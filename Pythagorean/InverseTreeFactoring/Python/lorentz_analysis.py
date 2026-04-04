#!/usr/bin/env python3
"""
Lorentz Group Analysis of Pythagorean Tree Factoring

Explores the connection between:
1. The Berggren tree and the integer Lorentz group SO(2,1;ℤ)
2. The light cone x² + y² = z² and lattice points
3. Hyperbolic geometry and the factoring descent
4. Potential algebraic shortcuts via the Lorentz structure

Key insight: The Berggren matrices are integer orthogonal transformations
preserving Q = diag(1,1,-1). The group they generate is a finite-index
subgroup of SO(2,1;ℤ). The descent path traces a "geodesic" on the
hyperboloid model of H², and factoring corresponds to finding special
lattice points along this geodesic.
"""

import math
import numpy as np
from typing import Tuple, List
import sys

sys.path.insert(0, '.')
from inverse_tree_factoring import (
    trivial_triple, parent, full_descent,
    INV_B1_MAT, INV_B2_MAT, INV_B3_MAT
)

# ============================================================================
# Lorentz Form
# ============================================================================

Q = np.diag([1, 1, -1])  # Lorentz metric

def lorentz_inner(v1, v2):
    """Compute the Lorentz inner product: v1·Q·v2 = x1x2 + y1y2 - z1z2."""
    return v1[0]*v2[0] + v1[1]*v2[1] - v1[2]*v2[2]

def lorentz_norm(v):
    """Compute Q(v) = x² + y² - z²."""
    return lorentz_inner(v, v)

def verify_on_light_cone(a, b, c):
    """Check that (a,b,c) lies on the light cone Q = 0."""
    return a*a + b*b == c*c

# ============================================================================
# Berggren Matrices as Lorentz Transformations
# ============================================================================

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

def verify_lorentz_preservation(M, name="M"):
    """Verify M^T · Q · M = Q (M preserves the Lorentz form)."""
    result = M.T @ Q @ M
    is_preserved = np.allclose(result, Q)
    det = int(round(np.linalg.det(M)))
    print(f"  {name}: M^T·Q·M = Q? {is_preserved}, det(M) = {det}")
    return is_preserved

# ============================================================================
# Hyperboloid Model Coordinates
# ============================================================================

def to_hyperboloid(a: int, b: int, c: int) -> Tuple[float, float]:
    """
    Project a light-cone point (a, b, c) to the hyperboloid model of H².
    
    The hyperboloid is {(x,y,z) : x² + y² - z² = -1, z > 0}.
    We project (a,b,c) (with a²+b²=c²) radially to get a point on H².
    
    Actually, Pythagorean triples lie on the light cone (Q=0), not the
    hyperboloid (Q=-1). We use the Klein model instead: project to the
    disk {(x,y) : x²+y² < 1} by (a,b,c) → (a/c, b/c).
    """
    if c == 0:
        return (0.0, 0.0)
    return (a / c, b / c)

def klein_to_poincare(x: float, y: float) -> Tuple[float, float]:
    """Convert Klein disk coordinates to Poincaré disk coordinates."""
    r2 = x*x + y*y
    if r2 >= 1:
        return (x, y)  # On boundary
    scale = 1 / (1 + math.sqrt(1 - r2))
    return (x * scale, y * scale)

def hyperbolic_distance(p1: Tuple[float, float], p2: Tuple[float, float]) -> float:
    """
    Compute hyperbolic distance between two points in the Klein model.
    """
    x1, y1 = p1
    x2, y2 = p2
    
    # Klein model distance formula
    r1_sq = x1*x1 + y1*y1
    r2_sq = x2*x2 + y2*y2
    
    if r1_sq >= 1 or r2_sq >= 1:
        return float('inf')
    
    dot = x1*x2 + y1*y2
    
    # cosh(d) = (1 - x1·x2) / sqrt((1-|x1|²)(1-|x2|²))
    num = 1 - dot
    denom = math.sqrt((1 - r1_sq) * (1 - r2_sq))
    
    if denom < 1e-15:
        return float('inf')
    
    cosh_d = num / denom
    if cosh_d < 1:
        cosh_d = 1  # Numerical safety
    
    return math.acosh(cosh_d)

# ============================================================================
# Descent Geodesic Analysis
# ============================================================================

def trace_geodesic(N: int) -> List[Tuple[float, float, float]]:
    """
    Trace the descent path in the Klein disk model.
    Returns list of (x, y, hyperbolic_distance_from_root) tuples.
    """
    path = full_descent(N)
    root_klein = to_hyperboloid(3, 4, 5)
    
    geodesic = []
    for (a, b, c), branch in path:
        kx, ky = to_hyperboloid(a, b, c)
        d = hyperbolic_distance((kx, ky), root_klein)
        geodesic.append((kx, ky, d))
    
    return geodesic

# ============================================================================
# Lattice Structure Analysis
# ============================================================================

def factor_lattice_points(N: int, max_c: int = 1000) -> List[Tuple[int, int, int]]:
    """
    Find all Pythagorean triples (a, b, c) with c ≤ max_c where
    gcd(a, N) or gcd(b, N) reveals a factor.
    """
    points = []
    
    for c in range(5, max_c + 1):
        for a in range(3, c):
            b_sq = c*c - a*a
            b = int(math.isqrt(b_sq))
            if b*b == b_sq and b > 0:
                ga = math.gcd(a, N)
                gb = math.gcd(b, N)
                if (1 < ga < N) or (1 < gb < N):
                    points.append((a, b, c))
    
    return points

