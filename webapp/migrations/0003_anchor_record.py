# Generated by Django 2.1.2 on 2018-10-30 15:48

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('webapp', '0002_manager'),
    ]

    operations = [
        migrations.CreateModel(
            name='Anchor',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('a_id', models.CharField(max_length=64, unique=True, verbose_name='坐标系ID')),
                ('a_gps_jd', models.CharField(max_length=64, verbose_name='经度')),
                ('a_gps_wd', models.CharField(max_length=64, verbose_name='维度')),
            ],
            options={
                'verbose_name': '参考坐标系',
                'verbose_name_plural': '参考坐标系',
            },
        ),
        migrations.CreateModel(
            name='Record',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('a_gps_jd', models.CharField(max_length=64, verbose_name='经度')),
                ('a_gps_wd', models.CharField(max_length=64, verbose_name='维度')),
                ('a_update_time', models.DateField(auto_now_add=True, verbose_name='录入时间')),
                ('r_device_id', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='webapp.Device', verbose_name='设备')),
            ],
        ),
    ]
