// lib/screens/home_page.dart

import 'package:amazon/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _productList = [];
  List<Product> _filteredProducts = [];
  int _page = 1;
  bool _isLoading = false;

  // Filter and sort variables
  String selectedCategory = 'All Categories';
  double minPrice = 0;
  double maxPrice = 1000;
  double selectedRating = 0;
  String sortCriteria = 'Price';
  String selectedPriceRange = 'All Prices';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Product> newProducts = await ApiService.fetchProducts();
      setState(() {
        _isLoading = false;
        _productList = newProducts;
        _filteredProducts = newProducts;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching products: $error');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _productList.where((product) {
        return (selectedCategory == 'All Categories' ||
                product.category == selectedCategory) &&
            (product.price >= minPrice && product.price <= maxPrice) &&
            (product.rating >= selectedRating);
      }).toList();
    });
  }

  void _sortProducts(String criteria) {
    setState(() {
      if (criteria == 'Price') {
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (criteria == 'Rating') {
        _filteredProducts.sort((a, b) => a.rating.compareTo(b.rating));
      }
    });
  }

  // Price range dropdown handling
  void _updatePriceRange(String priceRange) {
    setState(() {
      selectedPriceRange = priceRange;
      switch (priceRange) {
        case 'Under \$50':
          minPrice = 0;
          maxPrice = 50;
          break;
        case '\$50 - \$100':
          minPrice = 50;
          maxPrice = 100;
          break;
        case '\$100 - \$200':
          minPrice = 100;
          maxPrice = 200;
          break;
        case 'Above \$200':
          minPrice = 200;
          maxPrice = 1000; 
          break;
        default:
          minPrice = 0;
          maxPrice = 1000;
      }
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopify'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _filteredProducts = _productList
                      .where((product) => product.title
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: selectedCategory,
                  items: [
                    'All Categories',
                    'men\'s clothing',
                    'jewelery',
                    'electronics',
                    'women\'s clothing'
                  ].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      _filterProducts();
                    });
                  },
                ),
                DropdownButton<String>(
                  value: selectedPriceRange,
                  items: [
                    'All Prices',
                    'Under \$50',
                    '\$50 - \$100',
                    '\$100 - \$200',
                    'Above \$200'
                  ].map((String range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _updatePriceRange(value!);
                  },
                ),
                DropdownButton<double>(
                  value: selectedRating,
                  items: [0, 1, 2, 3, 4, 5].map((rating) {
                    return DropdownMenuItem<double>(
                      value: rating.toDouble(),
                      child: Text('$rating stars'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRating = value!;
                      _filterProducts();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty && !_isLoading
                ? Center(child: Text('No products found.'))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredProducts.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredProducts.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final product = _filteredProducts[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(productId: product.id),
                            ),
                          );
                        },
                        child: ProductCard(product: product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
