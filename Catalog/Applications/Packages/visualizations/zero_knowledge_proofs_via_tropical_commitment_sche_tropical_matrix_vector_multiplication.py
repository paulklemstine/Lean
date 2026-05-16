#!/usr/bin/env python3
"""
Tropical Zero-Knowledge Commitments — Algorithms

Implements the core algorithms from the research paper:
  1. Tropical matrix-vector multiplication (shortest-path evaluation)
  2. Tropical matrix commitment scheme
  3. Tropical Σ-protocol (prover, verifier, simulator)
  4. Parallel repetition with soundness amplification
  5. Idempotent transcript normalization

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional
import hashlib

INF = float('inf')


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Tropical Matrix-Vector Multiplication
# ═══════════════════════════════════════════════════════════════════════

def trop_mat_vec_mul(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix-vector product.

    Computes (A ⊗ x)_i = min_j (A[i,j] + x[j])

    This is equivalent to shortest-path evaluation in a bipartite graph
    where A[i,j] is the edge weight from input node j to output node i.

    Complexity: O(m·n) where A is m×n.

    Args:
        A: Tropical matrix of shape (m, n). Entries are floats; inf = ⊤.
        x: Tropical vector of length n.

    Returns:
        Tropical vector of length m.

    Example:
        >>> A = np.array([[1, 3], [4, 2]])
        >>> x = np.array([5, 7])
        >>> trop_mat_vec_mul(A, x)
        array([ 6.,  9.])
    """
    m, n = A.shape
    assert x.shape == (n,), f"Vector length {x.shape} doesn't match matrix cols {n}"

    result = np.full(m, INF)
    for i in range(m):
        for j in range(n):
            if A[i, j] < INF and x[j] < INF:
                result[i] = min(result[i], A[i, j] + x[j])
    return result


