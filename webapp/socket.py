import datetime
import os
import subprocess

from webapp.models import Anchor, Record, Device


def get_actual_gps(device_id):
    jd, wd, u_time = 0, 0, 0
    status = False
    try:
        d = Record.objects.filter(r_device_id=device_id).order_by("-a_update_time").first()
        jd = d.a_gps_jd
        wd = d.a_gps_wd
        u_time = (d.a_update_time + datetime.timedelta(hours=8)).strftime("%Y-%m-%d %H:%M:%S")
        status = True
    finally:
        return jd, wd, u_time, status
        # jd = 120.38442818+ random.random()
        # wd = 36.1052149 + random.random()
        # return jd, wd, status


def calc_gps(anchor_id, device_id, datapack):
    datapack.sort(key=lambda x: (x['unique_id']))
    signals = []
    if len(datapack) < 4:
        raise RuntimeError('数据包信号数量不够')
    for i in range(4):
        if datapack[i].get('unique_id')[:5] != '00001':
            raise RuntimeError('数据包信号数量不够')
        signals.append(datapack[i].get('signal_intensity'))
    jd, wd = call_c_program(anchor_id, device_id, signals)
    if jd == 'NaN' or wd == 'NaN':
        raise RuntimeError('计算结果为NaN_jd:{}_wd:{}'.format(jd, wd))

    return jd, wd


def call_c_program(anchor_id, device_id, signals):
    a = Anchor.objects.get(a_id=anchor_id)
    d = Device.objects.get(d_number=device_id)
    # r_jd,r_wd = call_c(jd,wd,s_1,s_2,s_3,s_4,x_len,y_len,angle,A,N)
    sts = 'call_exe.exe {} {} {} {} {} {} {} {}'.format(
        a.a_gps_jd, a.a_gps_wd,
        ' '.join(signals),
        a.a_x_length, a.a_y_length,
        a.a_tangle,
        d.d_CONST_A, d.d_CONST_N
    )

    cmd_stdout = subprocess.getoutput(os.path.join(os.path.dirname(os.path.abspath(__file__)), sts))

    jd, wd = cmd_stdout.split(',')
    return jd, wd
