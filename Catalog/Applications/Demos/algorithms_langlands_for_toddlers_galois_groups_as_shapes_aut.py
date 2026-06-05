#!/usr/bin/env python3
"""
Algorithms for the Langlands Mirror: Shape-Color Duality

Type-hinted implementations of the core algorithms:
1. Kronecker/Jacobi symbol computation
2. Quadratic discriminant computation
3. Prime splitting classification
4. Character sum computation
5. Mirror matching verification
"""

from typing import List, Dict, Tuple, Set, Optional
from math import gcd, isqrt
from dataclasses import dataclass
from enum import Enum


class SplittingType(Enum):
    """How a prime interacts with a quadratic field."""
    SPLIT = 1       # χ(p) = +1: p splits into two primes
    INERT = -1      # χ(p) = -1: p remains prime
    RAMIFIED = 0    # χ(p) = 0:  p divides the discriminant


@dataclass
class QuadraticField:
    """A quadratic field Q(√d) with its arithmetic data."""
    d: int                    # squarefree integer
    discriminant: int         # fundamental discriminant D
    conductor: int            # conductor = |D|
    character: Dict[int, int] # Kronecker character values at small integers


@dataclass
class LanglandsMirror:
    """A concrete Langlands Mirror for quadratic fields.
    
    Shapes: squarefree integers d
    Colors: Kronecker character sequences
    Probes: primes
    Trace: Jacobi symbol J(d, p)
    """
    shapes: List[int]                           # squarefree integers
    colors: Dict[int, List[int]]               # d -> character values at primes
    probe_primes: List[int]                     # the primes used as probes
    matching: Dict[int, Tuple[int, ...]]        # d -> color tuple


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n).
    
    Algorithm: Binary Jacobi symbol algorithm.
    Time complexity: O(log²(n))
    
    Args:
        a: integer numerator
        n: positive odd integer denominator
    
    Returns:
        -1, 0, or 1
    """
    if n <= 0 or n % 2 == 0:
        if n == 1:
            return 1
        if n == 0:
            return 0
        raise ValueError(f"n must be positive odd, got {n}")
    if n == 1:
        return 1

    a = a % n
    if a == 0:
        return 0 if n > 1 else 1

    result: int = 1
    while a != 0:
        # Remove factors of 2 from a
        while a % 2 == 0:
            a //= 2
            # Second supplement: (2/n) = (-1)^((n²-1)/8)
            if n % 8 in (3, 5):
                result = -result
        # Quadratic reciprocity: swap a and n
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n

    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    """Compute the Kronecker symbol (d/n), extending Jacobi to even n.
    
    Args:
        d: discriminant-like integer
        n: positive integer (can be even)
    
    Returns:
        -1, 0, or 1
    """
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1

    result: int = 1

    # Factor out 2 from n
    v: int = 0
    temp_n: int = n
    while temp_n % 2 == 0:
        v += 1
        temp_n //= 2

    if v > 0:
        if d % 2 == 0:
            return 0
        if v % 2 == 1:
            if d % 8 in (3, 5):
                result = -1

    if temp_n == 1:
        return result

    return result * jacobi_symbol(d, temp_n)


def quad_discriminant(d: int) -> int:
    """Compute the fundamental discriminant of Q(√d).
    
    Args:
        d: squarefree integer
    
    Returns:
        D = d if d ≡ 1 (mod 4), else D = 4d
    """
    if d % 4 == 1:
        return d
    return 4 * d


def classify_prime(d: int, p: int) -> SplittingType:
    """Classify how prime p behaves in Q(√d).
    
    Args:
        d: squarefree integer defining the field
        p: a prime number
    
    Returns:
        SplittingType indicating split/inert/ramified
    """
    val = kronecker_symbol(d, p)
    if val == 1:
        return SplittingType.SPLIT
    elif val == -1:
        return SplittingType.INERT
    else:
        return SplittingType.RAMIFIED


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def build_quadratic_field(d: int, num_primes: int = 20) -> QuadraticField:
    """Construct a QuadraticField object with character data.
    
    Args:
        d: squarefree integer
        num_primes: how many character values to compute
    
    Returns:
        QuadraticField with populated character dictionary
    """
    D = quad_discriminant(d)
    primes = sieve_primes(num_primes * 5)[:num_primes]
    character = {n: kronecker_symbol(d, n) for n in range(1, abs(D) + 1)}
    return QuadraticField(d=d, discriminant=D, conductor=abs(D), character=character)


def build_mirror(squarefree_list: List[int], num_probes: int = 50) -> LanglandsMirror:
    """Construct the quadratic Langlands Mirror.
    
    Args:
        squarefree_list: list of squarefree integers (shapes)
        num_probes: number of prime probes to use
    
    Returns:
        LanglandsMirror with shapes, colors, and matching
    """
    primes = sieve_primes(num_probes * 5)[:num_probes]

    colors: Dict[int, List[int]] = {}
    matching: Dict[int, Tuple[int, ...]] = {}

    for d in squarefree_list:
        char_values = [kronecker_symbol(d, p) for p in primes]
        colors[d] = char_values
        matching[d] = tuple(char_values)

    return LanglandsMirror(
        shapes=squarefree_list,
        colors=colors,
        probe_primes=primes,
        matching=matching
    )


def verify_mirror_injectivity(mirror: LanglandsMirror) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify that the mirror matching is injective.
    
    Returns:
        (True, None) if injective, (False, (d1, d2)) if not
    """
    seen: Dict[Tuple[int, ...], int] = {}
    for d in mirror.shapes:
        color = mirror.matching[d]
        if color in seen:
            return False, (seen[color], d)
        seen[color] = d
    return True, None


