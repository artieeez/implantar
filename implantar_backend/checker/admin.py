from django.contrib import admin
from checker.models import Rede, Ponto, Visita, ItemBase, Categoria, Item, Profile

# Register your models here.
admin.site.register(Rede)
admin.site.register(Ponto)
admin.site.register(Visita)
admin.site.register(Item)
admin.site.register(ItemBase)
admin.site.register(Categoria)
admin.site.register(Profile)


# FIX sem permissão para remover usuário por conta do OutstandingToken
# # Abordado em:
# # # https://github.com/SimpleJWT/django-rest-framework-simplejwt/issues/266

from rest_framework_simplejwt.token_blacklist.models import OutstandingToken
from rest_framework_simplejwt.token_blacklist.admin import OutstandingTokenAdmin

class CustomOutstandingTokenAdmin(OutstandingTokenAdmin):
    def has_delete_permission(self, *args, **kwargs):
        return True

admin.site.unregister(OutstandingToken)
admin.site.register(OutstandingToken, CustomOutstandingTokenAdmin)

