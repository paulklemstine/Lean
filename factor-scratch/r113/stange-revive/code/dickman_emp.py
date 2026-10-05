"""
Independent, EMPIRICAL validation of the Dickman table in cost.py.

rho(u) is defined as the density of y-smooth numbers among integers up to
M = y^u.  So we can just COUNT them: sieve [1,M], mark every multiple of any
prime in (y, M], and read off the surviving fraction.  This uses no part of
cost.py, so it is a genuine external check -- and it simultaneously tests
the assumption the whole cost model rests on, namely that a random residue
mod n is B-smooth with probability ~rho(log n / log B).
"""
import math
import sys

import numpy as np

from cost import log_rho, rho


def primes_upto(n):
    s = np.ones(n + 1, dtype=bool)
    s[:2] = False
    for i in range(2, int(n ** 0.5) + 1):
        if s[i]:
            s[i * i::i] = False
    return np.flatnonzero(s)


def smooth_fraction(M, y):
    """Fraction of integers in [1,M] whose largest prime factor is <= y."""
    pr = primes_upto(M)
    ok = np.ones(M + 1, dtype=bool)
    bad = pr[(pr > y)]
    for p in bad:
        ok[p::p] = False
    return ok[1:].sum() / M, len(bad)


if __name__ == "__main__":
    print("Empirical smooth-number density vs the cost.py Dickman table")
    print("(rho(u) is DEFINED as this density for M = y^u)")
    print()
    print("      M          u         y     measured        rho(u)      ratio")
    rows = []
    for M in (10 ** 6, 10 ** 7, 10 ** 8):
        for u in (2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 7.0):
            y = int(round(M ** (1.0 / u)))
            if y < 2:
                continue
            meas, npr = smooth_fraction(M, y)
            uu = math.log(M) / math.log(y)
            mod = rho(uu)
            ratio = meas / mod if mod > 0 else float("nan")
            rows.append((M, uu, y, meas, mod, ratio))
            print("%10d  %7.3f  %8d   %.6e   %.6e  %8.4f"
                  % (M, uu, y, meas, mod, ratio))
    print()
    good = [r for r in rows if r[3] > 0]
    worst = max(abs(r[5] - 1.0) for r in good)
    print(f"worst |measured/rho - 1| over {len(good)} cells with meas>0: {worst:.4f}")
    # a positive control for the COUNTER itself: u<=1 must give 1.0 exactly
    M = 10 ** 6
    f, _ = smooth_fraction(M, M)
    print(f"POSITIVE CONTROL  smooth_fraction(10^6, 10^6) = {f:.6f}  (want 1.0)")
    # and a negative control: y=2 (only powers of 2) must give ~0
    f2, _ = smooth_fraction(10 ** 6, 2)
    print(f"NEGATIVE CONTROL  smooth_fraction(10^6, 2) = {f2:.6e}  (want ~0)")
    ok = worst < 0.06 and abs(f - 1.0) < 1e-9 and f2 < 1e-4
    print()
    print("VERDICT:", "Dickman table corroborated" if ok else "MISMATCH")
    sys.exit(0 if ok else 1)