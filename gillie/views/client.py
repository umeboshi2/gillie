from pyramid.view import view_config, view_defaults
from pyramid.response import Response

from pyramid.httpexceptions import HTTPNotFound
from pyramid.httpexceptions import HTTPFound
from pyramid.httpexceptions import HTTPForbidden

from pyramid.security import remember, forget
from trumpet.views.client import BaseClientView 

from .base import BaseUserViewCallable
from .util import make_app_page

class MyResource(object):
    def __init__(self, name, parent=None):
        self.__name__ = name
        self.__parent__ = parent

class ClientView(BaseClientView):
    @view_config(route_name='home')
    def index(self):
        self.data['appname'] = self.settings.get('default.js.mainapp', 'index')
        return self.data
        
    @view_config(route_name='admin')
    def admin(self):
        self.data['appname'] = self.settings.get('default.js.admin_app', 'admin')
        return self.data
        
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
                raise HTTPNotFound("no such animal")
        elif view == 'admin':
            appname = settings.get('default.js.admin_app', 'admin')
            basecolor = settings.get('default.admin.basecolor', 'DarkSeaGreen')
            self.get_main(appname=appname, basecolor=basecolor)
        else:
            raise HTTPNotFound('no way')
        
    def get_main(self, appname=None, basecolor=None):
        settings = self.get_app_settings()
        if appname is None:
            appname = settings.get('default.js.mainapp', 'frontdoor')
        content = make_app_page(appname, settings, basecolor=basecolor,
                            request=self.request)
        self.response = Response(body=content)
        self.response.encode_content()
        
