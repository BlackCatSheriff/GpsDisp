"""GpsDisp URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from webapp import views as main_view
from webapp import server_views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/<str:device_id>', main_view.get_gps),
    path('api/devices/', main_view.get_all_devices),
    path('api/device/', main_view.handler_device),
    path('api/anchor/', main_view.handler_anchor),
    path('api/anchors/', main_view.get_all_anchors),
    path('api/device/upload/', main_view.save_device_data,name="upload_interface"),
    path('api/device/upload/records/', main_view.review_upload_data,name="upload_interface_record"),
    path('api/user/', main_view.handler_user),
    path('api/user/logout/', main_view.user_logout),
    path('api/user/login/', main_view.user_login),
    path('server/', server_views.config),
    path('login', main_view.jump_login, name="login_page"),
    path('index', main_view.index, name='home_page'),
]
