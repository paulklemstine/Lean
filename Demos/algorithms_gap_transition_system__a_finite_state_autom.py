#!/usr/bin/env python3
"""
Gap Transition System — Core Algorithms

Type-hinted implementations of the GTS algorithms for prime gap analysis.
"""

from math import gcd
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass


@dataclass
class GapTransitionSystem:
    """A Gap Transition System with modulus M ≥ 2."""
    modulus: int

    def __post_init__(self):
        assert self.modulus >= 2, "Modulus must be at least 2"
        self._states: Optional[List[int]] = None

    @property
    def states(self) -> List[int]:
        """Coprime residue classes mod M (cached)."""
        if self._states is None:
            self._states = [s for s in range(self.modulus) if gcd(s, self.modulus) == 1]
        return self._states

    @property
    def num_states(self) -> int:
        """Number of states = φ(M)."""
        return len(self.states)

    def transition(self, state: int, gap: int) -> int:
        """Deterministic transition: (state + gap) % M."""
        return (state + gap) % self.modulus

    def is_state(self, s: int) -> bool:
        """Check if s is a valid state."""
        return 0 <= s < self.modulus and gcd(s, self.modulus) == 1

    def is_admissible(self, state: int, gap: int) -> bool:
        """Check if gap is admissible from state."""
        return self.is_state(state) and self.is_state(self.transition(state, gap))

    def admissible_gaps(self, state: int, max_gap: Optional[int] = None) -> List[int]:
        """All admissible gaps from state in [1, max_gap]."""
        if max_gap is None:
            max_gap = self.modulus
        return [g for g in range(1, max_gap + 1) if self.is_admissible(state, g)]

    def min_gap(self, state: int) -> int:
        """Minimum admissible gap from state."""
        for g in range(1, self.modulus + 1):
            if self.is_admissible(state, g):
                return g
        return -1

    def run_orbit(self, state: int, gaps: List[int]) -> List[int]:
        """Execute gap sequence, returning orbit of visited states."""
        orbit = [state]
        for g in gaps:
            state = self.transition(state, g)
            orbit.append(state)
        return orbit

    def is_cycle(self, state: int, gaps: List[int]) -> bool:
        """Check if gap sequence forms a cycle from state."""
        if not gaps:
            return False
        s = state
        for g in gaps:
            s = self.transition(s, g)
        return s == state

    def transition_graph(self) -> Dict[int, Dict[int, List[int]]]:
        """Build adjacency structure: state → {target → [gaps]}."""
        graph: Dict[int, Dict[int, List[int]]] = {s: {} for s in self.states}
        for s in self.states:
            for g in range(1, self.modulus + 1):
                t = self.transition(s, g)
                if self.is_state(t):
                    graph[s].setdefault(t, []).append(g)
        return graph

    def forcing_profile(self) -> Dict[int, int]:
        """Map each state to its minimum admissible gap."""
        return {s: self.min_gap(s) for s in self.states}

    def admissibility_matrix(self) -> List[List[int]]:
        """φ(M) × φ(M) matrix: entry (i,j) = number of gaps from state i to state j."""
        states = self.states
        n = len(states)
        mat = [[0] * n for _ in range(n)]
        for i, s in enumerate(states):
            for g in range(1, self.modulus + 1):
                t = self.transition(s, g)
                if t in states:
                    j = states.index(t)
                    mat[i][j] += 1
        return mat


def prime_gap_sequence(limit: int) -> List[int]:
    """Generate prime gaps up to limit using sieve of Eratosthenes."""
    if limit < 3:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, limit + 1, i):
                sieve[j] = False
    primes = [i for i, is_p in enumerate(sieve) if is_p]
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def verify_gts_on_primes(M: int, limit: int = 10000) -> Tuple[bool, int]:
    """Verify that consecutive primes > max_prime_factor(M) follow GTS transitions.

    Returns (all_valid, count_verified).
    """
    gts = GapTransitionSystem(M)

    # Find primes not dividing M
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, limit + 1, i):
                sieve[j] = False
    primes = [i for i, is_p in enumerate(sieve) if is_p]

    # Filter to primes > max prime factor of M
    max_pf = max(p for p in range(2, M + 1) if M % p == 0 and all(p % d != 0 for d in range(2, p)))
    primes = [p for p in primes if p > max_pf]

    count = 0
    for i in range(len(primes) - 1):
        p, q = primes[i], primes[i + 1]
        s = p % M
        g = q - p
        t = gts.transition(s, g)
        if t != q % M:
            return False, count
        if not gts.is_state(s) or not gts.is_state(t):
            return False, count
        count += 1

    return True, count


if __name__ == "__main__":
    # Verify GTS correctness on actual primes
    for M in [6, 30, 210]:
        valid, count = verify_gts_on_primes(M, 100000)
        print(f"GTS({M}): verified {count} consecutive prime pairs — {'PASS' if valid else 'FAIL'}")

    # Show forcing profiles
    for M in [6, 30]:
        gts = GapTransitionSystem(M)
        print(f"\nGTS({M}) forcing profile:")
        profile = gts.forcing_profile()
        for s, mg in sorted(profile.items()):
            print(f"  state {s:2d} → min gap = {mg}")
