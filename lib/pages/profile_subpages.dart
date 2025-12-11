import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/firebase_service.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userId;
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    if (userId == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F5F2),
        appBar: AppBar(
          title: Text(
            settings.tr('my_orders'),
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.brown,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            settings.tr('please_login'),
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          settings.tr('my_orders'),
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.brown,
        elevation: 0,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: firebaseService.streamUserOrders(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settings.tr('no_orders_yet'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return GestureDetector(
                onTap: () {
                  // Show order detail dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Order Details',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORD-${order.id.substring(0, 8).toUpperCase()}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Items:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: order.items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = order.items[itemIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            item.productImage,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.image, color: Colors.grey),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: isDark ? Colors.white : Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'x${item.quantity}  •  \$${item.price.toStringAsFixed(2)}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  '\$${order.total.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusText(order.status, settings),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Close',
                            style: GoogleFonts.poppins(
                              color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ORD-${order.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(order.status, settings),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${order.items.length} ${settings.tr('items')}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'shipping':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, SettingsProvider settings) {
    switch (status) {
      case 'delivered':
        return settings.tr('delivered');
      case 'shipping':
        return settings.tr('shipping_order');
      case 'processing':
        return settings.tr('processing');
      case 'cancelled':
        return settings.tr('cancelled');
      default:
        return settings.tr('pending');
    }
  }
}

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final _addressController = TextEditingController();
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location services are disabled. Please enable them.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location permission denied.',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location permission permanently denied. Please enable it in settings.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          _addressController.text = address;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location retrieved successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to get location: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          'Shipping Address',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.brown,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Address',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 4,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your shipping address',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Get Current Location Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                        ),
                      )
                    : Icon(
                        Icons.my_location,
                        color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                      ),
                label: Text(
                  _isLoadingLocation ? 'Getting Location...' : 'Use Current Location',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  authProvider.updateProfile(address: _addressController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Address saved successfully!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Address',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userId;
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final firebaseService = FirebaseService();

    if (userId == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F5F2),
        appBar: AppBar(
          title: Text(
            settings.tr('payment_methods'),
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.brown,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            settings.tr('please_login'),
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          settings.tr('payment_methods'),
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.brown,
        elevation: 0,
      ),
      body: StreamBuilder<List<PaymentMethodModel>>(
        stream: firebaseService.streamPaymentMethods(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final paymentMethods = snapshot.data ?? [];

          if (paymentMethods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settings.tr('no_payment_methods'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.tr('add_payment_method_hint'),
                    style: GoogleFonts.poppins(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: paymentMethods.length,
            itemBuilder: (context, index) {
              final method = paymentMethods[index];
              return Dismissible(
                key: Key(method.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  firebaseService.removePaymentMethod(userId, method.id);
                },
                child: GestureDetector(
                  onTap: () {
                    firebaseService.setDefaultPaymentMethod(userId, method.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: method.isDefault
                          ? Border.all(
                              color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                              width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.brown.shade900
                                : Colors.brown.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getPaymentIcon(method.type),
                            color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                method.detail,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (method.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              settings.tr('default'),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentDialog(context, userId, isDark, settings),
        backgroundColor: isDark ? const Color(0xFFD7A86E) : Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'credit_card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      case 'bank_transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  void _showAddPaymentDialog(
      BuildContext context, String userId, bool isDark, SettingsProvider settings) {
    String selectedType = 'credit_card';
    final nameController = TextEditingController();
    final detailController = TextEditingController();
    final firebaseService = FirebaseService();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          title: Text(
            settings.tr('add_payment_method'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                  decoration: InputDecoration(
                    labelText: settings.tr('payment_type'),
                    labelStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'credit_card',
                      child: Text(
                        settings.tr('credit_card'),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'paypal',
                      child: Text(
                        'PayPal',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'bank_transfer',
                      child: Text(
                        settings.tr('bank_transfer'),
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: settings.tr('name'),
                    labelStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                    hintText: 'e.g., My Visa Card',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailController,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: settings.tr('detail'),
                    labelStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                    hintText: selectedType == 'credit_card'
                        ? '**** **** **** 1234'
                        : selectedType == 'paypal'
                            ? 'email@example.com'
                            : 'Bank - Account Number',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                settings.tr('cancel'),
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    detailController.text.isNotEmpty) {
                  final paymentMethod = PaymentMethodModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: selectedType,
                    name: nameController.text,
                    detail: detailController.text,
                    isDefault: false,
                  );
                  await firebaseService.addPaymentMethod(userId, paymentMethod);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFFD7A86E) : Colors.brown,
              ),
              child: Text(
                settings.tr('add'),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          settings.tr('settings'),
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.brown,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(
                settings.tr('notifications'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                settings.tr('receive_notifications'),
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              value: settings.notifications,
              activeColor: isDark ? const Color(0xFFD7A86E) : Colors.brown,
              activeTrackColor: isDark ? const Color(0xFFD7A86E).withValues(alpha: 0.5) : Colors.brown.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.brown; // Outline color when selected (active)
                  }
                  return Colors.grey.shade100; // Outline color when not selected (inactive)
                },
              ),
              onChanged: (value) {
                settings.setNotifications(value);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Dark Mode
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(
                settings.tr('dark_mode'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                settings.tr('enable_dark_theme'),
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              value: settings.isDarkMode,
              activeColor: isDark ? const Color(0xFFD7A86E) : Colors.brown,
              activeTrackColor: isDark ? const Color(0xFFD7A86E).withValues(alpha: 0.5) : Colors.brown.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.brown; // Outline color when selected (active)
                  }
                  return Colors.grey.shade100; // Outline color when not selected (inactive)
                },
              ),
              onChanged: (value) {
                settings.setDarkMode(value);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Language
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                settings.tr('language'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                settings.languageDisplayName,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDark
                      ? const Color(0xFF2D2D2D)
                      : Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            settings.tr('select_language'),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: Text(
                              'English',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            trailing: settings.language == 'en'
                                ? Icon(
                                    Icons.check,
                                    color: isDark
                                        ? const Color(0xFFD7A86E)
                                        : Colors.brown,
                                  )
                                : null,
                            onTap: () {
                              settings.setLanguage('en');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(
                              'Bahasa Indonesia',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            trailing: settings.language == 'id'
                                ? Icon(
                                    Icons.check,
                                    color: isDark
                                        ? const Color(0xFFD7A86E)
                                        : Colors.brown,
                                  )
                                : null,
                            onTap: () {
                              settings.setLanguage('id');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          Text(
            settings.tr('about'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                  ),
                  title: Text(
                    settings.tr('about_app'),
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Home Decor',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Home Decor',
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                  ),
                  title: Text(
                    settings.tr('privacy_policy'),
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${settings.tr('privacy_policy')} - ${settings.tr('coming_soon')}',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: isDark ? const Color(0xFFD7A86E) : Colors.brown,
                  ),
                  title: Text(
                    settings.tr('terms_of_service'),
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${settings.tr('terms_of_service')} - ${settings.tr('coming_soon')}',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
