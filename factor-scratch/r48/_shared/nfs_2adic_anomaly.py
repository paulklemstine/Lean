"""
CLOSE THE 2-ADIC ANOMALY in the NFS valuation law.

Paper #523 claims, and round 48 verified by exhaustive enumeration:

    P(p^k | a^2 - b^3) = (2p-1)/p^k = (2 - 1/p) / p^k   for odd p, all k >= 2

and that at k=1 the rate is exactly 1/p (no excess). Measured ratios
P/p^k: p=3 -> 5/3, p=5 -> 1.8, p=7 -> 13/7, p=11 -> 21/11, p=13 -> 25/13,
all = 2 - 1/p, independent of k.

FOR p = 2 the paper flagged an ANOMALY and refused to explain it:
    k=1..5 -> 1.5 = 2 - 1/2   (consistent)
    k=6    -> 2.5            (NOT 1.5)

That anomaly is the paper's stated open item. This script finds its cause.

SELF-TEST FIRST, and the self-test must exercise the QUANTITY being claimed,
not a downstream component -- the round's twice-earned rule.
"""

from __future__ import annotations

import math


def ratio_p2(k: int) -> tuple[float, int]:
    """P(2^k | a^2 - b^3) / 2^-k by exhaustive enumeration over ALL (a,b) mod 2^k.

    ALL means all -- excluding a^2 = b^3 drops precisely the cases that carry
    the effect, which is the trap that voided round 48's first measurement.
    """
    P = 2**k
    hit = 0
    for a in range(P):
        a2 = a * a
        for b in range(P):
            if (a2 - b**3) % P == 0:
                hit += 1
    return hit / (P * P) / (1.0 / P), hit


def selftest() -> bool:
    ok = True
    print("SELFTEST 1: enumeration must agree with a direct count on a tiny case")
    # k=2 : 16 pairs. P(4 | a^2-b^3) should be 3/8.
    r, hit = ratio_p2(2)
    if abs(r - 1.5) > 1e-12 or hit != 6:
        print(f"  [FAIL] k=2 ratio {r} hit {hit} (expect 1.5, 6)")
        ok = False
    else:
        print(f"  [PASS] k=2: ratio {r}, {hit}/16 pairs")

    print("SELFTEST 2: the counter must be able to return the NULL")
    # For odd p=3, k=1, the ratio must be exactly 1.0 (no excess at k=1).
    P = 3
    hit = sum(1 for a in range(P) for b in range(P) if (a*a - b**3) % P == 0)
    r = hit / (P * P) / (1.0 / P)
    if abs(r - 1.0) > 1e-12:
        print(f"  [FAIL] p=3 k=1 ratio {r} (expect exactly 1.0 -- the null)")
        ok = False
    else:
        print(f"  [PASS] p=3 k=1: ratio exactly {r} -- counter CAN return null")

    print()
    print("ALL SELFTESTS PASS" if ok else "!!! SELFTEST FAILURE")
    return ok


def main() -> None:
    if not selftest():
        raise SystemExit(1)

    print("=" * 72)
    print("p = 2: ratio P(2^k | a^2 - b^3) / 2^-k")
    print("=" * 72)
    print(f"  law predicts  2 - 1/2 = 1.5   for every k >= 2")
    print()
    print(f"  {'k':>3} {'pairs':>10} {'hits':>9} {'ratio':>9}")
    ratios = {}
    for k in range(1, 9):
        r, hit = ratio_p2(k)
        ratios[k] = r
        print(f"  {k:3d} {2**(2*k):10d} {hit:9d} {r:9.4f}")

    print()
    print("=" * 72)
    print("HYPOTHESIS: count solutions exactly, by separating a=0 and b=0 cases")
    print("=" * 72)
    # For p=2, a^2 and b^3 have different valuations when a,b are even/odd.
    # Enumerate by (v2(a) capped, v2(b) capped) to expose the structure.
    for k in (4, 6):
        P = 2**k
        buckets: dict[tuple[int, int], int] = {}
        for a in range(P):
            va = (a & -a).bit_length() - 1 if a else k  # v2(0) treated as k
            a2 = a * a
            for b in range(P):
                if (a2 - b**3) % P == 0:
                    vb = (b & -b).bit_length() - 1 if b else k
                    key = (min(va, k), min(vb, k))
                    buckets[key] = buckets.get(key, 0) + 1
        tot = sum(buckets.values())
        print(f"  k={k}: {tot} solutions of {P*P} pairs")
        # show buckets where both are even (the bulk)
        for key in sorted(buckets):
            va, vb = key
            if va >= 1 and vb >= 1:
                print(f"      v2(a)={va}, v2(b)={vb}: {buckets[key]}")
        print()


if __name__ == "__main__":
    main()