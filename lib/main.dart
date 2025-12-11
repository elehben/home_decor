import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'pages/wishlist_page.dart';
import 'pages/profile_page.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Home Decor App',
            debugShowCheckedModeBanner: false,
            theme: settings.theme,
            home: const MainPage(),
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String? _lastUserId;

  final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const WishlistPage(),
    const ProfilePage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncUserProviders();
  }
  
  void _syncUserProviders() {
    // Sync user ID with cart and wishlist providers
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userId;
    
    // Only update if userId changed
    if (_lastUserId != currentUserId) {
      print('DEBUG main.dart: userId changed from $_lastUserId to $currentUserId');
      _lastUserId = currentUserId;
      
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      
      cartProvider.setUserId(currentUserId);
      wishlistProvider.setUserId(currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    
    // Sync user when auth changes
    _syncUserProviders();

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        selectedItemColor: isDark ? const Color(0xFFD7A86E) : Colors.brown,
        unselectedItemColor: Colors.grey,
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: settings.tr('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: settings.tr('cart'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: settings.tr('wishlist'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: settings.tr('profile'),
          ),
        ],
      ),
    );
  }
}
