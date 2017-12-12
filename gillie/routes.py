from paste.deploy.converters import asbool

def includeme(config):
    settings = config.get_settings()

    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view('assets', '../assets', cache_max_age=3600)

    config.add_route('home', '/')
    config.add_route('apps', '/app/{appname}')
    config.add_route('admin', '/admin')
    
    config.add_route('login', '/login')
    config.add_route('auth_refresh', '/auth/refresh')
    config.add_route('auth_chpass', '/auth/chpass')


    config.add_view('.views.auth.login', route_name='login',
                    request_method='POST', renderer='json')
    config.add_view('.views.auth.refresh', route_name='auth_refresh',
                    request_method='GET', renderer='json')
    config.add_view('.views.auth.chpass', route_name='auth_chpass',
                    request_method='POST', renderer='json')

    use_pj = asbool(settings.get('api.use_pyramid_jsonapi', False))
    # FIXME jsonapi has "notfound" view
    #scan_views = ['notfound', 'sitecontent', 'userauth', 'todos']
    scan_views = ['sitecontent', 'auth', 'todos',
                  'client',
                  'useradmin',
                  'wikipages',
                  'ebcsv',]
    if not use_pj:
        scan_views.append('notfound')
    for view in scan_views:
        config.scan('.views.%s' % view)

    
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

