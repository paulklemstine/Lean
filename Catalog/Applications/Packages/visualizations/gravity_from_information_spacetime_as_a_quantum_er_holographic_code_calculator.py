#!/usr/bin/env python3
"""
Algorithms for holographic quantum error-correcting codes.
Type-hinted implementations of the code-geometry correspondence.
"""

from dataclasses import dataclass
from typing import Optional, Tuple, List, Set, FrozenSet
import math


@dataclass(frozen=True)
class StabilizerCodeParams:
    """Parameters [[n, k, d]] of a quantum stabilizer code."""
    n: int  # physical qubits
    k: int  # logical qubits
    d: int  # code distance

    def __post_init__(self):
        assert self.k <= self.n, f"k={self.k} > n={self.n}"
        assert self.d >= 1, f"d={self.d} < 1"
        assert self.d <= self.n, f"d={self.d} > n={self.n}"

    def satisfies_singleton_bound(self) -> bool:
        """Check k + 2d <= n + 2."""
        return self.k + 2 * self.d <= self.n + 2

    def saturates_singleton_bound(self) -> bool:
        """Check k + 2d = n + 2 (quantum MDS)."""
        return self.k + 2 * self.d == self.n + 2

    def erasure_correction_capacity(self) -> int:
        """Maximum number of correctable erasures: floor((d-1)/2)."""
        return (self.d - 1) // 2

    def redundancy(self) -> int:
        """Number of parity check qubits: n - k."""
        return self.n - self.k

    def redundancy_ratio(self) -> float:
        """Fraction of physical qubits used for error protection."""
        return self.redundancy() / self.n if self.n > 0 else 0.0


@dataclass(frozen=True)
class HolographicCode:
    """A stabilizer code with holographic (RT) constraint 4k = n."""
    params: StabilizerCodeParams
    boundary_area: int   # in Planck units (= n)
    bulk_geodesic_length: int  # in Planck units (= 2d)

    def __post_init__(self):
        assert self.boundary_area == self.params.n
        assert self.bulk_geodesic_length == 2 * self.params.d
        assert 4 * self.params.k == self.params.n, \
            f"RT formula violated: 4*{self.params.k} != {self.params.n}"

    @staticmethod
    def from_boundary_area(area: int, saturated: bool = True) -> 'HolographicCode':
        """Construct a holographic code from boundary area.
        If saturated=True, uses the saturated Singleton bound."""
        assert area % 4 == 0, f"Area {area} must be divisible by 4"
        k = area // 4
        if saturated:
            # k + 2d = n + 2 => d = (n - k + 2) / 2 = (3n/4 + 2) / 2
            d_twice = 3 * k + 2
            assert d_twice % 2 == 0, "Need even 3k+2 for integer d"
            d = d_twice // 2
        else:
            d = 1  # minimal distance
        params = StabilizerCodeParams(n=area, k=k, d=d)
        return HolographicCode(
            params=params,
            boundary_area=area,
            bulk_geodesic_length=2 * d,
        )


def compute_holographic_entropy(
    boundary_size: int,
    region_size: int,
    total_sites: int,
) -> float:
    """Compute holographic entropy for a boundary region.
    Uses the discrete RT formula: S(m) ∝ log(sin(πm/n)).
    
    Args:
        boundary_size: not used (for compatibility)
        region_size: number of sites in the region
        total_sites: total number of boundary sites
    
    Returns:
        Entropy value (proportional to RT surface area)
    """
    if region_size == 0 or region_size == total_sites:
        return 0.0
    # Continuous RT formula for CFT₂: S = (c/3) * log(sin(πm/n))
    # We use c = 1 for simplicity
    theta = math.pi * region_size / total_sites
    return (1.0 / 3.0) * math.log(total_sites * math.sin(theta) / math.pi)


def verify_strong_subadditivity(
    entropy_fn,
    total_sites: int,
    a_size: int,
    b_size: int,
    c_size: int,
) -> Tuple[bool, float]:
    """Verify SSA: S(ABC) + S(B) <= S(AB) + S(BC).
    
    Returns (satisfied, deficit) where deficit = RHS - LHS.
    """
    assert a_size + b_size + c_size <= total_sites
    s_abc = entropy_fn(0, a_size + b_size + c_size, total_sites)
    s_b = entropy_fn(0, b_size, total_sites)
    s_ab = entropy_fn(0, a_size + b_size, total_sites)
    s_bc = entropy_fn(0, b_size + c_size, total_sites)
    lhs = s_abc + s_b
    rhs = s_ab + s_bc
    return (lhs <= rhs + 1e-10, rhs - lhs)


