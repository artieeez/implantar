from django.urls import path, include
from django.contrib import admin
from rest_framework.authtoken import views

from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('api/', include('checker.urls')),
    path('api-auth/', include('rest_framework.urls')), # browsable api login
    path('admin/', admin.site.urls),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

url_A = [
    'api/', 'GET',
    'api/redes', 'GET',
    'api/redes', 'POST',
    'api/redes/<int:pk>/', 'GET',  
    'api/redes/<int:pk>/', 'PUT',
    'api/redes/<int:pk>/', 'DELETE',
    'api/redes/<int:pk>/pontos', 'GET',
    'api/redes/<int:pk>/pontos', 'POST',

    'api/redes/<int:pk>/pontos/<int:pk>/', 'GET',
    'api/redes/<int:pk>/pontos/<int:pk>/', 'PUT',
    'api/redes/<int:pk>/pontos/<int:pk>/', 'DELETE',

    'api/redes/<int:pk>/pontos/<int:pk>/visitas', 'GET',
    'api/redes/<int:pk>/pontos/<int:pk>/visitas', 'POST',

    'api/redes/<int:pk>/pontos/<int:pk>/visitas/<int:pk>', 'GET',
    'api/redes/<int:pk>/pontos/<int:pk>/visitas/<int:pk>', 'PUT',
    'api/redes/<int:pk>/pontos/<int:pk>/visitas/<int:pk>', 'DELETE',

    'api-auth/',
    'api-token-auth/',
    'admin/'
]

url_B = [
    'api/', 'GET',
    'api/redes', 'GET',
    'api/redes', 'POST',
    'api/redes/<int:pk>/', 'GET',  
    'api/redes/<int:pk>/', 'PUT',
    'api/redes/<int:pk>/', 'DELETE',
    'api/redes/<int:pk>/pontos', 'GET',

    'api/pontos/<int:pk>/', 'GET',
    'api/pontos/<int:pk>/', 'POST',
    'api/pontos/<int:pk>/', 'PUT',
    'api/pontos/<int:pk>/', 'DELETE',
    'api/pontos/<int:pk>/visitas', 'GET',

    'api/visitas/<int:pk>', 'GET',
    'api/visitas/<int:pk>', 'POST',
    'api/visitas/<int:pk>', 'PUT',
    'api/visitas/<int:pk>', 'DELETE',

    'api-auth/',
    'api-token-auth/',
    'admin/'
]