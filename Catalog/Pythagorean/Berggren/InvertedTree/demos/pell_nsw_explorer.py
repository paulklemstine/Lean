#!/usr/bin/env python3
"""
Pell and NSW Number Connections in the Ghost Matrix

Explores the remarkable connection between entries of M^n and:
- Companion Pell numbers (half-companion Pell sequence)
- Newman-Shanks-Williams (NSW) numbers
- Pell numbers
- The Pell equation d² − 2c² = 1
"""

import numpy as np
from math import sqrt, isqrt

M = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=object)

def mat_pow(M, n):
    """Integer matrix power."""
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
print("PELL AND NSW NUMBER CONNECTIONS IN THE GHOST MATRIX")
print("=" * 70)

# Section 1: M^n entries
print("\n--- M^n Entry Table ---\n")
print(f"{'n':>3} {'M[0,0]':>12} {'M[0,1]':>12} {'M[0,2]':>12} {'M[2,2]':>12} {'√M[0,0]':>10}")
print("-" * 65)

entries_00 = []
entries_22 = []
entries_02 = []

for n in range(1, 13):
    Mn = mat_pow(M, n)
    a00, a01, a02, a22 = int(Mn[0,0]), int(Mn[0,1]), int(Mn[0,2]), int(Mn[2,2])
    sq = isqrt(abs(a00))
    is_sq = "✓" if sq*sq == a00 else "✗"
    print(f"{n:>3} {a00:>12} {a01:>12} {a02:>12} {a22:>12} {sq:>8} {is_sq}")
    entries_00.append(a00)
    entries_22.append(a22)
    entries_02.append(abs(a02))

# Section 2: Companion Pell numbers
print("\n--- Companion Pell Numbers ---")
print("H_n = √(M^n[0,0]): ", [isqrt(x) for x in entries_00])
print("Recurrence: H_{n+1} = 2H_n + H_{n-1}")
H = [isqrt(x) for x in entries_00]
print("Verification:")
for i in range(2, len(H)):
    expected = 2 * H[i-1] + H[i-2]
    print(f"  H_{i+1} = 2·{H[i-1]} + {H[i-2]} = {expected}, actual = {H[i]}, {'✓' if expected == H[i] else '✗'}")

# Section 3: NSW numbers
print("\n--- NSW Numbers ---")
print("N_n = M^n[2,2]:", entries_22)
print("Recurrence: N_{n+1} = 6N_n − N_{n-1}")
print("Verification:")
for i in range(2, len(entries_22)):
    expected = 6 * entries_22[i-1] - entries_22[i-2]
    print(f"  N_{i+1} = 6·{entries_22[i-1]} − {entries_22[i-2]} = {expected}, actual = {entries_22[i]}, {'✓' if expected == entries_22[i] else '✗'}")

# Section 4: Double Pell numbers
print("\n--- |M^n[0,2]| = 2·P_n (Double Pell) ---")
print("|M^n[0,2]|:", entries_02)
half = [x // 2 for x in entries_02]
print("P_n = |M^n[0,2]|/2:", half)
print("Recurrence: P_{n+1} = 6P_n − P_{n-1}")
print("Verification:")
for i in range(2, len(half)):
    expected = 6 * half[i-1] - half[i-2]
    print(f"  P_{i+1} = 6·{half[i-1]} − {half[i-2]} = {expected}, actual = {half[i]}, {'✓' if expected == half[i] else '✗'}")

# Section 5: Pell equation
print("\n--- Pell Equation: d² − 2c² = 1 ---")
print("d = M^n[2,2] (NSW), c = |M^n[0,2]|")
for i in range(len(entries_22)):
    d = entries_22[i]
    c = entries_02[i]
    val = d*d - 2*c*c
    print(f"  n={i+1}: {d}² − 2·{c}² = {val} {'✓' if val == 1 else '✗'}")

# Section 6: Off-diagonal alternation
print("\n--- Off-diagonal Alternation: M^n[0,1] − M^n[0,0] = (−1)^{n+1} ---")
for n in range(1, 13):
    Mn = mat_pow(M, n)
    diff = int(Mn[0,1]) - int(Mn[0,0])
    expected = (-1)**(n+1)
    print(f"  n={n}: {int(Mn[0,1])} − {int(Mn[0,0])} = {diff}, expected (−1)^{n+1} = {expected}, {'✓' if diff == expected else '✗'}")

# Section 7: Growth rate oscillation
print("\n--- Growth Rate: M^{n+1}[0,0] / M^n[0,0] → (3+2√2) ≈ 5.828... ---")
silver_sq = 3 + 2*sqrt(2)
for i in range(1, len(entries_00)):
    ratio = entries_00[i] / entries_00[i-1]
    err = abs(ratio - silver_sq) / silver_sq
    print(f"  n={i+1}: ratio = {ratio:.6f}, target = {silver_sq:.6f}, rel error = {err:.2e}")

# Section 8: Trace sequence
print("\n--- Trace Sequence ---")
print("tr(M^n) = (−1)^n + (3+2√2)^n + (3−2√2)^n")
alpha = 3 + 2*sqrt(2)
beta = 3 - 2*sqrt(2)
for n in range(1, 13):
    Mn = mat_pow(M, n)
    trace = int(Mn[0,0]) + int(Mn[1,1]) + int(Mn[2,2])
    formula = (-1)**n + alpha**n + beta**n
    print(f"  n={n}: tr(M^{n}) = {trace}, formula = {formula:.0f}, {'✓' if abs(trace - formula) < 0.5 else '✗'}")

print("\n--- Key Findings ---")
print("1. M^n[0,0] = H_n² (companion Pell squares)")
print("2. M^n[2,2] = NSW(n) (Newman-Shanks-Williams numbers)")
print("3. |M^n[0,2]| = 2·P_n (double Pell numbers)")
print("4. NSW(n)² − 2·|M^n[0,2]|² = 1 (Pell equation)")
print("5. M^n[0,1] − M^n[0,0] = (−1)^{n+1} (off-diagonal alternation)")
print(f"6. Growth rate → (1+√2)² = {silver_sq:.6f} (silver ratio squared)")
