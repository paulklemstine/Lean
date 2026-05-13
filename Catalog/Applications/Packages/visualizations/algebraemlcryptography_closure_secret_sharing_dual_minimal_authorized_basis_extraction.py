#!/usr/bin/env python3
"""
Algorithms for Closure–Secret-Sharing Duality

Implements the core algorithms from the research paper:
1. Minimal Authorized Basis Extraction (Algorithm 1)
2. Idempotent Semimodule Construction (Algorithm 2)
3. Reconstruction Certificate Generation (Algorithm 3)
4. Authorization Verification (Algorithm 4)
"""

from itertools import combinations
from typing import FrozenSet, Callable, List, Set, Dict, Tuple, Optional
from dataclasses import dataclass
import time


# ============================================================
# Algorithm 1: Minimal Authorized Basis Extraction
# ============================================================

def extract_minimal_basis(
    cl: Callable[[FrozenSet[int]], FrozenSet[int]],
    secret: int,
    participants: List[int],
    verbose: bool = False
) -> List[FrozenSet[int]]:
    """
    Algorithm 1: Extract the minimal authorized basis from a closure operator.

    Given a closure operator cl, a secret element, and participants,
    finds all minimal authorized coalitions (the antichain basis).

    Complexity: O(2^n * n) where n = |participants|
    Space: O(2^n) for storing authorized sets

    This is the computational core of the Closure–Secret-Sharing Duality.
    By Theorem B, this basis is unique and fully characterizes authorization.

    Parameters:
        cl: Closure operator (set -> set)
        secret: The secret element
        participants: List of participant identifiers
        verbose: Print progress information

    Returns:
        List of minimal authorized coalitions (frozensets)
    """
    n = len(participants)
    authorized: List[FrozenSet[int]] = []

    # Phase 1: Find all authorized coalitions (bottom-up by size)
    if verbose:
        print(f"Scanning {2**n} coalitions...")

    for size in range(1, n + 1):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            if secret in cl(S):
                authorized.append(S)

    if verbose:
        print(f"Found {len(authorized)} authorized coalitions")

    # Phase 2: Filter to minimal elements
    # A coalition is minimal if no proper subset is also authorized
    minimal: List[FrozenSet[int]] = []
    for S in authorized:
        is_minimal = True
        for T in authorized:
            if T < S:  # proper subset
                is_minimal = False
                break
        if is_minimal:
            minimal.append(S)

    if verbose:
        print(f"Extracted {len(minimal)} minimal authorized coalitions")

    return minimal


def extract_minimal_basis_optimized(
    cl: Callable[[FrozenSet[int]], FrozenSet[int]],
    secret: int,
    participants: List[int],
) -> List[FrozenSet[int]]:
    """
    Optimized version: scan bottom-up and prune supersets early.

    Complexity: O(2^n) worst case but much faster in practice
    due to early pruning of supersets of known authorized sets.
    """
    n = len(participants)
    minimal: List[FrozenSet[int]] = []

    for size in range(1, n + 1):
        for combo in combinations(participants, size):
            S = frozenset(combo)
            # Skip if S contains a known minimal authorized coalition
            if any(M <= S for M in minimal):
                continue
            if secret in cl(S):
                minimal.append(S)

    return minimal


# ============================================================
# Algorithm 2: Idempotent Semimodule Construction
# ============================================================

@dataclass
class SemimoduleRealization:
    """
    An idempotent access semimodule realization.

    Attributes:
        participants: List of participant identifiers
        basis: The antichain basis
        dimension: Number of basis elements (semimodule dimension)
        share_matrix: Dict mapping participant -> bool vector
        secret_vector: The target vector
    """
    participants: List[int]
    basis: List[FrozenSet[int]]
    dimension: int
    share_matrix: Dict[int, List[bool]]
    secret_vector: List[bool]

    def authorized(self, coalition: FrozenSet[int]) -> bool:
        """Check if a coalition is authorized."""
        return any(B <= coalition for B in self.basis)

    def minimal_witness(self, coalition: FrozenSet[int]) -> Optional[FrozenSet[int]]:
        """Find a minimal authorized sub-coalition."""
        for B in self.basis:
            if B <= coalition:
                return B
        return None

    def share_coverage(self, coalition: FrozenSet[int]) -> List[bool]:
        """Compute the OR-combination of shares for a coalition."""
        result = [False] * self.dimension
        for x in coalition:
            if x in self.share_matrix:
                for i in range(self.dimension):
                    result[i] = result[i] or self.share_matrix[x][i]
        return result


def construct_semimodule(
    participants: List[int],
    basis: List[FrozenSet[int]]
) -> SemimoduleRealization:
    """
    Algorithm 2: Construct an idempotent access semimodule from an antichain basis.

    The construction (Theorem C1) maps:
    - Each participant x to the indicator vector share(x)[i] = (x ∈ basis[i])
    - The secret to the all-True vector
    - Authorization to basis containment

    Complexity: O(n * k) where n = |participants|, k = |basis|
    """
    k = len(basis)
    share_matrix = {}
    for x in participants:
        share_matrix[x] = [x in B for B in basis]

    return SemimoduleRealization(
        participants=participants,
        basis=basis,
        dimension=k,
        share_matrix=share_matrix,
        secret_vector=[True] * k
    )


# ============================================================
# Algorithm 3: Reconstruction Certificate Generation
# ============================================================

