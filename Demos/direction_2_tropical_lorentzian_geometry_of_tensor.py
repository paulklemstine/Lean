#!/usr/bin/env python3
"""
Tropical Lorentzian Geometry of Tensor Networks: Applications

Real-world applications of the tropical tensor network theory:
1. Entanglement complexity diagnosis for quantum states
2. Tensor network bond dimension estimation
3. Tropical phase boundary detection
4. Quantum error correction distance bounds
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from itertools import product as cartesian_product
import random


# ============================================================
# Inline Core Functions (self-contained)
# ============================================================

def weight_eval(coeff, x, m):
    """Tropical affine evaluation: c(m) + Σᵢ m(i)·x(i)."""
    return coeff.get(m, 0.0) + sum(m[i] * x[i] for i in range(len(m)))

def find_all_minimizers(support, coeff, x, tol=1e-10):
    """Find all minimizers at x."""
    weights = {m: weight_eval(coeff, x, m) for m in support}
    min_val = min(weights.values())
    return [m for m, w in weights.items() if abs(w - min_val) < tol], min_val

def local_gap(support, coeff, x):
    """Local tropical gap at x."""
    if len(support) <= 1:
        return float('inf')
    weights = sorted(weight_eval(coeff, x, m) for m in support)
    return weights[1] - weights[0]


# ============================================================
# Application 1: Entanglement Complexity Diagnosis
# ============================================================

def diagnose_entanglement_complexity(
    n: int, support: List[Tuple[int, ...]], 
    coeff: Dict[Tuple[int, ...], float],
    num_samples: int = 5000
) -> Dict:
    """Diagnose entanglement complexity using tropical geometry.
    
    Analyzes the boundary measurement data to extract:
    - Support cardinality (number of admissible boundary configurations)
    - Tropical gap statistics
    - Hypersurface density (fraction of parameter space near the hypersurface)
    - Estimated bond dimension requirement
    
    Args:
        n: number of boundary legs
        support: exponent vectors
        coeff: coefficient map
        num_samples: sampling density
    
    Returns:
        Dictionary with diagnostic information
    """
    np.random.seed(42)
    
    # Basic statistics
    max_component = max(max(m) for m in support) + 1
    
    # Sample tropical gaps
    gaps = []
    hypersurface_count = 0
    for _ in range(num_samples):
        x = np.random.randn(n) * 3.0
        g = local_gap(support, coeff, x)
        gaps.append(g)
        if g < 1e-8:
            hypersurface_count += 1
    
    min_gap = min(gaps)
    avg_gap = np.mean(gaps)
    hypersurface_density = hypersurface_count / num_samples
    
    # Estimate minimum bond dimension
    est_bond_dim = max_component
    while est_bond_dim ** n < len(support):
        est_bond_dim += 1
    
    return {
        "n_boundary": n,
        "support_size": len(support),
        "max_component": max_component,
        "min_tropical_gap": min_gap,
        "avg_tropical_gap": avg_gap,
        "hypersurface_density": hypersurface_density,
        "estimated_min_bond_dim": est_bond_dim,
        "theoretical_bound": f"|S| ≤ χ^n = {est_bond_dim}^{n} = {est_bond_dim**n}",
    }


# ============================================================
# Application 2: Bond Dimension Estimation
# ============================================================

def estimate_required_bond_dimension(
    n: int, support: List[Tuple[int, ...]]
) -> Dict:
    """Estimate the minimum bond dimension from support data.
    
    Uses the theorem |S| ≤ χ^n to derive χ ≥ |S|^{1/n}.
    
    Args:
        n: number of boundary legs
        support: exponent vectors
    
    Returns:
        Dictionary with bond dimension estimates
    """
    S = len(support)
    
    # Lower bound from support cardinality
    lower_from_card = int(np.ceil(S ** (1.0 / n))) if n > 0 else S
    
    # Lower bound from max component
    max_comp = max(max(m) for m in support) + 1
    
    # Combined lower bound
    combined_lower = max(lower_from_card, max_comp)
    
    return {
        "support_size": S,
        "n_boundary": n,
        "lower_from_cardinality": lower_from_card,
        "lower_from_max_component": max_comp,
        "combined_lower_bound": combined_lower,
        "analysis": (f"Any tensor network representing this data needs "
                    f"bond dimension χ ≥ {combined_lower}")
    }


# ============================================================
# Application 3: Phase Boundary Detection
# ============================================================

def detect_tropical_phase_boundaries(
    n: int, support: List[Tuple[int, ...]], 
    coeff: Dict[Tuple[int, ...], float],
    grid_size: int = 50
) -> Dict:
    """Detect phase boundaries via tropical hypersurface scanning.
    
    For 2D parameter spaces, creates a grid and identifies
    transitions between dominant sectors.
    
    Args:
        n: dimension (should be 2 for visualization)
        support: exponent vectors
        coeff: coefficient map
        grid_size: number of grid points per dimension
    
    Returns:
        Dictionary with phase boundary information
    """
    assert n >= 2, "Need at least 2 dimensions"
    
    # Scan a 2D slice (first two coordinates, others = 0)
    x_range = np.linspace(-3, 3, grid_size)
    y_range = np.linspace(-3, 3, grid_size)
    
    phase_map = np.zeros((grid_size, grid_size), dtype=int)
    gap_map = np.zeros((grid_size, grid_size))
    boundary_points = []
    
    for i, xi in enumerate(x_range):
        for j, yj in enumerate(y_range):
            x = np.zeros(n)
            x[0], x[1] = xi, yj
            
            minimizers, min_val = find_all_minimizers(support, coeff, x)
            gap_map[i, j] = local_gap(support, coeff, x)
            
            # Assign phase by hashing the minimizer
            phase_map[i, j] = hash(minimizers[0]) % 1000
            
            if len(minimizers) >= 2:
                boundary_points.append((xi, yj))
    
    # Count distinct phases
    unique_phases = len(set(phase_map.flatten()))
    
    return {
        "grid_size": grid_size,
        "n_boundary_points": len(boundary_points),
        "n_distinct_phases": unique_phases,
        "min_gap": gap_map.min(),
        "max_gap": gap_map.max(),
        "avg_gap": gap_map.mean(),
        "boundary_fraction": len(boundary_points) / (grid_size * grid_size),
        "boundary_points_sample": boundary_points[:10],
    }


# ============================================================
# Application 4: Quantum Code Distance Estimation
# ============================================================

def estimate_code_distance_from_tropical_gap(
    n: int, support: List[Tuple[int, ...]], 
    coeff: Dict[Tuple[int, ...], float],
    num_samples: int = 10000
) -> Dict:
    """Estimate quantum code distance using tropical gap.
    
    Uses the conjecture that tropical gap ≥ c·log(d) where d is code distance.
    
    Args:
        n: number of physical qubits
        support: syndrome support
        coeff: coefficient map
        num_samples: sampling density
    
    Returns:
        Dictionary with distance estimates
    """
    np.random.seed(42)
    
    # Estimate global gap
    min_gap = float('inf')
    for _ in range(num_samples):
        x = np.random.randn(n) * 5.0
        g = local_gap(support, coeff, x)
        min_gap = min(min_gap, g)
    
    # Conjecture: gap ≥ c·log(d), so d ≤ exp(gap/c)
    # Use conservative c = 1
    if min_gap > 0 and min_gap < float('inf'):
        estimated_distance = int(np.exp(min_gap))
    else:
        estimated_distance = 1
    
    return {
        "n_qubits": n,
        "support_size": len(support),
        "estimated_tropical_gap": min_gap,
        "estimated_code_distance_upper": estimated_distance,
        "note": "Based on Conjecture A (logarithmic scaling)"
    }


# ============================================================
# Demo: All Applications
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Tensor Network Theory: Applications          ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Create example data
    n = 3
    chi = 2
    support = [(0,0,0), (1,0,0), (0,1,0), (0,0,1), (1,1,0), (1,0,1)]
    coeff = {m: np.random.uniform(0.1, 2.0) for m in support}
    
    # Application 1: Entanglement complexity
    print("\n" + "=" * 55)
    print("APPLICATION 1: Entanglement Complexity Diagnosis")
    print("=" * 55)
    result = diagnose_entanglement_complexity(n, support, coeff)
    for k, v in result.items():
        print(f"  {k}: {v}")
    
    # Application 2: Bond dimension estimation
    print("\n" + "=" * 55)
    print("APPLICATION 2: Bond Dimension Estimation")
    print("=" * 55)
    result = estimate_required_bond_dimension(n, support)
    for k, v in result.items():
        print(f"  {k}: {v}")
    
    # Application 3: Phase boundaries (2D example)
    print("\n" + "=" * 55)
    print("APPLICATION 3: Phase Boundary Detection")
    print("=" * 55)
    support_2d = [(0,0), (1,0), (0,1), (1,1), (2,0), (0,2)]
    coeff_2d = {m: np.random.uniform(0.1, 2.0) for m in support_2d}
    result = detect_tropical_phase_boundaries(2, support_2d, coeff_2d, grid_size=30)
    for k, v in result.items():
        print(f"  {k}: {v}")
    
    # Application 4: Code distance
    print("\n" + "=" * 55)
    print("APPLICATION 4: Quantum Code Distance Estimation")
    print("=" * 55)
    # Simple repetition code-like support
    n_code = 5
    support_code = [(1,0,0,0,0), (0,1,0,0,0), (0,0,1,0,0), 
                    (0,0,0,1,0), (0,0,0,0,1), (1,1,0,0,0)]
    coeff_code = {m: 1.0 for m in support_code}
    result = estimate_code_distance_from_tropical_gap(n_code, support_code, coeff_code)
    for k, v in result.items():
        print(f"  {k}: {v}")
    
    print("\n" + "=" * 55)
    print("All applications completed.")
    print("=" * 55)


#!/usr/bin/env python3
"""
Tropical Lorentzian Geometry of Tensor Network Boundary States: Demo

