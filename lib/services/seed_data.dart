import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/unsplash.dart';

Future<void> seedSampleData() async {
  final firestore = FirebaseFirestore.instance;

  final categories = [
    {'id': 'biryani', 'name': 'Biryani', 'icon': '🍚', 'imageUrl': unsplashUrl('1563379091339-03246963e90f', w: 160, h: 160), 'bgColorHex': '#B8833A'},
    {'id': 'karahi', 'name': 'Karahi', 'icon': '🍲', 'imageUrl': unsplashUrl('1534422298391-e4f8c172dddb', w: 160, h: 160), 'bgColorHex': '#8B3A2C'},
    {'id': 'nihari', 'name': 'Nihari', 'icon': '🥘', 'imageUrl': unsplashUrl('1631515243349-e0cb75fb8d3a', w: 160, h: 160), 'bgColorHex': '#6B3322'},
    {'id': 'daal', 'name': 'Daal', 'icon': '🫘', 'imageUrl': unsplashUrl('1567188040759-fb8a883dc6d8', w: 160, h: 160), 'bgColorHex': '#C9873A'},
    {'id': 'bbq', 'name': 'BBQ', 'icon': '🍢', 'imageUrl': unsplashUrl('1529006557810-274f16d20dab', w: 160, h: 160), 'bgColorHex': '#3E2A1A'},
    {'id': 'desserts', 'name': 'Desserts', 'icon': '🍮', 'imageUrl': unsplashUrl('1578985545062-69928b1d9587', w: 160, h: 160), 'bgColorHex': '#C2513A'},
    {'id': 'snacks', 'name': 'Snacks', 'icon': '🥙', 'imageUrl': unsplashUrl('1504674900247-0877df9cc836', w: 160, h: 160), 'bgColorHex': '#D4875A'},
    {'id': 'breakfast', 'name': 'Breakfast', 'icon': '🍳', 'imageUrl': unsplashUrl('1533089860892-a7c6f0a88666', w: 160, h: 160), 'bgColorHex': '#E8A041'},
    {'id': 'healthy', 'name': 'Healthy', 'icon': '🥗', 'imageUrl': unsplashUrl('1512621776951-a57141f2eefd', w: 160, h: 160), 'bgColorHex': '#4A7C59'},
    {'id': 'beverages', 'name': 'Beverages', 'icon': '🥤', 'imageUrl': unsplashUrl('1544145945-f90425340c7e', w: 160, h: 160), 'bgColorHex': '#2C6E49'},
  ];
  for (final c in categories) {
    await firestore.collection('categories').doc(c['id'] as String).set(c);
  }

  final sellers = {
    's1': {
      'name': "Ammi's Kitchen",
      'avatarUrl': unsplashUrl('1531746020798-e6953c6e8e04', w: 160, h: 160),
      'coverUrl': unsplashUrl('1556909114-f6e7ad7d3136', w: 800, h: 400),
      'avatarEmoji': '👩‍🍳', 'avatarBgHex': '#C2513A',
      'coverEmoji': '🍲', 'coverBgHex': '#8B3A2C',
      'rating': 4.9, 'reviews': 248,
      'location': 'DHA Phase 6, Karachi', 'distance': '1.2 km',
      'cuisines': ['Pakistani', 'Homemade', 'Halal'],
      'verified': true, 'topRated': true,
      'description': 'Fresh homemade Pakistani food prepared daily.',
      'story': 'Started cooking for family and neighbours 5 years ago.',
      'hours': '11am – 9pm', 'days': 'Mon–Sat',
    },
    's2': {
      'name': "Dadi's Dastarkhwan",
      'avatarUrl': unsplashUrl('1494790108377-be9c29b29330', w: 160, h: 160),
      'coverUrl': unsplashUrl('1504674900247-0877df9cc836', w: 800, h: 400),
      'avatarEmoji': '👵', 'avatarBgHex': '#6B5048',
      'coverEmoji': '🥘', 'coverBgHex': '#6B3322',
      'rating': 4.8, 'reviews': 186,
      'location': 'Gulshan-e-Iqbal, Karachi', 'distance': '2.4 km',
      'cuisines': ['Traditional', 'Nihari', 'Halal'],
      'verified': true, 'topRated': true,
      'description': 'Traditional recipes passed down three generations.',
      'story': 'My dadi taught me everything about cooking.',
      'hours': '10am – 8pm', 'days': 'Mon–Sun',
    },
    's3': {
      'name': 'Desi Kitchen',
      'avatarUrl': unsplashUrl('1438761681033-6461ffad8d80', w: 160, h: 160),
      'coverUrl': unsplashUrl('1567188040759-fb8a883dc6d8', w: 800, h: 400),
      'avatarEmoji': '👩‍🍳', 'avatarBgHex': '#4A7C59',
      'coverEmoji': '🍢', 'coverBgHex': '#3E2A1A',
      'rating': 4.7, 'reviews': 134,
      'location': 'Clifton, Karachi', 'distance': '3.1 km',
      'cuisines': ['Desi', 'BBQ', 'Fresh'],
      'verified': true, 'topRated': false,
      'description': 'Authentic desi flavours made fresh every day.',
      'story': '',
      'hours': '12pm – 10pm', 'days': 'Tue–Sun',
    },
  };
  for (final entry in sellers.entries) {
    await firestore.collection('sellers').doc(entry.key).set(entry.value);
  }

  final foods = {
    'f1': {'name': 'Chicken Biryani', 'sellerId': 's1', 'sellerName': "Ammi's Kitchen", 'category': 'biryani', 'price': 450, 'rating': 4.8, 'reviews': 128, 'imageUrl': unsplashUrl('1563379091339-03246963e90f', w: 800, h: 600), 'emoji': '🍚', 'bgColorHex': '#B8833A', 'description': 'Fragrant basmati rice cooked with tender chicken pieces.', 'ingredients': 'Chicken, Basmati Rice, Yogurt, Onions, Tomatoes, Garam Masala', 'portionSize': 'Serves 1–2', 'prepTime': '45 mins', 'available': 8, 'verified': true, 'featured': true, 'freshToday': true},
    'f2': {'name': 'Chicken Karahi', 'sellerId': 's1', 'sellerName': "Ammi's Kitchen", 'category': 'karahi', 'price': 650, 'rating': 4.9, 'reviews': 95, 'imageUrl': unsplashUrl('1534422298391-e4f8c172dddb', w: 800, h: 600), 'emoji': '🍲', 'bgColorHex': '#8B3A2C', 'description': 'Classic Pakistani karahi made in a traditional wok.', 'ingredients': 'Chicken, Tomatoes, Ginger, Green Chilies, Oil, Whole Spices', 'portionSize': 'Serves 2–3', 'prepTime': '35 mins', 'available': 4, 'verified': true, 'featured': true, 'freshToday': true},
    'f3': {'name': 'Nihari', 'sellerId': 's2', 'sellerName': "Dadi's Dastarkhwan", 'category': 'nihari', 'price': 350, 'rating': 4.9, 'reviews': 156, 'imageUrl': unsplashUrl('1631515243349-e0cb75fb8d3a', w: 800, h: 600), 'emoji': '🥘', 'bgColorHex': '#6B3322', 'description': 'Slow-cooked beef shank in a rich, aromatic gravy.', 'ingredients': 'Beef, Nihari Masala, Wheat Flour, Ginger, Onions, Ghee', 'portionSize': 'Serves 1', 'prepTime': 'Slow-cooked 8 hrs', 'available': 12, 'verified': true, 'featured': false, 'freshToday': true},
    'f4': {'name': 'Daal Chawal', 'sellerId': 's2', 'sellerName': "Dadi's Dastarkhwan", 'category': 'daal', 'price': 250, 'rating': 4.7, 'reviews': 88, 'imageUrl': unsplashUrl('1567188040759-fb8a883dc6d8', w: 800, h: 600), 'emoji': '🫘', 'bgColorHex': '#C9873A', 'description': 'Comfort food — yellow lentils tempered with cumin, with steamed rice.', 'ingredients': 'Lentils, Rice, Cumin, Tomatoes, Onions, Ghee, Turmeric', 'portionSize': 'Serves 1', 'prepTime': '30 mins', 'available': 20, 'verified': true, 'featured': false, 'freshToday': true},
    'f5': {'name': 'Gulab Jamun', 'sellerId': 's1', 'sellerName': "Ammi's Kitchen", 'category': 'desserts', 'price': 200, 'rating': 4.8, 'reviews': 72, 'imageUrl': unsplashUrl('1578985545062-69928b1d9587', w: 800, h: 600), 'emoji': '🍮', 'bgColorHex': '#C2513A', 'description': 'Soft khoya dumplings soaked in rose-flavoured sugar syrup.', 'ingredients': 'Khoya, Flour, Sugar Syrup, Rose Water, Cardamom', 'portionSize': '6 pieces', 'prepTime': '30 mins', 'available': 30, 'verified': true, 'featured': false, 'freshToday': false},
    'f6': {'name': 'Halwa Puri', 'sellerId': 's3', 'sellerName': 'Desi Kitchen', 'category': 'breakfast', 'price': 300, 'rating': 4.6, 'reviews': 54, 'imageUrl': unsplashUrl('1533089860892-a7c6f0a88666', w: 800, h: 600), 'emoji': '🍳', 'bgColorHex': '#E8A041', 'description': 'Traditional weekend breakfast — halwa, puris, and chana masala.', 'ingredients': 'Semolina, Sugar, Ghee, Flour, Chickpeas, Spices', 'portionSize': 'Serves 1–2', 'prepTime': '40 mins', 'available': 10, 'verified': true, 'featured': false, 'freshToday': true},
    'f7': {'name': 'Chicken Pulao', 'sellerId': 's3', 'sellerName': 'Desi Kitchen', 'category': 'biryani', 'price': 380, 'rating': 4.5, 'reviews': 42, 'imageUrl': unsplashUrl('1476224203421-9ac39bcb3327', w: 800, h: 600), 'emoji': '🍚', 'bgColorHex': '#A07842', 'description': 'Fragrant one-pot chicken pulao with whole spices.', 'ingredients': 'Chicken, Rice, Onions, Whole Spices, Yogurt', 'portionSize': 'Serves 1–2', 'prepTime': '50 mins', 'available': 6, 'verified': true, 'featured': false, 'freshToday': true},
    'f8': {'name': 'BBQ Seekh Kebab', 'sellerId': 's3', 'sellerName': 'Desi Kitchen', 'category': 'bbq', 'price': 550, 'rating': 4.7, 'reviews': 67, 'imageUrl': unsplashUrl('1529006557810-274f16d20dab', w: 800, h: 600), 'emoji': '🍢', 'bgColorHex': '#3E2A1A', 'description': 'Hand-minced beef kebabs grilled on charcoal, served with mint chutney.', 'ingredients': 'Beef Mince, Onions, Coriander, Green Chilies, Spices', 'portionSize': '6 pieces + naan', 'prepTime': '25 mins', 'available': 15, 'verified': true, 'featured': true, 'freshToday': false},
    'f9': {'name': 'Samosa Platter', 'sellerId': 's1', 'sellerName': "Ammi's Kitchen", 'category': 'snacks', 'price': 180, 'rating': 4.6, 'reviews': 40, 'imageUrl': unsplashUrl('1504674900247-0877df9cc836', w: 800, h: 600), 'emoji': '🥙', 'bgColorHex': '#D4875A', 'description': 'Crispy golden samosas stuffed with spiced potato and peas.', 'ingredients': 'Potato, Peas, Flour, Cumin, Coriander, Oil', 'portionSize': '8 pieces', 'prepTime': '20 mins', 'available': 25, 'verified': true, 'featured': false, 'freshToday': true},
    'f10': {'name': 'Grilled Veggie Bowl', 'sellerId': 's2', 'sellerName': "Dadi's Dastarkhwan", 'category': 'healthy', 'price': 320, 'rating': 4.4, 'reviews': 21, 'imageUrl': unsplashUrl('1512621776951-a57141f2eefd', w: 800, h: 600), 'emoji': '🥗', 'bgColorHex': '#4A7C59', 'description': 'Grilled seasonal vegetables with a light lemon-herb dressing.', 'ingredients': 'Zucchini, Bell Peppers, Olive Oil, Lemon, Herbs', 'portionSize': 'Serves 1', 'prepTime': '20 mins', 'available': 14, 'verified': true, 'featured': false, 'freshToday': true},
    'f11': {'name': 'Doodh Patti Chai', 'sellerId': 's3', 'sellerName': 'Desi Kitchen', 'category': 'beverages', 'price': 90, 'rating': 4.9, 'reviews': 60, 'imageUrl': unsplashUrl('1544145945-f90425340c7e', w: 800, h: 600), 'emoji': '🥤', 'bgColorHex': '#2C6E49', 'description': 'Rich, milky Pakistani tea brewed with cardamom.', 'ingredients': 'Milk, Tea Leaves, Sugar, Cardamom', 'portionSize': '1 cup', 'prepTime': '10 mins', 'available': 40, 'verified': true, 'featured': false, 'freshToday': true},
  };
  for (final entry in foods.entries) {
    await firestore.collection('foods').doc(entry.key).set(entry.value);
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// // LoremFlickr returns a REAL photo matched to your keyword tags, instead of
// // picsum.photos which just returns a totally random, unrelated stock photo.
// // Format: https://loremflickr.com/WIDTH/HEIGHT/keyword1,keyword2,keyword3
// String _img(String keywords, {int w = 800, int h = 600}) =>
//     'https://loremflickr.com/$w/$h/$keywords';

// Future<void> seedSampleData() async {
//   final firestore = FirebaseFirestore.instance;

//   final categories = [
//     {
//       'id': 'biryani',
//       'name': 'Biryani',
//       'icon': '🍚',
//       'imageUrl': _img('biryani,rice,chicken', w: 160, h: 160),
//       'bgColorHex': '#B8833A'
//     },
//     {
//       'id': 'karahi',
//       'name': 'Karahi',
//       'icon': '🍲',
//       'imageUrl': _img('karahi,curry,chicken', w: 160, h: 160),
//       'bgColorHex': '#8B3A2C'
//     },
//     {
//       'id': 'nihari',
//       'name': 'Nihari',
//       'icon': '🥘',
//       'imageUrl': _img('nihari,beef,stew', w: 160, h: 160),
//       'bgColorHex': '#6B3322'
//     },
//     {
//       'id': 'daal',
//       'name': 'Daal',
//       'icon': '🫘',
//       'imageUrl': _img('daal,lentils,rice', w: 160, h: 160),
//       'bgColorHex': '#C9873A'
//     },
//     {
//       'id': 'bbq',
//       'name': 'BBQ',
//       'icon': '🍢',
//       'imageUrl': _img('bbq,kebab,grill', w: 160, h: 160),
//       'bgColorHex': '#3E2A1A'
//     },
//     {
//       'id': 'desserts',
//       'name': 'Desserts',
//       'icon': '🍮',
//       'imageUrl': _img('gulabjamun,indian,dessert', w: 160, h: 160),
//       'bgColorHex': '#C2513A'
//     },
//     {
//       'id': 'snacks',
//       'name': 'Snacks',
//       'icon': '🥙',
//       'imageUrl': _img('samosa,snack,fried', w: 160, h: 160),
//       'bgColorHex': '#D4875A'
//     },
//     {
//       'id': 'breakfast',
//       'name': 'Breakfast',
//       'icon': '🍳',
//       'imageUrl': _img('puri,breakfast,indian', w: 160, h: 160),
//       'bgColorHex': '#E8A041'
//     },
//     {
//       'id': 'healthy',
//       'name': 'Healthy',
//       'icon': '🥗',
//       'imageUrl': _img('salad,vegetables,healthy', w: 160, h: 160),
//       'bgColorHex': '#4A7C59'
//     },
//     {
//       'id': 'beverages',
//       'name': 'Beverages',
//       'icon': '🥤',
//       'imageUrl': _img('chai,tea,milk', w: 160, h: 160),
//       'bgColorHex': '#2C6E49'
//     },
//   ];

//   for (final c in categories) {
//     await firestore.collection('categories').doc(c['id'] as String).set(c);
//   }

//   final sellers = {
//     's1': {
//       'name': "Ammi's Kitchen",
//       'avatarUrl': _img('woman,chef,cooking', w: 400, h: 400),
//       'coverUrl': _img('pakistani,food,kitchen', w: 800, h: 400),
//       'avatarEmoji': '👩‍🍳',
//       'avatarBgHex': '#C2513A',
//       'coverEmoji': '🍲',
//       'coverBgHex': '#8B3A2C',
//       'rating': 4.9,
//       'reviews': 248,
//       'location': 'DHA Phase 6, Karachi',
//       'distance': '1.2 km',
//       'cuisines': ['Pakistani', 'Homemade', 'Halal'],
//       'verified': true,
//       'topRated': true,
//       'description': 'Fresh homemade Pakistani food prepared daily.',
//       'story': 'Started cooking for family and neighbours 5 years ago.',
//       'hours': '11am – 9pm',
//       'days': 'Mon–Sat',
//     },
//     's2': {
//       'name': "Dadi's Dastarkhwan",
//       'avatarUrl': _img('grandmother,cooking,portrait', w: 400, h: 400),
//       'coverUrl': _img('nihari,curry,pot', w: 800, h: 400),
//       'avatarEmoji': '👵',
//       'avatarBgHex': '#6B5048',
//       'coverEmoji': '🥘',
//       'coverBgHex': '#6B3322',
//       'rating': 4.8,
//       'reviews': 186,
//       'location': 'Gulshan-e-Iqbal, Karachi',
//       'distance': '2.4 km',
//       'cuisines': ['Traditional', 'Nihari', 'Halal'],
//       'verified': true,
//       'topRated': true,
//       'description': 'Traditional recipes passed down three generations.',
//       'story': 'My dadi taught me everything about cooking.',
//       'hours': '10am – 8pm',
//       'days': 'Mon–Sun',
//     },
//     's3': {
//       'name': 'Desi Kitchen',
//       'avatarUrl': _img('chef,portrait,kitchen', w: 400, h: 400),
//       'coverUrl': _img('bbq,kebab,grill,charcoal', w: 800, h: 400),
//       'avatarEmoji': '👩‍🍳',
//       'avatarBgHex': '#4A7C59',
//       'coverEmoji': '🍢',
//       'coverBgHex': '#3E2A1A',
//       'rating': 4.7,
//       'reviews': 134,
//       'location': 'Clifton, Karachi',
//       'distance': '3.1 km',
//       'cuisines': ['Desi', 'BBQ', 'Fresh'],
//       'verified': true,
//       'topRated': false,
//       'description': 'Authentic desi flavours made fresh every day.',
//       'story': '',
//       'hours': '12pm – 10pm',
//       'days': 'Tue–Sun',
//     },
//   };

//   for (final entry in sellers.entries) {
//     await firestore.collection('sellers').doc(entry.key).set(entry.value);
//   }

//   final foods = {
//     'f1': {
//       'name': 'Chicken Biryani',
//       'sellerId': 's1',
//       'sellerName': "Ammi's Kitchen",
//       'category': 'biryani',
//       'price': 450,
//       'rating': 4.8,
//       'reviews': 128,
//       'imageUrl': _img('chicken,biryani,rice'),
//       'emoji': '🍚',
//       'bgColorHex': '#B8833A',
//       'description':
//           'Fragrant basmati rice cooked with tender chicken pieces.',
//       'ingredients':
//           'Chicken, Basmati Rice, Yogurt, Onions, Tomatoes, Garam Masala',
//       'portionSize': 'Serves 1–2',
//       'prepTime': '45 mins',
//       'available': 8,
//       'verified': true,
//       'featured': true,
//       'freshToday': true
//     },
//     'f2': {
//       'name': 'Chicken Karahi',
//       'sellerId': 's1',
//       'sellerName': "Ammi's Kitchen",
//       'category': 'karahi',
//       'price': 650,
//       'rating': 4.9,
//       'reviews': 95,
//       'imageUrl': _img('karahi,chicken,curry'),
//       'emoji': '🍲',
//       'bgColorHex': '#8B3A2C',
//       'description':
//           'Classic Pakistani karahi made in a traditional wok.',
//       'ingredients':
//           'Chicken, Tomatoes, Ginger, Green Chilies, Oil, Whole Spices',
//       'portionSize': 'Serves 2–3',
//       'prepTime': '35 mins',
//       'available': 4,
//       'verified': true,
//       'featured': true,
//       'freshToday': true
//     },
//     'f3': {
//       'name': 'Nihari',
//       'sellerId': 's2',
//       'sellerName': "Dadi's Dastarkhwan",
//       'category': 'nihari',
//       'price': 350,
//       'rating': 4.9,
//       'reviews': 156,
//       'imageUrl': _img('nihari,beef,curry'),
//       'emoji': '🥘',
//       'bgColorHex': '#6B3322',
//       'description':
//           'Slow-cooked beef shank in a rich, aromatic gravy.',
//       'ingredients':
//           'Beef, Nihari Masala, Wheat Flour, Ginger, Onions, Ghee',
//       'portionSize': 'Serves 1',
//       'prepTime': 'Slow-cooked 8 hrs',
//       'available': 12,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//     'f4': {
//       'name': 'Daal Chawal',
//       'sellerId': 's2',
//       'sellerName': "Dadi's Dastarkhwan",
//       'category': 'daal',
//       'price': 250,
//       'rating': 4.7,
//       'reviews': 88,
//       'imageUrl': _img('daal,lentils,rice'),
//       'emoji': '🫘',
//       'bgColorHex': '#C9873A',
//       'description':
//           'Comfort food — yellow lentils tempered with cumin, with steamed rice.',
//       'ingredients':
//           'Lentils, Rice, Cumin, Tomatoes, Onions, Ghee, Turmeric',
//       'portionSize': 'Serves 1',
//       'prepTime': '30 mins',
//       'available': 20,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//     'f5': {
//       'name': 'Gulab Jamun',
//       'sellerId': 's1',
//       'sellerName': "Ammi's Kitchen",
//       'category': 'desserts',
//       'price': 200,
//       'rating': 4.8,
//       'reviews': 72,
//       'imageUrl': _img('gulabjamun,indian,sweet,dessert'),
//       'emoji': '🍮',
//       'bgColorHex': '#C2513A',
//       'description':
//           'Soft khoya dumplings soaked in rose-flavoured sugar syrup.',
//       'ingredients':
//           'Khoya, Flour, Sugar Syrup, Rose Water, Cardamom',
//       'portionSize': '6 pieces',
//       'prepTime': '30 mins',
//       'available': 30,
//       'verified': true,
//       'featured': false,
//       'freshToday': false
//     },
//     'f6': {
//       'name': 'Halwa Puri',
//       'sellerId': 's3',
//       'sellerName': 'Desi Kitchen',
//       'category': 'breakfast',
//       'price': 300,
//       'rating': 4.6,
//       'reviews': 54,
//       'imageUrl': _img('halwa,puri,breakfast'),
//       'emoji': '🍳',
//       'bgColorHex': '#E8A041',
//       'description':
//           'Traditional weekend breakfast — halwa, puris, and chana masala.',
//       'ingredients':
//           'Semolina, Sugar, Ghee, Flour, Chickpeas, Spices',
//       'portionSize': 'Serves 1–2',
//       'prepTime': '40 mins',
//       'available': 10,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//     'f7': {
//       'name': 'Chicken Pulao',
//       'sellerId': 's3',
//       'sellerName': 'Desi Kitchen',
//       'category': 'biryani',
//       'price': 380,
//       'rating': 4.5,
//       'reviews': 42,
//       'imageUrl': _img('pulao,rice,chicken'),
//       'emoji': '🍚',
//       'bgColorHex': '#A07842',
//       'description':
//           'Fragrant one-pot chicken pulao with whole spices.',
//       'ingredients':
//           'Chicken, Rice, Onions, Whole Spices, Yogurt',
//       'portionSize': 'Serves 1–2',
//       'prepTime': '50 mins',
//       'available': 6,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//     'f8': {
//       'name': 'BBQ Seekh Kebab',
//       'sellerId': 's3',
//       'sellerName': 'Desi Kitchen',
//       'category': 'bbq',
//       'price': 550,
//       'rating': 4.7,
//       'reviews': 67,
//       'imageUrl': _img('seekh,kebab,bbq,grill'),
//       'emoji': '🍢',
//       'bgColorHex': '#3E2A1A',
//       'description':
//           'Hand-minced beef kebabs grilled on charcoal, served with mint chutney.',
//       'ingredients':
//           'Beef Mince, Onions, Coriander, Green Chilies, Spices',
//       'portionSize': '6 pieces + naan',
//       'prepTime': '25 mins',
//       'available': 15,
//       'verified': true,
//       'featured': true,
//       'freshToday': false
//     },
//     'f9': {
//       'name': 'Samosa Platter',
//       'sellerId': 's1',
//       'sellerName': "Ammi's Kitchen",
//       'category': 'snacks',
//       'price': 180,
//       'rating': 4.6,
//       'reviews': 40,
//       'imageUrl': _img('samosa,fried,snack'),
//       'emoji': '🥙',
//       'bgColorHex': '#D4875A',
//       'description':
//           'Crispy golden samosas stuffed with spiced potato and peas.',
//       'ingredients':
//           'Potato, Peas, Flour, Cumin, Coriander, Oil',
//       'portionSize': '8 pieces',
//       'prepTime': '20 mins',
//       'available': 25,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//     'f10': {
//       'name': 'Grilled Veggie Bowl',
//       'sellerId': 's2',
//       'sellerName': "Dadi's Dastarkhwan",
//       'category': 'healthy',
//       'price': 320,
//       'rating': 4.4,
//       'reviews': 21,
//       'imageUrl': _img('grilled,vegetables,salad,bowl'),
//       'emoji': '🥗',
//       'bgColorHex': '#4A7C59',
//       'description':
//           'Grilled seasonal vegetables with a light lemon-herb dressing.',
//       'ingredients':
//           'Zucchini, Bell Peppers, Olive Oil, Lemon, Herbs',
//       'portionSize': 'Serves 1',
//       'prepTime': '20 mins',
//       'available': 14,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//     'f11': {
//       'name': 'Doodh Patti Chai',
//       'sellerId': 's3',
//       'sellerName': 'Desi Kitchen',
//       'category': 'beverages',
//       'price': 90,
//       'rating': 4.9,
//       'reviews': 60,
//       'imageUrl': _img('chai,tea,milk,cup'),
//       'emoji': '🥤',
//       'bgColorHex': '#2C6E49',
//       'description':
//           'Rich, milky Pakistani tea brewed with cardamom.',
//       'ingredients':
//           'Milk, Tea Leaves, Sugar, Cardamom',
//       'portionSize': '1 cup',
//       'prepTime': '10 mins',
//       'available': 40,
//       'verified': true,
//       'featured': false,
//       'freshToday': true
//     },
//   };

//   for (final entry in foods.entries) {
//     await firestore.collection('foods').doc(entry.key).set(entry.value);
//   }
// }