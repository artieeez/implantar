# Generated by Django 3.1.3 on 2020-11-20 19:46

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('checker', '0002_rede_photo'),
    ]

    operations = [
        migrations.CreateModel(
            name='ItemBase',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('text', models.CharField(max_length=255)),
                ('t_created', models.DateField(auto_now_add=True)),
                ('t_modified', models.DateField(auto_now=True)),
            ],
        ),
        migrations.CreateModel(
            name='Item',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('comment', models.CharField(blank=True, max_length=255)),
                ('photo', models.ImageField(blank=True, upload_to='checklist_data/images/')),
                ('itemBase', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='checker.itembase')),
                ('visita', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, to='checker.visita')),
            ],
            options={
                'ordering': ['itemBase__id'],
            },
        ),
        migrations.AddField(
            model_name='visita',
            name='itens',
            field=models.ManyToManyField(blank=True, through='checker.Item', to='checker.ItemBase'),
        ),
    ]
