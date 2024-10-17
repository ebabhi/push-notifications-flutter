// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
// import 'package:pusher_beams_platform_interface/method_channel_pusher_beams.dart';
// import 'package:pusher_beams_platform_interface/pusher_beams_platform_interface.dart';

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   final PusherBeamsPlatform initialInstance = PusherBeamsPlatform.instance;

//   group('$PusherBeamsPlatform', () {
//     test('$PusherBeamsApi is the default instance', () {
//       expect(initialInstance, isInstanceOf<PusherBeamsApi>());
//     });

//     test('Cannot be implemented with `implements`', () {
//       expect(() {
//         PusherBeamsPlatform.instance = ImplementsPusherBeamsPlatform();
//       }, throwsA(isInstanceOf<AssertionError>()));
//     });

//     test('Can be mocked with `implements`', () {
//       final PusherBeamsPlatformMock mock = PusherBeamsPlatformMock();
//       PusherBeamsPlatform.instance = mock;
//     });

//     test('Can be extended', () {
//       PusherBeamsPlatform.instance = IllegalImplementation();
//     });
//   });

//   group('$PusherBeamsApi', () {
//     print(
//         'Pigeon Generated Platform API not tested in favor of integration tests');
//   });
// }

// class PusherBeamsPlatformMock extends Mock
//     with MockPlatformInterfaceMixin
//     implements PusherBeamsPlatform {}

// class ImplementsPusherBeamsPlatform extends Mock
//     implements PusherBeamsPlatform {}

// class IllegalImplementation extends PusherBeamsPlatform {
//   @override
//   Future<void> addDeviceInterest(String interest) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> clearAllState() {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> clearDeviceInterests() {
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<String?>> getDeviceInterests() {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> onInterestChanges(OnInterestsChange callback) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> removeDeviceInterest(String interest) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setDeviceInterests(List<String> interests) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setUserId(
//       String userId, BeamsAuthProvider provider, OnUserCallback callback) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> start(String instanceId) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> stop() {
//     throw UnimplementedError();
//   }
// }
