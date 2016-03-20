from rest_framework import serializers
from rest_framework.fields import ListField, FloatField
from rest_framework.reverse import reverse

from boards import models


class PostSerializer(serializers.ModelSerializer):
    file = serializers.SerializerMethodField()
    thumb = serializers.SerializerMethodField()
    author = serializers.SlugRelatedField(many=False, read_only=True,
                                          slug_field='username', source='creator')

    def get_file(self, obj):
        if not obj.file:
            return ''
        return self.context['request'].build_absolute_uri(obj.file.url)
    def get_thumb(self, obj):
        if not obj.thumbnail:
            return ''
        return self.context['request'].build_absolute_uri(obj.thumbnail.url)
    class Meta:
        model = models.Post
        fields = ('pk', 'title', 'file', 'created', 'author', 'text', 'thumb', 'is_alert')


class NoticeBoardSerializer(serializers.ModelSerializer):
    messages = serializers.SerializerMethodField(source='pk')
    alerts = serializers.SerializerMethodField(source='pk')

    def get_alerts(self, obj):
        serializer = PostSerializer(models.Post.objects.filter(is_alert=True, board_id=obj.pk).all(), many=True, context={'request': self.context['request']})
        return serializer.data
    def get_messages(self, obj):
        return reverse('board-messages',
                       kwargs={'noticeboard_pk': obj.pk},
                       request=self.context['request'])
    class Meta:
        model = models.NoticeBoard
        fields = ('name', 'pk', 'messages', 'alerts')