Demonstrates the core mathematical concepts:
1. Constructing boundary measurement data for small tensor networks
2. Computing tropical evaluations and finding minimizers
3. Detecting tropical hypersurface points (competing boundary sectors)
4. Testing the bond-dimension support bound
5. Testing the conjectured relation between tropical gap and bond dimension
6. Searching for counterexamples to the exchange property conjecture
"""

import numpy as np
from itertools import product as cartesian_product
from typing import List, Tuple, Optional, Dict, Set
import random


# ============================================================
# Core Data Structures
# ============================================================

class BoundaryMeasurementData:
    """Boundary measurement data: finitely supported polynomial with real coefficients.
    
    Attributes:
        n: number of boundary legs
        support: list of exponent vectors (tuples of ints)
        coeff: dictionary mapping exponent vectors to real coefficients
    """
    def __init__(self, n: int, support: List[Tuple[int, ...]], 
                 coeff: Dict[Tuple[int, ...], float]):
        self.n = n
        self.support = list(set(support))
        self.coeff = {m: coeff.get(m, 0.0) for m in self.support}
        assert len(self.support) > 0, "Support must be nonempty"
    
    def __repr__(self):
        return f"BoundaryMeasurementData(n={self.n}, |support|={len(self.support)})"


class FiniteTensorNetwork:
    """A finite tensor network with boundary/internal structure."""
    def __init__(self, num_boundary: int, num_internal: int, bond_dim: int):
        assert bond_dim > 0
        self.num_boundary = num_boundary
        self.num_internal = num_internal
        self.bond_dim = bond_dim
    
    def __repr__(self):
        return (f"FiniteTensorNetwork(nB={self.num_boundary}, "
                f"nI={self.num_internal}, χ={self.bond_dim})")


# ============================================================
# Core Algorithms
# ============================================================

def weight_eval(coeff: Dict[Tuple[int, ...], float], 
                x: np.ndarray, m: Tuple[int, ...]) -> float:
    """Tropical affine evaluation: c(m) + Σᵢ m(i)·x(i)"""
    return coeff.get(m, 0.0) + sum(m[i] * x[i] for i in range(len(m)))


def find_minimizer(D: BoundaryMeasurementData, 
                   x: np.ndarray) -> Tuple[Tuple[int, ...], float]:
    """Find the monomial achieving minimum tropical weight at x."""
    best_m = D.support[0]
    best_val = weight_eval(D.coeff, x, best_m)
    for m in D.support[1:]:
        val = weight_eval(D.coeff, x, m)
        if val < best_val:
            best_m, best_val = m, val
    return best_m, best_val


def find_competing_sectors(D: BoundaryMeasurementData, 
                           x: np.ndarray, 
                           tol: float = 1e-10
                           ) -> Optional[Tuple[Tuple[int,...], Tuple[int,...]]]:
    """Find two competing minimizers at x, or None if unique minimizer."""
    weights = [(m, weight_eval(D.coeff, x, m)) for m in D.support]
    weights.sort(key=lambda p: p[1])
    min_val = weights[0][1]
    minimizers = [m for m, w in weights if abs(w - min_val) < tol]
    if len(minimizers) >= 2:
        return (minimizers[0], minimizers[1])
    return None


def estimate_tropical_gap(D: BoundaryMeasurementData, 
                          x: np.ndarray) -> float:
    """Estimate the local tropical gap at x (2nd smallest - smallest weight)."""
    if len(D.support) <= 1:
        return float('inf')
    weights = sorted(weight_eval(D.coeff, x, m) for m in D.support)
    return weights[1] - weights[0]


def is_bond_dim_compatible(D: BoundaryMeasurementData, chi: int) -> bool:
    """Check if all support vectors have components < chi."""
    return all(m[i] < chi for m in D.support for i in range(D.n))


def check_exchange_property(support: List[Tuple[int, ...]]) -> bool:
    """Check symmetric exchange property on support.
    For m1, m2 in S and i with m1[i] > m2[i], 
    ∃ j with m1[j] < m2[j] s.t. m1 - e_i + e_j ∈ S.
    """
    support_set = set(support)
    for m1 in support:
        for m2 in support:
            if m1 == m2:
                continue
            for i in range(len(m1)):
                if m1[i] > m2[i]:
                    found = False
                    for j in range(len(m1)):
                        if m1[j] < m2[j]:
                            exchanged = list(m1)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in support_set:
                                found = True
                                break
                    if not found:
                        return False
    return True


# ============================================================
# Tensor Network Examples
# ============================================================

def make_triangle_network(chi: int = 2) -> Tuple[FiniteTensorNetwork, BoundaryMeasurementData]:
    """Create a triangle tensor network with 3 boundary legs."""
    T = FiniteTensorNetwork(num_boundary=3, num_internal=3, bond_dim=chi)
    # Generate support: all binary vectors of length 3 with even parity
    support = []
    for m in cartesian_product(range(chi), repeat=3):
        if sum(m) % 2 == 0:  # parity constraint from network structure
            support.append(m)
    coeff = {m: random.uniform(0.1, 2.0) for m in support}
    D = BoundaryMeasurementData(n=3, support=support, coeff=coeff)
    return T, D


def make_chain_network(length: int = 3, chi: int = 2
                       ) -> Tuple[FiniteTensorNetwork, BoundaryMeasurementData]:
    """Create a chain (MPS-like) tensor network."""
    T = FiniteTensorNetwork(num_boundary=length, num_internal=length-1, bond_dim=chi)
    # Support: vectors where adjacent entries differ by at most 1
    support = []
    for m in cartesian_product(range(chi), repeat=length):
        if all(abs(m[i] - m[i+1]) <= 1 for i in range(length-1)):
            support.append(m)
    if not support:
        support = [tuple(0 for _ in range(length))]
    coeff = {m: random.uniform(0.1, 2.0) for m in support}
    D = BoundaryMeasurementData(n=length, support=support, coeff=coeff)
    return T, D


def make_rectangular_network(rows: int = 2, cols: int = 3, chi: int = 2
                             ) -> Tuple[FiniteTensorNetwork, BoundaryMeasurementData]:
    """Create a rectangular PEPS-like tensor network."""
    n_boundary = 2 * (rows + cols)  # perimeter sites
    T = FiniteTensorNetwork(num_boundary=n_boundary, 
                           num_internal=rows*cols, bond_dim=chi)
    # Support: random subset of bounded vectors (simulating contraction)
    all_vecs = list(cartesian_product(range(chi), repeat=min(n_boundary, 4)))
    # Pad to full dimension
    padded = []
    for v in all_vecs:
        if len(v) < n_boundary:
            padded.append(v + (0,) * (n_boundary - len(v)))
        else:
            padded.append(v[:n_boundary])
    # Keep a fraction to simulate network constraints
    support = random.sample(padded, min(len(padded), chi**3))
    if not support:
        support = [tuple(0 for _ in range(n_boundary))]
    coeff = {m: random.uniform(0.1, 2.0) for m in support}
    D = BoundaryMeasurementData(n=n_boundary, support=support, coeff=coeff)
    return T, D


# ============================================================
# Demo Functions
# ============================================================

def demo_basic_operations():
    """Demonstrate basic tropical operations."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Operations")
    print("=" * 60)
    
    # Simple 2-boundary-leg example
    support = [(0, 0), (1, 0), (0, 1), (1, 1)]
    coeff = {(0,0): 0.0, (1,0): 1.0, (0,1): 0.5, (1,1): 2.0}
    D = BoundaryMeasurementData(n=2, support=support, coeff=coeff)
    print(f"\nBoundary measurement data: {D}")
    print(f"Support: {D.support}")
    print(f"Coefficients: {D.coeff}")
    
    # Evaluate at different points
    test_points = [np.array([0.0, 0.0]), np.array([1.0, -1.0]), 
                   np.array([-0.5, -0.5])]
    for x in test_points:
        print(f"\n  x = {x}")
        for m in D.support:
            w = weight_eval(D.coeff, x, m)
            print(f"    weightEval({m}) = {w:.3f}")
        best_m, best_val = find_minimizer(D, x)
        print(f"    → Minimizer: {best_m} with value {best_val:.3f}")
        
        competing = find_competing_sectors(D, x)
        if competing:
            print(f"    → TROPICAL HYPERSURFACE POINT! Competing: {competing}")
        else:
            gap = estimate_tropical_gap(D, x)
            print(f"    → Unique minimizer. Gap = {gap:.3f}")


