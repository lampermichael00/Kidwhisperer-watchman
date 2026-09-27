# Watchman architecture

Parent phone Flutter app: LocationService -> GeofenceEngine -> AlertService.
CryDetector scores audio on-device and discards the buffer.
LocalStore writes SharedPreferences key watchman.snapshot.v1.
Demo GNSS path wanders around Anaconda, MT (46.1288, -112.9420) so Home/Yard fences fire without hardware.
