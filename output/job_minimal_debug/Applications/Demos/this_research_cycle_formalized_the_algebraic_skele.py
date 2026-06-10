#!/usr/bin/env python3
"""
Demonstration of the Hecke Eigenvalue Recursion and Tropical Dequantization.

This script demonstrates the key mathematical results formalized in Lean 4:
1. The Hecke eigenvalue recursion for GL₂
2. The Cassini-Hecke identity (generalization of Fibonacci's Cassini identity)
3. The tropical Hecke recursion
4. The Maslov dequantization bridge
5. The Hecke Growth Dichotomy conjecture (computational test)
"""

from algorithms import (
    hecke_seq, hecke_seq_list, verify_cassini_identity,
    trop_hecke_seq, maslov_hecke_seq, hecke_growth_analysis,
    verify_euler_product_identity
)


def demo_hecke_recursion():
    """Demonstrate the Hecke eigenvalue recursion."""
    print("=" * 70)
    print("DEMO 1: Hecke Eigenvalue Recursion for GL₂")
    print("=" * 70)
    print()
    print("The recursion: h(0)=1, h(1)=a, h(n+2) = a·h(n+1) - q·h(n)")
    print()

    # Example: Ramanujan's tau function at p=2 (weight 12)
    # a_2 = -24, q = 2^11 = 2048
    a, q = -24, 2048
    print(f"Example: Ramanujan tau function (weight 12, p=2)")
    print(f"  a = τ(2) = {a}, q = 2^11 = {q}")
    vals = hecke_seq_list(a, q, 6)
    for i, v in enumerate(vals):
        print(f"  h({i}) = τ(2^{i}) = {v}")

    print()

    # Example: Level 11, weight 2 (elliptic curve 11a)
    a, q = -2, 11
    print(f"Example: Elliptic curve 11a (weight 2, p=11)")
    print(f"  a = a_11 = {a}, q = 11^1 = {q}")
    vals = hecke_seq_list(a, q, 8)
    for i, v in enumerate(vals):
        print(f"  h({i}) = a_{{11^{i}}} = {v}")
    print()


def demo_cassini_identity():
    """Demonstrate the Cassini-Hecke identity."""
    print("=" * 70)
    print("DEMO 2: The Cassini-Hecke Identity")
    print("=" * 70)
    print()
    print("Identity: h(n+1)² - h(n+2)·h(n) = q^(n+1)")
    print("(Generalization of Cassini's identity for Fibonacci numbers)")
    print()

    test_cases = [
        (1, -1, "Fibonacci (a=1, q=-1)"),
        (2, 1, "Chebyshev U_n (a=2, q=1)"),
        (-24, 2048, "Ramanujan tau (a=-24, q=2048)"),
        (3, 5, "Generic (a=3, q=5)"),
    ]

    for a, q, name in test_cases:
        print(f"  {name}:")
        all_ok = True
        for n in range(8):
            lhs, rhs = verify_cassini_identity(a, q, n)
            ok = lhs == rhs
            all_ok = all_ok and ok
            if n < 4:
                print(f"    n={n}: h({n+1})² - h({n+2})·h({n}) = {lhs}, q^{n+1} = {rhs}  {'✓' if ok else '✗'}")
        print(f"    ... verified for n=0..7: {'ALL PASS ✓' if all_ok else 'FAILED ✗'}")
        print()


def demo_tropical():
    """Demonstrate the tropical Hecke recursion."""
    print("=" * 70)
    print("DEMO 3: Tropical Hecke Recursion (Max-Plus Semiring)")
    print("=" * 70)
    print()
    print("Tropical recursion: h(0)=0, h(1)=a, h(n+2) = max(a+h(n+1), q+h(n))")
    print()

    # Ramanujan regime: 2a ≥ q → h(n) = n·a
    a, q = 5, 8  # 2*5=10 ≥ 8
    print(f"Ramanujan regime (2a ≥ q): a={a}, q={q}")
    for n in range(8):
        val = trop_hecke_seq(a, q, n)
        expected = n * a
        print(f"  h_trop({n}) = {val}, n·a = {expected}  {'✓' if val == expected else '✗'}")
    print()

    # Non-Ramanujan regime: 2a < q → phase transition
    a, q = 2, 7  # 2*2=4 < 7
    print(f"Non-Ramanujan regime (2a < q): a={a}, q={q}")
    for n in range(8):
        val = trop_hecke_seq(a, q, n)
        linear = n * a
        print(f"  h_trop({n}) = {val}, n·a = {linear}  {'linear' if val == linear else 'DIVERGES'}")
    print()


