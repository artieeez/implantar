from rest_framework import permissions
from checker.models import RegisterToken

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    Assumes the model instance has an `owner` attribute.
    """

    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            return True

        # Instance must have an attribute named `owner`.
        return obj.avaliador == request.user


class IsAssigned(permissions.BasePermission): 
    """
    Only person who assigned has permission
    """

    def has_object_permission(self, request, view, obj):
		# check if user who launched request is object owner 
        if request.user.groups.filter(name = 'operador').exists():
            return True
        else:
            if request.user in obj.assigned: 
                return True
            else:
                return False


class IsOperador(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.user.groups.filter(name = 'operador').exists():
            return True
        return False


class HasRegisterToken(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.user.groups.filter(name = 'operador').exists():
            return True
        registerToken = request.query_params.get('register-token', None)
        if registerToken is not None:
            exists = RegisterToken.objects.filter(token=registerToken).exists()
            return exists
        return False


class EoProprioUsuario(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in permissions.SAFE_METHODS:
            print("safe method")
            return True

        # Instance must have an attribute named `owner`.
        print(obj == request.user)
        return obj == request.user

