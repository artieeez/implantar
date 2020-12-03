from rest_framework import serializers
from checker.models import Pessoa, Rede, Ponto, Visita, Item, ItemBase, Profile
from django.contrib.auth.models import User, Group
from rest_framework.reverse import reverse
from django.conf import settings
import datetime


class ProfileSerializer(serializers.ModelSerializer):

    class Meta:
        model = Profile
        fields = ['display_name']


class ClienteCreateSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'profile']

    def create(self, validated_data):
        user = User(
            email=validated_data['email'],
            username=validated_data['username']
        )
        user.set_password(validated_data['password'])
        user.save()
        try:
            group = Group.objects.get(name=settings.CLIENTE_GROUP_NAME)
            group.user_set.add(user)
        except:
            print("Err - Crie o grupo de clientes.")
        profile_data = validated_data.pop('profile')
        Profile.objects.create(user=user, **profile_data)
        return user


class AvaliadorCreateSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'profile']

    def create(self, validated_data):
        user = User(
            email=validated_data['email'],
            username=validated_data['username']
        )
        user.set_password(validated_data['password'])
        user.save()
        try:
            group = Group.objects.get(name=settings.AVALIADOR_GROUP_NAME)
            group.user_set.add(user)
        except:
            print("Err - Crie o grupo de avaliadores.")
        profile_data = validated_data.pop('profile')
        Profile.objects.create(user=user, **profile_data)
        return user


class AvaliadorPasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)

    model = User


class AvaliadorUsernameSerializer(serializers.Serializer):
    password = serializers.CharField(write_only=True)
    username = serializers.CharField(write_only=True)

    model = User


class AvaliadorSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'profile']
        extra_kwargs = {
            'username': {'read_only': True},
        }


class PessoaSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Pessoa
        fields = ['url', 'id', 'nome', 'telefone', 'celular', 'email',
            't_created', 't_modified']


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
    """ visita_id = serializers.IntegerField(write_only=True)
    item_base_id = serializers.IntegerField(write_only=True) """
    itemBase = ItemBaseSerializer(required=False)

    class Meta:
        model = Item
        fields = ['id', 'conformidade', 'comment', 'photo', 'itemBase']
        extra_kwargs = {
            'id': {'read_only': False},
        }

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
    avaliador = AvaliadorSerializer(read_only=True)

    class Meta:
        model = Visita
        fields = ['url', 'id', 'ponto_id', 'data', 'inicio', 'termino', 
            'avaliador', 'plantao', 'item_set', 't_created', 't_modified']
        extra_kwargs = {
            'avaliador': {'read_only': True},
            'data': {'read_only': True},
            'inicio': {'read_only': True},
            'termino': {'read_only': True},
        }

    def create(self, validated_data):
        avaliador = self.context['request'].user
        data = datetime.date.today()
        inicio = datetime.datetime.now()
        v = Visita.objects.create(data=data,
            inicio=inicio, avaliador=avaliador)
        Ponto.objects.get(id=validated_data['ponto_id']).visitas.add(v)
        """ Popula visita com itens """
        itens_pool = ItemBase.objects.filter(active=True)
        for item in itens_pool:
            Item.objects.create(itemBase=item, visita=v)
        return v

    def update(self, instance, validated_data):
        if instance.termino is None:
            instance.termino = datetime.datetime.now()
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
    cliente = ClienteCreateSerializer()
    pontos = PontoSerializer(many=True, read_only=True)
    contatos = PessoaSerializer(many=True, read_only=True)

    def create(self, validated_data):
        cliente_data = validated_data.pop('cliente')
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
        Profile.objects.create(user=user, **profile_data)

        return Rede.objects.create(cliente=user, **validated_data)

    def update(self, instance, validated_data):
        instance.nome = validated_data.get('nome', instance.nome)
        instance.save()
        return instance


class RedeSerializer(_BaseRedeSerializer):
    class Meta:
        model = Rede
        fields = ['url', 'id', 'nome', 'photo', 'pontos', 'contatos',
            't_created', 't_modified', 'cliente']

class TrashRedeSerializer(_BaseRedeSerializer):
    class Meta:
        model = Rede
        fields = ['url', 'id', 'nome', 'photo', 'pontos', 'contatos',
            't_created', 't_modified', 'cliente']
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
