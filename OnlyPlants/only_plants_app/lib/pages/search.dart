import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:only_plants/pages/plant_details.dart';
import 'package:only_plants/services/firestore_service.dart';

class Plant {
  final int id;
  final String commonName;
  final List<String> scientificName;
  final String cycle;
  final String watering;
  final List<String> sunlight;
  final Map<String, dynamic> defaultImage;
  final String userId;

  Plant(
      {required this.id,
      required this.commonName,
      required this.scientificName,
      required this.cycle,
      required this.watering,
      required this.sunlight,
      required this.defaultImage,
      required this.userId});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'cycle': cycle,
      'watering': watering,
      'sunlight': sunlight,
      'default_image': defaultImage,
      'user_id': userId,
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      commonName: json['common_name'],
      scientificName: List<String>.from(json['scientific_name']),
      cycle: json['cycle'],
      watering: json['watering'],
      sunlight: List<String>.from(json['sunlight']),
      defaultImage: json['default_image'] != null
          ? Map<String, dynamic>.from(json['default_image'])
          : Map<String, dynamic>(), // or set it to an empty Map if null
      userId: json['user_id'] ?? '',
    );
  }
}

class PlantApiService {
  final String apiKey = 'sk-OkGd656bee00f1b6b3278';

  Future<List<Plant>> getAllPlants(int currentPage, int maxPages) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';
    print('Fetching plants for user: $userId');
    final List<Plant> allPlants = [];
    int page = 1;

    while (page <= maxPages) {
      final response = await http.get(
        Uri.parse(
            'https://perenual.com/api/species-list?key=$apiKey&page=$page'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Check if 'data' key exists and is not null
        if (responseData != null &&
            responseData is Map &&
            responseData['data'] != null &&
            responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];

          final List<Plant> plants = data
              .map(
                (json) => Plant.fromJson(
                  json..['userId'] = FirebaseAuth.instance.currentUser?.uid,
                ),
              )
              .toList();
          allPlants.addAll(plants);

          // If there are no more pages, break from the loop
          if (data.isEmpty) {
            break;
          }

          // Move to the next page
          page++;
        } else {
          print('Invalid response format. Data key is null or not a List.');
          throw Exception('Failed to load plant list');
        }
      } else {
        print('Failed to load plant list. Status code: ${response.statusCode}');
        throw Exception('Failed to load plant list');
      }
    }

    return allPlants;
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final PlantApiService _plantApiService = PlantApiService();
  List<Plant> _searchResults = [];
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadPlants(
        maxPages: 40); // Load 5 pages initially (you can adjust as needed)
  }

  void _addToCollection(Plant plant) async {
    try {
      // Fetch the current user's ID
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? '';
      print('Adding plant to collection for user: $userId'); // Debug print

      // Check if the plant is already in the collection
      final userPlants = await _firestoreService.getUserPlants(userId);

      if (!userPlants.any((userPlant) => userPlant.id == plant.id)) {
        // Plant is not in the collection, create a new instance with updated userId
        Plant updatedPlant = Plant(
          id: plant.id,
          commonName: plant.commonName,
          scientificName: plant.scientificName,
          cycle: plant.cycle,
          watering: plant.watering,
          sunlight: plant.sunlight,
          defaultImage: plant.defaultImage,
          userId: userId,
        );

        // Add the updated plant to the collection
        await _firestoreService.addPlantToCollection(updatedPlant);
        print('Plant added to collection!');
      } else {
        print('Plant is already in the collection.');
      }
    } catch (e) {
      print('Error adding plant to collection: $e');
    }
  }

  Future<void> _loadUserPlants(Plant plant) async {
    final userPlants = await _firestoreService.getUserPlants(plant.userId);
    // Handle user plants as needed (e.g., display them in the UI)
  }

  Future<void> _loadPlants({int maxPages = 1}) async {
    if (!_hasMoreData || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('_currentPage before API call: $_currentPage');

      final plants =
          await _plantApiService.getAllPlants(_currentPage, maxPages);

      setState(() {
        if (plants.isEmpty) {
          _hasMoreData = false;
        } else {
          _allPlants.addAll(plants);
          _filteredPlants = List.from(_allPlants);
          _currentPage++;
        }
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      try {
        setState(() {
          _filteredPlants = _allPlants
              .where((plant) =>
                  plant.commonName.toLowerCase().contains(query) ||
                  plant.scientificName.any((scientificName) =>
                      scientificName.toLowerCase().contains(query)))
              .toList();
        });
      } catch (e) {
        // Handle error, e.g., show a snackbar or display an error message
        print('Error: $e');
      }
    } else {
      setState(() {
        _filteredPlants = List.from(_allPlants);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Image _buildImage(Plant plant) {
    if (plant.defaultImage['medium_url'] != null &&
        plant.defaultImage['medium_url'].isNotEmpty) {
      // Use Image.network for network images
      return Image.network(
        plant.defaultImage['medium_url'],
        fit: BoxFit.cover,
      );
    } else {
      // Use Image.asset for local placeholder images
      return Image.asset(
        'assets/image-coming-soon.jpg', // Replace with the path to your placeholder image in the assets folder
        fit: BoxFit.cover,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Color.fromARGB(255, 231, 252, 214),
        title: const Text('Search for a plant'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Enter plant name...',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = _filteredPlants[index];
                      return GestureDetector(
                        onTap: () async {
                          // Navigate to PlantDetailsPage and wait for result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantDetailsPage(
                                plant: plant,
                                addToCollectionCallback: _addToCollection,
                              ),
                            ),
                          );

                          // Handle the result if needed
                          if (result != null) {
                            // Handle the result returned from PlantDetailsPage
                            // For example, you can check if the plant was added to the collection
                            if (result is bool && result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Plant added to collection!')),
                              );
                            }
                          }
                        },
                        child: ListTile(
                          title: Stack(
                            children: [
                              // Image container
                              Container(
                                height: 100,
                                width: double.infinity,
                                child: _buildImage(plant),
                              ),
                              // Centered text over the image with black border
                              Align(
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    // Black-bordered text (behind)
                                    Text(
                                      plant.commonName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 3
                                          ..color = Colors.black,
                                      ),
                                    ),
                                    // White text (front)
                                    Text(
                                      plant.commonName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          // ElevatedButton(
          //   onPressed: _loadNextPage,
          //   child: Text('Next Page'),
          // ),
        ],
      ),
    );
  }
}
