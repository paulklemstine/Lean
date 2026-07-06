"""Numerical demonstrations for gamma-positivity of symmetric (palindromic)
polynomials, the algebraic engine behind the "minimal dimension 36" result on
symmetric edge polytopes.

Every function is self-contained (only the standard library is used). We
represent a polynomial p(t) = c_0 + c_1 t + ... + c_d t^d as the list of its
coefficients [c_0, c_1, ..., c_d] using Python's exact `Fraction` arithmetic, so
all conclusions about signs are rigorous.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List, Optional


# --------------------------------------------------------------------------- #
# Basic polynomial utilities                                                  #
# --------------------------------------------------------------------------- #
def trim(coeffs: List[Fraction]) -> List[Fraction]:
    """Drop trailing zero coefficients (keep at least the constant term)."""
    out = list(coeffs)
    while len(out) > 1 and out[-1] == 0:
        out.pop()
    return out


def gamma_basis(n: int, i: int) -> List[Fraction]:
    """Coefficient vector of the gamma-basis element B_{n,i}(t) = t^i (1+t)^(n-2i).

    Uses the closed form  [t^k] B_{n,i} = C(n-2i, k-i)  for i <= k, else 0.
    """
    assert 2 * i <= n, "gamma-basis requires 2*i <= n"
    coeffs = [Fraction(0)] * (n + 1)
    top = n - 2 * i
    for k in range(i, n + 1):
        j = k - i
        if 0 <= j <= top:
            coeffs[k] = Fraction(comb(top, j))
    return coeffs


def is_palindromic(coeffs: List[Fraction], n: Optional[int] = None) -> bool:
    """Test c_k == c_{n-k} for 0 <= k <= n (default n = degree)."""
    c = list(coeffs)
    if n is None:
        n = len(trim(c)) - 1
    if len(c) < n + 1:
        c = c + [Fraction(0)] * (n + 1 - len(c))
    return all(c[k] == c[n - k] for k in range(n + 1))


def gamma_vector(coeffs: List[Fraction], n: int) -> Optional[List[Fraction]]:
    """Return the (unique) gamma-vector expressing `coeffs` in the order-n
    gamma-basis {B_{n,i}: 0 <= i <= n//2}, or None if `coeffs` is not palindromic
    of order n (in which case no gamma-expansion exists).

    The gamma-basis is upper-triangular in a suitable sense, so we peel off the
    coefficients from the lowest degree upward: B_{n,i} is the lowest-index basis
    element with a nonzero t^i coefficient.
    """
    c = list(coeffs)
    if len(c) < n + 1:
        c = c + [Fraction(0)] * (n + 1 - len(c))
    if not is_palindromic(c, n):
        return None

    residual = [Fraction(x) for x in c]
    gammas: List[Fraction] = []
    for i in range(n // 2 + 1):
        basis = gamma_basis(n, i)
        # [t^i] B_{n,i} == C(n-2i, 0) == 1, and lower-index basis elements
        # already contribute 0 to degree i after previous subtractions.
        gi = residual[i]
        gammas.append(gi)
        for k in range(len(basis)):
            residual[k] -= gi * basis[k]
    return gammas


def is_gamma_positive(coeffs: List[Fraction], n: int) -> bool:
    """True iff `coeffs` is gamma-positive of order n: palindromic AND its
    (necessarily unique) gamma-vector is entrywise nonnegative."""
    gv = gamma_vector(coeffs, n)
    return gv is not None and all(g >= 0 for g in gv)


def is_unimodal(coeffs: List[Fraction]) -> bool:
    """Weakly unimodal: rises then falls."""
    c = trim(coeffs)
    peak = c.index(max(c))
    up = all(c[k] <= c[k + 1] for k in range(peak))
    down = all(c[k] >= c[k + 1] for k in range(peak, len(c) - 1))
    return up and down


def fmt(coeffs: List[Fraction]) -> str:
    terms = []
    for k, ck in enumerate(coeffs):
        if ck == 0:
            continue
        mono = "1" if k == 0 else ("t" if k == 1 else f"t^{k}")
        terms.append(f"{ck}*{mono}" if ck != 1 or k == 0 else mono)
    return " + ".join(terms) if terms else "0"


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_basis_is_palindromic() -> None:
    print("=" * 70)
    print("1. Every gamma-basis element B_{n,i} = t^i (1+t)^(n-2i) is palindromic")
    print("=" * 70)
    for n in range(0, 7):
        for i in range(n // 2 + 1):
            b = gamma_basis(n, i)
            print(f"  n={n}, i={i}:  {fmt(b):<40}  palindromic={is_palindromic(b, n)}")
    print()


def demo_pow_one_plus_t() -> None:
    print("=" * 70)
    print("2. The trivial h*-polynomial (1+t)^n is gamma-positive (gamma_0 = 1)")
    print("=" * 70)
    for n in range(0, 6):
        coeffs = [Fraction(comb(n, k)) for k in range(n + 1)]
        gv = gamma_vector(coeffs, n)
        print(f"  (1+t)^{n} = {fmt(coeffs):<30}  gamma-vector={[str(g) for g in gv]}  "
              f"positive={is_gamma_positive(coeffs, n)}")
    print()


def demo_degree2_separation() -> None:
    print("=" * 70)
    print("3. Degree 2:  1 + t^2  is palindromic but NOT gamma-positive")
    print("=" * 70)
    p = [Fraction(1), Fraction(0), Fraction(1)]
    print(f"  p(t) = {fmt(p)}")
    print(f"  palindromic     : {is_palindromic(p, 2)}")
    print(f"  unimodal        : {is_unimodal(p)}   (dips in the middle -> fails)")
    gv = gamma_vector(p, 2)
    print(f"  gamma-vector    : {[str(g) for g in gv]}   -> gamma_1 = {gv[1]} < 0")
    print(f"  gamma-positive  : {is_gamma_positive(p, 2)}")
    print()


def demo_degree4_sharp() -> None:
    print("=" * 70)
    print("4. Degree 4 (SHARP):  1 + t + t^2 + t^3 + t^4")
    print("     palindromic, nonnegative, unimodal -- yet NOT gamma-positive")
    print("=" * 70)
    p = [Fraction(1)] * 5
    print(f"  p(t) = {fmt(p)}")
    print(f"  palindromic     : {is_palindromic(p, 4)}")
    print(f"  nonneg coeffs   : {all(c >= 0 for c in p)}")
    print(f"  unimodal        : {is_unimodal(p)}")
    gv = gamma_vector(p, 4)
    print(f"  gamma-vector    : {[str(g) for g in gv]}   -> gamma_1 = {gv[1]} < 0")
    print(f"  gamma-positive  : {is_gamma_positive(p, 4)}")
    print()


def demo_persistent_gap() -> None:
    print("=" * 70)
    print("5. Persistent gap: all-ones F_n = 1 + t + ... + t^n forces gamma_1 = 1 - n")
    print("=" * 70)
    for n in range(2, 12):
        p = [Fraction(1)] * (n + 1)
        gv = gamma_vector(p, n)
        print(f"  n={n:2d}:  gamma_1 = {gv[1]}   (predicted 1 - n = {1 - n})   "
              f"gamma-positive={is_gamma_positive(p, n)}")
    print()


def demo_multiplicative_law() -> None:
    print("=" * 70)
    print("6. Multiplicative law:  B_{m,i} * B_{n,j} = B_{m+n, i+j}")
    print("=" * 70)

    def poly_mul(a: List[Fraction], b: List[Fraction]) -> List[Fraction]:
        out = [Fraction(0)] * (len(a) + len(b) - 1)
        for i, ai in enumerate(a):
            for j, bj in enumerate(b):
                out[i + j] += ai * bj
        return out

    cases = [(2, 1, 3, 0), (4, 2, 2, 1), (5, 0, 3, 1)]
    for m, i, n, j in cases:
        lhs = trim(poly_mul(gamma_basis(m, i), gamma_basis(n, j)))
        rhs = trim(gamma_basis(m + n, i + j))
        print(f"  B_{{{m},{i}}} * B_{{{n},{j}}} = B_{{{m+n},{i+j}}} ?  {lhs == rhs}")
    print()


def demo_real_rooted_certificate() -> None:
    print("=" * 70)
    print("7. Real, nonpositive-rooted palindrome is gamma-positive: (1+t)^2 * (1+3t+t^2)")
    print("   while non-real roots (1+t^2, cyclotomic 1+t+t^2+t^3+t^4) break it")
    print("=" * 70)

    def poly_mul(a, b):
        out = [Fraction(0)] * (len(a) + len(b) - 1)
        for i, ai in enumerate(a):
            for j, bj in enumerate(b):
                out[i + j] += ai * bj
        return out

    # (1 + 3t + t^2) has real roots (-3 +/- sqrt5)/2 < 0, reciprocal to each other
    q = poly_mul([Fraction(1), Fraction(2), Fraction(1)],  # (1+t)^2
                 [Fraction(1), Fraction(3), Fraction(1)])   # real nonpos roots
    q = trim(q)
    n = len(q) - 1
    gv = gamma_vector(q, n)
    print(f"  q(t) = {fmt(q)}")
    print(f"  gamma-vector = {[str(g) for g in gv]}   gamma-positive={is_gamma_positive(q, n)}")
    print()


if __name__ == "__main__":
    demo_basis_is_palindromic()
    demo_pow_one_plus_t()
    demo_degree2_separation()
    demo_degree4_sharp()
    demo_persistent_gap()
    demo_multiplicative_law()
    demo_real_rooted_certificate()
    print("All demonstrations complete.")
