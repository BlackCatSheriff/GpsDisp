import json

from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt

# Create your views here.
from webapp import socket
from webapp import utils
from webapp.models import Device, Manager, Anchor, Record, RowUpload

"""
按照
"""


@csrf_exempt
def get_gps(requests, device_id):
    # time.sleep()
    ENUM = {
        "GPS_SUCCESS": 0,
        "DELETE_SUCCESS": 1,
        "NOT_FOUND_DEVICE": -1,
        "DEVICE_OFFLINE": -2,
        "OVERTIME": -3,
        "SERVER_ERR": 500
    }
    # 默认服务器错误
    ans = {"msg": ENUM.get("SERVER_ERR")}
    try:
        d = Device.objects.get(d_number=device_id)
        if requests.method == 'DELETE':
            d.delete()
            ans["msg"] = ENUM.get("DELETE_SUCCESS")
        else:
            jd, wd, u_time, status = socket.get_actual_gps(d.id)
            if status:
                ans["msg"] = ENUM.get("GPS_SUCCESS")
            else:
                ans["msg"] = ENUM.get("DEVICE_OFFLINE")
            ans["jd"] = jd
            ans["wd"] = wd
            ans["time"] = u_time

    except Device.DoesNotExist:
        ans["msg"] = ENUM.get("NOT_FOUND_DEVICE")

    finally:
        return HttpResponse(json.dumps(ans), content_type="application/json")


def get_all_devices(requests):
    ans = {}
    ans['code'] = 0
    ans['data'] = list(Device.objects.all().values("d_name", "d_number", "d_CONST_A", "d_CONST_N"))
    return HttpResponse(json.dumps(ans))


def get_all_anchors(requests):
    ans = {}
    ans['code'] = 0
    ans['data'] = list(
        Anchor.objects.all().values("a_name", "a_id", "a_gps_jd", "a_gps_wd", "a_x_length", "a_y_length", "a_tangle"))
    return HttpResponse(json.dumps(ans))


@csrf_exempt
def handler_anchor(requests):
    ENUM = {
        "ADD_SUCCESS": 0,
        "EXIST": 1,
        "SERVER_ERR": 500
    }
    ans = dict()
    ans['code'] = ENUM.get('SERVER_ERR')
    if requests.method == 'POST':
        req = json.loads(requests.body.decode())
        try:
            Anchor.objects.get(a_id=req.get('a_id'))
            ans['code'] = ENUM.get('EXIST')
        except Anchor.DoesNotExist:
            a = Anchor()
            a.a_id = req.get('a_id')
            a.a_gps_jd = req.get('a_gps_jd')
            a.a_gps_wd = req.get('a_gps_wd')
            a.a_name = req.get('a_name')
            a.a_x_length = req.get('a_x_length')
            a.a_y_length = req.get('a_y_length')
            a.a_tangle = req.get('a_tangle')
            a.save()
            ans['code'] = ENUM.get('ADD_SUCCESS')
        finally:
            return HttpResponse(json.dumps(ans), content_type="application/json")
    elif requests.method == 'DELETE':
        try:
            a_id = str(requests.body).split('=')[1][:-1]
            a = Anchor.objects.get(a_id=a_id)
            a.delete()
            ans['code'] = 0
        finally:
            return HttpResponse(json.dumps(ans), content_type="application/json")

    else:
        return HttpResponse(status=403)


@csrf_exempt
def handler_device(requests):
    ENUM = {
        "ADD_SUCCESS": 0,
        "EXIST": 1,
        "SERVER_ERR": 500
    }
    ans = dict()
    ans['code'] = ENUM.get('SERVER_ERR')
    if requests.method == 'POST':
        req = json.loads(requests.body.decode())
        try:
            Device.objects.get(d_number=req.get('d_number'))
            ans['code'] = ENUM.get('EXIST')
        except Device.DoesNotExist:
            d = Device()
            d.d_name = req.get('d_name')
            d.d_number = req.get('d_number')
            d.d_located_style = req.get('d_located_style', '0')
            d.d_CONST_N = req.get('d_CONST_N')
            d.d_CONST_A = req.get('d_CONST_A')
            d.save()
            ans['code'] = ENUM.get('ADD_SUCCESS')
        finally:
            return HttpResponse(json.dumps(ans), content_type="application/json")
    else:
        return HttpResponse(status=403)


@csrf_exempt
def handler_user(requests):
    ans = dict()
    ans['code'] = -1
    # 修改用户密码
    if requests.method == 'PUT':
        req = json.loads(requests.body.decode())
        try:
            m = Manager.objects.get(m_name=req.get("username"))
            m.m_pwd = req.get('password')
            m.save()
            ans['code'] = 0
        finally:
            return HttpResponse(json.dumps(ans), content_type="application/json")
    else:
        return HttpResponse(status=403)


@csrf_exempt
def user_login(requests):
    ans = dict()
    ans['code'] = -1
    # 登陆请求
    if requests.method == 'POST':
        req = json.loads(requests.body.decode())
        try:
            Manager.objects.get(m_name=req.get("username"), m_pwd=req.get('password'))
            ans['code'] = 0
            ans['url'] = reverse("home_page")
            requests.session['__uer_id'] = req.get("username")
        finally:
            return HttpResponse(json.dumps(ans), content_type="application/json")
    else:
        return HttpResponse(status=403)


def user_logout(requests):
    requests.session.flush()
    return HttpResponseRedirect(reverse("login_page"))


def index(requests):
    return render(requests, "layui.html", {"username": requests.session.get('__uer_id', None)})


def jump_login(requests):
    return render(requests, 'login.html')


@csrf_exempt
def save_device_data(requests):
    code = "-1"
    rowUploadRecord = RowUpload()
    rowUploadRecord.device_id = "非法请求"
    rowUploadRecord.ip_address = utils.get_client_ip(requests)
    if requests.method == 'POST':
        try:
            rowUploadRecord.device_id = "load json error"
            post_data = json.loads(requests.body)
            rowUploadRecord.content = str(post_data)
            d = Device.objects.get(d_number=post_data.get('device_id'))
            rowUploadRecord.device_id = d.d_number
            r = Record()
            r.r_device_id = d

            if post_data.get('method') == "1":
                anchor_id = post_data.get('anchor_id')
                datapack = post_data.get('data')
                tmp_jd, tmp_wd = socket.calc_gps(anchor_id, d.d_number, datapack)
                r.a_gps_jd = tmp_jd
                r.a_gps_wd = tmp_wd
            else:
                r.a_gps_jd = post_data.get('gps_jd')
                r.a_gps_wd = post_data.get('gps_wd')
            r.save()
            rowUploadRecord.successful = True
            code = "0"
        except Exception as e:
            rowUploadRecord.remark = e.__str__()
        finally:
            rowUploadRecord.save()
            return HttpResponse(code)
    else:
        rowUploadRecord.remark = '无效请求,不是POST'
        rowUploadRecord.save()
        return HttpResponse(code)
