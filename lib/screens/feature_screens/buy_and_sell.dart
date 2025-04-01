import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../Database/Fav.dart';
import '../../Database/database.dart';
import '../../admin_panel/add_post.dart';
import '../../filter_class/price_range_class.dart';
import '../detailPage_screen.dart';

class BuyAndSell extends StatefulWidget {
  const BuyAndSell({super.key});

  @override
  State<BuyAndSell> createState() => _BuyAndSellState();
}

class _BuyAndSellState extends State<BuyAndSell> {
  final FavoriteManager _favoriteManager = FavoriteManager();
  final TextEditingController _searchController = TextEditingController();
  PriceRange? _selectedPriceRange;
  int _selectedIndex = -1;
  final Color selectedColor = const Color(0xFF6A1B9A); // Purple
  final Color unselectedColor = Colors.grey.shade200;
  final DataBaseStorage _dataBaseStorage = DataBaseStorage();
  final List<PriceRange> priceRanges = [
    PriceRange(start: 1000, end: 5000),
    PriceRange(start: 5000, end: 10000),
    PriceRange(start: 10000, end: 20000),
    PriceRange(start: 20000, end: double.infinity),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Pets", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterSheet(context),
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
              );
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 30, 197, 177), Color.fromARGB(255, 13, 188, 159)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          petType(),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedIndex == -1) {
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _dataBaseStorage.retrieveAllData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildShimmerLoading();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }
                      return _buildList(context, snapshot.data!);
                    },
                  );
                } else {
                  return IndexedStack(
                    index: _selectedIndex,
                    children: [
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _dataBaseStorage.retrieveDataFromCat(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return buildShimmerLoading();
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No data available'));
                          }
                          return _buildList(context, snapshot.data!);
                        },
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _dataBaseStorage.retrieveDataFroDog(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return buildShimmerLoading();
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No data available'));
                          }
                          return _buildList(context, snapshot.data!);
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPost()),
          );
        },
        label: const Text("Sell your Pet", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 19, 187, 173),
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget petType() {
    List<String> propertyType = ["Cats", "Dogs"];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: propertyType.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color.fromARGB(255, 30, 197, 177), Color.fromARGB(255, 13, 188, 159)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : unselectedColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color.fromARGB(255, 18, 198, 198).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = _selectedIndex == index ? -1 : index;
                });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    propertyType[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 36, 208, 165), Color.fromARGB(255, 17, 206, 177)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Price Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...priceRanges.map((range) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: RadioListTile<PriceRange>(
                title: Text(
                  '${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14),
                ),
                value: range,
                groupValue: _selectedPriceRange,
                onChanged: (value) {
                  setState(() {
                    _selectedPriceRange = value == _selectedPriceRange ? null : value;
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
                activeColor: const Color.fromARGB(255, 27, 203, 162),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> homeData) {
    // Apply price filter if a price range is selected
    final filteredData = _selectedPriceRange != null
        ? homeData.where((pet) {
            final price = double.tryParse(pet['price']?.toString() ?? '0') ?? 0;
            return price >= _selectedPriceRange!.start && price <= _selectedPriceRange!.end;
          }).toList()
        : homeData;

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        return _buildPostCard(context, filteredData[index], index);
      },
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> petData, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(homeData: petData),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              children: [
                Image.network(
                  petData['images'][0],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
                // "For Sale" Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'For Sale',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Consumer<FavoriteManager>(
                    builder: (BuildContext context, favourite, Widget? child) {
                      String propertyId = favourite.generatePropertyId(petData);
                      bool isFavorite = favourite.isFavorite(propertyId);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 30,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () async {
                          await Provider.of<FavoriteManager>(context, listen: false)
                              .toggleFavorite(petData);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${petData['pet_breed'] ?? ''}, 📍${petData['location'] ?? 'No location'}, PKR ${petData['price'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    petData['description'] ?? 'No description available.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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