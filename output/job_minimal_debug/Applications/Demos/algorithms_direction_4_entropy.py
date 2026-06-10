#!/usr/bin/env python3
"""
Entropy-Complexity Bridge: Algorithms and Implementations

Implements the key algorithms underlying the formal theorems:
- Entropy bound computation
- Support cardinality tracking through function composition
- Compressor-based entropy estimation
"""

import math
from typing import TypeVar, Callable, List, Set, Dict, Tuple, Optional
from dataclasses import dataclass

T = TypeVar('T')
U = TypeVar('U')
V = TypeVar('V')


def entropy_bound(cardinality: int) -> int:
    """
    Compute the minimum number of bits needed to encode `cardinality` distinct objects.
    
    This is ⌈log₂(cardinality)⌉, the finite uniform entropy.
    Corresponds to the formal predicate: EntropyBound α k ↔ |α| ≤ 2^k,
    so the minimum k satisfying this is ⌈log₂|α|⌉.
    
    Args:
        cardinality: Number of distinct objects to encode.
        
    Returns:
        Minimum number of bits for a lossless injective encoding.
        
    Examples:
        >>> entropy_bound(1)
        0
        >>> entropy_bound(2)
        1
        >>> entropy_bound(8)
        3
        >>> entropy_bound(100)
        7
    """
    if cardinality <= 0:
        return 0
    if cardinality == 1:
        return 0
    return math.ceil(math.log2(cardinality))


def check_entropy_bound(cardinality: int, k: int) -> bool:
    """
    Check whether EntropyBound holds: |α| ≤ 2^k.
    
    Args:
        cardinality: |α|, the number of elements.
        k: The proposed bit budget.
        
    Returns:
        True if cardinality ≤ 2^k.
    """
    return cardinality <= 2 ** k


def support_size(f: Callable[[T], U], domain: List[T]) -> int:
    """
    Compute |range(f)| = number of distinct outputs of f on the given domain.
    
    This is the support cardinality, the combinatorial entropy surrogate.
    
    Args:
        f: A function from domain elements to some codomain.
        domain: The finite domain to evaluate f on.
        
    Returns:
        Number of distinct values in {f(x) : x ∈ domain}.
    """
    return len(set(f(x) for x in domain))


def verify_data_processing(
    f: Callable[[T], U],
    g: Callable[[U], V],
    domain: List[T]
) -> Tuple[int, int, bool]:
    """
    Verify the data processing inequality: |range(g ∘ f)| ≤ |range(f)|.
    
    Args:
        f: First function (α → β).
        g: Second function (β → γ).
        domain: The finite domain α.
        
    Returns:
        Tuple of (|range(g∘f)|, |range(f)|, inequality_holds).
    """
    range_f = set(f(x) for x in domain)
    range_gf = set(g(f(x)) for x in domain)
    return len(range_gf), len(range_f), len(range_gf) <= len(range_f)


def verify_entropy_subadditivity(
    card_alpha: int, k: int,
    card_beta: int, l: int
) -> Dict[str, any]:
    """
    Verify entropy subadditivity: if |α| ≤ 2^k and |β| ≤ 2^ℓ,
    then |α × β| ≤ 2^(k+ℓ).
    
    Args:
        card_alpha: |α|
        k: Entropy bound for α
        card_beta: |β|  
        l: Entropy bound for β
        
    Returns:
        Dictionary with verification results.
    """
    bound_alpha = check_entropy_bound(card_alpha, k)
    bound_beta = check_entropy_bound(card_beta, l)
    card_product = card_alpha * card_beta
    bound_product = check_entropy_bound(card_product, k + l)
    
    return {
        "card_alpha": card_alpha,
        "k": k,
        "alpha_bound_holds": bound_alpha,
        "card_beta": card_beta,
        "l": l,
        "beta_bound_holds": bound_beta,
        "card_product": card_product,
        "k_plus_l": k + l,
        "product_bound_holds": bound_product,
        "theorem_applicable": bound_alpha and bound_beta,
        "theorem_verified": not (bound_alpha and bound_beta) or bound_product,
    }


@dataclass
class CompressorResult:
    """Result of applying a compressor to a collection."""
    max_compressed_length: int
    entropy_bound_k: int
    cardinality_bound: int
    actual_cardinality: int
    bound_holds: bool
    compressed_lengths: List[int]


class InvertibleCompressor:
    """
    An invertible compressor satisfying the formal specification:
    - Idempotent: compress(compress(s)) = compress(s)
    - Non-expanding: len(compress(s)) ≤ len(s)
    - Strictly shortening on non-fixed-points
    - Invertible: decompress(compress(s)) = s
    """
    
    def compress(self, bits: List[int]) -> List[int]:
        """Compress a bit sequence. Must be overridden."""
        raise NotImplementedError
    
    def decompress(self, bits: List[int], original_length: int) -> List[int]:
        """Decompress a bit sequence. Must be overridden."""
        raise NotImplementedError
    
    def apply_to_family(self, family: List[List[int]]) -> CompressorResult:
        """
        Apply the compressor to a family and compute the entropy bound.
        
        Implements complexity_bound_implies_finite_entropy_bound:
        if max compressed length is k, then |family| ≤ 2^(k+1).
        """
        compressed_lengths = [len(self.compress(bits)) for bits in family]
        k = max(compressed_lengths) if compressed_lengths else 0
        bound = 2 ** (k + 1)
        
        return CompressorResult(
            max_compressed_length=k,
            entropy_bound_k=k + 1,
            cardinality_bound=bound,
            actual_cardinality=len(family),
            bound_holds=len(family) <= bound,
            compressed_lengths=compressed_lengths,
        )


