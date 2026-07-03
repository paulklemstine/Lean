"""Numerical demonstrations for structural results on polynomial Diophantine tuples.

A set ``A`` of elements of a ring has the *k-th power Diophantine property*
``D_k(n)`` when, for every pair of distinct ``a, b`` in ``A``, the shifted product
``a*b + n`` is a perfect k-th power in the ring.

This self-contained script (standard library only) illustrates the three
structural theorems:

  1. Over an algebraically closed field, every set of *constants* is D_k(n);
     hence arbitrarily large Diophantine sets exist (no bound among constants).
  2. Degree rigidity: a same-degree family with a small shift forces k | 2d.
     In particular, degree-one cubic Diophantine pairs are impossible.
  3. Zero-extension: adjoining 0 to a Diophantine set is possible iff the shift
     n is a perfect k-th power.
"""

from __future__ import annotations

from cmath import exp, pi
from fractions import Fraction
from itertools import combinations
from typing import List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Minimal exact univariate polynomials over the rationals.                    #
# A polynomial is stored as a list of Fraction coefficients, lowest degree    #
# first: [c0, c1, c2, ...] represents c0 + c1*x + c2*x^2 + ...                 #
# --------------------------------------------------------------------------- #

Poly = List[Fraction]


def poly(coeffs: Sequence[object]) -> Poly:
    """Build a normalized polynomial from a coefficient sequence (low->high)."""
    p = [Fraction(c) for c in coeffs]
    return normalize(p)


def normalize(p: Poly) -> Poly:
    """Strip trailing zero coefficients."""
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def is_zero(p: Poly) -> bool:
    return all(c == 0 for c in normalize(p))


def degree(p: Poly) -> int:
    """Degree of a polynomial; the zero polynomial has degree -1 here."""
    q = normalize(p)
    if is_zero(q):
        return -1
    return len(q) - 1


def add(p: Poly, q: Poly) -> Poly:
    n = max(len(p), len(q))
    out = [Fraction(0)] * n
    for i, c in enumerate(p):
        out[i] += c
    for i, c in enumerate(q):
        out[i] += c
    return normalize(out)


def mul(p: Poly, q: Poly) -> Poly:
    if is_zero(p) or is_zero(q):
        return [Fraction(0)]
    out = [Fraction(0)] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i + j] += a * b
    return normalize(out)


def power(p: Poly, k: int) -> Poly:
    result: Poly = [Fraction(1)]
    for _ in range(k):
        result = mul(result, p)
    return result


def kth_root(p: Poly, k: int) -> Optional[Poly]:
    """Return a rational polynomial c with c**k == p, or None if none exists.

    Uses the fact that deg(c) = deg(p)/k and recovers c coefficient by
    coefficient from the top, which is exact over the rationals.
    """
    p = normalize(p)
    if is_zero(p):
        return [Fraction(0)]
    d = degree(p)
    if d % k != 0:
        return None
    m = d // k
    lead = p[-1]
    # Leading coefficient of c must be a k-th root of the leading coeff of p.
    root_lead = _rational_kth_root(lead, k)
    if root_lead is None:
        return None
    c: Poly = [Fraction(0)] * (m + 1)
    c[m] = root_lead
    # Solve for remaining coefficients top-down.
    for j in range(m - 1, -1, -1):
        current = power(normalize(c), k)
        current += [Fraction(0)] * (len(p) - len(current))
        target_coeff = p[j + m * (k - 1)] if (j + m * (k - 1)) < len(p) else Fraction(0)
        have_coeff = current[j + m * (k - 1)] if (j + m * (k - 1)) < len(current) else Fraction(0)
        denom = k * (root_lead ** (k - 1))
        c[j] = (target_coeff - have_coeff) / denom + c[j]
    return normalize(c) if power(normalize(c), k) == p else None


def _rational_kth_root(a: Fraction, k: int) -> Optional[Fraction]:
    """Exact rational k-th root of a Fraction, or None."""
    if a == 0:
        return Fraction(0)
    sign = 1 if a > 0 else -1
    if sign < 0 and k % 2 == 0:
        return None
    num = _int_kth_root(abs(a.numerator), k)
    den = _int_kth_root(abs(a.denominator), k)
    if num is None or den is None:
        return None
    return Fraction(sign * num, den)


def _int_kth_root(m: int, k: int) -> Optional[int]:
    if m == 0:
        return 0
    r = round(m ** (1.0 / k))
    for cand in (r - 1, r, r + 1):
        if cand >= 0 and cand ** k == m:
            return cand
    return None


