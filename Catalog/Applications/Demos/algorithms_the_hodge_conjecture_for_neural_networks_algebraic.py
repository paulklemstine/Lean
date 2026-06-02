#!/usr/bin/env python3
"""
Algorithms for Neural Network Decision Surface Topology

Type-hinted implementations of the key algorithms:
1. Zaslavsky bound computation
2. Neural complexity estimation
3. Activation pattern enumeration
4. F-vector and Euler characteristic computation
5. Hodge number bound calculation
"""

from math import comb
from typing import List, Tuple, Iterator, Dict
from itertools import product as cartesian_product
from dataclasses import dataclass


@dataclass
class NetworkArch:
    """Architecture of a feedforward ReLU network."""
    input_dim: int
    hidden_widths: List[int]

    @property
    def depth(self) -> int:
        return len(self.hidden_widths)

    @property
    def total_neurons(self) -> int:
        return sum(self.hidden_widths)


def zaslavsky_bound(n: int, w: int) -> int:
    """
    Compute the Zaslavsky bound Z(n, w) = Σ_{k=0}^{min(n,w)} C(w, k).

    This is the maximum number of regions created by w hyperplanes
    in general position in R^n.

    Args:
        n: Ambient dimension
        w: Number of hyperplanes

    Returns:
        Maximum number of regions

    Examples:
        >>> zaslavsky_bound(2, 3)  # 3 lines in R^2 → at most 7 regions
        7
        >>> zaslavsky_bound(1, 5)  # 5 points on R → at most 6 intervals
        6
    """
    return sum(comb(w, k) for k in range(min(n, w) + 1))


def neural_complexity(arch: NetworkArch) -> int:
    """
    Compute the neural complexity of a network architecture.

    This is the product of per-layer Zaslavsky bounds, which bounds
    the maximum number of linear regions.

    Args:
        arch: Network architecture

    Returns:
        Neural complexity bound

    Examples:
        >>> neural_complexity(NetworkArch(2, [3, 3]))
        49
    """
    result = 1
    for w in arch.hidden_widths:
        result *= zaslavsky_bound(arch.input_dim, w)
    return result


def neural_complexity_upper_bound(arch: NetworkArch) -> int:
    """
    Compute the simplified upper bound 2^{total_neurons}.

    This is always >= neural_complexity but easier to compute.

    Args:
        arch: Network architecture

    Returns:
        2^{total_neurons}
    """
    return 2 ** arch.total_neurons


def enumerate_activation_patterns(width: int) -> Iterator[Tuple[bool, ...]]:
    """
    Enumerate all activation patterns for a single layer.

    Args:
        width: Layer width

    Yields:
        Tuples of booleans representing active (True) / inactive (False) neurons
    """
    for pattern in cartesian_product([False, True], repeat=width):
        yield pattern


def count_activation_patterns(arch: NetworkArch) -> int:
    """
    Count the total number of full activation patterns.

    This is Π_i 2^{w_i} = 2^{total_neurons}.

    Args:
        arch: Network architecture

    Returns:
        Number of full activation patterns
    """
    result = 1
    for w in arch.hidden_widths:
        result *= 2 ** w
    return result


def euler_characteristic(f_vector: List[int]) -> int:
    """
    Compute the Euler characteristic from an f-vector.

    χ = Σ_{k=0}^{d} (-1)^k f_k

    Args:
        f_vector: List of face counts [f_0, f_1, ..., f_d]

    Returns:
        Euler characteristic

    Examples:
        >>> euler_characteristic([4, 6, 4])  # tetrahedron
        2
        >>> euler_characteristic([8, 12, 6])  # cube
        2
    """
    return sum((-1)**k * fk for k, fk in enumerate(f_vector))


def euler_char_bound(f_vector: List[int]) -> int:
    """
    Compute the upper bound on |χ| from the f-vector.

    |χ| ≤ Σ f_k

    Args:
        f_vector: List of face counts

    Returns:
        Total face count (upper bound on |χ|)
    """
    return sum(f_vector)


def hodge_numbers_bound(w1: int, wL: int, max_pq: int) -> Dict[Tuple[int, int], int]:
    """
    Compute the Hodge number bounds h^{p,q} ≤ C(w1, p) * C(wL, q).

    Args:
        w1: Width of first hidden layer
        wL: Width of last hidden layer
        max_pq: Maximum value of p and q to compute

    Returns:
        Dictionary mapping (p, q) to the Hodge number bound
    """
    bounds = {}
    for p in range(max_pq + 1):
        for q in range(max_pq + 1):
            bounds[(p, q)] = comb(w1, p) * comb(wL, q)
    return bounds


def face_count_bound(arch: NetworkArch) -> int:
    """
    Upper bound on the number of faces of the decision boundary.

    Bound: total_neurons * neural_complexity ≤ total_neurons * 2^{total_neurons}

    Args:
        arch: Network architecture

    Returns:
        Upper bound on face count
    """
    return arch.total_neurons * neural_complexity_upper_bound(arch)


def max_betti_bound(arch: NetworkArch, k: int) -> int:
    """
    Upper bound on the k-th Betti number of the decision surface.

    β_k ≤ face_count_bound (since each k-cycle is a sum of k-faces,
    and the number of k-faces is bounded by the total face count).

    Args:
        arch: Network architecture
        k: Dimension of the Betti number

    Returns:
        Upper bound on β_k
    """
    return face_count_bound(arch)


# --- Demonstration ---
if __name__ == "__main__":
    # Example: 2D input, two hidden layers of width 5
    arch = NetworkArch(input_dim=2, hidden_widths=[5, 5])

    print(f"Architecture: input_dim={arch.input_dim}, widths={arch.hidden_widths}")
    print(f"Depth: {arch.depth}")
    print(f"Total neurons: {arch.total_neurons}")
    print(f"Neural complexity: {neural_complexity(arch)}")
    print(f"Upper bound (2^W): {neural_complexity_upper_bound(arch)}")
    print(f"Activation patterns: {count_activation_patterns(arch)}")
    print(f"Face count bound: {face_count_bound(arch)}")
    print()

    # Hodge numbers
    print("Hodge number bounds (w1=5, wL=5):")
    bounds = hodge_numbers_bound(5, 5, 3)
    for (p, q), b in sorted(bounds.items()):
        print(f"  h^{{{p},{q}}} ≤ {b}")
