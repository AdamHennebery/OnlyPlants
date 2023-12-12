import 'package:flutter/material.dart';
import 'package:only_plants/search.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantDetailsPage extends StatelessWidget {
  final Plant plant;
  final Function(Plant) addToCollectionCallback;

  const PlantDetailsPage({
    Key? key,
    required this.plant,
    required this.addToCollectionCallback, // Add this line
  }) : super(key: key);

  ElevatedButton _buildAddToCollectionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        addToCollectionCallback(plant);
        // Optionally, you can show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plant added to collection!')),
        );
      },
      child: Text('Add to Collection'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.commonName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              plant.defaultImage['medium_url'] ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              'Common Name: ${plant.commonName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Scientific Name: ${plant.scientificName}', // Replace with the actual property from your Plant class
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Watering: ${getCycle(plant.cycle)}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Watering: ${getWateringDescription(plant.watering)}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Sunlight: ${getSunlightDescription(plant.sunlight)}',
              style: TextStyle(fontSize: 18),
            ),
            _buildAddToCollectionButton(context),
          ],
        ),
      ),
    );
  }
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

String getSunlightDescription(List<String> sunlight) {
  // Add your logic here to customize the displayed information based on sunlight
  if (sunlight.contains('full sun') && sunlight.contains('part shade')) {
    return 'Thrives in full sun to partial shade';
  } else if (sunlight.contains('full sun')) {
    return 'Requires full sun';
  } else if (sunlight.contains('part shade')) {
    return 'Prefers partial shade';
  } else if (sunlight.contains('part shade') &&
      sunlight.contains('part sun/part shade')) {
    return 'Can thrive in full sun or partial shade';
  } else if (sunlight.contains('full shade')) {
    return 'Needs full shade to thrive';
  } else {
    return 'Sunlight requirements vary';
  }
}
