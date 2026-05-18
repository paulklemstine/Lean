#!/usr/bin/env python3
"""
Algorithms: Entropy–Compression–Communication Complexity Barriers

Implements the core algorithms from the barrier framework:
1. Bounded bitstring enumeration and counting
2. Optimal encoding and incompressibility detection
3. Karchmer–Wigderson witness enumeration
4. KW complexity estimation
5. Entropy computation and compression bounds
"""

from itertools import product
from math import log2, ceil, floor
from typing import Callable, TypeVar, Optional
from dataclasses import dataclass

T = TypeVar('T')


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Bounded Bitstring Counting
# ─────────────────────────────────────────────────────────────

def count_bounded_bitstrings(k: int) -> int:
    """
    Count bitstrings of length ≤ k.

    Uses the geometric series formula: Σ_{i=0}^{k} 2^i = 2^(k+1) - 1.

    Time complexity: O(1) (closed-form)
    Space complexity: O(1)

    Args:
        k: Maximum bitstring length

    Returns:
        Number of distinct bitstrings of length 0, 1, ..., k

    Examples:
        >>> count_bounded_bitstrings(0)
        1
        >>> count_bounded_bitstrings(3)
        15
        >>> count_bounded_bitstrings(10)
        2047
    """
    return (1 << (k + 1)) - 1


def enumerate_bounded_bitstrings(k: int) -> list[tuple[int, ...]]:
    """
    Enumerate all bitstrings of length ≤ k.

    Time complexity: O(2^(k+1))
    Space complexity: O(2^(k+1))

    Args:
        k: Maximum bitstring length

    Returns:
        List of all bitstrings (as tuples of 0/1) of length ≤ k

    Examples:
        >>> enumerate_bounded_bitstrings(1)
        [(), (0,), (1,)]
        >>> len(enumerate_bounded_bitstrings(3))
        15
    """
    result = []
    for length in range(k + 1):
        for bits in product([0, 1], repeat=length):
            result.append(bits)
    return result


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Incompressibility Detection
# ─────────────────────────────────────────────────────────────

@dataclass
class IncompressibilityResult:
    """Result of an incompressibility analysis."""
    set_size: int
    max_short_codes: int
    min_long_code_length: int
    is_incompressible: bool
    witness_element: Optional[int]  # Element needing a long code
    encoding: Optional[dict]  # The actual encoding used


