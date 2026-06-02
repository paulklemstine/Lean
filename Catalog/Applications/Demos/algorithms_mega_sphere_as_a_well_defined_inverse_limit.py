#!/usr/bin/env python3
"""
Algorithms for Mega-Sphere computations.

Type-hinted implementations of the key algorithms:
1. Bernoulli number computation (recursive)
2. Euler characteristic with resonance short-circuit
3. Convolution via closed-form formula
4. Mega-Sphere inverse limit projection
"""
from fractions import Fraction
from typing import Callable, Dict, List, Optional, Tuple


# --- Algorithm 1: Bernoulli Numbers ---

def compute_bernoulli_prime(n: int, cache: Optional[Dict[int, Fraction]] = None) -> Fraction:
    """
    Compute B'_n using the recursive Bernoulli formula.
    
    B'_0 = 1
    B'_n = 1 - sum_{k=0}^{n-1} C(n,k)/(n-k+1) * B'_k
    
    Time complexity: O(n^2) with memoization.
    Space complexity: O(n) for cache.
    """
    if cache is None:
        cache = {}
    if n in cache:
        return cache[n]
    if n == 0:
        cache[0] = Fraction(1)
        return Fraction(1)
    
    s = Fraction(0)
    binom = 1
    for k in range(n):
        if k > 0:
            binom = binom * (n - k + 1) // k
        s += Fraction(binom, n - k + 1) * compute_bernoulli_prime(k, cache)
    
    result = Fraction(1) - s
    cache[n] = result
    return result


# --- Algorithm 2: Euler Characteristic with Resonance ---

def euler_char_sphere(n: int) -> int:
    """
    Euler characteristic of S^n: chi(S^n) = 1 + (-1)^n.
    
    Returns 2 for even n, 0 for odd n.
    Time complexity: O(1).
    """
    return 0 if n % 2 == 1 else 2


def bernoulli_sphere_weight(n: int, cache: Optional[Dict[int, Fraction]] = None) -> Fraction:
    """
    Bernoulli-sphere weight w(n) = B'_n * chi(S^n).
    
    Uses resonance theorem: returns 0 immediately for odd n
    without computing B'_n (short-circuit optimization).
    
    Time complexity: O(1) for odd n, O(n^2) for even n.
    """
    if n % 2 == 1:
        return Fraction(0)  # Resonance theorem
    return compute_bernoulli_prime(n, cache) * 2  # chi(S^n) = 2 for even n


# --- Algorithm 3: Sphere Convolution ---

def sphere_pairing(j: int, k: int) -> int:
    """
    Sphere pairing P(j, k) = chi(S^j) * chi(S^k).
    
    Returns 4 if both j, k even; 0 otherwise.
    Time complexity: O(1).
    """
    if j % 2 == 1 or k % 2 == 1:
        return 0
    return 4


def sphere_convolution(n: int) -> int:
    """
    Sphere convolution C(n) = sum_{j=0}^{n} P(j, n-j).
    
    Uses closed-form formula:
    - C(n) = 0 for odd n (even concentration theorem)
    - C(2m) = 4(m+1) for even n = 2m
    
    Time complexity: O(1).
    """
    if n % 2 == 1:
        return 0  # Even concentration theorem
    m = n // 2
    return 4 * (m + 1)


# --- Algorithm 4: Mega-Sphere Inverse Limit ---

class MegaSphereSystem:
    """
    The sphere invariant inverse system.
    
    At level n, the object is a function Fin(n+1) -> Z
    recording Euler characteristics of S^0 through S^n.
    The bonding map truncates the last entry.
    """
    
    @staticmethod
    def obj(n: int) -> List[int]:
        """Level-n object: [chi(S^0), ..., chi(S^n)]."""
        return [euler_char_sphere(k) for k in range(n + 1)]
    
    @staticmethod
    def bond(n: int, data: List[int]) -> List[int]:
        """Bonding map: truncate from level n+1 to level n."""
        return data[:n + 1]
    
    @staticmethod
    def canonical_element() -> Callable[[int], List[int]]:
        """
        The Mega-Sphere: the canonical element of the inverse limit.
        Returns a function n -> obj(n) compatible with all bonding maps.
        """
        return MegaSphereSystem.obj
    
    @staticmethod
    def verify_compatibility(max_level: int = 20) -> bool:
        """Verify the compatibility condition for the first max_level levels."""
        elem = MegaSphereSystem.canonical_element()
        for n in range(max_level):
            projected = MegaSphereSystem.bond(n, elem(n + 1))
            direct = elem(n)
            if projected != direct:
                return False
        return True


# --- Algorithm 5: Cumulative Weight Analysis ---

def cumulative_weight_sequence(max_n: int) -> List[Tuple[int, Fraction]]:
    """
    Compute the cumulative even-indexed Bernoulli-sphere weights.
    
    Returns [(N, sum_{k=0}^{N} w(2k))] for N = 0, ..., max_n.
    """
    cache: Dict[int, Fraction] = {}
    result: List[Tuple[int, Fraction]] = []
    running_sum = Fraction(0)
    
    for N in range(max_n + 1):
        running_sum += bernoulli_sphere_weight(2 * N, cache)
        result.append((N, running_sum))
    
    return result


if __name__ == "__main__":
    # Verify all algorithms
    print("Algorithm Verification:")
    
    # Bernoulli numbers
    cache: Dict[int, Fraction] = {}
    print(f"B'_0 = {compute_bernoulli_prime(0, cache)} (expected 1)")
    print(f"B'_1 = {compute_bernoulli_prime(1, cache)} (expected 1/2)")
    print(f"B'_2 = {compute_bernoulli_prime(2, cache)} (expected 1/6)")
    print(f"B'_4 = {compute_bernoulli_prime(4, cache)} (expected -1/30)")
    
    # Resonance
    print(f"\nResonance check: w(3) = {bernoulli_sphere_weight(3)} (expected 0)")
    print(f"w(0) = {bernoulli_sphere_weight(0)} (expected 2)")
    print(f"w(2) = {bernoulli_sphere_weight(2)} (expected 1/3)")
    
    # Convolution
    print(f"\nConvolution: C(0) = {sphere_convolution(0)} (expected 4)")
    print(f"C(1) = {sphere_convolution(1)} (expected 0)")
    print(f"C(4) = {sphere_convolution(4)} (expected 12)")
    
    # Mega-Sphere
    print(f"\nMega-Sphere compatibility: {MegaSphereSystem.verify_compatibility()}")
    
    # Cumulative weights
    print("\nCumulative weights:")
    for N, s in cumulative_weight_sequence(8):
        print(f"  N={N}: {s} = {float(s):.6f}")
