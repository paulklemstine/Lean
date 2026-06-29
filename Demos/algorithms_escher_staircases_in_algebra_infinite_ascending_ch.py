#!/usr/bin/env python3
"""
Algorithms for Escher Staircase computations.

Provides implementations for:
1. Chain Defect computation in Z/(n)
2. Escher Height computation between ideals
3. Ascending/descending chain enumeration
4. Ideal lattice construction
"""

from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from dataclasses import dataclass
from functools import lru_cache
import math


@dataclass
class IdealInZn:
    """Represents an ideal (d) in Z/(n), where d | n."""
    generator: int
    modulus: int

    def __post_init__(self) -> None:
        assert self.modulus % self.generator == 0, \
            f"{self.generator} does not divide {self.modulus}"

    def __le__(self, other: 'IdealInZn') -> bool:
        """(a) ⊆ (b) in Z/(n) iff b | a."""
        assert self.modulus == other.modulus
        return self.generator % other.generator == 0

    def __lt__(self, other: 'IdealInZn') -> bool:
        return self <= other and self.generator != other.generator

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, IdealInZn):
            return NotImplemented
        return self.generator == other.generator and self.modulus == other.modulus

    def __hash__(self) -> int:
        return hash((self.generator, self.modulus))

    def __repr__(self) -> str:
        if self.generator == self.modulus:
            return "(0)"
        elif self.generator == 1:
            return f"Z/{self.modulus}"
        return f"({self.generator})"


def ideal_lattice(n: int) -> List[IdealInZn]:
    """
    Construct the lattice of ideals in Z/(n).
    
    Ideals of Z/(n) are in bijection with divisors of n:
    divisor d corresponds to ideal (d)/(n) ≅ Z/(n/d).
    
    Args:
        n: The modulus
        
    Returns:
        List of all ideals, ordered by containment (ascending)
    """
    divisors = sorted([d for d in range(1, n + 1) if n % d == 0], reverse=True)
    return [IdealInZn(d, n) for d in divisors]


def chain_defect(n: int) -> int:
    """
    Compute the chain defect of Z/(n).
    
    The chain defect is the maximum length of a strictly ascending chain
    of ideals minus 1 (the number of strict inclusions).
    
    Algorithm: Find the longest path in the divisibility DAG of n's divisors.
    
    Time complexity: O(d(n)^2) where d(n) is the number of divisors.
    
    Args:
        n: The modulus
        
    Returns:
        Chain defect value
    """
    ideals = ideal_lattice(n)
    
    # Dynamic programming on the DAG
    memo: Dict[int, int] = {}
    
    def longest_chain_from(idx: int) -> int:
        if idx in memo:
            return memo[idx]
        best = 1  # Just this ideal alone
        for j in range(len(ideals)):
            if j != idx and ideals[idx] < ideals[j]:
                best = max(best, 1 + longest_chain_from(j))
        memo[idx] = best
        return best
    
    max_len = max(longest_chain_from(i) for i in range(len(ideals)))
    return max_len - 1  # Defect = number of strict inclusions


def escher_height(n: int, gen_I: int, gen_J: int) -> int:
    """
    Compute the Escher Height between ideals (gen_I) and (gen_J) in Z/(n).
    
    This is the maximum length of a strictly ascending chain from (gen_I)
    to (gen_J), including both endpoints.
    
    Args:
        n: The modulus
        gen_I: Generator of the smaller ideal (gen_J | gen_I)
        gen_J: Generator of the larger ideal
        
    Returns:
        Maximum chain length (number of ideals in the chain)
    """
    assert n % gen_I == 0 and n % gen_J == 0
    assert gen_I % gen_J == 0, f"({gen_I}) is not contained in ({gen_J})"
    
    # Find all ideals between (gen_I) and (gen_J)
    between: List[int] = []
    for d in range(1, n + 1):
        if n % d == 0 and gen_I % d == 0 and d % gen_J == 0:
            between.append(d)
    
    # Longest chain from gen_I to gen_J
    memo: Dict[int, int] = {}
    
    def longest_to_target(d: int) -> int:
        if d == gen_J:
            return 1
        if d in memo:
            return memo[d]
        best = 0
        for d2 in between:
            if d != d2 and d % d2 == 0:
                result = longest_to_target(d2)
                if result > 0:
                    best = max(best, 1 + result)
        memo[d] = best
        return best
    
    return longest_to_target(gen_I)


