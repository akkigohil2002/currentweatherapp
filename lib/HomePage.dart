import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

import 'Constant/const.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  final TextEditingController _cityController = TextEditingController();
  String _currentCity = "Vadodara";

  @override
  void initState() {
    super.initState();
    _fetchWeather(_currentCity);
  }

  Future<void> _fetchWeather(String city) async {
    try {
      Weather weather = await _wf.currentWeatherByCityName(city);
      setState(() {
        _weather = weather;
        _currentCity = city;
      });
    } catch (e) {
      // Show error in the UI
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Unable to fetch weather for '$city'. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(child: _buildUI()),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: "Enter city name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_cityController.text.isNotEmpty) {
                _fetchWeather(_cityController.text);
              }
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          const SizedBox(height: 20),
          _dateTimeInfo(),
          const SizedBox(height: 20),
          _weatherIcon(),
          const SizedBox(height: 20),
          _currentTemp(),
          const SizedBox(height: 20),
          _extraInfo(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "Unknown Location",
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather?.date ?? DateTime.now();
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          DateFormat('EEEE, d MMM y').format(now),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    String iconUrl =
        "http://openweathermap.org/img/wn/${_weather?.weatherIcon ?? "01d"}@4x.png";
    return Column(
      children: [
        Image.network(iconUrl, height: 100),
        Text(
          _weather?.weatherDescription?.toUpperCase() ?? "Clear",
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0) ?? "--"}°C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 60,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0) ?? "--"}°C",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0) ?? "--"}°C",
                style: const TextStyle(color: Colors.white, fontSize: 23),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(1) ?? "--"} m/s",
                style: const TextStyle(color: Colors.white, fontSize: 23),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0) ?? "--"}%",
                style: const TextStyle(color: Colors.white, fontSize: 23),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
