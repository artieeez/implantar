from django.urls import path, include
from rest_framework.routers import DefaultRouter
from checker import views

# Create a router and register our viewsets with it.
router = DefaultRouter()
router.register(r'redes', views.RedeViewSet)
router.register(r'pontos', views.PontoViewSet)


# The API URLs are now determined automatically by the router.
urlpatterns = [
    path('', include(router.urls)),
    path('redes/<int:pk>/pontos/', views.pontosList.as_view()),
]