// SEEDED FIXTURE for /design-audit's fabricated-content grep (task 4.71).
// Every address below sits in a range RFC 2606 reserves for documentation,
// so none can belong to a real person — which is exactly what makes them
// placeholder data wearing a real-data face. Do NOT "fix" these.
//
// The shipped grep sampled two second-level forms and no reserved TLD, so
// the TLD form sailed past it in shakedown 17 and was caught by a model
// reading the file rather than by the pattern. This comment deliberately
// spells out NO address: a fixture whose prose trips its own detector
// reports a pass it did not earn (known bug class).
export const seats = [
  { name: "A", email: "alexandria.desjardins@really-long-subsidiary.example" },
  { name: "B", email: "ops@example.net" },
  { name: "C", email: "qa@staging.invalid" },
  { name: "D", email: "dev@sandbox.test" },
  { name: "E", email: "root@localhost" },
];

// NEGATIVE TWIN — a plausible real address, and a real domain that merely
// CONTAINS a reserved word. Neither may match, or the grep cries wolf.
export const realContact = "hello@mycompany.io";
export const alsoReal = "billing@testflight.example-corp.io";
