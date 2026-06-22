/**
 * Revenexx Web SDK — end-to-end commerce workflow.
 *
 * A real WRITE flow: browse catalog → create cart → add line item → place
 * order → create & confirm payment. Unlike the read-only tour in index.ts,
 * each step depends on the previous one, so a failure aborts the flow with a
 * typed error (see the catch at the bottom).
 *
 * This WRITES data — run it against a sandbox / test tenant, not production.
 */
import { Client, Products, Carts, Payments } from "@revenexx/sdk";
import { randomUUID } from "node:crypto";

const endpoint = process.env.REVENEXX_API_URL || "https://api.revenexx.com";
const tenant = process.env.REVENEXX_TENANT;
const apiKey = process.env.REVENEXX_API_KEY;
const jwt = process.env.REVENEXX_JWT;
const currency = process.env.REVENEXX_CURRENCY || "EUR";

if (!tenant || (!apiKey && !jwt)) {
  console.error(
    "Set REVENEXX_TENANT plus REVENEXX_JWT (preferred for user-facing apps) or REVENEXX_API_KEY — see ../.env.example.",
  );
  process.exit(1);
}

// Auth: user-facing browser/mobile callers authenticate with a per-user bearer
// JWT; servers and other trusted environments use a scoped API key. Prefer the
// JWT when one is provided.
const client = new Client().setEndpoint(endpoint).setTenant(tenant);
if (jwt) {
  client.setBearerAuth(`Bearer ${jwt}`);
} else {
  client.setApiKeyAuth(apiKey!);
}

const products = new Products(client);
const carts = new Carts(client);
const payments = new Payments(client);

type ListEnvelope<T> = { items?: T[] };

async function resolvePaymentMethod(): Promise<string> {
  if (process.env.REVENEXX_PAYMENT_METHOD) {
    return process.env.REVENEXX_PAYMENT_METHOD;
  }
  const methods = (await payments.paymentsMethodsList()) as ListEnvelope<{
    code?: string;
  }>;
  const code = methods.items?.[0]?.code;
  if (!code) {
    throw new Error(
      "No payment methods configured for this tenant; set REVENEXX_PAYMENT_METHOD.",
    );
  }
  return code;
}

async function main(): Promise<void> {
  console.log(`Revenexx commerce workflow → ${endpoint} (tenant: ${tenant})\n`);

  // 1. Catalog — find a product to buy.
  const catalog = (await products.productsList()) as ListEnvelope<{
    id?: string;
    sku?: string;
  }>;
  const product = catalog.items?.[0];
  if (!product?.id) {
    throw new Error(
      "This tenant has no products; seed one before running the workflow.",
    );
  }
  console.log(`1. product: ${product.id}${product.sku ? ` (${product.sku})` : ""}`);

  // 2. Create a cart.
  const cart = await carts.cartsCreate({ name: "Sample order", currency });
  if (!cart.id) throw new Error("cartsCreate returned no id");
  console.log(`2. cart: ${cart.id}`);

  // 3. Add a line item.
  await carts.cartsItemsCreate({
    cartId: cart.id,
    productId: product.id,
    quantity: 1,
  });
  console.log("3. added 1x line item");

  // 4. Convert the cart into an order.
  const ordered = await carts.cartsOrder({ id: cart.id });
  console.log(`4. placed order (cart status: ${ordered.status ?? "?"})`);

  // 5. Create a payment. The idempotency key makes retrying this exact request
  //    safe — the gateway returns the existing payment instead of charging twice.
  const methodCode = await resolvePaymentMethod();
  const payment = await payments.paymentsCreate({
    amount: ordered.subtotal ?? 0,
    currency,
    methodCode,
    cartId: cart.id,
    idempotencyKey: randomUUID(),
  });
  if (!payment.id) throw new Error("paymentsCreate returned no id");
  console.log(`5. payment: ${payment.id} (${payment.status ?? "?"})`);

  // 6. Confirm the payment.
  const confirmed = await payments.paymentsConfirm({ id: payment.id });
  console.log(`6. confirmed payment (status: ${confirmed.status ?? "?"})`);

  console.log("\n✓ workflow complete");
}

main().catch((error: unknown) => {
  // Write-path error handling: the SDK throws an exception carrying a numeric
  // `code`. We branch on it (auth vs validation vs transient 5xx) by duck-typing
  // rather than importing a specific class, since the exception's name is
  // SDK/version-specific (e.g. RevenexxException vs RevenexxAPIRevenexxException).
  const code =
    error && typeof (error as { code?: unknown }).code === "number"
      ? (error as { code: number }).code
      : undefined;
  if (code !== undefined) {
    const kind =
      code === 401 || code === 403
        ? "auth"
        : code === 404
          ? "not-found"
          : code === 409
            ? "conflict"
            : code === 422
              ? "validation"
              : code === 429
                ? "rate-limit — retry with backoff"
                : code >= 500
                  ? "server — retry with backoff"
                  : "client";
    console.error(`\n✗ workflow failed [${code} ${kind}]: ${(error as Error).message}`);
  } else {
    console.error(`\n✗ workflow failed: ${(error as Error).message ?? error}`);
  }
  process.exit(1);
});
