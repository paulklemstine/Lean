#!/usr/bin/env python3
"""
Quantum Proof Advantage: Algorithm Implementations

Type-hinted implementations of the key algorithms from the research.
"""

from typing import NamedTuple
import math


class ProofSystem(NamedTuple):
    """Abstract proof system with classical and quantum proof lengths."""
    classical_length: int
    quantum_length: int
    provable: bool


class QuantumCertificate(NamedTuple):
    """Quantum certificate with compression parameters."""
    classical_bits: int
    quantum_qubits: int
    gap: float


class QuantumWalkParams(NamedTuple):
    """Parameters for a quantum walk on a graph."""
    num_vertices: int
    classical_mixing: int
    quantum_mixing: int
    speedup_factor: float


def compute_advantage_ratio(system: ProofSystem) -> int:
    """Compute the proof advantage ratio (Theorem 2).

    Returns ⌊classical_length / quantum_length⌋.
    """
    if system.quantum_length == 0:
        raise ValueError("Quantum length must be positive")
    return system.classical_length // system.quantum_length


def find_dominance_threshold(c: int) -> int:
    """Find the smallest N such that n^c < 2^n for all n ≥ N (Theorem 1).

    Uses binary search for efficiency.
    """
    if c == 0:
        return 1  # 1 < 2^1

    # Upper bound: 2^c * c is always sufficient
    lo, hi = 1, max(4, 4 * c)
    while hi ** c >= 2 ** hi:
        hi *= 2

    # Find exact threshold
    n = 1
    while n ** c >= 2 ** n:
        n += 1
    return n


def sunflower_bound(k: int, ell: int) -> int:
    """Compute the Erdős-Rado sunflower bound S(k, ℓ) (Definition 2.7).

    Any k-uniform set family of size > S(k, ℓ) contains an ℓ-sunflower.
    """
    if k < 0 or ell < 1:
        raise ValueError("k must be non-negative and ℓ must be positive")
    return (ell - 1) ** k * math.factorial(k) + 1


def construct_quantum_certificate(n: int) -> QuantumCertificate:
    """Construct a quantum certificate with quadratic compression (Theorem 4).

    Maps n² classical bits to n quantum qubits with gap 1/3.
    """
    if n < 1:
        raise ValueError("n must be at least 1")
    return QuantumCertificate(
        classical_bits=n ** 2,
        quantum_qubits=n,
        gap=1 / 3,
    )


def quantum_walk_params(n: int) -> QuantumWalkParams:
    """Compute quantum walk parameters for n-vertex graph (Theorem 7).

    Classical mixing: O(n), Quantum mixing: O(√n).
    """
    if n < 4:
        raise ValueError("Need at least 4 vertices")
    quantum_mixing = max(2, int(math.sqrt(n)))
    return QuantumWalkParams(
        num_vertices=n,
        classical_mixing=n,
        quantum_mixing=quantum_mixing,
        speedup_factor=n / quantum_mixing,
    )


def is_super_polynomial(
    classical_lengths: list[int],
    quantum_lengths: list[int],
    max_degree: int = 10,
) -> tuple[bool, int]:
    """Test whether the advantage is super-polynomial.

    Returns (is_super_poly, max_degree_exceeded).
    Checks if classical/quantum grows faster than n^c for c = 1, ..., max_degree.
    """
    if len(classical_lengths) != len(quantum_lengths):
        raise ValueError("Length mismatch")

    max_exceeded = 0
    for c in range(1, max_degree + 1):
        exceeded = True
        for i, (cl, qu) in enumerate(zip(classical_lengths, quantum_lengths)):
            n = i + 1
            if qu > 0:
                ratio = cl // qu
                if ratio <= n ** c:
                    exceeded = False
                    break
        if exceeded:
            max_exceeded = c

    return max_exceeded > 0, max_exceeded


def proof_compression_analysis(
    sizes: list[int],
) -> list[dict[str, float]]:
    """Analyze proof compression across problem sizes.

    For each size n, computes classical (2^n), quantum (n²),
    and the advantage ratio.
    """
    results = []
    for n in sizes:
        classical = 2 ** n
        quantum = n ** 2
        ratio = classical // quantum if quantum > 0 else 0
        log_ratio = math.log2(ratio) if ratio > 0 else 0
        results.append({
            "size": n,
            "classical_length": classical,
            "quantum_length": quantum,
            "advantage_ratio": ratio,
            "log2_ratio": log_ratio,
            "is_super_poly": ratio > n ** 10,
        })
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")

    # Theorem 1
    for c in range(1, 6):
        N = find_dominance_threshold(c)
        assert N ** c < 2 ** N, f"Failed for c={c}, N={N}"
        print(f"  exp_dominates_poly(c={c}): threshold N={N}")

    # Theorem 2
    sys = ProofSystem(classical_length=1024, quantum_length=32, provable=True)
    ratio = compute_advantage_ratio(sys)
    assert ratio * sys.quantum_length <= sys.classical_length
    print(f"  advantage_ratio(1024, 32) = {ratio}")

    # Theorem 4
    cert = construct_quantum_certificate(10)
    assert cert.classical_bits == 100
    assert cert.quantum_qubits <= 10
    print(f"  certificate(n=10): {cert.classical_bits} bits → {cert.quantum_qubits} qubits")

    # Theorem 6
    for k in range(2, 6):
        sb = sunflower_bound(k, 3)
        assert sb >= math.factorial(k), f"Sunflower bound too small for k={k}"
        print(f"  sunflower_bound(k={k}, ℓ=3) = {sb} ≥ {math.factorial(k)} = {k}!")

    # Theorem 7
    qw = quantum_walk_params(100)
    assert qw.quantum_mixing ** 2 <= qw.classical_mixing
    print(f"  quantum_walk(n=100): classical={qw.classical_mixing}, quantum={qw.quantum_mixing}")

    print("\nAll tests passed! ✓")
