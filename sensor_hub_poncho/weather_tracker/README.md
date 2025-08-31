# Weather Tracker

## Project Overview

**Weather Tracker** is a Phoenix/Elixir-based backend service for collecting, storing, and serving weather condition data from IoT devices. The system supports real-time data ingestion from sensor-equipped devices (like Raspberry Pi) and provides a REST API for retrieving and analyzing weather metrics.

**Key Features:**

- Receive weather data via HTTP POST requests.
- Store readings in a PostgreSQL database using Ecto.
- Provide JSON endpoints for querying recent weather conditions.
- Real-time monitoring support through Phoenix LiveView (optional).

## Requirements

### System Requirements

- **Elixir** >= 1.14
- **Erlang/OTP** >= 25
- **Phoenix** >= 1.5
- **PostgreSQL** >= 13
- **Nerves** (for Raspberry Pi / IoT integration)

### Dependencies

- `ecto` and `postgrex` for database access
- `phoenix` and `phoenix_pubsub` for the web framework
- `jason` for JSON encoding/decoding
- `finch` for HTTP client requests from the devices

### Network Requirements

- Devices must be able to reach the Phoenix server via LAN IP and port (default: `4000`).
- Firewalls and WSL networking may require port forwarding to allow external devices to POST data.


## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/weather_tracker.git
cd weather_tracker
```


### 2. Install Dependencies
Make sure you have Elixir, Erlang, and Node.js installed.

```bash
mix deps.get
```

### 3. Configure the Database
Update the database configuration in config/dev.exs:

```elixir
config :weather_tracker, WeatherTracker.Repo,
  username: "postgres",
  password: "postgres",
  database: "weather_tracker_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```
Create and migrate the database:

```bash
mix ecto.create
mix ecto.migrate
```

### 4. Start the Phoenix Server
```bash
mix phx.server
```

### 5 Networking for IoT Devices (Optional)
If running Phoenix under WSL and allowing external devices (like Raspberry Pi) to POST data:

1. Open a PowerShell terminal as Administrator.
```powershell
netsh interface portproxy add v4tov4 listenaddress=192.168.50.74 listenport=4000 connectaddress=172.27.4.112 connectport=4000
```

2. Forward the WSL port to the Windows LAN IP:
```powershell
netsh advfirewall firewall add rule name="Allow Phoenix 4000" dir=in action=allow protocol=TCP localport=4000
```