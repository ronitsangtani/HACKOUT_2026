/// Model representing a verified circular drop-off or recycling facility.
class RecyclingCenter {
  final String id;
  final String name;
  final String address;
  final String distance;
  final double latitude;
  final double longitude;
  final List<String> acceptedMaterials;
  final String operatingHours;
  final String contact;

  const RecyclingCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    required this.acceptedMaterials,
    required this.operatingHours,
    required this.contact,
  });

  factory RecyclingCenter.fromMap(Map<String, dynamic> map) {
    return RecyclingCenter(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      distance: map['distance'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 77.5946,
      acceptedMaterials: (map['acceptedMaterials'] as List?)?.map((e) => e.toString()).toList() ?? [],
      operatingHours: map['operatingHours'] as String? ?? '',
      contact: map['contact'] as String? ?? '',
    );
  }

  static List<RecyclingCenter> get mockCenters => const [
        RecyclingCenter(
          id: '1',
          name: 'GreenEarth E-Waste & Battery Drop-Off',
          address: '42 Ring Road, Indiranagar',
          distance: '1.2 km away',
          acceptedMaterials: ['E-Waste', 'Batteries', 'Cables', 'Screens'],
          operatingHours: 'Mon - Sat: 9:00 AM - 6:30 PM',
          contact: '+91 98765 43210',
        ),
        RecyclingCenter(
          id: '2',
          name: 'EcoCycle Polymer Recovery Hub',
          address: 'Plot 18, Industrial Area Stage 2',
          distance: '2.8 km away',
          acceptedMaterials: ['Plastic', 'PET Bottles', 'Packaging', 'Paper'],
          operatingHours: 'Mon - Fri: 8:00 AM - 5:00 PM',
          contact: '+91 98765 11223',
        ),
        RecyclingCenter(
          id: '3',
          name: 'Circular Textile & Clothing Thrift Drop',
          address: 'Corner 12th Main, Koramangala',
          distance: '3.5 km away',
          acceptedMaterials: ['Clothes', 'Fabrics', 'Footwear', 'Linens'],
          operatingHours: 'Daily: 10:00 AM - 8:00 PM',
          contact: '+91 98765 99887',
        ),
        RecyclingCenter(
          id: '4',
          name: 'City Metals & Paper Reclamation Point',
          address: 'Civic Utility Center, Jayanagar',
          distance: '4.1 km away',
          acceptedMaterials: ['Metal Cans', 'Paper', 'Cardboard', 'Glass'],
          operatingHours: 'Mon - Sat: 9:30 AM - 5:30 PM',
          contact: '+91 98765 33445',
        ),
      ];
}
