"""
Numerical demonstrations for:

    The Algebraic Geometry of ReLU Decision Boundaries
    A Depth-Free Tropical Correspondence and an Explicit Boundary Variety

This self-contained script illustrates the two main results:

  1. Depth-free characterization.  Functions built from affine forms using
     addition, real scaling, and the rectifier ReLU(t) = max(t, 0) are exactly
     the tropical rational functions  f = p - q, where p and q are finite maxima
     of affine forms.  We verify the two key identities that power the proof:

         max(a, b)      = a + ReLU(b - a)          (max is a disguised rectifier)
         ReLU(p - q)    = max(p, q) - q            (rectifier preserves rationality)

  2. Algebraic boundary containment.  The decision boundary {x : p(x) = q(x)} of
     a tropical rational classifier lies inside the real zero set of the boundary
     polynomial B(x) = prod over piece pairs (A, B) of (A(x) - B(x)).  We verify
     numerically that every boundary point is a root of B, and exhibit the
     phantom crossings that make the containment strict.

Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import Callable, List, Sequence, Tuple

# An affine piece (a, b) represents  x -> <a, x> + b.
Piece = Tuple[Tuple[float, ...], float]


# ---------------------------------------------------------------------------
# Core evaluators
# ---------------------------------------------------------------------------
def aff_eval(piece: Piece, x: Sequence[float]) -> float:
    """Evaluate the affine functional (a, b) at x:  <a, x> + b."""
    a, b = piece
    return sum(ai * xi for ai, xi in zip(a, x)) + b


def trop_poly_eval(pieces: Sequence[Piece], x: Sequence[float]) -> float:
    """Evaluate a tropical polynomial (finite max of affine pieces) at x."""
    return max(aff_eval(p, x) for p in pieces)


def relu(t: float) -> float:
    """The rectified linear unit ReLU(t) = max(t, 0)."""
    return max(t, 0.0)


def trop_rational_eval(
    p_pieces: Sequence[Piece], q_pieces: Sequence[Piece], x: Sequence[float]
) -> float:
    """Evaluate a tropical rational classifier f = p - q at x."""
    return trop_poly_eval(p_pieces, x) - trop_poly_eval(q_pieces, x)


# ---------------------------------------------------------------------------
# The boundary polynomial B(x) = prod_{A in Sp} prod_{C in Sq} (A(x) - C(x))
# ---------------------------------------------------------------------------
def boundary_poly_eval(
    p_pieces: Sequence[Piece], q_pieces: Sequence[Piece], x: Sequence[float]
) -> float:
    """Evaluate the boundary polynomial: product of all pairwise affine differences."""
    value = 1.0
    for a_piece in p_pieces:
        for c_piece in q_pieces:
            value *= aff_eval(a_piece, x) - aff_eval(c_piece, x)
    return value


# ---------------------------------------------------------------------------
# Demo 1: the two identities behind the depth-free characterization
# ---------------------------------------------------------------------------
def demo_identities(trials: int = 100_000) -> None:
    print("=" * 70)
    print("Demo 1: identities behind the depth-free characterization")
    print("=" * 70)
    rng = random.Random(0)
    max_err_1 = 0.0
    max_err_2 = 0.0
    for _ in range(trials):
        a = rng.uniform(-10, 10)
        b = rng.uniform(-10, 10)
        # Identity 1:  max(a, b) = a + ReLU(b - a)
        max_err_1 = max(max_err_1, abs(max(a, b) - (a + relu(b - a))))
        # Identity 2:  ReLU(a - b) = max(a, b) - b
        max_err_2 = max(max_err_2, abs(relu(a - b) - (max(a, b) - b)))
    print(f"  max |max(a,b) - (a + ReLU(b-a))|   over {trials} trials = {max_err_1:.2e}")
    print(f"  max |ReLU(a-b) - (max(a,b) - b)|   over {trials} trials = {max_err_2:.2e}")
    print("  => Both identities hold to machine precision.\n")


# ---------------------------------------------------------------------------
# Demo 2: a deep ReLU network computes a tropical rational function
# ---------------------------------------------------------------------------
def demo_network_is_tropical() -> None:
    print("=" * 70)
    print("Demo 2: a deep ReLU network equals an explicit tropical rational fn")
    print("=" * 70)
    # A small 2-input network:
    #   h1 = ReLU(x1 - x2 + 1),  h2 = ReLU(-x1 + 2*x2)
    #   out = 2*h1 - h2 + (x1 + x2)     (a difference of convex PL functions)
    def network(x: Sequence[float]) -> float:
        h1 = relu(aff_eval(((1.0, -1.0), 1.0), x))
        h2 = relu(aff_eval(((-1.0, 2.0), 0.0), x))
        return 2.0 * h1 - h2 + aff_eval(((1.0, 1.0), 0.0), x)

    # Its guaranteed tropical rational form f = p - q with
    #   2*ReLU(u) = max(2u, 0),  -ReLU(v) = 0 - max(v, 0), so
    #   p = max(2u,0) + (x1+x2),  q = max(v, 0).
    def p_of(x: Sequence[float]) -> float:
        u = aff_eval(((1.0, -1.0), 1.0), x)
        return max(2.0 * u, 0.0) + aff_eval(((1.0, 1.0), 0.0), x)

    def q_of(x: Sequence[float]) -> float:
        v = aff_eval(((-1.0, 2.0), 0.0), x)
        return max(v, 0.0)

    rng = random.Random(1)
    max_err = 0.0
    for _ in range(100_000):
        x = (rng.uniform(-5, 5), rng.uniform(-5, 5))
        max_err = max(max_err, abs(network(x) - (p_of(x) - q_of(x))))
    print(f"  max |network(x) - (p(x) - q(x))|  = {max_err:.2e}")
    print("  => The depth-3 computation equals a difference of two tropical polys.\n")


# ---------------------------------------------------------------------------
# Demo 3: decision boundary is contained in the boundary variety
# ---------------------------------------------------------------------------
def demo_boundary_containment() -> None:
    print("=" * 70)
    print("Demo 3: decision boundary lies inside the algebraic boundary variety")
    print("=" * 70)
    # p(x) = max(x1, -x1),  q(x) = max(x2, -x2)  (so f = |x1| - |x2|).
    p_pieces: List[Piece] = [((1.0, 0.0), 0.0), ((-1.0, 0.0), 0.0)]
    q_pieces: List[Piece] = [((0.0, 1.0), 0.0), ((0.0, -1.0), 0.0)]

    rng = random.Random(2)
    checked = 0
    worst = 0.0
    # Sample points ON the boundary |x1| = |x2| by construction: x2 = +/- x1.
    for _ in range(50_000):
        t = rng.uniform(-5, 5)
        sign = rng.choice((1.0, -1.0))
        x = (t, sign * t)  # satisfies |x1| = |x2|, hence f(x) = 0
        assert abs(trop_rational_eval(p_pieces, q_pieces, x)) < 1e-9
        b = boundary_poly_eval(p_pieces, q_pieces, x)
        worst = max(worst, abs(b))
        checked += 1
    print(f"  checked {checked} boundary points; max |B(x)| = {worst:.2e}")
    print("  => Every decision-boundary point is a root of B (containment).")

    # Phantom crossing: a point where a single pairwise factor vanishes but
    # neither tied piece is the active maximizer, so B(x) = 0 yet f(x) != 0.
    # Use q with an extra constant piece 5:  q(x) = max(x2, -x2, 5).
    q_pieces_c: List[Piece] = [((0.0, 1.0), 0.0), ((0.0, -1.0), 0.0), ((0.0, 0.0), 5.0)]
    x_phantom = (5.0, 100.0)
    # Piece x1 of p equals 5 here; constant piece 5 of q equals 5 -> factor = 0.
    b_ph = boundary_poly_eval(p_pieces, q_pieces_c, x_phantom)
    f_ph = trop_rational_eval(p_pieces, q_pieces_c, x_phantom)
    print(f"  phantom point x={x_phantom}: B(x)={b_ph:.2e}, f(x)={f_ph:.2e}")
    print("  => B vanishes though f is far from 0: the containment is strict.\n")


# ---------------------------------------------------------------------------
# Demo 4: degree of the boundary polynomial = m * k
# ---------------------------------------------------------------------------
def demo_degree() -> None:
    print("=" * 70)
    print("Demo 4: boundary polynomial degree equals (pieces of p) x (pieces of q)")
    print("=" * 70)
    for m, k in [(2, 1), (2, 2), (3, 2), (4, 3)]:
        # Each factor A - C has degree <= 1; product of m*k factors has degree m*k.
        print(f"  |Sp|={m}, |Sq|={k}  =>  deg B <= m*k = {m * k}")
    print()


def main() -> None:
    demo_identities()
    demo_network_is_tropical()
    demo_boundary_containment()
    demo_degree()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
