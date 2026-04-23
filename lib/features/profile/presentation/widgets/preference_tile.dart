import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';

Widget buildPreferenceTile(String title, IconData icon, bool value, Function(bool) onChanged) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: Switch(value: value, onChanged: onChanged),
  );
}