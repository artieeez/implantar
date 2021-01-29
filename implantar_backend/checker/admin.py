from django.contrib import admin
from checker.models import Rede, Ponto, Visita, ItemBase, Categoria, Item

# Register your models here.
admin.site.register(Rede)
admin.site.register(Ponto)
admin.site.register(Visita)
admin.site.register(Item)
admin.site.register(ItemBase)
admin.site.register(Categoria)


