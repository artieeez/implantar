from django.urls import path, include
from rest_framework.routers import DefaultRouter
from checker import views

# Create a router and register our viewsets with it.
router = DefaultRouter()
router.register(r'avaliadores', views.AvaliadorViewSet)
router.register(r'redes', views.RedeViewSet)
router.register(r'pontos', views.PontoViewSet)
router.register(r'visitas', views.VisitaViewSet)
router.register(r'checklist/item', views.ItemViewSet)
router.register(r'checklist/item_base', views.ItemBaseViewSet)


# The API URLs are now determined automatically by the router.
urlpatterns = [
    path('', include(router.urls)),
    path('redes/<int:pk>/pontos/', views.RedeViewSet.as_view({'get': 'pontos'})),
    path('pontos/<int:pk>/visitas/', views.PontoViewSet.as_view({'get': 'visitas'})),
    path('checklist/item_base/active', views.ItemBaseViewSet.as_view({'get': 'active'})),
    path('avaliadores/<int:pk>/username', views.AvaliadorViewSet.as_view({'put': 'username'})),
    path('avaliadores/<int:pk>/password', views.AvaliadorViewSet.as_view({'put': 'password'})),
]