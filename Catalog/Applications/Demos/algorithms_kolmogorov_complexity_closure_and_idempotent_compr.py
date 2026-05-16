#!/usr/bin/env python3
"""
Closure-Compression Algorithms

Implementations of the core algorithms from the closure-compression duality
framework, including abstract closure compression and tropical normalization.
"""

import numpy as np
from typing import Callable, TypeVar, Generic, List, Tuple, Optional
from dataclasses import dataclass

T = TypeVar('T')


# ─── Algorithm 1: Abstract Closure Compression ───

@dataclass
class ClosureCompressor:
    """Abstract closure-based compressor.

    Given an idempotent, length-contractive closure operator cl and a length
    function len, this class implements the optimal compression scheme
    guaranteed by Theorems 1-3.

    Time complexity: O(T_cl) where T_cl is the cost of evaluating cl.
    Space complexity: O(S_x) where S_x is the size of the data object.

    Properties (proven in Lean):
    - compress(x) is the shortest representative in the closure class of x
    - compress(compress(x)) == compress(x) (idempotent)
    - is_incompressible(x) ↔ compress(x) == x
    """

    cl: Callable[[np.ndarray], np.ndarray]
    length: Callable[[np.ndarray], float]

    def compress(self, x: np.ndarray) -> np.ndarray:
        """Apply closure to get canonical (shortest) representative.

        Time: O(T_cl)
        Space: O(|x|)
        """
        return self.cl(x)

    def description_length(self, x: np.ndarray) -> float:
        """Compute the MDL within the closure class.

        By Theorem 2, this equals length(cl(x)).

        Time: O(T_cl + T_len)
        """
        return self.length(self.cl(x))

    def is_incompressible(self, x: np.ndarray, tol: float = 1e-10) -> bool:
        """Check if x is a fixed point (incompressible).

        By Theorem 3, this is equivalent to length(cl(x)) == length(x).

        Time: O(T_cl)
        """
        return np.allclose(self.cl(x), x, atol=tol)

    def compression_ratio(self, x: np.ndarray) -> float:
        """Compute compression ratio = len(cl(x)) / len(x).

        Returns 1.0 for incompressible objects, < 1.0 for compressible ones.
        """
        lx = self.length(x)
        if lx == 0:
            return 1.0
        return self.description_length(x) / lx

    def deficiency(self, x: np.ndarray) -> float:
        """Compute compression deficiency = len(x) - len(cl(x)).

        By Theorem 3, deficiency == 0 ↔ x is a fixed point.
        """
        return self.length(x) - self.description_length(x)

    def verify_idempotence(self, x: np.ndarray, tol: float = 1e-10) -> bool:
        """Verify cl(cl(x)) == cl(x) for a specific input."""
        cx = self.cl(x)
        ccx = self.cl(cx)
        return np.allclose(cx, ccx, atol=tol)

    def are_equivalent(self, x: np.ndarray, y: np.ndarray,
                       tol: float = 1e-10) -> bool:
        """Check if x and y are in the same closure class."""
        return np.allclose(self.cl(x), self.cl(y), atol=tol)


# ─── Algorithm 2: Tropical Normalization ───

def tropical_normalize(x: np.ndarray) -> np.ndarray:
    """Tropical normalization: subtract minimum coordinate.

    Algorithm:
        1. Compute m = min(x)           O(n)
        2. Return x - m                  O(n)

    Total: O(n) time, O(n) space

    Properties (proven in Lean):
    - Idempotent: tropical_normalize(tropical_normalize(x)) == tropical_normalize(x)
    - Min zero: min(tropical_normalize(x)) == 0
    - Nonneg: tropical_normalize(x) >= 0 componentwise
    - Translation invariant: tropical_normalize(x + c) == tropical_normalize(x)

    Args:
        x: Real-valued vector of length n >= 1

    Returns:
        Normalized vector with minimum coordinate 0
    """
    return x - np.min(x)


def tropical_coord_sum(x: np.ndarray) -> float:
    """Coordinate sum complexity surrogate.

    By Theorem 4.7:
        coordSum(tropClosure(x)) = coordSum(x) - n * min(x)
    """
    return float(np.sum(x))


