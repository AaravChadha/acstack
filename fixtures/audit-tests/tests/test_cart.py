"""SEEDED FIXTURE for `/audit tests` (task 4.10) — every test below is
deliberately defective. Do NOT "fix" them: they are the plants that prove
the audit's detection works. scripts/controls.sh asserts they are present.

The suite passes end to end while catching essentially nothing, which is
exactly the condition the audit exists to surface. Written on stdlib
unittest so it runs anywhere python3 does — the pack ships no test
dependency, and a fixture that cannot run proves nothing.

Run: python3 -m unittest discover -s tests
"""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from src.cart import apply_discount, cart_total  # noqa: E402


class TestCart(unittest.TestCase):
    # PLANT 1 — assertion-free. Calls the unit and asserts nothing, so it
    # passes as long as no exception escapes: a smoke test wearing a unit
    # test's name.
    def test_discount_runs(self):
        apply_discount(100, 10)

    # PLANT 2 — tautological. Cannot fail under any implementation.
    def test_discount_is_sane(self):
        self.assertTrue(True)

    # PLANT 3 — passes against deliberately broken code. Asserts only the
    # TYPE, so `return 0.0` or an inverted discount still satisfies it.
    # This is the one a mutation spot-check catches and a skim does not.
    def test_cart_total_returns_a_number(self):
        total = cart_total([{"price": 10.0, "qty": 2}])
        self.assertIsInstance(total, float)


if __name__ == "__main__":
    unittest.main()
