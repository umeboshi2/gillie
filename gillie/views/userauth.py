from pyramid.response import Response
from pyramid.view import view_config
import pyramid.httpexceptions as exc

from sqlalchemy.exc import DBAPIError

from ..models.mymodel import User
from ..util import password_matches, make_token

def authenticate(request, login, password):
    s = request.dbsession
    q = s.query(User)
    user = q.filter_by(username=login).first()
    if user is not None and password_matches(user, password):
        return user
    else:
        return None

def login(request):
    login = request.POST['username']
    password = request.POST['password']
    user = authenticate(request, login, password)
    if user:
        return {
            'result': 'ok',
            'token': make_token(request, user)
        }
    else:
        raise exc.HTTPUnauthorized()


def refresh(request):
    if request.authenticated_userid:
        return dict(result='ok',
                    token=make_token(request, request.user)
        )
    else:
        raise exc.HTTPUnauthorized()
    
