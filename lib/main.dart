import 'dart:io';
import 'dart:async';

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

      /*
        The StreamBuilder widget is used here as it will listen for events flowing in from the streams
        And will rebuild descendents for each new event. In this case we are using the state of the 
        FlutterBluePlus Instance as the stream. We're able to provide an initial state of "unknown" which 
        will determine how the app's default state.
          
      */
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (context, snapshot) {
            final btState = snapshot.data;
            if (btState != BluetoothState.on) {
              return BTOffScreen(btState: btState);
            }
            return const ConnectionScreen();
            //return BTOffScreen(btState: btState);
          }),
    );
  }
}

class BTOffScreen extends StatefulWidget {
  const BTOffScreen({Key? key, this.btState}) : super(key: key);
  final BluetoothState? btState;

  @override
  State<BTOffScreen> createState() => _BTOffScreenState();
}

class _BTOffScreenState extends State<BTOffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              // This will update the icon based on the current state of the bluetooth adapter
              (widget.btState == BluetoothState.on)
                  ? Icons.bluetooth
                  : (widget.btState == BluetoothState.turningOn)
                      ? Icons.more_horiz
                      : Icons.bluetooth_disabled,

              color: Colors.white70,
              size: 200,
            ),

            // This will pull the state and print this information to the screen
            Text(
                'Bluetooth is Currently ${widget.btState != null ? widget.btState.toString().substring(15) : ' - Bluetooth'}.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),

            //  Flutter Blue Plus is only Capable of changing the state of the bluetooth adapter
            //  on android, so if the user is on Android we'll provide a button capable of turning
            //  the bluetooth on, and if the user is on any other platform we'll simple ask the
            //  user to enable bluetooth
            if (Platform.isAndroid) ...[
              Container(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(30),
                    backgroundColor: Colors.green[400]),
                  child: Text('Turn On Bluetooth',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white)),
                  onPressed: () {
                    FlutterBluePlus.instance.turnOn();
                  },
                ),
              )
            ] else ...[
              Text('Please Enable Bluetooth',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.white70)),
            ]
          ],
        ),
      ),
    );
  }
}

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  List<Widget> btDeviceContainer = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Screen'),
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance
            .startScan(timeout: const Duration(seconds: 4)),
        child: ListView(
          children: [
            Text('Connected Devices',
                style: Theme.of(context).textTheme.titleLarge),

            // Uses a stream builder to update the list, with a period of checking for a connected device every 2 seconds
            //
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 2))
                  .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
              initialData: const [],
              builder: (context, snapshot) => Column(
                children: snapshot.data!
                    .map((device) => ListTile(
                          title: Text(device.name),
                          subtitle: Text(device.id.toString()),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: device.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (context, snapshot) {
                              if (snapshot.data ==
                                  BluetoothDeviceState.connected) {
                                return ElevatedButton(
                                    child: const Text('OPEN'),
                                    onPressed: () async {
                                      /*
                                      Navigator.pushReplacementNamed(
                                          context, '/MainScreen');
                                          */
                                      Navigator.pushReplacement(context,
                                              MaterialPageRoute (builder: (context) {return MainScreen(
                                                title: 'lms',
                                                device:device
                                              );})
                                            );
                                    });
                              }
                              return Text(
                                  snapshot.data.toString().substring(15));
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),

            Text('Available Devices',
                style: Theme.of(context).textTheme.titleLarge),

            StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (context, snapshot) => Column(
                      children: snapshot.data!
                          .map((result) => ListTile(
                                title: Text(result.device.name),
                                subtitle: Text(result.device.id.toString()),
                                trailing: StreamBuilder<BluetoothDeviceState>(
                                  stream: result.device.state,
                                  initialData:
                                      BluetoothDeviceState.disconnected,
                                  builder: (context, snapshot) {
                                    if (snapshot.data !=
                                        BluetoothDeviceState.connected) {
                                      return ElevatedButton(
                                          child: const Text('Connect'),
                                          onPressed: () {
                                            result.device.connect();
                                            /*Navigator.pushReplacementNamed(
                                                context, 
                                                '/MainScreen',);
                                            */
                                            Navigator.pushReplacement(context,
                                              MaterialPageRoute (builder: (context) {return MainScreen(
                                                title: 'lms',
                                                device:result.device
                                              );})
                                            );


                                          });
                                    }
                                    return Text(
                                        snapshot.data.toString().substring(21));
                                  },
                                ),
                              ))
                          .toList(),
                    ))
          ],
        ),
        
      ),
    );
    /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
       */ // This trailing comma makes auto-formatting nicer for build methods.
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title, required this.device});
  final String title;
  final BluetoothDevice device;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //Timer _mvTimer;
  bool _motorOn = false;
  int _rollerValue = 50;
  late BluetoothCharacteristic serialCharacteristic;


  void _updateRoller(int sign) {
    setState(() {
      if (sign == 1 && _rollerValue != 100 ) {
        _rollerValue += sign * 1;
        _sendRollerData();

      }
      else if (sign == -1 && _rollerValue!= 0) {
        _rollerValue += sign * 1;
        _sendRollerData();
      }
    });
  }

  Future<void> _sendRollerData() async {
    //await serialCharacteristic.write([0x62]);
    await serialCharacteristic.write('\x01R$_rollerValue\x00'.codeUnits);
    print('\x01R$_rollerValue\x00');
    //await serialCharacteristic.write([98]);
  }

  Future<void> _sendMotorOn() async {
    await serialCharacteristic.write('\x01C$_motorOn\x00'.codeUnits);
    print('\x01C$_motorOn\x00');
  }
  
  String get16BitUUID(inputguid) {
    return inputguid.toString().substring(4,8);
  }

  Future<void> _findServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      //print('service UUID');
      //print(get16BitUUID(service.uuid));
      for(BluetoothCharacteristic c in service.characteristics){
        //print('Characteristic');
        //print(get16BitUUID(c.uuid));

        if(get16BitUUID(c.uuid) == "ffe1"){
          //print("IO found");
          serialCharacteristic = c;
        }
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // do something
      Future.delayed(const Duration(milliseconds: 1000), () {_findServices();});
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text('Motor Speed',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.apply(fontWeightDelta: 1)),
            ElevatedButton(
              child: const Icon(
                Icons.arrow_drop_up,
                color: Colors.white,
                size: 100,
              ),
              onPressed: () {
                _updateRoller(1);
              },
            ),
            Text('$_rollerValue %',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.apply(fontWeightDelta: 3)),
            ElevatedButton(
              child: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 100,
              ),
              onPressed: () {
                _updateRoller(-1);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Motor Power',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.apply(fontWeightDelta: 1)),
                Transform.scale(scale: 2.5,
                  child: Switch(
                    value: _motorOn,
                    onChanged: (bool value) {
                      setState(() {
                        _motorOn = value;
                        _sendMotorOn();
                      });
                    },
                  ),
                ),
              ],),

            
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _UpdateRoller(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
