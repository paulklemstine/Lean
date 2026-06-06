#!/usr/bin/env python3
"""
Neural Hodge Theory: Core Algorithms

Type-hinted implementations of the main combinatorial algorithms
for computing topological bounds on ReLU network decision surfaces.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class NetworkArchitecture:
    """Architecture of a feedforward ReLU network."""
    input_dim: int
    layer_widths: List[int]

    @property
    def depth(self) -> int:
        return len(self.layer_widths)

    @property
    def total_neurons(self) -> int:
        return sum(self.layer_widths)

    def __post_init__(self) -> None:
        assert self.input_dim > 0, "Input dimension must be positive"
        assert all(w > 0 for w in self.layer_widths), "All widths must be positive"


@dataclass
class FVector:
    """The f-vector of a polyhedral complex."""
    faces: List[int]  # faces[k] = number of k-dimensional faces

    @property
    def dimension(self) -> int:
        return len(self.faces) - 1

    @property
    def total_faces(self) -> int:
        return sum(self.faces)

    @property
    def euler_characteristic(self) -> int:
        return sum((-1)**k * f for k, f in enumerate(self.faces))


def zaslavsky_bound(m: int, n: int) -> int:
    """
    Zaslavsky bound: maximum regions from m hyperplanes in R^n.

    Z(m, n) = Σ_{k=0}^{n} C(m, k)

    Satisfies the recurrence: Z(m+1, n) = Z(m, n) + Z(m, n-1).

    Args:
        m: Number of hyperplanes
        n: Ambient dimension

    Returns:
        Maximum number of regions
    """
    return sum(math.comb(m, k) for k in range(n + 1))


def zaslavsky_recurrence_verify(m: int, n: int) -> Tuple[int, int, bool]:
    """
    Verify the Zaslavsky recurrence Z(m+1,n) = Z(m,n) + Z(m,n-1).

    Returns (lhs, rhs, match).
    """
    if n < 1:
        return (0, 0, True)
    lhs = zaslavsky_bound(m + 1, n)
    rhs = zaslavsky_bound(m, n) + zaslavsky_bound(m, n - 1)
    return (lhs, rhs, lhs == rhs)


def network_region_bound(arch: NetworkArchitecture) -> int:
    """
    Montúfar-Pascanu-Cho-Bengio region bound.

    bound = ∏_i Z(w_i, n)

    where w_i is the width of layer i and n is the input dimension.
    """
    bound = 1
    for w in arch.layer_widths:
        bound *= zaslavsky_bound(w, arch.input_dim)
    return bound


def depth_amplification_bound(arch: NetworkArchitecture) -> int:
    """
    Upper bound on network_region_bound for uniform-width networks.

    For width w and depth L: ((w+1)^n)^L
    """
    if not arch.layer_widths:
        return 1
    w = max(arch.layer_widths)
    n = arch.input_dim
    L = arch.depth
    return ((w + 1) ** n) ** L


def hodge_bound(arch: NetworkArchitecture, p: int, q: int) -> int:
    """
    Hodge-type bound on h^{p,q} for a network with ≥ 2 layers.

    h^{p,q} ≤ C(w₁, p) · C(w_L, q) · ∏_{middle} w_i

    Args:
        arch: Network architecture
        p: First Hodge index
        q: Second Hodge index

    Returns:
        Upper bound on h^{p,q}
    """
    if arch.depth < 2:
        return 1
    w1 = arch.layer_widths[0]
    wL = arch.layer_widths[-1]
    middle_prod = math.prod(arch.layer_widths[1:-1]) if arch.depth > 2 else 1
    return math.comb(w1, p) * math.comb(wL, q) * middle_prod


def hodge_table(arch: NetworkArchitecture, max_pq: int = 4) -> List[List[int]]:
    """
    Compute the full Hodge bound table for a network.

    Returns a (max_pq+1) × (max_pq+1) matrix of bounds.
    """
    return [
        [hodge_bound(arch, p, q) for q in range(max_pq + 1)]
        for p in range(max_pq + 1)
    ]


def euler_char_bound(fvec: FVector) -> Tuple[int, int, bool]:
    """
    Verify |χ| ≤ total_faces.

    Returns (|χ|, total_faces, satisfied).
    """
    chi = abs(fvec.euler_characteristic)
    total = fvec.total_faces
    return (chi, total, chi <= total)


def compare_depth_vs_width(
    input_dim: int,
    total_neurons: int,
) -> List[Tuple[int, int, int]]:
    """
    Compare region bounds for different depth/width allocations
    with a fixed neuron budget.

    Returns list of (width, depth, region_bound) tuples.
    """
    results: List[Tuple[int, int, int]] = []
    for depth in range(1, total_neurons + 1):
        width = total_neurons // depth
        if width < 1:
            break
        arch = NetworkArchitecture(input_dim, [width] * depth)
        bound = network_region_bound(arch)
        results.append((width, depth, bound))
    return results


def optimal_architecture(
    input_dim: int,
    total_neurons: int,
) -> Tuple[int, int, int]:
    """
    Find the depth/width allocation that maximizes the region bound.

    Returns (optimal_width, optimal_depth, max_bound).
    """
    results = compare_depth_vs_width(input_dim, total_neurons)
    return max(results, key=lambda x: x[2])


if __name__ == "__main__":
    # Example usage
    arch = NetworkArchitecture(input_dim=3, layer_widths=[5, 5, 5])
    print(f"Architecture: input_dim={arch.input_dim}, layers={arch.layer_widths}")
    print(f"Total neurons: {arch.total_neurons}")
    print(f"Region bound: {network_region_bound(arch)}")
    print(f"Depth amplification bound: {depth_amplification_bound(arch)}")
    print(f"Hodge bound h^{{1,1}}: {hodge_bound(arch, 1, 1)}")
    print(f"Hodge bound h^{{2,2}}: {hodge_bound(arch, 2, 2)}")
    print()

    # Optimal architecture for 20 neurons in R^3
    w, d, b = optimal_architecture(3, 20)
    print(f"Optimal for 20 neurons in R^3: width={w}, depth={d}, bound={b:,}")
