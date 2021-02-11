from django.http import Http404
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser


class TrashModelMixin:
    """
    Requires 'is_active' boolean filed in model
    Send a model to trash.
    """
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if hasattr(instance, 'is_active'):
            self.perform_destroy(instance)
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            assert('Acrescente o boolean field "is_active" ao model.')

    def perform_destroy(self, instance):
        instance.is_active = False
        instance.save()

    """
    Restores from model trash.
    """
    @action(detail=True, methods=['post']) # FIX ME METHOD NOT ALLOWED
    def restore(self, request, pk, format=None):
        if request.method == 'POST':
            instance = self.get_object()
            if hasattr(instance, 'is_active'):
                self.perform_restore(instance)
                return Response(status=status.HTTP_200_OK)
            else:
                assert('Acrescente o boolean field "is_active" ao model.')


class TrashMixin:
    permission_classes = [IsAdminUser]

    """
    Destroy a model instance.
    """
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)

    def perform_destroy(self, instance):
        instance.delete()

    """
    Restores from model trash.
    """
    @action(detail=True, methods=['post'])
    def restore(self, request, pk, format=None):
        if request.method == 'POST':
            instance = self.get_object()
            if hasattr(instance, 'is_active'):
                self.perform_restore(instance)
                return Response(status=status.HTTP_200_OK)
            else:
                assert('Acrescente o boolean field "is_active" ao model.')

    def perform_restore(self, instance):
        instance.is_active = True
        instance.save()
