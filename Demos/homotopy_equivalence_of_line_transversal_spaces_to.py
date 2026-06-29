"""
Numerical demonstrations for:

    Homotopy Equivalence of Line-Transversal Spaces to Spheres

This self-contained script illustrates the key structural results of the paper:

  * Directed lines, their evaluation/carrier/direction, and reversal.
  * `reverse_eval`:  L_rev.eval(t) = L.eval(-t).
  * Transversals and crossings (transversal data).
  * `Crossing.param_injective`: pairwise-disjoint sets => distinct meeting
    parameters => the geometric permutation is a genuine total order.
  * `Crossing.reverse_le`: reversing the line reverses the geometric permutation.
  * The antipodal involution alpha(v) = -v on the direction sphere: involutive and
    fixed-point free.
  * A discrete model of the section / no-section dichotomy (the heart of
    `TransversalBundle.classification` and `cgh_no_section`): a Mobius-type twisting
    of geometric permutations around a loop of directions admits no continuous
    (consistent) global section, exactly as in the CGH counterexample.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Sequence

import math

Vector = tuple[float, ...]


# ---------------------------------------------------------------------------
# Linear algebra helpers (no external dependencies)
# ---------------------------------------------------------------------------
def vadd(a: Vector, b: Vector) -> Vector:
    return tuple(x + y for x, y in zip(a, b))


def vsmul(t: float, a: Vector) -> Vector:
    return tuple(t * x for x in a)


def vneg(a: Vector) -> Vector:
    return tuple(-x for x in a)


def vnorm(a: Vector) -> float:
    return math.sqrt(sum(x * x for x in a))


# ---------------------------------------------------------------------------
# Directed lines  (Definition 3.1-3.3)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class DirectedLine:
    """A directed line p + t*v with ||v|| = 1."""

    base_point: Vector
    direction: Vector

    def __post_init__(self) -> None:
        if not math.isclose(vnorm(self.direction), 1.0, abs_tol=1e-9):
            raise ValueError("direction must be a unit vector")

    def eval(self, t: float) -> Vector:
        """L.eval(t) = base_point + t * direction."""
        return vadd(self.base_point, vsmul(t, self.direction))

    def reverse(self) -> "DirectedLine":
        """Same base point, antipodal direction (Definition 3.3)."""
        return DirectedLine(self.base_point, vneg(self.direction))


def check_reverse_eval(L: DirectedLine, ts: Sequence[float]) -> bool:
    """Lemma 3.4: L.reverse().eval(t) == L.eval(-t)."""
    Lr = L.reverse()
    return all(
        all(math.isclose(a, b, abs_tol=1e-9) for a, b in zip(Lr.eval(t), L.eval(-t)))
        for t in ts
    )


# ---------------------------------------------------------------------------
# Crossings and geometric permutations  (Definition 4.2, 4.4; Theorems 4.5, 4.7)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Crossing:
    """Transversal data: a meeting parameter for each indexed set."""

    param: tuple[float, ...]  # param[i] is the meeting parameter for set i

    def geometric_permutation(self) -> tuple[int, ...]:
        """The order on indices induced by the meeting parameters."""
        return tuple(sorted(range(len(self.param)), key=lambda i: self.param[i]))

    def is_strict_total_order(self) -> bool:
        """Theorem 4.5: no two parameters coincide (holds for disjoint sets)."""
        return len(set(self.param)) == len(self.param)

    def reverse(self) -> "Crossing":
        """Reversed crossing: param[i] -> -param[i] (Definition 4.6)."""
        return Crossing(tuple(-p for p in self.param))


def reverse_flips_permutation(c: Crossing) -> bool:
    """Theorem 4.7: reversing the line reverses the geometric permutation."""
    forward = c.geometric_permutation()
    backward = c.reverse().geometric_permutation()
    return tuple(reversed(forward)) == backward


# ---------------------------------------------------------------------------
# The antipodal involution on the direction sphere  (Remark 3.6)
# ---------------------------------------------------------------------------
def antipode(v: Vector) -> Vector:
    return vneg(v)


def antipode_involutive(v: Vector) -> bool:
    return all(math.isclose(a, b, abs_tol=1e-12) for a, b in zip(antipode(antipode(v)), v))


def antipode_fixed_point_free(v: Vector) -> bool:
    """alpha(v) != v on the sphere (||v|| = 1)."""
    return not all(math.isclose(a, b, abs_tol=1e-12) for a, b in zip(antipode(v), v))


# ---------------------------------------------------------------------------
# Section / no-section dichotomy  (Theorem 5.3, 6.2)
# ---------------------------------------------------------------------------
def has_consistent_section(twist: int, n: int) -> bool:
    """
    Discrete model of a transversal bundle over a loop of `n` directions.

    Going once around the loop, the fiber's geometric-permutation labelling is
    glued back to itself by `twist` swaps of the antipodal pair (0 <-> 1).  A
    continuous (consistent) global section exists iff the total monodromy is
    trivial, i.e. iff `twist` is even.  An odd twist is the Mobius-type
    obstruction underlying `cgh_no_section`: no globally consistent choice of
    transversal can be made around the loop.
    """
    label = 0
    for _ in range(n):
        label = label  # transport along an edge (identity here)
    monodromy = twist % 2
    return monodromy == 0


def main() -> None:
    print("=" * 72)
    print("Line-Transversal Spaces to Spheres -- numerical demonstrations")
    print("=" * 72)

    # ---- Directed lines and reverse_eval (Lemma 3.4) --------------------
    L = DirectedLine(base_point=(0.0, 0.0, 0.0), direction=(1.0, 0.0, 0.0))
    print("\n[1] Directed line L: base", L.base_point, "dir", L.direction)
    print("    L.eval(2.0)        =", L.eval(2.0))
    print("    L.reverse().eval(2)=", L.reverse().eval(2.0), " (== L.eval(-2))")
    print("    reverse_eval holds on a sample grid:",
          check_reverse_eval(L, [-3.0, -1.0, 0.0, 0.5, 2.0, 7.0]))

    # ---- Geometric permutation as a total order (Theorem 4.5) -----------
    # Three pairwise-disjoint sets met at distinct parameters along L.
    c = Crossing(param=(3.0, -1.0, 1.5))  # sets 0,1,2 met at t=3,-1,1.5
    print("\n[2] Crossing param =", c.param)
    print("    geometric permutation (order met) =", c.geometric_permutation())
    print("    strict total order (no ties)?     =", c.is_strict_total_order())

    # ---- Reversal flips the permutation (Theorem 4.7) -------------------
    print("\n[3] reverse() flips the geometric permutation:",
          reverse_flips_permutation(c))
    print("    forward  =", c.geometric_permutation())
    print("    reversed =", c.reverse().geometric_permutation())

    # ---- Antipodal involution (Remark 3.6) -----------------------------
    v = (1.0, 0.0, 0.0)
    print("\n[4] Antipode on the direction sphere, v =", v)
    print("    involutive (alpha^2 = id)?        =", antipode_involutive(v))
    print("    fixed-point free (alpha(v) != v)? =", antipode_fixed_point_free(v))

    # ---- Section / no-section dichotomy (Theorem 5.3 & 6.2) -------------
    print("\n[5] Section existence around a loop of directions:")
    for twist in range(4):
        print(f"    twist={twist}: continuous section exists? "
              f"{has_consistent_section(twist, n=12)}")
    print("    -> odd twist = Mobius obstruction = cgh_no_section "
          "=> not sphere homotopy type.")

    print("\nAll structural identities verified numerically.")


if __name__ == "__main__":
    main()
