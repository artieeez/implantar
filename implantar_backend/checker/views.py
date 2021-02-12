from checker.models import Rede, Ponto, Visita, Item, ItemBase
from checker.serializers import *
from rest_framework import generics, renderers, viewsets
from django.contrib.auth.models import User
from rest_framework.decorators import api_view, action
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination, LimitOffsetPagination
from rest_framework import status, permissions, mixins
from django.conf import settings
from drf_trashbin import trash_mixins

# DbVersion
from db_version import utils as db_version

# File upload
from rest_framework.parsers import MultiPartParser, FormParser


# Auth
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.permissions import IsAuthenticated, IsAdminUser, AllowAny
from checker.permissions import *


class CustomAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data,
                                           context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'id': user.pk,
            'first_name': user.first_name,
            'vCount': user.profile.vCount
        })


class RegisterTokenViewSet(viewsets.ModelViewSet):
    serializer_class = RegisterTokenSerializer
    queryset = RegisterToken.objects.all()

    @action(detail=True, methods=['get'])
    def verify(self, request, token, format=None):
        if request.method == 'GET':
            try:
                token = RegisterToken.objects.get(token=token)
                if not token.is_valid():
                    assert()
                response = {
                    'message': 'Código válido.',
                    'data': []
                }
                return Response(response, status=status.HTTP_200_OK)
            except:
                response = {
                    'message': 'Código inválido',
                    'data': []
                }
                return Response(response, status=status.HTTP_404_NOT_FOUND)

    def get_permissions(self):
        if self.request.method == 'GET' and self.action == 'verify':
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated, IsOperador]
        return [permission() for permission in permission_classes]


class GroupViewSet(viewsets.ModelViewSet):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer

    def get_permissions(self):
        permission_classes = [IsAuthenticated, IsAdminUser]
        if self.action == 'list':
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    filterset_fields = ['is_active']

    @action(detail=True, methods=['put'])
    def password(self, request, pk, format=None):
        if request.method == 'PUT':
            user = self.get_object()
            serializer = UserPasswordSerializer(user, data=request.data)
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
            serializer = UserUsernameSerializer(user, data=request.data)
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

    @action(detail=False, methods=['get'])
    def my_profile(self, request, format=None):
        if request.method == 'GET':
            user = request.user
            groups = []
            for row in user.groups.all():
                groups.append(row.name)
            response = {
                'first_name': user.first_name,
                'last_name': user.last_name,
                'groups': groups,
            }
            return Response(response, status=status.HTTP_200_OK,)

    @action(detail=True, methods=['get'])
    def is_username_in_use(self, request, username, format=None):
        if request.method == 'GET':
            try:
                user = User.objects.filter(username=username).exists()
                if user:
                    response = {
                        'message': 'username indisponível.',
                        'data': []
                    }
                    return Response(response, status=status.HTTP_200_OK)
                else:
                    response = {
                        'message': 'username disponível.',
                        'data': []
                    }
                    return Response(response, status=status.HTTP_204_NO_CONTENT)
            except:
                response = {
                    'message': 'Erro',
                    'data': []
                }
                return Response(response, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def get_serializer_class(self):
        serializer_class = self.serializer_class

        if self.request.method == 'POST':
            serializer_class = UserCreateSerializer
        if self.request.method == 'PUT':
            serializer_class = UserSerializer
        if self.action == 'password':
            serializer_class = UserPasswordSerializer
        if self.action == 'username':
            serializer_class = UserUsernameSerializer

        return serializer_class

    def get_permissions(self):
        permission_classes = [IsAuthenticated, IsOperador]
        if self.action == 'my_profile':
            permission_classes = [IsAuthenticated]
        elif self.request.method == 'POST':
            permission_classes = [HasRegisterToken]
        elif self.action == 'list':
            permission_classes = [IsAuthenticated, IsOperador]
        elif self.action in ('password', 'username'):
            permission_classes = [EoProprioUsuario]
        elif self.action == 'is_username_in_use':
            permission_classes = [HasRegisterToken]
        elif self.action == 'partial_update':
            permission_classes = [IsUserHimselfOrOperador]
        return [permission() for permission in permission_classes]


class RedeViewSet(mixins.CreateModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.UpdateModelMixin,
                  mixins.ListModelMixin,
                  trash_mixins.TrashModelMixin,
                  viewsets.GenericViewSet):
    
    serializer_class = RedeSerializer
    filterset_fields = ['is_active']

    def get_queryset(self):
        queryset = Rede.objects.all()
        user = self.request.user
        if (IsOperador().has_permission(self.request, RedeViewSet())): # Permissões
            return queryset
        else:
            return user.redes_visiveis
    
    @action(detail=True, methods=['get'])
    def pontos(self, request, pk, format=None):
        if request.method == 'GET':
            self.serializer_class = PontoSerializer
            queryset = Rede.objects.get(id=pk).pontos.filter(is_active=True) # filtro is_active
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)

    def get_permissions(self):
        permission_classes = [IsAuthenticated, IsOperador]

        """ if self.request.method == 'DELETE':
            permission_classes = [IsAdminUser]
        elif self.request.method == 'POST':
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAuthenticated] """
        # TODO
        """ return [IsStaffOrTargetUser()] """
        return [permission() for permission in permission_classes]

    def finalize_response(self, request, response, *args, **kwargs):
        """ Atualiza a versão da db """
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse


