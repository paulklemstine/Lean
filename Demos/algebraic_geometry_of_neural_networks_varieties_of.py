"""Numerical demonstrations for the tropical geometry of ReLU decision boundaries.

This self-contained module illustrates the main results:

  * A tropical polynomial is the pointwise maximum of affine monomials, and is
    convex, continuous and piecewise linear.
  * Addition law:      max(p, q)  ->  monomial families take the DISJOINT UNION
                       (monomial counts ADD).
  * Multiplication law: p + q      ->  monomial families take the CARTESIAN PRODUCT
                       (monomial counts MULTIPLY).
  * ReLU identity:      max(t, 0) = max(t + q, q) - q, so ReLU(p - q) = max(p, q) - q.
  * Depth  => degree  <= 2 ** L.
  * Width  => region count = prod(w_i).
  * The decision boundary {f = 0} equals the equalizer {p = q}.

Everything is implemented with the standard library only (plus optional plotting).
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, List, Sequence, Tuple

Vector = Tuple[float, ...]


@dataclass(frozen=True)
class Monomial:
    """An affine monomial m(x) = coeff + <weight, x>."""

    coeff: float
    weight: Vector

    def value(self, x: Vector) -> float:
        return self.coeff + sum(w * xi for w, xi in zip(self.weight, x))


@dataclass(frozen=True)
class TropicalPolynomial:
    """A tropical polynomial p(x) = max_i (coeff_i + <weight_i, x>)."""

    monomials: Tuple[Monomial, ...]

    def value(self, x: Vector) -> float:
        return max(m.value(x) for m in self.monomials)

    def argmax_indices(self, x: Vector, tol: float = 1e-9) -> List[int]:
        vals = [m.value(x) for m in self.monomials]
        best = max(vals)
        return [i for i, v in enumerate(vals) if abs(v - best) <= tol]

    @property
    def count(self) -> int:
        return len(self.monomials)


def tropical_max(p: TropicalPolynomial, q: TropicalPolynomial) -> TropicalPolynomial:
    """Addition law: max(p, q) has the DISJOINT UNION of monomial families."""
    return TropicalPolynomial(p.monomials + q.monomials)


def tropical_add(p: TropicalPolynomial, q: TropicalPolynomial) -> TropicalPolynomial:
    """Multiplication law: p + q has the CARTESIAN PRODUCT of monomial families."""
    prod_monomials = tuple(
        Monomial(
            coeff=a.coeff + b.coeff,
            weight=tuple(wa + wb for wa, wb in zip(a.weight, b.weight)),
        )
        for a, b in product(p.monomials, q.monomials)
    )
    return TropicalPolynomial(prod_monomials)


# ---------------------------------------------------------------------------
# Demonstration 1: the two growth laws (counts add vs. multiply)
# ---------------------------------------------------------------------------
def demo_growth_laws() -> None:
    print("=" * 70)
    print("Demonstration 1: monomial counts ADD under max, MULTIPLY under sum")
    print("=" * 70)
    p = TropicalPolynomial((Monomial(0.0, (1.0, 0.0)), Monomial(1.0, (0.0, 1.0))))
    q = TropicalPolynomial((Monomial(-0.5, (0.0, -1.0)), Monomial(0.2, (-1.0, 0.0)),
                            Monomial(0.0, (1.0, 1.0))))
    m = tropical_max(p, q)
    s = tropical_add(p, q)
    print(f"  |p| = {p.count},  |q| = {q.count}")
    print(f"  addition law:       |max(p,q)| = {m.count}  (= {p.count} + {q.count})")
    print(f"  multiplication law: |p + q|    = {s.count}  (= {p.count} * {q.count})")

    # Verify the identities hold pointwise on a random-ish grid.
    ok_max = ok_add = True
    for x in ((0.3, -0.7), (1.1, 2.0), (-1.5, 0.4), (0.0, 0.0)):
        ok_max &= abs(max(p.value(x), q.value(x)) - m.value(x)) < 1e-9
        ok_add &= abs(p.value(x) + q.value(x) - s.value(x)) < 1e-9
    print(f"  pointwise check max(p,q) == tropical_max : {ok_max}")
    print(f"  pointwise check p + q     == tropical_add : {ok_add}")


# ---------------------------------------------------------------------------
# Demonstration 2: the ReLU identity max(t,0) = max(p,q) - q
# ---------------------------------------------------------------------------
def relu(t: float) -> float:
    return max(t, 0.0)


def demo_relu_identity() -> None:
    print("=" * 70)
    print("Demonstration 2: ReLU(p - q) = max(p, q) - q")
    print("=" * 70)
    max_err = 0.0
    for p in (-3.0, -1.2, 0.0, 0.7, 4.5):
        for q in (-2.0, 0.0, 1.3, 3.0):
            lhs = relu(p - q)
            rhs = max(p, q) - q
            max_err = max(max_err, abs(lhs - rhs))
    print(f"  max |ReLU(p-q) - (max(p,q)-q)| over grid = {max_err:.2e}")
    print("  => each ReLU layer replaces numerator by disjoint union {p} U {q}.")


# ---------------------------------------------------------------------------
# Demonstration 3: depth => degree <= 2^L, width => count = prod(w_i)
# ---------------------------------------------------------------------------
def layer_doubling_bound(num_layers: int) -> int:
    """m_0 = 1, m_{k+1} <= 2 m_k  =>  m_L <= 2^L."""
    count = 1
    for _ in range(num_layers):
        count = 2 * count  # worst-case doubling under a ReLU layer
    return count


def width_product(widths: Sequence[int]) -> int:
    total = 1
    for w in widths:
        total *= w
    return total


def demo_complexity_bounds() -> None:
    print("=" * 70)
    print("Demonstration 3: depth -> 2^L, width -> prod(w_i), region bound")
    print("=" * 70)
    widths = [3, 4, 2]
    L = len(widths)
    deg = layer_doubling_bound(L)
    reg = deg * width_product(widths)
    print(f"  widths = {widths}, depth L = {L}")
    print(f"  degree bound            2^L          = {deg}")
    print(f"  product of widths       prod(w_i)    = {width_product(widths)}")
    print(f"  linear-region bound     2^L*prod w_i = {reg}")
    print(f"  singularity bound       prod C(w_i,2) = "
          f"{width_product([w * (w - 1) // 2 for w in widths])}")


# ---------------------------------------------------------------------------
# Demonstration 4: a concrete ReLU classifier, its boundary {p = q}
# ---------------------------------------------------------------------------
def demo_decision_boundary() -> None:
    print("=" * 70)
    print("Demonstration 4: boundary {f = 0} = equalizer {p = q}")
    print("=" * 70)
    # f(x) = |x1| - |x2| = max(x1, -x1) - max(x2, -x2), a tropical rational p - q.
    p = TropicalPolynomial((Monomial(0.0, (1.0, 0.0)), Monomial(0.0, (-1.0, 0.0))))
    q = TropicalPolynomial((Monomial(0.0, (0.0, 1.0)), Monomial(0.0, (0.0, -1.0))))

    def f(x: Vector) -> float:
        return p.value(x) - q.value(x)

    # Sample a coarse grid, count sign regions and near-boundary points.
    step = 0.25
    pos = neg = boundary = 0
    for i in range(-8, 9):
        for j in range(-8, 9):
            x = (i * step, j * step)
            v = f(x)
            if abs(v) < 1e-9:
                boundary += 1
            elif v > 0:
                pos += 1
            else:
                neg += 1
    print("  classifier f(x) = |x1| - |x2|  (boundary = the two diagonals |x1|=|x2|)")
    print(f"  grid points with f > 0 (label +): {pos}")
    print(f"  grid points with f < 0 (label -): {neg}")
    print(f"  grid points on boundary f = 0   : {boundary}")
    # Confirm equalizer description at a boundary point.
    xb = (1.0, 1.0)
    print(f"  at x = {xb}: p(x) = {p.value(xb)}, q(x) = {q.value(xb)}, "
          f"f(x) = {f(xb)}  (p == q, so on boundary)")


# ---------------------------------------------------------------------------
# Demonstration 5: curvature-free robustness radius
# ---------------------------------------------------------------------------
def l2(v: Vector) -> float:
    return sum(c * c for c in v) ** 0.5


def robustness_radius(p: TropicalPolynomial, q: TropicalPolynomial,
                      x0: Vector) -> float:
    """margin / (||dominant p slope|| + ||dominant q slope||), curvature-free."""
    margin = abs(p.value(x0) - q.value(x0))
    wp = p.monomials[p.argmax_indices(x0)[0]].weight
    wq = q.monomials[q.argmax_indices(x0)[0]].weight
    denom = l2(wp) + l2(wq)
    return margin / denom if denom > 0 else float("inf")


def demo_robustness() -> None:
    print("=" * 70)
    print("Demonstration 5: curvature-free certified robustness radius")
    print("=" * 70)
    p = TropicalPolynomial((Monomial(0.0, (1.0, 0.0)), Monomial(0.0, (-1.0, 0.0))))
    q = TropicalPolynomial((Monomial(0.0, (0.0, 1.0)), Monomial(0.0, (0.0, -1.0))))
    for x0 in ((2.0, 0.3), (3.0, 1.0), (0.5, 0.2)):
        r = robustness_radius(p, q, x0)
        print(f"  x0 = {x0}: margin = {abs(p.value(x0) - q.value(x0)):.3f}, "
              f"certified radius = {r:.3f}")


def main() -> None:
    demo_growth_laws()
    demo_relu_identity()
    demo_complexity_bounds()
    demo_decision_boundary()
    demo_robustness()


if __name__ == "__main__":
    main()
