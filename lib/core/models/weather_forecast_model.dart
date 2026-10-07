// ============================================================================
// FitPulse Mobile App — Weather & Training Conditions Domain Model
// Week 4: API Integration and Asynchronous Data Handling
// Maps Open-Meteo REST API payload into training advisories & environmental data
// ============================================================================

class WeatherForecast {
  final String cityName;
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final int weatherCode;
  final DateTime timestamp;

  const WeatherForecast({
    required this.cityName,
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.timestamp,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json, {String cityName = 'Hyderabad'}) {
    final current = json['current'] as Map<String, dynamic>? ?? {};

    return WeatherForecast(
      cityName: cityName,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 25.0,
      apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? 26.0,
      relativeHumidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 50,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 8.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      timestamp: DateTime.now(),
    );
  }

  /// Translates WMO meteorological code into user-friendly condition description
  String get conditionText {
    if (weatherCode == 0) return 'Clear Sky ☀️';
    if (weatherCode >= 1 && weatherCode <= 3) return 'Partly Cloudy ⛅';
    if (weatherCode >= 45 && weatherCode <= 48) return 'Foggy / Hazy 🌫️';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Rain / Drizzle 🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow Flurries ❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain Showers 🌦️';
    if (weatherCode >= 95 && weatherCode <= 99) return 'Thunderstorm ⛈️';
    return 'Moderate / Clear 🌤️';
  }

  /// Dynamic recommendation for outdoor athletic training
  String get trainingSafetyAdvisory {
    if (apparentTemperature > 36.0) {
      return 'Extreme Heat Alert: Avoid peak sun workouts. Move training indoors or hydrate with +1.0L electrolytes.';
    } else if (apparentTemperature > 30.0) {
      return 'Warm Conditions: Moderate cardiovascular strain. Pre-hydrate with 500ml before outdoor session.';
    } else if (apparentTemperature < 8.0) {
      return 'Cold Temperature Alert: Extended 15-min warm-up required to prevent muscle strain. Dress in thermal layers.';
    } else if (weatherCode >= 51 && weatherCode <= 99) {
      return 'Precipitation Alert: Wet surfaces. Choose gym training or ensure slip-resistant trail footwear.';
    } else {
      return 'Optimal Training Window: Excellent environmental conditions for outdoor run or athletic drills!';
    }
  }

  /// Dynamic hydration target recommendation (in ml)
  int get suggestedExtraHydrationMl {
    if (apparentTemperature > 35.0) return 800;
    if (apparentTemperature > 28.0) return 500;
    if (relativeHumidity > 75) return 400;
    return 250;
  }
}

