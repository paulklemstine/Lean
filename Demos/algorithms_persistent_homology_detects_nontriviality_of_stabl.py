"""
Algorithms for Persistent Stable Homotopy Detection
====================================================

Implements the core computational methods for computing persistent Betti numbers
and barcode profiles of finite filtered chain complexes, with mod-p reduction.

Key algorithms:
1. Filtered chain complex representation
2. Restricted differential computation
3. Persistent Betti number computation via image-subspace intersection
4. Interval multiplicity recovery via Möbius inversion
5. Primewise barcode profile computation
"""

from typing import List, Tuple, Dict
import numpy as np
from dataclasses import dataclass


@dataclass
class FilteredChainComplex:
    """A finite filtered 2-term chain complex C₁ →d→ C₀ over ℤ.

    Attributes:
        gen0_filts: filtration levels of degree-0 generators
        gen1_filts: filtration levels of degree-1 generators
        diff: differential matrix (gen0 × gen1), where diff[i,j] is the
              coefficient of generator i in d(generator j)
    """
    gen0_filts: List[int]
    gen1_filts: List[int]
    diff: np.ndarray  # shape (gen0, gen1)

    @property
    def gen0(self) -> int:
        return len(self.gen0_filts)

    @property
    def gen1(self) -> int:
        return len(self.gen1_filts)

    @property
    def max_filt(self) -> int:
        all_filts = self.gen0_filts + self.gen1_filts
        return max(all_filts) if all_filts else 0

    @property
    def euler_char(self) -> int:
        return self.gen0 - self.gen1

    def validate(self) -> bool:
        """Check that the differential respects filtration."""
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.diff[i, j] != 0:
                    if self.gen0_filts[i] > self.gen1_filts[j]:
                        return False
        return True

    def restricted_diff(self, f: int) -> np.ndarray:
        """Compute the differential restricted to filtration ≤ f.

        Time complexity: O(gen0 * gen1)
        Space complexity: O(gen0 * gen1)
        """
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f: int) -> int:
        """Count degree-0 generators with filtration ≤ f."""
        return sum(1 for x in self.gen0_filts if x <= f)

    def num_gen1_at_filt(self, f: int) -> int:
        """Count degree-1 generators with filtration ≤ f."""
        return sum(1 for x in self.gen1_filts if x <= f)


def rank_mod_p(matrix: np.ndarray, p: int) -> int:
    """Compute the rank of an integer matrix modulo prime p.

    Uses Gaussian elimination over 𝔽_p.

    Time complexity: O(min(m,n) * m * n) where m×n is the matrix shape
    Space complexity: O(m * n)
    """
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0

    mat = matrix.astype(int) % p
    rank = 0

    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break

        if pivot_row is None:
            continue

        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]

        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p

        rank += 1

    return rank


def compute_persistent_betti(
    C: FilteredChainComplex,
    p: int,
    n: int,
    i: int,
    j: int,
) -> int:
    """Compute the persistent Betti number β_n^{i,j} over 𝔽_p.

    For a 2-term complex C₁ →d→ C₀:
    β₀^{i,j} = rank(im(H₀(F_i C ⊗ 𝔽_p) → H₀(F_j C ⊗ 𝔽_p)))

    where H₀(F_f) = C₀^{≤f} / im(d|_{≤f}).

    The image of H₀(F_i) → H₀(F_j) is:
      (C₀^{≤i} + im(d|_{≤j})) / im(d|_{≤j})

    Its rank equals:
      dim(C₀^{≤i}) - dim(C₀^{≤i} ∩ im(d|_{≤j}))
      = numGen0AtFilt(i) - dim(im(d|_{≤j}) ∩ span(gen0 at filt ≤ i))

    We compute dim(A ∩ B) = dim(A) + dim(B) - dim(A + B)
    where A = im(d|_{≤j}) and B = span(gen0 at filt ≤ i).

    Time complexity: O(gen0 * (gen0 + gen1) * min(gen0, gen0 + gen1))
    Space complexity: O(gen0 * (gen0 + gen1))
    """
    if n != 0 or i > j:
        return 0

    # Restricted differential at filtration j
    d_j = C.restricted_diff(j)

    # Subspace V = span of degree-0 generators at filt ≤ i
    # Represented as columns of an identity-like matrix
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)

    if dim_V == 0:
        return 0

    # Build the subspace matrix V (gen0 × dim_V)
    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1

    # Concatenate [d_j | V] to compute dim(im(d_j) + V)
    combined = np.hstack([d_j, V])

    # dim(A ∩ B) = rank(A) + rank(B) - rank([A | B])
    rank_A = rank_mod_p(d_j, p)
    rank_B = dim_V  # V has full rank (identity columns)
    rank_AB = rank_mod_p(combined, p)

    dim_intersection = rank_A + rank_B - rank_AB

    return dim_V - dim_intersection


