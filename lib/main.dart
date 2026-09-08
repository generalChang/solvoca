import 'package:flutter/material.dart';
import 'package:solvoca/app/solvoca_app.dart';
import 'package:solvoca/app/study_controller.dart';
import 'package:solvoca/persistence/json_file_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = JsonFileStore();
  await store.load();

  final controller = createStudyController(store: store);
  runApp(SolvocaApp(controller: controller));
}
