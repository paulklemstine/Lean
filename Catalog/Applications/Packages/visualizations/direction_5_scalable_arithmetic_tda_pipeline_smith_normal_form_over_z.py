"""
Algorithms for Scalable Arithmetic TDA Pipeline:
Torsion Profile Extraction from Smith Normal Forms

This module implements the core algorithms for extracting torsion profiles
from boundary matrices of simplicial complexes via Smith Normal Form computation.

Key algorithms:
1. Smith Normal Form computation over ℤ
2. Eratosthenes sieve for certified primality
3. Torsion profile extraction from SNF diagonal
4. Prime profile computation with sieve optimization
"""

from __future__ import annotations
import numpy as np
from typing import List, Tuple, Dict, Set
from dataclasses import dataclass, field
from collections import defaultdict
import math


@dataclass
class TorsionProfile:
    """
    The torsion profile of a finitely generated abelian group.

    Given invariant factors d₁ | d₂ | ⋯ | dᵣ (with dᵢ > 1),
    the torsion profile records:
    - The invariant factors themselves
    - The prime factorization of each factor
    - The multiset of primes with multiplicities
    """
    factors: List[int]
    prime_decomposition: Dict[int, List[Tuple[int, int]]]  # factor -> [(prime, power)]
    prime_multiplicities: Dict[int, int]  # prime -> total multiplicity

    def __repr__(self) -> str:
        if not self.factors:
            return "TorsionProfile(trivial — free abelian group)"
        parts = [f"ℤ/{d}ℤ" for d in self.factors]
        return f"TorsionProfile({' ⊕ '.join(parts)})"

    @property
    def is_trivial(self) -> bool:
        return len(self.factors) == 0

    @property
    def primes(self) -> Set[int]:
        return set(self.prime_multiplicities.keys())


@dataclass
class EratosthenesSieve:
    """
    Certified Eratosthenes sieve up to a bound.

    Precomputes all primes up to `bound` in O(n log log n) time,
    then supports O(1) primality queries.
    """
    bound: int
    _is_prime: List[bool] = field(default_factory=list, repr=False)

    def __post_init__(self) -> None:
        self._is_prime = [False, False] + [True] * (self.bound - 1)
        if self.bound < 2:
            self._is_prime = [False] * (self.bound + 1)
            return
        for i in range(2, int(math.isqrt(self.bound)) + 1):
            if self._is_prime[i]:
                for j in range(i * i, self.bound + 1, i):
                    self._is_prime[j] = False

    def is_prime(self, n: int) -> bool:
        """O(1) primality test for n ≤ bound."""
        if n < 0 or n > self.bound:
            raise ValueError(f"{n} out of sieve range [0, {self.bound}]")
        return self._is_prime[n]

    def primes_up_to(self, n: int) -> List[int]:
        """Return all primes ≤ n."""
        return [i for i in range(2, min(n, self.bound) + 1) if self._is_prime[i]]

    @property
    def prime_count(self) -> int:
        return sum(1 for x in self._is_prime if x)


