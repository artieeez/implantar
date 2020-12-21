from django.db import models

# Create your models here.
class Version(models.Model):
    number = models.IntegerField(default=1)
