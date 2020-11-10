from django.db import models
from datetime import date

# Create your models here.
class Pessoa(models.Model):
    nome = models.CharField(verbose_name="nome", max_length=64)

    """ Contato """
    telefone = models.CharField(max_length=32, blank=True)
    celular = models.CharField(max_length=32, blank=True)
    email = models.EmailField(max_length=64, blank=True)


class Rede(models.Model):
    nome = models.CharField(max_length=64)

    pontos = models.ManyToManyField(
        'checker.Ponto',
        blank=True,
    )
    contatos = models.ManyToManyField(
        'checker.Pessoa',
        blank=True,
    )
    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)


class Ponto(models.Model):
    nome = models.CharField(max_length=64)

    visitas = models.ManyToManyField(
        'checker.Visita',
        blank=True,
    )
    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)


class Visita(models.Model):
    data = models.DateField()
    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)