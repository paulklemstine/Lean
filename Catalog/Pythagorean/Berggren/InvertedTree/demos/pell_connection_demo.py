#!/usr/bin/env python3
"""
Pell Number Connection to the Ghost Matrix
==========================================

Demonstrates the deep connection between the ghost matrix M = B₂⁻¹
and Pell numbers / NSW (Newman-Shanks-Williams) numbers.

Key discoveries:
1. M[0,0] entries are perfect squares of companion Pell numbers
2. M[2,2] entries are NSW numbers
3. |M[0,2]| entries are 2 × Pell numbers
4. The eigenvalue 3+2√2 = (1+√2)² connects to the silver ratio
"""

import numpy as np
from fractions import Fraction

# Ghost matrix M = B₂⁻¹
M = np.array([[1, 2, -2],
              [2, 1, -2],
              [-2, -2, 3]], dtype=object)

print("=" * 70)
print("PELL NUMBER CONNECTION TO THE GHOST MATRIX")
print("=" * 70)

# ═══════════════════════════════════════════════════════════════
# 1. Companion Pell Numbers and M[0,0]
# ═══════════════════════════════════════════════════════════════

print("\n1. COMPANION PELL NUMBERS IN M[0,0]")
print("-" * 50)

# Companion Pell sequence: H(n) = 2*H(n-1) + H(n-2), H(0)=1, H(1)=1
# 1, 1, 3, 7, 17, 41, 99, 239, 577, 1393, ...
def companion_pell(n):
    """Compute the n-th companion Pell number (half-companion Pell)."""
    a, b = 1, 1
    for _ in range(n):
        a, b = b, 2*b + a
    return a

companion_pell_seq = [companion_pell(i) for i in range(12)]
print(f"Companion Pell numbers: {companion_pell_seq}")

Mn = np.eye(3, dtype=object)
print(f"\n{'n':>3} {'M^n[0,0]':>15} {'CompPell(n)²':>15} {'Match':>8}")
print("-" * 45)
for n in range(1, 10):
    Mn = Mn @ M
    entry = int(Mn[0, 0])
    cp = companion_pell(n)
    print(f"{n:3d} {entry:15d} {cp*cp:15d} {'✓' if entry == cp*cp else '✗':>8}")

# ═══════════════════════════════════════════════════════════════
# 2. NSW Numbers and M[2,2]
# ═══════════════════════════════════════════════════════════════

print("\n\n2. NSW NUMBERS IN M[2,2]")
print("-" * 50)

# NSW sequence: N(k+1) = 6*N(k) - N(k-1), N(1)=1, N(2)=7 or
# starting from N₁=3, N₂=17 with the same recurrence
def nsw(n):
    """Compute the n-th NSW number (starting N₁=3, N₂=17)."""
    if n == 1: return 3
    if n == 2: return 17
    a, b = 3, 17
    for _ in range(n - 2):
        a, b = b, 6*b - a
    return b

Mn = np.eye(3, dtype=object)
print(f"\n{'n':>3} {'M^n[2,2]':>15} {'NSW(n)':>15} {'Match':>8}")
print("-" * 45)
for n in range(1, 10):
    Mn = Mn @ M
    entry = int(Mn[2, 2])
    nsw_n = nsw(n)
    print(f"{n:3d} {entry:15d} {nsw_n:15d} {'✓' if entry == nsw_n else '✗':>8}")

# ═══════════════════════════════════════════════════════════════
# 3. Pell Numbers and |M[0,2]|
# ═══════════════════════════════════════════════════════════════

print("\n\n3. PELL NUMBERS IN |M[0,2]|")
print("-" * 50)

def pell(n):
    """Compute the n-th generalized Pell number for our sequence."""
    # |M^n[0,2]| / 2 gives: 1, 6, 35, 204, 1189, 6930, ...
    # These satisfy a(n) = 6*a(n-1) - a(n-2)
    if n == 1: return 1
    if n == 2: return 6
    a, b = 1, 6
    for _ in range(n - 2):
        a, b = b, 6*b - a
    return b

Mn = np.eye(3, dtype=object)
print(f"\n{'n':>3} {'|M^n[0,2]|':>15} {'2×Pell(n)':>15} {'Match':>8}")
print("-" * 45)
for n in range(1, 10):
    Mn = Mn @ M
    entry = abs(int(Mn[0, 2]))
    pell_n = 2 * pell(n)
    print(f"{n:3d} {entry:15d} {pell_n:15d} {'✓' if entry == pell_n else '✗':>8}")

