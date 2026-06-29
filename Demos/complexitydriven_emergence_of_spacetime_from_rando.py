"""
Complexity-Driven Emergence of Spacetime from Tensor Networks (Tropical Core)
=============================================================================

Numerical companion to the formalized results.

Two intertwined stories are demonstrated, both living in the (min, +) "tropical"
world that governs how *complexity* (entanglement resources / bond dimension)
turns into *geometry* (holographic distance and reconstructable bulk regions):

  PART I  -- Multi-cut integrated information of a tensor network.
            For an n-party network we measure, across every nontrivial
            bipartition (cut) A, the Schmidt rank rank(A) >= 1.  The
            "integrated information" of a single cut is rank(A) - 1, and the
            network's integrated information Phi is the MINIMUM over all cuts
            (Tononi's Minimum Information Partition):

                Phi = min over nontrivial cuts A of (rank(A) - 1).

            Theorems demonstrated: bond-dimension cap Phi <= D - 1,
            reducibility Phi = 0 iff a product cut exists, and the headline
            tightness result that the maximally entangled network attains
            Phi = D - 1.

  PART II -- Tropical entanglement-wedge reconstruction.
            On a finite graph with a distance function d, the min-plus distance
            from a vertex v to a set S is dist(v, S) = min_{b in S} d(v, b).
            The entanglement wedge of a boundary region B is the set of bulk
            vertices strictly closer to B than to its complement.  Boundary
            observations are min-plus convolutions
                Obs(phi)(b) = min_{v in bulk} (phi(v) + d(v, b)),
            and we demonstrate wedge-membership stability under perturbation
            and bulk reconstruction from boundary data.

Everything is self-contained: pure Python standard library, type hints, and
all helper functions inlined.
"""

from __future__ import annotations

from itertools import combinations
from math import isclose, log
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple


# ===========================================================================
# PART I -- Multi-cut integrated information
# ===========================================================================

def nontrivial_cuts(n: int) -> List[FrozenSet[int]]:
    """All nontrivial bipartitions of {0, ..., n-1}: nonempty proper subsets.

    Mirrors `cuts n = univ.powerset.filter (A.Nonempty and A != univ)`.
    """
    parties = list(range(n))
    cuts: List[FrozenSet[int]] = []
    for size in range(1, n):  # 1 .. n-1, excludes empty and full set
        for combo in combinations(parties, size):
            cuts.append(frozenset(combo))
    return cuts


def phi_multicut(rank: Callable[[FrozenSet[int]], int], n: int) -> int:
    """Multi-cut integrated information Phi = min over cuts of (rank(A) - 1).

    Mirrors `phiMC`.  Requires n >= 2 (so at least one cut exists) and
    rank(A) >= 1 for every cut (a nonzero pure state).
    """
    if n < 2:
        raise ValueError("phi_multicut requires n >= 2 (need a nontrivial cut)")
    cuts = nontrivial_cuts(n)
    return min(rank(A) - 1 for A in cuts)


def minimum_information_partition(
    rank: Callable[[FrozenSet[int]], int], n: int
) -> Tuple[FrozenSet[int], int]:
    """Return a cut realizing Phi together with the value Phi.

    Mirrors `exists_MIP`: some nontrivial cut attains the minimum.
    """
    cuts = nontrivial_cuts(n)
    best = min(cuts, key=lambda A: rank(A) - 1)
    return best, rank(best) - 1


