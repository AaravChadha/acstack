const { createClient } = require("fixture-http-client");

// positional form: deprecated in 2.4.0, removed in 3.0.0
const client = createClient("https://api.example.com", { retries: 3 });

async function listInvoices() {
  const page = await client.get("/invoices");
  return page.items;
}

module.exports = { listInvoices };
