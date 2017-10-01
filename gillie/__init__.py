from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_jinja2')
    config.include('cornice')
    config.include('.models')
    config.include('.routes')
    orig_views = ['default', 'notfound']
    for view in orig_views:
        config.scan('.views.%s' % view)
    new_views = ['sitecontent']
    for view in new_views:
        config.scan('.views.%s' % view)
    return config.make_wsgi_app()
