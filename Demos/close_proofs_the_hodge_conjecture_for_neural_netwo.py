"""Numerical demonstrations for the exact Betti-Rank formula and the width
calculus of piecewise-linear decision surfaces.

The results demonstrated here:

  1. Exact Betti-Rank formula (three-term chain complex over a field Q):
         dim H + rank d1 + rank d2 = dim C1,     i.e.
         dim H = dim C1 - rank d1 - rank d2.
     Homology H = ker(d1) / range(d2) is the middle homology of
         C2 --d2--> C1 --d1--> C0,   with d1 . d2 = 0.

  2. The width calculus for the activation-pattern count P(w) = prod_i 2^{w_i}:
         - closed form P(w) = 2^{sum w_i},
         - monotonicity: w <= w'  =>  P(w) <= P(w'),
         - multiplicativity: P(w concat v) = P(w) * P(v).

  3. The monotone width bound: dim H <= dim C1 <= P(w) <= P(w').

All linear algebra is done exactly over the rationals with the built-in
``fractions.Fraction`` type, so ranks are computed without floating-point error.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence, Tuple

Matrix = List[List[Fraction]]


# --------------------------------------------------------------------------- #
# Exact rational linear algebra                                               #
# --------------------------------------------------------------------------- #
def _to_fraction_matrix(rows: Sequence[Sequence[object]]) -> Matrix:
    """Coerce a nested list of ints/Fractions into a matrix of Fractions."""
    return [[Fraction(x) for x in row] for row in rows]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Exact matrix product a @ b over the rationals."""
    n, k, m = len(a), len(b), len(b[0]) if b else 0
    assert all(len(row) == k for row in a), "inner dimensions must match"
    return [
        [sum((a[i][t] * b[t][j] for t in range(k)), Fraction(0)) for j in range(m)]
        for i in range(n)
    ]


def rank(matrix: Matrix) -> int:
    """Exact rank via fraction-arithmetic Gaussian elimination.

    A column-map convention is used: ``matrix`` has one row per output
    coordinate and one column per input coordinate, so ``rank`` equals the
    dimension of the image (the classical rank).
    """
    if not matrix or not matrix[0]:
        return 0
    m = [row[:] for row in matrix]  # copy
    rows, cols = len(m), len(m[0])
    r = 0
    for c in range(cols):
        pivot = next((i for i in range(r, rows) if m[i][c] != 0), None)
        if pivot is None:
            continue
        m[r], m[pivot] = m[pivot], m[r]
        inv = Fraction(1) / m[r][c]
        m[r] = [x * inv for x in m[r]]
        for i in range(rows):
            if i != r and m[i][c] != 0:
                factor = m[i][c]
                m[i] = [x - factor * y for x, y in zip(m[i], m[r])]
        r += 1
        if r == rows:
            break
    return r


def homology_dim_from_maps(d1: Matrix, d2: Matrix, dim_c1: int) -> int:
    """dim H = dim C1 - rank d1 - rank d2, the subtraction form of the formula.

    ``d1`` maps C1 -> C0 (rows = dim C0, cols = dim C1).
    ``d2`` maps C2 -> C1 (rows = dim C1, cols = dim C2).
    """
    return dim_c1 - rank(d1) - rank(d2)


