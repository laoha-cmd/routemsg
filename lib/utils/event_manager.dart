import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:routemsg/packet/packet.dart';

class ChatMessageEvent {
  PktMsg msg;
  String ip;

  ChatMessageEvent(this.msg, this.ip);
}

class UserStausEvent {
  String ip;
  int status;

  UserStausEvent(this.ip, this.status);
}

typedef ChatMsgHandler = Function(ChatMessageEvent);
typedef UserStatusHandler = Function(UserStausEvent);

class EventManager {
  //私有构造函数
  EventManager._internal();
  final EventBus eventBus = EventBus();
  //保存单例
  static final EventManager _singleton = EventManager._internal();

  //工厂构造函数
  factory EventManager() => _singleton;

  StreamSubscription<ChatMessageEvent> subMsgEvent(ChatMsgHandler onData) {
    return eventBus.on<ChatMessageEvent>().listen(onData);
  }

  StreamSubscription<UserStausEvent> subUserEvent(UserStatusHandler onUser) {
    return eventBus.on<UserStausEvent>().listen(onUser);
  }

  void fireChatMessageEvent(PktMsg msg, String ip) {
    eventBus.fire(ChatMessageEvent(msg, ip));
  }

  void fireUserStatusEvent(String ip, int status) {
    eventBus.fire(UserStausEvent(ip, status));
  }
}
