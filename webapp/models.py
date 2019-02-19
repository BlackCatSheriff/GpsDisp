from django.db import models


# Create your models here.


class Device(models.Model):
    CHOICE_SOURCE = (
        ('0', 'absolute'),
        ('1', 'relative'),
    )

    d_name = models.CharField('设备名字', max_length=64)
    d_number = models.CharField('设备编号', max_length=128)
    d_located_style = models.CharField('定位方式', choices=CHOICE_SOURCE, max_length=32)
    d_CONST_A = models.CharField('特征值A', max_length=64, default='')
    d_CONST_N = models.CharField('特征值N', max_length=64, default='')

    def __str__(self):
        return self.d_name

    class Meta:
        verbose_name = '设备'
        verbose_name_plural = '设备'


class Manager(models.Model):
    m_name = models.CharField('管理员名字', max_length=64, unique=True)
    m_pwd = models.CharField('管理员密码', max_length=128)

    def __str__(self):
        return self.m_name

    class Meta:
        verbose_name = '管理员'
        verbose_name_plural = '管理员'


class Anchor(models.Model):
    a_name = models.CharField('坐标系名称', max_length=512, default='')
    a_id = models.CharField('坐标系ID', max_length=64, unique=True)
    a_gps_jd = models.CharField('经度', max_length=64)
    a_gps_wd = models.CharField('维度', max_length=64)
    a_x_length = models.CharField('X长', max_length=64, default='')
    a_y_length = models.CharField('Y长', max_length=64, default='')
    a_tangle = models.CharField('角度', max_length=64, default='')

    def __str__(self):
        return self.a_id

    class Meta:
        verbose_name = '参考坐标系'
        verbose_name_plural = '参考坐标系'


class Record(models.Model):
    r_device_id = models.ForeignKey(Device, verbose_name='设备', on_delete=models.CASCADE)
    a_gps_jd = models.CharField('经度', max_length=64)
    a_gps_wd = models.CharField('纬度', max_length=64)
    a_update_time = models.DateTimeField('录入时间', auto_now_add=True)

    def __str__(self):
        return self.r_device_id.d_number

    class Meta:
        verbose_name = '记录'
        verbose_name_plural = '记录'


class RowUpload(models.Model):
    device_id = models.ForeignKey(Device, verbose_name='设备', null=True, blank=True, on_delete=models.SET_NULL)
    update_time = models.DateTimeField('上传时间', auto_now_add=True)
    content = models.TextField('上传内容', default='')
    successful = models.BooleanField('是否合法', default=False)
    remark = models.CharField('备注', max_length=256, default='')

    def __str__(self):
        return self.device_id.d_number

    class Meta:
        verbose_name = '上传原始记录'
        verbose_name_plural = '上传原始记录'
