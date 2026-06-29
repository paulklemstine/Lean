"""
Chromatic Darkness Theory — Core Algorithms

Type-hinted implementations of dark witness family analysis algorithms.
"""

from typing import List, Set, Dict, Tuple, Optional
from dataclasses import dataclass


@dataclass
class DarkFamily:
    """A dark witness family with m worlds and candidates from {0, ..., N-1}."""
    m: int  # number of worlds
    N: int  # number of candidates
    witnesses: List[Set[int]]  # witnesses[a] = set of witnesses for world a
    level: int  # darkness level (min witnesses per world)

    def __post_init__(self) -> None:
        assert len(self.witnesses) == self.m
        assert all(all(0 <= n < self.N for n in w) for w in self.witnesses)


def rejection_set(D: DarkFamily, a: int) -> Set[int]:
    """Compute the rejection set of world a: candidates not accepted by world a."""
    return set(range(D.N)) - D.witnesses[a]


def spectrum(D: DarkFamily, n: int) -> Set[int]:
    """Compute the spectrum of candidate n: worlds that accept n."""
    return {a for a in range(D.m) if n in D.witnesses[a]}


def anti_spectrum(D: DarkFamily, n: int) -> Set[int]:
    """Compute the anti-spectrum of candidate n: worlds that reject n."""
    return {a for a in range(D.m) if n not in D.witnesses[a]}


def defect(D: DarkFamily, n: int) -> int:
    """Compute the defect of candidate n: number of worlds rejecting it."""
    return len(anti_spectrum(D, n))


def verify_dark_family(witnesses: List[Set[int]], N: int) -> Tuple[bool, int, bool]:
    """
    Verify whether given witness sets form a dark family.

    Returns:
        (is_dark, level, is_balanced)
    """
    m = len(witnesses)
    if m == 0 or N == 0:
        return (False, 0, False)

    level = min(len(w) for w in witnesses)
    if level == 0:
        return (False, 0, False)

    D = DarkFamily(m=m, N=N, witnesses=witnesses, level=level)

    # Check no_universal: every candidate rejected by at least one world
    is_dark = all(defect(D, n) >= 1 for n in range(N))

    # Check balanced: every candidate rejected by exactly one world
    is_balanced = all(defect(D, n) == 1 for n in range(N))

    return (is_dark, level, is_balanced)


def equitable_block_partition(m: int, N: int) -> DarkFamily:
    """
    Construct the extremal balanced dark family via equitable block partition.

    Requires: m divides N, m >= 2, N > 0.

    Each world rejects a contiguous block of N/m candidates.
    Achieves the maximum darkness level: N - N/m.
    """
    assert N % m == 0, f"m={m} must divide N={N}"
    assert m >= 2
    assert N > 0

    block_size = N // m
    witnesses = []
    for a in range(m):
        rejected = set(range(a * block_size, (a + 1) * block_size))
        witnesses.append(set(range(N)) - rejected)

    return DarkFamily(m=m, N=N, witnesses=witnesses, level=N - block_size)


def compute_chromatic_classes(D: DarkFamily) -> Dict[frozenset, List[int]]:
    """
    Compute chromatic equivalence classes.

    Two candidates are chromatically equivalent if they have the same
    anti-spectrum (same set of rejecting worlds).

    Returns: dict mapping anti-spectrum (frozenset) to list of candidates.
    """
    classes: Dict[frozenset, List[int]] = {}
    for n in range(D.N):
        key = frozenset(anti_spectrum(D, n))
        if key not in classes:
            classes[key] = []
        classes[key].append(n)
    return classes


def dark_inequality_check(D: DarkFamily) -> Tuple[int, int, bool]:
    """
    Verify the Dark Inequality: level * m <= N * (m - 1).

    Returns: (lhs, rhs, satisfied)
    """
    lhs = D.level * D.m
    rhs = D.N * (D.m - 1)
    return (lhs, rhs, lhs <= rhs)


def double_count_verify(D: DarkFamily) -> Tuple[int, int, bool]:
    """
    Verify the double counting identity:
      sum of rejection sizes = sum of defects.

    Returns: (world_sum, candidate_sum, equal)
    """
    world_sum = sum(len(rejection_set(D, a)) for a in range(D.m))
    candidate_sum = sum(defect(D, n) for n in range(D.N))
    return (world_sum, candidate_sum, world_sum == candidate_sum)


def witness_overlap(D: DarkFamily, a: int, b: int) -> int:
    """Compute |witnesses(a) ∩ witnesses(b)|."""
    return len(D.witnesses[a] & D.witnesses[b])


def compute_defect_vector(D: DarkFamily) -> List[int]:
    """Compute the defect vector (defect(n) for n in 0..N-1)."""
    return [defect(D, n) for n in range(D.N)]


def optimal_level_search(m: int, N: int, max_attempts: int = 1000) -> int:
    """
    Search for the maximum achievable darkness level with m worlds, N candidates.
    Uses random sampling to find good constructions.

    Returns the best level found.
    """
    import random
    best_level = 0

    for _ in range(max_attempts):
        # Random partition approach: assign each candidate to a random rejecting world
        assignment = [random.randint(0, m - 1) for _ in range(N)]
        witnesses = [set() for _ in range(m)]
        for n in range(N):
            for a in range(m):
                if assignment[n] != a:
                    witnesses[a].add(n)

        level = min(len(w) for w in witnesses)
        is_dark, actual_level, _ = verify_dark_family(witnesses, N)
        if is_dark:
            best_level = max(best_level, actual_level)

    return best_level
