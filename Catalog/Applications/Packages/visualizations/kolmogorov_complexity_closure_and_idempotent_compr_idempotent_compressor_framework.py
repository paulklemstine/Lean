#!/usr/bin/env python3
"""
Algorithms for Closure-Kolmogorov Compression Duality

Implements the core algorithms from the research paper:
1. Idempotent compressor construction
2. Tropical normalization
3. Fixed-point detection
4. Compression ratio analysis
5. Fiber structure computation
"""

from typing import List, Tuple, Set, Dict, Optional, Callable, FrozenSet
from dataclasses import dataclass
import collections
import itertools


# ============================================================================
# Algorithm 1: Generic Idempotent Compressor Framework
# ============================================================================

@dataclass
class CompressionResult:
    """Result of applying an idempotent compressor."""
    original: List[bool]
    compressed: List[bool]
    is_fixed: bool
    compression_ratio: float
    
    def __repr__(self):
        orig = ''.join('1' if b else '0' for b in self.original)
        comp = ''.join('1' if b else '0' for b in self.compressed)
        return (f"CompressionResult('{orig}' -> '{comp}', "
                f"fixed={self.is_fixed}, ratio={self.compression_ratio:.3f})")


class IdempotentCompressor:
    """
    Abstract idempotent compressor satisfying the formal axioms:
    - Idempotence: compress(compress(s)) = compress(s)
    - Length-nonincreasing: len(compress(s)) <= len(s) 
    - Strict shortening: if compress(s) != s then len(compress(s)) < len(s)
    
    Time complexity: O(n) per compression where n = len(s)
    Space complexity: O(n)
    """
    
    def __init__(self, compress_fn: Callable[[List[bool]], List[bool]],
                 name: str = "generic"):
        self._compress = compress_fn
        self.name = name
    
    def compress(self, s: List[bool]) -> List[bool]:
        """Apply the compressor. O(n) time."""
        return self._compress(s)
    
    def compress_result(self, s: List[bool]) -> CompressionResult:
        """Compress and return detailed result."""
        cs = self.compress(s)
        ratio = len(cs) / len(s) if len(s) > 0 else 1.0
        return CompressionResult(
            original=s,
            compressed=cs,
            is_fixed=(cs == s),
            compression_ratio=ratio
        )
    
    def verify_axioms(self, max_length: int = 6) -> bool:
        """
        Verify the three axioms on all strings up to max_length.
        
        Time complexity: O(2^n * n) where n = max_length
        """
        for n in range(max_length + 1):
            for bits in itertools.product([False, True], repeat=n):
                s = list(bits)
                cs = self.compress(s)
                ccs = self.compress(cs)
                
                # Axiom 1: Idempotence
                if ccs != cs:
                    print(f"IDEMPOTENCE VIOLATED: {s}")
                    return False
                
                # Axiom 2: Length-nonincreasing
                if len(cs) > len(s):
                    print(f"LENGTH INCREASE: {s}")
                    return False
                
                # Axiom 3: Strict shortening on non-fixed-points
                if cs != s and len(cs) >= len(s):
                    print(f"NOT STRICTLY SHORTENED: {s}")
                    return False
        
        return True
    
    def fixed_points(self, length: int) -> List[List[bool]]:
        """
        Enumerate all fixed points of given length.
        
        Time complexity: O(2^n * n)
        """
        result = []
        for bits in itertools.product([False, True], repeat=length):
            s = list(bits)
            if self.compress(s) == s:
                result.append(s)
        return result
    
    def fiber(self, fixed_pt: List[bool], max_length: int) -> List[List[bool]]:
        """
        Compute the fiber (preimage) of a fixed point.
        
        Time complexity: O(sum_{k=0}^{max_length} 2^k * k)
        """
        result = []
        for n in range(max_length + 1):
            for bits in itertools.product([False, True], repeat=n):
                s = list(bits)
                if self.compress(s) == fixed_pt:
                    result.append(s)
        return result


# ============================================================================
# Algorithm 2: Concrete Compressors
# ============================================================================

def dedup_compress(s: List[bool]) -> List[bool]:
    """
    Remove consecutive duplicate bits.
    
    Properties:
    - Idempotent: alternating strings are unchanged by dedup
    - Strictly shortening: any string with consecutive duplicates gets shorter
    - Fixed points: strings without consecutive duplicates
    
    Time: O(n), Space: O(n)
    """
    if not s:
        return s
    result = [s[0]]
    for bit in s[1:]:
        if bit != result[-1]:
            result.append(bit)
    return result


def canonical_sort_compress(s: List[bool]) -> List[bool]:
    """
    Sort the bits (all 0s before all 1s).
    Note: This is length-PRESERVING, not length-reducing.
    Fixed points: already-sorted strings.
    
    Time: O(n), Space: O(n)
    """
    return sorted(s)


