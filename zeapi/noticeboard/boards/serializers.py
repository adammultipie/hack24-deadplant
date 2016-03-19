from rest_framework import serializers
from rest_framework.fields import ListField, FloatField
from rest_framework.reverse import reverse

from boards import models

class NoticeBoardSerializer(serializers.ModelSerializer):
    messages = serializers.SerializerMethodField(source='pk')

    def get_messages(self, obj):
        return reverse('board-messages',
                       kwargs={'noticeboard_pk': obj.pk},
                       request=self.context['request'])
    class Meta:
        model = models.NoticeBoard
        fields = ('name', 'pk', 'messages')


class PostSerializer(serializers.ModelSerializer):
    file = serializers.SerializerMethodField()
    author = serializers.SlugRelatedField(many=False, read_only=True,
                                          slug_field='username', source='creator')

    def get_file(self, obj):
        if not obj.file:
            return ''
        return self.context['request'].build_absolute_uri(obj.file.url)
    class Meta:
        model = models.Post
        fields = ('pk', 'title', 'file', 'created', 'author')