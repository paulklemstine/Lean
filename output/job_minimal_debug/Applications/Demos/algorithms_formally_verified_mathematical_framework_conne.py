#!/usr/bin/env python3
"""
Algorithms for Neural Decision Surface Topology

Type-hinted implementations of the core algorithms for computing
hyperplane arrangement statistics, network region bounds, and
tropical polynomial degrees.
"""

from math import comb, prod
from typing import List, Tuple, Optional
from dataclasses import dataclass


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class ReLUArchitecture:
    """A ReLU neural network architecture."""
    input_dim: int
    layer_widths: List[int]

    @property
    def total_neurons(self) -> int:
        return sum(self.layer_widths)

    @property
    def depth(self) -> int:
        return len(self.layer_widths)

    def __repr__(self) -> str:
        dims = [self.input_dim] + self.layer_widths + [1]
        return "→".join(str(d) for d in dims)


@dataclass
class ArrangementStats:
    """Statistics of a hyperplane arrangement."""
    num_hyperplanes: int
    ambient_dim: int
    num_regions: int
    euler_characteristic: int
    efficiency: float  # fraction of 2^m that is realized


@dataclass
class NetworkBounds:
    """Expressivity bounds for a neural network."""
    architecture: ReLUArchitecture
    per_layer_regions: List[int]
    total_regions_upper: int
    tropical_monomials: int
    shallow_equivalent_bound: int
    depth_advantage_ratio: float


# =============================================================================
# Algorithm 1: Zaslavsky Function
# =============================================================================

def zaslavsky(m: int, n: int) -> int:
    """
    Compute the Zaslavsky function Z(m, n).

    Z(m, n) = Σ_{k=0}^{n} C(m, k)

    This gives the maximum number of regions formed by m hyperplanes
    in general position in R^n.

    Time complexity: O(min(m, n))
    Space complexity: O(1)

    Args:
        m: Number of hyperplanes (non-negative)
        n: Ambient dimension (non-negative)

    Returns:
        Maximum number of regions
    """
    return sum(comb(m, k) for k in range(min(m, n) + 1))


# =============================================================================
# Algorithm 2: Deep Network Region Bound
# =============================================================================

def deep_network_bound(arch: ReLUArchitecture) -> NetworkBounds:
    """
    Compute expressivity bounds for a deep ReLU network.

    For each layer i with width w_i, the per-layer bound is Z(w_i, n).
    The total bound is the product: Π Z(w_i, n).

    The tropical monomial count is 2^N where N = Σ w_i.

    Args:
        arch: The network architecture

    Returns:
        NetworkBounds with all computed bounds
    """
    n = arch.input_dim
    per_layer = [zaslavsky(w, n) for w in arch.layer_widths]
    total = prod(per_layer)
    N = arch.total_neurons
    tropical = 2 ** N
    shallow = zaslavsky(N, n)
    ratio = total / shallow if shallow > 0 else float('inf')

    return NetworkBounds(
        architecture=arch,
        per_layer_regions=per_layer,
        total_regions_upper=total,
        tropical_monomials=tropical,
        shallow_equivalent_bound=shallow,
        depth_advantage_ratio=ratio,
    )


# =============================================================================
# Algorithm 3: Arrangement Statistics
# =============================================================================

def arrangement_stats(m: int, n: int) -> ArrangementStats:
    """
    Compute statistics of a hyperplane arrangement.

    Args:
        m: Number of hyperplanes
        n: Ambient dimension

    Returns:
        ArrangementStats with regions, Euler char, efficiency
    """
    regions = zaslavsky(m, n)
    euler = sum((-1)**k * comb(m, k) for k in range(n + 1))
    efficiency = regions / (2**m) if m > 0 else 1.0

    return ArrangementStats(
        num_hyperplanes=m,
        ambient_dim=n,
        num_regions=regions,
        euler_characteristic=euler,
        efficiency=efficiency,
    )


# =============================================================================
# Algorithm 4: Zaslavsky Recurrence (Dynamic Programming)
# =============================================================================

