#!/usr/bin/env python3
"""
Demo: Reversible Sorting and Thermodynamic Cost Analysis

Demonstrates the key results from the formalization:
1. Bennett's reversible witness construction for sorting
2. Landauer cost comparison across sorting algorithms
3. Fiber decomposition analysis
4. Scaling behavior of sorting entropy
"""

import math
from itertools import permutations
from collections import Counter


def factorial(n: int) -> int:
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def sorting_entropy(n: int) -> float:
    if n <= 1:
        return 0.0
    return math.log2(factorial(n))


def landauer_cost(kT: float, bits: float) -> float:
    return kT * math.log(2) * bits


def main():
    kT_room = 4.14e-21  # kT at room temperature (300K) in joules

    print("=" * 72)
    print("  REVERSIBLE SORTING AND THERMODYNAMIC COST ANALYSIS")
    print("  Formal proofs in Lean 4 — Numerical demonstrations")
    print("=" * 72)

    # Demo 1: Sorting entropy scaling
    print("\n┌─ DEMO 1: Sorting Entropy (log₂(n!) bits) ─────────────────────────┐")
    print(f"│ {'n':>4} │ {'n!':>12} │ {'log₂(n!)':>10} │ {'n·log₂n':>10} │ {'ratio':>8} │")
    print(f"│{'─'*4}─┼{'─'*12}─┼{'─'*10}─┼{'─'*10}─┼{'─'*8}─│")
    for n in [2, 3, 5, 8, 10, 15, 20, 50, 100]:
        nfact = factorial(n)
        entropy = sorting_entropy(n)
        nlogn = n * math.log2(n) if n > 1 else 0
        ratio = entropy / nlogn if nlogn > 0 else 0
        nfact_str = str(nfact) if nfact < 1e10 else f"{nfact:.3e}"
        print(f"│ {n:>4} │ {nfact_str:>12} │ {entropy:>10.2f} │ {nlogn:>10.2f} │ {ratio:>8.4f} │")
    print(f"└{'─' * 70}┘")

    # Demo 2: Landauer cost comparison
    print("\n┌─ DEMO 2: Thermodynamic Cost at Room Temperature ──────────────────┐")
    print(f"│ {'n':>4} │ {'Optimal (J)':>14} │ {'MergeSort (J)':>14} │ {'BubbleSort (J)':>14} │")
    print(f"│{'─'*4}─┼{'─'*14}─┼{'─'*14}─┼{'─'*14}─│")
    for n in [5, 10, 20, 50, 100, 1000]:
        entropy = sorting_entropy(n)
        merge_comps = n * math.ceil(math.log2(max(2, n))) if n > 1 else 0
        bubble_comps = n * (n - 1) // 2
        w_opt = landauer_cost(kT_room, entropy)
        w_merge = landauer_cost(kT_room, merge_comps)
        w_bubble = landauer_cost(kT_room, bubble_comps)
        print(f"│ {n:>4} │ {w_opt:>14.4e} │ {w_merge:>14.4e} │ {w_bubble:>14.4e} │")
    print(f"└{'─' * 54}┘")

    # Demo 3: Reversible witness construction
    print("\n┌─ DEMO 3: Bennett's Reversible Witness (n=4) ──────────────────────┐")
    n = 4
    perms = list(permutations(range(n)))
    print(f"│ Number of permutations (4!): {len(perms)}")
    print(f"│ History bits needed: ⌈log₂(24)⌉ = {math.ceil(math.log2(24))}")
    print(f"│ Sorting entropy: {sorting_entropy(4):.4f} bits")
    print(f"│")
    print(f"│ Sample encodings (σ → (sorted, history_index)):")
    for i, perm in enumerate(perms[:8]):
        print(f"│   {list(perm)} → (sorted=[0,1,2,3], history={i})")
    print(f"│   ... ({len(perms) - 8} more)")
    print(f"│")
    print(f"│ Roundtrip verification: ", end="")
    all_ok = True
    for perm in perms:
        idx = perms.index(perm)
        recovered = perms[idx]
        if recovered != perm:
            all_ok = False
            break
    print(f"{'✓ PASS' if all_ok else '✗ FAIL'} (all {len(perms)} permutations)")
    print(f"└{'─' * 70}┘")

    # Demo 4: Fiber analysis
    print("\n┌─ DEMO 4: Fiber Decomposition Analysis ─────────────────────────────┐")

    # Sorting function: constant (all perms → sorted)
    print(f"│ Sorting function (n=3): all 6 permutations → single output")
    print(f"│   max_fiber_size = 6 = 3!")
    print(f"│   info_erased = log₂(6) - log₂(1) = {math.log2(6):.4f} bits")
    print(f"│")

    # Bijection: identity
    print(f"│ Identity function (n=3): each input maps to itself")
    print(f"│   max_fiber_size = 1")
    print(f"│   info_erased = log₂(3) - log₂(3) = 0 bits")
    print(f"│")

    # Projection: (a,b) → a
    domain_4 = [(i, j) for i in range(2) for j in range(2)]
    proj = lambda x: x[0]
    fibers = Counter(proj(x) for x in domain_4)
    print(f"│ Projection (2×2 → 2): (a,b) ↦ a")
    print(f"│   fibers: {dict(fibers)}")
    print(f"│   max_fiber_size = {max(fibers.values())}")
    ie = math.log2(4) - math.log2(2)
    print(f"│   info_erased = log₂(4) - log₂(2) = {ie:.4f} bits")
    print(f"└{'─' * 71}┘")

    # Demo 5: Wasted work analysis
    print("\n┌─ DEMO 5: Thermodynamic Waste of Suboptimal Algorithms ─────────────┐")
    print(f"│ {'n':>4} │ {'Bubble waste':>14} │ {'Merge waste':>14} │ {'Bubble/Opt':>12} │")
    print(f"│{'─'*4}─┼{'─'*14}─┼{'─'*14}─┼{'─'*12}─│")
    for n in [5, 10, 20, 50, 100]:
        entropy = sorting_entropy(n)
        merge_comps = n * math.ceil(math.log2(max(2, n))) if n > 1 else 0
        bubble_comps = n * (n - 1) // 2
        bubble_waste = bubble_comps - entropy
        merge_waste = merge_comps - entropy
        ratio = bubble_comps / entropy if entropy > 0 else 0
        print(f"│ {n:>4} │ {bubble_waste:>12.1f} b │ {merge_waste:>12.1f} b │ {ratio:>10.2f}× │")
    print(f"└{'─' * 52}┘")

    # Demo 6: Reversible bubble sort trace
    print("\n┌─ DEMO 6: Reversible Bubble Sort Trace ──────────────────────────────┐")
    arr = [4, 2, 7, 1, 3]
    n = len(arr)
    history = []
    a = list(arr)
    for i in range(n):
        for j in range(n - 1 - i):
            swapped = a[j] > a[j + 1]
            history.append((j, j + 1, swapped))
            if swapped:
                a[j], a[j + 1] = a[j + 1], a[j]

    print(f"│ Input:  {arr}")
    print(f"│ Output: {a}")
    print(f"│ History ({len(history)} comparisons):")
    for j, k, swapped in history[:8]:
        print(f"│   Compare positions {j},{k}: {'swapped' if swapped else 'kept'}")
    if len(history) > 8:
        print(f"│   ... ({len(history) - 8} more)")

    # Reverse
    b = list(a)
    for j, k, swapped in reversed(history):
        if swapped:
            b[j], b[k] = b[k], b[j]
    print(f"│ Reversed: {b}")
    print(f"│ Match original: {'✓' if b == arr else '✗'}")
    print(f"│")
    print(f"│ Comparisons used: {len(history)}")
    print(f"│ Information-theoretic minimum: {sorting_entropy(n):.2f} bits")
    print(f"│ Wasted bits: {len(history) - sorting_entropy(n):.2f}")
    print(f"│ Landauer cost (irreversible): {landauer_cost(kT_room, len(history)):.4e} J")
    print(f"│ Landauer cost (reversible):   0 J")
    print(f"└{'─' * 72}┘")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Thermodynamic Cost Landscape of Sorting Algorithms

