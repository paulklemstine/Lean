#!/usr/bin/env python3
"""
Algorithms for Algebraic Fingerprinting and Polynomial Identity Testing

Implements the key algorithms from the research paper with full
documentation, type hints, and complexity analysis.
"""

import random
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ============================================================================
# Algorithm 1: Algebraic Fingerprint Equality Test
# ============================================================================

@dataclass
class FingerprintResult:
    """Result of a fingerprint equality test."""
    equal: bool
    evaluation_point: int
    fingerprint_a: int
    fingerprint_b: int
    field_size: int
    vector_length: int
    error_bound: float


def algebraic_fingerprint_test(
    a: List[int],
    b: List[int],
    p: int,
    num_trials: int = 1
) -> FingerprintResult:
    """
    Algebraic Fingerprint Equality Test

    Tests whether two integer vectors a and b are equal by encoding them
    as polynomials and evaluating at random field points.

    Algorithm:
        1. Encode a as p_a(X) = sum(a[i] * X^i)
        2. Encode b as p_b(X) = sum(b[i] * X^i)
        3. Pick random r in GF(p)
        4. Compare p_a(r) vs p_b(r)

    Complexity:
        Time:  O(n) per trial for polynomial evaluation
        Space: O(1) beyond input (streaming-compatible)
        Communication: O(log p) bits per trial

    Soundness (from fingerprint_collision_bound):
        If a != b, Pr[p_a(r) = p_b(r)] <= (n-1)/p per trial.
        With k independent trials: error <= ((n-1)/p)^k.

    Args:
        a: First vector (integers mod p)
        b: Second vector (integers mod p)
        p: Prime defining the field GF(p)
        num_trials: Number of independent random evaluations

    Returns:
        FingerprintResult with equality verdict and metadata.
    """
    assert len(a) == len(b), "Vectors must have equal length"
    n = len(a)

    for _ in range(num_trials):
        r = random.randint(0, p - 1)

        # Evaluate polynomials using Horner's method: O(n) time, O(1) space
        fa = 0
        fb = 0
        for i in range(n - 1, -1, -1):
            fa = (fa * r + a[i]) % p
            fb = (fb * r + b[i]) % p

        if fa != fb:
            return FingerprintResult(
                equal=False,
                evaluation_point=r,
                fingerprint_a=fa,
                fingerprint_b=fb,
                field_size=p,
                vector_length=n,
                error_bound=0.0  # Definite inequality
            )

    error_bound = ((n - 1) / p) ** num_trials
    return FingerprintResult(
        equal=True,
        evaluation_point=r,
        fingerprint_a=fa,
        fingerprint_b=fb,
        field_size=p,
        vector_length=n,
        error_bound=error_bound
    )


# ============================================================================
# Algorithm 2: Streaming Fingerprint Verifier
# ============================================================================

class StreamingFingerprinter:
    """
    Streaming polynomial fingerprint with O(log p) memory.

    Maintains the running evaluation of p_s(r) = sum(s[i] * r^i)
    as stream elements arrive one at a time.

    Complexity:
        Space: O(log p) bits (stores r, current value, current power of r)
        Time per element: O(1) field operations
        Total time: O(n)

    This is the formal core of Rabin-Karp style hashing.
    """

    def __init__(self, p: int, evaluation_point: Optional[int] = None):
        """Initialize with field GF(p) and optional evaluation point."""
        self.p = p
        self.r = evaluation_point if evaluation_point is not None else random.randint(0, p - 1)
        self.value = 0       # Running fingerprint
        self.r_power = 1     # Current power of r
        self.count = 0       # Elements seen

    def feed(self, element: int) -> None:
        """Process one stream element. O(1) time, O(1) space."""
        self.value = (self.value + element * self.r_power) % self.p
        self.r_power = (self.r_power * self.r) % self.p
        self.count += 1

    def fingerprint(self) -> int:
        """Return current fingerprint value."""
        return self.value

    def compare(self, other: 'StreamingFingerprinter') -> Tuple[bool, float]:
        """
        Compare fingerprints from two streams.

        Returns (match, error_bound) where:
        - match = True means fingerprints agree (streams might be equal)
        - error_bound = (n-1)/p upper bounds false positive probability

        By fingerprint_collision_bound, if streams differ,
        Pr[match] <= (n-1)/p.
        """
        match = self.fingerprint() == other.fingerprint()
        n = max(self.count, other.count)
        error = (n - 1) / self.p if n > 0 else 0.0
        return match, error


# ============================================================================
# Algorithm 3: Multivariate PIT via Schwartz-Zippel
# ============================================================================