def analyze_incompressibility(
    elements: list,
    max_code_length: int,
    encoder: Optional[Callable] = None
) -> IncompressibilityResult:
    """
    Analyze whether a set can be injectively encoded with short codes.

    Implements the finite incompressibility theorem:
    If |elements| > 2^(k+1) - 1, some element needs code length > k.

    Time complexity: O(n log n) where n = |elements|
    Space complexity: O(n)

    Args:
        elements: The set to encode
        max_code_length: Maximum desired code length k
        encoder: Optional custom encoder; default uses lexicographic

    Returns:
        IncompressibilityResult with analysis details

    Examples:
        >>> r = analyze_incompressibility(list(range(16)), 3)
        >>> r.is_incompressible
        True
        >>> r.min_long_code_length
        4
    """
    n = len(elements)
    max_short = count_bounded_bitstrings(max_code_length)

    if encoder is None:
        # Default: assign codes in order, shortest first
        codes = enumerate_bounded_bitstrings(max_code_length)
        encoding = {}
        witness = None

        for i, elem in enumerate(elements):
            if i < len(codes):
                encoding[elem] = codes[i]
            else:
                if witness is None:
                    witness = elem
                # Need longer code
                extra_bits = i - len(codes)
                long_code = tuple(
                    int(b) for b in format(extra_bits, f'0{max_code_length + 1}b')
                )
                encoding[elem] = (1,) + long_code  # Prefix with 1 to distinguish
    else:
        encoding = {elem: encoder(elem) for elem in elements}
        witness = max(elements, key=lambda e: len(encoding[e]))

    is_incompressible = n > max_short
    min_long = ceil(log2(n)) if n > 1 else 0

    return IncompressibilityResult(
        set_size=n,
        max_short_codes=max_short,
        min_long_code_length=min_long,
        is_incompressible=is_incompressible,
        witness_element=witness,
        encoding=encoding
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 3: KW Witness Enumeration
# ─────────────────────────────────────────────────────────────

@dataclass
class KWWitness:
    """A Karchmer–Wigderson witness: (x, y, i) where f(x)=T, f(y)=F, x[i]≠y[i]."""
    x: tuple[int, ...]
    y: tuple[int, ...]
    index: int

    def __repr__(self):
        return f"KW(x={self.x}, y={self.y}, i={self.index})"


def enumerate_kw_witnesses(
    f: Callable[[tuple[int, ...]], bool],
    n: int
) -> list[KWWitness]:
    """
    Enumerate all KW witnesses for a Boolean function f on n variables.

    A KW witness is a triple (x, y, i) where:
    - f(x) = True (x is a "yes" instance)
    - f(y) = False (y is a "no" instance)
    - x[i] ≠ y[i] (coordinate i distinguishes x from y)

    Time complexity: O(2^(2n) · n)
    Space complexity: O(|witnesses|)

    Args:
        f: Boolean function on n-bit inputs
        n: Number of input variables

    Returns:
        List of all KW witnesses

    Examples:
        >>> parity = lambda x: sum(x) % 2 == 1
        >>> len(enumerate_kw_witnesses(parity, 2))
        8
    """
    inputs = list(product([0, 1], repeat=n))
    true_inputs = [x for x in inputs if f(x)]
    false_inputs = [y for y in inputs if not f(y)]

    witnesses = []
    for x in true_inputs:
        for y in false_inputs:
            for i in range(n):
                if x[i] != y[i]:
                    witnesses.append(KWWitness(x=x, y=y, index=i))

    return witnesses


def kw_witness_cardinality(
    f: Callable[[tuple[int, ...]], bool],
    n: int
) -> int:
    """
    Compute |KWWitness(f)| for a Boolean function f on n variables.

    Time complexity: O(2^(2n) · n)
    Space complexity: O(1) (counting only)

    Args:
        f: Boolean function
        n: Number of variables

    Returns:
        Cardinality of the KW witness space
    """
    inputs = list(product([0, 1], repeat=n))
    true_inputs = [x for x in inputs if f(x)]
    false_inputs = [y for y in inputs if not f(y)]

    count = 0
    for x in true_inputs:
        for y in false_inputs:
            for i in range(n):
                if x[i] != y[i]:
                    count += 1
    return count


# ─────────────────────────────────────────────────────────────
# Algorithm 4: KW Complexity Estimation
# ─────────────────────────────────────────────────────────────

@dataclass
class KWComplexityBound:
    """Bounds on KW complexity derived from witness counting."""
    witness_count: int
    log_lower_bound: float  # log₂(witness_count) is a lower bound
    compression_bound: int  # Minimum code length forced
    entropy_bound: float    # Shannon entropy of uniform distribution


def estimate_kw_complexity(
    f: Callable[[tuple[int, ...]], bool],
    n: int
) -> KWComplexityBound:
    """
    Estimate KW complexity bounds from the witness space.

    The chain of implications:
    |KWWitness(f)| ≥ 2^d  →  min code length ≥ d  →  entropy ≥ d

    Time complexity: O(2^(2n) · n)
    Space complexity: O(1)

    Args:
        f: Boolean function
        n: Number of variables

    Returns:
        KWComplexityBound with derived bounds
    """
    count = kw_witness_cardinality(f, n)
    log_bound = log2(count) if count > 0 else 0
    compression = ceil(log_bound)
    entropy = log_bound  # Uniform entropy = log₂(|support|)

    return KWComplexityBound(
        witness_count=count,
        log_lower_bound=log_bound,
        compression_bound=compression,
        entropy_bound=entropy
    )


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Entropy and Information Bounds
# ─────────────────────────────────────────────────────────────

def shannon_entropy(distribution: dict[str, float]) -> float:
    """
    Compute Shannon entropy H(X) = -Σ p(x) log₂ p(x).

    Time complexity: O(|support|)
    Space complexity: O(1)

    Args:
        distribution: Mapping from outcomes to probabilities

    Returns:
        Shannon entropy in bits

    Examples:
        >>> shannon_entropy({"H": 0.5, "T": 0.5})
        1.0
        >>> round(shannon_entropy({"a": 0.25, "b": 0.25, "c": 0.25, "d": 0.25}), 2)
        2.0
    """
    H = 0.0
    for p in distribution.values():
        if p > 0:
            H -= p * log2(p)
    return H


def uniform_entropy(n: int) -> float:
    """
    Shannon entropy of uniform distribution on n elements = log₂(n).

    Args:
        n: Number of elements

    Returns:
        Entropy in bits
    """
    return log2(n) if n > 0 else 0.0


def source_coding_bound(alphabet_size: int) -> float:
    """
    Source coding theorem: expected code length ≥ entropy.

    For uniform distribution on alphabet_size elements,
    expected code length ≥ log₂(alphabet_size).

    Args:
        alphabet_size: Number of distinct symbols

    Returns:
        Lower bound on expected code length (bits)
    """
    return uniform_entropy(alphabet_size)


# ─────────────────────────────────────────────────────────────
# Standard Boolean Functions
# ─────────────────────────────────────────────────────────────

def parity(x: tuple[int, ...]) -> bool:
    """XOR/parity function."""
    return sum(x) % 2 == 1


def majority(x: tuple[int, ...]) -> bool:
    """Majority function (strict majority of 1s)."""
    return sum(x) > len(x) / 2


def threshold_k(k: int) -> Callable[[tuple[int, ...]], bool]:
    """Threshold-k function: true iff at least k inputs are 1."""
    return lambda x: sum(x) >= k


def or_fn(x: tuple[int, ...]) -> bool:
    """OR function."""
    return any(b == 1 for b in x)


def and_fn(x: tuple[int, ...]) -> bool:
    """AND function."""
    return all(b == 1 for b in x)


# ─────────────────────────────────────────────────────────────
# Main: Run all algorithms with examples
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Bounded Bitstring Counting")
    print("-" * 40)
    for k in range(8):
        print(f"  k={k}: |bs length ≤ {k}| = {count_bounded_bitstrings(k)}")

    print()
    print("Incompressibility Analysis")
    print("-" * 40)
    for size in [8, 16, 32, 64]:
        result = analyze_incompressibility(list(range(size)), 3)
        print(f"  |α|={size}, k=3: incompressible={result.is_incompressible}, "
              f"min code={result.min_long_code_length}")

    print()
    print("KW Complexity Bounds")
    print("-" * 40)
    functions = [
        ("Parity", parity),
        ("Majority", majority),
        ("OR", or_fn),
        ("AND", and_fn),
    ]
    for n in range(2, 6):
        print(f"  n={n}:")
        for name, f in functions:
            bounds = estimate_kw_complexity(f, n)
            print(f"    {name:>10}: |KW|={bounds.witness_count:>6}, "
                  f"log₂={bounds.log_lower_bound:>6.2f}, "
                  f"entropy={bounds.entropy_bound:>6.2f}")
        print()
