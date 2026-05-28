#!/usr/bin/env python3
"""
Tropical Lorentzian Geometry of Tensor Networks: Algorithms

Implements the core algorithms from the research paper:
1. Tropical minimizer computation
2. Tropical hypersurface witness detection
3. Tropical gap estimation
4. Bond dimension compatibility checking
5. Exchange property verification
6. Tropical hypersurface scanning

All algorithms include docstrings, type hints, and example usage.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set, FrozenSet
from itertools import product as cartesian_product
from dataclasses import dataclass


# ============================================================
# Data Types
# ============================================================

ExponentVector = Tuple[int, ...]

@dataclass
class BoundaryMeasurementData:
    """Boundary measurement data with n boundary legs.
    
    Attributes:
        n: dimension (number of boundary legs)
        support: list of exponent vectors in the support
        coeff: coefficient map from exponent vectors to reals
    """
    n: int
    support: List[ExponentVector]
    coeff: Dict[ExponentVector, float]
    
    def __post_init__(self):
        assert len(self.support) > 0, "Support must be nonempty"
        assert all(len(m) == self.n for m in self.support), "All vectors must have length n"


@dataclass
class TropicalHypersurfaceWitness:
    """Witness that a point lies on the tropical hypersurface.
    
    Attributes:
        x: the evaluation point
        m1, m2: two distinct minimizers with equal weight
        weight: the common minimum weight
    """
    x: np.ndarray
    m1: ExponentVector
    m2: ExponentVector
    weight: float


# ============================================================
# Algorithm 1: Tropical Minimizer Computation
# ============================================================

def weight_eval(coeff: Dict[ExponentVector, float], 
                x: np.ndarray, m: ExponentVector) -> float:
    """Tropical affine evaluation: c(m) + Σᵢ m(i)·x(i).
    
    Args:
        coeff: coefficient map
        x: evaluation point in R^n
        m: exponent vector
    
    Returns:
        The tropical weight c(m) + m·x
        
    Example:
        >>> weight_eval({(1, 2): 3.0}, np.array([1.0, -1.0]), (1, 2))
        2.0
    """
    return coeff.get(m, 0.0) + sum(m[i] * x[i] for i in range(len(m)))


def find_minimizer(D: BoundaryMeasurementData, 
                   x: np.ndarray) -> Tuple[ExponentVector, float]:
    """Find the monomial achieving minimum tropical weight at x.
    
    Implements Algorithm 1 from the paper.
    Complexity: O(|S| · n) time, O(n) space.
    
    Args:
        D: boundary measurement data
        x: evaluation point
    
    Returns:
        (minimizer, minimum_value) pair
    
    Example:
        >>> D = BoundaryMeasurementData(2, [(0,0), (1,0)], {(0,0): 0.0, (1,0): 1.0})
        >>> find_minimizer(D, np.array([0.0, 0.0]))
        ((0, 0), 0.0)
    """
    best_m = D.support[0]
    best_val = weight_eval(D.coeff, x, best_m)
    for m in D.support[1:]:
        val = weight_eval(D.coeff, x, m)
        if val < best_val:
            best_m, best_val = m, val
    return best_m, best_val


# ============================================================
# Algorithm 2: Tropical Hypersurface Witness Detection
# ============================================================

def find_competing_sectors(
    D: BoundaryMeasurementData, 
    x: np.ndarray, 
    tol: float = 1e-10
) -> Optional[TropicalHypersurfaceWitness]:
    """Find two competing minimizers at x (tropical hypersurface witness).
    
    Implements Algorithm 2 from the paper.
    Complexity: O(|S| · n) time, O(|S|) space.
    
    Args:
        D: boundary measurement data
        x: evaluation point
        tol: tolerance for weight equality
    
    Returns:
        TropicalHypersurfaceWitness if x is on the hypersurface, None otherwise
    
    Example:
        >>> D = BoundaryMeasurementData(1, [(0,), (1,)], {(0,): 0.0, (1,): 1.0})
        >>> w = find_competing_sectors(D, np.array([-1.0]))
        >>> w is not None  # x=-1 is on the hypersurface
        True
    """
    weights = [(m, weight_eval(D.coeff, x, m)) for m in D.support]
    min_val = min(w for _, w in weights)
    minimizers = [m for m, w in weights if abs(w - min_val) < tol]
    
    if len(minimizers) >= 2:
        return TropicalHypersurfaceWitness(
            x=x, m1=minimizers[0], m2=minimizers[1], weight=min_val
        )
    return None


# ============================================================
# Algorithm 3: Tropical Gap Estimation
# ============================================================

def estimate_local_tropical_gap(
    D: BoundaryMeasurementData, x: np.ndarray
) -> float:
    """Estimate the local tropical gap at x.
    
    Returns the difference between the 2nd smallest and smallest weight.
    Complexity: O(|S| · (n + log|S|)) time.
    
    Args:
        D: boundary measurement data
        x: evaluation point
    
    Returns:
        gap ≥ 0 (infinity if |S| ≤ 1)
    """
    if len(D.support) <= 1:
        return float('inf')
    weights = sorted(weight_eval(D.coeff, x, m) for m in D.support)
    return weights[1] - weights[0]


def estimate_global_tropical_gap(
    D: BoundaryMeasurementData, 
    num_samples: int = 10000,
    scale: float = 3.0,
    seed: Optional[int] = None
) -> float:
    """Estimate the global tropical gap by sampling.
    
    Samples random points and returns the minimum local gap found.
    
    Args:
        D: boundary measurement data
        num_samples: number of random points to sample
        scale: standard deviation of sampling distribution
        seed: random seed for reproducibility
    
    Returns:
        estimated lower bound on the global tropical gap
    """
    if seed is not None:
        np.random.seed(seed)
    
    min_gap = float('inf')
    for _ in range(num_samples):
        x = np.random.randn(D.n) * scale
        gap = estimate_local_tropical_gap(D, x)
        min_gap = min(min_gap, gap)
    return min_gap


# ============================================================
# Algorithm 4: Bond Dimension Compatibility
# ============================================================

def check_bond_dim_compatibility(
    D: BoundaryMeasurementData, chi: int
) -> bool:
    """Check if D is bond-dimension compatible with χ.
    
    Verifies that all support vectors have components < χ.
    Complexity: O(|S| · n) time.
    
    Args:
        D: boundary measurement data
        chi: bond dimension
    
    Returns:
        True if compatible
    """
    return all(m[i] < chi for m in D.support for i in range(D.n))


def support_cardinality_bound(n: int, chi: int) -> int:
    """Compute the theoretical upper bound χ^n on support cardinality.
    
    By Theorem 8, if D is bond-dim compatible with χ, then |S| ≤ χ^n.
    
    Args:
        n: number of boundary legs
        chi: bond dimension
    
    Returns:
        χ^n
    """
    return chi ** n


# ============================================================
# Algorithm 5: Exchange Property Verification
# ============================================================

def check_exchange_property(
    support: List[ExponentVector]
) -> Tuple[bool, Optional[Tuple[ExponentVector, ExponentVector, int]]]:
    """Check the symmetric exchange property on support.
    
    For m1, m2 in S and i with m1[i] > m2[i], checks whether
    ∃ j with m1[j] < m2[j] s.t. m1 - eᵢ + eⱼ ∈ S.
    
    Args:
        support: list of exponent vectors
    
    Returns:
        (True, None) if exchange holds
        (False, (m1, m2, i)) if counterexample found
    """
    support_set = set(support)
    for m1 in support:
        for m2 in support:
            if m1 == m2:
                continue
            n = len(m1)
            for i in range(n):
                if m1[i] > m2[i]:
                    found = False
                    for j in range(n):
                        if m1[j] < m2[j]:
                            exchanged = list(m1)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in support_set:
                                found = True
                                break
                    if not found:
                        return False, (m1, m2, i)
    return True, None


# ============================================================
# Algorithm 6: Tropical Hypersurface Scanning
# ============================================================

def scan_hypersurface(
    D: BoundaryMeasurementData,
    num_samples: int = 10000,
    scale: float = 3.0,
    tol: float = 1e-8,
    seed: Optional[int] = None
) -> List[TropicalHypersurfaceWitness]:
    """Scan for tropical hypersurface points by sampling.
    
    Args:
        D: boundary measurement data
        num_samples: number of points to sample
        scale: sampling scale
        tol: tolerance for detecting ties
        seed: random seed
    
    Returns:
        list of hypersurface witnesses found
    """
    if seed is not None:
        np.random.seed(seed)
    
    witnesses = []
    for _ in range(num_samples):
        x = np.random.randn(D.n) * scale
        w = find_competing_sectors(D, x, tol=tol)
        if w is not None:
            witnesses.append(w)
    return witnesses


def find_exact_hypersurface_1d(
    D: BoundaryMeasurementData
) -> List[TropicalHypersurfaceWitness]:
    """For 1D data (n=1), find exact hypersurface points analytically.
    
    Two monomials (a,) and (b,) with a ≠ b tie when:
    c(a) + a·x = c(b) + b·x  →  x = (c(a) - c(b)) / (b - a)
    
    Then check if this x gives a global minimum.
    
    Args:
        D: 1D boundary measurement data
    
    Returns:
        list of exact hypersurface witnesses
    """
    assert D.n == 1, "Only for 1D data"
    witnesses = []
    
    for i, m1 in enumerate(D.support):
        for m2 in D.support[i+1:]:
            a, b = m1[0], m2[0]
            ca, cb = D.coeff[m1], D.coeff[m2]
            if a == b:
                continue  # parallel affine functions
            x_cross = (ca - cb) / (b - a)
            x = np.array([x_cross])
            
            # Check if both are minimal at this x
            val = weight_eval(D.coeff, x, m1)
            is_minimal = all(
                val <= weight_eval(D.coeff, x, m) + 1e-12
                for m in D.support
            )
            if is_minimal:
                witnesses.append(TropicalHypersurfaceWitness(
                    x=x, m1=m1, m2=m2, weight=val
                ))
    
    return witnesses


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Tensor Network Algorithms — Example Usage")
    print("=" * 55)
    
    # Create example data
    D = BoundaryMeasurementData(
        n=2,
        support=[(0,0), (1,0), (0,1), (1,1)],
        coeff={(0,0): 0.0, (1,0): 1.0, (0,1): 0.5, (1,1): 2.0}
    )
    
    # Algorithm 1: Find minimizer
    x = np.array([0.0, 0.0])
    m, val = find_minimizer(D, x)
    print(f"\nMinimizer at x={x}: m={m}, val={val:.3f}")
    
    # Algorithm 2: Find competing sectors
    w = find_competing_sectors(D, np.array([-1.0, 0.0]))
    print(f"Competing sectors at x=[-1,0]: {w}")
    
    # Algorithm 3: Estimate gap
    gap = estimate_global_tropical_gap(D, seed=42)
    print(f"Estimated global tropical gap: {gap:.6f}")
    
    # Algorithm 4: Bond dim compatibility
    print(f"Bond-dim compatible with χ=2: {check_bond_dim_compatibility(D, 2)}")
    print(f"Bond-dim compatible with χ=3: {check_bond_dim_compatibility(D, 3)}")
    print(f"Support bound (n=2, χ=2): {support_cardinality_bound(2, 2)}")
    
    # Algorithm 5: Exchange property
    has_exchange, counterex = check_exchange_property(D.support)
    print(f"Exchange property: {has_exchange}")
    
    # Algorithm 6: Scan hypersurface
    witnesses = scan_hypersurface(D, num_samples=5000, seed=42)
    print(f"Hypersurface witnesses found: {len(witnesses)}")
    
    # 1D exact analysis
    D1 = BoundaryMeasurementData(1, [(0,), (1,), (2,)],
                                  {(0,): 0.0, (1,): 1.0, (2,): 3.0})
    exact = find_exact_hypersurface_1d(D1)
    print(f"\n1D exact hypersurface points: {len(exact)}")
    for w in exact:
        print(f"  x={w.x[0]:.4f}: {w.m1} vs {w.m2}, weight={w.weight:.4f}")
