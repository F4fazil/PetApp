import 'package:flutter/material.dart';
import 'package:petpalace/constant/constant.dart';

import 'cats_dogs/cats/Animal.dart';
import 'cats_dogs/cats/animalJsonloading.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  String selectedCategory = "cats";
  late Future<List<Animal>> animalsFuture;

  @override
  void initState() {
    super.initState();
    animalsFuture = loadAnimals('$selectedCategory.json');
  }

  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
      animalsFuture = loadAnimals('$selectedCategory.json');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bc,
      appBar: AppBar(
        backgroundColor: app_bc,
        title: const Text("BreedsFood"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => updateCategory("cats"),
                  child: CategoryTab(
                    label: "Cats",
                    isSelected: selectedCategory == "cats",
                  ),
                ),
                GestureDetector(
                  onTap: () => updateCategory("dogs"),
                  child: CategoryTab(
                    label: "Dogs",
                    isSelected: selectedCategory == "dogs",
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Animal>>(
              future: animalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading data."));
                } else {
                  final animals = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      animal.image.isNotEmpty
                                          ? AssetImage(animal.image)
                                          : const AssetImage(
                                            "assets/app_icon.ong",
                                          ),
                                ),
                              ),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                animal.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text("Origin: ${animal.origin}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text("Life Span: ${animal.lifeSpan}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text("Food: ${animal.foodRecommendation}"),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryTab({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
