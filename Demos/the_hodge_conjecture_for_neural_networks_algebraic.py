"""
Numerical demonstrations for:

    Algebraic Cycles in Piecewise-Linear Decision Surfaces:
    A Width-Driven Bound on the Homology of ReLU Classifiers

This self-contained script illustrates the three quantitative pillars of the
paper for small ReLU networks:

  1. The activation-pattern count of a network equals
         prod_i 2^{w_i} = 2^{sum_i w_i}.
  2. The Betti number of a cellular chain complex over a field is a subquotient
     dimension, bounded by the number of cells, and satisfies the exact
     rank identity  beta + rank(B) = rank(Z).
  3. The width-driven bound  beta <= #cells <= 2^{sum_i w_i}  holds by
     transitivity, and we sample random ReLU networks to observe realised
     region counts staying under the bound.

No external dependencies beyond the Python standard library are required; a
minimal exact-rational linear algebra layer is inlined so the homology
computations are exact (no floating-point error).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Iterable, List, Sequence, Tuple

Matrix = List[List[Fraction]]


# ----------------------------------------------------------------------
# 1. Activation-pattern counting
# ----------------------------------------------------------------------
def activation_pattern_count(widths: Sequence[int]) -> int:
    """Number of activation patterns of a network with the given hidden widths.

    Equals prod_i 2^{w_i} = 2^{sum_i w_i}.
    """
    prod = 1
    for w in widths:
        prod *= 2 ** w
    return prod


def activation_pattern_count_via_sum(widths: Sequence[int]) -> int:
    """Same count computed as 2^{sum_i w_i}; must equal the product form."""
    return 2 ** sum(widths)


def enumerate_activation_patterns(widths: Sequence[int]) -> Iterable[Tuple[Tuple[bool, ...], ...]]:
    """Explicitly enumerate all activation patterns (one bool per neuron)."""
    per_layer = [list(product([False, True], repeat=w)) for w in widths]
    yield from product(*per_layer)


# ----------------------------------------------------------------------
# 2. Exact rational linear algebra (rank via Gaussian elimination)
# ----------------------------------------------------------------------
def matrix_rank(rows: Matrix) -> int:
    """Exact rank of a matrix over the rationals via Gaussian elimination."""
    if not rows:
        return 0
    m = [row[:] for row in rows]
    n_rows = len(m)
    n_cols = len(m[0]) if m else 0
    rank = 0
    pivot_col = 0
    for r in range(n_rows):
        if pivot_col >= n_cols:
            break
        # find a pivot in column pivot_col at or below row r
        piv = None
        while pivot_col < n_cols:
            for i in range(r, n_rows):
                if m[i][pivot_col] != 0:
                    piv = i
                    break
            if piv is not None:
                break
            pivot_col += 1
        if piv is None:
            break
        m[r], m[piv] = m[piv], m[r]
        inv = m[r][pivot_col]
        m[r] = [x / inv for x in m[r]]
        for i in range(n_rows):
            if i != r and m[i][pivot_col] != 0:
                factor = m[i][pivot_col]
                m[i] = [a - factor * b for a, b in zip(m[i], m[r])]
        rank += 1
        pivot_col += 1
    return rank


def homology_ranks(d2: Matrix, d1: Matrix) -> Tuple[int, int, int, int]:
    """Given boundary matrices d2: C2 -> C1 and d1: C1 -> C0, return
    (dim C1, rank Z = nullity d1, rank B = rank d2, beta = dim H).

    Here Z = ker d1, B = range d2 (assumed inside Z), and beta = dim(Z/B).
    """
    dim_c1 = len(d1[0]) if d1 else (len(d2) if d2 else 0)
    rank_d1 = matrix_rank(d1)
    rank_z = dim_c1 - rank_d1          # nullity of d1
    rank_b = matrix_rank(d2)           # dim range d2
    beta = rank_z - rank_b             # dim(Z / B)
    return dim_c1, rank_z, rank_b, beta


# ----------------------------------------------------------------------
# 3. A concrete tiny complex:  a hollow triangle (circle), beta_1 = 1
# ----------------------------------------------------------------------
def triangle_boundary_matrices() -> Tuple[Matrix, Matrix]:
    """Cellular chain complex of the boundary of a triangle (a 1-cycle).

    3 vertices v0,v1,v2 (C0), 3 edges e0=v0->v1, e1=v1->v2, e2=v2->v0 (C1),
    no 2-cells (C2 = 0).  Expected: beta_1 = 1 (one loop).
    d1 : C1 -> C0 is the 3x3 incidence matrix; d2 is empty (0 columns).
    """
    F = Fraction
    # columns = edges, rows = vertices; entry -1 at tail, +1 at head
    d1: Matrix = [
        [F(-1), F(0), F(1)],   # v0: tail of e0, head of e2
        [F(1), F(-1), F(0)],   # v1: head of e0, tail of e1
        [F(0), F(1), F(-1)],   # v2: head of e1, tail of e2
    ]
    d2: Matrix = [[F(0)], [F(0)], [F(0)]]  # placeholder single zero 2-cell
    # Use a genuinely empty C2 (rank 0): represent as 3x0
    d2 = [[] for _ in range(3)]
    return d2, d1


def filled_triangle_boundary_matrices() -> Tuple[Matrix, Matrix]:
    """Same 1-skeleton but with the 2-cell filling the disk: beta_1 = 0."""
    F = Fraction
    d1: Matrix = [
        [F(-1), F(0), F(1)],
        [F(1), F(-1), F(0)],
        [F(0), F(1), F(-1)],
    ]
    # one 2-cell whose boundary is e0 + e1 + e2
    d2: Matrix = [[F(1)], [F(1)], [F(1)]]
    return d2, d1


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------
def demo_activation_counts() -> None:
    print("=" * 64)
    print("1. Activation-pattern counts:  prod 2^{w_i} = 2^{sum w_i}")
    print("=" * 64)
    for widths in [(2,), (3, 3), (2, 4, 2), (5, 1, 1, 1)]:
        prod_form = activation_pattern_count(widths)
        sum_form = activation_pattern_count_via_sum(widths)
        enumerated = sum(1 for _ in enumerate_activation_patterns(widths))
        assert prod_form == sum_form == enumerated
        print(f"  widths={widths!s:<14} "
              f"prod 2^w_i = {prod_form:<8} "
              f"2^sum = {sum_form:<8} enumerated = {enumerated}")
    print()


def demo_homology_identity() -> None:
    print("=" * 64)
    print("2. Betti number, cell bound, and exact rank identity")
    print("=" * 64)
    for name, mats in [
        ("hollow triangle (circle)", triangle_boundary_matrices()),
        ("filled triangle (disk)", filled_triangle_boundary_matrices()),
    ]:
        d2, d1 = mats
        dim_c1, rank_z, rank_b, beta = homology_ranks(d2, d1)
        print(f"  {name}")
        print(f"    dim C1 (#1-cells) = {dim_c1}")
        print(f"    rank Z (cycles)   = {rank_z}")
        print(f"    rank B (bdries)   = {rank_b}")
        print(f"    beta = dim H      = {beta}")
        # exact rank identity: beta + rank B = rank Z
        assert beta + rank_b == rank_z, "rank identity failed!"
        # cell bound: beta <= dim C1
        assert beta <= dim_c1, "cell bound failed!"
        print(f"    check  beta + rank B = rank Z : "
              f"{beta} + {rank_b} = {rank_z}  OK")
        print(f"    check  beta <= #cells         : {beta} <= {dim_c1}  OK")
    print()


def relu_regions_1d(weights: Sequence[float], biases: Sequence[float],
                    samples: int = 20001, lo: float = -10.0,
                    hi: float = 10.0) -> int:
    """Count realised activation regions of a 1-hidden-layer ReLU net on [lo,hi]
    by sampling: each neuron j is active where w_j x + b_j > 0; the region is the
    tuple of activation bits, and we count distinct tuples encountered."""
    seen = set()
    for k in range(samples):
        x = lo + (hi - lo) * k / (samples - 1)
        pattern = tuple((w * x + b) > 0 for w, b in zip(weights, biases))
        seen.add(pattern)
    return len(seen)


def demo_region_bound() -> None:
    print("=" * 64)
    print("3. Realised regions stay under the width-driven bound 2^{sum w}")
    print("=" * 64)
    import random
    random.seed(0)
    for width in [1, 2, 3, 4, 5]:
        weights = [random.uniform(-3, 3) for _ in range(width)]
        biases = [random.uniform(-3, 3) for _ in range(width)]
        realised = relu_regions_1d(weights, biases)
        bound = 2 ** width
        assert realised <= bound
        print(f"  width={width}:  realised regions = {realised:<4} "
              f"<=  2^{width} = {bound}")
    print()


def main() -> None:
    demo_activation_counts()
    demo_homology_identity()
    demo_region_bound()
    print("All checks passed.")


if __name__ == "__main__":
    main()
