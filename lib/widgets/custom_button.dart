import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
    final String text;
    // final Function(String) click;
    final click;

    const CustomButton({
        required this.text,
        required this.click,
        super.key,
    });

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: 300,
            height: 52,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                    ),
                ),
                onPressed: click,
                child: Text('$text'),
            ),
        );
    }
}


