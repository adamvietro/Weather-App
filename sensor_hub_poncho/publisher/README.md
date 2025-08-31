# Publisher

## Project Overview

The **Publisher** is responsible for reading sensor data from the Raspberry Pi and sending it to the `weather_tracker` Phoenix API.  
It runs on the Pi and handles:

- Periodic sensor measurements
- Formatting data as JSON
- Sending HTTP POST requests to the API endpoint

This allows the `weather_tracker` backend to store and analyze environmental data in real-time.

## Requirements

- Raspberry Pi (tested on Pi 3A+)
- Elixir >= 1.14
- Erlang/OTP >= 25
- Nerves for firmware builds
- Network access to the `weather_tracker` server
