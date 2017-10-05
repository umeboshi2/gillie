from ziggurat_foundations.permissions import permission_to_pyramid_acls

class ResourceFactory(object):
    def __init__(self, request):
        self.__acl__ = []
        rid = request.matchdict.get("resource_id")

        if not rid:
            raise HTTPNotFound()
        self.resource = Resource.by_resource_id(rid)
        if not self.resource:
            raise HTTPNotFound()
        if self.resource and request.user:
            # append basic resource acl that gives all permissions to owner
            self.__acl__ = self.resource.__acl__
            # append permissions that current user may have for this context resource
            permissions = self.resource.perms_for_user(request.user)
            for outcome, perm_user, perm_name in permission_to_pyramid_acls(
                    permissions):
                self.__acl__.append((outcome, perm_user, perm_name,))

                
