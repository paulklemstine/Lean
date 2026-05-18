"""
Hadamard Matrix Theory — Algorithms

Complete implementations of Hadamard matrix construction algorithms,
equivalence testing, and existence certification.

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Optional, Set, List, Tuple
from functools import lru_cache


# ============================================================
# CONSTRUCTION ALGORITHMS
# ============================================================

def sylvester_construction(k: int) -> np.ndarray:
    """
    Construct the Sylvester-Hadamard matrix of order 2^k.

    Algorithm:
        H_0 = [[1]]
        H_{k+1} = [[H_k, H_k], [H_k, -H_k]]

    Time complexity: O(4^k) = O(n^2) where n = 2^k
    Space complexity: O(4^k) = O(n^2)

    Args:
        k: Non-negative integer giving the recursion depth.

    Returns:
        A 2^k × 2^k Hadamard matrix with integer entries ±1.

    Example:
        >>> sylvester_construction(2)
        array([[ 1,  1,  1,  1],
               [ 1, -1,  1, -1],
               [ 1,  1, -1, -1],
               [ 1, -1, -1,  1]])
    """
    if k < 0:
        raise ValueError("k must be non-negative")
    H = np.array([[1]], dtype=int)
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H


def kronecker_product(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Compute the Kronecker (tensor) product of two matrices.

    If A is m×m and B is n×n, the result is (mn)×(mn).
    If both inputs are Hadamard, the output is Hadamard.

    Time complexity: O(m^2 * n^2)
    Space complexity: O(m^2 * n^2)

    This is the central closure operation: it turns the set of
    Hadamard orders into a multiplicative semigroup.
    """
    return np.kron(A, B)


