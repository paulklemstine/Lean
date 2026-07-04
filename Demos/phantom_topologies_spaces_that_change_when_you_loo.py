"""
Phantom Topologies: Spaces That Change When You Look at Them
===========================================================

Numerical demonstrations of the two headline results about observer-dependent
("phantom") topologies on the real line:

  * CONSENSUS RECONSTRUCTION.  The Euclidean topology on R is the *agreement*
    (supremum in the lattice of topologies) of two complementary observers:
    the lower-limit / right-looking observer (basic opens  [x, b) ) and the
    upper-limit / left-looking observer (basic opens  (a, x] ).  A set is
    Euclidean-open iff it is open for BOTH observers.

  * POSSIBILITY COLLAPSE.  The *possibility* (infimum) of the SAME two
    observers is the DISCRETE topology, because for a < x < b

            [x, b)  cap  (a, x]  =  {x}.

    Every singleton becomes open, hence every set is open.

Because R is infinite, we illustrate the phenomena three ways:

  1. Exact rational verification of the singleton-collapse identity
     [x, b) cap (a, x] = {x}  on dense rational grids (no floating point).
  2. A finite lattice-of-topologies engine that computes consensus (supremum)
     and possibility (infimum) of arbitrary finite topologies, confirming the
     sandwich  possibility <= observer <= consensus  and the modal duality.
  3. A "half-open observers" model on a finite ordered sample of the line,
     showing that pooling the left-cut and right-cut viewpoints isolates every
     sample point (discreteness), while their agreement keeps only two-sided
     neighbourhoods.

Self-contained: standard library only.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, Iterable, List, Sequence, Set, Tuple

# A finite topology is represented as a set of open sets; each open set is a
# frozenset of points.
Point = int
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


# ---------------------------------------------------------------------------
# 1. Exact verification of the collapse identity  [x, b) cap (a, x] = {x}
# ---------------------------------------------------------------------------

def half_open_right(x: Fraction, b: Fraction, grid: Sequence[Fraction]) -> Set[Fraction]:
    """Points of `grid` lying in the right half-open interval [x, b)."""
    return {p for p in grid if x <= p < b}


def half_open_left(a: Fraction, x: Fraction, grid: Sequence[Fraction]) -> Set[Fraction]:
    """Points of `grid` lying in the left half-open interval (a, x]."""
    return {p for p in grid if a < p <= x}


def verify_singleton_collapse(
    a: Fraction, x: Fraction, b: Fraction, grid: Sequence[Fraction]
) -> bool:
    """Check [x, b) cap (a, x] = {x} on a rational grid (requires a < x < b)."""
    assert a < x < b, "identity requires a < x < b"
    left = half_open_left(a, x, grid)
    right = half_open_right(x, b, grid)
    return left & right == {x}


def demo_singleton_collapse() -> None:
    print("=" * 70)
    print("1. SINGLETON COLLAPSE:  [x, b) cap (a, x] = {x}   (exact rationals)")
    print("=" * 70)
    # A dense rational grid on [-2, 2] with step 1/12.
    step = Fraction(1, 12)
    grid = [Fraction(-24) * step + k * step for k in range(0, 97)]
    triples = [
        (Fraction(-1), Fraction(0), Fraction(1)),
        (Fraction(-1, 2), Fraction(1, 3), Fraction(3, 2)),
        (Fraction(-2), Fraction(-1, 4), Fraction(1)),
        (Fraction(0), Fraction(1, 2), Fraction(2)),
    ]
    all_ok = True
    for (a, x, b) in triples:
        ok = verify_singleton_collapse(a, x, b, grid)
        all_ok &= ok
        print(f"  a={str(a):>6}  x={str(x):>6}  b={str(b):>6}  ->  "
              f"[x,b) cap (a,x] = {{{x}}}  : {ok}")
    print(f"\n  All singleton-collapse checks passed: {all_ok}\n")


# ---------------------------------------------------------------------------
# 2. Finite lattice of topologies: consensus (sup) and possibility (inf)
# ---------------------------------------------------------------------------

def generate_topology(ground: FrozenSet[Point], subbasis: Iterable[OpenSet]) -> Topology:
    """Smallest topology on `ground` containing `subbasis`.

    Close the subbasis (together with empty set and the whole space) under
    finite intersections, then under arbitrary unions.
    """
    empty: OpenSet = frozenset()
    sub: Set[OpenSet] = {empty, ground}
    for s in subbasis:
        sub.add(frozenset(s) & ground)

    # Close under pairwise (hence finite) intersections.
    basis: Set[OpenSet] = set(sub)
    changed = True
    while changed:
        changed = False
        for u in list(basis):
            for v in list(basis):
                w = u & v
                if w not in basis:
                    basis.add(w)
                    changed = True

    # Close under arbitrary unions (build all unions of basis elements).
    opens: Set[OpenSet] = {empty}
    for r in range(1, len(basis) + 1):
        for combo in combinations(basis, r):
            union: OpenSet = frozenset().union(*combo)
            opens.add(union)
    opens.add(empty)
    opens.add(ground)
    return frozenset(opens)


def is_finer(t: Topology, s: Topology) -> bool:
    """t is finer than s  (t <= s in the refinement order):  every s-open is t-open."""
    return s <= t


def consensus(topologies: Sequence[Topology]) -> Topology:
    """Consensus (supremum): sets open in EVERY observer -> intersection of opens."""
    if not topologies:
        raise ValueError("need at least one topology")
    result: Set[OpenSet] = set(topologies[0])
    for t in topologies[1:]:
        result &= set(t)
    return frozenset(result)


def possibility(ground: FrozenSet[Point], topologies: Sequence[Topology]) -> Topology:
    """Possibility (infimum): topology GENERATED by the union of all observers' opens."""
    union_opens: Set[OpenSet] = set()
    for t in topologies:
        union_opens |= set(t)
    return generate_topology(ground, union_opens)