def zaslavsky_table(max_m: int, max_n: int) -> List[List[int]]:
    """
    Build the Zaslavsky table using the recurrence relation.

    Z(0, n) = 1 for all n
    Z(m, 0) = 1 for all m
    Z(m+1, n+1) = Z(m, n+1) + Z(m, n)

    Time complexity: O(max_m * max_n)
    Space complexity: O(max_m * max_n)

    Args:
        max_m: Maximum number of hyperplanes
        max_n: Maximum dimension

    Returns:
        2D table where table[m][n] = Z(m, n)
    """
    table = [[0] * (max_n + 1) for _ in range(max_m + 1)]

    # Base cases
    for n in range(max_n + 1):
        table[0][n] = 1
    for m in range(max_m + 1):
        table[m][0] = 1

    # Fill using recurrence
    for m in range(max_m):
        for n in range(max_n):
            table[m + 1][n + 1] = table[m][n + 1] + table[m][n]

    return table


# =============================================================================
# Algorithm 5: Optimal Architecture Search
# =============================================================================

def optimal_architecture(
    total_neurons: int,
    input_dim: int,
    max_depth: Optional[int] = None,
) -> Tuple[ReLUArchitecture, int]:
    """
    Find the architecture that maximizes the region count upper bound
    for a given total neuron budget.

    Searches over all ways to partition total_neurons into layers,
    with each layer having at least 1 neuron.

    Args:
        total_neurons: Total neuron budget N
        input_dim: Input dimension n
        max_depth: Maximum number of layers (default: N)

    Returns:
        Tuple of (best architecture, best region count)
    """
    if max_depth is None:
        max_depth = total_neurons

    best_arch = ReLUArchitecture(input_dim, [total_neurons])
    best_count = zaslavsky(total_neurons, input_dim)

    def search(remaining: int, depth: int, widths: List[int]) -> None:
        nonlocal best_arch, best_count

        if depth == 0 or remaining == 0:
            if remaining == 0 and widths:
                count = prod(zaslavsky(w, input_dim) for w in widths)
                if count > best_count:
                    best_count = count
                    best_arch = ReLUArchitecture(input_dim, list(widths))
            return

        min_width = max(1, input_dim)  # At least input_dim for full expressivity
        for w in range(min(remaining, remaining), min_width - 1, -1):
            widths.append(w)
            search(remaining - w, depth - 1, widths)
            widths.pop()

    search(total_neurons, min(max_depth, total_neurons), [])
    return best_arch, best_count


# =============================================================================
# Algorithm 6: Hamming Distance on Activation Patterns
# =============================================================================

def hamming_distance(p: Tuple[bool, ...], q: Tuple[bool, ...]) -> int:
    """
    Compute the Hamming distance between two activation patterns.

    Args:
        p, q: Activation patterns (tuples of bools of equal length)

    Returns:
        Number of positions where p and q differ
    """
    assert len(p) == len(q), "Patterns must have equal length"
    return sum(a != b for a, b in zip(p, q))


# =============================================================================
# Main: demonstrate algorithms
# =============================================================================

if __name__ == "__main__":
    # Demo: architecture analysis
    archs = [
        ReLUArchitecture(2, [3, 3]),
        ReLUArchitecture(3, [4, 4, 4]),
        ReLUArchitecture(5, [10, 10]),
        ReLUArchitecture(2, [5, 5, 5]),
    ]

    for arch in archs:
        bounds = deep_network_bound(arch)
        print(f"\nArchitecture: {arch}")
        print(f"  Per-layer regions: {bounds.per_layer_regions}")
        print(f"  Total region bound: {bounds.total_regions_upper}")
        print(f"  Tropical monomials: {bounds.tropical_monomials}")
        print(f"  Shallow equivalent: {bounds.shallow_equivalent_bound}")
        print(f"  Depth advantage: {bounds.depth_advantage_ratio:.1f}x")

    # Demo: optimal architecture search
    print("\n\nOptimal architectures (input_dim=3):")
    for N in [6, 9, 12, 15]:
        arch, count = optimal_architecture(N, 3, max_depth=5)
        print(f"  N={N}: {arch} → {count} regions")

    # Demo: Zaslavsky table
    print("\nZaslavsky table (DP construction):")
    table = zaslavsky_table(6, 6)
    print(f"{'m\\n':>4}", end="")
    for n in range(7):
        print(f"{n:>6}", end="")
    print()
    for m in range(7):
        print(f"{m:>4}", end="")
        for n in range(7):
            print(f"{table[m][n]:>6}", end="")
        print()