def character_sum(d: int, N: int) -> int:
    """Compute the partial character sum ∑_{n=1}^{N} χ_d(n).
    
    Args:
        d: squarefree integer
        N: upper limit
    
    Returns:
        The character sum
    """
    return sum(kronecker_symbol(d, n) for n in range(1, N + 1))


def class_number_formula(d: int) -> float:
    """Compute h(d) using Dirichlet's class number formula (for d < 0).
    
    h(d) = -(1/D) · ∑_{a=1}^{|D|-1} a · χ_D(a)
    
    Args:
        d: negative squarefree integer
    
    Returns:
        The class number (should be a positive integer)
    """
    D = quad_discriminant(d)
    if D >= 0:
        raise ValueError("Class number formula requires negative discriminant")
    char_sum = sum(a * kronecker_symbol(D, a) for a in range(1, abs(D)))
    w = 6 if D == -3 else (4 if D == -4 else 2)
    return w * abs(char_sum) / (2 * abs(D))


def verify_quadratic_reciprocity(p: int, q: int) -> bool:
    """Verify quadratic reciprocity for odd primes p, q.
    
    J(p,q) · J(q,p) = (-1)^((p-1)/2 · (q-1)/2)
    """
    if p == 2 or q == 2 or p == q:
        raise ValueError("Need distinct odd primes")
    lhs = jacobi_symbol(p, q) * jacobi_symbol(q, p)
    rhs = (-1) ** (((p - 1) // 2) * ((q - 1) // 2))
    return lhs == rhs


def split_prime_density(d: int, N: int) -> float:
    """Compute the density of split primes up to N.
    
    Returns the ratio of split primes to total (non-ramified) primes.
    By Chebotarev, this should approach 1/2 for squarefree d ≠ 0, 1.
    """
    D = quad_discriminant(d)
    primes = sieve_primes(N)
    good_primes = [p for p in primes if D % p != 0]
    if not good_primes:
        return 0.0
    split_count = sum(1 for p in good_primes if kronecker_symbol(d, p) == 1)
    return split_count / len(good_primes)


if __name__ == "__main__":
    # Build and verify the mirror for squarefree d in [-15, 15]
    shapes = [d for d in range(-15, 16) if d != 0 and d != 1
              and all(d % (p*p) != 0 for p in range(2, abs(d)+1) if p*p <= abs(d))]

    print(f"Building mirror with {len(shapes)} shapes...")
    mirror = build_mirror(shapes, num_probes=30)

    injective, collision = verify_mirror_injectivity(mirror)
    print(f"Mirror injective: {injective}")
    if not injective and collision:
        print(f"  Collision: d={collision[0]} and d={collision[1]} have same color")

    # Class number formula
    print("\nClass numbers via Dirichlet formula:")
    for d in [-1, -2, -3, -5, -6, -7, -10, -11, -13]:
        h = class_number_formula(d)
        print(f"  h({d}) = {h:.0f}")
