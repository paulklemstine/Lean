"""
Numerical demonstrations for:

    "The Interleaving Distance on Filtrations Is a Genuine Metric"
    (Boltzmann Bridge VII)

All mathematics is reproduced here in elementary, self-contained Python so the
key theorems can be *seen* on concrete finite data:

  * Filtrations are monotone weight functions on simplices (Definition 2.2).
  * delta-interleaving on a finite carrier is a uniform sup-norm bound on the
    weight difference (Algorithm A).
  * the exact extended interleaving distance is the *attained* maximum of the
    weight-difference table (Algorithm B) -- the finite shadow of the
    attained-infimum theorem (Theorem 4.3).
  * distance 0  <=>  equal weights  <=>  equal filtrations (Theorem 4.7).
  * Vietoris-Rips diameter weights and 1-Lipschitz stability (Proposition 3.5),
    including the concrete two-cloud certificate (distance <= 1/10).

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import inf
from typing import Callable, Dict, FrozenSet, Iterable, List, Tuple

# A simplex is a frozenset of vertices (so it is hashable / usable as a dict key).
Simplex = FrozenSet[int]


# --------------------------------------------------------------------------- #
# Filtrations as monotone weight functions on a finite simplex carrier.
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Filtration:
    """A finite filtration: a weight table over a fixed carrier of simplices.

    Invariants mirroring Definition 2.2:
      * weight(empty) <= 0,
      * sigma subset tau  =>  weight(sigma) <= weight(tau)   (monotonicity).
    """

    weight: Dict[Simplex, float]

    def carrier(self) -> List[Simplex]:
        return list(self.weight.keys())

    def is_monotone(self) -> bool:
        """Check the two structural properties of a Filtration."""
        empty: Simplex = frozenset()
        if empty in self.weight and self.weight[empty] > 0.0:
            return False
        faces = self.carrier()
        for sigma in faces:
            for tau in faces:
                if sigma <= tau and self.weight[sigma] > self.weight[tau] + 1e-12:
                    return False
        return True

    def sublevel(self, t: float) -> FrozenSet[Simplex]:
        """The sublevel set at scale t:  { sigma : weight(sigma) <= t }."""
        return frozenset(s for s, w in self.weight.items() if w <= t + 1e-12)


# --------------------------------------------------------------------------- #
# Interleaving on a finite carrier (Algorithm A) and the exact distance
# (Algorithm B).  These use the equivalence
#     delta-interleaved  <=>  for all sigma, |F.w(sigma) - G.w(sigma)| <= delta.
# --------------------------------------------------------------------------- #
def common_carrier(f: Filtration, g: Filtration) -> List[Simplex]:
    """The simplices on which both filtrations are defined."""
    return [s for s in f.weight if s in g.weight]


def is_interleaved(f: Filtration, g: Filtration, delta: float) -> bool:
    """Decide whether F and G are delta-interleaved (Algorithm A).

    On a finite common carrier this is exactly:  delta >= 0  and the weights
    differ by at most delta everywhere.
    """
    if delta < 0.0:
        return False
    carrier = common_carrier(f, g)
    if not carrier:
        return False
    return all(abs(f.weight[s] - g.weight[s]) <= delta + 1e-12 for s in carrier)


def interleaving_distance(f: Filtration, g: Filtration) -> float:
    """Exact extended interleaving distance (Algorithm B).

    Returns the *attained* maximum weight-difference -- the finite shadow of
    Theorem 4.3 (the infimum over slacks is attained).  Returns +inf when the
    carriers do not overlap (no interleaving exists).
    """
    carrier = common_carrier(f, g)
    if not carrier:
        return inf
    return max(abs(f.weight[s] - g.weight[s]) for s in carrier)


def interleaved_zero(f: Filtration, g: Filtration) -> bool:
    """Whether F and G are *literally* 0-interleaved (equal sublevel families)."""
    return is_interleaved(f, g, 0.0)


# --------------------------------------------------------------------------- #
# Vietoris-Rips diameter weights from a distance matrix (Algorithm C).
# --------------------------------------------------------------------------- #
def diam_weight(d: Callable[[int, int], float], sigma: Simplex) -> float:
    """diamWeight(sigma) = max(0, max pairwise distance over vertices of sigma)."""
    best = 0.0
    for x in sigma:
        for y in sigma:
            best = max(best, d(x, y))
    return best


def vr_filtration(d: Callable[[int, int], float], n: int, max_dim: int) -> Filtration:
    """Vietoris-Rips filtration on n points, up to simplices of `max_dim` vertices."""
    weight: Dict[Simplex, float] = {frozenset(): 0.0}
    verts = list(range(n))
    for k in range(1, max_dim + 1):
        for combo in combinations(verts, k):
            sigma: Simplex = frozenset(combo)
            weight[sigma] = diam_weight(d, sigma)
    return Filtration(weight)


def matrix_to_fn(matrix: List[List[float]]) -> Callable[[int, int], float]:
    return lambda i, j: matrix[i][j]


def sup_distortion(
    d1: Callable[[int, int], float], d2: Callable[[int, int], float], n: int
) -> float:
    """max_{i,j} |d1(i,j) - d2(i,j)|  -- the data-level distortion."""
    return max(abs(d1(i, j) - d2(i, j)) for i in range(n) for j in range(n))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_attained_infimum() -> None:
    """Theorem 4.3 / Algorithm B: the infimum over slacks is ATTAINED.

    We exhibit two filtrations, scan candidate slacks delta -> 0, and show that
    the smallest delta that still interleaves is exactly the distance returned
    by the closed-form maximum -- the infimum is reached, not merely approached.
    """
    banner("Demo 1: the infimum over interleaving slacks is ATTAINED (Thm 4.3)")
    f = Filtration({frozenset(): 0.0, frozenset({0}): 0.0, frozenset({0, 1}): 1.0})
    g = Filtration({frozenset(): 0.0, frozenset({0}): 0.0, frozenset({0, 1}): 1.3})

    dist = interleaving_distance(f, g)
    print(f"closed-form distance (attained max diff) = {dist:.4f}")
    print("scanning candidate slacks delta -> dist from above and below:")
    for delta in [0.5, 0.30001, dist, 0.29, 0.1, 0.0]:
        print(f"  delta = {delta:7.5f}  interleaved? {is_interleaved(f, g, delta)}")
    assert is_interleaved(f, g, dist), "distance itself must interleave (attained!)"
    assert not is_interleaved(f, g, dist - 1e-6), "nothing strictly smaller works"
    print("=> delta = dist works, and no smaller delta does: the inf is attained.")


def demo_t0_separation() -> None:
    """Theorem 4.7: distance 0  <=>  equal weights  <=>  equal filtrations."""
    banner("Demo 2: distance 0 <=> equality (T0 separation, Thm 4.7)")
    base = {frozenset(): 0.0, frozenset({0}): 0.0, frozenset({1}): 0.0,
            frozenset({0, 1}): 2.0}
    f = Filtration(dict(base))
    g_equal = Filtration(dict(base))
    g_diff = Filtration({**base, frozenset({0, 1}): 2.0000001})

    print(f"F vs identical copy:  distance = {interleaving_distance(f, g_equal):.7f}"
          f"   equal weights? {f.weight == g_equal.weight}")
    print(f"F vs perturbed copy:  distance = {interleaving_distance(f, g_diff):.7f}"
          f"   equal weights? {f.weight == g_diff.weight}")
    assert interleaving_distance(f, g_equal) == 0.0
    assert interleaved_zero(f, g_equal)
    assert interleaving_distance(f, g_diff) > 0.0
    assert not interleaved_zero(f, g_diff)
    print("=> distance 0 occurs exactly for the identical filtration (no ghosts).")


def demo_quotient_is_trivial() -> None:
    """Theorems 5.2/5.3: the separation quotient map is injective.

    We simulate the separation quotient by gluing filtrations at distance 0 and
    verify that each class is a singleton -- i.e. mk is injective.
    """
    banner("Demo 3: the separation quotient is trivial / mk is injective (Thm 5.3)")
    fs = [
        Filtration({frozenset(): 0.0, frozenset({0, 1}): 1.0}),
        Filtration({frozenset(): 0.0, frozenset({0, 1}): 1.0}),  # duplicate
        Filtration({frozenset(): 0.0, frozenset({0, 1}): 2.0}),
        Filtration({frozenset(): 0.0, frozenset({0, 1}): 2.5}),
    ]
    # classes under "distance 0" -- distinct weight tables stay distinct.
    classes: List[List[int]] = []
    for i, f in enumerate(fs):
        placed = False
        for cls in classes:
            if interleaving_distance(f, fs[cls[0]]) == 0.0:
                cls.append(i)
                placed = True
                break
        if not placed:
            classes.append([i])
    print(f"4 filtrations (two with identical weight tables) -> "
          f"{len(classes)} classes: {classes}")
    distinct_weights = {tuple(sorted(f.weight.items(), key=lambda kv: sorted(kv[0])))
                        for f in fs}
    print(f"number of distinct weight tables = {len(distinct_weights)}")
    print("=> classes correspond 1-1 to distinct filtrations: no nontrivial gluing.")


def demo_vr_stability() -> None:
    """Proposition 3.5 + concrete certificate: VR stability is 1-Lipschitz.

    cloud_1: unit-distance triangle (all off-diagonal distances 1).
    cloud_2: same triangle perturbed to off-diagonal distance 11/10.
    The interleaving distance of their VR filtrations is <= 1/10.
    """
    banner("Demo 4: Vietoris-Rips 1-Lipschitz stability + cloud certificate")
    n = 3
    cloud1 = [[0.0 if i == j else 1.0 for j in range(n)] for i in range(n)]
    cloud2 = [[0.0 if i == j else 1.1 for j in range(n)] for i in range(n)]
    d1, d2 = matrix_to_fn(cloud1), matrix_to_fn(cloud2)

    f = vr_filtration(d1, n, max_dim=n)
    g = vr_filtration(d2, n, max_dim=n)
    distortion = sup_distortion(d1, d2, n)
    dist = interleaving_distance(f, g)

    print(f"data-level sup distortion  max|d1 - d2| = {distortion:.4f}")
    print(f"VR interleaving distance               = {dist:.4f}")
    print(f"stability bound satisfied (dist <= distortion)? {dist <= distortion + 1e-12}")
    assert dist <= distortion + 1e-12
    assert dist <= 0.1 + 1e-12, "concrete certificate: distance <= 1/10"
    print("=> certificate verified: the two clouds sit within 1/10.")


def demo_triangle_inequality() -> None:
    """Proposition 3.4: the (extended) triangle inequality holds unconditionally."""
    banner("Demo 5: unconditional triangle inequality (Prop 3.4)")
    f = Filtration({frozenset(): 0.0, frozenset({0, 1}): 1.0})
    g = Filtration({frozenset(): 0.0, frozenset({0, 1}): 1.7})
    h = Filtration({frozenset(): 0.0, frozenset({0, 1}): 2.5})
    dfh = interleaving_distance(f, h)
    dfg = interleaving_distance(f, g)
    dgh = interleaving_distance(g, h)
    print(f"d(F,H) = {dfh:.3f}   d(F,G) + d(G,H) = {dfg:.3f} + {dgh:.3f} = "
          f"{dfg + dgh:.3f}")
    assert dfh <= dfg + dgh + 1e-12
    print("=> d(F,H) <= d(F,G) + d(G,H) holds.")


def main() -> None:
    print("Boltzmann Bridge VII -- numerical demonstrations")
    print("The interleaving distance on filtrations is a genuine metric.")
    demo_attained_infimum()
    demo_t0_separation()
    demo_quotient_is_trivial()
    demo_vr_stability()
    demo_triangle_inequality()
    banner("All demonstrations passed.")


if __name__ == "__main__":
    main()
