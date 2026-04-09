import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';
import 'package:localstorage/localstorage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routemsg/common/cmd.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

const _keyList1 = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08];
const _keyList2 = [0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18];
const _keyList3 = [0x1D, 0x1E, 0x1A, 0x2c, 0x3D, 0x4D, 0x51, 0x88];

class FileData {
  String dirPath;
  String fileName;
  String extetion;

  FileData(this.dirPath, this.fileName, this.extetion);
}

class MyCompleter<T> {
  Completer<T> completer = Completer();

  MyCompleter();

  Future<T> get future => completer.future;

  void reply(T result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }
}

class Utils {
  static String getBroadIp(String ip) {
    final idx = ip.lastIndexOf(".");
    if (idx > 0) {
      return "${ip.substring(0, idx + 1)}255";
    }

    return "";
  }

  static String getRandomString(int len) {
    const String org = "abcdefghijklmnopqrstuvwxyz1234567890";
    var rder = Random(DateTime.now().microsecondsSinceEpoch);
    var ret = "";
    for (var i = 0; i < len; i++) {
      var cur = org[rder.nextInt(org.length)];

      ret += cur;
    }

    return ret;
  }

  static Future<int> formatFileSize(String path) async {
    File file = File(path);
    try {
      int fileSize = await file.length();
      return fileSize;
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }

  static String formatPercent(int progress, int total) {
    if (total == 0) return "100%";

    return "${(progress * 100 / total).toStringAsFixed(1)}%";
  }

  static String saveFileFull(String filePath, List<int> content) {
    try {
      File file = File(filePath);
      file.writeAsBytesSync(content);
      return "";
    } catch (e) {
      return "$e";
    }
  }

  static String appendFile(String filePath, List<int> content) {
    try {
      File file = File(filePath);
      file.writeAsBytesSync(content, mode: FileMode.append);
      return "";
    } catch (e) {
      return "$e";
    }
  }

  static bool isAttachFollowd(Map<int, Uint8List> attaches) {
    int minId = -1;
    int maxId = 0;
    attaches.forEach((key, val) {
      if (minId > key || minId == -1) {
        minId = key;
      }

      if (maxId < key) {
        maxId = key;
      }
    });

    for (int id = minId; id <= maxId; id++) {
      if (!attaches.containsKey(id)) {
        return false;
      }
    }

    return true;
  }

  static String appendFlushFile(
      String filePath, Map<int, Uint8List> attaches, int goodSize, bool force) {
    try {
      int minId = -1;
      int maxId = 0;
      int totalSize = 0;
      attaches.forEach((key, val) {
        if (minId > key || minId == -1) {
          minId = key;
        }

        if (maxId < key) {
          maxId = key;
        }

        totalSize += val.length;
      });

      if (!force && totalSize < goodSize) {
        logout(
            "file filePath size $totalSize less than $goodSize next loop to append");
        return "nextLoop";
      }

      Uint8List content = Uint8List(totalSize);
      int offset = 0;
      for (var idx = minId; idx <= maxId; idx++) {
        final datas = attaches[idx];
        content.setAll(offset, datas!);

        offset += datas.length;
      }

      logout("file filePath size $totalSize append");

      File file = File(filePath);
      file.writeAsBytesSync(content, mode: FileMode.append);
      return "";
    } catch (e) {
      return "$e";
    }
  }

  static Future<String> writeFile(
      String filePath, int offset, List<int> content) async {
    RandomAccessFile file = await File(filePath).open(mode: FileMode.write);

    String ret = "";
    try {
      // 移动到指定的偏移量位置
      await file.setPosition(offset);
      // 在当前位置写入数据
      await file.writeFrom(content);
    } catch (e) {
      ret = "$e";
    } finally {
      // 确保文件被正确关闭
      await file.close();
    }

    return ret;
  }

  static Future<List<int>> getFileContent(
      String fName, int offset, int length) {
    File file = File(fName);
    final c = MyCompleter<List<int>>();

    List<int> result = [];
    file.openRead(offset, offset + length).listen((data) {
      result.addAll(data);
    }).onDone(() {
      c.reply(result);
    });

    return c.future;
  }

  static int timestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static int mstimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static void logout(String content) {
    print("chat:$content");
  }

  static String getShowFileSize(int size) {
    const List<String> units = [
      'B',
      'KB',
      'MB',
      'GB',
      'TB',
      'PB',
      'EB',
      'ZB',
      'YB'
    ];
    var e = (log(size) / log(1024)).floor();
    return '${(size / pow(1024, e)).toStringAsFixed(2)} ${units[e]}';
  }

  static String getPlatAssets(int platId) {
    switch (platId) {
      case platAndroid:
        return "assets/images/icon_android.png";

      case platIos:
        return "assets/images/icon_ios.png";

      case platWindows:
        return "assets/images/icon_windows.png";

      case platMac:
        return "assets/images/icon_macos.png";

      case platLinux:
        return "assets/images/icon_linux.png";

      case platUnkown:
        return "assets/images/icon_windows.png";

      default:
        return "assets/images/icon_windows.png";
    }
  }

  static int getPlatId() {
    if (Platform.isAndroid) {
      return platAndroid;
    }

    if (Platform.isIOS) {
      return platIos;
    }

    if (Platform.isMacOS) {
      return platMac;
    }

    if (Platform.isWindows) {
      return platWindows;
    }

    if (Platform.isFuchsia) {
      return platLinux;
    }

    return platUnkown;
  }

  static Future<String> getLocalIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
      );