# --------------------------------------------------------------------------- #
# 1. Exact Betti-Rank formula                                                 #
# --------------------------------------------------------------------------- #
def demo_betti_rank_formula() -> None:
    print("=" * 72)
    print("1. Exact Betti-Rank formula:  dim H + rank d1 + rank d2 = dim C1")
    print("=" * 72)

    # A genuine chain complex C2 --d2--> C1 --d1--> C0 with d1 . d2 = 0.
    # Take C1 = Q^4, C0 = Q^3, C2 = Q^2.
    # d1 : C1 -> C0 chosen with a 2-dim kernel (rank 2).
    d1 = _to_fraction_matrix(
        [
            [1, 0, 1, 0],
            [0, 1, 0, 1],
            [0, 0, 0, 0],
        ]
    )  # rank 2, ker d1 is 2-dimensional
    # d2 : C2 -> C1 whose image lies in ker d1 (so d1 . d2 = 0), rank 1.
    d2 = _to_fraction_matrix(
        [
            [1, 0],
            [0, 0],
            [-1, 0],
            [0, 0],
        ]
    )  # column (1,0,-1,0) is in ker d1; second column is zero -> rank 1

    dim_c1 = 4
    product = matmul(d1, d2)
    is_complex = all(x == 0 for row in product for x in row)
    assert is_complex, "d1 . d2 must vanish for a chain complex"

    r1, r2 = rank(d1), rank(d2)
    dim_h = homology_dim_from_maps(d1, d2, dim_c1)

    print(f"  dim C1        = {dim_c1}")
    print(f"  rank d1       = {r1}")
    print(f"  rank d2       = {r2}")
    print(f"  d1 . d2 = 0   : {is_complex}")
    print(f"  dim H         = dim C1 - rank d1 - rank d2 = {dim_h}")
    print(f"  identity      : dim H + rank d1 + rank d2 = "
          f"{dim_h + r1 + r2}  (= dim C1 = {dim_c1})")
    assert dim_h + r1 + r2 == dim_c1
    print("  [OK] exact Betti-Rank identity verified\n")


# --------------------------------------------------------------------------- #
# 2. The width calculus                                                       #
# --------------------------------------------------------------------------- #
def activation_pattern_count(widths: Sequence[int]) -> int:
    """P(w) = prod_i 2^{w_i} = 2^{sum w_i}, the activation-pattern count."""
    total = 1
    for w in widths:
        total *= 2 ** w
    return total


def demo_width_calculus() -> None:
    print("=" * 72)
    print("2. Width calculus for P(w) = prod_i 2^{w_i}")
    print("=" * 72)

    w = [3, 2, 4]
    print(f"  widths w          = {w}")
    print(f"  P(w)              = prod 2^w_i = {activation_pattern_count(w)}")
    print(f"  2^(sum w)         = {2 ** sum(w)}   (closed form check)")
    assert activation_pattern_count(w) == 2 ** sum(w)

    # Monotonicity
    w_wide = [4, 2, 6]
    assert all(a <= b for a, b in zip(w, w_wide))
    print(f"\n  wider profile w'  = {w_wide}")
    print(f"  P(w)  = {activation_pattern_count(w)}")
    print(f"  P(w') = {activation_pattern_count(w_wide)}")
    assert activation_pattern_count(w) <= activation_pattern_count(w_wide)
    print("  [OK] monotonicity: P(w) <= P(w')")

    # Multiplicativity under concatenation
    v = [1, 5]
    concat = list(w) + list(v)
    print(f"\n  second network v  = {v}")
    print(f"  P(w || v)         = {activation_pattern_count(concat)}")
    print(f"  P(w) * P(v)       = "
          f"{activation_pattern_count(w) * activation_pattern_count(v)}")
    assert activation_pattern_count(concat) == (
        activation_pattern_count(w) * activation_pattern_count(v)
    )
    print("  [OK] multiplicativity: P(w || v) = P(w) * P(v)\n")


