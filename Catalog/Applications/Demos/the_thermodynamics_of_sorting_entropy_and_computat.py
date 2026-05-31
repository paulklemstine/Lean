#!/usr/bin/env python3
"""
Thermodynamic Sorting Demo

Demonstrates the connection between sorting algorithms, information entropy,
and thermodynamic work via Landauer's principle.
"""

import math
import random
from algorithms import (
    bubble_sort_counted, merge_sort_counted, insertion_sort_counted,
    heapsort_counted, sorting_entropy_bits, thermodynamic_work,
    min_thermodynamic_work, wasted_work, factorial,
    stirling_entropy_lower, stirling_entropy_upper,
    KT_ROOM, LANDAUER_BIT
)


def demo_sorting_with_entropy():
    """Demonstrate sorting with entropy bookkeeping."""
    print("=" * 70)
    print("THERMODYNAMIC SORTING DEMO")
    print("=" * 70)
    print()
    print(f"Physical constants:")
    print(f"  kT (room temp) = {KT_ROOM:.3e} J")
    print(f"  Landauer limit = {LANDAUER_BIT:.3e} J/bit")
    print()

    for n in [5, 8, 10, 15, 20]:
        print(f"\n{'='*60}")
        print(f"Sorting n = {n} elements")
        print(f"{'='*60}")

        # Generate worst-case-ish input (reverse sorted)
        arr = list(range(n, 0, -1))

        # Sort with each algorithm
        algorithms = [
            ("Bubble Sort", bubble_sort_counted),
            ("Insertion Sort", insertion_sort_counted),
            ("Merge Sort", merge_sort_counted),
            ("Heapsort", heapsort_counted),
        ]

        entropy = sorting_entropy_bits(n)
        min_w = min_thermodynamic_work(n)
        optimal_comps = math.ceil(math.log2(factorial(n))) if n > 1 else 0

        print(f"  Permutation entropy: {entropy:.2f} bits")
        print(f"  Information-theoretic minimum: {optimal_comps} comparisons")
        print(f"  Minimum thermodynamic work: {min_w:.3e} J")
        print()
        print(f"  {'Algorithm':<20} {'Comparisons':>12} {'Work (J)':>14} {'Waste (J)':>14} {'Efficiency':>10}")
        print(f"  {'-'*20} {'-'*12} {'-'*14} {'-'*14} {'-'*10}")

        for name, sort_fn in algorithms:
            sorted_arr, comps = sort_fn(arr)
            assert sorted_arr == sorted(arr), f"{name} failed!"
            w = thermodynamic_work(comps)
            waste = wasted_work(comps, n)
            efficiency = optimal_comps / comps * 100 if comps > 0 else 100
            print(f"  {name:<20} {comps:>12} {w:>14.3e} {waste:>14.3e} {efficiency:>9.1f}%")


def demo_stirling_bounds():
    """Verify Stirling bounds on sorting entropy."""
    print(f"\n\n{'='*70}")
    print("STIRLING APPROXIMATION BOUNDS")
    print("='*70")
    print()
    print(f"  {'n':>5} {'log₂(n!)':>12} {'Lower bound':>12} {'Upper bound':>12} {'Gap':>8}")
    print(f"  {'-'*5} {'-'*12} {'-'*12} {'-'*12} {'-'*8}")

    for n in [3, 5, 10, 20, 50, 100, 200, 500, 1000]:
        entropy = sorting_entropy_bits(n)
        lower = stirling_entropy_lower(n)
        upper = stirling_entropy_upper(n)
        gap = entropy - lower
        print(f"  {n:>5} {entropy:>12.2f} {lower:>12.2f} {upper:>12.2f} {gap:>8.3f}")

    print()
    print("  Conjecture: n·log₂(n) - n·log₂(e) ≤ log₂(n!) for n ≥ 3: ", end="")
    all_valid = all(stirling_entropy_lower(n) <= sorting_entropy_bits(n) for n in range(3, 1001))
    print("✓ VERIFIED" if all_valid else "✗ FAILED")


