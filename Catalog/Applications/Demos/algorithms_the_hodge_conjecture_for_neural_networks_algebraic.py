#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for analyzing neural network decision surfaces.

Type-hinted implementations of:
1. Zaslavsky region counting
2. Deep network region bound (Montufar et al.)
3. Hodge rank computation
4. Face enumeration for hyperplane arrangements
5. Euler characteristic computation
"""

from typing import List, Tuple, Optional
import math


def choose(n: int, k: int) -> int:
    """Binomial coefficient C(n, k).

    Args:
        n: Total number of items
        k: Number to choose

    Returns:
        C(n, k), or 0 if k < 0 or k > n
    """
    if k < 0 or k > n:
        return 0
    return math.comb(n, k)


def max_regions(n_hyperplanes: int, dimension: int) -> int:
    """Zaslavsky's bound on regions created by hyperplane arrangement.

    For n hyperplanes in general position in R^d, the maximum number
    of regions is sum_{k=0}^{d} C(n, k).

    Args:
        n_hyperplanes: Number of hyperplanes
        dimension: Ambient dimension

    Returns:
        Maximum number of regions
    """
    return sum(choose(n_hyperplanes, k) for k in range(dimension + 1))


def deep_region_bound(
    input_dim: int,
    hidden_width: int,
    num_hidden_layers: int,
) -> int:
    """Montufar-Pascanu-Cho-Bengio bound on linear regions.

    For a deep ReLU network with L hidden layers, each of width w,
    operating on R^d input, the number of linear regions is at most:
        max_regions(w, d) * (2^w)^(L-1)

    Args:
        input_dim: Input dimension d
        hidden_width: Width w of each hidden layer
        num_hidden_layers: Number of hidden layers L

    Returns:
        Upper bound on the number of linear regions
    """
    base = max_regions(hidden_width, input_dim)
    exponent = max(0, num_hidden_layers - 1)
    return base * (2 ** hidden_width) ** exponent


def hodge_rank(widths: List[int], p: int, q: int) -> int:
    """Conjectured Hodge rank h^{p,q} for a network decision surface.

    For a network with architecture [n, w_1, ..., w_L, 1], the
    conjectured bound on the Hodge number h^{p,q} of the decision
    surface is C(w_1, p) * C(w_L, q).

    Args:
        widths: Layer widths [input, hidden_1, ..., hidden_L, output]
        p: First Hodge index
        q: Second Hodge index

    Returns:
        Conjectured upper bound on h^{p,q}
    """
    if len(widths) < 2:
        return 0
    w1 = widths[0]
    wL = widths[-1] if len(widths) >= 3 else widths[0]
    return choose(w1, p) * choose(wL, q)


def arrangement_face_bound(
    n_hyperplanes: int,
    dimension: int,
    face_dim: int,
) -> int:
    """Upper bound on k-faces of a hyperplane arrangement.

    Args:
        n_hyperplanes: Number of hyperplanes n
        dimension: Ambient dimension d
        face_dim: Dimension k of the faces to count

    Returns:
        Upper bound C(n, d-k) * C(d, k)
    """
    return choose(n_hyperplanes, dimension - face_dim) * choose(dimension, face_dim)


def euler_characteristic(face_counts: List[int]) -> int:
    """Compute Euler characteristic from face vector.

    chi = sum_{i=0}^{dim} (-1)^i * f_i

    Args:
        face_counts: List [f_0, f_1, ..., f_dim] of face counts

    Returns:
        Euler characteristic
    """
    return sum((-1) ** i * f for i, f in enumerate(face_counts))


def relu(x: float) -> float:
    """The rectified linear unit function.

    relu(x) = max(0, x) = (x + |x|) / 2

    Args:
        x: Input value

    Returns:
        max(0, x)
    """
    return max(0.0, x)


def network_complexity_profile(widths: List[int]) -> dict:
    """Compute complexity profile of a network architecture.

    Args:
        widths: Layer widths [input, hidden_1, ..., hidden_L, output]

    Returns:
        Dictionary with complexity metrics
    """
    if len(widths) < 2:
        return {"error": "Need at least 2 layers"}

    input_dim = widths[0]
    output_dim = widths[-1]
    hidden_widths = widths[1:-1] if len(widths) > 2 else []
    num_hidden = len(hidden_widths)

    # Region bound
    if hidden_widths:
        w = max(hidden_widths)
        region_bound = deep_region_bound(input_dim, w, num_hidden)
    else:
        region_bound = 1

    # Hodge ranks
    hodge_table: dict = {}
    for p in range(min(input_dim + 1, 6)):
        for q in range(min(output_dim + 1, 6)):
            h = hodge_rank(widths, p, q)
            if h > 0:
                hodge_table[(p, q)] = h

    # Total parameters
    total_params = sum(
        widths[i] * widths[i + 1] + widths[i + 1]
        for i in range(len(widths) - 1)
    )

    return {
        "input_dim": input_dim,
        "output_dim": output_dim,
        "hidden_widths": hidden_widths,
        "num_hidden_layers": num_hidden,
        "total_parameters": total_params,
        "max_linear_regions": region_bound,
        "hodge_ranks": hodge_table,
        "decision_surface_dim": input_dim - 1 if output_dim == 1 else None,
    }


if __name__ == "__main__":
    print("Network Complexity Profiles")
    print("=" * 50)

    architectures = [
        [2, 3, 1],
        [2, 5, 1],
        [3, 4, 1],
        [2, 4, 3, 1],
        [10, 20, 1],
        [2, 10, 10, 1],
    ]

    for arch in architectures:
        profile = network_complexity_profile(arch)
        print(f"\nArchitecture: {arch}")
        for key, value in profile.items():
            if key == "hodge_ranks":
                print(f"  {key}:")
                for (p, q), h in sorted(value.items()):
                    print(f"    h^{{{p},{q}}} = {h}")
            else:
                print(f"  {key}: {value}")
