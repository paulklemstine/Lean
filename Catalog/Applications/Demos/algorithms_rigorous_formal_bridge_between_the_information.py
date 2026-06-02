"""
Algorithms for Reversible Sorting and Thermodynamic Cost Analysis

This module implements the key algorithms from the formalization of
Bennett's theorem applied to sorting, including reversible sort
implementations, Landauer cost calculations, and fiber analysis.
"""

import math
from typing import List, Tuple, Dict, Callable, TypeVar, Generic
from itertools import permutations
from collections import Counter

T = TypeVar('T')


def factorial(n: int) -> int:
    """Compute n! iteratively."""
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def sorting_entropy_bits(n: int) -> float:
    """
    Compute the sorting entropy in bits: log₂(n!).

    This is the information content of a uniformly random permutation
    of n elements — the minimum number of bits that must be erased
    (or recorded as history) when sorting.
    """
    if n <= 1:
        return 0.0
    return math.log2(factorial(n))


def landauer_cost(kT: float, bits_erased: float) -> float:
    """
    Compute the Landauer cost of erasing `bits_erased` bits.

    W = kT · ln(2) · bits_erased

    At room temperature (T = 300K), kT ≈ 4.14 × 10⁻²¹ J.
    """
    return kT * math.log(2) * bits_erased


def min_sorting_work(n: int, kT: float = 4.14e-21) -> float:
    """
    Minimum thermodynamic work to sort n elements irreversibly.

    W_min = kT · ln(2) · log₂(n!)
    """
    return landauer_cost(kT, sorting_entropy_bits(n))


def info_erased(domain_size: int, image_size: int) -> float:
    """
    Information erased by a function: log₂(|domain|) - log₂(|image|).

    For sorting: domain = n!, image = 1, so info_erased = log₂(n!).
    """
    if domain_size <= 0 or image_size <= 0:
        return 0.0
    return math.log2(domain_size) - math.log2(image_size)


def max_fiber_size(f: Callable, domain: list) -> int:
    """
    Compute the maximum fiber size of a function f on a domain.

    The fiber of y is {x ∈ domain : f(x) = y}. Returns max |fiber(y)|.
    """
    fibers: Dict = Counter(f(x) for x in domain)
    return max(fibers.values()) if fibers else 0


def fiber_decomposition(f: Callable, domain: list) -> Dict:
    """
    Compute the complete fiber decomposition of f.

    Returns dict mapping each output value to the list of inputs
    that produce it.
    """
    fibers: Dict = {}
    for x in domain:
        y = f(x)
        if y not in fibers:
            fibers[y] = []
        fibers[y].append(x)
    return fibers


class ReversibleSortWitness:
    """
    A reversible sorting witness for permutations of [0, ..., n-1].

    The encoding maps each permutation σ to (sorted, history),
    where history records which permutation σ was, enabling
    perfect reconstruction of the original input.
    """

    def __init__(self, n: int):
        self.n = n
        self.perms = list(permutations(range(n)))
        # Build encoding: permutation index → ((), perm_index)
        self.perm_to_index = {p: i for i, p in enumerate(self.perms)}

    def encode(self, perm: tuple) -> Tuple[tuple, int]:
        """Encode: σ ↦ (sorted, history_index)."""
        sorted_output = tuple(sorted(perm))
        history = self.perm_to_index[perm]
        return (sorted_output, history)

    def decode(self, sorted_output: tuple, history: int) -> tuple:
        """Decode: (sorted, history_index) ↦ σ."""
        return self.perms[history]

    def verify_roundtrip(self) -> bool:
        """Verify that encode/decode is a perfect roundtrip for all permutations."""
        for perm in self.perms:
            s, h = self.encode(perm)
            recovered = self.decode(s, h)
            if recovered != perm:
                return False
        return True

    def aux_space_size(self) -> int:
        """Size of the auxiliary (history) space: n!."""
        return len(self.perms)

    def aux_bits(self) -> float:
        """Number of bits needed for the history: ⌈log₂(n!)⌉."""
        return math.ceil(math.log2(max(1, self.aux_space_size())))


class BubbleSortTraced:
    """
    Bubble sort with comparison history recording.

    Records every comparison made, enabling reversibility by
    replaying the comparison outcomes in reverse.
    """

    def __init__(self):
        self.history: List[Tuple[int, int, bool]] = []

    def sort(self, arr: List[int]) -> List[int]:
        """Sort arr using bubble sort, recording comparison history."""
        self.history = []
        a = list(arr)
        n = len(a)
        for i in range(n):
            for j in range(n - 1 - i):
                swapped = a[j] > a[j + 1]
                self.history.append((j, j + 1, swapped))
                if swapped:
                    a[j], a[j + 1] = a[j + 1], a[j]
        return a

    def unsort(self, sorted_arr: List[int]) -> List[int]:
        """Reverse the sort using recorded history."""
        a = list(sorted_arr)
        for j, k, swapped in reversed(self.history):
            if swapped:
                a[j], a[k] = a[k], a[j]
        return a

    def comparison_count(self) -> int:
        return len(self.history)

    def wasted_bits(self, n: int) -> float:
        """Bits of comparison history beyond the information-theoretic minimum."""
        return self.comparison_count() - sorting_entropy_bits(n)


def algorithm_comparison(n: int, kT: float = 4.14e-21) -> Dict[str, float]:
    """
    Compare thermodynamic costs of different sorting strategies on n elements.

    Returns dict with costs for:
    - optimal: information-theoretic minimum
    - merge_sort: n⌈log₂n⌉ comparisons
    - bubble_sort: n(n-1)/2 comparisons
    - reversible: zero Landauer cost (all info preserved)
    """
    entropy = sorting_entropy_bits(n)
    merge_comps = n * math.ceil(math.log2(max(2, n))) if n > 1 else 0
    bubble_comps = n * (n - 1) // 2

    return {
        'n': n,
        'entropy_bits': entropy,
        'optimal_cost_J': landauer_cost(kT, entropy),
        'merge_sort_cost_J': landauer_cost(kT, merge_comps),
        'bubble_sort_cost_J': landauer_cost(kT, bubble_comps),
        'reversible_cost_J': 0.0,
        'merge_waste_bits': merge_comps - entropy,
        'bubble_waste_bits': bubble_comps - entropy,
        'merge_efficiency': entropy / merge_comps if merge_comps > 0 else 1.0,
        'bubble_efficiency': entropy / bubble_comps if bubble_comps > 0 else 1.0,
    }


if __name__ == '__main__':
    # Quick self-test
    for n in range(1, 7):
        w = ReversibleSortWitness(n)
        assert w.verify_roundtrip(), f"Roundtrip failed for n={n}"
        print(f"n={n}: aux_space={w.aux_space_size()}, aux_bits={w.aux_bits()}, "
              f"entropy={sorting_entropy_bits(n):.2f}")

    print("\nBubble sort trace test:")
    bs = BubbleSortTraced()
    original = [3, 1, 4, 1, 5, 9]
    sorted_arr = bs.sort(original)
    recovered = bs.unsort(sorted_arr)
    print(f"  Original:  {original}")
    print(f"  Sorted:    {sorted_arr}")
    print(f"  Recovered: {recovered}")
    print(f"  Comparisons: {bs.comparison_count()}")
    print(f"  Wasted bits: {bs.wasted_bits(len(original)):.2f}")
