# StressTool

[![Build and Test](https://github.com/YOUR_USERNAME/StressTool/workflows/Build%20and%20Test/badge.svg)](https://github.com/YOUR_USERNAME/StressTool/actions)

A modern HTTP stress testing tool built with SwiftUI and AsyncHTTPClient, designed specifically for macOS.

## Features

- 🚀 **High Concurrency Support**: Supports 1-10,000 concurrent connections
- 📊 **Real-time Monitoring**: Real-time display of request statistics and response times
- 🎯 **Multiple Request Methods**: Supports GET and POST requests
- 📈 **Performance Metrics**: Real-time calculation of average response time, success rate and other key metrics
- 💾 **Persistent Storage**: Uses SwiftData to save test logs
- ⚡ **High-Performance Architecture**: Uses AsyncHTTPClient and concurrency optimization to avoid UI freezing
- 🎨 **Modern UI**: Intuitive user interface built with SwiftUI

## System Requirements

- macOS 14.0 or higher
- Xcode 15.0 or higher
- Swift 5.9 or higher

## Tech Stack

- **Framework**: SwiftUI
- **HTTP Client**: AsyncHTTPClient
- **Data Storage**: SwiftData
- **Concurrency**: Swift Concurrency (async/await)
- **Network Layer**: NIO (Network Input/Output)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd StressTool
```

2. Open the project with Xcode:
```bash
open StressTool.xcodeproj
```

3. Build and run the project (⌘+R)

## Usage

### Basic Usage

1. **Enter Target URL**: Input the HTTP endpoint to test in the "Request URL" field
2. **Set Concurrency**: Enter the number of concurrent connections (1-10,000) in the "Concurrency" field
3. **Select Request Method**:
   - GET: For simple HTTP GET requests
   - POST: For sending JSON data with POST requests
4. **Configure Request Body** (POST only): Input JSON format data in the request body field
5. **Start Testing**: Click the "Start Test" button
6. **View Results**: Monitor real-time metrics panel and request logs

### Example Configurations

#### GET Request Test
```
URL: https://httpbin.org/get
Concurrency: 10
Method: GET
```

#### POST Request Test
```
URL: https://httpbin.org/post
Concurrency: 50
Method: POST
Request Body: {"test": "data", "timestamp": "2025-07-10"}
```

### Performance Metrics Description

- **Total Requests**: Total number of requests sent
- **Success**: Number of requests with HTTP status code 2xx
- **Failed**: Number of requests with network errors or non-2xx status codes
- **Average Duration**: Average response time of all completed requests (seconds)
- **Total Duration**: Total time from start to end of testing (seconds)

## Architecture Design

### Core Components

1. **ConcurrencyTester**: Main stress testing engine
   - Uses Swift Concurrency for high concurrency
   - Batch log updates to avoid UI freezing
   - Incremental average calculation for performance optimization

2. **DashboardView**: Real-time performance metrics display panel
3. **RequestRow**: Individual request log display component
4. **Models**: Data model layer
   - `Metrics`: Performance metrics data structure
   - `RequestLog`: Request log data structure
   - `PersistentLog`: Persistent log model

### Performance Optimizations

- **Batch UI Updates**: Uses timers for batch log refreshing to reduce UI update frequency
- **Incremental Calculation**: Average response time uses incremental algorithm to avoid repeated calculations
- **Memory Management**: Proper task lifecycle management to prevent memory leaks
- **Concurrency Control**: Uses TaskGroup to manage concurrent tasks

## Development Guide

### Project Structure

```
StressTool/
├── StressToolApp.swift          # Application entry point
├── ContentView.swift            # Main interface
├── ViewModel/
│   └── ConcurrencyTester.swift  # Stress testing core logic
├── Views/
│   ├── DashboardView.swift      # Performance metrics panel
│   └── RequestRow.swift         # Request log row
├── Model/
│   ├── Metrics.swift            # Performance metrics model
│   ├── RequestLog.swift         # Request log model
│   ├── RequestStatus.swift      # Request status enum
│   └── PersistentLog.swift      # Persistent log model
└── Assets.xcassets/             # Application resources
```

### Extension Features

For adding new features, consider the following extension points:

1. **New HTTP Methods**: Add support for PUT, DELETE and other methods in `ConcurrencyTester`
2. **Custom Headers**: Extend UI to support custom HTTP headers
3. **Result Export**: Add functionality to export test results as CSV/JSON
4. **Chart Display**: Integrate charting libraries to display performance trends
5. **Preset Configurations**: Support saving and loading test configurations

## Troubleshooting

### Common Issues

1. **Connection Timeout**
   - Check if the target URL is accessible
   - Confirm network connection is normal
   - Reduce concurrency number and retry

2. **High Memory Usage**
   - Reduce concurrent connections
   - Ensure timely test termination
   - Restart application to release memory

3. **Slow UI Response**
   - Already optimized with batch updates and incremental calculations
   - If issues persist, consider reducing concurrency

### Debug Mode

In development mode, the console displays detailed HTTP response header information to help debug network request issues.

## Contributing

Issues and Pull Requests are welcome!

### Development Environment Setup

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Create a Pull Request

## License

[MIT License](LICENSE)

## Author

Created by spectator on 2025/7/10

---

⚠️ **Disclaimer**: This tool is intended for legitimate performance testing purposes only. Do not use it to attack other people's servers or engage in any malicious activities. When testing third-party services with this tool, please ensure you have appropriate authorization.
