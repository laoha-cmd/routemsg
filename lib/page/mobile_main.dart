import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routemsg/common/chat_page.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/page/about_us.dart';
import 'package:routemsg/page/help_page.dart';
import 'package:routemsg/page/setting_page.dart';
import 'package:routemsg/utils/data_helper.dart';
import 'package:routemsg/utils/event_manager.dart';
import 'package:routemsg/utils/socket_helper.dart';
import 'package:routemsg/utils/utils.dart';

class MobileMain extends StatefulWidget {
  const MobileMain({super.key});

  @override
  State<MobileMain> createState() => _MobileMainState();
}

class _MobileMainState extends State<MobileMain> {
  List<ChatUser> chats = [];
  late StreamSubscription<ChatMessageEvent> _msgStream;

  void _getRequests() async {
    Utils.logout("_getRequests run...");
    DataHelper dh = DataHelper();
    setState(() {
      chats.clear();
      chats.addAll(dh.users.values);
    });
  }

  @override
  void initState() {
    DataHelper dh = DataHelper();
    chats.clear();
    chats.assignAll(dh.users.values.toList());

    EventManager mgr = EventManager();
    mgr.subUserEvent(onUserStatus);
    _msgStream = mgr.subMsgEvent(onMsgData);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    Utils.logout("didChangeDependencies run ...");
    super.didChangeDependencies();
  }

  void onUserStatus(dynamic dMsg) {
    UserStausEvent event = dMsg as UserStausEvent;
    Utils.logout("get user status ${event.ip} status ${event.status}");
    DataHelper dh = DataHelper();

    if (event.status == stateOffLine) {
      for (var i = 0; i < chats.length; i++) {
        if (chats[i].ip == event.ip) {
          setState(() {
            chats[i].status = stateOffLine;
          });

          break;
        }
      }
    } else {
      bool exist = false;

      for (var i = 0; i < chats.length; i++) {
        if (chats[i].ip == event.ip) {
          chats[i] = dh.getChatUser(event.ip)!;
          exist = true;
          break;
        }
      }

      if (!exist) {
        setState(() {
          chats.add(dh.getChatUser(event.ip)!);
        });
      }
    }
  }

  void onMsgData(dynamic dMsg) {
    final event = dMsg as ChatMessageEvent;
    final cmd = event.msg.cmd;
    final ip = event.ip;
    final dh = DataHelper();

    switch (cmd) {
      case cmdAttachAck:
      case cmdAttachMsg:
      case cmdChatAck:
      case cmdChatMsg:
        if (ip != dh.selectedIp) {
          setState(() {
            chats.clear();
            chats.assignAll(dh.users.values.toList());
          });
        }
      case cmdLoop:
      case cmdReport:
    }
  }

  Widget buildEmpty() {
    return Stack(
      children: [
        Center(
          child: Text(
            "无其他设备",
            style: TextStyle(color: Colors.grey, fontSize: 38),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 1,
          child: Text(
            "局域网传输工具\n绿色无毒开源免费",
            style: TextStyle(color: Colors.green[100], fontSize: 12),
          ),
        )
      ],
    );
  }

  void goToChat(ChatUser user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatPage(hasAppBar: true, curUser: user);
    })).then((val) => _getRequests());
  }

  Widget buildChatList() {
    DataHelper dh = DataHelper();

    return ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final item = chats[index];
          int msgSize = dh.getUserUnRead(item.ip);
          Utils.logout("get ip ${item.ip} unread size $msgSize");

          return ListTile(
            leading: Badge(
              label: msgSize > 0
                  ? Text(
                      "${msgSize > 99 ? '99' : msgSize}",
                      style: TextStyle(color: Colors.white),
                    )
                  : const SizedBox(),
              backgroundColor: msgSize > 0 ? Colors.red : Colors.transparent,
              isLabelVisible: msgSize > 0,
              child: Image.asset(Utils.getPlatAssets(item.platId),
                  fit: BoxFit.contain),
            ),
            title: Text(item.name),
            subtitle: Text(item.ip),
            onTap: () {
              dh.setSelectedIp(item.ip);
              goToChat(chats[index]);
            },
            trailing: item.status != stateOnline
                ? Icon(Icons.error_outline_rounded, color: Colors.amberAccent)
                : null,
          );
        });
  }

  void freshDevice() async {
    final socket = SocketHelper();
    await socket.tryAcquireLock();

    socket.sendBroadReport();
  }

  void openSetting(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingPage();
    }));
  }

  void openAboutUs(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AboutPage();
    }));
  }

  void openHelp(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HelpPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    Utils.logout("build run...");
    _getRequests();

    return Scaffold(
      appBar: AppBar(
        title: Text("局域网传输工具"),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            tooltip: "更多",
            onSelected: (int value) {
              switch (value) {
                case 0:
                  freshDevice();
                  break;

                case 1:
                  openSetting(context);
                  break;

                case 2:
                  openAboutUs(context);
                  break;

                case 3:
                  openHelp(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(
                        Icons.broadcast_on_home,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Text('广播设备'),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 10),
                      Text('设置'),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.help_sharp, color: Colors.green),
                      SizedBox(width: 10),
                      Text('关于'),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.help_center, color: Colors.amber),
                      SizedBox(width: 10),
                      Text(
                        '帮助',
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Icon(
                Icons.more_vert,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: chats.isEmpty ? buildEmpty() : buildChatList(),
    );
  }

  @override
  void dispose() {
    _msgStream.cancel();

    super.dispose();
  }
}
