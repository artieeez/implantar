from django.urls import path, include
from django.contrib import admin
from rest_framework.authtoken import views

from django.conf.urls.static import static
from django.conf import settings

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView)

urlpatterns = [
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/api-auth/', include('rest_framework.urls')), # browsable api login
    path('api/admin/', admin.site.urls),
    path('api/', include('checker.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
