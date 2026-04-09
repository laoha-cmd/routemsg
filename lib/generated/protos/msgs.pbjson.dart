// This is a generated file - do not edit.
//
// Generated from msgs.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use deviceReportDescriptor instead')
const DeviceReport$json = {
  '1': 'DeviceReport',
  '2': [
    {'1': 'ip', '3': 1, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'aesKey', '3': 2, '4': 1, '5': 12, '10': 'aesKey'},
    {'1': 'way', '3': 3, '4': 1, '5': 5, '10': 'way'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'platId', '3': 5, '4': 1, '5': 5, '10': 'platId'},
  ],
};

/// Descriptor for `DeviceReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceReportDescriptor = $convert.base64Decode(
    'CgxEZXZpY2VSZXBvcnQSDgoCaXAYASABKAlSAmlwEhYKBmFlc0tleRgCIAEoDFIGYWVzS2V5Eh'
    'AKA3dheRgDIAEoBVIDd2F5EhIKBG5hbWUYBCABKAlSBG5hbWUSFgoGcGxhdElkGAUgASgFUgZw'
    'bGF0SWQ=');

@$core.Deprecated('Use pingPongDescriptor instead')
const PingPong$json = {
  '1': 'PingPong',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `PingPong`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingPongDescriptor = $convert.base64Decode(
    'CghQaW5nUG9uZxIcCgl0aW1lc3RhbXAYASABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage$json = {
  '1': 'ChatMessage',
  '2': [
    {'1': 'fromIp', '3': 1, '4': 1, '5': 9, '10': 'fromIp'},
    {'1': 'toIp', '3': 2, '4': 1, '5': 9, '10': 'toIp'},
    {'1': 'msgType', '3': 3, '4': 1, '5': 5, '10': 'msgType'},
    {'1': 'msgId', '3': 4, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'status', '3': 5, '4': 1, '5': 5, '10': 'status'},
    {'1': 'sourcePath', '3': 6, '4': 1, '5': 9, '10': 'sourcePath'},
    {'1': 'targetPath', '3': 7, '4': 1, '5': 9, '10': 'targetPath'},
    {'1': 'fileName', '3': 8, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'fileSize', '3': 9, '4': 1, '5': 5, '10': 'fileSize'},
    {'1': 'timestamp', '3': 10, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'attachCount', '3': 11, '4': 1, '5': 5, '10': 'attachCount'},
    {'1': 'content', '3': 12, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `ChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageDescriptor = $convert.base64Decode(
    'CgtDaGF0TWVzc2FnZRIWCgZmcm9tSXAYASABKAlSBmZyb21JcBISCgR0b0lwGAIgASgJUgR0b0'
    'lwEhgKB21zZ1R5cGUYAyABKAVSB21zZ1R5cGUSFAoFbXNnSWQYBCABKANSBW1zZ0lkEhYKBnN0'
    'YXR1cxgFIAEoBVIGc3RhdHVzEh4KCnNvdXJjZVBhdGgYBiABKAlSCnNvdXJjZVBhdGgSHgoKdG'
    'FyZ2V0UGF0aBgHIAEoCVIKdGFyZ2V0UGF0aBIaCghmaWxlTmFtZRgIIAEoCVIIZmlsZU5hbWUS'
    'GgoIZmlsZVNpemUYCSABKAVSCGZpbGVTaXplEhwKCXRpbWVzdGFtcBgKIAEoA1IJdGltZXN0YW'
    '1wEiAKC2F0dGFjaENvdW50GAsgASgFUgthdHRhY2hDb3VudBIYCgdjb250ZW50GAwgASgMUgdj'
    'b250ZW50');

@$core.Deprecated('Use chatResponseDescriptor instead')
const ChatResponse$json = {
  '1': 'ChatResponse',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'result', '3': 2, '4': 1, '5': 5, '10': 'result'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'sourcePath', '3': 4, '4': 1, '5': 9, '10': 'sourcePath'},
    {'1': 'recvLength', '3': 5, '4': 1, '5': 5, '10': 'recvLength'},
  ],
};

/// Descriptor for `ChatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatResponseDescriptor = $convert.base64Decode(
    'CgxDaGF0UmVzcG9uc2USFAoFbXNnSWQYASABKANSBW1zZ0lkEhYKBnJlc3VsdBgCIAEoBVIGcm'
    'VzdWx0EhwKCXRpbWVzdGFtcBgDIAEoA1IJdGltZXN0YW1wEh4KCnNvdXJjZVBhdGgYBCABKAlS'
    'CnNvdXJjZVBhdGgSHgoKcmVjdkxlbmd0aBgFIAEoBVIKcmVjdkxlbmd0aA==');

@$core.Deprecated('Use attachMessageDescriptor instead')
const AttachMessage$json = {
  '1': 'AttachMessage',
  '2': [
    {'1': 'attachId', '3': 1, '4': 1, '5': 3, '10': 'attachId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'lessLength', '3': 4, '4': 1, '5': 5, '10': 'lessLength'},
    {'1': 'content', '3': 5, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `AttachMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachMessageDescriptor = $convert.base64Decode(
    'Cg1BdHRhY2hNZXNzYWdlEhoKCGF0dGFjaElkGAEgASgDUghhdHRhY2hJZBIUCgVtc2dJZBgCIA'
    'EoA1IFbXNnSWQSHAoJdGltZXN0YW1wGAMgASgDUgl0aW1lc3RhbXASHgoKbGVzc0xlbmd0aBgE'
    'IAEoBVIKbGVzc0xlbmd0aBIYCgdjb250ZW50GAUgASgMUgdjb250ZW50');

@$core.Deprecated('Use attachResponseDescriptor instead')
const AttachResponse$json = {
  '1': 'AttachResponse',
  '2': [
    {'1': 'attachId', '3': 1, '4': 1, '5': 3, '10': 'attachId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 3, '10': 'msgId'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'recvLength', '3': 4, '4': 1, '5': 5, '10': 'recvLength'},
    {'1': 'result', '3': 5, '4': 1, '5': 5, '10': 'result'},
    {'1': 'expectId', '3': 6, '4': 1, '5': 3, '10': 'expectId'},
    {'1': 'handleLen', '3': 7, '4': 1, '5': 5, '10': 'handleLen'},
  ],
};

/// Descriptor for `AttachResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachResponseDescriptor = $convert.base64Decode(
    'Cg5BdHRhY2hSZXNwb25zZRIaCghhdHRhY2hJZBgBIAEoA1IIYXR0YWNoSWQSFAoFbXNnSWQYAi'
    'ABKANSBW1zZ0lkEhwKCXRpbWVzdGFtcBgDIAEoA1IJdGltZXN0YW1wEh4KCnJlY3ZMZW5ndGgY'
    'BCABKAVSCnJlY3ZMZW5ndGgSFgoGcmVzdWx0GAUgASgFUgZyZXN1bHQSGgoIZXhwZWN0SWQYBi'
    'ABKANSCGV4cGVjdElkEhwKCWhhbmRsZUxlbhgHIAEoBVIJaGFuZGxlTGVu');

