import 'package:finalproject/models/http_exception.dart';
import 'package:finalproject/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  List<Product> getCategoryItems(String category) {
    return _items.where((prodItem) => prodItem.category == category).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://finalproject-52a7e-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://finalproject-52a7e-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      //var nowTime = new DateTime.now();
      extractedData.forEach(
        (productId, productData) {
          loadedProducts.add(
            Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              imageUrl: productData['imageUrl'],
              originalPrice: productData['originalPrice'],
              dealPrice: productData['dealPrice'],
              date: productData['date'],
              creatorId: productData['creatorId'],
              category: productData['category'],
              isFavorite: favoriteData == null
                  ? false
                  : favoriteData[productId] ?? false,
            ),
          );
          //}
        },
      );
      _items = loadedProducts.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw (error);
      //print("Still needs to be handeld");
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://finalproject-52a7e-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'originalPrice': product.originalPrice,
          'dealPrice': product.dealPrice,
          'isFavorite': product.isFavorite,
          'date': product.date,
          'creatorId': userId,
          'category': product.category,
        }),
      );
      final newProduct = Product(
        title: product.title,
        dealPrice: product.dealPrice,
        originalPrice: product.originalPrice,
        description: product.description,
        date: product.date,
        imageUrl: product.imageUrl,
        category: product.category,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Product findByCategory(String category) {
    //didnt added to products overview yet
    return _items.firstWhere((prod) => prod.category == category);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://finalproject-52a7e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'originalPrice': newProduct.originalPrice,
            'dealPrice': newProduct.dealPrice,
            'date': newProduct.date,
            'category': newProduct.category,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://finalproject-52a7e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
