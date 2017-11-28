import os
import datetime

from pyramid.config import Configurator
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.renderers import JSON

import pyramid_jsonapi

from .models import mymodel

def datetime_adapter(obj, request):
    return obj.isoformat()


def groupfinder(userid, request):
    """
    Default groupfinder implementaion for pyramid applications

    :param userid:
    :param request:
    :return:
    """
    if userid and hasattr(request, 'user') and request.user:
        groups = ['group:%s' % g.id for g in request.user.groups]
        return groups
    return []
    
def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_jinja2')
    config.include('pyramid_mako')
    config.include('cornice')
    config.include('.models')
    config.include('.routes')

    renderer = JSON()
    #renderer.add_adapter(datetime.date, datetime_adapter)
    renderer.add_adapter(datetime.date, lambda obj, request: obj.isoformat())
    config.add_renderer('json', renderer)
    
    
    pj = pyramid_jsonapi.PyramidJSONAPI(config, mymodel)
    print(pj)
    print(('-'*88))
    print((dir(pj.endpoint_data)))
    print((pj.endpoint_data))
    ep = pj.endpoint_data.endpoints
    #import pdb ; pdb.set_trace()
    
    pj.create_jsonapi()
    
    # FIXME make tests
    JWT_SECRET = os.environ.get('JWT_SECRET', 'secret')
    config.set_jwt_authentication_policy(JWT_SECRET,
                                         callback=groupfinder)
    
    authz_policy = ACLAuthorizationPolicy()
    config.set_authorization_policy(authz_policy)

    #scan_views = ['notfound', 'sitecontent', 'userauth', 'todos']
    # FIXME jsonapi has "notfound" view
    scan_views = ['sitecontent', 'userauth', 'todos']
    for view in scan_views:
        config.scan('.views.%s' % view)
    client_view = '.views.client.ClientView'
    config.add_route('home', '/')
    config.add_route('apps', '/app/{appname}')
    config.add_route('admin', '/admin')
    
    #config.add_view(client_view, route_name='home')
    #config.add_view(client_view, route_name='apps')
    config.scan('.views.client')
    config.scan('.views.wikipages')
    
    lview = '.views.userauth.login'
    config.add_route('login', '/login')
    config.add_view(lview, route_name='login', request_method='POST',
                    renderer='json')

    config.add_route('auth_refresh', '/auth/refresh')
    config.add_view('.views.userauth.refresh', route_name='auth_refresh',
                    request_method='GET', renderer='json')
    
    return config.make_wsgi_app()
