import 'dart:async';

Future<String> performTask() {
	final completer = Completer<String>();

	print("Task started...");
	Future.delayed(const Duration(seconds: 3), () {
		// Manually completing the Future
		completer.complete("Task completed successfully!");
	});
	return completer.future;
}

void main() async {
	final result = await performTask();
	print(result);
}

