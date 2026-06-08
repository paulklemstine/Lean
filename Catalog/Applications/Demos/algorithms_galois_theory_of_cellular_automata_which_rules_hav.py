"""
Algorithms for Cellular Automata Reversibility Analysis

This module implements the core algorithms for analyzing which cellular automata
rules have reversible (bijective) dynamics, computing reversibility groups,
and exploring the Galois connection between subgroups and invariant configurations.

Type-hinted implementations with clear documentation.
"""

from typing import List, Tuple, Set, Dict, FrozenSet
from itertools import product
from functools import reduce
import math


def wolfram_rule(rule_number: int, radius: int = 1) -> Dict[Tuple[int, ...], int]:
    """Convert a Wolfram rule number to a local rule function.
    
    For binary CAs of radius r, the rule maps each (2r+1)-tuple of bits
    to a single output bit. The rule number encodes this map in binary.
    
    Args:
        rule_number: Integer 0..2^(2^(2r+1))-1
        radius: Neighborhood radius (default 1 for elementary CAs)
    
    Returns:
        Dictionary mapping neighborhood tuples to output bits
    """
    width = 2 * radius + 1
    num_neighborhoods = 2 ** width
    rule: Dict[Tuple[int, ...], int] = {}
    for i in range(num_neighborhoods):
        neighborhood = tuple((i >> j) & 1 for j in range(width))
        rule[neighborhood] = (rule_number >> i) & 1
    return rule


def apply_rule_periodic(rule: Dict[Tuple[int, ...], int], config: Tuple[int, ...],
                         radius: int = 1) -> Tuple[int, ...]:
    """Apply a CA rule to a periodic configuration.
    
    Args:
        rule: Local rule as neighborhood -> output mapping
        config: Periodic configuration as tuple of bits
        radius: Neighborhood radius
    
    Returns:
        New configuration after one step
    """
    n = len(config)
    result = []
    for i in range(n):
        neighborhood = tuple(config[(i + j - radius) % n] for j in range(2 * radius + 1))
        result.append(rule[neighborhood])
    return tuple(result)


def is_reversible_periodic(rule_number: int, period: int, radius: int = 1) -> bool:
    """Check if a CA rule is reversible (bijective) on periodic configurations.
    
    Args:
        rule_number: Wolfram rule number
        period: Period of the configuration space
        radius: Neighborhood radius
    
    Returns:
        True if the global map is bijective on {0,1}^period
    """
    rule = wolfram_rule(rule_number, radius)
    configs = list(product([0, 1], repeat=period))
    images = set()
    for config in configs:
        image = apply_rule_periodic(rule, config, radius)
        if image in images:
            return False
        images.add(image)
    return len(images) == len(configs)


def find_reversible_rules(period: int, radius: int = 1) -> List[int]:
    """Find all reversible CA rules for a given period and radius.
    
    Args:
        period: Period of configuration space
        radius: Neighborhood radius
    
    Returns:
        List of Wolfram rule numbers that are reversible
    """
    num_rules = 2 ** (2 ** (2 * radius + 1))
    reversible = []
    for rule_number in range(num_rules):
        if is_reversible_periodic(rule_number, period, radius):
            reversible.append(rule_number)
    return reversible


def shift_config(config: Tuple[int, ...], k: int = 1) -> Tuple[int, ...]:
    """Shift a periodic configuration by k positions.
    
    Args:
        config: Configuration as tuple
        k: Shift amount
    
    Returns:
        Shifted configuration
    """
    n = len(config)
    return tuple(config[(i + k) % n] for i in range(n))


def complement_config(config: Tuple[int, ...]) -> Tuple[int, ...]:
    """Complement (bit-flip) a binary configuration.
    
    Args:
        config: Binary configuration
    
    Returns:
        Complemented configuration
    """
    return tuple(1 - x for x in config)


def is_shift_equivariant(perm: Dict[Tuple[int, ...], Tuple[int, ...]],
                          period: int) -> bool:
    """Check if a permutation of configurations is shift-equivariant.
    
    A permutation π is shift-equivariant iff π(σ(c)) = σ(π(c)) for all
    configurations c and shifts σ.
    
    Args:
        perm: Permutation as dictionary mapping configs to configs
        period: Period of configuration space
    
    Returns:
        True if the permutation commutes with the shift
    """
    for config in perm:
        shifted_input = shift_config(config, 1)
        # π(σ(c))
        left = perm[shifted_input]
        # σ(π(c))
        right = shift_config(perm[config], 1)
        if left != right:
            return False
    return True


