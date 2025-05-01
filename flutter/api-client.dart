
import 'dart:convert';
import 'package:dio/dio.dart';

class ApiClient {
	final Dio dio = Dio(BaseOptions(
		baseUrl: 'https://jsonplaceholder.typicode.com',
		connectTimeout: const Duration(seconds: 5),
		receiveTimeout: const Duration(seconds: 5),
		headers: {'Content-Type': 'application/json'},
	));

	ApiClient() {
		dio.interceptors.add(InterceptorsWrapper(
			onRequest: (options, handler) {
				print('Sending request to: ${options.uri}');
				return handler.next(options);
			},
			onResponse: (response, handler) {
				print('Received response: ${response.statusCode}');
				return handler.next (response);
			},
			onError: (DioException e, handler) async {
				int retryCount = 0;
				int maxRetries = 3;
				while (retryCount < maxRetries && e.type == DioExceptionType.connectionTimeout) {
					retryCount++;
					try {
						print('Connection timeout, retrying...');
						final res = await dio.request(e.requestOptions.path);
						return handler.resolve(res) ;
					} catch (e) {
						print(e.toString());
					}
				}

				return handler.next(e);
			},
		));
	}

	Future<List<dynamic>> fetchPosts() async {
		try {
			Response response = await dio.get('/posts');
			final data = jsonDecode(response.data);
			return data as List<dynamic>;
		} catch (e) {
			print('Error fetching posts: $e');
			return [];
		}
	}
}

