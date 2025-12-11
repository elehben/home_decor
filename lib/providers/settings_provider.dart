import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'en'; // 'en' for English, 'id' for Indonesian
  bool _notifications = true;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get notifications => _notifications;

  String get languageDisplayName =>
      _language == 'en' ? 'English' : 'Bahasa Indonesia';

  // Dark Mode Theme
  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.brown,
    scaffoldBackgroundColor: const Color(0xFFF8F5F2),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.brown,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.grey,
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey,
    colorScheme: const ColorScheme.light(
      primary: Colors.brown,
      secondary: Colors.brown,
      surface: Colors.white,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.brown,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D2D2D),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      selectedItemColor: Color(0xFFD7A86E),
      unselectedItemColor: Colors.grey,
    ),
    cardColor: const Color(0xFF2D2D2D),
    dividerColor: Colors.grey.shade800,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD7A86E),
      secondary: Color(0xFFD7A86E),
      surface: Color(0xFF2D2D2D),
    ),
  );

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  // Translations
  Map<String, String> get translations =>
      _language == 'en' ? _enTranslations : _idTranslations;

  static const Map<String, String> _enTranslations = {
    // Navigation
    'home': 'Home',
    'cart': 'Cart',
    'wishlist': 'Wishlist',
    'profile': 'Profile',

    // Profile Page
    'my_orders': 'My Orders',
    'shipping_address': 'Shipping Address',
    'payment_methods': 'Payment Methods',
    'firebase_admin': 'Firebase Admin',
    'settings': 'Settings',
    'logout': 'Logout',
    'guest_user': 'Guest User',
    'tap_to_login': 'Tap to login or register',

    // Settings Page
    'notifications': 'Notifications',
    'receive_notifications': 'Receive push notifications',
    'dark_mode': 'Dark Mode',
    'enable_dark_theme': 'Enable dark theme',
    'language': 'Language',
    'select_language': 'Select Language',
    'about': 'About',
    'about_app': 'About App',
    'privacy_policy': 'Privacy Policy',
    'terms_of_service': 'Terms of Service',

    // Cart Page
    'my_cart': 'My Cart',
    'clear_all': 'Clear All',
    'clear_cart': 'Clear Cart',
    'confirm_clear_cart':
        'Are you sure you want to remove all items from cart?',
    'cancel': 'Cancel',
    'delete_all': 'Delete All',
    'empty_cart': 'Cart is Empty',
    'add_products': 'Add products to cart\nto start shopping',
    'subtotal': 'Subtotal',
    'shipping': 'Shipping',
    'total': 'Total',
    'checkout': 'Checkout',
    'payment_success': 'Payment Successful!',
    'order_confirmed':
        'Your order has been confirmed and will be delivered to your address.',
    'thank_you': 'Thank you for shopping!',

    // Wishlist Page
    'my_wishlist': 'My Wishlist',
    'empty_wishlist': 'Wishlist is Empty',
    'add_to_wishlist': 'Add items to wishlist\nto save them for later',

    // Orders Page
    'no_orders': 'No orders yet',
    'delivered': 'Delivered',
    'order_shipping': 'Shipping',
    'items': 'items',

    // Login Page
    'welcome_back': 'Welcome Back!',
    'create_account': 'Create Account',
    'sign_in_continue': 'Sign in to continue shopping',
    'sign_up_start': 'Sign up to start shopping',
    'full_name': 'Full Name',
    'email': 'Email',
    'password': 'Password',
    'enter_name': 'Enter your full name',
    'enter_email': 'Enter your email',
    'enter_password': 'Enter your password',
    'forgot_password': 'Forgot Password?',
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'no_account': "Don't have an account? ",
    'have_account': 'Already have an account? ',
    'login_success': 'Login successful!',
    'register_success': 'Registration successful!',
    'login_failed': 'Login failed. Check your email and password.',
    'register_failed': 'Registration failed. Please check your data.',

    // Dialog & Messages
    'login_required': 'Login Required',
    'please_login': 'Please login to access this feature.',
    'login': 'Login',
    'logout_confirm': 'Are you sure you want to logout?',
    'logged_out': 'Logged out successfully',
    'address_saved': 'Address saved successfully!',
    'your_address': 'Your Address',
    'enter_address': 'Enter your shipping address',
    'save_address': 'Save Address',
    'coming_soon': 'Coming soon!',
    'ok': 'OK',

    // Orders
    'no_orders_yet': 'No orders yet',
    'pending': 'Pending',
    'processing': 'Processing',
    'cancelled': 'Cancelled',

    // Payment Methods
    'no_payment_methods': 'No payment methods',
    'add_payment_method_hint': 'Add a payment method to checkout faster',
    'add_payment_method': 'Add Payment Method',
    'payment_type': 'Payment Type',
    'credit_card': 'Credit Card',
    'bank_transfer': 'Bank Transfer',
    'name': 'Name',
    'detail': 'Detail',
    'add': 'Add',
    'default': 'Default',
  };

  static const Map<String, String> _idTranslations = {
    // Navigation
    'home': 'Beranda',
    'cart': 'Keranjang',
    'wishlist': 'Favorit',
    'profile': 'Profil',

    // Profile Page
    'my_orders': 'Pesanan Saya',
    'shipping_address': 'Alamat Pengiriman',
    'payment_methods': 'Metode Pembayaran',
    'firebase_admin': 'Admin Firebase',
    'settings': 'Pengaturan',
    'logout': 'Keluar',
    'guest_user': 'Pengguna Tamu',
    'tap_to_login': 'Ketuk untuk masuk atau daftar',

    // Settings Page
    'notifications': 'Notifikasi',
    'receive_notifications': 'Terima notifikasi push',
    'dark_mode': 'Mode Gelap',
    'enable_dark_theme': 'Aktifkan tema gelap',
    'language': 'Bahasa',
    'select_language': 'Pilih Bahasa',
    'about': 'Tentang',
    'about_app': 'Tentang Aplikasi',
    'privacy_policy': 'Kebijakan Privasi',
    'terms_of_service': 'Syarat Layanan',

    // Cart Page
    'my_cart': 'Keranjang Saya',
    'clear_all': 'Hapus Semua',
    'clear_cart': 'Kosongkan Keranjang',
    'confirm_clear_cart':
        'Apakah Anda yakin ingin menghapus semua item dari keranjang?',
    'cancel': 'Batal',
    'delete_all': 'Hapus Semua',
    'empty_cart': 'Keranjang Kosong',
    'add_products': 'Tambahkan produk ke keranjang\nuntuk mulai berbelanja',
    'subtotal': 'Subtotal',
    'shipping': 'Ongkir',
    'total': 'Total',
    'checkout': 'Bayar',
    'payment_success': 'Pembayaran Berhasil!',
    'order_confirmed':
        'Pesanan Anda berhasil dibayar dan segera diantar ke alamat Anda.',
    'thank_you': 'Terima kasih telah berbelanja!',

    // Wishlist Page
    'my_wishlist': 'Favorit Saya',
    'empty_wishlist': 'Favorit Kosong',
    'add_to_wishlist': 'Tambahkan item ke favorit\nuntuk menyimpannya',

    // Orders Page
    'no_orders': 'Belum ada pesanan',
    'delivered': 'Terkirim',
    'order_shipping': 'Dikirim',
    'items': 'item',

    // Login Page
    'welcome_back': 'Selamat Datang!',
    'create_account': 'Buat Akun',
    'sign_in_continue': 'Masuk untuk melanjutkan belanja',
    'sign_up_start': 'Daftar untuk mulai berbelanja',
    'full_name': 'Nama Lengkap',
    'email': 'Email',
    'password': 'Kata Sandi',
    'enter_name': 'Masukkan nama lengkap',
    'enter_email': 'Masukkan email Anda',
    'enter_password': 'Masukkan kata sandi',
    'forgot_password': 'Lupa Kata Sandi?',
    'sign_in': 'Masuk',
    'sign_up': 'Daftar',
    'no_account': 'Belum punya akun? ',
    'have_account': 'Sudah punya akun? ',
    'login_success': 'Login berhasil!',
    'register_success': 'Registrasi berhasil!',
    'login_failed': 'Login gagal. Periksa email dan password.',
    'register_failed': 'Registrasi gagal. Periksa data Anda.',

    // Dialog & Messages
    'login_required': 'Login Diperlukan',
    'please_login': 'Silakan login untuk mengakses fitur ini.',
    'login': 'Masuk',
    'logout_confirm': 'Apakah Anda yakin ingin keluar?',
    'logged_out': 'Berhasil keluar',
    'address_saved': 'Alamat berhasil disimpan!',
    'your_address': 'Alamat Anda',
    'enter_address': 'Masukkan alamat pengiriman',
    'save_address': 'Simpan Alamat',
    'coming_soon': 'Segera hadir!',
    'ok': 'OK',

    // Orders
    'no_orders_yet': 'Belum ada pesanan',
    'pending': 'Menunggu',
    'processing': 'Diproses',
    'cancelled': 'Dibatalkan',

    // Payment Methods
    'no_payment_methods': 'Belum ada metode pembayaran',
    'add_payment_method_hint': 'Tambahkan metode pembayaran untuk checkout lebih cepat',
    'add_payment_method': 'Tambah Metode Pembayaran',
    'payment_type': 'Jenis Pembayaran',
    'credit_card': 'Kartu Kredit',
    'bank_transfer': 'Transfer Bank',
    'name': 'Nama',
    'detail': 'Detail',
    'add': 'Tambah',
    'default': 'Utama',
  };

  String tr(String key) => translations[key] ?? key;
}
