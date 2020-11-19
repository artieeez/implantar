from rest_framework import serializers
from checker.models import Pessoa, Rede, Ponto, Visita
from django.contrib.auth.models import User


class PessoaSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Pessoa
        fields = ['url', 'id', 'nome', 'telefone', 'celular', 'email', 't_created', 't_modified']


class VisitaSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Visita
        fields = ['url', 'id', 'data', 't_created', 't_modified']


class PontoSerializer(serializers.HyperlinkedModelSerializer):
    visitas = serializers.HyperlinkedRelatedField(many=True, view_name='visitas-list', read_only=True)

    class Meta:
        model = Ponto
        fields = ['url', 'id', 'nome', 'visitas', 't_created', 't_modified']


class RedeSerializer(serializers.HyperlinkedModelSerializer):
    """ pontos = serializers.HyperlinkedRelatedField(many=True, view_name='pontos-list', read_only=True) """
    pontos = PontoSerializer(many=True)
    contatos = PessoaSerializer(many=True)

    class Meta:
        model = Rede
        fields = ['url', 'id', 'nome', 'photo', 'pontos', 'contatos', 't_created', 't_modified']

    def create(self, validated_data):
        return Rede.objects.create(**validated_data)

    def update(self, instance, validated_data):
        instance.nome = validated_data.get('nome', instance.nome)
        instance.save()
        return instance
