import 'package:flutter/material.dart';
class Textbox extends StatefulWidget {
	final bgcolor;
  const Textbox({super.key,required  this.bgcolor});
	
  @override
  State<Textbox> createState() => _TextboxState();
}

class _TextboxState extends State<Textbox> {
  @override
  Widget build(BuildContext context) {
    return TextField(
            decoration: InputDecoration(
				filled: true,
				fillColor: widget.bgcolor,
		        enabledBorder: OutlineInputBorder(
			      borderSide: BorderSide(
				    color: Colors.black,
				    width: 1.0,
			)
		)
	)
	);
  }
}