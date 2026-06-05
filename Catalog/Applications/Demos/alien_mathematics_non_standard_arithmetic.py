#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Numerical Demonstrations

Demonstrates key concepts from the formalized theory:
1. Infinitesimal detection and ideal properties
2. Ultrafilter simulation and transfer
3. Overspill visualization
4. Non-Archimedean characterization
"""

import math
from typing import Callable, List, Tuple


def is_computationally_infinitesimal(x: float, max_n: int = 10000) -> bool:
    """Test if x is 'computationally infinitesimal' up to bound max_n.

    An element x is infinitesimal if n * |x| < 1 for ALL positive n.
    In ℝ (Archimedean), only 0 is truly infinitesimal.
    This function checks up to max_n.
    """
    return all(n * abs(x) < 1.0 for n in range(1, max_n + 1))


def demo_infinitesimal_algebra():
    """Demonstrate infinitesimal algebra properties."""
    print("=" * 60)
    print("DEMO 1: Infinitesimal Algebra")
    print("=" * 60)

    # In ℝ, only 0 is truly infinitesimal
    test_values = [0.0, 1e-10, 1e-100, 1e-300, 0.001, 1.0]
    print("\nInfinitesimal test (checking n * |x| < 1 for n up to 10000):")
    for x in test_values:
        result = is_computationally_infinitesimal(x)
        status = "YES" if result else "NO"
        print(f"  x = {x:>15.2e} -> Infinitesimal up to n=10000? {status}")

    # Demonstrate ideal property: bounded * small ≈ small
    print("\nIdeal property: bounded × (small element) = smaller element")
    eps = 1e-10
    bounded_vals = [1.0, 7.0, 100.0, 1000.0]
    for b in bounded_vals:
        product = b * eps
        print(f"  {b:>8.1f} × {eps:.2e} = {product:.2e}")

    # Demonstrate reciprocal duality
    print("\nReciprocal Duality: small ↔ 1/large")
    for k in range(1, 8):
        eps = 10 ** (-k)
        inv_eps = 1.0 / eps
        print(f"  ε = 10^(-{k}) = {eps:.0e}, "
              f"ε⁻¹ = {inv_eps:.0e}, "
              f"ε⁻¹ > n for n ≤ {int(inv_eps) - 1}")


def simulate_ultrafilter_vote(
    property_fns: List[Callable[[int], bool]],
    n_indices: int = 10000
) -> List[float]:
    """Simulate ultrafilter 'voting' on properties.

    Returns the proportion of indices where each property holds.
    A free ultrafilter would include a set iff its density is 'large enough'.
    """
    proportions = []
    for fn in property_fns:
        count = sum(1 for i in range(n_indices) if fn(i))
        proportions.append(count / n_indices)
    return proportions


def demo_ultrafilter_transfer():
    """Demonstrate ultrafilter transfer principles."""
    print("\n" + "=" * 60)
    print("DEMO 2: Ultrafilter Transfer Simulation")
    print("=" * 60)

    n = 10000

    # Properties to test
    is_even = lambda i: i % 2 == 0
    is_positive = lambda i: i > 0
    is_div_by_3 = lambda i: i % 3 == 0
    is_composite = lambda i: i > 1 and any(i % d == 0 for d in range(2, min(i, 100)))

    props = [
        ("Even", is_even),
        ("Positive", is_positive),
        ("Divisible by 3", is_div_by_3),
        ("Composite (checked up to 100)", is_composite),
    ]

    print(f"\nProperty density over indices 0..{n-1}:")
    for name, fn in props:
        density = sum(1 for i in range(n) if fn(i)) / n
        print(f"  {name:>35s}: {density:.4f}")

    # Transfer of conjunction
    print("\nTransfer of conjunction (P ∧ Q):")
    p_and_q = lambda i: is_even(i) and is_div_by_3(i)
    d_p = sum(1 for i in range(n) if is_even(i)) / n
    d_q = sum(1 for i in range(n) if is_div_by_3(i)) / n
    d_pq = sum(1 for i in range(n) if p_and_q(i)) / n
    print(f"  Density(Even) = {d_p:.4f}")
    print(f"  Density(Div3) = {d_q:.4f}")
    print(f"  Density(Even ∧ Div3) = {d_pq:.4f}")
    print(f"  Expected (independent): {d_p * d_q:.4f}")

    # Binomial identity transfer (always true)
    print("\nBinomial identity (a+b)² = a² + 2ab + b² (universal transfer):")
    violations = 0
    for i in range(n):
        a, b = i * 7 + 3, i * 13 + 5
        lhs = (a + b) ** 2
        rhs = a ** 2 + 2 * a * b + b ** 2
        if lhs != rhs:
            violations += 1
    print(f"  Violations over {n} tests: {violations}")
    print(f"  → Identity holds universally, transfer is trivial")


def demo_overspill():
    """Demonstrate the overspill principle computationally."""
    print("\n" + "=" * 60)
    print("DEMO 3: Overspill Principle")
    print("=" * 60)

    # Simulate decreasing chain S_n = {i | i > n}
    # Each S_n has cofinite density → "U-large" for free U
    # The "overflow function" f(i) = i-1 gives f(i) → ∞
    N = 100
    print(f"\nDecreasing chain: S_n = {{i ∈ ℕ | i > n}}")
    for n_val in [0, 5, 10, 50, 90]:
        count = sum(1 for i in range(N) if i > n_val)
        print(f"  |S_{n_val} ∩ [0,{N-1}]| = {count}/{N} "
              f"(density {count/N:.2f})")

    print(f"\nOverflow function f(i) = i - 1:")
    print(f"  f represents a 'nonstandard' element: f(i) → ∞")
    print(f"  For each n, {{i | f(i) ≥ n}} = {{i | i ≥ n+1}} is cofinite")
    for n_val in [0, 10, 50]:
        count = sum(1 for i in range(N) if (i - 1) >= n_val)
        print(f"  |{{i | f(i) ≥ {n_val}}} ∩ [0,{N-1}]| = {count}/{N}")

    # Overspill: the diagonal i ∈ S_{f(i)} = S_{i-1} = {j | j > i-1}
    # i ∈ S_{i-1} iff i > i-1, which is always true for i ≥ 1
    print(f"\nDiagonal membership: i ∈ S_{{f(i)}} = S_{{i-1}}:")
    count = sum(1 for i in range(1, N) if i > (i - 1))
    print(f"  {{i ∈ [1,{N-1}] | i ∈ S_{{i-1}}}} has {count} elements (all!)")


def demo_non_archimedean():
    """Demonstrate the non-Archimedean characterization."""
    print("\n" + "=" * 60)
    print("DEMO 4: Non-Archimedean Characterization")
    print("=" * 60)

    # ℝ is Archimedean: for any x, there exists n with n > x
    print("\nℝ is Archimedean:")
    for x in [3.14, 1000.0, 1e100]:
        n = math.ceil(x) + 1
        print(f"  x = {x:.2e} → n = {n} satisfies n > x")

    # Simulated p-adic: in ℤ_p, |p^k|_p = p^(-k) → 0 as k → ∞
    # So p is "infinitesimally small" in p-adic metric
    print("\nSimulated p-adic (p=5): |5^k|_5 = 5^(-k)")
    p = 5
    for k in range(1, 8):
        padic_abs = p ** (-k)
        is_inf = all(n * padic_abs < 1 for n in range(1, 10000))
        print(f"  |5^{k}|_5 = 5^(-{k}) = {padic_abs:.2e}, "
              f"computationally infinitesimal: {is_inf}")

    print("\n  → In ℚ_5, the element 5 is 'small' (|5|_5 = 1/5)")
    print("  → This means ℚ_5 is non-Archimedean w.r.t. p-adic absolute value")
    print("  → By our theorem: non-Archimedean ↔ ∃ nonzero infinitesimal")


def demo_compositeness_transfer():
    """Demonstrate compositeness transfer through ultraproducts."""
    print("\n" + "=" * 60)
    print("DEMO 5: Compositeness Transfer")
    print("=" * 60)

    # Sequence: f(i) = (i+2) * (i+3) is always composite for i ≥ 0
    # The factorization transfers through the ultraproduct
    print("\nSequence f(i) = (i+2)(i+3), a(i) = i+2, b(i) = i+3:")
    for i in range(8):
        f_i = (i + 2) * (i + 3)
        print(f"  i={i}: f={f_i:>4d} = {i+2} × {i+3}, "
              f"a>{1}: {i+2>1}, b>{1}: {i+3>1}, "
              f"composite: {not _is_prime(f_i)}")

    print("\n  Since a(i) > 1 and b(i) > 1 for all i ≥ 0,")
    print("  and f(i) = a(i) * b(i) for all i,")
    print("  our theorem guarantees: f is composite on a U-large set")
    print("  (in fact, on ALL of ℕ)")


def _is_prime(n: int) -> bool:
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


if __name__ == "__main__":
    demo_infinitesimal_algebra()
    demo_ultrafilter_transfer()
    demo_overspill()
    demo_non_archimedean()
    demo_compositeness_transfer()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Infinitesimal/Bounded/Infinite Layer Structure

Shows the three-layer decomposition of a non-Archimedean ordered field:
- Infinitesimal core (green)
- Bounded ring (blue)
- Infinite elements (red)
With reciprocal duality arrows connecting them.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def create_layer_diagram():
    """Create the three-layer diagram of a non-Archimedean field."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Nested structure
    ax1.set_xlim(-5, 5)
    ax1.set_ylim(-5, 5)
    ax1.set_aspect('equal')
    ax1.set_title('Non-Archimedean Field Structure\n'
                   '(Three Algebraic Layers)', fontsize=13, fontweight='bold')

    # Infinite region (background)
    infinite_rect = patches.FancyBboxPatch(
        (-4.5, -4.5), 9, 9, boxstyle="round,pad=0.1",
        facecolor='#ffcccc', edgecolor='red', linewidth=2, alpha=0.5)
    ax1.add_patch(infinite_rect)

    # Bounded ring (middle circle)
    bounded_circle = plt.Circle((0, 0), 3, facecolor='#cce5ff',
                                 edgecolor='blue', linewidth=2, alpha=0.7)
    ax1.add_patch(bounded_circle)

    # Infinitesimal ideal (inner circle)
    inf_circle = plt.Circle((0, 0), 1, facecolor='#ccffcc',
                             edgecolor='green', linewidth=2, alpha=0.8)
    ax1.add_patch(inf_circle)

    # Labels
    ax1.text(0, 0, '0\n(infinitesimal)', ha='center', va='center',
             fontsize=10, fontweight='bold', color='darkgreen')
    ax1.text(0, 2, 'Bounded Elements\n(subring)', ha='center', va='center',
             fontsize=10, fontweight='bold', color='darkblue')
    ax1.text(0, -2, '±1, ±2, ..., ±n', ha='center', va='center',
             fontsize=9, color='navy')
    ax1.text(3.8, 3.8, 'Infinite\nElements', ha='center', va='center',
             fontsize=10, fontweight='bold', color='darkred')
    ax1.text(-3.8, -3.8, 'ω, ω², ...', ha='center', va='center',
             fontsize=9, color='darkred')

    # Reciprocal duality arrow
    ax1.annotate('', xy=(0.7, 0.3), xytext=(3.5, 3.5),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2))
    ax1.annotate('', xy=(3.5, 3.5), xytext=(0.7, 0.3),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2,
                               connectionstyle="arc3,rad=0.3"))
    ax1.text(2.5, 2.5, 'x ↔ x⁻¹\n(Reciprocal\nDuality)',
             ha='center', va='center', fontsize=9, color='purple',
             fontweight='bold', rotation=45)

    ax1.set_xlabel('Elements of F', fontsize=11)
    ax1.axis('off')

    # Right panel: n * |x| < 1 visualization
    ax2.set_title('Infinitesimal Test: n · |x| < 1\n'
                   'for all positive n', fontsize=13, fontweight='bold')

    x_vals = np.logspace(-4, 1, 200)
    n_vals = [1, 5, 10, 50, 100, 500]

    for n in n_vals:
        y = n * x_vals
        ax2.plot(x_vals, y, label=f'n = {n}', alpha=0.7)

    ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Threshold = 1')
    ax2.fill_between(x_vals, 0, 1, alpha=0.1, color='green')

    ax2.set_xscale('log')
    ax2.set_yscale('log')
    ax2.set_xlabel('|x|', fontsize=12)
    ax2.set_ylabel('n · |x|', fontsize=12)
    ax2.legend(fontsize=9, loc='upper left')
    ax2.set_ylim(1e-4, 1e4)
    ax2.grid(True, alpha=0.3)

    ax2.text(1e-3, 0.3, 'Infinitesimal\nregion', fontsize=11,
             color='green', fontweight='bold', ha='center')
    ax2.text(1, 10, 'Bounded but\nnot infinitesimal', fontsize=10,
             color='blue', ha='center')

    plt.tight_layout()
    plt.savefig('viz_infinitesimal_layers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_infinitesimal_layers.png")


def create_overspill_diagram():
    """Visualize the overspill principle."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title('Overspill Principle: Decreasing Chain with Overflow',
                 fontsize=13, fontweight='bold')

    N = 50
    # S_n = {i | i > n} for n = 0, 5, 10, ...
    chain_indices = list(range(0, 30, 3))

    for idx, n in enumerate(chain_indices):
        y = len(chain_indices) - idx
        members = [i for i in range(N) if i > n]
        non_members = [i for i in range(N) if i <= n]

        ax.scatter(members, [y] * len(members), c='blue', s=10, alpha=0.6)
        ax.scatter(non_members, [y] * len(non_members), c='lightgray', s=10, alpha=0.3)
        ax.text(-3, y, f'S_{n}', fontsize=9, ha='right', va='center')

    # Overflow function line: f(i) = i - 1
    overflow_x = list(range(1, N))
    overflow_y = [len(chain_indices) - (i - 1) / 3 for i in overflow_x]
    ax.plot(overflow_x, overflow_y, 'r-', linewidth=2, alpha=0.7,
            label='Overflow f(i) = i−1')

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Chain level (decreasing ↑)', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('viz_overspill.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_overspill.png")


if __name__ == "__main__":
    create_layer_diagram()
    create_overspill_diagram()
