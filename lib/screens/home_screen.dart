import 'package:flutter/material.dart';
import 'package:news/resources/network_helper.dart';
import 'package:news/widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _newsCategories = [
    {
      'key': 'world_affairs',
      'name': 'World Affairs',
      'searchQuery': 'International Relations'
    },
    {
      'key': 'geopolitics',
      'name': 'Geopolitics',
      'searchQuery': 'Global Geopolitics'
    },
    {
      'key': 'economic_policy',
      'name': 'Economic Policy',
      'searchQuery': 'Global Economic Trends'
    },
    {
      'key': 'stock_market',
      'name': 'Market Insights',
      'searchQuery': 'Global Stock Market Analysis'
    },
    {
      'key': 'trade_relations',
      'name': 'Trade Relations',
      'searchQuery': 'International Trade Dynamics'
    },
    {
      'key': 'central_banks',
      'name': 'Central Banks',
      'searchQuery': 'Global Central Bank Policies'
    },
  ];

  List<dynamic> _newsList = [];
  bool _isLoading = false;
  String _currentCategory = 'world_affairs';

  final helper = NetworkHelper();

  @override
  void initState() {
    super.initState();
    _clearLocalStorage();
    _fetchNews();
  }

  Future<void> _clearLocalStorage() async {
    await helper.clearCache();
  }

  Future<void> _fetchNews() async {
    try {
      print('Starting to fetch news');
      final category = _newsCategories.firstWhere(
        (cat) => cat['key'] == _currentCategory,
        orElse: () => _newsCategories[0],
      );

      setState(() {
        _isLoading = true;
      });

      final response = await helper.fetchResponse(
        searchString: category['searchQuery']!,
        page: 1, // Fetch all items without relying on pagination
      );

      final fetchedNews = response['data'];

      setState(() {
        _newsList = fetchedNews;
      });

      if (_newsList.isEmpty) {
        _showNoDataSnackBar();
      }
    } catch (error) {
      print('Error fetching news: $error');
      _showErrorSnackBar();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showNoDataSnackBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No news data available for this category.'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  void _showErrorSnackBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load news. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _selectCategory(String categoryKey) {
    setState(() {
      _currentCategory = categoryKey;
      _newsList.clear(); // Clear current news list
    });
    _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            _buildCategorySelector(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await helper.clearCache();
                        await _fetchNews();
                      },
                      child: _newsList.isEmpty
                          ? const Center(child: Text("No news available"))
                          : _buildNewsListView(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _newsCategories.length,
        itemBuilder: (context, index) {
          final category = _newsCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ChoiceChip(
              label: Text(category['name']!),
              selected: _currentCategory == category['key'],
              onSelected: (_) => _selectCategory(category['key']!),
              selectedColor: Colors.blue[900],
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(
                color: _currentCategory == category['key']
                    ? Colors.white
                    : Colors.white70,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5),
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        final newsItem = _newsList[index];
        return NewsCard(
          index: index + 1,
          onTap: () {}, // Handle article redirection
          article: newsItem,
        );
      },
    );
  }
}
