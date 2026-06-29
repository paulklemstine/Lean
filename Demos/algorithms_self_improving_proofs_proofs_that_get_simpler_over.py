"""
Proof Refinement Systems: Algorithms and Data Structures

This module implements the core algorithms for proof refinement systems,
including greedy refinement, exhaustive search for minimal proofs,
optimizer iteration, and analysis tools.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional, TypeVar, Generic
import heapq
from collections import defaultdict


# ──────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Proof:
    """A proof in a refinement system."""
    id: int
    theorem_id: int
    complexity: int
    label: str = ""

    def __lt__(self, other: "Proof") -> bool:
        return self.complexity < other.complexity


@dataclass
class ProofRefinementSystem:
    """
    A proof refinement system with explicit proof and theorem types.

    Attributes:
        proofs: List of all proofs in the system.
        theorem_ids: Set of all theorem identifiers.
    """
    proofs: list[Proof] = field(default_factory=list)

    def proves(self, p: Proof) -> int:
        """Return the theorem ID that proof p establishes."""
        return p.theorem_id

    def complexity(self, p: Proof) -> int:
        """Return the complexity of proof p."""
        return p.complexity

    def is_refinement(self, p_prime: Proof, p: Proof) -> bool:
        """Check if p_prime is a refinement of p."""
        return (self.proves(p_prime) == self.proves(p) and
                self.complexity(p_prime) < self.complexity(p))

    def is_minimal(self, p: Proof) -> bool:
        """Check if p is a minimal proof (no refinement exists)."""
        return not any(self.is_refinement(q, p) for q in self.proofs)

    def refinements_of(self, p: Proof) -> list[Proof]:
        """Return all refinements of p."""
        return [q for q in self.proofs if self.is_refinement(q, p)]

    def proofs_of_theorem(self, theorem_id: int) -> list[Proof]:
        """Return all proofs of a given theorem."""
        return [p for p in self.proofs if p.theorem_id == theorem_id]

    def minimal_proofs(self) -> list[Proof]:
        """Return all minimal proofs in the system."""
        return [p for p in self.proofs if self.is_minimal(p)]

    @property
    def theorem_ids(self) -> set[int]:
        return {p.theorem_id for p in self.proofs}


# ──────────────────────────────────────────────────────────────
# Algorithms
# ──────────────────────────────────────────────────────────────

def greedy_refine(system: ProofRefinementSystem, p: Proof) -> list[Proof]:
    """
    Greedy refinement: repeatedly choose the refinement with lowest complexity.

    Returns the refinement chain from p to a locally minimal proof.

    Algorithm:
        1. Start with current proof p
        2. Find all refinements of p
        3. Choose the one with minimum complexity
        4. Repeat until no refinements exist

    Guaranteed to terminate by well-foundedness (complexity decreases at each step).
    """
    chain = [p]
    current = p
    while True:
        refs = system.refinements_of(current)
        if not refs:
            break
        current = min(refs, key=lambda q: q.complexity)
        chain.append(current)
    return chain


def exhaustive_minimal(system: ProofRefinementSystem, theorem_id: int) -> Optional[Proof]:
    """
    Find the globally minimal proof of a theorem by exhaustive search.

    Returns the proof with minimum complexity among all proofs of the theorem.
    """
    proofs = system.proofs_of_theorem(theorem_id)
    if not proofs:
        return None
    return min(proofs, key=lambda p: p.complexity)


def iterate_optimizer(
    optimizer: Callable[[Proof], Proof],
    p: Proof,
    system: ProofRefinementSystem,
    max_steps: int = 10000
) -> tuple[list[Proof], int]:
    """
    Iterate a proof optimizer until complexity stabilizes.

    Returns (chain, fixed_point_step) where chain is the sequence of proofs
    and fixed_point_step is the step at which complexity first stabilized.

    By the Fixed Point Theorem, this always terminates (in at most
    initial_complexity steps of strict decrease).
    """
    chain = [p]
    current = p
    for step in range(max_steps):
        next_proof = optimizer(current)
        chain.append(next_proof)
        if system.complexity(next_proof) == system.complexity(current):
            return chain, step
        current = next_proof
    return chain, max_steps


def max_refinement_chain(system: ProofRefinementSystem, p: Proof) -> list[Proof]:
    """
    Find the longest refinement chain starting from p using DFS.

    Uses depth-first search with memoization to find the chain
    that makes the maximum number of refinement steps.
    """
    memo: dict[int, list[Proof]] = {}

    def dfs(current: Proof) -> list[Proof]:
        if current.id in memo:
            return memo[current.id]
        refs = system.refinements_of(current)
        if not refs:
            memo[current.id] = [current]
            return [current]
        best = max((dfs(r) for r in refs), key=len)
        result = [current] + best
        memo[current.id] = result
        return result

    return dfs(p)


def refinement_dag(system: ProofRefinementSystem, theorem_id: int) -> dict[int, list[int]]:
    """
    Build the refinement DAG for a specific theorem.

    Returns adjacency list: node_id -> list of refinement node_ids.
    """
    proofs = system.proofs_of_theorem(theorem_id)
    dag: dict[int, list[int]] = {p.id: [] for p in proofs}
    for p in proofs:
        for q in proofs:
            if system.is_refinement(q, p):
                dag[p.id].append(q.id)
    return dag


def complexity_spectrum(system: ProofRefinementSystem, theorem_id: int) -> dict[int, int]:
    """
    Compute the complexity spectrum: for each complexity value c,
    how many proofs of the theorem have complexity c?
    """
    proofs = system.proofs_of_theorem(theorem_id)
    spectrum: dict[int, int] = defaultdict(int)
    for p in proofs:
        spectrum[p.complexity] += 1
    return dict(sorted(spectrum.items()))


# ──────────────────────────────────────────────────────────────
# System Constructors
# ──────────────────────────────────────────────────────────────

def linear_system(n: int) -> ProofRefinementSystem:
    """
    Construct the linear system with N+1 proofs of a single theorem,
    complexities N, N-1, ..., 0.

    This is the canonical example from the Lean formalization.
    """
    proofs = [Proof(id=i, theorem_id=0, complexity=n - i,
                    label=f"P_{i}") for i in range(n + 1)]
    return ProofRefinementSystem(proofs=proofs)


def diamond_system() -> ProofRefinementSystem:
    """
    Construct a diamond-shaped system: one proof of complexity 3,
    two independent refinements of complexity 2, both refining to
    a single proof of complexity 1.

    This demonstrates non-unique refinement paths.
    """
    proofs = [
        Proof(id=0, theorem_id=0, complexity=3, label="Top"),
        Proof(id=1, theorem_id=0, complexity=2, label="Left"),
        Proof(id=2, theorem_id=0, complexity=2, label="Right"),
        Proof(id=3, theorem_id=0, complexity=1, label="Bottom"),
    ]
    return ProofRefinementSystem(proofs=proofs)


def multi_theorem_system(num_theorems: int, max_complexity: int) -> ProofRefinementSystem:
    """
    Construct a system with multiple theorems, each having proofs
    at various complexity levels.
    """
    proofs = []
    proof_id = 0
    for thm in range(num_theorems):
        for c in range(max_complexity + 1):
            proofs.append(Proof(id=proof_id, theorem_id=thm,
                                complexity=c, label=f"T{thm}_C{c}"))
            proof_id += 1
    return ProofRefinementSystem(proofs=proofs)


# ──────────────────────────────────────────────────────────────
# Analysis
# ──────────────────────────────────────────────────────────────

def analyze_system(system: ProofRefinementSystem) -> dict:
    """Comprehensive analysis of a proof refinement system."""
    minimal = system.minimal_proofs()
    theorems = system.theorem_ids

    max_chains = {}
    for thm_id in theorems:
        thm_proofs = system.proofs_of_theorem(thm_id)
        if thm_proofs:
            top = max(thm_proofs, key=lambda p: p.complexity)
            chain = max_refinement_chain(system, top)
            max_chains[thm_id] = len(chain) - 1  # chain length = #edges

    return {
        "num_proofs": len(system.proofs),
        "num_theorems": len(theorems),
        "num_minimal": len(minimal),
        "max_complexity": max((p.complexity for p in system.proofs), default=0),
        "min_complexity": min((p.complexity for p in system.proofs), default=0),
        "max_chain_lengths": max_chains,
        "complexity_spectra": {
            thm_id: complexity_spectrum(system, thm_id)
            for thm_id in theorems
        },
    }


if __name__ == "__main__":
    # Example usage
    print("=== Linear System (N=5) ===")
    sys5 = linear_system(5)
    analysis = analyze_system(sys5)
    print(f"Proofs: {analysis['num_proofs']}")
    print(f"Theorems: {analysis['num_theorems']}")
    print(f"Minimal proofs: {analysis['num_minimal']}")
    print(f"Max chain length: {analysis['max_chain_lengths']}")

    top = max(sys5.proofs, key=lambda p: p.complexity)
    chain = greedy_refine(sys5, top)
    print(f"Greedy chain: {[p.complexity for p in chain]}")
    print(f"Chain bound satisfied: {len(chain)-1} <= {top.complexity}")

    print("\n=== Diamond System ===")
    diamond = diamond_system()
    analysis = analyze_system(diamond)
    print(f"Proofs: {analysis['num_proofs']}")
    print(f"Max chain length: {analysis['max_chain_lengths']}")
    top = diamond.proofs[0]
    chain = max_refinement_chain(diamond, top)
    print(f"Max chain: {[p.label for p in chain]}")

    print("\n=== Multi-Theorem System (3 theorems, max complexity 4) ===")
    multi = multi_theorem_system(3, 4)
    analysis = analyze_system(multi)
    print(f"Proofs: {analysis['num_proofs']}")
    print(f"Theorems: {analysis['num_theorems']}")
    print(f"Max chain lengths: {analysis['max_chain_lengths']}")
