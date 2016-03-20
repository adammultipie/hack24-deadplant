from django.shortcuts import render, get_object_or_404
from boards import models as board_models

def index(request):
    board_ids = list(board_models.NoticeBoardOwner.objects.filter(user=request.user).values_list('board_id', flat=True))
    boards = board_models.NoticeBoard.objects.filter(pk__in=board_ids).all()

    return render(request, 'notice-board-list.html', { 'boards': boards })

def notice_board_posts(request, notice_board_id):
    nb = get_object_or_404(board_models.NoticeBoard, pk=notice_board_id)
    posts = nb.post_set.all()
    return render(request, 'notice-board-content.html', {'board': nb, 'posts': posts})