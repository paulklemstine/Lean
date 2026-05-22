#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Communication Complexity Gap Analysis

Implements:
1. Polynomial fingerprinting over finite fields
2. Deterministic equality protocol (baseline)
3. Schwartz-Zippel root counting
4. Communication gap ratio computation
5. Reed-Solomon encoding via fingerprints
"""

import math
from typing import Set, List, Tuple, Dict, Optional
from dataclasses import dataclass


# ─────────────────────────────────────────────────
# Prime Arithmetic
# ─────────────────────────────────────────────────

def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes up to limit."""
    if limit < 2:
        return []
    is_p = [True] * (limit + 1)
    is_p[0] = is_p[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_p[i]:
            for j in range(i*i, limit + 1, i):
                is_p[j] = False
    return [i for i in range(2, limit + 1) if is_p[i]]


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test for small numbers."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def next_prime_after(n: int) -> int:
    """Find smallest prime ≥ n."""
    while not is_prime(n):
        n += 1
    return n


# ─────────────────────────────────────────────────
# Polynomial Fingerprinting
# ─────────────────────────────────────────────────

@dataclass
class FingerprintResult:
    """Result of a fingerprint computation."""
    value: int
    prime: int
    evaluation_point: int
    subset: frozenset


def fingerprint_polynomial(S: Set[int], r: int, p: int) -> int:
    """
    Compute the fingerprint polynomial P_S(r) = Σ_{i ∈ S} r^i mod p.
    
    This is the core of the randomized communication protocol.
    
    Args:
        S: Subset of {0, 1, ..., n-1}
        r: Evaluation point in ZMod p
        p: Prime modulus
    
    Returns:
        P_S(r) mod p
        
    Time complexity: O(n log n) using fast exponentiation
    Space complexity: O(1) beyond input
    
    Example:
        >>> fingerprint_polynomial({0, 2, 3}, 5, 7)
        # = 5^0 + 5^2 + 5^3 = 1 + 25 + 125 = 151 = 4 mod 7
        4
    """
    return sum(pow(r, i, p) for i in S) % p


def difference_polynomial_roots(S: Set[int], T: Set[int], p: int) -> List[int]:
    """
    Find all roots of the difference polynomial Δ_{S,T}(X) = P_S(X) - P_T(X) in ZMod p.
    
    These are exactly the evaluation points where the fingerprints collide.
    
    Args:
        S, T: Subsets to compare
        p: Prime modulus
    
    Returns:
        List of roots r ∈ {0, ..., p-1} where P_S(r) = P_T(r) mod p
        
    Time complexity: O(p · n) — brute force, suitable for small p
    """
    roots = []
    for r in range(p):
        if fingerprint_polynomial(S, r, p) == fingerprint_polynomial(T, r, p):
            roots.append(r)
    return roots


# ─────────────────────────────────────────────────
# Communication Protocols
# ─────────────────────────────────────────────────

@dataclass
class ProtocolResult:
    """Result of running a communication protocol."""
    answer: bool          # Protocol's answer: True = 'equal'
    communication: int    # Bits communicated
    correct: bool         # Whether the answer is correct
    

def deterministic_protocol(S: Set[int], T: Set[int], n: int) -> ProtocolResult:
    """
    Deterministic equality protocol: Alice sends the full encoding of S.
    
    Alice encodes S as an n-bit string (characteristic vector) and sends it.
    Bob checks if it matches T. Communication cost: n bits.
    
    Args:
        S, T: Subsets of {0, ..., n-1}
        n: Universe size
    
    Returns:
        ProtocolResult with communication = n bits
    """
    # Alice's message: n-bit characteristic vector
    msg = tuple(1 if i in S else 0 for i in range(n))
    communication = n
    
    # Bob reconstructs and compares
    bob_S = set(i for i in range(n) if msg[i] == 1)
    answer = (bob_S == T)
    correct = (answer == (S == T))
    
    return ProtocolResult(answer=answer, communication=communication, correct=correct)


def randomized_protocol(S: Set[int], T: Set[int], n: int, 
                         p: int, r: int) -> ProtocolResult:
    """
    Randomized fingerprinting protocol: Alice sends P_S(r) mod p.
    
    Communication cost: ⌈log₂(p)⌉ bits.
    Error: one-sided — may say 'equal' when S ≠ T, never the reverse.
    
    Args:
        S, T: Subsets of {0, ..., n-1}
        n: Universe size
        p: Prime modulus (shared parameter)
        r: Shared random evaluation point
    
    Returns:
        ProtocolResult with communication = ⌈log₂(p)⌉ bits
    """
    fp_S = fingerprint_polynomial(S, r, p)
    fp_T = fingerprint_polynomial(T, r, p)
    
    communication = math.ceil(math.log2(p)) if p > 1 else 1
    answer = (fp_S == fp_T)
    correct = (answer == (S == T))
    
    return ProtocolResult(answer=answer, communication=communication, correct=correct)


# ─────────────────────────────────────────────────
# Schwartz-Zippel Root Counting
# ─────────────────────────────────────────────────

def schwartz_zippel_bound(degree: int, field_size: int) -> float:
    """
    Schwartz-Zippel bound: Pr[f(r) = 0] ≤ degree / field_size.
    
    For a nonzero polynomial f of degree d over a field of size q,
    a uniformly random evaluation point is a root with probability ≤ d/q.
    
    Args:
        degree: Degree of the polynomial
        field_size: Size of the field (must be prime for ZMod)
    
    Returns:
        Upper bound on collision probability
    """
    if field_size == 0:
        return 1.0
    return min(degree / field_size, 1.0)


def count_polynomial_roots(coeffs: List[int], p: int) -> int:
    """
    Count roots of a polynomial with given coefficients over ZMod p.
    
    Args:
        coeffs: Coefficients [a_0, a_1, ..., a_d] for polynomial a_0 + a_1*x + ... + a_d*x^d
        p: Prime modulus
    
    Returns:
        Number of roots in {0, ..., p-1}
    """
    count = 0
    for r in range(p):
        val = sum(c * pow(r, i, p) for i, c in enumerate(coeffs)) % p
        if val == 0:
            count += 1
    return count


# ─────────────────────────────────────────────────
# Communication Gap Analysis
# ─────────────────────────────────────────────────

@dataclass
class GapAnalysis:
    """Analysis of the communication gap for a given n."""
    n: int
    det_lower_bound: int       # Deterministic lower bound (bits)
    rand_upper_bound: int      # Randomized upper bound (bits)
    prime_used: int            # Prime p used for randomized protocol
    error_bound: float         # Error probability bound
    gap_ratio: float           # det / rand ratio


def analyze_gap(n: int, target_error: float = 1/3) -> GapAnalysis:
    """
    Analyze the deterministic-randomized communication gap for Finset(Fin n) equality.
    
    Args:
        n: Universe size
        target_error: Maximum allowed error probability
    
    Returns:
        GapAnalysis with detailed bounds
    
    Example:
        >>> result = analyze_gap(10)
        >>> print(f"Gap ratio: {result.gap_ratio:.1f}x")
    """
    # Deterministic: need to distinguish 2^n inputs → n bits
    det_lower = n
    
    # Randomized: use prime p ≥ n/target_error
    min_p = math.ceil(n / target_error)
    p = next_prime_after(min_p)
    
    # Communication = bits to encode one element of ZMod p
    rand_upper = math.ceil(math.log2(p)) + 1 if p > 1 else 1
    
    # Actual error bound
    error = (n - 1) / p if p > 0 else 1.0
    
    gap = det_lower / rand_upper if rand_upper > 0 else float('inf')
    
    return GapAnalysis(
        n=n,
        det_lower_bound=det_lower,
        rand_upper_bound=rand_upper,
        prime_used=p,
        error_bound=error,
        gap_ratio=gap
    )


# ─────────────────────────────────────────────────
# Reed-Solomon Encoding
# ─────────────────────────────────────────────────

def reed_solomon_encode(S: Set[int], n: int, p: int) -> List[int]:
    """
    Encode a subset as its Reed-Solomon codeword.
    
    The codeword is (P_S(0), P_S(1), ..., P_S(p-1)) where P_S(X) = Σ_{i∈S} X^i.
    
    Args:
        S: Subset of {0, ..., n-1}
        n: Universe size
        p: Prime modulus (code length)
    
    Returns:
        List of p elements in ZMod p
    
    Properties:
        - Message length: n bits (characteristic vector of S)
        - Codeword length: p symbols in ZMod p
        - Minimum distance: ≥ p - n + 1 (by Schwartz-Zippel / BCH bound)
    """
    return [fingerprint_polynomial(S, r, p) for r in range(p)]


def reed_solomon_distance(S: Set[int], T: Set[int], n: int, p: int) -> int:
    """
    Compute the Hamming distance between Reed-Solomon codewords of S and T.
    
    By the Schwartz-Zippel lemma, if S ≠ T, the distance is ≥ p - (n-1).
    """
    code_S = reed_solomon_encode(S, n, p)
    code_T = reed_solomon_encode(T, n, p)
    return sum(1 for a, b in zip(code_S, code_T) if a != b)


# ─────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Communication Gap Analysis ===\n")
    
    for n in [4, 8, 12, 16, 20]:
        result = analyze_gap(n)
        print(f"n={n:3d}: det≥{result.det_lower_bound:3d} bits, "
              f"rand≤{result.rand_upper_bound:3d} bits (p={result.prime_used}), "
              f"gap={result.gap_ratio:.2f}x, error≤{result.error_bound:.4f}")
    
    print("\n=== Reed-Solomon Distance ===\n")
    n, p = 4, 13
    S, T = {0, 1}, {2, 3}
    dist = reed_solomon_distance(S, T, n, p)
    print(f"n={n}, p={p}, S={S}, T={T}")
    print(f"Hamming distance: {dist} (expected ≥ {p - n + 1})")
    
    print("\n=== Schwartz-Zippel Bounds ===\n")
    for d in [1, 5, 10, 50]:
        for q in [101, 1009, 10007]:
            bound = schwartz_zippel_bound(d, q)
            print(f"deg={d:3d}, |F|={q:6d}: Pr[root] ≤ {bound:.6f}")
