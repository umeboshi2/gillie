import os
import datetime

from paste.deploy.converters import asbool
from pyramid.config import Configurator
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.renderers import JSON

import pyramid_jsonapi

from .models import mymodel

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
    renderer.add_adapter(datetime.date, lambda obj, request: obj.isoformat())
    config.add_renderer('json', renderer)
    
    use_pj = asbool(settings.get('api.use_pyramid_jsonapi', False))
    if use_pj:
        pj = pyramid_jsonapi.PyramidJSONAPI(config, mymodel)
        ep = pj.endpoint_data.endpoints
    
        pj.create_jsonapi()
    
    # FIXME make tests
    JWT_SECRET = os.environ.get('JWT_SECRET', 'secret')
    config.set_jwt_authentication_policy(JWT_SECRET,
                                         callback=groupfinder)
    
    authz_policy = ACLAuthorizationPolicy()
    config.set_authorization_policy(authz_policy)


    config.add_route('home', '/')
    config.add_route('apps', '/app/{appname}')
    config.add_route('admin', '/admin')
    
    config.add_route('login', '/login')
    config.add_route('auth_refresh', '/auth/refresh')

    config.add_view('.views.userauth.login', route_name='login',
                    request_method='POST', renderer='json')
    config.add_view('.views.userauth.refresh', route_name='auth_refresh',
                    request_method='GET', renderer='json')

    #scan_views = ['notfound', 'sitecontent', 'userauth', 'todos']
    # FIXME jsonapi has "notfound" view
    scan_views = ['sitecontent', 'userauth', 'todos',
                  'client',
                  'ebcsv',
                  'wikipages',]
    if not use_pj:
        scan_views.append('notfound')
    for view in scan_views:
        config.scan('.views.%s' % view)

    
    #config.add_route('clzcore', '/clzcore/*path')
    #config.add_view('.views.wikipages.get_clzpage', route_name='clzcore')
    
    config.set_request_property('.util.get_user', 'user', reify=True)
    
    
    application = config.make_wsgi_app()
    # add wsgi middleware here
    
    return application
