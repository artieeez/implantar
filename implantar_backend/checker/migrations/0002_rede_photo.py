# Generated by Django 3.1.3 on 2020-11-18 11:30

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('checker', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='rede',
            name='photo',
            field=models.ImageField(blank=True, upload_to='redes/'),
        ),
    ]