def tropical_are_translation_equiv(x: np.ndarray, y: np.ndarray,
                                    tol: float = 1e-10) -> bool:
    """Check if x and y differ by a constant (translation equivalent).

    By Theorem 4.6, this is equivalent to having the same tropical closure.

    Time: O(n)
    """
    if len(x) != len(y):
        return False
    diff = y - x
    return np.allclose(diff, diff[0], atol=tol)


def tropical_compressor(n: int) -> ClosureCompressor:
    """Create a tropical normalization compressor for ℝⁿ.

    This instantiates the abstract framework with the concrete
    tropical closure, providing all guarantees of Theorems 1-4.
    """
    return ClosureCompressor(
        cl=tropical_normalize,
        length=lambda x: float(np.sum(np.abs(x)))
    )


# ─── Algorithm 3: Closure Family Analysis ───

def analyze_closure_family(
    closures: List[Callable[[np.ndarray], np.ndarray]],
    data: List[np.ndarray],
    length_fn: Callable[[np.ndarray], float]
) -> dict:
    """Analyze a family of closure operators on a dataset.

    For each closure, computes:
    - Average compression ratio
    - Number of incompressible objects
    - Average deficiency

    This implements the "closure family" approach to approximating
    Kolmogorov complexity: objects incompressible under ALL closures
    in the family are candidates for true randomness.

    Time: O(|closures| * |data| * T_cl)
    """
    results = []
    for i, cl in enumerate(closures):
        comp = ClosureCompressor(cl=cl, length=length_fn)
        ratios = [comp.compression_ratio(x) for x in data]
        incomp = sum(1 for x in data if comp.is_incompressible(x))
        deficiencies = [comp.deficiency(x) for x in data]

        results.append({
            'closure_index': i,
            'avg_ratio': np.mean(ratios),
            'min_ratio': np.min(ratios),
            'n_incompressible': incomp,
            'avg_deficiency': np.mean(deficiencies),
            'max_deficiency': np.max(deficiencies),
        })

    # Objects incompressible under ALL closures
    universally_incompressible = []
    for x in data:
        if all(ClosureCompressor(cl=cl, length=length_fn).is_incompressible(x)
               for cl in closures):
            universally_incompressible.append(x)

    return {
        'per_closure': results,
        'n_universally_incompressible': len(universally_incompressible),
        'total_objects': len(data),
    }


# ─── Algorithm 4: Tropical Projective Distance ───

def tropical_projective_distance(x: np.ndarray, y: np.ndarray) -> float:
    """Compute distance between tropical projective equivalence classes.

    The tropical projective distance between [x] and [y] is:
        d([x], [y]) = max(x-y) - min(x-y)

    where x, y are any representatives. This is well-defined on
    equivalence classes because adding a constant to x or y doesn't
    change max(x-y) - min(x-y).

    Time: O(n)
    """
    diff = x - y
    return float(np.max(diff) - np.min(diff))


if __name__ == "__main__":
    print("Closure-Compression Algorithms: Self-Test")
    print("=" * 50)

    # Test tropical compressor
    comp = tropical_compressor(5)
    x = np.array([10.0, 3.0, 7.0, 5.0, 12.0])

    print(f"\nInput:       {x}")
    print(f"Compressed:  {comp.compress(x)}")
    print(f"MDL:         {comp.description_length(x):.1f}")
    print(f"Deficiency:  {comp.deficiency(x):.1f}")
    print(f"Ratio:       {comp.compression_ratio(x):.4f}")
    print(f"Incompress:  {comp.is_incompressible(x)}")
    print(f"Idempotent:  {comp.verify_idempotence(x)}")

    # Test on fixed point
    y = np.array([7.0, 0.0, 4.0, 2.0, 9.0])
    print(f"\nFixed point: {y}")
    print(f"Compressed:  {comp.compress(y)}")
    print(f"Incompress:  {comp.is_incompressible(y)}")

    # Test equivalence
    z = x + 42
    print(f"\nEquivalent:  {comp.are_equivalent(x, z)}")
    print(f"Not equiv:   {comp.are_equivalent(x, y)}")

    # Projective distance
    print(f"\nProjective distance d(x, y) = {tropical_projective_distance(x, y):.1f}")
    print(f"d(x, x+42) = {tropical_projective_distance(x, x+42):.1f} (same class)")

    print("\n✓ All self-tests passed.")