def demo_hypersurface_detection():
    """Demonstrate tropical hypersurface detection."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Hypersurface Detection")
    print("=" * 60)
    
    # Create data where we know the hypersurface
    # Two monomials: (0,) with coeff 0, (1,) with coeff 1
    # weightEval at x: 0 + 0*x = 0 vs 1 + 1*x
    # They tie when 0 = 1 + x, i.e., x = -1
    D = BoundaryMeasurementData(n=1, support=[(0,), (1,)],
                                coeff={(0,): 0.0, (1,): 1.0})
    
    print(f"\n1D example: monomials (0) and (1), coeffs 0 and 1")
    print(f"Expected hypersurface point: x = -1")
    
    for x_val in [-2.0, -1.5, -1.0, -0.5, 0.0]:
        x = np.array([x_val])
        competing = find_competing_sectors(D, x)
        gap = estimate_tropical_gap(D, x)
        status = "HYPERSURFACE" if competing else "regular"
        print(f"  x = {x_val:5.1f}: gap = {gap:.3f}  [{status}]")


def demo_bond_dimension_bound():
    """Demonstrate the bond dimension support bound."""
    print("\n" + "=" * 60)
    print("DEMO 3: Bond Dimension Bounds Support Cardinality")
    print("=" * 60)
    
    for chi in [2, 3, 4]:
        for n in [2, 3, 4]:
            T, D = make_chain_network(length=n, chi=chi)
            bound = chi ** n
            compatible = is_bond_dim_compatible(D, chi)
            print(f"  Chain(n={n}, χ={chi}): |S| = {len(D.support)}, "
                  f"χ^n = {bound}, compatible = {compatible}, "
                  f"|S| ≤ χ^n: {len(D.support) <= bound}")


def demo_tropical_gap_vs_bond_dim():
    """Test the conjectured relation between tropical gap and bond dimension."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Gap vs. Bond Dimension")
    print("=" * 60)
    
    random.seed(42)
    print(f"\n{'χ':>4} {'|S|':>6} {'Min Gap':>10} {'Avg Gap':>10} {'log(χ+1)':>10} {'Ratio':>8}")
    print("-" * 52)
    
    for chi in [2, 3, 4, 5, 6]:
        T, D = make_chain_network(length=3, chi=chi)
        
        # Sample many points and compute gaps
        gaps = []
        for _ in range(1000):
            x = np.random.randn(D.n) * 2
            gap = estimate_tropical_gap(D, x)
            if gap < float('inf'):
                gaps.append(gap)
        
        if gaps:
            min_gap = min(gaps)
            avg_gap = np.mean(gaps)
            log_chi = np.log(chi + 1)
            ratio = avg_gap / log_chi if log_chi > 0 else float('inf')
            print(f"{chi:4d} {len(D.support):6d} {min_gap:10.4f} "
                  f"{avg_gap:10.4f} {log_chi:10.4f} {ratio:8.4f}")


