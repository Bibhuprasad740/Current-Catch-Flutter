import 'package:flutter/material.dart';
import 'package:news/resources/network_helper.dart';
import 'package:news/screens/news_details_screen.dart';
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

  // List of countries with their codes
  final List<Map<String, String>> _countries = [
    {'code': 'in', 'name': 'India'},
    {'code': 'us', 'name': 'United States'},
    {'code': 'pk', 'name': 'Pakistan'},
    {'code': 'il', 'name': 'Israel'},
    {'code': 'ru', 'name': 'Russia'},
    {'code': 'bd', 'name': 'Bangladesh'},
    {'code': 'cn', 'name': 'China'},
    {'code': 'ca', 'name': 'Canada'},
    {'code': 'fr', 'name': 'France'},
    {'code': 'ir', 'name': 'Iran'},
    {'code': 'gb', 'name': 'United Kingdom'},
    {'code': 'au', 'name': 'Australia'},
    {'code': 'de', 'name': 'Germany'},
    {'code': 'jp', 'name': 'Japan'},
  ];

  List<dynamic> _newsList = [];
  bool _isLoading = false;
  String _currentCategory = 'world_affairs';
  String _currentCountry = 'us'; // Default to United States
  int _currentPage = 1;

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

  Future<void> _fetchNews({int page = 1}) async {
    try {
      print('Starting to fetch news');
      final category = _newsCategories.firstWhere(
        (cat) => cat['key'] == _currentCategory,
        orElse: () => _newsCategories[0],
      );

      setState(() {
        _isLoading = true;
        _currentPage = page;
      });

      final response = await helper.fetchResponse(
        searchString: category['searchQuery']!,
        page: page,
        countryCode: _currentCountry, // Pass the country code
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
          content:
              Text('No news data available for this category and country.'),
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
      _currentPage = 1;
      _newsList.clear(); // Clear current news list
    });
    _fetchNews();
  }

  void _selectCountry(String countryCode) {
    setState(() {
      _currentCountry = countryCode;
      _currentPage = 1;
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
            _buildCountrySelector(),
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
            _buildPaginationControls(),
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

  Widget _buildCountrySelector() {
    return GestureDetector(
      onTap: _showCountrySelectionModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Image.asset(
              'assets/images/${_currentCountry}.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Text(
              _countries.firstWhere(
                  (country) => country['code'] == _currentCountry)['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showCountrySelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Select Country',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _countries.length,
                      itemBuilder: (context, index) {
                        final country = _countries[index];
                        return GestureDetector(
                          onTap: () {
                            _selectCountry(country['code']!);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentCountry == country['code']
                                  ? Colors.blue[900]
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/${country['code']}.png',
                                  width: 60,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  country['name']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _currentCountry == country['code']
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          onTap: () {
            Navigator.of(context).pushReplacementNamed(
                NewsDetailsScreen.routeName,
                arguments: {newsItem});
          },
          article: newsItem,
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1
                ? () => _fetchNews(page: _currentPage - 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 5),
                Text('Previous'),
              ],
            ),
          ),
          Text(
            'Page $_currentPage',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          ElevatedButton(
            onPressed: _newsList.isNotEmpty
                ? () => _fetchNews(page: _currentPage + 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
            ),
            child: const Row(
              children: [
                Text('Next'),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