def compute_shift_orbits(period: int) -> List[FrozenSet[Tuple[int, ...]]]:
    """Compute the orbits of binary configurations under the shift action.
    
    These orbits are called 'binary necklaces' — equivalence classes of
    binary strings up to cyclic rotation.
    
    Args:
        period: Length of binary strings
    
    Returns:
        List of orbits (each orbit is a frozenset of configurations)
    """
    configs = set(product([0, 1], repeat=period))
    orbits: List[FrozenSet[Tuple[int, ...]]] = []
    visited: Set[Tuple[int, ...]] = set()
    
    for config in sorted(configs):
        if config in visited:
            continue
        orbit = set()
        c = config
        for _ in range(period):
            orbit.add(c)
            visited.add(c)
            c = shift_config(c, 1)
        orbits.append(frozenset(orbit))
    
    return orbits


def necklace_count(n: int, k: int = 2) -> int:
    """Count the number of k-colored necklaces of length n using Burnside's lemma.
    
    N(k, n) = (1/n) * sum_{d|n} φ(n/d) * k^d
    
    This equals the number of shift orbits on {0,...,k-1}^n.
    
    Args:
        n: Necklace length
        k: Number of colors (default 2 for binary)
    
    Returns:
        Number of distinct necklaces
    """
    if n == 0:
        return 1
    
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            # Euler's totient of n/d
            phi_val = euler_totient(n // d)
            total += phi_val * (k ** d)
    
    return total // n


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n).
    
    Args:
        n: Positive integer
    
    Returns:
        φ(n) = number of integers 1..n coprime to n
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


def centralizer_size(cycle_type: Dict[int, int]) -> int:
    """Compute the size of the centralizer of a permutation with given cycle type.
    
    |C_{S_m}(σ)| = ∏_{d} (c_d! * d^{c_d})
    where σ has c_d cycles of length d.
    
    Args:
        cycle_type: Dictionary mapping cycle length d to count c_d
    
    Returns:
        Size of the centralizer
    """
    result = 1
    for d, c_d in cycle_type.items():
        result *= math.factorial(c_d) * (d ** c_d)
    return result


def shift_cycle_type(n: int, k: int = 2) -> Dict[int, int]:
    """Compute the cycle type of the shift permutation on {0,...,k-1}^n.
    
    The shift σ acts on k^n configurations. Its orbits (= necklaces) determine
    the cycle structure: each orbit of size d contributes a cycle of length d.
    
    Args:
        n: Configuration length
        k: Alphabet size (default 2)
    
    Returns:
        Cycle type as dictionary {cycle_length: count}
    """
    orbits = compute_shift_orbits(n)
    cycle_type: Dict[int, int] = {}
    for orbit in orbits:
        size = len(orbit)
        cycle_type[size] = cycle_type.get(size, 0) + 1
    return cycle_type


def reversibility_group_size(n: int) -> int:
    """Compute the size of the reversibility group for binary CAs on ℤ/nℤ.
    
    By the Centralizer = Reversibility theorem, this equals the centralizer
    size of the shift permutation acting on {0,1}^n.
    
    Args:
        n: Period of configuration space
    
    Returns:
        |Rev(n, {0,1})| = |C_{S_{2^n}}(σ)|
    """
    ct = shift_cycle_type(n)
    return centralizer_size(ct)


def hamming_weight(config: Tuple[int, ...]) -> int:
    """Compute the Hamming weight (number of 1s) of a binary configuration.
    
    Args:
        config: Binary configuration
    
    Returns:
        Number of 1-bits
    """
    return sum(config)


def weight_distribution(configs: List[Tuple[int, ...]]) -> Dict[int, int]:
    """Compute the distribution of Hamming weights over a set of configurations.
    
    Args:
        configs: List of binary configurations
    
    Returns:
        Dictionary mapping weight to count
    """
    dist: Dict[int, int] = {}
    for c in configs:
        w = hamming_weight(c)
        dist[w] = dist.get(w, 0) + 1
    return dist
