"""
CM-ECM-ORDER: numerical demonstration of the two complex-multiplication
dichotomies and of the residue shadow they cast on semiprimes.

Everything here is elementary and self-contained: point counts of the curves

    E_(-4) : y^2 = x^3 + x          (endomorphisms by the Gaussian integers)
    E_(-3) : y^2 = x^3 + 1          (endomorphisms by the Eisenstein integers)

over the prime fields F_p, and the mutual information between the residue
N mod m of a semiprime N = p*q and various divisibility events attached to the
point counts of its factors.

Results demonstrated
--------------------
 1. a_p = 0 exactly on p = 3 mod 4 for y^2 = x^3 + x  (p odd).
 2. 4 | #E for every odd prime, on both halves, for y^2 = x^3 + x.
 3. On the split half p = 1 mod 4, |a_p| = 2a where p = a^2 + b^2, a odd.
 4. Quadratic twist law: #E + #E^u = 2p + 2 for a non-residue u.
 5. Whole quartic family y^2 = x^3 + A x is supersingular on the inert half.
 6. a_p = 0 exactly on p = 2 mod 3 for y^2 = x^3 + B (any B), p > 3;
    and 3 | #E(y^2 = x^3 + 1) on the split half p = 1 mod 3.
 7. The two dichotomies are independent (they cut the primes along
    independent congruences mod 4 and mod 3).
 8. The residue shadow: a small but positive symmetric mutual information at
    l = 3, 5 for the Gaussian curve, and a vanishing asymmetric
    (which-factor) mutual information -- the factoring null.
 9. On the inert half, stage-1 of the elliptic method on the CM curve is
    literally the p+1 method.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Iterable, Iterator


# ---------------------------------------------------------------------------
# Basic arithmetic utilities
# ---------------------------------------------------------------------------

def primes_up_to(n: int) -> list[int]:
    """All primes <= n by a simple sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(n + 1) if sieve[i]]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p: 0, +1 or -1."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def curve_card(A: int, B: int, p: int) -> int:
    """#E(F_p) for y^2 = x^3 + A x + B, including the point at infinity."""
    total = 1  # point at infinity
    for x in range(p):
        total += 1 + legendre((x * x % p * x + A * x + B) % p, p)
    return total


def cm_card(p: int) -> int:
    """Point count of the Gaussian CM curve y^2 = x^3 + x over F_p."""
    return curve_card(1, 0, p)


def eis_card(p: int) -> int:
    """Point count of the Eisenstein CM curve y^2 = x^3 + 1 over F_p."""
    return curve_card(0, 1, p)


def sum_two_squares(p: int) -> tuple[int, int]:
    """Write p = a^2 + b^2 with a odd, for a prime p = 1 mod 4 (brute force)."""
    for a in range(1, int(math.isqrt(p)) + 1):
        b2 = p - a * a
        b = math.isqrt(b2)
        if b * b == b2:
            return (a, b) if a % 2 == 1 else (b, a)
    raise ValueError(f"{p} is not a sum of two squares")


def non_residue(p: int) -> int:
    """Smallest quadratic non-residue mod p."""
    for u in range(2, p):
        if legendre(u, p) == -1:
            return u
    raise ValueError("no non-residue found")


# ---------------------------------------------------------------------------
# 1-5. The Gaussian curve y^2 = x^3 + x
# ---------------------------------------------------------------------------

