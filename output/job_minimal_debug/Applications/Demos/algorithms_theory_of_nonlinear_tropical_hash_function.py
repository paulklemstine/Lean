"""
NTSHA — Nonlinear Tropical Secure Hash Algorithm
Type-hinted implementations of core algorithms.
"""

from typing import List, Tuple, Optional
import math


def tropical_hash(m: List[int], h: List[int]) -> int:
    """Standard tropical (min-plus) hash: TSHA(m, h) = min_i(m_i + h_i)."""
    assert len(m) == len(h) > 0, "Vectors must be non-empty and same length"
    return min(mi + hi for mi, hi in zip(m, h))


def ntsha(p: int, m: List[int], h: List[int]) -> int:
    """Nonlinear Tropical Secure Hash Algorithm.
    NTSHA_p(m, h) = min_i((m_i + h_i) mod p)
    
    Args:
        p: Modulus (positive integer, ideally prime)
        m: Message vector (list of integers)
        h: Key vector (list of integers, same length as m)
    
    Returns:
        Hash value in {0, 1, ..., p-1}
    """
    assert p > 0, "Modulus must be positive"
    assert len(m) == len(h) > 0, "Vectors must be non-empty and same length"
    return min((mi + hi) % p for mi, hi in zip(m, h))


def ntsha_fiber(p: int, h: List[int], y: int, bound: int = 10) -> List[List[int]]:
    """Enumerate preimage fiber: all m in [0, bound)^k with NTSHA_p(m, h) = y.
    
    Demonstrates the lattice periodicity structure of fibers.
    """
    k = len(h)
    fiber = []
    for idx in range(bound ** k):
        m = []
        temp = idx
        for _ in range(k):
            m.append(temp % bound)
            temp //= bound
        if ntsha(p, m, h) == y:
            fiber.append(m)
    return fiber


def avalanche_deficiency(p: int, m: List[int], h: List[int], j: int) -> int:
    """Compute avalanche deficiency for perturbing component j by 1."""
    m_perturbed = m.copy()
    m_perturbed[j] += 1
    return abs(ntsha(p, m_perturbed, h) - ntsha(p, m, h))


def avalanche_zero_proportion(p: int, k: int, h: List[int], j: int) -> float:
    """Compute proportion of inputs where avalanche deficiency is zero.
    
    Tests the Tropical Avalanche Threshold conjecture.
    """
    total = p ** k
    zeros = 0
    for idx in range(total):
        m = []
        temp = idx
        for _ in range(k):
            m.append(temp % p)
            temp //= p
        if avalanche_deficiency(p, m, h, j) == 0:
            zeros += 1
    return zeros / total


def verify_shift_equivariance_tsha(k: int, c: int, trials: int = 100) -> bool:
    """Verify that TSHA is shift-equivariant for random inputs."""
    import random
    for _ in range(trials):
        m = [random.randint(-100, 100) for _ in range(k)]
        h = [random.randint(-100, 100) for _ in range(k)]
        m_shifted = [mi + c for mi in m]
        assert tropical_hash(m_shifted, h) == tropical_hash(m, h) + c
    return True


def verify_shift_break_ntsha(p: int, k: int, trials: int = 1000) -> Tuple[int, int]:
    """Count how often NTSHA shift equivariance breaks.
    
    Returns (breaks, total) — the number of trials where
    NTSHA(m+c, h) ≠ (NTSHA(m, h) + c) mod p.
    """
    import random
    breaks = 0
    for _ in range(trials):
        m = [random.randint(0, p - 1) for _ in range(k)]
        h = [random.randint(0, p - 1) for _ in range(k)]
        c = random.randint(1, p - 1)
        m_shifted = [mi + c for mi in m]
        lhs = ntsha(p, m_shifted, h)
        rhs = (ntsha(p, m, h) + c) % p
        if lhs != rhs:
            breaks += 1
    return breaks, trials


def fiber_periodicity_check(p: int, k: int, trials: int = 100) -> bool:
    """Verify fiber periodicity: NTSHA(m + n*p*e_j, h) = NTSHA(m, h)."""
    import random
    for _ in range(trials):
        m = [random.randint(-100, 100) for _ in range(k)]
        h = [random.randint(-100, 100) for _ in range(k)]
        j = random.randint(0, k - 1)
        n = random.randint(-10, 10)
        m_shifted = m.copy()
        m_shifted[j] += n * p
        assert ntsha(p, m_shifted, h) == ntsha(p, m, h), \
            f"Periodicity failed: p={p}, m={m}, h={h}, j={j}, n={n}"
    return True


def preimage_count_by_modulus(p_values: List[int], k: int = 3) -> dict:
    """Count average fiber sizes for different moduli.
    
    For each p, computes the average number of preimages in [0,p)^k
    for each hash value, with h = 0.
    """
    results = {}
    for p in p_values:
        h = [0] * k
        counts = {y: 0 for y in range(p)}
        total = p ** k
        for idx in range(total):
            m = []
            temp = idx
            for _ in range(k):
                m.append(temp % p)
                temp //= p
            y = ntsha(p, m, h)
            counts[y] += 1
        avg_fiber = total / p  # Expected by symmetry
        actual_avg = sum(counts.values()) / p
        max_fiber = max(counts.values())
        min_fiber = min(counts.values())
        results[p] = {
            'expected_avg': avg_fiber,
            'actual_avg': actual_avg,
            'max_fiber': max_fiber,
            'min_fiber': min_fiber,
            'distribution': counts
        }
    return results
