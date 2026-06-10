#!/usr/bin/env python3
"""
Tropical Quadratic Sieve Shadow: Core Algorithms

Implements the algorithms described in the research paper:
- Tropical score computation
- Score defect analysis  
- Min-plus matrix multiplication
- Tropical sieve relation collection
"""

import math
from collections import Counter
from typing import List, Dict, Tuple, Optional
import numpy as np


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return list of primes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def factorize(n: int) -> Dict[int, int]:
    """
    Return prime factorization of n as {prime: exponent}.
    
    Time complexity: O(sqrt(n))
    """
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = 1
    return factors


def p_adic_valuation(n: int, p: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of n.
    
    Returns the largest k such that p^k divides n.
    """
    if n == 0 or p < 2:
        return 0
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


class TropicalScorer:
    """
    Tropical score computation engine.
    
    Given a factor base P = {p_1, ..., p_k}, computes:
    - tropicalScore(n) = sum_{p in P} v_p(n) * log(p)
    - scoreDefect(n) = log(n) - tropicalScore(n)
    
    Theorem: scoreDefect(n) >= 0, with equality iff n is P-smooth.
    
    Complexity: O(k * log(n)) per score computation, where k = |P|.
    """
    
    def __init__(self, factor_base: List[int]):
        """
        Initialize with a factor base of primes.
        
        Args:
            factor_base: List of primes forming the factor base.
        """
        self.factor_base = sorted(set(factor_base))
        self.log_primes = {p: math.log(p) for p in self.factor_base}
    
    def valuation_vector(self, n: int) -> List[int]:
        """
        Compute the valuation vector w_P(n) = (v_{p_1}(n), ..., v_{p_k}(n)).
        
        This is the tropical weight vector encoding all factor-base information.
        """
        return [p_adic_valuation(n, p) for p in self.factor_base]
    
    def tropical_score(self, n: int) -> float:
        """
        Compute tropicalScore_P(n) = sum_{p in P} v_p(n) * log(p).
        
        This equals log(prod_{p in P} p^{v_p(n)}) by Theorem A.
        """
        if n <= 0:
            return float('-inf')
        return sum(
            p_adic_valuation(n, p) * self.log_primes[p]
            for p in self.factor_base
        )
    
    def score_defect(self, n: int) -> float:
        """
        Compute scoreDefect_P(n) = log(n) - tropicalScore_P(n).
        
        Theorem C.1: This is always >= 0.
        Theorem C.2: This equals 0 iff n is P-smooth.
        """
        if n <= 0:
            return float('inf')
        return math.log(n) - self.tropical_score(n)
    
    def is_smooth(self, n: int) -> bool:
        """Check if n is P-smooth (all prime factors in factor base)."""
        return abs(self.score_defect(n)) < 1e-10
    
    def classify(self, n: int, large_prime_bound: Optional[int] = None) -> str:
        """
        Classify n by its tropical defect:
        - "smooth": defect = 0, full relation
        - "one-large-prime": defect = log(q) for some prime q ≤ bound
        - "non-smooth": defect too large
        """
        sd = self.score_defect(n)
        if sd < 1e-10:
            return "smooth"
        
        if large_prime_bound is not None:
            # Check if residual is a single prime
            residual = n
            for p in self.factor_base:
                while residual % p == 0:
                    residual //= p
            if 1 < residual <= large_prime_bound and all(
                residual % p != 0 for p in range(2, int(residual**0.5) + 1)
            ):
                return f"one-large-prime (q={residual})"
        
        return "non-smooth"


class MinPlusMatrix:
    """
    Min-plus (tropical) matrix algebra over ℕ∞ = ℕ ∪ {∞}.
    
    Operations:
    - Tropical addition: a ⊕ b = min(a, b)
    - Tropical multiplication: a ⊗ b = a + b
    
    Matrix multiplication: (A ⊗ B)_{ik} = min_j (A_{ij} + B_{jk})
    
    Theorem: This multiplication is associative (minPlusMatMul_assoc).
    
    Complexity: O(n³) for n×n matrix multiplication.
    """
    
    INF = float('inf')
    
    def __init__(self, data: List[List[float]]):
        """Initialize from a 2D list."""
        self.data = [row[:] for row in data]
        self.n = len(data)
    
    @classmethod
    def identity(cls, n: int) -> 'MinPlusMatrix':
        """Tropical identity matrix: 0 on diagonal, ∞ elsewhere."""
        data = [[cls.INF] * n for _ in range(n)]
        for i in range(n):
            data[i][i] = 0
        return cls(data)
    
    @classmethod
    def from_graph(cls, adj: Dict[Tuple[int,int], float], n: int) -> 'MinPlusMatrix':
        """Create from weighted directed graph."""
        data = [[cls.INF] * n for _ in range(n)]
        for i in range(n):
            data[i][i] = 0
        for (i, j), w in adj.items():
            data[i][j] = w
        return cls(data)
    
    def __matmul__(self, other: 'MinPlusMatrix') -> 'MinPlusMatrix':
        """Min-plus matrix multiplication."""
        assert self.n == other.n
        n = self.n
        result = [[self.INF] * n for _ in range(n)]
        for i in range(n):
            for k in range(n):
                for j in range(n):
                    val = self.data[i][j] + other.data[j][k]
                    if val < result[i][k]:
                        result[i][k] = val
        return MinPlusMatrix(result)
    
    def power(self, k: int) -> 'MinPlusMatrix':
        """Compute k-th min-plus power (shortest paths of length ≤ k)."""
        result = MinPlusMatrix.identity(self.n)
        base = MinPlusMatrix(self.data)
        while k > 0:
            if k % 2 == 1:
                result = result @ base
            base = base @ base
            k //= 2
        return result
    
    def __eq__(self, other: 'MinPlusMatrix') -> bool:
        if self.n != other.n:
            return False
        for i in range(self.n):
            for j in range(self.n):
                a, b = self.data[i][j], other.data[i][j]
                if a == self.INF and b == self.INF:
                    continue
                if abs(a - b) > 1e-10:
                    return False
        return True
    
    def __repr__(self) -> str:
        rows = []
        for row in self.data:
            entries = []
            for x in row:
                entries.append("∞" if x == self.INF else f"{x:.0f}")
            rows.append("[" + ", ".join(f"{e:>4}" for e in entries) + "]")
        return "\n".join(rows)


def tropical_sieve(N: int, factor_base: List[int], interval_size: int = 100,
                   large_prime_bound: Optional[int] = None) -> Dict[str, list]:
    """
    Tropical sieve algorithm for finding smooth relations.
    
    Pseudocode:
    1. Compute Q(x) = x² - N for x in sieve interval
    2. For each x, compute tropicalScore(Q(x)) and scoreDefect(Q(x))
    3. Accept x if scoreDefect = 0 (smooth) or scoreDefect ≤ log(large_prime_bound)
    
    Args:
        N: Number to factor
        factor_base: List of primes
        interval_size: Half-width of sieve interval
        large_prime_bound: Optional bound for one-large-prime relations
    
    Returns:
        Dictionary with 'smooth', 'one_large_prime', and 'statistics' keys.
    
    Complexity: O(M * B) where M = interval size, B = |factor_base|
    """
    scorer = TropicalScorer(factor_base)
    base = int(math.isqrt(N)) + 1
    
    smooth_relations = []
    large_prime_relations = []
    total_scored = 0
    
    for i in range(-interval_size, interval_size + 1):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        
        total_scored += 1
        classification = scorer.classify(Q, large_prime_bound)
        
        if classification == "smooth":
            smooth_relations.append({
                'x': x,
                'Q': Q,
                'factorization': factorize(Q),
                'valuation_vector': scorer.valuation_vector(Q),
                'score': scorer.tropical_score(Q),
                'defect': 0.0
            })
        elif classification.startswith("one-large-prime"):
            large_prime_relations.append({
                'x': x,
                'Q': Q,
                'factorization': factorize(Q),
                'valuation_vector': scorer.valuation_vector(Q),
                'score': scorer.tropical_score(Q),
                'defect': scorer.score_defect(Q),
                'classification': classification
            })
    
    return {
        'smooth': smooth_relations,
        'one_large_prime': large_prime_relations,
        'statistics': {
            'N': N,
            'factor_base': factor_base,
            'interval_size': interval_size,
            'total_scored': total_scored,
            'smooth_count': len(smooth_relations),
            'large_prime_count': len(large_prime_relations),
            'work': total_scored * len(factor_base)
        }
    }


def verify_associativity(n: int = 4, trials: int = 10) -> bool:
    """
    Verify min-plus matrix associativity on random instances.
    
    This is a computational check of the formally proven theorem
    minPlusMatMul_assoc.
    """
    import random
    INF = float('inf')
    
    for trial in range(trials):
        A = MinPlusMatrix([[random.choice([random.randint(0, 20), INF]) 
                           for _ in range(n)] for _ in range(n)])
        B = MinPlusMatrix([[random.choice([random.randint(0, 20), INF]) 
                           for _ in range(n)] for _ in range(n)])
        C = MinPlusMatrix([[random.choice([random.randint(0, 20), INF]) 
                           for _ in range(n)] for _ in range(n)])
        
        left = (A @ B) @ C
        right = A @ (B @ C)
        
        if left != right:
            return False
    return True


if __name__ == "__main__":
    print("=== Tropical Sieve Demo ===\n")
    
    # Factor a small semiprime
    N = 15347  # = 113 × 137 (but we don't know this yet)
    fb = sieve_of_eratosthenes(50)
    
    result = tropical_sieve(N, fb, interval_size=200, large_prime_bound=500)
    
    stats = result['statistics']
    print(f"Factoring N = {N}")
    print(f"Factor base: {fb}")
    print(f"Work performed: {stats['work']} tropical operations")
    print(f"Smooth relations found: {stats['smooth_count']}")
    print(f"One-large-prime relations: {stats['large_prime_count']}")
    
    print("\nSmooth relations (defect = 0):")
    for rel in result['smooth'][:10]:
        print(f"  x={rel['x']}, Q(x)={rel['Q']}, factors={dict(rel['factorization'])}")
    
    print("\nOne-large-prime relations:")
    for rel in result['one_large_prime'][:10]:
        print(f"  x={rel['x']}, Q(x)={rel['Q']}, {rel['classification']}, defect={rel['defect']:.4f}")
    
    print(f"\n=== Associativity Check ===")
    print(f"Min-plus associativity verified: {verify_associativity()}")
