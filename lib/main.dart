import 'package:eth_counter_flutter_defulatapp/ethClient.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ethClient = EthClient();

  bool isReady = false;

  int counter = 0;

  @override
  void initState() {
    ethClient.init().then((v) => setState(() {
          isReady = true;
          getCounter();

          ethClient.listenToEvents().listen((event) {
            final decoded = ethClient.counterIncremented.decodeResults(event.topics!, event.data!);
            print(decoded);

            setState(() {
              counter = (decoded[0] as BigInt).toInt();
            });
          });
        }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isReady
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('You have pushed the button this many times:'),
                  Text('$counter', style: Theme.of(context).textTheme.headline4),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: increment,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  Future<int> getCounter() async {
    final response = await ethClient.readContract(ethClient.getCounter, []);
    assert(response.length == 1);
    final out = (((response)[0]) as BigInt).toInt();

    setState(() {
      counter = out;
    });
    print(out);

    return out;
  }

  Future increment() async {
    print('boo');
    await ethClient.writeContract(ethClient.increment, []);
  }
}