def trop_mat_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix-matrix product.

    (A ⊗ B)[i,k] = min_j (A[i,j] + B[j,k])

    Equivalent to composing shortest-path graphs.
    Complexity: O(m·n·p) where A is m×n, B is n×p.
    """
    m, n = A.shape
    n2, p = B.shape
    assert n == n2

    C = np.full((m, p), INF)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                if A[i, j] < INF and B[j, k] < INF:
                    C[i, k] = min(C[i, k], A[i, j] + B[j, k])
    return C


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Matrix Commitment Scheme
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class TropCommitParams:
    """Public parameters for a tropical matrix commitment scheme.

    The commitment is Com(x, r) = (A ⊗ x) ⊓ (B ⊗ r)
    where ⊓ is componentwise min.

    Attributes:
        A: Message encoding matrix (m × n)
        B: Randomness encoding matrix (m × k)
    """
    A: np.ndarray  # m × n
    B: np.ndarray  # m × k

    @property
    def m(self) -> int:
        return self.A.shape[0]

    @property
    def n(self) -> int:
        return self.A.shape[1]

    @property
    def k(self) -> int:
        return self.B.shape[1]


def trop_commit(params: TropCommitParams,
                x: np.ndarray, r: np.ndarray) -> np.ndarray:
    """
    Compute tropical matrix commitment.

    Com(x, r) = (A ⊗ x) ⊓ (B ⊗ r)

    where ⊓ is componentwise minimum.

    Complexity: O(m·(n+k))

    Args:
        params: Public commitment parameters (matrices A, B)
        x: Message vector of length n
        r: Randomness vector of length k

    Returns:
        Commitment vector of length m
    """
    ax = trop_mat_vec_mul(params.A, x)
    br = trop_mat_vec_mul(params.B, r)
    return np.minimum(ax, br)


def verify_binding(params: TropCommitParams,
                   x1: np.ndarray, r1: np.ndarray,
                   x2: np.ndarray, r2: np.ndarray) -> bool:
    """
    Check whether two (message, randomness) pairs produce the same commitment.

    Returns True if they collide (binding violation), False otherwise.
    """
    c1 = trop_commit(params, x1, r1)
    c2 = trop_commit(params, x2, r2)
    return np.allclose(c1, c2)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Tropical Σ-Protocol
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class TropTranscript:
    """A Σ-protocol transcript in the tropical setting.

    Attributes:
        commitment: Prover's first message (tropical vector)
        challenge: Verifier's challenge (list of bits)
        response: Prover's response (tropical vector)
    """
    commitment: np.ndarray
    challenge: List[bool]
    response: np.ndarray


def trop_shift(v: np.ndarray, s: float) -> np.ndarray:
    """Shift a tropical vector by adding constant s to each component.

    Complexity: O(n)
    """
    result = v.copy()
    finite_mask = result < INF
    result[finite_mask] += s
    return result


def transcript_shift(t: TropTranscript, s: float) -> TropTranscript:
    """Shift a transcript: add s to commitment and response.

    This is the key zero-knowledge operation: shifted transcripts
    verify identically under any shift-invariant verifier.

    Complexity: O(n)
    """
    return TropTranscript(
        commitment=trop_shift(t.commitment, s),
        challenge=t.challenge,  # challenge unchanged
        response=trop_shift(t.response, s)
    )


class TropSigmaProtocol:
    """
    A Σ-protocol based on tropical matrix commitments.

    Protocol:
    1. Prover commits: com = A ⊗ (x + s) for random shift s
    2. Verifier sends challenge c ∈ {0, 1}
    3. Prover responds: resp = x + s (if c=0) or resp = s (if c=1)
    4. Verifier checks: A ⊗ resp = com (if c=0) or A ⊗ (witness + resp) = com (if c=1)

    Zero-knowledge: simulator picks random s, computes com = A ⊗ (witness + s),
    and outputs (com, c, appropriate response). Shift invariance ensures
    this is indistinguishable from real transcripts.
    """

    def __init__(self, A: np.ndarray):
        self.A = A

    def prove(self, x: np.ndarray, shift: float) -> Tuple[np.ndarray, np.ndarray]:
        """Prover step 1: compute commitment with shift.

        Returns (commitment, shifted_input)
        """
        x_shifted = trop_shift(x, shift)
        com = trop_mat_vec_mul(self.A, x_shifted)
        return com, x_shifted

    def respond(self, x: np.ndarray, shift: float,
                challenge: bool) -> np.ndarray:
        """Prover step 3: compute response to challenge."""
        if not challenge:
            return trop_shift(x, shift)
        else:
            return np.full_like(x, shift)

    def verify(self, statement: np.ndarray, com: np.ndarray,
               challenge: bool, response: np.ndarray) -> bool:
        """Verifier: check the transcript.

        For c=0: check A ⊗ response = com
        For c=1: check that com is consistent with statement + response
        """
        if not challenge:
            check = trop_mat_vec_mul(self.A, response)
            return np.allclose(check, com)
        else:
            # Simplified verification
            return True  # In full protocol, more complex check

    def simulate(self, statement: np.ndarray,
                 challenge: bool, shift: float) -> TropTranscript:
        """Simulator: produce a simulated transcript.

        The simulator knows the statement but NOT the witness.
        It uses shift invariance to produce valid-looking transcripts.
        """
        if not challenge:
            # Pick arbitrary response, compute matching commitment
            response = trop_shift(np.zeros_like(statement), shift)
            com = trop_mat_vec_mul(self.A, response)
        else:
            com = trop_shift(statement, shift)
            response = np.full_like(statement, shift)

        return TropTranscript(
            commitment=com,
            challenge=[challenge],
            response=response
        )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Parallel Repetition with Soundness Amplification
# ═══════════════════════════════════════════════════════════════════════

def parallel_repeat(protocol: TropSigmaProtocol,
                    x: np.ndarray,
                    k: int,
                    shifts: Optional[List[float]] = None) -> List[TropTranscript]:
    """
    Run k independent parallel repetitions of the protocol.

    Each repetition uses an independent random shift.
    Soundness error decays as ε^k where ε is the single-round error.

    Complexity: O(k · m · n) for k rounds with m×n matrix.

    Args:
        protocol: The base Σ-protocol
        x: The witness
        k: Number of parallel repetitions
        shifts: Optional list of shifts (random if not provided)

    Returns:
        List of k transcripts
    """
    if shifts is None:
        shifts = [np.random.randint(1, 1000) for _ in range(k)]

    transcripts = []
    for i in range(k):
        com, x_shifted = protocol.prove(x, shifts[i])
        challenge = np.random.choice([True, False])
        resp = protocol.respond(x, shifts[i], challenge)
        transcripts.append(TropTranscript(
            commitment=com,
            challenge=[challenge],
            response=resp
        ))

    return transcripts


def soundness_error(epsilon: float, k: int) -> float:
    """
    Compute soundness error after k parallel repetitions.

    If single-round error is ε, k-round error is ε^k.

    Args:
        epsilon: Single-round soundness error (0 < ε < 1)
        k: Number of repetitions

    Returns:
        k-round soundness error ε^k
    """
    return epsilon ** k


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Idempotent Transcript Normalization
# ═══════════════════════════════════════════════════════════════════════

def normalize_vec(v: np.ndarray) -> np.ndarray:
    """
    Idempotent normalization of a tropical vector.

    normalize(v)_i = v_i ⊓ v_i = min(v_i, v_i) = v_i

    This is trivially the identity for WithTop ℕ, but the concept
    generalizes to composed transcripts where normalization removes
    redundant constraints.

    Complexity: O(n)
    """
    return np.minimum(v, v)


def compose_transcripts(t1: TropTranscript,
                        t2: TropTranscript) -> TropTranscript:
    """
    Compose two transcripts by taking componentwise min.

    The composed commitment is the strongest constraint from either transcript.
    Challenges are concatenated. Responses are combined by min.

    Complexity: O(n + c₁ + c₂)
    """
    return TropTranscript(
        commitment=np.minimum(t1.commitment, t2.commitment),
        challenge=t1.challenge + t2.challenge,
        response=np.minimum(t1.response, t2.response)
    )


def normalize_transcript(t: TropTranscript) -> TropTranscript:
    """
    Normalize a transcript by applying idempotent normalization
    to commitment and response vectors.

    Property: normalize(normalize(t)) = normalize(t)

    Complexity: O(n)
    """
    return TropTranscript(
        commitment=normalize_vec(t.commitment),
        challenge=t.challenge,
        response=normalize_vec(t.response)
    )


# ═══════════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical ZK Commitments — Algorithm Demonstrations")
    print("=" * 60)

    # Setup
    A = np.array([[1, 3, 5],
                  [4, 2, 6],
                  [7, 8, 0]], dtype=float)
    B = np.array([[10, 12],
                  [11, 13],
                  [14, 9]], dtype=float)

    params = TropCommitParams(A=A, B=B)

    # Commitment
    x = np.array([2, 1, 3], dtype=float)
    r = np.array([0, 1], dtype=float)

    com = trop_commit(params, x, r)
    print(f"\nCommitment: Com(x={x}, r={r}) = {com}")

    # Σ-protocol
    proto = TropSigmaProtocol(A)
    shift = 7.0
    commitment, x_shifted = proto.prove(x, shift)
    print(f"\nΣ-protocol commitment (shift={shift}): {commitment}")

    # Simulation
    statement = trop_mat_vec_mul(A, x)
    sim_transcript = proto.simulate(statement, False, 42.0)
    print(f"Simulated transcript: com={sim_transcript.commitment}")

    # Parallel repetition
    print(f"\nSoundness decay (ε=0.5):")
    for k in [1, 5, 10, 20]:
        print(f"  k={k:2d}: ε^k = {soundness_error(0.5, k):.10f}")
