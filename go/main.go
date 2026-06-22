// Revenexx Go SDK (github.com/revenexx-sdks/go) sample.
//
// Initializes a client from the REVENEXX_* environment variables and runs a
// short tour of representative read calls, printing each result. Read-only —
// an empty tenant is fine.
package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/revenexx-sdks/go/apps"
	"github.com/revenexx-sdks/go/carts"
	"github.com/revenexx-sdks/go/channels"
	"github.com/revenexx-sdks/go/client"
	"github.com/revenexx-sdks/go/customers"
	"github.com/revenexx-sdks/go/inventories"
	"github.com/revenexx-sdks/go/locale"
	"github.com/revenexx-sdks/go/markets"
	"github.com/revenexx-sdks/go/messaging"
	"github.com/revenexx-sdks/go/orders"
	"github.com/revenexx-sdks/go/payments"
	"github.com/revenexx-sdks/go/prices"
	"github.com/revenexx-sdks/go/products"
	"github.com/revenexx-sdks/go/shipping"
	"github.com/revenexx-sdks/go/sites"
)

func main() {
	endpoint := os.Getenv("REVENEXX_API_URL")
	if endpoint == "" {
		endpoint = "https://api.revenexx.com"
	}
	tenant := os.Getenv("REVENEXX_TENANT")
	apiKey := os.Getenv("REVENEXX_API_KEY")

	if tenant == "" || apiKey == "" {
		fmt.Fprintln(os.Stderr, "Set REVENEXX_TENANT and REVENEXX_API_KEY (see ../.env.example) before running.")
		os.Exit(1)
	}

	c := client.New(
		client.WithEndpoint(endpoint),
		client.WithTenant(tenant),
		client.WithApiKeyAuth(apiKey),
	)

	loc := locale.New(c)
	prod := products.New(c)
	chan_ := channels.New(c)
	mkt := markets.New(c)
	cust := customers.New(c)
	ord := orders.New(c)
	crt := carts.New(c)
	pay := payments.New(c)
	inv := inventories.New(c)
	ship := shipping.New(c)
	prc := prices.New(c)
	sit := sites.New(c)
	app := apps.New(c)
	msg := messaging.New(c)

	tour := []struct {
		label string
		call  func() (any, error)
	}{
		{"locale.continents", func() (any, error) { return loc.LocaleListContinents() }},
		{"locale.currencies", func() (any, error) { return loc.LocaleListCurrencies() }},
		{"products.list", func() (any, error) { return prod.ProductsList() }},
		{"products.categories", func() (any, error) { return prod.ProductsCategoriesList() }},
		{"products.attributes", func() (any, error) { return prod.ProductsAttributesList() }},
		{"channels.list", func() (any, error) { return chan_.ChannelsList() }},
		{"markets.list", func() (any, error) { return mkt.MarketsList() }},
		{"customers.contacts", func() (any, error) { return cust.CustomersContactsList() }},
		{"orders.list", func() (any, error) { return ord.OrdersList() }},
		{"carts.list", func() (any, error) { return crt.CartsList() }},
		{"payments.providersCatalog", func() (any, error) { return pay.PaymentsProvidersCatalog() }},
		{"payments.methods", func() (any, error) { return pay.PaymentsMethodsList() }},
		{"inventories.stock", func() (any, error) { return inv.InventoriesStockList() }},
		{"shipping.methods", func() (any, error) { return ship.ShippingMethodsList() }},
		{"prices.lists", func() (any, error) { return prc.PricesListsList() }},
		{"sites.list", func() (any, error) { return sit.SitesList() }},
		{"apps.list", func() (any, error) { return app.AppsList() }},
		{"messaging.topics", func() (any, error) { return msg.MessagingListTopics() }},
	}

	fmt.Printf("Revenexx Go SDK sample → %s (tenant: %s)\n\n", endpoint, tenant)

	for _, step := range tour {
		result, err := step.call()
		if err != nil {
			fmt.Printf("✗ %s: %s\n", step.label, err)
			continue
		}
		encoded, _ := json.MarshalIndent(result, "", "  ")
		fmt.Printf("✓ %s: %s\n", step.label, encoded)
	}
}
