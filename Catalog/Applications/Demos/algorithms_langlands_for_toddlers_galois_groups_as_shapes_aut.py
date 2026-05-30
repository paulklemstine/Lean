"""
Algorithms for the Langlands Shape-Color Correspondence (n=1 case).

Implements efficient computation of:
- Jacobi/Kronecker symbols
- Quadratic residue counting
- Shape-color pairing verification
- Character table generation

All algorithms have documented time/space complexity.
"""

from math import gcd, isqrt
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) using quadratic reciprocity.
    
    Time complexity: O(log²(n)) via the Euclidean-like algorithm
    Space complexity: O(1)
    
    The Jacobi symbol generalizes the Legendre symbol to composite moduli.
    For prime p, (a/p) = 1 iff a is a quadratic residue mod p.
    
    Args:
        a: Integer (numerator)
        n: Positive odd integer (denominator)
    
    Returns:
        -1, 0, or 1
    
    Example:
        >>> jacobi_symbol(2, 7)
        1
        >>> jacobi_symbol(3, 7)
        -1
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be a positive odd integer, got {n}")
    
    a = a % n
    result = 1
    
    while a != 0:
        # Remove factors of 2 from a
        while a % 2 == 0:
            a //= 2
            # (2/n) = (-1)^((n²-1)/8)
            if n % 8 in (3, 5):
                result = -result
        
        # Quadratic reciprocity: (a/n)(n/a) = (-1)^((a-1)(n-1)/4)
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    """Compute the Kronecker symbol (d/n), extending Jacobi to all integers.
    
    Time complexity: O(log²(max(|d|, n)))
    Space complexity: O(1)
    
    The Kronecker symbol extends the Jacobi symbol to handle:
    - n = 0: returns 1 if |d| = 1, else 0
    - n = 2: uses the supplementary law
    - Even n: factors out powers of 2
    
    Args:
        d: Any integer (the discriminant / "shape")
        n: Non-negative integer (the evaluation point)
    
    Returns:
        -1, 0, or 1
    """
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    
    result = 1
    
    # Handle factor of 2
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            result = 0
            return 0
        d_mod_8 = d % 8
        if d_mod_8 in (3, 5):
            result = -result
    
    if n > 1:
        result *= jacobi_symbol(d, n)
    
    return result


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree (not divisible by any perfect square > 1).
    
    Time complexity: O(√n)
    Space complexity: O(1)
    """
    n = abs(n)
    if n == 0:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % (p * p) == 0:
            return False
    return True


@dataclass
class ShapeColorPair:
    """A Langlands n=1 shape-color pair.
    
    The 'shape' is a squarefree discriminant d determining Q(√d).
    The 'color' is the Kronecker character χ_d.
    
    Attributes:
        disc: The discriminant (squarefree integer)
        label: Human-readable description of the quadratic field
    """
    disc: int
    label: str = ""
    
    def __post_init__(self):
        if not self.label:
            self.label = f"Q(√{self.disc})"
    
    def color(self, n: int) -> int:
        """Evaluate the Kronecker character χ_d(n)."""
        return kronecker_symbol(self.disc, n)
    
    def character_table(self, primes: List[int]) -> Dict[int, int]:
        """Compute the character table at given primes."""
        return {p: self.color(p) for p in primes}
    
    def splitting_type(self, p: int) -> str:
        """Determine how prime p behaves in Q(√d)."""
        chi = self.color(p)
        return {1: "split", -1: "inert", 0: "ramified"}.get(chi, "unknown")


def frobenius_matrix(d: int, p: int) -> List[List[int]]:
    """Compute the 1×1 Frobenius matrix for the character χ_d at prime p.
    
    For GL(1), this is simply [[χ_d(p)]].
    For GL(n), this would be an n×n matrix — the heart of Langlands.
    
    Time complexity: O(log²(p))
    Space complexity: O(1)
    """
    return [[kronecker_symbol(d, p)]]


def character_product(d1: int, d2: int, n: int) -> int:
    """Compute the product of two Kronecker characters.
    
    By the functoriality theorem:
        χ_{d₁}(n) · χ_{d₂}(n) = χ_{d₁·d₂}(n)
    
    This corresponds to the tensor product of Galois representations.
    """
    return kronecker_symbol(d1, n) * kronecker_symbol(d2, n)


def count_quadratic_residues(p: int) -> int:
    """Count the number of quadratic residues in {1, ..., p-1}.
    
    By the quadratic residue balance theorem, this equals (p-1)/2
    for any odd prime p.
    
    Time complexity: O(p log²(p))
    Space complexity: O(1)
    """
    return sum(1 for a in range(1, p) if jacobi_symbol(a, p) == 1)


def verify_quadratic_residue_balance(max_prime: int = 100) -> List[Tuple[int, bool]]:
    """Verify the quadratic residue balance theorem for all odd primes up to max_prime.
    
    For each odd prime p, checks that #{a ∈ {1,...,p-1} : (a/p) = 1} = (p-1)/2.
    
    Returns:
        List of (prime, passes) tuples
    """
    results = []
    for p in range(3, max_prime):
        if not all(p % i != 0 for i in range(2, isqrt(p) + 1)):
            continue
        if p <= 1:
            continue
        qr_count = count_quadratic_residues(p)
        expected = (p - 1) // 2
        results.append((p, qr_count == expected))
    return results


def enumerate_shape_color_pairs(max_disc: int = 50) -> List[ShapeColorPair]:
    """Enumerate all squarefree discriminants up to max_disc.
    
    Each squarefree d ≠ 0, 1 determines a unique quadratic extension Q(√d)
    and a corresponding Kronecker character χ_d.
    
    Time complexity: O(max_disc · √max_disc) for squarefree testing
    Space complexity: O(max_disc) for storing results
    """
    pairs = []
    for d in range(-max_disc, max_disc + 1):
        if d in (0, 1):
            continue
        if is_squarefree(d):
            pairs.append(ShapeColorPair(disc=d))
    return pairs


def verify_correspondence_uniqueness(max_disc: int = 100, num_primes: int = 20) -> bool:
    """Verify that distinct discriminants give distinct characters.
    
    Tests the injectivity of the Langlands map: if d₁ ≠ d₂ are squarefree,
    then there exists a prime p where χ_{d₁}(p) ≠ χ_{d₂}(p).
    
    This is a computational verification of the shape-color uniqueness theorem.
    
    Time complexity: O(max_disc² · num_primes · log²(max_disc))
    """
    primes = []
    candidate = 2
    while len(primes) < num_primes:
        if all(candidate % i != 0 for i in range(2, isqrt(candidate) + 1)) and candidate > 1:
            primes.append(candidate)
        candidate += 1
    
    pairs = enumerate_shape_color_pairs(max_disc)
    
    for i, p1 in enumerate(pairs):
        for p2 in pairs[i+1:]:
            table1 = tuple(p1.color(p) for p in primes)
            table2 = tuple(p2.color(p) for p in primes)
            if table1 == table2:
                print(f"WARNING: d={p1.disc} and d={p2.disc} have identical characters!")
                return False
    
    return True


# Example usage and verification
if __name__ == "__main__":
    print("=== Jacobi Symbol Examples ===")
    for a, n in [(2, 7), (3, 7), (5, 11), (2, 15)]:
        print(f"  ({a}/{n}) = {jacobi_symbol(a, n)}")
    
    print("\n=== Kronecker Symbol (Shape-Color) Examples ===")
    for d in [2, -3, 5, -7]:
        pair = ShapeColorPair(disc=d)
        print(f"  {pair.label}:")
        for p in [2, 3, 5, 7, 11, 13]:
            print(f"    p={p}: χ_{d}({p}) = {pair.color(p)} ({pair.splitting_type(p)})")
    
    print("\n=== Quadratic Residue Balance Verification ===")
    results = verify_quadratic_residue_balance(200)
    all_pass = all(r[1] for r in results)
    print(f"  All {len(results)} odd primes up to 200: {'PASS ✓' if all_pass else 'FAIL ✗'}")
    
    print("\n=== Correspondence Uniqueness Verification ===")
    unique = verify_correspondence_uniqueness(50, 30)
    print(f"  All squarefree |d| ≤ 50 have distinct characters: {'PASS ✓' if unique else 'FAIL ✗'}")
    
    print("\n=== Character Product (Functoriality) ===")
    for d1, d2 in [(2, 3), (5, -1), (-3, 7)]:
        for p in [5, 7, 11]:
            prod = character_product(d1, d2, p)
            direct = kronecker_symbol(d1 * d2, p)
            print(f"  χ_{d1}({p})·χ_{d2}({p}) = {prod}, χ_{d1*d2}({p}) = {direct} {'✓' if prod == direct else '✗'}")