def demo_exchange_property():
    """Test the exchange property conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 5: Exchange Property Testing")
    print("=" * 60)
    
    random.seed(123)
    
    # Test on various network types
    configs = [
        ("Triangle χ=2", lambda: make_triangle_network(chi=2)),
        ("Triangle χ=3", lambda: make_triangle_network(chi=3)),
        ("Chain(3) χ=2", lambda: make_chain_network(3, chi=2)),
        ("Chain(4) χ=2", lambda: make_chain_network(4, chi=2)),
        ("Chain(3) χ=3", lambda: make_chain_network(3, chi=3)),
    ]
    
    for name, factory in configs:
        T, D = factory()
        has_exchange = check_exchange_property(D.support)
        print(f"  {name:20s}: |S| = {len(D.support):3d}, "
              f"exchange = {'✓' if has_exchange else '✗'}")


def demo_singleton_no_hypersurface():
    """Demonstrate that singleton support has no hypersurface points."""
    print("\n" + "=" * 60)
    print("DEMO 6: Singleton Support — No Hypersurface")
    print("=" * 60)
    
    D = BoundaryMeasurementData(n=3, support=[(1, 2, 3)],
                                coeff={(1, 2, 3): 1.5})
    print(f"  Singleton support: {D.support}")
    
    found_hypersurface = False
    for _ in range(10000):
        x = np.random.randn(3) * 10
        competing = find_competing_sectors(D, x)
        if competing:
            found_hypersurface = True
            break
    
    print(f"  Searched 10000 random points.")
    print(f"  Found hypersurface point: {found_hypersurface}")
    print(f"  (Theorem guarantees: never)")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Lorentzian Geometry of Tensor Networks: Demo  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_basic_operations()
    demo_hypersurface_detection()
    demo_bond_dimension_bound()
    demo_tropical_gap_vs_bond_dim()
    demo_exchange_property()
    demo_singleton_no_hypersurface()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 2: Bond Dimension vs. Tropical Gap Scaling

Visualizes the relationship between bond dimension χ and:
- Support cardinality |S| (bounded by χ^n, Theorem 8)
- Estimated tropical gap (Conjecture A: gap ~ log(χ))

This illustrates the cross-domain bridge between tensor network
complexity and tropical geometric invariants.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
import random


def weight_eval(coeff, x, m):
    """Tropical affine evaluation."""
    return coeff.get(m, 0.0) + sum(m[i] * x[i] for i in range(len(m)))


def local_gap(support, coeff, x):
    """Local tropical gap at x."""
    if len(support) <= 1:
        return float('inf')
    weights = sorted(weight_eval(coeff, x, m) for m in support)
    return weights[1] - weights[0]


def make_chain_support(length, chi):
    """Generate chain network support: adjacent entries differ by ≤ 1."""
    support = []
    for m in cartesian_product(range(chi), repeat=length):
        if all(abs(m[i] - m[i+1]) <= 1 for i in range(length-1)):
            support.append(m)
    if not support:
        support = [tuple(0 for _ in range(length))]
    return support


def estimate_gap(support, coeff, n, num_samples=5000):
    """Estimate global tropical gap by sampling."""
    min_gap = float('inf')
    avg_gap = 0.0
    for _ in range(num_samples):
        x = np.random.randn(n) * 3.0
        g = local_gap(support, coeff, x)
        if g < float('inf'):
            min_gap = min(min_gap, g)
            avg_gap += g
    avg_gap /= num_samples
    return min_gap, avg_gap


# Parameters
n = 3  # boundary legs
chi_values = list(range(2, 9))
random.seed(42)
np.random.seed(42)

# Collect data
support_sizes = []
theoretical_bounds = []
min_gaps = []
avg_gaps = []

for chi in chi_values:
    support = make_chain_support(n, chi)
    coeff = {m: random.uniform(0.1, 2.0) for m in support}
    
    support_sizes.append(len(support))
    theoretical_bounds.append(chi ** n)
    
    min_g, avg_g = estimate_gap(support, coeff, n)
    min_gaps.append(min_g)
    avg_gaps.append(avg_g)

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Support size vs bound
ax1 = axes[0]
ax1.bar(chi_values, support_sizes, alpha=0.7, color='#3498DB', label='Actual |S|')
ax1.plot(chi_values, theoretical_bounds, 'r-o', linewidth=2, markersize=8,
         label=f'Bound χ^{n}')
ax1.set_xlabel('Bond dimension χ', fontsize=12)
ax1.set_ylabel('Support cardinality', fontsize=12)
ax1.set_title('Support Size vs. Bond Dimension Bound\n(Theorem 8)', 
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Average gap vs log(χ)
ax2 = axes[1]
log_chi = [np.log(chi + 1) for chi in chi_values]
ax2.plot(log_chi, avg_gaps, 'bo-', linewidth=2, markersize=8, label='Avg tropical gap')
ax2.plot(log_chi, min_gaps, 'rs--', linewidth=2, markersize=8, label='Min tropical gap')

# Fit linear regression
z = np.polyfit(log_chi, avg_gaps, 1)
fit_line = np.poly1d(z)
ax2.plot(log_chi, fit_line(log_chi), 'g--', linewidth=1.5, alpha=0.7,
         label=f'Fit: {z[0]:.2f}·log(χ+1) + {z[1]:.2f}')

ax2.set_xlabel('log(χ + 1)', fontsize=12)
ax2.set_ylabel('Tropical gap', fontsize=12)
ax2.set_title('Tropical Gap vs. log(Bond Dimension)\n(Conjecture A)', 
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Gap/log(χ) ratio
ax3 = axes[2]
ratios = [avg_gaps[i] / log_chi[i] for i in range(len(chi_values))]
ax3.plot(chi_values, ratios, 'ko-', linewidth=2, markersize=8)
ax3.axhline(y=np.mean(ratios), color='red', linestyle='--', alpha=0.5,
            label=f'Mean ratio = {np.mean(ratios):.3f}')
ax3.fill_between(chi_values, 
                 [np.mean(ratios) - np.std(ratios)] * len(chi_values),
                 [np.mean(ratios) + np.std(ratios)] * len(chi_values),
                 alpha=0.1, color='red')

ax3.set_xlabel('Bond dimension χ', fontsize=12)
ax3.set_ylabel('Gap / log(χ+1)', fontsize=12)
ax3.set_title('Ratio Stability\n(Tests Logarithmic Scaling)', 
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.suptitle('Bond Dimension Controls Tropical Geometry: Computational Evidence',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('bond_dim_scaling.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved bond_dim_scaling.png")
print("\nData summary:")
for i, chi in enumerate(chi_values):
    print(f"  χ={chi}: |S|={support_sizes[i]}, bound={theoretical_bounds[i]}, "
          f"avg_gap={avg_gaps[i]:.4f}, ratio={ratios[i]:.4f}")


#!/usr/bin/env python3
"""
Visualization 3: Competing Boundary Sectors in 1D

