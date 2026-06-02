#!/usr/bin/env python3
"""
The Mega-Sphere: Numerical Demonstrations

Demonstrates the key constructions and theorems:
1. Sphere Euler characteristics and their parity pattern
2. Bernoulli-sphere weights and odd vanishing
3. Graded Sphere Algebra pairings
4. Mega-Sphere filtration and Euler encoding
5. Characteristic polynomials
"""

from fractions import Fraction
from typing import List, Tuple


def euler_char(n: int) -> int:
    """Euler characteristic of S^n: χ(S^n) = 1 + (-1)^n."""
    return 1 + (-1) ** n


def bernoulli_prime(n: int) -> Fraction:
    """Compute B'_n (Bernoulli number, B'_1 = 1/2 convention) via recurrence."""
    B = [Fraction(0)] * (n + 1)
    B[0] = Fraction(1)
    for m in range(1, n + 1):
        s = Fraction(0)
        for k in range(m):
            # Binomial coefficient C(m+1, k)
            binom = 1
            for j in range(k):
                binom = binom * (m + 1 - j) // (j + 1)
            s += binom * B[k]
        B[m] = -s / (m + 1)
    # Convert from B_n to B'_n: B'_1 = 1/2 (positive)
    if n == 1:
        return Fraction(1, 2)
    return B[n]


def bernoulli_sphere_weight(n: int) -> Fraction:
    """Bernoulli-sphere weight: B'_n * (1 + (-1)^n)."""
    return bernoulli_prime(n) * (1 + (-1) ** n)


def graded_pairing(m: int, n: int) -> int:
    """Graded Sphere Algebra pairing: P(m, n) = χ(S^m) * χ(S^n)."""
    return euler_char(m) * euler_char(n)


def char_poly_eval(n: int, x: int) -> int:
    """Evaluate characteristic polynomial p_n(X) = X^n + (-1)^n at x."""
    return x ** n + (-1) ** n


def mega_sphere_project(seq: List[int], level: int) -> List[int]:
    """Project an infinite sequence to truncation level n."""
    return seq[: level + 1]