class TrailingZeroCompressor(InvertibleCompressor):
    """Compressor that removes trailing zeros."""
    
    def compress(self, bits: List[int]) -> List[int]:
        if not bits:
            return bits
        result = list(bits)
        while result and result[-1] == 0:
            result.pop()
        return result if result else [0]
    
    def decompress(self, bits: List[int], original_length: int) -> List[int]:
        return bits + [0] * (original_length - len(bits))


class RunLengthCompressor(InvertibleCompressor):
    """Simple run-length encoding compressor."""
    
    def compress(self, bits: List[int]) -> List[int]:
        if not bits:
            return []
        result = []
        current = bits[0]
        count = 1
        for b in bits[1:]:
            if b == current:
                count += 1
            else:
                result.extend([current, count])
                current = b
                count = 1
        result.extend([current, count])
        # Only use compressed if shorter
        if len(result) < len(bits):
            return result
        return bits
    
    def decompress(self, bits: List[int], original_length: int) -> List[int]:
        # Try run-length decode
        if len(bits) % 2 == 0 and len(bits) < original_length:
            result = []
            for i in range(0, len(bits), 2):
                result.extend([bits[i]] * bits[i + 1])
            if len(result) == original_length:
                return result
        return bits


def information_flow_analysis(
    functions: List[Callable],
    domain: List[T]
) -> List[Dict[str, any]]:
    """
    Analyze information flow through a chain of functions.
    
    Demonstrates that support cardinality is monotonically non-increasing
    through a pipeline of deterministic transformations.
    
    Args:
        functions: List of functions [f₁, f₂, ..., fₙ].
        domain: The initial finite domain.
        
    Returns:
        List of dictionaries with step-by-step analysis.
    """
    results = []
    current_values = list(domain)
    
    for i, func in enumerate(functions):
        new_values = [func(x) for x in current_values]
        distinct_before = len(set(current_values))
        distinct_after = len(set(new_values))
        
        results.append({
            "step": i + 1,
            "distinct_inputs": distinct_before,
            "distinct_outputs": distinct_after,
            "information_preserved": distinct_after == distinct_before,
            "information_lost": distinct_before - distinct_after,
            "compression_ratio": distinct_after / distinct_before if distinct_before > 0 else 0,
        })
        
        current_values = new_values
    
    return results


if __name__ == "__main__":
    print("Entropy-Complexity Bridge: Algorithm Demonstrations")
    print("=" * 55)
    
    # Entropy bound examples
    print("\n--- Entropy Bounds ---")
    for n in [1, 2, 3, 4, 8, 16, 100, 1000]:
        k = entropy_bound(n)
        print(f"|α| = {n:>4}  →  min bits = {k:>2}  (2^{k} = {2**k})")
    
    # Data processing
    print("\n--- Data Processing Inequality ---")
    domain = list(range(20))
    f = lambda x: x % 7
    g = lambda x: x % 3
    r_gf, r_f, holds = verify_data_processing(f, g, domain)
    print(f"|range(f)| = {r_f}, |range(g∘f)| = {r_gf}, inequality holds: {holds}")
    
    # Subadditivity
    print("\n--- Entropy Subadditivity ---")
    result = verify_entropy_subadditivity(6, 3, 5, 3)
    print(f"|α|={result['card_alpha']}, k={result['k']}: bound holds = {result['alpha_bound_holds']}")
    print(f"|β|={result['card_beta']}, l={result['l']}: bound holds = {result['beta_bound_holds']}")
    print(f"|α×β|={result['card_product']}, k+l={result['k_plus_l']}: bound holds = {result['product_bound_holds']}")
    
    # Compressor
    print("\n--- Compressor Entropy Bound ---")
    compressor = TrailingZeroCompressor()
    family = [[(i >> j) & 1 for j in range(5)] for i in range(32)]
    result = compressor.apply_to_family(family)
    print(f"Family size: {result.actual_cardinality}")
    print(f"Max compressed length: {result.max_compressed_length}")
    print(f"Entropy bound: |family| ≤ 2^{result.entropy_bound_k} = {result.cardinality_bound}")
    print(f"Bound holds: {result.bound_holds}")
    
    # Information flow
    print("\n--- Information Flow Analysis ---")
    pipeline = [
        lambda x: x ** 2,         # squaring (lossy: -x and x collide)
        lambda x: x % 10,         # mod 10 (lossy)
        lambda x: x > 5,          # threshold (very lossy)
    ]
    flow = information_flow_analysis(pipeline, list(range(-10, 11)))
    for step in flow:
        print(f"Step {step['step']}: {step['distinct_inputs']} → {step['distinct_outputs']} "
              f"(lost {step['information_lost']}, ratio {step['compression_ratio']:.2f})")
