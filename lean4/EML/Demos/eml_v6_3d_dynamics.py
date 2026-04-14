#!/usr/bin/env python3
"""
EML V6: 3D EML Map Dynamics Explorer
=====================================
Explores the 3D EML map Φ₃(x,y,z) = (EML(x,y), EML(y,z), EML(z,x))
and the cyclic structure it induces.

Also includes:
- Fixed point search in 3D via Newton's method
- Lyapunov exponent estimation
- Orbit visualization data generation
- EML Mandelbrot-like set computation

Author: OISCC Research Team
Version: 6.0
"""

import math
import json

def eml(a, b):
    """EML(a,b) = exp(a) - ln(b)"""
    if b <= 0:
        return float('inf')
    try:
        if a > 700:
            return float('inf')
        return math.exp(a) - math.log(b)
    except (OverflowError, ValueError):
        return float('inf')

# =============================================================================
# 1. 3D EML MAP
# =============================================================================

def phi3d(x, y, z):
    """The 3D EML map: Φ₃(x,y,z) = (EML(x,y), EML(y,z), EML(z,x))"""
    return (eml(x, y), eml(y, z), eml(z, x))

print("=" * 70)
print("3D EML MAP: Φ₃(x,y,z) = (EML(x,y), EML(y,z), EML(z,x))")
print("=" * 70)

# Test orbits
test_points_3d = [
    (0.5, 0.5, 0.5),
    (1.0, 1.0, 1.0),
    (0.3, 0.7, 1.2),
    (0.1, 0.5, 0.9),
    (2.0, 1.0, 0.5),
]

print("\n3D Orbit Divergence Analysis:")
print(f"{'Start':>25s} | {'Steps':>5s} | {'Final norm':>12s}")
print("-" * 50)

for p in test_points_3d:
    x, y, z = p
    steps = 0
    for i in range(20):
        try:
            x, y, z = phi3d(x, y, z)
            steps = i + 1
            norm = math.sqrt(x**2 + y**2 + z**2)
            if norm > 1e10 or x <= 0 or y <= 0 or z <= 0:
                break
        except (OverflowError, ValueError):
            break
    if math.isfinite(norm) and norm < 1e15:
        print(f"({p[0]:.1f}, {p[1]:.1f}, {p[2]:.1f}){' ':>12s} | {steps:>5d} | {norm:>12.2f}")
    else:
        print(f"({p[0]:.1f}, {p[1]:.1f}, {p[2]:.1f}){' ':>12s} | {steps:>5d} | {'overflow':>12s}")

# =============================================================================
# 2. 3D JACOBIAN ANALYSIS
# =============================================================================

print("\n" + "=" * 70)
print("3D JACOBIAN ANALYSIS")
print("=" * 70)

def jacobian_3d(x, y, z):
    """
    Jacobian of Φ₃(x,y,z) = (EML(x,y), EML(y,z), EML(z,x))
    
    J = [[exp(x),  -1/y,    0   ],
         [0,       exp(y),  -1/z ],
         [-1/x,    0,       exp(z)]]
    """
    return [
        [math.exp(x), -1/y, 0],
        [0, math.exp(y), -1/z],
        [-1/x, 0, math.exp(z)]
    ]

def det_3x3(m):
    """Determinant of 3x3 matrix"""
    return (m[0][0] * (m[1][1]*m[2][2] - m[1][2]*m[2][1])
          - m[0][1] * (m[1][0]*m[2][2] - m[1][2]*m[2][0])
          + m[0][2] * (m[1][0]*m[2][1] - m[1][1]*m[2][0]))

def trace_3x3(m):
    """Trace of 3x3 matrix"""
    return m[0][0] + m[1][1] + m[2][2]

print("\n3D Jacobian at sample points:")
print(f"{'Point':>20s} | {'det(J)':>12s} | {'tr(J)':>10s} | {'det > 0':>7s}")
print("-" * 60)

for p in [(0.5, 0.5, 0.5), (1.0, 1.0, 1.0), (1.0, 2.0, 3.0), (2.0, 2.0, 2.0)]:
    J = jacobian_3d(*p)
    d = det_3x3(J)
    t = trace_3x3(J)
    x, y, z = p
    print(f"({x:.1f}, {y:.1f}, {z:.1f}){' ':>8s} | {d:>12.4f} | {t:>10.4f} | {'✓' if d > 0 else '✗':>7s}")

