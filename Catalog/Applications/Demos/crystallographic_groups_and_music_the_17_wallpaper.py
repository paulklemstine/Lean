#!/usr/bin/env python3
"""
Crystallographic Rhythm Theory — Demo
Demonstrates the main results: crystallographic restriction, necklace counting,
and involution product structure.
"""

from math import gcd
from functools import reduce
from itertools import product as cartprod

def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    if n <= 0:
        return 0
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result

def crystallographic_orders(max_n: int = 100) -> list[int]:
    """Find all n with φ(n) ≤ 2."""
    return [n for n in range(1, max_n + 1) if euler_totient(n) <= 2]

def necklace_count(p: int) -> int:
    """Number of distinct binary necklaces of length p (Burnside formula for prime p)."""
    return (2**p + 2*p - 2) // p

def all_necklaces(n: int) -> list[tuple[int, ...]]:
    """Generate all distinct binary necklaces of length n."""
    seen = set()
    necklaces = []
    for bits in cartprod([0, 1], repeat=n):
        # Canonical form: minimum rotation
        rotations = tuple(min(bits[i:] + bits[:i] for i in range(n)))
        if rotations not in seen:
            seen.add(rotations)
            necklaces.append(rotations)
    return sorted(necklaces)

def is_palindromic(rhythm: tuple[int, ...]) -> bool:
    """Check if a rhythm is palindromic (mirror-symmetric)."""
    return rhythm == rhythm[::-1]

def has_kfold_symmetry(rhythm: tuple[int, ...], k: int) -> bool:
    """Check if a rhythm has k-fold rotational symmetry."""
    n = len(rhythm)
    if n % k != 0:
        return False
    shift = n // k
    return all(rhythm[i] == rhythm[(i + shift) % n] for i in range(n))

def symmetry_order(rhythm: tuple[int, ...]) -> int:
    """Find the maximum rotational symmetry order of a rhythm."""
    n = len(rhythm)
    max_k = 1
    for k in range(2, n + 1):
        if n % k == 0 and has_kfold_symmetry(rhythm, k):
            max_k = k
    return max_k

# ═══════════════════════════════════════════════════════════════
# Demo 1: Crystallographic Restriction
# ═══════════════════════════════════════════════════════════════
print("=" * 60)
print("DEMO 1: Crystallographic Restriction via Euler's Totient")
print("=" * 60)
print()
print("The crystallographic restriction theorem states:")
print("  φ(n) ≤ 2  ⟺  n ∈ {1, 2, 3, 4, 6}")
print()
print("Verification:")
for n in range(1, 13):
    phi = euler_totient(n)
    is_cryst = phi <= 2
    marker = " ✓ crystallographic" if is_cryst else ""
    print(f"  φ({n:2d}) = {phi:2d}{marker}")

cryst = crystallographic_orders()
print(f"\nAll n ≤ 100 with φ(n) ≤ 2: {cryst}")
print(f"This confirms the theorem: exactly {{1, 2, 3, 4, 6}}.")

# ═══════════════════════════════════════════════════════════════
# Demo 2: Necklace Counting
# ═══════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("DEMO 2: Necklace Counting (Rhythms up to Rotation)")
print("=" * 60)
print()
print("For prime p, distinct rhythms = (2^p + 2p - 2) / p")
print()
primes = [2, 3, 5, 7, 11, 13]
for p in primes:
    nc = necklace_count(p)
    # Verify by enumeration for small p
    if p <= 7:
        actual = len(all_necklaces(p))
        assert nc == actual, f"Mismatch for p={p}: formula={nc}, actual={actual}"
        print(f"  p={p:2d}: N(p) = {nc:5d}  (verified by enumeration)")
    else:
        print(f"  p={p:2d}: N(p) = {nc:5d}")

print()
print("Lower bound verification: N(p) ≥ p + 1 for prime p ≥ 3")
for p in [3, 5, 7, 11, 13, 17, 19]:
    nc = necklace_count(p)
    print(f"  N({p:2d}) = {nc:5d} ≥ {p+1:3d}  {'✓' if nc >= p + 1 else '✗'}")

# ═══════════════════════════════════════════════════════════════
# Demo 3: Rhythm Symmetry Classification
# ═══════════════════════════════════════════════════════════════
print()
print("=" * 60)
print("DEMO 3: Rhythm Symmetry Classification")
print("=" * 60)
print()