Visualizes the tropical polynomial evaluation for a 1D boundary measurement
datum. Each affine function c(m) + m·x corresponds to a monomial/sector.
The tropical polynomial is the pointwise minimum (lower envelope). 
Tropical hypersurface points are where two lines cross at the minimum —
exactly the "competing sectors" of Theorems 2-3.
"""

import numpy as np
import matplotlib.pyplot as plt


# Define 1D boundary measurement data
support = [(0,), (1,), (2,), (3,)]
coeff = {
    (0,): 3.0,   # constant sector
    (1,): 1.5,   # linear sector  
    (2,): 0.5,   # quadratic sector
    (3,): 0.0,   # cubic sector
}

colors = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12']
labels = ['Sector m=0', 'Sector m=1', 'Sector m=2', 'Sector m=3']

# Compute weight evaluations
x_range = np.linspace(-3, 3, 1000)

fig, axes = plt.subplots(2, 1, figsize=(12, 9), height_ratios=[3, 1])

# Top panel: affine functions and lower envelope
ax1 = axes[0]

all_weights = []
for idx, m in enumerate(support):
    weights = [coeff[m] + m[0] * x for x in x_range]
    all_weights.append(weights)
    ax1.plot(x_range, weights, color=colors[idx], linewidth=1.5, 
             alpha=0.5, linestyle='--', label=labels[idx])

# Lower envelope (tropical polynomial)
all_weights = np.array(all_weights)
tropical_min = np.min(all_weights, axis=0)
dominant_sector = np.argmin(all_weights, axis=0)

# Draw lower envelope with color indicating dominant sector
for idx in range(len(support)):
    mask = dominant_sector == idx
    # Find contiguous regions
    segments = np.where(mask)[0]
    if len(segments) == 0:
        continue
    # Split into contiguous groups
    breaks = np.where(np.diff(segments) > 1)[0] + 1
    groups = np.split(segments, breaks)
    for g in groups:
        if len(g) > 1:
            ax1.plot(x_range[g], tropical_min[g], color=colors[idx], 
                     linewidth=3.5, solid_capstyle='round')

# Mark hypersurface points (crossings at the minimum)
hypersurface_x = []
for i in range(len(x_range) - 1):
    if dominant_sector[i] != dominant_sector[i + 1]:
        # Interpolate the crossing point
        x_cross = (x_range[i] + x_range[i + 1]) / 2
        y_cross = tropical_min[i]
        hypersurface_x.append((x_cross, y_cross, 
                              dominant_sector[i], dominant_sector[i+1]))

for x_c, y_c, s1, s2 in hypersurface_x:
    ax1.plot(x_c, y_c, 'ko', markersize=12, zorder=5)
    ax1.plot(x_c, y_c, 'w*', markersize=8, zorder=6)
    ax1.annotate(f'{labels[s1].split("=")[1]}/{labels[s2].split("=")[1]} tie',
                 xy=(x_c, y_c), xytext=(x_c + 0.3, y_c + 1.0),
                 fontsize=9, fontweight='bold',
                 arrowprops=dict(arrowstyle='->', color='black', lw=1.5),
                 bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.8))

ax1.set_ylabel('Tropical weight', fontsize=13)
ax1.set_title('Competing Boundary Sectors: Tropical Polynomial as Lower Envelope',
              fontsize=14, fontweight='bold')
ax1.legend(loc='upper left', fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3, 3)

# Bottom panel: tropical gap
ax2 = axes[1]
gaps = []
for i in range(len(x_range)):
    weights_at_x = all_weights[:, i]
    sorted_w = np.sort(weights_at_x)
    gap = sorted_w[1] - sorted_w[0]
    gaps.append(gap)

ax2.fill_between(x_range, 0, gaps, alpha=0.3, color='purple')
ax2.plot(x_range, gaps, color='purple', linewidth=2, label='Tropical gap')

# Mark hypersurface points
for x_c, y_c, s1, s2 in hypersurface_x:
    ax2.axvline(x=x_c, color='red', linestyle=':', alpha=0.7, linewidth=1.5)
    ax2.plot(x_c, 0, 'rv', markersize=10, zorder=5)

ax2.set_xlabel('Tropical parameter x', fontsize=13)
ax2.set_ylabel('Gap', fontsize=13)
ax2.set_title('Tropical Gap (Zero = Hypersurface Point = Entanglement Ambiguity)',
              fontsize=12, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-3, 3)
ax2.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('competing_sectors.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved competing_sectors.png")
print(f"\nHypersurface points found: {len(hypersurface_x)}")
for x_c, y_c, s1, s2 in hypersurface_x:
    print(f"  x ≈ {x_c:.3f}: sectors m={support[s1][0]} and m={support[s2][0]} compete "
          f"(weight ≈ {y_c:.3f})")


#!/usr/bin/env python3
"""
Visualization 1: Tropical Hypersurface of Boundary Measurement Data

