from .models.usergroup import User

def make_token(request, user):
    claims = dict(name=user.username, fullname=user.fullname,
                  email=user.email, uid=user.id,
                  groups=user.get_groups())
    return request.create_jwt_token(user.id, **claims)


def get_user(request):
    userid = request.unauthenticated_userid
    return request.dbsession.query(User).get(userid)
    
