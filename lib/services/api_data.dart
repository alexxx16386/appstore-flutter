import 'dart:convert';

import 'package:appstore/constants.dart';
import 'package:appstore/models/cart_product.dart';
import 'package:appstore/models/category.dart';
import 'package:appstore/models/product.dart';
import 'package:appstore/models/product_image.dart';
import 'package:appstore/models/review.dart';
import 'package:appstore/models/user.dart';
import 'package:http/http.dart' as http;

import '../auth_config.dart';

Future<List<Product>> getAllProducts() async {
  var url = Uri.parse('$SERVER_URL/api/products');
  final response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'text/html; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    List<Product> products =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => Product.fromJson(data))
            .toList();
    return products;
  } else {
    throw Exception('Failed to load');
  }
}

Future<List<Category>> getCategories() async {
  var url = Uri.parse('$SERVER_URL/api/category');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    List<Category> categories =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => Category.fromJson(data))
            .toList();
    return categories;
  } else {
    throw Exception('Failed to load');
  }
}

Future<List<Product>> getCategoryProducts(String category) async {
  var url = Uri.parse('$SERVER_URL/api/category/$category');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    List<Product> products =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => Product.fromJson(data))
            .toList();
    return products;
  } else {
    throw Exception('Failed to load');
  }
}

Future<List<Product>> getFavorites() async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/favorites');
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    List<Product> products =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => Product.fromJson(data))
            .toList();
    return products;
  } else {
    throw Exception('Failed to load');
  }
}

Future<Product> getProduct(int id) async {
  var url = Uri.parse('$SERVER_URL/api/products/$id');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    var product =
        Product.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    return product;
  } else {
    throw Exception('Failed to load');
  }
}

Future<UserModel> getInfoMe() async {
  await AuthConfig().init();
  print(1);
  if (!AuthConfig.isAuthorize) {
    print('object');
    throw Exception('Unauthorized');
  }
  print('ok');
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  print(headers.toString());
  var url = Uri.parse('$SERVER_URL/api/auth/users/me/');
  var response = await http.get(url, headers: headers);
  print(2);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    var user = UserModel.fromJson(jsonResponse);
    AuthConfig().setUser(user);
    print(jsonResponse);
    return user;
  } else if (response.statusCode == 401) {
    kStorage.delete(key: 'authToken');
    AuthConfig().init();
    throw Exception('Unauthorized');
  } else {
    throw Exception('Failed to load');
  }
}

Future<int> logIn(String username, String password) async {
  Map body = {"username": username, "password": password};
  var url = Uri.parse('$SERVER_URL/api/auth/token/login');
  final response = await http.post(url, body: body);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    print(jsonResponse['auth_token']);
    kStorage.write(key: 'authToken', value: jsonResponse['auth_token']);
    await AuthConfig().init();
    return response.statusCode;
  } else {
    throw Exception('Failed to load');
  }
}

Future<int> register(
  String username,
  String password,
  String firstName,
  String lastName,
  String email,
) async {
  Map body = {
    "username": username,
    "password": password,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
  };
  var url = Uri.parse('$SERVER_URL/api/auth/users/');
  final response = await http.post(url, body: body);
  if (response.statusCode != 201) {
    throw Exception('Failed to load');
  } else {
    if (await logIn(username, password) != 200) {
      throw Exception('Failed to load');
    }
    return response.statusCode;
  }
}

Future<UserModel> getMe() async {
  var url = Uri.parse('$SERVER_URL/api/auth/users/me/');
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    var user = UserModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    return user;
  } else {
    throw Exception('Failed to load');
  }
}

Future<List<CartProduct>> getCartProducts() async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/cart');
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    List<CartProduct> cartProducts =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => CartProduct.fromJson(data))
            .toList();
    return cartProducts;
  } else {
    throw Exception('Failed to load');
  }
}

Future<int> changeCartProductCount(int count, int id) async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var body = jsonEncode({"count": count});
  var url = Uri.parse('$SERVER_URL/api/cart/$id');
  final response = await http.put(url, headers: headers, body: body);
  return response.statusCode;
}

Future<int> addCartProduct(int id) async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/cart/$id');
  final response = await http.post(url, headers: headers);
  return response.statusCode;
}

Future<int> deleteCartProduct(int id) async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/cart/$id');
  final response = await http.delete(url, headers: headers);
  return response.statusCode;
}

Future<int> checkLike(int id) async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/favorite/$id');
  final response = await http.get(url, headers: headers);
  return response.statusCode;
}

Future<int> setLike(int id) async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/favorite/$id');
  final response = await http.post(url, headers: headers);
  return response.statusCode;
}

Future<int> deleteLike(int id) async {
  var headers = {"Authorization": "Token ${AuthConfig.token}"};
  var url = Uri.parse('$SERVER_URL/api/favorite/$id');
  final response = await http.delete(url, headers: headers);
  return response.statusCode;
}

Future<List<ProductImage>> getProductImages(int id) async {
  var url = Uri.parse('$SERVER_URL/api/products/$id/images');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    List<ProductImage> images =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => ProductImage.fromJson(data))
            .toList();
    return images;
  } else {
    throw Exception('Failed to load');
  }
}

Future<List<Review>> getProductReviews(int id) async {
  var url = Uri.parse('$SERVER_URL/api/products/$id/reviews');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    List<Review> reviews =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => Review.fromJson(data))
            .toList();
    return reviews;
  } else {
    throw Exception('Failed to load');
  }
}

Future<List<Review>> getReplyReviews(int id) async {
  var url = Uri.parse('$SERVER_URL/api/reviews/$id');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    List<Review> reviews =
        (json.decode(utf8.decode(response.bodyBytes)) as List)
            .map((data) => Review.fromJson(data))
            .toList();
    return reviews;
  } else {
    throw Exception('Failed to load');
  }
}
