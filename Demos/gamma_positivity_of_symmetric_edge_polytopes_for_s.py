"""
Numerical demonstrations for:

    gamma-positivity of symmetric edge polytopes for series-parallel graphs
    with at most four paths (generalized theta graphs).

All routines are self-contained and use only the Python standard library.

Core objects
------------
* Polynomials are represented as coefficient lists, index k holding [t^k].
* The gamma-basis element of order n and index i is  B_{n,i}(t) = (1+t)^{n-2i} t^i.
* A palindromic polynomial p of order n has a unique gamma-vector; p is
  gamma-positive iff every entry of that vector is >= 0.

The demos reproduce, numerically:
  (1) exact coefficient formula for the gamma-basis,
  (2) evaluation positivity on [0, inf),
  (3) the cone structure (scaling / addition / multiplication),
  (4) the flat-palindrome classification: 1 + t + ... + t^n is
      gamma-positive iff n <= 1,
  (5) the series-parallel product model is gamma-positive for any number
      of paths.
"""

from __future__ import annotations

from math import comb
from typing import List


# ---------------------------------------------------------------------------
# Basic polynomial arithmetic (coefficient lists, low degree first)
# ---------------------------------------------------------------------------
def poly_trim(p: List[float]) -> List[float]:
    """Drop trailing (high-degree) zeros; keep at least [0.0]."""
    q = list(p)
    while len(q) > 1 and abs(q[-1]) < 1e-12:
        q.pop()
    return q


def poly_add(p: List[float], q: List[float]) -> List[float]:
    """Return p + q."""
    n = max(len(p), len(q))
    return [(p[k] if k < len(p) else 0.0) + (q[k] if k < len(q) else 0.0)
            for k in range(n)]


def poly_scale(c: float, p: List[float]) -> List[float]:
    """Return c * p."""
    return [c * a for a in p]


