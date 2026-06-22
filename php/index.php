<?php

/**
 * Revenexx PHP SDK (revenexx/sdk) sample.
 *
 * Initializes a client from the REVENEXX_* environment variables and runs a
 * short tour of representative read calls, printing each result. Read-only —
 * an empty tenant is fine.
 */

declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

use RevenexxAPIRevenexx\Client;
use RevenexxAPIRevenexx\Services\Locale;
use RevenexxAPIRevenexx\Services\Products;
use RevenexxAPIRevenexx\Services\Channels;
use RevenexxAPIRevenexx\Services\Markets;
use RevenexxAPIRevenexx\Services\Customers;
use RevenexxAPIRevenexx\Services\Orders;
use RevenexxAPIRevenexx\Services\Carts;
use RevenexxAPIRevenexx\Services\Payments;
use RevenexxAPIRevenexx\Services\Inventories;
use RevenexxAPIRevenexx\Services\Shipping;
use RevenexxAPIRevenexx\Services\Prices;
use RevenexxAPIRevenexx\Services\Sites;
use RevenexxAPIRevenexx\Services\Apps;
use RevenexxAPIRevenexx\Services\Messaging;

$endpoint = getenv('REVENEXX_API_URL') ?: 'https://api.revenexx.com';
$tenant = getenv('REVENEXX_TENANT') ?: '';
$apiKey = getenv('REVENEXX_API_KEY') ?: '';

if ($tenant === '' || $apiKey === '') {
    fwrite(STDERR, "Set REVENEXX_TENANT and REVENEXX_API_KEY (see ../.env.example) before running.\n");
    exit(1);
}

$client = (new Client())
    ->setEndpoint($endpoint)
    ->setTenant($tenant)
    ->setApiKeyAuth($apiKey);

$locale = new Locale($client);
$products = new Products($client);
$channels = new Channels($client);
$markets = new Markets($client);
$customers = new Customers($client);
$orders = new Orders($client);
$carts = new Carts($client);
$payments = new Payments($client);
$inventories = new Inventories($client);
$shipping = new Shipping($client);
$prices = new Prices($client);
$sites = new Sites($client);
$apps = new Apps($client);
$messaging = new Messaging($client);

$tour = [
    ['locale.continents', fn () => $locale->localeListContinents()],
    ['locale.currencies', fn () => $locale->localeListCurrencies()],
    ['products.list', fn () => $products->productsList()],
    ['products.categories', fn () => $products->productsCategoriesList()],
    ['products.attributes', fn () => $products->productsAttributesList()],
    ['channels.list', fn () => $channels->channelsList()],
    ['markets.list', fn () => $markets->marketsList()],
    ['customers.contacts', fn () => $customers->customersContactsList()],
    ['orders.list', fn () => $orders->ordersList()],
    ['carts.list', fn () => $carts->cartsList()],
    ['payments.providersCatalog', fn () => $payments->paymentsProvidersCatalog()],
    ['payments.methods', fn () => $payments->paymentsMethodsList()],
    ['inventories.stock', fn () => $inventories->inventoriesStockList()],
    ['shipping.methods', fn () => $shipping->shippingMethodsList()],
    ['prices.lists', fn () => $prices->pricesListsList()],
    ['sites.list', fn () => $sites->sitesList()],
    ['apps.list', fn () => $apps->appsList()],
    ['messaging.topics', fn () => $messaging->messagingListTopics()],
];

printf("Revenexx PHP SDK sample → %s (tenant: %s)\n\n", $endpoint, $tenant);

foreach ($tour as [$label, $call]) {
    try {
        $result = $call();
        printf("✓ %s: %s\n", $label, json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    } catch (\Throwable $e) {
        printf("✗ %s: %s\n", $label, $e->getMessage());
    }
}
