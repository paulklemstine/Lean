#!/usr/bin/env python3
"""
Prime Gap Automaton — Algorithms

Type-hinted implementations of the prime gap automaton and
its applications to prime gap prediction and pattern analysis.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass


@dataclass
class AutomatonState:
    """State of the prime gap automaton."""
    residue_mod6: int    # 1 or 5
    residue_mod30: int   # one of {1,7,11,13,17,19,23,29}

    @property
    def state_id(self) -> int:
        """Return 0 for residue 1 mod 6, 1 for residue 5 mod 6."""
        return 0 if self.residue_mod6 == 1 else 1


class PrimeGapAutomaton:
    """
    The 2-state finite automaton governing prime gap sequences mod 6.

    States: {0, 1} representing p ≡ 1 (mod 6) and p ≡ 5 (mod 6)
    Transitions:
        From state 0: gap ≡ 0 mod 6 → state 0, gap ≡ 4 mod 6 → state 1
        From state 1: gap ≡ 0 mod 6 → state 1, gap ≡ 2 mod 6 → state 0
    """

    ADMISSIBLE_GAPS_MOD6: Dict[int, Set[int]] = {
        0: {0, 4},  # From state 0 (p ≡ 1 mod 6)
        1: {0, 2},  # From state 1 (p ≡ 5 mod 6)
    }

    @staticmethod
    def transition(state: int, gap_mod6: int) -> int:
        """Compute the next state given current state and gap mod 6."""
        if gap_mod6 % 6 == 0:
            return state  # Identity transition
        elif state == 0:
            return 1      # State 0 → State 1
        else:
            return 0      # State 1 → State 0

    @staticmethod
    def is_admissible_gap(state: int, gap: int) -> bool:
        """Check if a gap value is admissible from the given state."""
        return gap % 6 in PrimeGapAutomaton.ADMISSIBLE_GAPS_MOD6[state]

    @staticmethod
    def admissible_gaps_up_to(state: int, max_gap: int) -> List[int]:
        """Return all admissible gap values up to max_gap from given state."""
        admissible = PrimeGapAutomaton.ADMISSIBLE_GAPS_MOD6[state]
        return [g for g in range(2, max_gap + 1, 2) if g % 6 in admissible]

    @staticmethod
    def classify_prime(p: int) -> int:
        """Classify a prime > 3 into automaton state 0 or 1."""
        if p <= 3:
            raise ValueError("Automaton is defined for primes > 3")
        return 0 if p % 6 == 1 else 1


class Mod30Automaton:
    """
    The 8-state automaton governing prime gaps mod 30.

    States: {1, 7, 11, 13, 17, 19, 23, 29} (residues coprime to 30)
    Transitions: gap g maps state r to (r + g) mod 30, which must also
    be in the admissible set.
    """

    ADMISSIBLE_RESIDUES: Set[int] = {1, 7, 11, 13, 17, 19, 23, 29}

    @staticmethod
    def admissible_gaps(state: int) -> List[int]:
        """Return admissible gap values mod 30 from given state."""
        return [g for g in range(1, 31)
                if (state + g) % 30 in Mod30Automaton.ADMISSIBLE_RESIDUES]

    @staticmethod
    def transition(state: int, gap: int) -> int:
        """Compute the next state given current state and gap."""
        next_state = (state + gap) % 30
        assert next_state in Mod30Automaton.ADMISSIBLE_RESIDUES
        return next_state

    @staticmethod
    def transition_matrix() -> Dict[int, Dict[int, int]]:
        """Return the full transition matrix: state → gap_mod30 → next_state."""
        matrix: Dict[int, Dict[int, int]] = {}
        for r in Mod30Automaton.ADMISSIBLE_RESIDUES:
            matrix[r] = {}
            for g in Mod30Automaton.admissible_gaps(r):
                matrix[r][g] = (r + g) % 30
        return matrix


def analyze_gap_patterns(primes: List[int]) -> Dict[str, any]:
    """
    Analyze a list of primes through the automaton lens.

    Returns statistics about state distribution, transition frequencies,
    and pattern admissibility.
    """
    if len(primes) < 2:
        return {"error": "Need at least 2 primes"}

    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

    # State sequence
    states = [PrimeGapAutomaton.classify_prime(p) for p in primes if p > 3]

    # Transition verification
    violations = 0
    for i, (p, g) in enumerate(zip(primes[:-1], gaps)):
        if p <= 3:
            continue
        state = PrimeGapAutomaton.classify_prime(p)
        if not PrimeGapAutomaton.is_admissible_gap(state, g):
            violations += 1

    # Gap distribution by state
    gap_dist: Dict[int, Dict[int, int]] = {0: {}, 1: {}}
    for p, g in zip(primes[:-1], gaps):
        if p <= 3:
            continue
        state = PrimeGapAutomaton.classify_prime(p)
        gap_dist[state][g] = gap_dist[state].get(g, 0) + 1

    return {
        "total_gaps": len(gaps),
        "violations": violations,
        "state_counts": {0: states.count(0), 1: states.count(1)},
        "gap_distribution_by_state": gap_dist,
    }


def predict_admissible_next_gaps(p: int, max_gap: int = 100) -> List[int]:
    """
    Given a prime p > 3, return all admissible gap values up to max_gap.

    These are the gap values compatible with the mod-6 constraint.
    The actual gap must additionally ensure p + gap is prime.
    """
    state = PrimeGapAutomaton.classify_prime(p)
    return PrimeGapAutomaton.admissible_gaps_up_to(state, max_gap)


def sieve_based_prediction(p: int, max_gap: int = 100) -> List[int]:
    """
    Predict admissible next primes using the mod-30 automaton.

    Returns candidate values q = p + g where g is admissible mod 30.
    """
    state = p % 30
    candidates = []
    for g in range(2, max_gap + 1, 2):
        if (state + g) % 30 in Mod30Automaton.ADMISSIBLE_RESIDUES:
            candidates.append(p + g)
    return candidates


def find_forcing_patterns(max_pattern_length: int = 4,
                          max_gap: int = 30) -> List[Tuple[List[int], int]]:
    """
    Find gap patterns that uniquely determine the automaton's next state
    and severely constrain the next gap value.

    A pattern is 'forcing' if knowing the pattern of gaps determines
    the mod-6 state and leaves very few admissible next gaps below max_gap.
    """
    forcing: List[Tuple[List[int], int]] = []

    # Generate all admissible gap patterns
    even_gaps = list(range(2, max_gap + 1, 2))

    for length in range(1, max_pattern_length + 1):
        # For each starting state
        for start_state in [0, 1]:
            patterns = _generate_patterns(start_state, length, even_gaps)
            for pattern, end_state in patterns:
                admissible = PrimeGapAutomaton.admissible_gaps_up_to(end_state, max_gap)
                if len(admissible) <= 3:  # Highly constrained
                    forcing.append((pattern, len(admissible)))

    return forcing


def _generate_patterns(start_state: int, length: int,
                       gaps: List[int]) -> List[Tuple[List[int], int]]:
    """Generate all admissible gap patterns of given length from start_state."""
    if length == 0:
        return [([], start_state)]

    results = []
    for g in gaps:
        if PrimeGapAutomaton.is_admissible_gap(start_state, g):
            next_state = PrimeGapAutomaton.transition(start_state, g % 6)
            sub_patterns = _generate_patterns(next_state, length - 1, gaps)
            for sub_pat, end_state in sub_patterns:
                results.append(([g] + sub_pat, end_state))

    return results


if __name__ == "__main__":
    # Demo
    from sympy import primerange

    primes = list(primerange(5, 100000))
    result = analyze_gap_patterns(primes)

    print("=== Prime Gap Automaton Analysis ===")
    print(f"Total gaps: {result['total_gaps']}")
    print(f"Constraint violations: {result['violations']}")
    print(f"State distribution: {result['state_counts']}")

    print("\nAdmissible next gaps from p=997 (state", PrimeGapAutomaton.classify_prime(997), "):")
    print(predict_admissible_next_gaps(997, 50))

    print("\nMod-30 candidates after p=997:")
    candidates = sieve_based_prediction(997, 50)
    print(candidates[:10])
