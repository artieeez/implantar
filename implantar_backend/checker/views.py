from checker.models import Pessoa, Rede, Ponto, Visita, Item, ItemBase
from checker.serializers import PessoaSerializer, RedeSerializer
from checker.serializers import RedeSerializer, TrashRedeSerializer
from checker.serializers import PontoSerializer, VisitaSerializer
from checker.serializers import ItemBaseSerializer, AvaliadorSerializer
from checker.serializers import AvaliadorCreateSerializer, AvaliadorPasswordSerializer, AvaliadorUsernameSerializer
from checker.serializers import ItemSerializer, AvaliadorUsernameSerializer
from checker.serializers import ItemPhotoSerializer, SignatureSerializer
from rest_framework import generics, renderers, viewsets
from django.contrib.auth.models import User
from rest_framework import permissions
from rest_framework.decorators import api_view, action
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination, LimitOffsetPagination
from rest_framework import status
from rest_framework import permissions, mixins
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
from checker.permissions import IsOwnerOrReadOnly, IsAssigned, EoProprioUsuario


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
            'display_name': user.profile.display_name,
            'vCount': user.profile.vCount
        })


class AvaliadorViewSet(viewsets.ModelViewSet):
    queryset = User.objects.filter(groups__name=settings.AVALIADOR_GROUP_NAME)
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
        if self.detail and self.request.method == 'GET':
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAdminUser]
        if self.action in ('password', 'username'):
            permission_classes = [EoProprioUsuario]

        """ if self.request.method == 'DELETE':
            permission_classes = [IsAdminUser]
        elif self.request.method == 'POST':
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAuthenticated] """
        # TODO
        """ return [IsStaffOrTargetUser()] """
        return [permission() for permission in permission_classes]


class PontosDaRedeMixins:
    @action(detail=True, methods=['get'])
    def pontos(self, request, pk, format=None):
        if request.method == 'GET':
            self.serializer_class = PontoSerializer
            queryset = Rede.objects.get(id=pk).pontos.filter(in_trash=False)
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)

            serializer = self.get_serializer(queryset, many=True)
            return Response(serializer.data)


class RedeViewSet(mixins.CreateModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.UpdateModelMixin,
                  mixins.ListModelMixin,
                  trash_mixins.SendToTrashModelMixin,
                  PontosDaRedeMixins,
                  viewsets.GenericViewSet):
    queryset = Rede.objects.filter(in_trash=False)
    serializer_class = RedeSerializer

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse


class TrashRedeViewSet(mixins.RetrieveModelMixin,
                       mixins.ListModelMixin,
                       trash_mixins.TrashMixin,
                       PontosDaRedeMixins,
                       viewsets.GenericViewSet):
    queryset = Rede.objects.filter(in_trash=True)
    serializer_class = TrashRedeSerializer

    def finalize_response(self, request, response, *args, **kwargs):
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


class ItensMixin:
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


class VisitaViewSet(mixins.CreateModelMixin,
                    mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin,
                    mixins.ListModelMixin,
                    trash_mixins.SendToTrashModelMixin,
                    ItensMixin,
                    viewsets.GenericViewSet):
    queryset = Visita.objects.filter(in_trash=False)
    serializer_class = VisitaSerializer


class TrashVisitaViewSet(mixins.RetrieveModelMixin,
                        mixins.ListModelMixin,
                        trash_mixins.TrashMixin,
                        ItensMixin,
                        viewsets.GenericViewSet):
    queryset = Visita.objects.filter(in_trash=True)
    serializer_class = VisitaSerializer


class VisitasMixin:
    @action(detail=True, methods=['get'])
    def visitas(self, request, pk, format=None):
        if request.method == 'GET':
            print(request.headers)
            self.serializer_class = VisitaSerializer
            queryset = Ponto.objects.get(id=pk).visitas.filter(in_trash=False)
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
                    trash_mixins.SendToTrashModelMixin,
                    VisitasMixin,
                    viewsets.GenericViewSet):
    queryset = Ponto.objects.filter(in_trash=False)
    serializer_class = PontoSerializer

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse

        
class TrashPontoViewSet(mixins.RetrieveModelMixin,
                        mixins.ListModelMixin,
                        trash_mixins.TrashMixin,
                        VisitasMixin,
                        viewsets.GenericViewSet):
    queryset = Ponto.objects.filter(in_trash=True)
    serializer_class = PontoSerializer

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse


class ItemBaseViewSet(mixins.CreateModelMixin,
                  mixins.RetrieveModelMixin,
                  mixins.UpdateModelMixin,
                  mixins.ListModelMixin,
                  trash_mixins.SendToTrashModelMixin,
                  viewsets.GenericViewSet):
    queryset = ItemBase.objects.filter(in_trash=False)
    serializer_class = ItemBaseSerializer

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse

    @action(detail=False, methods=['get'])
    def active(self, request):
        queryset = ItemBase.objects.filter(active=True)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    def perform_destroy(self, instance):
        instance.in_trash = True
        instance.active = False
        instance.save()
    

class TrashItemBaseViewSet(mixins.RetrieveModelMixin,
                       mixins.ListModelMixin,
                       trash_mixins.TrashMixin,
                       viewsets.GenericViewSet):
    queryset = ItemBase.objects.filter(in_trash=True)
    serializer_class = ItemBaseSerializer

    def finalize_response(self, request, response, *args, **kwargs):
        xresponse = super().finalize_response(request, response, *args, **kwargs)
        if request.method not in ['GET', 'HEAD', 'OPTIONS'] and (response.status_code >= 200 and response.status_code <=299):
            db_version.upgrade_version()
        return xresponse
