from rest_framework import serializers
from checker.models import Pessoa, Rede, Ponto, Visita, ItemBase, Profile
from django.contrib.auth.models import User, Group
from rest_framework.reverse import reverse

GRUPO_AVALIADORES = 'avaliador'

class ProfileSerializer(serializers.ModelSerializer):

    class Meta:
        model = Profile
        fields = ['display_name']


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
        group = Group.objects.get(name=GRUPO_AVALIADORES)
        group.user_set.add(user)
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
        fields = ['url', 'id', 'nome', 'telefone', 'celular', 'email', 't_created', 't_modified']


class VisitaSerializer(serializers.HyperlinkedModelSerializer):
    ponto_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Visita
        fields = ['url', 'id', 'data', 'inicio', 'termino', 'avaliador',
            'plantao', 't_created', 't_modified']

    def create(self, validated_data):
        v = Visita.objects.create(data=validated_data['data'])
        Ponto.objects.get(id=validated_data['ponto_id']).visitas.add(v)
        return v


class PontoSerializer(serializers.HyperlinkedModelSerializer):
    visitas = serializers.HyperlinkedRelatedField(many=True, view_name='visitas-list', read_only=True)
    rede_nome = serializers.SerializerMethodField('get_rede_nome', read_only=True)
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
        fields = ['url', 'id', 'nome', 'rede_id', 'rede_nome', 'visitas', 't_created', 't_modified']


class RedeSerializer(serializers.HyperlinkedModelSerializer):
    """ pontos = serializers.HyperlinkedRelatedField(many=True, view_name='pontos-list', read_only=True) """
    pontos = PontoSerializer(many=True, read_only=True)
    contatos = PessoaSerializer(many=True, read_only=True)

    class Meta:
        model = Rede
        fields = ['url', 'id', 'nome', 'photo', 'pontos', 'contatos', 't_created', 't_modified']

    def create(self, validated_data):
        return Rede.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.nome = validated_data.get('nome', instance.nome)
        instance.save()
        return instance


class ItemBaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = ItemBase
        fields = '__all__'

    def create(self, validated_data):
        return Rede.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.nome = validated_data.get('text', instance.text)
        instance.nome = validated_data.get('active', instance.active)
        instance.save()
        return instance