# ============================================================================
# Eigenvalue Analysis
# ============================================================================

def eigenvalue_analysis():
    """
    Analyze eigenvalues of Berggren matrices.
    
    Key insight: The eigenvalue λ = 3 - 2√2 ≈ 0.172 of the inverse matrices
    determines the rate of hypotenuse decay during descent.
    """
    print("\n" + "=" * 60)
    print("EIGENVALUE ANALYSIS OF BERGGREN MATRICES")
    print("=" * 60)
    
    for name, M in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
        eigenvalues = np.linalg.eigvals(M)
        print(f"\n{name}:")
        print(f"  Eigenvalues: {eigenvalues}")
        print(f"  |eigenvalues|: {np.abs(eigenvalues)}")
        print(f"  Product: {np.prod(eigenvalues):.6f} (should be ±det)")
        print(f"  det: {np.linalg.det(M):.0f}")
    
    # Inverse matrix eigenvalues
    for name, M in [("B₁⁻¹", np.array(INV_B1_MAT)), 
                     ("B₂⁻¹", np.array(INV_B2_MAT)),
                     ("B₃⁻¹", np.array(INV_B3_MAT))]:
        eigenvalues = np.linalg.eigvals(M)
        print(f"\n{name}:")
        print(f"  Eigenvalues: {eigenvalues}")
        print(f"  |eigenvalues|: {np.abs(eigenvalues)}")
    
    # Key eigenvalue
    lambda_decay = 3 - 2*math.sqrt(2)
    lambda_growth = 3 + 2*math.sqrt(2)
    print(f"\nKey eigenvalues:")
    print(f"  3 - 2√2 = {lambda_decay:.10f} (contracting)")
    print(f"  3 + 2√2 = {lambda_growth:.10f} (expanding)")
    print(f"  Product: {lambda_decay * lambda_growth:.10f} (should be 1)")
    print(f"  Descent rate: log(c_k/c_{k+1}) ≈ log(1/λ) = {-math.log(lambda_decay):.6f}")
    print(f"  Expected depth ≈ log(c₀) / {-math.log(lambda_decay):.4f}")

# ============================================================================
# Boost Parameter Analysis
# ============================================================================

def boost_analysis(N: int):
    """
    Analyze the descent in terms of Lorentz boost parameters.
    
    Each Berggren matrix can be decomposed as a rotation followed by a boost.
    The boost parameter (rapidity) decreases monotonically during descent.
    """
    print(f"\n{'='*60}")
    print(f"BOOST PARAMETER ANALYSIS: N = {N}")
    print(f"{'='*60}")
    
    path = full_descent(N)
    
    print(f"\n{'Depth':>5} {'a':>10} {'b':>10} {'c':>10} {'rapidity':>12} {'angle':>12}")
    print("-" * 65)
    
    for i, ((a, b, c), branch) in enumerate(path):
        if c > 0:
            # Rapidity: cosh(η) = c / sqrt(c² - a² - b²)... but a²+b²=c²
            # So we use a different parameterization
            # In the Klein model, the "radius" is r = sqrt(a²+b²)/c = 1 (on light cone)
            # Use angle θ = arctan(b/a)
            if a != 0:
                angle = math.atan2(b, a) * 180 / math.pi
            else:
                angle = 90.0
            
            rapidity = math.log(c) if c > 0 else 0
        else:
            angle = 0
            rapidity = 0
        
        if i <= 20 or i == len(path) - 1:
            print(f"{i:5d} {a:10d} {b:10d} {c:10d} {rapidity:12.6f} {angle:12.4f}°")
        elif i == 21:
            print(f"  ... ({len(path) - 22} more levels)")

# ============================================================================
# Demo
# ============================================================================

def demo():
    print("=" * 60)
    print("LORENTZ GROUP ANALYSIS OF PYTHAGOREAN TREE FACTORING")
    print("=" * 60)
    
    # Verify Lorentz preservation
    print("\nVerifying Lorentz form preservation:")
    verify_lorentz_preservation(B1, "B₁")
    verify_lorentz_preservation(B2, "B₂")
    verify_lorentz_preservation(B3, "B₃")
    
    # Eigenvalue analysis
    eigenvalue_analysis()
    
    # Boost analysis for specific N
    for N in [77, 221]:
        boost_analysis(N)
    
    # Geodesic trace
    print(f"\n{'='*60}")
    print("GEODESIC TRACE IN KLEIN DISK: N = 77")
    print(f"{'='*60}")
    
    geo = trace_geodesic(77)
    print(f"\n{'Depth':>5} {'x':>10} {'y':>10} {'hyp_dist':>12}")
    print("-" * 40)
    for i, (x, y, d) in enumerate(geo):
        print(f"{i:5d} {x:10.6f} {y:10.6f} {d:12.6f}")
    
    # Factor lattice analysis
    print(f"\n{'='*60}")
    print("FACTOR LATTICE POINTS FOR N = 77")
    print(f"{'='*60}")
    
    points = factor_lattice_points(77, max_c=200)
    print(f"\nFound {len(points)} factor-revealing triples with c ≤ 200:")
    for a, b, c in points[:20]:
        ga, gb = math.gcd(a, 77), math.gcd(b, 77)
        factor = ga if 1 < ga < 77 else gb
        print(f"  ({a}, {b}, {c}): gcd reveals factor {factor}")


if __name__ == '__main__':
    demo()
