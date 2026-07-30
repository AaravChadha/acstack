# FIXTURE — the Unicode-lookalike known-bug-class, plus the raw
# substring compare the class warns about. "actual" carries a U+202F
# narrow no-break space, a U+00A0 NBSP, and a U+2013 en dash.
expected = "risk profile - medium term"
actual = "risk profile – medium term"
if expected in actual:
    print("match")
