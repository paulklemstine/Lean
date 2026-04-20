#!/usr/bin/env python3
"""
Hyperbolic Geometry and Factoring via Berggren Descent
======================================================

Demonstrates:
1. The hyperbolic geometry interpretation of the Berggren tree
2. Deterministic factoring via Berggren descent
3. Modular periodicity of the ghost matrix
4. Higher-dimensional Pythagorean quadruple extension
"""

import math
from collections import defaultdict
import numpy as np

# ═══════════════════════════════════════════════════════════════
# Setup
# ═══════════════════════════════════════════════════════════════

M = np.array([[1, 2, -2],
              [2, 1, -2],
              [-2, -2, 3]])

B1 = np.array([[1, -2, 2],
               [2, -1, 2],
               [2, -2, 3]])

B2 = np.array([[1, 2, 2],
               [2, 1, 2],
               [2, 2, 3]])

B3 = np.array([[-1, 2, 2],
               [-2, 1, 2],
               [-2, 2, 3]])

def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

print("=" * 70)
print("HYPERBOLIC GEOMETRY & FACTORING VIA BERGGREN DESCENT")
print("=" * 70)

# ═══════════════════════════════════════════════════════════════
# 1. Modular Periodicity of Ghost Matrix
# ═══════════════════════════════════════════════════════════════

print("\n1. MODULAR PERIODICITY OF M")
print("-" * 50)

def matrix_mod(A, p):
    return np.mod(A, p)

def matrix_power_mod(A, n, p):
    """Compute A^n mod p."""
    result = np.eye(3, dtype=int)
    base = matrix_mod(A, p)
    while n > 0:
        if n % 2 == 1:
            result = matrix_mod(result @ base, p)
        base = matrix_mod(base @ base, p)
        n //= 2
    return result

def find_order_mod(A, p, max_n=1000):
    """Find the order of A in GL(3, F_p)."""
    I = np.eye(3, dtype=int)
    power = matrix_mod(A, p)
    for n in range(1, max_n + 1):
        if np.array_equal(matrix_mod(power, p), matrix_mod(I, p)):
            return n
        power = matrix_mod(power @ A, p)
    return None

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
print(f"\n{'p':>5} {'order(M mod p)':>15} {'p²-1':>10} {'(p-1)(p+1)':>12}")
print("-" * 45)
for p in primes:
    order = find_order_mod(M, p)
    print(f"{p:5d} {str(order) if order else '>1000':>15} {p*p-1:10d} {(p-1)*(p+1):12d}")

# ═══════════════════════════════════════════════════════════════
# 2. M mod p: Structure Analysis
# ═══════════════════════════════════════════════════════════════

print("\n\n2. GHOST MATRIX MOD SMALL PRIMES")
print("-" * 50)

for p in [2, 3, 5, 7]:
    Mmod = matrix_mod(M, p)
    print(f"\n  M mod {p}:")
    for row in Mmod:
        print(f"    {list(row)}")
    Msq = matrix_mod(M @ M, p)
    print(f"  M² mod {p}:")
    for row in Msq:
        print(f"    {list(row)}")

# ═══════════════════════════════════════════════════════════════
# 3. Deterministic Factoring via Berggren Descent
# ═══════════════════════════════════════════════════════════════

print("\n\n3. FACTORING VIA BERGGREN DESCENT")
print("-" * 50)

