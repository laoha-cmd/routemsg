import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/common/video_dialog.dart';
import 'package:routemsg/generated/protos/msgs.pb.dart';
import 'package:routemsg/packet/packet.dart';
import 'package:routemsg/utils/data_helper.dart';
import 'package:routemsg/utils/event_manager.dart';
import 'package:routemsg/utils/socket_helper.dart';
import 'package:routemsg/utils/toast_utils.dart';
import 'package:routemsg/utils/utils.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  bool hasAppBar = false;
  ChatUser curUser = ChatUser();
  ChatPage({required this.hasAppBar, required this.curUser, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<MessageItem> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DataHelper dh = DataHelper();
  final SocketHelper socket = SocketHelper();
  final EventManager mgr = EventManager();
  final audioPlayer = AudioPlayer();
  late StreamSubscription<ChatMessageEvent> stream;
  String _onAudioName = "";

  @override
  void initState() {
    dh.resetUserUnRead(widget.curUser.ip);
    stream = mgr.subMsgEvent(onData);
    dh.setSelectedIp(widget.curUser.ip);

    final msgs = dh.getChatMessages(widget.curUser.ip);
    if (msgs != null && msgs.isNotEmpty) {
      _messages.assignAll(msgs);
    }

    Utils.logout("chatPage ip:${widget.curUser.ip}, msg size:${msgs?.length}");
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _onAudioName = "";
      });
    });

    super.initState();
  }

  void onData(dynamic dMsg) {
    final event = dMsg as ChatMessageEvent;
    final cmd = event.msg.cmd;
    final rawPbMsg = event.msg.body;
    final ip = event.ip;
    if (ip != widget.curUser.ip) {
      return;
    }

    DataHelper dh = DataHelper();
    switch (cmd) {
      case cmdAttachMsg:
        final pbMsg = rawPbMsg as AttachMessage;
        final msg = dh.getMessageItem(widget.curUser.ip, pbMsg.msgId.toInt());
        setState(() {
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].id == msg.id) {
              _messages[i] = msg;
              break;
            }
          }
        });
        break;

      case cmdAttachAck:
        final pbMsg = rawPbMsg as AttachResponse;
        final msg = dh.getMessageItem(widget.curUser.ip, pbMsg.msgId.toInt());
        setState(() {
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i].id == msg.id) {
              _messages[i] = msg;
              break;
            }
          }
        });
        break;

      case cmdChatMsg:
        final pbMsg = rawPbMsg as ChatMessage;
        final msg = dh.getMessageItem(widget.curUser.ip, pbMsg.msgId.toInt());

        if (!_messages.any((ele) => ele.id == msg.id)) {
          setState(() {
            _messages.add(msg);
          });
        }

      case cmdChatAck:
        break;
    }
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (text.length <= maxBodyLength) {
      List<int> data = utf8.encode(text);

      var msg = MessageItem();
      msg.id = DateTime.now().millisecondsSinceEpoch;
      msg.content = data;
      msg.type = msgTypeText;
      msg.timestamp = Utils.timestamp();
      msg.isMe = true;
      msg.sender = dh.selfInfo.ip;
      msg.recver = widget.curUser.ip;

      var pbMsg = dh.msgToPbMsg(msg);

      socket.sendToPoint(
          Packet.packMsg(
              cmdChatMsg, 1, dh.getChatKey(widget.curUser.ip), pbMsg),
          widget.curUser.ip);

      dh.addChatMessage(msg.recver, msg);
      dh.addNeedReplyMsg(
          msg.recver, msg.id.toString(), PktMsg(cmdChatMsg, pbMsg));

      setState(() {
        _messages.add(msg);
        _textController.clear();
      });

      _scrollToBottom();
    } else {
      final pList = Utils.splitString(text, maxBodyLength);
      int loop = 0;
      int tick = DateTime.now().millisecondsSinceEpoch;
      for (var item in pList) {
        var msg = MessageItem();
        msg.id = tick + loop;
        msg.content = item;
        msg.type = msgTypeText;
        msg.timestamp = Utils.timestamp();
        msg.isMe = true;
        msg.sender = dh.selfInfo.ip;
        msg.recver = widget.curUser.ip;

        var pbMsg = dh.msgToPbMsg(msg);

        socket.sendToPoint(
            Packet.packMsg(
                cmdChatMsg, 1, dh.getChatKey(widget.curUser.ip), pbMsg),
            widget.curUser.ip);

        dh.addChatMessage(msg.recver, msg);
        dh.addNeedReplyMsg(
            msg.recver, msg.id.toString(), PktMsg(cmdChatMsg, pbMsg));
        loop++;

        setState(() {
          _messages.add(msg);
        });
      }

      _textController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path!);
      _sendImageMessage(file);
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      File file = File(result.files.single.path!);
      _sendVideoMessage(file);
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      File file = File(result.files.single.path!);
      _sendAudioMessage(file);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      File file = File(result.files.single.path!);

      _sendFileMessage(file);
    }
  }

  void _sendImageMessage(File imageFile) {
    int size = imageFile.lengthSync();

    final message = MessageItem();
    message.id = DateTime.now().millisecondsSinceEpoch;
    message.fileSize = size;
    message.fileName = imageFile.uri.pathSegments.last;
    message.type = msgTypeImage;
    message.timestamp = Utils.timestamp();
    message.sourcePath = imageFile.path;
    message.sender = dh.selfInfo.ip;
    message.recver = widget.curUser.ip;
    if (size < maxBodyLength) {
      Utils.getFileContent(message.sourcePath, 0, maxBodyLength).then((val) {
        message.content = val;
        message.attachCount = 0;

        var pbMsg = dh.msgToPbMsg(message);

        socket.sendToPoint(
            Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
            widget.curUser.ip);

        message.content.clear();
        message.content = [];
        dh.addChatMessage(message.recver, message);
        dh.addNeedReplyMsg(
            message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
        setState(() {
          _messages.add(message);
        });

        _scrollToBottom();
      });
    } else {
      message.attachCount = (size / maxBodyLength).toInt();
      if (size % maxBodyLength != 0) {
        message.attachCount++;
      }

      Utils.logout(
          "file ${message.sourcePath}, total:${message.fileSize},attachSize:${message.attachCount}");

      var pbMsg = dh.msgToPbMsg(message);

      socket.sendToPoint(
          Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
          widget.curUser.ip);

      message.content.clear();
      message.content = [];
      dh.addChatMessage(message.recver, message);
      dh.addNeedReplyMsg(
          message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    }
  }

  void _sendAudioMessage(File videoFile) {
    int size = videoFile.lengthSync();

    final message = MessageItem();
    message.id = DateTime.now().millisecondsSinceEpoch;
    message.fileSize = size;
    message.fileName = videoFile.uri.pathSegments.last;
    message.type = msgTypeVoice;
    message.timestamp = Utils.timestamp();
    message.sourcePath = videoFile.path;
    message.sender = dh.selfInfo.ip;
    message.recver = widget.curUser.ip;
    if (size < maxBodyLength) {
      Utils.getFileContent(message.sourcePath, 0, maxBodyLength).then((val) {
        message.content = val;
        message.attachCount = 0;

        var pbMsg = dh.msgToPbMsg(message);

        socket.sendToPoint(
            Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
            widget.curUser.ip);

        message.content.clear();
        message.content = [];
        dh.addChatMessage(message.recver, message);
        dh.addNeedReplyMsg(
            message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
        setState(() {
          _messages.add(message);
        });

        _scrollToBottom();
      });
    } else {
      message.attachCount = (size / maxBodyLength).toInt();
      if (size % maxBodyLength != 0) {
        message.attachCount++;
      }

      var pbMsg = dh.msgToPbMsg(message);

      socket.sendToPoint(
          Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
          widget.curUser.ip);

      message.content.clear();
      message.content = [];
      dh.addChatMessage(message.recver, message);
      dh.addNeedReplyMsg(
          message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    }
  }

  void _sendVideoMessage(File videoFile) {
    int size = videoFile.lengthSync();

    final message = MessageItem();
    message.id = DateTime.now().millisecondsSinceEpoch;
    message.fileSize = size;
    message.fileName = videoFile.uri.pathSegments.last;
    message.type = msgTypeVideo;
    message.timestamp = Utils.timestamp();
    message.sourcePath = videoFile.path;
    message.sender = dh.selfInfo.ip;
    message.recver = widget.curUser.ip;
    if (size < maxBodyLength) {
      Utils.getFileContent(message.sourcePath, 0, maxBodyLength).then((val) {
        message.content = val;
        message.attachCount = 0;

        var pbMsg = dh.msgToPbMsg(message);

        socket.sendToPoint(
            Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
            widget.curUser.ip);

        message.content.clear();
        message.content = [];
        dh.addChatMessage(message.recver, message);
        dh.addNeedReplyMsg(
            message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
        setState(() {
          _messages.add(message);
        });

        _scrollToBottom();
      });
    } else {
      message.attachCount = (size / maxBodyLength).toInt();
      if (size % maxBodyLength != 0) {
        message.attachCount++;
      }

      var pbMsg = dh.msgToPbMsg(message);

      socket.sendToPoint(
          Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
          widget.curUser.ip);

      message.content.clear();
      message.content = [];
      dh.addChatMessage(message.recver, message);
      dh.addNeedReplyMsg(
          message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    }
  }

  void _sendFileMessage(File videoFile) {
    int size = videoFile.lengthSync();

    final message = MessageItem();
    message.id = DateTime.now().millisecondsSinceEpoch;
    message.fileSize = size;
    message.fileName = videoFile.uri.pathSegments.last;
    message.type = msgTypeFile;
    message.timestamp = Utils.timestamp();
    message.sourcePath = videoFile.path;
    message.sender = dh.selfInfo.ip;
    message.recver = widget.curUser.ip;
    if (size < maxBodyLength) {
      Utils.getFileContent(message.sourcePath, 0, maxBodyLength).then((val) {
        message.content = val;
        message.attachCount = 0;

        var pbMsg = dh.msgToPbMsg(message);

        socket.sendToPoint(
            Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
            widget.curUser.ip);

        message.content.clear();
        message.content = [];
        dh.addChatMessage(message.recver, message);
        dh.addNeedReplyMsg(
            message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
        setState(() {
          _messages.add(message);
        });

        _scrollToBottom();
      });
    } else {
      message.attachCount = (size / maxBodyLength).toInt();
      if (size % maxBodyLength != 0) {
        message.attachCount++;
      }

      var pbMsg = dh.msgToPbMsg(message);

      socket.sendToPoint(
          Packet.packMsg(cmdChatMsg, 1, widget.curUser.aesKey, pbMsg),
          widget.curUser.ip);

      message.content.clear();
      message.content = [];
      dh.addChatMessage(message.recver, message);
      dh.addNeedReplyMsg(
          message.recver, message.id.toString(), PktMsg(cmdChatMsg, pbMsg));
      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearAllMsgs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认'),
          content: Text('您确定要清除所有消息？'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
            TextButton(
              child: Text('确定'),
              onPressed: () {
                DataHelper dh = DataHelper();
                dh.removeChatMessages(widget.curUser.ip);
                setState(() {
                  _messages.clear();
                });
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.curUser.name),
          leading: BackButton(),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case "clear":
                    clearAllMsgs();
                    break;
                }
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'clear', child: Text('清除记录')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      );
    }

    return SafeArea(
        child: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: widget.curUser.ip.isEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.grey[80], // 背景色为灰色
              ),
              child: Center(
                // 居中文字
                child: Text(
                  '局域网传输工具\n绿色无毒永久免费',
                  style: TextStyle(
                    color: Colors.grey[200], // 文字颜色为白色
                    fontSize: 45, // 文字大小
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
    ));
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(MessageItem message) {
    message.isMe = message.sender == dh.selfInfo.ip;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) _buildAvatar(message),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: message.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!message.isMe)
                    Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        widget.curUser.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: _buildMessageContent(message),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) _buildAvatar(message),
        ],
      ),
    );
  }

  Widget _buildAvatar(MessageItem message) {
    String assets = "";
    if (message.isMe) {
      assets = Utils.getPlatAssets(dh.selfInfo.platId);
    } else {
      assets = Utils.getPlatAssets(widget.curUser.platId);
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
          radius: 16,
          child: ClipOval(
              child: Image.asset(assets,
                  width: 32, height: 32, fit: BoxFit.cover))),
    );
  }

  Widget _buildMessageContent(MessageItem message) {
    switch (message.type) {
      case msgTypeText:
        return _buildTextMessage(message);

      case msgTypeImage:
        return _buildImageMessage(message);

      case msgTypeVideo:
        return _buildVideoMessage(message);

      case msgTypeVoice:
        return _buildAudioMessage(message);

      case msgTypeFile:
        return _buildFileMessage(message);

      //case MessageType.system:
      //  return _buildSystemMessage(message);

      default:
        return Text(String.fromCharCodes(message.content));
    }
  }

  Widget _buildTextMessage(MessageItem message) {
    return SelectableText(
      utf8.decode(message.content),
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _buildImageMessage(MessageItem message) {
    String imgPath = message.targetPath;
    if (message.isMe) {
      imgPath = message.sourcePath;
    }

    double maxSize = 400;
    if (Platform.isAndroid || Platform.isIOS) {
      maxSize = 300;
    }
    final progress = DataHelper().getMsgHandled(widget.curUser.ip, message.id);

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        // details.globalPosition 获取长按的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onSecondaryTapDown: (TapDownDetails details) {
        // details.globalPosition 获取右键点击的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onTap: () {
        if (message.isMe || message.status == msgSendOk) {
          Utils.logout("_showImagePreview path = $imgPath");
          _showImagePreview(imgPath);
        } else if (message.status == msgSending) {
          ToastUtils.toast("传输中，请稍后...");
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxSize,
          maxHeight: maxSize,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: message.status == msgSendOk || message.isMe
                  ? Image.file(
                      File(imgPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
            ),
            message.status == msgSending
                ? Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        Utils.formatPercent(progress, message.fileSize),
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
                :
                // 视频角标
                Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.photo, size: 12, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _getFileName(String path) {
    try {
      Uri.parse(path).fragment;
      return Uri.parse(path).pathSegments.last;
    } catch (e) {
      return path.split('/').last;
    }
  }

  void showSavePath(String dirName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text("存储路径"),
            contentPadding: EdgeInsets.all(16),
            content: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SelectableText(dirName),
            ));
      },
    );
  }

  void showAttachDetail(MessageItem msg) {
    String filePath = msg.targetPath;
    if (msg.isMe) filePath = msg.sourcePath;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("详情"),
            titlePadding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              Row(
                children: [
                  Text(
                    "文件名:",
                    style: TextStyle(color: Colors.grey[188]),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                      child: SelectableText(msg.fileName,
                          maxLines: null,
                          style: TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
              Row(
                children: [
                  Text("文件路径:", style: TextStyle(color: Colors.grey[188])),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                      child: SelectableText(filePath,
                          maxLines: null,
                          style: TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
              Row(
                children: [
                  Text("文件大小:", style: TextStyle(color: Colors.grey[188])),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                      child: SelectableText(
                    Utils.getShowFileSize(msg.fileSize),
                    maxLines: null,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: 180,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("关闭")),
                ),
              )
            ],
          );
        });
  }

  // 显示菜单的方法
  void _showMsgMenu(BuildContext context, Offset position, MessageItem msg) {
    String filePath = msg.targetPath;
    if (msg.isMe) {
      filePath = msg.sourcePath;
    }

    String fileName = _getFileName(filePath);
    String dirName =
        filePath.substring(0, filePath.length - fileName.length - 1);

    Utils.logout("$filePath with name $fileName");

    // 如果 position 为 null (例如键盘触发或默认位置)，则使用组件中心或鼠标当前位置
    // 这里我们简单地在点击位置附近显示
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // 计算相对位置，如果 position 是全局坐标
    final RelativeRect relativePosition = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: relativePosition,
      items: [
        const PopupMenuItem(value: 'view', child: Text('详情')),
        const PopupMenuItem(value: 'open', child: Text('外部打开')),
        const PopupMenuItem(value: 'filepath', child: Text('存储路径')),
        if (Platform.isAndroid || Platform.isIOS)
          const PopupMenuItem(value: 'share', child: Text('分享')),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case "view":
            showAttachDetail(msg);

            break;

          case "open":
            Utils.outOpenFile(filePath);
            break;

          case "filepath":
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              Utils.logout("open dir name = $dirName");
              Utils.openFolder(dirName);
            } else {
              showSavePath(dirName);
            }

            break;

          case "share":
            break;
        }
      }
    });
  }

  Widget _buildVideoMessage(MessageItem message) {
    String imgPath = message.targetPath;
    if (message.isMe) {
      imgPath = message.sourcePath;
    }

    final progress = DataHelper().getMsgHandled(widget.curUser.ip, message.id);

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        // details.globalPosition 获取长按的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onSecondaryTapDown: (TapDownDetails details) {
        // details.globalPosition 获取右键点击的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onTap: () {
        if (message.isMe || message.status == msgSendOk) {
          _playVideo(imgPath);
        } else if (message.status == msgSending) {
          ToastUtils.toast("传输中，请稍后...");
        }
      },
      child: Container(
        width: 250,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.videocam, color: Colors.blue, size: 14),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFileName(imgPath),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(Utils.getShowFileSize(message.fileSize),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
            ),
            message.status == msgSending
                ? Container(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Utils.formatPercent(progress, message.fileSize),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.play_circle_filled, size: 25),
                    onPressed: () {
                      if (message.isMe || message.status == msgSendOk) {
                        _playVideo(imgPath);
                      } else if (message.status == msgSending) {
                        ToastUtils.toast("传输中，请稍后...");
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(MessageItem message) {
    String imgPath = message.targetPath;
    if (message.isMe) {
      imgPath = message.sourcePath;
    }

    final progress = DataHelper().getMsgHandled(widget.curUser.ip, message.id);

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        // details.globalPosition 获取长按的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onSecondaryTapDown: (TapDownDetails details) {
        // details.globalPosition 获取右键点击的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onTap: () {
        if (message.isMe || message.status == msgSendOk) {
          _playAudio(imgPath);
        } else if (message.status == msgSending) {
          ToastUtils.toast("传输中，请稍后...");
        }
      },
      child: Container(
        width: 200,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.audiotrack, color: Colors.purple),
            SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFileName(imgPath),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(Utils.getShowFileSize(message.fileSize),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
            ),
            message.status == msgSending
                ? Container(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Utils.formatPercent(progress, message.fileSize),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                        _onAudioName != imgPath
                            ? Icons.play_circle_filled
                            : Icons.stop_circle_rounded,
                        size: 18),
                    onPressed: () {
                      if (message.isMe || message.status == msgSendOk) {
                        if (_onAudioName != imgPath) {
                          _playAudio(imgPath);
                        } else {
                          audioPlayer.stop();
                          setState(() {
                            _onAudioName = "";
                          });
                        }
                      } else if (message.status == msgSending) {
                        ToastUtils.toast("传输中，请稍后...");
                      }
                    },
                  ),
          ],
        ),
      ),
    );

    // return Container(
    //   width: 200,
    //   padding: EdgeInsets.all(12),
    //   decoration: BoxDecoration(
    //     color: Colors.purple[100],
    //     borderRadius: BorderRadius.circular(8),
    //   ),
    //   child: Row(
    //     children: [
    //       Icon(Icons.audiotrack, color: Colors.purple),
    //       SizedBox(width: 8),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text('语音消息', style: TextStyle(fontWeight: FontWeight.bold)),
    //             SizedBox(height: 4),
    //             LinearProgressIndicator(
    //               value: 0.5,
    //               backgroundColor: Colors.purple[200],
    //               valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
    //             ),
    //           ],
    //         ),
    //       ),
    //       SizedBox(width: 8),
    //       Text('1:23', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
    //     ],
    //   ),
    // );
  }

  Widget _buildFileMessage(MessageItem message) {
    String imgPath = message.targetPath;
    if (message.isMe) {
      imgPath = message.sourcePath;
    }

    final progress = DataHelper().getMsgHandled(widget.curUser.ip, message.id);

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        // details.globalPosition 获取长按的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onSecondaryTapDown: (TapDownDetails details) {
        // details.globalPosition 获取右键点击的全局坐标
        _showMsgMenu(context, details.globalPosition, message);
      },
      onTap: () {
        if (message.isMe || message.status == msgSendOk) {
          _innerOpenFile(imgPath);
        } else if (message.status == msgSending) {
          ToastUtils.toast("传输中，请稍后...");
        }
      },
      child: Container(
        width: 250,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file, color: Colors.orange, size: 14),
            SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFileName(imgPath),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(Utils.getShowFileSize(message.fileSize),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
            ),
            message.status == msgSending
                ? Container(
                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Utils.formatPercent(progress, message.fileSize),
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.file_present_sharp, size: 25),
                    onPressed: () {
                      if (message.isMe || message.status == msgSendOk) {
                        _innerOpenFile(imgPath);
                      } else if (message.status == msgSending) {
                        ToastUtils.toast("传输中，请稍后...");
                      }
                    },
                  ),
          ],
        ),
      ),
    );

    // return Container(
    //   width: 250,
    //   padding: EdgeInsets.all(12),
    //   decoration: BoxDecoration(
    //     color: Colors.orange[100],
    //     borderRadius: BorderRadius.circular(8),
    //   ),
    //   child: Row(
    //     children: [
    //       Icon(Icons.insert_drive_file, color: Colors.orange),
    //       SizedBox(width: 12),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               message.fileName,
    //               style: TextStyle(fontWeight: FontWeight.bold),
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //             SizedBox(height: 4),
    //             Text(Utils.getShowFileSize(message.fileSize),
    //                 style: TextStyle(fontSize: 12, color: Colors.grey[700])),
    //           ],
    //         ),
    //       ),
    //       IconButton(
    //         icon: Icon(Icons.download, size: 20),
    //         onPressed: () {
    //           // 下载文件
    //         },
    //       ),
    //     ],
    //   ),
    // );
  }

  // Widget _buildSystemMessage(MessageItem message) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[300],
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       message.content,
  //       style: TextStyle(fontSize: 14, color: Colors.grey[700]),
  //     ),
  //   );
  // }

  Widget _buildMessageInput() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 60, maxHeight: 300),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            // 附件按钮
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                _showAttachmentMenu();
              },
            ),

            // 文本输入框
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
            ),

            // 发送按钮
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: _sendTextMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo, color: Colors.green),
                title: Text('图片'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: Colors.blue),
                title: Text('视频'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              ListTile(
                leading: Icon(Icons.audiotrack, color: Colors.purple),
                title: Text('音频'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAudio();
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: Colors.orange),
                title: Text('文件'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imagePath.startsWith('http')
                          ? Image.network(imagePath, fit: BoxFit.contain)
                          : Image.file(File(imagePath), fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playAudio(String audioName) async {
    if (_onAudioName.isNotEmpty) {
      audioPlayer.stop();
    }

    setState(() {
      _onAudioName = audioName;

      audioPlayer.play(DeviceFileSource(audioName));
    });
  }

  void _playVideo(String videoPath) async {
    // 使用 chewie 播放视频
    // 需要添加 video_player 和 chewie 依赖
    showDialog(
      context: context,
      builder: (context) {
        return VideoDialog(videoPath);
      },
    );
  }

  void _innerOpenFile(String filePath) {
    Utils.outOpenFile(filePath);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    stream.cancel();
    audioPlayer.dispose();

    if (widget.hasAppBar) {
      DataHelper dh = DataHelper();
      dh.setSelectedIp("");
    }

    super.dispose();
  }
}
