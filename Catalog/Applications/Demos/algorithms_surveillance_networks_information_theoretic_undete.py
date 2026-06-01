#!/usr/bin/env python3
"""
Surveillance Networks: Core Algorithms

Type-hinted implementations of the key algorithms from the formal theory.
"""

from typing import List, Tuple, Set, Dict, Callable, Optional
import itertools
import math


# Type aliases
AdjMatrix = Tuple[Tuple[bool, ...], ...]
Code = int


def generate_all_configs(n: int) -> List[AdjMatrix]:
    """Generate all 2^(n²) network configurations on n nodes.

    Args:
        n: Number of nodes in the network.

    Returns:
        List of all possible adjacency matrices.
    """
    configs: List[AdjMatrix] = []
    for bits in itertools.product([False, True], repeat=n * n):
        adj = tuple(tuple(bits[i * n + j] for j in range(n)) for i in range(n))
        configs.append(adj)
    return configs


def edge_distortion(g1: AdjMatrix, g2: AdjMatrix) -> int:
    """Compute edge distortion (Hamming distance) between two configs.

    This is the number of directed edge slots where the configurations disagree.

    Args:
        g1: First adjacency matrix.
        g2: Second adjacency matrix.

    Returns:
        Number of disagreeing edges.
    """
    n = len(g1)
    return sum(1 for i in range(n) for j in range(n) if g1[i][j] != g2[i][j])


def channel_image_size(encode: Callable[[AdjMatrix], Code],
                       configs: List[AdjMatrix]) -> int:
    """Compute the channel image size (number of distinct codes).

    Args:
        encode: The surveillance channel encoding function.
        configs: All possible network configurations.

    Returns:
        Number of distinct code values in the image.
    """
    return len(set(encode(g) for g in configs))


def privacy_defect(encode: Callable[[AdjMatrix], Code],
                   configs: List[AdjMatrix]) -> float:
    """Compute the privacy defect of a channel.

    Privacy defect is normalized to [0, 1]:
    - 0 = maximal privacy (trivial channel)
    - 1 = no privacy (injective channel)

    Args:
        encode: The surveillance channel encoding function.
        configs: All possible network configurations.

    Returns:
        Privacy defect value in [0, 1].
    """
    N = len(configs)
    if N <= 1:
        return 0.0
    img = channel_image_size(encode, configs)
    return (img - 1) / (N - 1)


def max_fiber_size(encode: Callable[[AdjMatrix], Code],
                   configs: List[AdjMatrix]) -> int:
    """Compute the maximum fiber size (largest preimage).

    Args:
        encode: The surveillance channel encoding function.
        configs: All possible network configurations.

    Returns:
        Size of the largest fiber (preimage of a code value).
    """
    fibers: Dict[Code, int] = {}
    for g in configs:
        c = encode(g)
        fibers[c] = fibers.get(c, 0) + 1
    return max(fibers.values()) if fibers else 0


def find_packing_set(configs: List[AdjMatrix], D: int) -> List[AdjMatrix]:
    """Find a maximal packing set with separation > D.

    A packing set is a set of configurations where every pair has
    edge distortion > D. This is found greedily.

    Args:
        configs: Pool of network configurations.
        D: Minimum separation threshold.

    Returns:
        A maximal packing set.
    """
    packing: List[AdjMatrix] = []
    for g in configs:
        if all(edge_distortion(g, p) > D for p in packing):
            packing.append(g)
    return packing


def optimal_reconstruction(encode: Callable[[AdjMatrix], Code],
                          configs: List[AdjMatrix]) -> Callable[[Code], AdjMatrix]:
    """Find the optimal reconstruction map for a given channel.

    For each code value, finds the config that minimizes the maximum
    distortion within the fiber (minimax reconstruction).

    Args:
        encode: The surveillance channel encoding function.
        configs: All possible network configurations.

    Returns:
        Reconstruction function mapping codes to configs.
    """
    # Group configs by code
    fibers: Dict[Code, List[AdjMatrix]] = {}
    for g in configs:
        c = encode(g)
        if c not in fibers:
            fibers[c] = []
        fibers[c].append(g)

    # For each fiber, find the centroid (minimizes max distortion)
    reconstruction: Dict[Code, AdjMatrix] = {}
    for code, fiber in fibers.items():
        best_config: Optional[AdjMatrix] = None
        best_max_dist = float('inf')
        for candidate in fiber:
            max_dist = max(edge_distortion(candidate, g) for g in fiber)
            if max_dist < best_max_dist:
                best_max_dist = max_dist
                best_config = candidate
        reconstruction[code] = best_config  # type: ignore

    default = configs[0]
    return lambda c: reconstruction.get(c, default)


def worst_case_distortion(encode: Callable[[AdjMatrix], Code],
                          decode: Callable[[Code], AdjMatrix],
                          configs: List[AdjMatrix]) -> int:
    """Compute worst-case distortion of a channel-reconstruction pair.

    Args:
        encode: Channel encoding function.
        decode: Reconstruction function.
        configs: All possible network configurations.

    Returns:
        Maximum distortion over all configs.
    """
    return max(edge_distortion(g, decode(encode(g))) for g in configs)


def privacy_utility_curve(n: int,
                          num_channels: int = 100) -> List[Tuple[float, float]]:
    """Compute the privacy-utility tradeoff curve by sampling random channels.

    Args:
        n: Number of nodes.
        num_channels: Number of random channels to sample.

    Returns:
        List of (privacy_defect, worst_case_distortion) pairs.
    """
    import random
    configs = generate_all_configs(n)
    curve: List[Tuple[float, float]] = []

    for num_codes in range(1, len(configs) + 1):
        # Random channel with `num_codes` code values
        def make_channel(nc: int) -> Callable[[AdjMatrix], Code]:
            mapping = {g: random.randint(0, nc - 1) for g in configs}
            return lambda g: mapping[g]

        encode = make_channel(num_codes)
        decode = optimal_reconstruction(encode, configs)
        pd = privacy_defect(encode, configs)
        wcd = worst_case_distortion(encode, decode, configs)
        curve.append((pd, float(wcd)))

    return curve


if __name__ == "__main__":
    # Example usage
    n = 2
    configs = generate_all_configs(n)
    print(f"Network on {n} nodes: {len(configs)} configurations")

    # Identity channel
    identity: Callable[[AdjMatrix], Code] = lambda g: hash(g)
    print(f"Identity channel image size: {channel_image_size(identity, configs)}")
    print(f"Identity privacy defect: {privacy_defect(identity, configs):.4f}")

    # Constant channel
    constant: Callable[[AdjMatrix], Code] = lambda g: 0
    print(f"Constant channel image size: {channel_image_size(constant, configs)}")
    print(f"Constant privacy defect: {privacy_defect(constant, configs):.4f}")

    # Packing bound
    for D in [0, 1, 2, 3]:
        packing = find_packing_set(configs, 2 * D)
        print(f"D={D}: packing size = {len(packing)} (lower bound on channel size)")
