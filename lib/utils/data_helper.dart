import 'dart:async';
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/generated/protos/msgs.pb.dart';
import 'package:routemsg/packet/packet.dart';
import 'package:routemsg/utils/event_manager.dart';
import 'package:routemsg/utils/socket_helper.dart';

import 'utils.dart';

const msgTimeoutInSecond = 1;

class ChatUser {
  String ip = "";
  String aesKey = "";
  String name = "";
  int msgTick = 0;
  int status = 0;
  int platId = 0;
  int unReadSize = 0;
}

class MessageItem {
  String sender = "";
  String recver = "";
  bool isMe = false;
  int id = 0;
  int type = 0;
  int status = 0;
  String fileName = "";
  String sourcePath = "";
  String targetPath = "";
  int fileSize = 0;
  int timestamp = 0;
  int attachCount = 0;
  int handleSize = 0;
  List<int> content = [];
}

class DataHelper {
  static final DataHelper _instance = DataHelper._internal();
  factory DataHelper() => _instance;
  DataHelper._internal();

  Map<String, ChatUser> users = {};
  Map<String, List<MessageItem>> allMessages = {};
  Map<String, Map<String, PktMsg>> replyMsgs = {};
  Map<int, int> msgAttachId = {};
  Map<int, Map<int, Uint8List>> msgAttaches = {};
  Map<int, Map<int, int>> attachHandled = {};
  ChatUser selfInfo = ChatUser();
  String broadIp = "";
  String hostName = "";
  String selectedIp = "";
  int loopTick = 0;
  String userName = "";
  String savePath = "";
  String defaultSaveDir = "";
  String defaultDownDir = "";
  bool keepFileName = false;
  int saveDirIndex = 0;
  bool showRecommApps = false;

  void _handleChatTimeout(Timer tm) {
    if (users.isEmpty) return;

    int tick = Utils.timestamp();
    if (loopTick + 30 < tick) {
      loopTick = tick;

      final pingMsg = PingPong(timestamp: Int64(tick));
      SocketHelper socket = SocketHelper();
      final rawMsg = Packet.packMsg(cmdLoop, 0, "", pingMsg);
      for (var user in users.entries) {
        // if (user.value.msgTick + 20 > tick) {
        //   continue;
        // }

        socket.sendToPoint(rawMsg, user.value.ip);
      }
    }

    for (var user in users.entries) {
      if (user.value.msgTick + 60 < tick && user.value.status == stateOnline) {
        EventManager mgr = EventManager();
        users[user.key]?.status = stateOffLine;
        mgr.fireUserStatusEvent(user.value.ip, stateOnline);
      }
    }
  }

  void _handleMsgTimeout(Timer tm) {
    if (replyMsgs.isEmpty) return;

    int tick = Utils.timestamp();
    SocketHelper socket = SocketHelper();

    for (var pPare in replyMsgs.entries) {
      String ip = pPare.key;
      final pMap = pPare.value;

      for (var pMsgs in pMap.entries) {
        pMsgs.key;
        pMsgs.value;

        if (pMsgs.value.tick + msgTimeoutInSecond < tick) {
          continue;
        }

        pMsgs.value.tick = tick;

        Utils.logout("resend cmd ${pMsgs.value.cmd} to $ip");

        socket.sendToPoint(
            Packet.packMsg(
                pMsgs.value.cmd, 1, getChatKey(ip), pMsgs.value.body!),
            ip);
      }
    }
  }

  ChatMessage msgToPbMsg(MessageItem msg) {
    var pbMsg = ChatMessage.create();
    pbMsg.content = msg.content;
    pbMsg.fileName = msg.fileName;
    pbMsg.fileSize = msg.fileSize;
    pbMsg.fromIp = msg.sender;
    pbMsg.msgId = Int64(msg.id);
    pbMsg.msgType = msg.type;
    pbMsg.sourcePath = msg.sourcePath;
    pbMsg.status = msg.status;
    pbMsg.targetPath = msg.targetPath;
    pbMsg.toIp = msg.recver;
    pbMsg.attachCount = msg.attachCount;
    pbMsg.timestamp = Int64(msg.timestamp);

    return pbMsg;
  }

