"""
POSITIVE + NEGATIVE CONTROL for ecm2.py.

Brief: "Never publish a null without a positive control."  The ECM baseline
harness must be shown to FIRE where the phenomenon is certainly present and to
be exactly verifiable (factor multiplies back to N).

Run: python3 ct_ecm.py
"""
import sys
import time
from sympy import nextprime
from ecm2 import factor_ecm


def make_N(nb, Nbits, seed):
    import random
    rng = random.Random(seed)
    while True:
        p = int(nextprime(rng.randrange(2 ** (nb - 1), 2 ** nb - 1)))
        q = int(nextprime(rng.randrange(2 ** (Nbits - nb - 1), 2 ** (Nbits - nb) - 1)))
        if p != q:
            N = p * q
            assert abs(N.bit_length() - Nbits) <= 1, (N.bit_length(), Nbits)
            return N, p, q


print("== POSITIVE CONTROL: planted factors, harness must fire ==")
print("%-6s %-7s %-7s %-7s %-9s %-24s %s" % ("nbits", "Nbits", "B1", "curves", "time_s", "found", "verified"))
rows = [(30, 700, 2000, 30), (40, 700, 2000, 30), (50, 700, 2000, 30),
        (60, 700, 11000, 30), (70, 800, 11000, 30), (80, 800, 11000, 30)]
allpass = True
for nb, Nbits, B1, nc in rows:
    N, p, q = make_N(nb, Nbits, 9000 + nb)
    f, el, used = factor_ecm(N, B1=B1, ncurves=nc, seed=42 + nb)
    ok = (f is not None and N % f == 0 and f in (p, q))
    allpass &= ok
    print("%-6d %-7d %-7d %-7d %-9.2f %-24s %s" % (nb, Nbits, B1, nc, el, f, ok))
print("POSITIVE CONTROL:", "PASS" if allpass else "FAIL")

print()
print("== NEGATIVE CONTROL: a prime must never be 'factored' ==")
pr = int(nextprime(2 ** 199))
f, el, used = factor_ecm(pr, B1=2000, ncurves=5, seed=1)
print("199-bit prime -> factor returned: %s (must be None)" % f)
assert f is None
print("PASS")
if not allpass:
    sys.exit(1)
print()
print("ALL CONTROLS PASS")
