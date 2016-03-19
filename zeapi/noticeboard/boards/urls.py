from django.conf.urls import url, include
from rest_framework import routers, serializers, viewsets
from boards import views

router = routers.DefaultRouter()
router.register(r'noticeboard', views.NoticeBoardViewSet, base_name='noticeboards')

urlpatterns = [
    url(r'^', include(router.urls)),
    url(r'^ibeaconboard/(?P<uuid>[\w-]+)/(?P<major>\d+)/(?P<minor>\d+)/$', views.get_ibeacon_noticeboard, name='get_ibeacon_noticeboard')
]