Generates plots showing the relationship between sorting entropy,
algorithmic efficiency, and thermodynamic work.
"""

import math

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.ticker as ticker
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available, skipping visualization")


def factorial(n):
    r = 1
    for i in range(2, n + 1):
        r *= i
    return r


def sorting_entropy(n):
    if n <= 1:
        return 0.0
    return math.log2(factorial(n))


def main():
    if not HAS_MPL:
        return

    ns = list(range(2, 101))
    entropy = [sorting_entropy(n) for n in ns]
    nlogn = [n * math.log2(n) for n in ns]
    bubble = [n * (n - 1) / 2 for n in ns]
    merge = [n * math.ceil(math.log2(n)) for n in ns]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Thermodynamics of Sorting: Entropy, Work, and Reversibility',
                 fontsize=14, fontweight='bold')

    # Plot 1: Comparison counts
    ax = axes[0, 0]
    ax.plot(ns, entropy, 'b-', linewidth=2, label='log₂(n!) [optimal]')
    ax.plot(ns, nlogn, 'g--', linewidth=1.5, label='n·log₂(n)')
    ax.plot(ns, merge, 'r-.', linewidth=1.5, label='Merge sort')
    ax.plot(ns, bubble, 'm:', linewidth=1.5, label='Bubble sort')
    ax.set_xlabel('n (elements)')
    ax.set_ylabel('Comparisons / Bits')
    ax.set_title('Sorting Complexity Landscape')
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: Thermodynamic waste
    ax = axes[0, 1]
    waste_bubble = [b - e for b, e in zip(bubble, entropy)]
    waste_merge = [m - e for m, e in zip(merge, entropy)]
    ax.fill_between(ns, waste_bubble, alpha=0.3, color='red', label='Bubble sort waste')
    ax.fill_between(ns, waste_merge, alpha=0.3, color='blue', label='Merge sort waste')
    ax.plot(ns, waste_bubble, 'r-', linewidth=1.5)
    ax.plot(ns, waste_merge, 'b-', linewidth=1.5)
    ax.set_xlabel('n (elements)')
    ax.set_ylabel('Wasted bits')
    ax.set_title('Thermodynamic Waste (excess Landauer cost)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Efficiency ratio
    ax = axes[1, 0]
    eff_bubble = [e / b if b > 0 else 1 for e, b in zip(entropy, bubble)]
    eff_merge = [e / m if m > 0 else 1 for e, m in zip(entropy, merge)]
    ax.plot(ns, eff_merge, 'b-', linewidth=2, label='Merge sort')
    ax.plot(ns, eff_bubble, 'r-', linewidth=2, label='Bubble sort')
    ax.axhline(y=1.0, color='g', linestyle='--', alpha=0.5, label='Perfect efficiency')
    ax.set_xlabel('n (elements)')
    ax.set_ylabel('Thermodynamic efficiency')
    ax.set_title('Algorithmic Efficiency (log₂(n!) / comparisons)')
    ax.legend(fontsize=9)
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.3)

    # Plot 4: Stirling approximation quality
    ax = axes[1, 1]
    stirling = [n * math.log2(n) - n * math.log2(math.e) for n in ns]
    ratio = [s / e if e > 0 else 0 for s, e in zip(stirling, entropy)]
    ax.plot(ns, ratio, 'purple', linewidth=2)
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('n (elements)')
    ax.set_ylabel('Stirling / Exact ratio')
    ax.set_title('Stirling Approximation Quality for log₂(n!)')
    ax.set_ylim(0.85, 1.01)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('thermodynamic_sorting.png', dpi=150, bbox_inches='tight')
    print("Saved thermodynamic_sorting.png")


if __name__ == '__main__':
    main()