      for (var interface in interfaces) {
        if (!interface.name.toLowerCase().contains('wi') &&
            !interface.name.toLowerCase().contains('wl')) {
          print(
              "getLocalIPAddress ignore interface with name ${interface.name}");
          continue;
        }

        for (var addr in interface.addresses) {
          // 只取 IPv6 地址
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      // 处理异常
      print('无法获取本地 IP 地址: $e');
    }

    return "";
  }

  static Future<String> getTempDir() async {
    final Directory tempDir = await getTemporaryDirectory();

    return tempDir.path;
  }

  static Future<String> getDownloadDir() async {
    final Directory? downloadsDir = await getDownloadsDirectory();

    return downloadsDir!.path;
  }

  static String getKeyValue(String key) {
    final ret = localStorage.getItem(key);
    if (null == ret) {
      return "";
    }

    return ret;
  }

  static void setKeyValue(String key, String value) {
    localStorage.setItem(key, value);
  }

  static Future<String> getDevName() async {
    String name;
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      name = (await deviceInfo.androidInfo).model;
    } else if (Platform.isIOS) {
      name = (await deviceInfo.iosInfo).localizedModel;
    } else if (Platform.isMacOS) {
      name = (await deviceInfo.macOsInfo).computerName;
    } else if (Platform.isWindows) {
      name = (await deviceInfo.windowsInfo).computerName;
    } else if (Platform.isLinux) {
      name = (await deviceInfo.linuxInfo).name;
    } else {
      name = 'Flutter';
    }

