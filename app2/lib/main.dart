import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Product {
  final String id;
  final String title;
  final int price;
  final String category;
  final String platform;
  final String rating;
  final double discount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.platform,
    required this.rating,
    required this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'category': category,
      'platform': platform,
      'rating': rating,
      'discount': discount,
    };
  }

}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

Future<void> _createDatabase(Database db, int version) async {
    // Create your table here, using the Product data model
    await db.execute('''
      CREATE TABLE product (
        id TEXT PRIMARY KEY,
        title TEXT,
        price INTEGER,
        category TEXT,
        platform TEXT,
        rating TEXT,
        discount REAL
      )
    ''');
  }

  //create insert function
  Future<int> insert(Product product) async {
    Database db = await instance.database;
    return await db.insert('product', product.toMap());
  }


}

class _MyHomePageState extends State<MyHomePage> {
  bool model = false;
  bool snapdeal = false;
  bool flipkart = false;
  bool amazon = false;
  bool men = false;
  bool women = false;
  bool isLoading = false; // New variable to track loading state


  List<Product> products = [];
  Duration? timeTakenV;
  int? bytesReceivedV;
  DateTime? requestTimestamp;
  int? MVVM_length;


  Future<void> fetchDataV() async {
    String url = 'https://ecommerce-v1-api.onrender.com/';

    requestTimestamp = DateTime.now();
    final response = await http.get(Uri.parse(url));

    bytesReceivedV = response.contentLength;

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<dynamic> results = [];
      results = jsonData
          .map((product) {
            double rating = (5.0 * product['five_star'] +
                    4.0 * product['four_star'] +
                    3.0 * product['three_star'] +
                    2.0 * product['two_star'] +
                    1.0 * product['one_star']) /
                (product['five_star'] +
                    product['four_star'] +
                    product['three_star'] +
                    product['two_star'] +
                    product['one_star']);
            product['rating'] = rating.toStringAsFixed(1);
            return product;
          })
          .toList();

      for (var i = 0; i < results.length; i++) {
        Product product = Product(
          id: results[i]['_id'],
          title: results[i]['title'],
          platform: results[i]['platform'],
          category: results[i]['category'],
          rating: results[i]['rating'],
          discount: results[i]['discount'].toDouble(),
          price: results[i]['price'],
        );
        await DatabaseHelper.instance.insert(product);
      }

      print('Data added to db');
    }
  }


void _showInfoPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Adjust as needed
          crossAxisAlignment: CrossAxisAlignment.start, // Adjust as needed
          children: <Widget>[
            Text('Total number of products in the database:' + MVVM_length.toString() + '.'),
            Text('Total number of attributes in each product:' + '11' + '.'),
            Text('Number of attribute displayed in the app:' + '6' + '.'),
            Text('Total number of products received from MVVM model' + ' : ' + MVVM_length.toString() + '.'),
            Text('Display Method: sorted with ascending price of the product.'),
            // Add more rows and columns as needed
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  void clearData() {
    setState(() {
      snapdeal = false;
      flipkart = false;
      amazon = false;
      men = false;
      women = false;
      products.clear();
      timeTakenV = null;
      bytesReceivedV = null;
    });
    //clear the database
    DatabaseHelper.instance.database.then((db) {
      db.delete('product');
    });
  }

Future<void> fetchData() async {
  setState(() {
    isLoading = true; // Show loading indicator
  });

  final connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    setState(() {
      isLoading = false; // Hide loading indicator
    });
    showDialog(
      context: this.context,
      builder: ( context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('No internet connection available.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  await fetchDataV();
  setState(() {
    isLoading = false; // Hide loading indicator
  });
}

//create a function to get data from database
Future<List<Product>> getProducts() async {
  Database db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> products = await db.query('product');
      List<Product> results = [];
      List<String> categoryarray = [];
      List<String> platformarray = [];

      //convert products to product array list
      List<Product> productsList = products.map((product) {
        return Product(
          id: product['id'],
          title: product['title'],
          platform: product['platform'],
          category: product['category'],
          rating: product['rating'],
          discount: product['discount'],
          price: product['price'],
        );
      }).toList();

      if (men) categoryarray.add("Men");
      if (women) categoryarray.add("Women");

      if (categoryarray.isEmpty) {
        categoryarray.add("Men");
        categoryarray.add("Women");
      }
      if (amazon) platformarray.add("Amazon");
      if (flipkart) platformarray.add("Flipkart");
      if (snapdeal) platformarray.add("Snapdeal");

      if (platformarray.isEmpty) {
        platformarray.add("Amazon");
        platformarray.add("Flipkart");
        platformarray.add("Snapdeal");
      }
      for (var i = 0; i < productsList.length; i++) {
        if (categoryarray.contains(productsList[i].category) &&
            platformarray.contains(productsList[i].platform)) {
          results.add(productsList[i]);
        }
      }
      results.sort((a, b) =>
          (a.price as Comparable).compareTo(b.price));

      return results;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                  ElevatedButton(
                    onPressed: () {
                      fetchData();
                    },
                    child: const Text(
                      'Go',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showInfoPopup(context); // Open information popup
                    },
                    child: const Text(
                      'Info',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: clearData, // Call the clearData function
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ],
                ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0), // Add padding on top
                  child: Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Show loading indicator
               isLoading ? // Show loading indicator
                    const Center(child: CircularProgressIndicator(),)
                :
              Column(
                children: [
                  FutureBuilder<List<Product>>(
                    future: getProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data!.map((product) {
                            return ProductCard(
                              product: product,
                            );
                          }).toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Price: \$${product.price.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Discount: ${product.discount.toString()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Rating: ${product.rating}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Category: ${product.category}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Platform: ${product.platform}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
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