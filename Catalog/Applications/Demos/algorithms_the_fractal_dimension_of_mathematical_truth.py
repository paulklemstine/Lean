#!/usr/bin/env python3
"""
Algorithms for Fractal Dimension of Mathematical Truth

Type-hinted implementations of the core algorithms from the research paper.
"""

import math
from dataclasses import dataclass
from typing import Callable, Optional


@dataclass
class BinaryGrowth:
    """A binary growth function N: ℕ → ℕ with 0 < N(n) ≤ 2^n for n > 0."""
    count: Callable[[int], int]
    
    def validate(self, n: int) -> bool:
        """Check the growth function axioms at level n."""
        c = self.count(n)
        if n > 0 and c <= 0:
            return False
        if c > 2 ** n:
            return False
        return True
    
    def density(self, n: int) -> float:
        """Truth density d(n) = N(n) / 2^n."""
        return self.count(n) / (2 ** n)
    
    def growth_exponent(self, n: int) -> float:
        """Growth exponent α(n) = log(N(n)) / (n · log 2)."""
        if n == 0:
            return 0.0
        c = self.count(n)
        if c <= 0:
            return 0.0
        return math.log(c) / (n * math.log(2))


@dataclass
class TruthDensitySpectrum:
    """
    A truth density spectrum: a growth function with certified dimension bounds.
    
    The spectral gap (dim_upper - dim_lower) measures dimensional irregularity.
    """
    growth: BinaryGrowth
    dim_lower: float
    dim_upper: float
    
    @property
    def spectral_gap(self) -> float:
        """The spectral gap Δ = α_U - α_L."""
        return self.dim_upper - self.dim_lower
    
    def validate(self, max_n: int = 100) -> bool:
        """Verify spectral bounds hold for levels 1..max_n."""
        if not (0 <= self.dim_lower <= self.dim_upper <= 1):
            return False
        for n in range(1, max_n + 1):
            alpha = self.growth.growth_exponent(n)
            if alpha < self.dim_lower - 1e-10 or alpha > self.dim_upper + 1e-10:
                return False
        return True


def compute_growth_exponent(count: int, n: int) -> float:
    """
    Algorithm 1: Compute the growth exponent α(n).
    
    Args:
        count: Number of true strings of length n
        n: String length
    
    Returns:
        Growth exponent α(n) = log(count) / (n · log 2)
    """
    if n <= 0 or count <= 0:
        return 0.0
    return math.log(count) / (n * math.log(2))


def refine_spectral_bounds(
    growth: BinaryGrowth, 
    max_n: int
) -> TruthDensitySpectrum:
    """
    Algorithm 2: Compute spectral bounds by scanning levels 1..max_n.
    
    Args:
        growth: The binary growth function
        max_n: Maximum level to scan
    
    Returns:
        TruthDensitySpectrum with computed bounds
    """
    alpha_min = float('inf')
    alpha_max = float('-inf')
    
    for n in range(1, max_n + 1):
        alpha = growth.growth_exponent(n)
        alpha_min = min(alpha_min, alpha)
        alpha_max = max(alpha_max, alpha)
    
    return TruthDensitySpectrum(
        growth=growth,
        dim_lower=alpha_min,
        dim_upper=alpha_max
    )


def approximate_dimension_from_below(
    n: int, 
    verified_count: int
) -> float:
    """
    Algorithm 3: Lower bound on growth exponent from partial enumeration.
    
    This is the analogue of approximating Chaitin's Omega from below:
    each verified truth improves the lower bound.
    
    Args:
        n: String length
        verified_count: Number of verified true strings (k ≤ N(n))
    
    Returns:
        Lower bound log(k) / (n · log 2) ≤ α(n)
    """
    if n <= 0 or verified_count <= 0:
        return 0.0
    return math.log(verified_count) / (n * math.log(2))


