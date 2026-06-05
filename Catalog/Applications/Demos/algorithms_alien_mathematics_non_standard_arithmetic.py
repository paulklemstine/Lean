#!/usr/bin/env python3
"""
Algorithms for GrowthRank and Non-Standard Arithmetic
=====================================================

Type-hinted implementations of the core algorithms from the research.
"""

from __future__ import annotations
from typing import Callable, List, Tuple, Optional, Set
from math import isqrt, log2
from dataclasses import dataclass
from functools import reduce


# ============================================================
# Type Aliases
# ============================================================

Sequence = Callable[[int], int]


# ============================================================
# Algorithm 1: Ultrafilter Approximation
# ============================================================

@dataclass
class ApproxUltrafilter:
    """Approximate a free ultrafilter on ℕ using a threshold-based rule.
    
    A set S ⊆ {0,...,N-1} is declared 'U-large' if its density in the
    upper half exceeds a threshold. This captures the cofinite flavor
    of free ultrafilters.
    
    Pseudocode:
        IS_LARGE(S, N):
            tail ← {N/2, ..., N-1}
            return |S ∩ tail| / |tail| > threshold
    """
    N: int = 1000
    threshold: float = 0.5
    
    def is_large(self, S: Set[int]) -> bool:
        """Determine if S is 'U-large' (approximation)."""
        tail_start = self.N // 2
        tail_size = self.N - tail_start
        count = sum(1 for i in range(tail_start, self.N) if i in S)
        return count / tail_size > self.threshold
    
    def ultra_le(self, f: Sequence, g: Sequence) -> bool:
        """Check f ≤_U g."""
        S = {i for i in range(self.N) if f(i) <= g(i)}
        return self.is_large(S)
    
    def ultra_lt(self, f: Sequence, g: Sequence) -> bool:
        """Check f <_U g."""
        S = {i for i in range(self.N) if f(i) < g(i)}
        return self.is_large(S)
    
    def ultra_eq(self, f: Sequence, g: Sequence) -> bool:
        """Check f =_U g."""
        S = {i for i in range(self.N) if f(i) == g(i)}
        return self.is_large(S)


# ============================================================
# Algorithm 2: Growth Rank Classification
# ============================================================

@dataclass
class GrowthClass:
    """Classification of a sequence's growth rate.
    
    Pseudocode:
        CLASSIFY(f, N):
            Compute ratios f(i)/i^α for α ∈ {0, 0.5, 1, 1.5, 2}
            Find α that minimizes variance of ratios
            Return (α, average_ratio)
    """
    exponent: float
    coefficient: float
    name: str
    
    def __repr__(self) -> str:
        return f"GrowthClass({self.name}: ~{self.coefficient:.2f} · n^{self.exponent:.2f})"


