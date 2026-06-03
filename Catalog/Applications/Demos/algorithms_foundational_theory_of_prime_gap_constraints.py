"""
Prime Gap Automaton: Algorithms for modular constraint analysis of prime gaps.

This module implements the Residue Transition System (RTS) framework,
which models prime gap sequences as walks on finite-state automata
defined by coprime residue classes modulo primorials.
"""

from typing import List, Dict, Tuple, Optional, Set
from dataclasses import dataclass
import math


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


@dataclass
class ResidueTransitionSystem:
    """A finite-state automaton for prime gap constraints.

    States are coprime residue classes modulo `modulus`.
    Transitions correspond to gap values: from state r,
    a gap g leads to state (r + g) % modulus, if that
    residue is also coprime to the modulus.
    """
    modulus: int
    states: Set[int]  # coprime residues mod modulus

    @classmethod
    def from_primorial(cls, primes: List[int]) -> 'ResidueTransitionSystem':
        """Build RTS from a list of small primes (the primorial sieve)."""
        modulus = 1
        for p in primes:
            modulus *= p
        states = {r for r in range(modulus) if math.gcd(r, modulus) == 1}
        return cls(modulus=modulus, states=states)

    def transition(self, state: int, gap: int) -> Optional[int]:
        """Apply a gap transition. Returns new state or None if inadmissible."""
        new_state = (state + gap) % self.modulus
        return new_state if new_state in self.states else None

    def admissible_gaps(self, state: int) -> List[int]:
        """All gap residues (mod modulus) admissible from a given state."""
        return [g for g in range(self.modulus)
                if (state + g) % self.modulus in self.states]

    def transition_matrix(self) -> Dict[Tuple[int, int], List[int]]:
        """Build the transition matrix: (from_state, to_state) -> gap residues."""
        matrix: Dict[Tuple[int, int], List[int]] = {}
        sorted_states = sorted(self.states)
        for s in sorted_states:
            for g in range(self.modulus):
                t = (s + g) % self.modulus
                if t in self.states:
                    key = (s, t)
                    if key not in matrix:
                        matrix[key] = []
                    matrix[key].append(g)
        return matrix

    def forbidden_gap_residues(self, state: int) -> List[int]:
        """Gap residues (mod modulus) that are inadmissible from a state."""
        admissible = set(self.admissible_gaps(state))
        return [g for g in range(self.modulus) if g not in admissible]

    def is_word_admissible(self, word: List[int], start: int) -> bool:
        """Check if a gap word is admissible starting from a given state."""
        current = start
        for gap in word:
            result = self.transition(current, gap)
            if result is None:
                return False
            current = result
        return True

    def admissible_words(self, length: int) -> List[Tuple[int, List[int]]]:
        """Generate all admissible gap words of a given length.

        Returns (start_state, word) pairs.
        """
        results = []
        for start in sorted(self.states):
            self._gen_words(start, start, [], length, results)
        return results

    def _gen_words(self, start: int, current: int, word: List[int],
                   remaining: int, results: List[Tuple[int, List[int]]]) -> None:
        if remaining == 0:
            results.append((start, list(word)))
            return
        for g in self.admissible_gaps(current):
            new_state = self.transition(current, g)
            if new_state is not None:
                word.append(g)
                self._gen_words(start, new_state, word, remaining - 1, results)
                word.pop()


def mod6_state(p: int) -> str:
    """Classify a prime > 3 into its mod-6 state."""
    r = p % 6
    if r == 1:
        return "one"
    elif r == 5:
        return "five"
    else:
        return f"invalid({r})"


def analyze_gap_sequence(primes: List[int]) -> Dict:
    """Analyze a sequence of primes through the mod-6 automaton lens.

    Returns statistics about state transitions, gap distribution,
    and forbidden pattern near-misses.
    """
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    states = [mod6_state(p) for p in primes if p > 3]

    # Count transitions
    transitions: Dict[Tuple[str, str], int] = {}
    for i in range(len(states) - 1):
        key = (states[i], states[i+1])
        transitions[key] = transitions.get(key, 0) + 1

    # Count gap residues mod 6
    gap_residues: Dict[int, int] = {}
    for g in gaps:
        r = g % 6
        gap_residues[r] = gap_residues.get(r, 0) + 1

    # Find longest run of equal gaps
    max_run = 1
    max_run_gap = gaps[0] if gaps else 0
    current_run = 1
    for i in range(1, len(gaps)):
        if gaps[i] == gaps[i-1]:
            current_run += 1
            if current_run > max_run:
                max_run = current_run
                max_run_gap = gaps[i]
        else:
            current_run = 1

    return {
        "num_primes": len(primes),
        "num_gaps": len(gaps),
        "transitions": transitions,
        "gap_residues_mod6": gap_residues,
        "max_equal_gap_run": max_run,
        "max_equal_gap_value": max_run_gap,
        "twin_prime_count": sum(1 for g in gaps if g == 2),
        "cousin_prime_count": sum(1 for g in gaps if g == 4),
        "sexy_prime_count": sum(1 for g in gaps if g == 6),
    }


def find_longest_gap_runs(limit: int, gap_value: int) -> Tuple[int, List[int]]:
    """Find the longest consecutive run of gaps equal to `gap_value`
    among primes up to `limit`.

    Returns (run_length, starting_primes).
    """
    primes = primes_up_to(limit)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

    max_run = 0
    max_starts: List[int] = []
    current_run = 0
    run_start = 0

    for i, g in enumerate(gaps):
        if g == gap_value:
            if current_run == 0:
                run_start = i
            current_run += 1
            if current_run > max_run:
                max_run = current_run
                max_starts = [primes[run_start]]
            elif current_run == max_run:
                max_starts.append(primes[run_start])
        else:
            current_run = 0

    return max_run, max_starts


def compute_admissibility_density(modulus: int) -> float:
    """Compute the fraction of gap residues (mod modulus) that are
    admissible, averaged over all states. This is φ(m)/m."""
    rts = ResidueTransitionSystem.from_primorial(
        [p for p in range(2, modulus + 1) if is_prime(p) and modulus % p == 0]
    )
    if not rts.states:
        return 0.0
    total = sum(len(rts.admissible_gaps(s)) for s in rts.states)
    return total / (len(rts.states) * rts.modulus)


if __name__ == "__main__":
    # Build standard RTS instances
    rts6 = ResidueTransitionSystem.from_primorial([2, 3])
    rts30 = ResidueTransitionSystem.from_primorial([2, 3, 5])
    rts210 = ResidueTransitionSystem.from_primorial([2, 3, 5, 7])

    print("=== Residue Transition Systems ===")
    for name, rts in [("mod-6", rts6), ("mod-30", rts30), ("mod-210", rts210)]:
        print(f"\n{name} (modulus={rts.modulus}):")
        print(f"  States: {sorted(rts.states)}")
        print(f"  Number of states: {len(rts.states)} = φ({rts.modulus})")
        density = len(rts.states) / rts.modulus
        print(f"  State density: {density:.4f}")