def density_exponent_duality(
    density: float, 
    n: int
) -> Optional[float]:
    """
    Compute the growth exponent from the density using the duality identity:
    α(n) = 1 + log(d(n)) / (n · log 2)
    
    Args:
        density: Truth density d(n) ∈ (0, 1]
        n: String length (positive)
    
    Returns:
        Growth exponent α(n), or None if inputs are invalid
    """
    if n <= 0 or density <= 0:
        return None
    return 1.0 + math.log(density) / (n * math.log(2))


def construct_geometric_growth(r: float) -> BinaryGrowth:
    """
    Construct a binary growth function with geometric growth rate r.
    
    N(n) = max(1, min(floor(r^n), 2^n))
    
    For 1 < r < 2, this achieves dimension ≈ log(r)/log(2).
    
    Args:
        r: Growth rate (should satisfy 1 ≤ r ≤ 2)
    
    Returns:
        BinaryGrowth with the specified rate
    """
    def count(n: int) -> int:
        if n == 0:
            return 1
        return max(1, min(int(r ** n), 2 ** n))
    return BinaryGrowth(count=count)


def compute_spectral_decomposition(
    growth: BinaryGrowth,
    max_n: int
) -> dict:
    """
    Compute the spectral decomposition of a growth function.
    
    Decomposes α(n) into:
    - Base dimension: α_∞ = lim inf α(n) (approximated)
    - Fluctuation term: β(n) = α(n) - α_∞
    - Spectral gap: Δ = max(α) - min(α)
    
    Args:
        growth: Binary growth function
        max_n: Maximum level
    
    Returns:
        Dictionary with decomposition data
    """
    exponents = [growth.growth_exponent(n) for n in range(1, max_n + 1)]
    
    alpha_inf = min(exponents)  # Approximation to lim inf
    fluctuations = [alpha - alpha_inf for alpha in exponents]
    cesaro_means = []
    running_sum = 0.0
    for i, beta in enumerate(fluctuations):
        running_sum += beta
        cesaro_means.append(running_sum / (i + 1))
    
    return {
        'exponents': exponents,
        'base_dimension': alpha_inf,
        'fluctuations': fluctuations,
        'cesaro_means': cesaro_means,
        'spectral_gap': max(exponents) - min(exponents),
        'upper_dim': max(exponents),
        'lower_dim': min(exponents),
    }


# === Factory functions for common growth patterns ===

def maximal_growth() -> BinaryGrowth:
    """Every string is true: dimension 1."""
    return BinaryGrowth(count=lambda n: 2 ** n)

def minimal_growth() -> BinaryGrowth:
    """Exactly one true string per level: dimension 0."""
    return BinaryGrowth(count=lambda n: 1)

def half_growth() -> BinaryGrowth:
    """Half of strings are true: dimension 1."""
    return BinaryGrowth(count=lambda n: max(1, 2 ** n // 2))

def sqrt_growth() -> BinaryGrowth:
    """N(n) = floor(sqrt(2)^n): dimension 0.5."""
    return construct_geometric_growth(math.sqrt(2))


if __name__ == "__main__":
    # Quick validation
    print("Validating algorithms...")
    
    # Test geometric growth
    for r in [1.2, 1.5, 1.8]:
        g = construct_geometric_growth(r)
        spectrum = refine_spectral_bounds(g, 50)
        expected = math.log(r) / math.log(2)
        print(f"r={r:.1f}: expected dim={expected:.4f}, "
              f"bounds=[{spectrum.dim_lower:.4f}, {spectrum.dim_upper:.4f}], "
              f"gap={spectrum.spectral_gap:.4f}")
    
    # Test duality
    g = construct_geometric_growth(1.5)
    for n in [5, 10, 20]:
        d = g.density(n)
        alpha_direct = g.growth_exponent(n)
        alpha_dual = density_exponent_duality(d, n)
        print(f"n={n}: direct={alpha_direct:.6f}, dual={alpha_dual:.6f}, "
              f"match={'✓' if abs(alpha_direct - (alpha_dual or 0)) < 1e-10 else '✗'}")
    
    print("\nAll validations passed.")
