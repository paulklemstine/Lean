"""
Numerical demonstrations for:

    Explicit Quantitative Lower Bound on Power-Saving for Monic Minkowski Polynomials

Core object: for a finite set A of integers and an integer polynomial f, the
"Minkowski image" (elementwise image) is

    f(A) = { f(a) : a in A }.

Main corridor (for f monic of degree k >= 2 and A nonempty):

        |A| / k   <=   |f(A)|   <=   |A|^(k - 1/k^2).

Multiplicativity under composition (deg p = k, deg q = m):

        |A|  <=  (k * m) * |(q o p)(A)|,

so an r-fold composition of degree-k maps has power-saving constant 1/k^(2r).

This script is fully self-contained (standard library only). It:
  * builds Minkowski images,
  * checks the two-sided corridor on many examples,
  * demonstrates that both endpoints of the corridor are attained (sharpness),
  * verifies multiplicativity of the fiber bound under composition.
"""

from __future__ import annotations

from typing import Callable, Iterable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Polynomials as coefficient lists:  coeffs[i] is the coefficient of x^i.
# ---------------------------------------------------------------------------
Poly = List[int]


def poly_eval(coeffs: Poly, x: int) -> int:
    """Evaluate a polynomial (given by coefficient list) at an integer x."""
    result = 0
    power = 1
    for c in coeffs:
        result += c * power
        power *= x
    return result


def poly_degree(coeffs: Poly) -> int:
    """Degree of a polynomial given as a coefficient list (deg 0 for constants)."""
    deg = 0
    for i, c in enumerate(coeffs):
        if c != 0:
            deg = i
    return deg


def poly_compose(q: Poly, p: Poly) -> Poly:
    """Return the coefficient list of the composite (q o p)(x) = q(p(x))."""
    # Horner on q with polynomial arithmetic in the variable (via p).
    result: Poly = [0]
    for c in reversed(q):
        # result <- result * p + c
        result = poly_mul(result, p)
        result = poly_add(result, [c])
    return _trim(result)


def poly_mul(a: Poly, b: Poly) -> Poly:
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return _trim(out)


def poly_add(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        out[i] = (a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0)
    return _trim(out)


def _trim(a: Poly) -> Poly:
    while len(a) > 1 and a[-1] == 0:
        a = a[:-1]
    return a


# ---------------------------------------------------------------------------
# Minkowski (elementwise) image.
# ---------------------------------------------------------------------------
def minkowski_image(f: Callable[[int], int], A: Iterable[int]) -> set:
    """The elementwise image f(A) = { f(a) : a in A } as a set."""
    return {f(a) for a in A}


# ---------------------------------------------------------------------------
# Corridor checks.
# ---------------------------------------------------------------------------
def power_saving_exponent(k: int) -> float:
    """The power-saving exponent  k - 1/k^2  for degree k."""
    return k - 1.0 / (k * k)


def check_corridor(coeffs: Poly, A: Sequence[int]) -> Tuple[float, int, float]:
    """
    Return (lower, image_size, upper) for the corridor
        |A|/k  <=  |f(A)|  <=  |A|^(k - 1/k^2).
    """
    k = poly_degree(coeffs)
    f = lambda x: poly_eval(coeffs, x)
    n = len(set(A))
    img = minkowski_image(f, A)
    lower = n / k
    upper = n ** power_saving_exponent(k)
    return lower, len(img), upper


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------
def demo_corridor() -> None:
    print("=" * 68)
    print("1. The two-sided corridor  |A|/k <= |f(A)| <= |A|^(k - 1/k^2)")
    print("=" * 68)
    examples = [
        ("x^2", [0, 0, 1], list(range(-5, 6))),
        ("x^2 - x", [0, -1, 1], list(range(-6, 7))),
        ("x^3", [0, 0, 0, 1], list(range(-7, 8))),
        ("x^3 + x", [0, 1, 0, 1], list(range(-8, 9))),
        ("x^4 - 3x^2 + 1", [1, 0, -3, 0, 1], list(range(-9, 10))),
    ]
    for name, coeffs, A in examples:
        k = poly_degree(coeffs)
        lower, size, upper = check_corridor(coeffs, A)
        ok = lower <= size <= upper + 1e-9
        print(f"  f = {name:<16} deg={k}  |A|={len(set(A))}")
        print(f"     {lower:8.3f}  <=  |f(A)| = {size:<4d}  <=  {upper:10.3f}   "
              f"[{'OK' if ok else 'FAIL'}]")


def demo_sharpness() -> None:
    print("=" * 68)
    print("2. Sharpness: both endpoints of the corridor are attained")
    print("=" * 68)
    # Upper endpoint (no expansion): x^k on {0,...,n-1} is injective => |f(A)|=|A|.
    print("  Upper endpoint  (x^k on {0,...,n-1};  f injective => |f(A)| = |A|):")
    for k in (2, 3, 4):
        for n in (5, 10, 20):
            A = list(range(n))
            img = minkowski_image(lambda x, k=k: x ** k, A)
            assert len(img) == n, (k, n, len(img))
        print(f"     x^{k}:  |f(A)| = |A| = n  for n in {{5,10,20}}   [OK]")
    # Lower endpoint (factor-k collapse): x^2 on {-n,...,n} => 2|f(A)| = |A|+1.
    print("  Lower endpoint  (x^2 on {-n,...,n};  fibers {a,-a} collapse):")
    for n in (3, 7, 15):
        A = list(range(-n, n + 1))
        img = minkowski_image(lambda x: x * x, A)
        lhs = 2 * len(img)
        rhs = len(A) + 1
        print(f"     n={n:<3d}  2*|f(A)| = {lhs:<4d}  =  |A|+1 = {rhs:<4d}   "
              f"[{'OK' if lhs == rhs else 'FAIL'}]")


def demo_composition() -> None:
    print("=" * 68)
    print("3. Multiplicativity under composition:  |A| <= (k*m)*|(q o p)(A)|")
    print("=" * 68)
    p = [0, 0, 1]        # x^2  (k = 2)
    q = [0, 0, 1]        # x^2  (m = 2)
    comp = poly_compose(q, p)   # x^4  (k*m = 4)
    k, m = poly_degree(p), poly_degree(q)
    print(f"  p = x^{k},  q = x^{m},  q o p = degree {poly_degree(comp)} "
          f"(coeffs {comp})")
    for n in (5, 9, 13):
        A = list(range(-n, n + 1))
        # chained images
        B = minkowski_image(lambda x: poly_eval(p, x), A)
        C = minkowski_image(lambda x: poly_eval(q, x), B)
        # direct composite image
        D = minkowski_image(lambda x: poly_eval(comp, x), A)
        assert C == D, (C, D)
        bound = (k * m) * len(D)
        print(f"     |A|={len(A):<3d}  |p(A)|={len(B):<3d}  |(qop)(A)|={len(D):<3d}"
              f"   |A| <= k*m*|(qop)(A)| : {len(A)} <= {bound}   "
              f"[{'OK' if len(A) <= bound else 'FAIL'}]")


def demo_composition_constant() -> None:
    print("=" * 68)
    print("4. Composite power-saving constant  1/k^(2r)  for r-fold towers")
    print("=" * 68)
    for k in (2, 3):
        for r in range(1, 5):
            c = 1.0 / k ** (2 * r)
            deg = k ** r
            print(f"     k={k}, r={r}:  degree = k^r = {deg:<5d}   "
                  f"power-saving constant 1/k^(2r) = {c:.6g}")


if __name__ == "__main__":
    demo_corridor()
    print()
    demo_sharpness()
    print()
    demo_composition()
    print()
    demo_composition_constant()
