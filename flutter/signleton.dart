//  Singleton Design Pattern
// The Singleton pattern ensures that a class has only one instance throughout your app's lifecycle, providing a global point of access.

class Logger {
	// Private constructor prevents direct instantiation
	Logger._internal();

	// The sing instance of Logger
	static final Logger _instance = Logger._internal();

	// Factory constructor returns the same instance
	factory Logger() {
		return _instance;
	}

	// Method to log messages with a timestamp
	void log(String message) {
		final timestamp = DateTime.now().toIso8601String();
		print("[$timestamp] $message");
	}
}



void main() {
	// Both logger1 and logger2 refer to the same Logger instance
	var logger1 = Logger();
	var logger2 = Logger();

	logger1.log("Application started");
	logger2.log("User logged in");

	// 	Verifying at both instances are identical
	print("Are logger1 and logger2 identical? ${identical(logger1, logger2)}");
}
