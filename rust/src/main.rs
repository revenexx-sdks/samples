//! Revenexx Rust SDK (`revenexx`) sample.
//!
//! Initializes a client from the REVENEXX_* environment variables and runs a
//! short tour of representative read calls, printing each result. Read-only —
//! an empty tenant is fine.

use revenexx::Client;
use std::env;

/// Run one tour step, printing success or error and continuing either way.
macro_rules! step {
    ($label:expr, $call:expr) => {
        match $call.await {
            Ok(value) => println!("✓ {}: {:#?}", $label, value),
            Err(error) => println!("✗ {}: {:?}", $label, error),
        }
    };
}

#[tokio::main]
async fn main() {
    let endpoint =
        env::var("REVENEXX_API_URL").unwrap_or_else(|_| "https://api.revenexx.com".to_string());
    let tenant = env::var("REVENEXX_TENANT").unwrap_or_default();
    let api_key = env::var("REVENEXX_API_KEY").unwrap_or_default();

    if tenant.is_empty() || api_key.is_empty() {
        eprintln!("Set REVENEXX_TENANT and REVENEXX_API_KEY (see ../.env.example) before running.");
        std::process::exit(1);
    }

    let client = Client::new()
        .set_endpoint(&endpoint)
        .set_tenant(&tenant)
        .set_api_key_auth(&api_key);

    println!("Revenexx Rust SDK sample → {endpoint} (tenant: {tenant})\n");

    step!("locale.continents", client.locale().locale_list_continents());
    step!("locale.currencies", client.locale().locale_list_currencies());
    step!("products.list", client.products().products_list());
    step!("products.categories", client.products().products_categories_list());
    step!("products.attributes", client.products().products_attributes_list());
    step!("channels.list", client.channels().channels_list());
    step!("markets.list", client.markets().markets_list());
    step!("customers.contacts", client.customers().customers_contacts_list());
    step!("orders.list", client.orders().orders_list());
    step!("carts.list", client.carts().carts_list());
    step!("payments.providersCatalog", client.payments().payments_providers_catalog());
    step!("payments.methods", client.payments().payments_methods_list());
    step!("inventories.stock", client.inventories().inventories_stock_list());
    step!("shipping.methods", client.shipping().shipping_methods_list());
    step!("prices.lists", client.prices().prices_lists_list());
    step!("sites.list", client.sites().sites_list());
    step!("apps.list", client.apps().apps_list());
    step!("messaging.topics", client.messaging().messaging_list_topics());
}
