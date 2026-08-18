"""
Renormalized factorization of normalized series: numerical demonstrations.

This self-contained script illustrates, by explicit computation, the results of
"Renormalized Factorization of Normalized Series: Realizability, Rigidity, and
Positivity":

  1. Orders add:  a product of m simple-pole series has order -m, and the
     renormalization q^m lands it exactly on order 0.
  2. Realizability: every order-0 target is a renormalized product of m
     simple-pole factors, via the canonical family
        f_0 = q^{-1} g,  f_1 = ... = f_{m-1} = q^{-1}.
  3. Non-uniqueness: for m >= 2, twisting slot 0 by a unit u and slot 1 by
     u^{-1} gives a different factorization of the same target; the units
     1 + q^{n+1} give infinitely many, over every field (including F_2).
  4. Gauge invariance: shifting the pole profile by exponents summing to 0
     leaves the renormalized product untouched.
  5. Finite levels: modulo p^D the fibre over any target has exactly
        ((p-1) p^{D-1})^{m-1}
     elements; the level-to-level ratio is p^{m-1}, and the counting series
     is rational with Euler factor 1 - p^{m-1} T.
  6. Positivity collapse: a nonnegative power series whose inverse is also
     nonnegative must be constant, so the positivity-preserving twist group
     is trivial.

Only the Python standard library is used.  Laurent series are represented
truncated: a pair (val, coeffs) meaning  sum_{j} coeffs[j] * q^(val + j),
with coeffs[0] != 0 for a nonzero series.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product as iter_product
from typing import Dict, List, Sequence, Tuple

Scalar = Fraction
PREC: int = 12  # number of coefficients tracked


# --------------------------------------------------------------------------
# 1. Truncated Laurent series arithmetic
# --------------------------------------------------------------------------


class Laurent:
    """A formal Laurent series truncated to PREC coefficients.

    Represents  sum_{j=0}^{prec-1} coeffs[j] * q^(val + j).
    The zero series is encoded by an empty coefficient list.
    """

    __slots__ = ("val", "coeffs")

    def __init__(self, val: int, coeffs: Sequence[Scalar]) -> None:
        c: List[Scalar] = [Fraction(x) for x in coeffs]
        # normalize: strip leading zeros so that coeffs[0] != 0
        shift = 0
        while shift < len(c) and c[shift] == 0:
            shift += 1
        if shift == len(c):
            self.val: int = 0
            self.coeffs: List[Scalar] = []
        else:
            self.val = val + shift
            self.coeffs = c[shift : shift + PREC]

    # -- basic predicates ---------------------------------------------------

    def is_zero(self) -> bool:
        return len(self.coeffs) == 0

    def order(self) -> float:
        """Order (valuation): the exponent of the lowest nonzero term."""
        return float("inf") if self.is_zero() else float(self.val)

    # -- algebra ------------------------------------------------------------

    def __mul__(self, other: "Laurent") -> "Laurent":
        if self.is_zero() or other.is_zero():
            return Laurent(0, [])
        n = min(PREC, len(self.coeffs) + len(other.coeffs) - 1)
        out: List[Scalar] = [Fraction(0)] * n
        for i, a in enumerate(self.coeffs):
            if i >= n:
                break
            for j, b in enumerate(other.coeffs):
                if i + j >= n:
                    break
                out[i + j] += a * b
        return Laurent(self.val + other.val, out)

    def __add__(self, other: "Laurent") -> "Laurent":
        if self.is_zero():
            return other
        if other.is_zero():
            return self
        lo = min(self.val, other.val)
        hi = max(self.val + len(self.coeffs), other.val + len(other.coeffs))
        out: List[Scalar] = [Fraction(0)] * (hi - lo)
        for j, a in enumerate(self.coeffs):
            out[self.val - lo + j] += a
        for j, b in enumerate(other.coeffs):
            out[other.val - lo + j] += b
        return Laurent(lo, out)

    def inv(self) -> "Laurent":
        """Multiplicative inverse (exists for every nonzero Laurent series)."""
        if self.is_zero():
            raise ZeroDivisionError("the zero series is not invertible")
        a0 = self.coeffs[0]
        out: List[Scalar] = [Fraction(0)] * PREC
        out[0] = Fraction(1) / a0
        for n in range(1, PREC):
            s = Fraction(0)
            for k in range(1, n + 1):
                ak = self.coeffs[k] if k < len(self.coeffs) else Fraction(0)
                s += ak * out[n - k]
            out[n] = -s / a0
        return Laurent(-self.val, out)

    # -- display ------------------------------------------------------------

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Laurent):
            return NotImplemented
        if self.is_zero() or other.is_zero():
            return self.is_zero() and other.is_zero()
        lo = min(self.val, other.val)

        def padded(s: "Laurent") -> List[Scalar]:
            head = [Fraction(0)] * (s.val - lo)
            body = list(s.coeffs)
            return (head + body + [Fraction(0)] * PREC)[:PREC]

        return padded(self) == padded(other)

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        parts: List[str] = []
        for j, a in enumerate(self.coeffs[:5]):
            if a == 0:
                continue
            e = self.val + j
            mono = "1" if e == 0 else (f"q^{e}" if e != 1 else "q")
            parts.append(mono if a == 1 else f"{a}*{mono}")
        return " + ".join(parts) + " + O(q^%d)" % (self.val + min(5, len(self.coeffs)))


def q_pow(e: int) -> Laurent:
    """The monomial q^e."""
    return Laurent(e, [Fraction(1)])


ONE: Laurent = q_pow(0)


def prod(series: Sequence[Laurent]) -> Laurent:
    out = ONE
    for s in series:
        out = out * s
    return out


# --------------------------------------------------------------------------
# 2. Renormalized products, canonical factorization, twists
# --------------------------------------------------------------------------


def renorm_prod(k: int, factors: Sequence[Laurent]) -> Laurent:
    """The renormalized product  q^k * prod_i factors[i]."""
    return q_pow(k) * prod(factors)


def canonical_family(m: int, g: Laurent) -> List[Laurent]:
    """Canonical factorization of an order-0 target g into m simple-pole factors.

    Slot 0 carries q^{-1} g; every other slot carries q^{-1}.
    """
    if m < 1:
        raise ValueError("m must be at least 1")
    return [q_pow(-1) * g] + [q_pow(-1) for _ in range(m - 1)]


def canonical_family_profile(k: int, m: int, d: Sequence[int], g: Laurent) -> List[Laurent]:
    """Canonical factorization with prescribed pole profile d and exponent k.

    Requires order(g) == k + sum(d).  Slots 1..m-1 carry pure monomials q^{d_i};
    slot 0 absorbs the remainder.
    """
    tail_sum = sum(d[1:m])
    f0 = g * q_pow(-k - tail_sum)
    return [f0] + [q_pow(d[i]) for i in range(1, m)]


def two_slot_twist(u: Laurent, factors: Sequence[Laurent]) -> List[Laurent]:
    """Multiply slot 0 by u and slot 1 by u^{-1}; leave the rest alone."""
    out = list(factors)
    out[0] = u * out[0]
    out[1] = u.inv() * out[1]
    return out


def unit_at(n: int) -> Laurent:
    """The distinguished order-0 unit 1 + q^{n+1}."""
    return ONE + q_pow(n + 1)


def gauge_transform(e: Sequence[int], factors: Sequence[Laurent]) -> List[Laurent]:
    """Monomial gauge transformation f_i -> f_i * q^{e_i}."""
    return [f * q_pow(ei) for f, ei in zip(factors, e)]


# --------------------------------------------------------------------------
# 3. Finite-level fibre counts over Z/p^D
# --------------------------------------------------------------------------


def units_mod(n: int) -> List[int]:
    """The unit group (Z/n)^x as a sorted list of residues."""
    from math import gcd

    return [a for a in range(1, n) if gcd(a, n) == 1]


def euler_phi_prime_power(p: int, D: int) -> int:
    """phi(p^D) = (p-1) p^{D-1}."""
    return (p - 1) * p ** (D - 1)


def fibre_count_bruteforce(p: int, D: int, n: int, g: int) -> int:
    """Brute-force count of tuples (f_0,...,f_n) in ((Z/p^D)^x)^{n+1} with product g."""
    mod = p**D
    U = units_mod(mod)
    count = 0
    for tup in iter_product(U, repeat=n + 1):
        r = 1
        for x in tup:
            r = (r * x) % mod
        if r == g % mod:
            count += 1
    return count


def fibre_count_formula(p: int, D: int, n: int) -> int:
    """Closed form:  ((p-1) p^{D-1})^n."""
    return euler_phi_prime_power(p, D) ** n


def fibre_enumerate(p: int, D: int, n: int, g: int) -> List[Tuple[int, ...]]:
    """Enumerate the fibre by choosing slots 1..n freely and forcing slot 0."""
    mod = p**D
    U = units_mod(mod)
    out: List[Tuple[int, ...]] = []
    for tail in iter_product(U, repeat=n):
        r = 1
        for x in tail:
            r = (r * x) % mod
        f0 = (g * pow(r, -1, mod)) % mod
        out.append((f0,) + tail)
    return out


def euler_factor_lhs_rhs(p: int, n: int, N: int, T: Fraction) -> Tuple[Fraction, Fraction]:
    """Both sides of  (1 - p^n T) * sum_{D<N} ((p-1)p^D)^n T^{D+1}
                     =  (p-1)^n T (1 - (p^n T)^N)."""
    lhs = (1 - Fraction(p**n) * T) * sum(
        (Fraction(((p - 1) * p**D) ** n) * T ** (D + 1) for D in range(N)), Fraction(0)
    )
    rhs = Fraction((p - 1) ** n) * T * (1 - (Fraction(p**n) * T) ** N)
    return lhs, rhs


# --------------------------------------------------------------------------
# 4. Positivity: nonnegative power series with nonnegative inverse
# --------------------------------------------------------------------------


def power_series_inverse(u: Sequence[Fraction], prec: int) -> List[Fraction]:
    """Coefficients of 1/u for a power series u with u[0] != 0."""
    if u[0] == 0:
        raise ZeroDivisionError("constant term must be nonzero")
    v: List[Fraction] = [Fraction(0)] * prec
    v[0] = Fraction(1) / u[0]
    for n in range(1, prec):
        s = Fraction(0)
        for k in range(1, n + 1):
            uk = u[k] if k < len(u) else Fraction(0)
            s += uk * v[n - k]
        v[n] = -s / u[0]
    return v


def is_nonnegative(coeffs: Sequence[Fraction]) -> bool:
    return all(c >= 0 for c in coeffs)


# --------------------------------------------------------------------------
# 5. Demonstrations
# --------------------------------------------------------------------------


def demo_orders_add() -> None:
    print("=" * 74)
    print("1.  Orders add: m simple poles give order -m; q^m restores order 0")
    print("=" * 74)
    factors = [
        q_pow(-1) * (ONE + q_pow(1)),                       # order -1
        q_pow(-1) * (ONE + Laurent(2, [Fraction(3)])),      # order -1
        q_pow(-1) * (ONE + q_pow(1) + q_pow(4)),            # order -1
    ]
    for i, f in enumerate(factors):
        print(f"   order(f_{i}) = {f.order():>4}   f_{i} = {f}")
    m = len(factors)
    print(f"   order(prod)          = {prod(factors).order()}   (predicted {-m})")
    g = renorm_prod(m, factors)
    print(f"   order(q^{m} * prod)    = {g.order()}   (predicted 0)")
    print(f"   renormalized product = {g}\n")


def demo_realizability() -> None:
    print("=" * 74)
    print("2.  Realizability: every order-0 target is realized, for every m")
    print("=" * 74)
    g = ONE + Laurent(1, [Fraction(1, 2)]) + q_pow(3)
    print(f"   target g = {g},  order(g) = {g.order()}")
    for m in range(1, 6):
        f = canonical_family(m, g)
        ok_norm = all(fi.order() == -1.0 for fi in f)
        ok_prod = renorm_prod(m, f) == g
        print(f"   m = {m}: all factors simple poles? {ok_norm};  q^{m}*prod == g? {ok_prod}")
    print("   Obstruction check: a target of nonzero order is never realizable.")
    for target in (q_pow(1), q_pow(-1), Laurent(2, [Fraction(5)])):
        print(f"     order({target}) = {target.order():>4}  ->  realizable: "
              f"{target.order() == 0.0}")
    print()


def demo_nonuniqueness() -> None:
    print("=" * 74)
    print("3.  Non-uniqueness for m >= 2: twisting by units 1 + q^(n+1)")
    print("=" * 74)
    g = ONE + q_pow(2)
    m = 3
    base = canonical_family(m, g)
    seen: List[List[Laurent]] = [base]
    print(f"   target g = {g},  m = {m}")
    print(f"   canonical:      slot0 = {base[0]}")
    for n in range(4):
        u = unit_at(n)
        tw = two_slot_twist(u, base)
        same_target = renorm_prod(m, tw) == g
        normalized = all(fi.order() == -1.0 for fi in tw)
        distinct = all(tw[0] != s[0] for s in seen)
        seen.append(tw)
        print(f"   u = 1 + q^{n+1}:  slot0 = {tw[0]}")
        print(f"       same target? {same_target}   all simple poles? {normalized}"
              f"   new factorization? {distinct}")
    print(f"   distinct factorizations exhibited: {len(seen)} (and the family is infinite)")
    print("   For m = 1 no twist is possible: the single slot is forced to q^{-1} g.\n")


def demo_gauge() -> None:
    print("=" * 74)
    print("4.  Gauge invariance: only the total pole order is observable")
    print("=" * 74)
    g = ONE + q_pow(1) + q_pow(5)
    m, k = 3, 3
    d = [-1, -1, -1]
    f = canonical_family_profile(k, m, d, g)
    print(f"   profile d  = {d}, k = {k}, sum(d) + k = {k + sum(d)} = order(g) = {g.order()}")
    print(f"   orders of the factors: {[fi.order() for fi in f]}")
    print(f"   q^{k} * prod == g ? {renorm_prod(k, f) == g}")
    d2 = [-3, 0, 0]
    e = [d2[i] - d[i] for i in range(m)]
    f2 = gauge_transform(e, f)
    print(f"   gauge shift e = {e} (sums to {sum(e)})")
    print(f"   new profile   = {[fi.order() for fi in f2]}  (target profile {d2})")
    print(f"   renormalized product unchanged? {renorm_prod(k, f2) == g}")
    print("   => profiles with the same total realize the same targets, bijectively.\n")


def demo_finite_levels() -> None:
    print("=" * 74)
    print("5.  Finite levels mod p^D: exact fibre counts and the Euler factor")
    print("=" * 74)
    print("     p   D   m   |fibre| (brute force)   ((p-1)p^(D-1))^(m-1)")
    for (p, D, m) in [(3, 1, 2), (3, 1, 3), (5, 1, 2), (2, 2, 3), (3, 2, 2), (2, 1, 4)]:
        n = m - 1
        mod = p**D
        g = units_mod(mod)[-1]
        brute = fibre_count_bruteforce(p, D, n, g)
        closed = fibre_count_formula(p, D, n)
        flag = "  <-- exceptional level (trivial unit group)" if (p, D) == (2, 1) else ""
        print(f"    {p:>2}  {D:>2}  {m:>2}      {brute:>10}            {closed:>10}{flag}")
    print("   Enumeration matches the closed form, and the constructive bijection")
    print("   'choose slots 1..n freely, force slot 0' reproduces the fibre exactly:")
    p, D, n = 3, 1, 2
    g = 2
    enum = fibre_enumerate(p, D, n, g)
    ok = all((x[0] * x[1] * x[2]) % (p**D) == g for x in enum)
    print(f"    p={p}, D={D}, m={n+1}, g={g}: {len(enum)} tuples, all with product g? {ok}")
    print("   Level recursion  |fibre|_{D+1} = p^(m-1) * |fibre|_D:")
    for p, n in [(3, 2), (5, 1), (2, 3)]:
        for D in (1, 2, 3):
            a = fibre_count_formula(p, D, n)
            b = fibre_count_formula(p, D + 1, n)
            print(f"    p={p}, m={n+1}: |fibre|_{D}={a:>8}, |fibre|_{D+1}={b:>10},"
                  f" ratio={b // a} (= p^{n} = {p**n})")
    print("   Euler factor identity, checked exactly over the rationals:")
    for p, n, N, T in [(3, 2, 5, Fraction(1, 7)), (5, 1, 4, Fraction(2, 9)),
                       (2, 3, 6, Fraction(1, 11))]:
        lhs, rhs = euler_factor_lhs_rhs(p, n, N, T)
        print(f"    p={p}, m={n+1}, N={N}, T={T}: LHS == RHS ? {lhs == rhs}")
    print("   => counting series = (p-1)^n T / (1 - p^n T): Euler factor 1 - p^(m-1) T.\n")


def demo_positivity() -> None:
    print("=" * 74)
    print("6.  Positivity collapses the twist group")
    print("=" * 74)
    prec = 10
    examples: Dict[str, List[Fraction]] = {
        "1 + q          ": [Fraction(1), Fraction(1)],
        "1 + q^2        ": [Fraction(1), Fraction(0), Fraction(1)],
        "1 + q/2 + q^2/4": [Fraction(1), Fraction(1, 2), Fraction(1, 4)],
        "1 (constant)   ": [Fraction(1)],
    }
    for name, u in examples.items():
        v = power_series_inverse(u, prec)
        print(f"   u = {name}: u >= 0 ? {is_nonnegative(u)};  "
              f"1/u >= 0 ? {is_nonnegative(v)}")
        print(f"       coefficients of 1/u: {[str(c) for c in v[:6]]}")
    print("   Only the constant survives: a nonnegative series with nonnegative")
    print("   inverse must be constant, so the normalized positive twist group is {1}.")
    print("   Probabilistic reading: the only law on {0,1,2,...} with p_0 = 1 whose")
    print("   generating function has a nonnegative reciprocal is the point mass at 0.\n")


def demo_probability_bridge() -> None:
    print("=" * 74)
    print("7.  Probability bridge: factorizability <=> the law charges the atom 0")
    print("=" * 74)
    laws: Dict[str, List[Fraction]] = {
        "Bernoulli(1/3) on {0,1}   ": [Fraction(2, 3), Fraction(1, 3)],
        "uniform on {0,1,2}        ": [Fraction(1, 3), Fraction(1, 3), Fraction(1, 3)],
        "uniform on {1,2} (p_0 = 0)": [Fraction(0), Fraction(1, 2), Fraction(1, 2)],
        "point mass at 2 (p_0 = 0) ": [Fraction(0), Fraction(0), Fraction(1)],
    }
    m = 4
    for name, p in laws.items():
        gf = Laurent(0, p)
        realizable = gf.order() == 0.0
        line = f"   {name}: order(gf) = {gf.order():>4}  ->  factorizable for m={m}? {realizable}"
        print(line)
        if realizable:
            f = canonical_family(m, gf)
            print(f"       witness: q^{m} * prod == gf ? {renorm_prod(m, f) == gf};"
                  f" infinitely many since m >= 2")
    print()


def main() -> None:
    print()
    print("RENORMALIZED FACTORIZATION OF NORMALIZED SERIES — NUMERICAL DEMONSTRATIONS")
    print()
    demo_orders_add()
    demo_realizability()
    demo_nonuniqueness()
    demo_gauge()
    demo_finite_levels()
    demo_positivity()
    demo_probability_bridge()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
