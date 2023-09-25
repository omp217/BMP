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

  Future<int> insert(Product product) async {
    Database db = await instance.database;
    return await db.insert('product', product.toMap());
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  List<Product> products = [];

  void clearData() {
    setState(() {
      products.clear();
    });
    DatabaseHelper.instance.database.then((db) {
      db.delete('product');
    });
  }

  Future<void> fetchData() async {

    final Connectivity _connectivity = Connectivity();
    final ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('No Internet Connection'),
        ),
      );
      return;
    }
    clearData();
    String url = 'https://ecommerce-v1-api.onrender.com/app2';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> results = [];

      results = jsonData
          .map((product) {
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Product>> getProducts() async {
    if (products.isNotEmpty) {
      return products;
    }
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> productsFromDB = await db.query('product');

    List<Product> results = productsFromDB.map((product) {
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

    setState(() {
      products = results;
    });
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
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          getProducts();
                        },
                        child: const Text(
                          'Show',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          fetchData();
                        },
                        child: const Text(
                          'Fetch',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showInfoPopup(context);
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
                        onPressed: clearData,
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
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        if (products.isNotEmpty)
                          Column(
                            children: products.map((product) {
                              return ProductCard(
                                product: product,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Total number of attributes in each product:11.'),
              Text('Number of attributes displayed in the app:6.'),
              Text('Display Method: sorted with ascending price of the product.'),
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