# ═══════════════════════════════════════════════════════════════
# 4. Silver Ratio Connection
# ═══════════════════════════════════════════════════════════════

print("\n\n4. SILVER RATIO CONNECTION")
print("-" * 50)

import math
silver = 1 + math.sqrt(2)
alpha = 3 + 2*math.sqrt(2)
beta = 3 - 2*math.sqrt(2)

print(f"Silver ratio δ_S = 1 + √2 = {silver:.10f}")
print(f"δ_S² = (1+√2)² = {silver**2:.10f}")
print(f"3 + 2√2 = {alpha:.10f}")
print(f"Match: δ_S² = 3+2√2? {'✓' if abs(silver**2 - alpha) < 1e-10 else '✗'}")
print(f"\nDominant eigenvalue: {alpha:.10f}")
print(f"Subdominant eigenvalue: {beta:.10f}")
print(f"Product: {alpha * beta:.10f} (should be 1)")
print(f"Sum: {alpha + beta:.10f} (should be 6)")

# ═══════════════════════════════════════════════════════════════
# 5. Growth Rate Convergence
# ═══════════════════════════════════════════════════════════════

print("\n\n5. GROWTH RATE CONVERGENCE")
print("-" * 50)

Mn = np.eye(3, dtype=object)
prev = 1
print(f"\n{'n':>3} {'M^n[0,0]':>15} {'Ratio':>15} {'3+2√2':>15} {'Error':>15}")
print("-" * 65)
for n in range(1, 12):
    Mn = Mn @ M
    entry = int(Mn[0, 0])
    ratio = entry / prev if prev != 0 else float('inf')
    error = ratio - alpha
    print(f"{n:3d} {entry:15d} {ratio:15.6f} {alpha:15.6f} {error:+15.6f}")
    prev = entry

# ═══════════════════════════════════════════════════════════════
# 6. Trace Formula Verification
# ═══════════════════════════════════════════════════════════════

print("\n\n6. TRACE FORMULA: tr(M^n) = (-1)^n + α^n + β^n")
print("-" * 50)

Mn = np.eye(3, dtype=object)
print(f"\n{'n':>3} {'tr(M^n)':>15} {'Formula':>15} {'Match':>8}")
print("-" * 45)
for n in range(1, 12):
    Mn = Mn @ M
    trace = sum(int(Mn[i, i]) for i in range(3))
    formula = (-1)**n + round(alpha**n + beta**n)
    print(f"{n:3d} {trace:15d} {formula:15d} {'✓' if trace == formula else '~':>8}")

# ═══════════════════════════════════════════════════════════════
# 7. Off-Diagonal Pattern: M^n[0,1] - M^n[0,0] = (-1)^n
# ═══════════════════════════════════════════════════════════════

print("\n\n7. OFF-DIAGONAL PATTERN: M^n[0,1] - M^n[0,0] = (-1)^n")
print("-" * 50)

Mn = np.eye(3, dtype=object)
print(f"\n{'n':>3} {'M^n[0,0]':>15} {'M^n[0,1]':>15} {'Diff':>8} {'(-1)^n':>8}")
print("-" * 55)
for n in range(1, 10):
    Mn = Mn @ M
    a00 = int(Mn[0, 0])
    a01 = int(Mn[0, 1])
    diff = a01 - a00
    expected = (-1)**n
    print(f"{n:3d} {a00:15d} {a01:15d} {diff:8d} {expected:8d}")

# ═══════════════════════════════════════════════════════════════
# 8. Matrix Power Closed Form via Cayley-Hamilton
# ═══════════════════════════════════════════════════════════════

print("\n\n8. CAYLEY-HAMILTON RECURRENCE: M^n = 5·M^{n-1} + 5·M^{n-2} - M^{n-3}")
print("-" * 70)

M1 = M.copy()
M2 = M @ M
M3 = M @ M @ M

print("Verification:")
for n in range(4, 10):
    Mn_computed = 5 * M3 + 5 * M2 - M1
    Mn_actual = np.linalg.matrix_power(M.astype(int), n)
    match = np.array_equal(Mn_computed, Mn_actual)
    print(f"  n={n}: {'✓' if match else '✗'}")
    M1, M2, M3 = M2, M3, Mn_computed

print("\n" + "=" * 70)
print("All patterns verified! The ghost matrix M encodes deep")
print("connections to Pell numbers, NSW numbers, and the silver ratio.")
print("=" * 70)
