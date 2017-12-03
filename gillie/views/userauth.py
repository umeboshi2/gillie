from pyramid.response import Response
from pyramid.view import view_config
import pyramid.httpexceptions as exc

from sqlalchemy.exc import DBAPIError
import transaction
from trumpet.util import password_matches, encrypt_password

from ..models.mymodel import User
from ..util import make_token

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


def chpass(request):
    if request.authenticated_userid:
        pw = request.json['password']
        if pw != request.json['confirm']:
            raise exc.HTTPForbidden()
        user = request.user
        with transaction.manager:
            user.password = encrypt_password(request.json['password'])
            request.dbsession.add(user)
        return dict(result='ok',
                    token=make_token(request, request.user))
    raise exc.HTTPUnauthorized()
    
def refresh(request):
    if request.authenticated_userid:
        return dict(result='ok',
                    token=make_token(request, request.user))
    raise exc.HTTPUnauthorized()
    
