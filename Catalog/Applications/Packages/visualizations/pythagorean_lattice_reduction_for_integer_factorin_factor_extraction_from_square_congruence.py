#!/usr/bin/env python3
"""
Algorithms for Pythagorean Lattice Factoring

Implements the core algorithms from the research:
1. Factor extraction from square-root collisions
2. Berggren tree traversal and triple generation
3. Euclid parametrization with congruence data
4. Divisibility lattice construction and factor embedding
5. Pythagorean-guided factoring search
"""

import math
from typing import Tuple, List, Optional, Set
from dataclasses import dataclass


# ────────────────────────────────────────────────────────────────
# Algorithm 1: Factor Extraction from Square Congruences
# ────────────────────────────────────────────────────────────────

def extract_factor(n: int, x: int, y: int) -> Optional[int]:
    """
    Extract a nontrivial factor of n from a square congruence x² ≡ y² (mod n).
    
    Algorithm:
        1. Verify x² ≡ y² (mod n)
        2. Compute d = gcd(x - y, n)
        3. If 1 < d < n, return d
        4. Otherwise try gcd(x + y, n)
    
    Complexity: O(log n) via Euclidean algorithm
    
    Args:
        n: The composite number to factor
        x, y: Integers with x² ≡ y² (mod n), x ≢ ±y (mod n)
    
    Returns:
        A nontrivial factor of n, or None if the collision is trivial
    """
    assert n > 1, "n must be > 1"
    assert (x**2 - y**2) % n == 0, "Not a valid square congruence"
    
    d = math.gcd(abs(x - y), n)
    if 1 < d < n:
        return d
    
    d = math.gcd(abs(x + y), n)
    if 1 < d < n:
        return d
    
    return None


