import 'package:flutter/material.dart';

InputDecoration textFieldInputDecoration(String hintText){
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white54,
      ),
      focusedBorder:  UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)),
      enabledBorder:  UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      )
  );
}

TextStyle simpleTextFieldStyle(){
  return TextStyle(
    color: Colors.white,
        fontSize: 16,
  );
}

TextStyle mediumTextFieldStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 18,
    decoration: TextDecoration.none
  );
}
