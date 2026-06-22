# Revenexx SDK Samples

Minimal, runnable example apps for every released Revenexx SDK. Each sample installs the SDK from
its package registry, initializes a client against your endpoint + tenant, and runs a short **tour**
of representative read calls across the platform (locale, products & PIM, channels, markets,
customers, orders, carts, payments, inventory, shipping, prices, sites, apps, messaging), printing
each result.

These samples consume the **published** SDKs as normal dependencies — they are documentation and
onboarding glue, not generator output.

## Structure

| Directory | SDK | Registry | Instructions |
|---|---|---|---|
| [`web/`](web/) | `@revenexx/sdk` (JS/TS, browser/SSR) | npm | [Web](#web) |
| [`node/`](node/) | `@revenexx/node` | npm | [Node](#node) |
| [`cli/`](cli/) | `@revenexx/cli` | npm | [CLI](#cli) |
| [`php/`](php/) | `revenexx/sdk` | Packagist | [PHP](#php) |
| [`python/`](python/) | `revenexx_revenexx` | PyPI | [Python](#python) |
| [`go/`](go/) | `github.com/revenexx-sdks/go` | Go module proxy (git tags) | [Go](#go) |
| [`rust/`](rust/) | `revenexx` | crates.io | [Rust](#rust) |
| [`apple/`](apple/) | `RevenexxAPIRevenexx` | SwiftPM (git tags) | [Apple](#apple) |
| [`flutter/`](flutter/) | `revenexx` | pub.dev | [Flutter](#flutter) |
| [`android/`](android/) | `com.revenexx:android` | Maven Central | [Android](#android) |

## Configuration

Every sample reads the same environment variables. Copy [`.env.example`](.env.example) to `.env`
and fill it in, then export them (or `source .env`):

```bash
export REVENEXX_API_URL=https://api.revenexx.com   # optional, this is the default
export REVENEXX_TENANT=<your-tenant-slug>
# provide ONE of:
export REVENEXX_JWT=<signed-in-user-JWT>           # production browser/mobile path
export REVENEXX_API_KEY=rvxk_...                   # server-side / trusted path
```

| Variable | Meaning |
|---|---|
| `REVENEXX_API_URL` | API endpoint (the gateway). Defaults to `https://api.revenexx.com`. |
| `REVENEXX_TENANT` | The tenant your requests are scoped to (sent as `X-Revenexx-Tenant`). |
| `REVENEXX_JWT` | A signed-in user's bearer JWT (Zitadel-issued). Production path for browser/mobile. |
| `REVENEXX_API_KEY` | A gateway-managed scoped API key (`rvxk_…`). Server-side / trusted use only. |

### Two auth modes

The SDKs support two authentication methods, and the samples pick whichever you provide (preferring
the JWT):

```
client.setEndpoint(REVENEXX_API_URL).setTenant(REVENEXX_TENANT)
// user-facing browser/mobile apps — per-user bearer JWT:
client.setBearerAuth(`Bearer ${REVENEXX_JWT}`)
// servers / trusted environments — scoped API key:
client.setApiKeyAuth(REVENEXX_API_KEY)
```

The **web** and **node** samples demonstrate this selection in code (set `REVENEXX_JWT` to exercise
the bearer path). See [Web](#web) / [Node](#node).

> **Security:** never commit a real `rvxk_…` key, and never ship an API key in code that runs in a
> browser or on a device — those callers must use a per-user bearer JWT (`setBearerAuth`). API keys
> are for server-side / trusted environments only.

> **Note for Flutter & Android:** these don't read shell env vars at runtime — Flutter takes config
> via `--dart-define` and Android injects it into `BuildConfig` at build time. See their sections.

## What each sample calls

The same tour, in order, across all SDKs (all read-only calls; an empty tenant is fine):

1. `localeListContinents`
2. `localeListCurrencies`
3. `productsList`
4. `productsCategoriesList`
5. `productsAttributesList`
6. `channelsList`
7. `marketsList`
8. `customersContactsList`
9. `ordersList`
10. `cartsList`
11. `paymentsProvidersCatalog`
12. `paymentsMethodsList`
13. `inventoriesStockList`
14. `shippingMethodsList`
15. `pricesListsList`
16. `sitesList`
17. `appsList`
18. `messagingListTopics`

(Method names shown in camelCase; Python/Rust use `snake_case`, Go uses `PascalCase`, the CLI uses
kebab subcommands.)

**Expected output:** one line per call — `✓ <label>: <result>` on success, or `✗ <label>: <message>`
for a call the tenant can't serve. Either way the tour continues to the next call.

## Commerce workflow (write flow)

Beyond the read-only tour, the **web** and **node** samples include an end-to-end **write** workflow
that shows how a real integration is composed — each step feeds the next:

1. **catalog** — `productsList()` → pick a product
2. **cart** — `cartsCreate()`
3. **line item** — `cartsItemsCreate({ cartId, productId, quantity })`
4. **order** — `cartsOrder({ id })`
5. **payment** — `paymentsCreate({ amount, methodCode, currency, cartId, idempotencyKey })`
6. **confirm** — `paymentsConfirm({ id })`

It uses an **idempotency key** on the payment (so a retry can't double-charge) and demonstrates
**write-path error handling** — branching on the SDK error's numeric `code` (auth vs validation vs
conflict vs rate-limit vs server) and aborting the dependent chain on failure.

> This **writes data** — run it against a **sandbox / test tenant**, not production.

```bash
cd web  && npm install && npm run workflow      # tsx workflow.ts
cd node && npm install && npm run workflow      # node workflow.js
```

Set `REVENEXX_PAYMENT_METHOD` to a method code, or leave it unset to use the first one from
`paymentsMethodsList()`. See [Web](#web) / [Node](#node).

## Write operations (create / update / delete)

The runnable samples focus on reads plus the commerce workflow above, but every resource that has a
`…List` also supports **create / update / delete** with a consistent shape: `create` takes the new
object, `update` takes `{ id, …fields }`, `delete` takes `{ id }`. These are **reference snippets**
(TypeScript / Web SDK) — the same methods exist in every SDK (Python/Rust `snake_case`, Go
`PascalCase`, CLI kebab subcommands). They **write data**, so run against a sandbox tenant.

**Products**

```ts
import { Client, Products } from "@revenexx/sdk";

const products = new Products(client); // client configured as in the samples

// create
const created = await products.productsCreate({
  sku: "SKU-001",
  enabled: true,
  // optional: familyId, familyVariantId, attributeValues, parentId, kind, …
});

// update (partial — pass the id plus the fields to change)
await products.productsUpdate({ id: created.id!, sku: "SKU-001-v2" });

// delete
await products.productsDelete({ id: created.id! });
```

**Categories** (categories live under the `Products` service)

```ts
import { Client, Products } from "@revenexx/sdk";

const products = new Products(client);

// create
const category = await products.productsCategoriesCreate({
  code: "outerwear",
  labels: { "en-US": "Outerwear" },
  // optional: parentId, path, position, values
});

// update
await products.productsCategoriesUpdate({ id: category.id!, code: "outerwear-2025" });

// delete
await products.productsCategoriesDelete({ id: category.id! });
```

> The same `…Create` / `…Update` / `…Delete` shape applies to the other writable resources —
> channels, markets, payment methods & providers, shipping methods, price lists, inventory stock,
> attributes, families, and so on.

## Publish status

All ten SDKs will be published to their registries by launch. All npm packages are live (web, node,
cli); the rest are pending their registry/trusted-publisher setup (tracked in DX-50 / DX-51). A
sample only installs end-to-end once its package is live, so until then a pending SDK's CI job fails
at the dependency-resolution step — that's expected, not a sample bug.

| SDK | Registry | Installable today? |
|---|---|---|
| web | npm `@revenexx/sdk@0.0.5` | ✅ published |
| node | npm `@revenexx/node@0.0.2` | ✅ published |
| cli | npm `@revenexx/cli@0.0.4` | ✅ published |
| php | Packagist `revenexx/sdk@0.0.3` | ✅ published |
| python | PyPI | ⏳ pending PyPI publish |
| go | git tags / module proxy | ⏳ pending first tag |
| rust | crates.io | ⏳ pending crates.io publish |
| apple | SwiftPM git tags | ⏳ pending first tag |
| flutter | pub.dev | ⏳ pending pub.dev publish |
| android | Maven Central | ⏳ pending Sonatype publish |

When a package goes live, bump the pinned version in that sample and confirm its CI job turns green.

---

# Samples

All sample commands are run from inside the sample's directory. Set the environment variables from
[Configuration](#configuration) first (Flutter and Android differ — see their sections).

## Web

[`@revenexx/sdk`](https://www.npmjs.com/package/@revenexx/sdk) — JS/TS, usable from the browser or
server-side. This sample runs server-side (Node) for simplicity. Code: [`web/index.ts`](web/index.ts).

- **Prerequisites:** Node.js 18+
- **Run:**
  ```bash
  cd web
  npm install
  npm start            # read-only tour (index.ts via tsx)
  npm run workflow     # write workflow: cart → order → payment (workflow.ts)
  ```
- **Build check (no live calls):** `npm run typecheck` (`tsc --noEmit`, covers both files)

> **Auth:** set `REVENEXX_JWT` to run as a signed-in user via `setBearerAuth` (the production
> browser path); otherwise the sample falls back to `REVENEXX_API_KEY`. Never ship an API key to the
> browser — it's used here only for a self-contained demo.

## Node

[`@revenexx/node`](https://www.npmjs.com/package/@revenexx/node). Code: [`node/index.js`](node/index.js).

- **Prerequisites:** Node.js 18+
- **Run:**
  ```bash
  cd node
  npm install
  npm start            # read-only tour (index.js)
  npm run workflow     # write workflow: cart → order → payment (workflow.js)
  ```
- **Build check (no live calls):** `npm run typecheck` (`node --check` on both files)
- **Auth:** set `REVENEXX_JWT` to use the bearer path, or `REVENEXX_API_KEY` for the server path.

## CLI

[`@revenexx/cli`](https://www.npmjs.com/package/@revenexx/cli) — a scripted command walkthrough. The
CLI resolves credentials directly from the `REVENEXX_*` environment variables. Code:
[`cli/run.sh`](cli/run.sh).

- **Prerequisites:** Node.js 18+
- **Install:** `npm install -g @revenexx/cli@0.0.4` (provides the `revenexx` command), or run via `npx`.
- **Run:**
  ```bash
  cd cli
  bash run.sh
  # or, without a global install:
  REVENEXX_CLI="npx @revenexx/cli" bash run.sh
  ```
  `run.sh` invokes one `revenexx <service> <method>` per tour step (e.g.
  `revenexx locale locale-list-continents`). You can also persist credentials with
  `revenexx login --token <key> --tenant <slug>`.
- **Build check (no live calls):** CI only verifies the CLI installs and is invokable (`revenexx -v`).

## PHP

[`revenexx/sdk`](https://packagist.org/packages/revenexx/sdk) — installed from public Packagist.
Code: [`php/index.php`](php/index.php).

- **Prerequisites:** PHP 8.0+ with the `curl` and `json` extensions, and [Composer](https://getcomposer.org/)
- **Run:**
  ```bash
  cd php
  composer install
  php index.php
  ```
- **Build check (no live calls):** `php -l index.php`

## Python

[`revenexx_revenexx`](https://pypi.org/project/revenexx-revenexx/). Code: [`python/main.py`](python/main.py).

- **Prerequisites:** Python 3.9+
- **Run:**
  ```bash
  cd python
  python -m venv .venv && source .venv/bin/activate
  pip install -r requirements.txt
  python main.py
  ```
- **Build check (no live calls):** `python -m py_compile main.py`

## Go

`github.com/revenexx-sdks/go` — consumed from git tags via the Go module proxy. Code:
[`go/main.go`](go/main.go).

- **Prerequisites:** Go 1.22+
- **Run:**
  ```bash
  cd go
  go mod download
  go run .
  ```
- **Build check (no live calls):** `go build ./...`

## Rust

[`revenexx`](https://crates.io/crates/revenexx) — async; the sample uses
[`tokio`](https://crates.io/crates/tokio). Code: [`rust/src/main.rs`](rust/src/main.rs).

- **Prerequisites:** Rust (stable) with Cargo
- **Run:**
  ```bash
  cd rust
  cargo run
  ```
- **Build check (no live calls):** `cargo build`

## Apple

`RevenexxAPIRevenexx` — Swift, consumed via Swift Package Manager from git tags. The sample is a
small command-line executable, so it builds and runs with plain `swift` (no Xcode project). Code:
[`apple/Sources/RevenexxSample/RevenexxSample.swift`](apple/Sources/RevenexxSample/RevenexxSample.swift).

- **Prerequisites:** Swift 5.7+ (Xcode 14+ on macOS, or a Swift toolchain)
- **Run:**
  ```bash
  cd apple
  swift run
  ```
  The dependency is pinned to `from: "0.0.1"` in `Package.swift`.
- **Build check (no live calls):** `swift build`

> In a shipping iOS app, authenticate with a per-user bearer JWT via
> `client.setBearerAuth("Bearer <jwt>")`, not an embedded API key.

## Flutter

[`revenexx`](https://pub.dev/packages/revenexx) — a minimal Flutter app with a **Run tour** button
that lists each result on screen (and in the console). Code: [`flutter/lib/main.dart`](flutter/lib/main.dart).

- **Prerequisites:** Flutter SDK (3.x), and a device, simulator, or desktop/web target
- **Configure & run:** Flutter apps don't read shell env vars, so config is passed with `--dart-define`:
  ```bash
  cd flutter
  flutter pub get
  flutter run \
    --dart-define=REVENEXX_API_URL=https://api.revenexx.com \
    --dart-define=REVENEXX_TENANT=<your-tenant-slug> \
    --dart-define=REVENEXX_API_KEY=rvxk_...
  ```
- **Build check (no live calls):** `flutter pub get && flutter analyze` (optionally `flutter build web`)

> In a shipping app, authenticate with a per-user bearer JWT via
> `client.setBearerAuth('Bearer <jwt>')`, not an embedded API key.

## Android

`com.revenexx:android` (Maven Central) — a minimal single-screen app that shows each result on
screen and in Logcat. Code:
[`android/app/src/main/java/com/example/revenexxsample/MainActivity.kt`](android/app/src/main/java/com/example/revenexxsample/MainActivity.kt).

- **Prerequisites:** JDK 17, the Android SDK (API 34), and Gradle 8.2+ (or Android Studio)
- **Configure & run:** config is injected into `BuildConfig` from environment variables at build time:
  ```bash
  cd android
  export REVENEXX_API_URL=https://api.revenexx.com   # optional, this is the default
  export REVENEXX_TENANT=<your-tenant-slug>
  export REVENEXX_API_KEY=rvxk_...
  gradle :app:installDebug     # or open in Android Studio and Run
  ```
- **Build check (no live calls):** `gradle :app:assembleDebug`

> This project has no committed Gradle wrapper; CI provisions Gradle directly. Locally, use Android
> Studio's bundled Gradle or a system `gradle`. In a shipping app, authenticate with a per-user
> bearer JWT via `client.setBearerAuth("Bearer <jwt>")`, not an embedded API key.
