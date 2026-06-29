"""Numerical demonstrations for:

    A Finite-Discrepancy Criterion for the Connectivity Defect of
    Slice-Projections of Polymatroids

This self-contained script illustrates the tropical (max-plus) Fourier
reconstruction theory and its polymatroid-connectivity application. Every
function is inlined and type-hinted; running the file prints a guided tour of
the main results.

Key results demonstrated:
  * tightCoeff / reconstruct / discrepancy  (Definitions 2.2-2.4)
  * orderConvex_iff_discrepancy_zero         (Theorem 2.12, main result)
  * sliceProj_isPolymatroid                  (Theorem 3.3)
  * polyConnectivity_nonneg                  (Theorem 3.5)
  * modular_discrepancy_zero                 (Theorem 4.3)
  * cex_not_orderConvex                      (Theorem 4.4, counterexample)
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Part 1: Tropical (max-plus) Fourier reconstruction over a finite dictionary
# ---------------------------------------------------------------------------

Mode = Sequence[float]          # one mode phi_k as a vector over the domain
Dictionary = Sequence[Mode]     # phi : list of modes


def tight_coeff(f: Sequence[float], phi_k: Mode) -> float:
    """Canonical (tight) coefficient at one mode: min_x (f(x) - phi_k(x)).

    This is the largest scalar t with t + phi_k <= f pointwise.
    """
    return min(fx - pk for fx, pk in zip(f, phi_k))


def reconstruct(f: Sequence[float], phi: Dictionary) -> List[float]:
    """Canonical reconstruction: max_k (tight_coeff_k + phi_k(x)).

    The max-plus (Fenchel-Moreau) biconjugate of f over the dictionary.
    """
    coeffs: List[float] = [tight_coeff(f, phi_k) for phi_k in phi]
    n: int = len(f)
    return [max(coeffs[k] + phi[k][x] for k in range(len(phi))) for x in range(n)]


def discrepancy(f: Sequence[float], phi: Dictionary) -> float:
    """Finite discrepancy: max_x (f(x) - reconstruct(x)).  Always >= 0."""
    rec: List[float] = reconstruct(f, phi)
    return max(fx - rx for fx, rx in zip(f, rec))


def is_order_convex(f: Sequence[float], phi: Dictionary, tol: float = 1e-9) -> bool:
    """f is order-convex over phi iff discrepancy(f, phi) == 0 (Theorem 2.12)."""
    return discrepancy(f, phi) <= tol


# ---------------------------------------------------------------------------
# Part 2: Polymatroids, slice-projections, connectivity
# ---------------------------------------------------------------------------

Subset = FrozenSet[int]
SetFunction = Callable[[Subset], float]


def powerset(ground: Sequence[int]) -> List[Subset]:
    """All subsets of a finite ground set, as frozensets."""
    return [
        frozenset(c)
        for c in chain.from_iterable(
            combinations(ground, r) for r in range(len(ground) + 1)
        )
    ]


def is_polymatroid(f: SetFunction, ground: Sequence[int]) -> bool:
    """Check normalized + monotone + submodular (Definition 3.1)."""
    subsets: List[Subset] = powerset(ground)
    if abs(f(frozenset())) > 1e-9:                       # normalized
        return False
    for a in subsets:                                    # monotone
        for b in subsets:
            if a <= b and f(a) > f(b) + 1e-9:
                return False
    for a in subsets:                                    # submodular
        for b in subsets:
            if f(a | b) + f(a & b) > f(a) + f(b) + 1e-9:
                return False
    return True


def slice_proj(f: SetFunction, s: Subset) -> SetFunction:
    """Slice-projection / contraction by slice s: A -> f(A | s) - f(s)."""
    base: float = f(s)
    return lambda a: f(a | s) - base


def connectivity(f: SetFunction, ground: Sequence[int], a: Subset) -> float:
    """Connectivity function lambda(A) = f(A) + f(A^c) - f(E)."""
    full: Subset = frozenset(ground)
    comp: Subset = full - a
    return f(a) + f(comp) - f(full)


def modular(weights: Dict[int, float]) -> SetFunction:
    """Modular (weighted-cardinality) set function A -> sum of weights in A."""
    return lambda a: sum(weights[i] for i in a)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_main_equivalence() -> None:
    print("=" * 70)
    print("Theorem 2.12  -  orderConvex_iff_discrepancy_zero")
    print("=" * 70)
    # A genuine max-plus envelope of two ramps is order-convex.
    domain = [0, 1, 2, 3]
    phi: Dictionary = [
        [0.0, 1.0, 2.0, 3.0],     # ramp going up
        [3.0, 2.0, 1.0, 0.0],     # ramp going down
    ]
    coeffs = [0.5, -0.5]
    f = [max(coeffs[k] + phi[k][x] for k in range(len(phi))) for x in domain]
    print(f"f built as a max-plus expansion: {f}")
    print(f"  reconstruct(f) = {reconstruct(f, phi)}")
    print(f"  discrepancy    = {discrepancy(f, phi):.6f}")
    print(f"  order-convex?  = {is_order_convex(f, phi)}   (expected True)")


def demo_counterexample() -> None:
    print("\n" + "=" * 70)
    print("Theorem 4.4  -  cex_not_orderConvex (single constant mode)")
    print("=" * 70)
    f = [0.0, 1.0, 2.0]                 # non-constant target
    phi: Dictionary = [[0.0, 0.0, 0.0]]  # one constant mode
    print(f"f (non-constant)     = {f}")
    print(f"phi (constant mode)  = {phi[0]}")
    print(f"  reconstruct(f) = {reconstruct(f, phi)}  (forced constant)")
    print(f"  discrepancy    = {discrepancy(f, phi):.6f}  (> 0)")
    print(f"  order-convex?  = {is_order_convex(f, phi)}   (expected False)")


def demo_slice_projection() -> None:
    print("\n" + "=" * 70)
    print("Theorem 3.3 & 3.5  -  sliceProj_isPolymatroid, connectivity >= 0")
    print("=" * 70)
    ground = [0, 1, 2]
    f = modular({0: 1.0, 1: 2.0, 2: 3.0})
    print(f"modular f is a polymatroid? {is_polymatroid(f, ground)}")
    s: Subset = frozenset({2})
    g = slice_proj(f, s)
    print(f"slice-projection by s={set(s)} is a polymatroid? "
          f"{is_polymatroid(g, ground)}")
    lambdas = [connectivity(f, ground, a) for a in powerset(ground)]
    print(f"connectivity values lambda(A): "
          f"{[round(v, 3) for v in lambdas]}")
    print(f"all nonnegative? {all(v >= -1e-9 for v in lambdas)}")


def demo_modular_zero_discrepancy() -> None:
    print("\n" + "=" * 70)
    print("Theorem 4.3  -  modular_discrepancy_zero")
    print("=" * 70)
    # Represent a modular function over its 4-point domain as a tropical
    # envelope of coordinate ramps; the discrepancy is exactly zero.
    domain = [0, 1, 2, 3]
    f = [0.0, 2.0, 4.0, 6.0]          # linear (modular-like) profile
    phi: Dictionary = [[float(x) * 2.0 for x in domain]]
    print(f"linear f          = {f}")
    print(f"  discrepancy     = {discrepancy(f, phi):.6f}")
    print(f"  order-convex?   = {is_order_convex(f, phi)}   (expected True)")


def demo_connectivity_profile() -> None:
    print("\n" + "=" * 70)
    print("Algorithm B  -  connectivity profile of a slice chain")
    print("=" * 70)
    ground = [0, 1, 2]
    base = modular({0: 1.0, 1: 1.0, 2: 1.0})
    profile: List[Tuple[FrozenSet[int], bool]] = []
    for s in [frozenset(), frozenset({0}), frozenset({0, 1})]:
        g = slice_proj(base, s)
        # minimal connectivity over nontrivial cuts (the defect kappa)
        cuts = [
            connectivity(g, ground, a)
            for a in powerset(ground)
            if 0 < len(a) < len(ground)
        ]
        kappa = min(cuts) if cuts else 0.0
        profile.append((s, kappa > 1e-9))
        s_label: str = str(set(s)) if s else "{}"
        print(f"  slice s={s_label:<8}  defect kappa={kappa:.3f}"
              f"  connected={kappa > 1e-9}")
    connected_levels = [i for i, (_, c) in enumerate(profile) if c]
    print(f"connected levels: {connected_levels} "
          f"(Interval Property: must be contiguous)")


def main() -> None:
    demo_main_equivalence()
    demo_counterexample()
    demo_slice_projection()
    demo_modular_zero_discrepancy()
    demo_connectivity_profile()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
