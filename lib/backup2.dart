import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/ble-settings': (context) => BluetoothSettingsRoute(title: 'Bluetooth Settings'),
      },
      
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _ledState = false;

  void _incrementCounter() {
    setState(() {
      _ledState = !_ledState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Press to illuminate the LED on the MSP430',
            ),
            Text(
              '$_ledState',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              child: const Text('Open Bluetooth settings'),
              onPressed: (){
                  Navigator.pushNamed(context, '/ble-settings');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class BluetoothSettingsRoute extends StatefulWidget {
  BluetoothSettingsRoute({super.key, required this.title});
  final String title;
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  @override
  State<BluetoothSettingsRoute> createState() => _BluetoothSettingsRouteState();
}

class _BluetoothSettingsRouteState extends State<BluetoothSettingsRoute> {

  void _scanDevices(){
    //do Something
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          /*children: <Widget>[
            const Text(
              'Welcome to the Bluetooth Settings Page',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              child: const Text('Return To HomePage'),
              onPressed: (){
                // Navigate to second screen When Pressed
                Navigator.pop(context);
              },
            ),
          ], */
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanDevices,
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}