// This is a generated file - do not edit.
//
// Generated from msgs.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class DeviceReport extends $pb.GeneratedMessage {
  factory DeviceReport({
    $core.String? ip,
    $core.List<$core.int>? aesKey,
    $core.int? way,
    $core.String? name,
    $core.int? platId,
  }) {
    final result = create();
    if (ip != null) result.ip = ip;
    if (aesKey != null) result.aesKey = aesKey;
    if (way != null) result.way = way;
    if (name != null) result.name = name;
    if (platId != null) result.platId = platId;
    return result;
  }

  DeviceReport._();

  factory DeviceReport.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory DeviceReport.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeviceReport', package: const $pb.PackageName(_omitMessageNames ? '' : 'msgentity'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ip')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'aesKey', $pb.PbFieldType.OY, protoName: 'aesKey')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'way', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'platId', $pb.PbFieldType.O3, protoName: 'platId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceReport clone() => DeviceReport()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceReport copyWith(void Function(DeviceReport) updates) => super.copyWith((message) => updates(message as DeviceReport)) as DeviceReport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceReport create() => DeviceReport._();
  @$core.override
  DeviceReport createEmptyInstance() => create();
  static $pb.PbList<DeviceReport> createRepeated() => $pb.PbList<DeviceReport>();
  @$core.pragma('dart2js:noInline')
  static DeviceReport getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceReport>(create);
  static DeviceReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ip => $_getSZ(0);
  @$pb.TagNumber(1)
  set ip($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get aesKey => $_getN(1);
  @$pb.TagNumber(2)
  set aesKey($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAesKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearAesKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get way => $_getIZ(2);
  @$pb.TagNumber(3)
  set way($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWay() => $_has(2);
  @$pb.TagNumber(3)
  void clearWay() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get platId => $_getIZ(4);
  @$pb.TagNumber(5)
  set platId($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPlatId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlatId() => $_clearField(5);
}

class PingPong extends $pb.GeneratedMessage {
  factory PingPong({
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  PingPong._();

  factory PingPong.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory PingPong.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PingPong', package: const $pb.PackageName(_omitMessageNames ? '' : 'msgentity'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingPong clone() => PingPong()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingPong copyWith(void Function(PingPong) updates) => super.copyWith((message) => updates(message as PingPong)) as PingPong;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingPong create() => PingPong._();
  @$core.override
  PingPong createEmptyInstance() => create();
  static $pb.PbList<PingPong> createRepeated() => $pb.PbList<PingPong>();
  @$core.pragma('dart2js:noInline')
  static PingPong getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingPong>(create);
  static PingPong? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
}

class ChatMessage extends $pb.GeneratedMessage {
  factory ChatMessage({
    $core.String? fromIp,
    $core.String? toIp,
    $core.int? msgType,
    $fixnum.Int64? msgId,
    $core.int? status,
    $core.String? sourcePath,
    $core.String? targetPath,
    $core.String? fileName,
    $core.int? fileSize,
    $fixnum.Int64? timestamp,
    $core.int? attachCount,
    $core.List<$core.int>? content,
  }) {
    final result = create();
    if (fromIp != null) result.fromIp = fromIp;
    if (toIp != null) result.toIp = toIp;
    if (msgType != null) result.msgType = msgType;
    if (msgId != null) result.msgId = msgId;
    if (status != null) result.status = status;
    if (sourcePath != null) result.sourcePath = sourcePath;
    if (targetPath != null) result.targetPath = targetPath;
    if (fileName != null) result.fileName = fileName;
    if (fileSize != null) result.fileSize = fileSize;
    if (timestamp != null) result.timestamp = timestamp;
    if (attachCount != null) result.attachCount = attachCount;
    if (content != null) result.content = content;
    return result;
  }

  ChatMessage._();

  factory ChatMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChatMessage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'msgentity'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fromIp', protoName: 'fromIp')
    ..aOS(2, _omitFieldNames ? '' : 'toIp', protoName: 'toIp')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'msgType', $pb.PbFieldType.O3, protoName: 'msgType')
    ..aInt64(4, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'sourcePath', protoName: 'sourcePath')
    ..aOS(7, _omitFieldNames ? '' : 'targetPath', protoName: 'targetPath')
    ..aOS(8, _omitFieldNames ? '' : 'fileName', protoName: 'fileName')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'fileSize', $pb.PbFieldType.O3, protoName: 'fileSize')
    ..aInt64(10, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'attachCount', $pb.PbFieldType.O3, protoName: 'attachCount')
    ..a<$core.List<$core.int>>(12, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage clone() => ChatMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage copyWith(void Function(ChatMessage) updates) => super.copyWith((message) => updates(message as ChatMessage)) as ChatMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage create() => ChatMessage._();
  @$core.override
  ChatMessage createEmptyInstance() => create();
  static $pb.PbList<ChatMessage> createRepeated() => $pb.PbList<ChatMessage>();
  @$core.pragma('dart2js:noInline')
  static ChatMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatMessage>(create);
  static ChatMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fromIp => $_getSZ(0);
  @$pb.TagNumber(1)
  set fromIp($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromIp() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromIp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get toIp => $_getSZ(1);
  @$pb.TagNumber(2)
  set toIp($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearToIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get msgType => $_getIZ(2);
  @$pb.TagNumber(3)
  set msgType($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMsgType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsgType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get msgId => $_getI64(3);
  @$pb.TagNumber(4)
  set msgId($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMsgId() => $_has(3);
  @$pb.TagNumber(4)
  void clearMsgId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get status => $_getIZ(4);
  @$pb.TagNumber(5)
  set status($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get sourcePath => $_getSZ(5);
  @$pb.TagNumber(6)
  set sourcePath($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourcePath() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourcePath() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetPath => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetPath($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetPath() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetPath() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fileName => $_getSZ(7);
  @$pb.TagNumber(8)
  set fileName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFileName() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get fileSize => $_getIZ(8);
  @$pb.TagNumber(9)
  set fileSize($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFileSize() => $_has(8);
  @$pb.TagNumber(9)
  void clearFileSize() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get timestamp => $_getI64(9);
  @$pb.TagNumber(10)
  set timestamp($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimestamp() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get attachCount => $_getIZ(10);
  @$pb.TagNumber(11)
  set attachCount($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAttachCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearAttachCount() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.List<$core.int> get content => $_getN(11);
  @$pb.TagNumber(12)
  set content($core.List<$core.int> value) => $_setBytes(11, value);
  @$pb.TagNumber(12)
  $core.bool hasContent() => $_has(11);
  @$pb.TagNumber(12)
  void clearContent() => $_clearField(12);
}

class ChatResponse extends $pb.GeneratedMessage {
  factory ChatResponse({
    $fixnum.Int64? msgId,
    $core.int? result,
    $fixnum.Int64? timestamp,
    $core.String? sourcePath,
    $core.int? recvLength,
  }) {
    final result$ = create();
    if (msgId != null) result$.msgId = msgId;
    if (result != null) result$.result = result;
    if (timestamp != null) result$.timestamp = timestamp;
    if (sourcePath != null) result$.sourcePath = sourcePath;
    if (recvLength != null) result$.recvLength = recvLength;
    return result$;
  }

  ChatResponse._();

  factory ChatResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory ChatResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'msgentity'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'result', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..aOS(4, _omitFieldNames ? '' : 'sourcePath', protoName: 'sourcePath')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'recvLength', $pb.PbFieldType.O3, protoName: 'recvLength')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatResponse clone() => ChatResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatResponse copyWith(void Function(ChatResponse) updates) => super.copyWith((message) => updates(message as ChatResponse)) as ChatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatResponse create() => ChatResponse._();
  @$core.override
  ChatResponse createEmptyInstance() => create();
  static $pb.PbList<ChatResponse> createRepeated() => $pb.PbList<ChatResponse>();
  @$core.pragma('dart2js:noInline')
  static ChatResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatResponse>(create);
  static ChatResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get msgId => $_getI64(0);
  @$pb.TagNumber(1)
  set msgId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get result => $_getIZ(1);
  @$pb.TagNumber(2)
  set result($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasResult() => $_has(1);
  @$pb.TagNumber(2)
  void clearResult() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sourcePath => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourcePath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourcePath() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourcePath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get recvLength => $_getIZ(4);
  @$pb.TagNumber(5)
  set recvLength($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRecvLength() => $_has(4);
  @$pb.TagNumber(5)
  void clearRecvLength() => $_clearField(5);
}

class AttachMessage extends $pb.GeneratedMessage {
  factory AttachMessage({
    $fixnum.Int64? attachId,
    $fixnum.Int64? msgId,
    $fixnum.Int64? timestamp,
    $core.int? lessLength,
    $core.List<$core.int>? content,
  }) {
    final result = create();
    if (attachId != null) result.attachId = attachId;
    if (msgId != null) result.msgId = msgId;
    if (timestamp != null) result.timestamp = timestamp;
    if (lessLength != null) result.lessLength = lessLength;
    if (content != null) result.content = content;
    return result;
  }

  AttachMessage._();

  factory AttachMessage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AttachMessage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AttachMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'msgentity'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'attachId', protoName: 'attachId')
    ..aInt64(2, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'lessLength', $pb.PbFieldType.O3, protoName: 'lessLength')
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachMessage clone() => AttachMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachMessage copyWith(void Function(AttachMessage) updates) => super.copyWith((message) => updates(message as AttachMessage)) as AttachMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachMessage create() => AttachMessage._();
  @$core.override
  AttachMessage createEmptyInstance() => create();
  static $pb.PbList<AttachMessage> createRepeated() => $pb.PbList<AttachMessage>();
  @$core.pragma('dart2js:noInline')
  static AttachMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttachMessage>(create);
  static AttachMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get attachId => $_getI64(0);
  @$pb.TagNumber(1)
  set attachId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttachId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttachId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get msgId => $_getI64(1);
  @$pb.TagNumber(2)
  set msgId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get lessLength => $_getIZ(3);
  @$pb.TagNumber(4)
  set lessLength($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLessLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearLessLength() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get content => $_getN(4);
  @$pb.TagNumber(5)
  set content($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearContent() => $_clearField(5);
}

class AttachResponse extends $pb.GeneratedMessage {
  factory AttachResponse({
    $fixnum.Int64? attachId,
    $fixnum.Int64? msgId,
    $fixnum.Int64? timestamp,
    $core.int? recvLength,
    $core.int? result,
    $fixnum.Int64? expectId,
    $core.int? handleLen,
  }) {
    final result$ = create();
    if (attachId != null) result$.attachId = attachId;
    if (msgId != null) result$.msgId = msgId;
    if (timestamp != null) result$.timestamp = timestamp;
    if (recvLength != null) result$.recvLength = recvLength;
    if (result != null) result$.result = result;
    if (expectId != null) result$.expectId = expectId;
    if (handleLen != null) result$.handleLen = handleLen;
    return result$;
  }

  AttachResponse._();

  factory AttachResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AttachResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AttachResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'msgentity'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'attachId', protoName: 'attachId')
    ..aInt64(2, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'recvLength', $pb.PbFieldType.O3, protoName: 'recvLength')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'result', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'expectId', protoName: 'expectId')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'handleLen', $pb.PbFieldType.O3, protoName: 'handleLen')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachResponse clone() => AttachResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachResponse copyWith(void Function(AttachResponse) updates) => super.copyWith((message) => updates(message as AttachResponse)) as AttachResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachResponse create() => AttachResponse._();
  @$core.override
  AttachResponse createEmptyInstance() => create();
  static $pb.PbList<AttachResponse> createRepeated() => $pb.PbList<AttachResponse>();
  @$core.pragma('dart2js:noInline')
  static AttachResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttachResponse>(create);
  static AttachResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get attachId => $_getI64(0);
  @$pb.TagNumber(1)
  set attachId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttachId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttachId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get msgId => $_getI64(1);
  @$pb.TagNumber(2)
  set msgId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get recvLength => $_getIZ(3);
  @$pb.TagNumber(4)
  set recvLength($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRecvLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecvLength() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get result => $_getIZ(4);
  @$pb.TagNumber(5)
  set result($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasResult() => $_has(4);
  @$pb.TagNumber(5)
  void clearResult() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get expectId => $_getI64(5);
  @$pb.TagNumber(6)
  set expectId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectId() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get handleLen => $_getIZ(6);
  @$pb.TagNumber(7)
  set handleLen($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHandleLen() => $_has(6);
  @$pb.TagNumber(7)
  void clearHandleLen() => $_clearField(7);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
