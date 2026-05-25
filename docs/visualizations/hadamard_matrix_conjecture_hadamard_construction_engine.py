#!/usr/bin/env python3
"""
Hadamard Matrix Construction Algorithms

Implements multiple construction methods for Hadamard matrices:
1. Sylvester (Walsh) construction — powers of 2
2. Paley construction — from quadratic residues of prime powers
3. Tensor (Kronecker) product — compositional closure
4. Sporadic seeds — verified small-order matrices
5. Certified search engine — tries all methods

Each algorithm includes verification and provenance tracking.
"""

import numpy as np
from typing import Optional, List, Tuple, Dict
from functools import lru_cache


# ══════════════════════════════════════════════════════════════════════
# 1. Sylvester Construction
# ══════════════════════════════════════════════════════════════════════

def sylvester_matrix(k: int) -> np.ndarray:
    """Construct 2^k × 2^k Hadamard matrix via Sylvester doubling.

    Time complexity: O(4^k) = O(n²)
    Space complexity: O(4^k) = O(n²)

    The construction is:
        H_0 = [1]
        H_{k+1} = [[H_k, H_k], [H_k, -H_k]]
    """
    H = np.array([[1]], dtype=int)
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H


# ══════════════════════════════════════════════════════════════════════
# 2. Paley Construction
# ══════════════════════════════════════════════════════════════════════

def is_prime(n: int) -> bool:
    """Primality test."""
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


def is_prime_power(n: int) -> Optional[Tuple[int, int]]:
    """If n = p^k for prime p, return (p, k); else None."""
    if n < 2:
        return None
    for p in range(2, int(n**0.5) + 2):
        if not is_prime(p):
            continue
        k = 0
        m = n
        while m % p == 0:
            m //= p
            k += 1
        if m == 1 and k >= 1:
            return (p, k)
    if is_prime(n):
        return (n, 1)
    return None


def legendre_symbol(a: int, p: int) -> int:
    """Compute Legendre symbol (a/p) for odd prime p."""
    a = a % p
    if a == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result <= 1 else result - p


def quadratic_residue_matrix(q: int) -> np.ndarray:
    """Construct the q × q quadratic character matrix Q for prime q.
    Q[i][j] = χ(i - j) where χ is the Legendre symbol.
    """
    Q = np.zeros((q, q), dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i][j] = legendre_symbol(i - j, q)
    return Q


def paley_type1(q: int) -> Optional[np.ndarray]:
    """Paley Type I construction: order q + 1 where q ≡ 3 (mod 4) is prime.

    The matrix is:
        H = [[1, j^T], [-j, Q + I]]
    where Q is the quadratic residue matrix and j is the all-ones vector.

    Actually the Paley construction is:
        S = Q + I (conference matrix with 0 on diagonal replaced by -1)
        H = [[1, 1, ..., 1], [1, S]]  with appropriate signs

    For q ≡ 3 (mod 4), the construction gives a skew-type Hadamard matrix.
    """
    if not is_prime(q) or q % 4 != 3:
        return None

    n = q + 1  # Order of the Hadamard matrix
    Q = quadratic_residue_matrix(q)

    # Construct the (q+1) × (q+1) Hadamard matrix
    H = np.zeros((n, n), dtype=int)
    H[0, :] = 1
    H[:, 0] = 1
    H[0, 0] = 1

    # Fill the q × q submatrix
    for i in range(q):
        for j in range(q):
            if i == j:
                H[i+1, j+1] = -1
            else:
                H[i+1, j+1] = Q[i][j]

    # Verify
    if verify_hadamard(H):
        return H
    return None


def paley_type2(q: int) -> Optional[np.ndarray]:
    """Paley Type II construction: order 2(q + 1) where q ≡ 1 (mod 4) is prime.

    Uses the conference matrix C derived from quadratic residues.
    H = [[C + I, C - I], [C - I, -(C + I)]]
    """
    if not is_prime(q) or q % 4 != 1:
        return None

    Q = quadratic_residue_matrix(q)

    # Conference matrix: Q with diagonal set to 0
    C_inner = Q.copy()
    n_conf = q + 1
    C = np.zeros((n_conf, n_conf), dtype=int)
    C[0, 1:] = 1
    C[1:, 0] = 1
    C[1:, 1:] = C_inner

    I = np.eye(n_conf, dtype=int)
    CpI = C + I
    CmI = C - I

    H = np.block([[CpI, CmI], [CmI, -CpI]])

    if verify_hadamard(H):
        return H
    return None


def verify_hadamard(H: np.ndarray) -> bool:
    """Check H is a valid Hadamard matrix."""
    n = H.shape[0]
    if H.shape != (n, n):
        return False
    if not np.all(np.abs(H) == 1):
        return False
    return np.array_equal(H @ H.T, n * np.eye(n, dtype=int))


# ══════════════════════════════════════════════════════════════════════
# 3. Sporadic seeds
# ══════════════════════════════════════════════════════════════════════

def hadamard_12() -> np.ndarray:
    """Explicit Hadamard matrix of order 12 (discovered by Hadamard himself)."""
    # Using the Hadamard matrix from the Paley construction with q=11
    H = paley_type1(11)
    if H is not None:
        return H
    raise ValueError("Failed to construct H_12")


# ══════════════════════════════════════════════════════════════════════
# 4. Certified Construction Engine
# ══════════════════════════════════════════════════════════════════════

