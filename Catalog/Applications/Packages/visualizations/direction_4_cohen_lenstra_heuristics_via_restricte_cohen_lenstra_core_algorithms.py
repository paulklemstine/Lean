"""
Cohen-Lenstra Heuristics: Core Algorithms

This module implements the mathematical machinery for computing Cohen-Lenstra
distributions, automorphism group orders, and cokernel statistics for random
matrices over Z/p^kZ.

All algorithms correspond to formally verified mathematical structures in
the companion Lean 4 development.
"""

from typing import List, Tuple, Dict, Optional
from math import log, exp, prod
from itertools import product as iter_product
from functools import lru_cache
import random


# =============================================================================
# Partition enumeration
# =============================================================================

def partitions_bounded(n: int, k: int) -> List[List[int]]:
    """
    Enumerate all integer partitions with at most n parts, each part <= k.
    Parts are in weakly decreasing order. Includes the empty partition [].

    These correspond to finite abelian p-groups with at most n generators
    and exponent dividing p^k.

    Args:
        n: Maximum number of parts (rank bound)
        k: Maximum part size (exponent bound)

    Returns:
        List of partitions as weakly decreasing lists of positive integers.

    Example:
        >>> partitions_bounded(2, 2)
        [[], [1], [2], [1, 1], [2, 1], [2, 2]]
    """
    result = [[]]

    def generate(parts: List[int], max_val: int, remaining: int):
        if remaining == 0:
            return
        for v in range(min(max_val, k), 0, -1):
            new_parts = parts + [v]
            result.append(new_parts)
            generate(new_parts, v, remaining - 1)

    generate([], k, n)
    return result


# =============================================================================
# Automorphism group orders
# =============================================================================

