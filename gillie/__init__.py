import os
import datetime

from paste.deploy.converters import asbool
from pyramid.config import Configurator
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.renderers import JSON

import pyramid_jsonapi

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

    renderer = JSON()
    renderer.add_adapter(datetime.date, lambda obj, request: obj.isoformat())
    config.add_renderer('json', renderer)


    # FIXME make tests
    JWT_SECRET = os.environ.get('JWT_SECRET', 'secret')
    config.set_jwt_authentication_policy(JWT_SECRET,
                                         callback=groupfinder)

    authz_policy = ACLAuthorizationPolicy()
    config.set_authorization_policy(authz_policy)

    use_pj = asbool(settings.get('api.use_pyramid_jsonapi', False))
    if True or use_pj:
        from .models.usergroup import User, Group
        pj = pyramid_jsonapi.PyramidJSONAPI(config, [User, Group])
        # ep = pj.endpoint_data.endpoints
        pj.create_jsonapi()

    config.include('.routes')

    config.set_request_property('.util.get_user', 'user', reify=True)
    application = config.make_wsgi_app()
    # add wsgi middleware here

    return application
