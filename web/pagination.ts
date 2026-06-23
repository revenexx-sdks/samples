/**
 * Revenexx Web SDK — pagination example.
 *
 * List endpoints are paginated: every response carries a `page` object
 * ({ limit, offset, returned, total, hasMore }). This walks all pages of
 * products using limit/offset until `hasMore` is false. Read-only.
 */
import { Client, Products } from "@revenexx/sdk";

const endpoint = process.env.REVENEXX_API_URL || "https://api.revenexx.com";
const tenant = process.env.REVENEXX_TENANT;
const apiKey = process.env.REVENEXX_API_KEY;
const jwt = process.env.REVENEXX_JWT;

if (!tenant || (!apiKey && !jwt)) {
  console.error(
    "Set REVENEXX_TENANT plus REVENEXX_JWT or REVENEXX_API_KEY (see ../.env.example).",
  );
  process.exit(1);
}

const client = new Client().setEndpoint(endpoint).setTenant(tenant);
if (jwt) {
  client.setBearerAuth(`Bearer ${jwt}`);
} else {
  client.setApiKeyAuth(apiKey!);
}

const products = new Products(client);

// List responses are `{ items, page }`; the typed method returns `{}`, so we
// describe the envelope shape locally.
interface Page<T> {
  items?: T[];
  page?: {
    limit?: number;
    offset?: number;
    returned?: number;
    total?: number;
    hasMore?: boolean;
  };
}

async function main(): Promise<void> {
  const pageSize = 25;
  let offset = 0;
  let fetched = 0;
  let pageNo = 0;

  console.log(
    `Paginating products → ${endpoint} (tenant: ${tenant}), page size ${pageSize}\n`,
  );

  for (;;) {
    const res = (await products.productsList({
      limit: pageSize,
      offset,
    })) as Page<unknown>;
    const items = res.items ?? [];
    fetched += items.length;
    pageNo += 1;

    const total = res.page?.total;
    console.log(
      `page ${pageNo} (offset ${offset}): ${items.length} items` +
        (total != null ? ` — ${fetched}/${total}` : ` — ${fetched} so far`),
    );

    if (!res.page?.hasMore || items.length === 0) break;
    offset += pageSize;
  }

  console.log(`\n✓ done — ${fetched} products across ${pageNo} page(s)`);
}

main().catch((error: unknown) => {
  console.error(`✗ pagination failed: ${(error as Error).message ?? error}`);
  process.exit(1);
});