def compute_persistent_betti_table(
    C: FilteredChainComplex,
    p: int,
) -> Dict[Tuple[int, int], int]:
    """Compute the full persistent Betti table β₀^{i,j} for all valid (i,j).

    Time complexity: O(F² * gen0 * (gen0 + gen1) * min(gen0, gen0 + gen1))
    Space complexity: O(F² + gen0 * (gen0 + gen1))
    """
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            beta = compute_persistent_betti(C, p, 0, i, j)
            table[(i, j)] = beta
    return table


def interval_multiplicities_from_betti(
    betti_table: Dict[Tuple[int, int], int],
    max_filt: int,
) -> Dict[Tuple, int]:
    """Recover interval multiplicities from persistent Betti numbers
    via Möbius inversion on the interval poset.

    The multiplicity of interval [b, d) is:
    μ(b, d) = β^{b,d-1} - β^{b-1,d-1} - β^{b,d} + β^{b-1,d}

    Time complexity: O(F²)
    Space complexity: O(F²)
    """
    def beta(i: int, j: int) -> int:
        if i < 0 or j < 0 or i > j:
            return 0
        return betti_table.get((i, j), 0)

    multiplicities = {}
    for b in range(max_filt + 1):
        for d in range(b + 1, max_filt + 2):
            mu = beta(b, d - 1) - beta(b - 1, d - 1) - beta(b, d) + beta(b - 1, d)
            if mu != 0:
                multiplicities[(b, d)] = mu

        # Infinite intervals [b, ∞)
        mu_inf = beta(b, max_filt) - beta(b - 1, max_filt)
        if mu_inf != 0:
            multiplicities[(b, float('inf'))] = mu_inf

    return multiplicities


def primewise_barcode_profile(
    C: FilteredChainComplex,
    primes: List[int],
) -> Dict[int, Dict[Tuple, int]]:
    """Compute the primewise barcode profile of a filtered chain complex.

    For each prime p, computes the full barcode of H₀(C ⊗ 𝔽_p).
    """
    profiles = {}
    for p in primes:
        betti_table = compute_persistent_betti_table(C, p)
        multiplicities = interval_multiplicities_from_betti(betti_table, C.max_filt)
        profiles[p] = multiplicities
    return profiles


# ============================================================
# Concrete examples
# ============================================================

def example_C() -> FilteredChainComplex:
    """Example C: d(e) = b - a.
    3 generators in degree 0 (filt 0, 1, 2), 1 generator in degree 1 (filt 2).
    The differential kills the class born at filtration 1."""
    return FilteredChainComplex(
        gen0_filts=[0, 1, 2],
        gen1_filts=[2],
        diff=np.array([[-1], [1], [0]])
    )


def example_D() -> FilteredChainComplex:
    """Example D: d(e) = c - a.
    Same generators as C, but differential kills the class born at filtration 2."""
    return FilteredChainComplex(
        gen0_filts=[0, 1, 2],
        gen1_filts=[2],
        diff=np.array([[-1], [0], [1]])
    )


def ladder_flow_model(k: int) -> FilteredChainComplex:
    """Ladder flow model of depth k.

    Grade 0: k+1 generators with filtrations 0, 1, ..., k
    Grade 1: k generators with filtrations 1, 2, ..., k
    d(eⱼ) = g_{j+1} - g₀
    """
    gen0_filts = list(range(k + 1))
    gen1_filts = list(range(1, k + 1))

    diff = np.zeros((k + 1, k), dtype=int)
    for j in range(k):
        diff[0, j] = -1
        diff[j + 1, j] = 1

    return FilteredChainComplex(
        gen0_filts=gen0_filts,
        gen1_filts=gen1_filts,
        diff=diff
    )


def coarse_invariants(C: FilteredChainComplex) -> dict:
    """Compute all coarse invariants of a filtered chain complex."""
    F = C.max_filt
    return {
        'graded_ranks': (C.gen0, C.gen1),
        'euler_char': C.euler_char,
        'gen0_profile': {f: C.num_gen0_at_filt(f) for f in range(F + 1)},
    }


if __name__ == "__main__":
    C = example_C()
    D = example_D()

    print("=== Coarse Invariants ===")
    print(f"C: {coarse_invariants(C)}")
    print(f"D: {coarse_invariants(D)}")

    print("\n=== Persistent Betti Tables (mod 2) ===")
    table_C = compute_persistent_betti_table(C, 2)
    table_D = compute_persistent_betti_table(D, 2)
    print(f"C: {table_C}")
    print(f"D: {table_D}")

    print("\n=== Separation ===")
    print(f"β₀^{{1,2}}(C) mod 2 = {table_C.get((1,2), 0)}")
    print(f"β₀^{{1,2}}(D) mod 2 = {table_D.get((1,2), 0)}")

    print("\n=== Barcode Profiles ===")
    prof_C = primewise_barcode_profile(C, [2, 3, 5])
    prof_D = primewise_barcode_profile(D, [2, 3, 5])
    print(f"C barcodes: {prof_C}")
    print(f"D barcodes: {prof_D}")