def generate_ppts_with_hyp(max_c):
    """Generate PPTs sorted by hypotenuse."""
    triples = []
    max_m = int(math.sqrt(max_c)) + 1
    for m in range(2, max_m + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0 or gcd(m, n) != 1:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_c:
                break
            triples.append((min(a,b), max(a,b), c))
    return sorted(triples, key=lambda t: t[2])

def ghost_map(a, b, c):
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def berggren_descent(a, b, c):
    """Return the full descent path to (3,4,5)."""
    path = [(a, b, c)]
    current = (a, b, c)
    for _ in range(200):
        if current == (3, 4, 5) or current == (4, 3, 5):
            break
        p, q, h = ghost_map(*current)
        if p > 0 and q < 0:
            current = (p, -q, h)
        elif p > 0 and q > 0:
            current = (p, q, h)
        elif p < 0 and q > 0:
            current = (-p, q, h)
        else:
            break
        path.append(current)
    return path

# Find numbers with multiple PPT representations
hyp_triples = defaultdict(list)
triples = generate_ppts_with_hyp(5000)
for a, b, c in triples:
    hyp_triples[c].append((a, b, c))

print("\n  Hypotenuses with multiple PPT representations:")
multi = {c: ts for c, ts in hyp_triples.items() if len(ts) >= 2}
for c in sorted(multi.keys())[:8]:
    print(f"\n  c = {c} ({len(multi[c])} representations):")
    for a, b, cc in multi[c]:
        path = berggren_descent(a, b, c)
        depth = len(path) - 1
        branches = []
        for i in range(len(path) - 1):
            curr = path[i]
            p, q, h = ghost_map(*curr)
            if p > 0 and q < 0:
                branches.append('1')
            elif p > 0 and q > 0:
                branches.append('2')
            elif p < 0 and q > 0:
                branches.append('3')
            else:
                branches.append('?')
        addr = ''.join(branches)
        print(f"    ({a:4d},{b:4d},{c:4d}): depth={depth:2d}, address={addr}")

# ═══════════════════════════════════════════════════════════════
# 4. Pythagorean Quadruples Extension
# ═══════════════════════════════════════════════════════════════

print("\n\n4. PYTHAGOREAN QUADRUPLES a²+b²+c²=d²")
print("-" * 50)

def find_quadruples(max_d):
    """Find primitive Pythagorean quadruples with d ≤ max_d."""
    quads = []
    for d in range(3, max_d + 1):
        for a in range(1, d):
            for b in range(a, d):
                c_sq = d*d - a*a - b*b
                if c_sq <= 0:
                    break
                c = int(math.sqrt(c_sq))
                if c*c == c_sq and c >= b:
                    if gcd(gcd(a, b), gcd(c, d)) == 1:
                        quads.append((a, b, c, d))
    return quads

quads = find_quadruples(50)
print(f"\n  Primitive quadruples with d ≤ 50: {len(quads)}")
for q in quads[:15]:
    a, b, c, d = q
    print(f"    {a}² + {b}² + {c}² = {d}²  →  {a*a} + {b*b} + {c*c} = {d*d}")

# ═══════════════════════════════════════════════════════════════
# 5. Hyperbolic Distance Interpretation
# ═══════════════════════════════════════════════════════════════

print("\n\n5. HYPERBOLIC DISTANCE INTERPRETATION")
print("-" * 50)
print("  The Lorentz group O(2,1;ℤ) acts on the hyperbolic plane ℍ².")
print("  Each PPT (a,b,c) maps to the point (a/c, b/c) on the unit disk.")
print(f"  The ghost matrix M corresponds to a hyperbolic isometry with")
print(f"  expansion factor 3+2√2 ≈ {3+2*math.sqrt(2):.6f}")
print(f"  Translation length = 2·cosh⁻¹((3+2√2)/2) ≈ {2*math.acosh((3+2*math.sqrt(2))/2):.6f}")

# Map some PPTs to the Poincaré disk
print(f"\n  PPT projections onto Poincaré disk:")
for a, b, c in [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (20,21,29)]:
    x, y = a/c, b/c
    r = math.sqrt(x*x + y*y)
    theta = math.degrees(math.atan2(y, x))
    print(f"    ({a:2d},{b:2d},{c:2d}) → disk({x:.4f}, {y:.4f}), r={r:.4f}, θ={theta:.1f}°")

# ═══════════════════════════════════════════════════════════════
# 6. Eigenvalue Modular Analysis
# ═══════════════════════════════════════════════════════════════

print("\n\n6. CHARACTERISTIC POLYNOMIAL MOD p")
print("-" * 50)
print("  char(M) = λ³ − 5λ² − 5λ + 1 = (λ+1)(λ² − 6λ + 1)")
print("  Discriminant of λ² − 6λ + 1 = 32 = 2⁵")
print("  Roots exist mod p iff 32 is a QR mod p (or p = 2)")

for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
    # Check if 32 is a quadratic residue mod p
    is_qr = any((x*x) % p == 32 % p for x in range(p))
    # Find roots of x² - 6x + 1 mod p
    roots = [x for x in range(p) if (x*x - 6*x + 1) % p == 0]
    order = find_order_mod(M, p)
    print(f"  p={p:2d}: 32 QR? {'Y' if is_qr else 'N'}, "
          f"quad roots mod p: {roots}, order(M)={order}")

print("\n" + "=" * 70)
print("Exploration complete!")
print("=" * 70)
