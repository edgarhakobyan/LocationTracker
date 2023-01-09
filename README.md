# LocationTracker

The application tracks users' location and shows it on a map


### CLLocationManager
Is used for tracking location updates <br/>
The location will be updated for each 50 meters distance <br/>
It can be changed in the line `locationManager.distanceFilter = 50.0`


### MKMapView
Is used for showing map


### Background updates
The application will track location in background mode and keep coordinates in the file located in the document folder
