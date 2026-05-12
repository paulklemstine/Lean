#!/usr/bin/env python3
"""
Closure Kramers-Wannier Duality: Core Algorithms

Implements the key algorithms from the research paper:
1. Tropical Legendre transform
2. Dual Legendre transform and bidual
3. Normalization and gauge operations
4. Certified Gibbs reconstruction
5. Gauge uniqueness verification

All algorithms operate on finite configuration spaces represented as
dictionaries mapping frozensets to integer energies.
"""

from typing import Dict, FrozenSet, List, Optional, Tuple
from dataclasses import dataclass


# Type aliases
Config = FrozenSet[int]
EnergyMap = Dict[Config, int]


@dataclass
class DualReconstruction:
    """Output of the certified reconstruction algorithm."""
    dual_weights: EnergyMap
    gauge_shift: int
    realized_boundary: EnergyMap
    normalized_boundary: EnergyMap

    def is_certified(self) -> bool:
        """Verify the certification condition: R(S) = w(S) + g for all S."""
        return all(
            self.realized_boundary[s] == self.dual_weights[s] + self.gauge_shift
            for s in self.realized_boundary
        )

    def is_coherent(self) -> bool:
        """Verify coherence: normalized = realized - realized(∅)."""
        r_empty = self.realized_boundary[frozenset()]
        return all(
            self.normalized_boundary[s] == self.realized_boundary[s] - r_empty
            for s in self.normalized_boundary
        )


@dataclass
class ClosureInteractionStructure:
    """A finite closure interaction structure."""
    elements: List[int]
    closure: callable  # Finset -> Finset
    generators: List[Config]
    energy: EnergyMap

    def all_configs(self) -> List[Config]:
        """Generate all configurations (subsets of elements)."""
        n = len(self.elements)
        configs = []
        for i in range(2**n):
            s = frozenset(self.elements[j] for j in range(n) if i & (1 << j))
            configs.append(s)
        return configs


def tropical_legendre(p: EnergyMap) -> EnergyMap:
    """
    Tropical Legendre transform: L(p)(T) = min_S p(S) - p(T).

    Since min_S p(S) is a constant, this equals m - p(T) where m = min p.

    Time complexity: O(|configs|)
    Space complexity: O(|configs|)

    Args:
        p: Primal partition section (config -> energy)

    Returns:
        Dual partition section L(p)
    """
    m = min(p.values())
    return {t: m - p[t] for t in p}


def dual_tropical_legendre(q: EnergyMap) -> EnergyMap:
    """
    Dual tropical Legendre: L*(q)(S) = min_T q(T) - q(S).

    Time complexity: O(|configs|)
    Space complexity: O(|configs|)

    Args:
        q: Dual partition section

    Returns:
        Primal partition section L*(q)
    """
    m = min(q.values())
    return {s: m - q[s] for s in q}


def tropical_bidual(p: EnergyMap) -> EnergyMap:
    """
    Tropical bidual: p** = L*(L(p)).

    By Theorem 3.3, p**(S) = p(S) - max_T p(T).

    Time complexity: O(|configs|)
    Space complexity: O(|configs|)

    Args:
        p: Primal partition section

    Returns:
        Bidual partition section p**
    """
    return dual_tropical_legendre(tropical_legendre(p))


def normalize(p: EnergyMap) -> EnergyMap:
    """
    Normalize a partition section: p_hat(S) = p(S) - p(∅).

    Time complexity: O(|configs|)

    Args:
        p: Partition section to normalize

    Returns:
        Normalized partition section with p_hat(∅) = 0
    """
    p_empty = p[frozenset()]
    return {s: p[s] - p_empty for s in p}


def gauge_equivalent(p: EnergyMap, q: EnergyMap) -> Tuple[bool, Optional[int]]:
    """
    Check if two partition sections are gauge-equivalent (differ by constant).

    Time complexity: O(|configs|)

    Args:
        p, q: Partition sections to compare

    Returns:
        (True, c) if p(S) = q(S) + c for all S, else (False, None)
    """
    configs = list(p.keys())
    if not configs:
        return True, 0
    c = p[configs[0]] - q[configs[0]]
    if all(p[s] - q[s] == c for s in configs):
        return True, c
    return False, None


