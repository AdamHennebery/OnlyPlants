// Step 1: Model for Plant Collection Item
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:only_plants/pages/plant_details.dart';
import 'package:only_plants/services/firestore_service.dart';

class PlantCollectionItem {
  final String plantId;
  final String commonName;
  final Map<String, dynamic> documentData;
  // Add other properties as needed

  PlantCollectionItem({
    required this.plantId,
    required this.commonName,
    required this.documentData,
    // Initialize other properties here
  });

  factory PlantCollectionItem.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return PlantCollectionItem(
      plantId: documentId,
      commonName: data['common_name'] ?? '',
      documentData: data,
    );
  }
}

// Step 2: Fetch User's Plant Collection
Future<List<PlantCollectionItem>> getUserPlantCollection(String userId) async {
  try {
    print('Fetching user plant collection for user: $userId');

    // Add this line to see if the userId is correct
    print('UserId before query: $userId');

    final querySnapshot = await FirebaseFirestore.instance
        .collection('plants')
        .where('user_id', isEqualTo: userId)
        .get();

    // Add this line to confirm that the query executed
    print(
        'Query executed successfully. Retrieved ${querySnapshot.size} documents.');

    return querySnapshot.docs.map((doc) {
      print('Document data: ${doc.data()}');
      return PlantCollectionItem.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
    // Map other properties as needed
  } catch (e) {
    print('Error fetching user plant collection: $e');
    return [];
  }
}

// Step 3 and 4: Create a Collection Page
class PlantCollectionPage extends StatefulWidget {
  final String userId;

  PlantCollectionPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PlantCollectionPageState createState() => _PlantCollectionPageState();
}

class _PlantCollectionPageState extends State<PlantCollectionPage> {
  late Future<List<PlantCollectionItem>> _plantCollection;

  @override
  void initState() {
    super.initState();
    _plantCollection = getUserPlantCollection(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Replace with your desired background color
        child: Scaffold(
          appBar: AppBar(
            title: Text('Your Plant Collection'),
          ),
          body: FutureBuilder<List<PlantCollectionItem>>(
            future: _plantCollection,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Your plant collection is empty.');
              } else {
                // Display the user's plant collection using ListView or other widgets
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final plant = snapshot.data![index];
                    return ListTile(
                      title: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              plant.documentData['default_image']
                                      ['medium_url'] ??
                                  '',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 20),
                            _buildOutlinedText(
                                'Common Name: ${plant.commonName}',
                                20,
                                FontWeight.bold),
                            const SizedBox(height: 10),
                            _buildOutlinedText(
                                'Scientific Name: ${plant.documentData['scientific_name'][0] ?? ''}',
                                18),
                            const SizedBox(height: 10),
                            _buildOutlinedText(
                                'Cycle: ${getCycle(plant.documentData['cycle'])}',
                                18),
                            const SizedBox(height: 10),
                            _buildOutlinedText(
                                'Watering: ${getWateringDescription(plant.documentData['watering'])}',
                                18),
                            const SizedBox(height: 10),
                            _buildOutlinedText(
                                'Sunlight: ${getSunlightDescription(plant.documentData['sunlight'])}',
                                18),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ));
  }

  Widget _buildOutlinedText(String text, double fontSize,
      [FontWeight? fontWeight]) {
    return Stack(
      children: [
        // Text with black border
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0
              ..color = Colors.black,
          ),
        ),
        // Text with white fill
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String getWateringDescription(String watering) {
    // Add your logic here to customize the displayed information based on watering
    switch (watering) {
      case 'Frequent':
        return 'This plant needs frquent watering to thrive';
      case 'Average':
        return 'This plant needs semi regular watering to thrive';
      case 'Minimal':
        return 'This plant thrives on infrequent watering';
      default:
        return 'Watering requirements vary';
    }
  }

  String getCycle(String cycle) {
    // Add your logic here to customize the displayed information based on watering
    switch (cycle) {
      case 'Perennial':
        return 'Live for more than two years and typically flower and produce seeds multiple times throughout their lifespan.';
      case 'Annual':
        return 'Complete their life cycle in one growing season or year and germinate, grow, flower, set seed, and die within a single year.';
      case 'Biennial':
        return 'Require two growing seasons or years to complete their life cycle and typically germinate and grow in the first year, flower and produce seeds in the second year, and then die.';
      case 'Biannual':
        return 'Require two growing seasons or years to complete their life cycle and typically germinate and grow in the first year, flower and produce seeds in the second year, and then die.';
      default:
        return 'No cycle information available';
    }
  }

  String getSunlightDescription(dynamic sunlight) {
    if (sunlight is List<dynamic>) {
      List<String> sunlightList = sunlight.cast<String>();

      if (sunlightList.contains('full sun') &&
          sunlightList.contains('part shade')) {
        return 'Thrives in full sun to partial shade';
      } else if (sunlightList.contains('full sun')) {
        return 'Requires full sun';
      } else if (sunlightList.contains('part shade')) {
        return 'Prefers partial shade';
      } else if (sunlightList.contains('part shade') &&
          sunlightList.contains('part sun/part shade')) {
        return 'Can thrive in full sun or partial shade';
      } else if (sunlightList.contains('full shade')) {
        return 'Needs full shade to thrive';
      } else {
        return 'Sunlight requirements vary';
      }
    } else {
      // Handle the case when sunlight is not a List<String>
      return 'Sunlight information not available';
    }
  }
}
