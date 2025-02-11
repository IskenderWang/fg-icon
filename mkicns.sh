#!/usr/bin/env bash

cd FlightGear.iconset || exit
sips -z 16 16 ../FlightGear_app_icon.png --out icon_16x16.png
sips -z 32 32 ../FlightGear_app_icon.png --out icon_16x16@2x.png
sips -z 32 32 ../FlightGear_app_icon.png --out icon_32x32.png
sips -z 64 64 ../FlightGear_app_icon.png --out icon_32x32@2x.png
sips -z 64 64 ../FlightGear_app_icon.png --out icon_64x64.png
sips -z 128 128 ../FlightGear_app_icon.png --out icon_64x64@2x.png
sips -z 128 128 ../FlightGear_app_icon.png --out icon_128x128.png
sips -z 256 256 ../FlightGear_app_icon.png --out icon_128x128@2x.png
sips -z 256 256 ../FlightGear_app_icon.png --out icon_256x256.png
sips -z 512 512 ../FlightGear_app_icon.png --out icon_256x256@2x.png
sips -z 512 512 ../FlightGear_app_icon.png --out icon_512x512.png
sips -z 1024 1024 ../FlightGear_app_icon.png --out icon_512x512@2x.png
sips -z 1024 1024 ../FlightGear_app_icon.png --out icon_1024x1024.png
sips -z 2048 2048 ../FlightGear_app_icon.png --out icon_1024x1024@2x.png
cd .. && iconutil -c icns FlightGear.iconset
