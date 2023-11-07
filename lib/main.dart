import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/detalhes.dart';



import 'OpenWeather.dart';
import 'detalhes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt', ''),
      ],
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName: (_) => const MyHomePage(title: 'Meteorologia'),
        DetalhesScreen.routeName: (_) => const DetalhesScreen()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  static const String routeName = 'homescreen';

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _weatherInfo = WeatherInfo();
  String _imageFolder = 'clear';
  int _image = 1;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _temDadosAnteriores = false;
  DateTime _lastUpdateDate = DateTime.now();
  bool _infoHora = false;

  Future<void> _getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _latitude = _locationData.latitude ?? 0.0;
      _longitude = _locationData.longitude ?? 0.0;
    });
  }

  void _updateInfo() async{
    await _getLocation();

    await _getWeatherUpdate();   


    if(await updateSharedPrefs() == false){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.msgErrorSavingData),
    ));
    }
      
    setState(() {
      _image = 1 + (Random().nextInt(4));
      _lastUpdateDate = DateTime.now();
      _temDadosAnteriores = true;    
    });
  }

  Future<void> _getWeatherUpdate() async{
    await _weatherInfo.getWeatherLoc(_latitude.toString(), _longitude.toString());
  }


  Future<bool> updateSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(await prefs.setString('current_weather', _weatherInfo.getCurrentWeatherString()) == false){
      return false;
    }

    if(await prefs.setString('daily_weather', _weatherInfo.getDailyWeatherString()) == false){
      return false;
    }


    if(await prefs.setString('hourly_weather', _weatherInfo.getHourlyWeatherString()) == false){
      return false;
    }

    return prefs.setString('date_last_update', _lastUpdateDate.toString()); 
}

  Future<void> _checkSavedData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _stringData = (prefs.getString('date_last_update'));
    if (_stringData == null) {
      return;
    }

    try {
      _lastUpdateDate = DateTime.parse(_stringData);

      String? _stringCurr = (prefs.getString('current_weather'));

      if (_stringCurr == null) {
        throw Exception();        
      }
      _weatherInfo.setCurrentWeatherFromString(_stringCurr);


      String? _stringDaily = (prefs.getString('daily_weather'));

      if (_stringDaily == null) {
        throw Exception();        
      }
      _weatherInfo.setDailyWeatherFromString(_stringDaily);

      String? _stringHour = (prefs.getString('hourly_weather'));

      if (_stringHour == null) {
        throw Exception();        
      }
      _weatherInfo.setHourlyWeatherFromString(_stringHour);




      _temDadosAnteriores = true;
      setState(() {
        _image = 1 + (Random().nextInt(4));
        switch (_weatherInfo.getCurrId()) {
          case 800: 
            _imageFolder = 'clear';
            break;
          default:{
            switch ((_weatherInfo.getCurrId() / 100).floor()) {
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
      });
    }catch (e) {
      debugPrint(e.toString());
      _temDadosAnteriores = false;
    }

    // if( não tem informação nas shared_preferences ){
    //    updateInfo();
    // }
  }

  void gotoDetalhesScreen(int i){

  }

  @override
  void initState() {
    super.initState();    
    _checkSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/$_imageFolder/$_image.jpg'),
                fit: BoxFit.cover
              )
            ),
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
                  stops: const [0.0, 0.7, 1.0])
              ),
              padding: EdgeInsets.all(20),
              child:Column(
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
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                    end: 10, top: 40),
                            child: Text(
                              _temDadosAnteriores? 
                                AppLocalizations.of(context)!.msgLastUpdate(DateFormat('dd').format(_lastUpdateDate), DateFormat('MM').format(_lastUpdateDate) , DateFormat('yyyy').format(_lastUpdateDate), DateFormat('HH:mm').format(_lastUpdateDate)): 
                                  AppLocalizations.of(context)!.msgNoSavedData,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: EdgeInsetsDirectional.only(end: 10),
                                  child:
                                FloatingActionButton(
                                onPressed: _swapBoolHourInfo,
                                child: const Icon(Icons.timer),
                              )),
                              FloatingActionButton(
                                heroTag: 'floatingButton',
                                onPressed: _updateInfo,
                                child: const Icon(Icons.update),
                              )
                                ],

                          ),
                        ],
                      ),
                        InkWell(
                            onTap: !_infoHora? () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 0)):
                             () => {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _weatherInfo.getCurrTemp().toStringAsFixed(1) + 'º',
                                style: const TextStyle(
                                    fontSize: 85,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _getCurrWeatherMsg(),
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                  (_weatherInfo.getCurrIcon()!=0.toString())?
                                    Hero(
                                    tag: 'icon0',
                                    child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getCurrIcon() + '@2x.png')):
                                      const SizedBox(height: 5),
                              const SizedBox(
                                height: 5,
                              ),
                                ],
                              ),
                              Text(
                                _weatherInfo.getCurrTdString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                              )
                            ],
                          ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: _infoHora? 
                      Container(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [ 
                            Builder(builder: _hourRow1Builder),
                            Builder(builder: _hourRow2Builder),
                              ],
                        ),
                      ):
                      Container(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 1)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(1).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon1',
                                          child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(1) + '@2x.png', height: 40,)):
                                        const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(1).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 2)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(2).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon2',
                                          child:Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(2) + '@2x.png', height: 40,)):
                                        const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(2).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 3)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(3).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon3',
                                          child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(3) + '@2x.png', height: 40,)):
                                        const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(3).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 4)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(4).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon4',
                                          child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(4) + '@2x.png', height: 40,)):
                                          const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(4).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 5)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(5).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon5',
                                          child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(5) + '@2x.png', height: 40,)):
                                          const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(5).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 6)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(6).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon6',
                                          child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(6) + '@2x.png', height: 40,)):
                                          const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(6).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, DetalhesScreen.routeName, arguments: Arguments(_weatherInfo, 7)),
                                  child: Column(
                                    children: [
                                      Text(
                                        _weatherInfo.getDayMaxTemp(7).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      (_weatherInfo.getDayIcon(1)!=0.toString())?
                                        Hero(
                                          tag: 'icon7',
                                          child: Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getDayIcon(7) + '@2x.png', height: 40,)):
                                          const SizedBox(height: 5),
                                      Text(
                                        _weatherInfo.getDayMinTemp(7).toStringAsFixed(1) + 'º',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]
        ), // This trailing comma makes auto-formatting nicer for build methods.
            )
          ]
    ),
    );
  }

  String _getCurrWeatherMsg() {
    return _getWeatherMsg(_weatherInfo.getCurrId());
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
            return AppLocalizations.of(context)!.noData;
        }
      }
    }
  }

  void _swapBoolHourInfo() {
    setState(() {
      _infoHora = !_infoHora;      
    });
  }

  Widget _hourRow1Builder(BuildContext context) {
    List<Widget> l = [];

    for (var i = 0; i < 6; i++) {
      l.add(
        Column(
          children: [
            Text(
              _weatherInfo.getHourTdString(i),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            (_weatherInfo.getHourIcon(i)!=0.toString())?
              Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getHourIcon(i) + '@2x.png', height: 40,):
              const SizedBox(height: 5),
            Text(
              _weatherInfo.getHourTemp(i).toStringAsFixed(1) + 'º',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
    );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: l,
    );
  }

  Widget _hourRow2Builder(BuildContext context) {
    List<Widget> l = [];

    for (var i = 6; i < 12; i++) {
      l.add(
        Column(
          children: [
            Text(
              _weatherInfo.getHourTdString(i),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            (_weatherInfo.getHourIcon(i)!=0.toString())?
              Image.network('http://openweathermap.org/img/wn/' + _weatherInfo.getHourIcon(i) + '@2x.png', height: 40,):
              const SizedBox(height: 5),
            Text(
              _weatherInfo.getHourTemp(i).toStringAsFixed(1) + 'º',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: l,
    );
  }
}