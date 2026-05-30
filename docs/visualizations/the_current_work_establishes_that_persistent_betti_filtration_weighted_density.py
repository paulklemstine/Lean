"""
algorithms.py — Core algorithms for multi-degree persistence of filtered chain complexes.

Implements:
1. FilteredChainComplex3 — 3-term filtered chain complex with d² = 0
2. Filtration-weighted density computation
3. d² = 0 verification and cancellation pattern detection
4. Diagonal-like matrix detection
5. Arithmetic filtration via prime factorization
6. Barcode realizability bound checking
"""

from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass
import numpy as np


@dataclass
class FilteredChainComplex3:
    """
    A 3-term filtered chain complex over ℤ:
        C₂ --d₁--> C₁ --d₀--> C₀
    
    with d₀ ∘ d₁ = 0 and filtration functions on each module.
    
    Attributes:
        d1: Matrix (n₁ × n₂) representing d₁ : C₂ → C₁
        d0: Matrix (n₀ × n₁) representing d₀ : C₁ → C₀
        filt2: Filtration levels for C₂ basis elements
        filt1: Filtration levels for C₁ basis elements
        filt0: Filtration levels for C₀ basis elements
    """
    d1: np.ndarray
    d0: np.ndarray
    filt2: List[int]
    filt1: List[int]
    filt0: List[int]
    
    def __post_init__(self):
        """Verify d² = 0 condition."""
        product = self.d0 @ self.d1
        if not np.allclose(product, 0):
            raise ValueError(f"d² ≠ 0: d₀·d₁ = {product}")
        if len(self.filt1) != self.d1.shape[0]:
            raise ValueError(f"filt₁ length {len(self.filt1)} ≠ n₁ = {self.d1.shape[0]}")
        if len(self.filt2) != self.d1.shape[1]:
            raise ValueError(f"filt₂ length {len(self.filt2)} ≠ n₂ = {self.d1.shape[1]}")
        if len(self.filt0) != self.d0.shape[0]:
            raise ValueError(f"filt₀ length {len(self.filt0)} ≠ n₀ = {self.d0.shape[0]}")
    
    @property
    def n2(self) -> int: return self.d1.shape[1]
    
    @property
    def n1(self) -> int: return self.d1.shape[0]
    
    @property
    def n0(self) -> int: return self.d0.shape[0]


def filtration_weighted_density(C: FilteredChainComplex3) -> int:
    """
    Compute the filtration-weighted differential density ρ(C).
    
    For each nonzero entry d₁[i,j], accumulates filt₁[i] - filt₂[j].
    This is the key invariant that detects filtration timing.
    
    Time complexity: O(n₁ · n₂)
    Space complexity: O(1)
    
    Args:
        C: A filtered chain complex
    
    Returns:
        The integer density value ρ(C)
    """
    density = 0
    for i in range(C.n1):
        for j in range(C.n2):
            if C.d1[i, j] != 0:
                density += C.filt1[i] - C.filt2[j]
    return density


def check_d_squared_zero(d1: np.ndarray, d0: np.ndarray) -> bool:
    """
    Check if d₀ · d₁ = 0 (chain complex condition).
    
    Time complexity: O(n₀ · n₁ · n₂)
    Space complexity: O(n₀ · n₂)
    """
    return np.allclose(d0 @ d1, 0)


def d_sq_cancellation_analysis(
    d1: np.ndarray, d0: np.ndarray
) -> List[Dict]:
    """
    Analyze the cancellation patterns forced by d² = 0.
    
    For each pair (i, k), determines whether:
    - All products d₀[i,j]·d₁[j,k] are zero, or
    - At least two nonzero products exist (and cancel)
    
    Returns a list of analysis results, one per (i,k) pair.
    """
    results = []
    n0, n1 = d0.shape
    _, n2 = d1.shape
    
    for i in range(n0):
        for k in range(n2):
            products = [(j, int(d0[i, j] * d1[j, k])) 
                       for j in range(n1)]
            nonzero = [(j, p) for j, p in products if p != 0]
            
            result = {
                'i': i, 'k': k,
                'num_nonzero': len(nonzero),
                'nonzero_entries': nonzero,
                'sum': sum(p for _, p in nonzero),
                'pattern': 'all_zero' if len(nonzero) == 0 
                          else 'cancellation' if len(nonzero) >= 2
                          else 'ERROR_lone_survivor'
            }
            results.append(result)
    
    return results


def is_diagonal_like(M: np.ndarray) -> bool:
    """
    Check if a matrix is diagonal-like (≤1 nonzero entry per row and column).
    
    Time complexity: O(m · n)
    Space complexity: O(1)
    """
    m, n = M.shape
    for i in range(m):
        if np.count_nonzero(M[i, :]) > 1:
            return False
    for j in range(n):
        if np.count_nonzero(M[:, j]) > 1:
            return False
    return True


