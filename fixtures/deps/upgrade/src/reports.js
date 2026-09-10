const { createClient } = require("fixture-http-client");

const reports = createClient("https://reports.example.com", { retries: 1 });

async function monthlyTotals(month) {
  const page = await reports.get(`/totals/${month}`);
  return page.total;
}

module.exports = { monthlyTotals };
