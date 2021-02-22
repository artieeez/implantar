from django.conf import settings
from django.db import models
from datetime import date, datetime
from django.utils import timezone
from django.contrib.auth.models import Group
import os
import secrets

from django.db.models.signals import pre_delete
from django.dispatch.dispatcher import receiver

def _delete_file(path):
   """ Deletes file from filesystem. """
   if os.path.isfile(path):
       os.remove(path)


class Profile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True)
    vCount = models.IntegerField(default=1)
    display_name = models.CharField(max_length=255)


class RegisterToken(models.Model):
    token = models.CharField(max_length=255, blank=True)
    group = models.ForeignKey(Group, on_delete=models.CASCADE)
    responsavel = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    redes = models.ManyToManyField("checker.rede", blank=True)
    t_created = models.DateTimeField(auto_now_add=True)

    def is_valid(self):
        delta = timezone.now() - self.t_created
        return (delta.seconds//3600) < settings.REGISTER_TOKEN_LIFE

    def save(self, *args, **kwargs):
        if not self.pk:
            self.token = secrets.token_urlsafe(16)
        super(RegisterToken, self).save(*args, **kwargs)


class Rede(models.Model):
    nome = models.CharField(max_length=64)
    photo = models.ImageField(upload_to='redes/', blank=True)
    """ cliente = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True) """

    pontos = models.ManyToManyField(
        'checker.Ponto',
        blank=True,
    )
    assigned_to = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='redes',
        blank=True
    )
    """ Cadastro """
    is_active = models.BooleanField(default=True)
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)

    class Meta:
        ordering = ['nome']

    def __str__(self):
        return f'{self.nome}'

""" Remove os arquivos da visita ao deletar """
@receiver(models.signals.pre_delete, sender=Rede)
def delete_file(sender, instance, *args, **kwargs):
    if instance.photo:
        _delete_file(instance.photo.path)

class Ponto(models.Model):
    nome = models.CharField(max_length=64)

    visitas = models.ManyToManyField(
        'checker.Visita',
        blank=True,
    )
    """ Cadastro """
    is_active = models.BooleanField(default=True)
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)
    deleted = models.BooleanField(default=False)


    """ def save(self, *args, **kwargs):
        print(**kwargs)
        if not self.pk:
            print()
            # This code only happens if the objects is
            # not in the database yet. Otherwise it would
            # have pk
        super(MyModel, self).save(*args, **kwargs) """

    class Meta:
        ordering = ['t_created']

    def __str__(self):
        return f'{self.nome}'


class Visita(models.Model):
    data = models.DateField()
    inicio = models.DateTimeField()
    termino = models.DateTimeField(null=True)
    avaliador = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        null=True)
    signature = models.ImageField(upload_to='checklist_data/signatures/', blank=True)
    itens = models.ManyToManyField(
        'checker.ItemBase',
        through='checker.Item',
        through_fields=('visita', 'itemBase'),
        blank=True,
    )
    plantao = models.CharField(max_length=255, blank=True)
    """ Cadastro """
    is_active = models.BooleanField(default=True)
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)

    class Meta:
        ordering = ['t_created']

    def __str__(self):
        return f"""{self.ponto_set.first().rede_set.first().nome}
                {self.ponto_set.first().nome} 
                ({self.data.day}/{self.data.month}/{self.data.year})
                -> {self.avaliador.first_name + ' ' + self.avaliador.last_name}"""

""" Remove os arquivos da visita ao deletar """
@receiver(models.signals.pre_delete, sender=Visita)
def delete_file(sender, instance, *args, **kwargs):
    for row in instance.item_set.all():
        if row.photo:
            _delete_file(row.photo.path)
    if instance.signature:
        _delete_file(instance.signature.path)

class Item(models.Model):
    class Meta:
        ordering = ["itemBase__id"]

    CONFORMIDADE_CHOICHES = [
        ('C', 'Conforme'),
        ('NC', 'Não Conforme'),
        ('NCR', 'Não Conforme Resolvida'),
        ('NA', 'Não Aplicável'),
        ('NO', 'Não Observado'),
    ]
    
    clientId = models.IntegerField()
    conformidade = models.CharField(max_length=3,
        choices=CONFORMIDADE_CHOICHES, default='NO')
    visita = models.ForeignKey('checker.Visita', on_delete=models.CASCADE)
    itemBase = models.ForeignKey('checker.ItemBase', on_delete=models.PROTECT)
    comment = models.CharField(max_length=255, blank=True)
    photo = models.ImageField(upload_to='checklist_data/images/', blank=True)

    class Meta:
        ordering = ['itemBase__categoria__id_arb', 'itemBase__id_arb']


class Checklist(models.Model): 
    """ Modelo de checklist
        Novas visitas deverão carregar a partir um destes objetos
        visita já registradas não deverão depender deste modelo
    """
    class Meta:
        ordering = ['']

    nome = models.TextField(blank=True)
    comment = models.TextField(blank=True)
    rede = models.ManyToManyField(
        'checker.rede',
        blank=True,
    )
    itens = models.ManyToManyField(
        'checker.ItemBase',
        through='checker.ChecklistItem',
        through_fields=('checklist', 'itemBase'),
        blank=True,
    )
    """ Cadastro """
    is_active = models.BooleanField(default=True)
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)

    class Meta:
        ordering = ['t_created']
    

class ChecklistItem(models.Model):
    """ Configuração do item dentro do modelo de checklist
    """
    inUse = models.BooleanField(default=True) # Determina se fará parte do c.
    checklist = models.ForeignKey('checker.checklist', on_delete=models.CASCADE)
    itemBase = models.ForeignKey('checker.ItemBase', on_delete=models.PROTECT)


class ItemBase(models.Model):
    id_arb = models.IntegerField(null=True) # Determina ordem
    text = models.CharField(max_length=255)
    active = models.BooleanField(default=True)
    categoria = models.ForeignKey('checker.Categoria',
        on_delete=models.PROTECT, null=True)

    """ Cadastro """
    is_active = models.BooleanField(default=True)
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)

    class Meta:
        ordering = ['categoria__id_arb', 'id_arb']

    def __str__(self):
        return f'{self.categoria.id_arb}.{self.id_arb} - {self.text}'


class Categoria(models.Model):
    id_arb = models.IntegerField(null=True) # Determina ordem
    nome = models.CharField(max_length=255)

    class Meta:
        ordering = ['id_arb']

    def __str__(self):
        return f'{self.id_arb} - {self.nome}'
