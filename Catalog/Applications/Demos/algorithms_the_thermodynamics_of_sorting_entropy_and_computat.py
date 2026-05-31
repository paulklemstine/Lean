"""
Thermodynamic Sorting: Algorithms and Analysis

Implements sorting algorithms with entropy bookkeeping to measure
thermodynamic work (in units of kT·ln(2)) for each algorithm.
"""

from __future__ import annotations
import math
from typing import List, Tuple, Callable


# Physical constants
K_BOLTZMANN = 1.380649e-23  # J/K (exact, SI 2019)
ROOM_TEMP = 300.0  # K
KT_ROOM = K_BOLTZMANN * ROOM_TEMP  # ~4.14e-21 J
LANDAUER_BIT = KT_ROOM * math.log(2)  # ~2.87e-21 J


def factorial(n: int) -> int:
    """Compute n! exactly."""
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def sorting_entropy_bits(n: int) -> float:
    """Sorting entropy in bits: log₂(n!)."""
    if n <= 1:
        return 0.0
    return math.log2(factorial(n))


def discrete_sorting_entropy(n: int) -> int:
    """Discrete sorting entropy: ⌊log₂(n!)⌋."""
    if n <= 1:
        return 0
    return int(math.log2(factorial(n)))


def min_thermodynamic_work(n: int, kT: float = KT_ROOM) -> float:
    """
    Minimum thermodynamic work for sorting n elements.
    W_min = kT · ln(2) · ⌊log₂(n!)⌋
    """
    return kT * math.log(2) * discrete_sorting_entropy(n)


def thermodynamic_work(comparisons: int, kT: float = KT_ROOM) -> float:
    """
    Thermodynamic work for a given number of comparisons.
    W = kT · ln(2) · C
    """
    return kT * math.log(2) * comparisons


def wasted_work(comparisons: int, n: int, kT: float = KT_ROOM) -> float:
    """Excess energy dissipated by a suboptimal algorithm."""
    return thermodynamic_work(comparisons, kT) - min_thermodynamic_work(n, kT)


# --- Sorting algorithms with comparison counting ---

def bubble_sort_counted(arr: List[int]) -> Tuple[List[int], int]:
    """
    Bubble sort with comparison counting.
    Returns (sorted_list, comparison_count).
    Worst case: n(n-1)/2 comparisons.
    """
    a = arr.copy()
    n = len(a)
    comparisons = 0
    for i in range(n):
        for j in range(0, n - i - 1):
            comparisons += 1
            if a[j] > a[j + 1]:
                a[j], a[j + 1] = a[j + 1], a[j]
    return a, comparisons


def insertion_sort_counted(arr: List[int]) -> Tuple[List[int], int]:
    """
    Insertion sort with comparison counting.
    Returns (sorted_list, comparison_count).
    Worst case: n(n-1)/2 comparisons.
    """
    a = arr.copy()
    n = len(a)
    comparisons = 0
    for i in range(1, n):
        key = a[i]
        j = i - 1
        while j >= 0:
            comparisons += 1
            if a[j] > key:
                a[j + 1] = a[j]
                j -= 1
            else:
                break
        a[j + 1] = key
    return a, comparisons


def merge_sort_counted(arr: List[int]) -> Tuple[List[int], int]:
    """
    Merge sort with comparison counting.
    Returns (sorted_list, comparison_count).
    Worst case: ~n⌈log₂n⌉ comparisons.
    """
    if len(arr) <= 1:
        return arr.copy(), 0
    mid = len(arr) // 2
    left, c1 = merge_sort_counted(arr[:mid])
    right, c2 = merge_sort_counted(arr[mid:])
    merged, c3 = _merge_counted(left, right)
    return merged, c1 + c2 + c3


def _merge_counted(left: List[int], right: List[int]) -> Tuple[List[int], int]:
    """Merge two sorted lists, counting comparisons."""
    result = []
    i = j = 0
    comparisons = 0
    while i < len(left) and j < len(right):
        comparisons += 1
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    result.extend(left[i:])
    result.extend(right[j:])
    return result, comparisons


