#!/usr/bin/env python3
"""
Thermodynamics of Sorting: Algorithm Implementations

Type-hinted implementations of sorting algorithms with entropy bookkeeping.
Each algorithm returns (sorted_list, comparison_count, entropy_trace).
"""

import math
import random
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class SortResult:
    """Result of a sorting algorithm with thermodynamic bookkeeping."""
    sorted_array: List[int]
    comparisons: int
    entropy_trace: List[float]  # Entropy after each comparison

    @property
    def thermodynamic_work(self) -> float:
        """Work in units of kT (natural log base)."""
        return self.comparisons * math.log(2)

    @property
    def minimum_work(self) -> float:
        """Minimum thermodynamic work for sorting n elements."""
        n = len(self.sorted_array)
        return sum(math.log(k) for k in range(1, n + 1))

    @property
    def entropy_gap(self) -> float:
        """Wasted thermodynamic work."""
        return self.thermodynamic_work - self.minimum_work

    @property
    def efficiency(self) -> float:
        """Thermodynamic efficiency (0 to 1)."""
        if self.thermodynamic_work == 0:
            return 1.0
        return self.minimum_work / self.thermodynamic_work


def log_factorial(n: int) -> float:
    """Compute ln(n!) using Stirling's approximation for large n."""
    if n <= 1:
        return 0.0
    return sum(math.log(k) for k in range(1, n + 1))


def entropy_after_comparisons(n: int, comparisons_made: int) -> float:
    """Approximate entropy remaining after c comparisons.

    Initially entropy = ln(n!). Each comparison reduces entropy by at most ln(2).
    This is an upper bound on remaining entropy.
    """
    initial = log_factorial(n)
    return max(0.0, initial - comparisons_made * math.log(2))


def merge_sort_thermo(arr: List[int]) -> SortResult:
    """Merge sort with thermodynamic bookkeeping.

    Pseudocode:
        MERGE-SORT(A):
          if |A| <= 1: return A
          mid = |A| / 2
          L = MERGE-SORT(A[1..mid])
          R = MERGE-SORT(A[mid+1..|A|])
          return MERGE(L, R)  // each merge comparison costs kT·ln(2)
    """
    n = len(arr)
    comparisons = [0]
    trace: List[float] = []

    def merge_sort_inner(a: List[int]) -> List[int]:
        if len(a) <= 1:
            return a[:]
        mid = len(a) // 2
        left = merge_sort_inner(a[:mid])
        right = merge_sort_inner(a[mid:])
        merged: List[int] = []
        i = j = 0
        while i < len(left) and j < len(right):
            comparisons[0] += 1
            trace.append(entropy_after_comparisons(n, comparisons[0]))
            if left[i] <= right[j]:
                merged.append(left[i])
                i += 1
            else:
                merged.append(right[j])
                j += 1
        merged.extend(left[i:])
        merged.extend(right[j:])
        return merged

    result = merge_sort_inner(arr)
    return SortResult(result, comparisons[0], trace)


def bubble_sort_thermo(arr: List[int]) -> SortResult:
    """Bubble sort with thermodynamic bookkeeping.

    Pseudocode:
        BUBBLE-SORT(A):
          for i = 1 to n:
            for j = 1 to n-i:
              COMPARE(A[j], A[j+1])  // costs kT·ln(2)
              if A[j] > A[j+1]: SWAP(A[j], A[j+1])
    """
    n = len(arr)
    a = arr[:]
    comparisons = 0
    trace: List[float] = []

    for i in range(n):
        for j in range(n - 1 - i):
            comparisons += 1
            trace.append(entropy_after_comparisons(n, comparisons))
            if a[j] > a[j + 1]:
                a[j], a[j + 1] = a[j + 1], a[j]

    return SortResult(a, comparisons, trace)


def insertion_sort_thermo(arr: List[int]) -> SortResult:
    """Insertion sort with thermodynamic bookkeeping.

    Pseudocode:
        INSERTION-SORT(A):
          for i = 2 to n:
            key = A[i]
            j = i - 1
            while j >= 1 and A[j] > key:
              COMPARE(A[j], key)  // costs kT·ln(2)
              A[j+1] = A[j]
              j = j - 1
            A[j+1] = key
    """
    n = len(arr)
    a = arr[:]
    comparisons = 0
    trace: List[float] = []

    for i in range(1, n):
        key = a[i]
        j = i - 1
        while j >= 0:
            comparisons += 1
            trace.append(entropy_after_comparisons(n, comparisons))
            if a[j] > key:
                a[j + 1] = a[j]
                j -= 1
            else:
                break
        a[j + 1] = key

    return SortResult(a, comparisons, trace)


def quicksort_thermo(arr: List[int]) -> SortResult:
    """Quicksort with thermodynamic bookkeeping (random pivot).

    Pseudocode:
        QUICKSORT(A):
          if |A| <= 1: return A
          pivot = random element of A
          L = {x in A : x < pivot}    // each test costs kT·ln(2)
          R = {x in A : x > pivot}
          return QUICKSORT(L) + [pivot] + QUICKSORT(R)
    """
    n = len(arr)
    comparisons = [0]
    trace: List[float] = []

    def qs_inner(a: List[int]) -> List[int]:
        if len(a) <= 1:
            return a[:]
        pivot_idx = random.randint(0, len(a) - 1)
        pivot = a[pivot_idx]
        left, right, equal = [], [], []
        for x in a:
            if x == pivot:
                equal.append(x)
            else:
                comparisons[0] += 1
                trace.append(entropy_after_comparisons(n, comparisons[0]))
                if x < pivot:
                    left.append(x)
                else:
                    right.append(x)
        return qs_inner(left) + equal + qs_inner(right)

    result = qs_inner(arr)
    return SortResult(result, comparisons[0], trace)


def analyze_algorithms(n: int, num_trials: int = 10) -> None:
    """Run all algorithms on random inputs and report statistics."""
    print(f"\n{'='*60}")
    print(f"Analysis for n = {n} ({num_trials} trials)")
    print(f"{'='*60}")
    print(f"Minimum work (ln(n!) nats): {log_factorial(n):.2f}")
    print(f"Minimum comparisons (⌈log₂(n!)⌉): {math.ceil(math.log2(math.factorial(n)))}")
    print()

    algorithms = {
        "Merge Sort": merge_sort_thermo,
        "Bubble Sort": bubble_sort_thermo,
        "Insertion Sort": insertion_sort_thermo,
        "Quicksort": quicksort_thermo,
    }

    for name, algo in algorithms.items():
        comps = []
        effs = []
        gaps = []
        for _ in range(num_trials):
            arr = list(range(n))
            random.shuffle(arr)
            result = algo(arr)
            comps.append(result.comparisons)
            effs.append(result.efficiency)
            gaps.append(result.entropy_gap)

        avg_comp = sum(comps) / len(comps)
        avg_eff = sum(effs) / len(effs)
        avg_gap = sum(gaps) / len(gaps)

        print(f"{name:>20}: avg comparisons = {avg_comp:.1f}, "
              f"efficiency = {avg_eff:.4f}, entropy gap = {avg_gap:.1f}")


if __name__ == "__main__":
    for n in [10, 50, 100]:
        analyze_algorithms(n)
