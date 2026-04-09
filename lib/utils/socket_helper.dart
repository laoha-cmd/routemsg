import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/generated/protos/msgs.pb.dart';
import 'package:routemsg/packet/packet.dart';
import 'package:routemsg/utils/event_manager.dart';
import 'package:routemsg/utils/utils.dart';

import 'data_helper.dart';

class SocketHelper {
  static const String _groupIp = '224.0.100.100';
  static const String _channelName = 'com.laoha.routemsg/multicast_lock';
  static final SocketHelper _instance = SocketHelper._internal();
  factory SocketHelper() => _instance;
  SocketHelper._internal();

  late RawDatagramSocket _socket;
  //late ServerSocket _serverSocket;
  //late RawDatagramSocket _groupSocket;

  void sendBroadReport() {
    DataHelper dh = DataHelper();
    DeviceReport report = DeviceReport();
    report.ip = dh.selfInfo.ip;
    report.name = dh.selfInfo.name;
    report.platId = dh.selfInfo.platId;
    report.way = 0;
    report.aesKey = dh.selfInfo.aesKey.codeUnits;

    Utils.logout(
        "send broad report ip:${report.ip},name:${report.name},platId:${report.platId},broad ip:${dh.broadIp}");

    final rawMsg = Packet.packMsg(cmdReport, 1, defaultAesKey, report);
    sendBroadMsg(rawMsg);
  }

  void sendBroadOffline() {
    DataHelper dh = DataHelper();
    DeviceReport report = DeviceReport();
    report.ip = dh.selfInfo.ip;
    report.name = dh.selfInfo.name;
    report.platId = dh.selfInfo.platId;
    report.way = 2;
    report.aesKey = dh.selfInfo.aesKey.codeUnits;

    Utils.logout(
        "send broad offline ip:${report.ip},name:${report.name},platId:${report.platId},broad ip:${dh.broadIp}");

    final rawMsg = Packet.packMsg(cmdReport, 1, defaultAesKey, report);
    sendBroadMsg(rawMsg);
  }

  void sendPointAskReport(String targetIp) {
    DataHelper dh = DataHelper();
    DeviceReport report = DeviceReport();
    report.ip = dh.selfInfo.ip;
    report.name = dh.selfInfo.name;
    report.platId = dh.selfInfo.platId;
    report.way = 0;
    report.aesKey = dh.selfInfo.aesKey.codeUnits;

    Utils.logout(
        "send point report ip:${report.ip},name:${report.name},platId:${report.platId}");

    final rawMsg = Packet.packMsg(cmdReport, 1, defaultAesKey, report);
    sendToPoint(rawMsg, targetIp);
  }

  void sendPointReport(String targetIp) {
    DataHelper dh = DataHelper();
    DeviceReport report = DeviceReport();
    report.ip = dh.selfInfo.ip;
    report.name = dh.selfInfo.name;
    report.platId = dh.selfInfo.platId;
    report.way = 1;
    report.aesKey = dh.selfInfo.aesKey.codeUnits;

    Utils.logout(
        "send point report ip:${report.ip},name:${report.name},platId:${report.platId}");

    final rawMsg = Packet.packMsg(cmdReport, 1, defaultAesKey, report);
    sendToPoint(rawMsg, targetIp);
  }

  Future<int> sendBroadMsg(List<int> buffer) async {
    final groupAddress = InternetAddress(DataHelper().broadIp);

    return _socket.send(buffer, groupAddress, defaultPort);
  }

  Future<void> tryAcquireLock() async {
    if (Platform.isAndroid) {
      try {
        await MethodChannel(_channelName).invokeMethod('acquireLock');
        print('[Discovery] Android MulticastLock acquired');
      } catch (e) {
        print('[Discovery] Failed to get MulticastLock: $e');
      }
    }
  }

  void initSocket() async {
    if (Platform.isAndroid) {
      try {
        await MethodChannel(_channelName).invokeMethod('acquireLock');
        print('[Discovery] Android MulticastLock acquired');
      } catch (e) {
        print('[Discovery] Failed to get MulticastLock: $e');
      }
    }

    DataHelper dh = DataHelper();
    bool reusePort = true;
    if (Platform.isWindows) {
      reusePort = false;
    }

    if (dh.selfInfo.ip.isNotEmpty) {
      _socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4, defaultPort,
          reusePort: reusePort);

      // _serverSocket = await ServerSocket.bind(
      //     InternetAddress(dh.selfInfo.ip), tcpServertPort);
    } else {
      _socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4, defaultPort,
          reusePort: reusePort);

      // _serverSocket =
      //     await ServerSocket.bind(InternetAddress.anyIPv4, tcpServertPort);
    }

    await Future.delayed(Duration(milliseconds: 500));
    // _groupSocket =
    //     await RawDatagramSocket.bind(InternetAddress.anyIPv4, multicatPort);

    // _groupSocket.broadcastEnabled = true;
    _socket.broadcastEnabled = true;

    //_groupSocket.joinMulticast(InternetAddress(_groupIp));
    _socket.joinMulticast(InternetAddress(_groupIp));
    _socket.listen(onSocketEvent);
    //_groupSocket.listen(onGroupEvent);

    sendBroadReport();
  }

  int sendToPoint(List<int> buffer, String ipAddr) {
    Utils.logout("sendToPoint buffer size ${buffer.length} to $ipAddr");

    try {
      return _socket.send(buffer, InternetAddress(ipAddr), defaultPort);
    } catch (e) {
      print("sendToPoint $ipAddr length ${buffer.length}} fail: $e");
      return 0;
    }
  }

  // void onGroupEvent(RawSocketEvent e) {
  //   switch (e) {
  //     case RawSocketEvent.read:
  //       Datagram? dg = _groupSocket.receive();
  //       var address = dg!.address.address;
  //       DataHelper dh = DataHelper();

  //       final rawMsg = Packet.unPackMsg(dg.data, dh.selfInfo.aesKey);

  //       if (address == dh.selfInfo.ip) {
  //         Utils.logout("get self msg cmd=${rawMsg.cmd}");
  //         return;
  //       }

  //       if (rawMsg.cmd < 1) {
  //         Utils.logout("unpack msg fail ");
  //       } else {
  //         dh.onSocketData(ChatMessageEvent(rawMsg, address));
  //       }

  //       break;

  //     case RawSocketEvent.write:
  //       break;

  //     case RawSocketEvent.readClosed:
  //       break;

  //     case RawSocketEvent.closed:
  //       break;
  //   }
  // }

  void onSocketEvent(RawSocketEvent e) {
    switch (e) {
      case RawSocketEvent.read:
        Datagram? dg = _socket.receive();
        var address = dg!.address.address;
        DataHelper dh = DataHelper();

        final rawMsg = Packet.unPackMsg(dg.data, dh.selfInfo.aesKey);

        if (address == dh.selfInfo.ip) {
          Utils.logout("get self msg cmd=${rawMsg.cmd}");
          return;
        }

        if (rawMsg.cmd < 1) {
          Utils.logout("unpack msg fail ");
        } else {
          dh.onSocketData(ChatMessageEvent(rawMsg, address));
        }

        break;

      case RawSocketEvent.write:
        break;

      case RawSocketEvent.readClosed:
        break;

      case RawSocketEvent.closed:
        break;
    }
  }

  void stop() {
    _socket.close();
    //_groupSocket.close();

    if (Platform.isAndroid) {
      MethodChannel(_channelName)
          .invokeMethod('releaseLock')
          .catchError((e) => null);
    }
  }
}
