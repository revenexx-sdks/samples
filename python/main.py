"""Revenexx Python SDK (revenexx_revenexx) sample.

Initializes a client from the REVENEXX_* environment variables and runs a short
tour of representative read calls, printing each result. Read-only — an empty
tenant is fine.
"""

import json
import os
import sys

from revenexx_revenexx.client import Client
from revenexx_revenexx.services.locale import Locale
from revenexx_revenexx.services.products import Products
from revenexx_revenexx.services.channels import Channels
from revenexx_revenexx.services.markets import Markets
from revenexx_revenexx.services.customers import Customers
from revenexx_revenexx.services.orders import Orders
from revenexx_revenexx.services.carts import Carts
from revenexx_revenexx.services.payments import Payments
from revenexx_revenexx.services.inventories import Inventories
from revenexx_revenexx.services.shipping import Shipping
from revenexx_revenexx.services.prices import Prices
from revenexx_revenexx.services.sites import Sites
from revenexx_revenexx.services.apps import Apps
from revenexx_revenexx.services.messaging import Messaging


def main() -> None:
    endpoint = os.environ.get("REVENEXX_API_URL", "https://api.revenexx.com")
    tenant = os.environ.get("REVENEXX_TENANT")
    api_key = os.environ.get("REVENEXX_API_KEY")

    if not tenant or not api_key:
        print(
            "Set REVENEXX_TENANT and REVENEXX_API_KEY (see ../.env.example) before running.",
            file=sys.stderr,
        )
        sys.exit(1)

    client = Client()
    client.set_endpoint(endpoint)
    client.set_tenant(tenant)
    client.set_api_key_auth(api_key)

    locale = Locale(client)
    products = Products(client)
    channels = Channels(client)
    markets = Markets(client)
    customers = Customers(client)
    orders = Orders(client)
    carts = Carts(client)
    payments = Payments(client)
    inventories = Inventories(client)
    shipping = Shipping(client)
    prices = Prices(client)
    sites = Sites(client)
    apps = Apps(client)
    messaging = Messaging(client)

    tour = [
        ("locale.continents", locale.locale_list_continents),
        ("locale.currencies", locale.locale_list_currencies),
        ("products.list", products.products_list),
        ("products.categories", products.products_categories_list),
        ("products.attributes", products.products_attributes_list),
        ("channels.list", channels.channels_list),
        ("markets.list", markets.markets_list),
        ("customers.contacts", customers.customers_contacts_list),
        ("orders.list", orders.orders_list),
        ("carts.list", carts.carts_list),
        ("payments.providersCatalog", payments.payments_providers_catalog),
        ("payments.methods", payments.payments_methods_list),
        ("inventories.stock", inventories.inventories_stock_list),
        ("shipping.methods", shipping.shipping_methods_list),
        ("prices.lists", prices.prices_lists_list),
        ("sites.list", sites.sites_list),
        ("apps.list", apps.apps_list),
        ("messaging.topics", messaging.messaging_list_topics),
    ]

    print(f"Revenexx Python SDK sample → {endpoint} (tenant: {tenant})\n")

    for label, call in tour:
        try:
            result = call()
            dumped = result.model_dump() if hasattr(result, "model_dump") else result
            print(f"✓ {label}: {json.dumps(dumped, indent=2, default=str)}")
        except Exception as error:  # noqa: BLE001 - sample: report and continue
            print(f"✗ {label}: {error}")


if __name__ == "__main__":
    main()
