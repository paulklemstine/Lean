#!/usr/bin/env python3
"""Independent verification of the `order_mod` bug claim (r52exp/design/dcore.py).

Deliberately does NOT import dcore.py's order_mod except in PART D, where it is
executed under our own harness so we can watch it fail.

Three independent order computations:
  * mine_strip : factor lambda(pq) = lcm(p-1,q-1) once, then strip by repeated
                 pow() tests.  Written from scratch here.
  * mine_bsgs  : baby-step / giant-step.  Algorithmically unrelated to stripping,
                 so agreement between the two is a real check.
  * sympy.n_order : third-party oracle for cross-validation.
"""
import json
import math
import random
import sys
import time
from math import gcd, lcm

from sympy import factorint, isprime, n_order, nextprime

RESULTS = "/home/raver1975/lean/factor-scratch/r52exp/design/results"
OUT = {}


# ---------------------------------------------------------------- mine_strip
def strip_order(a, m, mult):
    """Reduce `mult` to ord_m(a) by dividing out prime factors.

    Invariant we rely on: ord_m(a) | mult, and ord_m(a) | mult/q for a prime q
    dividing mult iff a^(mult/q) = 1 (mod m).  Each successful division strictly
    decreases the exponent, so the loop terminates.
    """
    order = mult
    for q in factorint(mult):
        while order % q == 0 and pow(a, order // q, m) == 1:
            order //= q
    return order


def mine_strip_prime(a, p):
    """ord_p(a) for prime p: divides p-1, not p."""
    return strip_order(a, p, p - 1)


def mine_strip_semiprime(a, n, p, q):
    """ord_n(a) for n = pq semiprime, from the Carmichael function."""
    assert n == p * q and isprime(p) and isprime(q)
    return strip_order(a, n, lcm(p - 1, q - 1))


# ----------------------------------------------------------------- mine_bsgs
def mine_bsgs(a, m, mult):
    """Order of a mod m by baby-step / giant-step.

    Find the least k>0 with a^k = 1 (mod m) given ord_m(a) | mult.
    M = isqrt(mult); baby[j] = a^j for j<M; walk a^(M*i) backwards.
    """
    a %= m
    if a == 1:
        return 1
    # a^mult = 1 (mod m) is guaranteed by the caller's multiple, so a is a unit.
    # Baby steps hold a^j for j in [0,M); giant steps hold a^(iM).  A collision
    # a^(iM) = a^j gives a^(iM - j) = 1, so k = iM - j.  The order k is at most
    # mult <= M^2, so i <= M suffices.
    M = math.isqrt(mult) + 1
    baby = {}
    e = 1
    for j in range(M):
        # Overwrite, so for a repeated value we keep the LARGEST j.  Then
        # k = iM - j is the smallest candidate at this i, and since i ascends
        # the first hit is the true order.
        baby[e] = j
        e = (e * a) % m
    factor = pow(a, M, m)
    e = 1
    for i in range(M + 1):
        j = baby.get(e)
        if j is not None:
            k = i * M - j
            if k > 0 and pow(a, k, m) == 1:
                return k
        e = (e * factor) % m
    raise RuntimeError("bsgs failed: order does not divide the supplied multiple")


# ------------------------------------------------------------- the broken one
def buggy_order_mod(a, m, cap_bits=40):
    """Verbatim copy of r52exp/design/dcore.py:460 order_mod."""
    if gcd(a, m) != 1:
        return 0
    order = m
    fac = factorint(m)
    for q in fac:
        for _ in range(cap_bits):
            if order % q == 0 and pow(a, order // q, m) == 1:
                order //= q
            else:
                break
    return order


# =============================================================== PART A
# Cross-validation: mine_strip vs mine_bsgs vs sympy.n_order, 12-24 bits.
def part_a():
    rng = random.Random(20261004)
    n_pairs = 0
    mismatch_sb = 0   # mine_strip vs mine_bsgs
    mismatch_sv = 0   # mine_strip vs sympy
    mismatch_bv = 0   # mine_bsgs  vs sympy
    bad_examples = []
    bugsame = 0       # buggy == m  (the smoking gun)
    for bits in range(12, 25):
        for _ in range(20):
            p = sympy_nextprime(rng.getrandbits(bits // 2) | 1)
            q = sympy_nextprime(rng.getrandbits(bits - bits // 2) | 1)
            if p == q:
                continue
            n = p * q
            for g in (5, rng.randrange(2, n)):
                if gcd(g, n) != 1:
                    continue
                n_pairs += 1
                lam = lcm(p - 1, q - 1)
                o1 = mine_strip_semiprime(g, n, p, q)
                o2 = mine_bsgs(g % n, n, lam)
                o3 = int(n_order(g, n))
                if o1 != o2:
                    mismatch_sb += 1
                    bad_examples.append(("strip", o1, "bsgs", o2, n, g))
                if o1 != o3:
                    mismatch_sv += 1
                    bad_examples.append(("strip", o1, "sympy", o3, n, g))
                if o2 != o3:
                    mismatch_bv += 1
                # sanity: order must divide lambda and satisfy pow
                assert pow(g, o1, n) == 1
                assert lam % o1 == 0
                if buggy_order_mod(g, n) == n:
                    bugsame += 1
    OUT["A"] = dict(pairs=n_pairs, strip_vs_bsgs=mismatch_sb,
                    strip_vs_sympy=mismatch_sv, bsgs_vs_sympy=mismatch_bv,
                    examples=bad_examples[:5],
                    buggy_returned_n_unchanged=bugsame)
    return OUT["A"]


def sympy_nextprime(x):
    return int(nextprime(x))


# =============================================================== PART B
# The TRUE ord_n(g)/n at 16/20/24/28 bits, g=5 and random g.
def gen_semiprime(bits, rng, tries=400):
    """Independent semiprime generator (balanced, p<q, distinct, ~`bits` bits)."""
    for _ in range(tries):
        p = int(nextprime(rng.getrandbits(bits // 2) | 1))
        q = int(nextprime(rng.getrandbits(bits - bits // 2) | 1))
        if p == q:
            continue
        lo, hi = 2 ** (bits - 1), 2 ** bits
        if lo <= p * q < hi:
            return p * q, min(p, q), max(p, q)
    raise RuntimeError(f"no semiprime at {bits} bits")


def part_b():
    rng = random.Random(777001)
    rows = []
    for bits in (16, 20, 24, 28):
        for gkind in ("g5", "grand"):
            for trial in range(6):
                n, p, q = gen_semiprime(bits, rng)
                g = 5 % n if gkind == "g5" else rng.randrange(2, n)
                if gcd(g, n) != 1:
                    g = rng.randrange(2, n)
                op = mine_strip_prime(g % p, p)
                oq = mine_strip_prime(g % q, q)
                T = lcm(op, oq)
                assert T == mine_strip_semiprime(g, n, p, q) == int(n_order(g, n))
                lam = lcm(p - 1, q - 1)
                rows.append(dict(bits=bits, gkind=gkind, trial=trial, n=n, p=p, q=q,
                                 ord_p=op, ord_q=oq, ord_n=T, lam=lam,
                                 ratio=T / n, ratio_over_64=T / 64.0,
                                 ratio_over_400=T / 400.0,
                                 ord_p_div_p1=op / (p - 1), ord_q_div_q1=oq / (q - 1),
                                 gcd_lam=n // lam,
                                 buggy_on_n=buggy_order_mod(g, n),
                                 buggy_on_p=buggy_order_mod(g % p, p),
                                 buggy_on_q=buggy_order_mod(g % q, q)))
    OUT["B"] = rows
    return rows


# =============================================================== PART C
# Reproduce MM_design 3c's exact numbers and test the hypothesis
# "ord_n(g) == n, i.e. the buggy function returned p and q unchanged".
MM_ORD = {16: 40301, 20: 761029, 24: 11865251, 28: 202715707}


def part_c():
    rows = []
    for bits, reported in MM_ORD.items():
        f = factorint(reported)
        is_two_primes = len(f) == 2 and all(e == 1 for e in f.values())
        pp, qq = (sorted(f) if is_two_primes else (None, None))
        rec = dict(bits=bits, reported_ord=reported,
                   reported_bits=reported.bit_length(),
                   factored=dict(f), is_semiprime=bool(is_two_primes))
        if is_two_primes:
            n = reported  # the reported "order" IS the modulus
            lam = lcm(pp - 1, qq - 1)
            op_true = mine_strip_prime(5 % pp, pp)
            oq_true = mine_strip_prime(5 % qq, qq)
            T_true = lcm(op_true, oq_true)
            rec.update(
                p=pp, q=qq, n_from_product=n,
                lambda_of_n=lam,
                # if order_mod returned p and q unchanged:
                lcm_pq=lcm(pp, qq),
                lcm_pq_equals_reported=(lcm(pp, qq) == reported),
                n_times_lambda_equals_n=(n * lam == n),
                ord_p_g5_true=op_true, ord_q_g5_true=oq_true,
                ord_n_g5_true=T_true, ord_n_g5_over_n=T_true / n,
                buggy_g_on_p_is_p=(buggy_order_mod(5 % pp, pp) == pp),
                buggy_g_on_q_is_q=(buggy_order_mod(5 % qq, qq) == qq),
            )
            # brute check: is ANY g a unit mod n with ord exactly n?
            rec["can_ord_equal_n"] = (lam % n == 0)  # ord|n requires lambda|n; lambda<n
        rows.append(rec)
    OUT["C"] = rows
    return rows


# =============================================================== PART D
# Does the broken function reproduce ord_n/n == 1.000 on fresh semiprimes?
def part_d():
    rng = random.Random(31337)
    rows = []
    for bits in (16, 18, 20, 22):
        for _ in range(4):
            n, p, q = gen_semiprime(bits, rng)
            g = rng.randrange(2, n)
            op = buggy_order_mod(g % p, p)
            oq = buggy_order_mod(g % q, q)
            T = lcm(op, oq)
            T_true = mine_strip_semiprime(g, n, p, q)
            rows.append(dict(bits=bits, n=n, p=p, q=q,
                             buggy_ord_p=op, buggy_ord_q=oq,
                             buggy_ord_p_is_p=(op == p), buggy_ord_q_is_q=(oq == q),
                             buggy_T=T, buggy_ratio=T / n,
                             true_T=T_true, true_ratio=T_true / n,
                             true_over_64=T_true / 64.0))
    OUT["D"] = rows
    return rows


# =============================================================== PART E
# Qualitative check: with the TRUE period, is it still >> the sieve limit 64?
def part_e():
    rng = random.Random(5150)
    worst = None
    rows = []
    for bits in (16, 20, 24, 28, 32):
        n, p, q = gen_semiprime(bits, rng)
        g = 5 % n
        T = mine_strip_semiprime(g, n, p, q)
        rows.append(dict(bits=bits, n=n, ord_n=T, ratio=T / n,
                         over_64=T / 64.0, over_400=T / 400.0))
        if worst is None or T < worst["ord_n"]:
            worst = rows[-1]
    OUT["E"] = dict(rows=rows, smallest_ord_seen=worst)
    return OUT["E"]


if __name__ == "__main__":
    t0 = time.time()
    a = part_a()
    print("== PART A: cross-validation (mine_strip / mine_bsgs / sympy.n_order) ==")
    print(json.dumps(a, indent=1))

    print("\n== PART B: TRUE ord_n(g)/n ==")
    rows = part_b()
    print(f"{'bits':>4} {'g':>5} {'n':>12} {'ord_n':>12} {'ord/n':>8} "
          f"{'/64':>12} {'/400':>12} {'op/(p-1)':>9} {'oq/(q-1)':>9} "
          f"{'buggy(n)':>11} {'buggy==n':>8}")
    for r in rows:
        print(f"{r['bits']:>4} {r['gkind']:>5} {r['n']:>12} {r['ord_n']:>12} "
              f"{r['ratio']:>8.4f} {r['ratio_over_64']:>12.1f} "
              f"{r['ratio_over_400']:>12.1f} {r['ord_p_div_p1']:>9.4f} "
              f"{r['ord_q_div_q1']:>9.4f} {r['buggy_on_n']:>11} "
              f"{str(r['buggy_on_n'] == r['n']):>8}")
    for bits in (16, 20, 24, 28):
        sub = [r for r in rows if r["bits"] == bits]
        rs = sorted(r["ratio"] for r in sub)
        print(f"  {bits} bits: ratio min={rs[0]:.4f} med={rs[len(rs)//2]:.4f} "
              f"max={rs[-1]:.4f}  min(/64)={rs[0]*sub[0]['n']/64:.0f}")

    print("\n== PART C: MM_design 3c reported values ==")
    for r in part_c():
        print(json.dumps(r, default=str))

    print("\n== PART D: buggy function on fresh semiprimes ==")
    for r in part_d():
        print(f"  {r['bits']:>3}b n={r['n']:<12} buggy(op,oq)=({r['buggy_ord_p']},"
              f"{r['buggy_ord_q']}) == (p,q)=({r['p']},{r['q']})? "
              f"{r['buggy_ord_p_is_p'] and r['buggy_ord_q_is_q']}  "
              f"buggy ratio={r['buggy_ratio']:.4f}  true ratio={r['true_ratio']:.4f} "
              f"true/64={r['true_over_64']:.0f}")

    print("\n== PART E: is the TRUE period still >> 64? ==")
    for r in part_e()["rows"]:
        print(f"  {r['bits']:>3}b n={r['n']:<14} ord_n={r['ord_n']:<14} "
              f"ord/n={r['ratio']:.4f}  /64={r['over_64']:.0f}  /400={r['over_400']:.0f}")

    with open("/home/raver1975/lean/factor-scratch/r53exp/synth/verify_order/results.json", "w") as fh:
        json.dump(OUT, fh, indent=1, default=str)
    print(f"\nelapsed {time.time()-t0:.1f}s -> results.json")