def support_disjointness_check(C: FilteredChainComplex3) -> Dict:
    """
    Check support disjointness for diagonal-like differentials.
    
    If both d₁ and d₀ are diagonal-like, verifies that no C₁ basis
    element appears in both the column support of d₁ and the row
    support of d₀.
    
    Returns analysis dict with supports and intersection.
    """
    d1_support: Set[int] = set()
    d0_support: Set[int] = set()
    
    for j in range(C.n1):
        if any(C.d1[j, k] != 0 for k in range(C.n2)):
            d1_support.add(j)
        if any(C.d0[i, j] != 0 for i in range(C.n0)):
            d0_support.add(j)
    
    return {
        'd1_diagonal_like': is_diagonal_like(C.d1),
        'd0_diagonal_like': is_diagonal_like(C.d0),
        'im_d1_support': d1_support,
        'd0_support': d0_support,
        'intersection': d1_support & d0_support,
        'disjoint': len(d1_support & d0_support) == 0
    }


def prime_factorization_length(n: int) -> int:
    """
    Compute Ω(n) = number of prime factors of n with multiplicity.
    
    This is the arithmetic filtration level.
    Ω(0) = Ω(1) = 0, Ω(p) = 1 for prime p.
    
    Time complexity: O(√n)
    Space complexity: O(1)
    """
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count


def arithmetic_filtration(f: List[int]) -> List[int]:
    """
    Compute the arithmetic filtration for a list of natural numbers.
    
    Each element gets filtration level Ω(f[i]) = prime factorization length.
    
    Time complexity: O(n · √M) where M = max(f)
    Space complexity: O(n)
    """
    return [prime_factorization_length(x) for x in f]


def verify_multiplicativity(a: int, b: int) -> bool:
    """Verify Ω(a·b) = Ω(a) + Ω(b) for specific a, b > 0."""
    if a <= 0 or b <= 0:
        raise ValueError("Both a and b must be positive")
    return (prime_factorization_length(a * b) == 
            prime_factorization_length(a) + prime_factorization_length(b))


def barcode_realizability_check(total_pairs: int, middle_dim: int) -> bool:
    """
    Check the barcode realizability bound: total_pairs ≤ 2 · middle_dim.
    
    Conjecture: For any 3-term filtered chain complex with d² = 0,
    this bound always holds.
    """
    return total_pairs <= 2 * middle_dim


def enumerate_d_sq_zero_complexes_F2(n2: int, n1: int, n0: int) -> List[Tuple[np.ndarray, np.ndarray]]:
    """
    Enumerate all pairs (d₁, d₀) over F₂ = {0, 1} satisfying d₀·d₁ = 0.
    
    WARNING: Exponential in dimensions. Only use for small values.
    
    Time complexity: O(2^(n₁·n₂ + n₀·n₁))
    """
    results = []
    # Enumerate all d₁ matrices
    for d1_bits in range(2 ** (n1 * n2)):
        d1 = np.zeros((n1, n2), dtype=int)
        for idx in range(n1 * n2):
            i, j = idx // n2, idx % n2
            d1[i, j] = (d1_bits >> idx) & 1
        
        # Enumerate all d₀ matrices
        for d0_bits in range(2 ** (n0 * n1)):
            d0 = np.zeros((n0, n1), dtype=int)
            for idx in range(n0 * n1):
                i, j = idx // n1, idx % n1
                d0[i, j] = (d0_bits >> idx) & 1
            
            # Check d² = 0 over F₂ (mod 2)
            product = (d0 @ d1) % 2
            if np.allclose(product, 0):
                results.append((d1.copy(), d0.copy()))
    
    return results


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Separation example
    d1 = np.array([[1], [0]])
    d0 = np.array([[0, 1]])
    
    A = FilteredChainComplex3(d1, d0, filt2=[2], filt1=[0, 3], filt0=[0])
    B = FilteredChainComplex3(d1, d0, filt2=[2], filt1=[3, 0], filt0=[0])
    
    rho_A = filtration_weighted_density(A)
    rho_B = filtration_weighted_density(B)
    
    print(f"ρ(A) = {rho_A}, ρ(B) = {rho_B}")
    print(f"Separated: {rho_A != rho_B}")
    
    # Cancellation analysis
    d1_c = np.array([[1], [-1]])
    d0_c = np.array([[1, 1]])
    analysis = d_sq_cancellation_analysis(d1_c, d0_c)
    for r in analysis:
        print(f"({r['i']},{r['k']}): {r['pattern']}, nonzero={r['nonzero_entries']}")
    
    # Arithmetic filtration
    values = [1, 2, 3, 4, 6, 12, 30, 60]
    filt = arithmetic_filtration(values)
    print(f"Values: {values}")
    print(f"Arithmetic filtration: {filt}")
    
    # Multiplicativity
    for a, b in [(2, 3), (4, 5), (6, 7)]:
        print(f"Ω({a}·{b}) = Ω({a}) + Ω({b}): {verify_multiplicativity(a, b)}")
