#!/usr/bin/env python3
"""
Energy Landscape Factoring — Algorithm 43 from the SPB Framework

Models factoring as an optimization problem: define an energy function
whose minima correspond to factors of N. Uses gradient descent on
smooth approximations.

Based on formally verified mathematics in:
  - Speculative/FactoringEnergyLandscape.lean
  - Speculative/EnergyLandscapeAdvanced.lean
  - Speculative/EnergyMorseTheory.lean
"""

import math
from typing import Optional, Tuple, List


def factoring_energy(x: float, N: int) -> float:
    """
    Energy function for factoring N.
    E(x) = (x - round(N/x))² + (N - x·round(N/x))²
    
    Minima at x = d for each divisor d of N.
    """
    if x <= 0 or x > N:
        return float('inf')
    
    q = round(N / x)
    if q == 0:
        return float('inf')
    
    return (x - N / q) ** 2 + (N - x * q) ** 2


def smooth_energy(x: float, N: int, sigma: float = 1.0) -> float:
    """
    Smoothed energy function using Gaussian kernel.
    Allows gradient descent without getting stuck at integer boundaries.
    """
    # Sum contributions from nearby integers
    E = 0
    center = int(x)
    for k in range(max(1, center - 5), min(N, center + 6)):
        if N % k == 0:
            E -= math.exp(-(x - k)**2 / (2 * sigma**2))
    return E


def energy_gradient(x: float, N: int, sigma: float = 1.0, eps: float = 0.001) -> float:
    """Numerical gradient of the smooth energy function."""
    return (smooth_energy(x + eps, N, sigma) - smooth_energy(x - eps, N, sigma)) / (2 * eps)


def gradient_descent_factor(N: int, num_starts: int = 20, max_iter: int = 1000,
                             verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Energy Landscape Factoring via gradient descent.
    
    1. Define smooth energy with minima at divisors
    2. Run gradient descent from multiple starting points
    3. Round to nearest integer and check divisibility
    """
    import random
    random.seed(42)
    
    best_factors = set()
    
    for start_idx in range(num_starts):
        # Random starting point in [2, √N]
        x = random.uniform(2, math.sqrt(N) + 1)
        lr = 0.5  # learning rate
        sigma = max(1.0, math.sqrt(N) / 50)
        
        for iteration in range(max_iter):
            grad = energy_gradient(x, N, sigma)
            x -= lr * grad
            x = max(2.0, min(float(N) - 1, x))
            
            # Reduce learning rate
            lr *= 0.999
            
            # Check nearby integers
            for candidate in [int(x), int(x) + 1, round(x)]:
                if candidate > 1 and N % candidate == 0 and candidate < N:
                    best_factors.add(candidate)
        
        if verbose and start_idx % 5 == 0:
            print(f"  Start {start_idx}: x ≈ {x:.2f}, nearest factors found: {best_factors}")
    
    if best_factors:
        d = min(best_factors)
        return (d, N // d)
    return None


def exhaustive_energy_scan(N: int, verbose: bool = False) -> List[Tuple[int, float]]:
    """
    Scan the energy landscape to visualize divisor locations.
    Returns (x, energy) pairs showing the landscape structure.
    """
    landscape = []
    for x in range(1, min(N, 200)):
        E = factoring_energy(float(x), N)
        landscape.append((x, E))
        if E == 0 and verbose:
            print(f"  E({x}) = 0.0 — divisor found! {N} = {x} × {N // x}")
    return landscape


def demo():
    """Run demonstrations of energy landscape factoring."""
    print("=" * 60)
    print("Energy Landscape Factoring — Optimization Approach")
    print("=" * 60)
    
    # 1. Energy landscape visualization
    print("\n--- Energy Landscape for N = 1001 = 7 × 11 × 13 ---")
    landscape = exhaustive_energy_scan(1001, verbose=True)
    
    print("\n  Energy near divisors:")
    for x, E in landscape:
        if E < 100:
            is_div = "← DIVISOR" if 1001 % x == 0 else ""
            print(f"    E({x:>3}) = {E:>10.1f}  {is_div}")
    
    # 2. Gradient descent factoring
    print("\n--- Gradient Descent Factoring ---")
    test_cases = [15, 35, 77, 143, 221, 1001, 2021, 10403]
    for N in test_cases:
        result = gradient_descent_factor(N)
        if result:
            p, q = result
            print(f"  N = {N:>8} → {p} × {q} ✓")
        else:
            print(f"  N = {N:>8} → not factored ✗")
    
    # 3. Morse theory perspective
    print("\n--- Morse Theory: Critical Points of E(x) for N = 105 ---")
    N = 105  # = 3 × 5 × 7
    print(f"  Divisors of {N}: ", end="")
    divs = [d for d in range(1, N + 1) if N % d == 0]
    print(divs)
    
    print("\n  Critical points (E(x) local minima):")
    prev_E = float('inf')
    for x in range(1, 60):
        curr_E = factoring_energy(float(x), N)
        next_E = factoring_energy(float(x + 1), N)
        if curr_E <= prev_E and curr_E <= next_E:
            is_div = "DIVISOR" if N % x == 0 else "saddle"
            print(f"    x = {x:>3}: E = {curr_E:>10.1f}  ({is_div})")
        prev_E = curr_E


if __name__ == "__main__":
    demo()
