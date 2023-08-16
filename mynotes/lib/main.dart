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
  bool model = false;
  bool snapdeal = false;
  bool Flipkart= false;
  bool amazon = false;
  bool men = false;
  bool women = false;

  List<ProductCard> products = [
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
    // Add more Product objects here
  ];

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select View Model:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text(
                    'MVVM',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: model,
                    onChanged: (newValue) {
                      setState(() {
                        model = newValue;
                      });
                    },
                  ),
                  const Text(
                    'RMMRVM',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // const SizedBox(height: 5),
              // const Text(
              //   'Checkboxes:',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Checkbox(
                    value: snapdeal,
                    onChanged: (newValue) {
                      setState(() {
                        snapdeal = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Snapdeal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: Flipkart,
                    onChanged: (newValue) {
                      setState(() {
                        Flipkart = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Flipkart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: amazon,
                    onChanged: (newValue) {
                      setState(() {
                        amazon = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Amazon',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Checkbox(
                    value: men,
                    onChanged: (newValue) {
                      setState(() {
                        men = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Men',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: women,
                    onChanged: (newValue) {
                      setState(() {
                        women = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Women',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // SizedBox(height: 10),
              // const ProductCard(
              //   title: 'Product 1',
              //   price: 'X Rs.',
              //   imageUrl:
              //       'https://th.bing.com/th/id/OIP.WRHHphUndTOsyVfr-UtIDAHaDa?w=291&h=161&c=7&r=0&o=5&dpr=1.3&pid=1.7',
              // ),
              // const ProductCard(
              //   title: 'Product 2',
              //   price: 'Y Rs.',
              //   imageUrl:
              //       'https://th.bing.com/th/id/OIP.WRHHphUndTOsyVfr-UtIDAHaDa?w=291&h=161&c=7&r=0&o=5&dpr=1.3&pid=1.7',
              // ),
              // You can add more ProductCard widgets here
              Column(
                children: products.map((product) {
                  return ProductCard(
                    title: product.title,
                    price: product.price,
                    imageUrl: product.imageUrl,
                  );
                }).toList(),
              ),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Image on the left side
            Image.network(
              imageUrl,
              width: 100, // Set your desired width for the image
              height: 100, // Set your desired height for the image
            ),
            SizedBox(width: 10), // Add spacing between image and content
            // Content on the right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}