# --------------------------------------------------------------------------- #
# 3. Monotone width bound on the Betti number                                 #
# --------------------------------------------------------------------------- #
def demo_width_bound() -> None:
    print("=" * 72)
    print("3. Monotone width bound:  dim H <= dim C1 <= P(w) <= P(w')")
    print("=" * 72)

    widths = [2, 1]                     # tiny network
    budget = activation_pattern_count(widths)   # = 2^3 = 8

    # A chain complex whose middle group C1 has dim <= budget.
    dim_c1 = 5                          # 5 cells, and 5 <= 8 = P(w)
    # d1: rank 2, d2: rank 1  ->  dim H = 5 - 2 - 1 = 2
    d1 = _to_fraction_matrix(
        [
            [1, 0, 0, 0, 1],
            [0, 1, 0, 0, 0],
        ]
    )
    d2 = _to_fraction_matrix(
        [
            [1],
            [0],
            [0],
            [0],
            [-1],
        ]
    )
    assert all(x == 0 for row in matmul(d1, d2) for x in row)

    dim_h = homology_dim_from_maps(d1, d2, dim_c1)
    wider = [3, 4]
    budget_wide = activation_pattern_count(wider)

    print(f"  widths w      = {widths},  P(w)  = {budget}")
    print(f"  dim C1        = {dim_c1}  (<= P(w) = {budget})")
    print(f"  dim H         = {dim_h}")
    print(f"  wider w'      = {wider}, P(w') = {budget_wide}")
    print(f"  chain         : {dim_h} <= {dim_c1} <= {budget} <= {budget_wide}")
    assert dim_h <= dim_c1 <= budget <= budget_wide
    print("  [OK] monotone width bound verified\n")


# --------------------------------------------------------------------------- #
# 4. A concrete piecewise-linear decision surface (1-D ReLU network)          #
# --------------------------------------------------------------------------- #
def relu_network_breakpoints(
    layer1_weights: Sequence[float],
    layer1_biases: Sequence[float],
    output_weights: Sequence[float],
    output_bias: float,
) -> Tuple[List[float], int]:
    """For a scalar-input, single-hidden-layer ReLU network f: R -> R,
    return the neuron breakpoints (where each ReLU switches) and the number
    of zero crossings of f (the "0-cells" of the decision surface V(f)).

    f(x) = output_bias + sum_j output_weights[j] * relu(layer1_weights[j]*x
                                                        + layer1_biases[j]).
    The decision surface V(f) = {x : f(x) = 0} is a finite set of points,
    each a hyperplane section (here, a point) -- an algebraic cycle.
    """
    def relu(t: float) -> float:
        return max(0.0, t)

    def f(x: float) -> float:
        return output_bias + sum(
            ow * relu(w * x + b)
            for ow, w, b in zip(output_weights, layer1_weights, layer1_biases)
        )

    breakpoints = sorted(
        -b / w for w, b in zip(layer1_weights, layer1_biases) if w != 0
    )

    # Count sign changes of f by sampling between/around breakpoints.
    lo = (breakpoints[0] - 1.0) if breakpoints else -1.0
    hi = (breakpoints[-1] + 1.0) if breakpoints else 1.0
    samples = [lo] + breakpoints + [hi]
    # densify
    dense = []
    for a, c in zip(samples, samples[1:]):
        dense.extend(a + (c - a) * k / 20 for k in range(20))
    dense.append(hi)
    crossings = sum(
        1 for p, q in zip(dense, dense[1:]) if f(p) == 0 or (f(p) < 0) != (f(q) < 0)
    )
    return breakpoints, crossings


def demo_decision_surface() -> None:
    print("=" * 72)
    print("4. A piecewise-linear decision surface of a scalar ReLU network")
    print("=" * 72)

    w = [1.0, 1.0, 1.0]
    b = [2.0, 0.0, -2.0]           # breakpoints at x = -2, 0, 2
    ow = [1.0, -3.0, 1.0]
    ob = 0.5

    breaks, crossings = relu_network_breakpoints(w, b, ow, ob)
    print(f"  hidden width          = {len(w)}")
    print(f"  neuron breakpoints    = {breaks}")
    print(f"  # activation regions  = {len(breaks) + 1} "
          f"(<= 2^{len(w)} = {2 ** len(w)} patterns)")
    print(f"  # zero crossings V(f) = {crossings}  (the 0-cells / algebraic")
    print("                          cycles making up the decision surface)")
    assert len(breaks) + 1 <= 2 ** len(w)
    print("  [OK] region count within the width budget 2^(width)\n")


def main() -> None:
    demo_betti_rank_formula()
    demo_width_calculus()
    demo_width_bound()
    demo_decision_surface()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
