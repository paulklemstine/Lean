#!/usr/bin/env python3
"""
Anti-Fibonacci Sequence: Numbers That Avoid the Golden Ratio at All Costs

Demonstrates the key properties of the anti-Fibonacci sequence,
the canonical example of a Recurrence Avoidance Partition.
"""

def anti_fib(n: int) -> int:
    """Compute the n-th anti-Fibonacci term: floor(3n/2) + 1."""
    return n + n // 2 + 1


def anti_fib_greedy(count: int) -> list[int]:
    """Compute the anti-Fibonacci sequence via the greedy avoidance algorithm.
    
    Starting from (1, 2), each term is the smallest integer greater than the
    previous that doesn't appear in the set of all previous consecutive sums.
    """
    seq = [1, 2]
    forbidden = {3}  # 1 + 2
    for _ in range(count - 2):
        candidate = seq[-1] + 1
        while candidate in forbidden:
            candidate += 1
        forbidden.add(seq[-1] + candidate)
        seq.append(candidate)
    return seq


def verify_closed_form(n: int = 100) -> None:
    """Verify that the greedy algorithm matches the closed form."""
    greedy = anti_fib_greedy(n)
    closed = [anti_fib(i) for i in range(n)]
    assert greedy == closed, f"Mismatch at some index!"
    print(f"✓ Greedy algorithm matches closed form ⌊3n/2⌋+1 for n=0..{n-1}")


def verify_avoidance(n: int = 200) -> None:
    """Verify no term equals the sum of two preceding terms."""
    seq = [anti_fib(i) for i in range(n)]
    for i in range(2, n):
        assert seq[i] != seq[i-1] + seq[i-2], f"Avoidance violated at {i}"
    print(f"✓ Anti-Fibonacci avoidance holds for n=0..{n-1}")


def verify_strong_avoidance(n: int = 200) -> None:
    """Verify no term equals ANY consecutive sum (cumulative avoidance)."""
    seq = [anti_fib(i) for i in range(n)]
    all_sums = {seq[i] + seq[i+1] for i in range(n-1)}
    terms = set(seq)
    assert terms.isdisjoint(all_sums), "Strong avoidance violated!"
    print(f"✓ Strong (cumulative) avoidance holds for n=0..{n-1}")


def verify_partition(n: int = 500) -> None:
    """Verify that terms ⊔ consecutive sums = {1, ..., max_val}."""
    seq = [anti_fib(i) for i in range(n)]
    terms = set(seq)
    sums = {seq[i] + seq[i+1] for i in range(n-1)}
    
    max_val = max(terms | sums)
    universe = set(range(1, max_val + 1))
    
    # Check disjointness
    assert terms.isdisjoint(sums), "Partition failed: overlap!"
    
    # Check that we cover a large initial segment
    covered = terms | sums
    missing = universe - covered
    # Some large values might be missing from sums (edge effects)
    small_missing = {x for x in missing if x < seq[-2]}
    assert len(small_missing) == 0, f"Partition has gaps: {small_missing}"
    print(f"✓ Partition verified: terms ⊔ sums covers {{1, ..., {seq[-2]}}}")


def verify_mod3_property(n: int = 1000) -> None:
    """Verify terms are exactly the non-multiples of 3."""
    terms = {anti_fib(i) for i in range(n)}
    max_val = max(terms)
    non_mult_3 = {k for k in range(1, max_val + 1) if k % 3 != 0}
    assert terms == non_mult_3, "Mod 3 property failed!"
    print(f"✓ Anti-Fibonacci terms = {{k ∈ ℕ⁺ : 3 ∤ k}} verified up to {max_val}")


def demonstrate_ratio_oscillation(n: int = 30) -> None:
    """Show that the ratio A(n+1)/A(n) does NOT converge to a constant."""
    print("\n--- Ratio Oscillation ---")
    print(f"{'n':>4} {'A(n)':>6} {'A(n+1)':>8} {'diff':>5} {'ratio':>8}")
    print("-" * 35)
    for i in range(n):
        a = anti_fib(i)
        b = anti_fib(i + 1)
        diff = b - a
        ratio = b / a if a > 0 else float('inf')
        print(f"{i:4d} {a:6d} {b:8d} {diff:5d} {ratio:8.4f}")


