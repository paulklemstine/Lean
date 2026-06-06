#!/usr/bin/env python3
"""
Computational Thermodynamics Demo
==================================

Demonstrates the key concepts from the CEA framework:
1. Image contraction under non-injective maps
2. Entropy decrease tracking
3. Polynomial vs exponential budget comparison
4. Maxwell's Demon simulation
"""

import math
import random
from typing import Callable


def fiber_card(f: Callable[[int], int], n: int, y: int) -> int:
    """Compute the fiber cardinality of f at y over {0, ..., n-1}."""
    return sum(1 for x in range(n) if f(x) == y)


def max_fiber(f: Callable[[int], int], n: int) -> int:
    """Compute the maximum fiber cardinality of f over {0, ..., n-1}."""
    return max(fiber_card(f, n, y) for y in range(n))


def image_size(f: Callable[[int], int], n: int) -> int:
    """Compute the image size of f on {0, ..., n-1}."""
    return len(set(f(x) for x in range(n)))


def iterate_f(f: Callable[[int], int], k: int, x: int) -> int:
    """Compute f^k(x)."""
    for _ in range(k):
        x = f(x)
    return x


def image_size_after_k(f: Callable[[int], int], n: int, k: int) -> int:
    """Compute |f^k({0, ..., n-1})|."""
    return len(set(iterate_f(f, k, x) for x in range(n)))


def demo_image_contraction():
    """Demonstrate image contraction under iteration."""
    print("=" * 60)
    print("Demo 1: Image Contraction Under Iteration")
    print("=" * 60)

    n = 16
    # Non-injective: f(x) = x // 2
    f = lambda x: x // 2
    print(f"\nf(x) = x // 2 on {{0, ..., {n-1}}}")
    print(f"{'Step k':<10} {'Image Size':<15} {'Entropy (ln)':<15}")
    print("-" * 40)
    for k in range(6):
        sz = image_size_after_k(f, n, k)
        ent = math.log(sz) if sz > 0 else 0
        print(f"{k:<10} {sz:<15} {ent:<15.4f}")

    print(f"\nMax fiber at step 0: {max_fiber(f, n)}")
    print(f"Information erased per step: log({max_fiber(f, n)}) = {math.log(max_fiber(f, n)):.4f} nats")

    # Injective (permutation): f(x) = (x + 1) mod n
    g = lambda x: (x + 1) % n
    print(f"\ng(x) = (x + 1) mod {n} (injective/reversible)")
    print(f"{'Step k':<10} {'Image Size':<15} {'Entropy (ln)':<15}")
    print("-" * 40)
    for k in range(6):
        sz = image_size_after_k(g, n, k)
        ent = math.log(sz) if sz > 0 else 0
        print(f"{k:<10} {sz:<15} {ent:<15.4f}")
    print("→ Image size constant: reversible computation erases no information!")


def demo_polynomial_vs_exponential():
    """Demonstrate exponential dominance over polynomial."""
    print("\n" + "=" * 60)
    print("Demo 2: Exponential Dominates Polynomial")
    print("=" * 60)

    for d in range(1, 6):
        # Find threshold N where 2^n > n^d
        N = 1
        while N**d >= 2**N:
            N += 1
        print(f"\nd = {d}: 2^n > n^d for all n ≥ {N}")
        print(f"  Verification: n={N}: {N}^{d} = {N**d}, 2^{N} = {2**N}")
        if N > 1:
            print(f"  Last failure: n={N-1}: {(N-1)}^{d} = {(N-1)**d}, 2^{N-1} = {2**(N-1)}")


def demo_entropy_budget():
    """Demonstrate polynomial entropy budget ceiling."""
    print("\n" + "=" * 60)
    print("Demo 3: Polynomial Budget Entropy Ceiling")
    print("=" * 60)

    c = 0.1  # per-step entropy cost
    print(f"\nPer-step entropy cost c = {c}")
    print(f"\n{'n':<6} {'n^2 * c':<12} {'n^3 * c':<12} {'2^n * c':<15} {'Ratio 2^n/n^3':<15}")
    print("-" * 60)
    for n in [5, 10, 15, 20, 25, 30]:
        poly2 = n**2 * c
        poly3 = n**3 * c
        exp = 2**n * c
        ratio = 2**n / n**3
        print(f"{n:<6} {poly2:<12.1f} {poly3:<12.1f} {exp:<15.1f} {ratio:<15.1f}")