def demo_thermodynamic_waste():
    """Show thermodynamic waste as a function of n."""
    print(f"\n\n{'='*70}")
    print("THERMODYNAMIC WASTE: BUBBLE SORT vs MERGE SORT")
    print("='*70")
    print()
    print(f"  {'n':>5} {'Optimal':>10} {'Merge':>10} {'Bubble':>10} {'Waste(B)':>12} {'Ratio(B/M)':>12}")
    print(f"  {'-'*5} {'-'*10} {'-'*10} {'-'*10} {'-'*12} {'-'*12}")

    for n in [5, 10, 20, 50, 100, 200, 500]:
        optimal = math.ceil(math.log2(factorial(n))) if n > 1 else 0
        merge = n * math.ceil(math.log2(n)) if n > 1 else 0
        bubble = n * (n - 1) // 2
        waste_bubble = bubble - optimal
        ratio = bubble / merge if merge > 0 else float('inf')
        print(f"  {n:>5} {optimal:>10} {merge:>10} {bubble:>10} {waste_bubble:>12} {ratio:>12.2f}")


def demo_random_inputs():
    """Compare algorithms on random inputs (average case)."""
    print(f"\n\n{'='*70}")
    print("AVERAGE CASE: RANDOM INPUTS (100 trials)")
    print("='*70")
    print()

    random.seed(42)

    for n in [10, 20, 50]:
        print(f"\n  n = {n}:")
        print(f"  {'Algorithm':<20} {'Avg Comps':>10} {'Min Comps':>10} {'Max Comps':>10} {'Optimal':>10}")
        print(f"  {'-'*20} {'-'*10} {'-'*10} {'-'*10} {'-'*10}")

        optimal = math.ceil(math.log2(factorial(n)))

        for name, sort_fn in [
            ("Bubble Sort", bubble_sort_counted),
            ("Insertion Sort", insertion_sort_counted),
            ("Merge Sort", merge_sort_counted),
            ("Heapsort", heapsort_counted),
        ]:
            comps_list = []
            for _ in range(100):
                arr = list(range(n))
                random.shuffle(arr)
                _, comps = sort_fn(arr)
                comps_list.append(comps)
            avg = sum(comps_list) / len(comps_list)
            print(f"  {name:<20} {avg:>10.1f} {min(comps_list):>10} {max(comps_list):>10} {optimal:>10}")


