import GpsDisp.settings as web_settings
from django.http import HttpResponse

# Create your views here.


def get_static_url():
    return web_settings.STATIC_URL


def config(requests):
    handler = requests.GET.get('config', None)
    if handler:
        if handler == 'static_url':
            return HttpResponse(get_static_url())
        elif handler == 'test_git':
            return HttpResponse('return git update!!!!!!!!!!!!!!')
        else:
            HttpResponse(status=403)
    else:
        return HttpResponse(status=403)

