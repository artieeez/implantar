from db_version.models import *

def upgrade_version():
    try:
        instance = Version.objects.first()
        instance.number += 1
        instance.save()
    except:
        instance = Version.objects.create()
    print(f"db version upgrades to {instance.number}")
    return