def demonstrate_density(max_k: int = 20) -> None:
    """Show that density approaches 2/3."""
    print("\n--- Density Convergence ---")
    print(f"{'N':>6} {'count(non-mult-3)':>18} {'density':>10} {'2/3':>10}")
    print("-" * 50)
    for k in range(1, max_k + 1):
        N = 3 * k
        count = sum(1 for i in range(1, N + 1) if i % 3 != 0)
        density = count / N
        print(f"{N:6d} {count:18d} {density:10.6f} {2/3:10.6f}")


def demonstrate_shadow_enumeration(n: int = 20) -> None:
    """Show consecutive sums enumerate all multiples of 3."""
    print("\n--- Shadow (Consecutive Sums) ---")
    print(f"{'n':>4} {'A(n)':>6} {'A(n+1)':>8} {'sum':>6} {'sum/3':>6}")
    print("-" * 35)
    for i in range(n):
        a = anti_fib(i)
        b = anti_fib(i + 1)
        s = a + b
        print(f"{i:4d} {a:6d} {b:8d} {s:6d} {s/3:6.0f}")


def golden_ratio_comparison() -> None:
    """Compare Fibonacci and Anti-Fibonacci growth rates."""
    import math
    phi = (1 + math.sqrt(5)) / 2
    anti_fib_rate = 3 / 2
    
    print("\n--- Growth Rate Comparison ---")
    print(f"Fibonacci growth rate (φ):        {phi:.6f}")
    print(f"Anti-Fibonacci growth rate (3/2):  {anti_fib_rate:.6f}")
    print(f"Ratio: φ / (3/2) = {phi / anti_fib_rate:.6f}")
    print(f"3/2 < φ < 2: {anti_fib_rate} < {phi:.6f} < 2.0  ✓")
    print(f"\nFibonacci grows EXPONENTIALLY at rate φ")
    print(f"Anti-Fibonacci grows LINEARLY at rate 3/2")
    print(f"Avoidance constrains growth from exponential to linear!")


if __name__ == "__main__":
    print("=" * 60)
    print("  ANTI-FIBONACCI SEQUENCE DEMONSTRATION")
    print("  Numbers That Avoid the Golden Ratio at All Costs")
    print("=" * 60)
    
    # First 20 terms
    print(f"\nFirst 20 terms: {[anti_fib(i) for i in range(20)]}")
    
    # Verifications
    print("\n--- Verifications ---")
    verify_closed_form(200)
    verify_avoidance(500)
    verify_strong_avoidance(500)
    verify_partition(300)
    verify_mod3_property(500)
    
    # Demonstrations
    demonstrate_ratio_oscillation(15)
    demonstrate_density(10)
    demonstrate_shadow_enumeration(15)
    golden_ratio_comparison()
    
    print("\n" + "=" * 60)
    print("  ALL VERIFICATIONS PASSED")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Anti-Fibonacci Sequence Properties

Generates plots showing the key properties of the anti-Fibonacci sequence:
1. The sequence and its shadow (partition of ℕ⁺)
2. Ratio oscillation vs. Fibonacci convergence
3. Density convergence to 2/3
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def anti_fib(n):
    return n + n // 2 + 1


