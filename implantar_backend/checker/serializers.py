from rest_framework import serializers
from checker.models import *
from django.contrib.auth.models import User, Group
from rest_framework.reverse import reverse
from django.conf import settings
import datetime
from django.utils import timezone
import pytz

# DbVersion
from db_version import utils as db_version


class ProfileSerializer(serializers.ModelSerializer):

    class Meta:
        model = Profile
        fields = []


class UserCreateSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ['username', 'password', 'first_name', 'last_name', 'email']

    def create(self, validated_data):
        str_registerToken = self.context['request'].query_params.get('register-token', None)
        registerToken = RegisterToken.objects.get(token=str_registerToken)
        user = User(
            username=validated_data['username'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            email=validated_data['email'],
        )
        user.set_password(validated_data['password'])
        user.save()
        group = registerToken.group
        group.user_set.add(user)
        Profile.objects.create(user=user)
        return user


class UserPasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)

    model = User


class UserUsernameSerializer(serializers.Serializer):
    password = serializers.CharField(write_only=True)
    username = serializers.CharField(write_only=True)

    model = User


class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'profile',
            'is_active',
            'date_joined',
            'last_login',
            ]
        extra_kwargs = {
            'username': {'read_only': True},
            'date_joined': {'read_only': True},
            'last_login': {'read_only': True},
        }


class RegisterTokenSerializer(serializers.ModelSerializer):
    responsavel = UserSerializer(read_only=True)
    idade = serializers.SerializerMethodField()

    class Meta:
        model = RegisterToken
        fields = ['id', 'idade', 'token', 'group', 'rede', 'responsavel']
        extra_kwargs = {
            'token': {'read_only': True},
            'idade': {'read_only': True},
        }

    def create(self, validated_data):
        token = RegisterToken.objects.create(
            group=validated_data['group'],
            rede=validated_data['rede'],
            responsavel = self.context['request'].user
        )
        return token

    def get_idade(self, obj):
        idade = timezone.now() - obj.t_created
        return idade.seconds//3600 # Horas
    

class ItemBaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = ItemBase
        fields = '__all__'

    def create(self, validated_data):
        return ItemBase.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.nome = validated_data.get('text', instance.text)
        instance.nome = validated_data.get('active', instance.active)
        instance.save()
        return instance


class ItemSerializer(serializers.ModelSerializer):
    visita_id = serializers.IntegerField(required=False)
    itemBase_id = serializers.IntegerField(write_only=True)
    itemBase = ItemBaseSerializer(required=False)

    class Meta:
        model = Item
        fields = ['id', 'visita_id', 'clientId', 'itemBase_id', 'conformidade', 'comment', 'photo', 'itemBase']
        extra_kwargs = {
            'id': {'read_only': True},
        }

    def create(self, validated_data):
        _visita = Visita.objects.get(pk=validated_data['visita_id'])
        _itemBase = ItemBase.objects.get(pk=validated_data['itemBase_id'])
        i = Item.objects.create(
            clientId=validated_data['clientId'],
            conformidade=validated_data['conformidade'],
            visita=_visita,
            itemBase=_itemBase,
        )
        return i

    def update(self, instance, validated_data):
        instance.conformidade = validated_data.get('conformidade',
            instance.conformidade)
        instance.comment = validated_data.get('comment',
            instance.comment)
        instance.photo = validated_data.get('photo',
            instance.photo)
        instance.save()
        return instance


class VisitaSerializer(serializers.HyperlinkedModelSerializer):
    ponto_id = serializers.IntegerField(required=False)
    item_set = ItemSerializer(many=True, required=False)
    avaliador = UserSerializer(read_only=True)

    class Meta:
        model = Visita
        fields = ['url', 'id', 'ponto_id', 'data', 'inicio', 'termino', 
            'avaliador', 'signature', 'plantao', 'item_set', 't_created', 't_modified']
        extra_kwargs = {
            'avaliador': {'read_only': True},
            'data': {'read_only': True},
        }

    def create(self, validated_data):
        avaliador = self.context['request'].user
        itens = validated_data.pop('item_set')

        data = datetime.date.today()
        inicio = timezone.now()
        termino = timezone.now()

        plantao = validated_data['plantao']
        v = Visita.objects.create(
            data=data,
            inicio=inicio,
            termino=termino,
            avaliador=avaliador)
        Ponto.objects.get(id=validated_data['ponto_id']).visitas.add(v)
        for row in itens:
            row['visita_id'] = v.id
            serializer = ItemSerializer(data=row)
            serializer.is_valid(raise_exception=True)
            serializer.save()
        return v

    def update(self, instance, validated_data):
        if instance.termino is None:
            instance.termino = timezone.now()
        instance.plantao = validated_data['plantao']
        itens = validated_data.pop('item_set')
        for row in itens:
            item = Item.objects.get(pk=row['id'])
            serializer = ItemSerializer(item, row, partial=True)
            serializer.is_valid(raise_exception=True)
            serializer.save()
        instance.save()
        return instance


class PontoSerializer(serializers.HyperlinkedModelSerializer):
    rede_nome = serializers.SerializerMethodField('get_rede_nome',
        read_only=True)
    rede_id = serializers.IntegerField(write_only=True)

    def get_rede_nome(self, ponto):
        rede_nome = ponto.rede_set.all()[0].nome
        return rede_nome

    def create(self, validated_data):
        p = Ponto.objects.create(nome=validated_data['nome'])
        Rede.objects.get(id=validated_data['rede_id']).pontos.add(p)
        return p

    class Meta:
        model = Ponto
        fields = ['url', 'id', 'nome', 'rede_id', 'rede_nome', 't_created',
            't_modified']


class _BaseRedeSerializer(serializers.HyperlinkedModelSerializer):
    """ pontos = serializers.HyperlinkedRelatedField(many=True, 
        view_name='pontos-list', read_only=True) """
    """ cliente = UserCreateSerializer() """
    pontos = PontoSerializer(many=True, read_only=True)

    def create(self, validated_data):
        """ cliente_data = validated_data.pop('cliente')
        user = User(
            email=cliente_data['email'],
            username=cliente_data['username']
        )
        user.set_password(cliente_data['password'])
        user.save()
        try:
            group = Group.objects.get(name=settings.CLIENTE_GROUP_NAME)
            group.user_set.add(user)
        except:
            print("Err - Crie o grupo de clientes.")
        profile_data = cliente_data.pop('profile')
        Profile.objects.create(user=user, **profile_data) """

        return Rede.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.nome = validated_data.get('nome', instance.nome)
        instance.save()
        return instance


class RedeSerializer(_BaseRedeSerializer):
    class Meta:
        model = Rede
        fields = ['url', 'id', 'nome', 'photo', 'pontos',
            't_created', 't_modified']

class TrashRedeSerializer(_BaseRedeSerializer):
    class Meta:
        model = Rede
        fields = ['url', 'id', 'nome', 'photo', 'pontos',
            't_created', 't_modified']
        extra_kwargs = {
            'url': {'view_name': 'trash-rede-detail'},
        }


class ItemPhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["photo"]

    def save(self, *args, **kwargs):
        if self.instance.photo:
            self.instance.photo.delete()
        return super().save(*args, **kwargs)


class SignatureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Visita
        fields = ["signature"]

    def save(self, *args, **kwargs):
        if self.instance.signature:
            self.instance.signature.delete()
        return super().save(*args, **kwargs)
