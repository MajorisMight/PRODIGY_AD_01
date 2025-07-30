import 'package:flutter/material.dart';
import 'package:lalcucator/view/pages/calculator.dart';
import 'package:lalcucator/view/pages/history_page.dart';
import '/data/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// List<Widget> pages = [Calc(), Tictactoe(), Todo()];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('DiviDead'),

            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  );
                },
                icon: Icon(Icons.history),
              ),

              IconButton(
                padding: EdgeInsets.all(10),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  lightmode.value = !lightmode.value;
                  await prefs.setBool('themeModeKey', lightmode.value);
                },
                icon: ValueListenableBuilder(
                  valueListenable: lightmode,
                  builder: (context, lightmode, child) {
                    return Icon(lightmode ? Icons.dark_mode : Icons.light_mode);
                  },
                ),
              ),
            ],
          ),
          body: Calc(),
          // bottomNavigationBar: NavBar(),
        );
      },
    );
  }
}