Visualizes the tropical hypersurface — the locus where two or more boundary
sectors compete as the dominant configuration — for a 2D boundary measurement
polynomial. Each colored region shows which monomial "wins" (has minimum
tropical weight), and the black lines show the tropical hypersurface where
transitions between dominant sectors occur.

This directly illustrates Theorems 2-3: tropical hypersurface points are
exactly the parameter loci where competing boundary sectors tie for minimum cost.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap


def weight_eval(coeff, x0, x1, m):
    """Tropical affine evaluation: c(m) + m[0]*x0 + m[1]*x1."""
    return coeff[m] + m[0] * x0 + m[1] * x1


def compute_dominant_sector(support, coeff, x0, x1):
    """Find the dominant sector (minimizer) at (x0, x1)."""
    best_idx = 0
    best_val = weight_eval(coeff, x0, x1, support[0])
    for i, m in enumerate(support[1:], 1):
        val = weight_eval(coeff, x0, x1, m)
        if val < best_val:
            best_idx, best_val = i, val
    return best_idx, best_val


def compute_tropical_gap(support, coeff, x0, x1):
    """Compute the gap between 1st and 2nd smallest weights."""
    weights = sorted(weight_eval(coeff, x0, x1, m) for m in support)
    return weights[1] - weights[0] if len(weights) >= 2 else float('inf')


