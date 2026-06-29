"""
Retrocausal Proof Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the retrocausal
proof theory framework.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import FrozenSet, Set, Dict, List, Tuple, Optional
import random


@dataclass(frozen=True)
class ConsequenceSystem:
    """A consequence system over a finite set of propositions.

    Attributes:
        propositions: The universe of propositions (as integers).
        provable: Set of provable propositions.
        consequences: Map from each proposition to its consequence set.
        complexity: Map from each proposition to its proof complexity.
    """
    propositions: FrozenSet[int]
    provable: FrozenSet[int]
    consequences: Dict[int, FrozenSet[int]]
    complexity: Dict[int, int]

    def is_stable(self, p: int) -> bool:
        """Check if proposition p is consequence-stable."""
        return all(q in self.provable for q in self.consequences.get(p, frozenset()))

    def stable_set(self) -> FrozenSet[int]:
        """Return the set of all consequence-stable propositions."""
        return frozenset(p for p in self.propositions if self.is_stable(p))

    def candidates_for(self, observed: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the candidate set for a given set of observations."""
        return frozenset(
            p for p in self.propositions
            if observed.issubset(self.consequences.get(p, frozenset()))
        )

    def is_separated(self, p: int) -> bool:
        """Check if proposition p is consequence-separated."""
        p_cons = self.consequences.get(p, frozenset())
        return all(
            q == p
            for q in self.propositions
            if self.consequences.get(q, frozenset()) == p_cons
        )

    def is_consequence_maximal(self, p: int) -> bool:
        """Check if proposition p is consequence-maximal."""
        p_cons = self.consequences.get(p, frozenset())
        return all(
            self.consequences.get(q, frozenset()).issubset(p_cons)
            for q in self.propositions
            if p_cons.issubset(self.consequences.get(q, frozenset()))
        )

    def consequence_class(self, p: int) -> FrozenSet[int]:
        """Return the consequence class of p."""
        p_cons = self.consequences.get(p, frozenset())
        return frozenset(
            q for q in self.propositions
            if self.consequences.get(q, frozenset()) == p_cons
        )

    def discrimination_power(self, candidates: FrozenSet[int], q: int) -> int:
        """Compute the discrimination power of consequence q over candidates."""
        return sum(
            1 for p in candidates
            if q not in self.consequences.get(p, frozenset())
        )

    def compression_ratio(self, observed: FrozenSet[int]) -> float:
        """Compute the compression ratio for given observations."""
        n = len(self.propositions)
        if n == 0:
            return 0.0
        return len(self.candidates_for(observed)) / n


def retrocausal_search(
    system: ConsequenceSystem,
    target: int,
    max_verifications: int = 100,
) -> Tuple[FrozenSet[int], List[int], List[float]]:
    """Retrocausal proof search algorithm.

    Iteratively verifies consequences of the target proposition,
    using each verification to narrow the candidate set.

    Args:
        system: The consequence system.
        target: The target proposition to search for.
        max_verifications: Maximum number of consequence verifications.

    Returns:
        Tuple of (final_candidates, verification_sequence, compression_history).
    """
    consequences = list(system.consequences.get(target, frozenset()))
    observed: Set[int] = set()
    candidates = system.candidates_for(frozenset())
    compression_history: List[float] = [system.compression_ratio(frozenset())]
    verification_sequence: List[int] = []

    for i in range(min(max_verifications, len(consequences))):
        # Greedy: pick the consequence with maximum discrimination power
        best_q = max(
            (q for q in consequences if q not in observed),
            key=lambda q: system.discrimination_power(candidates, q),
            default=None,
        )
        if best_q is None:
            break

        observed.add(best_q)
        verification_sequence.append(best_q)
        candidates = system.candidates_for(frozenset(observed))
        compression_history.append(system.compression_ratio(frozenset(observed)))

        if len(candidates) <= 1:
            break

    return candidates, verification_sequence, compression_history


