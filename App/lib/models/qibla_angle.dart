import 'dart:math';

class QiblaDirection {
  static double calculateQiblaDirection(double latitude, double longitude) {
    double kaabaLongitude = 39.826206; // Kaaba longitude
    double kaabaLatitude = 21.422487; // Kaaba latitude

    double qiblaDirection = atan2(
        sin((kaabaLongitude - longitude) * pi / 180),
        cos(latitude * pi / 180) * tan(kaabaLatitude * pi / 180) -
            sin(latitude * pi / 180) *
                cos((kaabaLongitude - longitude) * pi / 180));

    qiblaDirection = (qiblaDirection * 180 / pi);

    if (qiblaDirection < 0) {
      qiblaDirection += 360;
    }

    return qiblaDirection;
  }
}

// void main() {
//   double userLatitude = 37.7749;  // Replace with user's latitude
//   double userLongitude = -122.4194;  // Replace with user's longitude

//   double qiblaDirection = QiblaDirection.calculateQiblaDirection(userLatitude, userLongitude);
  
//   print('Direction to Qibla: $qiblaDirection degrees');
// }