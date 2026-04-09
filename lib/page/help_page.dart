import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final List<Map<String, String>> helpItems = [
    {
      'question': '设备无法互相发现?',
      'answer':
          '检查所有设备是否连接到同一局域网（同一路由器/交换机）。\n检查防火墙是否允许UDP端口 19876（可自定义）通信，可以尝试暂时关闭防火墙测试。路由器是否开启了AP隔离，尝试关闭AP隔离后再试。\n移动端存在Wifi保护，发现不到PC端设备，可尝试在移动端手动点击广播设备。'
    },
    {'question': '修改本地名称不生效？', 'answer': '修改本地设备名称后，其他端设备二次进入系统后会生效。'},
    {
      'question': '是否支持跨网段传输？',
      'answer': '设备发现依赖UDP广播，通常只能在同网段内自动发现。但您可以在设置中手动添加目标IP地址，实现跨网段传输（需路由可达）。'
    },
    {
      'question': '应用闪退怎么办？',
      'answer': '请尝试以下步骤：\n1. 重启应用\n2. 检查更新\n3. 清理缓存\n4. 如果问题持续，请下载最新版本'
    },
    {'question': '是否需要互联网？', 'answer': '无需广域网，通讯只在本地路由器内部加密传输。'},
  ];

  HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('帮助中心'),
        centerTitle: true,
        backgroundColor: Colors.green[100],
        elevation: 2,
      ),
      body: ListView.builder(
        itemCount: helpItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                helpItems[index]['question']!,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    helpItems[index]['answer']!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