def demo_maxwell_demon():
    """Simulate Maxwell's demon on a simple system."""
    print("\n" + "=" * 60)
    print("Demo 4: Maxwell's Demon Simulation")
    print("=" * 60)

    n = 32  # number of particles
    random.seed(42)

    # Initial state: random energies
    energies = [random.gauss(0, 1) for _ in range(n)]
    threshold = 0  # hot = above threshold

    hot = [e for e in energies if e >= threshold]
    cold = [e for e in energies if e < threshold]
    print(f"\nInitial state: {n} particles")
    print(f"  Hot (E ≥ 0): {len(hot)} particles, avg energy: {sum(hot)/max(len(hot),1):.3f}")
    print(f"  Cold (E < 0): {len(cold)} particles, avg energy: {sum(cold)/max(len(cold),1):.3f}")
    print(f"  System entropy: H = ln({n}) = {math.log(n):.4f} nats")

    # Demon sorts: total entropy reduction
    if len(hot) > 0 and len(cold) > 0:
        entropy_reduction = math.log(n) - math.log(len(hot)) - math.log(len(cold))
        # But entropy_reduction could be negative if both groups exist
        # The actual reduction is from unsorted to sorted
        initial_entropy = math.log(math.factorial(n))  # log(n!) permutations
        sorted_entropy = math.log(math.factorial(len(hot))) + math.log(math.factorial(len(cold)))
        reduction = initial_entropy - sorted_entropy

        print(f"\n  Sorting entropy: log({n}!) - log({len(hot)}!) - log({len(cold)}!)")
        print(f"  = {initial_entropy:.2f} - {sorted_entropy:.2f} = {reduction:.2f} nats")
        print(f"\n  Landauer cost (kT per nat): {reduction:.2f} × kT")
        print(f"  At T=300K: {reduction * 1.38e-23 * 300:.2e} joules")

    # Step budget analysis
    print(f"\n  Steps needed for brute-force sort: {n * math.ceil(math.log2(n))}")
    print(f"  Polynomial budget (n^2): {n**2}")
    print(f"  Exponential requirement for full search: 2^{n} = {2**n}")


def demo_fiber_analysis():
    """Analyze fiber structure of various functions."""
    print("\n" + "=" * 60)
    print("Demo 5: Fiber Analysis")
    print("=" * 60)

    n = 12

    functions = {
        "Identity (injective)": lambda x: x,
        "Halving (2-to-1)": lambda x: x // 2,
        "Constant (maximally non-injective)": lambda x: 0,
        "Modular (periodic)": lambda x: x % 4,
    }

    for name, f in functions.items():
        fibers = [fiber_card(f, n, y) for y in range(n)]
        max_fib = max(fibers)
        img_sz = image_size(f, n)
        info_erased = math.log(n) - math.log(img_sz) if img_sz > 0 else float('inf')
        print(f"\n{name}: f on {{0, ..., {n-1}}}")
        print(f"  Image size: {img_sz}")
        print(f"  Max fiber: {max_fib}")
        print(f"  Information erased: {info_erased:.4f} nats")
        print(f"  Injective: {max_fib <= 1}")
        non_trivial_fibers = [(y, fiber_card(f, n, y)) for y in range(n) if fiber_card(f, n, y) > 0]
        print(f"  Non-trivial fibers: {non_trivial_fibers[:6]}{'...' if len(non_trivial_fibers) > 6 else ''}")


if __name__ == "__main__":
    demo_image_contraction()
    demo_polynomial_vs_exponential()
    demo_entropy_budget()
    demo_maxwell_demon()
    demo_fiber_analysis()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Entropy Contraction Under Iteration

