import 'package:geolocator/geolocator.dart';
import '../config/app_constants.dart';
import '../error/exceptions.dart';

/// Service abstraction for retrieving high-accuracy device GPS coordinates.
class LocationService {
  const LocationService();

  /// Checks whether device location service (GPS) is currently enabled.
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Opens the device system location settings.
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Stream of location service status changes (enabled / disabled).
  Stream<ServiceStatus> getServiceStatusStream() {
    return Geolocator.getServiceStatusStream();
  }

  /// Requests permissions and retrieves current device GPS coordinates.
  /// Throws [LocationException] if services are disabled or permissions are denied.
  Future<Position> getCurrentLocation() async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please turn on GPS in your device settings.',
      );
    }

    // 2. Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permissions are denied. Location access is required to mark attendance.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permissions are permanently denied. Please enable them from system settings.',
      );
    }

    // 3. Obtain current position with 10s timeout
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: AppConstants.locationTimeout,
        ),
      );
    } catch (e) {
      throw LocationException('Failed to retrieve location: ${e.toString()}');
    }
  }
}