def fib(n):
    a, b = 1, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Anti-Fibonacci Sequence: Recurrence Avoidance Algebra",
                 fontsize=16, fontweight='bold')

    # --- Plot 1: Partition of ℕ⁺ ---
    ax1 = axes[0, 0]
    N = 60
    terms = {anti_fib(n) for n in range(2 * N // 3 + 5)}
    shadows = set()
    for n in range(2 * N // 3 + 4):
        shadows.add(anti_fib(n) + anti_fib(n + 1))

    colors = []
    for k in range(1, N + 1):
        if k in terms:
            colors.append('#2196F3')  # blue
        elif k in shadows:
            colors.append('#FF5722')  # orange
        else:
            colors.append('#9E9E9E')  # grey (shouldn't happen)

    rows = 6
    cols = N // rows
    for i, k in enumerate(range(1, N + 1)):
        r, c = i // cols, i % cols
        color = colors[i]
        ax1.add_patch(plt.Rectangle((c, rows - 1 - r), 0.9, 0.9,
                                     facecolor=color, edgecolor='white', linewidth=0.5))
        ax1.text(c + 0.45, rows - 1 - r + 0.45, str(k),
                ha='center', va='center', fontsize=6, fontweight='bold',
                color='white')

    ax1.set_xlim(-0.1, cols + 0.1)
    ax1.set_ylim(-0.1, rows + 0.1)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.set_title('Partition of ℕ⁺: Terms (blue) vs Shadow (orange)', fontsize=11)
    blue_patch = mpatches.Patch(color='#2196F3', label='Anti-Fibonacci (3∤n)')
    orange_patch = mpatches.Patch(color='#FF5722', label='Shadow (3|n)')
    ax1.legend(handles=[blue_patch, orange_patch], loc='lower right', fontsize=8)

    # --- Plot 2: Growth comparison ---
    ax2 = axes[0, 1]
    ns = np.arange(1, 25)
    af_vals = [anti_fib(int(n)) for n in ns]
    fib_vals = [fib(int(n)) for n in ns]
    linear = [int(n) for n in ns]

    ax2.semilogy(ns, af_vals, 'b-o', label='Anti-Fibonacci A(n)', markersize=4)
    ax2.semilogy(ns, fib_vals, 'r-s', label='Fibonacci F(n)', markersize=4)
    ax2.semilogy(ns, linear, 'g--', label='Linear (n)', alpha=0.5)
    ax2.semilogy(ns, [1.5 * n for n in ns], 'b--', label='3n/2 (asymptote)', alpha=0.5)
    ax2.set_xlabel('n')
    ax2.set_ylabel('Value (log scale)')
    ax2.set_title('Growth: Linear (Anti-Fib) vs Exponential (Fib)', fontsize=11)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # --- Plot 3: Ratio oscillation ---
    ax3 = axes[1, 0]
    n_ratio = 40
    af_ratios = [anti_fib(n + 1) / anti_fib(n) for n in range(n_ratio)]
    fib_ratios = [fib(n + 1) / fib(n) for n in range(n_ratio)]
    phi = (1 + np.sqrt(5)) / 2

    ax3.plot(range(n_ratio), af_ratios, 'b-o', label='A(n+1)/A(n)', markersize=3)
    ax3.plot(range(n_ratio), fib_ratios, 'r-s', label='F(n+1)/F(n)', markersize=3, alpha=0.7)
    ax3.axhline(y=phi, color='r', linestyle='--', alpha=0.5, label=f'φ = {phi:.4f}')
    ax3.axhline(y=1.5, color='b', linestyle='--', alpha=0.5, label='3/2 = 1.5')
    ax3.axhline(y=1.0, color='gray', linestyle=':', alpha=0.3)
    ax3.set_xlabel('n')
    ax3.set_ylabel('Ratio')
    ax3.set_title('Ratio: Anti-Fib oscillates, Fibonacci converges to φ', fontsize=11)
    ax3.legend(fontsize=8)
    ax3.set_ylim(0.8, 2.2)
    ax3.grid(True, alpha=0.3)

    # --- Plot 4: Density ---
    ax4 = axes[1, 1]
    ks = range(1, 100)
    densities = []
    for k in ks:
        N = 3 * k
        count = sum(1 for i in range(1, N + 1) if i % 3 != 0)
        densities.append(count / N)

    ax4.plot(list(ks), densities, 'b-', linewidth=2, label='Density of anti-Fib terms')
    ax4.axhline(y=2/3, color='r', linestyle='--', label='2/3 (limit)', alpha=0.7)
    ax4.set_xlabel('k (N = 3k)')
    ax4.set_ylabel('Density')
    ax4.set_title('Density of Anti-Fibonacci Terms → 2/3', fontsize=11)
    ax4.legend(fontsize=8)
    ax4.set_ylim(0.6, 0.7)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('antifib_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: antifib_visualization.png")


if __name__ == "__main__":
    main()
