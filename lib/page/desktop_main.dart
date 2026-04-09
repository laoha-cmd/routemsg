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

// ignore: must_be_immutable
class DesktopMain extends StatefulWidget {
  double leftSize = 100;

  DesktopMain(this.leftSize, {super.key});

  @override
  State<DesktopMain> createState() => _DesktopMainState();
}

class _DesktopMainState extends State<DesktopMain> {
  List<ChatUser> chats = [];
  ChatUser curUser = ChatUser();
  late Widget _chatWidget;

  @override
  void initState() {
    print("_DesktopMainState initState");
    _chatWidget =
        ChatPage(hasAppBar: false, curUser: curUser, key: UniqueKey());
    DataHelper dh = DataHelper();
    chats.clear();
    chats.assignAll(dh.users.values.toList());

    EventManager mgr = EventManager();
    mgr.subUserEvent(onUserStatus);
    mgr.subMsgEvent(onMsgData);

    super.initState();
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

  Widget buildEmpty() {
    return Center(
      child: Text(
        "无其他设备",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  void goToChat(ChatUser user) {
    setState(() {
      for (var i = 0; i < chats.length; i++) {
        if (chats[i].ip == user.ip) {
          chats[i].unReadSize = 0;
          break;
        }
      }

      curUser = user;
      _chatWidget = ChatPage(
        hasAppBar: false,
        curUser: user,
        key: UniqueKey(),
      );
    });
  }

  Widget buildChatList() {
    if (chats.isEmpty) return buildEmpty();

    DataHelper dh = DataHelper();

    return ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final item = chats[index];
          int msgSize = dh.getUserUnRead(item.ip);

          if (item.ip == dh.selectedIp) {
            msgSize = 0;
          }

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
            trailing: item.status != stateOnline
                ? Icon(Icons.error_outline_rounded, color: Colors.amberAccent)
                : null,
            selected: item.ip == dh.selectedIp,
            onTap: () {
              dh.setSelectedIp(item.ip);
              goToChat(chats[index]);
            },
          );
        });
  }

  Widget buildChatSelected(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity, // 容器宽度
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey, // 右边框颜色
                width: 1.0, // 右边框宽度
              ),
            ),
          ),
          child: ListTile(
            title: Text(curUser.name.isEmpty ? "未选择消息对象" : curUser.name,
                style: TextStyle(
                    color: curUser.name.isEmpty ? Colors.grey : Colors.green)),
            trailing: PopupMenuButton<int>(
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
                    openHelpPage(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.broadcast_on_home, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('广播设备'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blue),
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
                        Icon(Icons.help, color: Colors.amber),
                        SizedBox(width: 10),
                        Text('帮助'),
                      ],
                    ),
                  ),
                ];
              },
              child: Icon(Icons.more_vert),
            ),
          ),
        ),
        SizedBox(
          height: 6,
        ),
        Expanded(child: _chatWidget),
      ],
    );
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

  void openHelpPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HelpPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    DataHelper dh = DataHelper();
    return Scaffold(
        body: Row(
          children: [
            Container(
              width: widget.leftSize, // 容器宽度
              height: double.infinity, // 容器高度
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey, // 右边框颜色
                    width: 1.0, // 右边框宽度
                  ),
                ),
              ),
              child: buildChatList(),
            ),
            Expanded(
                child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: buildChatSelected(context),
            ))
          ],
        ),
        bottomNavigationBar: Container(
          height: 25.0, // 设置高度
          color: Colors.grey[200], // 背景色
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dh.selfInfo.name,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                dh.selfInfo.ip,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                "版本: $versionName",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ));
  }
}