Shows how the image size (and hence entropy) decreases under
repeated application of a non-injective function, while remaining
constant for a bijective function.
"""
import matplotlib.pyplot as plt
import matplotlib
import math

matplotlib.use('Agg')


def iterate_f(f, k, x):
    for _ in range(k):
        x = f(x)
    return x


def image_size_after_k(f, n, k):
    return len(set(iterate_f(f, k, x) for x in range(n)))


def main():
    n = 64
    max_k = 10

    functions = {
        r"$f(x) = \lfloor x/2 \rfloor$ (halving)": lambda x: x // 2,
        r"$f(x) = \lfloor x/3 \rfloor$ (thirding)": lambda x: x // 3,
        r"$f(x) = x \bmod 8$ (modular)": lambda x: x % 8,
        r"$f(x) = (x+1) \bmod n$ (rotation, bijective)": lambda x: (x + 1) % n,
    }

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db']

    for (name, f), color in zip(functions.items(), colors):
        ks = list(range(max_k + 1))
        sizes = [image_size_after_k(f, n, k) for k in ks]
        entropies = [math.log(s) if s > 0 else 0 for s in sizes]

        ax1.plot(ks, sizes, 'o-', label=name, color=color, linewidth=2, markersize=6)
        ax2.plot(ks, entropies, 's-', label=name, color=color, linewidth=2, markersize=6)

    ax1.set_xlabel('Iteration k', fontsize=12)
    ax1.set_ylabel('Image Size |f^k({0,...,n-1})|', fontsize=12)
    ax1.set_title('Image Contraction Under Iteration', fontsize=14)
    ax1.legend(fontsize=9, loc='upper right')
    ax1.set_ylim(0, n + 5)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=n, color='gray', linestyle='--', alpha=0.5, label=f'n={n}')

    ax2.set_xlabel('Iteration k', fontsize=12)
    ax2.set_ylabel('Entropy ln(|image|)', fontsize=12)
    ax2.set_title('Entropy Decrease Under Iteration', fontsize=14)
    ax2.legend(fontsize=9, loc='upper right')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_entropy_contraction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_entropy_contraction.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: CEA Capacity Hierarchy

Shows the strict polynomial hierarchy of CEA entropy capacities:
budget n^d * c < n^(d+1) * c for n >= 2.
"""
import matplotlib.pyplot as plt
import matplotlib
import math

matplotlib.use('Agg')


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    c = 1.0  # per-step cost
    ns = list(range(2, 20))
    colors = ['#3498db', '#2ecc71', '#e67e22', '#9b59b6', '#e74c3c', '#1abc9c']

    # Left: Capacity hierarchy
    for d, color in zip(range(1, 7), colors):
        capacities = [n**d * c for n in ns]
        ax1.plot(ns, capacities, 'o-', color=color, linewidth=2,
                 markersize=4, label=f'd={d}: $n^{d} \\cdot c$')

    ax1.set_xlabel('Base n', fontsize=12)
    ax1.set_ylabel('Entropy Capacity ($n^d \\cdot c$)', fontsize=12)
    ax1.set_title('CEA Polynomial Capacity Hierarchy', fontsize=14)
    ax1.set_yscale('log')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Gap between consecutive levels
    for d, color in zip(range(1, 6), colors):
        gaps = [(n**(d+1) * c - n**d * c) / (n**d * c) for n in ns]
        ax2.plot(ns, gaps, 's-', color=color, linewidth=2,
                 markersize=4, label=f'$(n^{{{d+1}}} - n^{d}) / n^{d}$')

    ax2.set_xlabel('Base n', fontsize=12)
    ax2.set_ylabel('Relative Capacity Gap', fontsize=12)
    ax2.set_title('Relative Gap Between Hierarchy Levels', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Polynomial vs Exponential Growth

Shows the thermodynamic barrier: for any polynomial degree d,
2^n eventually dominates n^d, meaning exponential entropy
requirements exceed polynomial computational budgets.
"""
import matplotlib.pyplot as plt
import matplotlib
import math

matplotlib.use('Agg')


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ns = list(range(1, 25))
    colors_poly = ['#3498db', '#2ecc71', '#e67e22', '#9b59b6', '#e74c3c']

    # Left: absolute values
    exp_vals = [2**n for n in ns]
    ax1.plot(ns, exp_vals, 'k-', linewidth=3, label=r'$2^n$ (exponential)', zorder=5)

    for d, color in zip(range(1, 6), colors_poly):
        poly_vals = [n**d for n in ns]
        ax1.plot(ns, poly_vals, '--', color=color, linewidth=2, label=f'$n^{d}$')

    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Exponential vs Polynomial Growth', fontsize=14)
    ax1.set_yscale('log')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: ratio n^d / 2^n → 0
    ns_long = list(range(1, 40))
    for d, color in zip(range(1, 6), colors_poly):
        ratios = [n**d / 2**n for n in ns_long]
        ax2.plot(ns_long, ratios, '-', color=color, linewidth=2, label=f'$n^{d}/2^n$')

    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel(r'$n^d / 2^n$', fontsize=12)
    ax2.set_title(r'Ratio $n^d/2^n \to 0$ (Exponential Dominance)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=0, color='black', linewidth=0.5)

    # Mark thresholds
    for d, color in zip(range(1, 6), colors_poly):
        N = 1
        while N**d >= 2**N:
            N += 1
        ax2.axvline(x=N, color=color, linestyle=':', alpha=0.5)
        ax2.annotate(f'N={N}', xy=(N, 0.01), fontsize=8, color=color,
                     ha='center', va='bottom')

    plt.tight_layout()
    plt.savefig('viz_poly_vs_exp.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_poly_vs_exp.png")


if __name__ == "__main__":
    main()
