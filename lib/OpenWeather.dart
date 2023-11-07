import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather/detalhes.dart';

class DailyInfo{
  double tempMin;
  double tempMax;
  int weatherId;
  String weatherIcon;
  int pressure;
  int humidity;
  double windSpeed;
  DateTime dateTime;

  DailyInfo(
    this.tempMin, 
    this.tempMax, 
    this.weatherId, 
    this.weatherIcon, 
    this.pressure, 
    this.humidity, 
    this.windSpeed,
    this.dateTime
  );

  Map<String, dynamic> toJson() => 
  {
    'tempMin': tempMin,
    'tempMax': tempMax,
    'weatherId': weatherId,
    'weatherIcon': weatherIcon,
    'pressure': pressure,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'dateTime': dateTime.millisecondsSinceEpoch,
  };

  factory DailyInfo.fromJson(Map<String, dynamic> json) {
        return DailyInfo(
          json['tempMin'], 
          json['tempMax'],
          json['weatherId'],
          json['weatherIcon'],
          json['pressure'],
          json['humidity'],
          json['windSpeed'],
          DateTime.fromMillisecondsSinceEpoch(json['dateTime'])
        );
    }
}

class _CurrentWeather {
  double temp;
  int weatherId;
  String weatherIcon;
  DateTime dateTime;

   _CurrentWeather(
    this.temp,
    this.weatherId, 
    this.weatherIcon,
    this.dateTime
  );

  Map<String, dynamic> toJson() => 
  {
    'temp': temp,
    'weatherId': weatherId,
    'weatherIcon': weatherIcon,
    'dateTime': dateTime.millisecondsSinceEpoch,
  };

  factory _CurrentWeather.fromJson(Map<String, dynamic> json) {
        return _CurrentWeather(
          json['temp'],
          json['weatherId'],
          json['weatherIcon'],
          DateTime.fromMillisecondsSinceEpoch(json['dateTime'])
        );
    }
}

class _HourInfo {
  double temp = 0;
  int weatherId = 0;
  String weatherIcon = '';
  DateTime dateTime;

  _HourInfo(
    this.temp,
    this.weatherId, 
    this.weatherIcon,
    this.dateTime,
  );

  Map<String, dynamic> toJson() => 
  {
    'temp': temp,
    'weatherId': weatherId,
    'weatherIcon': weatherIcon,
    'dateTime': dateTime.millisecondsSinceEpoch,
  };

  
  factory _HourInfo.fromJson(Map<String, dynamic> json) {
        return _HourInfo(
          json['temp'],
          json['weatherId'],
          json['weatherIcon'],
          DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
        );
    }
}

class WeatherInfo {
  final List<DailyInfo> _dailyInfo = [];
  late _CurrentWeather _currentWeather = _CurrentWeather(0,0,'0',DateTime.now());
  final List<_HourInfo> _hourInfo = [];

  Future<void> getWeatherLoc(dynamic lat, dynamic lon) async {
    //https://api.openweathermap.org/data/2.5/onecall?lat={lat}&lon={lon}&appid={API key}

    final queryParameters = {
      'lat': lat,
      'lon': lon,
      'appid': 'd454b416d6eac750778821f89cef1cc9',
      'units': 'metric',
      'exclude': 'minutely,alerts'
    };

    final uri = Uri.https(
        'api.openweathermap.org', '/data/2.5/onecall', queryParameters);

    final response = await http.get(uri);
    debugPrint(response.body.toString());

    final json = jsonDecode(response.body);
   
    _currentWeather.temp = (json['current']['temp'] as num).toDouble();
    _currentWeather.weatherId = json['current']['weather'][0]['id'];
    _currentWeather.weatherIcon = json['current']['weather'][0]['icon'];

    final listDay = json['daily'];

    _dailyInfo.clear();
    for(var _day in listDay){
      var _dayInfo = DailyInfo(
        (_day['temp']['min'] as num).toDouble(), 
        (_day['temp']['max'] as num).toDouble(),
        _day['weather'][0]['id'],
        _day['weather'][0]['icon'],
        _day['pressure'],
        _day['humidity'],
        (_day['wind_speed'] as num).toDouble(),
        DateTime.fromMillisecondsSinceEpoch(_day['dt'] * 1000)
      );

      _dailyInfo.add(_dayInfo);
    }

    final listHour = json['hourly'];

    _hourInfo.clear();
    for(var i = 0; i<12; i++){
      var _newHour = _HourInfo(
        (listHour[i]['temp'] as num).toDouble(),
        listHour[i]['weather'][0]['id'],
        listHour[i]['weather'][0]['icon'],
        DateTime.fromMillisecondsSinceEpoch(listHour[i]['dt'] * 1000)
      );
      _hourInfo.add(_newHour);      
    }


  }