for n in [4, 6, 8]:
    necklaces = all_necklaces(n)
    print(f"Length {n}: {len(necklaces)} distinct necklaces")
    sym_counts: dict[int, int] = {}
    for nk in necklaces:
        k = symmetry_order(nk)
        sym_counts[k] = sym_counts.get(k, 0) + 1

    for k in sorted(sym_counts.keys()):
        print(f"  {k}-fold symmetry: {sym_counts[k]} rhythms")

    pal_count = sum(1 for nk in necklaces if is_palindromic(nk))
    print(f"  Palindromic: {pal_count} rhythms")
    print()

# ═══════════════════════════════════════════════════════════════
# Demo 4: Involution Product
# ═══════════════════════════════════════════════════════════════
print("=" * 60)
print("DEMO 4: Involution Product Structure")
print("=" * 60)
print()
print("In the dihedral group D_n, reflections σ, τ satisfy:")
print("  - σ² = τ² = 1 (involutions)")
print("  - If στ = τσ (commuting), then (στ)² = 1")
print("  - [σ,τ] = (στ)²")
print()

# Demonstrate with 2x2 reflection matrices
import math

def mat_mul(a, b):
    return [[sum(a[i][k]*b[k][j] for k in range(2)) for j in range(2)] for i in range(2)]

def mat_inv_2x2(m):
    det = m[0][0]*m[1][1] - m[0][1]*m[1][0]
    return [[m[1][1]/det, -m[0][1]/det], [-m[1][0]/det, m[0][0]/det]]

def mat_close(a, b, tol=1e-10):
    return all(abs(a[i][j]-b[i][j])<tol for i in range(2) for j in range(2))

def reflection_matrix(angle):
    c, s = math.cos(2*angle), math.sin(2*angle)
    return [[c, s], [s, -c]]

IDENTITY = [[1,0],[0,1]]

for angle_deg in [0, 30, 45, 60, 90]:
    angle = math.radians(angle_deg)
    sigma = reflection_matrix(0)
    tau = reflection_matrix(angle)
    product = mat_mul(sigma, tau)
    product_sq = mat_mul(product, product)
    is_identity = mat_close(product_sq, IDENTITY)
    commutator = mat_mul(mat_mul(mat_inv_2x2(sigma), mat_inv_2x2(tau)), mat_mul(sigma, tau))
    comm_eq_sq = mat_close(commutator, product_sq)

    print(f"  Angle between mirrors: {angle_deg}°")
    print(f"    (στ)² = I? {is_identity}  (commuting involutions → involution product)")
    print(f"    [σ,τ] = (στ)²? {comm_eq_sq}")
    print()

# ═══════════════════════════════════════════════════════════════
# Demo 5: Wallpaper Distribution
# ═══════════════════════════════════════════════════════════════
print("=" * 60)
print("DEMO 5: Wallpaper Type Distribution")
print("=" * 60)
print()

wallpaper_types = {
    1: ["p1", "pm", "pg", "cm"],
    2: ["p2", "pmm", "pmg", "pgg", "cmm"],
    3: ["p3", "p3m1", "p31m"],
    4: ["p4", "p4m", "p4g"],
    6: ["p6", "p6m"],
}

total = 0
for order in sorted(wallpaper_types.keys()):
    types = wallpaper_types[order]
    total += len(types)
    print(f"  Order {order}: {len(types)} types — {', '.join(types)}")

print(f"\n  Total: {total} wallpaper groups")
print(f"  Crystallographic orders: {sorted(wallpaper_types.keys())}")
print(f"  Note: order 5 is absent because φ(5) = {euler_totient(5)} > 2")


#!/usr/bin/env python3
"""Visualization: Necklace count growth for prime-length rhythms."""
import matplotlib.pyplot as plt
import numpy as np

def euler_totient(n):
    if n <= 0: return 0
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0: temp //= p
            result -= result // p
        p += 1
    if temp > 1: result -= result // temp
    return result

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

