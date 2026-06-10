#!/usr/bin/env python3
"""
Thermodynamics of Sorting: Numerical Demonstrations

Demonstrates the key results:
1. Comparison counts for various sorting algorithms
2. Thermodynamic work (in units of kT) for each algorithm
3. Entropy gap (wasted work) analysis
4. Stirling approximation verification
"""

import math
import random
from typing import List, Tuple

# Boltzmann constant (J/K)
kB = 1.380649e-23
# Room temperature (K)
T = 300.0
# kT at room temperature
kT = kB * T


def merge_sort_count(arr: List[int]) -> Tuple[List[int], int]:
    """Merge sort that counts comparisons."""
    if len(arr) <= 1:
        return arr[:], 0
    mid = len(arr) // 2
    left, c1 = merge_sort_count(arr[:mid])
    right, c2 = merge_sort_count(arr[mid:])
    merged = []
    comparisons = c1 + c2
    i = j = 0
    while i < len(left) and j < len(right):
        comparisons += 1
        if left[i] <= right[j]:
            merged.append(left[i])
            i += 1
        else:
            merged.append(right[j])
            j += 1
    merged.extend(left[i:])
    merged.extend(right[j:])
    return merged, comparisons


def bubble_sort_count(arr: List[int]) -> Tuple[List[int], int]:
    """Bubble sort that counts comparisons."""
    arr = arr[:]
    n = len(arr)
    comparisons = 0
    for i in range(n):
        for j in range(n - 1 - i):
            comparisons += 1
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr, comparisons


def insertion_sort_count(arr: List[int]) -> Tuple[List[int], int]:
    """Insertion sort that counts comparisons."""
    arr = arr[:]
    comparisons = 0
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0:
            comparisons += 1
            if arr[j] > key:
                arr[j + 1] = arr[j]
                j -= 1
            else:
                break
        arr[j + 1] = key
    return arr, comparisons


def quicksort_count(arr: List[int]) -> Tuple[List[int], int]:
    """Quicksort that counts comparisons (random pivot)."""
    if len(arr) <= 1:
        return arr[:], 0
    pivot_idx = random.randint(0, len(arr) - 1)
    pivot = arr[pivot_idx]
    left, right, equal = [], [], []
    comparisons = 0
    for x in arr:
        if x == pivot:
            equal.append(x)
        else:
            comparisons += 1
            if x < pivot:
                left.append(x)
            else:
                right.append(x)
    sorted_left, c1 = quicksort_count(left)
    sorted_right, c2 = quicksort_count(right)
    return sorted_left + equal + sorted_right, comparisons + c1 + c2


def log_factorial(n: int) -> float:
    """Compute log(n!) = sum of log(k) for k=1..n."""
    return sum(math.log(k) for k in range(1, n + 1))


def thermodynamic_work(comparisons: int) -> float:
    """Thermodynamic work in units of kT."""
    return comparisons * math.log(2)


def entropy_gap(n: int, comparisons: int) -> float:
    """Entropy gap (wasted work) in nats."""
    return thermodynamic_work(comparisons) - log_factorial(n)


def stirling_ratio(n: int) -> float:
    """Compute log(n!) / (n * log(n))."""
    if n <= 1:
        return float('inf')
    return log_factorial(n) / (n * math.log(n))