  MessageItem pbMsgToMsg(ChatMessage pbMsg) {
    var msg = MessageItem();
    msg.content = pbMsg.content;
    msg.fileName = pbMsg.fileName;
    msg.fileSize = pbMsg.fileSize;
    msg.sender = pbMsg.fromIp;
    msg.id = pbMsg.msgId.toInt();
    msg.type = pbMsg.msgType;
    msg.sourcePath = pbMsg.sourcePath;
    msg.status = pbMsg.status;
    msg.targetPath = pbMsg.targetPath;
    msg.recver = pbMsg.toIp;
    msg.attachCount = pbMsg.attachCount;
    msg.timestamp = pbMsg.timestamp.toInt();

    return msg;
  }

  void setSelectedIp(String ip) {
    Utils.logout("set selected ip $ip");
    selectedIp = ip;
  }

  void addUserUnRead(String ip) {
    Utils.logout("addUserUnRead ip=$ip,selectedIp:$selectedIp");
    if (ip == selectedIp) return;

    var u = users[ip];
    u?.unReadSize++;

    Utils.logout("addUserUnRead $ip,unreadSize:${u?.unReadSize}");

    users[ip] = u!;
  }

  int getUserUnRead(String ip) {
    if (!users.containsKey(ip)) {
      return 0;
    }

    var u = users[ip];
    return u!.unReadSize;
  }

  void resetUserUnRead(String ip) {
    if (!users.containsKey(ip)) {
      return;
    }

    users[ip]!.unReadSize = 0;

    Utils.logout("reset ip $ip unread msg size to 0");
  }

  void onUserStatus(dynamic dMsg) {
    final event = dMsg as UserStausEvent;

    setUserStatus(event.ip, event.status);
  }

  void sendAttachMessage(
      MessageItem msg, int attachId, String filePath, String ip) {
    int size = msg.fileSize;

    Utils.logout("sendAttachMessage $filePath,total size $size");

    final offset = (attachId - 1) * maxBodyLength;
    Utils.getFileContent(msg.sourcePath, offset, maxBodyLength).then((val) {
      Utils.logout(
          "sendAttachMessage $filePath,total size $size, cur length ${val.length}");
      AttachMessage message = AttachMessage();
      message.content = val;
      message.attachId = Int64(attachId);
      message.msgId = Int64(msg.id);
      message.lessLength = size - offset - maxBodyLength;
      if (message.lessLength < 0) message.lessLength = 0;
      message.timestamp = Int64(Utils.timestamp());

      sendToPoint(ip, cmdAttachMsg, message);

      addNeedReplyMsg(
          ip, "${msg.id}${message.attachId}", PktMsg(cmdAttachMsg, message));

      //message.content.clear();
      message.content = [];
    });
  }

  void sendToPoint(String ip, int cmd, GeneratedMessage pbMsg) {
    final SocketHelper socket = SocketHelper();
    final aesKey = getChatKey(ip);
    socket.sendToPoint(Packet.packMsg(cmd, 1, aesKey, pbMsg), ip);
  }

  void setMsgRecved(String ip, int msgId) {}

  void setMsgReaded(String ip, int msgId) {}
  void setMsgStatus(String ip, int msgId, int status) {
    MessageItem item = getMessageItem(ip, msgId);
    if (item.id < 1) {
      return;
    }

    item.status = status;
    addChatMessage(ip, item);
  }

  int addMsgHandled(String ip, int msgId, int size) {
    MessageItem item = getMessageItem(ip, msgId);
    if (item.id > 0) {
      item.handleSize += size;

      if (item.handleSize >= item.fileSize) {
        item.handleSize = item.fileSize;
        item.status = msgSendOk;
      }

      addChatMessage(ip, item);

      return item.handleSize;
    }

    return 0;
  }

  void setMsgHandled(String ip, int msgId, int size) {
    MessageItem item = getMessageItem(ip, msgId);
    if (item.id > 0) {
      item.handleSize = size;

      addChatMessage(ip, item);
    }
  }

  int getMsgHandled(String ip, int msgId) {
    MessageItem item = getMessageItem(ip, msgId);
    return item.handleSize;
  }