def schwartz_zippel_pit(
    eval_circuit: Callable[..., int],
    n_vars: int,
    degree_bound: int,
    p: int,
    num_trials: int = 10
) -> Tuple[bool, float]:
    """
    Polynomial Identity Testing via Schwartz-Zippel

    Tests whether an arithmetic circuit computes the zero polynomial
    by evaluating at random points over GF(p).

    Algorithm:
        1. For each trial:
           a. Sample random point r in GF(p)^n
           b. Evaluate circuit at r
           c. If result != 0, circuit is nonzero (certain)
        2. If all trials give 0, report "likely zero"

    Soundness (from schwartz_zippel_subtype):
        If circuit is nonzero with degree d, then
        Pr[eval(r) = 0] <= d/p per trial.
        With k trials: false zero probability <= (d/p)^k.

    Complexity:
        Time: O(circuit_size * num_trials)
        Space: O(n) for storing the random point
        Randomness: O(n * log(p) * num_trials) random bits

    Args:
        eval_circuit: Function (x1, ..., xn) -> result in GF(p)
        n_vars: Number of variables
        degree_bound: Upper bound on total degree
        p: Prime for the field
        num_trials: Number of random evaluations

    Returns:
        (is_zero, error_bound): verdict and false positive probability
    """
    for _ in range(num_trials):
        point = [random.randint(0, p - 1) for _ in range(n_vars)]
        result = eval_circuit(*point) % p
        if result != 0:
            return False, 0.0  # Definitely nonzero

    error = (degree_bound / p) ** num_trials
    return True, error


# ============================================================================
# Algorithm 4: Circuit Degree Bound Analyzer
# ============================================================================

@dataclass
class CircuitGate:
    """A gate in an arithmetic circuit."""
    op: str           # 'input', 'const', 'add', 'mul'
    inputs: Tuple     # Indices of input gates
    value: int        # Constant value (for 'const' gates)
    degree: int = 0   # Computed degree bound


def analyze_circuit_degree(gates: List[CircuitGate]) -> int:
    """
    Compute a degree upper bound for an arithmetic circuit.

    Uses the standard syntactic degree bound:
    - Input gate: degree 1
    - Constant gate: degree 0
    - Add gate: max(degree(left), degree(right))
    - Mul gate: degree(left) + degree(right)

    This is the formal `boundedCircuitDegree` from the research.

    Complexity: O(|circuit|) time and space.

    Args:
        gates: List of circuit gates in topological order

    Returns:
        Upper bound on the total degree of the computed polynomial
    """
    degrees = [0] * len(gates)

    for i, gate in enumerate(gates):
        if gate.op == 'input':
            degrees[i] = 1
        elif gate.op == 'const':
            degrees[i] = 0
        elif gate.op == 'add':
            left, right = gate.inputs
            degrees[i] = max(degrees[left], degrees[right])
        elif gate.op == 'mul':
            left, right = gate.inputs
            degrees[i] = degrees[left] + degrees[right]
        gate.degree = degrees[i]

    return degrees[-1] if degrees else 0


def count_mul_gates(gates: List[CircuitGate]) -> int:
    """Count multiplication gates in a circuit."""
    return sum(1 for g in gates if g.op == 'mul')


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("Algorithm 1: Fingerprint Equality Test")
    print("-" * 40)
    a = [1, 2, 3, 4, 5]
    b = [1, 2, 3, 4, 6]
    result = algebraic_fingerprint_test(a, b, p=101, num_trials=3)
    print(f"a = {a}")
    print(f"b = {b}")
    print(f"Equal: {result.equal}")
    print(f"Error bound: {result.error_bound:.2e}")
    print()

    print("Algorithm 2: Streaming Fingerprint")
    print("-" * 40)
    p = 101
    fp1 = StreamingFingerprinter(p, evaluation_point=42)
    fp2 = StreamingFingerprinter(p, evaluation_point=42)
    stream1 = [1, 0, 1, 1, 0]
    stream2 = [1, 0, 1, 0, 0]
    for x in stream1:
        fp1.feed(x)
    for x in stream2:
        fp2.feed(x)
    match, err = fp1.compare(fp2)
    print(f"Stream 1: {stream1}")
    print(f"Stream 2: {stream2}")
    print(f"Fingerprints match: {match}")
    print(f"Error bound: {err:.4f}")
    print()

    print("Algorithm 3: Multivariate PIT")
    print("-" * 40)
    # Test x*y - x*y (the zero polynomial)
    is_zero, err = schwartz_zippel_pit(
        lambda x, y: (x * y - x * y),
        n_vars=2, degree_bound=2, p=101, num_trials=5
    )
    print(f"Polynomial: x*y - x*y")
    print(f"Is zero: {is_zero}, error: {err:.2e}")

    # Test x*y + 1 (nonzero)
    is_zero, err = schwartz_zippel_pit(
        lambda x, y: (x * y + 1),
        n_vars=2, degree_bound=2, p=101, num_trials=5
    )
    print(f"Polynomial: x*y + 1")
    print(f"Is zero: {is_zero}, error: {err:.2e}")
    print()

    print("Algorithm 4: Circuit Degree Analysis")
    print("-" * 40)
    # Circuit for (x + 1) * (y + 2)
    gates = [
        CircuitGate('input', (), 0),     # gate 0: x
        CircuitGate('const', (), 1),     # gate 1: 1
        CircuitGate('add', (0, 1), 0),   # gate 2: x + 1
        CircuitGate('input', (), 0),     # gate 3: y
        CircuitGate('const', (), 2),     # gate 4: 2
        CircuitGate('add', (3, 4), 0),   # gate 5: y + 2
        CircuitGate('mul', (2, 5), 0),   # gate 6: (x+1)(y+2)
    ]
    degree = analyze_circuit_degree(gates)
    muls = count_mul_gates(gates)
    print(f"Circuit: (x + 1) * (y + 2)")
    print(f"Degree bound: {degree}")
    print(f"Multiplication gates: {muls}")
    print(f"Degree ≤ 2^(mul_gates) = {2**muls}")
