# AMov_TP_Flutter_Grupo35

# Weather Forecast App

![Untitled-2](https://github.com/pmspedrosa/AMov_TP_Flutter_Grupo35/assets/76016818/1819c236-ecb4-426d-b187-d70863cc5ced)


## Introduction
This Flutter application is a simple weather forecast app that provides users with current weather conditions and forecasts for the upcoming days. It utilizes a public weather data API (OpenWeatherMap) to fetch weather information.

## Features
- **Main Screen:** The main screen displays a concise overview of the current weather conditions and a 7-day weather forecast for the user's location. Users can press a button to refresh the data. They can also switch between a 7-day forecast view and a 12-hour forecast view.

- **Details Screen:** Users can tap on a specific day in the main screen to navigate to the details screen, where they can access more information about the selected day's weather. This includes minimum and maximum temperatures, wind speed, humidity, and atmospheric pressure.

- **Location Services:** The app utilizes the user's current location to provide weather data, ensuring accurate forecasts.

- **Data Persistence:** The last update time is stored using shared preferences, and the app displays this information to users.

- **Internationalization:** The app supports internationalization for different languages and regions.

- **Custom App Icon:** The app has a personalized icon.

- **Splash Screen:** A splash screen is displayed when the app is launched, providing a smooth and branded introduction.

- **Animations:** The app incorporates subtle animations for transitioning between screens, enhancing the user experience.

## Architecture
The application is built using the Flutter framework. It relies on the OpenWeatherMap API (OneCall API) to retrieve 7-day weather forecasts in addition to current weather data. The project is organized into three Dart files:

- `main.dart`: Contains the code for creating the main screen and functions to fetch weather information.

- `detalhes.dart`: Contains the code for creating the details screen and functions to fetch weather information.

- `OpenWeather.dart`: Contains code for interacting with the OpenWeatherMap API to fetch weather forecasts and present them on the screens.

## Usage
- Clone this repository.
- Open the project in a Flutter-compatible IDE (e.g., Android Studio or Visual Studio Code).
- Run the app on an emulator or a physical device.
- Make sure to grant location permissions for accurate weather data.

## Design
The user interface design was inspired by a publicly available design. You can view the design that served as inspiration [here](https://search.muz.li/NjcyYzlmYTRi). We made some modifications to accommodate all the required features.

## Authors
- [pmspedrosa](https://github.com/pmspedrosa)
- [APC15](https://github.com/APC15)https://github.com/APC15
- [C4CP10](https://github.com/C4CP10)https://github.com/C4CP10
