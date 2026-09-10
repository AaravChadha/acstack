const { createClient } = require("fixture-http-client");

// options-object form: added in 2.4.0, the only form left in 3.0.0
const client = createClient({ url: "https://api.example.com", retries: 3 });

async function listInvoices() {
  const page = await client.get("/invoices");
  return page.items;
}

module.exports = { listInvoices };