def find_discrimination_chain(
    system: ConsequenceSystem,
    initial_observed: FrozenSet[int],
    available: List[int],
) -> List[int]:
    """Find a maximal discrimination chain starting from initial observations.

    Returns a list of consequences that each strictly reduce the candidate set.
    """
    chain: List[int] = []
    current_observed = set(initial_observed)
    candidates = system.candidates_for(frozenset(current_observed))

    for q in available:
        if q in current_observed:
            continue
        # Check if q discriminates
        power = system.discrimination_power(candidates, q)
        if power > 0:
            chain.append(q)
            current_observed.add(q)
            candidates = system.candidates_for(frozenset(current_observed))

    return chain


def generate_random_system(
    n: int,
    consequence_density: float = 0.3,
    provable_fraction: float = 0.5,
    seed: Optional[int] = None,
) -> ConsequenceSystem:
    """Generate a random consequence system for testing.

    Args:
        n: Number of propositions (0 to n-1).
        consequence_density: Probability that q is a consequence of p.
        provable_fraction: Fraction of propositions that are provable.
        seed: Random seed for reproducibility.

    Returns:
        A random ConsequenceSystem.
    """
    if seed is not None:
        random.seed(seed)

    propositions = frozenset(range(n))
    provable = frozenset(random.sample(range(n), int(n * provable_fraction)))

    consequences: Dict[int, FrozenSet[int]] = {}
    for p in range(n):
        cons = frozenset(
            q for q in range(n)
            if random.random() < consequence_density
        )
        consequences[p] = cons

    complexity = {p: random.randint(1, 100) for p in range(n)}

    return ConsequenceSystem(
        propositions=propositions,
        provable=provable,
        consequences=consequences,
        complexity=complexity,
    )


def measure_compression_statistics(
    n_trials: int = 100,
    system_size: int = 50,
    consequence_density: float = 0.3,
) -> Dict[str, float]:
    """Measure average compression statistics across random systems.

    Returns statistics about compression ratios, discrimination chain
    lengths, and separation rates.
    """
    total_compression = 0.0
    total_chain_length = 0
    total_separated = 0
    total_stable = 0

    for trial in range(n_trials):
        system = generate_random_system(
            system_size, consequence_density, seed=trial
        )

        # Measure for a random target
        target = random.choice(list(system.propositions))
        _, _, history = retrocausal_search(system, target)
        if history:
            total_compression += history[-1]

        # Count separated and stable
        for p in system.propositions:
            if system.is_separated(p):
                total_separated += 1
            if system.is_stable(p):
                total_stable += 1

        # Find discrimination chain
        chain = find_discrimination_chain(
            system,
            frozenset(),
            list(system.propositions),
        )
        total_chain_length += len(chain)

    n_props = n_trials * system_size
    return {
        "avg_final_compression": total_compression / n_trials,
        "avg_chain_length": total_chain_length / n_trials,
        "separation_rate": total_separated / n_props,
        "stability_rate": total_stable / n_props,
    }


if __name__ == "__main__":
    # Example: the Fin 3 system from the Lean formalization
    example = ConsequenceSystem(
        propositions=frozenset({0, 1, 2}),
        provable=frozenset({0, 1}),
        consequences={
            0: frozenset({0, 1}),
            1: frozenset({1}),
            2: frozenset(),
        },
        complexity={0: 1, 1: 1, 2: 1},
    )

    print("=== Example System (Fin 3) ===")
    print(f"Propositions: {sorted(example.propositions)}")
    print(f"Provable: {sorted(example.provable)}")
    for p in sorted(example.propositions):
        print(f"  consequences({p}) = {sorted(example.consequences[p])}")
        print(f"  stable({p}) = {example.is_stable(p)}")
        print(f"  separated({p}) = {example.is_separated(p)}")
        print(f"  maximal({p}) = {example.is_consequence_maximal(p)}")

    print(f"\ncandidatesFor({{0, 1}}) = {sorted(example.candidates_for(frozenset({0, 1})))}")
    print(f"Compression ratio: {example.compression_ratio(frozenset({0, 1})):.3f}")

    # Retrocausal search
    candidates, verifs, history = retrocausal_search(example, 0)
    print(f"\nRetrocausal search for prop 0:")
    print(f"  Verification sequence: {verifs}")
    print(f"  Compression history: {[f'{x:.3f}' for x in history]}")
    print(f"  Final candidates: {sorted(candidates)}")
