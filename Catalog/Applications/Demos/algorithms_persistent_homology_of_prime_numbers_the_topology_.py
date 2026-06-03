#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for persistent homology of 1D point clouds.

Type-hinted implementations of:
1. Rips component counting for 1D point clouds
2. H_0 barcode computation
3. Barcode stability bound computation
4. Cramér model simulation and comparison
"""

from __future__ import annotations
import math
import random
from dataclasses import dataclass, field
from typing import Sequence


@dataclass
class PH0Bar:
    """A bar in the H_0 barcode. Birth is always 0 for Rips filtrations."""
    birth: float = 0.0
    death: float = 0.0

    @property
    def length(self) -> float:
        return self.death - self.birth


@dataclass
class BarcodeStats:
    """Statistics of an H_0 barcode."""
    num_bars: int = 0
    total_length: float = 0.0
    mean_length: float = 0.0
    max_length: float = 0.0
    min_length: float = float('inf')


def sieve_primes(limit: int) -> list[int]:
    """Sieve of Eratosthenes returning primes up to limit."""
    if limit < 2:
        return []
    sieve = bytearray(b'\x01') * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i, v in enumerate(sieve) if v]


def compute_gaps(points: Sequence[float]) -> list[float]:
    """Compute consecutive gaps of a sorted sequence."""
    return [points[i + 1] - points[i] for i in range(len(points) - 1)]


def rips_components_1d(gaps: Sequence[float], epsilon: float) -> int:
    """
    Number of connected components at scale epsilon for a 1D point cloud.

    By the 1D Rips Component Theorem:
        C(epsilon) = #{gaps > epsilon} + 1

    Args:
        gaps: Consecutive gaps of the sorted point cloud.
        epsilon: The scale parameter.

    Returns:
        Number of connected components.
    """
    return sum(1 for g in gaps if g > epsilon) + 1


def compute_h0_barcode(gaps: Sequence[float]) -> list[PH0Bar]:
    """
    Compute the H_0 barcode of a 1D point cloud from its gaps.

    Each bar has birth = 0 and death = gap_i. The essential bar is omitted.

    Args:
        gaps: Consecutive gaps of the sorted point cloud.

    Returns:
        List of PH0Bar objects, sorted by death time.
    """
    bars = [PH0Bar(birth=0.0, death=float(g)) for g in gaps]
    bars.sort(key=lambda b: b.death)
    return bars


def barcode_statistics(bars: list[PH0Bar]) -> BarcodeStats:
    """Compute statistics of an H_0 barcode."""
    if not bars:
        return BarcodeStats()
    lengths = [b.length for b in bars]
    return BarcodeStats(
        num_bars=len(bars),
        total_length=sum(lengths),
        mean_length=sum(lengths) / len(lengths),
        max_length=max(lengths),
        min_length=min(lengths),
    )


def component_drop(gaps: Sequence[float], k: int) -> int:
    """
    Compute the component drop between scale k and k+1.

    By the Component Derivative Formula:
        C(k) - C(k+1) = #{gaps == k+1}

    Args:
        gaps: Consecutive gaps.
        k: The scale.

    Returns:
        Number of gaps equal to k+1.
    """
    target = k + 1
    return sum(1 for g in gaps if g == target)


def gap_perturbation_bound(delta: float) -> float:
    """
    Maximum gap perturbation for delta-close sequences.

    By the 1D Barcode Stability Theorem:
        |gap_f(i) - gap_g(i)| <= 2*delta

    Args:
        delta: Maximum pointwise distance between sequences.

    Returns:
        The gap perturbation bound 2*delta.
    """
    return 2.0 * delta


def cramer_model_primes(limit: int, seed: int | None = None) -> list[int]:
    """
    Generate "primes" using Cramér's random model.

    Each integer n >= 2 is independently kept with probability 1/log(n).

    Args:
        limit: Upper bound for generation.
        seed: Random seed for reproducibility.

    Returns:
        List of model "primes".
    """
    rng = random.Random(seed)
    model_primes = [2]  # Always include 2
    for n in range(3, limit + 1):
        if rng.random() < 1.0 / math.log(n):
            model_primes.append(n)
    return model_primes


def compare_barcodes(
    prime_gaps: list[float],
    model_gaps: list[float],
) -> dict[str, float]:
    """
    Compare prime barcode with Cramér model barcode.

    Returns:
        Dictionary with comparison metrics.
    """
    p_bars = compute_h0_barcode(prime_gaps)
    m_bars = compute_h0_barcode(model_gaps)
    p_stats = barcode_statistics(p_bars)
    m_stats = barcode_statistics(m_bars)

    return {
        "prime_mean_bar": p_stats.mean_length,
        "model_mean_bar": m_stats.mean_length,
        "prime_max_bar": p_stats.max_length,
        "model_max_bar": m_stats.max_length,
        "prime_num_bars": p_stats.num_bars,
        "model_num_bars": m_stats.num_bars,
        "mean_ratio": p_stats.mean_length / m_stats.mean_length if m_stats.mean_length else 0,
    }


def filtration_step_function(
    gaps: Sequence[float],
    max_epsilon: int | None = None,
) -> list[tuple[int, int]]:
    """
    Compute the full filtration: (epsilon, num_components) pairs.

    Args:
        gaps: Consecutive gaps.
        max_epsilon: Maximum scale to compute (default: max gap).

    Returns:
        List of (epsilon, components) pairs.
    """
    if not gaps:
        return [(0, 1)]
    if max_epsilon is None:
        max_epsilon = int(max(gaps))
    return [(eps, rips_components_1d(gaps, eps)) for eps in range(max_epsilon + 1)]


if __name__ == "__main__":
    # Quick test
    primes = sieve_primes(1000)
    gaps = compute_gaps(primes)

    print("Prime barcode (first 1000):")
    stats = barcode_statistics(compute_h0_barcode(gaps))
    print(f"  Bars: {stats.num_bars}, Mean: {stats.mean_length:.2f}, "
          f"Max: {stats.max_length:.0f}")

    print("\nFiltration (first 20 scales):")
    for eps, c in filtration_step_function(gaps)[:20]:
        print(f"  ε={eps:>3}: {c:>4} components")

    print("\nCramér model comparison:")
    model = cramer_model_primes(1000, seed=42)
    mgaps = compute_gaps(model)
    comp = compare_barcodes(gaps, mgaps)
    print(f"  Prime mean gap: {comp['prime_mean_bar']:.2f}")
    print(f"  Model mean gap: {comp['model_mean_bar']:.2f}")
    print(f"  Ratio: {comp['mean_ratio']:.3f}")
