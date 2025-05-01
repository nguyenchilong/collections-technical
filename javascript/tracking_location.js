// Location Tracking
// Check if the Geolocation API is supported by the browser
if ('geolocation' in navigator) {
	// Request the user's current location
	navigator.geolocation.getCurrentPosition(
		function (position) {
			const Latitude = position.coords.latitude;
			const Longitude = position.coords.Longitude;
			console. log('Latitude: ', Latitude) ;
			console. Log('Longitude:', Longitude);
		},
		function (error) {
			console. Log('Error:', error.message);
		}
	);
} else {
	console. log( 'Geolocation is not supported by this browser.');
}
