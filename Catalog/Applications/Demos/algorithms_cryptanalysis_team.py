#!/usr/bin/env python3
"""
Geometric Cryptanalysis: Algorithms

Implements the core algorithms from the research paper:
1. Bounded-box collision finder (hash-based, O(|box|) expected time)
2. Short kernel vector extractor
3. Matrix SIS witness finder
4. Collision multiplicity counter
5. Threshold estimator
"""

import itertools
import math
from collections import defaultdict
from dataclasses import dataclass
from typing import Optional


@dataclass
class KernelVector:
    """A short vector in the kernel lattice."""
    z: tuple[int, ...]
    sup_norm: int
    inner_product: int  # ⟨a, z⟩
    modulus: int  # q


@dataclass
class CollisionResult:
    """Result of a bounded-box collision search."""
    x: tuple[int, ...]
    y: tuple[int, ...]
    z: tuple[int, ...]  # x - y
    residue: int  # common residue f(x) = f(y)


def box_cardinality(n: int, B: int) -> int:
    """
    Compute |Box(n, B)| = (2B+1)^n.
    
    This is the number of integer vectors in [-B, B]^n.
    
    Complexity: O(log n) via fast exponentiation.
    
    >>> box_cardinality(3, 2)
    125
    >>> box_cardinality(4, 1)
    81
    """
    return (2 * B + 1) ** n


def collision_threshold(n: int, q: int) -> int:
    """
    Compute the minimum B such that (2B+1)^n > q.
    
    This is the critical threshold: for B >= threshold, a collision
    is guaranteed by the bounded-box collision theorem.
    
    Returns the smallest B such that (2B+1)^n > q.
    
    Complexity: O(log q) via binary search or direct computation.
    
    >>> collision_threshold(2, 100)  # Need (2B+1)^2 > 100, so 2B+1 >= 11, B >= 5
    5
    """
    # (2B+1)^n > q iff 2B+1 > q^(1/n) iff B > (q^(1/n) - 1) / 2
    root = q ** (1.0 / n)
    B = int(math.ceil((root - 1) / 2))
    # Verify and adjust for floating point errors
    while (2 * B + 1) ** n <= q:
        B += 1
    return B


def find_collision(
    a: list[int], q: int, B: int
) -> Optional[CollisionResult]:
    """
    Find a collision in the modular linear form over the bounded box.
    
    Given a linear form f(x) = sum(a_i * x_i) mod q and a bound B,
    searches the box [-B, B]^n for distinct x, y with f(x) = f(y).
    
    Algorithm: Hash-based collision detection.
    - Enumerate vectors in the box.
    - For each vector, compute f(x) mod q.
    - Store in a hash table keyed by residue.
    - Return the first collision found.
    
    Time complexity: O(min(|box|, q)) expected (birthday bound)
    Space complexity: O(min(|box|, q))
    
    Returns None if no collision exists (only possible if |box| <= q).
    
    >>> result = find_collision([3, 7], 5, 2)
    >>> result is not None
    True
    >>> sum(a * z for a, z in zip([3, 7], result.z)) % 5
    0
    """
    n = len(a)
    residue_map: dict[int, tuple[int, ...]] = {}
    
    for x in itertools.product(range(-B, B + 1), repeat=n):
        r = sum(ai * xi for ai, xi in zip(a, x)) % q
        if r in residue_map:
            y = residue_map[r]
            z = tuple(xi - yi for xi, yi in zip(x, y))
            return CollisionResult(x=x, y=y, z=z, residue=r)
        residue_map[r] = x
    
    return None