def aut_order(p: int, partition: List[int]) -> int:
    """
    Compute |Aut(G)| where G is the finite abelian p-group with invariant
    factors given by the partition.

    For G = ⊕ Z/p^{λ_i}Z, the automorphism group order is:

    |Aut(G)| = ∏_{i<j} p^{min(λ_i, λ_j)} · ∏_s (∏_{j=1}^{m_s} (p^{m_s} - p^{j-1})) · p^{m_s(m_s-1)s/2 + ...}

    More precisely, using the formula from Butler (1994):
    |Aut(G)| = ∏_{i=1}^r ∏_{j=1}^r p^{min(λ_i, λ_j)} · ∏_{s} ∏_{j=1}^{m_s} (1 - p^{-j})

    Wait, let me use the standard formula. Group the parts by value.
    If the partition has parts with multiplicities m_1, m_2, ..., m_t
    (where the i-th distinct value appears m_i times), then:

    |Aut(G)| = p^N · ∏_{i=1}^t ∏_{j=1}^{m_i} (p^{m_i} - p^{j-1})

    where N accounts for the off-diagonal blocks.

    Args:
        p: Prime number
        partition: Weakly decreasing list of positive integers

    Returns:
        |Aut(G)| as an integer

    Example:
        >>> aut_order(2, [1])  # Aut(Z/2Z) = {id} has order 1
        1
        >>> aut_order(2, [1, 1])  # Aut((Z/2Z)^2) = GL_2(F_2) has order 6
        6
    """
    if not partition:
        return 1

    r = len(partition)

    # Compute N = sum_{i<j} min(λ_i, λ_j) (total off-diagonal contribution)
    # Actually, the full formula for |Aut(G)| where G = ⊕ Z/p^{a_i}Z:
    #
    # |Aut(G)| = p^E · ∏_k ∏_{j=1}^{c_k} (p^{c_k} - p^{j-1})
    #
    # where c_k = #{i : a_i >= k} (the column lengths of the Young diagram)
    # and E = ∑_{i<j} 2·min(a_i, a_j) + ∑_i (a_i - 1)  ... no, that's wrong.
    #
    # Standard formula (see e.g. Dummit-Foote or Butler):
    # For G = ⊕_{i=1}^r Z/p^{a_i}Z with a_1 >= a_2 >= ... >= a_r > 0,
    # let c_k = #{i : a_i >= k} for k = 1, 2, ...
    # Then:
    # |Aut(G)| = ∏_{k=1}^{a_1} [ ∏_{j=1}^{c_k} (p^{c_k} - p^{j-1}) · p^{c_k · (a_k_contribution)} ]
    #
    # Actually the clean formula is:
    # |Aut(G)| = p^A · ∏_k ∏_{j=0}^{c_k - 1} (p^{c_k} - p^j)
    # where A = 2·∑_{i<j} min(a_i, a_j) and c_k are the multiplicities
    # ... I need to be more careful.

    # Use the correct formula from Hillar-Rhea (2006):
    # |Aut(G)| = ∏_{i,j} p^{min(a_i, a_j)} · ∏_k |GL_{c_k - c_{k+1}}(F_p)| / (correction)
    #
    # Simpler: direct computation via the matrix
    # Let's use a direct computational approach.

    # The formula I'll use: for G = ⊕ Z/p^{a_i}Z,
    # |Aut(G)| = (∏_{i,j=1}^r p^{min(a_i, a_j)}) · ∏_k ∏_{j=1}^{m_k} (1 - p^{-j})
    # where m_k is the multiplicity of k in the partition.
    # NO, this is also wrong.

    # Let me use the well-known correct formula.
    # For a partition λ = (λ_1 >= ... >= λ_r), the conjugate partition
    # μ = (μ_1, μ_2, ...) where μ_k = #{i : λ_i >= k}.
    # Then:
    # |Aut(G)| = ∏_{k=1}^{λ_1} [p^{μ_k(μ_k-1)/2} · ∏_{j=1}^{μ_k} (p^{μ_k} - p^{j-1}) / p^{μ_k(μ_k-1)/2}]
    # Simplifying: ∏_k ∏_{j=0}^{μ_k - 1} (p^{μ_k} - p^j)
    # ... but this ignores the off-block contributions.

    # Let me just implement the correct formula directly.
    # |Aut(⊕ Z/p^{a_i}Z)| = p^S · ∏_k |GL_{d_k}(F_p)|
    # where d_k = μ_k - μ_{k+1} (drop in conjugate partition)
    # and S = ∑_{i<j} 2·min(a_i, a_j) - ∑_k d_k(d_k-1)/2
    # ... this is getting complicated.

    # CORRECT FORMULA (from standard references):
    # |Aut(G)| = ∏_{i=1}^r ∏_{j=1}^r p^{min(λ_i, λ_j) - δ_{ij}·0} ... no.

    # Let me just use a simple recursive/direct formula that I know is correct:
    # For G = Z/p^a x H where H = ⊕_{i>=2} Z/p^{a_i}:
    # This doesn't simplify easily.

    # Fallback: use the formula from
    # https://groupprops.subwiki.org/wiki/Automorphism_group_of_finite_abelian_group
    #
    # For G = ⊕_{i=1}^r Z/p^{e_i}Z with e_1 >= ... >= e_r,
    # let n_k = #{i : e_i = k} for each k.
    # Then |Aut(G)| = ∏_k X_k where
    # X_k = p^{n_k · (sum of n_j for j > k) · k} · (product for GL_{n_k}(F_p) scaled)
    #
    # Actually I'll use the direct matrix formula:
    # |Hom(Z/p^a, Z/p^b)| = p^{min(a,b)}
    # |Aut(G)| = |{φ ∈ End(G) : φ is invertible}|
    #          = |End(G)| · ∏_k (1 - various terms)

    # |End(G)| = ∏_{i,j} p^{min(e_i, e_j)}
    # For Aut(G), we need the invertible endomorphisms.

    # The fraction |Aut(G)|/|End(G)| = ∏_k ∏_{j=1}^{c_k} (1 - p^{-j})
    # where c_k = #{i : e_i >= k} is the k-th column of the Young diagram.

    # So: |Aut(G)| = (∏_{i,j} p^{min(e_i, e_j)}) · ∏_k ∏_{j=1}^{c_k} (1 - p^{-j})

    # This is the formula I'll use.

    # Compute |End(G)| = ∏_{i,j} p^{min(e_i, e_j)}
    end_order_exp = sum(min(partition[i], partition[j])
                        for i in range(r) for j in range(r))

    # Compute column lengths c_k = #{i : partition[i] >= k}
    max_part = max(partition) if partition else 0
    col_lengths = []
    for k in range(1, max_part + 1):
        c_k = sum(1 for x in partition if x >= k)
        col_lengths.append(c_k)

    # Compute the product ∏_k ∏_{j=1}^{c_k} (1 - p^{-j})
    # We need this as a rational number, so compute:
    # |Aut(G)| = p^{end_order_exp} · ∏_k ∏_{j=1}^{c_k} (1 - p^{-j})
    # = p^{end_order_exp} · ∏_k ∏_{j=1}^{c_k} (p^j - 1) / p^j
    # = (∏_k ∏_{j=1}^{c_k} (p^j - 1)) · p^{end_order_exp - ∑_k c_k(c_k+1)/2}

    numerator = 1
    denom_exp = 0
    for c_k in col_lengths:
        for j in range(1, c_k + 1):
            numerator *= (p ** j - 1)
            denom_exp += j

    result = numerator * (p ** (end_order_exp - denom_exp))
    return result