def demo_maslov_bridge():
    """Demonstrate the Maslov dequantization bridge."""
    print("=" * 70)
    print("DEMO 4: Maslov Dequantization Bridge")
    print("=" * 70)
    print()
    print("Interpolation: softmax_t(x,y) = (t·max(x,y) + min(x,y))/(t+1)")
    print("  t=0: min(x,y)     t=1: average     t→∞: max(x,y)")
    print()

    a, q = 3.0, 2.0
    n_val = 6

    print(f"Parameters: a={a}, q={q}, computing h({n_val})")
    print()

    t_values = [0, 0.5, 1, 2, 5, 10, 50, 100, 1000]
    trop_val = trop_hecke_seq(int(a), int(q), n_val)

    print(f"  {'t':>8s}  h_t({n_val})")
    print(f"  {'---':>8s}  {'---':>12s}")
    for t in t_values:
        val = maslov_hecke_seq(t, a, q, n_val)
        print(f"  {t:>8.1f}  {val:>12.4f}")
    print(f"  {'∞':>8s}  {trop_val:>12.4f}  (tropical limit)")
    print()


def demo_growth_dichotomy():
    """Demonstrate the Hecke Growth Dichotomy conjecture."""
    print("=" * 70)
    print("DEMO 5: Hecke Growth Dichotomy Conjecture (Computational Test)")
    print("=" * 70)
    print()
    print("Conjecture: |h(n)|² ≤ (n+1)²·q^n  ⟺  a² ≤ 4q")
    print()

    test_cases = [
        (2, 2, "a²=4 ≤ 4q=8 (Ramanujan)"),
        (3, 3, "a²=9 ≤ 4q=12 (Ramanujan)"),
        (4, 4, "a²=16 = 4q=16 (boundary)"),
        (3, 2, "a²=9 > 4q=8 (non-Ramanujan)"),
        (5, 3, "a²=25 > 4q=12 (non-Ramanujan)"),
        (10, 7, "a²=100 > 4q=28 (non-Ramanujan)"),
    ]

    for a, q, desc in test_cases:
        result = hecke_growth_analysis(a, q, max_n=15)
        status = "CONSISTENT ✓" if result["conjecture_consistent"] else "INCONSISTENT ✗"
        print(f"  ({a},{q}): {desc}")
        print(f"    Ramanujan regime: {result['ramanujan_regime']}, "
              f"Bound holds: {result['all_bounded']}")
        print(f"    Conjecture: {status}")
        if not result['all_bounded']:
            # Find first violation
            for i, holds in enumerate(result['bound_holds']):
                if not holds:
                    h = result['sequence'][i]
                    bound = (i + 1) ** 2 * q ** i
                    print(f"    First violation at n={i}: |h|²={h**2} > {bound}")
                    break
        print()


def demo_euler_product():
    """Demonstrate the Euler product identity."""
    print("=" * 70)
    print("DEMO 6: Euler Product Identity Verification")
    print("=" * 70)
    print()
    print("Identity: (1 - aX + qX²) · Σ h(n)X^n = 1 (mod X^{N+1})")
    print()

    test_cases = [(3, 5, 20), (-24, 2048, 15), (1, -1, 25)]
    for a, q, N in test_cases:
        ok = verify_euler_product_identity(a, q, N)
        print(f"  (a={a:>4d}, q={q:>5d}): verified up to N={N:>2d}  {'✓' if ok else '✗'}")
    print()


if __name__ == "__main__":
    demo_hecke_recursion()
    demo_cassini_identity()
    demo_tropical()
    demo_maslov_bridge()
    demo_growth_dichotomy()
    demo_euler_product()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Maslov Dequantization of the Hecke Recursion.

Shows how the tropical Hecke sequence deforms continuously into the
classical Hecke sequence through the Maslov dequantization parameter.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hecke_seq_list(a, q, n):
    if n < 0:
        return []
    result = [1]
    if n == 0:
        return result
    result.append(a)
    for i in range(2, n + 1):
        result.append(a * result[-1] - q * result[-2])
    return result


