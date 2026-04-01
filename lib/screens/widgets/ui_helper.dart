import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiHelper {
  static CustomImage({required String imgUrl}) {
    return Image.asset('assets/images/$imgUrl', width: 135);
  }

  static CustomText({
    required BuildContext context,
    required String text,
    required double fontSize,
    String? fontFamily,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: fontFamily ?? 'regular',
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? Color(0xFF0F1828),
      ),
    );
  }

  static CustomButton({
    required BuildContext context,
    required String btnName,
    required VoidCallback callback,
    Color? btnColor,
  }) {
    return SizedBox(
      height: 52,
      width: 327,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          callback();
        },
        child: CustomText(
          context: context,
          text: btnName,
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  static CustomTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String text,
    required TextInputType textInputType,
  }) {
    return Container(
      height: 45,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: TextField(
          controller: controller,
          keyboardType: textInputType,
          decoration: InputDecoration(label: Text(text)),
        ),
      ),
    );
  }
}