class Certificate:
    """Hadamard certificate with provenance and verification."""
    def __init__(self, order: int, matrix: np.ndarray, provenance: str,
                 children: Optional[List['Certificate']] = None):
        self.order = order
        self.matrix = matrix
        self.provenance = provenance
        self.children = children or []
        self.verified = verify_hadamard(matrix)

    def provenance_tree(self, indent=0) -> str:
        lines = [" " * indent + f"Order {self.order}: {self.provenance}"]
        for child in self.children:
            lines.append(child.provenance_tree(indent + 2))
        return "\n".join(lines)


_cache: Dict[int, Optional[Certificate]] = {}


def construct(n: int) -> Optional[Certificate]:
    """Main construction engine: try all methods to build order n.

    Strategy (in order):
    1. Base cases: n = 1, 2
    2. Powers of 2: Sylvester
    3. Paley Type I: q + 1 where q ≡ 3 (mod 4) is prime
    4. Paley Type II: 2(q + 1) where q ≡ 1 (mod 4) is prime
    5. Tensor decomposition: try all factorizations
    6. Give up

    Time complexity: O(n² log n) for direct constructions,
                     O(n³) worst case with tensor search.
    """
    if n in _cache:
        return _cache[n]

    cert = _construct_impl(n)
    _cache[n] = cert
    return cert


def _construct_impl(n: int) -> Optional[Certificate]:
    # Base cases
    if n == 1:
        return Certificate(1, np.array([[1]]), "base_seed")
    if n == 2:
        return Certificate(2, np.array([[1, 1], [1, -1]]), "base_seed")

    # Divisibility check
    if n > 2 and n % 4 != 0:
        return None

    # Power of 2 → Sylvester
    k = 0
    m = n
    while m > 1 and m % 2 == 0:
        m //= 2
        k += 1
    if m == 1:
        H = sylvester_matrix(k)
        return Certificate(n, H, f"Sylvester(2^{k})")

    # Paley Type I: n = q + 1 where q ≡ 3 (mod 4) is prime
    q = n - 1
    if is_prime(q) and q % 4 == 3:
        H = paley_type1(q)
        if H is not None:
            return Certificate(n, H, f"Paley_I(q={q})")

    # Paley Type II: n = 2(q + 1) where q ≡ 1 (mod 4) is prime
    if n % 2 == 0:
        q2 = n // 2 - 1
        if q2 > 0 and is_prime(q2) and q2 % 4 == 1:
            H = paley_type2(q2)
            if H is not None:
                return Certificate(n, H, f"Paley_II(q={q2})")

    # Tensor decomposition
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            c1 = construct(d)
            c2 = construct(n // d)
            if c1 is not None and c2 is not None:
                H = np.kron(c1.matrix, c2.matrix)
                return Certificate(n, H, f"Tensor({d}×{n//d})",
                                   children=[c1, c2])

    return None


# ══════════════════════════════════════════════════════════════════════
# 5. Analysis utilities
# ══════════════════════════════════════════════════════════════════════

def hamming_distances(H: np.ndarray) -> List[int]:
    """Compute all pairwise Hamming distances between rows (as ±1 → bit)."""
    n = H.shape[0]
    bits = ((1 - H) // 2).astype(int)
    dists = []
    for i in range(n):
        for j in range(i + 1, n):
            dists.append(int(np.sum(bits[i] != bits[j])))
    return dists


def design_parameters(H: np.ndarray) -> Dict:
    """Extract BIBD parameters from a Hadamard matrix."""
    n = H.shape[0]
    # Normalize
    Hn = H.copy()
    for j in range(n):
        if Hn[0, j] == -1:
            Hn[:, j] *= -1
    for i in range(n):
        if Hn[i, 0] == -1:
            Hn[i, :] *= -1

    core = Hn[1:, 1:]
    inc = ((core + 1) // 2).astype(int)
    v = n - 1

    block_sizes = set(int(s) for s in inc.sum(axis=0))
    replications = set(int(s) for s in inc.sum(axis=1))

    lambdas = set()
    for i in range(v):
        for j in range(i + 1, v):
            lambdas.add(int(np.sum(inc[i] * inc[j])))

    return {"v": v, "k": block_sizes, "r": replications, "lambda": lambdas}


# ══════════════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Hadamard Construction Algorithms — Test Suite")
    print("=" * 60)

    # Test all orders up to 200
    results = {}
    for n in range(1, 201):
        cert = construct(n)
        if cert is not None:
            results[n] = cert

    admissible = [n for n in range(1, 201) if n <= 2 or n % 4 == 0]
    constructed = sorted(results.keys())
    missing = [n for n in admissible if n not in results]

    print(f"\nAdmissible orders ≤ 200: {len(admissible)}")
    print(f"Constructed: {len(constructed)}")
    print(f"Missing: {len(missing)}")
    print(f"\nConstructed orders: {constructed}")
    print(f"\nMissing orders: {missing}")

    # Show provenance for some orders
    print("\nProvenance trees:")
    for n in [4, 8, 12, 16, 20, 24, 32, 36, 48]:
        cert = construct(n)
        if cert:
            print(f"\n{cert.provenance_tree()}")
        else:
            print(f"\nOrder {n}: NOT CONSTRUCTED")

    # Verify coding theory
    print("\n\nCoding theory verification:")
    for n in [4, 8, 12, 16]:
        cert = construct(n)
        if cert:
            dists = hamming_distances(cert.matrix)
            print(f"  Order {n}: Hamming distances = {set(dists)} (expected {{{n//2}}})")

    # Design parameters
    print("\nDesign parameters:")
    for n in [4, 8, 12, 16]:
        cert = construct(n)
        if cert:
            params = design_parameters(cert.matrix)
            t = n // 4
            print(f"  Order {n}: v={params['v']}, k={params['k']}, λ={params['lambda']}")
            print(f"    Expected: v={4*t-1}, k={{{2*t-1}}}, λ={{{t-1}}}")