    return name;
  }

  /// 将中文字符串分割为符合 MTU 限制的字节块
  /// 返回 List<Uint8List>，每个元素是一个完整的数据包载荷
  static List<Uint8List> splitString(String text, int maxPayloadSize) {
    // 1. 转为 UTF-8 字节数组
    Uint8List fullBytes = utf8.encode(text);
    List<Uint8List> chunks = [];

    int offset = 0;
    while (offset < fullBytes.length) {
      int end = offset + maxPayloadSize;

      if (end >= fullBytes.length) {
        // 最后一包，直接取剩余所有
        chunks.add(fullBytes.sublist(offset));
        break;
      } else {
        // 2. 检查切割点是否切断了 UTF-8 字符
        // UTF-8 编码规则：
        // 1字节: 0xxxxxxx
        // 2字节: 110xxxxx 10xxxxxx
        // 3字节: 1110xxxx 10xxxxxx 10xxxxxx
        // 4字节: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
        // 如果一个字节的最高位是 1 且次高位是 0 (10xxxxxx)，说明它是多字节字符的后续字节。
        // 如果切割点落在这样的字节上，说明把一个字切断了。

        while (end > offset && _isUtf8ContinuationByte(fullBytes[end])) {
          end--; // 回退切割点，直到找到一个完整的字符边界
        }

        // 极端情况：如果单个字符就超过了 maxPayloadSize (极罕见，除非 maxPayloadSize < 4)
        if (end == offset) {
          throw Exception("MTU 限制过小，无法容纳单个 UTF-8 字符");
        }

        chunks.add(fullBytes.sublist(offset, end));
        offset = end;
      }
    }

    return chunks;
  }

  // 判断是否为 UTF-8 的延续字节 (10xxxxxx)
  static bool _isUtf8ContinuationByte(int byte) {
    return (byte & 0xC0) == 0x80;
  }

  static String _getFileType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (Platform.isAndroid) {
      final ret = androidTypes[ext];
      if (ret != null) {
        return ret;
      }
    } else if (Platform.isIOS) {
      final ret = iosTypes[ext];
      if (ret != null) {
        return ret;
      }
    }

    return "";
  }

  static void outOpenFile(String filePath) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      openFolder(filePath);
    } else {
      OpenFile.open(filePath, type: _getFileType(filePath));
    }

    // final Uri uri = Uri.file(filePath, windows: Platform.isWindows);

    // canLaunchUrl(uri).then((result) {
    //   if (result) {
    //     launchUrl(uri);
    //   } else {
    //     if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //       openFolder(filePath);
    //     } else {
    //       OpenFile.open(filePath, type: _getFileType(filePath));
    //     }
    //   }
    // });
  }

  static Future<void> openFolder(String filePath) async {
    // 如果传入的是具体文件路径，想打开其所在目录，可以用以下方法获取目录
    // String directoryPath = (await File(folderPath).parent).path;

    try {
      if (Platform.isWindows) {
        // Windows 使用 start 命令
        Process.run('start', [filePath], runInShell: true);
      } else if (Platform.isMacOS) {
        // macOS 使用 open 命令
        Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        // Linux 使用 xdg-open 命令
        Process.run('xdg-open', [filePath]);
      }
    } catch (e) {
      print('打开文件时出错: $e');
    }
  }

  static FileData parseFilePath(String pathName) {
    return FileData(
        p.dirname(pathName), p.basename(pathName), p.extension(pathName));
  }

  static String makeLocalName(String dirName, int msgId, String ext) {
    return "$dirName/${msgId.toRadixString(16)}${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}$ext";
  }

  static Uint8List encryptAes(String plainText) {
    final keyList = List<int>.from(_keyList1);
    keyList.addAll(_keyList2);
    keyList.addAll(_keyList3);

    final key = Key.fromUtf8(String.fromCharCodes(keyList));

    final iv = IV.allZerosOfLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.bytes;
  }

  static String decryptAes(Uint8List cipherText, String keyString) {
    final keyList = List<int>.from(_keyList1);
    keyList.addAll(_keyList2);
    keyList.addAll(_keyList3);

    final key = Key.fromUtf8(String.fromCharCodes(keyList));

    final iv = IV.allZerosOfLength(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decryptBytes(Encrypted(cipherText), iv: iv);

    return utf8.decode(decrypted);
  }

  // static Future<List<AppInfo>> fetchRecommApps(
  //     Map<String, dynamic> originalData) async {
  //   try {
  //     final plainReq = jsonEncode(originalData);
  //     final requestBody = encryptAes(plainReq);
  //     final apiHref = "https://your-api-endpoint.com";

  //     final response = await http.post(
  //       Uri.parse('$apiHref/api/app/recomm'),
  //       headers: {'Content-Type': 'application/octet-stream'},
  //       body: requestBody,
  //     );

  //     if (response.statusCode == 200) {
  //       final rspData = Uint8List.fromList(response.body.codeUnits);
  //       final plainRsp = decryptAes(rspData, getRandomString(32));
  //       final decryptedData = jsonDecode(plainRsp);
  //       final ret = AppListResponse.fromJson(jsonDecode(decryptedData));

  //       if (ret.code == 200) {
  //         return ret.apps;
  //       }

  //       return [];
  //     } else {
  //       print('请求失败: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('异常: $e');
  //     return [];
  //   }
  // }

  static bool isDesktop() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return true;
    }

    return false;
  }
}
