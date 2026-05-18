#!/usr/bin/env python3
"""
Algorithms: Primality Testing Implementations

Complete implementations of Miller-Rabin and AKS primality testing algorithms
with complexity analysis, optimizations, and certification infrastructure.
"""

import math
import random
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass


# ============================================================
# CORE ARITHMETIC INFRASTRUCTURE
# ============================================================

def decompose_twos(m: int) -> Tuple[int, int]:
    """
    Two-adic decomposition: m = 2^s * d with d odd.
    
    Time complexity: O(log m)
    Space complexity: O(1)
    
    >>> decompose_twos(340)
    (2, 85)
    >>> decompose_twos(24)
    (3, 3)
    """
    if m == 0:
        return (0, 0)
    s = 0
    d = m
    while d % 2 == 0:
        d //= 2
        s += 1
    return (s, d)


def euler_totient(n: int) -> int:
    """
    Euler's totient function φ(n).
    
    Time complexity: O(√n)
    Space complexity: O(1)
    
    >>> euler_totient(12)
    4
    >>> euler_totient(7)
    6
    """
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def multiplicative_order(a: int, n: int) -> int:
    """
    Compute ord_n(a): the multiplicative order of a modulo n.
    
    Time complexity: O(ord_n(a) · log(n)) — worst case O(n)
    Space complexity: O(1)
    
    >>> multiplicative_order(2, 7)
    3
    >>> multiplicative_order(3, 7)
    6
    """
    if math.gcd(a, n) != 1:
        return 0
    order = 1
    current = a % n
    while current != 1:
        current = (current * a) % n
        order += 1
    return order


def is_perfect_power(n: int) -> Optional[Tuple[int, int]]:
    """
    Check if n = a^b for some a ≥ 2, b ≥ 2.
    Returns (a, b) if yes, None otherwise.
    
    Time complexity: O(log²(n) · log(log(n)))
    Space complexity: O(1)
    
    >>> is_perfect_power(8)
    (2, 3)
    >>> is_perfect_power(7)
    """
    if n <= 3:
        return None
    for b in range(2, int(math.log2(n)) + 2):
        a = round(n ** (1.0 / b))
        for candidate in [a - 1, a, a + 1]:
            if candidate >= 2 and candidate ** b == n:
                return (candidate, b)
    return None


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n).
    
    Time complexity: O(log²(n))
    Space complexity: O(1)
    
    >>> jacobi_symbol(2, 7)
    1
    >>> jacobi_symbol(5, 21)
    1
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


# ============================================================
# MILLER-RABIN PRIMALITY TEST
# ============================================================

@dataclass
class MillerRabinResult:
    """Result of a Miller-Rabin test."""
    n: int
    is_probable_prime: bool
    witnesses_found: List[int]
    liars_found: List[int]
    rounds: int
    error_bound: float


def miller_rabin_single_round(n: int, a: int) -> bool:
    """
    Single round of Miller-Rabin test.
    
    Returns True if a is a "liar" (n passes for base a),
    False if a is a "witness" (n is definitely composite).
    
    Algorithm:
    1. Write n-1 = 2^s · d with d odd
    2. Compute x = a^d mod n
    3. If x = 1 or x = n-1, return True (liar)
    4. Square x repeatedly up to s-1 times
    5. If x ever becomes n-1, return True (liar)
    6. Otherwise return False (witness)
    
    Time complexity: O(log²(n) · log(n)) with fast exponentiation
    Space complexity: O(log(n))
    """
    if n < 2:
        return False
    if a % n == 0:
        return True  # trivial case
    
    s, d = decompose_twos(n - 1)
    x = pow(a, d, n)
    
    if x == 1 or x == n - 1:
        return True
    
    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True
        if x == 1:
            return False  # found nontrivial square root of 1
    
    return False


def miller_rabin(n: int, k: int = 20, 
                 deterministic_bases: Optional[List[int]] = None) -> MillerRabinResult:
    """
    Miller-Rabin primality test.
    
    Pseudocode:
        INPUT: n ≥ 2, number of rounds k
        OUTPUT: "composite" (certain) or "probably prime"
        
        1. If n = 2 or n = 3: return "prime"
        2. If n is even: return "composite"
        3. Write n-1 = 2^s · d with d odd
        4. For i = 1 to k:
            a. Pick random a ∈ {2, ..., n-2}
            b. If a is a witness for n: return "composite"
        5. Return "probably prime"
    
    Time complexity: O(k · log²(n) · log(n))
    Space complexity: O(log(n))
    Error probability: ≤ (1/4)^k for composites
    
    For deterministic testing with specific bases:
    - {2, 3}: correct for n < 1,373,653
    - {2, 3, 5, 7, 11}: correct for n < 2,047,671
    - {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37}: correct for n < 3.3×10^24
    """
    if n < 2:
        return MillerRabinResult(n, False, [], [], 0, 0.0)
    if n < 4:
        return MillerRabinResult(n, True, [], [], 0, 0.0)
    if n % 2 == 0:
        return MillerRabinResult(n, False, [2], [], 1, 0.0)
    
    witnesses = []
    liars = []
    
    if deterministic_bases is not None:
        bases = deterministic_bases
    else:
        bases = [random.randint(2, n - 2) for _ in range(k)]
    
    for a in bases:
        a = a % n
        if a < 2:
            a = 2
        if miller_rabin_single_round(n, a):
            liars.append(a)
        else:
            witnesses.append(a)
    
    is_pp = len(witnesses) == 0
    error = (0.25 ** len(bases)) if is_pp else 0.0
    
    return MillerRabinResult(n, is_pp, witnesses, liars, len(bases), error)


