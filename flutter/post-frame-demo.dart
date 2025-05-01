import 'package:flutter/material.dart';

class PostFrameDemo extends StatefulWidget {
	const PostFrameDemo({super.key});

	@override
	_PostFrameDemoState createState() => _PostFrameDemoState();
}



class _PostFrameDemoState extends State<PostFrameDemo> {
	final ScrollController _controller = ScrollController();

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_controller.animateTo(
				100.0, // Scroll position
				duration: const Duration(seconds: 1),
				curve: Curves.easeInOut,
			);
		});
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return ListView.builder(
			controller: _controller,
			itemCount: 50,
			itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
		);
	}
}
