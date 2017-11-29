import bcrypt

from .models.usergroup import User

def encrypt_password(password):
    if type(password) is str:
        password = password.encode()
    hashed = bcrypt.hashpw(password, bcrypt.gensalt())
    return hashed.decode()

def password_matches(user, password):
    hashed = user.password
    if type(hashed) is str:
        hashed = hashed.encode()
    if type(password) is str:
        password = password.encode()
    return bcrypt.checkpw(password, hashed)

def make_token(request, user):
    claims = dict(name=user.username, fullname=user.fullname,
                  email=user.email, uid=user.id,
                  groups=user.get_groups())
    return request.create_jwt_token(user.id, **claims)


def get_user(request):
    userid = request.unauthenticated_userid
    return request.dbsession.query(User).get(userid)
    
