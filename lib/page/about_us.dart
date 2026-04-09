import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routemsg/common/cmd.dart';
import 'package:routemsg/utils/toast_utils.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // 打开链接的方法
  // Future<void> _launchUrl(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
  //     throw Exception('无法打开链接: $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用图标（可以使用项目中的图标，这里用占位图标）
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset("assets/images/ic_launcher.png"),
              ),
              const SizedBox(height: 24),
              // 应用名称
              Text(
                '局域网传输助手',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // 版本号
              Text(
                '版本 $versionName',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),

              // 描述卡片
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SelectableText(
                    '基于 UDP 广播设备发现和加密通讯的局域网传输工具。\n'
                    '无需配置，自动扫描同网段设备；所有传输均经过 AES 加密，保障数据安全。\n'
                    '已支持Windows,Linux,IOS,MAC,Android，代码免费开源\n'
                    '参考 $officeHref',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 开源地址卡片
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: githubHref))
                        .then((_) {
                      ToastUtils.toast("已复制链接到粘贴板");
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.code,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '开源地址',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                githubHref,
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 版权信息
              Text(
                '© 2026 局域网传输助手团队\n任何个人和团队都可以免费使用源代码',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 32),

              // 关闭按钮（可选）
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