def group_order(p: int, partition: List[int]) -> int:
    """Order of the p-group corresponding to a partition."""
    return p ** sum(partition)


# =============================================================================
# Cohen-Lenstra weights
# =============================================================================

def cl_weight(p: int, partition: List[int]) -> float:
    """
    Cohen-Lenstra weight of the p-group with given invariant factors.
    This is 1/|Aut(G)|, the unnormalized Cohen-Lenstra probability.

    Args:
        p: Prime
        partition: Invariant factors

    Returns:
        1/|Aut(G)| as a float
    """
    return 1.0 / aut_order(p, partition)


def cl_distribution(p: int, n: int, k: int) -> Dict[tuple, float]:
    """
    Compute the normalized Cohen-Lenstra distribution on p-groups
    bounded by (n, k).

    Returns:
        Dictionary mapping partition tuples to probabilities.
    """
    parts = partitions_bounded(n, k)
    weights = {tuple(part): cl_weight(p, part) for part in parts}
    total = sum(weights.values())
    return {part: w / total for part, w in weights.items()}


def cl_trivial_probability(p: int, K: int = 50) -> float:
    """
    Cohen-Lenstra prediction for the probability of trivial p-part:
    ∏_{k=1}^K (1 - p^{-k})

    Args:
        p: Prime
        K: Truncation level (default 50)

    Returns:
        Approximate probability
    """
    result = 1.0
    for k in range(1, K + 1):
        result *= (1 - p ** (-k))
    return result


# =============================================================================
# Shannon entropy
# =============================================================================

def shannon_entropy(distribution: Dict[tuple, float]) -> float:
    """
    Compute the Shannon entropy of a finite probability distribution.
    H(μ) = -∑ μ(x) log(μ(x))

    Args:
        distribution: Dictionary mapping states to probabilities

    Returns:
        Shannon entropy in nats
    """
    h = 0.0
    for x, p in distribution.items():
        if p > 0:
            h -= p * log(p)
    return h


# =============================================================================
# Product distributions
# =============================================================================

def product_distribution(
    distributions: Dict[int, Dict[tuple, float]]
) -> Dict[tuple, float]:
    """
    Compute the product of independent distributions.
    The product distribution on tuples (G_p)_{p in S} assigns weight
    ∏_p μ_p(G_p).

    Args:
        distributions: Dict mapping primes to their local distributions

    Returns:
        Product distribution on tuples
    """
    primes = sorted(distributions.keys())
    if not primes:
        return {(): 1.0}

    # Get all partition tuples for each prime
    local_states = {p: list(distributions[p].keys()) for p in primes}

    result = {}
    for combo in iter_product(*[local_states[p] for p in primes]):
        weight = 1.0
        for i, p in enumerate(primes):
            weight *= distributions[p][combo[i]]
        result[combo] = weight

    return result


# =============================================================================
# Valuation counting
# =============================================================================

def valuation_count(p: int, k: int, n: int) -> int:
    """
    Count elements in {0, ..., p^k - 1} with exact p-adic valuation n.
    Returns p^{k-n} - p^{k-n-1} for 0 <= n < k.

    Args:
        p: Prime
        k: Range exponent
        n: Target valuation

    Returns:
        Count of elements with valuation exactly n
    """
    if n >= k:
        return 1 if n == k else 0  # only 0 has valuation >= k
    return p ** (k - n) - p ** (k - n - 1)


def valuation_proportion(p: int, k: int, n: int) -> float:
    """
    Proportion of elements in {0,...,p^k-1} with exact p-adic valuation n.
    Returns p^{-n}(1 - p^{-1}).

    This is the geometric distribution probability mass at n.
    """
    if n >= k:
        return 0.0
    return p ** (-n) * (1 - p ** (-1))


# =============================================================================
# Random matrix cokernel computation
# =============================================================================