def extract_short_kernel_vector(
    a: list[int], q: int, B: int
) -> Optional[KernelVector]:
    """
    Extract a short nonzero vector in the kernel lattice.
    
    The kernel lattice is {z ∈ ℤ^n : ⟨a, z⟩ ≡ 0 (mod q)}.
    
    If (2B+1)^n > q, returns a vector z with:
    - z ≠ 0
    - |z_i| ≤ 2B for all i
    - ⟨a, z⟩ ≡ 0 (mod q)
    
    This is Algorithm 1 from the research paper.
    
    >>> kv = extract_short_kernel_vector([3, 7], 5, 2)
    >>> kv is not None
    True
    >>> kv.inner_product % 5
    0
    >>> kv.sup_norm <= 4
    True
    """
    result = find_collision(a, q, B)
    if result is None:
        return None
    
    z = result.z
    inner = sum(ai * zi for ai, zi in zip(a, z))
    
    return KernelVector(
        z=z,
        sup_norm=max(abs(zi) for zi in z),
        inner_product=inner,
        modulus=q
    )


def find_sis_witness(
    A: list[list[int]], q: int, B: int
) -> Optional[tuple[tuple[int, ...], list[int]]]:
    """
    Find a short SIS witness for matrix A modulo q.
    
    Given A ∈ ℤ^{m×n} and bound B, finds z ∈ ℤ^n with:
    - z ≠ 0
    - |z_i| ≤ 2B for all i
    - Az ≡ 0 (mod q)
    
    Requires: q^m < (2B+1)^n.
    
    Algorithm: Syndrome hashing.
    - Enumerate vectors in [-B, B]^n.
    - For each vector, compute the syndrome A*x mod q.
    - Hash by syndrome; return first collision.
    
    Time: O(min(|box|, q^m))
    Space: O(min(|box|, q^m))
    
    Returns (z, syndromes) where syndromes[j] = (A*z)[j] mod q (should all be 0).
    
    >>> z, syn = find_sis_witness([[3, 1, 4, 1], [5, 9, 2, 6]], 7, 2)
    >>> all(s == 0 for s in syn)
    True
    """
    m = len(A)
    n = len(A[0])
    
    syndrome_map: dict[tuple[int, ...], tuple[int, ...]] = {}
    
    for x in itertools.product(range(-B, B + 1), repeat=n):
        syndrome = tuple(
            sum(A[j][i] * x[i] for i in range(n)) % q
            for j in range(m)
        )
        
        if syndrome in syndrome_map:
            y = syndrome_map[syndrome]
            z = tuple(xi - yi for xi, yi in zip(x, y))
            syndromes = [sum(A[j][i] * z[i] for i in range(n)) % q for j in range(m)]
            return z, syndromes
        syndrome_map[syndrome] = x
    
    return None


def count_kernel_vectors(
    a: list[int], q: int, B: int, max_norm: Optional[int] = None
) -> list[KernelVector]:
    """
    Find ALL nonzero kernel vectors with coordinates in [-max_norm, max_norm].
    
    If max_norm is None, uses 2*B (the guaranteed bound from the theorem).
    
    This implements the exhaustive search version for small parameters,
    useful for verifying collision multiplicity predictions.
    
    >>> vectors = count_kernel_vectors([1, 1], 3, 2)
    >>> len(vectors) > 0
    True
    """
    if max_norm is None:
        max_norm = 2 * B
    
    n = len(a)
    results = []
    
    for z in itertools.product(range(-max_norm, max_norm + 1), repeat=n):
        if all(zi == 0 for zi in z):
            continue
        inner = sum(ai * zi for ai, zi in zip(a, z))
        if inner % q == 0:
            results.append(KernelVector(
                z=z,
                sup_norm=max(abs(zi) for zi in z),
                inner_product=inner,
                modulus=q
            ))
    
    return results