  void onSocketData(dynamic dMsg) {
    final event = dMsg as ChatMessageEvent;
    final cmd = event.msg.cmd;
    final rawPbMsg = event.msg.body;
    final ip = event.ip;
    EventManager mgr = EventManager();

    switch (cmd) {
      case cmdAttachAck:
        final pbMsg = rawPbMsg as AttachResponse;
        Utils.logout(
            "get a attch ack ip=$ip, attachId=${pbMsg.attachId} result:${pbMsg.result}");
        final msg = getMessageItem(ip, pbMsg.msgId.toInt());
        if (msg.id > 0) {
          rmNeedReplyMsg(ip, "${msg.id}${pbMsg.attachId}");

          if (pbMsg.result == retFinished) {
            setMsgStatus(ip, msg.id, msgSendOk);
          } else if (pbMsg.result == retErrAbort) {
            setMsgStatus(ip, msg.id, msgSendFail);
          } else if (pbMsg.result == retErrRetry) {
            final attachId = pbMsg.expectId.toInt();

            if (attachHandled.containsKey(msg.id)) {
              final handled = attachHandled[msg.id];
              if (handled!.containsKey(attachId)) {
                int state = handled[attachId]!;
                if (state > 1) {
                  break;
                }
              }
            }

            sendAttachMessage(msg, attachId, msg.sourcePath, ip);
            //addAttachState(msg.id, attachId);
          } else {
            setMsgHandled(ip, msg.id, pbMsg.handleLen);
            //addAttachState(msg.id, pbMsg.attachId.toInt(), state: 8);
            int nextId = pbMsg.attachId.toInt() + 1;
            Utils.logout(
                "get a attch ack attachId=${pbMsg.attachId}, attachCount=${msg.attachCount}");
            if (msg.attachCount > 0 && pbMsg.attachId < msg.attachCount) {
              sendAttachMessage(msg, nextId, msg.sourcePath, ip);
              //addAttachState(msg.id, nextId);
            } else {
              setMsgStatus(ip, msg.id, msgSendOk);
            }
          }
        }

        updateUserTick(ip, 0);
        mgr.fireChatMessageEvent(event.msg, ip);

      case cmdAttachMsg:
        final pbMsg = rawPbMsg as AttachMessage;
        final msg = getMessageItem(ip, pbMsg.msgId.toInt());
        Utils.logout(
            "get a attach msg ip=$ip, msg=${msg.id},attachId:${pbMsg.attachId}/${msg.attachCount},dstFile:${msg.targetPath}");

        AttachResponse rsp = AttachResponse();
        rsp.attachId = pbMsg.attachId;
        rsp.msgId = pbMsg.msgId;
        rsp.result = 1;
        rsp.timestamp = Int64(Utils.timestamp());
        rsp.recvLength = pbMsg.content.length;

        final attchId = pbMsg.attachId.toInt();

        if (msg.id < 1) {
          Utils.logout("***attach parent msg ${pbMsg.msgId} not found");
          rsp.result = retErrAbort;
          sendToPoint(ip, cmdAttachAck, rsp);
          break;
        }

        if (msg.status != msgSending) {
          rsp.result = retFinished;
          sendToPoint(ip, cmdAttachAck, rsp);
          break;
        }

        if (msgAttaches.containsKey(msg.id)) {
          final attachMap = msgAttaches[msg.id];
          if (!attachMap!.containsKey(attchId)) {
            attachMap[attchId] = Uint8List.fromList(pbMsg.content);
            addMsgHandled(ip, msg.id, pbMsg.content.length);

            rsp.handleLen = getMsgHandled(ip, msg.id);

            if (Utils.isAttachFollowd(attachMap)) {
              final forced = attachMap.containsKey(msg.attachCount);
              final errMsg = Utils.appendFlushFile(
                  msg.targetPath, attachMap, 1024 * 1024, forced);

              Utils.logout("append ${msg.targetPath}:$errMsg,forced=$forced");
              if (forced || errMsg.isEmpty) {
                attachMap.clear();
                msgAttaches.remove(msg.id);

                if (forced) {
                  setMsgStatus(ip, msg.id, msgSendOk);
                  rsp.result = retFinished;
                }

                sendToPoint(ip, cmdAttachAck, rsp);
                mgr.fireChatMessageEvent(event.msg, ip);
                break;
              }
            }

            sendToPoint(ip, cmdAttachAck, rsp);
            mgr.fireChatMessageEvent(event.msg, ip);
          }
        } else {
          var attachMap = <int, Uint8List>{};
          attachMap[attchId] = Uint8List.fromList(pbMsg.content);
          msgAttaches[msg.id] = attachMap;
          addMsgHandled(ip, msg.id, pbMsg.content.length);

          rsp.handleLen = getMsgHandled(ip, msg.id);

          if (Utils.isAttachFollowd(attachMap)) {
            final forced = attachMap.containsKey(msg.attachCount);
            final errMsg = Utils.appendFlushFile(
                msg.targetPath, attachMap, 1024 * 1024, forced);
            Utils.logout("append ${msg.targetPath}:$errMsg,forced=$forced");
            if (forced || errMsg.isEmpty) {
              attachMap.clear();
              msgAttaches.remove(msg.id);

              if (forced) {
                setMsgStatus(ip, msg.id, msgSendOk);
                rsp.result = retFinished;
              }
            }
          }
          updateUserTick(ip, 0);
          sendToPoint(ip, cmdAttachAck, rsp);
          mgr.fireChatMessageEvent(event.msg, ip);
        }

      // if (msgAttachId.containsKey(msg.id)) {
      //   final lastAttachId = msgAttachId[msg.id];
      //   if (lastAttachId! >= attchId) {
      //     //already recved
      //     rsp.handleLen = getMsgHandled(ip, msg.id);
      //     sendToPoint(ip, cmdAttachAck, rsp);
      //     rsp.attachId = Int64(lastAttachId);

      //     mgr.fireChatMessageEvent(event.msg, ip);
      //     break;
      //   }

      //   if (attchId > lastAttachId + 1) {
      //     //out order
      //     rsp.expectId = Int64(lastAttachId + 1);
      //     rsp.handleLen = getMsgHandled(ip, msg.id);
      //     rsp.result = retErrRetry;

      //     sendToPoint(ip, cmdAttachAck, rsp);
      //     break;
      //   }
      // } else if (pbMsg.attachId != 1 && msg.status == msgSending) {
      //   rsp.expectId = Int64(1);
      //   rsp.result = retErrRetry;
      //   rsp.handleLen = getMsgHandled(ip, msg.id);
      //   sendToPoint(ip, cmdAttachAck, rsp);
      //   break;
      // }

      // if (msg.status == msgSending) {
      //   msgAttachId[msg.id] = attchId;
      //   final errMsg = Utils.appendFile(msg.targetPath, pbMsg.content);
      //   if (errMsg.isNotEmpty) {
      //     Utils.logout("flush to ${msg.targetPath} fail $errMsg");
      //     rsp.result = retErrRetry;
      //     rsp.handleLen = getMsgHandled(ip, msg.id);
      //     rsp.expectId = pbMsg.attachId;
      //     sendToPoint(ip, cmdAttachAck, rsp);
      //     break;
      //   }

      //   final handled = addMsgHandled(ip, msg.id, pbMsg.content.length);
      //   rsp.handleLen = handled;
      // } else {
      //   rsp.handleLen = msg.fileSize;
      // }

      // if (pbMsg.attachId.toInt() == msg.attachCount) {
      //   setMsgStatus(ip, msg.id, msgSendOk);
      //   msgAttachId.remove(msg.id);
      // }

      case cmdChatAck:
        final pbMsg = rawPbMsg as ChatResponse;

        final msg = getMessageItem(ip, pbMsg.msgId.toInt());

        Utils.logout(
            "get a msg ack cmd=$cmd, ip=$ip, msgId=${pbMsg.msgId},attach:${msg.attachCount}");

        if (msg.id > 0) {
          rmNeedReplyMsg(ip, msg.id.toString());

          if (msg.type == msgTypeText || msg.attachCount < 1) {
            setMsgRecved(ip, pbMsg.msgId.toInt());
          }

          if (pbMsg.result == retErrAbort) {
            setMsgStatus(ip, pbMsg.msgId.toInt(), msgSendFail);
          } else if (msg.attachCount > 0) {
            sendAttachMessage(msg, 1, msg.sourcePath, ip);
          }
        }

        updateUserTick(ip, 0);
        mgr.fireChatMessageEvent(event.msg, ip);

      case cmdChatMsg:
        final pbMsg = rawPbMsg as ChatMessage;
        Utils.logout("get a msg cmd=$cmd, ip=$ip, body=$pbMsg");
        final msg = pbMsgToMsg(pbMsg);
        ChatResponse rsp = ChatResponse();

        rsp.msgId = pbMsg.msgId;
        rsp.result = 1;
        rsp.sourcePath = msg.sourcePath;
        rsp.timestamp = Int64(Utils.timestamp());

        if (msg.type != msgTypeText) {
          String filePath = "$savePath/${msg.fileName}";
          if (!DataHelper().keepFileName) {
            final fData = Utils.parseFilePath(filePath);
            filePath = Utils.makeLocalName(
                fData.dirPath, rsp.msgId.toInt(), fData.extetion);
          }

          msg.targetPath = filePath;
          Utils.logout("msg:${rsp.msgId} save to ${msg.targetPath}");

          if (msg.attachCount < 1) {
            Utils.saveFileFull(filePath, msg.content);

            rsp.recvLength = msg.content.length;

            //msg.content.clear();
            msg.content = [];
            msg.status = msgSendOk;
          }
        }

        addChatMessage(ip, msg);
        addUserUnRead(ip);
        sendToPoint(ip, cmdChatAck, rsp);
        mgr.fireChatMessageEvent(event.msg, ip);

        updateUserTick(ip, 0);

      case cmdLoop:
        final pbMsg = rawPbMsg as PingPong;
        Utils.logout("get a msg cmd=$cmd, ip=$ip, body=$pbMsg");
        if (!updateUserTick(ip, 0)) {
          SocketHelper socket = SocketHelper();
          socket.sendPointAskReport(ip);
        }

      case cmdReport:
        final pbMsg = rawPbMsg as DeviceReport;
        final aesKey = String.fromCharCodes(pbMsg.aesKey);
        Utils.logout(
            "get report ip=$ip,aes=$aesKey,name=${pbMsg.name},plat:${pbMsg.platId},way=${pbMsg.way}");

        if (pbMsg.way < 2) {
          addChatUser(ip, aesKey, pbMsg.name, pbMsg.platId);
          EventManager mgr = EventManager();
          mgr.fireUserStatusEvent(ip, stateOnline);
        }

        if (pbMsg.way == 0) {
          SocketHelper socket = SocketHelper();
          socket.sendPointReport(ip);
        } else if (pbMsg.way == 2) {
          setUserStatus(ip, stateOffLine);
          mgr.fireUserStatusEvent(ip, stateOffLine);
        }
    }
  }

