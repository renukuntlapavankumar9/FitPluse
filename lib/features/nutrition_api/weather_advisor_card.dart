// ============================================================================
// FitPulse Mobile App — Outdoor Weather & Training Conditions Card
// Week 4: API Integration and Asynchronous Data Handling
// Connects to Open-Meteo REST API to supply athletic environmental advisories
// ============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/weather_forecast_model.dart';
import '../../core/services/api_exception.dart';
import '../../core/services/weather_api_service.dart';
import '../../core/state/app_state.dart';

class WeatherAdvisorCard extends StatefulWidget {
  final WeatherApiService? apiService;

  const WeatherAdvisorCard({super.key, this.apiService});

  @override
  State<WeatherAdvisorCard> createState() => _WeatherAdvisorCardState();
}

class _WeatherAdvisorCardState extends State<WeatherAdvisorCard> {
  late final WeatherApiService _weatherService;
  WeatherForecast? _forecast;
  bool _isLoading = false;
  String? _error;
  CityCoordinates _selectedCity = WeatherApiService.popularCities.first;

  @override
  void initState() {
    super.initState();
    _weatherService = widget.apiService ?? WeatherApiService();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _weatherService.fetchOutdoorTrainingConditions(
        latitude: _selectedCity.latitude,
        longitude: _selectedCity.longitude,
        cityName: _selectedCity.name,
      );
      if (mounted) {
        setState(() {
          _forecast = result;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
          // Fall back to offline weather model for seamless UI
          _forecast = _weatherService.getOfflineFallbackWeather(cityName: _selectedCity.name);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load weather: $e';
          _isLoading = false;
          _forecast = _weatherService.getOfflineFallbackWeather(cityName: _selectedCity.name);
        });
      }
    }
  }

  void _onCityChanged(CityCoordinates? newCity) {
    if (newCity != null && newCity != _selectedCity) {
      setState(() => _selectedCity = newCity);
      _loadWeather();
    }
  }

  void _logSuggestedHydration(int ml) {
    FitPulseState.instance.addWater(ml / 1000.0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          'Logged +${ml}ml environmental hydration based on outdoor heat index!',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title, City Selector, and Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Outdoor Advisor',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Open-Meteo REST API',
                            style: TextStyle(fontSize: 10, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // City Dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<CityCoordinates>(
                      value: _selectedCity,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textMuted),
                      items: WeatherApiService.popularCities.map((c) {
                        return DropdownMenuItem<CityCoordinates>(
                          value: c,
                          child: Text(
                            c.name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: _onCityChanged,
                    ),
                  ),
                  // Refresh Button
                  IconButton(
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Icon(Icons.refresh, color: AppColors.primary),
                    tooltip: 'Refresh Weather API',
                    onPressed: _isLoading ? null : _loadWeather,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weather Content
          if (_forecast != null) ...[
            // Metrics row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_forecast!.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _forecast!.conditionText,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Feels like ${_forecast!.apparentTemperature.toStringAsFixed(1)}°C • Humidity ${_forecast!.relativeHumidity}%',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.air, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${_forecast!.windSpeed.toStringAsFixed(0)} km/h',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Wind Speed',
                          style: TextStyle(fontSize: 9, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Athletic Advisory Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.directions_run, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Athletic Advisory',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _forecast!.trainingSafetyAdvisory,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Suggested Hydration Action
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Heat Target: +${_forecast!.suggestedExtraHydrationMl}ml',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _logSuggestedHydration(_forecast!.suggestedExtraHydrationMl),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Water', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ] else if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              'Notice: Using offline cache due to connection timeout.',
              style: TextStyle(fontSize: 10, color: Colors.amber.shade800, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
