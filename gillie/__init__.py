from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_jinja2')
    config.include('pyramid_mako')
    config.include('cornice')
    config.include('.models')
    config.include('.routes')
    #orig_views = ['default', 'notfound']
    orig_views = ['notfound']
    for view in orig_views:
        config.scan('.views.%s' % view)
    new_views = ['sitecontent']
    for view in new_views:
        config.scan('.views.%s' % view)
    client_view = '.views.client.ClientView'
    config.add_route('home', '/')
    config.add_route('apps', '/app/{appname}')
    config.add_view(client_view, route_name='home')
    config.add_view(client_view, route_name='apps')
    config.add_view(client_view, name='login')
    config.add_view(client_view, name='logout')
    
    return config.make_wsgi_app()