def necklace_count_general(n):
    total = 0
    for d in range(1, n+1):
        if n % d == 0:
            total += euler_totient(n // d) * (2**d)
    return total // n

primes = [p for p in range(2, 50) if is_prime(p)]
composites = [n for n in range(4, 50) if not is_prime(n) and n > 1]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Necklace count growth
ax1 = axes[0]
ns = list(range(1, 25))
counts = [necklace_count_general(n) for n in ns]
prime_ns = [n for n in ns if is_prime(n)]
prime_counts = [necklace_count_general(n) for n in prime_ns]

ax1.bar(ns, counts, color='steelblue', alpha=0.7, label='All n')
ax1.bar(prime_ns, prime_counts, color='crimson', alpha=0.8, label='Prime n')
ax1.set_xlabel('Rhythm length n', fontsize=12)
ax1.set_ylabel('Number of distinct rhythms N(n)', fontsize=12)
ax1.set_title('Binary Necklace Count by Length', fontsize=14)
ax1.legend(fontsize=11)
ax1.set_yscale('log')

# Right: Crystallographic restriction visualization
ax2 = axes[1]
ns2 = list(range(1, 20))
phis = [euler_totient(n) for n in ns2]
colors = ['#2ecc71' if euler_totient(n) <= 2 else '#e74c3c' for n in ns2]

bars = ax2.bar(ns2, phis, color=colors, alpha=0.8)
ax2.axhline(y=2, color='black', linestyle='--', linewidth=2, label='φ(n) = 2 threshold')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('φ(n)', fontsize=12)
ax2.set_title('Crystallographic Restriction:\nφ(n) ≤ 2 ⟺ n ∈ {1,2,3,4,6}', fontsize=14)
ax2.legend(fontsize=11)

# Add annotations for crystallographic orders
for n in [1, 2, 3, 4, 6]:
    ax2.annotate(f'n={n}', xy=(n, euler_totient(n)),
                xytext=(n, euler_totient(n) + 1),
                fontsize=9, ha='center', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='green'))

plt.tight_layout()
plt.savefig('viz_necklace_growth.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved viz_necklace_growth.png")


#!/usr/bin/env python3
"""Visualization: Distribution of 17 wallpaper types across crystallographic orders."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

wallpaper_data = {
    1: {"types": ["p1", "pm", "pg", "cm"],
        "labels": ["Free\nrhythm", "Palin-\ndrome", "Canon", "Round"]},
    2: {"types": ["p2", "pmm", "pmg", "pgg", "cmm"],
        "labels": ["Call &\nresponse", "Bilateral\npalindrome", "Inverted\ncanon",
                   "Double\ncanon", "Round +\npalindrome"]},
    3: {"types": ["p3", "p3m1", "p31m"],
        "labels": ["3-bar\nblues", "3-fold\n+mirrors", "3-fold\n+glides"]},
    4: {"types": ["p4", "p4m", "p4g"],
        "labels": ["4-bar\ncycle", "Variations", "Inverted\nvariations"]},
    6: {"types": ["p6", "p6m"],
        "labels": ["Whole-\ntone", "Maximal\nsymmetry"]},
}

colors_by_order = {
    1: '#3498db',
    2: '#e74c3c',
    3: '#2ecc71',
    4: '#9b59b6',
    6: '#f39c12',
}

fig, ax = plt.subplots(figsize=(16, 8))

y_pos = 0
y_positions = {}
patches_legend = []

for order in [1, 2, 3, 4, 6]:
    data = wallpaper_data[order]
    n_types = len(data["types"])
    color = colors_by_order[order]

    for i, (wtype, label) in enumerate(zip(data["types"], data["labels"])):
        x = i
        rect = mpatches.FancyBboxPatch((x * 2.2, y_pos), 1.8, 1.5,
                                        boxstyle="round,pad=0.1",
                                        facecolor=color, alpha=0.7,
                                        edgecolor='black', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x * 2.2 + 0.9, y_pos + 0.95, wtype,
               ha='center', va='center', fontsize=11, fontweight='bold', color='white')
        ax.text(x * 2.2 + 0.9, y_pos + 0.4, label,
               ha='center', va='center', fontsize=7, color='white')

    ax.text(-1.5, y_pos + 0.75, f'Order {order}\n({n_types} types)',
           ha='center', va='center', fontsize=12, fontweight='bold',
           color=color)

    y_pos -= 2.2

ax.set_xlim(-3, 12)
ax.set_ylim(y_pos - 0.5, 2)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('The 17 Wallpaper Groups: Distribution by Rotation Order\n'
            '4 + 5 + 3 + 3 + 2 = 17', fontsize=16, fontweight='bold')

# Add the crystallographic restriction note
ax.text(8, -9.5,
       'Crystallographic Restriction:\n'
       'φ(n) ≤ 2 ⟺ n ∈ {1,2,3,4,6}\n'
       'No order-5 wallpaper groups exist\n'
       'because φ(5) = 4 > 2',
       fontsize=10, ha='center', va='center',
       bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='gray'))

plt.tight_layout()
plt.savefig('viz_wallpaper_distribution.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved viz_wallpaper_distribution.png")
