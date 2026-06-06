#!/usr/bin/env python3
"""
Algorithms for Associativity Defect Algebras

Type-hinted implementations of the core algorithms from the paper.
"""

from typing import Callable, Dict, List, Tuple, Set
from dataclasses import dataclass
import numpy as np


@dataclass
class AdditiveDefectAlgebra:
    """An additive defect algebra over ℤ/nℤ.
    
    Stores the cocycle as a 3D array indexed by (a, b, c).
    """
    n: int
    cocycle: np.ndarray  # shape (n, n, n)
    
    def verify_cocycle_condition(self) -> bool:
        """Verify δ(b,c,d) + δ(a,b+c,d) + δ(a,b,c) = δ(a+b,c,d) + δ(a,b,c+d) mod n."""
        n = self.n
        for a in range(n):
            for b in range(n):
                for c in range(n):
                    for d in range(n):
                        lhs = (self.cocycle[b, c, d] + 
                               self.cocycle[a, (b+c) % n, d] + 
                               self.cocycle[a, b, c]) % n
                        rhs = (self.cocycle[(a+b) % n, c, d] + 
                               self.cocycle[a, b, (c+d) % n]) % n
                        if lhs != rhs:
                            return False
        return True
    
    def defect_index(self) -> int:
        """Count non-zero entries in the cocycle."""
        return int(np.count_nonzero(self.cocycle))
    
    def __add__(self, other: 'AdditiveDefectAlgebra') -> 'AdditiveDefectAlgebra':
        """Pointwise addition of cocycles (defect product)."""
        assert self.n == other.n
        return AdditiveDefectAlgebra(
            n=self.n,
            cocycle=(self.cocycle + other.cocycle) % self.n
        )
    
    def __neg__(self) -> 'AdditiveDefectAlgebra':
        """Negation of cocycle (defect inverse)."""
        return AdditiveDefectAlgebra(
            n=self.n,
            cocycle=(-self.cocycle) % self.n
        )


def coboundary_operator(f: np.ndarray, n: int) -> np.ndarray:
    """Compute the coboundary of a 2-cochain f : ℤ/nℤ × ℤ/nℤ → ℤ/nℤ.
    
    Args:
        f: 2D array of shape (n, n) representing the 2-cochain
        n: modulus
    
    Returns:
        3D array of shape (n, n, n) representing the 3-cocycle ∂²f
    
    Formula: (∂²f)(a,b,c) = f(b,c) - f((a+b)%n, c) + f(a, (b+c)%n) - f(a, b)
    """
    delta = np.zeros((n, n, n), dtype=int)
    for a in range(n):
        for b in range(n):
            for c in range(n):
                delta[a, b, c] = (
                    f[b, c] - f[(a + b) % n, c] + f[a, (b + c) % n] - f[a, b]
                ) % n
    return delta


def construct_trivial_cocycle(n: int) -> AdditiveDefectAlgebra:
    """Construct the trivial (zero) cocycle over ℤ/nℤ."""
    return AdditiveDefectAlgebra(n=n, cocycle=np.zeros((n, n, n), dtype=int))


def construct_coboundary(f: np.ndarray, n: int) -> AdditiveDefectAlgebra:
    """Construct a coboundary cocycle from a 2-cochain."""
    return AdditiveDefectAlgebra(n=n, cocycle=coboundary_operator(f, n))


def enumerate_coboundaries(n: int) -> Set[Tuple[int, ...]]:
    """Enumerate all distinct coboundaries over ℤ/nℤ.
    
    Returns the set of distinct cocycle values (as tuples).
    Warning: O(n^(n²)) complexity — only feasible for small n.
    """
    coboundaries: Set[Tuple[int, ...]] = set()
    
    for f_vals in np.ndindex(*([n] * (n * n))):
        f = np.array(f_vals, dtype=int).reshape(n, n)
        delta = coboundary_operator(f, n)
        coboundaries.add(tuple(delta.flatten()))
    
    return coboundaries


def classify_h3(n: int) -> Dict[str, int]:
    """Classify H³(ℤ/nℤ, ℤ/nℤ) for small n.
    
    Returns:
        Dictionary with counts of cocycles, coboundaries, and |H³|.
    """
    # For very small n, we can enumerate all cocycles
    coboundaries = enumerate_coboundaries(n)
    
    # Count all cocycles by brute force (only feasible for n ≤ 2)
    cocycles: Set[Tuple[int, ...]] = set()
    if n <= 2:
        for delta_vals in np.ndindex(*([n] * (n * n * n))):
            delta = np.array(delta_vals, dtype=int).reshape(n, n, n)
            ada = AdditiveDefectAlgebra(n=n, cocycle=delta)
            if ada.verify_cocycle_condition():
                cocycles.add(tuple(delta.flatten()))
    
    return {
        "n": n,
        "num_coboundaries": len(coboundaries),
        "num_cocycles": len(cocycles) if n <= 2 else -1,
        "H3_order": len(cocycles) // len(coboundaries) if (n <= 2 and len(coboundaries) > 0) else -1,
    }


def defect_magma_from_perturbation(
    n: int, 
    base_op: Callable[[int, int], int],
    perturbation: np.ndarray
) -> Tuple[Callable[[int, int], int], np.ndarray]:
    """Construct a DefectMagma by perturbing an associative operation.
    
    Args:
        n: modulus
        base_op: the associative base operation
        perturbation: n×n array modifying the operation
    
    Returns:
        (new_op, defect_array) where defect measures associativity failure
    """
    def new_op(a: int, b: int) -> int:
        return (base_op(a, b) + perturbation[a % n, b % n]) % n
    
    # Compute the defect
    defect = np.zeros((n, n, n), dtype=int)
    for a in range(n):
        for b in range(n):
            for c in range(n):
                left = new_op(new_op(a, b), c)
                right = new_op(a, new_op(b, c))
                defect[a, b, c] = (left - right) % n
    
    return new_op, defect


def pentagon_violation(delta: np.ndarray, comp: Callable[[int, int], int], n: int) -> float:
    """Measure how much the pentagon identity is violated.
    
    Returns the fraction of 4-tuples (a,b,c,d) that violate pentagon.
    """
    violations = 0
    total = n ** 4
    
    for a in range(n):
        for b in range(n):
            for c in range(n):
                for d in range(n):
                    cd = comp(c, d)
                    ab = comp(a, b)
                    bc = comp(b, c)
                    
                    lhs = comp(delta[a, b, cd], delta[ab, c, d])
                    rhs_inner = comp(delta[b, c, d], delta[a, bc, d])
                    rhs = comp(rhs_inner, delta[a, b, c])
                    
                    if lhs % n != rhs % n:
                        violations += 1
    
    return violations / total


if __name__ == "__main__":
    # Quick test
    print("Testing coboundary construction over ℤ/5ℤ:")
    n = 5
    f = np.array([[i * j**2 % n for j in range(n)] for i in range(n)])
    ada = construct_coboundary(f, n)
    print(f"  Cocycle condition satisfied: {ada.verify_cocycle_condition()}")
    print(f"  Defect index: {ada.defect_index()}/{n**3}")
    
    print("\nClassifying H³(ℤ/2ℤ, ℤ/2ℤ):")
    result = classify_h3(2)
    print(f"  {result}")