# ────────────────────────────────────────────────────────────────
# Algorithm 2: Berggren Tree Traversal
# ────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class PythTriple:
    """A Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int
    
    def verify(self) -> bool:
        return self.a**2 + self.b**2 == self.c**2
    
    def is_primitive(self) -> bool:
        return math.gcd(math.gcd(abs(self.a), abs(self.b)), abs(self.c)) == 1
    
    def as_list(self) -> List[int]:
        return [self.a, self.b, self.c]


# Berggren matrices (3×3 integer matrices)
BERGGREN = {
    'U': [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
    'A': [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
    'D': [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]],
}


def apply_berggren(matrix_name: str, triple: PythTriple) -> PythTriple:
    """
    Apply a Berggren generator to a Pythagorean triple.
    
    The three generators U, A, D form a ternary tree whose nodes
    enumerate ALL primitive Pythagorean triples exactly once.
    
    Complexity: O(1) — fixed 3×3 matrix-vector multiply
    """
    M = BERGGREN[matrix_name]
    v = triple.as_list()
    result = [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]
    return PythTriple(*result)


def berggren_bfs(max_hypotenuse: int) -> List[Tuple[PythTriple, str]]:
    """
    Breadth-first enumeration of primitive Pythagorean triples
    via the Berggren tree, up to a given hypotenuse bound.
    
    Complexity: O(N) where N is the number of primitive triples with c ≤ max_hypotenuse.
    By Lehmer's theorem, N ~ max_hypotenuse / (2π).
    
    Args:
        max_hypotenuse: Upper bound on the hypotenuse c
    
    Returns:
        List of (triple, word) pairs where word is the Berggren generator sequence
    """
    root = PythTriple(3, 4, 5)
    results = [(root, "")]
    queue = [(root, "")]
    
    while queue:
        triple, word = queue.pop(0)
        for name in ['U', 'A', 'D']:
            child = apply_berggren(name, triple)
            if child.c <= max_hypotenuse:
                child_word = word + name
                results.append((child, child_word))
                queue.append((child, child_word))
    
    return results


# ────────────────────────────────────────────────────────────────
# Algorithm 3: Euclid Parametrization
# ────────────────────────────────────────────────────────────────

def euclid_triple(m: int, k: int) -> PythTriple:
    """
    Generate Pythagorean triple via Euclid's parametrization:
        a = m² - k², b = 2mk, c = m² + k²
    
    The triple is primitive iff gcd(m, k) = 1 and m - k is odd.
    
    Key identities:
        c - a = 2k²
        c + a = 2m²
    
    These give square congruence data: c² - a² = (c-a)(c+a) = 4m²k² = b².
    """
    a = m**2 - k**2
    b = 2 * m * k
    c = m**2 + k**2
    return PythTriple(a, b, c)


def euclid_congruence_data(m: int, k: int) -> dict:
    """
    Extract congruence data from an Euclid triple.
    
    Returns:
        Dictionary with the triple and its sum-difference decomposition
    """
    t = euclid_triple(m, k)
    return {
        'triple': t,
        'c_minus_a': t.c - t.a,  # = 2k²
        'c_plus_a': t.c + t.a,   # = 2m²
        'b_squared': t.b**2,     # = (c-a)(c+a)
        'identity_check': (t.c - t.a) * (t.c + t.a) == t.b**2,
    }


# ────────────────────────────────────────────────────────────────
# Algorithm 4: Divisibility Lattice
# ────────────────────────────────────────────────────────────────

@dataclass
class LatticeVector:
    """A 2D integer vector with norm computation."""
    x: int
    y: int
    
    def sq_norm(self) -> int:
        return self.x**2 + self.y**2
    
    def is_zero(self) -> bool:
        return self.x == 0 and self.y == 0
    
    def in_divisibility_lattice(self, n: int) -> bool:
        return (self.x * self.y) % n == 0


def factor_to_lattice_vector(n: int, d: int) -> LatticeVector:
    """
    Embed a factor d | n as a vector (d, n/d) in the divisibility lattice.
    
    Properties (proven in the formal development):
        - (d, n/d) ∈ DivisibilityLattice(n) because n | d·(n/d)
        - ‖(d, n/d)‖² = d² + (n/d)² ≤ n²
    """
    assert n % d == 0, f"{d} does not divide {n}"
    return LatticeVector(d, n // d)


def enumerate_lattice_vectors(n: int) -> List[LatticeVector]:
    """
    Find all factor-derived vectors in the divisibility lattice of n.
    
    Each nontrivial divisor d of n contributes the vector (d, n/d).
    """
    vectors = []
    for d in range(2, n):
        if n % d == 0:
            vectors.append(factor_to_lattice_vector(n, d))
    return vectors


# ────────────────────────────────────────────────────────────────
# Algorithm 5: Pythagorean-Guided Factoring
# ────────────────────────────────────────────────────────────────

def pythagorean_factor_search(n: int, search_bound: int = 1000) -> Optional[int]:
    """
    Search for a factor of n using Pythagorean triple congruence data.
    
    Strategy:
        For each Euclid pair (m, k), compute the triple (a, b, c) and check:
        1. If n | b², then c² ≡ a² (mod n), so gcd(c ± a, n) may give a factor
        2. If n | (c² - a²) nontrivially, extract factor via gcd
    
    This is NOT a practical factoring algorithm — it's a demonstration that
    Pythagorean arithmetic naturally produces the square-congruence data
    needed for factoring.
    
    Complexity: O(search_bound² · log n)
    
    Args:
        n: The number to factor (should be composite, not a prime power)
        search_bound: Upper bound on the Euclid parameters m, k
    
    Returns:
        A nontrivial factor of n, or None
    """
    for m in range(2, search_bound):
        for k in range(1, m):
            a, b, c = m**2 - k**2, 2*m*k, m**2 + k**2
            
            # Check if c² ≡ a² (mod n) nontrivially
            if (c**2 - a**2) % n == 0:
                if (c - a) % n != 0 and (c + a) % n != 0:
                    d = extract_factor(n, c, a)
                    if d is not None:
                        return d
                elif (c - a) % n != 0:
                    d = math.gcd(abs(c - a), n)
                    if 1 < d < n:
                        return d
                elif (c + a) % n != 0:
                    d = math.gcd(abs(c + a), n)
                    if 1 < d < n:
                        return d
    
    return None


# ────────────────────────────────────────────────────────────────
# Main: Run all algorithms with examples
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # Algorithm 1: Factor extraction
    print("\n1. Factor Extraction from Square Congruences")
    test_cases = [(91, 27, 1), (143, 12, 1), (221, 47, 21)]
    for n, x, y in test_cases:
        if (x**2 - y**2) % n == 0:
            d = extract_factor(n, x, y)
            print(f"   n={n}, x={x}, y={y}: factor = {d}")
    
    # Algorithm 2: Berggren tree
    print("\n2. Berggren Tree (triples with c ≤ 100)")
    triples = berggren_bfs(100)
    for t, w in sorted(triples, key=lambda x: x[0].c):
        print(f"   {w or '(root)':<10} ({t.a}, {t.b}, {t.c})")
    
    # Algorithm 3: Euclid parametrization
    print("\n3. Euclid Parametrization (first 10 primitive triples)")
    count = 0
    for m in range(2, 20):
        for k in range(1, m):
            if math.gcd(m, k) == 1 and (m - k) % 2 == 1:
                data = euclid_congruence_data(m, k)
                t = data['triple']
                print(f"   (m={m},k={k}): ({t.a},{t.b},{t.c}), "
                      f"c-a={data['c_minus_a']}=2·{k}²={2*k**2}, "
                      f"c+a={data['c_plus_a']}=2·{m}²={2*m**2}")
                count += 1
                if count >= 10:
                    break
        if count >= 10:
            break
    
    # Algorithm 4: Divisibility lattice
    print("\n4. Divisibility Lattice Vectors")
    for n in [15, 35, 91]:
        vectors = enumerate_lattice_vectors(n)
        print(f"   n={n}: ", end="")
        for v in vectors:
            print(f"({v.x},{v.y}) ‖v‖²={v.sq_norm()} ", end="")
        print(f"  [n²={n**2}]")
    
    # Algorithm 5: Pythagorean factoring
    print("\n5. Pythagorean-Guided Factoring")
    for n in [91, 143, 221, 323, 1001, 10403]:
        d = pythagorean_factor_search(n)
        if d:
            print(f"   n={n}: factor = {d}, {n} = {d} × {n//d}")
        else:
            print(f"   n={n}: no factor found in search range")
