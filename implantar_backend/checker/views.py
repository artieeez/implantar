from checker.models import Pessoa, Rede, Ponto, Visita
from checker.serializers import PessoaSerializer, RedeSerializer, PontoSerializer, VisitaSerializer
from rest_framework import generics, renderers, viewsets
from django.contrib.auth.models import User
from rest_framework import permissions
from rest_framework.decorators import api_view, action
from rest_framework.response import Response
from rest_framework.reverse import reverse

class RedeViewSet(viewsets.ModelViewSet):
    """
    This viewset automatically provides `list`, `create`, `retrieve`,
    `update` and `destroy` actions.

    Additionally we also provide an extra `highlight` action.
    """
    queryset = Rede.objects.all()
    serializer_class = RedeSerializer
