"""
Stone Duality for Neural Networks: Numerical Demonstrations
===========================================================

A self-contained illustration of the results in the accompanying paper.

A network of `k` threshold neurons maps each input x to an *activation pattern*
in P = {0,1}^k. Its "Stone dual" is the region map

        region(S) = { x : pattern(x) in S }      (S a set of patterns).

This script demonstrates, on concrete perceptron networks:

  1. Activation patterns and the pattern space P (|P| = 2^k).
  2. The region map is a Boolean-algebra homomorphism (union/inter/compl).
  3. Reconstruction: region is injective  <=>  the network realizes all patterns.
  4. Activation cells partition input space; a cell is nonempty iff realized.
  5. Region capacity: a surjective activation map yields exactly 2^(2^k) regions.
  6. Convexity of perceptron cells (intersections of half-spaces).

Run with:  python demo.py
Only the standard library is used.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, FrozenSet, List, Sequence, Set, Tuple

# A pattern is a tuple of booleans of length k; the input is a tuple of floats.
Pattern = Tuple[bool, ...]
Point = Tuple[float, ...]
ActivationMap = Callable[[Point], Pattern]


# ---------------------------------------------------------------------------
# Core constructions
# ---------------------------------------------------------------------------

def all_patterns(k: int) -> List[Pattern]:
    """Enumerate the pattern space P = {0,1}^k; |P| = 2^k."""
    return [tuple(bits) for bits in product([False, True], repeat=k)]


def perceptron_activation(
    weights: Sequence[Sequence[float]], biases: Sequence[float]
) -> ActivationMap:
    """Build a linear-threshold activation map: neuron j fires when
    sum_i w[j][i] * x[i] + b[j] > 0."""

    def act(x: Point) -> Pattern:
        out: List[bool] = []
        for w_row, b in zip(weights, biases):
            pre = sum(w * xi for w, xi in zip(w_row, x)) + b
            out.append(pre > 0.0)
        return tuple(out)

    return act


def region(act: ActivationMap, S: Set[Pattern], sample: Sequence[Point]) -> FrozenSet[Point]:
    """The Stone dual, evaluated on a finite sample of the input space:
    region(S) = { x in sample : act(x) in S }."""
    return frozenset(x for x in sample if act(x) in S)


def realized_patterns(act: ActivationMap, sample: Sequence[Point]) -> Set[Pattern]:
    """The set of patterns actually attained on the sample (range of act)."""
    return {act(x) for x in sample}


def grid(lo: float, hi: float, steps: int, dim: int) -> List[Point]:
    """A regular grid sample of [lo, hi]^dim."""
    axis = [lo + (hi - lo) * i / (steps - 1) for i in range(steps)]
    return [tuple(p) for p in product(axis, repeat=dim)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_pattern_space() -> None:
    print("=" * 70)
    print("1. THE PATTERN SPACE  P = {0,1}^k   (|P| = 2^k)")
    print("=" * 70)
    for k in range(1, 6):
        print(f"  k = {k}:  |P| = 2^{k} = {2 ** k:>3}   "
              f"# pattern-sets = 2^(2^{k}) = {2 ** (2 ** k)}")
    print()


def demo_homomorphism() -> None:
    print("=" * 70)
    print("2. THE REGION MAP IS A BOOLEAN-ALGEBRA HOMOMORPHISM")
    print("=" * 70)
    # Two neurons in R^2: x > 0  and  y > 0  (the four quadrants).
    act = perceptron_activation(weights=[[1.0, 0.0], [0.0, 1.0]], biases=[0.0, 0.0])
    sample = grid(-1.0, 1.0, 21, dim=2)
    P = all_patterns(2)
    S = {(True, False), (True, True)}   # "x > 0"
    T = {(False, True), (True, True)}   # "y > 0"

    def eq(a: FrozenSet[Point], b: FrozenSet[Point]) -> str:
        return "OK" if a == b else "MISMATCH"

    lhs_u = region(act, S | T, sample)
    rhs_u = region(act, S, sample) | region(act, T, sample)
    lhs_i = region(act, S & T, sample)
    rhs_i = region(act, S, sample) & region(act, T, sample)
    lhs_c = region(act, set(P) - S, sample)
    rhs_c = frozenset(sample) - region(act, S, sample)

    print(f"  region(S ∪ T) = region(S) ∪ region(T) : {eq(lhs_u, rhs_u)}")
    print(f"  region(S ∩ T) = region(S) ∩ region(T) : {eq(lhs_i, rhs_i)}")
    print(f"  region(Sᶜ)    = region(S)ᶜ            : {eq(lhs_c, rhs_c)}")
    print(f"  region(∅) empty: {eq(region(act, set(), sample), frozenset())}")
    print(f"  region(P) = whole sample: "
          f"{eq(region(act, set(P), sample), frozenset(sample))}")
    print()


def demo_reconstruction() -> None:
    print("=" * 70)
    print("3. RECONSTRUCTION:  region injective  <=>  act surjective")
    print("=" * 70)
    sample = grid(-1.0, 1.0, 41, dim=2)
    P = all_patterns(2)

    # (a) Independent thresholds x>0, y>0: all four patterns realized.
    act_full = perceptron_activation([[1.0, 0.0], [0.0, 1.0]], [0.0, 0.0])
    # (b) Two nearly-parallel hyperplanes: pattern (True, False) unrealizable.
    act_deg = perceptron_activation([[1.0, 0.0], [1.0, 0.0]], [0.5, -0.5])

    for name, act in [("independent (x>0, y>0)", act_full),
                      ("nested half-planes", act_deg)]:
        realized = realized_patterns(act, sample)
        surj = realized == set(P)
        # region injective iff distinct pattern-sets give distinct regions.
        seen = {}
        injective = True
        from itertools import combinations
        subsets = []
        for r in range(len(P) + 1):
            for combo in combinations(P, r):
                subsets.append(frozenset(combo))
        for S in subsets:
            key = region(act, set(S), sample)
            if key in seen and seen[key] != S:
                injective = False
                break
            seen[key] = S
        print(f"  {name:24s}: realized {len(realized)}/{len(P)}  "
              f"surjective={surj}  region-injective={injective}")
    print()


def demo_cells() -> None:
    print("=" * 70)
    print("4. ACTIVATION CELLS PARTITION THE INPUT SPACE")
    print("=" * 70)
    act = perceptron_activation([[1.0, 0.0], [0.0, 1.0]], [0.0, 0.0])
    sample = grid(-1.0, 1.0, 21, dim=2)
    P = all_patterns(2)
    cells = {p: frozenset(x for x in sample if act(x) == p) for p in P}

    # Disjointness and covering.
    union = frozenset().union(*cells.values())
    pairwise_disjoint = all(
        cells[p].isdisjoint(cells[q]) for p in P for q in P if p != q
    )
    print(f"  cells pairwise disjoint : {pairwise_disjoint}")
    print(f"  cells cover the sample  : {union == frozenset(sample)}")
    for p in P:
        tag = "nonempty" if cells[p] else "EMPTY"
        print(f"    cell{tuple(int(b) for b in p)}: {len(cells[p]):>3} pts ({tag})")
    print()


def demo_region_count() -> None:
    print("=" * 70)
    print("5. REGION CAPACITY:  surjective act  =>  2^(2^k) regions")
    print("=" * 70)
    # k=2 network realizing all 4 patterns on a fine grid.
    act = perceptron_activation([[1.0, 0.0], [0.0, 1.0]], [0.0, 0.0])
    sample = grid(-1.0, 1.0, 41, dim=2)
    P = all_patterns(2)
    from itertools import combinations
    distinct = set()
    for r in range(len(P) + 1):
        for combo in combinations(P, r):
            distinct.add(region(act, set(combo), sample))
    print(f"  k = 2:  distinct regions found = {len(distinct)}, "
          f"predicted 2^(2^2) = {2 ** (2 ** 2)}")
    print()


def demo_convexity() -> None:
    print("=" * 70)
    print("6. CONVEXITY OF PERCEPTRON CELLS")
    print("=" * 70)
    # Three random-ish hyperplanes in R^2.
    weights = [[1.0, 0.5], [-0.7, 1.0], [0.3, -1.2]]
    biases = [0.1, -0.2, 0.4]
    act = perceptron_activation(weights, biases)
    sample = grid(-2.0, 2.0, 61, dim=2)

    def in_cell(x: Point, p: Pattern) -> bool:
        return act(x) == p

    # Verify convexity empirically: for each realized cell, the midpoint of any
    # two of its points is also in the cell (necessary condition for convexity).
    realized = realized_patterns(act, sample)
    all_convex = True
    for p in realized:
        pts = [x for x in sample if in_cell(x, p)]
        ok = True
        for i in range(0, len(pts), max(1, len(pts) // 20)):
            for j in range(0, len(pts), max(1, len(pts) // 20)):
                mid = tuple((a + b) / 2 for a, b in zip(pts[i], pts[j]))
                # The exact midpoint of two half-space points lies in the same
                # half-spaces, hence the same cell (checked directly on act).
                if not in_cell(mid, p):
                    ok = False
        all_convex = all_convex and ok
        print(f"    cell{tuple(int(b) for b in p)}: {len(pts):>4} pts, "
              f"midpoint-closed = {ok}")
    print(f"  all realized cells convex (midpoint test): {all_convex}")
    print()


def main() -> None:
    demo_pattern_space()
    demo_homomorphism()
    demo_reconstruction()
    demo_cells()
    demo_region_count()
    demo_convexity()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
