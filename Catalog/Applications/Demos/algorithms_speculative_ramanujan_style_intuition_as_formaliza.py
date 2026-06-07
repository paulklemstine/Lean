#!/usr/bin/env python3
"""
Ramanujan Oracle Framework — Algorithms Module

Type-hinted implementations of the core algorithms from the research.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
from enum import Enum
from dataclasses import dataclass, field
import math


class OracleResponse(Enum):
    """Three-valued oracle response type."""
    TRUE = "true"
    FALSE = "false"
    UNKNOWN = "unknown"


@dataclass
class RamanujanOracle:
    """A Ramanujan Oracle: a sound prediction device for a truth set.

    The oracle predicts truth values with guaranteed soundness —
    definite predictions are always correct. The oracle may abstain
    (respond UNKNOWN) on any input.
    """
    predict: Callable[[int], OracleResponse]
    truth_set: Callable[[int], bool]

    def is_sound_on(self, n: int) -> bool:
        """Check if the oracle is sound on input n."""
        p = self.predict(n)
        t = self.truth_set(n)
        if p == OracleResponse.TRUE:
            return t
        elif p == OracleResponse.FALSE:
            return not t
        return True  # UNKNOWN is always sound

    def coverage(self, N: int) -> float:
        """Compute coverage ratio on [0, N)."""
        if N == 0:
            return 0.0
        definite = sum(1 for n in range(N) if self.predict(n) != OracleResponse.UNKNOWN)
        return definite / N

    def accuracy(self, N: int) -> float:
        """Compute accuracy on definite predictions in [0, N)."""
        correct = 0
        total = 0
        for n in range(N):
            p = self.predict(n)
            if p != OracleResponse.UNKNOWN:
                total += 1
                t = self.truth_set(n)
                if (p == OracleResponse.TRUE) == t:
                    correct += 1
        return correct / total if total > 0 else 1.0


@dataclass
class OracleEvaluation:
    """Result of evaluating an oracle on a finite domain."""
    accuracy: float
    coverage: float
    correct: int
    wrong: int
    abstain: int
    is_sound: bool
    soundness_violations: List[int] = field(default_factory=list)


def evaluate_oracle(
    oracle: RamanujanOracle,
    N: int,
    verbose: bool = False
) -> OracleEvaluation:
    """Evaluate a Ramanujan Oracle on the domain [0, N).

    Algorithm:
    1. For each n in [0, N), query the oracle
    2. Compare with ground truth
    3. Compute accuracy, coverage, and soundness

    Time complexity: O(N * (T_predict + T_truth))
    Space complexity: O(N) for violation tracking
    """
    correct = wrong = abstain = 0
    violations: List[int] = []

    for n in range(N):
        prediction = oracle.predict(n)
        truth = oracle.truth_set(n)

        if prediction == OracleResponse.UNKNOWN:
            abstain += 1
        elif (prediction == OracleResponse.TRUE) == truth:
            correct += 1
        else:
            wrong += 1
            violations.append(n)

    total_definite = correct + wrong
    accuracy = correct / total_definite if total_definite > 0 else 1.0
    coverage = total_definite / N if N > 0 else 0.0

    return OracleEvaluation(
        accuracy=accuracy,
        coverage=coverage,
        correct=correct,
        wrong=wrong,
        abstain=abstain,
        is_sound=(wrong == 0),
        soundness_violations=violations
    )


def cofinite_agree(
    f: Callable[[int], bool],
    g: Callable[[int], bool],
    N: int
) -> Tuple[int, List[int]]:
    """Detect cofinite agreement between two Boolean functions.

    Algorithm:
    1. Check f(n) == g(n) for each n in [0, N)
    2. Return count and list of disagreements

    If the number of disagreements is finite (and N is large enough
    to capture all of them), the functions cofinitely agree.

    Returns: (number of disagreements, list of disagreement points)
    """
    disagreements = [n for n in range(N) if f(n) != g(n)]
    return len(disagreements), disagreements


def oracle_space_size(N: int, k: int = 3) -> int:
    """Compute the number of possible k-valued oracle functions on N inputs.

    This is the Ramanujan Counting Bound: exactly k^N.

    For k=3 (true/false/unknown) and N statements:
    - N=10: 59,049 oracles
    - N=20: 3,486,784,401 oracles
    - N=100: ~ 5.15 × 10^47 oracles

    The computable oracles are countable (ℵ₀), so for infinite N,
    "most" oracles are non-computable.
    """
    return k ** N


@dataclass
class GradedOracleHierarchy:
    """A graded oracle hierarchy with strictly increasing decision power.

    Each level n has a set of decidable statements (encoded as integers).
    The hierarchy satisfies:
    - Monotonicity: level_set(m) ⊆ level_set(n) for m ≤ n
    - Strictness: level_set(n) ⊊ level_set(n+1) for all n
    """
    level_set: Callable[[int], Set[int]]
    max_level: int

    def is_monotone(self, N: int) -> bool:
        """Verify monotonicity on [0, N) up to max_level."""
        for m in range(self.max_level):
            for n in range(m + 1, self.max_level + 1):
                if not self.level_set(m).issubset(self.level_set(n)):
                    return False
        return True

    def is_strict(self, N: int) -> bool:
        """Verify strictness up to max_level."""
        for n in range(self.max_level):
            if not (self.level_set(n + 1) - self.level_set(n)):
                return False
        return True

    def estimate_level(self, statement: int) -> Optional[int]:
        """Estimate the minimum level needed to decide a statement."""
        for level in range(self.max_level + 1):
            if statement in self.level_set(level):
                return level
        return None  # beyond available levels


def oracle_guided_search(
    oracle: Callable[[int], OracleResponse],
    candidates: List[int],
    truth: Callable[[int], bool]
) -> Tuple[List[int], int]:
    """Oracle-guided proof search: use predictions to prioritize candidates.

    Algorithm:
    1. Query the oracle on all candidates
    2. Sort: TRUE predictions first, then UNKNOWN, then FALSE
    3. Search in this order

    The oracle acts as a heuristic: if sound, TRUE predictions are
    guaranteed correct, so checking them first finds solutions faster.

    Returns: (found truths, number of oracle queries)
    """
    # Query oracle on all candidates
    predictions = [(c, oracle(c)) for c in candidates]

    # Sort by prediction confidence
    priority = {
        OracleResponse.TRUE: 0,    # check these first
        OracleResponse.UNKNOWN: 1,  # then these
        OracleResponse.FALSE: 2     # last resort
    }
    predictions.sort(key=lambda x: priority[x[1]])

    # Search in priority order
    found: List[int] = []
    queries = len(candidates)

    for candidate, prediction in predictions:
        if truth(candidate):
            found.append(candidate)

    return found, queries


def proof_prediction_duality_table(
    N_values: List[int],
    proof_alphabet: int = 2,
    oracle_alphabet: int = 3
) -> List[Dict[str, float]]:
    """Generate the proof-prediction duality table.

    For each N, computes:
    - Proof space size: proof_alphabet^N
    - Oracle space size: oracle_alphabet^N
    - Ratio: oracle/proof
    - Log ratio: log2(oracle/proof)
    """
    results = []
    for N in N_values:
        proofs = proof_alphabet ** N
        oracles = oracle_alphabet ** N
        ratio = oracles / proofs if proofs > 0 else float('inf')
        log_ratio = N * math.log2(oracle_alphabet / proof_alphabet)
        results.append({
            "N": N,
            "proof_space": proofs,
            "oracle_space": oracles,
            "ratio": ratio,
            "log2_ratio": log_ratio
        })
    return results


# ── Utility: Primality Oracle ─────────────────────────────────────────────
def make_primality_oracle(
    confidence_threshold: int = 50
) -> RamanujanOracle:
    """Create a Ramanujan Oracle for primality testing.

    The oracle uses trial division for n < confidence_threshold
    and abstains for larger values (simulating limited intuition).
    """
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def predict(n: int) -> OracleResponse:
        if n < confidence_threshold:
            return OracleResponse.TRUE if is_prime(n) else OracleResponse.FALSE
        return OracleResponse.UNKNOWN

    return RamanujanOracle(predict=predict, truth_set=is_prime)


if __name__ == "__main__":
    # Quick self-test
    oracle = make_primality_oracle(confidence_threshold=30)
    result = evaluate_oracle(oracle, 100)
    print(f"Primality Oracle (threshold=30):")
    print(f"  Accuracy: {result.accuracy:.2%}")
    print(f"  Coverage: {result.coverage:.2%}")
    print(f"  Sound: {result.is_sound}")
    print(f"  Correct: {result.correct}, Wrong: {result.wrong}, Abstain: {result.abstain}")
    print()

    # Duality table
    table = proof_prediction_duality_table([1, 5, 10, 20, 50])
    print("Proof-Prediction Duality:")
    for row in table:
        print(f"  N={row['N']:3d}: proofs={row['proof_space']:>15,d}, "
              f"oracles={row['oracle_space']:>15,d}, ratio={row['ratio']:.2f}")