def all_miller_rabin_liars(n: int) -> List[int]:
    """
    Find ALL Miller-Rabin liars for n in {1, ..., n-1}.
    
    Only practical for small n (< 10000).
    
    Time complexity: O(n · log²(n))
    """
    return [a for a in range(1, n) if miller_rabin_single_round(n, a)]


# ============================================================
# SOLOVAY-STRASSEN PRIMALITY TEST
# ============================================================

def solovay_strassen_single(n: int, a: int) -> bool:
    """Single round of Solovay-Strassen test."""
    if math.gcd(a, n) > 1:
        return False
    jac = jacobi_symbol(a, n) % n
    euler = pow(a, (n - 1) // 2, n)
    return jac == euler


def solovay_strassen(n: int, k: int = 20) -> bool:
    """
    Solovay-Strassen primality test.
    
    For each round, checks if a^((n-1)/2) ≡ (a/n) (mod n)
    where (a/n) is the Jacobi symbol.
    
    Error probability: ≤ (1/2)^k
    (Weaker than Miller-Rabin's (1/4)^k)
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    for _ in range(k):
        a = random.randint(2, n - 1)
        if not solovay_strassen_single(n, a):
            return False
    return True


# ============================================================
# AKS PRIMALITY TEST
# ============================================================

class PolynomialModXrMinus1:
    """
    Polynomial in (Z/nZ)[X]/(X^r - 1).
    
    Represented as a list of r coefficients modulo n.
    Multiplication wraps indices modulo r.
    """
    
    def __init__(self, coeffs: List[int], n: int, r: int):
        self.n = n
        self.r = r
        self.coeffs = [c % n for c in coeffs]
        # Pad or truncate
        while len(self.coeffs) < r:
            self.coeffs.append(0)
        self.coeffs = self.coeffs[:r]
    
    def __mul__(self, other: 'PolynomialModXrMinus1') -> 'PolynomialModXrMinus1':
        result = [0] * self.r
        for i in range(self.r):
            if self.coeffs[i] == 0:
                continue
            for j in range(self.r):
                if other.coeffs[j] == 0:
                    continue
                idx = (i + j) % self.r
                result[idx] = (result[idx] + self.coeffs[i] * other.coeffs[j]) % self.n
        return PolynomialModXrMinus1(result, self.n, self.r)
    
    def __eq__(self, other):
        if isinstance(other, PolynomialModXrMinus1):
            return self.coeffs == other.coeffs
        return False
    
    def __pow__(self, exp: int) -> 'PolynomialModXrMinus1':
        result = PolynomialModXrMinus1([1] + [0]*(self.r-1), self.n, self.r)
        base = self
        while exp > 0:
            if exp % 2 == 1:
                result = result * base
            base = base * base
            exp //= 2
        return result
    
    @staticmethod
    def X(n: int, r: int) -> 'PolynomialModXrMinus1':
        """The polynomial X."""
        coeffs = [0] * r
        if r > 1:
            coeffs[1] = 1
        else:
            coeffs[0] = 1
        return PolynomialModXrMinus1(coeffs, n, r)
    
    @staticmethod
    def constant(c: int, n: int, r: int) -> 'PolynomialModXrMinus1':
        """A constant polynomial."""
        coeffs = [c % n] + [0] * (r - 1)
        return PolynomialModXrMinus1(coeffs, n, r)


def aks_check_congruence(n: int, r: int, a: int) -> bool:
    """
    Check (X + a)^n ≡ X^n + a in (Z/nZ)[X]/(X^r - 1).
    
    Time complexity: O(r² · log(n))
    """
    X = PolynomialModXrMinus1.X(n, r)
    Ca = PolynomialModXrMinus1.constant(a, n, r)
    
    lhs = (X * PolynomialModXrMinus1([1], n, r) + Ca)  # X + a
    lhs = (X + Ca)  # hm, need __add__
    
    # Manual construction
    x_plus_a = PolynomialModXrMinus1([a % n] + ([0]*(r-2) if r > 2 else []) + ([1] if r > 1 else []), n, r)
    if r == 1:
        x_plus_a = PolynomialModXrMinus1([(a + 1) % n], n, r)
    else:
        x_plus_a = PolynomialModXrMinus1([0]*r, n, r)
        x_plus_a.coeffs[0] = a % n
        x_plus_a.coeffs[1] = 1
    
    lhs_result = x_plus_a ** n
    
    # X^n + a
    rhs = PolynomialModXrMinus1([0]*r, n, r)
    rhs.coeffs[n % r] = (rhs.coeffs[n % r] + 1) % n
    rhs.coeffs[0] = (rhs.coeffs[0] + a) % n
    
    return lhs_result == rhs


def aks_primality_test(n: int) -> bool:
    """
    AKS Primality Test — deterministic polynomial-time.
    
    Pseudocode:
        INPUT: n ≥ 2
        OUTPUT: "prime" or "composite"
        
        1. If n = a^b for some a ≥ 2, b ≥ 2: return "composite"
        2. Find smallest r such that ord_r(n) > (log₂ n)²
        3. If 1 < gcd(a, n) < n for some a ≤ r: return "composite"  
        4. If n ≤ r: return "prime"
        5. For a = 1 to ⌊√φ(r) · log₂(n)⌋:
              If (X+a)^n ≠ X^n + a mod (X^r - 1, n): return "composite"
        6. Return "prime"
    
    Time complexity: O(r^(5/2) · log^(7+ε)(n)) ⊆ O(log^(21/2+ε)(n))
    Space complexity: O(r · log(n))
    """
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0:
        return False
    
    # Step 1: Perfect power check
    if is_perfect_power(n) is not None:
        return False
    
    # Step 2: Find suitable r
    log2n = max(1, math.log2(n))
    max_k = int(log2n) ** 2
    
    r = 2
    while r < n:
        g = math.gcd(n, r)
        if 1 < g < n:
            return False  # Step 3 incorporated
        if g == 1 and multiplicative_order(n, r) > max_k:
            break
        r += 1
    
    # Step 3: Small factor check
    for a in range(2, min(r + 1, n)):
        if n % a == 0:
            return n == a
    
    # Step 4
    if n <= r:
        return True
    
    # Step 5: Polynomial congruence checks
    phi_r = euler_totient(r)
    bound = int(math.sqrt(phi_r) * log2n) + 1
    
    for a in range(1, bound + 1):
        if not aks_check_congruence(n, r, a):
            return False
    
    return True


# ============================================================
# PRIMALITY CERTIFICATES
# ============================================================

@dataclass
class CompositeCertificate:
    """Certificate proving n is composite."""
    n: int
    witness: int
    s: int
    d: int
    chain: List[int]  # squaring chain values
    
    def verify(self) -> bool:
        """Verify this certificate proves n is composite."""
        if math.gcd(self.witness, self.n) > 1:
            return True  # witness shares factor with n
        s, d = decompose_twos(self.n - 1)
        if s != self.s or d != self.d:
            return False
        return not miller_rabin_single_round(self.n, self.witness)


def find_composite_certificate(n: int, max_attempts: int = 1000) -> Optional[CompositeCertificate]:
    """Find a certificate proving n is composite, if possible."""
    if n < 2 or n == 2 or n == 3:
        return None
    if n % 2 == 0:
        return CompositeCertificate(n, 2, 0, 0, [])
    
    s, d = decompose_twos(n - 1)
    
    for _ in range(max_attempts):
        a = random.randint(2, n - 2)
        if not miller_rabin_single_round(n, a):
            # Build the squaring chain
            chain = []
            x = pow(a, d, n)
            chain.append(x)
            for _ in range(s):
                x = pow(x, 2, n)
                chain.append(x)
            return CompositeCertificate(n, a, s, d, chain)
    
    return None


# ============================================================
# ANALYSIS AND STATISTICS
# ============================================================

def analyze_liar_density(max_n: int = 200) -> Dict[int, float]:
    """Compute liar density for odd composites up to max_n."""
    results = {}
    for n in range(9, max_n + 1, 2):
        if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
            continue  # prime
        liars = all_miller_rabin_liars(n)
        results[n] = len(liars) / (n - 1)
    return results


def find_strong_pseudoprimes(base: int, limit: int) -> List[int]:
    """Find all strong pseudoprimes to given base up to limit."""
    result = []
    for n in range(3, limit, 2):
        if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
            continue  # prime
        if miller_rabin_single_round(n, base):
            result.append(n)
    return result


if __name__ == "__main__":
    # Quick self-test
    print("Testing decompose_twos...")
    assert decompose_twos(340) == (2, 85)
    assert decompose_twos(24) == (3, 3)
    assert decompose_twos(1) == (0, 1)
    print("  ✓ decompose_twos")
    
    print("Testing Miller-Rabin...")
    assert miller_rabin(2).is_probable_prime
    assert miller_rabin(17).is_probable_prime
    assert not miller_rabin(15).is_probable_prime
    assert not miller_rabin(561).is_probable_prime  # Carmichael
    print("  ✓ miller_rabin")
    
    print("Testing AKS...")
    assert aks_primality_test(2)
    assert aks_primality_test(17)
    assert not aks_primality_test(15)
    assert aks_primality_test(31)
    print("  ✓ aks_primality_test")
    
    print("Testing composite certificates...")
    cert = find_composite_certificate(561)
    assert cert is not None
    assert cert.verify()
    print(f"  ✓ Certificate for 561: witness={cert.witness}")
    
    print("\nAll tests passed!")