  String getCurrentWeatherString() {
      return jsonEncode(_currentWeather.toJson());
  }

  String getDailyWeatherString() {
      return jsonEncode(_dailyInfo);
  }

  String getHourlyWeatherString() {
      return jsonEncode(_hourInfo);
  }

  int getDailySize(){
    return _dailyInfo.length;
  }

  void setCurrentWeatherFromString(String stringCurr) {
      _currentWeather = _CurrentWeather.fromJson(jsonDecode(stringCurr));
  }

  void setDailyWeatherFromString(String stringDaily) {
      _dailyInfo.clear();

      var _json = (jsonDecode(stringDaily) as List);

      for(var _day in _json){
        var _dayInfo = DailyInfo.fromJson(_day);

        _dailyInfo.add(_dayInfo);
      }
  }

  void setHourlyWeatherFromString(String stringHour) { 
      _hourInfo.clear();

      var _json = (jsonDecode(stringHour) as List);

      for(var _hour in _json){
        var _newHour = _HourInfo.fromJson(_hour);

        _hourInfo.add(_newHour);
      }}

  String getCurrIcon() {
    return _currentWeather.weatherIcon;
  }

  double getCurrTemp() {
    return _currentWeather.temp;
  }

  int getCurrId() {
    return _currentWeather.weatherId;
  }

  double getDayMaxTemp(int i) {
    if (_dailyInfo.length < i+1) {
      return -1;
    }
    return _dailyInfo[i].tempMax;
  }
  
  double getDayMinTemp(int i) {
    if (_dailyInfo.length < i+1) {
      return -1;
    }
    return _dailyInfo[i].tempMin;
  }

  String getDayIcon(int i) {
    if (_dailyInfo.length < i+1) {
      return '0';
    }
    return _dailyInfo[i].weatherIcon;
  }

  String getCurrTdString() {
    return DateFormat('dd/MM/yyyy HH:mm').format(_currentWeather.dateTime);
  }

  int getDayId(int i) {
    if (_dailyInfo.length < i+1) {
      return 0;
    }
    return _dailyInfo[i].weatherId;
  }

  String getDayTdString(int i) {
    if (_dailyInfo.length < i+1) {
      return '0';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(_dailyInfo[i].dateTime);
  }

  double getDayWind(int i){
    if (_dailyInfo.length < i+1) {
      return 0;
    }
    return _dailyInfo[i].windSpeed;
  }

  int getDayHumidity(int i) {
    if (_dailyInfo.length < i+1) {
      return 0;
    }
    return _dailyInfo[i].humidity;
  }

  int getDayPressure(int i) {
    if (_dailyInfo.length < i+1) {
      return 0;
    }
  return _dailyInfo[i].pressure;
  }

  String getHourTdString(int i) {
    if (_hourInfo.length < i+1) {
      return '0';
    }
    return DateFormat('HH:mm').format(_hourInfo[i].dateTime);   
  }

  String getHourIcon(int i) {
    if (_hourInfo.length < i+1) {
      return '0';
    }
    return _hourInfo[i].weatherIcon;
  }

  double getHourTemp(int i) {
    if (_hourInfo.length < i+1) {
      return 0;
    }
    return _hourInfo[i].temp;
  }
}





