# Generated by Django 3.1.3 on 2020-12-14 18:57

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('checker', '0012_auto_20201202_1910'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='categoria',
            options={'ordering': ['id_arb']},
        ),
        migrations.AlterModelOptions(
            name='item',
            options={'ordering': ['itemBase__categoria__id_arb', 'itemBase__id_arb']},
        ),
        migrations.AlterModelOptions(
            name='itembase',
            options={'ordering': ['categoria__id_arb', 'id_arb']},
        ),
        migrations.AlterModelOptions(
            name='ponto',
            options={'ordering': ['t_created']},
        ),
        migrations.AlterModelOptions(
            name='rede',
            options={'ordering': ['nome']},
        ),
        migrations.AlterModelOptions(
            name='visita',
            options={'ordering': ['t_created']},
        ),
        migrations.AddField(
            model_name='visita',
            name='signature',
            field=models.ImageField(blank=True, upload_to='checklist_data/signatures/'),
        ),
    ]