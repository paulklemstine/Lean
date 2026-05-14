#!/usr/bin/env python3
"""
Closure-Compression Duality: Core Algorithms

Implements the algorithms described in the research paper:
1. Generic closure-based compression
2. Tropical normalization
3. Deficiency computation
4. Closure equivalence class computation
5. MDL-optimal code construction
"""

import numpy as np
from typing import (
    Callable, Dict, Generic, List, Optional, Set, Tuple, TypeVar,
    Hashable
)
from dataclasses import dataclass
from collections import defaultdict
import heapq

T = TypeVar('T', bound=Hashable)


# ============================================================================
# Algorithm 1: Generic Closure-Based Compressor
# ============================================================================

@dataclass
class ClosureCompressor(Generic[T]):
    """
    A compression scheme induced by a closure operator.

    Given a closure operator cl : T → T and an encoding of fixed points,
    compresses any element by mapping it to its canonical representative
    and encoding that representative.

    Time complexity: O(T_cl + T_encode) per compression
    Space complexity: O(|fixed points|) for the codebook
    """
    closure: Callable[[T], T]
    domain: List[T]

    def __post_init__(self):
        # Verify idempotence on domain
        for x in self.domain:
            cx = self.closure(x)
            ccx = self.closure(cx)
            assert cx == ccx, f"Not idempotent: cl(cl({x})) = {ccx} ≠ {cx} = cl({x})"

        # Compute fixed points and build codebook
        self.fixed_points = sorted(set(
            x for x in self.domain if self.closure(x) == x
        ))
        self._code_map: Dict[T, str] = {}
        bits_needed = max(1, (len(self.fixed_points) - 1).bit_length())
        for i, fp in enumerate(self.fixed_points):
            self._code_map[fp] = format(i, f'0{bits_needed}b')

        self._decode_map = {v: k for k, v in self._code_map.items()}

    def compress(self, x: T) -> str:
        """Compress x by encoding its canonical representative."""
        return self._code_map[self.closure(x)]

    def decompress(self, code: str) -> T:
        """Decompress to the canonical representative."""
        return self._decode_map[code]

    def deficiency(self, x: T, length_fn: Callable[[T], int]) -> int:
        """Compute closure deficiency δ(x) = ℓ(x) - ℓ(cl(x))."""
        return max(0, length_fn(x) - length_fn(self.closure(x)))

    def is_incompressible(self, x: T) -> bool:
        """Check if x is a fixed point (incompressible)."""
        return self.closure(x) == x

    def equivalence_classes(self) -> Dict[T, List[T]]:
        """Compute all closure-equivalence classes."""
        classes: Dict[T, List[T]] = defaultdict(list)
        for x in self.domain:
            classes[self.closure(x)].append(x)
        return dict(classes)

    def compression_ratio(self) -> float:
        """Ratio of domain size to number of fixed points."""
        return len(self.domain) / max(1, len(self.fixed_points))

    def summary(self) -> str:
        """Print a summary of the compression scheme."""
        classes = self.equivalence_classes()
        lines = [
            f"Closure Compressor Summary",
            f"  Domain size:      {len(self.domain)}",
            f"  Fixed points:     {len(self.fixed_points)}",
            f"  Compression ratio: {self.compression_ratio():.2f}x",
            f"  Code length:      {len(next(iter(self._code_map.values())))} bits",
            f"  Equivalence classes: {len(classes)}",
        ]
        return '\n'.join(lines)


# ============================================================================
# Algorithm 2: Tropical Normalization
# ============================================================================

def tropical_normalize(x: np.ndarray) -> np.ndarray:
    """
    Tropical normalization: subtract the minimum coordinate.

    Given x ∈ ℝ^n, returns y where y[i] = x[i] - min(x).
    The result is nonneg with at least one zero coordinate.

    Properties (proven in Lean):
    - Idempotent: trop_normalize(trop_normalize(x)) = trop_normalize(x)
    - Fixed points: trop_normalize(x) = x ⟺ (∃i, x[i]=0) ∧ (∀j, x[j]≥0)
    - Canonical: trop_normalize(x) = trop_normalize(y) ⟺ x ~ y (tropical equiv)

    Time: O(n)
    Space: O(1) additional
    """
    return x - np.min(x)


def tropical_offset(x: np.ndarray) -> float:
    """The minimum coordinate value (gauge offset)."""
    return float(np.min(x))


def tropical_deficiency(x: np.ndarray) -> float:
    """
    Tropical deficiency: the total excess over the normalized form.

    δ(x) = sum(x) - sum(trop_normalize(x)) = n * min(x)

    This is zero iff x is already normalized (a fixed point).
    """
    n = len(x)
    return n * tropical_offset(x)


def is_tropically_equivalent(x: np.ndarray, y: np.ndarray,
                              tol: float = 1e-10) -> bool:
    """
    Check if two vectors are tropically equivalent (differ by a constant).

    x ~ y ⟺ trop_normalize(x) = trop_normalize(y)
    ⟺ ∃c, ∀i, y[i] = x[i] + c
    """
    return np.allclose(tropical_normalize(x), tropical_normalize(y), atol=tol)


