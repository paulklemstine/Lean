#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Chain Invariants in Divisibility Lattices

Type-hinted implementations of the key algorithms from the research.
"""

from collections import Counter
from itertools import permutations
from math import factorial, log2, prod
from typing import List, Tuple, Set, Dict, Optional


def factorize(n: int) -> List[int]:
    """
    Return the sorted list of prime factors of n with multiplicity.
    
    Examples:
        >>> factorize(12)
        [2, 2, 3]
        >>> factorize(60)
        [2, 2, 3, 5]
    """
    if n <= 1:
        return []
    factors: List[int] = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n: int) -> int:
    """
    Ω(n): the number of prime factors of n, counted with multiplicity.
    
    By the Chain Rank Theorem, this equals the maximum length of a
    divisibility chain from 1 to n.
    
    Examples:
        >>> big_omega(12)
        3
        >>> big_omega(1)
        0
    """
    return len(factorize(n))


def sopfr_func(n: int) -> int:
    """
    sopfr(n): sum of prime factors of n with repetition.
    
    By the Spectrum Sum Rigidity Theorem, this equals the spectrum sum
    of every maximal divisibility chain from 1 to n.
    
    Examples:
        >>> sopfr_func(12)
        7
        >>> sopfr_func(60)
        12
    """
    return sum(factorize(n))


def chain_spectrum(chain: List[int]) -> List[int]:
    """
    Compute the spectrum of a divisibility chain: the list of consecutive
    quotients chain[i+1] / chain[i].
    
    Precondition: each chain[i] divides chain[i+1].
    
    Examples:
        >>> chain_spectrum([1, 2, 4, 12])
        [2, 2, 3]
    """
    return [chain[i + 1] // chain[i] for i in range(len(chain) - 1)]


def chain_defect(n: int, chain: List[int]) -> int:
    """
    Compute the defect of a divisibility chain from 1 to n.
    
    The defect is Ω(n) - len(chain), where len is the number of steps.
    A chain is maximal iff its defect is 0.
    
    Examples:
        >>> chain_defect(12, [1, 2, 4, 12])
        0
        >>> chain_defect(12, [1, 2, 12])
        1
    """
    return big_omega(n) - (len(chain) - 1)


def enumerate_maximal_chains(n: int) -> List[List[int]]:
    """
    Enumerate all maximal divisibility chains from 1 to n.
    
    Each maximal chain corresponds to a distinct permutation of the
    prime factorization list. The chain is built by taking partial products.
    
    Returns chains sorted lexicographically.
    
    Examples:
        >>> enumerate_maximal_chains(12)
        [[1, 2, 4, 12], [1, 2, 6, 12], [1, 3, 6, 12]]
    """
    factors = factorize(n)
    if not factors:
        return [[1]] if n == 1 else []
    
    chains: Set[Tuple[int, ...]] = set()
    for perm in set(permutations(factors)):
        chain = [1]
        for p in perm:
            chain.append(chain[-1] * p)
        chains.add(tuple(chain))
    
    return [list(c) for c in sorted(chains)]


def count_maximal_chains(n: int) -> int:
    """
    Count the number of maximal divisibility chains from 1 to n
    using the multinomial coefficient formula (Chain Count Conjecture).
    
    For n = p₁^e₁ · ... · pₖ^eₖ, the count is Ω(n)! / (e₁! · ... · eₖ!).
    
    Examples:
        >>> count_maximal_chains(12)  # 3!/(2!·1!) = 3
        3
        >>> count_maximal_chains(30)  # 3!/1!1!1! = 6
        6
    """
    factors = factorize(n)
    total = len(factors)
    counts = Counter(factors)
    denom = prod(factorial(e) for e in counts.values())
    return factorial(total) // denom


def verify_spectrum_rigidity(n: int) -> Tuple[bool, int]:
    """
    Verify Spectrum Sum Rigidity for a given n.
    
    Returns (is_rigid, spectrum_sum) where is_rigid is True if all maximal
    chains have the same spectrum sum, and spectrum_sum is that common value.
    
    Examples:
        >>> verify_spectrum_rigidity(12)
        (True, 7)
    """
    chains = enumerate_maximal_chains(n)
    if not chains:
        return (True, 0)
    
    sums = set()
    for chain in chains:
        spec = chain_spectrum(chain)
        sums.add(sum(spec))
    
    expected = sopfr_func(n)
    return (sums == {expected}, expected)


def verify_exponential_growth(chain: List[int]) -> bool:
    """
    Verify that chain[k] ≥ 2^k for all k.
    
    Examples:
        >>> verify_exponential_growth([1, 2, 4, 12])
        True
    """
    return all(chain[k] >= 2**k for k in range(len(chain)))


def omega_depth(n: int) -> int:
    """
    Compute the Omega depth D(n): number of iterations of Ω needed to
    reach a value ≤ 1.
    
    D(n) ≤ log*(n) is conjectured.
    
    Examples:
        >>> omega_depth(1)
        0
        >>> omega_depth(16)  # Ω(16)=4, Ω(4)=2, Ω(2)=1
        3
    """
    depth = 0
    while n > 1:
        n = big_omega(n)
        depth += 1
    return depth


def enumerate_all_chains(n: int) -> List[List[int]]:
    """
    Enumerate ALL divisibility chains from 1 to n (not just maximal).
    Uses recursive construction.
    
    Warning: exponential in the number of divisors of n.
    """
    if n == 1:
        return [[1]]
    
    chains: List[List[int]] = []
    # For each proper divisor d of n (other than n itself)
    for d in range(1, n):
        if n % d == 0 and d != n:
            # Recursively find chains from 1 to d
            for sub_chain in enumerate_all_chains(d):
                chains.append(sub_chain + [n])
    
    return chains


def average_chain_defect(n: int) -> float:
    """
    Compute the average defect over all divisibility chains from 1 to n.
    
    Warning: expensive for large n (exponential in number of divisors).
    """
    chains = enumerate_all_chains(n)
    if not chains:
        return 0.0
    
    om = big_omega(n)
    total_defect = sum(om - (len(c) - 1) for c in chains)
    return total_defect / len(chains)


if __name__ == "__main__":
    # Quick tests
    print("factorize(360) =", factorize(360))
    print("Ω(360) =", big_omega(360))
    print("sopfr(360) =", sopfr_func(360))
    print("Maximal chains from 1 to 12:", enumerate_maximal_chains(12))
    print("Chain count for 360:", count_maximal_chains(360))
    print("Spectrum rigidity for 60:", verify_spectrum_rigidity(60))
    print("Omega depth of 65536:", omega_depth(65536))
