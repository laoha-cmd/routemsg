import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/generated/protos/msgs.pb.dart';

class PktMsg {
  int cmd = 0;
  int tick = 0;
  GeneratedMessage? body;

  PktMsg(this.cmd, this.body);
}

class Packet {
  static Uint8List _wrapData(Uint8List orgData, String sKey) {
    Uint8List key = Uint8List.fromList(sKey.codeUnits);

    Uint8List ret = Uint8List(orgData.length);
    for (var i = 0; i < orgData.length; i++) {
      ret[i] = orgData[i] ^ key[i % key.length];
    }

    return ret;
  }

  //1+1 + 2 + body
  static Uint8List packMsg(
      int cmd, int encrypt, String sKey, GeneratedMessage pbMsg) {
    final body = pbMsg.writeToBuffer();
    int bodySize = body.length;

    if (cmd == cmdReport) {
      sKey = defaultAesKey;
    }

    if (encrypt != 0 && sKey.isNotEmpty) {
      final btBody = _wrapData(body, sKey);
      bodySize = btBody.length;
      ByteData data = ByteData(bodySize + 4);
      data.setUint8(0, cmd);
      data.setUint8(1, 1);
      data.setUint16(2, bodySize);

      for (var i = 4; i < bodySize + 4; i++) {
        data.setUint8(i, btBody[i - 4]);
      }

      return Uint8List.view(data.buffer);
    } else {
      ByteData data = ByteData(bodySize + 4);
      data.setUint8(0, cmd);
      data.setUint8(1, 0);
      data.setUint16(2, bodySize);
      for (var i = 4; i < bodySize + 4; i++) {
        data.setUint8(i, body[i - 4]);
      }

      return Uint8List.view(data.buffer);
    }
  }

  static PktMsg unPackMsg(Uint8List pList, String sKey) {
    final datas = ByteData.view(pList.buffer);

    final cmd = datas.getUint8(0);
    final isEncypt = datas.getUint8(1);
    final bodyLen = datas.getUint16(2);

    if (cmd == cmdReport) {
      sKey = defaultAesKey;
    }

    if (bodyLen + 4 != pList.length) {
      return PktMsg(0, null);
    }

    Uint8List uBody = Uint8List(bodyLen);

    for (var i = 0; i < bodyLen; i++) {
      uBody[i] = datas.getUint8(i + 4);
    }

    if (isEncypt != 0 && sKey.isNotEmpty) {
      uBody = _wrapData(uBody, sKey);
    }

    GeneratedMessage? pbMsg;
    try {
      switch (cmd) {
        case cmdReport:
          pbMsg = DeviceReport.fromBuffer(uBody);
          break;

        case cmdLoop:
          pbMsg = PingPong.fromBuffer(uBody);
          break;

        case cmdChatMsg:
          pbMsg = ChatMessage.fromBuffer(uBody);
          break;

        case cmdAttachMsg:
          pbMsg = AttachMessage.fromBuffer(uBody);
          break;

        case cmdChatAck:
          pbMsg = ChatResponse.fromBuffer(uBody);
          break;

        case cmdAttachAck:
          pbMsg = AttachResponse.fromBuffer(uBody);
          break;
      }

      return PktMsg(cmd, pbMsg);
    } catch (e) {
      print('unWrapMsg Error: $e');

      return PktMsg(0, null);
    }
  }
}
