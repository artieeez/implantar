from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth.models import User, Group, Permission
from django.conf import settings

OPERADOR_GROUP_NAME = 'operador'

class Command(BaseCommand):
    help = 'Cuida das configurações iniciais para o funcionamento do app.'

    def handle(self, *args, **options):
        for row in settings.CLASSES_DE_USUARIOS:
            try:
                Group.objects.get(name=row)
                self.stdout.write(self.style.SUCCESS('''Grupo "%s"
                    já existe. Pulando.''' %row ))
            except:
                Group.objects.create(name=row)
                self.stdout.write(self.style.SUCCESS('''Grupo "%s"
                    criado.''' %row ))

        """ Permissões do operador """
        try:
            operador_group = Group.objects.get(name=OPERADOR_GROUP_NAME)
            operador_group.permissions.clear()
        except Exception as e:
            self.stdout.write(self.style.SUCCESS('''>> Erro ao encontrar grupo "%s".
                    \n\n %s''' %(OPERADOR_GROUP_NAME, e) ))

        for obj in settings.OBJETOS_ACESSIVEIS_OPERADOR:
            for action in obj['actions']:
                try:
                    perm = Permission.objects.get(codename=f'{action}_{obj["nome"]}')
                    operador_group.permissions.add(perm)
                except Exception as e:
                    self.stdout.write(self.style.SUCCESS('''
                        >> Erro ao adicionar permissão "%s".
                        \n\n %s''' 
                        %(f'{action}_{obj["nome"]}', e) ))
                    perm = Permission.objects.get(codename=f'{action}_{obj["nome"]}')


        self.stdout.write(self.style.SUCCESS('''>> Inicialização Concluída'''))