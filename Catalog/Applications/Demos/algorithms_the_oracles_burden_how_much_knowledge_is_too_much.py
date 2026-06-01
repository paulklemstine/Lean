"""
Oracle Hierarchy: Algorithms for Computing Oracle Power and Density

This module implements the key algorithms from the oracle hierarchy theory:
- Oracle jump iteration
- Oracle power measurement
- Density computation
- Hierarchy visualization data generation

Type-hinted implementations matching the Lean 4 formalizations.
"""

from typing import Set, Callable, List, Tuple, Optional
from dataclasses import dataclass
from fractions import Fraction


@dataclass
class OracleJump:
    """An oracle jump operator: maps a set of 'provable sentences' to a larger set."""
    jump: Callable[[Set[int]], Set[int]]

    def iter(self, base: Set[int], n: int) -> Set[int]:
        """Apply the jump operator n times starting from base."""
        result = set(base)
        for _ in range(n):
            result = self.jump(result)
        return result


@dataclass
class OracleHierarchy:
    """A base theory with a jump operator, defining the full hierarchy."""
    base: Set[int]
    jump: OracleJump

    def level(self, n: int) -> Set[int]:
        """The theory at level n."""
        return self.jump.iter(self.base, n)

    def limit(self, max_level: int) -> Set[int]:
        """Approximate the limit theory up to max_level."""
        result: Set[int] = set()
        for n in range(max_level + 1):
            result |= self.level(n)
        return result


def oracle_power(theory: Set[int], N: int) -> int:
    """Count provable sentences in [0, N)."""
    return len({x for x in range(N) if x in theory})


def oracle_density(theory: Set[int], N: int) -> Fraction:
    """Density of provable sentences in [0, N)."""
    if N == 0:
        return Fraction(0)
    return Fraction(oracle_power(theory, N), N)


def consistency_witness_jump(base: Set[int], witness_fn: Callable[[int], int]) -> OracleJump:
    """Build a jump operator from a witness function.

    The witness function maps level n to the 'consistency sentence' for level n.
    Each jump adds the consistency sentence of the current level.
    """
    # We need to track the level internally
    level_counter = [0]

    def jump(S: Set[int]) -> Set[int]:
        result = set(S)
        w = witness_fn(level_counter[0])
        result.add(w)
        level_counter[0] += 1
        return result

    return OracleJump(jump=jump)


def simple_godel_witness(n: int) -> int:
    """A simple Gödel-numbering scheme: map level n to a unique 'consistency sentence'.

    We use the formula w(n) = 2*n + 1 (odd numbers) to ensure witnesses
    don't collide with a base theory of even numbers.
    """
    return 2 * n + 1


def build_indexed_chain(base: Set[int], witness: Callable[[int], int],
                         max_level: int) -> List[Set[int]]:
    """Build the indexed chain: level 0 = base, level n+1 = level n ∪ {w(n)}."""
    levels: List[Set[int]] = [set(base)]
    for n in range(max_level):
        next_level = set(levels[-1])
        next_level.add(witness(n))
        levels.append(next_level)
    return levels


def verify_strict_hierarchy(levels: List[Set[int]]) -> List[bool]:
    """Verify that each level is strictly contained in the next."""
    results = []
    for i in range(len(levels) - 1):
        is_subset = levels[i] <= levels[i + 1]
        is_strict = levels[i] != levels[i + 1]
        results.append(is_subset and is_strict)
    return results


def compute_power_profile(levels: List[Set[int]], N: int) -> List[int]:
    """Compute oracle power at each level for universe [0, N)."""
    return [oracle_power(level, N) for level in levels]


def compute_density_profile(levels: List[Set[int]], N: int) -> List[float]:
    """Compute oracle density at each level for universe [0, N)."""
    return [float(oracle_density(level, N)) for level in levels]


def find_separation_witnesses(levels: List[Set[int]]) -> List[Optional[int]]:
    """Find a witness separating each pair of adjacent levels."""
    witnesses: List[Optional[int]] = []
    for i in range(len(levels) - 1):
        diff = levels[i + 1] - levels[i]
        witnesses.append(min(diff) if diff else None)
    return witnesses


@dataclass
class JumpChain:
    """Oracle hierarchy with Turing degree embedding."""
    hierarchy: OracleHierarchy
    degree: Callable[[int], int]

    def verify_strict_mono(self, max_level: int) -> bool:
        """Verify degree function is strictly monotone up to max_level."""
        for i in range(max_level):
            if self.degree(i) >= self.degree(i + 1):
                return False
        return True


def density_separation_test(hierarchy: OracleHierarchy, n: int,
                             N_values: List[int]) -> List[Tuple[int, int, int]]:
    """Test the density separation conjecture.

    Returns (N, power_n, power_{n+1}) triples.
    The conjecture predicts power_{n+1} > power_n for large N.
    """
    results = []
    level_n = hierarchy.level(n)
    level_n1 = hierarchy.level(n + 1)
    for N in N_values:
        p_n = oracle_power(level_n, N)
        p_n1 = oracle_power(level_n1, N)
        results.append((N, p_n, p_n1))
    return results
