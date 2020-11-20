from django.contrib import admin
from checker.models import Pessoa, Rede, Ponto, Visita, ItemBase

# Register your models here.
admin.site.register(Pessoa)
admin.site.register(Rede)
admin.site.register(Ponto)
admin.site.register(Visita)
admin.site.register(ItemBase)

