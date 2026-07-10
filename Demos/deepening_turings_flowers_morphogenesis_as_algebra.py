"""
Turing's Flowers: The Conic Classification of Morphogenesis
===========================================================

Numerical demonstrations of the discriminant dichotomy for near-onset Turing
patterns and of the exact mode-degree calculus.

A near-onset pattern is captured by a leading quadratic form
    q(x, y) = a x^2 + b x y + c y^2,
and its morphology is the level set {q(x, y) = k}.  The rotation-invariant
discriminant

    Delta = b^2 - 4 a c

decides everything:

  * Delta < 0 (with a > 0): positive-definite form  ->  SPOT
    The level set is a compact ellipse contained in a disc of squared radius
        R = 4 k (a + c) / (4 a c - b^2).

  * Delta > 0 (with a > 0): indefinite form  ->  LABYRINTH
    The level set is an unbounded hyperbola; an explicit family of points
    escapes to infinity.

On the mode side, cos(n*theta) = T_n(cos theta) (Chebyshev), so:
  * product of an m-mode and an n-mode has polynomial degree exactly m + n;
  * superposition alpha*cos(m*theta) + beta*cos(n*theta) with m < n, beta != 0
    has degree exactly n.

This script is self-contained (standard library only).
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
#  Part 1: the discriminant classifier
# --------------------------------------------------------------------------- #

def discriminant(a: float, b: float, c: float) -> float:
    """Return the discriminant Delta = b^2 - 4 a c of the quadratic form."""
    return b * b - 4.0 * a * c


def classify(a: float, b: float, c: float) -> str:
    """Classify the morphology of q(x,y) = a x^2 + b x y + c y^2.

    Returns one of 'spot', 'labyrinth', 'degenerate'.
    """
    delta = discriminant(a, b, c)
    if a > 0 and delta < 0:
        return "spot"
    if delta > 0:
        return "labyrinth"
    return "degenerate"


def spot_squared_radius(a: float, b: float, c: float, k: float) -> float:
    """Explicit squared-radius bound R = 4 k (a+c) / (4 a c - b^2) for a spot.

    Every point of the level set {q = k} satisfies x^2 + y^2 <= R.
    Requires positive-definite form (a > 0, b^2 < 4 a c) and k >= 0.
    """
    denom = 4.0 * a * c - b * b
    if denom <= 0:
        raise ValueError("form is not positive definite; no spot bound exists")
    return 4.0 * k * (a + c) / denom


# --------------------------------------------------------------------------- #
#  Part 2: the labyrinth escape sampler
# --------------------------------------------------------------------------- #

def labyrinth_escape_point(
    a: float, b: float, c: float, k: float, target_norm_sq: float
) -> Tuple[float, float]:
    """Return a point on the indefinite level set {q = k} of squared norm > target.

    Uses the completed square 4 a q = (2 a x + b y)^2 - Delta y^2.  Fix y = s
    large enough that W = Delta*s^2 + 4 a k > 0, then x = (sqrt(W) - b s)/(2 a).
    """
    delta = discriminant(a, b, c)
    if not (a > 0 and delta > 0):
        raise ValueError("form is not indefinite (need a > 0 and Delta > 0)")
    s = math.sqrt(abs(target_norm_sq) + abs(4.0 * a * k / delta) + 1.0)
    w = delta * s * s + 4.0 * a * k
    x = (math.sqrt(w) - b * s) / (2.0 * a)
    return (x, s)


# --------------------------------------------------------------------------- #
#  Part 3: Chebyshev polynomials and the exact mode-degree calculus
# --------------------------------------------------------------------------- #

def chebyshev_T(n: int) -> List[float]:
    """Coefficients of the Chebyshev polynomial T_n (ascending powers of X)."""
    if n == 0:
        return [1.0]
    if n == 1:
        return [0.0, 1.0]
    prev2: List[float] = [1.0]           # T_0
    prev1: List[float] = [0.0, 1.0]      # T_1
    for _ in range(2, n + 1):
        # T_k = 2 X T_{k-1} - T_{k-2}
        shifted = [0.0] + prev1          # X * T_{k-1}
        cur = [2.0 * v for v in shifted]
        for i, v in enumerate(prev2):
            cur[i] -= v
        prev2, prev1 = prev1, cur
    return prev1


def poly_degree(coeffs: List[float], tol: float = 1e-12) -> int:
    """Degree of a polynomial given by ascending coefficients (ignoring ~0 tail)."""
    deg = 0
    for i, v in enumerate(coeffs):
        if abs(v) > tol:
            deg = i
    return deg


def poly_mul(p: List[float], q: List[float]) -> List[float]:
    """Multiply two polynomials given by ascending coefficients."""
    out = [0.0] * (len(p) + len(q) - 1)
    for i, pi in enumerate(p):
        for j, qj in enumerate(q):
            out[i + j] += pi * qj
    return out


def poly_add_scaled(
    p: List[float], q: List[float], alpha: float, beta: float
) -> List[float]:
    """Return alpha*p + beta*q for polynomials in ascending-coefficient form."""
    n = max(len(p), len(q))
    out = [0.0] * n
    for i in range(n):
        if i < len(p):
            out[i] += alpha * p[i]
        if i < len(q):
            out[i] += beta * q[i]
    return out


def poly_eval(coeffs: List[float], x: float) -> float:
    """Evaluate an ascending-coefficient polynomial via Horner's rule."""
    acc = 0.0
    for v in reversed(coeffs):
        acc = acc * x + v
    return acc


def product_mode_degree(m: int, n: int) -> int:
    """Degree of the polynomial representing cos(m*theta) * cos(n*theta)."""
    return poly_degree(poly_mul(chebyshev_T(m), chebyshev_T(n)))


