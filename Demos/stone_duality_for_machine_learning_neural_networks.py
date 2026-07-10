"""
Stone Duality for Neural Networks — Numerical Demonstrations
============================================================

This self-contained script illustrates the central results connecting a
single fully-connected (ReLU-type) neural-network layer to a finite Boolean
algebra via Stone duality.

Set-up.  Fix a finite sample of input points X and a layer of n neurons with
weight rows W and biases b.  Evaluating the neurons at a point x and recording
which neurons are *active* (pre-activation > 0) yields an *activation pattern*
    act(x) : {0, 1, ..., n-1} -> {False, True}.
The distinct realized patterns are the *linear regions* cut on the sample.  A
set S of patterns selects a *decision region* {x : act(x) in S}, and the
collection of all decision regions forms the *decision algebra* B(f).

The results demonstrated below:
  1. #linear regions <= min(2^n, |X|).
  2. |B(f)| = 2^(#linear regions)                        (Stone duality count).
  3. The map S |-> decision region is a Boolean homomorphism.
  4. Distinct subsets of realized patterns give distinct regions
     (atoms of B(f) = linear regions).
  5. Shattering a sample of size m requires m <= 2^n         (VC-style bound).
"""

from __future__ import annotations

from itertools import chain, combinations, product
from typing import Callable, FrozenSet, Iterable, List, Sequence, Tuple

Vector = Tuple[float, ...]
Pattern = Tuple[bool, ...]


# --------------------------------------------------------------------------- #
#  Core layer definitions (all functions inlined, fully self-contained)       #
# --------------------------------------------------------------------------- #
def neuron_activation(
    W: Sequence[Vector], b: Sequence[float], x: Vector
) -> Pattern:
    """Activation pattern of a layer of n neurons at a point x in R^d.

    Neuron i fires iff its pre-activation <W_i, x> + b_i is strictly positive.
    """
    return tuple(
        sum(w_ij * x_j for w_ij, x_j in zip(W_i, x)) + b_i > 0.0
        for W_i, b_i in zip(W, b)
    )


def sample_activation(
    W: Sequence[Vector], b: Sequence[float], pts: Sequence[Vector]
) -> List[Pattern]:
    """Evaluate the layer on a finite sample of input points."""
    return [neuron_activation(W, b, x) for x in pts]


def linear_regions(patterns: Sequence[Pattern]) -> FrozenSet[Pattern]:
    """The set of realized activation patterns (the linear regions)."""
    return frozenset(patterns)


def powerset(items: Sequence[Pattern]) -> Iterable[FrozenSet[Pattern]]:
    """All subsets of a finite collection."""
    lst = list(items)
    return (
        frozenset(c)
        for c in chain.from_iterable(combinations(lst, r) for r in range(len(lst) + 1))
    )


def decision_region(
    patterns: Sequence[Pattern], S: FrozenSet[Pattern]
) -> FrozenSet[int]:
    """Indices of sample points whose activation pattern lies in S."""
    return frozenset(i for i, p in enumerate(patterns) if p in S)