  Future<bool> initDataHelper() async {
    Timer.periodic(Duration(seconds: 5), _handleChatTimeout);
    Timer.periodic(Duration(seconds: 1), _handleMsgTimeout);

    selfInfo.aesKey = Utils.getRandomString(24);
    selfInfo.ip = await Utils.getLocalIPAddress();
    if (selfInfo.ip.isNotEmpty) {
      broadIp = Utils.getBroadIp(selfInfo.ip);
    }

    Utils.logout("initDataHelper ip:${selfInfo.ip},broad:$broadIp");

    selfInfo.platId = Utils.getPlatId();
    hostName = await Utils.getDevName();

    final tmpValue = Utils.getKeyValue("installTick");
    if (tmpValue.isNotEmpty) {
      final tick = int.parse(tmpValue);
      int span = 3600 * 24 * 30;
      if (tick + span < Utils.timestamp()) {
        //showRecommApps = true;
      }
    } else {
      Utils.setKeyValue("installTick", Utils.timestamp().toString());
    }

    userName = Utils.getKeyValue(keyNameUserNicky);
    savePath = Utils.getKeyValue(keyNameSaveDir);
    final strKeepName = Utils.getKeyValue(keyNameKeepName);
    if (strKeepName.isEmpty || strKeepName != "1") {
      keepFileName = false;
    } else {
      keepFileName = true;
    }

    final strSaveIndex = Utils.getKeyValue(keyNameSaveIndex);
    if (strSaveIndex.isNotEmpty) {
      saveDirIndex = int.parse(strSaveIndex);
    }

    if (userName.isEmpty) {
      userName = hostName;
      Utils.setKeyValue(keyNameUserNicky, userName);
    }

    defaultSaveDir = await Utils.getTempDir();
    defaultDownDir = await Utils.getDownloadDir();

    if (savePath.isEmpty) {
      savePath = defaultSaveDir;
      saveDirIndex = 0;
      Utils.setKeyValue(keyNameSaveDir, savePath);
    }

    selfInfo.name = userName;

    Utils.logout(
        "get local ip ${selfInfo.ip}, platId:${selfInfo.platId},hostName=$hostName,userName=$userName,savePath=$savePath");

    final socket = SocketHelper();
    socket.initSocket();

    return false;
  }