def prefix_dedup_compress(s: List[bool]) -> List[bool]:
    """
    Remove duplicate consecutive bits, keeping track of the pattern.
    This is a more aggressive compressor.
    
    Time: O(n), Space: O(n)  
    """
    if len(s) <= 1:
        return s
    result = [s[0]]
    for bit in s[1:]:
        if bit != result[-1]:
            result.append(bit)
    return result


# ============================================================================
# Algorithm 3: Tropical Normalization
# ============================================================================

@dataclass
class TropicalNormResult:
    """Result of tropical normalization."""
    original: List[float]
    baseline: List[float]
    normalized: List[float]
    total_original: float
    total_normalized: float
    savings_pct: float
    is_fixed: bool


def tropical_normalize(baseline: List[float], 
                       weights: List[float]) -> List[float]:
    """
    Tropical (min-plus) normalization: pointwise minimum with baseline.
    
    Properties (proven formally):
    - Idempotent: normalize(normalize(w)) = normalize(w)
    - Pointwise ≤ original: norm(w)[i] ≤ w[i]
    - Pointwise ≤ baseline: norm(w)[i] ≤ b[i]
    - Minimal among equivalents bounded by baseline
    
    Time: O(n), Space: O(n)
    
    Args:
        baseline: The ceiling vector b
        weights: The weight vector w to normalize
    
    Returns:
        Normalized vector min(w, b) pointwise
    """
    assert len(baseline) == len(weights), "Dimension mismatch"
    return [min(w, b) for w, b in zip(weights, baseline)]


def tropical_normalize_result(baseline: List[float],
                              weights: List[float]) -> TropicalNormResult:
    """Compute tropical normalization with detailed statistics."""
    normalized = tropical_normalize(baseline, weights)
    total_orig = sum(weights)
    total_norm = sum(normalized)
    savings = (1 - total_norm / total_orig) * 100 if total_orig > 0 else 0
    is_fixed = all(w <= b for w, b in zip(weights, baseline))
    
    return TropicalNormResult(
        original=weights,
        baseline=baseline,
        normalized=normalized,
        total_original=total_orig,
        total_normalized=total_norm,
        savings_pct=savings,
        is_fixed=is_fixed
    )


def verify_tropical_idempotence(baseline: List[float],
                                 weights: List[float]) -> bool:
    """Verify that tropical normalization is idempotent for given inputs."""
    n1 = tropical_normalize(baseline, weights)
    n2 = tropical_normalize(baseline, n1)
    return all(abs(a - b) < 1e-12 for a, b in zip(n1, n2))


def tropical_equivalence_class(baseline: List[float],
                                representative: List[float],
                                samples: List[List[float]]) -> List[List[float]]:
    """
    Find all weight vectors in samples that are tropically equivalent
    to the representative (same normalization).
    
    Time: O(|samples| * n)
    """
    target = tropical_normalize(baseline, representative)
    return [w for w in samples
            if tropical_normalize(baseline, w) == target]


# ============================================================================
# Algorithm 4: Closure Operator on Finite Lattice
# ============================================================================

class ClosureOperator:
    """
    A closure operator on a finite powerset lattice.
    
    Models the formal ClosureOperator from Mathlib:
    - Extensive: x ≤ c(x) (subset inclusion)
    - Monotone: x ≤ y implies c(x) ≤ c(y)
    - Idempotent: c(c(x)) = c(x)
    
    Time complexity: O(n * |implications|) per closure computation
    """
    
    def __init__(self, universe: Set[str],
                 implications: Dict[str, Set[str]]):
        self.universe = universe
        self.implications = implications
    
    def close(self, features: FrozenSet[str]) -> FrozenSet[str]:
        """
        Compute the closure of a feature set.
        
        Time: O(n * |implications|) where n = |universe|
        """
        result = set(features)
        changed = True
        while changed:
            changed = False
            for f in list(result):
                if f in self.implications:
                    for implied in self.implications[f]:
                        if implied not in result:
                            result.add(implied)
                            changed = True
        return frozenset(result)
    
    def is_closed(self, features: FrozenSet[str]) -> bool:
        """Check if a set is closed (fixed point)."""
        return self.close(features) == features
    
    def all_closed_sets(self) -> List[FrozenSet[str]]:
        """
        Enumerate all closed sets (fixed points).
        
        Time: O(2^n * n * |implications|)
        """
        result = []
        for r in range(len(self.universe) + 1):
            for combo in itertools.combinations(self.universe, r):
                s = frozenset(combo)
                if self.is_closed(s):
                    result.append(s)
        return result
    
    def mdl_bound(self, features: FrozenSet[str],
                  length_fn: Callable[[FrozenSet[str]], int]) -> Tuple[FrozenSet[str], int]:
        """
        Compute the MDL bound via the closure fixed-point witness.
        
        Returns (witness, bound) where witness is a fixed point above
        features with length_fn(witness) as the bound.
        
        This implements the closure_mdl_bound_strengthened theorem:
        the closure c(x) is always a fixed point above x.
        """
        closed = self.close(features)
        return closed, length_fn(closed)
    
    def verify_axioms(self) -> bool:
        """Verify closure operator axioms on all subsets."""
        for r in range(len(self.universe) + 1):
            for combo in itertools.combinations(self.universe, r):
                s = frozenset(combo)
                cs = self.close(s)
                
                # Extensive: s ⊆ c(s)
                if not s.issubset(cs):
                    return False
                
                # Idempotent: c(c(s)) = c(s)
                if self.close(cs) != cs:
                    return False
        
        # Monotone: s ⊆ t implies c(s) ⊆ c(t)
        all_subsets = []
        for r in range(len(self.universe) + 1):
            for combo in itertools.combinations(self.universe, r):
                all_subsets.append(frozenset(combo))
        
        for s in all_subsets:
            for t in all_subsets:
                if s.issubset(t):
                    if not self.close(s).issubset(self.close(t)):
                        return False
        
        return True


