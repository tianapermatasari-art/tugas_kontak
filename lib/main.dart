import 'package:avatar_glow/avatar_glow.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:faker/faker.dart' show Faker;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// ======================= WARNA (biru - putih) =======================
const Color kBlue = Color(0xFF1976D2);
const Color kLightBlue = Color(0xFFE3F2FD);
const Color kWhite = Color(0xFFFFFFFF);

const List<String> kCategories = [
  'Keluarga',
  'Teman',
  'Kerja',
  'Sekolah',
  'Kuliah',
  'Tetangga',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: kBlue,
        useMaterial3: true,
        scaffoldBackgroundColor: kWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          centerTitle: true,
        ),
      ),
      home: const MainPage(),
    );
  }
}

// ======================= MODEL =======================
class ContactModel {
  final String name;
  final String phone;
  final String email;
  final String category;
  final DateTime addedAt;

  ContactModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.category,
    required this.addedAt,
  });
}

List<ContactModel> generateContacts(int count) {
  final faker = Faker();
  return List.generate(count, (i) {
    final part1 = faker.randomGenerator.integer(9000, min: 1000);
    final part2 = faker.randomGenerator.integer(9000, min: 1000);
    return ContactModel(
      name: faker.person.name(),
      phone: '0812$part1$part2',
      email: faker.internet.email(),
      category: kCategories[i % kCategories.length],
      addedAt: faker.date.dateTime(minYear: 2025, maxYear: 2026),
    );
  });
}

// ======================= KARTU KONTAK =======================
class ContactCard extends StatelessWidget {
  final ContactModel contact;
  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    return Card(
      color: kWhite,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBlue, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: kBlue,
              foregroundColor: kWhite,
              child: Text(contact.name[0]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.phone,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    contact.email,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ditambahkan pada ${dateFormat.format(contact.addedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kLightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                contact.category,
                style: const TextStyle(color: kBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= HALAMAN UTAMA + NAVIGASI =======================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<ContactModel> _contacts = generateContacts(20);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ContactPage(contacts: _contacts),
      SearchPage(contacts: _contacts),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: 0,
        backgroundColor: kBlue,
        color: Colors.white70,
        activeColor: kBlue,
        items: const [
          TabItem(icon: Icons.contacts, title: 'Kontak'),
          TabItem(icon: Icons.search, title: 'Cari'),
          TabItem(icon: Icons.person, title: 'Profil'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ======================= HALAMAN KONTAK =======================
class ContactPage extends StatelessWidget {
  final List<ContactModel> contacts;
  const ContactPage({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) => ContactCard(contact: contacts[index]),
      ),
    );
  }
}

// ======================= HALAMAN CARI =======================
class SearchPage extends StatefulWidget {
  final List<ContactModel> contacts;
  const SearchPage({super.key, required this.contacts});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selected = 'Keluarga';

  @override
  Widget build(BuildContext context) {
    final filtered =
    widget.contacts.where((c) => c.category == _selected).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kontak')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownSearch<String>(
              items: kCategories,
              selectedItem: _selected,
              popupProps: PopupProps.dialog(
                showSearchBox: true,
                containerBuilder: (context, popupWidget) => Container(
                  color: kWhite,
                  child: popupWidget,
                ),
                itemBuilder: (context, item, isSelected) => ListTile(
                  title: Text(
                    item,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  selected: isSelected,
                ),
                searchFieldProps: const TextFieldProps(
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Cari kategori...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Kategori Kontak',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Tidak ada kontak di kategori ini'))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  ContactCard(contact: filtered[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= HALAMAN PROFIL =======================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarGlow(
              glowColor: kBlue,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: ClipOval(
                child: Image.asset(
                  'assets/images.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 120,
                    color: kLightBlue,
                    child: const Icon(Icons.person, size: 70, color: kBlue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tiapermata',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('NIM: 4124045'),
          ],
        ),
      ),
    );
  }
}