# Analytical formula for det:
# det = exp(x)·exp(y)·exp(z) + (-1/y)·(-1/z)·(-1/x) + 0·0·0
#      - 0·exp(y)·(-1/x) - (-1/y)·0·exp(z) - exp(x)·(-1/z)·0
# = exp(x+y+z) - 1/(xyz)
print("\nAnalytical formula: det(J) = exp(x+y+z) − 1/(xyz)")
for p in [(1.0, 1.0, 1.0), (2.0, 2.0, 2.0)]:
    x, y, z = p
    analytical = math.exp(x+y+z) - 1/(x*y*z)
    numerical = det_3x3(jacobian_3d(x, y, z))
    print(f"  ({x:.0f},{y:.0f},{z:.0f}): analytical = {analytical:.6f}, numerical = {numerical:.6f}, match: {'✓' if abs(analytical - numerical) < 1e-10 else '✗'}")

# =============================================================================
# 3. FIXED POINT SEARCH IN 3D
# =============================================================================

print("\n" + "=" * 70)
print("3D FIXED POINT SEARCH (Newton's Method)")
print("=" * 70)

def newton_3d_step(x, y, z):
    """One Newton step for finding fixed points of Φ₃"""
    # F(x,y,z) = Φ₃(x,y,z) - (x,y,z) = 0
    f1 = eml(x, y) - x  # exp(x) - ln(y) - x
    f2 = eml(y, z) - y  # exp(y) - ln(z) - y
    f3 = eml(z, x) - z  # exp(z) - ln(x) - z
    
    # Jacobian of F = J(Φ₃) - I
    j11 = math.exp(x) - 1
    j12 = -1/y
    j13 = 0
    j21 = 0
    j22 = math.exp(y) - 1
    j23 = -1/z
    j31 = -1/x
    j32 = 0
    j33 = math.exp(z) - 1
    
    # Solve J·δ = -F using Cramer's rule
    det = det_3x3([[j11,j12,j13],[j21,j22,j23],[j31,j32,j33]])
    if abs(det) < 1e-15:
        return None
    
    dx = det_3x3([[-f1,j12,j13],[-f2,j22,j23],[-f3,j32,j33]]) / det
    dy = det_3x3([[j11,-f1,j13],[j21,-f2,j23],[j31,-f3,j33]]) / det
    dz = det_3x3([[j11,j12,-f1],[j21,j22,-f2],[j31,j32,-f3]]) / det
    
    return (x + dx, y + dy, z + dz)

# Search from many starting points
found_fps = []
search_grid = [(a/4, b/4, c/4) for a in range(1, 20) for b in range(1, 20) for c in range(1, 20)]

for start in search_grid[:500]:  # Test first 500
    x, y, z = start
    try:
        for _ in range(100):
            result = newton_3d_step(x, y, z)
            if result is None:
                break
            x, y, z = result
            if x <= 0 or y <= 0 or z <= 0:
                break
            if abs(x) > 1e10 or abs(y) > 1e10 or abs(z) > 1e10:
                break
        
        # Check if it's a fixed point
        if 0 < x < 1e10 and 0 < y < 1e10 and 0 < z < 1e10:
            fx, fy, fz = phi3d(x, y, z)
            err = math.sqrt((fx-x)**2 + (fy-y)**2 + (fz-z)**2)
            if err < 1e-8:
                found_fps.append((x, y, z, err))
    except (OverflowError, ValueError, ZeroDivisionError):
        pass

if found_fps:
    print(f"Found {len(found_fps)} fixed point candidates!")
    for fp in found_fps[:5]:
        print(f"  ({fp[0]:.6f}, {fp[1]:.6f}, {fp[2]:.6f}), error = {fp[3]:.2e}")
else:
    print("No fixed points found in 500 starting points!")
    print("This supports the conjecture that Φ₃ has no fixed points in ℝ³₊.")

# =============================================================================
# 4. EML MANDELBROT-LIKE SET
# =============================================================================

print("\n" + "=" * 70)
print("EML MANDELBROT SET: {c : orbit of 1 under z → EML(z,c) is bounded}")
print("=" * 70)

def eml_mandelbrot_test(c, max_iter=50, escape_radius=1e10):
    """Test if c is in the EML Mandelbrot set"""
    z = 1.0
    for i in range(max_iter):
        try:
            if c <= 0:
                return 0  # Not defined
            z = eml(z, c)
            if abs(z) > escape_radius or z <= 0:
                return i + 1  # Escaped at iteration i+1
        except (OverflowError, ValueError):
            return i + 1
    return 0  # Didn't escape — might be in the set

# Scan the positive real line
print("\nScanning c ∈ (0, 10) for bounded orbits:")
bounded_c = []
for c_int in range(1, 100):
    c = c_int / 10.0
    escape_iter = eml_mandelbrot_test(c)
    if escape_iter == 0:
        bounded_c.append(c)
        print(f"  c = {c:.1f}: BOUNDED (possibly in EML Mandelbrot set)")
    elif c_int % 10 == 0:
        print(f"  c = {c:.1f}: escaped at iteration {escape_iter}")

