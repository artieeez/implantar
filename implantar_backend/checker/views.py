from checker.models import Pessoa, Rede, Ponto, Visita, ItemBase
from checker.serializers import PessoaSerializer, RedeSerializer
from checker.serializers import PontoSerializer, VisitaSerializer
from checker.serializers import ItemBaseSerializer, AvaliadorSerializer
from checker.serializers import AvaliadorCreateSerializer, AvaliadorPasswordSerializer, AvaliadorUsernameSerializer
from rest_framework import generics, renderers, viewsets
from django.contrib.auth.models import User
from rest_framework import permissions
from rest_framework.decorators import api_view, action
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination, LimitOffsetPagination
from rest_framework import status
from rest_framework import permissions

# Auth
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.permissions import IsAuthenticated, IsAdminUser, AllowAny


class AvaliadorViewSet(viewsets.ModelViewSet):
    queryset = User.objects.exclude(profile__isnull=True)
    serializer_class = AvaliadorSerializer

    @action(detail=True, methods=['put'])
    def password(self, request, pk, format=None):
        if request.method == 'PUT':
            user = self.get_object()
            serializer = AvaliadorPasswordSerializer(user, data=request.data)
            if serializer.is_valid():
                # Check old password
                if not user.check_password(serializer.validated_data.get("old_password")):
                    return Response({"old_password": ["Senha incorreta"]}, status=status.HTTP_400_BAD_REQUEST)
                # set_password also hashes the password that the user will get
                user.set_password(serializer.validated_data.get("new_password"))
                user.save()
                response = {
                    'status': 'success',
                    'code': status.HTTP_200_OK,
                    'message': 'Senha alterada.',
                    'data': []
                }
                return Response(response)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['put'])
    def username(self, request, pk, format=None):
        if request.method == 'PUT':
            user = self.get_object()
            serializer = AvaliadorUsernameSerializer(user, data=request.data)
            if serializer.is_valid():
                # Check old password
                if not user.check_password(serializer.validated_data.get("password")):
                    return Response({"password": ["Senha incorreta"]}, status=status.HTTP_400_BAD_REQUEST)
                # set_password also hashes the password that the user will get
                user.username = serializer.validated_data.get("username")
                user.save()
                response = {
                    'status': 'success',
                    'code': status.HTTP_200_OK,
                    'message': 'Username alterado.',
                    'data': []
                }
                return Response(response)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get_serializer_class(self):
        serializer_class = self.serializer_class

        if self.request.method == 'POST':
            serializer_class = AvaliadorCreateSerializer
        if self.request.method == 'PUT':
            serializer_class = AvaliadorSerializer
        if self.action == 'password':
            serializer_class = AvaliadorPasswordSerializer
        if self.action == 'username':
            serializer_class = AvaliadorUsernameSerializer

        return serializer_class

    def get_permissions(self):
        if self.request.method == 'DELETE':
            permission_classes = [IsAdminUser]
        elif self.request.method == 'POST':
            permission_classes = [AllowAny]
        else:
            permission_classes = [AllowAny]
            # TODO
            """ return [IsStaffOrTargetUser()] """
        return [permission() for permission in permission_classes]


class RedeViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = Rede.objects.all()
    serializer_class = RedeSerializer

    @action(detail=True, methods=['get'])
    def pontos(self, request, pk, format=None):
        if request.method == 'GET':
            self.serializer_class = PontoSerializer
            queryset = Rede.objects.get(id=pk).pontos.all()
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)


class PontoViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.
    """
    queryset = Ponto.objects.all()
    serializer_class = PontoSerializer


class ItemBaseViewSet(viewsets.ModelViewSet):
    queryset = ItemBase.objects.all()
    serializer_class = ItemBaseSerializer

    @action(detail=False, methods=['get'])
    def active(self, request):
        self.queryset = ItemBase.objects.filter(active=True)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)




class MyPaginationMixin(object):
    """
    Retirado de rest_framework.generics.GenericAPIView
    """
    @property
    def paginator(self):
        """
        The paginator instance associated with the view, or `None`.
        """
        if not hasattr(self, '_paginator'):
            if self.pagination_class is None:
                self._paginator = None
            else:
                self._paginator = self.pagination_class()
        return self._paginator

    def paginate_queryset(self, queryset):
        """
        Return a single page of results, or `None` if pagination 
        is disabled.
        """
        if self.paginator is None:
            return None
        return self.paginator.paginate_queryset(
            queryset, self.request, view=self)

    def get_paginated_response(self, data):
        """
        Return a paginated style `Response` object for the given 
        output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data)


class pontosList(APIView, MyPaginationMixin):
    """ 
        EXEMPLO

        Exemplo de classe com APIView implementando paginação.
    """
    authentication_classes = [TokenAuthentication, SessionAuthentication]
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination
    serializer_class = PontoSerializer

    def get(self, request, pk, format=None):
        """
        Return a list of all users.
        """
        queryset = Rede.objects.get(id=pk).pontos.all()
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.serializer_class(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)