def collision_multiplicity_table(
    n: int, a: list[int], q: int, B_range: range
) -> dict[int, dict]:
    """
    Compute collision statistics for varying B.
    
    Returns a dictionary mapping B to statistics:
    - box_size: (2B+1)^n
    - ratio: box_size / q
    - num_collisions: number of collision pairs
    - num_kernel_vectors: distinct nonzero kernel vectors found
    - min_norm: minimum sup-norm of kernel vectors
    
    >>> table = collision_multiplicity_table(2, [1, 1], 5, range(1, 4))
    >>> all(B in table for B in range(1, 4))
    True
    """
    results = {}
    
    for B in B_range:
        box = list(itertools.product(range(-B, B + 1), repeat=n))
        box_size = len(box)
        
        # Group by residue
        residue_map = defaultdict(list)
        for x in box:
            r = sum(ai * xi for ai, xi in zip(a, x)) % q
            residue_map[r].append(x)
        
        # Count collisions and extract kernel vectors
        num_collisions = 0
        kernel_vectors = set()
        min_norm = float('inf')
        
        for vectors in residue_map.values():
            k = len(vectors)
            num_collisions += k * (k - 1) // 2
            
            for i in range(len(vectors)):
                for j in range(i + 1, len(vectors)):
                    z = tuple(vectors[i][c] - vectors[j][c] for c in range(n))
                    if any(zi != 0 for zi in z):
                        kernel_vectors.add(z)
                        norm = max(abs(zi) for zi in z)
                        min_norm = min(min_norm, norm)
        
        results[B] = {
            'box_size': box_size,
            'ratio': box_size / q,
            'num_collisions': num_collisions,
            'num_kernel_vectors': len(kernel_vectors),
            'min_norm': min_norm if min_norm < float('inf') else None,
        }
    
    return results


def estimate_security_level(n: int, q: int, beta: float) -> dict:
    """
    Estimate the security level of a lattice-based scheme.
    
    Given dimension n, modulus q, and target norm ratio beta = 2B/q^(1/n),
    estimates:
    - The minimum B for collision existence
    - The approximate number of collisions
    - A security level estimate (log2 of attack complexity)
    
    This is a simplified model based on the bounded-box collision theorem.
    
    >>> result = estimate_security_level(256, 2**13, 1.0)
    >>> result['threshold_B'] > 0
    True
    """
    B_threshold = collision_threshold(n, q)
    
    # Attack complexity is roughly the box size at threshold
    box_at_threshold = box_cardinality(n, B_threshold)
    security_bits = math.log2(box_at_threshold) if box_at_threshold > 0 else 0
    
    # At the given beta, compute the actual B
    B_beta = int(beta * q ** (1.0 / n) / 2)
    box_at_beta = box_cardinality(n, B_beta)
    
    return {
        'n': n,
        'q': q,
        'threshold_B': B_threshold,
        'box_at_threshold': box_at_threshold,
        'security_bits': security_bits,
        'beta': beta,
        'B_at_beta': B_beta,
        'box_at_beta': box_at_beta,
        'collision_guaranteed': box_at_beta > q,
    }


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")
    
    # Test 1: Basic collision
    result = find_collision([3, 7], 5, 2)
    assert result is not None
    assert sum(a * z for a, z in zip([3, 7], result.z)) % 5 == 0
    print("  ✓ find_collision")
    
    # Test 2: Kernel vector extraction
    kv = extract_short_kernel_vector([3, 7], 5, 2)
    assert kv is not None
    assert kv.inner_product % 5 == 0
    assert kv.sup_norm <= 4
    print("  ✓ extract_short_kernel_vector")
    
    # Test 3: SIS witness
    result = find_sis_witness([[3, 1, 4, 1], [5, 9, 2, 6]], 7, 2)
    assert result is not None
    z, syn = result
    assert all(s == 0 for s in syn)
    print("  ✓ find_sis_witness")
    
    # Test 4: Threshold
    B = collision_threshold(2, 100)
    assert (2 * B + 1) ** 2 > 100
    assert (2 * (B - 1) + 1) ** 2 <= 100
    print("  ✓ collision_threshold")
    
    # Test 5: Multiplicity table
    table = collision_multiplicity_table(2, [1, 1], 5, range(1, 4))
    assert len(table) == 3
    print("  ✓ collision_multiplicity_table")
    
    print("\nAll self-tests passed! ✓")
