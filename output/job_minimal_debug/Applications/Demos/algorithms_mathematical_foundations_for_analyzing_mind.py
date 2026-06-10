#!/usr/bin/env python3
"""
Algorithms for Sparse Connectome Complexity Analysis

Type-hinted implementations of the key algorithms from the research.
"""

import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class MindEncodingSystem:
    """A mind encoding system with neurons, weight levels, and storage budget."""
    neurons: int
    weight_levels: int
    storage_bits: int

    def is_faithful(self) -> bool:
        """Check if the encoding can be faithful (k^(n²) ≤ 2^B)."""
        log_source = self.neurons * self.neurons * math.log2(self.weight_levels)
        return log_source <= self.storage_bits

    def encoding_deficit(self) -> float:
        """How many bits short of faithful encoding (negative = surplus)."""
        return self.neurons * self.neurons * math.log2(self.weight_levels) - self.storage_bits


def connectome_entropy(n: int, k: int) -> float:
    """
    Compute the connectome entropy in bits.

    Parameters:
        n: Number of neurons
        k: Number of weight levels (k ≥ 2)

    Returns:
        n² × log₂(k) bits
    """
    if k < 2:
        return 0.0
    return n * n * math.log2(k)


def neural_info_defect(n: int, k: int, m: int) -> float:
    """
    Compute the Neural Information Defect (NID).

    The NID measures the total bits of information irreversibly lost when
    coarse-graining synaptic weights from k levels to m levels across
    n² synaptic positions.

    Parameters:
        n: Number of neurons
        k: Source weight resolution
        m: Target weight resolution (m < k for positive defect)

    Returns:
        NID(n, k, m) = n² × (log₂(k) - log₂(m))
    """
    if m >= k or m <= 0 or k <= 0:
        return 0.0
    return n * n * (math.log2(k) - math.log2(m))


def nid_composition_bound(n: int, k: int, m: int, l: int) -> Tuple[float, float]:
    """
    Compute the NID of a composed coarse-graining and verify subadditivity.

    Returns:
        (direct_nid, sum_of_parts) where direct_nid ≤ sum_of_parts
    """
    direct = neural_info_defect(n, k, l)
    part1 = neural_info_defect(n, k, m)
    part2 = neural_info_defect(n, m, l)
    return direct, part1 + part2


def min_faithful_bits(n: int, k: int) -> int:
    """
    Minimum number of bits for a faithful mind encoding.

    Returns the smallest B such that k^(n²) ≤ 2^B.
    """
    return math.ceil(n * n * math.log2(k))


def sparse_connectome_bound(n: int, k: int, d: int) -> float:
    """
    Upper bound on the number of d-sparse connectomes.

    Each neuron chooses at most d targets from n options, each with
    k-1 nonzero weight choices.

    Returns:
        C(n, d)^n × (k-1)^(n×d)
    """
    from math import comb
    d_eff = min(d, n)
    return float(comb(n, d_eff) ** n) * float((k - 1) ** (n * d_eff))


def compression_ratio(n: int, k: int, d: int) -> float:
    """
    Compression ratio achievable by exploiting d-sparsity.

    Returns the ratio of sparse encoding bits to dense encoding bits.
    """
    dense_bits = connectome_entropy(n, k)
    if dense_bits == 0:
        return 1.0
    # Sparse encoding: n × (d × log2(n) + d × log2(k)) bits
    # (d targets per neuron, each identified by log2(n) bits + log2(k) weight bits)
    d_eff = min(d, n)
    sparse_bits = n * d_eff * (math.log2(max(n, 2)) + math.log2(max(k, 2)))
    return sparse_bits / dense_bits


def critical_neuron_count(storage_bits: int, k: int) -> int:
    """
    Maximum number of neurons that can be faithfully encoded in B bits.

    Solves n² × log₂(k) ≤ B for n.

    Returns:
        ⌊√(B / log₂(k))⌋
    """
    if k < 2:
        return storage_bits  # trivial case
    return int(math.sqrt(storage_bits / math.log2(k)))


def bekenstein_neuron_limit(radius_m: float, energy_j: float, k: int) -> int:
    """
    Maximum neurons whose connectome fits within the Bekenstein bound.

    The Bekenstein bound gives I_max = 2πRE/(ℏc ln 2) bits.

    Parameters:
        radius_m: Brain radius in meters
        energy_j: Brain energy in joules
        k: Weight levels per synapse

    Returns:
        Maximum neuron count n* = ⌊√(I_max / log₂(k))⌋
    """
    hbar = 1.054571817e-34  # reduced Planck constant (J·s)
    c = 299792458.0  # speed of light (m/s)
    I_max = 2 * math.pi * radius_m * energy_j / (hbar * c * math.log(2))
    return int(math.sqrt(I_max / math.log2(k)))


@dataclass
class ScanningPipeline:
    """Model of a multi-stage brain scanning pipeline."""
    stages: List[Tuple[str, int]]  # (name, output_resolution)

    def total_nid(self, n: int, source_k: int) -> float:
        """Compute total NID across all pipeline stages."""
        total = 0.0
        current_k = source_k
        for name, target_m in self.stages:
            total += neural_info_defect(n, current_k, target_m)
            current_k = target_m
        return total

    def stage_nids(self, n: int, source_k: int) -> List[Tuple[str, float]]:
        """Compute NID for each pipeline stage."""
        result = []
        current_k = source_k
        for name, target_m in self.stages:
            nid = neural_info_defect(n, current_k, target_m)
            result.append((name, nid))
            current_k = target_m
        return result


def scanning_pipeline_demo():
    """Demonstrate the scanning pipeline analysis."""
    pipeline = ScanningPipeline(stages=[
        ("MRI Scanning", 64),
        ("Digital Quantization", 16),
        ("Compression", 4),
    ])

    n = 1000  # 1000 neurons
    k = 256   # original resolution

    print(f"Scanning Pipeline Analysis (n={n}, source k={k}):")
    print(f"{'Stage':<25} {'Output k':<10} {'NID (bits)':<15}")
    print("-" * 50)

    for name, nid in pipeline.stage_nids(n, k):
        print(f"{name:<25} {'':>10} {nid:>12,.0f}")

    total = pipeline.total_nid(n, k)
    direct = neural_info_defect(n, k, pipeline.stages[-1][1])
    print("-" * 50)
    print(f"{'Total NID (sum)':<25} {'':>10} {total:>12,.0f}")
    print(f"{'Direct NID (k→final)':<25} {'':>10} {direct:>12,.0f}")
    print(f"Subadditivity verified: {direct:.0f} ≤ {total:.0f}: {direct <= total}")


if __name__ == "__main__":
    scanning_pipeline_demo()
