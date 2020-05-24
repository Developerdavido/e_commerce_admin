import 'package:adminecommerce/providers/app_states.dart';
import 'package:adminecommerce/providers/products_provider.dart';
import 'package:adminecommerce/screens/dashboard.dart';
import 'package:adminecommerce/widgets/small_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/admin.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: AppState()),
      ChangeNotifierProvider.value(value: ProductProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    ),
));