def demo_energy_scale():
    """Put thermodynamic costs in context."""
    print(f"\n\n{'='*70}")
    print("ENERGY SCALE CONTEXT")
    print("='*70")
    print()

    comparisons = [
        ("Sorting 10 elements (optimal)", math.ceil(math.log2(factorial(10)))),
        ("Sorting 10 elements (bubble sort)", 10 * 9 // 2),
        ("Sorting 100 elements (optimal)", math.ceil(math.log2(factorial(100)))),
        ("Sorting 100 elements (bubble sort)", 100 * 99 // 2),
        ("Sorting 1000 elements (optimal)", math.ceil(math.log2(factorial(1000)))),
        ("Sorting 1000 elements (bubble sort)", 1000 * 999 // 2),
    ]

    print(f"  {'Operation':<45} {'Comparisons':>12} {'Energy (J)':>14}")
    print(f"  {'-'*45} {'-'*12} {'-'*14}")
    for name, comps in comparisons:
        energy = thermodynamic_work(comps)
        print(f"  {name:<45} {comps:>12} {energy:>14.3e}")

    print()
    print("  Context:")
    print(f"    1 ATP hydrolysis          ≈ 5.0e-20 J")
    print(f"    1 photon of visible light ≈ 3.0e-19 J")
    print(f"    1 kcal                    ≈ 4.2e+03 J")
    print(f"    Your daily food intake    ≈ 8.4e+06 J")


if __name__ == "__main__":
    demo_sorting_with_entropy()
    demo_stirling_bounds()
    demo_thermodynamic_waste()
    demo_random_inputs()
    demo_energy_scale()


#!/usr/bin/env python3
"""
Visualization: Decision Tree for Sorting

Shows the binary decision tree structure for sorting small lists,
illustrating how each comparison partitions the permutation space
and reduces entropy by at most 1 bit.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations


def factorial(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def entropy_reduction_simulation(n, num_trials=1000):
    """
    Simulate sorting random permutations, tracking entropy reduction.
    Returns average entropy curve over comparisons.
    """
    import random
    random.seed(42)

    all_perms = list(permutations(range(n)))
    total_perms = len(all_perms)
    max_comps = n * (n - 1) // 2 + 5

    entropy_curves = []

    for _ in range(num_trials):
        perm = list(range(n))
        random.shuffle(perm)

        # Track which permutations are still consistent
        consistent = set(range(total_perms))
        entropy_curve = [math.log2(len(consistent))]
        comparisons_done = 0

        # Bubble sort with tracking
        arr = perm.copy()
        for i in range(n):
            for j in range(0, n - i - 1):
                result = arr[j] < arr[j + 1]
                # Filter consistent permutations
                new_consistent = set()
                for idx in consistent:
                    p = all_perms[idx]
                    if (p[j] < p[j + 1]) == result:
                        new_consistent.add(idx)
                consistent = new_consistent
                if arr[j] > arr[j + 1]:
                    arr[j], arr[j + 1] = arr[j + 1], arr[j]
                comparisons_done += 1
                remaining = max(1, len(consistent))
                entropy_curve.append(math.log2(remaining))
                if remaining <= 1:
                    break
            if len(consistent) <= 1:
                break

        entropy_curves.append(entropy_curve)

    # Average curves (pad shorter ones)
    max_len = max(len(c) for c in entropy_curves)
    avg_curve = []
    for i in range(max_len):
        vals = [c[i] for c in entropy_curves if i < len(c)]
        avg_curve.append(sum(vals) / len(vals) if vals else 0)

    return avg_curve


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Entropy reduction during sorting (n=4)
    ax = axes[0]
    n = 4
    curve = entropy_reduction_simulation(n, num_trials=200)
    xs = list(range(len(curve)))
    initial_entropy = math.log2(factorial(n))
    
    ax.plot(xs, curve, 'b-', linewidth=2, label=f'Average entropy (n={n})')
    ax.axhline(y=initial_entropy, color='r', linestyle='--', alpha=0.7,
               label=f'Initial: log₂({n}!) = {initial_entropy:.2f}')
    ax.axhline(y=0, color='g', linestyle='--', alpha=0.7, label='Sorted: 0 bits')
    ax.plot(xs, [max(0, initial_entropy - i) for i in xs], 'k:', alpha=0.5,
            label='1 bit/comparison (maximum)')
    ax.set_xlabel('Number of comparisons', fontsize=12)
    ax.set_ylabel('Remaining entropy (bits)', fontsize=12)
    ax.set_title(f'Entropy Reduction During Sorting (n={n})', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, initial_entropy + 1)

    # Plot 2: Decision tree depth vs entropy
    ax2 = axes[1]
    ns_range = list(range(1, 13))
    entropies = [math.log2(factorial(n)) if n > 1 else 0 for n in ns_range]
    min_depths = [math.ceil(math.log2(factorial(n))) if n > 1 else 0 for n in ns_range]
    tree_leaves = [factorial(n) for n in ns_range]
    log2_leaves = [math.log2(factorial(n)) if n > 1 else 0 for n in ns_range]

    bars1 = ax2.bar([x - 0.2 for x in ns_range], min_depths, 0.4, 
                     color='steelblue', label='Min depth: ⌈log₂(n!)⌉', alpha=0.8)
    bars2 = ax2.bar([x + 0.2 for x in ns_range], entropies, 0.4,
                     color='coral', label='Entropy: log₂(n!)', alpha=0.8)
    
    ax2.set_xlabel('n (number of elements)', fontsize=12)
    ax2.set_ylabel('Bits / Comparisons', fontsize=12)
    ax2.set_title('Decision Tree Depth vs Sorting Entropy', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')
    ax2.set_xticks(ns_range)

    plt.tight_layout()
    plt.savefig('decision_tree_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved decision_tree_entropy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Sorting Entropy and Stirling Bounds

Plots log₂(n!) alongside the Stirling lower and upper bounds,
showing how sorting entropy grows with problem size.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def factorial(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def sorting_entropy(n):
    if n <= 1:
        return 0.0
    return math.log2(factorial(n))


def stirling_lower(n):
    if n <= 1:
        return 0.0
    return n * math.log2(n) - n * math.log2(math.e)


def stirling_upper(n):
    if n <= 1:
        return 0.0
    return n * math.log2(n) - n * math.log2(math.e) + 0.5 * math.log2(2 * math.pi * n)


def main():
    ns = list(range(1, 101))
    entropies = [sorting_entropy(n) for n in ns]
    lowers = [stirling_lower(n) for n in ns]
    uppers = [stirling_upper(n) for n in ns]
    n_log_n = [n * math.log2(n) if n > 1 else 0 for n in ns]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Entropy and bounds
    ax = axes[0]
    ax.plot(ns, entropies, 'b-', linewidth=2, label='log₂(n!) [exact]')
    ax.plot(ns, lowers, 'r--', linewidth=1.5, label='n·log₂(n) − n·log₂(e) [lower]')
    ax.plot(ns, uppers, 'g--', linewidth=1.5, label='+ ½·log₂(2πn) [upper]')
    ax.plot(ns, n_log_n, 'k:', linewidth=1, label='n·log₂(n)')
    ax.fill_between(ns, lowers, uppers, alpha=0.1, color='green')
    ax.set_xlabel('n (number of elements)', fontsize=12)
    ax.set_ylabel('Entropy (bits)', fontsize=12)
    ax.set_title('Sorting Entropy: log₂(n!) and Stirling Bounds', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Gap between exact and lower bound
    ax2 = axes[1]
    gaps = [entropies[i] - lowers[i] for i in range(len(ns))]
    ax2.plot(ns, gaps, 'purple', linewidth=2)
    ax2.axhline(y=0.5 * math.log2(2 * math.pi), color='orange', linestyle='--',
                label=f'½·log₂(2π) ≈ {0.5 * math.log2(2 * math.pi):.3f}')
    ax2.set_xlabel('n (number of elements)', fontsize=12)
    ax2.set_ylabel('log₂(n!) − (n·log₂(n) − n·log₂(e))', fontsize=12)
    ax2.set_title('Stirling Approximation Gap', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('sorting_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved sorting_entropy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Thermodynamic Waste of Sorting Algorithms

Compares the thermodynamic work (in units of kT·ln(2)) of different
sorting algorithms, highlighting the waste of suboptimal algorithms.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def factorial(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def main():
    ns = list(range(2, 51))
    
    optimal = [math.ceil(math.log2(factorial(n))) for n in ns]
    merge = [n * math.ceil(math.log2(n)) for n in ns]
    bubble = [n * (n - 1) // 2 for n in ns]
    insertion_worst = [n * (n - 1) // 2 for n in ns]
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Comparison counts
    ax = axes[0]
    ax.plot(ns, optimal, 'g-', linewidth=2.5, label='Optimal: ⌈log₂(n!)⌉')
    ax.plot(ns, merge, 'b-', linewidth=2, label='Merge sort: n⌈log₂n⌉')
    ax.plot(ns, bubble, 'r-', linewidth=2, label='Bubble sort: n(n-1)/2')
    ax.fill_between(ns, optimal, bubble, alpha=0.1, color='red', label='Wasted comparisons')
    ax.set_xlabel('n (number of elements)', fontsize=12)
    ax.set_ylabel('Worst-case comparisons', fontsize=12)
    ax.set_title('Comparison Count by Algorithm', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Waste ratios
    ax2 = axes[1]
    waste_bubble = [(bubble[i] - optimal[i]) / optimal[i] * 100 if optimal[i] > 0 else 0
                    for i in range(len(ns))]
    waste_merge = [(merge[i] - optimal[i]) / optimal[i] * 100 if optimal[i] > 0 else 0
                   for i in range(len(ns))]
    
    ax2.plot(ns, waste_bubble, 'r-', linewidth=2, label='Bubble sort waste %')
    ax2.plot(ns, waste_merge, 'b-', linewidth=2, label='Merge sort waste %')
    ax2.axhline(y=0, color='g', linestyle='--', linewidth=1)
    ax2.set_xlabel('n (number of elements)', fontsize=12)
    ax2.set_ylabel('Extra comparisons (%)', fontsize=12)
    ax2.set_title('Thermodynamic Waste (% above optimal)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('thermodynamic_waste.png', dpi=150, bbox_inches='tight')
    print("Saved thermodynamic_waste.png")


if __name__ == "__main__":
    main()