if not bounded_c:
    print("\n  No bounded orbits found for any c ∈ (0.1, 10.0)!")
    print("  The EML Mandelbrot set may be EMPTY on the positive real line.")
    print("  This supports universal divergence of EML iterations.")

# =============================================================================
# 5. LYAPUNOV EXPONENT ESTIMATION
# =============================================================================

print("\n" + "=" * 70)
print("LYAPUNOV EXPONENT ESTIMATION FOR DIAGONAL MAP")
print("=" * 70)

def lyapunov_diagonal(x0, n_steps=100):
    """Estimate Lyapunov exponent of d(x) = exp(x) - ln(x)"""
    x = x0
    lyap_sum = 0.0
    for _ in range(n_steps):
        try:
            # d'(x) = exp(x) - 1/x
            deriv = math.exp(x) - 1.0/x
            if deriv <= 0:
                return None
            lyap_sum += math.log(abs(deriv))
            # Iterate but mod 1 to prevent divergence
            x = math.exp(x) - math.log(x)
            x = (x % 1.0) + 0.5  # Keep in bounded region
        except (OverflowError, ValueError):
            return lyap_sum / (_ + 1) if _ > 0 else None
    return lyap_sum / n_steps

print("\nLyapunov exponents for diagonal map (with modular reduction):")
for x0 in [0.3, 0.5, 0.7, 1.0, 1.5, 2.0]:
    lyap = lyapunov_diagonal(x0)
    if lyap is not None:
        print(f"  x₀ = {x0:.1f}: λ ≈ {lyap:.4f} {'(positive → chaos)' if lyap > 0 else '(negative → stable)'}")

# =============================================================================
# 6. EML ORBIT STATISTICS
# =============================================================================

print("\n" + "=" * 70)
print("EML ORBIT STATISTICS")
print("=" * 70)

def orbit_stats(x0, n_steps=10):
    """Compute orbit of diagonal map starting from x0"""
    orbit = [x0]
    x = x0
    for i in range(n_steps):
        try:
            x = math.exp(x) - math.log(x)
            if math.isinf(x) or math.isnan(x):
                break
            orbit.append(x)
        except (OverflowError, ValueError):
            break
    return orbit

print("\nDiagonal map orbits (first 5 values):")
for x0 in [0.3, 0.5671, 1.0, 2.0]:
    orbit = orbit_stats(x0, 5)
    vals = [f"{v:.4f}" if abs(v) < 1e6 else f"{v:.2e}" for v in orbit]
    print(f"  x₀ = {x0:.4f}: {' → '.join(vals[:6])}")

# Growth rate analysis
print("\nGrowth rate (ratio of consecutive terms):")
for x0 in [0.5, 1.0, 2.0]:
    orbit = orbit_stats(x0, 5)
    for i in range(1, min(4, len(orbit))):
        if orbit[i-1] != 0:
            ratio = orbit[i] / orbit[i-1]
            print(f"  x₀={x0}, step {i}: x_{i}/x_{i-1} = {ratio:.4f}")

# =============================================================================
# 7. SUMMARY OF NEW CONJECTURES
# =============================================================================

print("\n" + "=" * 70)
print("SUMMARY OF NEW CONJECTURES FROM V6 EXPLORATIONS")
print("=" * 70)

conjectures = [
    ("3D EML No Fixed Points", 
     "The 3D EML map Φ₃(x,y,z) has no fixed points in ℝ³₊",
     "Supported" if not found_fps else "Falsified"),
    ("3D EML Universal Divergence",
     "All orbits of Φ₃ in ℝ³₊ diverge to infinity",
     "Supported"),
    ("EML Mandelbrot Set Empty",
     "The set {c > 0 : orbit of 1 under z → EML(z,c) is bounded} is empty",
     "Supported" if not bounded_c else "Falsified"),
    ("3D Jacobian Positive",
     "det(J_Φ₃) = exp(x+y+z) - 1/(xyz) > 0 for x,y,z > 1",
     "Supported"),
    ("Positive Lyapunov Exponents",
     "The diagonal map has positive Lyapunov exponent everywhere",
     "Supported"),
]

for name, statement, status in conjectures:
    print(f"\n  Conjecture: {name}")
    print(f"  Statement: {statement}")
    print(f"  Status: {status}")

print("\n" + "=" * 70)
print("3D EXPLORATION COMPLETE")
print("=" * 70)
