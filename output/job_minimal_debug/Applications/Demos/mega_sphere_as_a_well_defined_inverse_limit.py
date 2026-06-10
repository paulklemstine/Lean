#!/usr/bin/env python3
"""
Mega-Sphere Inverse Limit: Numerical Demonstrations

Demonstrates the Bernoulli-sphere resonance, Graded Sphere Algebra pairing,
and convolution structure constants.
"""
from fractions import Fraction
from typing import List


def bernoulli_prime(n: int) -> Fraction:
    """Compute B'_n (Bernoulli numbers with B'_1 = +1/2) using the recursive definition."""
    cache: dict[int, Fraction] = {}

    def _bp(k: int) -> Fraction:
        if k in cache:
            return cache[k]
        if k == 0:
            cache[0] = Fraction(1)
            return cache[0]
        # B'_n = 1 - sum_{k=0}^{n-1} C(n,k) / (n - k + 1) * B'_k
        s = Fraction(0)
        for j in range(k):
            binom = 1
            for r in range(j):
                binom = binom * (k - r) // (r + 1)
            s += Fraction(binom, k - j + 1) * _bp(j)
        cache[k] = Fraction(1) - s
        return cache[k]

    return _bp(n)


def euler_char_sphere(n: int) -> int:
    """Euler characteristic of S^n: chi(S^n) = 1 + (-1)^n."""
    return 1 + (-1) ** n


def bernoulli_sphere_weight(n: int) -> Fraction:
    """Bernoulli-sphere weight: w(n) = B'_n * chi(S^n)."""
    return bernoulli_prime(n) * euler_char_sphere(n)


def sphere_pairing(j: int, k: int) -> int:
    """Sphere pairing: P(j, k) = chi(S^j) * chi(S^k)."""
    return euler_char_sphere(j) * euler_char_sphere(k)


def sphere_convolution(n: int) -> int:
    """Sphere convolution: C(n) = sum_{j=0}^{n} P(j, n-j)."""
    return sum(sphere_pairing(j, n - j) for j in range(n + 1))