def main():
    print("=" * 70)
    print("THERMODYNAMICS OF SORTING: Numerical Demonstrations")
    print("=" * 70)

    # Demo 1: Comparison counts
    print("\n--- Demo 1: Comparison Counts ---")
    print(f"{'n':>6} {'log₂(n!)':>10} {'Merge':>8} {'Bubble':>8} {'Insert':>8} {'Quick':>8}")
    print("-" * 55)

    for n in [8, 16, 32, 64, 128, 256]:
        arr = list(range(n))
        random.shuffle(arr)

        _, c_merge = merge_sort_count(arr[:])
        _, c_bubble = bubble_sort_count(arr[:])
        _, c_insert = insertion_sort_count(arr[:])
        _, c_quick = quicksort_count(arr[:])
        log_nfact = math.log2(math.factorial(n))

        print(f"{n:>6} {log_nfact:>10.1f} {c_merge:>8} {c_bubble:>8} {c_insert:>8} {c_quick:>8}")

    # Demo 2: Thermodynamic work
    print("\n--- Demo 2: Thermodynamic Work (in kT units) ---")
    print(f"{'n':>6} {'W_min (kT)':>12} {'W_merge':>12} {'W_bubble':>12} {'Ratio':>8}")
    print("-" * 55)

    for n in [10, 50, 100, 500, 1000]:
        arr = list(range(n))
        random.shuffle(arr)

        _, c_merge = merge_sort_count(arr[:])
        _, c_bubble = bubble_sort_count(arr[:])

        w_min = log_factorial(n)
        w_merge = thermodynamic_work(c_merge)
        w_bubble = thermodynamic_work(c_bubble)
        ratio = w_bubble / w_min

        print(f"{n:>6} {w_min:>12.1f} {w_merge:>12.1f} {w_bubble:>12.1f} {ratio:>8.2f}")

    # Demo 3: Entropy gap (wasted work)
    print("\n--- Demo 3: Entropy Gap (Wasted Work in nats) ---")
    print(f"{'n':>6} {'Gap_merge':>12} {'Gap_bubble':>12} {'Gap_ratio':>10}")
    print("-" * 45)

    for n in [10, 50, 100, 500]:
        arr = list(range(n))
        random.shuffle(arr)

        _, c_merge = merge_sort_count(arr[:])
        _, c_bubble = bubble_sort_count(arr[:])

        gap_merge = entropy_gap(n, c_merge)
        gap_bubble = entropy_gap(n, c_bubble)
        gap_ratio = gap_bubble / gap_merge if gap_merge > 0 else float('inf')

        print(f"{n:>6} {gap_merge:>12.1f} {gap_bubble:>12.1f} {gap_ratio:>10.1f}")

    # Demo 4: Stirling approximation
    print("\n--- Demo 4: Stirling Ratio log(n!) / (n·log(n)) ---")
    print(f"{'n':>8} {'log(n!)':>12} {'n·log(n)':>12} {'Ratio':>8} {'1-1/log(n)':>12}")
    print("-" * 60)

    for n in [3, 5, 10, 50, 100, 1000, 10000]:
        lnf = log_factorial(n)
        nlnn = n * math.log(n)
        ratio = lnf / nlnn
        lower = 1 - 1 / math.log(n)

        print(f"{n:>8} {lnf:>12.2f} {nlnn:>12.2f} {ratio:>8.4f} {lower:>12.4f}")

    # Demo 5: Physical energy scale
    print("\n--- Demo 5: Physical Energy of Sorting at Room Temperature ---")
    print(f"kT at {T}K = {kT:.4e} J")
    print(f"{'n':>8} {'W_min (J)':>15} {'W_bubble (J)':>15} {'Waste (J)':>15}")
    print("-" * 60)

    for n in [10, 100, 1000, 10**6]:
        w_min_nats = log_factorial(n)
        w_bubble_nats = n * (n - 1) / 2 * math.log(2)
        w_min_J = kT * w_min_nats
        w_bubble_J = kT * w_bubble_nats
        waste_J = w_bubble_J - w_min_J

        print(f"{n:>8} {w_min_J:>15.4e} {w_bubble_J:>15.4e} {waste_J:>15.4e}")

    print("\n" + "=" * 70)
    print("Key insight: The entropy gap of bubble sort grows as O(n²),")
    print("while the minimum work grows as O(n·log(n)). Bubble sort")
    print("wastes quadratically more energy than necessary.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Entropy gap (thermodynamic waste) for different sorting algorithms.
Shows how bubble sort wastes quadratically more energy than merge sort.
"""
import math
import random

def log_factorial(n):
    return sum(math.log(k) for k in range(1, n + 1))

def merge_sort_count(arr):
    if len(arr) <= 1:
        return 0
    mid = len(arr) // 2
    c1 = merge_sort_count(arr[:mid])
    c2 = merge_sort_count(arr[mid:])
    return c1 + c2 + len(arr) - 1  # worst case merge

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    ns = list(range(4, 201))
    random.seed(42)

    gaps_merge = []
    gaps_bubble = []
    gaps_insert = []

    for n in ns:
        lnf = log_factorial(n)
        c_merge = int(n * math.log2(n))  # approximate
        c_bubble = n * (n - 1) // 2
        c_insert = n * (n - 1) // 4  # average case

        gaps_merge.append(c_merge * math.log(2) - lnf)
        gaps_bubble.append(c_bubble * math.log(2) - lnf)
        gaps_insert.append(c_insert * math.log(2) - lnf)

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(ns, gaps_merge, 'b-', linewidth=2, label='Merge Sort gap ≈ O(n)')
    ax.plot(ns, gaps_insert, color='#FF9800', linewidth=2,
            label='Insertion Sort gap ≈ O(n²/4)')
    ax.plot(ns, gaps_bubble, 'r-', linewidth=2, label='Bubble Sort gap ≈ O(n²/2)')

    ax.set_xlabel('n (number of elements)', fontsize=12)
    ax.set_ylabel('Entropy Gap (nats of wasted work)', fontsize=12)
    ax.set_title('Thermodynamic Waste: Entropy Gap by Algorithm', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_gap.png', dpi=150)
    print("Saved entropy_gap.png")

except ImportError:
    print("matplotlib not available; skipping visualization")


#!/usr/bin/env python3
"""
Visualization: Entropy trace during sorting.
Shows how entropy decreases with each comparison for different algorithms.
"""
import math
import random

def log_factorial(n):
    return sum(math.log(k) for k in range(1, n + 1))

def entropy_after(n, c):
    return max(0.0, log_factorial(n) - c * math.log(2))

def merge_sort_count(arr):
    if len(arr) <= 1:
        return arr[:], 0
    mid = len(arr) // 2
    left, c1 = merge_sort_count(arr[:mid])
    right, c2 = merge_sort_count(arr[mid:])
    merged, i, j, c = [], 0, 0, c1 + c2
    while i < len(left) and j < len(right):
        c += 1
        if left[i] <= right[j]:
            merged.append(left[i]); i += 1
        else:
            merged.append(right[j]); j += 1
    merged.extend(left[i:]); merged.extend(right[j:])
    return merged, c

def bubble_sort_count(arr):
    arr, n, c = arr[:], len(arr), 0
    for i in range(n):
        for j in range(n - 1 - i):
            c += 1
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr, c

def insertion_sort_count(arr):
    arr, c = arr[:], 0
    for i in range(1, len(arr)):
        key, j = arr[i], i - 1
        while j >= 0:
            c += 1
            if arr[j] > key:
                arr[j+1] = arr[j]; j -= 1
            else:
                break
        arr[j+1] = key
    return arr, c

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    n = 50
    random.seed(42)
    arr = list(range(n))
    random.shuffle(arr)

    _, c_merge = merge_sort_count(arr[:])
    _, c_bubble = bubble_sort_count(arr[:])
    _, c_insert = insertion_sort_count(arr[:])

    initial_entropy = log_factorial(n)

    fig, ax = plt.subplots(figsize=(10, 6))

    for label, total_c, color in [
        ("Merge Sort", c_merge, "#2196F3"),
        ("Insertion Sort", c_insert, "#FF9800"),
        ("Bubble Sort", c_bubble, "#F44336"),
    ]:
        xs = list(range(total_c + 1))
        ys = [entropy_after(n, c) for c in xs]
        ax.plot(xs, ys, label=f"{label} ({total_c} comparisons)", color=color, linewidth=2)

    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.axhline(y=initial_entropy, color='green', linestyle='--', alpha=0.5,
               label=f'Initial entropy ln({n}!) = {initial_entropy:.1f} nats')

    ax.set_xlabel('Number of Comparisons', fontsize=12)
    ax.set_ylabel('Remaining Entropy (nats)', fontsize=12)
    ax.set_title(f'Entropy Reduction During Sorting (n={n})', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_trace.png', dpi=150)
    print("Saved entropy_trace.png")

except ImportError:
    print("matplotlib not available; skipping visualization")


#!/usr/bin/env python3
"""
Visualization: Stirling approximation bounds.
Shows log(n!) sandwiched between n*log(n) - n and n*log(n).
"""
import math

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    ns = list(range(2, 101))
    log_facts = [sum(math.log(k) for k in range(1, n+1)) for n in ns]
    upper = [n * math.log(n) for n in ns]
    lower = [n * math.log(n) - n for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: absolute values
    ax1.plot(ns, log_facts, 'b-', linewidth=2, label='ln(n!)')
    ax1.plot(ns, upper, 'r--', linewidth=1.5, label='n·ln(n)')
    ax1.plot(ns, lower, 'g--', linewidth=1.5, label='n·ln(n) - n')
    ax1.fill_between(ns, lower, upper, alpha=0.1, color='blue')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Value (nats)', fontsize=12)
    ax1.set_title('Stirling Bounds on ln(n!)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: ratio
    ratios = [lf / (n * math.log(n)) for lf, n in zip(log_facts, ns)]
    ax2.plot(ns, ratios, 'b-', linewidth=2, label='ln(n!) / (n·ln(n))')
    ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='y = 1')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Ratio', fontsize=12)
    ax2.set_title('Convergence of ln(n!)/(n·ln(n)) → 1', fontsize=14)
    ax2.set_ylim(0.7, 1.05)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('stirling_bounds.png', dpi=150)
    print("Saved stirling_bounds.png")

except ImportError:
    print("matplotlib not available; skipping visualization")