def superposition_degree(m: int, n: int, alpha: float, beta: float) -> int:
    """Degree of alpha*cos(m*theta) + beta*cos(n*theta) as a polynomial."""
    return poly_degree(poly_add_scaled(chebyshev_T(m), chebyshev_T(n), alpha, beta))


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #

def demo_classification() -> None:
    print("=" * 70)
    print("PART 1  Discriminant classification of patterns")
    print("=" * 70)
    examples: List[Tuple[str, Tuple[float, float, float]]] = [
        ("isotropic spot   ", (1.0, 0.0, 1.0)),
        ("tilted spot      ", (2.0, 1.5, 2.0)),
        ("isotropic maze   ", (1.0, 0.0, -1.0)),
        ("tilted maze      ", (1.0, 3.0, 1.0)),
    ]
    for name, (a, b, c) in examples:
        d = discriminant(a, b, c)
        print(f"  {name}  a={a:+.1f} b={b:+.1f} c={c:+.1f}  "
              f"Delta={d:+.2f}  ->  {classify(a, b, c).upper()}")
    print()


def demo_spot_radius() -> None:
    print("=" * 70)
    print("PART 2  Spot radius certificate  (bound must hold for sampled points)")
    print("=" * 70)
    a, b, c, k = 2.0, 1.5, 2.0, 5.0
    R = spot_squared_radius(a, b, c, k)
    print(f"  form: {a} x^2 + {b} x y + {c} y^2 = {k}   Delta={discriminant(a,b,c):+.2f}")
    print(f"  certified squared radius R = {R:.4f}")
    # Sample the ellipse by solving the quadratic in x for many y.
    worst = 0.0
    ys = [(-3.0 + 6.0 * i / 400.0) for i in range(401)]
    for y in ys:
        # a x^2 + (b y) x + (c y^2 - k) = 0
        disc = (b * y) ** 2 - 4 * a * (c * y * y - k)
        if disc < 0:
            continue
        for sign in (+1.0, -1.0):
            x = (-b * y + sign * math.sqrt(disc)) / (2 * a)
            worst = max(worst, x * x + y * y)
    print(f"  max sampled x^2+y^2 on the level set = {worst:.4f}")
    print(f"  bound satisfied: {worst <= R + 1e-9}")
    print()


def demo_labyrinth_escape() -> None:
    print("=" * 70)
    print("PART 3  Labyrinth escape sampler  (points run to infinity)")
    print("=" * 70)
    a, b, c, k = 1.0, 3.0, 1.0, 4.0
    print(f"  form: {a} x^2 + {b} x y + {c} y^2 = {k}   Delta={discriminant(a,b,c):+.2f}")
    for target in [1e1, 1e3, 1e5, 1e7]:
        x, y = labyrinth_escape_point(a, b, c, k, target)
        val = a * x * x + b * x * y + c * y * y
        print(f"  target>{target:>8.0e}:  |p|^2={x*x+y*y:>14.2f}  "
              f"q(p)={val:.6f}  (should equal k={k})")
    print()


def demo_mode_degree() -> None:
    print("=" * 70)
    print("PART 4  Exact mode-degree calculus")
    print("=" * 70)
    print("  Products multiply degree:  deg[cos(m t) cos(n t)] = m + n")
    for m, n in [(1, 1), (2, 3), (3, 4), (5, 2)]:
        d = product_mode_degree(m, n)
        print(f"    m={m}, n={n}:  degree = {d}   (m+n = {m+n})   "
              f"{'OK' if d == m + n else 'FAIL'}")
    print()
    print("  Superposition is degree-stable:  deg = max mode (top harmonic wins)")
    for m, n, al, be in [(1, 3, 5.0, 0.1), (2, 5, 100.0, 1.0), (0, 4, 9.0, 2.0)]:
        d = superposition_degree(m, n, al, be)
        print(f"    a*cos({m}t)+b*cos({n}t), a={al}, b={be}:  degree = {d}   "
              f"(max = {n})   {'OK' if d == n else 'FAIL'}")
    print()
    # Numerical sanity: polynomial evaluation matches the trig identity.
    print("  Identity check  T_n(cos t) = cos(n t):")
    n = 4
    coeffs = chebyshev_T(n)
    max_err = 0.0
    for i in range(101):
        t = math.pi * i / 100.0
        max_err = max(max_err, abs(poly_eval(coeffs, math.cos(t)) - math.cos(n * t)))
    print(f"    n={n}: max error over [0, pi] = {max_err:.2e}")
    print()


def demo_separation() -> None:
    print("=" * 70)
    print("PART 5  Spots and labyrinths are distinct sets (capstone)")
    print("=" * 70)
    # Spot form and labyrinth form at the same threshold.
    a, b, c = 2.0, 1.5, 2.0                 # spot
    ap, bp, cp = 1.0, 3.0, 1.0             # labyrinth
    k = 5.0
    R = spot_squared_radius(a, b, c, k)
    x, y = labyrinth_escape_point(ap, bp, cp, k, R)
    print(f"  spot bound: every point of V_k(spot) has |p|^2 <= {R:.4f}")
    print(f"  but V_k(labyrinth) contains p=({x:.3f},{y:.3f}) with "
          f"|p|^2={x*x+y*y:.4f} > {R:.4f}")
    print("  => the two level sets cannot be equal.  QED.")
    print()


def main() -> None:
    demo_classification()
    demo_spot_radius()
    demo_labyrinth_escape()
    demo_mode_degree()
    demo_separation()


if __name__ == "__main__":
    main()
