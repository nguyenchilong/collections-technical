
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
	Workmanager().executeTask((task, inputData) async {
	  print("Executing background task: fetching new data...");
	  try {
		  final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
		  // Make the GET request
		  final response = await http.get(url);
		  if (response.statusCode == 200) {
		    // Decode the JSON response
		    final data = jsonDecode (response.body);
		    // Here you could save data to a local database or handle it as needed
		    print("Fetched Data: $data");
		    // Task completed successfully
		    return Future.value(true);
		  } else {
		    print("Failed to fetch data. Status Code: ${response.statusCode}");
		    return Future.value(false);
		  }
	  } catch (error) {
		  print("Error during background task: $error");
		  return Future.value(false);
	  }
	});
}

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	Workmanager().initialize(callbackDispatcher) ;

	// Register a periodic task every 15 minute
	Workmanager().registerPeriodicTask(
		"fetchTask",
		"simpleTask",
		frequency: const Duration(minutes: 15),
	);
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return const Scaffold();
	}
}

