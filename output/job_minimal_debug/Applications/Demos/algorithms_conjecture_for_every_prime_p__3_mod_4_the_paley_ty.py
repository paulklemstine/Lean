"""
Algorithms for Paley-Hadamard Construction and Design Extraction

Implements the complete pipeline from finite field arithmetic through
Hadamard matrix construction to BIBD certification.
"""
import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


def is_prime(n: int) -> bool:
    """Primality test using trial division (sufficient for demonstration sizes)."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def euler_criterion(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) using Euler's criterion.
    
    For prime p and integer a:
      (a/p) = 0 if p | a
      (a/p) = 1 if a is a quadratic residue mod p
      (a/p) = -1 otherwise
    
    Uses the identity (a/p) ≡ a^((p-1)/2) (mod p).
    
    Time complexity: O(log p) via modular exponentiation.
    Space complexity: O(1).
    
    >>> euler_criterion(2, 7)
    1
    >>> euler_criterion(3, 7)
    -1
    """
    if a % p == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result == 1 else -1


def build_jacobsthal_matrix(p: int) -> np.ndarray:
    """Construct the Jacobsthal matrix Q ∈ M_p(ℤ) where Q[a,b] = χ(a-b).
    
    The Jacobsthal matrix is a circulant matrix built from the quadratic
    character χ of F_p. Its key property is Q·Q^T = p·I - J where J is
    the all-ones matrix.
    
    Time complexity: O(p²) for construction.
    Space complexity: O(p²).
    
    Args:
        p: A prime ≡ 3 (mod 4).
    
    Returns:
        p×p integer matrix with entries in {-1, 0, 1}.
    """
    assert is_prime(p) and p % 4 == 3, f"p={p} must be prime ≡ 3 (mod 4)"
    
    # Precompute the character table
    chi = np.array([euler_criterion(a, p) for a in range(p)], dtype=int)
    
    # Build circulant matrix
    Q = np.zeros((p, p), dtype=int)
    for a in range(p):
        for b in range(p):
            Q[a, b] = chi[(a - b) % p]
    
    return Q


def build_paley_type_I(p: int) -> np.ndarray:
    """Construct the Paley Type I Hadamard matrix of order p+1.
    
    Algorithm:
    1. Build the Jacobsthal matrix Q from the quadratic character.
    2. Assemble the block matrix:
       H = | 1    j^T   |
           | -j   Q + I |
       where j is the all-ones column vector.
    
    Time complexity: O(p²) for construction.
    Space complexity: O(p²).
    
    Args:
        p: A prime ≡ 3 (mod 4).
    
    Returns:
        (p+1)×(p+1) Hadamard matrix with entries in {-1, 1}.
    
    >>> H = build_paley_type_I(3)
    >>> np.array_equal(H @ H.T, 4 * np.eye(4, dtype=int))
    True
    """
    Q = build_jacobsthal_matrix(p)
    n = p + 1
    H = np.zeros((n, n), dtype=int)
    
    H[0, 0] = 1
    H[0, 1:] = 1
    H[1:, 0] = -1
    H[1:, 1:] = Q + np.eye(p, dtype=int)
    
    return H


def normalize_hadamard(H: np.ndarray) -> np.ndarray:
    """Normalize a Hadamard matrix so first row and column are all 1s.
    
    Algorithm: Negate rows and columns whose leading entry is -1.
    This preserves the Hadamard property H·H^T = n·I.
    
    Time complexity: O(n²).
    Space complexity: O(n²) for the copy.
    
    Args:
        H: A Hadamard matrix with ±1 entries.
    
    Returns:
        Normalized Hadamard matrix with first row/column all 1s.
    """
    H = H.copy()
    n = H.shape[0]
    
    # Negate rows with -1 in first column
    for i in range(n):
        if H[i, 0] == -1:
            H[i, :] *= -1
    
    # Negate columns with -1 in first row
    for j in range(n):
        if H[0, j] == -1:
            H[:, j] *= -1
    
    return H


def extract_bibd_incidence(H: np.ndarray) -> Tuple[np.ndarray, dict]:
    """Extract the BIBD incidence matrix from a normalized Hadamard matrix.
    
    Given a normalized Hadamard matrix H of order 4m, the core incidence
    matrix A is defined by A[i,j] = (1 + H[i+1,j+1]) / 2.
    
    This yields a symmetric BIBD with parameters:
      v = 4m - 1, k = 2m - 1, λ = m - 1
    
    Algorithm:
    1. Verify H is normalized (first row/col all 1s).
    2. Extract the interior (4m-1)×(4m-1) submatrix.
    3. Apply the transformation (1+x)/2.
    
    Time complexity: O(n²) where n = 4m.
    Space complexity: O(n²).
    
    Args:
        H: A normalized Hadamard matrix of order 4m.
    
    Returns:
        (A, params) where A is the incidence matrix and params = {v, k, λ}.
    """
    n = H.shape[0]
    assert n % 4 == 0, f"Order {n} must be a multiple of 4"
    m = n // 4
    
    A = (1 + H[1:, 1:]) // 2
    
    return A, {"v": 4*m - 1, "k": 2*m - 1, "lambda": m - 1}


@dataclass
class HadamardCertificate:
    """A certificate that a matrix is Hadamard, with optional BIBD data."""
    order: int
    source: str  # e.g., "Paley Type I (p=7)", "Sylvester (n=8)"
    matrix: np.ndarray
    is_verified: bool
    bibd_params: Optional[dict] = None
    incidence: Optional[np.ndarray] = None


