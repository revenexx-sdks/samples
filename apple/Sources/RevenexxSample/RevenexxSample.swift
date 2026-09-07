// Revenexx Apple SDK sample.
//
// Initializes a client from the REVENEXX_* environment variables and runs a
// short tour of representative read calls, printing each result. Read-only —
// an empty tenant is fine.

import Foundation
import Revenexx

@main
struct RevenexxSample {
    static func main() async {
        let env = ProcessInfo.processInfo.environment
        let endpoint = env["REVENEXX_API_URL"] ?? "https://api.revenexx.com"
        guard let tenant = env["REVENEXX_TENANT"], !tenant.isEmpty,
              let apiKey = env["REVENEXX_API_KEY"], !apiKey.isEmpty else {
            FileHandle.standardError.write(
                Data("Set REVENEXX_TENANT and REVENEXX_API_KEY (see ../.env.example) before running.\n".utf8)
            )
            exit(1)
        }

        let client = Client()
            .setEndpoint(endpoint)
            .setTenant(tenant)
            .setApiKeyAuth(apiKey)

        print("Revenexx Apple SDK sample → \(endpoint) (tenant: \(tenant))\n")

        // One service class per API area. `Locale` is qualified to avoid
        // clashing with Foundation.Locale.
        let locale = Revenexx.Locale(client)
        let products = Products(client)
        let productCategories = ProductsCategories(client)
        let productDataModel = ProductsDataModel(client)
        let channels = Channels(client)
        let markets = Markets(client)
        let contacts = CustomersContacts(client)
        let orders = Orders(client)
        let carts = Carts(client)
        let paymentProviders = PaymentsProviders(client)
        let paymentMethods = PaymentsMethods(client)
        let stock = InventoriesStock(client)
        let shippingMethods = ShippingMethods(client)
        let prices = Prices(client)
        let sites = Sites(client)
        let apps = Apps(client)
        let messaging = Messaging(client)

        await step("locale.continents") { try await locale.localeListContinents() }
        await step("locale.currencies") { try await locale.localeListCurrencies() }
        await step("products.list") { try await products.productsList() }
        await step("products.categories") { try await productCategories.productsCategoriesList() }
        await step("products.attributes") { try await productDataModel.productsAttributesList() }
        await step("channels.list") { try await channels.channelsList() }
        await step("markets.list") { try await markets.marketsList() }
        await step("customers.contacts") { try await contacts.customersContactsList() }
        await step("orders.list") { try await orders.ordersList() }
        await step("carts.list") { try await carts.cartsList() }
        await step("payments.providersCatalog") { try await paymentProviders.paymentsProvidersCatalog() }
        await step("payments.methods") { try await paymentMethods.paymentsMethodsList() }
        await step("inventories.stock") { try await stock.inventoriesStockList() }
        await step("shipping.methods") { try await shippingMethods.shippingMethodsList() }
        await step("prices.lists") { try await prices.pricesListsList() }
        await step("sites.list") { try await sites.sitesList() }
        await step("apps.list") { try await apps.appsList() }
        await step("messaging.channels") { try await messaging.channelIndex() }
    }

    /// Run one tour step, printing success or error and continuing either way.
    static func step(_ label: String, _ call: () async throws -> Any) async {
        do {
            let result = try await call()
            print("✓ \(label): \(result)")
        } catch {
            print("✗ \(label): \(error)")
        }
    }
}
