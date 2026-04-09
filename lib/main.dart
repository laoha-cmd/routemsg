import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:routemsg/page/desktop_main.dart';
import 'package:routemsg/page/mobile_main.dart';
import 'package:routemsg/utils/data_helper.dart';
import 'package:routemsg/utils/toast_utils.dart';
//import 'package:fvp/fvp.dart' as fvp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // fvp.registerWith(options: {
  //   'platforms': ['windows']
  // });

  await initLocalStorage();

  await DataHelper().initDataHelper();

  runApp(ToastUtils.init(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '局域网传输工具',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // 定义断点（可根据设计需求调整）
          if (width >= 1200) {
            // 超大屏（桌面宽窗口、大屏平板横屏）
            return _buildDesktopLayout(width, height);
          } else if (width >= 800) {
            // 平板/小桌面（中等宽度）
            return _buildTabletLayout(width, height);
          } else {
            // 手机/窄屏（包括竖屏手机、小窗口桌面）
            return _buildMobileLayout(width, height);
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(double width, double height) {
    if (Platform.isMacOS || Platform.isWindows || Platform.isFuchsia) {
      return DesktopMain(200);
    }

    return DesktopMain(100);
  }

  Widget _buildTabletLayout(double width, double height) {
    if (Platform.isMacOS || Platform.isWindows || Platform.isFuchsia) {
      return DesktopMain(200);
    }

    return DesktopMain(100);
  }

  Widget _buildMobileLayout(double width, double height) {
    return MobileMain();
  }
}
