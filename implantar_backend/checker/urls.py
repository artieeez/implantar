from django.urls import path, include
from rest_framework.routers import DefaultRouter
from checker import views
from db_version import views as db_version

# Create a router and register our viewsets with it.
router = DefaultRouter()
router.register(r'users', views.UserViewSet, basename='usuarios')
router.register(r'register_token', views.RegisterTokenViewSet, basename='register-token')
router.register(r'redes', views.RedeViewSet, basename='rede')
router.register(r'trash/redes', views.TrashRedeViewSet, basename='trash-rede')
router.register(r'pontos', views.PontoViewSet, basename='ponto')
router.register(r'trash/pontos', views.TrashPontoViewSet, basename='trash-ponto')
router.register(r'visitas', views.VisitaViewSet, basename='visita')
router.register(r'trash/visitas', views.TrashVisitaViewSet, basename='trash-visita')
router.register(r'item_base', views.ItemBaseViewSet, basename='itembase')
router.register(r'trash/item_base', views.TrashItemBaseViewSet, basename='trash-itembase')


# The API URLs are now determined automatically by the router.
urlpatterns = [
    path('', include(router.urls)),
    path('token-auth/', views.CustomAuthToken.as_view()),
    path('redes/<int:pk>/pontos/', views.RedeViewSet.as_view({'get': 'pontos'})),
    path('trash/redes/<int:pk>/restore/', views.TrashRedeViewSet.as_view({'post': 'restore'})),
    path('pontos/<int:pk>/visitas/', views.PontoViewSet.as_view({'get': 'visitas'})),
    path('item_base/active', views.ItemBaseViewSet.as_view({'get': 'active'})),
    path('register_token/verify/<str:token>', views.RegisterTokenViewSet.as_view({'get': 'verify'})),
    path('users/my_profile', views.UserViewSet.as_view({'get': 'my_profile'})),
    path('users/<int:pk>/username_reset', views.UserViewSet.as_view({'put': 'username'})),
    path('users/<int:pk>/password_reset', views.UserViewSet.as_view({'put': 'password'})),
    path("item-photo/<int:pk>/", views.ItemPhotoUpload.as_view(), name="rest_item_photo_upload"),
    path("signature/<int:pk>/", views.SignatureUpload.as_view(), name="rest_signature_upload"),
    path("get_version/", db_version.DbVersionView.as_view()),
]