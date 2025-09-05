import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
    final String text;
    final bool obscureText;
    final TextEditingController controller;
    final Widget? suffixIcon;
    final String? Function(String?)? validator;

    const CustomTextField({
        required this.text, 
        this.obscureText = false, 
        required this.controller, 
        this.suffixIcon,
        this.validator,
        super.key,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children: [
                Container(
                    width: 300,
                    height: 52,
                    constraints: const BoxConstraints(
                        minHeight: 52,
                        maxHeight: 52,
                    ),
                    child: TextFormField(
                        controller: controller,
                        obscureText: obscureText,
                        validator: validator,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            hintText: '$text',
                            filled: true,
                            fillColor: Colors.grey[100],
                            suffixIcon: suffixIcon,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                            ),
                            errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                height: 1.0,
                            ),
                        ),
                    ),
                ),
            ],
        );
    }
}


