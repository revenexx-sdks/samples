// Revenexx Flutter SDK (revenexx) sample.
//
// Initializes a client and runs a short tour of representative read calls,
// showing each result on screen and printing it. Read-only — an empty tenant
// is fine.
//
// Config is provided at build/run time with --dart-define, e.g.:
//   flutter run \
//     --dart-define=REVENEXX_TENANT=<slug> \
//     --dart-define=REVENEXX_API_KEY=rvxk_...
import 'package:flutter/material.dart';
// The SDK is imported with a prefix so its `Locale` etc. don't clash with
// Flutter's own types.
import 'package:revenexx/revenexx.dart' as revenexx;

const String endpoint =
    String.fromEnvironment('REVENEXX_API_URL', defaultValue: 'https://api.revenexx.com');
const String tenant = String.fromEnvironment('REVENEXX_TENANT');
const String apiKey = String.fromEnvironment('REVENEXX_API_KEY');

void main() {
  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Revenexx Flutter SDK sample',
      home: TourScreen(),
    );
  }
}

class TourScreen extends StatefulWidget {
  const TourScreen({super.key});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  final List<String> _lines = <String>[];
  bool _running = false;

  Future<void> _runTour() async {
    if (tenant.isEmpty || apiKey.isEmpty) {
      setState(() => _lines
        ..clear()
        ..add('Set REVENEXX_TENANT and REVENEXX_API_KEY via --dart-define before running.'));
      return;
    }

    setState(() {
      _running = true;
      _lines.clear();
    });

    final revenexx.Client client = revenexx.Client()
        .setEndpoint(endpoint)
        .setTenant(tenant)
        .setApiKeyAuth(apiKey);

    final revenexx.Locale locale = revenexx.Locale(client);
    final revenexx.Products products = revenexx.Products(client);
    final revenexx.Channels channels = revenexx.Channels(client);
    final revenexx.Markets markets = revenexx.Markets(client);
    final revenexx.Customers customers = revenexx.Customers(client);
    final revenexx.Orders orders = revenexx.Orders(client);
    final revenexx.Carts carts = revenexx.Carts(client);
    final revenexx.Payments payments = revenexx.Payments(client);
    final revenexx.Inventories inventories = revenexx.Inventories(client);
    final revenexx.Shipping shipping = revenexx.Shipping(client);
    final revenexx.Prices prices = revenexx.Prices(client);
    final revenexx.Sites sites = revenexx.Sites(client);
    final revenexx.Apps apps = revenexx.Apps(client);
    final revenexx.Messaging messaging = revenexx.Messaging(client);

    final List<MapEntry<String, Future<Object?> Function()>> tour =
        <MapEntry<String, Future<Object?> Function()>>[
      MapEntry('locale.continents', () => locale.localeListContinents()),
      MapEntry('locale.currencies', () => locale.localeListCurrencies()),
      MapEntry('products.list', () => products.productsList()),
      MapEntry('products.categories', () => products.productsCategoriesList()),
      MapEntry('products.attributes', () => products.productsAttributesList()),
      MapEntry('channels.list', () => channels.channelsList()),
      MapEntry('markets.list', () => markets.marketsList()),
      MapEntry('customers.contacts', () => customers.customersContactsList()),
      MapEntry('orders.list', () => orders.ordersList()),
      MapEntry('carts.list', () => carts.cartsList()),
      MapEntry('payments.providersCatalog', () => payments.paymentsProvidersCatalog()),
      MapEntry('payments.methods', () => payments.paymentsMethodsList()),
      MapEntry('inventories.stock', () => inventories.inventoriesStockList()),
      MapEntry('shipping.methods', () => shipping.shippingMethodsList()),
      MapEntry('prices.lists', () => prices.pricesListsList()),
      MapEntry('sites.list', () => sites.sitesList()),
      MapEntry('apps.list', () => apps.appsList()),
      MapEntry('messaging.topics', () => messaging.messagingListTopics()),
    ];

    for (final MapEntry<String, Future<Object?> Function()> step in tour) {
      try {
        final Object? result = await step.value();
        _log('✓ ${step.key}: $result');
      } catch (error) {
        _log('✗ ${step.key}: $error');
      }
    }

    setState(() => _running = false);
  }

  void _log(String line) {
    debugPrint(line);
    setState(() => _lines.add(line));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenexx Flutter SDK sample')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _running ? null : _runTour,
        label: Text(_running ? 'Running…' : 'Run tour'),
        icon: const Icon(Icons.play_arrow),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Endpoint: $endpoint'),
          Text('Tenant: ${tenant.isEmpty ? '(unset)' : tenant}'),
          const Divider(),
          for (final String line in _lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(line),
            ),
        ],
      ),
    );
  }
}