class SignatureUpload(APIView):
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [IsAuthenticated]

    def post(self, request, pk, format=None):
        instance = Visita.objects.get(pk=pk)
        if (self.check_user(request, instance)):
            serializer = SignatureSerializer(data=request.data,
                instance=instance)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors,
                    status=status.HTTP_400_BAD_REQUEST)
        return Response({'Message': 'Você não é o avaliador desta visita'},
            status=status.HTTP_401_UNAUTHORIZED)

    def check_user(self, request, instance):
        """ Verifica se usuário é o avaliador da visita """
        user = request.user
        dono_da_visita = instance.avaliador
        return user == dono_da_visita


class ItemPhotoUpload(APIView):
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [IsAuthenticated]

    def post(self, request, pk, format=None):
        instance = Item.objects.get(pk=pk)
        if (self.check_user(request, instance)):
            serializer = ItemPhotoSerializer(data=request.data,
                instance=instance)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors,
                    status=status.HTTP_400_BAD_REQUEST)
        return Response({'Message': 'Você não é o avaliador desta visita'},
            status=status.HTTP_401_UNAUTHORIZED)
        

    def check_user(self, request, instance):
        """ Verifica se usuário é o avaliador da visita """
        user = request.user
        dono_da_visita = instance.visita.avaliador
        return user == dono_da_visita


class VisitaViewSet(mixins.CreateModelMixin,
                    mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin,
                    mixins.ListModelMixin,
                    trash_mixins.TrashModelMixin,
                    viewsets.GenericViewSet):
    queryset = Visita.objects.all()
    serializer_class = VisitaSerializer
    filterset_fields = ['is_active']


    @action(detail=True, methods=['get'])
    def itens(self, request, pk, format=None):
        if request.method == 'GET':
            self.serializer_class = ItemSerializer
            queryset = Visita.objects.get(id=pk).itens.all()
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)


class PontoViewSet(mixins.CreateModelMixin,
                    mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin,
                    mixins.ListModelMixin,
                    trash_mixins.TrashModelMixin,
                    viewsets.GenericViewSet):
    queryset = Ponto.objects.all()
    serializer_class = PontoSerializer
    filterset_fields = ['is_active']


    @action(detail=True, methods=['get'])
    def visitas(self, request, pk, format=None):
        if request.method == 'GET':
            self.serializer_class = VisitaSerializer
            queryset = Ponto.objects.get(id=pk).visitas.filter(is_active=True)
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse


class ItemBaseViewSet(mixins.CreateModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.UpdateModelMixin,
                  mixins.ListModelMixin,
                  trash_mixins.TrashModelMixin,
                  viewsets.GenericViewSet):
    queryset = ItemBase.objects.all()
    serializer_class = ItemBaseSerializer
    filterset_fields = ['is_active', 'active']

    def get_permissions(self):
        permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse
