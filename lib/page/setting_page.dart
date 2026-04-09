import 'package:flutter/material.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/page/donate_page.dart';
import 'package:routemsg/page/help_page.dart';
import 'package:routemsg/page/privacypolicy_page.dart';
import 'package:routemsg/page/recomm_page.dart';
import 'package:routemsg/utils/data_helper.dart';
import 'package:routemsg/utils/utils.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _userName = "";
  String _saveDir = "";
  bool _keepFileName = false;
  int _saveIndex = 0;
  final dh = DataHelper();

  @override
  void initState() {
    _keepFileName = dh.keepFileName;
    _saveDir = dh.savePath;
    _saveIndex = dh.saveDirIndex;
    _userName = dh.userName;

    Utils.logout("_saveDir=$_saveDir,_saveIndex=$_saveIndex");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("设置"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.title_rounded),
            title: Text('本地名称'),
            subtitle: Text(_userName),
            trailing: Icon(Icons.edit, size: 16),
            onTap: () => _showEditNameDialog(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.attach_file_rounded),
            title: Text('附件存储路径'),
            subtitle: _saveIndex == 0 ? Text("缓存目录") : Text("下载目录"),
            trailing: Icon(Icons.edit, size: 16),
            onTap: () => _showSaveDirDialog(),
          ),
          Divider(),
          // 通知开关
          SwitchListTile(
            secondary: Icon(Icons.notifications),
            title: Text('附件按源文件名'),
            subtitle: Text('接收文件是否保留原文件名(同名文件会覆盖)'),
            value: _keepFileName,
            onChanged: (bool value) {
              setState(() {
                _keepFileName = value;

                dh.keepFileName = _keepFileName;
                if (dh.keepFileName) {
                  Utils.setKeyValue(keyNameKeepName, "1");
                } else {
                  Utils.setKeyValue(keyNameKeepName, "0");
                }
              });
            },
          ),

          Divider(),
          // ListTile(
          //   leading: Icon(Icons.card_giftcard),
          //   title: Text('打赏'),
          //   trailing: Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) {
          //       return DonationPage();
          //     }));
          //     // ScaffoldMessenger.of(context).showSnackBar(
          //     //   SnackBar(
          //     //     content: Text('开源软件，无需打赏'),
          //     //     duration: Duration(seconds: 3),
          //     //   ),
          //     // );
          //   },
          // ),
          // 关于
          ListTile(
            leading: Icon(Icons.help),
            title: Text('帮助'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HelpPage();
              }));
            },
          ),

          ListTile(
            leading: Icon(Icons.policy),
            title: Text('隐私政策'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PrivacyPolicyPage();
              }));
            },
          ),
          if (dh.showRecommApps)
            ListTile(
              leading: Icon(Icons.thumb_up),
              title: Text('推荐应用'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RecommendPage();
                }));
              },
            ),
          SizedBox(height: 20),

          // 版本信息
          Center(
            child: Text(
              '版本 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    TextEditingController _controller = TextEditingController();
    _controller.text = _userName;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('修改本地名称'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '请输入新名称',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            // 取消按钮
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
            // 确定按钮
            TextButton(
              onPressed: () {
                // 这里处理确定逻辑
                setState(() {
                  String newName = _controller.text.trim();
                  if (newName.isNotEmpty) {
                    _userName = _controller.text;
                    dh.userName = _userName;
                    Utils.setKeyValue(keyNameUserNicky, newName);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showSaveDirDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择附件路径'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('缓存目录'),
                onTap: () {
                  dh.saveDirIndex = 0;
                  dh.savePath = dh.defaultSaveDir;
                  Utils.logout("reset save dir to index 0 ${dh.savePath}");
                  dh.saveAttachConfig();
                  setState(() {
                    _saveDir = dh.savePath;
                    _saveIndex = dh.saveDirIndex;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('下载目录'),
                onTap: () {
                  dh.saveDirIndex = 1;
                  dh.savePath = dh.defaultDownDir;
                  dh.saveAttachConfig();

                  Utils.logout("reset save dir to index 1 ${dh.savePath}");

                  setState(() {
                    _saveDir = dh.savePath;
                    _saveIndex = dh.saveDirIndex;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
