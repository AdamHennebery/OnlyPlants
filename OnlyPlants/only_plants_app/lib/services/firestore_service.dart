// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:only_plants/pages/search.dart'; // Adjust the import path based on your project structure

class FirestoreService {
  final CollectionReference plantCollection =
      FirebaseFirestore.instance.collection('plants');

  Future<void> addPlantToCollection(Plant plant) async {
    await plantCollection.doc(plant.id.toString()).set(plant.toMap());
  }

  Future<List<Plant>> getUserPlants(String userId) async {
    final querySnapshot =
        await plantCollection.where('userId', isEqualTo: userId).get();

    return querySnapshot.docs
        .map((doc) => Plant.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> removePlantFromCollection(String plantId) async {
    await plantCollection.doc(plantId).delete();
  }
}
