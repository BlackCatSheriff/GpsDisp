# Generated by Django 2.1.2 on 2018-10-31 01:31

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('webapp', '0004_auto_20181031_0050'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='record',
            name='r_device_id',
        ),
        migrations.DeleteModel(
            name='Record',
        ),
    ]
