#!/usr/bin/env bash
#
# Revenexx CLI (@revenexx/cli) sample.
#
# Runs a short tour of representative read commands. The CLI resolves
# credentials from the REVENEXX_API_URL / REVENEXX_TENANT / REVENEXX_API_KEY
# environment variables (copy ../.env.example to .env and `source` it, or
# export them in your shell).
#
# Use a globally-installed `revenexx`, or set REVENEXX_CLI to run via npx:
#   REVENEXX_CLI="npx @revenexx/cli" bash run.sh
set -uo pipefail

REVENEXX="${REVENEXX_CLI:-revenexx}"

if [[ -z "${REVENEXX_TENANT:-}" || -z "${REVENEXX_API_KEY:-}" ]]; then
  echo "Set REVENEXX_TENANT and REVENEXX_API_KEY (see ../.env.example) before running." >&2
  exit 1
fi

echo "Revenexx CLI sample → ${REVENEXX_API_URL:-https://api.revenexx.com} (tenant: ${REVENEXX_TENANT})"
echo

# Each entry is "<label>|<service> <method>"
tour=(
  "locale.continents|locale locale-list-continents"
  "locale.currencies|locale locale-list-currencies"
  "products.list|products products-list"
  "products.categories|products products-categories-list"
  "products.attributes|products products-attributes-list"
  "channels.list|channels channels-list"
  "markets.list|markets markets-list"
  "customers.contacts|customers customers-contacts-list"
  "orders.list|orders orders-list"
  "carts.list|carts carts-list"
  "payments.providersCatalog|payments payments-providers-catalog"
  "payments.methods|payments payments-methods-list"
  "inventories.stock|inventories inventories-stock-list"
  "shipping.methods|shipping shipping-methods-list"
  "prices.lists|prices prices-lists-list"
  "sites.list|sites sites-list"
  "apps.list|apps apps-list"
  "messaging.topics|messaging messaging-list-topics"
)

for entry in "${tour[@]}"; do
  label="${entry%%|*}"
  cmd="${entry#*|}"
  echo "=== ${label} (revenexx ${cmd}) ==="
  # shellcheck disable=SC2086
  $REVENEXX $cmd || echo "(command failed — continuing)"
  echo
done