def demo_gaussian(limit: int = 400) -> None:
    print("=" * 74)
    print("  THE GAUSSIAN CM CURVE  y^2 = x^3 + x   (D = -4)")
    print("=" * 74)
    ps = [p for p in primes_up_to(limit) if p != 2]

    inert_ok = split_ok = four_ok = gauss_ok = 0
    for p in ps:
        n = cm_card(p)
        a = p + 1 - n
        if p % 4 == 3:
            inert_ok += (a == 0)
        else:
            split_ok += (a != 0)
            g, _ = sum_two_squares(p)
            gauss_ok += (abs(a) == 2 * g and g % 2 == 1)
        four_ok += (n % 4 == 0)

    n_inert = sum(1 for p in ps if p % 4 == 3)
    n_split = len(ps) - n_inert
    print(f"  odd primes tested                       : {len(ps)}")
    print(f"  inert p = 3 mod 4 with a_p = 0          : {inert_ok}/{n_inert}")
    print(f"  split p = 1 mod 4 with a_p != 0         : {split_ok}/{n_split}")
    print(f"  split p with |a_p| = 2a, p = a^2+b^2, a odd : {gauss_ok}/{n_split}")
    print(f"  primes with 4 | #E                      : {four_ok}/{len(ps)}")

    print("\n  sample table (p, #E, a_p, regime):")
    for p in ps[:12]:
        n = cm_card(p)
        a = p + 1 - n
        tag = "supersingular (inert)" if p % 4 == 3 else "ordinary (split)"
        print(f"    p = {p:>3}   #E = {n:>4}   a_p = {a:>4}   {tag}")

    # Quartic family + twist law
    print("\n  whole quartic family y^2 = x^3 + A x on the inert half:")
    fam_tot = sum(p for p in ps if p % 4 == 3 and p < 60)
    fam_ok = sum(
        1 for p in ps if p % 4 == 3 and p < 60 for A in range(p)
        if curve_card(A, 0, p) == p + 1
    )
    print(f"    curves (A, p) with p < 60 inert and #E = p+1 : "
          f"{fam_ok}/{fam_tot}")

    print("\n  quadratic twist law  #E + #E^u = 2p + 2:")
    for p in ps[:8]:
        u = non_residue(p)
        n1 = curve_card(1, 0, p)
        n2 = curve_card(u * u % p, 0, p)
        print(f"    p = {p:>3}:  {n1:>4} + {n2:>4} = {n1 + n2:>4}   "
              f"(2p+2 = {2 * p + 2})   {'OK' if n1 + n2 == 2 * p + 2 else 'FAIL'}")
    print()


# ---------------------------------------------------------------------------
# 6-7. The Eisenstein curve y^2 = x^3 + 1 and independence
# ---------------------------------------------------------------------------

def demo_eisenstein(limit: int = 400) -> None:
    print("=" * 74)
    print("  THE EISENSTEIN CM CURVE  y^2 = x^3 + 1   (D = -3)")
    print("=" * 74)
    ps = [p for p in primes_up_to(limit) if p not in (2, 3)]

    inert_ok = split_ok = three_ok = fam_ok = fam_tot = 0
    for p in ps:
        n = eis_card(p)
        a = p + 1 - n
        if p % 3 == 2:
            inert_ok += (a == 0)
            if p < 80:
                for B in range(1, p):
                    fam_tot += 1
                    fam_ok += (curve_card(0, B, p) == p + 1)
        else:
            split_ok += (a != 0)
            three_ok += (n % 3 == 0)

    n_inert = sum(1 for p in ps if p % 3 == 2)
    n_split = len(ps) - n_inert
    print(f"  primes tested (p > 3)                   : {len(ps)}")
    print(f"  inert p = 2 mod 3 with a_p = 0          : {inert_ok}/{n_inert}")
    print(f"  split p = 1 mod 3 with a_p != 0         : {split_ok}/{n_split}")
    print(f"  split p with 3 | #E                     : {three_ok}/{n_split}")
    print(f"  whole family y^2=x^3+B, p<80 inert, #E=p+1 : {fam_ok}/{fam_tot}")

    print("\n  sample table (p, #E, a_p, regime):")
    for p in ps[:12]:
        n = eis_card(p)
        a = p + 1 - n
        tag = "supersingular (inert)" if p % 3 == 2 else "ordinary (split)"
        print(f"    p = {p:>3}   #E = {n:>4}   a_p = {a:>4}   {tag}")

    print("\n  independence of the two dichotomies:")
    print("    p    a_p(x^3+x)   a_p(x^3+1)")
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        print(f"    {p:>3}   {p + 1 - cm_card(p):>9}   {p + 1 - eis_card(p):>10}")
    counts = Counter(
        (p + 1 - cm_card(p) == 0, p + 1 - eis_card(p) == 0)
        for p in ps
    )
    print("    joint frequencies (Gauss-ss?, Eisenstein-ss?):")
    for key in [(True, True), (True, False), (False, True), (False, False)]:
        print(f"      {str(key):<16} {counts[key]:>4}  "
              f"(expected ~{len(ps) / 4:.0f})")
    print()


# ---------------------------------------------------------------------------
# 8. The residue shadow: mutual information on semiprimes
# ---------------------------------------------------------------------------

def entropy(counts: Iterable[int]) -> float:
    counts = [c for c in counts if c > 0]
    tot = sum(counts)
    return -sum((c / tot) * math.log2(c / tot) for c in counts)


def mutual_information(pairs: list[tuple[int, int]]) -> float:
    """I(X;Y) in bits from a list of (x, y) samples."""
    joint = Counter(pairs)
    px = Counter(x for x, _ in pairs)
    py = Counter(y for _, y in pairs)
    n = len(pairs)
    return sum(
        (c / n) * math.log2((c / n) / ((px[x] / n) * (py[y] / n)))
        for (x, y), c in joint.items()
    )


