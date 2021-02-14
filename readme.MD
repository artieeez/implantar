[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

# Implantar
Desenvolvido em parceria com a Implantar, este projeto tem como objetivo oferecer soluções para  nutricionistas e no momento conta com um sistema para auxiliar na avaliação de Boas Práticas de manipulação de alimentos. Este sistema é composto por um aplicativo mobile, o qual acompanhará o nutricionista nas visitas avaliativas, e uma interface web onde o representante do estabelecimento terá acesso aos relatórios, assim como o histórico de avaliações, gráficos e ferramentas de gestão.
#
## Tecnologias
Este projeto foi desenvolvido com:
- Backend: [Python](https://docs.python.org/3/tutorial/)/ [Django](https://www.djangoproject.com/)/ [Django Rest Framework](https://www.django-rest-framework.org/)
- Frontend web: [Javascript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)/ [Vue.js](https://vuejs.org/)(c/ [Vuex](https://vuex.vuejs.org/) e [Vue Router](https://router.vuejs.org/) )/ [BootstrapVue](https://bootstrap-vue.org/)
- Mobile: [Dart](https://dart.dev/)/ [Flutter](https://flutter.dev/)
#

## Instruções para configuração do ambiente de desenvolvimento (Docker):

### Backend e Frontend Web:

Na pasta raiz do projeto:

    docker-compose up -d

Executar o bash no container imp-dev-django:

    docker exec -it imp-dev-django bash

Criar um novo usuário

    python manage.py createsuperuser

### Mobile:
Requisitos:
* dart: ">=2.10.2 <2.11.0"
* [Flutter](https://flutter.dev/docs/get-started/install): ">=1.22.2 <2.0.0"

### Observações finais:
Usuários funcionais devem ser criados através da interface web ou diretamente pela browsable API.

Para teste do app mobile deve-se alterar a url na chave `base` no Map `API` localizada no seguinte arquivo:

    implantar_mobile/lib/services/settings.dart