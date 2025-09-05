import 'package:flutter/material.dart';

class KaKaoButton extends StatelessWidget {
    final click;

    const KaKaoButton({
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
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                    ),
                ),
                onPressed: click,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Image.asset('assets/images/kakao_logo.png', width: 20, height: 20),
                        const SizedBox(width: 8),
                        const Text('카카오로 계속하기'),
                    ],
                ),
            ),
        );
    }
}


