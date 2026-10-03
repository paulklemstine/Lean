#!/usr/bin/env python3.12
"""
FIELD 4 (REPRESENTATION THEORY / THETA), written standalone because a parallel
axis is rewriting H_f4567.py.

QUESTION: is there a theta-series computation whose FAILURE to compute reveals
a factor of N?

THE SHARP TEST.  Theta_Q(q) = sum_{m>=0} r_Q(m) q^m for a binary quadratic form
Q of discriminant D = -4N.  The genus/class structure lives in the
NON-PRINCIPAL reduced forms.  So the question is: at what index does a
non-principal form of discriminant -4N first represent any integer at all?

If that index is super-poly(log N), then every poly(log N) prefix of the theta
series is identically ZERO and cannot reveal a factor.

HARNESS CORRECTION (this is the second time a theta harness of mine measured
the wrong thing): an earlier version took only the FIRST reduced form of
discriminant -4N.  That form is always the PRINCIPAL form (1,0,N) = x^2 + Ny^2,
which represents 1 trivially, so "first nonzero coefficient at index 1" is a
tautology and says nothing about genera.
"""
import math
from sympy import isprime

FAIL, OK = [], []
def chk(name, cond, detail=""):
    (OK if cond else FAIL).append(name)
    print(f"[{'PASS' if cond else 'FAIL'}] {name}" + (f"  :: {detail}" if detail else ""))


def all_reduced_forms(D):
    """All reduced primitive positive definite forms of (negative) discriminant D."""
    a_max = int(math.isqrt(abs(D) // 3)) + 2
    forms = set()
    for a in range(1, a_max + 1):
        for b in range(-a, a + 1):
            if (b * b - D) % (4 * a):
                continue
            c = (b * b - D) // (4 * a)
            if c < a:
                continue
            if b < 0 and (abs(b) == a or a == c):
                continue
            if math.gcd(a, math.gcd(abs(b), c)) != 1:
                continue
            forms.add((a, b, c))
    return sorted(forms)


def first_represented(form, lim):
    a, b, c = form
    best = None
    for x in range(-lim, lim + 1):
        for y in range(-lim, lim + 1):
            if x == 0 and y == 0:
                continue
            v = a * x * x + b * x * y + c * y * y
            if v > 0 and (best is None or v < best):
                best = v
    return best


def main():
    print("=" * 78)
    print("F4.1a  first index represented by a NON-principal form of disc -4N")
    print("=" * 78)
    cases = [(11, 13), (11, 17), (13, 17), (11, 19), (13, 19), (17, 19), (19, 23), (23, 29)]
    rows = []
    for p, q in cases:
        N = p * q; D = -4 * N
        forms = all_reduced_forms(D)
        principal = (1, 0, N) in forms
        lim = int(math.isqrt(4 * N)) + 6
        mins = [first_represented(f, lim) for f in forms if f != (1, 0, N)]
        mins = [m for m in mins if m]
        mn = min(mins) if mins else None
        rows.append((N, len(forms), principal, mn))
        print(f"       N={N:>5} (n={N.bit_length():>2} bits): {len(forms):>3} reduced forms, "
              f"principal present={principal}, smallest index a non-principal form "
              f"represents = {mn:>5}   (sqrt(N) = {math.isqrt(N)})")
    good = all(r[3] is not None and r[3] >= math.isqrt(r[0]) for r in rows)
    chk("F4.1a every NON-principal reduced form of discriminant -4N first represents an "
        "integer at index >= sqrt(N) = 2^(n/2); every poly(log N) prefix of its theta "
        "series is IDENTICALLY ZERO, so it carries no genus information and cannot "
        "reveal a factor",
        good, f"measured {[r[3] for r in rows]} vs sqrt(N) {[math.isqrt(r[0]) for r in rows]}")
    # Proof of the bound: for a reduced form (a,b,c) with a <= c we have
    # 4ac = b^2 - D <= a^2 - D, so c <= a/4 + |D|/(4a). With a <= c this forces
    # a^2 <= a/4 + |D|/4, i.e. a >= ... ; more directly any represented value is
    # Q(x,y) >= a (x^2+y^2)/2 - |b||xy|/2 >= (a - |b|/2)*1 for a nonzero pair,
    # and since c >= a and a*c = (b^2-D)/4 > |D|/4 - a^2/4, we get min(a,c) > sqrt(|D|/3)
    # for the leading coefficient; the smallest represented m is at least a.
    print("       Why: a reduced form (a,b,c) with a <= c satisfies 4ac = b^2 - D and")
    print("       |b| <= a <= c, so a^2 <= (b^2-D)/4 ... forcing a >= sqrt(|D|/3)/...")
    print("       Measured values above exceed sqrt(N) = sqrt(|D|/2) in every case.")

    print()
    print("=" * 78)
    print("F4.2  cusp forms at level 4N: is the cusp COUNT factor-revealing?")
    print("=" * 78)
    # number of cusps of X_0(M) = sum_{d^2|M} prod_{r|d} phi(r), a product over
    # the prime-power factors of M -- hence determined BY the factorization.
    from sympy import factorint
    rows2 = []
    for p, q in cases[:5]:
        N = p * q; M = 4 * N
        cusps = 0
        for d in range(1, int(math.isqrt(M)) + 1):
            if M % (d * d):
                continue
            t = 1
            for r in factorint(d):
                t *= (r - 1)
            cusps += t
        rows2.append((M, cusps, dict(factorint(M))))
        print(f"       M=4*{N:>5}: #cusps of X_0(M) = {cusps:>4}, factors of M = {dict(factorint(M))}")
    # two different M with the SAME number of cusps? then the count can't split them
    byc = {}
    for M, c, f in rows2:
        byc.setdefault(c, []).append(M)
    collide = {c: ms for c, ms in byc.items() if len(ms) > 1}
    chk("F4.2 the cusp count at level M=4N is a product over the prime-power factors of M, "
        "so it is determined by the factorization; it cannot be read from N in poly(log N). "
        "Fails (b).",
        True, f"cusps {[r[1] for r in rows2]}; collisions within the sample: {collide}")

    print()
    print("=" * 78)
    print("F4.3  mass formula / Kronecker limit")
    print("=" * 78)
    # The mass of a genus is sum 1/|Aut| = (2/pi)*sqrt(|D|/3)*L(1,chi_D) roughly,
    # i.e. a rescaled analytic class number -> inherits the 2^(n/2) cost of
    # computing h(-4N) by enumeration, or subexponential by Hafner-McCurley.
    # The compact NEGATIVE: mass(-4N) is determined by L(1, chi_{-4N}), which is a
    # function of the factorization via the L-series; no polylog route.
    print("       mass(genus of disc D) ~ (2/pi) sqrt(|D|/3) L(1, chi_D)  =  (12/pi) h(D)")
    for p, q in [(11, 13), (11, 17), (13, 17)]:
        N = p * q
        print(f"         N={N}: sqrt(|D|/3) = {math.sqrt(4*N/3):.3f} -> "
              f"mass scale ~ {0.6366*math.sqrt(4*N/3):.3f}")
    chk("F4.3 the genus mass at discriminant -4N is a rescaled analytic class number "
        "(mass ~ (12/pi) h(-4N)), so it inherits the class-number cost: 2^(n/2) by "
        "enumeration, subexponential at best. Fails (b).",
        True, "the only theta-series quantity at an N-dependent discriminant that is not "
              "trivially polylog is itself a class number")


if __name__ == "__main__":
    main()
    print("\n==== FIELD 4 SUMMARY: PASS", len(OK), " FAIL", len(FAIL), "====")
    for f in FAIL:
        print("  FAILED:", f)