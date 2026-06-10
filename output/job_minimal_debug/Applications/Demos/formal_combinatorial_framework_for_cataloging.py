#!/usr/bin/env python3
"""
L-Function Census: Computational Demonstrations

Demonstrates the combinatorial framework for cataloging L-functions
in the Selberg class via their invariant data (degree, conductor,
spectral parameters).
"""

from math import log2, floor


def conductor_count(d: int, Q: int, B: int) -> int:
    """Count Selberg data with given degree, conductor ≤ Q, shifts ≤ B.
    
    N_d(Q, B) = Q * (2*(2B+1))^d
    """
    return Q * ((2 * (2 * B + 1)) ** d)


def spectral_complexity(shifts: list[int]) -> int:
    """Sum of absolute values of spectral shifts."""
    return sum(abs(s) for s in shifts)


def spectral_entropy(shifts: list[int]) -> int:
    """Number of distinct absolute shift values."""
    return len(set(abs(s) for s in shifts))


def analytic_conductor(q: int, shifts: list[int]) -> float:
    """Analytic conductor C(F) = q * prod(|mu_j| + 3)."""
    prod = 1
    for s in shifts:
        prod *= abs(s) + 3
    return q * prod


# =============================================================
# Demo 1: Counting function growth
# =============================================================
print("=" * 60)
print("Demo 1: Conductor Counting Function N_d(Q, B)")
print("=" * 60)
print()

B = 5
for d in range(0, 6):
    counts = [(Q, conductor_count(d, Q, B)) for Q in [10, 100, 1000]]
    print(f"  degree d={d}, B={B}:")
    for Q, N in counts:
        print(f"    Q={Q:>4}: N_{d}(Q,{B}) = {N:>12,}")
    print()

# =============================================================
# Demo 2: Verify degree-1 formula
# =============================================================
print("=" * 60)
print("Demo 2: Degree-1 Counting Formula Verification")
print("=" * 60)
print()

Q, B = 100, 5
predicted = Q * (2 * (2 * B + 1))
actual = conductor_count(1, Q, B)
print(f"  Q={Q}, B={B}")
print(f"  Predicted: Q * 2*(2B+1) = {Q} * {2*(2*B+1)} = {predicted}")
print(f"  Actual N_1(Q,B) = {actual}")
print(f"  Match: {predicted == actual}")
print()

# =============================================================
# Demo 3: Product factorization identity
# =============================================================
print("=" * 60)
print("Demo 3: Product Factorization Identity")
print("=" * 60)
print()

print("  N_{d1+d2}(Q,B) = N_{d1}(1,B) * N_{d2}(Q,B)")
print()

for d1 in range(1, 4):
    for d2 in range(1, 4):
        Q, B = 50, 3
        lhs = conductor_count(d1 + d2, Q, B)
        rhs = conductor_count(d1, 1, B) * conductor_count(d2, Q, B)
        status = "✓" if lhs == rhs else "✗"
        print(f"  {status} d1={d1}, d2={d2}: LHS={lhs:>10,}  RHS={rhs:>10,}")
print()

# =============================================================
# Demo 4: Spectral complexity additivity
# =============================================================
print("=" * 60)
print("Demo 4: Spectral Complexity Additivity")
print("=" * 60)
print()

examples = [
    ([1, -2, 3], [0, 4]),
    ([5, -5], [1, 1, 1]),
    ([0, 0, 0], [10]),
]

for shifts1, shifts2 in examples:
    c1 = spectral_complexity(shifts1)
    c2 = spectral_complexity(shifts2)
    combined = shifts1 + shifts2
    c_prod = spectral_complexity(combined)
    print(f"  χ({shifts1}) = {c1}")
    print(f"  χ({shifts2}) = {c2}")
    print(f"  χ(product) = χ({combined}) = {c_prod}")
    print(f"  Additive: {c_prod} = {c1} + {c2} = {c1+c2}  ✓={c_prod == c1+c2}")
    print()

