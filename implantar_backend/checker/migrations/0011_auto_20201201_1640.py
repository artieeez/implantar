# Generated by Django 3.1.3 on 2020-12-01 16:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('checker', '0010_auto_20201128_2240'),
    ]

    operations = [
        migrations.RenameField(
            model_name='itembase',
            old_name='deleted',
            new_name='in_trash',
        ),
        migrations.RenameField(
            model_name='profile',
            old_name='deleted',
            new_name='in_trash',
        ),
        migrations.RenameField(
            model_name='visita',
            old_name='deleted',
            new_name='in_trash',
        ),
        migrations.AddField(
            model_name='ponto',
            name='in_trash',
            field=models.BooleanField(default=False),
        ),
    ]
