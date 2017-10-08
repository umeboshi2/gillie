import os

from sqlalchemy.orm.exc import NoResultFound



#@resource(**make_resource(path, ident='name'))
def make_resource(rpath, ident='id', cross_site=True):
    path = os.path.join(rpath, '{%s}' % ident)
    data = dict(collection_path=rpath, path=path)
    if cross_site:
        data['cors_origins'] = ('*',)
    return data

def make_app_page(appname, settings, basecolor=None, request=None):
    template = 'gillie:templates/mainview.mako'
    if basecolor is None:
        basecolor = settings.get('default.css.basecolor', 'vanilla')
    csspath = settings.get('default.css.path', '/assets/stylesheets')
    jspath = settings.get('default.js.path', '/assets/client')
    env = dict(appname=appname,
               basecolor=basecolor,
               csspath=csspath,
               jspath=jspath)
    return render(template, env, request=request)
    
