/**
 * Created by www on 2018/10/23.
 */



function add_anchor(s_data) {
    for (var prop in s_data) {
        if(str_isEmpty(s_data[prop])){
            layer.msg("请输入内容！");
            return false;
        }
    }

      $.ajax({
        type: "POST",
        url: "/api/anchor/",
        dataType: "json",
        //headers:{ "X-CSRFtoken":$.cookie("csrftoken")},
         data:JSON.stringify(s_data),
        success: function(data){
          if(data["code"]== 0){
                layer.msg("添加成功！");

          }
          else if(data["code"] == 1)
                layer.msg("添加失败，请检查坐标系编号，不可以重复！");
          else
              layer.msg("服务器繁忙，请重试！");
        }
    });
    return false;
}



function add_device(s_data) {
    var flag=0;
    var len=Object.keys(s_data).length;
    for (var prop in s_data) {
        if(len==4 && flag==2) break;
        if(str_isEmpty(s_data[prop])){
            layer.msg("请输入内容！");
            return false;
        }
        flag++;
    }

      $.ajax({
        type: "POST",
        url: "/api/device/",
        dataType: "json",
        //headers:{ "X-CSRFtoken":$.cookie("csrftoken")},
         data:JSON.stringify(s_data),
        success: function(data){
          if(data["code"]== 0){
                layer.msg("添加成功！",function () {
                    window.parent.location.href = '/index';
                });

          }
          else if(data["code"] == 1)
                layer.msg("添加失败，请检查设备编号，不可以重复！");
          else
              layer.msg("服务器繁忙，请重试！");
        }
    });
    return false;
}


function del_device(id) {
        $.ajax({
        type: "DELETE",
        url: "/api/" + id,
        dataType: "json",
        //headers:{ "X-CSRFtoken":$.cookie("csrftoken")},
        success: function(data){
          if(data["msg"]==1){
             layer.msg("删除成功,即将自动重新获取!", function () {
                 window.parent.location.href = '/index';
             });

          }
          else
               layer.msg("删除失败，请重试！");

        }
    });
}


function del_anchor(a_id) {
        $.ajax({
        type: "DELETE",
        url: "/api/anchor/",
        dataType: "json",
        //headers:{ "X-CSRFtoken":$.cookie("csrftoken")},
            data:{"a_id":a_id},
            success: function(data){
          if(data["code"]==0){
             layer.msg("删除成功,即将自动重新获取!");

          }
          else
               layer.msg("删除失败，请重试！");

        }
    });
}


function str_isEmpty(str) {

return (!str || /^\s*$/.test(str))

}
