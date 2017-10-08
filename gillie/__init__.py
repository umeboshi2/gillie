import os
from pyramid.config import Configurator
from pyramid.authorization import ACLAuthorizationPolicy

from ziggurat_foundations.models import groupfinder

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_jinja2')
    config.include('pyramid_mako')
    config.include('cornice')
    config.include('.models')
    config.include('.routes')

    # FIXME make tests
    JWT_SECRET = os.environ.get('JWT_SECRET', 'secret')
    config.set_jwt_authentication_policy(JWT_SECRET,
                                         callback=groupfinder)
    
    authz_policy = ACLAuthorizationPolicy()
    config.set_authorization_policy(authz_policy)

    scan_views = ['notfound', 'sitecontent', 'userauth', 'todos']
    for view in scan_views:
        config.scan('.views.%s' % view)
    client_view = '.views.client.ClientView'
    config.add_route('home', '/')
    config.add_route('apps', '/app/{appname}')
    config.add_view(client_view, route_name='home')
    config.add_view(client_view, route_name='apps')

    lview = '.views.userauth.login'
    config.add_route('login', '/login')
    config.add_view(lview, route_name='login', request_method='POST',
                    renderer='json')

    config.add_route('auth_refresh', '/auth/refresh')
    config.add_view('.views.userauth.refresh', route_name='auth_refresh',
                    request_method='GET', renderer='json')
    
    return config.make_wsgi_app()
