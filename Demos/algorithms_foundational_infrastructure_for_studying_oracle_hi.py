"""
Oracle Hierarchy Algorithms

Type-hinted implementations of the key algorithms and data structures
from the oracle hierarchy foundations.
"""

from typing import Set, Callable, List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class OracleJump:
    """An oracle jump operator on sets of natural numbers.

    Models the Turing jump: given a theory (set of provable sentences),
    the jump produces a strictly larger theory by adding the halting
    problem for the original theory.
    """
    jump: Callable[[Set[int]], Set[int]]

    def iter(self, base: Set[int], n: int) -> Set[int]:
        """Apply the jump operator n times starting from base."""
        result = set(base)
        for _ in range(n):
            result = self.jump(result)
        return result


@dataclass
class OracleHierarchy:
    """An oracle hierarchy: a base theory with a jump operator."""
    base: Set[int]
    jump: OracleJump

    def level(self, n: int) -> Set[int]:
        """The theory at level n."""
        return self.jump.iter(self.base, n)

    def limit(self, max_level: int) -> Set[int]:
        """Approximate the limit theory (union of levels up to max_level)."""
        result: Set[int] = set()
        for n in range(max_level + 1):
            result |= self.level(n)
        return result


def oracle_power(theory: Set[int], N: int) -> int:
    """Count provable sentences in [0, N)."""
    return len({x for x in range(N) if x in theory})


def oracle_density(theory: Set[int], N: int) -> float:
    """Fraction of sentences in [0, N) that are provable."""
    if N == 0:
        return 0.0
    return oracle_power(theory, N) / N


def hierarchy_spectrum(hierarchy: OracleHierarchy, max_level: int, N: int) -> List[Set[int]]:
    """Compute witnesses separating each pair of adjacent levels.

    Returns a list where spectrum[k] contains elements in level(k+1) \ level(k)
    that are below N.
    """
    spectrum: List[Set[int]] = []
    for k in range(max_level):
        level_k = hierarchy.level(k)
        level_k1 = hierarchy.level(k + 1)
        witnesses = {x for x in range(N) if x in level_k1 and x not in level_k}
        spectrum.append(witnesses)
    return spectrum


def verify_strict_monotonicity(hierarchy: OracleHierarchy, max_level: int, N: int) -> bool:
    """Verify that the hierarchy is strictly monotone up to max_level within [0, N)."""
    for k in range(max_level):
        if oracle_power(hierarchy.level(k), N) >= oracle_power(hierarchy.level(k + 1), N):
            return False
    return True


def compose_jumps(j1: OracleJump, j2: OracleJump) -> OracleJump:
    """Compose two jump operators: apply j1 then j2."""
    return OracleJump(jump=lambda S: j2.jump(j1.jump(S)))


def find_prefixed_point(jump: OracleJump, base: Set[int], max_iter: int) -> Set[int]:
    """Approximate the least prefixed point by iterating the jump.

    Returns the union of all levels up to max_iter.
    """
    result = set(base)
    current = set(base)
    for _ in range(max_iter):
        current = jump.jump(current)
        result |= current
    return result


def independent_check(A: Set[int], B: Set[int]) -> bool:
    """Check if two sets are independent (neither is a subset of the other)."""
    return not A.issubset(B) and not B.issubset(A)


# --- Concrete model: Arithmetic hierarchy simulation ---

def arithmetic_jump(S: Set[int], witness_gen: Callable[[Set[int]], int]) -> Set[int]:
    """Simulate an arithmetic jump by adding a witness."""
    w = witness_gen(S)
    return S | {w}


def build_arithmetic_hierarchy(
    base: Set[int],
    witness_gen: Callable[[Set[int]], int],
    num_levels: int
) -> OracleHierarchy:
    """Build a concrete arithmetic hierarchy with a given witness generator."""
    jump = OracleJump(jump=lambda S: arithmetic_jump(S, witness_gen))
    return OracleHierarchy(base=base, jump=jump)


def multi_witness_separation(
    hierarchy: OracleHierarchy, m: int, n: int, N: int
) -> List[int]:
    """Find witnesses separating level m from level n within [0, N)."""
    level_m = hierarchy.level(m)
    level_n = hierarchy.level(n)
    return [x for x in range(N) if x in level_n and x not in level_m]
