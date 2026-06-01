"""
Algorithms for the Mega-Sphere: Inverse Limits of Sphere Towers

This module implements the core algebraic constructions for computing
with the Mega-Sphere — the inverse limit of truncated polynomial data
that encodes sphere invariants across all dimensions simultaneously.

Type-hinted implementations of:
1. Inverse limit construction and projection maps
2. Sphere Euler characteristic computation
3. Bernoulli-sphere weight function and cumulative invariant
4. Characteristic polynomial evaluation
"""

from typing import Callable, List, Tuple, Optional
from fractions import Fraction
import math


# ============================================================
# Algorithm 1: Inverse Limit Element Construction
# ============================================================
# Pseudocode:
#   INPUT: sequence a : N -> Z
#   OUTPUT: element of lim_{<-} (Z^{n+1})
#   For each level n, project: pi_n(a) = (a_0, a_1, ..., a_n)
#   Verify: forall n, bond_n(pi_{n+1}(a)) = pi_n(a)

class InverseSystemElement:
    """An element of the inverse limit of truncated integer sequences.
    
    Represents a compatible family of finite truncations of an infinite
    integer sequence, satisfying the bonding map compatibility condition.
    """
    
    def __init__(self, sequence: Callable[[int], int]) -> None:
        """Create from an infinite integer sequence."""
        self._seq = sequence
    
    def proj(self, n: int) -> List[int]:
        """Project to level n: returns first n+1 terms."""
        return [self._seq(i) for i in range(n + 1)]
    
    def bond(self, n: int) -> List[int]:
        """Apply bonding map at level n: drop last element of level n+1."""
        return self.proj(n + 1)[:-1]
    
    def verify_compatibility(self, max_level: int = 100) -> bool:
        """Verify bonding map compatibility up to a given level."""
        for n in range(max_level):
            if self.bond(n) != self.proj(n):
                return False
        return True
    
    def to_seq(self, length: int) -> List[int]:
        """Extract first `length` terms of the sequence."""
        return [self._seq(n) for n in range(length)]


# ============================================================
# Algorithm 2: Sphere Euler Characteristic
# ============================================================
# Pseudocode:
#   chi(S^n) = 1 + (-1)^n
#   = 2 if n is even
#   = 0 if n is odd

def sphere_euler_char(n: int) -> int:
    """Compute the Euler characteristic of the n-sphere S^n.
    
    χ(S^n) = 1 + (-1)^n = 2 if n even, 0 if n odd.
    """
    return 1 + (-1) ** n


def sphere_euler_char_sum(N: int) -> int:
    """Compute Σ_{i=0}^{N} χ(S^i).
    
    For N = 2k: sum = 2(k+1)
    For N = 2k+1: sum = 2(k+1)
    """
    return sum(sphere_euler_char(i) for i in range(N + 1))


# ============================================================
# Algorithm 3: Bernoulli Numbers (recursive computation)
# ============================================================
# Pseudocode:
#   B'_0 = 1
#   B'_n = 1 - sum_{k=0}^{n-1} C(n,n-k)/(n-k+1) * B'_k

def bernoulli_prime(n: int, _cache: Optional[dict] = None) -> Fraction:
    """Compute the n-th Bernoulli number B'_n (second convention).
    
    B'_0 = 1, B'_1 = 1/2, B'_2 = 1/6, B'_3 = 0, B'_4 = -1/30, ...
    Uses the recurrence from the defining identity.
    """
    if _cache is None:
        _cache = {}
    if n in _cache:
        return _cache[n]
    if n == 0:
        _cache[0] = Fraction(1)
        return Fraction(1)
    
    s = Fraction(0)
    for k in range(n):
        binom = math.comb(n, n - k)
        s += Fraction(binom, n - k + 1) * bernoulli_prime(k, _cache)
    
    result = Fraction(1) - s
    _cache[n] = result
    return result


# ============================================================
# Algorithm 4: Bernoulli-Sphere Weight and Invariant
# ============================================================
# Pseudocode:
#   BSW(n) = B'_n * (1 + (-1)^n)
#   BSI(N) = sum_{k=0}^{N} BSW(k)

def bernoulli_sphere_weight(n: int) -> Fraction:
    """Compute B'_n · (1 + (-1)^n).
    
    Vanishes for all odd n due to parity alignment.
    For even n = 2k: equals 2·B'_{2k}.
    """
    return bernoulli_prime(n) * Fraction(1 + (-1) ** n)


def bernoulli_sphere_invariant(N: int) -> Fraction:
    """Compute the cumulative Bernoulli-sphere invariant BSI(N) = Σ_{k≤N} BSW(k).
    
    BSI(0) = 2, BSI(1) = 2, BSI(2) = 2 + 2/6 = 7/3, ...
    Odd steps don't change the value: BSI(2k+1) = BSI(2k).
    """
    return sum(bernoulli_sphere_weight(k) for k in range(N + 1))


# ============================================================
# Algorithm 5: Characteristic Polynomial
# ============================================================
# Pseudocode:
#   p_n(X) = X^n + (-1)^n
#   Evaluate at X = 1 to get chi(S^n)

def sphere_char_poly_coeffs(n: int) -> List[int]:
    """Return coefficients of p_n(X) = X^n + (-1)^n.
    
    Coefficients are [(-1)^n, 0, ..., 0, 1] (constant to leading).
    For n=0: [2] (constant polynomial 2).
    """
    if n == 0:
        return [2]
    coeffs = [0] * (n + 1)
    coeffs[0] = (-1) ** n
    coeffs[n] = 1
    return coeffs


def sphere_char_poly_eval(n: int, x: int) -> int:
    """Evaluate p_n(X) = X^n + (-1)^n at a given integer x."""
    return x ** n + (-1) ** n


# ============================================================
# Algorithm 6: Euler Encoding
# ============================================================

def euler_encoding(length: int) -> InverseSystemElement:
    """Create the Euler encoding: the Mega-Sphere element whose
    n-th entry is χ(S^n) = 1 + (-1)^n.
    """
    return InverseSystemElement(sphere_euler_char)


def verify_euler_encoding_unfilterable(max_n: int = 1000) -> bool:
    """Verify that the Euler encoding is not in any finite filtration level.
    
    For each n, checks that there exists k > n with χ(S^k) ≠ 0.
    """
    enc = euler_encoding(max_n)
    for n in range(max_n):
        # 2*(n+1) is even and > n, so χ(S^{2(n+1)}) = 2 ≠ 0
        k = 2 * (n + 1)
        if enc._seq(k) == 0:
            return False
    return True
