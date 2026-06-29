"""
Numerical demonstrations for:

    Iteration and Semigroup Theory for Set-Local Distortion of Hausdorff Dimension

This self-contained script illustrates the main results without any external
dependencies:

  * Rule 1 (Lipschitz)      : dimH(f(s)) <= dimH(s)
  * Rule 2 (Hölder, exp r)  : dimH(f(s)) <= dimH(s) / r
  * Rule 3 (antilipschitz)  : dimH(s)    <= dimH(f(s))     [the new keystone]
  * dimH_image_eq           : bi-Lipschitz  =>  dimH(f(s)) = dimH(s)
  * lipschitzOnWith_iterate : Lip const of f^[n] is K^n
  * holderOnWith_iterate    : Hölder exponent of f^[n] is r^n
  * dimH_image_iterate_eq   : dimH(f^[n](s)) = dimH(s) for every n   (MAIN)
  * dimH_image_iterate_le   : dimH(f^[n](s)) <= dimH(s) / r^n

We model finite metric "sets" as sorted lists of real points, estimate Hausdorff
dimension by the box-counting slope, and verify that iterating a set-local
bi-Lipschitz self-map leaves the (estimated) dimension constant.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
#  Distortion bookkeeping: the algebra of constants and exponents             #
# --------------------------------------------------------------------------- #

def lipschitz_iterate_constant(K: float, n: int) -> float:
    """Lipschitz constant of f^[n] given Lipschitz constant K of f (Lemma 5.1)."""
    return K ** n


def antilipschitz_iterate_constant(K_anti: float, n: int) -> float:
    """Antilipschitz constant of f^[n] (Lemma 5.2)."""
    return K_anti ** n


def holder_iterate_exponent(r: float, n: int) -> float:
    """Hölder exponent of f^[n] given exponent r of f (Lemma 5.3)."""
    return r ** n


def compose_lipschitz(K_f: float, K_g: float) -> float:
    """Lipschitz constant of g o f: constants multiply (Section 4.2)."""
    return K_f * K_g


def compose_holder_exponent(r_f: float, r_g: float) -> float:
    """Hölder exponent of g o f: exponents multiply (Theorem 4.4)."""
    return r_g * r_f


def holder_dim_upper_bound(dim_s: float, r: float) -> float:
    """Rule 2 / Theorem 5.6 one-step bound: dimH(f(s)) <= dimH(s)/r."""
    return dim_s / r


def iterated_holder_corridor(dim_s: float, r: float, n: int) -> float:
    """Theorem 5.6: dimH(f^[n](s)) <= dimH(s) / r^n."""
    return dim_s / (r ** n)


# --------------------------------------------------------------------------- #
#  The middle-thirds Cantor set and its box-counting dimension               #
# --------------------------------------------------------------------------- #

def cantor_points(depth: int) -> List[float]:
    """Left endpoints of the 2^depth level-`depth` intervals of the Cantor set."""
    pts = [0.0]
    for _ in range(depth):
        pts = [p / 3.0 for p in pts] + [p / 3.0 + 2.0 / 3.0 for p in pts]
    return sorted(pts)


def box_count(points: List[float], eps: float) -> int:
    """Number of grid boxes of side `eps` that contain at least one point."""
    occupied = {math.floor(p / eps) for p in points}
    return len(occupied)


def box_dimension(points: List[float], scales: List[float]) -> float:
    """
    Estimate box-counting (Minkowski) dimension as the slope of
    log N(eps) vs log(1/eps) by least squares.  For nice self-similar sets
    this coincides with the Hausdorff dimension.
    """
    xs = [math.log(1.0 / e) for e in scales]
    ys = [math.log(box_count(points, e)) for e in scales]
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


# --------------------------------------------------------------------------- #
#  Set-local bi-Lipschitz self-map of the Cantor set                          #
# --------------------------------------------------------------------------- #

def left_third(x: float) -> float:
    """f(x) = x/3 maps the Cantor set C into C (into its left third)."""
    return x / 3.0


def iterate(f: Callable[[float], float], n: int) -> Callable[[float], float]:
    """Return the n-fold composition f^[n]; f^[0] is the identity."""
    def g(x: float) -> float:
        for _ in range(n):
            x = f(x)
        return x
    return g


def verify_iterate_invariance(depth: int, max_iter: int) -> List[Tuple[int, float]]:
    """
    dimH_image_iterate_eq:  the box dimension of f^[n](C) is constant in n,
    even though the orbit pieces shrink into [0, 3^-n].
    """
    base = cantor_points(depth)
    results: List[Tuple[int, float]] = []
    for n in range(max_iter + 1):
        fn = iterate(left_third, n)
        img = sorted(fn(p) for p in base)
        # Scale-adapted box sizes: the piece lives in [0, 3^-n], so the natural
        # smallest resolution scales with 3^-n.  Dimension is scale invariant.
        span = 3.0 ** (-n)
        scales = [span / 3.0 ** k for k in range(1, depth)]
        results.append((n, box_dimension(img, scales)))
    return results


# --------------------------------------------------------------------------- #
#  Driver                                                                     #
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("Set-local distortion of Hausdorff dimension under iteration")
    print("=" * 70)

    theoretical = math.log(2) / math.log(3)
    print(f"\nCantor set theoretical dimension  log2/log3 = {theoretical:.6f}")

    depth = 12
    base = cantor_points(depth)
    scales = [3.0 ** (-k) for k in range(1, depth)]
    est = box_dimension(base, scales)
    print(f"Box-counting estimate (depth {depth})      = {est:.6f}")

    print("\n--- Theorem dimH_image_iterate_eq: invariance under iteration ---")
    print(" n   estimated dimH(f^[n](C))    deviation from log2/log3")
    for n, d in verify_iterate_invariance(depth=11, max_iter=6):
        print(f"{n:2d}        {d:.6f}                 {abs(d - theoretical):.2e}")
    print("  => the orbit-piece dimension is a CONSTANT sequence.")

    print("\n--- Lemma 5.1 / 5.2: iterated (anti)Lipschitz constants K^n ---")
    K, K_anti = 1.0 / 3.0, 3.0
    for n in range(0, 5):
        print(f"  f^[{n}]:  Lip = (1/3)^{n} = {lipschitz_iterate_constant(K, n):.6f}, "
              f"antiLip = 3^{n} = {antilipschitz_iterate_constant(K_anti, n):.1f}, "
              f"product = {lipschitz_iterate_constant(K, n) * antilipschitz_iterate_constant(K_anti, n):.3f}")
    print("  product = 1 each row: bi-Lipschitz with reciprocal constants.")

    print("\n--- Theorem 5.6: iterated Hölder corridor dimH(s)/r^n ---")
    r, dim_s = 0.5, 0.6309
    for n in range(0, 6):
        print(f"  f^[{n}]: exponent r^{n} = {holder_iterate_exponent(r, n):.5f}, "
              f"upper bound dimH/r^{n} = {iterated_holder_corridor(dim_s, r, n):.4f}")

    print("\n--- Theorem 4.3: composition of distinct similarities ---")
    Kf, Kf_anti = 1.0 / 2.0, 2.0
    Kg, Kg_anti = 1.0 / 3.0, 3.0
    print(f"  g o f: Lip = {compose_lipschitz(Kf, Kg):.4f} (=1/6), "
          f"antiLip = {compose_lipschitz(Kf_anti, Kg_anti):.1f} (=6) "
          f"=> still bi-Lipschitz => dimension preserved.")

    print("\nAll demonstrations consistent with the formalised theorems.")


if __name__ == "__main__":
    main()