def classify_growth(f: Sequence, N: int = 500) -> GrowthClass:
    """Classify the growth rate of a sequence.
    
    Fits f(n) ≈ c · n^α by testing candidate exponents.
    """
    candidates = [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0]
    best_alpha = 0.0
    best_var = float('inf')
    best_coeff = 1.0
    
    for alpha in candidates:
        ratios: List[float] = []
        for i in range(max(2, N // 4), N):
            denom = i ** alpha if alpha > 0 else 1.0
            if denom > 0:
                ratios.append(f(i) / denom)
        
        if not ratios:
            continue
        
        mean = sum(ratios) / len(ratios)
        if mean == 0:
            continue
        var = sum((r - mean) ** 2 for r in ratios) / len(ratios)
        # Normalize variance by mean^2 for fair comparison
        normalized_var = var / (mean ** 2 + 1e-10)
        
        if normalized_var < best_var:
            best_var = normalized_var
            best_alpha = alpha
            best_coeff = mean
    
    names = {
        0.0: "constant", 0.25: "fourth-root", 0.5: "sqrt",
        0.75: "n^(3/4)", 1.0: "linear", 1.5: "n^(3/2)",
        2.0: "quadratic", 3.0: "cubic"
    }
    return GrowthClass(best_alpha, best_coeff, names.get(best_alpha, f"n^{best_alpha}"))


# ============================================================
# Algorithm 3: Compositeness Transfer
# ============================================================

def smallest_prime_factor(n: int) -> int:
    """Return the smallest prime factor of n, or n if prime."""
    if n < 2:
        return n
    if n % 2 == 0:
        return 2
    i = 3
    while i * i <= n:
        if n % i == 0:
            return i
        i += 2
    return n


def compositeness_transfer(
    f: Sequence, N: int = 100
) -> Tuple[Sequence, Sequence, float]:
    """Extract factor sequences g, h such that f =_U g × h.
    
    Pseudocode:
        COMPOSITENESS_TRANSFER(f, N):
            For each i in {0, ..., N-1}:
                If f(i) is composite:
                    g(i) ← smallest_prime_factor(f(i))
                    h(i) ← f(i) / g(i)
                Else:
                    g(i) ← 1, h(i) ← f(i)
            Return (g, h, fraction_where_both_nontrivial)
    
    Returns: (g, h, success_rate)
    """
    g_vals: List[int] = []
    h_vals: List[int] = []
    nontrivial = 0
    
    for i in range(N):
        fi = f(i)
        if fi >= 4:
            gi = smallest_prime_factor(fi)
            hi = fi // gi
            if gi >= 2 and hi >= 2:
                nontrivial += 1
        else:
            gi = 1
            hi = fi
        g_vals.append(gi)
        h_vals.append(hi)
    
    g_seq: Sequence = lambda i, v=g_vals: v[i] if i < len(v) else 1
    h_seq: Sequence = lambda i, v=h_vals: v[i] if i < len(v) else 1
    return g_seq, h_seq, nontrivial / N


# ============================================================
# Algorithm 4: Goldbach Transfer
# ============================================================

def is_prime(n: int) -> bool:
    """Primality test."""
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


def goldbach_decompose(n: int) -> Optional[Tuple[int, int]]:
    """Find primes p, q with n = p + q, or None."""
    if n < 4 or n % 2 != 0:
        return None
    for p in range(2, n):
        if is_prime(p) and is_prime(n - p):
            return (p, n - p)
    return None


def goldbach_transfer(
    f: Sequence, N: int = 100
) -> Tuple[Sequence, Sequence, float]:
    """Extract prime sequences p, q such that f =_U p + q.
    
    Pseudocode:
        GOLDBACH_TRANSFER(f, N):
            For each i in {0, ..., N-1}:
                If f(i) is even and ≥ 4:
                    (p(i), q(i)) ← goldbach_decompose(f(i))
                Else:
                    p(i) ← 2, q(i) ← 2
            Return (p, q, success_rate)
    """
    p_vals: List[int] = []
    q_vals: List[int] = []
    success = 0
    
    for i in range(N):
        fi = f(i)
        decomp = goldbach_decompose(fi)
        if decomp:
            p_vals.append(decomp[0])
            q_vals.append(decomp[1])
            success += 1
        else:
            p_vals.append(2)
            q_vals.append(2)
    
    p_seq: Sequence = lambda i, v=p_vals: v[i] if i < len(v) else 2
    q_seq: Sequence = lambda i, v=q_vals: v[i] if i < len(v) else 2
    return p_seq, q_seq, success / N


# ============================================================
# Algorithm 5: Underflow Detection
# ============================================================

def detect_underflow_bound(
    P: Callable[[int], bool], max_check: int = 10000
) -> Optional[int]:
    """Find N such that P(n) holds for all n ≥ N, or None.
    
    Pseudocode:
        DETECT_UNDERFLOW(P, max_check):
            last_failure ← -1
            For n from 0 to max_check:
                If not P(n):
                    last_failure ← n
            If last_failure < max_check - 100:
                Return last_failure + 1
            Else:
                Return None  (can't determine)
    """
    last_failure = -1
    for n in range(max_check):
        if not P(n):
            last_failure = n
    
    if last_failure < max_check - 100:
        return last_failure + 1
    return None


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("GrowthRank Algorithms\n")
    
    # Growth classification
    print("Growth Classification:")
    sequences = [
        ("constant 5", lambda i: 5),
        ("sqrt", lambda i: isqrt(max(1, i))),
        ("linear", lambda i: i),
        ("quadratic", lambda i: i * i),
    ]
    for name, seq in sequences:
        gc = classify_growth(seq)
        print(f"  {name:>12} → {gc}")
    
    # Compositeness transfer
    print("\nCompositeness Transfer (f(i) = 6i+4):")
    g, h, rate = compositeness_transfer(lambda i: 6 * i + 4, 200)
    print(f"  Success rate: {rate:.1%}")
    print(f"  g(10) = {g(10)}, h(10) = {h(10)}, product = {g(10)*h(10)}, f(10) = {6*10+4}")
    
    # Goldbach transfer
    print("\nGoldbach Transfer (f(i) = 2i+4):")
    p, q, rate = goldbach_transfer(lambda i: 2 * i + 4, 200)
    print(f"  Success rate: {rate:.1%}")
    print(f"  p(10) = {p(10)}, q(10) = {q(10)}, sum = {p(10)+q(10)}, f(10) = {2*10+4}")
    
    # Underflow detection
    print("\nUnderflow Detection:")
    bound = detect_underflow_bound(lambda n: n * n + n + 41 > 0 and is_prime(n * n + n + 41))
    print(f"  P(n) = 'n²+n+41 is prime': eventual bound N = {bound}")
    print(f"  (P fails first at n = 40: 40²+40+41 = {40*40+40+41} = 41², not prime)")
