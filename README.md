# DashCamDatabaseUpdater

MacOS X "LaunchAgent" script for automatic updating of speed cam database for the dash cam.

Currently it supports only TrendVision TDR-718GP dash cam. It downloads and unpacks speed cam database to the SD card of the dash cam if it is inserted and mounted and has no database file in it (database file gets automaticaly removed by the dash cam after successfull updating).

Also, there is a script `install.sh` to automatically install the "updater" stript on your MacOS X and make it auto-executed every minute.

See the scripts for further details.

Support for other models of dash cams is currently not planned.
