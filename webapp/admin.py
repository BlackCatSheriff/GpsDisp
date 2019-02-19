from django.contrib import admin
from webapp.models import Device, Manager, Anchor, Record,RowUpload

# Register your models here.


@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ['d_name', 'd_number', 'd_located_style']


@admin.register(Manager)
class ManagerAdmin(admin.ModelAdmin):
    list_display = ['m_name', 'm_pwd']


@admin.register(Record)
class ManagerAdmin(admin.ModelAdmin):
    list_display = ['r_device_id', 'a_gps_jd', 'a_gps_wd', 'a_update_time']
    list_filter = ['r_device_id']


@admin.register(Anchor)
class ManagerAdmin(admin.ModelAdmin):
    list_display = ['a_name', 'a_id', 'a_gps_jd', 'a_gps_wd']

@admin.register(RowUpload)
class RowUploadAdmin(admin.ModelAdmin):
    list_filter = ['successful','device_id']
    list_display =['device_id','successful','remark']
