#!/usr/bin/env python3
"""
Algorithms for zero-free region analysis and prime error estimation.

This module implements the core computational methods underlying the formal
framework:

1. BarrierComputer — evaluates the logarithmic barrier and induced strips
2. PrimeErrorEstimator — computes transfer bounds from zero-free data
3. RVMEstimator — Riemann-von Mangoldt zero counting estimates

All algorithms correspond directly to formally verified theorems.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class LogZeroFreeDatum:
    """
    Computational counterpart of the formal LogZeroFreeDatum structure.
    
    Represents a zero-free region of the form:
        F(s) ≠ 0 for Re(s) > 1 - c / log(|Im(s)| + 2), |Im(s)| ≥ T0
    
    Fields:
        c: Zero-free region constant (positive)
        T0: Height threshold (nonneg)
    """
    c: float
    T0: float = 0.0
    
    def __post_init__(self):
        assert self.c > 0, f"c must be positive, got {self.c}"
        assert self.T0 >= 0, f"T0 must be nonneg, got {self.T0}"


@dataclass 
class PrimeCountingTransferDatum:
    """
    Computational counterpart of PrimeCountingTransferDatum.
    
    Represents the bound |ψ(x) - x| ≤ A · x · exp(-B · √(log x)).
    """
    A: float
    B: float
    
    def __post_init__(self):
        assert self.A > 0, f"A must be positive, got {self.A}"
        assert self.B > 0, f"B must be positive, got {self.B}"


class BarrierComputer:
    """
    Computes properties of the logarithmic zero-free barrier.
    
    The barrier function is:
        b_c(y) = 1 - c / log(y + 2)
    
    Complexity: All operations are O(1) per evaluation.
    
    Example:
        >>> bc = BarrierComputer(c=0.1)
        >>> bc.barrier(100)  # barrier at height 100
        0.9783...
        >>> bc.strip_width(1000)  # width of zero-free strip at height 1000
        0.01447...
    """
    
    def __init__(self, datum: LogZeroFreeDatum):
        self.datum = datum
    
    def barrier(self, y: float) -> float:
        """
        Evaluate the barrier b_c(y) = 1 - c / log(y + 2).
        
        Args:
            y: Height parameter (must be ≥ 0)
        
        Returns:
            The barrier value, always strictly less than 1.
        
        Certified by: barrier_lt_one, log_pos_of_nonneg_add_two
        """
        assert y >= 0, f"y must be nonneg, got {y}"
        return 1.0 - self.datum.c / math.log(y + 2)
    
    def strip_width(self, T: float) -> float:
        """
        Compute the width of the zero-free strip at height T.
        
        Width = c / log(T + 2).
        
        Certified by: zero_free_vertical_strip
        """
        assert T >= 0
        return self.datum.c / math.log(T + 2)
    
    def is_in_zero_free_region(self, sigma: float, t: float) -> bool:
        """
        Check if the point s = σ + it is in the zero-free region.
        
        Args:
            sigma: Real part of s
            t: Imaginary part of s
        
        Returns:
            True if the point is certified zero-free.
        
        Certified by: LogZeroFreeDatum.zero_free
        """
        abs_t = abs(t)
        if abs_t < self.datum.T0:
            return False  # below threshold, no certification
        return sigma > self.barrier(abs_t)
    
    def verify_monotonicity(self, y1: float, y2: float) -> bool:
        """
        Verify barrier monotonicity: y1 ≤ y2 ⟹ b_c(y1) ≤ b_c(y2).
        
        Certified by: log_barrier_mono
        """
        assert 0 <= y1 <= y2
        return self.barrier(y1) <= self.barrier(y2) + 1e-15  # numerical tolerance
    
    def verify_constant_inheritance(self, c_prime: float, y: float) -> bool:
        """
        Verify that a smaller constant gives a smaller barrier:
        c' ≤ c ⟹ b_{c'}(y) ≤ b_c(y).
        
        Certified by: zero_free_of_smaller_constant
        """
        assert 0 < c_prime <= self.datum.c
        assert y >= 0
        b_small = 1.0 - c_prime / math.log(y + 2)
        b_large = self.barrier(y)
        return b_small <= b_large + 1e-15
    
    def tabulate_strips(self, T_values: List[float]) -> List[Tuple[float, float, float]]:
        """
        Tabulate strip parameters for a list of heights.
        
        Returns:
            List of (T, barrier_value, strip_width) tuples.
        """
        results = []
        for T in T_values:
            b = self.barrier(T)
            w = self.strip_width(T)
            results.append((T, b, w))
        return results


class PrimeErrorEstimator:
    """
    Estimates prime counting errors from transfer data.
    
    Given the bound |ψ(x) - x| ≤ A · x · exp(-B · √(log x)),
    computes error bounds and verifies sublinearity.
    
    Complexity: O(1) per evaluation.
    
    Example:
        >>> pe = PrimeErrorEstimator(PrimeCountingTransferDatum(A=1.0, B=1.0))
        >>> pe.error_bound(1e6)  # absolute error bound at x = 10^6
        >>> pe.relative_error(1e6)  # relative error |ψ(x)-x|/x
    """
    
    def __init__(self, datum: PrimeCountingTransferDatum):
        self.datum = datum
    
    def error_bound(self, x: float) -> float:
        """
        Compute the absolute error bound A · x · exp(-B · √(log x)).
        
        Args:
            x: The evaluation point (must be ≥ 2)
        
        Returns:
            Upper bound on |ψ(x) - x|.
        """
        assert x >= 2
        return self.datum.A * x * math.exp(-self.datum.B * math.sqrt(math.log(x)))
    
    def relative_error(self, x: float) -> float:
        """
        Compute the relative error bound A · exp(-B · √(log x)).
        
        Certified by: psiError_small_o_identity (this → 0)
        """
        assert x >= 2
        return self.datum.A * math.exp(-self.datum.B * math.sqrt(math.log(x)))
    
    def verify_sublinearity(self, x_values: List[float]) -> bool:
        """
        Verify that relative error decreases along a sequence.
        
        Certified by: psiError_small_o_identity
        """
        errors = [self.relative_error(x) for x in sorted(x_values) if x >= 2]
        for i in range(len(errors) - 1):
            if errors[i] < errors[i+1] - 1e-15:
                return False
        return True
    
    def find_threshold(self, epsilon: float) -> float:
        """
        Find the smallest x such that the relative error ≤ epsilon.
        
        Uses binary search. Returns approximate threshold.
        """
        assert epsilon > 0
        lo, hi = 2.0, 1e20
        for _ in range(100):
            mid = (lo + hi) / 2
            if self.relative_error(mid) <= epsilon:
                hi = mid
            else:
                lo = mid
        return hi


class RVMEstimator:
    """
    Riemann-von Mangoldt zero counting estimates.
    
    Computes the main term N(T) ~ (T/(2π)) · log(T/(2πe)) and related quantities.
    
    Complexity: O(1) per evaluation.
    """
    
    @staticmethod
    def main_term(T: float) -> float:
        """Compute (T/(2π)) · log(T/(2πe))."""
        if T <= 0:
            return 0.0
        two_pi = 2 * math.pi
        return (T / two_pi) * math.log(T / (two_pi * math.e))
    
    @staticmethod 
    def growth_ratio(T: float) -> float:
        """Compute N(T) / (T · log T) — should approach 1/(2π)."""
        if T <= 1:
            return 0.0
        return RVMEstimator.main_term(T) / (T * math.log(T))
    
    @staticmethod
    def density_per_unit_height(T: float) -> float:
        """
        Approximate density of zeros per unit height at height T.
        
        d/dT [N(T)] ≈ (1/(2π)) · log(T/(2π))
        """
        if T <= 0:
            return 0.0
        return math.log(T / (2 * math.pi)) / (2 * math.pi)


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Zero-Free Region Algorithms — Examples")
    print("=" * 60)
    
    # Barrier computation
    datum = LogZeroFreeDatum(c=0.1)
    bc = BarrierComputer(datum)
    
    print("\n--- Barrier Computer ---")
    print(f"Barrier at height 100:   b(100) = {bc.barrier(100):.6f}")
    print(f"Barrier at height 1000:  b(1000) = {bc.barrier(1000):.6f}")
    print(f"Barrier at height 10000: b(10000) = {bc.barrier(10000):.6f}")
    print(f"Strip width at T=1000:   w = {bc.strip_width(1000):.6f}")
    
    print("\nStrip tabulation:")
    strips = bc.tabulate_strips([10, 100, 1e3, 1e4, 1e5, 1e6])
    print(f"{'T':>12s} {'Barrier':>12s} {'Width':>12s}")
    for T, b, w in strips:
        print(f"{T:12.0f} {b:12.8f} {w:12.8f}")
    
    # Monotonicity verification
    print(f"\nMonotonicity (100 → 1000): {bc.verify_monotonicity(100, 1000)}")
    print(f"Constant inheritance (0.05 ≤ 0.1 at y=500): {bc.verify_constant_inheritance(0.05, 500)}")
    
    # Prime error estimation
    print("\n--- Prime Error Estimator ---")
    pe = PrimeErrorEstimator(PrimeCountingTransferDatum(A=1.0, B=1.0))
    
    for x in [1e3, 1e6, 1e9, 1e12, 1e15]:
        print(f"x = {x:.0e}: absolute bound = {pe.error_bound(x):.4e}, "
              f"relative = {pe.relative_error(x):.6e}")
    
    print(f"\nSublinearity verified: {pe.verify_sublinearity([1e3, 1e6, 1e9, 1e12])}")
    
    # RVM estimates
    print("\n--- Riemann-von Mangoldt Estimates ---")
    rvm = RVMEstimator()
    for T in [100, 1000, 1e4, 1e5, 1e6]:
        print(f"T = {T:.0e}: N(T) ≈ {rvm.main_term(T):.1f}, "
              f"ratio = {rvm.growth_ratio(T):.6f}, "
              f"density = {rvm.density_per_unit_height(T):.4f}")
    
    print(f"\n1/(2π) = {1/(2*math.pi):.6f} (limiting ratio)")
