"""
Numerical demonstrations of Frobenius rigidity in cyclotomic rings and of the
structural constraints on Hilbert class field data.

Everything is self-contained: no third-party dependencies, integer arithmetic
only.  Five experiments are performed.

  1. Frobenius congruence.  For a ring endomorphism sigma of Z[zeta_n] with
     sigma(zeta) = zeta^p (p prime), verify sigma(x) = x^p (mod p) for random x.

  2. Frobenius search and rigidity.  At a prime Q of Z[zeta_n] above p (p not
     dividing n), enumerate all phi(n) power maps and confirm that exactly one
     satisfies the Frobenius congruence modulo Q, namely m = p mod n.

  3. Sharpness at a ramified prime.  In Z[i] = Z[zeta_4] at Q = (1+i) the order
     n = 4 lies in Q, and both the identity and complex conjugation are
     arithmetic Frobenius maps at Q: rigidity genuinely needs n not in Q.

  4. Class numbers and Hilbert class field degrees.  Compute h_K for imaginary
     quadratic fields by counting reduced binary quadratic forms; the degree of
     any Hilbert class field of K must equal h_K, and the field is its own
     Hilbert class field exactly when h_K = 1 (the nine Heegner discriminants).

  5. Minkowski discriminant bound.  Confirm |d_K| > 2 for every degree >= 2,
     which is what forces an everywhere-unramified number field to be Q.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Dict, List, Optional, Sequence, Tuple

Poly = List[int]  # dense coefficient list, index = degree, little-endian


# ----------------------------------------------------------------------------
# 1. Polynomial arithmetic over Z and over F_p
# ----------------------------------------------------------------------------

def poly_trim(a: Poly) -> Poly:
    """Remove trailing zero coefficients."""
    b = list(a)
    while b and b[-1] == 0:
        b.pop()
    return b


def poly_add(a: Poly, b: Poly, mod: Optional[int] = None) -> Poly:
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        v = (a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0)
        out[i] = v % mod if mod else v
    return poly_trim(out)


def poly_sub(a: Poly, b: Poly, mod: Optional[int] = None) -> Poly:
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        v = (a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0)
        out[i] = v % mod if mod else v
    return poly_trim(out)


def poly_mul(a: Poly, b: Poly, mod: Optional[int] = None) -> Poly:
    if not a or not b:
        return []
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    if mod:
        out = [c % mod for c in out]
    return poly_trim(out)


def poly_divmod(a: Poly, b: Poly, mod: Optional[int] = None) -> Tuple[Poly, Poly]:
    """Division with remainder; `b` must be monic when working over Z."""
    a = poly_trim(a)
    b = poly_trim(b)
    if not b:
        raise ZeroDivisionError("division by the zero polynomial")
    lead = b[-1]
    if mod:
        inv_lead = pow(lead % mod, -1, mod)
    elif lead not in (1, -1):
        raise ValueError("over Z the divisor must be monic (or -monic)")
    else:
        inv_lead = lead
    q: Poly = [0] * max(0, len(a) - len(b) + 1)
    r = list(a)
    while poly_trim(r) and len(poly_trim(r)) >= len(b):
        r = poly_trim(r)
        shift = len(r) - len(b)
        coeff = (r[-1] * inv_lead) % mod if mod else r[-1] * inv_lead
        q[shift] = coeff % mod if mod else coeff
        for i, bi in enumerate(b):
            r[shift + i] -= coeff * bi
            if mod:
                r[shift + i] %= mod
    return poly_trim(q), poly_trim(r)


def poly_mod(a: Poly, m: Poly, mod: Optional[int] = None) -> Poly:
    return poly_divmod(a, m, mod)[1]


def poly_gcd_modp(a: Poly, b: Poly, p: int) -> Poly:
    a, b = poly_trim(a), poly_trim(b)
    while b:
        a, b = b, poly_mod(a, b, p)
    if a:
        inv = pow(a[-1], -1, p)
        a = [(c * inv) % p for c in a]
    return a


def poly_str(a: Poly, var: str = "z") -> str:
    a = poly_trim(a)
    if not a:
        return "0"
    parts: List[str] = []
    for i in range(len(a) - 1, -1, -1):
        c = a[i]
        if c == 0:
            continue
        if i == 0:
            parts.append(f"{c:+d}")
        elif i == 1:
            parts.append(f"{c:+d}*{var}")
        else:
            parts.append(f"{c:+d}*{var}^{i}")
    return " ".join(parts)


# ----------------------------------------------------------------------------
# 2. Cyclotomic polynomials
# ----------------------------------------------------------------------------

def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def cyclotomic(n: int) -> Poly:
    """Phi_n(X) computed by the recursion X^n - 1 = prod_{d | n} Phi_d(X)."""
    if n == 1:
        return [-1, 1]
    num: Poly = [0] * n + [1]
    num[0] = -1
    for d in divisors(n):
        if d < n:
            num, rem = poly_divmod(num, cyclotomic(d))
            assert not rem, "cyclotomic recursion must divide exactly"
    return num


def euler_phi(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if math.gcd(k, n) == 1)


# ----------------------------------------------------------------------------
# 3. The ring Z[zeta_n] and its power maps
# ----------------------------------------------------------------------------

class CyclotomicRing:
    """The order Z[zeta_n], represented as Z[X] / Phi_n(X)."""

    def __init__(self, n: int) -> None:
        self.n: int = n
        self.phi: Poly = cyclotomic(n)
        self.degree: int = len(self.phi) - 1

    def reduce(self, a: Poly, mod: Optional[int] = None) -> Poly:
        return poly_mod(a, self.phi if mod is None else [c % mod for c in self.phi], mod)

    def mul(self, a: Poly, b: Poly, mod: Optional[int] = None) -> Poly:
        return self.reduce(poly_mul(a, b, mod), mod)

    def power(self, a: Poly, e: int, mod: Optional[int] = None) -> Poly:
        result: Poly = [1]
        base = self.reduce(a, mod)
        while e:
            if e & 1:
                result = self.mul(result, base, mod)
            base = self.mul(base, base, mod)
            e >>= 1
        return result

    def power_map(self, a: Poly, m: int, mod: Optional[int] = None) -> Poly:
        """Apply sigma_m : zeta -> zeta^m to the element a(zeta)."""
        out: Poly = []
        for i, c in enumerate(a):
            if c == 0:
                continue
            term = self.power([0, 1], (i * m) % self.n, mod)
            out = poly_add(out, [(c * t) % mod if mod else c * t for t in term], mod)
        return self.reduce(out, mod)

    def random_element(self, bound: int = 5, rng: Optional[random.Random] = None) -> Poly:
        r = rng or random
        return poly_trim([r.randint(-bound, bound) for _ in range(self.degree)])


# ----------------------------------------------------------------------------
# Experiment 1: the Frobenius congruence sigma(x) = x^p (mod p)
# ----------------------------------------------------------------------------

def frobenius_congruence_defect(ring: CyclotomicRing, x: Poly, p: int) -> Poly:
    """Return sigma_p(x) - x^p in Z[zeta_n]; Theorem A says p divides it."""
    return poly_sub(ring.power_map(x, p), ring.power(x, p))


def experiment_frobenius_congruence(trials: int = 4, seed: int = 20260804) -> None:
    print("=" * 78)
    print("EXPERIMENT 1 -- Frobenius congruence:  sigma_p(x) = x^p  (mod p)")
    print("=" * 78)
    rng = random.Random(seed)
    for n, p in [(5, 3), (7, 2), (8, 5), (12, 7)]:
        ring = CyclotomicRing(n)
        print(f"\n  n = {n:2d}   Phi_n = {poly_str(ring.phi)}   deg = {ring.degree}   p = {p}")
        for _ in range(trials):
            x = ring.random_element(4, rng)
            defect = frobenius_congruence_defect(ring, x, p)
            divisible = all(c % p == 0 for c in defect)
            quotient = [c // p for c in defect]
            status = "OK " if divisible else "FAIL"
            print(f"    [{status}] x = {poly_str(x):<28s} "
                  f"(sigma_p(x) - x^p)/p = {poly_str(quotient)}")
            assert divisible, "Theorem A violated"
    print("\n  All defects are divisible by p, as Theorem A predicts.")


# ----------------------------------------------------------------------------
# Experiment 2: Frobenius search at a prime Q above p, and uniqueness
# ----------------------------------------------------------------------------

def irreducible_factor_mod_p(ring: CyclotomicRing, p: int) -> Poly:
    """A monic irreducible factor g of Phi_n mod p; Q = (p, g(zeta)) is a prime.

    The residue field Z[zeta]/Q is F_p[X]/(g), of size p^deg(g).  We take a
    factor of degree 1 whenever one exists (i.e. when p = 1 mod n), otherwise we
    split off a factor by trial division by all monic polynomials of small
    degree.  For the small parameters used in the demo this is ample.
    """
    f = [c % p for c in ring.phi]
    d = len(f) - 1
    for deg in range(1, d + 1):
        for coeffs in _monic_polys(deg, p):
            q, r = poly_divmod(f, coeffs, p)
            if not r:
                return coeffs
    raise RuntimeError("no factor found")


def _monic_polys(deg: int, p: int):
    """Enumerate monic polynomials of the given degree over F_p."""
    def rec(prefix: List[int], k: int):
        if k == 0:
            yield prefix + [1]
            return
        for c in range(p):
            yield from rec(prefix + [c], k - 1)
    return rec([], deg)


def is_arith_frobenius(ring: CyclotomicRing, m: int, p: int, g: Poly,
                       test_elements: Sequence[Poly]) -> bool:
    """Test sigma_m(x) = x^p mod Q for Q = (p, g(zeta)), on the given elements."""
    for x in test_elements:
        lhs = poly_mod(ring.power_map(x, m, p), g, p)
        rhs = poly_mod(ring.power(x, p, p), g, p)
        if poly_trim(lhs) != poly_trim(rhs):
            return False
    return True


def experiment_frobenius_search(seed: int = 7) -> None:
    print()
    print("=" * 78)
    print("EXPERIMENT 2 -- Frobenius search at Q | p:  exactly one power map wins")
    print("=" * 78)
    rng = random.Random(seed)
    for n, p in [(5, 3), (7, 3), (8, 5), (11, 2), (12, 7)]:
        ring = CyclotomicRing(n)
        g = irreducible_factor_mod_p(ring, p)
        tests = [ring.random_element(3, rng) for _ in range(6)] + [[0, 1], [1, 1]]
        winners = [m for m in range(1, n) if math.gcd(m, n) == 1
                   and is_arith_frobenius(ring, m, p, g, tests)]
        predicted = p % n
        print(f"\n  n = {n:2d}, p = {p}:  residue field F_{p}^{len(g) - 1} "
              f"via g = {poly_str(g, 'X')} mod {p}")
        print(f"    candidates m in (Z/{n})^*  : "
              f"{[m for m in range(1, n) if math.gcd(m, n) == 1]}")
        print(f"    Frobenius maps found       : {winners}")
        print(f"    predicted (m = p mod n)    : [{predicted}]")
        assert winners == [predicted], "Theorem C / rigidity violated"
    print("\n  In every case the Frobenius exists and is unique: it is sigma_p.")


# ----------------------------------------------------------------------------
# Experiment 3: sharpness -- a ramified prime where rigidity fails
# ----------------------------------------------------------------------------

def experiment_ramified_failure() -> None:
    print()
    print("=" * 78)
    print("EXPERIMENT 3 -- sharpness of the hypothesis  n not in Q")
    print("=" * 78)
    # Z[i] = Z[zeta_4], Phi_4 = X^2 + 1, Q = (1 + i) is the ramified prime over 2.
    # Residue field is F_2, so f(Q) = 2, and 4 = -(1+i)^2 * ... lies in Q.
    ring = CyclotomicRing(4)
    p = 2
    g = [1, 1]  # X + 1 : Phi_4 = X^2 + 1 = (X+1)^2 mod 2
    tests = [[0, 1], [1, 1], [1, 0], [2, 3], [-1, 4], [3, -2]]
    identity_ok = is_arith_frobenius(ring, 1, p, g, tests)
    conj_ok = is_arith_frobenius(ring, 3, p, g, tests)
    print("\n  Ring Z[i] = Z[zeta_4],  Phi_4 = X^2 + 1 = (X+1)^2 mod 2 (RAMIFIED)")
    print("  Prime Q = (2, 1+i), residue field F_2, so f(Q) = 2 and 4 lies in Q.")
    print(f"    identity            (m = 1) is a Frobenius at Q : {identity_ok}")
    print(f"    complex conjugation (m = 3) is a Frobenius at Q : {conj_ok}")
    assert identity_ok and conj_ok
    print("\n  Two DISTINCT Frobenius maps: rigidity fails exactly when the order")
    print("  n of zeta is not invertible mod Q.  The hypothesis is necessary.")


# ----------------------------------------------------------------------------
# Experiment 4: class numbers and Hilbert class field degrees
# ----------------------------------------------------------------------------

def class_number_imaginary_quadratic(disc: int) -> int:
    """h(D) for a negative fundamental discriminant D, by counting reduced forms.

    A reduced positive definite form (a, b, c) with b^2 - 4ac = D satisfies
    |b| <= a <= c, and b >= 0 whenever |b| = a or a = c.
    """
    if disc >= 0 or disc % 4 not in (0, 1):
        raise ValueError("D must be a negative discriminant, D = 0 or 1 mod 4")
    count = 0
    a_max = int(math.isqrt(-disc // 3)) + 1
    for a in range(1, a_max + 1):
        for b in range(-a + 1, a + 1):
            num = b * b - disc
            if num % (4 * a):
                continue
            c = num // (4 * a)
            if c < a:
                continue
            if (a == c or abs(b) == a) and b < 0:
                continue
            count += 1
    return count


def fundamental_discriminant(d: int) -> int:
    """Discriminant of Q(sqrt(-d)) for squarefree d > 0."""
    return -d if (-d) % 4 == 1 else -4 * d


def squarefree(m: int) -> bool:
    k = 2
    while k * k <= m:
        if m % (k * k) == 0:
            return False
        k += 1
    return True


def experiment_class_numbers(limit: int = 60) -> None:
    print()
    print("=" * 78)
    print("EXPERIMENT 4 -- class numbers h_K and forced Hilbert class field degree")
    print("=" * 78)
    print("\n  K = Q(sqrt(-d));  any Hilbert class field of K has degree exactly h_K,")
    print("  and equals K itself precisely when h_K = 1.\n")
    print(f"    {'d':>4s} {'disc':>6s} {'h_K':>5s}  {'[H:K] forced':>13s}  trivial?")
    trivial: List[int] = []
    by_class_number: Dict[int, List[int]] = {}
    for d in range(1, limit + 1):
        if not squarefree(d):
            continue
        D = fundamental_discriminant(d)
        h = class_number_imaginary_quadratic(D)
        by_class_number.setdefault(h, []).append(d)
        if h == 1:
            trivial.append(d)
        if d <= 30:
            print(f"    {d:4d} {D:6d} {h:5d}  {h:13d}  {'yes' if h == 1 else 'no'}")
    print(f"\n  Class number one for d <= {limit}: {trivial}")
    print("  (These are the Heegner values: 1, 2, 3, 7, 11, 19, 43, 67, 163.)")
    for h in sorted(by_class_number)[:6]:
        print(f"    h_K = {h}: d = {by_class_number[h][:10]}")
    assert trivial[:7] == [1, 2, 3, 7, 11, 19, 43]


# ----------------------------------------------------------------------------
# Experiment 5: the Minkowski discriminant bound
# ----------------------------------------------------------------------------

def minkowski_discriminant_lower_bound(n: int, r2: int) -> float:
    """(pi/4)^(2 r2) * n^(2n) / (n!)^2 : a lower bound for |d_K| in degree n."""
    return (math.pi / 4.0) ** (2 * r2) * (n ** (2 * n)) / (math.factorial(n) ** 2)


def experiment_minkowski(max_degree: int = 8) -> None:
    print()
    print("=" * 78)
    print("EXPERIMENT 5 -- Minkowski bound forces |d_K| > 2 in degree >= 2")
    print("=" * 78)
    print("\n  An everywhere-unramified number field has trivial different, hence")
    print("  |d_K| = 1.  The bound below shows that is impossible unless n = 1.\n")
    print(f"    {'n':>3s}  {'worst-case r2':>13s}  {'min |d_K| bound':>17s}  > 2 ?")
    for n in range(1, max_degree + 1):
        worst = max(range(0, n // 2 + 1),
                    key=lambda r2: -minkowski_discriminant_lower_bound(n, r2))
        bound = minkowski_discriminant_lower_bound(n, worst)
        flag = "yes" if bound > 2 else "no"
        print(f"    {n:3d}  {worst:13d}  {bound:17.4f}  {flag}")
        if n >= 2:
            assert bound > 2, "Minkowski bound unexpectedly weak"
    print("\n  Hence |d_K| = 1 forces [K:Q] = 1: Q has no unramified extension,")
    print("  so every Hilbert class field datum over Q is trivial, matching h_Q = 1.")


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 78)
    print("#  Frobenius rigidity in cyclotomic rings, and Hilbert class field data")
    print("#" * 78)
    experiment_frobenius_congruence()
    experiment_frobenius_search()
    experiment_ramified_failure()
    experiment_class_numbers()
    experiment_minkowski()
    print()
    print("All experiments completed successfully.")


if __name__ == "__main__":
    main()
