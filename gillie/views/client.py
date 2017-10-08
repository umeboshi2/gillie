from pyramid.renderers import render
from pyramid.response import Response

from pyramid.httpexceptions import HTTPNotFound
from pyramid.httpexceptions import HTTPFound
from pyramid.httpexceptions import HTTPForbidden

from pyramid.security import remember, forget

from .base import BaseUserViewCallable
from .util import make_app_page

class MyResource(object):
    def __init__(self, name, parent=None):
        self.__name__ = name
        self.__parent__ = parent

class ClientView(BaseUserViewCallable):
    def __init__(self, request):
        super(ClientView, self).__init__(request)
        if request.method == 'POST':
            self.handle_post()
        else:
            self.handle_get()

    def handle_get(self):
        request = self.request
        view = request.view_name
        subpath = request.subpath
        settings = self.get_app_settings()
        if not view:
            route = request.matched_route.name
            if route == 'home':
                self.get_main()
                return
            elif route == 'apps':
                self.get_main(appname=request.matchdict['appname'])
                return
            else:
                raise HTTPNotFound, "no such animal"
        elif view in ['login', 'logout']:
            if view == 'login':
                appname = settings.get('default.js.login_app', 'login')
                self.get_main(appname=appname)
                return
        elif view == 'admin':
            appname = settings.get('default.js.admin_app', 'admin')
            basecolor = settings.get('default.admin.basecolor', 'DarkSeaGreen')
            self.get_main(appname=appname, basecolor=basecolor)
        else:
            raise HTTPNotFound, 'no way'
        
    def get_main(self, appname=None, basecolor=None):
        settings = self.get_app_settings()
        if appname is None:
            appname = settings.get('default.js.mainapp', 'frontdoor')
        content = make_app_page(appname, settings, basecolor=basecolor,
                            request=self.request)
        self.response = Response(body=content)
        self.response.encode_content()
        
