# dost - NFC Tagging and Tracking Mobile Application for Earthquake Victims

<img width="540" alt="dost_large" src="https://github.com/keremgirenes/ELEC491-EarthquakeApp/assets/69321438/7d18f0ca-dd65-4f97-8a19-3facbddaaf18">

This project aims to develop a mobile application that utilizes Near Field Communication (NFC) tags to save crucial information about victims in chaotic environments caused by natural disasters, such as earthquakes. The objective is to address the challenges faced by search and rescue teams, health teams, and morgue teams in maintaining control and accurate records amidst the turmoil of a disaster.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

During a natural disaster, it is crucial for emergency response teams to have access to accurate and up-to-date information about victims. The Disaster Victim Management Mobile Application provides a solution by leveraging NFC technology to create victim profiles and store relevant information. Authorized personnel can create victim profiles and provide individuals with a bracelet containing an NFC tag. Other authorized individuals can then read these tags and add further information to the victim's profile.

By utilizing this application during emergencies, people are provided with accessible and accurate information about nearby earthquake victims, as well as their separated friends and family members who may have been out of reach. Moreover, it facilitates a comprehensive evaluation of the affected individuals on a larger scale, enabling the prompt deployment of necessary aid to the affected region. This project contributes to improved situational awareness and aid coordination during emergencies.

## Features

![dostscreens](https://github.com/keremgirenes/ELEC491-EarthquakeApp/assets/69321438/51b5a3f8-9055-4387-88a0-2fbaec3b6685)


- Create victim profiles with crucial information
- Associate NFC tags with victim profiles
- Read NFC tags to access victim profiles
- Add and update information to victim profiles
- Integration with location services for accurate victim tracking
- User-friendly interface for ease of use
- Cloud-based database for data storage and retrieval

## Technologies Used

- NFC technology for scanning and writing NFC tags
- Flutter framework for cross-platform mobile application development
- Firebase database system for data storage and retrieval
- Additional software packages as required for tag reading and location services
- Database management systems for backend support
- Third-party service providers for additional functionality

## Installation

#### NOTE: A physical device equipped with NFC hardware is needed to demonstrate the app's functionalities.

1. Clone the repository:

```bash
git clone https://github.com/keremgirenes/ELEC491-EarthquakeApp.git
```

2. Install the required dependencies:

```bash
cd ui
flutter pub get
```

3. Configure Firebase for the mobile application by following the instructions provided by Firebase documentation.

4. Build and run the application:

```bash
cd ui
flutter run
```

## Usage

1. Register and log in as an authorized user.
2. Create victim profiles by entering crucial information.
3. Provide the victim with a bracelet containing an NFC tag.
4. Scan the NFC tag using the mobile application to access the victim's profile.
5. Add and update information as necessary.
6. Utilize the integrated location services for accurate victim tracking.
7. Coordinate with other authorized individuals to ensure comprehensive victim management.

## Contributing

Contributions to the Disaster Victim Management Mobile Application project are welcome and encouraged! If you would like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make the necessary changes and commit them.
4. Push your branch to your forked repository.
5. Submit a pull request describing your changes.

## License

This project is licensed under the [MIT License](LICENSE.md).
