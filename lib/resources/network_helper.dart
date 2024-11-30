import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

String apiKey = 'pub_291781a64e11f885397c5e924b3d23adae6a6';
String baseUrl = 'https://newsdata.io/api/1/latest';
String country = 'us';
String language = 'en';
String category = 'politics,world';

class NetworkHelper {
  // Helper function to generate a cache key based on searchString and page
  String _generateCacheKey(String type, String searchString, int page) {
    return '$type|$searchString|$page';
  }

  // Fetch value from local storage
  Future<dynamic> _getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(key);

    if (cachedData != null) {
      return json.decode(cachedData);
    }

    return null;
  }

  // Save value to local storage
  Future<void> _saveCache(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
  }

  Future<Map<String, dynamic>> fetchResponse({
    String searchString = 'World Affairs',
    int page = 1,
  }) async {
    print('Start of fetch response');
    // Generate cache key for this request
    final String cacheKey = _generateCacheKey('data', searchString, page);
    print('Cache key generated: $cacheKey');

    // Try fetching cached data from local storage
    final cachedResponse = await _getCache(cacheKey);
    if (cachedResponse != null) {
      print('Returning cached data for: $cacheKey');
      return {'data': cachedResponse};
    }
    print('No cached data found for: $cacheKey');

    String url =
        '$baseUrl?q=$searchString&apikey=$apiKey&category=$category&country=$country';
    if (page > 1) {
      url += '&page=$page';
    }

    print('Fetching data from: $url');

    try {
      final Response response = await Dio().get(url);

      if (response.statusCode == 200) {
        log('Data fetched successfully for: $searchString');

        final List<dynamic> results = response.data['results'];

        // Save the fetched data to local storage
        await _saveCache(cacheKey, results);

        return {
          'data': results,
        };
      } else {
        print('Error: Unexpected status code ${response.statusCode}');
        return {
          'data': [],
        };
      }
    } on DioError catch (dioError) {
      print('DioError occurred: ${dioError.message}');
      if (dioError.response != null) {
        print('Response data: ${dioError.response?.data}');
        print('Status code: ${dioError.response?.statusCode}');
      }
      return {
        'data': [],
      };
    } catch (error) {
      print('An unexpected error occurred: $error');
      return {
        'data': [],
      };
    }
  }

  // Optional: Method to clear all cached data from local storage
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