# Define boundary measurement data
support = [(0, 0), (2, 0), (0, 2), (1, 1), (3, 0), (0, 3)]
coeff = {
    (0, 0): 0.0,
    (2, 0): 1.5,
    (0, 2): 1.2,
    (1, 1): 0.8,
    (3, 0): 3.0,
    (0, 3): 2.8,
}

# Create grid
grid_size = 500
x_range = np.linspace(-4, 4, grid_size)
y_range = np.linspace(-4, 4, grid_size)
X, Y = np.meshgrid(x_range, y_range)

# Compute dominant sector and gap at each point
sector_map = np.zeros((grid_size, grid_size), dtype=int)
gap_map = np.zeros((grid_size, grid_size))

for i in range(grid_size):
    for j in range(grid_size):
        idx, _ = compute_dominant_sector(support, coeff, X[i, j], Y[i, j])
        sector_map[i, j] = idx
        gap_map[i, j] = compute_tropical_gap(support, coeff, X[i, j], Y[i, j])

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Dominant sectors with tropical hypersurface
ax1 = axes[0]
colors = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12', '#9B59B6', '#1ABC9C']
cmap = ListedColormap(colors[:len(support)])
im1 = ax1.pcolormesh(X, Y, sector_map, cmap=cmap, shading='auto', alpha=0.7)

