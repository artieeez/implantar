from django.core.management.base import BaseCommand, CommandError
from django.contrib.auth.models import User, Group
from django.conf import settings

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

        self.stdout.write(self.style.SUCCESS('''>> Inicialização Concluída'''))