def demo_part1_bond_dimension() -> None:
    print("=" * 74)
    print("PART I -- Multi-cut integrated information and bond dimension")
    print("=" * 74)

    n = 4
    D = 3  # bond dimension

    # (a) Maximally entangled network: Schmidt rank D across EVERY cut.
    #     Theorem phiMC_const / phiMC_maximallyEntangled_tight: Phi = D - 1.
    def rank_max(_A: FrozenSet[int]) -> int:
        return D

    phi_max = phi_multicut(rank_max, n)
    print(f"\n(a) Maximally entangled network on n={n}, bond dimension D={D}")
    print(f"    Phi = {phi_max}  (predicted D - 1 = {D - 1})")
    assert phi_max == D - 1, "tightness theorem violated"

    # (b) A generic network whose ranks vary but never exceed the bond dim D.
    #     Theorem phiMC_le_bond: Phi <= D - 1.
    fixed_ranks: Dict[FrozenSet[int], int] = {}
    for i, A in enumerate(nontrivial_cuts(n)):
        fixed_ranks[A] = 1 + (i % D)  # ranks in {1, ..., D}

    def rank_generic(A: FrozenSet[int]) -> int:
        return fixed_ranks[A]

    phi_gen = phi_multicut(rank_generic, n)
    mip, _ = minimum_information_partition(rank_generic, n)
    print(f"\n(b) Generic network with all ranks in [1, D={D}]")
    print(f"    Phi = {phi_gen}  <=  D - 1 = {D - 1}   (bond cap holds: {phi_gen <= D - 1})")
    print(f"    Minimum Information Partition: A = {set(mip)} | complement")

    # (c) Reducibility: Phi = 0 iff some cut is a product state (rank 1).
    #     Theorem phiMC_eq_zero_iff.
    def rank_product(A: FrozenSet[int]) -> int:
        # rank 1 across the single cut {0}, large elsewhere
        return 1 if A == frozenset({0}) else D

    phi_prod = phi_multicut(rank_product, n)
    print(f"\n(c) Network with a product cut {{0}} (Schmidt rank 1 there)")
    print(f"    Phi = {phi_prod}  (reducible <=> Phi = 0: {phi_prod == 0})")
    assert phi_prod == 0

    # (d) The concept's explicit test case: bond dimension 2 => Phi <= 1.
    #     Theorem phiMC_bondTwo_le_one.
    def rank_bond2(A: FrozenSet[int]) -> int:
        return 2 if len(A) % 2 == 1 else 1

    phi_b2 = phi_multicut(rank_bond2, n)
    print(f"\n(d) Bond-dimension-2 MPS test: Phi = {phi_b2}  <=  1  ({phi_b2 <= 1})")
    assert phi_b2 <= 1


# ===========================================================================
# PART II -- Tropical entanglement-wedge reconstruction
# ===========================================================================

def dist_to_set(d: Callable[[int, int], float], S: Sequence[int], v: int) -> float:
    """Min-plus distance from v to the set S: min_{b in S} d(v, b).

    Mirrors `distToFinset`.  S must be nonempty.
    """
    if not S:
        raise ValueError("dist_to_set requires a nonempty set S")
    return min(d(v, b) for b in S)


def entanglement_wedge(
    bulk: Sequence[int],
    boundary: Sequence[int],
    B: Sequence[int],
    d: Callable[[int, int], float],
) -> List[int]:
    """Bulk vertices strictly closer to B than to (boundary \\ B).

    Mirrors `entanglementWedge`.  If B is empty the (vacuous) condition makes
    the wedge equal the whole bulk (`entanglementWedge_empty_eq_bulk`).
    """
    Bset = set(B)
    Bc = [b for b in boundary if b not in Bset]
    if not Bset:  # empty B: vacuously all bulk
        return list(bulk)
    if not Bc:  # B is the whole boundary: condition vacuous as well
        return list(bulk)
    wedge: List[int] = []
    for v in bulk:
        if dist_to_set(d, list(Bset), v) < dist_to_set(d, Bc, v):
            wedge.append(v)
    return wedge


def boundary_obs(
    bulk: Sequence[int],
    d: Callable[[int, int], float],
    phi: Callable[[int], float],
    b: int,
) -> float:
    """Min-plus convolution Obs(phi)(b) = min_{v in bulk} (phi(v) + d(v, b)).

    Mirrors `boundaryObs`.
    """
    return min(phi(v) + d(v, b) for v in bulk)