def heapsort_counted(arr: List[int]) -> Tuple[List[int], int]:
    """
    Heapsort with comparison counting.
    Returns (sorted_list, comparison_count).
    """
    a = arr.copy()
    n = len(a)
    comparisons = 0

    def sift_down(start: int, end: int) -> int:
        nonlocal comparisons
        root = start
        local_comps = 0
        while 2 * root + 1 <= end:
            child = 2 * root + 1
            swap_idx = root
            comparisons += 1
            local_comps += 1
            if a[swap_idx] < a[child]:
                swap_idx = child
            if child + 1 <= end:
                comparisons += 1
                local_comps += 1
                if a[swap_idx] < a[child + 1]:
                    swap_idx = child + 1
            if swap_idx == root:
                break
            a[root], a[swap_idx] = a[swap_idx], a[root]
            root = swap_idx
        return local_comps

    # Build max heap
    for start in range((n - 2) // 2, -1, -1):
        sift_down(start, n - 1)

    # Extract elements
    for end in range(n - 1, 0, -1):
        a[0], a[end] = a[end], a[0]
        sift_down(0, end - 1)

    return a, comparisons


# --- Analysis functions ---

def bubble_sort_worst_comparisons(n: int) -> int:
    """Worst-case comparisons for bubble sort: n(n-1)/2."""
    return n * (n - 1) // 2


def merge_sort_worst_comparisons(n: int) -> int:
    """Approximate worst-case comparisons for merge sort: n⌈log₂n⌉."""
    if n <= 1:
        return 0
    return n * (math.ceil(math.log2(n)))


def stirling_entropy_lower(n: int) -> float:
    """Stirling lower bound: n·log₂(n) - n·log₂(e)."""
    if n <= 1:
        return 0.0
    return n * math.log2(n) - n * math.log2(math.e)


def stirling_entropy_upper(n: int) -> float:
    """Stirling upper bound: n·log₂(n) - n·log₂(e) + ½·log₂(2πn)."""
    if n <= 1:
        return 0.0
    return n * math.log2(n) - n * math.log2(math.e) + 0.5 * math.log2(2 * math.pi * n)


def analyze_sorting_thermodynamics(n: int) -> dict:
    """
    Complete thermodynamic analysis of sorting n elements.
    Returns a dictionary with all relevant quantities.
    """
    entropy = sorting_entropy_bits(n)
    min_work = min_thermodynamic_work(n)
    stirling_lower = stirling_entropy_lower(n)
    stirling_upper = stirling_entropy_upper(n)

    bubble_comps = bubble_sort_worst_comparisons(n)
    merge_comps = merge_sort_worst_comparisons(n)
    optimal_comps = math.ceil(math.log2(factorial(n))) if n > 1 else 0

    return {
        "n": n,
        "n_factorial": factorial(n),
        "sorting_entropy_bits": entropy,
        "stirling_lower_bound": stirling_lower,
        "stirling_upper_bound": stirling_upper,
        "optimal_comparisons": optimal_comps,
        "merge_sort_comparisons": merge_comps,
        "bubble_sort_comparisons": bubble_comps,
        "min_work_joules": min_work,
        "merge_sort_work_joules": thermodynamic_work(merge_comps),
        "bubble_sort_work_joules": thermodynamic_work(bubble_comps),
        "bubble_sort_waste_joules": wasted_work(bubble_comps, n),
        "merge_sort_waste_joules": wasted_work(merge_comps, n),
        "waste_ratio_bubble": bubble_comps / optimal_comps if optimal_comps > 0 else float('inf'),
        "waste_ratio_merge": merge_comps / optimal_comps if optimal_comps > 0 else float('inf'),
    }


if __name__ == "__main__":
    # Run analysis for several sizes
    for n in [5, 10, 20, 50, 100]:
        results = analyze_sorting_thermodynamics(n)
        print(f"\n=== n = {n} ===")
        print(f"  n! = {results['n_factorial']}")
        print(f"  Sorting entropy: {results['sorting_entropy_bits']:.2f} bits")
        print(f"  Stirling bounds: [{results['stirling_lower_bound']:.2f}, {results['stirling_upper_bound']:.2f}]")
        print(f"  Optimal comparisons: {results['optimal_comparisons']}")
        print(f"  Merge sort comparisons: {results['merge_sort_comparisons']}")
        print(f"  Bubble sort comparisons: {results['bubble_sort_comparisons']}")
        print(f"  Min work: {results['min_work_joules']:.3e} J")
        print(f"  Bubble sort work: {results['bubble_sort_work_joules']:.3e} J")
        print(f"  Bubble sort waste ratio: {results['waste_ratio_bubble']:.2f}x")
        print(f"  Merge sort waste ratio: {results['waste_ratio_merge']:.2f}x")