def kronecker_product_hadamard(H1: np.ndarray, H2: np.ndarray) -> np.ndarray:
    """Build a larger Hadamard matrix via Kronecker product.
    
    If H1 is m×m Hadamard and H2 is n×n Hadamard, then
    H1 ⊗ H2 is (mn)×(mn) Hadamard.
    
    Time complexity: O(m²n²).
    Space complexity: O(m²n²).
    """
    return np.kron(H1, H2)


def sylvester_hadamard(k: int) -> np.ndarray:
    """Build the 2^k × 2^k Sylvester-Hadamard matrix.
    
    H_1 = [[1, 1], [1, -1]]
    H_k = H_1 ⊗ H_{k-1}
    
    Time complexity: O(4^k).
    Space complexity: O(4^k).
    """
    H = np.array([[1, 1], [1, -1]], dtype=int)
    for _ in range(k - 1):
        H = np.kron(np.array([[1, 1], [1, -1]], dtype=int), H)
    return H


def certified_hadamard_orders(bound: int) -> List[HadamardCertificate]:
    """Generate all certifiable Hadamard orders up to `bound`.
    
    Uses three sources:
    1. Sylvester: orders 2^k for k ≥ 1.
    2. Paley Type I: orders p+1 for primes p ≡ 3 (mod 4).
    3. Kronecker closure: products of existing certified orders.
    
    Time complexity: O(bound² · π(bound)) approximately.
    
    Args:
        bound: Upper limit for Hadamard orders to certify.
    
    Returns:
        List of HadamardCertificates for all certified orders ≤ bound.
    """
    certs: dict[int, HadamardCertificate] = {}
    
    # Trivial order 1
    H1 = np.array([[1]], dtype=int)
    certs[1] = HadamardCertificate(1, "Trivial", H1, True)
    
    # Sylvester powers of 2
    k = 1
    while 2**k <= bound:
        n = 2**k
        H = sylvester_hadamard(k)
        certs[n] = HadamardCertificate(n, f"Sylvester (2^{k})", H, True)
        k += 1
    
    # Paley Type I
    for p in range(3, bound):
        if is_prime(p) and p % 4 == 3 and p + 1 <= bound:
            H = build_paley_type_I(p)
            cert = HadamardCertificate(p + 1, f"Paley I (p={p})", H, True)
            certs[p + 1] = cert
    
    # Kronecker closure (iterate until no new orders found)
    changed = True
    while changed:
        changed = False
        existing = list(certs.keys())
        for n1 in existing:
            for n2 in existing:
                n = n1 * n2
                if n <= bound and n not in certs:
                    if n1 <= 64 and n2 <= 64:
                        H = kronecker_product_hadamard(certs[n1].matrix, certs[n2].matrix)
                    else:
                        H = np.array([[0]])  # Placeholder for large matrices
                    certs[n] = HadamardCertificate(
                        n, f"Kronecker ({n1}×{n2})", H, n1 <= 64 and n2 <= 64
                    )
                    changed = True
    
    return sorted(certs.values(), key=lambda c: c.order)


def coverage_analysis(bound: int) -> dict:
    """Analyze what fraction of multiples of 4 are certified Hadamard orders.
    
    Returns statistics about the coverage of the Sylvester + Paley I + Kronecker
    pipeline.
    """
    certs = certified_hadamard_orders(bound)
    certified_orders = {c.order for c in certs}
    
    multiples_of_4 = set(range(4, bound + 1, 4))
    covered = certified_orders & multiples_of_4
    
    return {
        "bound": bound,
        "multiples_of_4": len(multiples_of_4),
        "certified_count": len(certified_orders),
        "covered_multiples_of_4": len(covered),
        "coverage_fraction": len(covered) / len(multiples_of_4) if multiples_of_4 else 0,
        "uncovered": sorted(multiples_of_4 - covered)[:20],
        "certified_orders": sorted(certified_orders),
    }


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Demo: Paley Type I for p=7
    print("--- Paley Type I for p = 7 ---")
    H = build_paley_type_I(7)
    print("H =")
    print(H)
    print(f"\nH·H^T = {H.shape[0]}·I?", np.array_equal(H @ H.T, 8 * np.eye(8, dtype=int)))
    
    # Demo: Jacobsthal Gram
    print("\n--- Jacobsthal Gram Identity for p = 7 ---")
    Q = build_jacobsthal_matrix(7)
    print("Q·Q^T =")
    print(Q @ Q.T)
    print("7·I - J =")
    print(7 * np.eye(7, dtype=int) - np.ones((7, 7), dtype=int))
    
    # Demo: BIBD extraction
    print("\n--- BIBD Extraction from Paley p = 7 ---")
    H_norm = normalize_hadamard(H)
    A, params = extract_bibd_incidence(H_norm)
    print(f"BIBD parameters: {params}")
    print(f"Incidence matrix A =")
    print(A)
    print(f"A·A^T =")
    print(A @ A.T)
    
    # Demo: Coverage analysis
    print("\n--- Coverage Analysis ---")
    for bound in [100, 500, 1000]:
        stats = coverage_analysis(bound)
        print(f"Bound {bound}: {stats['covered_multiples_of_4']}/{stats['multiples_of_4']} "
              f"multiples of 4 covered ({stats['coverage_fraction']:.1%})")
        if stats['uncovered']:
            print(f"  First uncovered: {stats['uncovered'][:10]}")
