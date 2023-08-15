import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool toggleValue = false;
  bool checkbox1Value = false;
  bool checkbox2Value = false;
  bool checkbox3Value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select View Model:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text(
                    'MVVM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: toggleValue,
                    onChanged: (newValue) {
                      setState(() {
                        toggleValue = newValue;
                      });
                    },
                  ),
                  const Text(
                    'RMMRVM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Checkboxes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Checkbox(
                    value: checkbox1Value,
                    onChanged: (newValue) {
                      setState(() {
                        checkbox1Value = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Snapdeal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: checkbox2Value,
                    onChanged: (newValue) {
                      setState(() {
                        checkbox2Value = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Flipkart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: checkbox3Value,
                    onChanged: (newValue) {
                      setState(() {
                        checkbox3Value = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Amazon',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // SizedBox(height: 10),
              ProductCard(
                title: 'Product 1',
                price: 'X Rs.',
                imageUrl:
                    'https://th.bing.com/th/id/OIP.WRHHphUndTOsyVfr-UtIDAHaDa?w=291&h=161&c=7&r=0&o=5&dpr=1.3&pid=1.7',
              ),
              ProductCard(
                title: 'Product 2',
                price: 'Y Rs.',
                imageUrl:
                    'https://th.bing.com/th/id/OIP.WRHHphUndTOsyVfr-UtIDAHaDa?w=291&h=161&c=7&r=0&o=5&dpr=1.3&pid=1.7',
              ),
              // You can add more ProductCard widgets here
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const ProductCard(
      {required this.title, required this.price, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: [
          Image.network(imageUrl,
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.3),
          ListTile(
            title: Text(title),
            subtitle: Text(price),
          ),
        ],
      ),
    );
  }
}