@dataclass
class ReconstructionCertificate:
    """
    A certified minimal reconstruction certificate.

    Attributes:
        basis: The antichain basis (Finset of Finsets)
        is_valid_antichain: Whether the basis is an antichain
        is_minimal: Whether each basis element is truly minimal
        authorization_count: Total number of authorized coalitions
        compression_ratio: |basis| / |authorized coalitions|
    """
    basis: List[FrozenSet[int]]
    is_valid_antichain: bool
    is_minimal: bool
    authorization_count: int
    compression_ratio: float

    def verify(self, cl, secret: int, participants: List[int]) -> bool:
        """
        Fully verify the certificate against the closure operator.
        Returns True iff the certificate correctly characterizes authorization.
        """
        for size in range(len(participants) + 1):
            for combo in combinations(participants, size):
                S = frozenset(combo)
                auth_cl = secret in cl(S)
                auth_cert = any(B <= S for B in self.basis)
                if auth_cl != auth_cert:
                    return False
        return True


def generate_certificate(
    cl: Callable[[FrozenSet[int]], FrozenSet[int]],
    secret: int,
    participants: List[int]
) -> ReconstructionCertificate:
    """
    Algorithm 3: Generate a certified minimal reconstruction certificate.

    Implements Theorem E: from a finite accessible closure system,
    extract a certified minimal reconstruction certificate.

    Complexity: O(2^n * n) for basis extraction, O(k^2) for verification
    """
    basis = extract_minimal_basis_optimized(cl, secret, participants)

    # Verify antichain property
    is_antichain = True
    for i, U in enumerate(basis):
        for j, V in enumerate(basis):
            if i != j and U <= V:
                is_antichain = False

    # Verify minimality
    is_minimal = True
    for U in basis:
        for size in range(1, len(U)):
            for combo in combinations(U, size):
                V = frozenset(combo)
                if any(B <= V for B in basis):
                    is_minimal = False

    # Count authorized coalitions
    n_auth = 0
    for size in range(len(participants) + 1):
        for combo in combinations(participants, size):
            if any(B <= frozenset(combo) for B in basis):
                n_auth += 1

    return ReconstructionCertificate(
        basis=basis,
        is_valid_antichain=is_antichain,
        is_minimal=is_minimal,
        authorization_count=n_auth,
        compression_ratio=len(basis) / max(n_auth, 1)
    )


# ============================================================
# Algorithm 4: Fast Authorization Check
# ============================================================

def build_authorization_oracle(
    basis: List[FrozenSet[int]]
) -> Callable[[FrozenSet[int]], bool]:
    """
    Build a fast authorization oracle from the basis.

    Returns a function that checks authorization in O(k * m) time
    where k = |basis| and m = max |B| for B in basis.
    """
    # Sort basis by size for early termination
    sorted_basis = sorted(basis, key=len)

    def oracle(coalition: FrozenSet[int]) -> bool:
        for B in sorted_basis:
            if len(B) > len(coalition):
                break  # No larger basis element can be contained
            if B <= coalition:
                return True
        return False

    return oracle


# ============================================================
# Benchmarking
# ============================================================

def benchmark_algorithms(max_n: int = 12):
    """Benchmark the algorithms on threshold schemes of increasing size."""
    print("Benchmarking Minimal Basis Extraction")
    print(f"{'n':>4} {'|basis|':>8} {'|auth|':>8} {'time_naive':>12} {'time_opt':>12} {'speedup':>8}")
    print("-" * 60)

    for n in range(4, max_n + 1):
        universe = frozenset(range(n + 1))
        secret = 0
        participants = list(range(1, n + 1))

        def cl(S, _u=universe):
            return _u if len(S) >= 2 else S

        # Naive
        t0 = time.time()
        basis_naive = extract_minimal_basis(cl, secret, participants)
        t_naive = time.time() - t0

        # Optimized
        t0 = time.time()
        basis_opt = extract_minimal_basis_optimized(cl, secret, participants)
        t_opt = time.time() - t0

        n_auth = sum(1 for size in range(n + 1)
                     for combo in combinations(participants, size)
                     if any(B <= frozenset(combo) for B in basis_opt))

        speedup = t_naive / max(t_opt, 1e-9)
        print(f"{n:4d} {len(basis_opt):8d} {n_auth:8d} "
              f"{t_naive:12.6f} {t_opt:12.6f} {speedup:8.1f}x")


if __name__ == "__main__":
    # Quick demo
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Setup: (2,5)-threshold scheme
    n = 6
    universe = frozenset(range(n))
    cl = lambda S: universe if len(S) >= 2 else S
    secret = 0
    participants = list(range(1, n))

    # Algorithm 1
    basis = extract_minimal_basis(cl, secret, participants, verbose=True)

    # Algorithm 2
    semimod = construct_semimodule(participants, basis)
    print(f"\nSemimodule dimension: {semimod.dimension}")

    # Algorithm 3
    cert = generate_certificate(cl, secret, participants)
    print(f"\nCertificate: antichain={cert.is_valid_antichain}, "
          f"minimal={cert.is_minimal}, "
          f"compression={cert.compression_ratio:.3f}")
    print(f"Verified: {cert.verify(cl, secret, participants)}")

    # Algorithm 4
    oracle = build_authorization_oracle(basis)
    test = frozenset({1, 3})
    print(f"\nFast oracle({set(test)}): {oracle(test)}")

    # Benchmark
    print("\n")
    benchmark_algorithms(max_n=10)
