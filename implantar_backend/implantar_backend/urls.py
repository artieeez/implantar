from django.urls import path, include
from django.contrib import admin
from rest_framework.authtoken import views

from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('api/api-auth/', include('rest_framework.urls')), # browsable api login
    path('api/admin/', admin.site.urls),
    path('api/', include('checker.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