def tropical_canonical_class(vectors: List[np.ndarray],
                              tol: float = 1e-10
                              ) -> Dict[str, List[int]]:
    """
    Partition vectors into tropical equivalence classes.

    Returns a dict mapping normalized form (as string) to list of indices.
    """
    classes: Dict[str, List[int]] = defaultdict(list)
    for i, v in enumerate(vectors):
        key = str(np.round(tropical_normalize(v), 10))
        classes[key].append(i)
    return dict(classes)


# ============================================================================
# Algorithm 3: MDL-Optimal Code Construction
# ============================================================================

def mdl_optimal_code(
    domain: List[T],
    closure: Callable[[T], T],
    length_fn: Callable[[T], float]
) -> Dict[T, str]:
    """
    Construct an MDL-optimal code using closure-based compression.

    By Theorem B, any closure-respecting code factors through fixed points.
    This constructs a Huffman-like code on fixed points, weighted by
    class size, giving the optimal prefix-free code.

    Time: O(n log n) where n = |domain|
    Space: O(n)
    """
    # Compute equivalence classes
    classes: Dict[T, List[T]] = defaultdict(list)
    for x in domain:
        classes[closure(x)].append(x)

    # Fixed points with their class sizes
    fixed_points = [(fp, len(members)) for fp, members in classes.items()]

    # Build Huffman code on fixed points
    if len(fixed_points) <= 1:
        code = {fixed_points[0][0]: '0'} if fixed_points else {}
    else:
        code = _huffman_code(fixed_points)

    # Extend to full domain via closure
    full_code: Dict[T, str] = {}
    for x in domain:
        full_code[x] = code[closure(x)]

    return full_code


def _huffman_code(symbols_weights: List[Tuple[T, int]]) -> Dict[T, str]:
    """Build a Huffman code from (symbol, weight) pairs."""
    if len(symbols_weights) == 1:
        return {symbols_weights[0][0]: '0'}

    # Build Huffman tree
    heap: List[Tuple[int, int, object]] = []
    counter = 0
    for sym, weight in symbols_weights:
        heapq.heappush(heap, (weight, counter, sym))
        counter += 1

    while len(heap) > 1:
        w1, _, left = heapq.heappop(heap)
        w2, _, right = heapq.heappop(heap)
        heapq.heappush(heap, (w1 + w2, counter, (left, right)))
        counter += 1

    # Extract codes from tree
    codes: Dict[T, str] = {}
    def traverse(node, prefix):
        if isinstance(node, tuple) and len(node) == 2:
            traverse(node[0], prefix + '0')
            traverse(node[1], prefix + '1')
        else:
            codes[node] = prefix if prefix else '0'
    traverse(heap[0][2], '')
    return codes


# ============================================================================
# Algorithm 4: Iterative Closure Discovery
# ============================================================================

def discover_closure_structure(
    domain: List[T],
    closure: Callable[[T], T]
) -> dict:
    """
    Analyze the complete structure of a closure operator.

    Returns a dictionary with:
    - fixed_points: list of fixed points
    - classes: equivalence classes
    - class_sizes: histogram of class sizes
    - compression_ratio: domain size / fixed points
    - is_idempotent: verification of idempotence

    Time: O(n * T_cl)
    """
    fixed_points = []
    classes: Dict[T, List[T]] = defaultdict(list)
    is_idempotent = True

    for x in domain:
        cx = closure(x)
        ccx = closure(cx)
        if cx != ccx:
            is_idempotent = False
        if cx == x:
            fixed_points.append(x)
        classes[cx].append(x)

    class_sizes = sorted([len(v) for v in classes.values()], reverse=True)

    return {
        'fixed_points': fixed_points,
        'classes': dict(classes),
        'class_sizes': class_sizes,
        'compression_ratio': len(domain) / max(1, len(fixed_points)),
        'is_idempotent': is_idempotent,
        'domain_size': len(domain),
        'num_fixed_points': len(fixed_points),
    }


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    # Example: GCD-based closure on integers
    from math import gcd

    def gcd_closure(x: int) -> int:
        """Map each number to its largest prime factor (simplified: to GCD with 60)."""
        return gcd(x, 60)

    domain = list(range(1, 61))
    compressor = ClosureCompressor(closure=gcd_closure, domain=domain)
    print(compressor.summary())
    print()

    # Tropical example
    vectors = [
        np.array([5.0, 3.0, 7.0]),
        np.array([8.0, 6.0, 10.0]),
        np.array([2.0, 0.0, 4.0]),
        np.array([1.0, 2.0, 3.0]),
    ]

    print("Tropical Normalization:")
    for v in vectors:
        nv = tropical_normalize(v)
        delta = tropical_deficiency(v)
        print(f"  {v} → {nv}, deficiency = {delta:.1f}")

    print("\nTropical equivalence classes:")
    classes = tropical_canonical_class(vectors)
    for key, indices in classes.items():
        print(f"  Class {key}: vectors {indices}")
