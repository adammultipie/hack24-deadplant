import json

from django.shortcuts import render, get_object_or_404
from rest_framework.parsers import JSONParser
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view, authentication_classes, permission_classes

from boards import models
from boards import serializers
from django.db.models import Q

class NoticeBoardViewSet(viewsets.ViewSet):
    parser_classes = (JSONParser,)
    def list(self, request):
        boards = models.NoticeBoard.objects
        triggers = models.Triggers.objects
        beacons = request.data.get('beacons', [])
        q_filter = Q(board=None)
        for beacon in beacons:
            uuid = beacon.get('uuid', '').replace('-', '')
            major = beacon.get('major')
            minor = beacon.get('minor')
            q_filter = q_filter | (Q(uuid=uuid) & Q(major=major) & Q(minor=minor))
            print('is beack')
        if beacons:
            triggers = triggers.filter(q_filter).all()
            ids = []
            print ('triggers %s ' % len(triggers))
            for trigger in triggers:
                ids.append(trigger.board_id)
            boards = boards.filter(pk__in=ids)


        boards = boards.all()
        serializer = serializers.NoticeBoardSerializer(boards, many=True, context={'request': request})
        return Response(serializer.data)


@api_view(['GET',])
def get_ibeacon_noticeboard(request, type=models.Triggers.IBEACON, uuid=None,
             major=None, minor=None):
    return(Response(request.body))
    board = get_object_or_404(models.Triggers, uuid=uuid.replace('-',''),
                              major=major, minor=minor, type=type).board

    serializer = serializers.NoticeBoardSerializer(board, context={'request': request})
    return Response(serializer.data)