
import 'dart:async';
import 'dart:isolate';


void computeInIsolate(SendPort sendPort) {
	final receivePort = ReceivePort();
	sendPort.send(receivePort.sendPort);

	receivePort.listen ((data) {
		final result = data[0] as int;
		final replyPort = data[1] as SendPort;

		// Simulating a heavy computation
		int fibonacci(int n) {
			if (n <= 1) return n;
			return fibonacci(n - 1) + fibonacci(n - 2);
		}

		// Compute the Fibonacci number
		final computedValue = fibonacci(result);
		replyPort.send(computedValue);
	});
}



// Function to start the isolate and communicate with it
Future<void> startIsolate(int number) async {
	final receivePort = ReceivePort();
	final isolate = await Isolate.spawn(computeInIsolate, receivePort.sendPort) ;

	final sendPort = await receivePort.first as SendPort;
	final replyReceivePort = ReceivePort();

	sendPort.send([number, replyReceivePort.sendPort]);

	final computedValue = await replyReceivePort.first;
	print('Fibonacci of $number is $computedValue');

	receivePort.close();
	replyReceivePort.close();
	isolate.kill(priority: Isolate.immediate) ;
}

void main() {
	const number = 30; // Change this to compute different Fibonacci numbers
	startIsolate(number);
}

