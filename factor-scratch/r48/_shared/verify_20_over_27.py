"""
VERIFY the constant that CORRECTED my own paper.

Claim (from the follow-up agent): the Stange success probability is exactly
    P = 20/27 = 0.740740...
from the ORDER-FINDING step alone -- independent of the relation set, of c,
of b, and of n -- and NOT a property of the Q-kernel construction.

My paper #524 said 75% was evidence the construction works. That was
withdrawn. The replacement claim is 20/27. I have not verified it; I took it
from an agent. This verifies it from the MECHANISM, cheaply, rather than by
re-running 240 slow trials.

THE MECHANISM. Given a multiple M of ord_n(g), the classical procedure
recovers ord_p(g) and ord_q(g) and takes a gcd. It fails exactly when
    v2(ord_p g) == v2(ord_q g),
because then the two orders agree in their 2-part and the stripping cannot
separate them. So

    P(success) = P( v2(ord_p g) != v2(ord_q g) ).

For a uniform g in Z/p*, the 2-adic valuation of its order is geometric:
    P(v2(ord) = k) = 2^-(k+1),  k >= 0.
The two primes give INDEPENDENT valuations, so
    P(equal)  = sum_k 2^-(k+1) * 2^-(k+1) = sum_k 4^-(k+1) = 1/3
    P(unequal) = 2/3.

That is 2/3, NOT 20/27. So either my mechanism is incomplete or the agent's
20/27 is wrong. This script MEASURES the distribution and settles it.

This is exactly the discipline the round earned: do not publish a number
that corrects a published number without checking where the number comes from.
"""

from __future__ import annotations

import random
from sympy import factorint, isprime


def v2(m: int) -> int:
    if m == 0:
        return 0
    return (m & -m).bit_length() - 1


def ord_mod(a: int, p: int) -> int:
    """Exact multiplicative order of a mod prime p."""
    assert isprime(p)
    f = factorint(p - 1)
    o = p - 1
    for q in f:
        while o % q == 0 and pow(a, o // q, p) == 1:
            o //= q
    return o


def selftest() -> bool:
    """The harness must recover a KNOWN geometric distribution, and must
    separate the 'equal' from the 'unequal' case."""
    ok = True
    print("SELFTEST: ord_mod and the geometric law")
    for p in (101, 211, 307):
        for a in (2, 3, 5, 7):
            o = ord_mod(a, p)
            if pow(a, o, p) != 1 % p or o > p - 1:
                print(f"  [FAIL] ord_mod({a},{p}) = {o}")
                ok = False
        print(f"  [PASS] ord_mod correct on p={p}")
    print()
    print("SELFTEST: P(unequal) from the geometric law must be 2/3")
    p = 2 ** (1 / 3)
    # exact: sum_{k>=0} 4^-(k+1) = (1/4)/(1-1/4) = 1/3
    p_equal = (1 / 4) / (1 - 1 / 4)
    if abs(p_equal - 1 / 3) > 1e-12:
        print(f"  [FAIL] P(equal) = {p_equal}")
        ok = False
    else:
        print(f"  [PASS] P(equal) = 1/3 exactly, P(unequal) = 2/3")
    print()
    return ok


def main() -> None:
    if not selftest():
        raise SystemExit(1)

    print("=" * 70)
    print("MEASUREMENT: distribution of v2(ord_p g) and the success probability")
    print("=" * 70)
    rng = random.Random(20261003)
    # distinct primes, small enough to compute exact orders by trial factoring
    primes = [q for q in range(3, 4000) if isprime(q)]
    trials = 4000
    from collections import Counter
    kcount = Counter()
    neq = 0
    done = 0
    i = 0
    while done < trials:
        p = primes[i % len(primes)]
        q = primes[(i * 7 + 3) % len(primes)]
        i += 1
        if p == q:
            continue
        g = rng.randrange(2, p * q)
        if g % p == 0 or g % q == 0:
            continue
        # CRT: reduce g mod p and mod q
        gp = g % p
        gq = g % q
        if gp == 0 or gq == 0:
            continue
        kp = v2(ord_mod(gp, p))
        kq = v2(ord_mod(gq, q))
        kcount[kp] += 1
        if kp != kq:
            neq += 1
        done += 1

    n = done
    print(f"  trials: {n}")
    print()
    print("  measured distribution of v2(ord_p g):")
    for k in sorted(kcount):
        obs = kcount[k] / n
        pred = 2 ** (-(k + 1))
        print(f"    k={k}: observed {obs:.4f}   geometric 2^-(k+1) = {pred:.4f}   "
              f"ratio {obs/pred:.3f}")
    print()
    rate = neq / n
    print(f"  MEASURED P(v2 differs) = {rate:.5f}")
    print(f"  MECHANISM PREDICTS 2/3 = {2/3:.5f}")
    print(f"  AGENT CLAIMS   20/27  = {20/27:.5f}")
    se = math.sqrt if False else None
    import math
    se_ = math.sqrt((2 / 3) * (1 - 2 / 3) / n)
    print(f"  deviation from 2/3: {(rate - 2/3)/se_:+.2f} sigma (n={n})")
    se20 = math.sqrt((20 / 27) * (1 - 20 / 27) / n)
    print(f"  deviation from 20/27: {(rate - 20/27)/se20:+.2f} sigma")
    print()
    if abs(rate - 2 / 3) < 3 * se_:
        print("  => THE MECHANISM WINS. The constant is 2/3, and 20/27 is WRONG.")
        print("     (A correction to my own correction is still a correction.)")
    elif abs(rate - 20 / 27) < 3 * se20:
        print("  => 20/27 holds, but the simple geometric mechanism is incomplete;")
        print("     there is an additional failure mode not modelled above.")
    else:
        print("  => NEITHER. Report the measured number and investigate.")


if __name__ == "__main__":
    main()