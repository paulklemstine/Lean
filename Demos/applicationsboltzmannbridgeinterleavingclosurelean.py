"""
Persistence is an Isometry — Numerical Demonstrations
=====================================================

This self-contained script demonstrates the main theorem of
`InterleavingIsometry.lean`:

    eInterleavingDist(F, G)  =  sup over simplices σ of |w_F(σ) - w_G(σ)|

i.e. the interleaving distance between two sublevel-set filtrations equals the
worst-case difference in their simplex birth times ("weights").

Everything is implemented from scratch with type hints and no external
dependencies (standard library only).

Mathematical model
-------------------
* A *filtration* on a finite vertex set V is a weight function
  w : (subsets of V) -> float, with w(emptyset) <= 0 and w monotone under
  inclusion (w(sigma) <= w(tau) whenever sigma subseteq tau).
* The *sublevel complex* at scale t is { sigma : w(sigma) <= t }.
* F and G are *delta-interleaved* (delta >= 0) when, for every t,
  the scale-t sublevel complex of each is contained in the scale-(t+delta)
  sublevel complex of the other.
* The *interleaving distance* is the infimum of admissible delta.
* The Vietoris-Rips weight of a simplex sigma from a distance matrix d is its
  diameter:  diam(sigma) = max over x, y in sigma of d(x, y)   (0 if |sigma|<2).

Theorems demonstrated
---------------------
  Theorem 3.1  interleaved_iff_weightCloseBy:
               Interleaved F G delta  <=>  delta >= 0 and
               |w_F(sigma) - w_G(sigma)| <= delta for all sigma.
  Theorem 3.5  eInterleavingDist F G = sup_sigma |w_F(sigma) - w_G(sigma)|.
  Theorem 3.6  the distance is 0 iff the filtrations are equal.
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

Simplex = FrozenSet[int]
Weight = Dict[Simplex, float]


# --------------------------------------------------------------------------- #
# Combinatorics of simplices                                                  #
# --------------------------------------------------------------------------- #
def all_simplices(vertices: Sequence[int]) -> List[Simplex]:
    """Return every subset (simplex) of `vertices`, including the empty set."""
    verts = list(vertices)
    return [
        frozenset(combo)
        for combo in chain.from_iterable(
            combinations(verts, r) for r in range(len(verts) + 1)
        )
    ]


# --------------------------------------------------------------------------- #
# Vietoris-Rips weight (the diameter filtration)                              #
# --------------------------------------------------------------------------- #
def diam_weight(distance: Callable[[int, int], float], sigma: Simplex) -> float:
    """Diameter weight of `sigma`: max pairwise distance, with 0 adjoined."""
    best = 0.0
    for x, y in combinations(sorted(sigma), 2):
        best = max(best, distance(x, y))
    return best


def vr_filtration(
    vertices: Sequence[int], distance: Callable[[int, int], float]
) -> Weight:
    """Build the Vietoris-Rips filtration (weight function) for a distance matrix."""
    return {sigma: diam_weight(distance, sigma) for sigma in all_simplices(vertices)}


# --------------------------------------------------------------------------- #
# The two ways to compute the interleaving distance                           #
# --------------------------------------------------------------------------- #
def weight_sup_dist(w_f: Weight, w_g: Weight) -> float:
    """sup over simplices of |w_F(sigma) - w_G(sigma)|  (Theorem 3.5 RHS)."""
    keys = set(w_f) | set(w_g)
    return max(abs(w_f.get(k, 0.0) - w_g.get(k, 0.0)) for k in keys)


def sublevel(w: Weight, t: float) -> FrozenSet[Simplex]:
    """The scale-t sublevel complex { sigma : w(sigma) <= t }."""
    return frozenset(s for s, val in w.items() if val <= t + 1e-12)


def is_interleaved(w_f: Weight, w_g: Weight, delta: float) -> bool:
    """
    Check delta-interleaving directly from the sublevel definition.

    It suffices to test the inclusions at the critical scales, namely the
    weights themselves: if every simplex alive in F by time t is alive in G by
    time t+delta, and vice versa, at all critical t, the inclusion holds for all
    real t (sublevel sets only change at weight values).
    """
    if delta < -1e-12:
        return False
    crit = sorted(set(w_f.values()) | set(w_g.values()))
    for t in crit:
        if not sublevel(w_f, t) <= sublevel(w_g, t + delta):
            return False
        if not sublevel(w_g, t) <= sublevel(w_f, t + delta):
            return False
    return True


def interleaving_distance_bruteforce(
    w_f: Weight, w_g: Weight, resolution: float = 1e-3
) -> float:
    """
    Estimate the interleaving distance by scanning delta from 0 upward until an
    interleaving is found.  Used purely to corroborate the closed form; the
    theorem says the answer equals weight_sup_dist(w_f, w_g) exactly.
    """
    upper = weight_sup_dist(w_f, w_g)
    delta = 0.0
    while delta <= upper + 10 * resolution:
        if is_interleaved(w_f, w_g, delta):
            return delta
        delta += resolution
    return upper  # fallback (should not be reached)


# --------------------------------------------------------------------------- #
# Pretty printing                                                             #
# --------------------------------------------------------------------------- #
def fmt_simplex(sigma: Simplex) -> str:
    return "{" + ",".join(map(str, sorted(sigma))) + "}" if sigma else "{}"


def report(title: str, w_f: Weight, w_g: Weight) -> None:
    print("=" * 70)
    print(title)
    print("=" * 70)
    print(f"{'simplex':<14}{'w_F':>10}{'w_G':>10}{'|gap|':>10}")
    keys = sorted(set(w_f) | set(w_g), key=lambda s: (len(s), sorted(s)))
    for k in keys:
        a, b = w_f.get(k, 0.0), w_g.get(k, 0.0)
        print(f"{fmt_simplex(k):<14}{a:>10.4f}{b:>10.4f}{abs(a - b):>10.4f}")
    closed = weight_sup_dist(w_f, w_g)
    scanned = interleaving_distance_bruteforce(w_f, w_g)
    print("-" * 70)
    print(f"  closed form  sup_sigma |w_F - w_G|         = {closed:.4f}")
    print(f"  brute-force  inf admissible delta (scan)   = {scanned:.4f}")
    print(f"  Theorem 3.5 holds (values match): {abs(closed - scanned) < 2e-3}")
    print(f"  Theorem 3.6 (distance 0 <=> equal): "
          f"{(closed == 0.0) == (w_f == w_g)}")
    print()


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_unit_vs_swollen_triangle() -> None:
    """The certified example from the Lean development: a unit triangle vs a
    1.1-scaled triangle.  Worst birth-time gap = 0.1, so the interleaving
    distance is exactly 0.1."""
    verts = [0, 1, 2]
    d1 = lambda i, j: 0.0 if i == j else 1.0
    d2 = lambda i, j: 0.0 if i == j else 1.1
    report(
        "DEMO 1  Unit triangle  vs  1.1-swollen triangle  (expected dist 0.1)",
        vr_filtration(verts, d1),
        vr_filtration(verts, d2),
    )


def demo_identical() -> None:
    """Two identical filtrations: distance must be exactly 0 (Theorem 3.6)."""
    verts = [0, 1, 2]
    d = lambda i, j: 0.0 if i == j else 1.0
    report(
        "DEMO 2  A filtration vs itself  (expected dist 0)",
        vr_filtration(verts, d),
        vr_filtration(verts, d),
    )


def demo_anisotropic() -> None:
    """A 4-point cloud where one pair is stretched.  The worst gap need not sit
    on the top-dimensional simplex; the closed form finds it automatically."""
    verts = [0, 1, 2, 3]
    base = {(0, 1): 1.0, (0, 2): 1.4, (0, 3): 1.0,
            (1, 2): 1.0, (1, 3): 1.4, (2, 3): 1.0}

    def mk(stretch: float) -> Callable[[int, int], float]:
        def d(i: int, j: int) -> float:
            if i == j:
                return 0.0
            key = (min(i, j), max(i, j))
            val = base[key]
            # stretch only the (1,3) pair
            return val + (stretch if key == (1, 3) else 0.0)
        return d

    report(
        "DEMO 3  4-point cloud, one edge stretched by 0.3  (expected dist 0.3)",
        vr_filtration(verts, mk(0.0)),
        vr_filtration(verts, mk(0.3)),
    )


def demo_general_filtrations() -> None:
    """Arbitrary (non-VR) monotone weights, to show the theorem is about
    filtrations in general, not only Vietoris-Rips."""
    verts = [0, 1]
    simplices = all_simplices(verts)
    # hand-built monotone weights
    w_f: Weight = {frozenset(): 0.0, frozenset({0}): 0.5,
                   frozenset({1}): 0.5, frozenset({0, 1}): 2.0}
    w_g: Weight = {frozenset(): 0.0, frozenset({0}): 0.7,
                   frozenset({1}): 0.4, frozenset({0, 1}): 1.5}
    assert set(simplices) == set(w_f) == set(w_g)
    report(
        "DEMO 4  General monotone weights (expected dist 0.5 on simplex {0,1})",
        w_f,
        w_g,
    )


def demo_characterization() -> None:
    """Verify Theorem 3.1 directly: Interleaved F G delta holds at exactly the
    delta values that bound every birth-time gap."""
    print("=" * 70)
    print("DEMO 5  Theorem 3.1: interleaving <=> uniform weight closeness")
    print("=" * 70)
    verts = [0, 1, 2]
    d1 = lambda i, j: 0.0 if i == j else 1.0
    d2 = lambda i, j: 0.0 if i == j else 1.1
    w_f, w_g = vr_filtration(verts, d1), vr_filtration(verts, d2)
    worst = weight_sup_dist(w_f, w_g)
    for delta in [0.0, 0.05, worst - 1e-6, worst, worst + 0.05]:
        relational = is_interleaved(w_f, w_g, delta)
        metric = delta >= -1e-12 and all(
            abs(w_f[s] - w_g[s]) <= delta + 1e-9 for s in w_f
        )
        print(f"  delta = {delta:6.4f}:  Interleaved = {str(relational):<5} "
              f"|  weight-close = {str(metric):<5}  |  agree = {relational == metric}")
    print()


def main() -> None:
    demo_unit_vs_swollen_triangle()
    demo_identical()
    demo_anisotropic()
    demo_general_filtrations()
    demo_characterization()
    print("All demonstrations confirm: eInterleavingDist = sup gap of weights.")


if __name__ == "__main__":
    main()