def verify_monogamy(
    entropy_fn,
    total_sites: int,
    a_size: int,
    b_size: int,
    c_size: int,
) -> Tuple[bool, float]:
    """Verify monogamy: I(A:C) = S(A) + S(C) - S(AC) <= 2*S(A).
    
    Returns (satisfied, bound_minus_mi).
    """
    assert a_size + b_size + c_size == total_sites
    s_a = entropy_fn(0, a_size, total_sites)
    s_c = entropy_fn(0, c_size, total_sites)
    s_ac = entropy_fn(0, a_size + c_size, total_sites)
    mi = s_a + s_c - s_ac
    bound = 2 * s_a
    return (mi <= bound + 1e-10, bound - mi)


class EntanglementWedge:
    """Entanglement wedge assignment for a discrete holographic code.
    
    Models the bulk as a set of points, with each boundary region
    mapped to a subset of bulk points.
    """
    
    def __init__(self, n_boundary: int, n_bulk: int):
        self.n_boundary = n_boundary
        self.n_bulk = n_bulk
        # Simple model: boundary site i controls bulk points in its "causal wedge"
        self._wedge_cache: dict = {}
    
    def wedge(self, region: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the entanglement wedge of a boundary region.
        
        Simple model: bulk point j is in wedge(A) if |A| > n/2,
        or if j is "closest" to some site in A.
        """
        key = region
        if key in self._wedge_cache:
            return self._wedge_cache[key]
        
        if len(region) == 0:
            result = frozenset()
        elif len(region) == self.n_boundary:
            result = frozenset(range(self.n_bulk))
        elif len(region) >= self.n_boundary // 2 + 1:
            # Majority region gets all bulk points
            result = frozenset(range(self.n_bulk))
        else:
            # Assign bulk points proportionally
            ratio = len(region) / self.n_boundary
            n_bulk_pts = max(1, int(ratio * self.n_bulk))
            # Assign contiguous bulk points based on boundary position
            sorted_region = sorted(region)
            center = sum(sorted_region) / len(sorted_region)
            center_bulk = int(center * self.n_bulk / self.n_boundary)
            start = max(0, center_bulk - n_bulk_pts // 2)
            end = min(self.n_bulk, start + n_bulk_pts)
            result = frozenset(range(start, end))
        
        self._wedge_cache[key] = result
        return result
    
    def verify_nesting(self, A: FrozenSet[int], B: FrozenSet[int]) -> bool:
        """Check if A ⊆ B implies wedge(A) ⊆ wedge(B)."""
        if not A.issubset(B):
            return True  # vacuously true
        return self.wedge(A).issubset(self.wedge(B))
    
    def verify_complementarity(self, A: FrozenSet[int]) -> bool:
        """Check if wedge(A) ∪ wedge(Aᶜ) = bulk."""
        all_boundary = frozenset(range(self.n_boundary))
        complement = all_boundary - A
        union = self.wedge(A) | self.wedge(complement)
        return union == frozenset(range(self.n_bulk))


def singleton_geodesic_bound(boundary_area: int) -> int:
    """Compute the maximum bulk geodesic length allowed by the
    RT-strengthened Singleton bound: 4L ≤ 3A + 8."""
    return (3 * boundary_area + 8) // 4


def optimal_redundancy_allocation(
    total_qubits: int,
    target_distance: int,
) -> Optional[StabilizerCodeParams]:
    """Find optimal code parameters for given n and target d.
    
    Maximizes k subject to Singleton bound k + 2d ≤ n + 2.
    """
    k_max = total_qubits - 2 * target_distance + 2
    if k_max < 0:
        return None
    if target_distance > total_qubits:
        return None
    return StabilizerCodeParams(n=total_qubits, k=k_max, d=target_distance)


if __name__ == '__main__':
    # Quick test
    code = HolographicCode.from_boundary_area(32, saturated=True)
    print(f"Holographic code: [[{code.params.n}, {code.params.k}, {code.params.d}]]")
    print(f"  Singleton saturated: {code.params.saturates_singleton_bound()}")
    print(f"  Redundancy ratio: {code.params.redundancy_ratio():.2%}")
    print(f"  Erasure capacity: {code.params.erasure_correction_capacity()}")
    print(f"  Geodesic bound: L ≤ {singleton_geodesic_bound(32)}")
