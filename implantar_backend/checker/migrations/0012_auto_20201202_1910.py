# Generated by Django 3.1.3 on 2020-12-02 19:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('checker', '0011_auto_20201201_1640'),
    ]

    operations = [
        migrations.AlterField(
            model_name='visita',
            name='termino',
            field=models.DateTimeField(null=True),
        ),
    ]