def is_kth_power(p: Poly, k: int) -> bool:
    return kth_root(p, k) is not None


def is_dio_set(members: Sequence[Poly], k: int, n: Poly) -> bool:
    """Check the D_k(n) property for a family of rational polynomials."""
    for a, b in combinations(members, 2):
        if not is_kth_power(add(mul(a, b), n), k):
            return False
    return True


# --------------------------------------------------------------------------- #
# Demonstration 1: constants over an algebraically closed field.              #
# We work numerically over C: every constant has a k-th root, so a*b+n is     #
# always a perfect k-th power.                                                 #
# --------------------------------------------------------------------------- #

def complex_kth_root(w: complex, k: int) -> complex:
    """A principal k-th root of a complex number."""
    import cmath
    if w == 0:
        return 0
    r = abs(w) ** (1.0 / k)
    return r * exp(1j * cmath.phase(w) / k)


def demo_constants_unbounded(sizes: Sequence[int], k: int = 2, n: complex = 1) -> None:
    print("=" * 70)
    print("DEMO 1: Constants over C form Diophantine sets of ANY size")
    print("=" * 70)
    for N in sizes:
        constants = [complex(i + 1) for i in range(N)]
        ok = True
        for a, b in combinations(constants, 2):
            val = a * b + n
            c = complex_kth_root(val, k)
            if abs(c ** k - val) > 1e-9:
                ok = False
                break
        print(f"  |A| = {N:4d}:  D_{k}({n}) holds over C? {ok}")
    print("  => No absolute size bound exists among constants.\n")


# --------------------------------------------------------------------------- #
# Demonstration 2: degree rigidity and the impossible cubic pair.            #
# --------------------------------------------------------------------------- #

def demo_degree_rigidity() -> None:
    print("=" * 70)
    print("DEMO 2: Degree rigidity  k | 2d  and impossible degree-1 cubic pair")
    print("=" * 70)
    # Two degree-1 polynomials a, b and a small constant shift n; try to make
    # a*b + n a perfect cube (k=3). Theory: impossible, since 3 does not divide 2.
    a = poly([1, 1])       # x + 1     (degree 1)
    b = poly([-1, 1])      # x - 1     (degree 1)
    n = poly([5])          # constant shift, deg n = 0 < 2
    prod = add(mul(a, b), n)
    print(f"  a = x+1, b = x-1, n = 5")
    print(f"  a*b + n has degree {degree(prod)} (= 2d with d=1)")
    print(f"  Is a*b + n a perfect cube (k=3)? {is_kth_power(prod, 3)}")
    print(f"  Rigidity law requires 3 | 2d = 2, i.e. 3 | 2  -> FALSE")
    print("  => Degree-one cubic Diophantine pairs cannot exist.")
    # Same product IS allowed to be a perfect square (k=2), since 2 | 2.
    print(f"  For comparison, k=2 requires 2 | 2 (true); is it a square? "
          f"{is_kth_power(prod, 2)}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3: zero-extension iff the shift is a perfect k-th power.      #
# --------------------------------------------------------------------------- #

def demo_zero_extension() -> None:
    print("=" * 70)
    print("DEMO 3: Adjoining 0 is possible iff n is a perfect k-th power")
    print("=" * 70)
    k = 2
    # Case A: n = (x+1)^2 is a perfect square.
    n_square = power(poly([1, 1]), 2)   # (x+1)^2
    # A base Diophantine set with n = (x+1)^2. Take {a} plus 0; the only pair is
    # (0, a) -> 0*a + n = n = perfect square, so it is automatically D_2(n).
    a = poly([2, 3])                    # 3x + 2
    with_zero = [poly([0]), a]
    print(f"  n = (x+1)^2 is a perfect square: {is_kth_power(n_square, k)}")
    print(f"  {{0, 3x+2}} is D_2(n)? {is_dio_set(with_zero, k, n_square)}")
    # Case B: n = x is NOT a perfect square.
    n_nonsquare = poly([0, 1])          # x
    print(f"  n = x is a perfect square: {is_kth_power(n_nonsquare, k)}")
    print(f"  {{0, 3x+2}} is D_2(x)? {is_dio_set([poly([0]), a], k, n_nonsquare)}")
    print("  => 0 can join the set exactly when n is a perfect k-th power.\n")


def main() -> None:
    demo_constants_unbounded(sizes=[3, 10, 50, 200], k=2, n=1)
    demo_degree_rigidity()
    demo_zero_extension()


if __name__ == "__main__":
    main()