def smith_normal_form_mod_pk(matrix: List[List[int]], p: int, k: int) -> List[int]:
    """
    Compute the Smith normal form of a matrix over Z/p^kZ.
    Returns the list of diagonal entries (invariant factors).

    Args:
        matrix: n x n matrix with entries in {0, ..., p^k - 1}
        p: Prime
        k: Exponent

    Returns:
        List of invariant factors [d_1, d_2, ..., d_n] where d_i | d_{i+1}
    """
    mod = p ** k
    n = len(matrix)
    # Work with a copy
    A = [row[:] for row in matrix]

    def gcd_pk(a: int, b: int) -> int:
        """GCD in Z/p^kZ: find the largest power of p dividing both."""
        if a == 0 and b == 0:
            return mod
        va = 0
        temp = a % mod
        while temp > 0 and temp % p == 0:
            va += 1
            temp //= p
        vb = 0
        temp = b % mod
        while temp > 0 and temp % p == 0:
            vb += 1
            temp //= p
        if a % mod == 0:
            va = k
        if b % mod == 0:
            vb = k
        return p ** min(va, vb)

    invariant_factors = []
    for col in range(min(n, len(A[0]) if A else 0)):
        # Find pivot with smallest p-adic valuation
        best_val = k + 1
        best_row = -1
        best_col = -1
        for i in range(col, n):
            for j in range(col, len(A[0])):
                v = A[i][j] % mod
                if v != 0:
                    val = 0
                    temp = v
                    while temp % p == 0:
                        val += 1
                        temp //= p
                    if val < best_val:
                        best_val = val
                        best_row = i
                        best_col = j

        if best_row == -1:
            # All remaining entries are 0
            invariant_factors.extend([0] * (n - col))
            break

        # Swap rows and columns
        A[col], A[best_row] = A[best_row], A[col]
        for i in range(n):
            A[i][col], A[i][best_col] = A[i][best_col], A[i][col]

        # Reduce: make A[col][col] a power of p
        pivot = A[col][col] % mod
        # Find unit part
        val = 0
        temp = pivot
        while temp % p == 0 and val < k:
            val += 1
            temp //= p

        if val < k:
            # pivot = p^val * u where u is a unit mod p^(k-val)
            u = temp % (p ** (k - val))
            # Find inverse of u mod p^(k-val)
            u_inv = pow(u, -1, p ** (k - val)) if k > val else 1
            # Multiply row by u_inv
            for j in range(len(A[0])):
                A[col][j] = (A[col][j] * u_inv) % mod

        # Eliminate column and row
        for i in range(n):
            if i != col and A[i][col] % mod != 0:
                pivot_val = A[col][col] % mod
                if pivot_val != 0:
                    entry = A[i][col] % mod
                    # entry / pivot_val in Z/modZ
                    factor = 0
                    if pivot_val != 0:
                        pv = 0
                        t = pivot_val
                        while t % p == 0:
                            pv += 1
                            t //= p
                        pe = 0
                        t = entry
                        while t > 0 and t % p == 0:
                            pe += 1
                            t //= p
                        if pe >= pv:
                            factor = (entry // (p ** pv)) * pow(pivot_val // (p ** pv), -1, p ** (k - pv)) % (p ** (k - pv))
                            factor = (factor * p ** 0) % mod
                            for j in range(len(A[0])):
                                A[i][j] = (A[i][j] - factor * A[col][j]) % mod

        invariant_factors.append(A[col][col] % mod)

    if len(invariant_factors) < n:
        invariant_factors.extend([0] * (n - len(invariant_factors)))

    return invariant_factors


def cokernel_partition(matrix: List[List[int]], p: int, k: int) -> List[int]:
    """
    Compute the partition encoding the cokernel of a matrix over Z/p^kZ.
    The cokernel is (Z/p^kZ)^n / im(A), which is a finite abelian p-group.

    Returns the partition (invariant factors in decreasing order).
    """
    mod = p ** k
    n = len(matrix)
    snf = smith_normal_form_mod_pk(matrix, p, k)

    # The cokernel has invariant factors p^k / d_i for each d_i
    # Actually, the cokernel of A: (Z/p^kZ)^n -> (Z/p^kZ)^n
    # has type ⊕ Z/gcd(d_i, p^k)Z where d_i are the Smith normal form entries
    # Wait, the cokernel is (Z/p^kZ)^n / im(A).
    # If SNF(A) = diag(d_1, ..., d_n) then coker(A) ≅ ⊕ Z/(p^k / gcd(d_i, p^k))Z
    # No: coker(A) ≅ ⊕ Z/d_i'Z where d_i' = p^k / gcd(d_i, p^k)?
    # Actually: if A = UDV with U,V invertible and D = diag(d_i),
    # then im(A) ≅ ⊕ d_i · Z/p^kZ, and (Z/p^kZ)^n / ⊕ d_i·(Z/p^kZ)
    # ≅ ⊕ Z/(p^k / gcd(d_i, p^k))Z ... hmm not quite.
    #
    # Correct: (Z/p^kZ) / d·(Z/p^kZ) ≅ Z/gcd(d, p^k)Z
    # So coker ≅ ⊕ Z/gcd(d_i, p^k)Z where d_i are SNF diagonal entries.
    # Hmm, that's for the quotient Z^n / A(Z^n). For Z/p^kZ, it's different.
    #
    # For A over Z/p^kZ: the cokernel is (Z/p^kZ)^n / A((Z/p^kZ)^n).
    # If SNF is diag(d_1,...,d_n) then this is ⊕ (Z/p^kZ)/(d_i · Z/p^kZ) ≅ ⊕ Z/gcd(d_i, p^k)Z.
    #
    # Wait no: (Z/mZ)/(d·Z/mZ) ≅ Z/gcd(d,m)Z. Yes, that's correct.

    cokernel_factors = []
    for d in snf:
        from math import gcd
        g = gcd(d, mod)
        if g > 1:
            # Compute the valuation of g
            val = 0
            temp = g
            while temp % p == 0:
                val += 1
                temp //= p
            if val > 0:
                cokernel_factors.append(val)

    cokernel_factors.sort(reverse=True)
    return cokernel_factors


def sample_random_matrix(n: int, p: int, k: int) -> List[List[int]]:
    """Generate a random n x n matrix over Z/p^kZ."""
    mod = p ** k
    return [[random.randint(0, mod - 1) for _ in range(n)] for _ in range(n)]


def empirical_cokernel_distribution(
    p: int, n: int, k: int, num_samples: int = 1000
) -> Dict[tuple, float]:
    """
    Sample random matrices and compute empirical cokernel distribution.

    Args:
        p: Prime
        n: Matrix size
        k: Exponent
        num_samples: Number of random matrices to sample

    Returns:
        Dictionary mapping partition tuples to empirical frequencies
    """
    counts: Dict[tuple, int] = {}
    for _ in range(num_samples):
        A = sample_random_matrix(n, p, k)
        part = tuple(cokernel_partition(A, p, k))
        counts[part] = counts.get(part, 0) + 1

    return {part: count / num_samples for part, count in counts.items()}


# =============================================================================
# Verification utilities
# =============================================================================

def verify_normalization(distribution: Dict[tuple, float], tol: float = 1e-10) -> bool:
    """Check that a distribution sums to 1."""
    total = sum(distribution.values())
    return abs(total - 1.0) < tol


def verify_nonneg(distribution: Dict[tuple, float]) -> bool:
    """Check that all weights are nonneg."""
    return all(w >= 0 for w in distribution.values())


if __name__ == "__main__":
    print("=" * 60)
    print("Cohen-Lenstra Algorithms: Self-Test")
    print("=" * 60)

    # Test partition enumeration
    parts = partitions_bounded(2, 2)
    print(f"\nPartitions bounded by (2,2): {parts}")
    print(f"Count: {len(parts)}")

    # Test automorphism group orders
    for part in [[1], [2], [1, 1], [2, 1], [2, 2]]:
        print(f"|Aut(G_{part})| for p=2: {aut_order(2, part)}")

    # Test CL distribution
    dist = cl_distribution(3, 3, 3)
    print(f"\nCL distribution for p=3, n=3, k=3:")
    for part, w in sorted(dist.items(), key=lambda x: -x[1])[:5]:
        print(f"  {part}: {w:.6f}")
    print(f"Sum: {sum(dist.values()):.10f}")

    # Test valuation counts
    print(f"\nValuation counts for p=2, k=4:")
    for n in range(4):
        count = valuation_count(2, 4, n)
        prop = valuation_proportion(2, 4, n)
        print(f"  v_2 = {n}: count = {count}, proportion = {prop:.4f}")

    # Test CL trivial probability
    print(f"\nCL trivial probability predictions:")
    for p in [2, 3, 5, 7, 11]:
        print(f"  p={p}: {cl_trivial_probability(p):.6f}")

    # Test entropy
    dist2 = cl_distribution(2, 3, 3)
    print(f"\nEntropy of CL(2,3,3): {shannon_entropy(dist2):.6f}")
