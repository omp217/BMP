import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';


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
  final String category;
  final String platform;
  final String rating;
  final double discount;

  Product({
    required this.title,
    required this.price,
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
  bool isLoading = false; // New variable to track loading state


  List<Product> products = [];
  Duration? timeTakenV;
  int? bytesReceivedV;
  int? bytesReceivedR;
  Duration? timeTakenR;
  DateTime? requestTimestamp;
  int? MVVM_length;
  int? RMVRVM_length;

  Future<void> fetchDataR() async {
    String url = 'https://ecommerce-v1-api.onrender.com';
    var requestedCat = 0;
    var requestedPat = 0;

    if (men) requestedCat = requestedCat + 1;
    if (women) requestedCat = requestedCat + 2;

    if (amazon) requestedPat = requestedPat + 1;
    if (flipkart) requestedPat = requestedPat + 2;
    if (snapdeal) requestedPat = requestedPat + 4;

    url = url + '/' + requestedCat.toString() + '/' + requestedPat.toString();
    requestTimestamp = DateTime.now();

    final response = await http.get(Uri.parse(url));

    bytesReceivedR = response.contentLength;
    if (requestTimestamp != null) {
      timeTakenR = DateTime.now().difference(requestTimestamp!);
    }
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        products = List<Product>.from(jsonData.map((data) {
          String new_rating = data['rating'].toString();
          RMVRVM_length = jsonData.length;
          return Product(
            title: data['title'],
            platform: data['platform'],
            category: data['category'],
            rating: new_rating,
            discount: data['discount'].toDouble(),
            price: data['price'],
          );
        }));
      });
    }
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> fetchDataV() async {
    String url = 'https://ecommerce-v1-api.onrender.com/';

    requestTimestamp = DateTime.now();
    final response = await http.get(Uri.parse(url));

    bytesReceivedV = response.contentLength;

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> results = [];
      List<String> categoryarray = [];
      List<String> platformarray = [];

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
      for (var i = 0; i < jsonData.length; i++) {
        if (categoryarray.contains(jsonData[i]['category']) &&
            platformarray.contains(jsonData[i]['platform'])) {
          results.add(jsonData[i]);
        }
      }
      MVVM_length = jsonData.length;
      results = results
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

      results.sort((a, b) =>
          (a['price'] as Comparable).compareTo(b['price']));

      if (requestTimestamp != null) {
        timeTakenV = DateTime.now().difference(requestTimestamp!);
      }

      setState(() {
        products = List<Product>.from(results.map((data) {
          return Product(
            title: data['title'],
            platform: data['platform'],
            category: data['category'],
            rating: data['rating'],
            discount: data['discount'].toDouble(),
            price: data['price'],
          );
        }));
      });
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
            Text('Total number of products received from RMVRVM model' + ' : ' + RMVRVM_length.toString() + '.'),
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
      bytesReceivedR = null;
      timeTakenR = null;
    });
  }

Future<void> fetchData() async {
  setState(() {
    isLoading = true; // Show loading indicator
  });

  bool isConnected = await checkInternetConnectivity();

  if (!isConnected) {
    setState(() {
      isLoading = false; // Hide loading indicator
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
  await fetchDataR();
  await fetchDataV();
  setState(() {
    isLoading = false; // Hide loading indicator
  });
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
                const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(
                      color: Colors.black,
                      style: BorderStyle.solid,
                      width: 2, // Increase border width
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0:  IntrinsicColumnWidth(),
                      1:  IntrinsicColumnWidth(),
                      2:  IntrinsicColumnWidth(),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                        children: const [
                            TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(5.0), // Add padding
                              child: Center(child: Text(' ')),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(5.0), // Add padding
                              child: Center(child: Text('MVVM')),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(3.0), // Add padding
                              child: Center(child: Text('RMVRVM')),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children:  [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(5.0), // Add padding
                              child: Text('Response Time (ms)'),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0), // Add padding
                              child: Center(
                                child: 
                                isLoading ? // Show loading indicator
                                  Text(''
                                  )
                                :
                                Text(
                                  timeTakenV?.inMilliseconds.toString() ?? '',
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0), // Add padding
                              child: Center(
                                child: 
                                  isLoading ? // Show loading indicator
                                  Text(''
                                  )
                                :
                                Text(
                                  timeTakenR?.inMilliseconds.toString() ?? '',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(5.0), // Add padding
                              child: Text('Data Transfer (bytes)'),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0), // Add padding
                              child: Center(
                                child: 
                                  //show nothing if loading
                                  isLoading ? // Show loading indicator
                                  Text(''
                                  )
                                :
                                Text(
                                  bytesReceivedV?.toString() ?? '',
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0), // Add padding
                              child: Center(
                                child:
                                 isLoading ? // Show loading indicator
                                  Text(''
                                  )
                                :
                                 Text(
                                  bytesReceivedR?.toString() ?? '',
                                ),
                              ),
                            ),
                          ),
                        ],
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
                children: products.map((product) {
                  return ProductCard(
                    product: product,
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
