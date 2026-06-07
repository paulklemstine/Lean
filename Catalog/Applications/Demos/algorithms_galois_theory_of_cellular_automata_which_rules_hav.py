#!/usr/bin/env python3
"""
Algorithms for Cellular Automata Reversibility Group Computation

Type-hinted implementations of the core algorithms from the
Galois Theory of Cellular Automata research.
"""

import math
from collections import Counter
from typing import Dict, FrozenSet, List, Set, Tuple


Config = Tuple[int, ...]


def shift_config(config: Config, k: int = 1) -> Config:
    """Shift a periodic configuration by k positions.
    
    Args:
        config: A tuple of alphabet values (binary: 0 or 1)
        k: Number of positions to shift
    
    Returns:
        The shifted configuration
    """
    n = len(config)
    return tuple(config[(i + k) % n] for i in range(n))


def compute_shift_orbit(config: Config) -> FrozenSet[Config]:
    """Compute the complete shift orbit of a configuration.
    
    The orbit is the set {σ^k(c) : k = 0, ..., n-1} where σ is the shift.
    The orbit size always divides n (the period).
    
    Args:
        config: A periodic configuration
    
    Returns:
        The orbit as a frozenset of configurations
    """
    orbit: Set[Config] = set()
    c = config
    n = len(config)
    for _ in range(n):
        orbit.add(c)
        c = shift_config(c)
    return frozenset(orbit)


def orbit_decomposition(n: int, alphabet_size: int = 2) -> List[FrozenSet[Config]]:
    """Decompose the configuration space into shift orbits.
    
    Uses iterative exploration to partition all |alphabet|^n configurations
    into disjoint shift orbits.
    
    Args:
        n: Period length
        alphabet_size: Size of the alphabet (default 2 for binary)
    
    Returns:
        List of orbits, each a frozenset of configurations
    
    Time complexity: O(|alphabet|^n * n)
    """
    from itertools import product as cart_product
    
    configs = list(cart_product(range(alphabet_size), repeat=n))
    seen: Set[Config] = set()
    orbits: List[FrozenSet[Config]] = []
    
    for c in configs:
        if c not in seen:
            orb = compute_shift_orbit(c)
            seen |= orb
            orbits.append(orb)
    
    return orbits


def orbit_type(n: int, alphabet_size: int = 2) -> Dict[int, int]:
    """Compute the orbit type: maps orbit_size -> count.
    
    The orbit type is the complete invariant for the isomorphism type
    of the reversibility (centralizer) group.
    
    Args:
        n: Period length
        alphabet_size: Alphabet size
    
    Returns:
        Dictionary mapping each orbit size d to its count a_d
    """
    orbits = orbit_decomposition(n, alphabet_size)
    return dict(Counter(len(orb) for orb in orbits))


def centralizer_order_from_type(orbit_counts: Dict[int, int]) -> int:
    """Compute the centralizer order from the orbit type.
    
    Formula: |C(σ)| = ∏_{d} d^{a_d} · a_d!
    
    where a_d is the number of orbits of size d.
    
    This formula comes from the wreath product decomposition:
    C(σ) ≅ ∏_{d} (ℤ/dℤ ≀ S_{a_d})
    
    Args:
        orbit_counts: Map from orbit size to count
    
    Returns:
        The order of the centralizer group
    """
    result = 1
    for d, a_d in orbit_counts.items():
        if d > 0:
            result *= (d ** a_d) * math.factorial(a_d)
    return result


def necklace_count_burnside(n: int, k: int = 2) -> int:
    """Count necklaces of length n with k colors using Burnside's lemma.
    
    N(n, k) = (1/n) ∑_{i=0}^{n-1} k^{gcd(i, n)}
    
    This equals the number of shift orbits in the configuration space {0,...,k-1}^n.
    
    Args:
        n: Necklace length
        k: Number of colors
    
    Returns:
        Number of distinct necklaces
    """
    if n == 0:
        return 0
    total = sum(k ** math.gcd(i, n) for i in range(n))
    return total // n


def is_reversible_elementary_ca(rule_number: int) -> bool:
    """Check if an elementary CA rule (r=1, binary) is reversible.
    
    A rule is reversible if its local function, when applied globally
    to periodic configurations of every period, is a bijection.
    
    For elementary CAs, the reversible rules are: 15, 51, 85, 170, 204, 240.
    These are exactly the rules whose local map is a permutation of
    neighborhoods that commutes with the shift.
    
    Args:
        rule_number: Wolfram rule number (0-255)
    
    Returns:
        True if the rule defines a reversible CA
    """
    return rule_number in {15, 51, 85, 170, 204, 240}


def apply_elementary_ca(rule_number: int, config: Config) -> Config:
    """Apply an elementary CA rule to a periodic configuration.
    
    Args:
        rule_number: Wolfram rule number (0-255)
        config: Binary configuration (tuple of 0s and 1s)
    
    Returns:
        The next-generation configuration
    """
    n = len(config)
    result = []
    for i in range(n):
        # Extract the 3-cell neighborhood
        left = config[(i - 1) % n]
        center = config[i]
        right = config[(i + 1) % n]
        neighborhood = (left << 2) | (center << 1) | right
        # Apply rule
        result.append((rule_number >> neighborhood) & 1)
    return tuple(result)


def verify_reversibility(rule_number: int, max_period: int = 8) -> bool:
    """Verify reversibility of a CA rule by testing bijectivity on all periods.
    
    Args:
        rule_number: Wolfram rule number
        max_period: Maximum period to test
    
    Returns:
        True if the rule is bijective on all tested periods
    """
    from itertools import product as cart_product
    
    for n in range(1, max_period + 1):
        configs = list(cart_product([0, 1], repeat=n))
        images = [apply_elementary_ca(rule_number, c) for c in configs]
        if len(set(images)) != len(configs):
            return False
    return True


if __name__ == "__main__":
    # Demonstrate the algorithms
    print("Orbit types for binary CAs:")
    for n in range(1, 7):
        ot = orbit_type(n)
        co = centralizer_order_from_type(ot)
        print(f"  n={n}: type={ot}, |G|={co}, necklaces={necklace_count_burnside(n)}")
    
    print("\nReversible elementary CA rules:")
    for r in range(256):
        if verify_reversibility(r, max_period=6):
            print(f"  Rule {r} is reversible")
