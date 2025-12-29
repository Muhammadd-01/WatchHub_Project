// =============================================================================
// FILE: seeder_service.dart
// PURPOSE: Database seeder for WatchHub sample data
// DESCRIPTION: Seeds the Firestore database with sample watch products
//              from premium brands like Rolex, Omega, Patek Philippe, etc.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/product_model.dart';

/// Service to seed the database with sample data
///
/// This should only be run once to populate the database
/// with initial product data for demonstration.
class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds the database with sample products if not already seeded
  Future<void> seedIfNeeded() async {
    try {
      // Check if products already exist
      final productsSnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .limit(1)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        debugPrint('SeederService: Products already exist, skipping seed');
        return;
      }

      debugPrint('SeederService: Seeding database with sample products...');
      await seedProducts();
      debugPrint('SeederService: Seeding complete!');
    } catch (e) {
      debugPrint('SeederService: Error during seeding - $e');
    }
  }

  /// Seeds sample watch products
  Future<void> seedProducts() async {
    final products = _getSampleProducts();
    final batch = _firestore.batch();

    for (final product in products) {
      final docRef =
          _firestore.collection(AppConstants.productsCollection).doc();
      batch.set(docRef, {
        ...product.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint('SeederService: Seeded ${products.length} products');
  }

  /// Returns list of sample luxury watch products
  List<ProductModel> _getSampleProducts() {
    return [
      // =========== ROLEX WATCHES ===========
      ProductModel(
        id: '',
        name: 'Submariner Date',
        brand: 'Rolex',
        description:
            'The Oyster Perpetual Submariner Date in Oystersteel with a Cerachrom bezel insert in black ceramic and a black dial with large luminescent hour markers. The reference among divers\' watches, the Submariner was born in 1953. It was the first wristwatch waterproof to a depth of 100 metres (330 feet).',
        price: 14550.00,
        imageUrl:
            'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800',
        category: 'Diving',
        stock: 5,
        specifications: {
          'Case Size': '41 mm',
          'Movement': 'Automatic',
          'Caliber': '3235',
          'Power Reserve': '70 hours',
          'Water Resistance': '300 m',
          'Case Material': 'Oystersteel',
          'Bracelet': 'Oyster',
          'Crystal': 'Sapphire',
        },
        rating: 4.9,
        reviewCount: 127,
        isFeatured: true,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Daytona',
        brand: 'Rolex',
        description:
            'This Cosmograph Daytona in 18 ct yellow gold with a bright black dial and an Oyster bracelet. The bezel is engraved with a tachymetric scale that allows average speeds of up to 400 miles or kilometres per hour to be read. An icon of racing.',
        price: 43950.00,
        originalPrice: 46500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1548171915-e79a380a2a4b?w=800',
        category: 'Sport',
        stock: 3,
        specifications: {
          'Case Size': '40 mm',
          'Movement': 'Automatic',
          'Caliber': '4131',
          'Power Reserve': '72 hours',
          'Water Resistance': '100 m',
          'Case Material': '18K Yellow Gold',
          'Bracelet': 'Oyster',
          'Crystal': 'Sapphire',
        },
        rating: 4.8,
        reviewCount: 89,
        isFeatured: true,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'GMT-Master II',
        brand: 'Rolex',
        description:
            'The GMT-Master II with a two-color Cerachrom bezel insert in red and blue ceramic, known as "Pepsi". The watch allows you to set the local time in one timezone while simultaneously reading the time in two other time zones.',
        price: 17650.00,
        imageUrl:
            'https://images.unsplash.com/photo-1627225924765-552d49cf47ad?w=800',
        category: 'Luxury',
        stock: 4,
        specifications: {
          'Case Size': '40 mm',
          'Movement': 'Automatic',
          'Caliber': '3285',
          'Power Reserve': '70 hours',
          'Water Resistance': '100 m',
          'Case Material': 'Oystersteel',
          'Bracelet': 'Jubilee',
          'Crystal': 'Sapphire',
        },
        rating: 4.9,
        reviewCount: 156,
        isFeatured: true,
        isNewArrival: true,
        createdAt: DateTime.now(),
      ),

      // =========== OMEGA WATCHES ===========
      ProductModel(
        id: '',
        name: 'Seamaster Diver 300M',
        brand: 'Omega',
        description:
            'The Seamaster Diver 300M features a blue ceramic dial decorated with the iconic waves. The first watch to feature OMEGA\'s Co-Axial Master Chronometer Calibre 8800, certified by METAS for its industry-leading precision, performance, and magnetic resistance.',
        price: 5400.00,
        imageUrl:
            'https://images.unsplash.com/photo-1614164185128-e4ec99c436d7?w=800',
        category: 'Diving',
        stock: 8,
        specifications: {
          'Case Size': '42 mm',
          'Movement': 'Automatic',
          'Caliber': '8800',
          'Power Reserve': '55 hours',
          'Water Resistance': '300 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Stainless Steel',
          'Crystal': 'Sapphire',
        },
        rating: 4.7,
        reviewCount: 203,
        isFeatured: true,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Speedmaster Moonwatch',
        brand: 'Omega',
        description:
            'The iconic Moonwatch. First watch worn on the moon. This timepiece features the famous Hesalite crystal with the Co-Axial Master Chronometer Calibre 3861. A true icon of space exploration history.',
        price: 7100.00,
        imageUrl:
            'https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=800',
        category: 'Sport',
        stock: 6,
        specifications: {
          'Case Size': '42 mm',
          'Movement': 'Manual Winding',
          'Caliber': '3861',
          'Power Reserve': '50 hours',
          'Water Resistance': '50 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Stainless Steel',
          'Crystal': 'Hesalite',
        },
        rating: 4.9,
        reviewCount: 312,
        isFeatured: false,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Constellation',
        brand: 'Omega',
        description:
            'This Constellation watch features a striking aventurine-blue stone dial with 18K Sedna gold hands and indexes. The iconic "Griffes" and facets on the case and bracelet define this legendary design.',
        price: 8200.00,
        imageUrl:
            'https://images.unsplash.com/photo-1609587312208-cea54be969e7?w=800',
        category: 'Dress',
        stock: 5,
        specifications: {
          'Case Size': '39 mm',
          'Movement': 'Automatic',
          'Caliber': '8900',
          'Power Reserve': '60 hours',
          'Water Resistance': '50 m',
          'Case Material': 'Stainless Steel & 18K Gold',
          'Bracelet': 'Leather',
          'Crystal': 'Sapphire',
        },
        rating: 4.6,
        reviewCount: 78,
        isFeatured: false,
        isNewArrival: true,
        createdAt: DateTime.now(),
      ),

      // =========== PATEK PHILIPPE WATCHES ===========
      ProductModel(
        id: '',
        name: 'Nautilus 5711',
        brand: 'Patek Philippe',
        description:
            'The legendary Nautilus 5711/1A-010 with its distinctive porthole design by Gérald Genta. Features a blue dial with horizontal embossing and luminescent hour markers and hands. The ultimate expression of casual elegance.',
        price: 125000.00,
        imageUrl:
            'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800',
        category: 'Luxury',
        stock: 2,
        specifications: {
          'Case Size': '40 mm',
          'Movement': 'Automatic',
          'Caliber': '26-330 S C',
          'Power Reserve': '45 hours',
          'Water Resistance': '120 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Stainless Steel',
          'Crystal': 'Sapphire',
        },
        rating: 5.0,
        reviewCount: 45,
        isFeatured: true,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Aquanaut',
        brand: 'Patek Philippe',
        description:
            'The Aquanaut combines elegance with a sporty edge. Its distinctive octagonal bezel and embossed dial with Arabic numerals make it instantly recognizable. The "Tropical" composite strap perfectly matches the dial.',
        price: 52000.00,
        imageUrl:
            'https://images.unsplash.com/photo-1612817159949-195b6eb9e31a?w=800',
        category: 'Sport',
        stock: 3,
        specifications: {
          'Case Size': '42.2 mm',
          'Movement': 'Automatic',
          'Caliber': '324 S C',
          'Power Reserve': '45 hours',
          'Water Resistance': '120 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Composite',
          'Crystal': 'Sapphire',
        },
        rating: 4.9,
        reviewCount: 67,
        isFeatured: false,
        isNewArrival: true,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Calatrava',
        brand: 'Patek Philippe',
        description:
            'The Calatrava represents the essence of the round wristwatch. Pure lines, refined proportions, and perfect harmony of case, dial, and hands. The ultimate dress watch for the discerning collector.',
        price: 32500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=800',
        category: 'Dress',
        stock: 4,
        specifications: {
          'Case Size': '39 mm',
          'Movement': 'Automatic',
          'Caliber': '324 S C',
          'Power Reserve': '45 hours',
          'Water Resistance': '30 m',
          'Case Material': '18K White Gold',
          'Bracelet': 'Alligator Leather',
          'Crystal': 'Sapphire',
        },
        rating: 4.8,
        reviewCount: 34,
        isFeatured: false,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),

      // =========== AUDEMARS PIGUET WATCHES ===========
      ProductModel(
        id: '',
        name: 'Royal Oak',
        brand: 'Audemars Piguet',
        description:
            'The Royal Oak "Jumbo" Extra-Thin with its revolutionary octagonal bezel and "Grande Tapisserie" dial. Designed by Gérald Genta in 1972, it changed luxury watchmaking forever. An icon of haute horlogerie.',
        price: 68000.00,
        imageUrl:
            'https://images.unsplash.com/photo-1618220179428-22790b461013?w=800',
        category: 'Luxury',
        stock: 2,
        specifications: {
          'Case Size': '39 mm',
          'Movement': 'Automatic',
          'Caliber': '2121',
          'Power Reserve': '40 hours',
          'Water Resistance': '50 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Stainless Steel',
          'Crystal': 'Sapphire',
        },
        rating: 4.9,
        reviewCount: 98,
        isFeatured: true,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Royal Oak Offshore',
        brand: 'Audemars Piguet',
        description:
            'The Royal Oak Offshore takes the iconic design and amplifies it. Larger, bolder, and more robust. This chronograph version features a flyback function and date display. For those who dare to stand out.',
        price: 45000.00,
        imageUrl:
            'https://images.unsplash.com/photo-1606744824163-985d376605aa?w=800',
        category: 'Sport',
        stock: 4,
        specifications: {
          'Case Size': '44 mm',
          'Movement': 'Automatic',
          'Caliber': '3126/3840',
          'Power Reserve': '50 hours',
          'Water Resistance': '100 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Rubber',
          'Crystal': 'Sapphire',
        },
        rating: 4.7,
        reviewCount: 76,
        isFeatured: false,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Code 11.59',
        brand: 'Audemars Piguet',
        description:
            'Code 11.59 represents a new era for Audemars Piguet. The round case features an octagonal middle case, offering a fresh perspective on classic watchmaking. The lacquered dial showcases exceptional finishing.',
        price: 35000.00,
        imageUrl:
            'https://images.unsplash.com/photo-1639037687665-a728d63e3a8e?w=800',
        category: 'Classic',
        stock: 5,
        specifications: {
          'Case Size': '41 mm',
          'Movement': 'Automatic',
          'Caliber': '4302',
          'Power Reserve': '70 hours',
          'Water Resistance': '30 m',
          'Case Material': '18K White Gold',
          'Bracelet': 'Alligator Leather',
          'Crystal': 'Sapphire',
        },
        rating: 4.5,
        reviewCount: 42,
        isFeatured: false,
        isNewArrival: true,
        createdAt: DateTime.now(),
      ),

      // =========== ADDITIONAL WATCHES ===========
      ProductModel(
        id: '',
        name: 'Datejust 41',
        brand: 'Rolex',
        description:
            'The Datejust is the archetype of the modern watch, with aesthetics that never go out of style. This version features a slate dial with luminescent hour markers in 18K white gold, and a Jubilee bracelet.',
        price: 10450.00,
        imageUrl:
            'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800',
        category: 'Classic',
        stock: 7,
        specifications: {
          'Case Size': '41 mm',
          'Movement': 'Automatic',
          'Caliber': '3235',
          'Power Reserve': '70 hours',
          'Water Resistance': '100 m',
          'Case Material': 'Oystersteel',
          'Bracelet': 'Jubilee',
          'Crystal': 'Sapphire',
        },
        rating: 4.8,
        reviewCount: 234,
        isFeatured: false,
        isNewArrival: false,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Planet Ocean 600M',
        brand: 'Omega',
        description:
            'The Planet Ocean collection pays tribute to OMEGA\'s pioneering spirit of ocean exploration. This model features an orange bezel and black dial with Co-Axial Master Chronometer movement.',
        price: 6350.00,
        imageUrl:
            'https://images.unsplash.com/photo-1639006727687-3c1295e5b7f2?w=800',
        category: 'Diving',
        stock: 6,
        specifications: {
          'Case Size': '43.5 mm',
          'Movement': 'Automatic',
          'Caliber': '8900',
          'Power Reserve': '60 hours',
          'Water Resistance': '600 m',
          'Case Material': 'Stainless Steel',
          'Bracelet': 'Stainless Steel',
          'Crystal': 'Sapphire',
        },
        rating: 4.6,
        reviewCount: 89,
        isFeatured: false,
        isNewArrival: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Clears all products (use with caution!)
  Future<void> clearProducts() async {
    final snapshot =
        await _firestore.collection(AppConstants.productsCollection).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    debugPrint('SeederService: Cleared all products');
  }
}
