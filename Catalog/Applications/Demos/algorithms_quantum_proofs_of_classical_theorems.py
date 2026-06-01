"""
Quantum Proof Complexity: Algorithm Implementations

Type-hinted implementations of the key algorithms from the formal framework.
"""

from typing import Callable, Optional, Tuple, List
import math
import random


class ClassicalProofSystem:
    """A classical proof system with a verification oracle and search space."""

    def __init__(
        self,
        verify: Callable[[int, int], bool],
        search_space: Callable[[int], int],
    ):
        self.verify = verify
        self.search_space = search_space

    def classical_query_complexity(self, statement: int) -> int:
        """Worst-case classical search: exhaustive over search space."""
        return self.search_space(statement)

    def quantum_query_complexity(self, statement: int) -> int:
        """Grover-optimal quantum search: ceil(sqrt(search_space))."""
        return int(math.isqrt(self.search_space(statement))) + 1

    def advantage_ratio(self, statement: int) -> float:
        """Ratio of classical to quantum query complexity."""
        qc = self.quantum_query_complexity(statement)
        return self.classical_query_complexity(statement) / qc if qc > 0 else 0.0

    def find_witness_classical(self, statement: int) -> Optional[int]:
        """Exhaustive classical search for a valid witness."""
        for w in range(self.search_space(statement)):
            if self.verify(statement, w):
                return w
        return None


class QuantumWitnessSystem(ClassicalProofSystem):
    """Quantum proof system: witnesses are quantum states (superpositions)."""

    def __init__(
        self,
        verify: Callable[[int, int], bool],
        search_space: Callable[[int], int],
        num_qubits: Callable[[int], int],
    ):
        super().__init__(verify, search_space)
        self.num_qubits = num_qubits

    def quantum_proof_length(self, statement: int) -> int:
        """Number of qubits in the quantum witness."""
        return self.num_qubits(statement)

    def classical_proof_length(self, statement: int) -> int:
        """Number of classical bits to specify a witness."""
        ss = self.search_space(statement)
        return int(math.log2(ss)) + 1 if ss > 0 else 0


class ProofComplexityClass:
    """A proof complexity class with a monotone proof length bound."""

    def __init__(self, name: str, bound: Callable[[int], int]):
        self.name = name
        self.bound = bound

    def proof_length_bound(self, n: int) -> int:
        return self.bound(n)


def classical_np(c: int) -> ProofComplexityClass:
    """NP(c): polynomial proof length n^c."""
    return ProofComplexityClass(f"NP({c})", lambda n: n ** c)


def quantum_qma(c: int) -> ProofComplexityClass:
    """QMA(c): proof length sqrt(n^c) + 1."""
    return ProofComplexityClass(f"QMA({c})", lambda n: int(math.isqrt(n ** c)) + 1)


class ProofCompression:
    """A proof compression map between two proof complexity classes."""

    def __init__(
        self,
        source: ProofComplexityClass,
        target: ProofComplexityClass,
        overhead: Callable[[int], int],
    ):
        self.source = source
        self.target = target
        self.overhead = overhead

    def verify_valid(self, n: int) -> bool:
        """Check that target ≤ overhead(source) at input n."""
        return self.target.proof_length_bound(n) <= self.overhead(
            self.source.proof_length_bound(n)
        )

    @staticmethod
    def compose(f: "ProofCompression", g: "ProofCompression") -> "ProofCompression":
        """Compose two proof compressions."""
        return ProofCompression(
            f.source,
            g.target,
            lambda n: g.overhead(f.overhead(n)),
        )

    @staticmethod
    def identity(p: ProofComplexityClass) -> "ProofCompression":
        """Identity compression."""
        return ProofCompression(p, p, lambda n: n)


def grover_compression(c: int) -> ProofCompression:
    """The Grover compression from NP(c) to QMA(c)."""
    return ProofCompression(
        classical_np(c),
        quantum_qma(c),
        lambda n: int(math.isqrt(n)) + 1,
    )


class GapAmplification:
    """Gap amplification via iterated Grover rounds."""

    def __init__(self, rounds: int, base_factor: int = 2):
        assert base_factor >= 2
        self.rounds = rounds
        self.base_factor = base_factor
        self.total_factor = base_factor ** rounds

    def verify_exponential_gap(self) -> bool:
        """Verify that 2^rounds ≤ total_factor."""
        return 2 ** self.rounds <= self.total_factor


def pigeonhole_witness_space(n: int) -> int:
    """Classical witness space for pigeonhole over [n+1] → [n]."""
    return n * (n + 1) // 2


def pigeonhole_quantum_bound(n: int) -> int:
    """Quantum witness bound for pigeonhole: sqrt(n(n+1)/2)."""
    return int(math.isqrt(pigeonhole_witness_space(n)))


def exp_dominates_poly(c: int, n: int) -> bool:
    """Check that 2^n > n^c."""
    return 2 ** n > n ** c


def find_super_poly_threshold(c: int) -> int:
    """Find the threshold k₀ such that 2^k > k^c for all k ≥ k₀."""
    k = 2
    while k < 10000:
        if all(exp_dominates_poly(c, k + i) for i in range(100)):
            return k
        k += 1
    return -1


def grover_search_simulation(
    verify: Callable[[int], bool],
    search_space_size: int,
    num_iterations: Optional[int] = None,
) -> Tuple[Optional[int], int]:
    """Simulate Grover search (classically, for demonstration).

    Returns (witness_found, queries_used).
    In a real quantum computer, this would use O(sqrt(N)) queries.
    We simulate by random sampling sqrt(N) times.
    """
    if num_iterations is None:
        num_iterations = int(math.isqrt(search_space_size)) + 1

    queries = 0
    for _ in range(num_iterations):
        candidate = random.randint(0, search_space_size - 1)
        queries += 1
        if verify(candidate):
            return candidate, queries
    return None, queries