def enumerate_maximal_chains(n: int) -> List[List[IdealInZn]]:
    """
    Enumerate all maximal ascending chains of ideals in Z/(n).
    
    A maximal chain is one where no ideal can be inserted between
    consecutive elements.
    
    Args:
        n: The modulus
        
    Returns:
        List of maximal chains (each chain is a list of ideals)
    """
    ideals = ideal_lattice(n)
    
    # Build Hasse diagram (cover relations)
    covers: Dict[int, List[int]] = {i: [] for i in range(len(ideals))}
    for i in range(len(ideals)):
        for j in range(len(ideals)):
            if i != j and ideals[i] < ideals[j]:
                # Check if j covers i (no ideal strictly between them)
                is_cover = True
                for k in range(len(ideals)):
                    if k != i and k != j and ideals[i] < ideals[k] and ideals[k] < ideals[j]:
                        is_cover = False
                        break
                if is_cover:
                    covers[i].append(j)
    
    # Find all maximal chains using DFS
    chains: List[List[IdealInZn]] = []
    
    def dfs(idx: int, current_chain: List[int]) -> None:
        if not covers[idx]:  # No covers = maximal element
            chains.append([ideals[i] for i in current_chain])
            return
        for j in covers[idx]:
            dfs(j, current_chain + [j])
    
    # Start from minimal elements (those with no predecessors)
    min_elements = []
    for i in range(len(ideals)):
        is_min = True
        for j in range(len(ideals)):
            if j != i and ideals[j] < ideals[i]:
                is_min = False
                break
        if is_min:
            min_elements.append(i)
    
    for m in min_elements:
        dfs(m, [m])
    
    return chains


def descending_chain_intersection(generators: List[int]) -> int:
    """
    Compute the intersection of a descending chain of ideals in Z.
    
    For ideals (a_1) ⊇ (a_2) ⊇ ... in Z, the intersection is (lcm(a_1, a_2, ...)).
    
    Args:
        generators: List of generators [a_1, a_2, ...] where a_i | a_{i+1}
        
    Returns:
        Generator of the intersection (0 if the lcm diverges)
    """
    running_lcm = generators[0]
    for g in generators[1:]:
        running_lcm = math.lcm(running_lcm, g)
    return running_lcm


def is_escher_chain_possible(generators: List[int]) -> Tuple[bool, str]:
    """
    Check whether a descending chain in Z could be an Escher chain
    (i.e., has nontrivial intersection).
    
    Args:
        generators: List of generators of the descending chain
        
    Returns:
        (is_possible, explanation)
    """
    if len(generators) < 2:
        return False, "Chain too short"
    
    # Verify descending
    for i in range(len(generators) - 1):
        if generators[i + 1] % generators[i] != 0:
            return False, f"({generators[i]}) does not contain ({generators[i+1]})"
    
    # Verify strict descent
    for i in range(len(generators) - 1):
        if generators[i] == generators[i + 1]:
            return False, f"Chain is not strictly descending at index {i}"
    
    # Compute intersection (lcm)
    lcm = descending_chain_intersection(generators)
    
    if lcm == 0:
        return False, "Intersection is trivial (generators grow without bound)"
    
    # In a finite chain, lcm is always finite
    return False, f"Intersection = ({lcm}), but in Z (a PID), extending to an infinite strictly descending chain forces intersection to (0)"


def chain_defect_from_prime_factorization(prime_powers: List[int]) -> int:
    """
    Compute chain defect of Z/(p1^a1 * p2^a2 * ... * pk^ak).
    
    The chain defect equals sum(a_i), which is the total number of
    prime factors counted with multiplicity.
    
    This follows because the ideal lattice of Z/(n) is a product of chains,
    and the longest chain in a product of chains of lengths a_1, ..., a_k
    has length a_1 + ... + a_k.
    
    Args:
        prime_powers: List of prime power exponents [a_1, a_2, ..., a_k]
        
    Returns:
        Chain defect = sum of exponents
    """
    return sum(prime_powers)


if __name__ == "__main__":
    print("Chain Defect Examples:")
    for n in [6, 12, 24, 30, 60, 120, 360]:
        cd = chain_defect(n)
        print(f"  Z/({n}): chain defect = {cd}")
    
    print("\nEscher Height Examples (in Z/(360)):")
    pairs = [(360, 1), (180, 1), (60, 1), (360, 6)]
    for a, b in pairs:
        if 360 % a == 0 and 360 % b == 0 and a % b == 0:
            eh = escher_height(360, a, b)
            print(f"  ({a}) → ({b}): height = {eh}")
    
    print("\nMaximal Chains in Z/(12):")
    chains = enumerate_maximal_chains(12)
    for i, chain in enumerate(chains):
        print(f"  Chain {i+1}: {' ⊂ '.join(str(ideal) for ideal in chain)}")
    
    print("\nDescending Chain Analysis:")
    gens = [2, 4, 8, 16, 32, 64]
    possible, explanation = is_escher_chain_possible(gens)
    print(f"  Chain: {' ⊃ '.join(f'({g})' for g in gens)}")
    print(f"  Escher chain possible? {possible}")
    print(f"  Reason: {explanation}")
    
    print("\nChain Defect from Factorization:")
    examples = [
        ("2^3 * 3^2 * 5", [3, 2, 1]),
        ("2^4 * 3", [4, 1]),
        ("2 * 3 * 5 * 7", [1, 1, 1, 1]),
    ]
    for name, powers in examples:
        cd = chain_defect_from_prime_factorization(powers)
        print(f"  Z/({name}): chain defect = {cd} = {' + '.join(map(str, powers))}")
