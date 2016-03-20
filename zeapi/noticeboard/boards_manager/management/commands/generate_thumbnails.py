from django.core.management.base import BaseCommand, CommandError
from boards.models import Post
from django.db.transaction import atomic

class Command(BaseCommand):
    help = 'Refreshes the thumbnails of every post'

    def add_arguments(self, parser):
        pass

    @atomic
    def handle(self, *args, **options):
        posts = Post.objects.all()
        for post in posts:
            post.save() # pre_save signal does the changes