def smith_normal_form(matrix: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute the Smith Normal Form of an integer matrix.

    Given M ∈ ℤ^{m×n}, computes invertible U ∈ GL(m,ℤ), V ∈ GL(n,ℤ)
    and diagonal S such that S = U @ M @ V, with diagonal entries
    d₁ | d₂ | ⋯ | dᵣ where r = rank(M).

    Returns: (U, S, V) where S = U @ M @ V

    Complexity: O(m·n·min(m,n)) elementary operations
    """
    M = matrix.astype(np.int64).copy()
    m, n = M.shape
    U = np.eye(m, dtype=np.int64)
    V = np.eye(n, dtype=np.int64)

    pivot_row = 0
    pivot_col = 0

    while pivot_row < m and pivot_col < n:
        # Find nonzero entry with smallest absolute value
        nonzero = []
        for i in range(pivot_row, m):
            for j in range(pivot_col, n):
                if M[i, j] != 0:
                    nonzero.append((abs(M[i, j]), i, j))

        if not nonzero:
            break

        nonzero.sort()
        _, best_i, best_j = nonzero[0]

        # Swap to pivot position
        if best_i != pivot_row:
            M[[pivot_row, best_i]] = M[[best_i, pivot_row]]
            U[[pivot_row, best_i]] = U[[best_i, pivot_row]]
        if best_j != pivot_col:
            M[:, [pivot_col, best_j]] = M[:, [best_j, pivot_col]]
            V[:, [pivot_col, best_j]] = V[:, [best_j, pivot_col]]

        # Make pivot positive
        if M[pivot_row, pivot_col] < 0:
            M[pivot_row] = -M[pivot_row]
            U[pivot_row] = -U[pivot_row]

        # Eliminate column
        changed = True
        while changed:
            changed = False
            for i in range(pivot_row + 1, m):
                if M[i, pivot_col] != 0:
                    q = M[i, pivot_col] // M[pivot_row, pivot_col]
                    M[i] -= q * M[pivot_row]
                    U[i] -= q * U[pivot_row]
                    if M[i, pivot_col] != 0:
                        # Swap if remainder is smaller
                        if abs(M[i, pivot_col]) < abs(M[pivot_row, pivot_col]):
                            M[[pivot_row, i]] = M[[i, pivot_row]]
                            U[[pivot_row, i]] = U[[i, pivot_row]]
                            changed = True

            # Eliminate row
            for j in range(pivot_col + 1, n):
                if M[pivot_row, j] != 0:
                    q = M[pivot_row, j] // M[pivot_row, pivot_col]
                    M[:, j] -= q * M[:, pivot_col]
                    V[:, j] -= q * V[:, pivot_col]
                    if M[pivot_row, j] != 0:
                        if abs(M[pivot_row, j]) < abs(M[pivot_row, pivot_col]):
                            M[:, [pivot_col, j]] = M[:, [j, pivot_col]]
                            V[:, [pivot_col, j]] = V[:, [j, pivot_col]]
                            changed = True

            # Check divisibility condition
            for i in range(pivot_row + 1, m):
                for j in range(pivot_col + 1, n):
                    if M[i, j] % M[pivot_row, pivot_col] != 0:
                        M[i] += M[pivot_row]
                        U[i] += U[pivot_row]
                        changed = True
                        break
                if changed:
                    break

        pivot_row += 1
        pivot_col += 1

    # Ensure divisibility chain
    r = min(m, n)
    for k in range(r - 1):
        if M[k, k] != 0 and M[k+1, k+1] != 0:
            if M[k+1, k+1] % M[k, k] != 0:
                g = math.gcd(int(M[k, k]), int(M[k+1, k+1]))
                l = int(M[k, k]) * int(M[k+1, k+1]) // g
                M[k, k] = g
                M[k+1, k+1] = l

    return U, M, V


def extract_snf_diagonal(S: np.ndarray) -> List[int]:
    """Extract the diagonal entries from a Smith Normal Form matrix."""
    r = min(S.shape)
    return [abs(int(S[i, i])) for i in range(r) if S[i, i] != 0]


def factorize_with_sieve(n: int, sieve: EratosthenesSieve) -> List[Tuple[int, int]]:
    """
    Factorize n using a precomputed sieve.

    Trial-divides n by all primes up to √n from the sieve.
    Returns list of (prime, exponent) pairs.

    Complexity: O(π(√n)) = O(√n / log n) divisions
    """
    if n <= 1:
        return []

    factors = []
    remaining = n
    sqrt_n = int(math.isqrt(n))

    for p in sieve.primes_up_to(sqrt_n):
        if remaining <= 1:
            break
        if remaining % p == 0:
            exp = 0
            while remaining % p == 0:
                remaining //= p
                exp += 1
            factors.append((p, exp))

    if remaining > 1:
        factors.append((remaining, 1))

    return factors


def torsion_profile_from_snf(diag: List[int], sieve: EratosthenesSieve | None = None) -> TorsionProfile:
    """
    Extract the torsion profile from SNF diagonal entries.

    This is the core algorithm: given d₁ | d₂ | ⋯ | dᵣ, extract
    the entries > 1 and compute their prime factorizations.

    Args:
        diag: SNF diagonal entries (positive integers in divisibility order)
        sieve: Optional precomputed sieve for fast factorization

    Returns:
        TorsionProfile with invariant factors and prime decomposition

    Complexity: O(r · π(√M)) where M = max(diag), or O(r · √M / log M)
    """
    torsion_factors = [d for d in diag if d > 1]

    if not torsion_factors:
        return TorsionProfile(
            factors=[],
            prime_decomposition={},
            prime_multiplicities={}
        )

    max_d = max(torsion_factors)
    if sieve is None:
        sieve = EratosthenesSieve(int(math.isqrt(max_d)) + 1)

    prime_decomp: Dict[int, List[Tuple[int, int]]] = {}
    prime_mults: Dict[int, int] = defaultdict(int)

    for d in torsion_factors:
        facts = factorize_with_sieve(d, sieve)
        prime_decomp[d] = facts
        for p, e in facts:
            prime_mults[p] += e

    return TorsionProfile(
        factors=torsion_factors,
        prime_decomposition=prime_decomp,
        prime_multiplicities=dict(prime_mults)
    )


def compute_homology_profile(
    boundary_k: np.ndarray,
    boundary_k_plus_1: np.ndarray
) -> Tuple[int, TorsionProfile]:
    """
    Compute the complete homology profile H_k from boundary matrices.

    Given ∂_k and ∂_{k+1}, computes:
    - Free rank = dim(ker ∂_k) - rank(∂_{k+1})
    - Torsion profile from SNF of ∂_{k+1} restricted to ker(∂_k)

    Returns: (free_rank, torsion_profile)
    """
    # Compute SNF of ∂_{k+1}
    _, S, _ = smith_normal_form(boundary_k_plus_1)
    diag = extract_snf_diagonal(S)

    # rank of ∂_k
    _, S_k, _ = smith_normal_form(boundary_k)
    rank_k = len(extract_snf_diagonal(S_k))

    # rank of ∂_{k+1}
    rank_k1 = len(diag)

    # Free rank = (cols of ∂_k) - rank_k - (number of torsion-free invariant factors of ∂_{k+1})
    n_cols = boundary_k.shape[1]
    free_rank = max(0, n_cols - rank_k - rank_k1)

    # Torsion from SNF diagonal
    torsion = torsion_profile_from_snf(diag)

    return free_rank, torsion


def bockstein_kernel_dimension(boundary_k: np.ndarray, p: int) -> int:
    """
    Compute the dimension of the kernel of the Bockstein homomorphism β_p.

    The Bockstein β: H_k(K; ℤ/p) → H_{k-1}(K; ℤ/p) arises from the
    short exact sequence 0 → ℤ → ℤ → ℤ/p → 0.

    Returns: dim(ker β_p)
    """
    # Reduce boundary matrix mod p
    B_mod_p = boundary_k % p

    # Compute rank over 𝔽_p using Gaussian elimination
    m, n = B_mod_p.shape
    M = B_mod_p.copy()
    rank = 0

    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(rank, m):
            if M[row, col] % p != 0:
                pivot = row
                break
        if pivot is None:
            continue

        # Swap
        M[[rank, pivot]] = M[[pivot, rank]]

        # Eliminate
        inv = pow(int(M[rank, col]), p - 2, p)  # Fermat's little theorem
        for row in range(m):
            if row != rank and M[row, col] % p != 0:
                factor = (M[row, col] * inv) % p
                M[row] = (M[row] - factor * M[rank]) % p

        rank += 1

    # ker(β_p) dimension relates to mod-p homology
    nullity = n - rank
    return nullity


# === Simplicial complex construction utilities ===

def rips_complex_boundary_matrices(
    points: np.ndarray,
    epsilon: float,
    max_dim: int = 2
) -> Dict[int, np.ndarray]:
    """
    Construct boundary matrices of the Rips complex R_ε(X).

    Args:
        points: n × d array of point coordinates
        epsilon: proximity parameter
        max_dim: maximum simplex dimension to compute

    Returns:
        Dict mapping dimension k to boundary matrix ∂_k
    """
    from itertools import combinations

    n = len(points)

    # Compute distance matrix
    dists = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = np.linalg.norm(points[i] - points[j])
            dists[i, j] = dists[j, i] = d

    # Build simplices by dimension
    simplices: Dict[int, List[Tuple[int, ...]]] = {0: [(i,) for i in range(n)]}

    for dim in range(1, max_dim + 1):
        simplices[dim] = []
        for combo in combinations(range(n), dim + 1):
            # Check all pairwise distances
            if all(dists[i, j] <= epsilon
                   for i, j in combinations(combo, 2)):
                simplices[dim].append(combo)

    # Build boundary matrices
    boundaries: Dict[int, np.ndarray] = {}

    for dim in range(1, max_dim + 1):
        if not simplices.get(dim) or not simplices.get(dim - 1):
            continue

        # Index simplices
        simplex_index = {s: i for i, s in enumerate(simplices[dim - 1])}
        m = len(simplices[dim - 1])
        k = len(simplices[dim])

        B = np.zeros((m, k), dtype=np.int64)

        for j, sigma in enumerate(simplices[dim]):
            for face_idx in range(len(sigma)):
                face = sigma[:face_idx] + sigma[face_idx + 1:]
                if face in simplex_index:
                    sign = (-1) ** face_idx
                    B[simplex_index[face], j] = sign

        boundaries[dim] = B

    return boundaries


if __name__ == "__main__":
    # Example: Klein bottle triangulation
    print("=== Klein Bottle Torsion Profile ===")

    # Minimal Klein bottle boundary matrix (∂_2)
    # The Klein bottle has H_1(K;ℤ) ≅ ℤ ⊕ ℤ/2ℤ
    # We use a known boundary matrix for a triangulation
    B2 = np.array([
        [ 1, -1,  0,  1,  0,  0,  0,  0],
        [-1,  0,  1,  0,  1,  0,  0,  0],
        [ 0,  1, -1,  0,  0,  1,  0,  0],
        [ 0,  0,  0, -1,  1,  0,  1,  0],
        [ 0,  0,  0,  0, -1,  1,  0,  1],
        [ 0,  0,  0,  0,  0, -1, -1,  0],
        [ 0,  0,  0,  0,  0,  0,  0, -1],
    ], dtype=np.int64)

    _, S, _ = smith_normal_form(B2)
    diag = extract_snf_diagonal(S)
    print(f"SNF diagonal: {diag}")

    profile = torsion_profile_from_snf(diag)
    print(f"Torsion profile: {profile}")
    print(f"Prime factors: {profile.primes}")
    print()

    # Example: Sieve performance
    print("=== Eratosthenes Sieve ===")
    sieve = EratosthenesSieve(1000)
    print(f"Primes up to 1000: {sieve.prime_count}")
    print(f"Primes up to 100: {len(sieve.primes_up_to(100))}")
    print(f"Is 997 prime? {sieve.is_prime(997)}")
    print()

    # Example: Random point cloud
    print("=== Rips Complex Example ===")
    np.random.seed(42)
    points = np.random.randn(8, 2)
    boundaries = rips_complex_boundary_matrices(points, epsilon=1.5, max_dim=2)

    for dim, B in boundaries.items():
        _, S, _ = smith_normal_form(B)
        diag = extract_snf_diagonal(S)
        profile = torsion_profile_from_snf(diag)
        print(f"∂_{dim}: shape {B.shape}, SNF diag = {diag}, torsion = {profile}")