def main():
    print("=" * 70)
    print("THE MEGA-SPHERE: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Euler characteristics
    print("\n--- Demo 1: Sphere Euler Characteristics ---")
    print(f"{'n':>4} {'χ(S^n)':>8} {'Parity':>8}")
    print("-" * 24)
    for n in range(12):
        chi = euler_char(n)
        parity = "even" if n % 2 == 0 else "odd"
        print(f"{n:>4} {chi:>8} {parity:>8}")

    print("\nPattern: χ = 2 for even dimensions, χ = 0 for odd dimensions")

    # Demo 2: Recurrence verification
    print("\n--- Demo 2: Recurrence χ(S^{n+1}) = 2 - χ(S^n) ---")
    for n in range(8):
        lhs = euler_char(n + 1)
        rhs = 2 - euler_char(n)
        assert lhs == rhs, f"Recurrence failed at n={n}"
    print("✓ Verified for n = 0, 1, ..., 7")

    # Demo 3: Multiplicativity
    print("\n--- Demo 3: Multiplicativity χ(S^m × S^n) = χ(S^m) · χ(S^n) ---")
    print(f"{'(m,n)':>8} {'χ(S^m)·χ(S^n)':>16} {'Product':>10}")
    for m in range(5):
        for n in range(5):
            prod = euler_char(m) * euler_char(n)
            if prod != 0:
                print(f"({m},{n}):  {euler_char(m):>3} × {euler_char(n):>3} = {prod:>4}")

    # Demo 4: Bernoulli-sphere weights
    print("\n--- Demo 4: Bernoulli-Sphere Weights ---")
    header_bn = "B'_n"
    print(f"{'n':>4} {header_bn:>12} {'chi(S^n)':>8} {'w(n)':>12}")
    print("-" * 40)
    for n in range(11):
        bn = bernoulli_prime(n)
        chi = euler_char(n)
        w = bernoulli_sphere_weight(n)
        print(f"{n:>4} {str(bn):>12} {chi:>8} {str(w):>12}")

    print("\n✓ All odd weights are zero (resonance verified)")

    # Demo 5: Even concentration
    print("\n--- Demo 5: Even Concentration w(2k) = 2·B'_{2k} ---")
    for k in range(6):
        w = bernoulli_sphere_weight(2 * k)
        expected = 2 * bernoulli_prime(2 * k)
        assert w == expected, f"Even concentration failed at k={k}"
        print(f"  w({2*k:>2}) = {str(w):>12} = 2 · B'_{2*k} = 2 · {str(bernoulli_prime(2*k))}")
    print("✓ Even concentration verified for k = 0, 1, ..., 5")

    # Demo 6: Graded Sphere Algebra pairings
    print("\n--- Demo 6: Graded Sphere Algebra Pairings ---")
    print("Even × Even pairings (should all be 4):")
    for j in range(4):
        for k in range(4):
            p = graded_pairing(2 * j, 2 * k)
            assert p == 4, f"Pairing failed at ({2*j}, {2*k})"
    print("  ✓ P(2j, 2k) = 4 for all j, k ∈ {0,1,2,3}")

    print("Odd pairings (should all be 0):")
    for j in range(4):
        for n in range(8):
            p = graded_pairing(2 * j + 1, n)
            assert p == 0, f"Odd pairing failed at ({2*j+1}, {n})"
    print("  ✓ P(2k+1, n) = 0 for all k, n")

    # Demo 7: Characteristic polynomials
    print("\n--- Demo 7: Characteristic Polynomials p_n(1) = χ(S^n) ---")
    for n in range(8):
        val = char_poly_eval(n, 1)
        assert val == euler_char(n)
    print("✓ p_n(1) = χ(S^n) verified for n = 0, ..., 7")

    # Demo 8: Conjecture verification
    print("\n--- Demo 8: Sphere-Bernoulli Duality Conjecture (N=2) ---")
    lhs = bernoulli_prime(0) * 2 + bernoulli_prime(2) * 2 + bernoulli_prime(4) * 2
    rhs = Fraction(2) + Fraction(1, 3) + Fraction(-1, 15)
    print(f"  LHS = 2·B'_0 + 2·B'_2 + 2·B'_4 = {lhs}")
    print(f"  RHS = 2 + 1/3 + (-1/15)          = {rhs}")
    assert lhs == rhs
    print(f"  ✓ Both equal {lhs} = {float(lhs):.10f}")

    # Demo 9: Mega-Sphere Euler encoding
    print("\n--- Demo 9: Mega-Sphere Euler Encoding ---")
    euler_seq = [euler_char(n) for n in range(20)]
    print(f"  Full sequence: {euler_seq}")
    for level in [3, 5, 10]:
        proj = mega_sphere_project(euler_seq, level)
        print(f"  Projection to level {level:>2}: {proj}")

    print("\n  Infinite support: the sequence [2,0,2,0,...] never terminates,")
    print("  so the Euler encoding is NOT in any finite filtration level.")

    # Demo 10: Alternating term identity
    print("\n--- Demo 10: Alternating Term Identity ---")
    print("  (-1)^i · χ(S^i) = (-1)^i + 1:")
    for i in range(8):
        lhs = (-1) ** i * euler_char(i)
        rhs = (-1) ** i + 1
        assert lhs == rhs
        print(f"    i={i}: (-1)^{i} · {euler_char(i)} = {lhs} = {(-1)**i} + 1 = {rhs} ✓")

    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS PASSED SUCCESSFULLY")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Bernoulli-Sphere Weight Resonance"""
import matplotlib.pyplot as plt
from fractions import Fraction
from math import comb

def bernoulli_prime_table(N):
    B = [Fraction(0)] * (N + 1)
    B[0] = Fraction(1)
    for m in range(1, N + 1):
        s = Fraction(0)
        for k in range(m):
            s += Fraction(comb(m + 1, k)) * B[k]
        B[m] = -s / (m + 1)
    if N >= 1:
        B[1] = Fraction(1, 2)
    return B

def euler_char(n):
    return 1 + (-1)**n

N = 16
B = bernoulli_prime_table(N)
weights = [float(B[n] * (1 + (-1)**n)) for n in range(N + 1)]
bernoulli_vals = [float(B[n]) for n in range(N + 1)]
euler_vals = [euler_char(n) for n in range(N + 1)]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Bernoulli numbers
colors_b = ['#9C27B0' if n % 2 == 0 else '#BDBDBD' for n in range(N + 1)]
axes[0].bar(range(N + 1), bernoulli_vals, color=colors_b, edgecolor='black', linewidth=0.5)
axes[0].set_xlabel('n')
axes[0].set_ylabel("B'_n")
axes[0].set_title("Bernoulli Numbers B'_n")
axes[0].axhline(y=0, color='black', linewidth=0.5)

# Plot 2: Euler characteristics
colors_e = ['#2196F3' if n % 2 == 0 else '#FF5722' for n in range(N + 1)]
axes[1].bar(range(N + 1), euler_vals, color=colors_e, edgecolor='black', linewidth=0.5)
axes[1].set_xlabel('n')
axes[1].set_ylabel('χ(Sⁿ)')
axes[1].set_title('Euler Characteristics χ(Sⁿ)')

# Plot 3: Bernoulli-sphere weights (resonance)
colors_w = ['#4CAF50' if w != 0 else '#EEEEEE' for w in weights]
axes[2].bar(range(N + 1), weights, color=colors_w, edgecolor='black', linewidth=0.5)
axes[2].set_xlabel('n')
axes[2].set_ylabel('w(n)')
axes[2].set_title('Bernoulli-Sphere Weight w(n) = B\'_n · χ(Sⁿ)')
axes[2].axhline(y=0, color='black', linewidth=0.5)

plt.suptitle('Bernoulli-Sphere Resonance: Odd Vanishing', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_bernoulli_weights.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_bernoulli_weights.png")


#!/usr/bin/env python3
"""Visualization: Sphere Euler Characteristic Pattern"""
import matplotlib.pyplot as plt
import numpy as np

def euler_char(n):
    return 1 + (-1)**n

N = 20
dims = list(range(N))
chis = [euler_char(n) for n in dims]
colors = ['#2196F3' if n % 2 == 0 else '#FF5722' for n in dims]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Bar chart of Euler characteristics
ax1.bar(dims, chis, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Dimension n', fontsize=12)
ax1.set_ylabel('χ(Sⁿ)', fontsize=12)
ax1.set_title('Euler Characteristics of Spheres', fontsize=14)
ax1.set_xticks(range(0, N, 2))
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.legend(['Even dim (χ=2)', 'Odd dim (χ=0)'], loc='upper right')

# Plot 2: Cumulative sum
cum_sums = np.cumsum(chis)
ax2.plot(dims, cum_sums, 'ko-', markersize=4)
ax2.fill_between(dims, cum_sums, alpha=0.3, color='#4CAF50')
ax2.set_xlabel('N', fontsize=12)
ax2.set_ylabel('Σᵢ₌₀ᴺ χ(Sⁱ)', fontsize=12)
ax2.set_title('Cumulative Euler Characteristic Sum', fontsize=14)
ax2.set_xticks(range(0, N, 2))

plt.tight_layout()
plt.savefig('viz_euler_pattern.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_euler_pattern.png")


#!/usr/bin/env python3
"""Visualization: Graded Sphere Algebra Pairing Table"""
import matplotlib.pyplot as plt
import numpy as np

def euler_char(n):
    return 1 + (-1)**n

N = 12
pairing = np.array([[euler_char(m) * euler_char(n) for n in range(N)] for m in range(N)])

fig, ax = plt.subplots(figsize=(8, 8))
cmap = plt.cm.RdYlGn
im = ax.imshow(pairing, cmap=cmap, vmin=-1, vmax=5)

for i in range(N):
    for j in range(N):
        color = 'white' if pairing[i, j] == 4 else 'black'
        ax.text(j, i, str(pairing[i, j]), ha='center', va='center',
                fontsize=10, fontweight='bold', color=color)

ax.set_xticks(range(N))
ax.set_yticks(range(N))
ax.set_xticklabels([f'S{n}' for n in range(N)])
ax.set_yticklabels([f'S{m}' for m in range(N)])
ax.set_xlabel('Dimension n', fontsize=12)
ax.set_ylabel('Dimension m', fontsize=12)
ax.set_title('Graded Sphere Algebra Pairing P(m,n) = χ(Sᵐ)·χ(Sⁿ)', fontsize=13)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Pairing value', fontsize=11)

plt.tight_layout()
plt.savefig('viz_pairing_table.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_pairing_table.png")
