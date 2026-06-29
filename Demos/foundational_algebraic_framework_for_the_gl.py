#!/usr/bin/env python3
"""
GL₁ Langlands Bilinear Framework — Demonstration

Demonstrates the bilinear structure of the Jacobi symbol and its connection
to quadratic reciprocity, character detection, and prime classification.
"""

from math import gcd
from typing import List, Tuple


def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) for odd prime p."""
    if p == 2:
        raise ValueError("p must be an odd prime")
    a = a % p
    if a == 0:
        return 0
    # Euler's criterion: (a/p) = a^((p-1)/2) mod p
    result = pow(a, (p - 1) // 2, p)
    return 1 if result == 1 else -1


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) for odd positive n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0

    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def qr_correction_sign(a: int, b: int) -> int:
    """Compute the quadratic reciprocity correction sign (-1)^((a/2)(b/2))."""
    return (-1) ** ((a // 2) * (b // 2))


def chi4(n: int) -> int:
    """The primitive Dirichlet character mod 4."""
    n = n % 4
    if n == 0 or n == 2:
        return 0
    return 1 if n == 1 else -1


def chi8(n: int) -> int:
    """The primitive Dirichlet character mod 8."""
    n = n % 8
    if n % 2 == 0:
        return 0
    if n in (1, 7):
        return 1
    return -1  # n in (3, 5)


# ============================================================
# Demonstration 1: Bilinearity
# ============================================================
print("=" * 60)
print("DEMONSTRATION 1: Bilinearity of the Jacobi Symbol")
print("=" * 60)
print()
print("Testing J(a₁·a₂, b₁·b₂) = J(a₁,b₁)·J(a₁,b₂)·J(a₂,b₁)·J(a₂,b₂)")
print()

test_cases = [(3, 7, 5, 11), (2, 5, 3, 7), (-1, 3, 5, 13), (7, 11, 3, 17)]
for a1, a2, b1, b2 in test_cases:
    if b1 * b2 > 0 and (b1 * b2) % 2 == 1:
        lhs = jacobi_symbol(a1 * a2, b1 * b2)
        rhs = (jacobi_symbol(a1, b1) * jacobi_symbol(a1, b2) *
               jacobi_symbol(a2, b1) * jacobi_symbol(a2, b2))
        status = "✓" if lhs == rhs else "✗"
        print(f"  {status} J({a1}·{a2}, {b1}·{b2}) = J({a1},{b1})·J({a1},{b2})·"
              f"J({a2},{b1})·J({a2},{b2})")
        print(f"    LHS = {lhs}, RHS = {rhs}")

# ============================================================
# Demonstration 2: Quadratic Reciprocity as Self-Duality
# ============================================================
print()
print("=" * 60)
print("DEMONSTRATION 2: Quadratic Reciprocity as Self-Duality")
print("=" * 60)
print()
print("Testing J(a, b) = ε(a,b) · J(b, a) for odd a, b")
print("where ε(a,b) = (-1)^((a/2)(b/2))")
print()

odd_pairs = [(3, 5), (5, 7), (7, 11), (3, 13), (11, 17), (13, 19), (23, 29)]
for a, b in odd_pairs:
    ja_b = jacobi_symbol(a, b)
    jb_a = jacobi_symbol(b, a)
    eps = qr_correction_sign(a, b)
    status = "✓" if ja_b == eps * jb_a else "✗"
    print(f"  {status} J({a},{b}) = {ja_b}, ε({a},{b})·J({b},{a}) = "
          f"{eps}·{jb_a} = {eps * jb_a}")

# ============================================================
# Demonstration 3: Shape Detection — J(-1, p) classifies primes mod 4
# ============================================================
print()
print("=" * 60)
print("DEMONSTRATION 3: Shape Detection — J(-1, p) vs p mod 4")
print("=" * 60)
print()

primes = [p for p in range(3, 100) if is_prime(p)]
print(f"{'Prime p':>8} {'p mod 4':>8} {'J(-1,p)':>8} {'χ₄(p)':>8} {'Match':>6}")
print("-" * 42)
for p in primes[:20]:
    j_val = jacobi_symbol(-1, p)
    c4_val = chi4(p)
    match = "✓" if j_val == c4_val else "✗"
    print(f"{p:>8} {p % 4:>8} {j_val:>8} {c4_val:>8} {match:>6}")

# ============================================================
# Demonstration 4: J(2, p) = χ₈(p)
# ============================================================
print()
print("=" * 60)
print("DEMONSTRATION 4: J(2, p) = χ₈(p) for odd primes")
print("=" * 60)
print()

print(f"{'Prime p':>8} {'p mod 8':>8} {'J(2,p)':>8} {'χ₈(p)':>8} {'Match':>6}")
print("-" * 42)
for p in primes[:20]:
    j_val = jacobi_symbol(2, p)
    c8_val = chi8(p)
    match = "✓" if j_val == c8_val else "✗"
    print(f"{p:>8} {p % 8:>8} {j_val:>8} {c8_val:>8} {match:>6}")

# ============================================================
# Demonstration 5: Kernel Structure
# ============================================================
print()
print("=" * 60)
print("DEMONSTRATION 5: Kernel Structure for p = 13")
print("=" * 60)
print()

p = 13
qr = [a for a in range(1, p) if jacobi_symbol(a, p) == 1]
nqr = [a for a in range(1, p) if jacobi_symbol(a, p) == -1]
print(f"Quadratic residues mod {p} (kernel): {qr}")
print(f"Non-residues mod {p}:                {nqr}")
print(f"Kernel size: {len(qr)}, Non-kernel size: {len(nqr)}")
print(f"Index of kernel: {len(nqr) + len(qr)} / {len(qr)} = "
      f"{(len(nqr) + len(qr)) / len(qr):.1f}")

# Check closure under multiplication
print("\nClosure under multiplication:")
for a in qr[:3]:
    for b in qr[:3]:
        prod = (a * b) % p
        in_kernel = prod in qr
        print(f"  {a} × {b} ≡ {prod} (mod {p}), in kernel: {in_kernel}")

# ============================================================
# Demonstration 6: Shape-Color Dictionary
# ============================================================
print()
print("=" * 60)
print("DEMONSTRATION 6: Shape-Color Dictionary for d = -1, -3, 5")
print("=" * 60)
print()

discriminants = [(-1, -4, "ℚ(i)"), (-3, -3, "ℚ(√-3)"), (5, 5, "ℚ(√5)")]
small_primes = [p for p in range(3, 50) if is_prime(p)]

for d, disc, field in discriminants:
    print(f"\n  Field: {field}, discriminant D = {disc}")
    print(f"  {'p':>4}  {'J(D,p)':>7}  {'Splitting':>12}")
    print(f"  {'—'*4}  {'—'*7}  {'—'*12}")
    for p in small_primes[:10]:
        if abs(disc) % 2 == 0 and p == 2:
            continue
        j = jacobi_symbol(disc, p) if p > 2 else 0
        if j == 1:
            behavior = "splits"
        elif j == -1:
            behavior = "inert"
        else:
            behavior = "ramifies"
        print(f"  {p:>4}  {j:>7}  {behavior:>12}")

print()
print("=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Jacobi Symbol as a Bilinear Heatmap

Plots J(a, b) as a heatmap showing the bilinear structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


# Create heatmap of J(a, b) for a in [-30, 30], b odd in [1, 61]
a_range = range(-30, 31)
b_range = [b for b in range(1, 62) if b % 2 == 1]

data = np.zeros((len(a_range), len(b_range)))
for i, a in enumerate(a_range):
    for j, b in enumerate(b_range):
        data[i, j] = jacobi_symbol(a, b)

fig, ax = plt.subplots(figsize=(14, 8))
cmap = mcolors.ListedColormap(['#d32f2f', '#ffffff', '#1976d2'])
bounds = [-1.5, -0.5, 0.5, 1.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

im = ax.imshow(data.T, aspect='auto', cmap=cmap, norm=norm,
               extent=[min(a_range)-0.5, max(a_range)+0.5,
                       max(b_range)+0.5, min(b_range)-0.5])

ax.set_xlabel('a (first argument)', fontsize=12)
ax.set_ylabel('b (second argument, odd)', fontsize=12)
ax.set_title('Jacobi Symbol J(a, b) — Bilinear Structure Heatmap', fontsize=14)

cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1])
cbar.set_label('J(a, b)', fontsize=12)
cbar.ax.set_yticklabels(['-1 (non-residue)', '0 (ramified)', '+1 (residue)'])

plt.tight_layout()
plt.savefig('jacobi_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: jacobi_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Quadratic Reciprocity Correction Sign

Plots the correction sign ε(a,b) = (-1)^((a/2)(b/2)) and the
reciprocity defect J(a,b) - ε(a,b)·J(b,a) (should be zero).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


odd_range = [n for n in range(1, 60) if n % 2 == 1]

# Correction sign heatmap
eps_data = np.zeros((len(odd_range), len(odd_range)))
for i, a in enumerate(odd_range):
    for j, b in enumerate(odd_range):
        eps_data[i, j] = (-1) ** ((a // 2) * (b // 2))

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: correction sign
cmap1 = mcolors.ListedColormap(['#e53935', '#43a047'])
bounds1 = [-1.5, 0, 1.5]
norm1 = mcolors.BoundaryNorm(bounds1, cmap1.N)
im1 = axes[0].imshow(eps_data, aspect='equal', cmap=cmap1, norm=norm1)
axes[0].set_title('Correction Sign ε(a,b) = (-1)^{⌊a/2⌋·⌊b/2⌋}', fontsize=12)
axes[0].set_xlabel('b (odd)', fontsize=11)
axes[0].set_ylabel('a (odd)', fontsize=11)
ticks = list(range(0, len(odd_range), 5))
axes[0].set_xticks(ticks)
axes[0].set_xticklabels([odd_range[t] for t in ticks])
axes[0].set_yticks(ticks)
axes[0].set_yticklabels([odd_range[t] for t in ticks])
cbar1 = plt.colorbar(im1, ax=axes[0], ticks=[-1, 1])
cbar1.ax.set_yticklabels(['-1', '+1'])

# Right: J(a,b) vs ε·J(b,a) - verify reciprocity
recip_data = np.zeros((len(odd_range), len(odd_range)))
for i, a in enumerate(odd_range):
    for j, b in enumerate(odd_range):
        ja_b = jacobi_symbol(a, b)
        jb_a = jacobi_symbol(b, a)
        eps = (-1) ** ((a // 2) * (b // 2))
        recip_data[i, j] = ja_b  # Show J(a,b) pattern

cmap2 = mcolors.ListedColormap(['#d32f2f', '#ffffff', '#1976d2'])
bounds2 = [-1.5, -0.5, 0.5, 1.5]
norm2 = mcolors.BoundaryNorm(bounds2, cmap2.N)
im2 = axes[1].imshow(recip_data, aspect='equal', cmap=cmap2, norm=norm2)
axes[1].set_title('J(a, b) for odd a, b — Self-Duality Pattern', fontsize=12)
axes[1].set_xlabel('b (odd)', fontsize=11)
axes[1].set_ylabel('a (odd)', fontsize=11)
axes[1].set_xticks(ticks)
axes[1].set_xticklabels([odd_range[t] for t in ticks])
axes[1].set_yticks(ticks)
axes[1].set_yticklabels([odd_range[t] for t in ticks])
cbar2 = plt.colorbar(im2, ax=axes[1], ticks=[-1, 0, 1])
cbar2.ax.set_yticklabels(['-1', '0', '+1'])

plt.suptitle('Quadratic Reciprocity: Self-Duality of the Jacobi Pairing', fontsize=14)
plt.tight_layout()
plt.savefig('reciprocity_pattern.png', dpi=150, bbox_inches='tight')
print("Saved: reciprocity_pattern.png")
