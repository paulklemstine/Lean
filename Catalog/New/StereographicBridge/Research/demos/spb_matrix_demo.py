#!/usr/bin/env python3
"""
SPB Matrix Representation Demo

Demonstrates:
1. SPB as matrix multiplication
2. Determinant = 1 + a²
3. Trace = 2 always
4. Connection to rotation matrices
5. Composition verification
"""

import numpy as np
import math

def spb(x, y):
    """Standard SPB"""
    if abs(1 - x*y) < 1e-15:
        return float('inf')
    return (x + y) / (1 - x * y)

def spb_matrix(a):
    """The 2x2 matrix for SPB translation by a"""
    return np.array([[1, a], [-a, 1]])

def spb_from_matrix(M):
    """Extract spb value from matrix: M[0,1] / M[0,0]"""
    if abs(M[0,0]) < 1e-15:
        return float('inf')
    return M[0,1] / M[0,0]

print("=" * 70)
print("SPB MATRIX REPRESENTATION")
print("M(a) = [[1, a], [-a, 1]]")
print("=" * 70)

# 1. Basic properties
print("\n1. DETERMINANT AND TRACE")
print("-" * 50)
for a in [0, 0.5, 1, 2, -1, 3.14, -2.72]:
    M = spb_matrix(a)
    det = np.linalg.det(M)
    tr = np.trace(M)
    expected_det = 1 + a**2
    print(f"  a = {a:6.2f}: det = {det:8.4f} (1+a² = {expected_det:8.4f}), trace = {tr:.1f}")

# 2. Composition verification
print("\n2. COMPOSITION = MATRIX MULTIPLICATION")
print("-" * 50)
test_pairs = [(0.5, 0.3), (1, 2), (-1, 0.5), (3, -2), (0.1, 0.9)]
for a, b in test_pairs:
    # SPB way
    spb_val = spb(a, b)
    # Matrix way
    Ma = spb_matrix(a)
    Mb = spb_matrix(b)
    Mab = Ma @ Mb
    matrix_val = spb_from_matrix(Mab)
    match = abs(spb_val - matrix_val) < 1e-10
    print(f"  spb({a:5.1f}, {b:5.1f}) = {spb_val:8.4f}  |  M(a)·M(b) → {matrix_val:8.4f}  {'✓' if match else '✗'}")

# 3. Inverse verification
print("\n3. INVERSE: M(a) · M(-a) = (1+a²) · I")
print("-" * 50)
for a in [0.5, 1, 2, -3, 0.1]:
    Ma = spb_matrix(a)
    Mna = spb_matrix(-a)
    product = Ma @ Mna
    expected = (1 + a**2) * np.eye(2)
    close = np.allclose(product, expected)
    print(f"  a = {a:5.1f}: M(a)·M(-a) = (1+a²)·I = {1+a**2:.2f}·I  {'✓' if close else '✗'}")

# 4. Connection to rotations
print("\n4. ROTATION CONNECTION")
print("-" * 50)
print("  Normalized M(a)/√(1+a²) is a rotation matrix R(θ) with θ = arctan(a)")
for a in [0, 1, -1, math.sqrt(3), 0.5]:
    scale = 1 / math.sqrt(1 + a**2)
    M_norm = scale * spb_matrix(a)
    theta = math.atan(a)
    R = np.array([[math.cos(theta), math.sin(theta)],
                  [-math.sin(theta), math.cos(theta)]])
    close = np.allclose(M_norm, R)
    print(f"  a = {a:6.3f}: θ = {math.degrees(theta):7.2f}°  rotation match: {'✓' if close else '✗'}")

# 5. Eigenvalues
print("\n5. EIGENVALUES")
print("-" * 50)
for a in [0, 0.5, 1, 2, 5]:
    M = spb_matrix(a)
    eigenvalues = np.linalg.eigvals(M)
    print(f"  a = {a:4.1f}: eigenvalues = {eigenvalues[0]:.4f}, {eigenvalues[1]:.4f}")
    print(f"          expected: 1+{a}i, 1-{a}i → |λ| = {abs(eigenvalues[0]):.4f} = √(1+a²) = {math.sqrt(1+a**2):.4f}")

# 6. Triple composition - associativity via matrices
print("\n6. TRIPLE COMPOSITION ASSOCIATIVITY")
print("-" * 50)
for a, b, c in [(1, 2, 3), (0.5, -0.3, 0.7), (-1, 0.5, 2)]:
    # (a ∘ b) ∘ c
    lhs = spb(spb(a, b), c)
    # a ∘ (b ∘ c)
    rhs = spb(a, spb(b, c))
    # Matrix way
    M = spb_matrix(a) @ spb_matrix(b) @ spb_matrix(c)
    mat_val = spb_from_matrix(M)
    print(f"  ({a}, {b}, {c}): spb(spb(a,b),c) = {lhs:.6f}")
    print(f"               spb(a,spb(b,c)) = {rhs:.6f}")
    print(f"               M(a)·M(b)·M(c)  = {mat_val:.6f}")
    print(f"               {'✓ All agree' if abs(lhs-rhs) < 1e-8 and abs(lhs-mat_val) < 1e-8 else '✗ Mismatch'}")

# 7. Characteristic polynomial
print("\n7. CHARACTERISTIC POLYNOMIAL")
print("-" * 50)
print("  charpoly(M(a)) = λ² - 2λ + (1+a²)")
for a in [0, 1, 2, -1]:
    M = spb_matrix(a)
    # Verify: det(M - λI) = λ² - tr(M)λ + det(M) = λ² - 2λ + (1+a²)
    coeffs = np.poly(M)  # Returns coefficients of char poly
    print(f"  a = {a:4.1f}: coeffs = [{coeffs[0]:.0f}, {coeffs[1]:.0f}, {coeffs[2]:.0f}]"
          f"  expected = [1, -2, {1+a**2:.0f}]")

print("\n" + "=" * 70)
print("KEY INSIGHT: SPB composition IS matrix multiplication")
print("The SPB group is isomorphic to a subgroup of GL₂(ℝ)")
print("Normalized, it's exactly SO(2) — the rotation group!")
print("=" * 70)
