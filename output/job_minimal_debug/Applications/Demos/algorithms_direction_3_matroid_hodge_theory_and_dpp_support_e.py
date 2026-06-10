"""
Algorithms for Matroid Hodge Theory and DPP Support Exchange

Implements algorithms for:
1. DPP support computation
2. Matroid exchange verification
3. Symmetric exchange testing
4. Submodularity checking for matroid rank
"""
import numpy as np
from itertools import combinations
from typing import List, Set, Tuple, Dict, Optional


def compute_dpp_support(
    K: np.ndarray,
    d: int,
    eps: float = 1e-10
) -> List[Tuple[int, ...]]:
    """
    Compute the DPP support of size d for kernel K.

    The DPP support is {S ⊆ [n] : |S| = d, det(K_S) > eps}.
    For PSD K, all principal minors are ≥ 0, so the support
    consists of subsets where the minor is strictly positive.

    Args:
        K: n×n positive semidefinite matrix
        d: subset size
        eps: positivity threshold

    Returns:
        List of d-element tuples representing support sets

    Time: O(C(n,d) · d³) where C(n,d) is the binomial coefficient
    Space: O(C(n,d))
    """
    n = K.shape[0]
    support = []
    for S in combinations(range(n), d):
        S_list = list(S)
        det_val = np.linalg.det(K[np.ix_(S_list, S_list)])
        if det_val > eps:
            support.append(S)
    return support


def verify_exchange_property(
    bases: List[Tuple[int, ...]],
    verbose: bool = False
) -> Tuple[bool, Optional[Tuple]]:
    """
    Verify the matroid exchange property for a collection of bases.

    For all B1, B2 in bases and x in B1\\B2,
    checks existence of y in B2\\B1 with (B1 - x + y) in bases.

    Args:
        bases: list of equal-sized subsets
        verbose: print counterexamples if found

    Returns:
        (True, None) if exchange holds
        (False, (B1, B2, x)) if a violation is found

    Time: O(|bases|² · d²) where d is the common size
    """
    bases_set = set(bases)
    for B1 in bases:
        for B2 in bases:
            S1, S2 = set(B1), set(B2)
            for x in S1 - S2:
                found = False
                for y in S2 - S1:
                    B1_new = tuple(sorted((S1 - {x}) | {y}))
                    if B1_new in bases_set:
                        found = True
                        break
                if not found:
                    if verbose:
                        print(f"Exchange fails: B1={B1}, B2={B2}, x={x}")
                    return False, (B1, B2, x)
    return True, None


def verify_symmetric_exchange(
    bases: List[Tuple[int, ...]],
    verbose: bool = False
) -> Tuple[bool, Optional[Tuple]]:
    """
    Verify the SYMMETRIC exchange property (Brändén-Huh condition).

    For all B1, B2 in bases and x in B1\\B2,
    checks existence of y in B2\\B1 with BOTH
    (B1 - x + y) and (B2 + x - y) in bases.

    This is strictly stronger than the standard exchange property
    and is the key conjecture connecting DPPs to matroids.

    Args:
        bases: list of equal-sized subsets
        verbose: print counterexamples if found

    Returns:
        (True, None) if symmetric exchange holds
        (False, (B1, B2, x)) if a violation is found

    Time: O(|bases|² · d²) where d is the common size
    """
    bases_set = set(bases)
    for B1 in bases:
        for B2 in bases:
            S1, S2 = set(B1), set(B2)
            for x in S1 - S2:
                found = False
                for y in S2 - S1:
                    B1_new = tuple(sorted((S1 - {x}) | {y}))
                    B2_new = tuple(sorted((S2 - {y}) | {x}))
                    if B1_new in bases_set and B2_new in bases_set:
                        found = True
                        break
                if not found:
                    if verbose:
                        print(f"Sym exchange fails: B1={B1}, B2={B2}, x={x}")
                    return False, (B1, B2, x)
    return True, None


def matroid_rank(
    bases: List[Tuple[int, ...]],
    A: Set[int]
) -> int:
    """
    Compute the matroid rank of set A.

    rank(A) = max_{B in bases} |A ∩ B|

    This is submodular: r(A∪B) + r(A∩B) ≤ r(A) + r(B).

    Args:
        bases: collection of matroid bases
        A: subset to evaluate

    Returns:
        rank of A

    Time: O(|bases| · d) where d is the basis size
    """
    return max(len(A & set(B)) for B in bases) if bases else 0


def check_submodularity(
    bases: List[Tuple[int, ...]],
    n: int,
    num_tests: int = 100
) -> bool:
    """
    Empirically test submodularity of the matroid rank function.

    Tests r(A∪B) + r(A∩B) ≤ r(A) + r(B) for random A, B.

    Args:
        bases: matroid bases
        n: ground set size
        num_tests: number of random tests

    Returns:
        True if all tests pass
    """
    for _ in range(num_tests):
        A = set(np.random.choice(n, np.random.randint(0, n + 1), replace=False))
        B = set(np.random.choice(n, np.random.randint(0, n + 1), replace=False))
        r_union = matroid_rank(bases, A | B)
        r_inter = matroid_rank(bases, A & B)
        r_A = matroid_rank(bases, A)
        r_B = matroid_rank(bases, B)
        if r_union + r_inter > r_A + r_B:
            return False
    return True


def negative_dependence_gap(K: np.ndarray) -> np.ndarray:
    """
    Compute the negative dependence gap matrix.

    gap[i,j] = K[i,j] * K[j,i] = K[i,j]² for symmetric K.

    For symmetric PSD K, this equals the Frobenius norm entry-wise.

    Args:
        K: kernel matrix

    Returns:
        n×n matrix of gaps
    """
    n = K.shape[0]
    return np.array([[K[i, j] * K[j, i] for j in range(n)] for i in range(n)])


# Example usage
if __name__ == "__main__":
    np.random.seed(42)

    # Generate random PSD kernel
    n, rank = 6, 4
    B = np.random.randn(rank, n)
    K = B.T @ B

    print("Testing DPP support exchange properties:")
    print(f"  n={n}, rank={rank}")

    for d in range(1, rank + 1):
        support = compute_dpp_support(K, d)
        if len(support) >= 2:
            exch_ok, _ = verify_exchange_property(support)
            sym_ok, _ = verify_symmetric_exchange(support)
            submod_ok = check_submodularity(support, n)
            print(f"  d={d}: |support|={len(support):3d}  "
                  f"exchange={exch_ok}  sym_exchange={sym_ok}  "
                  f"submodular={submod_ok}")
