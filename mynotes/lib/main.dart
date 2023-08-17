import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

class Product {
  final String title;
  final int price;
  final String imageUrl;
  final String category;
  final String platform;
  final String rating;
  final double discount;


  Product({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.platform,
    required this.rating,
    required this.discount,

  });
}

class _MyHomePageState extends State<MyHomePage> {
  bool model = false;
  bool snapdeal = false;
  bool flipkart = false;
  bool amazon = false;
  bool men = false;
  bool women = false;

  List<Product> products = [];
  Duration? timeTaken;
  int? bytesSent;
  int? bytesReceived;
  DateTime? requestTimestamp;

  Future<void> fetchDataR() async {
    // Construct the API URL based on the selected checkboxes
    String url = 'http://10.200.35.151:3000';
    // const Categories = ['Men','Women'];
    // const Platforms = ['Amazon','Flipkart','Snapdeal'];

    var requestedCat = 0;
    var requestedPat = 0;

    //run for loop for categories
    if(men) requestedCat = requestedCat + 1;
    if(women) requestedCat = requestedCat + 2;

    if(amazon) requestedPat = requestedPat + 1;
    if(flipkart) requestedPat = requestedPat + 2;
    if(snapdeal) requestedPat = requestedPat + 4;

    url = url +'/' + requestedCat.toString() + '/' + requestedPat.toString();
    requestTimestamp = DateTime.now();
    final response = await http.get(Uri.parse(url));

    bytesSent = response.request!.contentLength;
    bytesReceived = response.contentLength;
    if (requestTimestamp != null) {
      timeTaken = DateTime.now().difference(requestTimestamp!);
    }
    if (response.statusCode == 200) {
      // Parse the JSON response and populate the products list
      final jsonData = json.decode(response.body);
      setState(() {
        products = List<Product>.from(jsonData.map((data) {
          String new_rating = data['rating'].toString();

          return Product(
            title: data['title'],
            platform: data['platform'],
            category: data['category'],
            rating: new_rating,
            discount: data['discount'].toDouble(),
            price: data['price'],
            imageUrl: data['imageurl'],
          );
        }));
      });
    }
  }


  Future<void> fetchDataV() async {
    String url = 'http://10.200.35.151:3000/';

    requestTimestamp = DateTime.now();
    
    final response = await http.get(Uri.parse(url));

    bytesSent = response.request!.contentLength;
    bytesReceived = response.contentLength;
    if (requestTimestamp != null) {
      timeTaken = DateTime.now().difference(requestTimestamp!);
    }
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<dynamic> results = [];
      List<String> categoryarray = [];
      List<String> platformarray = [];

      if(men) categoryarray.add("Men");
      if(women) categoryarray.add("Women");

      if(categoryarray.length == 0){
        categoryarray.add("Men");
        categoryarray.add("Women");
      }
      if(amazon) platformarray.add("Amazon");
      if(flipkart) platformarray.add("Flipkart");
      if(snapdeal) platformarray.add("Snapdeal");

      if(platformarray.length == 0){
        platformarray.add("Amazon");
        platformarray.add("Flipkart");
        platformarray.add("Snapdeal");
      }
      //iterate over the json data and filter according to the selected checkboxes & push the whole object
      for (var i = 0; i < jsonData.length; i++) {
        if(categoryarray.contains(jsonData[i]['category']) && platformarray.contains(jsonData[i]['platform'])) {
          results.add(jsonData[i]);
        }
      }

    results = results.map((product) {
      double rating = (5.0 * product['five_star'] + 4.0 * product['four_star'] +
          3.0 * product['three_star'] + 2.0 * product['two_star'] +
          1.0 * product['one_star']) /
          (product['five_star'] +
              product['four_star'] +
              product['three_star'] +
              product['two_star'] +
              product['one_star']);
      product['rating'] = rating.toStringAsFixed(1);
      return product;
    }).toList();

    results.sort((a, b) => (b['discount'] as Comparable).compareTo(a['discount']));

      setState(() {
        products = List<Product>.from(results.map((data) {
          return Product(
            title: data['title'],
            platform: data['platform'],
            imageUrl: data['imageurl'] ,
            category: data['category'],
            rating: data['rating'],
            discount: data['discount'].toDouble(),
            price: data['price'],
          );
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select View Model:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text(
                    'MVVM',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Checkbox(
                    value: flipkart,
                    onChanged: (newValue) {
                      setState(() {
                        flipkart = newValue!;
                      });
                    },
                  ),
                  const Text(
                    'Flipkart',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
              ElevatedButton(
                onPressed: () {
                  if(model) fetchDataR();
                  else fetchDataV();
                },
                child: Text('Go',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (timeTaken != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Time Taken: ${timeTaken!.inMilliseconds} ms'),
                          Text('Bytes Received: $bytesReceived'),
                        ],
                      ),
                    ],
                  ],
                ),
                ],
          ),
              Column(
                children: products.map((product) {
                  return ProductCard(
                    title: product.title,
                    price: product.price,
                    imageUrl: product.imageUrl,
                    discount: product.discount,
                    rating: product.rating,
                    category: product.category,
                    platform: product.platform,
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
  final int price;
  final String imageUrl;
  final double discount;
  final String rating;
  final String category;
  final String platform;

  ProductCard({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.discount,
    required this.rating,
    required this.category,
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add some padding
        child: Row(
          children: [
            // Image on the left side
            Image.network(
              imageUrl,
              width: 80, // Set your desired width for the image
              height: 80, // Set your desired height for the image
            ),
            SizedBox(width: 10), // Add spacing between image and content
            // Content on the right side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5), // Add some vertical spacing
                  Text(
                    'Price: \$${price.toString()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Discount: ${discount.toString()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue, // Or any desired color
                    ),
                  ),
                  Text(
                    'Rating: $rating',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange, // Or any desired color
                    ),
                  ),
                  Text(
                    'Category: $category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green, // Or any desired color
                    ),
                  ),
                  Text(
                    'Platform: $platform',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple, // Or any desired color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
