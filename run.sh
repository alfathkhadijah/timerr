#!/bin/bash

# run.sh - Script to deploy Study Timer to Android Emulator

# 1. Check if emulator is already running
RUNNING_DEVICE=$(flutter devices | grep "emulator-5554")

if [ -z "$RUNNING_DEVICE" ]; then
    echo "🚀 No running emulator detected. Launching 'Medium_Phone_API_36.1'..."
    flutter emulators --launch Medium_Phone_API_36.1
    
    # Wait for the device to be ready
    echo "⏳ Waiting for emulator to boot..."
    sleep 10
fi

# 2. Run the application
echo "🏃 Running Study Timer on emulator..."
flutter run -d emulator-5554
