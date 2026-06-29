#!/usr/bin/env python3
"""
Algorithms for Information-Theoretic Analysis of Neural Connectomes.
Type-hinted implementations of core computational methods.
"""
import math
from typing import List, Tuple, Optional
import itertools


def connectome_entropy(matrix: List[List[int]], k: int) -> float:
    """
    Compute the Shannon entropy of a connectome weight matrix.

    Args:
        matrix: n×n matrix of synaptic weights (values in {0, ..., k-1})
        k: number of weight levels

    Returns:
        Shannon entropy in bits (upper bound on compression ratio)
    """
    n = len(matrix)
    if n == 0 or k <= 0:
        return 0.0

    # Count frequency of each weight value
    freq: dict[int, int] = {}
    total = n * n
    for row in matrix:
        for w in row:
            freq[w] = freq.get(w, 0) + 1

    # Compute entropy
    entropy = 0.0
    for count in freq.values():
        if count > 0:
            p = count / total
            entropy -= p * math.log2(p)

    return entropy * total  # Total bits, not per-symbol


def neural_info_defect(n: int, k: int, k_prime: int) -> float:
    """
    Compute the Neural Information Defect (NID).

    NID(n, k, k') = n² · (log₂(k) - log₂(k'))

    Args:
        n: number of neurons
        k: original weight precision
        k_prime: target weight precision

    Returns:
        Number of bits irrecoverably lost
    """
    if k <= 0 or k_prime <= 0:
        raise ValueError("Weight levels must be positive")
    return n * n * (math.log2(k) - math.log2(k_prime))


def bekenstein_bound_bits(
    radius_m: float,
    mass_kg: float,
    hbar: float = 1.054571817e-34,
    c: float = 2.998e8,
) -> float:
    """
    Compute the Bekenstein bound in bits.

    B(R, M) = 2πRMc² / (ℏ ln 2)

    Args:
        radius_m: radius of the region in meters
        mass_kg: mass in kilograms
        hbar: reduced Planck constant (default: SI value)
        c: speed of light (default: SI value)

    Returns:
        Maximum information in bits
    """
    energy = mass_kg * c ** 2
    return 2 * math.pi * radius_m * energy / (hbar * math.log(2))


def min_description_length(n: int, k: int) -> float:
    """
    Minimum description length of a connectome in bits.

    MDL(n, k) = n² · log₂(k)

    Args:
        n: number of neurons
        k: number of weight levels

    Returns:
        Minimum bits required for lossless encoding
    """
    if k <= 0:
        raise ValueError("Weight levels must be positive")
    return n * n * math.log2(k)


def compression_ratio_bound(n: int, k: int, compressed_bits: int) -> float:
    """
    Compute the fraction of connectomes that CAN be compressed
    to at most `compressed_bits` bits.

    By the pigeonhole principle, at most 2^compressed_bits
    connectomes have descriptions of that length.

    Args:
        n: number of neurons
        k: weight levels
        compressed_bits: target description length

    Returns:
        Upper bound on fraction of compressible connectomes
    """
    total = k ** (n * n)
    compressible = 2 ** compressed_bits
    return min(1.0, compressible / total)


def enumerate_connectomes(n: int, k: int) -> List[Tuple[Tuple[int, ...], ...]]:
    """
    Enumerate all connectomes for small n, k.

    Args:
        n: number of neurons (keep small!)
        k: weight levels

    Returns:
        List of connectome matrices (as tuples of tuples)
    """
    if n * n > 16:
        raise ValueError(f"Too many synapses ({n*n}) to enumerate")

    weights = range(k)
    all_entries = list(itertools.product(weights, repeat=n * n))
    return [
        tuple(entries[i * n : (i + 1) * n] for i in range(n))
        for entries in all_entries
    ]


def coarse_grain(
    matrix: List[List[int]], k: int, k_prime: int
) -> List[List[int]]:
    """
    Apply uniform coarse-graining to a connectome matrix.

    Maps weights from {0,...,k-1} to {0,...,k'-1} by
    floor division: w ↦ w * k' // k.

    Args:
        matrix: n×n weight matrix
        k: original precision
        k_prime: target precision

    Returns:
        Coarse-grained weight matrix
    """
    return [[w * k_prime // k for w in row] for row in matrix]


def upload_feasibility_analysis(
    neurons: int,
    weight_levels: int,
    substrate_radius_m: float,
    substrate_mass_kg: float,
) -> dict:
    """
    Complete feasibility analysis for a mind upload specification.

    Args:
        neurons: number of neurons
        weight_levels: synaptic weight precision
        substrate_radius_m: radius of target substrate
        substrate_mass_kg: mass of target substrate

    Returns:
        Dictionary with analysis results
    """
    info_req = min_description_length(neurons, weight_levels)
    phys_cap = bekenstein_bound_bits(substrate_radius_m, substrate_mass_kg)
    ratio = phys_cap / info_req if info_req > 0 else float("inf")

    return {
        "neurons": neurons,
        "weight_levels": weight_levels,
        "info_requirement_bits": info_req,
        "bekenstein_capacity_bits": phys_cap,
        "capacity_ratio": ratio,
        "feasible": phys_cap >= info_req,
        "nid_to_half_precision": neural_info_defect(
            neurons, weight_levels, max(2, weight_levels // 2)
        ),
    }


if __name__ == "__main__":
    # Example: human brain upload feasibility
    result = upload_feasibility_analysis(
        neurons=86_000_000_000,
        weight_levels=256,
        substrate_radius_m=0.1,
        substrate_mass_kg=1.4,
    )
    print("Upload Feasibility Analysis:")
    for key, val in result.items():
        if isinstance(val, float):
            print(f"  {key}: {val:.4e}")
        else:
            print(f"  {key}: {val}")
