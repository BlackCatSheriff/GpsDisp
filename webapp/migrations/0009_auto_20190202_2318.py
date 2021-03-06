# Generated by Django 2.1.2 on 2019-02-02 15:18

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('webapp', '0008_auto_20181108_2248'),
    ]

    operations = [
        migrations.CreateModel(
            name='RowUpload',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('update_time', models.DateTimeField(auto_now_add=True, verbose_name='上传时间')),
                ('content', models.TextField(default='', verbose_name='上传内容')),
                ('successful', models.BooleanField(default=False, verbose_name='是否合法')),
                ('remark', models.CharField(default='', max_length=256, verbose_name='备注')),
                ('device_id', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='webapp.Device', verbose_name='设备')),
            ],
            options={
                'verbose_name': '上传原始记录',
                'verbose_name_plural': '上传原始记录',
            },
        ),
        migrations.AlterField(
            model_name='record',
            name='a_gps_wd',
            field=models.CharField(max_length=64, verbose_name='纬度'),
        ),
    ]