def discrete(ground: FrozenSet[Point]) -> Topology:
    pts = list(ground)
    opens: Set[OpenSet] = {frozenset()}
    for r in range(1, len(pts) + 1):
        for combo in combinations(pts, r):
            opens.add(frozenset(combo))
    return frozenset(opens)


def demo_lattice_duality() -> None:
    print("=" * 70)
    print("2. LATTICE DUALITY:  possibility <= observer <= consensus")
    print("=" * 70)
    ground: FrozenSet[Point] = frozenset({0, 1, 2})
    # Two genuinely disagreeing observers on {0,1,2}.
    obs_A = generate_topology(ground, [frozenset({0}), frozenset({0, 1})])
    obs_B = generate_topology(ground, [frozenset({2}), frozenset({1, 2})])

    con = consensus([obs_A, obs_B])
    pos = possibility(ground, [obs_A, obs_B])

    print(f"  |ground| = {len(ground)}   points = {sorted(ground)}")
    print(f"  observer A opens: {sorted(map(sorted, obs_A))}")
    print(f"  observer B opens: {sorted(map(sorted, obs_B))}")
    print(f"  consensus opens : {sorted(map(sorted, con))}")
    print(f"  possibility opens: {sorted(map(sorted, pos))}")

    # Sandwich: possibility finer than each observer; each observer finer than consensus.
    checks = {
        "possibility <= A": is_finer(pos, obs_A),
        "possibility <= B": is_finer(pos, obs_B),
        "A <= consensus": is_finer(obs_A, con),
        "B <= consensus": is_finer(obs_B, con),
        "possibility == discrete": pos == discrete(ground),
    }
    print()
    for name, ok in checks.items():
        print(f"    {name:>28} : {ok}")
    print()


# ---------------------------------------------------------------------------
# 3. Half-open observers on a finite ordered sample of the line
# ---------------------------------------------------------------------------

def right_looking_topology(sample: Sequence[Fraction]) -> Topology:
    """Lower-limit observer on a finite ordered sample: basic opens are the
    'right rays'  {p : p >= sample[i]} = [sample[i], +inf) restricted to the sample."""
    ground = frozenset(range(len(sample)))
    subbasis = [frozenset(j for j in range(len(sample)) if sample[j] >= sample[i])
                for i in range(len(sample))]
    return generate_topology(ground, subbasis)


def left_looking_topology(sample: Sequence[Fraction]) -> Topology:
    """Upper-limit observer: basic opens are the 'left rays'
    {p : p <= sample[i]} = (-inf, sample[i]] restricted to the sample."""
    ground = frozenset(range(len(sample)))
    subbasis = [frozenset(j for j in range(len(sample)) if sample[j] <= sample[i])
                for i in range(len(sample))]
    return generate_topology(ground, subbasis)


def demo_half_open_observers() -> None:
    print("=" * 70)
    print("3. HALF-OPEN OBSERVERS on a finite ordered sample of the line")
    print("=" * 70)
    sample: List[Fraction] = [Fraction(k, 2) for k in range(-2, 3)]  # -1, -1/2, 0, 1/2, 1
    print(f"  sample points: {[str(s) for s in sample]}")

    right = right_looking_topology(sample)   # left-cut viewpoint
    left = left_looking_topology(sample)     # right-cut viewpoint
    ground = frozenset(range(len(sample)))

    pos = possibility(ground, [left, right])
    con = consensus([left, right])

    # Each singleton = right-ray cap left-ray  (the finite analogue of [x,b) cap (a,x]).
    print("\n  Pooling the two viewpoints isolates every sample point:")
    for i, val in enumerate(sample):
        singleton = frozenset({i})
        print(f"    point {str(val):>5}  ->  {{{val}}} is possibility-open: "
              f"{singleton in pos}")

    print(f"\n  possibility == discrete : {pos == discrete(ground)}")
    print(f"  #consensus opens = {len(con)}  (agreement keeps far fewer opens)")
    print(f"  #possibility opens = {len(pos)} = 2^{len(sample)} "
          f"(every subset is open)\n")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_singleton_collapse()
    demo_lattice_duality()
    demo_half_open_observers()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("  * Consensus of the two half-open observers reconstructs the")
    print("    two-sided (Euclidean) neighbourhoods.")
    print("  * Possibility of the SAME two observers collapses to the discrete")
    print("    topology via  [x, b) cap (a, x] = {x}.")
    print("  * One fixed pair of observers, two opposite realities.")


if __name__ == "__main__":
    main()
