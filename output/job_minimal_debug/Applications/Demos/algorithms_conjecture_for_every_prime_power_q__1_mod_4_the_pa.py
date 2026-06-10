#!/usr/bin/env python3
"""
Algorithms for Paley-Hadamard Matrix Construction and Verification

Implements the complete pipeline from finite field arithmetic through
difference sets to certified Hadamard matrices and strongly regular graphs.
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass


# ============================================================
# FINITE FIELD ARITHMETIC
# ============================================================

@dataclass
class GaloisField:
    """
    Representation of GF(p^m) = F_p[t] / f(t) where f is irreducible.
    
    Elements are represented as tuples of m coefficients in F_p.
    For m=1 (prime fields), operations reduce to modular arithmetic.
    For m=2, we use the irreducible polynomial t^2 + c1*t + c0.
    
    Time complexity: O(m²) per multiplication, O(1) per addition.
    Space complexity: O(p^m) for element enumeration.
    """
    p: int  # characteristic
    m: int  # extension degree
    irred: List[int]  # coefficients [c0, c1, ...] of irreducible polynomial
    
    @property
    def order(self) -> int:
        return self.p ** self.m
    
    @property
    def zero(self) -> Tuple[int, ...]:
        return tuple(0 for _ in range(self.m))
    
    @property
    def one(self) -> Tuple[int, ...]:
        return (1,) + tuple(0 for _ in range(self.m - 1))
    
    def elements(self) -> List[Tuple[int, ...]]:
        """All field elements. O(p^m) time and space."""
        if self.m == 1:
            return [(a,) for a in range(self.p)]
        elif self.m == 2:
            return [(a, b) for a in range(self.p) for b in range(self.p)]
        raise NotImplementedError(f"m={self.m} not supported")
    
    def add(self, x: Tuple[int, ...], y: Tuple[int, ...]) -> Tuple[int, ...]:
        """Addition in GF(p^m). O(m) time."""
        return tuple((a + b) % self.p for a, b in zip(x, y))
    
    def sub(self, x: Tuple[int, ...], y: Tuple[int, ...]) -> Tuple[int, ...]:
        """Subtraction in GF(p^m). O(m) time."""
        return tuple((a - b) % self.p for a, b in zip(x, y))
    
    def neg(self, x: Tuple[int, ...]) -> Tuple[int, ...]:
        """Negation in GF(p^m). O(m) time."""
        return tuple((-a) % self.p for a in x)
    
    def mul(self, x: Tuple[int, ...], y: Tuple[int, ...]) -> Tuple[int, ...]:
        """Multiplication in GF(p^m). O(m²) time."""
        if self.m == 1:
            return ((x[0] * y[0]) % self.p,)
        elif self.m == 2:
            a, b = x
            c, d = y
            e0 = (a * c - b * d * self.irred[0]) % self.p
            e1 = (a * d + b * c - b * d * self.irred[1]) % self.p
            return (e0, e1)
        raise NotImplementedError
    
    def is_zero(self, x: Tuple[int, ...]) -> bool:
        return all(c == 0 for c in x)
    
    def squares(self) -> Set[Tuple[int, ...]]:
        """
        Compute the set of nonzero squares in GF(p^m).
        
        Returns: Set of all a² for nonzero a.
        Time: O(p^m · m²)
        """
        sq = set()
        for e in self.elements():
            if not self.is_zero(e):
                sq.add(self.mul(e, e))
        return sq
    
    def quadratic_char(self, x: Tuple[int, ...]) -> int:
        """
        Quadratic character χ(x):
        - χ(0) = 0
        - χ(x) = 1 if x is a nonzero square
        - χ(x) = -1 if x is a non-square
        
        Time: O(p^m · m²) on first call (caches squares), O(1) thereafter.
        """
        if not hasattr(self, '_squares_cache'):
            self._squares_cache = self.squares()
        if self.is_zero(x):
            return 0
        return 1 if x in self._squares_cache else -1


# ============================================================
# STANDARD FINITE FIELDS
# ============================================================

def GF(q: int) -> GaloisField:
    """
    Construct GF(q) for small prime powers q.
    
    For prime q, uses GF(q) = Z/qZ directly.
    For q = p², finds an irreducible quadratic over F_p.
    
    Supported: all primes, and squares of primes p where
    x² + 1 or x² + x + c is irreducible over F_p.
    """
    # Check if prime
    if q < 2:
        raise ValueError(f"q={q} must be a prime power ≥ 2")
    
    def is_prime(n):
        if n < 2: return False
        for d in range(2, int(n**0.5) + 1):
            if n % d == 0: return False
        return True
    
    if is_prime(q):
        return GaloisField(q, 1, [0])
    
    # Check if q = p² for prime p
    p = int(round(q ** 0.5))
    if p * p == q and is_prime(p):
        # Find irreducible quadratic over F_p
        # Try x² + 1 first (works when -1 is not a square mod p)
        if all((a * a) % p != p - 1 for a in range(p)):
            return GaloisField(p, 2, [1, 0])  # x² + 1
        # Try x² + x + c for various c
        for c in range(2, p):
            # Check if x² + x + c is irreducible: no roots
            if all((a * a + a + c) % p != 0 for a in range(p)):
                return GaloisField(p, 2, [c, 1])  # x² + x + c
        raise ValueError(f"Cannot find irreducible quadratic over F_{p}")
    
    raise NotImplementedError(f"q={q} not supported (need prime or prime²)")


# ============================================================
# MATRIX CONSTRUCTIONS
# ============================================================

def jacobsthal_matrix(field: GaloisField) -> np.ndarray:
    """
    Build the Jacobsthal matrix Q for GF(q).
    
    Q[i,j] = χ(e_i - e_j) where χ is the quadratic character.
    
    Properties:
    - Q is symmetric iff q ≡ 1 (mod 4)
    - Q is skew-symmetric iff q ≡ 3 (mod 4)
    - Q * Q^T = (q-1)I - J (always)
    
    Time: O(q² · m²) where q = p^m
    Space: O(q²)
    """
    elts = field.elements()
    q = len(elts)
    Q = np.zeros((q, q), dtype=int)
    for i, a in enumerate(elts):
        for j, b in enumerate(elts):
            diff = field.sub(a, b)
            Q[i, j] = field.quadratic_char(diff)
    return Q


def conference_matrix(Q: np.ndarray) -> np.ndarray:
    """
    Build the bordered conference matrix C from Jacobsthal matrix Q.
    
    C = [[0, 1...1], [1...1, Q]] of size (q+1) × (q+1).
    
    Properties:
    - C * C^T = qI (conference matrix identity)
    - C is symmetric iff Q is symmetric
    
    Time: O(q²)
    Space: O(q²)
    """
    q = Q.shape[0]
    C = np.zeros((q + 1, q + 1), dtype=int)
    C[0, 1:] = 1
    C[1:, 0] = 1
    C[1:, 1:] = Q
    return C


def paley_type_II(field: GaloisField) -> np.ndarray:
    """
    Construct the Paley Type II Hadamard matrix of order 2(q+1).
    
    Algorithm:
    1. Compute Jacobsthal matrix Q for GF(q)
    2. Build conference matrix C = [[0, j^T], [j, Q]]
    3. Return H = [[C+I, C-I], [C-I, -(C+I)]]
    
    Requires: q ≡ 1 (mod 4)
    
    Time: O(q² · m²) for Jacobsthal, O(q²) for block assembly
    Space: O(q²) total
    
    Pseudocode:
        function PaleyTypeII(q):
            F ← GF(q)
            Q ← JacobsthalMatrix(F)
            C ← BorderedConference(Q)
            I ← Identity(q+1)
            return BlockMatrix([[C+I, C-I], [C-I, -(C+I)]])
    """
    Q = jacobsthal_matrix(field)
    C = conference_matrix(Q)
    n = C.shape[0]
    I = np.eye(n, dtype=int)
    A = C + I
    B = C - I
    return np.block([[A, B], [B, -A]])


def paley_adjacency_matrix(field: GaloisField) -> np.ndarray:
    """
    Build the adjacency matrix of the Paley graph on GF(q).
    
    A[i,j] = 1 iff i ≠ j and χ(e_i - e_j) = 1.
    
    Requires: q ≡ 1 (mod 4) for a well-defined undirected graph.
    
    Time: O(q²)
    Space: O(q²)
    """
    elts = field.elements()
    q = len(elts)
    A = np.zeros((q, q), dtype=int)
    for i, a in enumerate(elts):
        for j, b in enumerate(elts):
            if i != j:
                diff = field.sub(a, b)
                if field.quadratic_char(diff) == 1:
                    A[i, j] = 1
    return A


def difference_set_incidence(D: Set[int], n: int) -> np.ndarray:
    """
    Build the incidence matrix M for a subset D of Z/nZ.
    
    M[g,h] = 1 if (g-h) mod n ∈ D, else 0.
    
    Time: O(n²)
    Space: O(n²)
    """
    M = np.zeros((n, n), dtype=int)
    for g in range(n):
        for h in range(n):
            if (g - h) % n in D:
                M[g, h] = 1
    return M


def verify_difference_set(D: Set[int], n: int) -> Optional[Tuple[int, int, int]]:
    """
    Verify D is a (v,k,λ)-difference set in Z/nZ.
    
    Returns (v, k, λ) if D is a valid difference set, None otherwise.
    
    Algorithm: For each nonzero g ∈ Z/nZ, count pairs (d₁,d₂) ∈ D×D
    with d₁ - d₂ ≡ g (mod n). All counts must be equal.
    
    Time: O(n · k²) where k = |D|
    Space: O(n)
    """
    v = n
    k = len(D)
    counts = {}
    for g in range(1, n):
        count = sum(1 for d1 in D for d2 in D if (d1 - d2) % n == g)
        counts[g] = count
    
    values = set(counts.values())
    if len(values) == 1:
        lam = values.pop()
        return (v, k, lam)
    return None


def verify_srg(A: np.ndarray) -> Optional[Tuple[int, int, int, int]]:
    """
    Verify A is the adjacency matrix of a strongly regular graph.
    
    Returns (n, k, a, c) if A defines an SRG, None otherwise.
    
    Checks:
    1. A is symmetric with zero diagonal and 0/1 entries
    2. All row sums equal k
    3. A² = (a-c)A + (k-c)I + cJ for some a, c
    
    Time: O(n³) for matrix multiplication
    Space: O(n²)
    """
    n = A.shape[0]
    
    # Check symmetric, zero diagonal, 0/1 entries
    if not np.array_equal(A, A.T):
        return None
    if not np.all(np.diag(A) == 0):
        return None
    if not np.all((A == 0) | (A == 1)):
        return None
    
    # Check regular
    row_sums = A.sum(axis=1)
    if len(set(row_sums)) != 1:
        return None
    k = int(row_sums[0])
    
    # Compute A² and extract parameters
    A2 = A @ A
    I_n = np.eye(n, dtype=int)
    J_n = np.ones((n, n), dtype=int)
    
    # From A² = (a-c)A + (k-c)I + cJ:
    # Diagonal: A²[i,i] = k-c + c*n → but A²[i,i] = k (sum of A[i,j]²)
    # Adjacent: A²[i,j] = (a-c) + c = a  when A[i,j]=1
    # Non-adj:  A²[i,j] = c              when A[i,j]=0, i≠j
    
    # Find a: take any adjacent pair
    a = None
    c_val = None
    for i in range(n):
        for j in range(n):
            if i != j:
                if A[i, j] == 1 and a is None:
                    a = int(A2[i, j])
                elif A[i, j] == 0 and c_val is None:
                    c_val = int(A2[i, j])
            if a is not None and c_val is not None:
                break
        if a is not None and c_val is not None:
            break
    
    if a is None or c_val is None:
        return None
    
    # Verify the full identity
    expected = (a - c_val) * A + (k - c_val) * I_n + c_val * J_n
    if np.array_equal(A2, expected):
        return (n, k, a, c_val)
    return None


# ============================================================
# HADAMARD ORDER COVERAGE
# ============================================================

def hadamard_orders_up_to(N: int) -> Set[int]:
    """
    Compute all certified Hadamard orders up to N using:
    1. Powers of 2 (Sylvester construction)
    2. Paley Type I/II for prime powers q ≡ 3 mod 4 (order q+1)
       and q ≡ 1 mod 4 (order 2(q+1))
    3. Kronecker closure (products of existing orders)
    
    Time: O(N log N) approximately
    Space: O(N)
    
    Pseudocode:
        function CertifiedHadamardOrders(N):
            orders ← {1, 2}
            // Sylvester family
            k ← 1
            while 2^k ≤ N:
                orders.add(2^k)
                k += 1
            // Paley families
            for each prime power q ≤ N:
                if q ≡ 3 mod 4 and q+1 ≤ N:
                    orders.add(q+1)
                if q ≡ 1 mod 4 and 2(q+1) ≤ N:
                    orders.add(2(q+1))
            // Kronecker closure
            repeat until stable:
                for a in orders:
                    for b in orders:
                        if a*b ≤ N:
                            orders.add(a*b)
            return orders
    """
    orders = {1, 2}
    
    # Powers of 2
    k = 1
    while 2 ** k <= N:
        orders.add(2 ** k)
        k += 1
    
    # Find prime powers up to N
    def is_prime(n):
        if n < 2: return False
        for d in range(2, int(n**0.5) + 1):
            if n % d == 0: return False
        return True
    
    prime_powers = set()
    for p in range(2, N + 1):
        if is_prime(p):
            pk = p
            while pk <= N:
                prime_powers.add(pk)
                pk *= p
    
    # Paley families
    for q in prime_powers:
        if q % 4 == 3 and q + 1 <= N:
            orders.add(q + 1)
        if q % 4 == 1 and 2 * (q + 1) <= N:
            orders.add(2 * (q + 1))
    
    # Kronecker closure
    changed = True
    while changed:
        changed = False
        new_orders = set()
        for a in orders:
            for b in orders:
                if a * b <= N and a * b not in orders:
                    new_orders.add(a * b)
                    changed = True
        orders.update(new_orders)
    
    return orders


# ============================================================
# EXAMPLE USAGE
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM 1: Finite Field Construction")
    print("=" * 60)
    
    for q in [5, 9, 13, 25]:
        try:
            F = GF(q)
            sq = F.squares()
            print(f"GF({q}): p={F.p}, m={F.m}, |squares|={len(sq)}")
        except Exception as e:
            print(f"GF({q}): {e}")
    
    print("\n" + "=" * 60)
    print("ALGORITHM 2: Paley Type II Construction")
    print("=" * 60)
    
    for q in [5, 9, 13, 17, 25]:
        if q % 4 == 1:
            F = GF(q)
            H = paley_type_II(F)
            is_had = np.all(np.abs(H) == 1) and np.array_equal(
                H @ H.T, 2 * (q + 1) * np.eye(2 * (q + 1), dtype=int))
            print(f"q={q}: H is {2*(q+1)}×{2*(q+1)}, Hadamard={is_had}")
    
    print("\n" + "=" * 60)
    print("ALGORITHM 3: SRG Verification")
    print("=" * 60)
    
    for q in [5, 13, 17, 29]:
        if q % 4 == 1:
            F = GF(q)
            A = paley_adjacency_matrix(F)
            params = verify_srg(A)
            print(f"Paley graph on F_{q}: SRG{params}")
    
    print("\n" + "=" * 60)
    print("ALGORITHM 4: Hadamard Order Coverage")
    print("=" * 60)
    
    for N in [100, 1000, 10000]:
        orders = hadamard_orders_up_to(N)
        multiples_of_4 = {n for n in range(4, N + 1, 4)}
        coverage = len(orders.intersection(multiples_of_4)) / len(multiples_of_4)
        print(f"Up to N={N}: {len(orders)} certified orders, "
              f"{coverage:.1%} of multiples of 4 covered")
        
        if N <= 100:
            missing = sorted(multiples_of_4 - orders)
            if missing:
                print(f"  Missing multiples of 4: {missing}")