def demo_shadow(n_samples: int = 4000, bits: int = 14, seed: int = 20260814) -> None:
    print("=" * 74)
    print("  THE RESIDUE SHADOW ON SEMIPRIMES  N = p q")
    print("=" * 74)
    rng = random.Random(seed)
    pool = [p for p in primes_up_to(1 << bits) if p > 1000]

    samples: list[tuple[int, int, int]] = []  # (N, p, q) with p < q
    while len(samples) < n_samples:
        p, q = rng.choice(pool), rng.choice(pool)
        if p == q:
            continue
        p, q = min(p, q), max(p, q)
        samples.append((p * q, p, q))

    cache_cm: dict[int, int] = {}

    def cm(p: int) -> int:
        # only supersingular (inert) primes are counted exactly here; the split
        # half is computed by the Gauss law |a_p| = 2a which is cheap.
        if p in cache_cm:
            return cache_cm[p]
        if p % 4 == 3:
            v = p + 1
        else:
            a, _ = sum_two_squares(p)
            # sign fixed by the quartic residue character of 2; we detect it by
            # checking which of p+1-2a, p+1+2a is 0 mod 4 *and* consistent with
            # a random point's order -- for the divisibility statistics below
            # we simply take the true count via a cheap test.
            v = _cm_card_split(p, a)
        cache_cm[p] = v
        return v

    def _cm_card_split(p: int, a: int) -> int:
        # The order is p+1-2a or p+1+2a; pick the one killing a random point.
        for n in (p + 1 - 2 * a, p + 1 + 2 * a, p + 1 - 2 * (-a), p + 1 + 2 * (-a)):
            if n % 4 == 0 and _kills_random_point(p, n):
                return n
        # fallback: exhaustive (small p only)
        return curve_card(1, 0, p)

    def _kills_random_point(p: int, n: int) -> bool:
        for _ in range(3):
            x = random.randrange(p)
            y2 = (x * x % p * x + x) % p
            if legendre(y2, p) != 1:
                continue
            y = pow(y2, (p + 1) // 4, p) if p % 4 == 3 else _sqrt_mod(y2, p)
            if y is None:
                continue
            if _scalar_mul((x, y), n, p) is not None:
                return False
        return True

    def _sqrt_mod(a: int, p: int) -> int | None:
        if legendre(a, p) != 1:
            return None
        if p % 4 == 3:
            return pow(a, (p + 1) // 4, p)
        # Tonelli-Shanks
        q, s = p - 1, 0
        while q % 2 == 0:
            q //= 2
            s += 1
        z = non_residue(p)
        m, c, t, r = s, pow(z, q, p), pow(a, q, p), pow(a, (q + 1) // 2, p)
        while t != 1:
            i, t2 = 0, t
            while t2 != 1:
                t2 = t2 * t2 % p
                i += 1
            b = pow(c, 1 << (m - i - 1), p)
            m, c = i, b * b % p
            t, r = t * c % p, r * b % p
        return r

    def _add(P, Q, p):
        if P is None:
            return Q
        if Q is None:
            return P
        x1, y1 = P
        x2, y2 = Q
        if x1 == x2 and (y1 + y2) % p == 0:
            return None
        if P == Q:
            lam = (3 * x1 * x1 + 1) * pow(2 * y1, p - 2, p) % p
        else:
            lam = (y2 - y1) * pow(x2 - x1, p - 2, p) % p
        x3 = (lam * lam - x1 - x2) % p
        return (x3, (lam * (x1 - x3) - y1) % p)

    def _scalar_mul(P, k, p):
        R = None
        while k:
            if k & 1:
                R = _add(R, P, p)
            P = _add(P, P, p)
            k >>= 1
        return R

    for ell in (3, 5, 7):
        for modulus in (ell, 4 * ell):
            sym_pairs, asym_pairs, ctrl_pairs = [], [], []
            for N, p, q in samples:
                r = N % modulus
                sym = int(cm(p) % ell == 0 or cm(q) % ell == 0)
                asym = int(cm(p) % ell == 0)      # p is the least factor
                ctrl = int((p - 1) % ell == 0 or (q - 1) % ell == 0)
                sym_pairs.append((r, sym))
                asym_pairs.append((r, asym))
                ctrl_pairs.append((r, ctrl))
            # null threshold: shuffle the labels, keeping the marginals
            shuffled = [s for _, s in sym_pairs]
            null = 0.0
            for _ in range(12):
                rng.shuffle(shuffled)
                null = max(null, mutual_information(
                    [(r, s) for (r, _), s in zip(sym_pairs, shuffled)]))
            print(f"  l = {ell}, residue N mod {modulus}:")
            print(f"    symmetric   I(N mod {modulus}; l | #E_p or l | #E_q) "
                  f"= {mutual_information(sym_pairs):.4f} bits"
                  f"   (shuffled null max {null:.4f})")
            print(f"    asymmetric  I(N mod {modulus}; l | #E_p, least factor) "
                  f"= {mutual_information(asym_pairs):.4f} bits")
            print(f"    control     I(N mod {modulus}; l | p-1 or l | q-1) "
                  f"= {mutual_information(ctrl_pairs):.4f} bits")
    print()


# ---------------------------------------------------------------------------
# 9. The explicit collisions: the which-factor null, in closed form
# ---------------------------------------------------------------------------

def demo_collisions() -> None:
    print("=" * 74)
    print("  EXPLICIT COLLISIONS: THE WHICH-FACTOR BIT IS INVISIBLE")
    print("=" * 74)
    print("  Gaussian curve, l = 3, modulus 12")
    for (p, q) in [(7, 11), (11, 19)]:
        N = p * q
        print(f"    N = {p}*{q} = {N:>4}   N mod 12 = {N % 12}   "
              f"#E({p}) = {cm_card(p):>3}, #E({q}) = {cm_card(q):>3}   "
              f"symmetric = {cm_card(p) % 3 == 0 or cm_card(q) % 3 == 0}   "
              f"least-factor bit = {cm_card(p) % 3 == 0}")
    print("    -> same residue, same symmetric value, opposite least-factor bit.")

    print("\n  even the symmetric bit is only partial (modulus 12):")
    for (p, q) in [(7, 19), (11, 23)]:
        N = p * q
        print(f"    N = {p}*{q} = {N:>4}   N mod 12 = {N % 12}   "
              f"symmetric = {cm_card(p) % 3 == 0 or cm_card(q) % 3 == 0}")

    print("\n  Eisenstein curve, l = 5, modulus 15: the symmetric bit is dead too")
    for (p, q, r, s) in [(17, 47, 11, 29), (17, 23, 29, 59),
                         (17, 11, 23, 29), (23, 11, 17, 29)]:
        print(f"    {p}*{q} = {p*q:>5} (mod 15 = {(p*q) % 15}) sym="
              f"{eis_card(p) % 5 == 0 or eis_card(q) % 5 == 0}   "
              f"vs {r}*{s} = {r*s:>5} (mod 15 = {(r*s) % 15}) sym="
              f"{eis_card(r) % 5 == 0 or eis_card(s) % 5 == 0}")

    print("\n  the symmetric leak that IS live (Gaussian, l = 3):")
    print("    p, q = 3 mod 4 and N = 5 mod 12  =>  3 | #E(p) or 3 | #E(q)")
    ok = tot = 0
    for p in primes_up_to(400):
        for q in primes_up_to(400):
            if p % 4 == 3 and q % 4 == 3 and p < q and (p * q) % 12 == 5:
                tot += 1
                ok += (cm_card(p) % 3 == 0 or cm_card(q) % 3 == 0)
    print(f"    verified on {ok}/{tot} such semiprimes below 400^2")
    print()


# ---------------------------------------------------------------------------
# 10. Stage 1 on the inert half IS the p+1 method
# ---------------------------------------------------------------------------

def demo_stage_one(bound: int = 20, limit: int = 300) -> None:
    print("=" * 74)
    print("  STAGE 1 ON THE INERT HALF IS THE p+1 METHOD")
    print("=" * 74)
    M = 1
    for pr in primes_up_to(bound):
        e = int(math.log(bound) / math.log(pr))
        M *= pr**e
    print(f"  stage-1 multiplier M = lcm of prime powers <= {bound}  "
          f"({len(str(M))} digits)")
    agree = tot = 0
    diff = []
    for p in primes_up_to(limit):
        if p == 2:
            continue
        n = cm_card(p)
        a1 = (M % n == 0)
        a2 = (M % (p + 1) == 0)
        tot += 1
        agree += (a1 == a2)
        if a1 != a2:
            diff.append((p, n, p + 1))
    print(f"  primes where 'M divisible by #E' agrees with 'M divisible by p+1': "
          f"{agree}/{tot}")
    print("  all disagreements occur on the split half p = 1 mod 4:")
    for p, n, pp1 in diff[:10]:
        print(f"    p = {p:>3} (p mod 4 = {p % 4})  #E = {n:>4}  p+1 = {pp1:>4}")
    print()


def main() -> None:
    demo_gaussian()
    demo_eisenstein()
    demo_collisions()
    demo_stage_one()
    demo_shadow()


if __name__ == "__main__":
    main()
