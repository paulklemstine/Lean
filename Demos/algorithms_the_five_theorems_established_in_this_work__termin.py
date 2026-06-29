"""
Algorithms for Proof Refinement Systems (PRS)

Implementations of normalization, redundancy computation, product construction,
and energy spectrum analysis for abstract rewriting systems with Lyapunov-style
energy functions.

All algorithms correspond to formally verified theorems in the Lean formalization.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import (
    Callable, Dict, FrozenSet, Generic, List, Optional, Set, Tuple, TypeVar,
)
import heapq

T = TypeVar("T")  # State type
S = TypeVar("S")  # Semantics type


@dataclass(frozen=True)
class PRSConfig(Generic[T, S]):
    """Configuration for a Proof Refinement System.

    Corresponds to OrdinalPRS in the Lean formalization, specialized to
    natural-number energies (which embed into ordinals).

    Attributes:
        successors: Given a state, returns all one-step reducts.
        sem: Extracts the semantic content of a state.
        energy: Returns the energy (Lyapunov value) of a state.
    """
    successors: Callable[[T], List[T]]
    sem: Callable[[T], S]
    energy: Callable[[T], int]


def is_normal_form(prs: PRSConfig[T, S], state: T) -> bool:
    """Check if a state is a normal form (no successors)."""
    return len(prs.successors(state)) == 0


def normalize(prs: PRSConfig[T, S], state: T, max_steps: int = 100000) -> Tuple[T, int]:
    """Normalize a state by greedily reducing.

    Returns the normal form and the number of steps taken.
    Termination is guaranteed by oprs_wellFounded (energy strictly decreases).

    Args:
        prs: The proof refinement system.
        state: Initial state.
        max_steps: Safety bound (should never be hit for valid PRS).

    Returns:
        Tuple of (normal_form, num_steps).
    """
    steps = 0
    current = state
    while steps < max_steps:
        succs = prs.successors(current)
        if not succs:
            return current, steps
        # Choose the successor with minimum energy (greedy strategy)
        current = min(succs, key=prs.energy)
        steps += 1
    raise RuntimeError(f"normalize exceeded {max_steps} steps — PRS may not be valid")


def redundancy(prs: PRSConfig[T, S], state: T) -> int:
    """Compute the redundancy index: energy(p) - energy(nf(p)).

    Corresponds to redundancyIndex in the Lean formalization.
    Zero iff the state is already a normal form.
    """
    nf, _ = normalize(prs, state)
    return prs.energy(state) - prs.energy(nf)


def energy_spectrum(
    prs: PRSConfig[T, S], state: T, max_states: int = 10000
) -> Set[int]:
    """Compute the energy spectrum: set of energies reachable from state.

    Corresponds to energySpectrum in the Lean formalization.
    By spectrum_le_energy, all values are ≤ energy(state).
    """
    visited: Set[int] = set()
    queue = [state]
    seen_states: Set[int] = set()
    seen_states.add(id(state))
    count = 0

    while queue and count < max_states:
        current = queue.pop(0)
        visited.add(prs.energy(current))
        count += 1
        for succ in prs.successors(current):
            sid = id(succ)
            if sid not in seen_states:
                seen_states.add(sid)
                queue.append(succ)

    return visited


def verify_semantic_invariance(
    prs: PRSConfig[T, S], state: T, max_steps: int = 1000
) -> bool:
    """Verify that semantic invariance holds along a normalization chain.

    Checks that sem(state) = sem(nf(state)), which is guaranteed
    by oprs_sem_invariant_rtc.
    """
    original_sem = prs.sem(state)
    current = state
    for _ in range(max_steps):
        succs = prs.successors(current)
        if not succs:
            return prs.sem(current) == original_sem
        current = min(succs, key=prs.energy)
        if prs.sem(current) != original_sem:
            return False
    return True


def verify_energy_descent(prs: PRSConfig[T, S], state: T) -> bool:
    """Verify that all successors have strictly lower energy.

    This is the energy_strict axiom of OrdinalPRS.
    """
    e = prs.energy(state)
    for succ in prs.successors(state):
        if prs.energy(succ) >= e:
            return False
    return True


def verify_no_cycles(
    prs: PRSConfig[T, S], state: T, max_depth: int = 100
) -> bool:
    """Verify no cycles are reachable from state (guaranteed by oprs_no_cycles)."""
    path: List[int] = []

    def dfs(s: T, depth: int) -> bool:
        sid = id(s)
        if sid in path:
            return False  # Cycle detected
        if depth >= max_depth:
            return True
        path.append(sid)
        for succ in prs.successors(s):
            if not dfs(succ, depth + 1):
                return False
        path.pop()
        return True

    return dfs(state, 0)


@dataclass
class ProductPRS(Generic[T, S]):
    """Product of two PRS systems using natural sum for energy.

    Corresponds to OrdinalPRS.prod in the Lean formalization.
    For ℕ-valued energies, the Hessenberg sum coincides with ordinary addition.
    """
    prs1: PRSConfig
    prs2: PRSConfig

    def successors(self, state: Tuple) -> List[Tuple]:
        """Interleaved successors: step in either component."""
        s1, s2 = state
        result = []
        for succ1 in self.prs1.successors(s1):
            result.append((succ1, s2))
        for succ2 in self.prs2.successors(s2):
            result.append((s1, succ2))
        return result

    def sem(self, state: Tuple) -> Tuple:
        s1, s2 = state
        return (self.prs1.sem(s1), self.prs2.sem(s2))

    def energy(self, state: Tuple) -> int:
        s1, s2 = state
        return self.prs1.energy(s1) + self.prs2.energy(s2)

    def to_prs(self) -> PRSConfig:
        return PRSConfig(
            successors=self.successors,
            sem=self.sem,
            energy=self.energy,
        )


def check_local_confluence(
    prs: PRSConfig[T, S], state: T, max_join_depth: int = 50
) -> Optional[bool]:
    """Check local confluence at a given state.

    Returns True if all pairs of one-step reducts have a common reduct,
    False if a counterexample is found, None if inconclusive.
    """
    succs = prs.successors(state)
    if len(succs) <= 1:
        return True

    def reachable_nfs(s: T, depth: int) -> Set:
        """Find all normal forms reachable within depth."""
        if depth == 0 or is_normal_form(prs, s):
            return {id(s)}
        result = set()
        for succ in prs.successors(s):
            result |= reachable_nfs(succ, depth - 1)
        return result

    for i in range(len(succs)):
        for j in range(i + 1, len(succs)):
            nfs_i = reachable_nfs(succs[i], max_join_depth)
            nfs_j = reachable_nfs(succs[j], max_join_depth)
            if not (nfs_i & nfs_j):
                return False  # No common reduct found
    return True


def stratified_level_check(
    prs: PRSConfig[T, S],
    level: Callable[[T], int],
    state: T,
) -> bool:
    """Verify that the level function is non-increasing along reduction.

    Corresponds to stratified_level_rtc — checks the single-step condition.
    """
    current_level = level(state)
    for succ in prs.successors(state):
        if level(succ) > current_level:
            return False
    return True


def max_chain_length(prs: PRSConfig[T, S], state: T) -> int:
    """Compute the length of the longest reduction chain from state.

    By energy_gap_lower_bound, this is at most energy(state).
    """
    if is_normal_form(prs, state):
        return 0
    return 1 + max(
        max_chain_length(prs, succ) for succ in prs.successors(state)
    )
