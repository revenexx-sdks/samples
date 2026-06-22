/**
 * Revenexx Web SDK (@revenexx/sdk) sample.
 *
 * Initializes a client from the REVENEXX_* environment variables and runs a
 * short tour of representative read calls, printing each result. Read-only —
 * an empty tenant is fine.
 */
import {
  Client,
  Locale,
  Products,
  Channels,
  Markets,
  Customers,
  Orders,
  Carts,
  Payments,
  Inventories,
  Shipping,
  Prices,
  Sites,
  Apps,
  Messaging,
} from "@revenexx/sdk";

const endpoint = process.env.REVENEXX_API_URL || "https://api.revenexx.com";
const tenant = process.env.REVENEXX_TENANT;
const apiKey = process.env.REVENEXX_API_KEY;
const jwt = process.env.REVENEXX_JWT;

if (!tenant || (!apiKey && !jwt)) {
  console.error(
    "Set REVENEXX_TENANT plus REVENEXX_JWT (preferred for browser apps) or REVENEXX_API_KEY (see ../.env.example).",
  );
  process.exit(1);
}

// Auth: in a real browser app, authenticate the signed-in user with a per-user
// bearer JWT (REVENEXX_JWT) — never ship an API key to the browser. An API key
// is for server-side / trusted use only. We prefer the JWT when one is provided.
const client = new Client().setEndpoint(endpoint).setTenant(tenant);
if (jwt) {
  client.setBearerAuth(`Bearer ${jwt}`);
} else {
  client.setApiKeyAuth(apiKey!);
}

const locale = new Locale(client);
const products = new Products(client);
const channels = new Channels(client);
const markets = new Markets(client);
const customers = new Customers(client);
const orders = new Orders(client);
const carts = new Carts(client);
const payments = new Payments(client);
const inventories = new Inventories(client);
const shipping = new Shipping(client);
const prices = new Prices(client);
const sites = new Sites(client);
const apps = new Apps(client);
const messaging = new Messaging(client);

const tour: [string, () => Promise<unknown>][] = [
  ["locale.continents", () => locale.localeListContinents()],
  ["locale.currencies", () => locale.localeListCurrencies()],
  ["products.list", () => products.productsList()],
  ["products.categories", () => products.productsCategoriesList()],
  ["products.attributes", () => products.productsAttributesList()],
  ["channels.list", () => channels.channelsList()],
  ["markets.list", () => markets.marketsList()],
  ["customers.contacts", () => customers.customersContactsList()],
  ["orders.list", () => orders.ordersList()],
  ["carts.list", () => carts.cartsList()],
  ["payments.providersCatalog", () => payments.paymentsProvidersCatalog()],
  ["payments.methods", () => payments.paymentsMethodsList()],
  ["inventories.stock", () => inventories.inventoriesStockList()],
  ["shipping.methods", () => shipping.shippingMethodsList()],
  ["prices.lists", () => prices.pricesListsList()],
  ["sites.list", () => sites.sitesList()],
  ["apps.list", () => apps.appsList()],
  ["messaging.topics", () => messaging.messagingListTopics()],
];

async function main(): Promise<void> {
  console.log(`Revenexx Web SDK sample → ${endpoint} (tenant: ${tenant})\n`);
  for (const [label, call] of tour) {
    try {
      const result = await call();
      console.log(`✓ ${label}:`, JSON.stringify(result, null, 2));
    } catch (error) {
      console.log(`✗ ${label}:`, (error as Error).message ?? error);
    }
  }
}

main();