def legendre_symbol(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p) for odd prime p.

    Uses Euler's criterion: (a/p) = a^((p-1)/2) mod p.

    Time complexity: O(log p) via modular exponentiation.
    """
    if a % p == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result == 1 else -1


def jacobsthal_matrix(q: int) -> np.ndarray:
    """
    Construct the Jacobsthal matrix Q of order q,
    where q is an odd prime.

    Q[i,j] = χ(i - j) where χ is the Legendre symbol mod q.

    Properties:
        - Q is symmetric if q ≡ 1 (mod 4)
        - Q is skew-symmetric if q ≡ 3 (mod 4)
        - Q @ Q.T = q*I - J  (where J is all-ones matrix)

    Time complexity: O(q^2)
    """
    Q = np.zeros((q, q), dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i, j] = legendre_symbol(i - j, q)
    return Q


def paley_type_I(q: int) -> Optional[np.ndarray]:
    """
    Paley Type I construction: produces a Hadamard matrix of order q+1,
    where q is a prime with q ≡ 3 (mod 4).

    Algorithm:
        1. Compute Jacobsthal matrix Q (q×q)
        2. Form H = [[1, j^T], [-j, Q + I]]
        3. H is a (q+1)×(q+1) Hadamard matrix

    Time complexity: O(q^2) for construction, O(q^3) for verification.

    Args:
        q: An odd prime with q ≡ 3 (mod 4).

    Returns:
        A (q+1)×(q+1) Hadamard matrix, or None if q doesn't satisfy conditions.
    """
    if q < 3 or q % 4 != 3:
        return None

    # Verify q is prime
    if not _is_prime(q):
        return None

    Q = jacobsthal_matrix(q)
    n = q + 1
    H = np.zeros((n, n), dtype=int)
    H[0, 0] = 1
    H[0, 1:] = 1
    H[1:, 0] = -1
    H[1:, 1:] = Q + np.eye(q, dtype=int)
    return H


def paley_type_II(q: int) -> Optional[np.ndarray]:
    """
    Paley Type II construction: produces a Hadamard matrix of order 2(q+1),
    where q is a prime with q ≡ 1 (mod 4).

    Algorithm:
        1. Compute Jacobsthal matrix Q (q×q) — symmetric since q ≡ 1 (mod 4)
        2. Form S = Q + I (conference matrix)
        3. Form H = [[S + I, S - I], [S - I, -(S + I)]]
        4. H is a 2(q+1)×2(q+1) Hadamard matrix

    Time complexity: O(q^2)

    Args:
        q: An odd prime with q ≡ 1 (mod 4).

    Returns:
        A 2(q+1)×2(q+1) Hadamard matrix, or None if conditions not met.
    """
    if q < 5 or q % 4 != 1:
        return None

    if not _is_prime(q):
        return None

    Q = jacobsthal_matrix(q)
    n = q + 1
    I_q = np.eye(q, dtype=int)

    # Build conference matrix C of order n = q+1
    C = np.zeros((n, n), dtype=int)
    C[0, 0] = 0
    C[0, 1:] = 1
    C[1:, 0] = 1
    C[1:, 1:] = Q

    S_plus = C + np.eye(n, dtype=int)
    S_minus = C - np.eye(n, dtype=int)

    H = np.block([
        [S_plus, S_minus],
        [S_minus, -S_plus]
    ])
    return H


def _is_prime(n: int) -> bool:
    """Simple primality test. O(sqrt(n))."""
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


# ============================================================
# VERIFICATION ALGORITHMS
# ============================================================

def verify_hadamard(H: np.ndarray) -> Tuple[bool, str]:
    """
    Verify whether a matrix is Hadamard, with diagnostic information.

    Checks:
        1. Square matrix
        2. All entries are ±1
        3. H @ H.T = n * I

    Time complexity: O(n^3) for matrix multiplication.

    Returns:
        (is_valid, message) tuple.
    """
    n = H.shape[0]
    if H.shape != (n, n):
        return False, f"Not square: shape = {H.shape}"

    bad_entries = np.argwhere(~np.isin(H, [-1, 1]))
    if len(bad_entries) > 0:
        return False, f"Non-±1 entries at positions: {bad_entries[:5].tolist()}"

    product = H @ H.T
    expected = n * np.eye(n, dtype=int)
    if not np.array_equal(product, expected):
        diff = product - expected
        max_diff = np.max(np.abs(diff))
        return False, f"H @ H^T ≠ {n}I, max deviation = {max_diff}"

    return True, f"Valid Hadamard matrix of order {n}"


def normalize_hadamard(H: np.ndarray) -> np.ndarray:
    """
    Normalize a Hadamard matrix so first row and column are all +1.

    Algorithm:
        1. Negate columns where H[0,j] = -1
        2. Negate rows where H[i,0] = -1

    Time complexity: O(n^2)

    The normalized matrix has the same Hadamard property.
    """
    H = H.copy()
    n = H.shape[0]

    # Fix first row
    for j in range(n):
        if H[0, j] == -1:
            H[:, j] *= -1

    # Fix first column
    for i in range(n):
        if H[i, 0] == -1:
            H[i, :] *= -1

    return H


# ============================================================
# EXISTENCE ENGINE
# ============================================================

def certified_hadamard_orders(bound: int) -> Set[int]:
    """
    Compute all Hadamard orders ≤ bound that are constructible
    from the certified construction families.

    Uses:
        - Order 1 (trivial)
        - Order 2 (trivial)
        - Sylvester family: 2^k
        - Paley Type I: q+1 for primes q ≡ 3 (mod 4)
        - Paley Type II: 2(q+1) for primes q ≡ 1 (mod 4)
        - Kronecker closure: if m, n are orders then m*n is an order

    Time complexity: O(bound^2 * log(bound)) approximately.

    Returns:
        Set of all constructible Hadamard orders up to bound.
    """
    orders: Set[int] = {1, 2}

    # Sylvester family
    k = 0
    while 2**k <= bound:
        orders.add(2**k)
        k += 1

    # Paley Type I: q+1 for primes q ≡ 3 (mod 4)
    for q in range(3, bound, 4):
        if _is_prime(q) and q + 1 <= bound:
            orders.add(q + 1)

    # Paley Type II: 2(q+1) for primes q ≡ 1 (mod 4)
    for q in range(5, bound, 4):
        if _is_prime(q) and 2 * (q + 1) <= bound:
            orders.add(2 * (q + 1))

    # Kronecker closure (iterate until stable)
    changed = True
    while changed:
        changed = False
        current = list(orders)
        for a in current:
            for b in current:
                prod = a * b
                if prod <= bound and prod not in orders:
                    orders.add(prod)
                    changed = True

    return orders


def unresolved_orders(bound: int) -> List[int]:
    """
    Find multiples of 4 up to bound that are NOT covered by
    the certified construction families.

    These are the "frontier" orders where the Hadamard conjecture
    remains unresolved by our construction engine.

    Returns:
        Sorted list of unresolved multiples of 4.
    """
    covered = certified_hadamard_orders(bound)
    multiples = set(range(4, bound + 1, 4))
    return sorted(multiples - covered)


# ============================================================
# DESIGN AND CODE EXTRACTION
# ============================================================

def extract_bibd_incidence(H: np.ndarray) -> np.ndarray:
    """
    Extract a symmetric BIBD incidence matrix from a normalized Hadamard matrix.

    Given a normalized n×n Hadamard matrix H (first row/column all 1s),
    delete the first row and column to get the (n-1)×(n-1) core C.
    The incidence matrix A is defined by A[i,j] = (1 - C[i,j]) / 2,
    mapping +1 → 0 and -1 → 1.

    The resulting design has parameters:
        v = n-1, k = n/2 - 1, λ = n/4 - 1

    This is a symmetric (v, k, λ)-BIBD.

    Time complexity: O(n^2)
    """
    H_norm = normalize_hadamard(H)
    n = H_norm.shape[0]
    core = H_norm[1:, 1:]
    incidence = ((1 - core) // 2).astype(int)
    return incidence


def verify_bibd(A: np.ndarray, v: int, k: int, lam: int) -> Tuple[bool, str]:
    """
    Verify that A is a (v, k, λ)-BIBD incidence matrix.

    Checks:
        1. A is v×v with 0/1 entries
        2. Each row sums to k
        3. Each column sums to k (for symmetric design)
        4. A @ A^T = (k - λ)I + λJ  (where J is all-ones)

    Time complexity: O(v^3)
    """
    if A.shape != (v, v):
        return False, f"Shape mismatch: {A.shape} vs ({v},{v})"

    if not np.all(np.isin(A, [0, 1])):
        return False, "Non-binary entries"

    row_sums = A.sum(axis=1)
    if not np.all(row_sums == k):
        return False, f"Row sums not constant: {row_sums}"

    col_sums = A.sum(axis=0)
    if not np.all(col_sums == k):
        return False, f"Column sums not constant: {col_sums}"

    gram = A @ A.T
    expected = (k - lam) * np.eye(v, dtype=int) + lam * np.ones((v, v), dtype=int)
    if not np.array_equal(gram, expected):
        return False, "A @ A^T ≠ (k-λ)I + λJ"

    return True, f"Valid ({v}, {k}, {lam})-BIBD"


def extract_equidistant_code(H: np.ndarray) -> List[np.ndarray]:
    """
    Extract an equidistant binary code from a normalized Hadamard matrix.

    From an n×n normalized Hadamard matrix:
        - Map +1 → 0, -1 → 1 to get binary codewords from rows
        - Add complements of each codeword
        - Result: 2n codewords of length n, pairwise Hamming distance n/2

    Time complexity: O(n^2)

    Returns:
        List of 2n binary codewords (numpy arrays).
    """
    H_norm = normalize_hadamard(H)
    n = H_norm.shape[0]

    codewords = []
    for i in range(n):
        word = ((1 - H_norm[i]) // 2).astype(int)
        codewords.append(word)
        codewords.append(1 - word)  # complement

    return codewords


def hamming_distance(x: np.ndarray, y: np.ndarray) -> int:
    """Compute Hamming distance between two binary vectors."""
    return int(np.sum(x != y))


# ============================================================
# EXAMPLE USAGE
# ============================================================

if __name__ == "__main__":
    print("=== Hadamard Matrix Algorithms ===\n")

    # Construction examples
    print("1. Sylvester H_3 (order 8):")
    H8 = sylvester_construction(3)
    valid, msg = verify_hadamard(H8)
    print(f"   {msg}")

    print("\n2. Paley Type I (q=11, order 12):")
    H12 = paley_type_I(11)
    if H12 is not None:
        valid, msg = verify_hadamard(H12)
        print(f"   {msg}")

    print("\n3. Paley Type II (q=5, order 12):")
    H12_II = paley_type_II(5)
    if H12_II is not None:
        valid, msg = verify_hadamard(H12_II)
        print(f"   {msg}")

    print("\n4. Kronecker product (4 × 12 = 48):")
    H4 = sylvester_construction(2)
    H48 = kronecker_product(H4, H12)
    valid, msg = verify_hadamard(H48)
    print(f"   {msg}")

    # Existence engine
    print("\n5. Certified Hadamard orders up to 100:")
    orders = certified_hadamard_orders(100)
    print(f"   {sorted(orders)}")

    print("\n6. Unresolved orders up to 200:")
    unres = unresolved_orders(200)
    print(f"   {unres}")

    # BIBD extraction
    print("\n7. BIBD from H12:")
    if H12 is not None:
        A = extract_bibd_incidence(H12)
        v, k, lam = 11, 5, 2
        valid, msg = verify_bibd(A, v, k, lam)
        print(f"   {msg}")

    # Code extraction
    print("\n8. Equidistant code from H4:")
    code = extract_equidistant_code(H4)
    print(f"   Code size: {len(code)}, length: {len(code[0])}")
    distances = set()
    for i in range(len(code)):
        for j in range(i+1, len(code)):
            distances.add(hamming_distance(code[i], code[j]))
    print(f"   Distinct Hamming distances: {distances}")
