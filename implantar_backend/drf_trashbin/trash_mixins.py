from django.http import Http404
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser


class SendToTrashModelMixin:
    """
    Requires 'in_trash' boolean filed in model
    Send a model to trash.
    """
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if hasattr(instance, 'in_trash'):
            self.perform_destroy(instance)
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            assert('Acrescente o boolean field "in_trash" ao model.')

    def perform_destroy(self, instance):
        instance.in_trash = True
        instance.save()


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
            if hasattr(instance, 'in_trash'):
                self.perform_restore(instance)
                return Response(status=status.HTTP_204_NO_CONTENT)
            else:
                assert('Acrescente o boolean field "in_trash" ao model.')

    def perform_restore(self, instance):
        instance.in_trash = False
        instance.save()