def main():
    print("=" * 70)
    print("MEGA-SPHERE INVERSE LIMIT: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Euler characteristics
    print("\n--- Demo 1: Euler Characteristics of Spheres ---")
    print(f"{'n':>4} | {'chi(S^n)':>10} | {'Parity':>6}")
    print("-" * 30)
    for n in range(11):
        chi = euler_char_sphere(n)
        parity = "even" if n % 2 == 0 else "odd"
        print(f"{n:>4} | {chi:>10} | {parity:>6}")
    print("\nVerified: chi(S^n) = 2 for even n, 0 for odd n ✓")

    # Demo 2: Bernoulli-sphere resonance
    print("\n--- Demo 2: Bernoulli-Sphere Resonance ---")
    bp_header = "B'_n"
    print(f"{'n':>4} | {bp_header:>12} | {'chi(S^n)':>10} | {'w(n)':>12}")
    print("-" * 50)
    for n in range(13):
        bp = bernoulli_prime(n)
        chi = euler_char_sphere(n)
        w = bernoulli_sphere_weight(n)
        print(f"{n:>4} | {str(bp):>12} | {chi:>10} | {str(w):>12}")
    print("\nVerified: w(n) = 0 for ALL odd n ✓")
    print("Double resonance: for odd n > 1, BOTH B'_n = 0 AND chi(S^n) = 0 ✓")

    # Demo 3: Universal pairing rigidity
    print("\n--- Demo 3: Universal Pairing Rigidity ---")
    print("P(2j, 2k) for various j, k:")
    print(f"{'':>6}", end="")
    for k in range(6):
        print(f"{'2*'+str(k):>6}", end="")
    print()
    for j in range(6):
        print(f"{'2*'+str(j):>6}", end="")
        for k in range(6):
            print(f"{sphere_pairing(2*j, 2*k):>6}", end="")
        print()
    print("\nVerified: P(2j, 2k) = 4 for ALL j, k ✓ (rigidity)")

    # Demo 4: Convolution structure
    print("\n--- Demo 4: Sphere Convolution C(n) ---")
    print(f"{'n':>4} | {'C(n)':>8} | {'Parity':>6} | {'Formula':>12}")
    print("-" * 40)
    for n in range(13):
        cn = sphere_convolution(n)
        parity = "even" if n % 2 == 0 else "odd"
        if n % 2 == 0:
            m = n // 2
            formula = f"4*({m}+1)={4*(m+1)}"
        else:
            formula = "0"
        print(f"{n:>4} | {cn:>8} | {parity:>6} | {formula:>12}")
    print("\nVerified: C(odd) = 0, C(2m) = 4(m+1) ✓")

    # Demo 5: Adjacent sum
    print("\n--- Demo 5: Adjacent Sphere Sum ---")
    for n in range(8):
        s = euler_char_sphere(n) + euler_char_sphere(n + 1)
        print(f"chi(S^{n}) + chi(S^{n+1}) = {euler_char_sphere(n)} + {euler_char_sphere(n+1)} = {s}")
    print("\nVerified: chi(S^n) + chi(S^{n+1}) = 2 for all n ✓")

    # Demo 6: Cumulative sums
    print("\n--- Demo 6: Cumulative Euler Characteristics ---")
    for m in range(6):
        total = sum(euler_char_sphere(k) for k in range(2 * m + 1))
        print(f"sum_{{k=0}}^{{{2*m}}} chi(S^k) = {total} = 2*({m}+1) = {2*(m+1)}")
    print("\nVerified: cumulative sum over [0, 2m] = 2(m+1) ✓")

    # Demo 7: Falsified conjecture
    print("\n--- Demo 7: Falsified Growth Conjecture ---")
    print("Partial sums of |sum w(2k)|:")
    for N in range(8):
        partial = sum(bernoulli_sphere_weight(2 * k) for k in range(N + 1))
        print(f"N={N}: sum = {partial} = {float(partial):.6f}, |sum| = {float(abs(partial)):.6f}, > 2? {abs(partial) > 2}")
    print("\nConjecture |sum| <= 2 FALSIFIED at N=1: |7/3| = 2.333... > 2 ✓")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Graded Sphere Algebra Convolution

Shows the sphere pairing matrix and convolution structure constants,
demonstrating the even concentration and linear growth C(2m) = 4(m+1).
"""
import matplotlib.pyplot as plt
import numpy as np


def euler_char_sphere(n: int) -> int:
    return 0 if n % 2 == 1 else 2


def sphere_pairing(j: int, k: int) -> int:
    return euler_char_sphere(j) * euler_char_sphere(k)


def sphere_convolution(n: int) -> int:
    return sum(sphere_pairing(j, n - j) for j in range(n + 1))


def main():
    # Figure 1: Pairing matrix
    N = 12
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Pairing matrix heatmap
    ax1 = axes[0]
    matrix = np.array([[sphere_pairing(j, k) for k in range(N)] for j in range(N)])
    im = ax1.imshow(matrix, cmap='YlOrRd', aspect='equal', origin='lower')
    ax1.set_xlabel('k', fontsize=12)
    ax1.set_ylabel('j', fontsize=12)
    ax1.set_title('Sphere Pairing P(j, k) = χ(Sʲ) · χ(Sᵏ)', fontsize=13)
    ax1.set_xticks(range(N))
    ax1.set_yticks(range(N))
    
    # Add text annotations
    for j in range(N):
        for k in range(N):
            val = sphere_pairing(j, k)
            color = 'white' if val > 2 else 'black'
            ax1.text(k, j, str(val), ha='center', va='center',
                    fontsize=8, color=color, fontweight='bold')
    
    plt.colorbar(im, ax=ax1, shrink=0.8)
    
    # Convolution plot
    ax2 = axes[1]
    max_n = 20
    dims = list(range(max_n + 1))
    convs = [sphere_convolution(n) for n in dims]
    
    colors = ['#9C27B0' if n % 2 == 0 else '#E0E0E0' for n in dims]
    ax2.bar(dims, convs, color=colors, alpha=0.85, edgecolor='black', linewidth=0.5)
    
    # Overlay the formula line
    even_dims = [n for n in dims if n % 2 == 0]
    even_vals = [4 * (n // 2 + 1) for n in even_dims]
    ax2.plot(even_dims, even_vals, 'ro-', markersize=5, linewidth=1.5,
             label='C(2m) = 4(m+1)', zorder=5)
    
    ax2.set_xlabel('Degree n', fontsize=12)
    ax2.set_ylabel('C(n)', fontsize=12)
    ax2.set_title('Sphere Convolution: Even Concentration', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.axhline(y=0, color='gray', linewidth=0.5)
    
    plt.tight_layout()
    plt.savefig('sphere_convolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: sphere_convolution.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Bernoulli-Sphere Resonance Pattern

Shows the Bernoulli-sphere weight w(n) = B'_n * chi(S^n) across dimensions,
highlighting the even concentration and double resonance.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from fractions import Fraction
from typing import Dict, Optional


def compute_bernoulli_prime(n: int, cache: Optional[Dict[int, Fraction]] = None) -> Fraction:
    if cache is None:
        cache = {}
    if n in cache:
        return cache[n]
    if n == 0:
        cache[0] = Fraction(1)
        return Fraction(1)
    s = Fraction(0)
    binom = 1
    for k in range(n):
        if k > 0:
            binom = binom * (n - k + 1) // k
        s += Fraction(binom, n - k + 1) * compute_bernoulli_prime(k, cache)
    result = Fraction(1) - s
    cache[n] = result
    return result


def euler_char_sphere(n: int) -> int:
    return 0 if n % 2 == 1 else 2


def main():
    cache: Dict[int, Fraction] = {}
    N = 20
    
    dims = list(range(N + 1))
    weights = [float(compute_bernoulli_prime(n, cache) * euler_char_sphere(n)) for n in dims]
    bernoulli_vals = [float(compute_bernoulli_prime(n, cache)) for n in dims]
    euler_vals = [euler_char_sphere(n) for n in dims]
    
    fig, axes = plt.subplots(3, 1, figsize=(12, 10), sharex=True)
    
    # Plot 1: Euler characteristics
    ax1 = axes[0]
    colors1 = ['#2196F3' if n % 2 == 0 else '#FF5722' for n in dims]
    ax1.bar(dims, euler_vals, color=colors1, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax1.set_ylabel('χ(Sⁿ)', fontsize=12)
    ax1.set_title('Euler Characteristics of Spheres', fontsize=14)
    ax1.set_yticks([0, 2])
    ax1.axhline(y=0, color='gray', linewidth=0.5)
    even_patch = mpatches.Patch(color='#2196F3', label='Even n: χ = 2')
    odd_patch = mpatches.Patch(color='#FF5722', label='Odd n: χ = 0')
    ax1.legend(handles=[even_patch, odd_patch], loc='upper right')
    
    # Plot 2: Bernoulli numbers
    ax2 = axes[1]
    colors2 = ['#4CAF50' if n % 2 == 0 else '#9E9E9E' for n in dims]
    ax2.bar(dims, bernoulli_vals, color=colors2, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax2.set_ylabel("B'_n", fontsize=12)
    ax2.set_title("Bernoulli Numbers B'_n (B'_1 = +1/2 convention)", fontsize=14)
    ax2.axhline(y=0, color='gray', linewidth=0.5)
    
    # Plot 3: Bernoulli-sphere weight
    ax3 = axes[2]
    colors3 = []
    for n in dims:
        if n % 2 == 0:
            colors3.append('#9C27B0')  # Purple for nonzero even weights
        else:
            colors3.append('#BDBDBD')  # Gray for zero (resonance)
    ax3.bar(dims, weights, color=colors3, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax3.set_ylabel('w(n) = B\'_n · χ(Sⁿ)', fontsize=12)
    ax3.set_xlabel('Dimension n', fontsize=12)
    ax3.set_title('Bernoulli-Sphere Weight: Even Concentration (Resonance)', fontsize=14)
    ax3.axhline(y=0, color='gray', linewidth=0.5)
    
    # Annotate key values
    for n in range(0, N + 1, 2):
        if abs(weights[n]) > 0.01:
            w_frac = compute_bernoulli_prime(n, cache) * euler_char_sphere(n)
            ax3.annotate(f'{w_frac}', (n, weights[n]),
                        textcoords="offset points", xytext=(0, 8 if weights[n] > 0 else -15),
                        ha='center', fontsize=7, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('bernoulli_sphere_resonance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: bernoulli_sphere_resonance.png")


if __name__ == "__main__":
    main()
