from django.conf.urls import url, include
from boards_manager import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^board/(?P<notice_board_id>\d+)/$', views.notice_board_posts, name='view-notice-board')
]