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
  // Helper function to generate a cache key based on type, searchString, and page
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

    // Generate cache keys for data and cursor
    final String dataCacheKey = _generateCacheKey('data', searchString, page);
    final String cursorCacheKey =
        _generateCacheKey('cursor', searchString, page);

    print('Data Cache key generated: $dataCacheKey');
    print('Cursor Cache key generated: $cursorCacheKey');

    // Check for cached data for the current page
    if (page > 1) {
      // Fetch cursor for the previous page
      final String prevCursorCacheKey =
          _generateCacheKey('cursor', searchString, page - 1);
      final prevCursor = await _getCache(prevCursorCacheKey);

      if (prevCursor == null) {
        print(
            'No cursor found for previous page. Cannot fetch data for page $page.');
        return {'data': []};
      }

      print('Cursor found for previous page: $prevCursor');
    }

    // Try fetching cached data for the current page
    final cachedResponse = await _getCache(dataCacheKey);
    if (cachedResponse != null) {
      print('Returning cached data for: $dataCacheKey');
      return {'data': cachedResponse};
    }
    print('No cached data found for: $dataCacheKey');

    String url =
        '$baseUrl?q=$searchString&apikey=$apiKey&category=$category&country=$country&language=$language';
    if (page > 1) {
      final String prevCursorCacheKey =
          _generateCacheKey('cursor', searchString, page - 1);
      final prevCursor = await _getCache(prevCursorCacheKey);
      if (prevCursor != null) {
        url += '&page=$prevCursor';
      }
    }

    print('Fetching data from: $url');

    try {
      final Response response = await Dio().get(url);

      if (response.statusCode == 200) {
        log('Data fetched successfully for: $searchString');

        final List<dynamic> results = response.data['results'];
        final String? nextCursor = response.data['nextPage'];

        // Save the fetched data and cursor to local storage
        await _saveCache(dataCacheKey, results);
        if (nextCursor != null) {
          await _saveCache(cursorCacheKey, nextCursor);
        }

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

  // Clear all cached data from local storage
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
