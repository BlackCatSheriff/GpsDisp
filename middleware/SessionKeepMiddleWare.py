from django.utils.deprecation import MiddlewareMixin
from django.http import HttpResponseRedirect
from django.urls import reverse


class RequestLogMiddleWare(MiddlewareMixin):
    def process_request(self, request):
        _url = request.get_full_path()
        if not(("login" in _url) or ("admin" in _url) or (reverse("upload_interface") in _url)):
            online = request.session.get('__uer_id', None)
            if online is None:
                request.session.flush()
                return HttpResponseRedirect(reverse("login_page"))