  ChatUser? getChatUser(String ip) {
    if (users.containsKey(ip)) {
      return users[ip];
    }

    return ChatUser();
  }

  void saveAttachConfig() {
    Utils.setKeyValue(keyNameSaveIndex, saveDirIndex.toString());
    Utils.setKeyValue(keyNameSaveDir, savePath);
  }

  String getChatKey(String ip) {
    if (users.containsKey(ip)) {
      return users[ip]!.aesKey;
    }

    return "";
  }

  MessageItem getMessageItem(String ip, int msgId) {
    if (allMessages.containsKey(ip)) {
      final pList = allMessages[ip];
      for (var msg in pList!) {
        if (msg.id == msgId) {
          return msg;
        }
      }
    }

    return MessageItem();
  }

  void addNeedReplyMsg(String ip, String msgId, PktMsg msg) {
    msg.tick = Utils.timestamp();

    if (replyMsgs.containsKey(ip)) {
      var reply = replyMsgs[ip];
      reply![msgId] = msg;
    } else {
      var reply = <String, PktMsg>{};
      reply[msgId] = msg;

      replyMsgs[ip] = reply;
    }
  }

  // void addAttachState(int msgId, int attachId, {int state = 0}) {
  //   if (attachHandled.containsKey(msgId)) {
  //     final handled = attachHandled[msgId];
  //     if (state > 0) {
  //       handled![attachId] = state;
  //     } else {
  //       if (handled!.containsKey(attachId)) {
  //         final oldState = handled[attachId];

