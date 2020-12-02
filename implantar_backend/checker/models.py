from django.conf import settings
from django.db import models
from datetime import date

# Create your models here.
class Profile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True)
    display_name = models.CharField(max_length=255)
    in_trash = models.BooleanField(default=False)


class Pessoa(models.Model):
    nome = models.CharField(verbose_name="nome", max_length=64)

    """ Contato """
    telefone = models.CharField(max_length=32, blank=True)
    celular = models.CharField(max_length=32, blank=True)
    email = models.EmailField(max_length=64, blank=True)

    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)


class Rede(models.Model):
    nome = models.CharField(max_length=64)
    photo = models.ImageField(upload_to='redes/', blank=True)
    cliente = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True)

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
    in_trash = models.BooleanField(default=False)


    def __str__(self):
        return f'{self.nome}'


class Ponto(models.Model):
    nome = models.CharField(max_length=64)

    visitas = models.ManyToManyField(
        'checker.Visita',
        blank=True,
    )
    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)
    deleted = models.BooleanField(default=False)
    in_trash = models.BooleanField(default=False)


    """ def save(self, *args, **kwargs):
        print(**kwargs)
        if not self.pk:
            print()
            # This code only happens if the objects is
            # not in the database yet. Otherwise it would
            # have pk
        super(MyModel, self).save(*args, **kwargs) """

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
    itens = models.ManyToManyField(
        'checker.ItemBase',
        through='checker.Item',
        through_fields=('visita', 'itemBase'),
        blank=True,
    )
    plantao = models.CharField(max_length=255, blank=True)
    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)
    in_trash = models.BooleanField(default=False)


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
    
    conformidade = models.CharField(max_length=3,
        choices=CONFORMIDADE_CHOICHES, default='NO')
    visita = models.ForeignKey('checker.Visita', on_delete=models.CASCADE)
    itemBase = models.ForeignKey('checker.ItemBase', on_delete=models.PROTECT)
    comment = models.CharField(max_length=255, blank=True)
    photo = models.ImageField(upload_to='checklist_data/images/', blank=True)




class ItemBase(models.Model):
    id_arb = models.IntegerField(null=True)
    text = models.CharField(max_length=255)
    active = models.BooleanField(default=True)
    categoria = models.ForeignKey('checker.Categoria',
        on_delete=models.PROTECT, null=True)

    """ Cadastro """
    t_created = models.DateField(auto_now_add=True)
    t_modified = models.DateField(auto_now=True)
    in_trash = models.BooleanField(default=False)


class Categoria(models.Model):
    id_arb = models.IntegerField(null=True)
    nome = models.CharField(max_length=255)