def decision_algebra(patterns: Sequence[Pattern]) -> FrozenSet[FrozenSet[int]]:
    """All decision regions: the image of the powerset under decision_region.

    By the theory this equals the image of the powerset of the *linear
    regions*, which is what we compute (an equivalent, smaller enumeration).
    """
    regs = list(linear_regions(patterns))
    return frozenset(decision_region(patterns, S) for S in powerset(regs))


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_bounds() -> None:
    print("=" * 70)
    print("DEMO 1  Bounds on the number of linear regions")
    print("=" * 70)
    # A layer of n = 3 neurons in the plane (d = 2).
    W = [(1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    b = [0.0, 0.0, -0.5]
    # A grid sample of 25 points in [-1, 1]^2.
    grid = [(-1.0, -0.5, 0.0, 0.5, 1.0)[i] for i in range(5)]
    pts = [(gx, gy) for gx in grid for gy in grid]
    patterns = sample_activation(W, b, pts)
    regs = linear_regions(patterns)
    n = len(W)
    print(f"  neurons n = {n},  sample size |X| = {len(pts)}")
    print(f"  #linear regions realized      = {len(regs)}")
    print(f"  syntactic bound 2^n           = {2 ** n}")
    print(f"  sample bound |X|              = {len(pts)}")
    print(f"  combined bound min(2^n, |X|)  = {min(2 ** n, len(pts))}")
    assert len(regs) <= min(2 ** n, len(pts))
    print("  OK: #linear regions <= min(2^n, |X|)\n")


def demo_stone_count() -> None:
    print("=" * 70)
    print("DEMO 2  Stone duality count: |B(f)| = 2^(#linear regions)")
    print("=" * 70)
    W = [(1.0, 0.0), (0.0, 1.0)]
    b = [0.0, 0.0]
    pts = [(1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0), (0.3, -0.7)]
    patterns = sample_activation(W, b, pts)
    regs = linear_regions(patterns)
    algebra = decision_algebra(patterns)
    print(f"  realized patterns (linear regions): {sorted(regs)}")
    print(f"  #linear regions r     = {len(regs)}")
    print(f"  |decision algebra|    = {len(algebra)}")
    print(f"  2^r                   = {2 ** len(regs)}")
    assert len(algebra) == 2 ** len(regs)
    print("  OK: |B(f)| = 2^(#linear regions)\n")


def demo_homomorphism() -> None:
    print("=" * 70)
    print("DEMO 3  S |-> decision region is a Boolean-algebra homomorphism")
    print("=" * 70)
    W = [(1.0, 0.0), (0.0, 1.0), (-1.0, 1.0)]
    b = [0.0, 0.0, 0.0]
    pts = [(0.5 * i - 2.0, 0.7 * j - 2.0) for i in range(4) for j in range(4)]
    patterns = sample_activation(W, b, pts)
    regs = list(linear_regions(patterns))
    universe = frozenset(regs)

    def dr(S: FrozenSet[Pattern]) -> FrozenSet[int]:
        return decision_region(patterns, S)

    checks = 0
    for S in powerset(regs):
        for T in powerset(regs):
            assert dr(S | T) == dr(S) | dr(T)          # union
            assert dr(S & T) == dr(S) & dr(T)          # intersection
            assert dr(universe - S) == dr(universe) - dr(S)  # complement
            checks += 1
    assert dr(frozenset()) == frozenset()              # bottom
    assert dr(universe) == frozenset(range(len(pts)))  # top
    print(f"  verified union/intersection/complement on {checks} subset pairs")
    print("  OK: homomorphism laws hold (empty, univ, union, inter, compl)\n")


def demo_atoms_injectivity() -> None:
    print("=" * 70)
    print("DEMO 4  Atoms of B(f) are exactly the linear regions")
    print("=" * 70)
    W = [(1.0, 0.0), (0.0, 1.0)]
    b = [0.0, 0.0]
    pts = [(1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)]
    patterns = sample_activation(W, b, pts)
    regs = list(linear_regions(patterns))
    seen = {}
    for S in powerset(regs):
        r = decision_region(patterns, S)
        assert r not in seen, "distinct subsets collided -> not injective"
        seen[r] = S
    print(f"  #subsets of realized patterns = {2 ** len(regs)}")
    print(f"  #distinct decision regions    = {len(seen)}")
    print("  atoms (singletons -> fibers):")
    for p in regs:
        atom = decision_region(patterns, frozenset([p]))
        print(f"    pattern {tuple(int(v) for v in p)} -> points {sorted(atom)}")
    print("  OK: S |-> region is injective on subsets of linear regions\n")


def demo_shattering() -> None:
    print("=" * 70)
    print("DEMO 5  VC-style capacity: shattering size m requires m <= 2^n")
    print("=" * 70)
    # n = 2 neurons can realize at most 4 patterns, so it can shatter
    # a sample of at most 4 points.
    n = 2
    W = [(1.0, 0.0), (0.0, 1.0)]
    b = [0.0, 0.0]
    # Four points in distinct quadrants -> four distinct patterns -> shattered.
    pts4 = [(1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)]
    patterns4 = sample_activation(W, b, pts4)
    algebra4 = decision_algebra(patterns4)
    shatters4 = len(algebra4) == 2 ** len(pts4)
    print(f"  n = {n} neurons,  2^n = {2 ** n}")
    print(f"  sample of 4 points: shatters = {shatters4}  (needs 4 <= 4)")
    assert shatters4 and len(pts4) <= 2 ** n
    # Five points cannot be shattered: pigeonhole forces two to share a pattern.
    pts5 = pts4 + [(0.5, 0.5)]
    patterns5 = sample_activation(W, b, pts5)
    algebra5 = decision_algebra(patterns5)
    shatters5 = len(algebra5) == 2 ** len(pts5)
    print(f"  sample of 5 points: shatters = {shatters5}  (5 > 2^n = 4)")
    assert not shatters5
    print("  OK: a layer of n neurons shatters at most 2^n points\n")


def main() -> None:
    demo_bounds()
    demo_stone_count()
    demo_homomorphism()
    demo_atoms_injectivity()
    demo_shattering()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
