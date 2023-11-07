import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:weather/OpenWeather.dart';
import 'package:weather/main.dart';

class Arguments{
  WeatherInfo _weatherInfo;
  int _index;

  Arguments(
    this._weatherInfo, 
    this._index
  );
}

class DetalhesScreen extends StatefulWidget {
  const DetalhesScreen({Key? key}) : super(key: key);

  static const String routeName = 'detalhesScreen';

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late final Arguments args;
  final num _image = 1 + (Random().nextInt(4));
  String _imageFolder = '';

  @override
  void initState() {
    super.initState();
  }

  void updateBackgroundImage() async{
    switch (args._weatherInfo.getDayId(args._index)) {
          case 800: 
            _imageFolder = 'clear';
            break;
          default:{
            switch ((args._weatherInfo.getDayId(args._index) / 100).floor()) {
              case 2:
                _imageFolder = 'thunderstorm';
                break;
              case 3:
                _imageFolder = 'drizzle';
                break;
              case 5:
                _imageFolder = 'rain';
                break;
              case 6:
                _imageFolder = 'snow';
                break;
              case 7:
                _imageFolder = 'atmosphere';
                break;
              case 8:
                _imageFolder = 'clouds';
                break;
              default:
                _imageFolder = 'clear';
            }
          }
        }
      setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as Arguments;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                image: AssetImage('assets/images/${getImageFolder()}/$_image.jpg'),
                    fit: BoxFit.cover)),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [
                      0.0,
                      0.7,
                      1.0
                    ])),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 10, top: 40),
                                child: FloatingActionButton.small(
                                  heroTag: 'floatingButton',
                                  onPressed: () => Navigator.pop(context),
                                  child: const Icon(Icons.arrow_back),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                  Text(
                                    _getDayWeatherMsg(),
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                (args._weatherInfo.getDayIcon(args._index)!=0.toString())?
                                  Hero(
                                    tag: 'icon${args._index}',
                                    child: Image.network('http://openweathermap.org/img/wn/' + args._weatherInfo.getDayIcon(args._index) + '@2x.png')):
                                    const SizedBox(height: 5),
                            const SizedBox(
                              height: 5,
                            ),
                              ],
                            ),
                            Text(
                              args._weatherInfo.getDayTdString(args._index),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Tº Min',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                args._weatherInfo.getDayMinTemp(args._index).toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const Text(
                                'ºC',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Tº Max',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                args._weatherInfo.getDayMaxTemp(args._index).toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const Text(
                                'ºC',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.wind,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                args._weatherInfo.getDayWind(args._index).toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const Text(
                                'km/h',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.humidity,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                args._weatherInfo.getDayHumidity(args._index).toString(),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const Text(
                                '%',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.pressure,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                args._weatherInfo.getDayPressure(args._index).toString(),
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                'hPa',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              /*Stack(
                          children: [
                            Container(
                              height: 5,
                              width: 50,
                              color: Colors.white38,
                            ),
                            Container(
                              height: 5,
                              width: 20 / 2,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayWeatherMsg() {
    return _getWeatherMsg(args._weatherInfo.getDayId(args._index));
  }

  String _getWeatherMsg(weatherId) {
    switch (weatherId) {
      case 800:
          return AppLocalizations.of(context)!.weatherClear;
      default:{
        switch ((weatherId/100).floor()) {
          case 2:
            return AppLocalizations.of(context)!.weatherThunder;
          case 3:
            return AppLocalizations.of(context)!.weatherDrizzle;
          case 5:
            return AppLocalizations.of(context)!.weatherRain;
          case 6:
            return AppLocalizations.of(context)!.weatherSnow;
          case 7:
            return AppLocalizations.of(context)!.weatherAtmosphere;
          case 8:
            return AppLocalizations.of(context)!.weatherClouds;
          default:
            return 'erro';
        }
      }
    }
  }

  getImageFolder() {
    if (_imageFolder.compareTo('')==0) {
      updateBackgroundImage();
      return _imageFolder;
    }
  }
}