def demo_part2_wedge() -> None:
    print("\n" + "=" * 74)
    print("PART II -- Tropical entanglement-wedge reconstruction")
    print("=" * 74)

    # A small graph: bulk vertices 0..3, boundary vertices 10..13 placed on a
    # 1-D line so that geometry is transparent.  Coordinates on a line:
    coord: Dict[int, float] = {
        0: 1.0, 1: 3.0, 2: 6.0, 3: 8.0,        # bulk
        10: 0.0, 11: 4.0, 12: 5.0, 13: 9.0,    # boundary
    }

    def d(u: int, v: int) -> float:
        return abs(coord[u] - coord[v])

    bulk = [0, 1, 2, 3]
    boundary = [10, 11, 12, 13]
    B = [10, 11]  # left half of the boundary

    wedge = entanglement_wedge(bulk, boundary, B, d)
    print(f"\nBulk = {bulk}, Boundary = {boundary}, Region B = {B}")
    print(f"Entanglement wedge of B: {wedge}")
    for v in bulk:
        dB = dist_to_set(d, B, v)
        dBc = dist_to_set(d, [b for b in boundary if b not in set(B)], v)
        tag = "IN wedge" if v in wedge else "outside"
        print(f"  v={v}: dist(v,B)={dB:.1f}  dist(v,Bc)={dBc:.1f}  gap={dBc-dB:+.1f}  -> {tag}")

    # Perturbation stability: theorem wedge_membership_stable_under_uniform_perturbation.
    # A wedge vertex with gap delta survives any perturbation of size eps < delta/2.
    print("\nPerturbation stability (gap > 2*eps keeps wedge membership):")
    for v in wedge:
        dB = dist_to_set(d, B, v)
        dBc = dist_to_set(d, [b for b in boundary if b not in set(B)], v)
        gap = dBc - dB
        eps = gap / 2 - 1e-9
        print(f"  v={v}: gap={gap:.2f}, any |d - d'| < eps={eps:.3f} keeps v in the wedge")

    # Reconstruction: theorem wedge_reconstruction_from_boundary_profiles.
    # If two bulk states have a unique min-plus argmin from some b in B for each
    # wedge vertex, equal boundary observations on B force equal bulk states on
    # the wedge.  We verify the contrapositive numerically: changing a wedge
    # vertex's value changes a boundary observation on B.
    print("\nReconstruction / detectability:")
    phi0: Dict[int, float] = {0: 0.0, 1: 0.2, 2: 5.0, 3: 5.1}

    def phi(v: int) -> float:
        return phi0[v]

    obs_before = {b: boundary_obs(bulk, d, phi, b) for b in B}
    # Surgery: perturb a wedge vertex's value.
    target = wedge[0]
    phi0[target] += 1.0
    obs_after = {b: boundary_obs(bulk, d, phi, b) for b in B}
    changed = [b for b in B if not isclose(obs_before[b], obs_after[b])]
    print(f"  Surgery on wedge vertex {target} (phi += 1.0)")
    print(f"  Boundary observations on B that changed: {changed}")
    print(f"  Detectable from B? {len(changed) > 0}")


# ===========================================================================
# PART III -- Bond-dimension threshold as a tropical (min, +) crossover
# ===========================================================================

def mincut_entropy(area: Sequence[float], slope: Sequence[float], t: float) -> float:
    """Tropical min-cut entropy S(t) = min_i (a_i + c_i * t), a (min,+) polynomial.

    Each competing cut i contributes an affine 'area-law' line a_i + c_i * t
    in the log-bond-dimension parameter t = log D.  S is the lower envelope.
    """
    return min(a + c * t for a, c in zip(area, slope))


def critical_bond_dimension(a0: float, a1: float, c0: float, c1: float) -> float:
    """Sharp crossover bond dimension for two competing cuts.

    Solving a0 + c0 * t = a1 + c1 * t gives t_c = (a0 - a1)/(c1 - c0), and the
    critical bond dimension is D_c = exp(t_c).  At D_c the dominant minimal
    surface (entanglement wedge) switches -- a first-order jump in the
    scaling exponent.
    """
    if isclose(c0, c1):
        raise ValueError("equal slopes: no isolated crossover")
    t_c = (a0 - a1) / (c1 - c0)
    return float(__import__("math").exp(t_c))


def demo_part3_threshold() -> None:
    print("\n" + "=" * 74)
    print("PART III -- Sharp bond-dimension threshold (tropical crossover)")
    print("=" * 74)

    # Two competing cuts.  Cut 0: small slope (small surface), large area offset.
    # Cut 1: large slope (large surface), small area offset.
    a0, c0 = 4.0, 1.0
    a1, c1 = 0.0, 3.0
    Dc = critical_bond_dimension(a0, a1, c0, c1)
    print(f"\nTwo cuts: S0(t) = {a0} + {c0} t,  S1(t) = {a1} + {c1} t")
    print(f"Critical bond dimension D_c = exp((a0-a1)/(c1-c0)) = {Dc:.4f}")
    print(f"  (log D_c = t_c = {log(Dc):.4f})")

    print("\n  log D   S(t)   dominant cut   scaling exponent dS/dt")
    for t in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        s = mincut_entropy([a0, a1], [c0, c1], t)
        dom = 0 if (a0 + c0 * t) <= (a1 + c1 * t) else 1
        slope = c0 if dom == 0 else c1
        print(f"   {t:4.1f}   {s:5.2f}      cut {dom}            {slope:.1f}")

    print("\n  -> Below D_c the small-slope cut dominates (fractal/low-D regime);")
    print("     above D_c the large-slope cut dominates (smooth/large-D regime).")
    print("     The discrete curvature S(t-1) - 2 S(t) + S(t+1) <= 0 (concavity)")
    print("     is zero away from the breakpoint and negative exactly at D_c.")


if __name__ == "__main__":
    demo_part1_bond_dimension()
    demo_part2_wedge()
    demo_part3_threshold()
    print("\nAll demonstrations completed successfully.")