# Overlay hypersurface as contour at gap ≈ 0
ax1.contour(X, Y, gap_map, levels=[0.01], colors='black', linewidths=2)

ax1.set_xlabel('Tropical parameter x₁', fontsize=12)
ax1.set_ylabel('Tropical parameter x₂', fontsize=12)
ax1.set_title('Dominant Boundary Sectors\n& Tropical Hypersurface', fontsize=13, fontweight='bold')

# Add legend for sectors
for idx, m in enumerate(support):
    ax1.plot([], [], 's', color=colors[idx], markersize=10, label=f'm = {m}')
ax1.legend(loc='upper right', fontsize=9, title='Sector')

# Right panel: Tropical gap heatmap
ax2 = axes[1]
im2 = ax2.pcolormesh(X, Y, np.log10(gap_map + 1e-15), cmap='magma_r', 
                      shading='auto', vmin=-2, vmax=2)
plt.colorbar(im2, ax=ax2, label='log₁₀(tropical gap)')
ax2.contour(X, Y, gap_map, levels=[0.01], colors='white', linewidths=1.5, 
            linestyles='dashed')

ax2.set_xlabel('Tropical parameter x₁', fontsize=12)
ax2.set_ylabel('Tropical parameter x₂', fontsize=12)
ax2.set_title('Tropical Gap (Separation Strength)\nDark = Competing Sectors', 
              fontsize=13, fontweight='bold')

plt.suptitle('Tropical Hypersurface of Tensor Network Boundary Measurement Data',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_hypersurface.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved tropical_hypersurface.png")
print(f"Support size: {len(support)}")
print(f"Number of distinct dominant sectors: {len(set(sector_map.flatten()))}")
print(f"Minimum gap observed: {gap_map.min():.6f}")