def poly_mul(p: List[float], q: List[float]) -> List[float]:
    """Return p * q (Cauchy convolution)."""
    if not p or not q:
        return [0.0]
    r = [0.0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            r[i + j] += a * b
    return r


def poly_eval(p: List[float], t: float) -> float:
    """Evaluate polynomial p at t via Horner's method."""
    acc = 0.0
    for a in reversed(p):
        acc = acc * t + a
    return acc


# ---------------------------------------------------------------------------
# The gamma-basis
# ---------------------------------------------------------------------------
def one_plus_x_pow(n: int) -> List[float]:
    """Coefficients of (1 + t)^n."""
    return [float(comb(n, k)) for k in range(n + 1)]


def gamma_basis(n: int, i: int) -> List[float]:
    """B_{n,i}(t) = (1 + t)^(n - 2 i) * t^i, as a coefficient list."""
    if 2 * i > n:
        raise ValueError(f"index i={i} out of range for order n={n} (need 2 i <= n)")
    base = one_plus_x_pow(n - 2 * i)
    return [0.0] * i + base  # multiply by t^i = shift right by i


def gamma_basis_coeff(n: int, i: int, k: int) -> float:
    """Closed form: [t^k] B_{n,i} = C(n-2 i, k - i) if i <= k else 0."""
    if i > k:
        return 0.0
    return float(comb(n - 2 * i, k - i))


# ---------------------------------------------------------------------------
# gamma-vector extraction and gamma-positivity test
# ---------------------------------------------------------------------------
def gamma_vector(p: List[float], n: int) -> List[float]:
    """
    Compute the (unique) gamma-vector of a palindromic polynomial p of order n.

    Peels off basis elements from the bottom: gamma_i is forced by the
    coefficient [t^i] after subtracting the already-known contributions.
    """
    r = list(p) + [0.0] * (n + 1 - len(p))
    gammas: List[float] = []
    for i in range(n // 2 + 1):
        gi = r[i]  # only B_{n,i} still contributes to [t^i]
        gammas.append(gi)
        b = gamma_basis(n, i)
        for k in range(len(b)):
            r[k] -= gi * b[k]
    return gammas


def is_gamma_positive(p: List[float], n: int, tol: float = 1e-9) -> bool:
    """True iff p equals its gamma-expansion and every gamma_i >= -tol."""
    gammas = gamma_vector(p, n)
    # reconstruct and compare
    recon = [0.0]
    for i, gi in enumerate(gammas):
        recon = poly_add(recon, poly_scale(gi, gamma_basis(n, i)))
    recon = recon + [0.0] * (n + 1 - len(recon))
    pp = list(p) + [0.0] * (n + 1 - len(p))
    if any(abs(a - b) > 1e-7 for a, b in zip(recon, pp)):
        return False
    return all(g >= -tol for g in gammas)


# ---------------------------------------------------------------------------
# Families of interest
# ---------------------------------------------------------------------------
def flat_palindrome(n: int) -> List[float]:
    """F_n(t) = 1 + t + ... + t^n."""
    return [1.0] * (n + 1)


def path_block(a: int) -> List[float]:
    """Building block of a path of length a: (1 + t)^a."""
    return one_plus_x_pow(a)


def series_model(path_lengths: List[int]) -> List[float]:
    """
    Series-parallel product model over the given path lengths:
        prod_k (1 + t)^{a_k} = (1 + t)^{sum a_k}.
    """
    acc = [1.0]
    for a in path_lengths:
        acc = poly_mul(acc, path_block(a))
    return acc


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_basis_coefficients() -> None:
    print("=" * 70)
    print("DEMO 1: exact coefficient formula for the gamma-basis")
    print("=" * 70)
    for (n, i) in [(6, 0), (6, 1), (6, 2), (8, 3)]:
        b = gamma_basis(n, i)
        formula = [gamma_basis_coeff(n, i, k) for k in range(n + 1)]
        b_full = b + [0.0] * (n + 1 - len(b))
        ok = all(abs(x - y) < 1e-9 for x, y in zip(b_full, formula))
        print(f"  B_{{{n},{i}}} coeffs = {[int(x) for x in b_full]}   formula matches: {ok}")
    print()


def demo_evaluation_positivity() -> None:
    print("=" * 70)
    print("DEMO 2: gamma-positive polynomials are nonnegative on [0, inf)")
    print("=" * 70)
    # 2*B_{5,0} + 3*B_{5,1} + 1*B_{5,2}
    p = [0.0]
    for gi, i in [(2.0, 0), (3.0, 1), (1.0, 2)]:
        p = poly_add(p, poly_scale(gi, gamma_basis(5, i)))
    print(f"  p (gamma-vector (2,3,1), order 5) = {[round(c,1) for c in p]}")
    for t in [0.0, 0.5, 1.0, 2.0, 5.0]:
        print(f"    p({t}) = {poly_eval(p, t):.4f}  (>= 0: {poly_eval(p, t) >= 0})")
    print()


def demo_cone_structure() -> None:
    print("=" * 70)
    print("DEMO 3: cone structure (scaling, addition, multiplication)")
    print("=" * 70)
    p = poly_add(poly_scale(1.0, gamma_basis(4, 0)), poly_scale(2.0, gamma_basis(4, 1)))
    q = poly_add(poly_scale(3.0, gamma_basis(3, 0)), poly_scale(1.0, gamma_basis(3, 1)))
    print(f"  p order 4 gamma-positive: {is_gamma_positive(p, 4)}")
    print(f"  q order 3 gamma-positive: {is_gamma_positive(q, 3)}")
    print(f"  2.5 * p gamma-positive (order 4): {is_gamma_positive(poly_scale(2.5, p), 4)}")
    p2 = poly_add(poly_scale(4.0, gamma_basis(4, 0)), poly_scale(0.5, gamma_basis(4, 2)))
    print(f"  p + p2 gamma-positive (order 4): {is_gamma_positive(poly_add(p, p2), 4)}")
    print(f"  p * q gamma-positive (order 4+3=7): {is_gamma_positive(poly_mul(p, q), 7)}")
    print()


def demo_flat_palindrome() -> None:
    print("=" * 70)
    print("DEMO 4: flat palindrome 1 + t + ... + t^n is gamma-positive iff n <= 1")
    print("=" * 70)
    for n in range(0, 8):
        F = flat_palindrome(n)
        gv = gamma_vector(F, n)
        gp = is_gamma_positive(F, n)
        print(f"  n={n}: gamma-vector = {[round(g,1) for g in gv]:} "
              f"-> gamma-positive: {gp}"
              + ("" if n <= 1 else f"   (gamma_1 = {round(gv[1],1)} < 0)"))
    print()


def demo_series_model() -> None:
    print("=" * 70)
    print("DEMO 5: series-parallel product model is gamma-positive for any m")
    print("=" * 70)
    families = [[2, 3], [1, 2, 2], [1, 2, 2, 3], [1, 1, 2, 2, 3], [2, 2, 2, 2, 2, 2]]
    for a in families:
        M = series_model(a)
        n = sum(a)
        gv = gamma_vector(M, n)
        print(f"  paths {a} (m={len(a)}, total length {n}): "
              f"gamma-positive: {is_gamma_positive(M, n)}, "
              f"gamma-vector = {[int(round(g)) for g in gv]}")
    print()


def main() -> None:
    demo_basis_coefficients()
    demo_evaluation_positivity()
    demo_cone_structure()
    demo_flat_palindrome()
    demo_series_model()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
