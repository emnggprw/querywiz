import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:querywiz/querywiz_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async code

  // await dotenv.load(fileName: "/lib/assets/.env");

  await dotenv.load(); // Automatically loads .env from root for mobile/desktop
  // Use this for web fallback:
  // await dotenv.load(fileName: kIsWeb ? "assets/.env" : ".env");

  runApp(const QueryWizApp());
}
