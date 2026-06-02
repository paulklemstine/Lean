#!/usr/bin/env python3
"""
Algorithms for Horseshoe-Based Computation

Type-hinted implementations of the core algorithms connecting
Smale horseshoe dynamics to computational universality.
"""

from typing import Callable, TypeVar
from dataclasses import dataclass
import math
import itertools

T = TypeVar('T')


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class BoolEncoding:
    """A Boolean encoding scheme for symbolic dynamics."""
    num_symbols: int
    
    def encode(self, b: bool) -> int:
        """Encode a Boolean value as a symbol."""
        return 1 if b else 0
    
    def decode(self, s: int) -> bool:
        """Decode a symbol to a Boolean value."""
        return s != 0
    
    def roundtrip(self, b: bool) -> bool:
        """Verify the round-trip property: decode(encode(b)) == b."""
        return self.decode(self.encode(b)) == b


@dataclass
class ShiftSpace:
    """A full shift space on d symbols."""
    d: int  # number of symbols
    
    def shift(self, seq: Callable[[int], int]) -> Callable[[int], int]:
        """Apply the shift map σ: σ(x)(n) = x(n+1)."""
        return lambda n: seq(n + 1)
    
    def orbit_window(self, seq: Callable[[int], int], start: int, k: int) -> list[int]:
        """Extract a length-k orbit window starting at position start."""
        return [seq(start + i) for i in range(k)]
    
    def word_count(self, k: int) -> int:
        """Number of distinct words of length k."""
        return self.d ** k
    
    def topological_entropy(self) -> float:
        """Topological entropy h_top = log(d)."""
        return math.log(self.d) if self.d > 0 else 0.0
    
    def word_entropy(self, k: int) -> float:
        """Word entropy at scale k: k * log₂(d)."""
        return k * math.log2(self.d) if self.d > 0 else 0.0


@dataclass
class SmaleHorseshoe:
    """Abstract Smale horseshoe of degree d."""
    degree: int
    shift: ShiftSpace
    
    def __post_init__(self) -> None:
        self.shift = ShiftSpace(self.degree)
    
    def contains_sub_horseshoe(self, d_prime: int) -> bool:
        """Check if this horseshoe contains a degree-d' sub-horseshoe."""
        return 2 <= d_prime <= self.degree
    
    def sub_horseshoe_degrees(self) -> list[int]:
        """List all sub-horseshoe degrees contained in this horseshoe."""
        return list(range(2, self.degree + 1))
    
    def information_capacity(self, window_length: int) -> int:
        """Number of distinguishable patterns in a window of given length."""
        return self.degree ** window_length


# ============================================================
# Algorithm 1: Boolean Function Encoding via Shift Dynamics
# ============================================================

def encode_boolean_function(
    f: Callable[[tuple[bool, ...]], bool],
    inputs: tuple[bool, ...],
    d: int = 2
) -> Callable[[int], int]:
    """
    Encode a Boolean function evaluation f(inputs) into a shift sequence.
    
    Algorithm:
    1. Place encoded input bits at positions 0, 1, ..., n-1
    2. Place encoded output at position n
    3. Fill remaining positions with 0
    
    Returns a bi-infinite sequence (as a callable) whose orbit window
    [0, n] encodes the computation f(inputs).
    
    Time complexity: O(1) per position lookup
    Space complexity: O(n) for input storage
    """
    enc = BoolEncoding(d)
    n = len(inputs)
    output = f(inputs)
    
    # Pre-compute the encoded values
    encoded_inputs = [enc.encode(inputs[i]) for i in range(n)]
    encoded_output = enc.encode(output)
    
    def sequence(pos: int) -> int:
        if 0 <= pos < n:
            return encoded_inputs[pos]
        elif pos == n:
            return encoded_output
        return 0
    
    return sequence


def verify_encoding(
    f: Callable[[tuple[bool, ...]], bool],
    n: int,
    d: int = 2
) -> bool:
    """
    Verify that Boolean encoding works for all 2^n inputs.
    
    Returns True if every input-output pair is correctly encoded.
    """
    enc = BoolEncoding(d)
    
    for bits in itertools.product([False, True], repeat=n):
        seq = encode_boolean_function(f, bits, d)
        
        # Check input encoding
        for i in range(n):
            if enc.decode(seq(i)) != bits[i]:
                return False
        
        # Check output encoding
        if enc.decode(seq(n)) != f(bits):
            return False
    
    return True


# ============================================================
# Algorithm 2: Geometric Complexity Computation
# ============================================================