# ============================================================================
# Algorithm 5: Compression Analysis
# ============================================================================

def compression_spectrum(compressor: IdempotentCompressor,
                         max_length: int) -> Dict[int, Dict[str, int]]:
    """
    Compute the compression spectrum: for each length n, count
    fixed points, compressed strings, and total strings.
    
    Time: O(sum_{n=0}^{max_length} 2^n * n)
    
    Returns: {length: {total, fixed, compressed, avg_compression}}
    """
    spectrum = {}
    for n in range(max_length + 1):
        total = 0
        fixed = 0
        total_compressed_len = 0
        
        for bits in itertools.product([False, True], repeat=n):
            s = list(bits)
            cs = compressor.compress(s)
            total += 1
            total_compressed_len += len(cs)
            if cs == s:
                fixed += 1
        
        spectrum[n] = {
            'total': total,
            'fixed': fixed,
            'compressed': total - fixed,
            'avg_compressed_length': total_compressed_len / total if total > 0 else 0,
            'fixed_ratio': fixed / total if total > 0 else 1.0
        }
    
    return spectrum


def fiber_analysis(compressor: IdempotentCompressor,
                   max_length: int) -> Dict[str, List[str]]:
    """
    Compute the complete fiber structure of a compressor.
    
    Returns: mapping from fixed point (as string) to list of 
    strings in its fiber (as strings).
    
    Time: O(sum_{n=0}^{max_length} 2^n * n)
    """
    fibers: Dict[str, List[str]] = collections.defaultdict(list)
    
    for n in range(max_length + 1):
        for bits in itertools.product([False, True], repeat=n):
            s = list(bits)
            cs = compressor.compress(s)
            key = ''.join('1' if b else '0' for b in cs)
            val = ''.join('1' if b else '0' for b in s)
            fibers[key].append(val)
    
    return dict(fibers)


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Create compressor
    comp = IdempotentCompressor(dedup_compress, "dedup")
    
    # Verify axioms
    print("Verifying compressor axioms...")
    assert comp.verify_axioms(6), "Axiom verification failed!"
    print("All axioms verified ✓\n")
    
    # Compression spectrum
    print("Compression spectrum:")
    spectrum = compression_spectrum(comp, 8)
    print(f"{'n':>3} | {'Total':>6} | {'Fixed':>6} | {'Ratio':>8} | {'Avg Len':>8}")
    print("-" * 45)
    for n, stats in spectrum.items():
        print(f"{n:>3} | {stats['total']:>6} | {stats['fixed']:>6} | "
              f"{stats['fixed_ratio']:>7.3f} | {stats['avg_compressed_length']:>7.2f}")
    
    # Tropical normalization
    print("\nTropical normalization example:")
    baseline = [10.0, 8.0, 6.0, 4.0, 2.0]
    weights = [12.0, 5.0, 3.0, 7.0, 1.0]
    result = tropical_normalize_result(baseline, weights)
    print(f"  Baseline:   {result.baseline}")
    print(f"  Original:   {result.original} (total: {result.total_original:.1f})")
    print(f"  Normalized: {result.normalized} (total: {result.total_normalized:.1f})")
    print(f"  Savings:    {result.savings_pct:.1f}%")
    print(f"  Is fixed:   {result.is_fixed}")
    
    # Closure operator
    print("\nClosure operator example:")
    universe = {'a', 'b', 'c', 'd'}
    implications = {'a': {'b', 'c'}, 'b': {'d'}, 'c': set(), 'd': set()}
    cl = ClosureOperator(universe, implications)
    assert cl.verify_axioms(), "Closure axioms failed!"
    print("  Axioms verified ✓")
    
    closed_sets = cl.all_closed_sets()
    print(f"  Closed sets: {len(closed_sets)}")
    for cs in closed_sets:
        print(f"    {set(cs) if cs else '{}'}")