def certified_reconstruction(B: EnergyMap) -> DualReconstruction:
    """
    Certified Gibbs reconstruction from boundary partition data.

    Given boundary functional B, reconstruct dual weights w, gauge shift g,
    realized boundary R, and normalized boundary R_hat such that:
    - R(S) = w(S) + g (certified)
    - R_hat(S) = B(S) - B(∅) (normalized)

    Time complexity: O(|configs|)

    Args:
        B: Boundary partition functional

    Returns:
        DualReconstruction with all fields populated
    """
    g = B[frozenset()]
    w = {s: B[s] - g for s in B}
    R = dict(B)
    R_hat = {s: B[s] - g for s in B}
    return DualReconstruction(
        dual_weights=w,
        gauge_shift=g,
        realized_boundary=R,
        normalized_boundary=R_hat,
    )


def gauge_unique_reconstruction(
    R1: DualReconstruction,
    R2: DualReconstruction
) -> Tuple[bool, Optional[int]]:
    """
    Check gauge uniqueness: do certified coherent reconstructions with
    the same normalized boundary differ by a constant in dual weights?

    Time complexity: O(|configs|)

    Args:
        R1, R2: Two dual reconstructions

    Returns:
        (True, c) if w1(S) = w2(S) + c for all S, else (False, None)
    """
    # Check both are certified and coherent
    if not R1.is_certified() or not R2.is_certified():
        return False, None
    if not R1.is_coherent() or not R2.is_coherent():
        return False, None

    # Check same normalized boundary
    if any(R1.normalized_boundary[s] != R2.normalized_boundary[s]
           for s in R1.normalized_boundary):
        return False, None

    return gauge_equivalent(R1.dual_weights, R2.dual_weights)


def ising_chain_energy(subset: Config, n: int, J: int = 1) -> int:
    """
    Compute Ising energy for a spin configuration on a chain of n sites.

    Args:
        subset: Set of sites with spin +1
        n: Number of sites
        J: Coupling constant

    Returns:
        Energy E = -J * sum_{i} sigma_i * sigma_{i+1}
    """
    energy = 0
    for i in range(n - 1):
        si = 1 if i in subset else -1
        sj = 1 if (i + 1) in subset else -1
        energy -= J * si * sj
    return energy


def identity_closure(s: Config) -> Config:
    """Identity closure operator: cl(S) = S."""
    return s


def make_ising_structure(n: int, J: int = 1) -> ClosureInteractionStructure:
    """
    Create a closure interaction structure for the n-site Ising chain.

    Args:
        n: Number of sites
        J: Coupling constant

    Returns:
        ClosureInteractionStructure
    """
    elements = list(range(n))
    generators = [frozenset({i, i+1}) for i in range(n-1)]
    configs = []
    for i in range(2**n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        configs.append(s)
    energy = {s: ising_chain_energy(s, n, J) for s in configs}
    return ClosureInteractionStructure(
        elements=elements,
        closure=identity_closure,
        generators=generators,
        energy=energy,
    )


if __name__ == "__main__":
    # Quick verification
    struct = make_ising_structure(3)
    configs = struct.all_configs()
    p = struct.energy

    print("Ising chain energies:")
    for s in configs:
        print(f"  {sorted(s)}: {p[s]}")

    lp = tropical_legendre(p)
    print("\nLegendre transform:")
    for s in configs:
        print(f"  {sorted(s)}: {lp[s]}")

    pp = tropical_bidual(p)
    is_ge, c = gauge_equivalent(pp, p)
    print(f"\nBidual gauge-equivalent to primal? {is_ge} (c={c})")

    p_norm = normalize(p)
    pp_norm = normalize(pp)
    print(f"Normalized bidual == normalized primal? "
          f"{all(p_norm[s] == pp_norm[s] for s in configs)}")