  //         handled[attachId] = oldState! + 1;
  //       }
  //     }
  //   } else {
  //     var handled = <int, int>{};
  //     if (state > 0) {
  //       handled[attachId] = state;
  //     } else {
  //       handled[attachId] = 1;
  //     }

  //     attachHandled[msgId] = handled;
  //   }
  // }

  void rmNeedReplyMsg(String ip, String msgId) {
    if (!replyMsgs.containsKey(ip)) {
      return;
    }

    var reply = replyMsgs[ip];
    reply!.remove(msgId);

    if (reply.isEmpty) {
      replyMsgs.remove(ip);
    }
  }

  List<MessageItem>? getChatMessages(String ip) {
    if (allMessages.containsKey(ip)) {
      return allMessages[ip];
    }

    return [];
  }

  void removeChatMessages(String ip) {
    allMessages.remove(ip);
  }

  void addChatMessage(String ip, MessageItem msg) {
    if (allMessages.containsKey(ip)) {
      var old = allMessages[ip];

      bool exist = false;
      for (var i = 0; i < old!.length; i++) {
        if (old[i].id == msg.id) {
          old[i] = msg;
          exist = true;
          break;
        }
      }

      if (!exist) {
        old.add(msg);
      }
    } else {
      List<MessageItem> msgs = [];
      msgs.add(msg);

      allMessages[ip] = msgs;
    }
  }

  void addChatUser(String ip, String aesKey, String name, int platId) {
    int tick = Utils.mstimestamp();

    var item = ChatUser();
    item.ip = ip;
    item.aesKey = aesKey;
    item.name = name;
    item.msgTick = tick;
    item.platId = platId;
    item.status = stateOnline;
    users[ip] = item;
  }

  bool updateUserTick(String ip, int tick) {
    if (users.containsKey(ip)) {
      if (tick == 0) {
        tick = Utils.timestamp();
      }

      users[ip]?.msgTick = tick;
      return true;
    }

    return false;
  }

  void setUserStatus(String ip, int status) {
    if (users.containsKey(ip)) {
      users[ip]?.status = status;
    }
  }
}