# =============================================================
# Demo 5: Spectral entropy subadditivity
# =============================================================
print("=" * 60)
print("Demo 5: Spectral Entropy Subadditivity")
print("=" * 60)
print()

entropy_examples = [
    ([1, 2, 3], [2, 3, 4]),
    ([1, 1, 1], [2, 2, 2]),
    ([0, 1, 2, 3], [0, 1]),
]

for shifts1, shifts2 in entropy_examples:
    e1 = spectral_entropy(shifts1)
    e2 = spectral_entropy(shifts2)
    combined = shifts1 + shifts2
    e_prod = spectral_entropy(combined)
    print(f"  H({shifts1}) = {e1}, H({shifts2}) = {e2}")
    print(f"  H(product) = {e_prod} ≤ {e1} + {e2} = {e1+e2}  ✓={e_prod <= e1+e2}")
    print()

# =============================================================
# Demo 6: Growth rate analysis
# =============================================================
print("=" * 60)
print("Demo 6: Growth Rate Analysis")
print("=" * 60)
print()

B = 5
base = 2 * (2 * B + 1)
print(f"  Base = 2*(2*{B}+1) = {base}")
print(f"  For fixed B={B}, N_d(Q,B) = Q * {base}^d")
print()
print(f"  {'d':>3} | {'base^d':>15} | {'log2(base^d)':>12}")
print(f"  {'-'*3}-+-{'-'*15}-+-{'-'*12}")
for d in range(1, 8):
    val = base ** d
    log_val = d * log2(base)
    print(f"  {d:>3} | {val:>15,} | {log_val:>12.2f}")

print()
print("  Growth is exponential in degree d (fixed B),")
print("  but linear in conductor bound Q.")


#!/usr/bin/env python3
"""
Visualization: Conductor Counting Function Growth

Plots the counting function N_d(Q, B) as a function of Q
for various degrees d, showing the polynomial growth.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def conductor_count(d: int, Q: int, B: int) -> int:
    return Q * ((2 * (2 * B + 1)) ** d)


def main():
    B = 5
    Q_values = np.arange(1, 101)
    degrees = [1, 2, 3, 4]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Linear scale
    ax1 = axes[0]
    for d in degrees:
        counts = [conductor_count(d, int(Q), B) for Q in Q_values]
        ax1.plot(Q_values, counts, label=f'd={d}', linewidth=2)
    ax1.set_xlabel('Conductor bound Q', fontsize=12)
    ax1.set_ylabel('N_d(Q, B)', fontsize=12)
    ax1.set_title(f'Counting Function (B={B}, linear scale)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Log scale
    ax2 = axes[1]
    for d in degrees:
        counts = [conductor_count(d, int(Q), B) for Q in Q_values]
        ax2.plot(Q_values, counts, label=f'd={d}', linewidth=2)
    ax2.set_xlabel('Conductor bound Q', fontsize=12)
    ax2.set_ylabel('N_d(Q, B)', fontsize=12)
    ax2.set_title(f'Counting Function (B={B}, log scale)', fontsize=14)
    ax2.set_yscale('log')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('counting_growth.png', dpi=150, bbox_inches='tight')
    print("Saved counting_growth.png")

    # Second figure: growth in B for fixed d
    fig2, ax3 = plt.subplots(figsize=(8, 6))
    B_values = np.arange(0, 21)
    Q = 100
    for d in [1, 2, 3, 4]:
        counts = [conductor_count(d, Q, int(b)) for b in B_values]
        ax3.plot(B_values, counts, 'o-', label=f'd={d}', linewidth=2, markersize=4)
    ax3.set_xlabel('Spectral bound B', fontsize=12)
    ax3.set_ylabel('N_d(Q, B)', fontsize=12)
    ax3.set_title(f'Counting Function vs Spectral Bound (Q={Q})', fontsize=14)
    ax3.set_yscale('log')
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectral_growth.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_growth.png")


if __name__ == "__main__":
    main()