def trop_hecke_seq_list(a, q, n):
    if n < 0:
        return []
    result = [0]
    if n == 0:
        return result
    result.append(a)
    for i in range(2, n + 1):
        result.append(max(a + result[-1], q + result[-2]))
    return result


def maslov_hecke_seq_list(t, a, q, n):
    if n < 0:
        return []
    result = [0.0]
    if n == 0:
        return result
    result.append(float(a))
    for i in range(2, n + 1):
        x = a + result[-1]
        y = q + result[-2]
        if t + 1 == 0:
            val = min(x, y)
        else:
            val = (t * max(x, y) + min(x, y)) / (t + 1)
        result.append(val)
    return result


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Hecke Eigenvalue Recursion and Tropical Dequantization',
                 fontsize=14, fontweight='bold')

    a, q = 3, 2
    N = 12

    # Plot 1: Classical Hecke sequence
    ax = axes[0, 0]
    vals = hecke_seq_list(a, q, N)
    ns = list(range(N + 1))
    ax.bar(ns, vals, color='steelblue', alpha=0.8)
    ax.set_title(f'Classical Hecke Sequence (a={a}, q={q})')
    ax.set_xlabel('n')
    ax.set_ylabel('h(n)')
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Plot 2: Cassini identity verification
    ax = axes[0, 1]
    cassini_lhs = []
    cassini_rhs = []
    for n in range(N - 1):
        lhs = vals[n + 1] ** 2 - vals[n + 2] * vals[n]
        rhs = q ** (n + 1)
        cassini_lhs.append(lhs)
        cassini_rhs.append(rhs)
    ns2 = list(range(1, N))
    ax.semilogy(ns2, [abs(x) for x in cassini_lhs], 'bo-', label='|h(n+1)² - h(n+2)·h(n)|', markersize=6)
    ax.semilogy(ns2, cassini_rhs, 'r^--', label='q^(n+1)', markersize=6)
    ax.set_title('Cassini-Hecke Identity Verification')
    ax.set_xlabel('n+1')
    ax.set_ylabel('Value (log scale)')
    ax.legend(fontsize=9)

    # Plot 3: Maslov dequantization
    ax = axes[1, 0]
    t_values = [0, 0.5, 1, 2, 5, 20, 100]
    colors = plt.cm.viridis(np.linspace(0, 1, len(t_values)))
    for t, color in zip(t_values, colors):
        vals_t = maslov_hecke_seq_list(t, float(a), float(q), N)
        ax.plot(range(N + 1), vals_t, 'o-', color=color, label=f't={t}',
                markersize=4, linewidth=1.5)
    trop_vals = trop_hecke_seq_list(a, q, N)
    ax.plot(range(N + 1), trop_vals, 'k*-', label='t=∞ (tropical)',
            markersize=8, linewidth=2)
    ax.set_title('Maslov Dequantization Bridge')
    ax.set_xlabel('n')
    ax.set_ylabel('h_t(n)')
    ax.legend(fontsize=8, ncol=2)

    # Plot 4: Growth dichotomy
    ax = axes[1, 1]
    test_params = [(2, 2, 'Ramanujan'), (3, 2, 'Non-Ramanujan'),
                   (4, 4, 'Boundary'), (5, 3, 'Non-Ramanujan')]
    for a_test, q_test, regime in test_params:
        vals_test = hecke_seq_list(a_test, q_test, 15)
        log_ratios = []
        for n in range(1, 16):
            if vals_test[n] != 0 and q_test > 0:
                ratio = abs(vals_test[n]) / ((n + 1) * q_test ** (n / 2))
                log_ratios.append(ratio)
            else:
                log_ratios.append(0)
        style = 'o-' if 'Ramanujan' in regime else 's--'
        ax.plot(range(1, 16), log_ratios, style,
                label=f'a={a_test},q={q_test} ({regime})', markersize=4)
    ax.axhline(y=1.0, color='red', linestyle=':', linewidth=1.5,
               label='Bound |h(n)|/(n+1)q^{n/2}=1')
    ax.set_title('Growth Dichotomy: |h(n)| / ((n+1)·q^{n/2})')
    ax.set_xlabel('n')
    ax.set_ylabel('Ratio')
    ax.legend(fontsize=7)
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('viz_hecke_dequantization.png', dpi=150, bbox_inches='tight')
    print("Saved viz_hecke_dequantization.png")


if __name__ == '__main__':
    main()
