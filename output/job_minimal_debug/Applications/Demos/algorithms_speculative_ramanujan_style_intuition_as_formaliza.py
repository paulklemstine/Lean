#!/usr/bin/env python3
"""
Algorithms for Ramanujan Oracle Non-Computability Theory

Type-hinted implementations of the core algorithms from the research.
"""

from typing import List, Tuple, Optional, Callable
import math
import itertools


# ============================================================
# Algorithm 1: Oracle Space Enumeration
# ============================================================

def enumerate_oracles(N: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all 3^N possible oracles on N statements.
    
    Each oracle is a tuple of N values, each in {0, 1, 2}
    representing {true, false, unknown}.
    
    Args:
        N: Number of statements
    
    Returns:
        List of all 3^N oracle tuples
    
    Complexity: O(N * 3^N) time, O(N) per oracle
    """
    return list(itertools.product(range(3), repeat=N))


# ============================================================
# Algorithm 2: Program Space Enumeration
# ============================================================

def enumerate_programs(b: int, k: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all b^k possible programs of length k over alphabet of size b.
    
    Args:
        b: Alphabet size
        k: Maximum program length
    
    Returns:
        List of all b^k program tuples
    """
    return list(itertools.product(range(b), repeat=k))


# ============================================================
# Algorithm 3: Oracle Accuracy Computation
# ============================================================

def oracle_accuracy(
    oracle: Tuple[int, ...],
    truth: Tuple[int, ...],
) -> int:
    """
    Compute the accuracy of an oracle relative to ground truth.
    
    Accuracy = number of positions where oracle agrees with truth.
    
    Args:
        oracle: Oracle output tuple
        truth: Ground truth tuple
    
    Returns:
        Number of agreeing positions
    """
    assert len(oracle) == len(truth)
    return sum(1 for o, t in zip(oracle, truth) if o == t)


def is_accurate(
    oracle: Tuple[int, ...],
    truth: Tuple[int, ...],
    max_errors: int,
) -> bool:
    """
    Check if an oracle is (N - max_errors)-accurate.
    
    Args:
        oracle: Oracle output tuple
        truth: Ground truth tuple  
        max_errors: Maximum allowed disagreements
    
    Returns:
        True if oracle disagrees with truth on at most max_errors positions
    """
    N = len(oracle)
    return oracle_accuracy(oracle, truth) >= N - max_errors


# ============================================================
# Algorithm 4: Non-Covered Oracle Detection
# ============================================================

def find_uncovered_oracle(
    N: int,
    programs: List[Tuple[int, ...]],
) -> Optional[Tuple[int, ...]]:
    """
    Find an oracle not covered by any program in the list.
    
    Uses exhaustive search over 3^N oracles.
    
    Args:
        N: Number of statements
        programs: List of oracle outputs (each a tuple of length N)
    
    Returns:
        An oracle tuple not in programs, or None if all are covered
    """
    program_set = set(programs)
    for oracle in itertools.product(range(3), repeat=N):
        if oracle not in program_set:
            return oracle
    return None


# ============================================================
# Algorithm 5: Cantor Diagonal Construction
# ============================================================

def cantor_diagonal(
    enumeration: Callable[[int], Callable[[int], int]],
    length: int,
) -> Tuple[int, ...]:
    """
    Construct a function that differs from every function in an enumeration.
    
    Given f: ℕ → (ℕ → Fin 3), constructs g such that g(n) ≠ f(n)(n)
    for all n < length.
    
    Args:
        enumeration: Function mapping index to oracle function
        length: Number of positions to construct
    
    Returns:
        Tuple of length `length` differing from enumeration at each diagonal
    """
    result = []
    for n in range(length):
        fnn = enumeration(n)(n)
        # Choose a value different from f(n)(n)
        gn = 1 if fnn == 0 else 0
        result.append(gn)
    return tuple(result)


# ============================================================
# Algorithm 6: Gap Ratio Computation
# ============================================================

def compute_gap_table(
    b: int,
    max_k: int,
    max_N: int,
) -> List[Tuple[int, int, float, bool]]:
    """
    Compute the gap ratio 3^N / b^k for a range of parameters.
    
    Args:
        b: Alphabet size for programs
        max_k: Maximum program length
        max_N: Maximum number of statements
    
    Returns:
        List of (k, N, ratio, oracle_exceeds) tuples
    """
    results = []
    for k in range(1, max_k + 1):
        for N in range(1, max_N + 1):
            oracle_count = 3 ** N
            program_count = b ** k
            ratio = oracle_count / program_count
            exceeds = oracle_count > program_count
            results.append((k, N, ratio, exceeds))
    return results


# ============================================================
# Algorithm 7: Minimum N Threshold
# ============================================================

def threshold_N(b: int, k: int) -> int:
    """
    Find minimum N such that 3^N > b^k.
    
    Args:
        b: Alphabet size
        k: Program length
    
    Returns:
        Minimum N where oracle space exceeds program space
    """
    if b <= 1:
        return 1
    target = k * math.log(b) / math.log(3)
    N = math.ceil(target)
    # Verify and adjust
    while 3 ** N <= b ** k:
        N += 1
    return N


# ============================================================
# Algorithm 8: Accuracy Distribution
# ============================================================

def accuracy_distribution(
    N: int,
    truth: Tuple[int, ...],
) -> dict:
    """
    Compute the distribution of accuracies across all 3^N oracles.
    
    Args:
        N: Number of statements
        truth: Ground truth tuple
    
    Returns:
        Dictionary mapping accuracy level to count of oracles achieving it
    """
    dist: dict = {i: 0 for i in range(N + 1)}
    for oracle in itertools.product(range(3), repeat=N):
        acc = oracle_accuracy(oracle, truth)
        dist[acc] += 1
    return dist


if __name__ == "__main__":
    # Quick test
    print("Oracle space for N=5:", len(enumerate_oracles(5)), "= 3^5 =", 3**5)
    
    truth = (0, 1, 0, 1, 0)
    dist = accuracy_distribution(5, truth)
    print(f"\nAccuracy distribution for N=5, truth={truth}:")
    for acc, count in sorted(dist.items()):
        print(f"  Accuracy {acc}: {count} oracles ({count/3**5*100:.1f}%)")
    
    # Cantor diagonal demo
    def enum(n):
        return lambda m: (n + m) % 3
    
    diag = cantor_diagonal(enum, 10)
    print(f"\nCantor diagonal (first 10): {diag}")
    print("Verification:")
    for n in range(10):
        fnn = enum(n)(n)
        print(f"  f({n})({n}) = {fnn}, g({n}) = {diag[n]}, differ: {fnn != diag[n]}")
