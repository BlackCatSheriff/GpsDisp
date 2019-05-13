/**
 * Created by www on 2018/10/21.
 */

var STATIC_URL;
var img_url = new Array();
img_url['on'] = "images/icon-yes.svg";
img_url['off'] = "images/icon-no.svg";
img_url['wait'] = "images/icon-unknown.svg";
img_url['overtime'] = "images/icon-alert.svg";


$(document).ready(function(){

    $.get('/server/',{'config':'static_url'},function (data) {
       STATIC_URL=data;
    });

    $(".single-disp").parent().parent().parent().on("click","a",function(event){
        var target = $(event.target);
        var img = target.siblings("img");
        var input = target.siblings("input");
        if(target.attr('_forbidden')=="true"){
            alert('正在通信...请稍后...');
            return false;
        }
        refresh(target, img, input);
    });

    init_devices();
});


function reload_all() {
    remove_overlay();

    $(".single-disp").each(function (i) {
        if (i!=0){
            $(this).click();
        }
    });
}


function refresh(a, img, input) {
    $.ajax({
        type: "GET",
        url: "/api/" + input.attr('_n'),
        beforeSend:function () {
            // alert("提交前");
            a.attr('_forbidden','true');
            img.attr("src", STATIC_URL+img_url['wait']);
        },
        dataType: "json",
        success: function(data){
            if(data['msg']==-2){
                img.attr('src', STATIC_URL+img_url['off']);
            }

            else if(data['msg']==0) {
                input.attr("_j", data['jd']);
                input.attr("_w", data['wd']);
                input.attr("_t", data['time']);
                img.attr('src', STATIC_URL+img_url['on']);
                var remark = "编号:"+input.attr('_n')+"<br>"+"经度:"+data['jd']+"<br>"+"维度:"+data['wd']+"<br>"+"最后更新时间:"+data['time'];
                var point_bundle = [[data['jd'], data['wd'], remark]];
                transPositions(point_bundle);
            }
            else
                img.attr('src', STATIC_URL+img_url['overtime']);

            a.attr('_forbidden','false');
        }


    });
}


function init_devices() {
    $.ajax({
        type: "GET",
        url: "/api/devices/",
        dataType: "json",
        success: function(data){
            var html = '';
            $.each(data['data'], function(commentIndex, comment){
                html+=`<li class="layui-nav-item"><div class="test"><a href="javascript:void(0);" class="single-disp">${comment['d_name']}</a><img src="${STATIC_URL+img_url['wait']}"><input  hidden _n="${comment['d_number']}" _j="0" _w="0" _t="0"></div></li>`;
            });
            $('#dispaly_panel').append(html);
            reload_all();
        }
    });

}


function login(s_data) {
         $.ajax({
        type: "POST",
        url: "/api/user/login/",
        dataType: "json",
        //headers:{ "X-CSRFtoken":$.cookie("csrftoken")},
        data:s_data,
        success: function(data){
            if(data["code"]==0){
               layer.msg("登陆成功！即将跳转...",function(){
location.href=data['url'];
                });
          }
          else
              layer.msg("登陆失败，请检查用户名，密码！")
        }
    });
}



function edit_user(s_data) {
        $.ajax({
        type: "PUT",
        url: "/api/user/",
        dataType: "json",
        //headers:{ "X-CSRFtoken":$.cookie("csrftoken")},
         data:s_data,
        success: function(data){
          if(data["code"] == 0)
                layer.msg("修改成功");
          else
                layer.msg("修改失败，请重试！");
        }
    });
}


function transPositions(data_info) {
    // 坐标转换
    var points = [];

    for(var i=0;i<data_info.length;i++){
        points.push(new BMap.Point(data_info[i][0],data_info[i][1]))
    }

    //坐标转换完之后的回调函数
    translateCallback = function (data){
      if(data.status === 0) {
        donepos=[]
        for (var i = 0; i < data.points.length; i++) {
              donepos.push(data.points[i]);
        }
        add_point_on_map(data_info,donepos);
      }
    };
    setTimeout(function(){
        var convertor = new BMap.Convertor();
        convertor.translate(points, 1, 5, translateCallback)
    }, 1000);
}

function add_point_on_map(data_info,transposs) {

    var opts = {
        width : 250,     // 信息窗口宽度
        height: 100,     // 信息窗口高度
        title : "设备信息" , // 信息窗口标题
        enableMessage:true//设置允许信息窗发送短息
    };

    for(var i=0;i<data_info.length;i++){
        var marker = new BMap.Marker(transposs[i]);  // 创建标注
        var content = data_info[i][2];
        map.addOverlay(marker);               // 将标注添加到地图中
        addClickHandler(content,marker);
    }

    function addClickHandler(content,marker){
        marker.addEventListener("click",function(e){
            openInfo(content,e)}
        );
    }
    function openInfo(content,e) {
        var p = e.target;
        var point = new BMap.Point(p.getPosition().lng, p.getPosition().lat);
        var infoWindow = new BMap.InfoWindow(content, opts);  // 创建信息窗口对象
        map.openInfoWindow(infoWindow, point); //开启信息窗口
    }

    map.panTo(new BMap.Point(data_info[0][0],data_info[0][1]));
    // map.setZoom(15);
}

function remove_overlay(){
    map.clearOverlays();
}