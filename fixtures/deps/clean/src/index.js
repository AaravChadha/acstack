const { z } = require("zod");

const Invoice = z.object({
  id: z.number().int().positive(),
  currency: z.enum(["GBP", "USD", "EUR"]),
  lines: z.array(z.object({ sku: z.string().min(1), pence: z.number().int() })).min(1),
});

function parseInvoice(raw) {
  return Invoice.parse(raw);
}

module.exports = { parseInvoice, Invoice };
