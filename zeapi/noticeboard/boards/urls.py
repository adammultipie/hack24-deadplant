from django.conf.urls import url, include
from rest_framework import routers, serializers, viewsets
from boards import views

router = routers.DefaultRouter()

urlpatterns = [
    url(r'^', include(router.urls)),
    url(r'noticeboard/$', views.noticeboard_by_ibeacon, name='noticeboards'),
    url(r'^ibeaconboard/(?P<uuid>[\w-]+)/(?P<major>\d+)/(?P<minor>\d+)/$', views.get_ibeacon_noticeboard, name='get_ibeacon_noticeboard'),
    url(r'noticeboard/(?P<noticeboard_pk>\d+)/messages/$', views.messages, name='board-messages'),
    url(r'noticeboard/(?P<noticeboard_pk>\d+)/newmessage/$', views.post_message, name='board-post-message'),
    url(r'createboard/', views.create_new_board, name='create-new-board'),
    url(r'createtrigger/(?P<noticeboard_pk>\d+)/', views.create_board_trigger, name='create-trigger'),
]
