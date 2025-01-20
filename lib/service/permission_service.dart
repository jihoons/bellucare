import 'package:bellucare/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._postConstructor();

  static PermissionService get instance => _instance;
  bool _hasNotification = false;
  bool get needRequestNotification => !_hasNotification;

  bool _notificationPermanentlyDenied = false;

  bool _hasLocation = false;
  bool get needRequestLocation => !_hasLocation;
  bool _locationPermanentlyDenied = false;

  bool _hasActivity = false;
  bool get needRequestActivity => !_hasActivity;
  bool _activityPermanentlyDenied = false;

  PermissionService._postConstructor();

  Future<void> checkPermission() async {
    _hasNotification = (await Permission.notification.isGranted);
    _notificationPermanentlyDenied = await Permission.notification.isPermanentlyDenied;

    _hasLocation = (await Permission.locationWhenInUse.isGranted);
    _locationPermanentlyDenied = (await Permission.locationWhenInUse.isPermanentlyDenied);

    _hasActivity = (await Permission.activityRecognition.isGranted);
    _activityPermanentlyDenied = (await Permission.activityRecognition.isPermanentlyDenied);
  }

  Future<bool> requestActivity() async {
    if (_hasActivity == false) {
      PermissionStatus state = (await Permission.activityRecognition.request());
      debug("request activity $state");
      _hasActivity = (state == PermissionStatus.granted);
      _activityPermanentlyDenied = (state == PermissionStatus.permanentlyDenied);
    }
    return _hasActivity;
  }
}