def compute_geometric_complexity(
    f: Callable[[tuple[bool, ...]], bool],
    n: int
) -> int:
    """
    Compute the geometric complexity of a Boolean function.
    
    Algorithm:
    1. Check if f is constant (outputs all True or all False)
    2. If constant → GC = 1
    3. If non-constant → GC = 2 (by Boolean universality theorem)
    
    Time complexity: O(2^n) in the worst case (must check all inputs
    to determine constancy)
    
    The key insight from our formalization: the full 2-symbol shift
    is computationally universal, so GC(f) = 2 for ALL non-constant f.
    """
    seen_true = False
    seen_false = False
    
    for bits in itertools.product([False, True], repeat=n):
        result = f(bits)
        if result:
            seen_true = True
        else:
            seen_false = True
        
        if seen_true and seen_false:
            return 2  # Non-constant → GC = 2
    
    return 1  # Constant → GC = 1


# ============================================================
# Algorithm 3: Entropy-Capacity Analysis
# ============================================================

def entropy_capacity_analysis(d: int, k_max: int) -> list[dict[str, float]]:
    """
    Analyze the entropy-capacity relationship for a shift space.
    
    Returns a list of dictionaries with:
    - k: window length
    - window_capacity: d^k (number of distinct windows)
    - bool_fn_count: 2^(d^k) (number of encodable Boolean functions)
    - word_entropy: k * log₂(d)
    - capacity_ratio: bool_fn_count / window_capacity
    
    This quantifies the exponential gap theorem:
    the Boolean function space grows doubly-exponentially while
    window capacity grows only singly-exponentially.
    """
    results: list[dict[str, float]] = []
    
    for k in range(1, k_max + 1):
        wc = d ** k
        bfc = 2 ** wc if wc <= 20 else float('inf')  # Avoid overflow
        we = k * math.log2(d) if d > 0 else 0.0
        ratio = bfc / wc if wc > 0 and bfc != float('inf') else float('inf')
        
        results.append({
            'k': k,
            'window_capacity': wc,
            'bool_fn_count': bfc,
            'word_entropy': we,
            'capacity_ratio': ratio,
        })
    
    return results


# ============================================================
# Algorithm 4: Horseshoe Hierarchy Exploration
# ============================================================

def explore_horseshoe_hierarchy(max_degree: int) -> dict[int, list[int]]:
    """
    Explore the sub-horseshoe hierarchy up to a given degree.
    
    For each degree d from 2 to max_degree, lists all sub-horseshoe
    degrees d' with 2 ≤ d' ≤ d.
    
    Returns a dictionary mapping degree → list of sub-horseshoe degrees.
    """
    hierarchy: dict[int, list[int]] = {}
    
    for d in range(2, max_degree + 1):
        horseshoe = SmaleHorseshoe(degree=d, shift=ShiftSpace(d))
        hierarchy[d] = horseshoe.sub_horseshoe_degrees()
    
    return hierarchy


# ============================================================
# Algorithm 5: Oracle Construction from Horseshoe
# ============================================================

def horseshoe_oracle(
    coding: Callable[[int], Callable[[int], int]],
    pos: int,
    decode: Callable[[int], bool]
) -> Callable[[int], bool]:
    """
    Construct an oracle from a horseshoe coding map.
    
    Given:
    - coding: maps invariant set points to shift sequences
    - pos: position to extract
    - decode: symbol-to-Boolean decoder
    
    Returns an oracle O: invariant_set → Bool that extracts
    the Boolean value at position `pos` of the coded sequence.
    
    Key property (proved formally): O(O(x)) = O(x) when composed
    with encode, making it idempotent (IsGravOracle).
    """
    return lambda x: decode(coding(x)(pos))


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")
    
    # Test Boolean encoding
    and_fn = lambda bits: all(bits)
    assert verify_encoding(and_fn, 3), "AND encoding failed"
    
    xor_fn = lambda bits: sum(bits) % 2 == 1
    assert verify_encoding(xor_fn, 4), "XOR encoding failed"
    
    # Test geometric complexity
    assert compute_geometric_complexity(lambda _: True, 3) == 1
    assert compute_geometric_complexity(lambda _: False, 3) == 1
    assert compute_geometric_complexity(and_fn, 3) == 2
    assert compute_geometric_complexity(xor_fn, 3) == 2
    
    # Test entropy analysis
    results = entropy_capacity_analysis(2, 5)
    assert results[0]['window_capacity'] == 2
    assert results[0]['word_entropy'] == 1.0
    
    # Test hierarchy
    hierarchy = explore_horseshoe_hierarchy(5)
    assert hierarchy[2] == [2]
    assert hierarchy[5] == [2, 3, 4, 5]
    
    print("All self-tests passed! ✓")
