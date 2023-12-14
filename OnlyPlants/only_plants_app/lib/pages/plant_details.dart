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

Widget _buildAddToCollectionButton(BuildContext context) {
  return Align(
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.only(top: 30.0), // Adjust the top padding for space
      child: SizedBox(
        width: 200, // Set the desired width
        child: ElevatedButton(
          onPressed: () {
            addToCollectionCallback(plant);
            // Optionally, you can show a confirmation message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Plant added to collection!')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(20.0), // Set the desired padding
          ),
          child: Text(
            'Add to Collection',
            style: TextStyle(fontSize: 18), // Set the desired font size
          ),
        ),
      ),
    ),
  );
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(plant.commonName),
      backgroundColor: Color.fromARGB(255, 231, 252, 214),
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
          _buildOutlinedText(
            'Common Name: ${plant.commonName}',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          _buildOutlinedText(
            'Scientific Name: ${plant.scientificName}',
            fontSize: 18,
          ),
          const SizedBox(height: 10),
          _buildOutlinedText(
            'Cycle: ${getCycle(plant.cycle)}',
            fontSize: 18,
          ),
          const SizedBox(height: 10),
          _buildOutlinedText(
            'Watering: ${getWateringDescription(plant.watering)}',
            fontSize: 18,
          ),
          const SizedBox(height: 10),
          _buildOutlinedText(
            'Sunlight: ${getSunlightDescription(plant.sunlight)}',
            fontSize: 18,
          ),
          _buildAddToCollectionButton(context),
          const SizedBox(height: 20), // Additional space at the bottom
        ],
      ),
    ),
  );
}

Widget _buildOutlinedText(String text,
    {double fontSize = 16, FontWeight? fontWeight, double strokeWidth = 2.0}) {
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
            ..strokeWidth = strokeWidth
            ..color = Colors.black,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.black.withOpacity(0.5),
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      // Text with white fill
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.black.withOpacity(0.9),
              offset: Offset(1, 1),
            ),
          ],
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
}