import 'package:flutter/material.dart';
import 'package:pos_app/pages/home.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes:{
      '/': (context) => Home(),
     
    },

  ));
}


