# # from django.test import TestCase
# from GpsDisp.wsgi import *
# from webapp.models import Device
#
# # Create your tests here.
#
# # for i in Device.objects.all():
# #     print(i)

import subprocess

import os
sts='call_exe.exe 111 60 1 1 1 1 1 1 1 1 1'

aaa=subprocess.getoutput(os.path.join(os.path.dirname(os.path.abspath(__file__)),sts))




print(aaa)