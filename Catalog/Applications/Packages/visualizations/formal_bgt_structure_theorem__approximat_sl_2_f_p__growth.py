"""
Visualization: Growth in SL(2, F_p)

Shows product set growth in the special linear group SL(2, F_p)
for small primes. Demonstrates that elementary matrix generators
produce rapid expansion, consistent with Helfgott's theorem.
"""

import matplotlib.pyplot as plt
import numpy as np


def mat_mul_mod(A, B, p):
    """2x2 matrix multiplication mod p."""
    return (
        (A[0]*B[0] + A[1]*B[2]) % p,
        (A[0]*B[1] + A[1]*B[3]) % p,
        (A[2]*B[0] + A[3]*B[2]) % p,
        (A[2]*B[1] + A[3]*B[3]) % p
    )


def mat_inv(M, p):
    """Inverse of 2x2 matrix with det=1 in F_p."""
    return (M[3] % p, (-M[1]) % p, (-M[2]) % p, M[0] % p)


def sl2_product_set(A_set, B_set, p):
    """Product set of matrix sets."""
    return {mat_mul_mod(a, b, p) for a in A_set for b in B_set}


def sl2_generators(p):
    """Standard generators: I, E12, E21, E12⁻¹, E21⁻¹."""
    I = (1, 0, 0, 1)
    E12 = (1, 1, 0, 1)
    E21 = (1, 0, 1, 1)
    E12_inv = mat_inv(E12, p)
    E21_inv = mat_inv(E21, p)
    return {I, E12, E21, E12_inv, E21_inv}


def sl2_size(p):
    """Order of SL(2, F_p)."""
    return p * (p * p - 1)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Growth sequences for different primes
ax = axes[0]
primes = [3, 5, 7]
colors = ['#2196F3', '#FF5722', '#4CAF50']

for p, color in zip(primes, colors):
    gens = sl2_generators(p)
    sizes = [len(gens)]
    current = gens
    
    for k in range(1, 30):
        next_set = sl2_product_set(current, gens, p)
        sizes.append(len(next_set))
        if len(next_set) == len(current):
            break
        current = next_set
    
    group_size = sl2_size(p)
    # Normalize by group size
    normalized = [s / group_size for s in sizes]
    steps = list(range(1, len(sizes) + 1))
    
    ax.plot(steps, normalized, 'o-', color=color, markersize=4, linewidth=2,
            label=f'SL(2, F_{p}), |G|={group_size}')
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.3)

ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^k| / |G|', fontsize=12)
ax.set_title('Growth in SL(2, F_p)\n(Normalized by group order)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.1)

# Right: Growth ratios
ax = axes[1]

for p, color in zip(primes, colors):
    gens = sl2_generators(p)
    sizes = [len(gens)]
    current = gens
    
    for k in range(1, 30):
        next_set = sl2_product_set(current, gens, p)
        sizes.append(len(next_set))
        if len(next_set) == len(current):
            break
        current = next_set
    
    ratios = [sizes[k]/sizes[k-1] for k in range(1, len(sizes)) if sizes[k-1] > 0]
    steps = list(range(1, len(ratios) + 1))
    
    ax.plot(steps, ratios, 's-', color=color, markersize=5, linewidth=2,
            label=f'SL(2, F_{p})')

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='No growth')
ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^{k+1}| / |A^k|', fontsize=12)
ax.set_title('Growth Ratios in SL(2, F_p)\n(Rapid initial expansion)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('sl2_growth.png', dpi=150, bbox_inches='tight')
print("Saved sl2_growth.png")
