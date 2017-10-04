import os
import json

from pyramid.renderers import render
from pyramid.response import Response

from pyramid.httpexceptions import HTTPNotFound
from pyramid.httpexceptions import HTTPFound
from pyramid.httpexceptions import HTTPForbidden

from pyramid.security import remember, forget

from .base import BaseUserViewCallable

from .util import check_login_form

class MyResource(object):
    def __init__(self, name, parent=None):
        self.__name__ = name
        self.__parent__ = parent

def get_manifest(settings):
    jspath = settings.get('default.js.path', '/assets/client')
    while jspath.startswith('/'):
        jspath = jspath[1:]
    # FIXME - find a better way
    views_dirname = os.path.dirname(__file__)
    repodir = os.path.abspath(os.path.join(views_dirname, '../../'))
    filename = os.path.join(repodir, jspath, 'manifest.json')
    if not os.path.isfile(filename):
        raise RuntimeError, "No manifest.json!"
    return json.load(file(filename))

def make_page(appname, settings, basecolor=None, request=None):
    template = 'gillie:templates/mainview.mako'
    if basecolor is None:
        basecolor = settings.get('default.css.basecolor', 'BlanchedAlmond')
    csspath = settings.get('default.css.path', '/assets/stylesheets')
    jspath = settings.get('default.js.path', '/assets/client')
    manifest = get_manifest(settings)
    env = dict(appname=appname,
               basecolor=basecolor,
               csspath=csspath,
               jspath=jspath,
               manifest=manifest)
    return render(template, env, request=request)
    
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
            if view == 'logout':
                return self.handle_logout()
            elif view == 'login':
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
        content = make_page(appname, settings, basecolor=basecolor,
                            request=self.request)
        self.response = Response(body=content)
        self.response.encode_content()
        
    def handle_login(self, post):
        if check_login_form(self.request):
            username = post['username']
            headers = remember(self.request, username)
        self.response = HTTPFound('/')


    def handle_logout(self):
        headers = forget(self.request)
        if 'user' in self.request.session:
            del self.request.session['user']
        while self.request.session.keys():
            key = self.request.session.keys()[0]
            del  self.request.session[key]
        location = self.request.route_url('home')
        self.response = HTTPFound(location=location, headers=headers)

    def handle_post(self):
        request = self.request
        view = request.view_name
        post = request.POST
        if view == 'login':
            return self.handle_login(post)
        elif view == 'logout':
            return self.handle_logout()
        else:
            raise HTTPNotFound, 'nope'
        
        
