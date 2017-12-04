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

    config.include('.routes')

    config.add_route('meeting_calendar', '/rest/v0/main/hubcal')
    config.add_view('hubby.views.main.MeetingCalendarViewer',
                    route_name='meeting_calendar',
                    renderer='json',)
    
    config.add_route('meeting_calendar_ts', '/hubcal1')
    config.add_view('hubby.views.main.MeetingCalendarViewer',
                    route_name='meeting_calendar_ts',
                    renderer='json',)
    
    hubby_views = ['basic', 'main']
    for view in hubby_views:
        config.scan('hubby.views.{}'.format(view))

    #config.add_route('clzcore', '/clzcore/*path')
    #config.add_view('.views.wikipages.get_clzpage', route_name='clzcore')
    
    config.set_request_property('.util.get_user', 'user', reify=True)
    
    
    application = config.make_wsgi_app()
    # add wsgi middleware here
    
    return application
