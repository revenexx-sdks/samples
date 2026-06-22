// Revenexx Android SDK (com.revenexx:android) sample.
//
// Initializes a client with the application context and runs a short tour of
// representative read calls, showing each result on screen and logging it.
// Read-only — an empty tenant is fine. Config is injected from environment
// variables at build time (see BuildConfig fields in app/build.gradle).
package com.example.revenexxsample

import android.os.Bundle
import android.util.Log
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.lifecycle.lifecycleScope
import com.revenexx.Client
import com.revenexx.services.Apps
import com.revenexx.services.Carts
import com.revenexx.services.Channels
import com.revenexx.services.Customers
import com.revenexx.services.Inventories
import com.revenexx.services.Locale
import com.revenexx.services.Markets
import com.revenexx.services.Messaging
import com.revenexx.services.Orders
import com.revenexx.services.Payments
import com.revenexx.services.Prices
import com.revenexx.services.Products
import com.revenexx.services.Shipping
import com.revenexx.services.Sites
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var output: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        output = TextView(this).apply { setPadding(32, 32, 32, 32) }
        setContentView(ScrollView(this).apply { addView(output) })

        val endpoint = BuildConfig.REVENEXX_API_URL.ifEmpty { "https://api.revenexx.com" }
        val tenant = BuildConfig.REVENEXX_TENANT
        val apiKey = BuildConfig.REVENEXX_API_KEY

        if (tenant.isEmpty() || apiKey.isEmpty()) {
            log("Set REVENEXX_TENANT and REVENEXX_API_KEY (env vars at build time) before running.")
            return
        }

        val client = Client(applicationContext)
            .setEndpoint(endpoint)
            .setTenant(tenant)
            .setApiKeyAuth(apiKey)

        val locale = Locale(client)
        val products = Products(client)
        val channels = Channels(client)
        val markets = Markets(client)
        val customers = Customers(client)
        val orders = Orders(client)
        val carts = Carts(client)
        val payments = Payments(client)
        val inventories = Inventories(client)
        val shipping = Shipping(client)
        val prices = Prices(client)
        val sites = Sites(client)
        val apps = Apps(client)
        val messaging = Messaging(client)

        lifecycleScope.launch {
            log("Revenexx Android SDK sample → $endpoint (tenant: $tenant)\n")
            step("locale.continents") { locale.localeListContinents() }
            step("locale.currencies") { locale.localeListCurrencies() }
            step("products.list") { products.productsList() }
            step("products.categories") { products.productsCategoriesList() }
            step("products.attributes") { products.productsAttributesList() }
            step("channels.list") { channels.channelsList() }
            step("markets.list") { markets.marketsList() }
            step("customers.contacts") { customers.customersContactsList() }
            step("orders.list") { orders.ordersList() }
            step("carts.list") { carts.cartsList() }
            step("payments.providersCatalog") { payments.paymentsProvidersCatalog() }
            step("payments.methods") { payments.paymentsMethodsList() }
            step("inventories.stock") { inventories.inventoriesStockList() }
            step("shipping.methods") { shipping.shippingMethodsList() }
            step("prices.lists") { prices.pricesListsList() }
            step("sites.list") { sites.sitesList() }
            step("apps.list") { apps.appsList() }
            step("messaging.topics") { messaging.messagingListTopics() }
        }
    }

    /** Run one tour step, logging success or error and continuing either way. */
    private suspend fun step(label: String, block: suspend () -> Any?) {
        try {
            val result = block()
            log("✓ $label: $result")
        } catch (error: Exception) {
            log("✗ $label: ${error.message}")
        }
    }

    private fun log(line: String) {
        Log.d("RevenexxSample", line)
        output.append(line + "\n")
    }
}
