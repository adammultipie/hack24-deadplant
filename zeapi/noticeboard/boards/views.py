import json

from django.shortcuts import render, get_object_or_404
from rest_framework.parsers import JSONParser
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.authentication import SessionAuthentication, BasicAuthentication, TokenAuthentication
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.reverse import reverse

from boards import models
from boards import serializers
from django.db.models import Q


@api_view(['GET', 'POST'])
def messages(request, noticeboard_pk):
    board = get_object_or_404(models.NoticeBoard, pk=noticeboard_pk)
    posts = board.post_set.order_by('-created')
    serializer = serializers.PostSerializer(posts, many=True, context={'request': request})
    return Response(serializer.data)

@api_view(['POST'])
@authentication_classes((SessionAuthentication, BasicAuthentication, TokenAuthentication))
@permission_classes((IsAuthenticated,))
def create_new_board(request):
    data = request.data
    if not data:
        try:
            data = json.loads(request.body)
        except ValueError:
            data = {}
    board = models.NoticeBoard()
    board.name = data.get('name', 'Untitled')
    triggers = data.get('triggers', [])
    board.save()

    bo = models.NoticeBoardOwner()
    bo.board_id = board.pk
    bo.user_id = request.user.pk
    bo.save()
    for trigger_info in triggers:
        trigger = models.Triggers()
        trigger.board_id = board.pk
        trigger.uuid = trigger_info.get('uuid')
        trigger.major = trigger_info.get('major')
        trigger.minor = trigger_info.get('minor')
        trigger.save()
    return Response({'status': 'success', 'pk': board.pk,
                     'url':  reverse('view-notice-board',
                                     kwargs={'notice_board_id': board.pk},
                                     request=request)})

@api_view(['POST'])
@authentication_classes((SessionAuthentication, BasicAuthentication, TokenAuthentication))
@permission_classes((IsAuthenticated,))
def create_board_trigger(request, noticeboard_pk):
    data = request.data
    if not data:
        try:
            data = json.loads(request.body)
        except ValueError:
            data = {}
    board = get_object_or_404(models.NoticeBoard, pk=noticeboard_pk)
    trigger = models.Triggers()
    trigger.board = board
    trigger.uuid = data.get('uuid')
    trigger.major = data.get('major')
    trigger.minor = data.get('minor')
    trigger.save()
    return Response({'status': 'success',
                     'next': reverse('view-notice-board',
                                     kwargs={'notice_board_id': noticeboard_pk},
                                     request=request)})

@api_view(['PUT', 'POST'])
@authentication_classes((SessionAuthentication, BasicAuthentication, TokenAuthentication))
@permission_classes((IsAuthenticated,))
def post_message(request, noticeboard_pk):
    board = get_object_or_404(models.NoticeBoard, pk=noticeboard_pk)
    permission = get_object_or_404(models.NoticeBoardOwner, board=board, user=request.user)
    data = request.data
    if not data:
        try:
            data = json.loads(request.body)
        except ValueError:
            data = {}

    post = models.Post()
    post.creator = request.user
    post.title = data.get('title', 'Untitled')
    post.board = board
    for file_name in request.FILES:
        if request.FILES[file_name]:
            post.file = request.FILES[file_name]
    post.save()

    serializer = serializers.PostSerializer(post, many=False, context={'request': request})
    return Response(serializer.data)

@api_view(['GET', 'POST'])
def noticeboard_by_ibeacon(request):
    boards = models.NoticeBoard.objects
    triggers = models.Triggers.objects
    data = request.data
    if not data:
        try:
            data = json.loads(request.body)
        except ValueError:
            data = {}
    print(data)
    beacons = data.get('beacons', [])

    q_filter = Q(board=None)
    for beacon in beacons:
        uuid = beacon.get('uuid', '').replace('-', '')
        major = beacon.get('major')
        minor = beacon.get('minor')
        q_filter = q_filter | (Q(uuid=uuid) & Q(major=major) & Q(minor=minor))
    triggers = triggers.filter(q_filter).all()
    ids = []
    for trigger in triggers:
        ids.append(trigger.board_id)
    boards = boards.filter(pk__in=ids)


    boards = boards.all()
    serializer = serializers.NoticeBoardSerializer(boards, many=True, context={'request': request})
    return Response(serializer.data)

@api_view(['GET','POST'])
def get_ibeacon_noticeboard(request, type=models.Triggers.IBEACON, uuid=None,
             major=None, minor=None):
    board = get_object_or_404(models.Triggers, uuid=uuid.replace('-',''),
                              major=major, minor=minor, type=type).board

    serializer = serializers.NoticeBoardSerializer(board, context={'request': request})
    return Response(serializer.data)