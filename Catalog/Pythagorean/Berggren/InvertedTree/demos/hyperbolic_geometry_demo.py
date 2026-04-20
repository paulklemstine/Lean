#!/usr/bin/env python3
"""
Hyperbolic Geometry of the Berggren Tree

Explores the connection between the ghost matrix M and hyperbolic geometry:
- Hyperboloid model points
- Poincaré disk coordinates
- Translation lengths
- Ideal boundary approach
"""

import numpy as np
from math import sqrt, acosh, pi

M = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=object)

def mat_pow(M, n):
    if n == 0:
        return np.eye(3, dtype=object)
    result = np.eye(3, dtype=object)
    base = M.copy()
    while n > 0:
        if n % 2 == 1:
            result = result @ base
        base = base @ base
        n //= 2
    return result

print("=" * 70)
print("HYPERBOLIC GEOMETRY OF THE BERGGREN TREE")
print("=" * 70)

# Section 1: Hyperboloid orbit
print("\n--- Orbit of (0,0,1) under M ---")
print("The point (0,0,1) is on the upper hyperboloid x²+y²−z²=−1.\n")

origin = np.array([0, 0, 1], dtype=object)
orbit = []

for n in range(9):
    Mn = mat_pow(M, n)
    pt = Mn @ origin
    pt_int = [int(x) for x in pt]
    x, y, z = pt_int
    check = x*x + y*y - z*z
    orbit.append(pt_int)
    print(f"  M^{n}·o = ({x:>8}, {y:>8}, {z:>8}), x²+y²−z² = {check:>2}")

# Section 2: Poincaré disk coordinates
print("\n--- Poincaré Disk Coordinates ---")
print("Projection: (x,y,z) → (x/(z+1), y/(z+1))\n")

for n, (x, y, z) in enumerate(orbit):
    if z > 0:
        dx = x / (z + 1)
        dy = y / (z + 1)
        r = sqrt(float(dx)**2 + float(dy)**2)
        print(f"  n={n}: ({float(dx):>10.6f}, {float(dy):>10.6f}), |r| = {r:.6f}")

print(f"\n  Ideal point (n→∞): ({-1/sqrt(2):.6f}, {-1/sqrt(2):.6f})")

# Section 3: Translation length
print("\n--- Hyperbolic Translation Length ---")
print("cosh(d_n) = −η(o, M^n·o) = M^n[2,2] = NSW(n)\n")

for n in range(1, 9):
    Mn = mat_pow(M, n)
    cosh_d = int(Mn[2, 2])
    d = acosh(float(cosh_d))
    d1 = acosh(float(int(M[2, 2])))  # d₁
    ratio = d / d1 if d1 > 0 else 0
    print(f"  n={n}: cosh(d) = {cosh_d:>12}, d = {d:>10.6f}, d/d₁ = {ratio:.4f}")

print(f"\n  d₁ = arccosh(3) = {acosh(3):.6f}")
print(f"  The translation length is approximately linear in n (d_n ≈ n·d₁)")

# Section 4: Berggren tree children in hyperbolic space
print("\n--- Berggren Tree Children in Hyperbolic Space ---")
print("Root = (3,4,5) on the null cone x²+y²=z²\n")

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

root = np.array([3, 4, 5])
children = [
    ("B₁", B1 @ root),
    ("B₂", B2 @ root),
    ("B₃", B3 @ root)
]

for name, child in children:
    a, b, c = child
    check = a*a + b*b - c*c
    # Project to Poincaré disk: (a/c, b/c) for null cone points
    # (normalized version)
    print(f"  {name}·(3,4,5) = ({a:>3}, {b:>3}, {c:>3}), a²+b²−c² = {check}, disk ≈ ({a/c:.3f}, {b/c:.3f})")

# Section 5: Tree depth and hyperbolic distance from root
print("\n--- Depth vs Hyperbolic Distance ---")
print("How far each PPT is from (3,4,5) in hyperbolic space\n")

# Some PPTs at various depths
ppts = [
    (3, 4, 5, 0),      # root
    (5, 12, 13, 1),     # depth 1 (B₁)
    (21, 20, 29, 1),    # depth 1 (B₂)
    (15, 8, 17, 1),     # depth 1 (B₃)
    (7, 24, 25, 2),     # depth 2
    (55, 48, 73, 2),    # depth 2
    (9, 40, 41, 3),     # depth 3
]

for a, b, c, depth in ppts:
    # "Distance" metric: log(c) as a proxy
    import math
    print(f"  ({a:>3}, {b:>3}, {c:>3}), depth={depth}, log(c) = {math.log(c):.3f}")

# Section 6: NSW numbers and cosh of translation length
print("\n--- NSW Numbers as cosh(translation length) ---")
print("The NSW numbers 1, 3, 17, 99, 577, 3363, 19601, ... satisfy:")
print("  N_{k+1} = 6N_k − N_{k-1}")
print("  N_k² − 2·P_k² = 1 (Pell equation)")
print("  N_k = cosh(k·arccosh(3))\n")

nsw = [1, 3]
for i in range(10):
    nsw.append(6*nsw[-1] - nsw[-2])

for k, n in enumerate(nsw):
    d = acosh(3) * k if k > 0 else 0
    cosh_check = np.cosh(d) if k > 0 else 1
    print(f"  N_{k} = {n:>15}, cosh({k}·d₁) = {cosh_check:>15.1f}, match = {'✓' if abs(n - cosh_check) < 0.5 else '✗'}")

print("\n--- Key Insight ---")
print("The ghost matrix M acts as a hyperbolic translation in ℍ².")
print("Its translation length is d = arccosh(3) ≈ 1.763.")
print("The orbit points approach the ideal boundary at (−1/√2, −1/√2),")
print("corresponding to the eigenvector for the dominant eigenvalue 3+2√2.")
