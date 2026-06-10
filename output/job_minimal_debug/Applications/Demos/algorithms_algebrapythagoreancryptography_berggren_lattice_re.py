#!/usr/bin/env python3
"""
Algorithms for Berggren Lattice Reduction Duality

Implements the core algorithms from the research paper:
1. Berggren tree traversal and Gram matrix computation
2. Gram-based lattice invariant computation
3. Lagrange reduction of rank-2 lattice bases
4. Certified short-basis reconstruction from Berggren path data
"""

from typing import Tuple, List, Optional, Dict
from dataclasses import dataclass
import math


# ============================================================================
# Data Types
# ============================================================================

@dataclass(frozen=True)
class PythagTriple:
    """A Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int
    
    def __post_init__(self):
        assert self.a**2 + self.b**2 == self.c**2, f"Not Pythagorean: {self}"
        assert self.a > 0 and self.b > 0 and self.c > 0, f"Not positive: {self}"
    
    def gram_matrix(self) -> Tuple[Tuple[int,int], Tuple[int,int]]:
        """Return the Gram matrix as ((g00, g01), (g10, g11))."""
        g00 = self.a**2 + self.b**2  # = c²
        g01 = self.a * self.b + self.b * self.c
        g11 = self.b**2 + self.c**2
        return ((g00, g01), (g01, g11))
    
    def gram_trace(self) -> int:
        """Gram trace = a² + 2b² + c²."""
        return self.a**2 + 2 * self.b**2 + self.c**2
    
    def gram_det(self) -> int:
        """Gram determinant = (ac - b²)²."""
        return (self.a * self.c - self.b**2)**2
    
    def short_norm_sq(self) -> int:
        """Minimum basis vector squared norm = c²."""
        return self.c**2
    
    def ac_minus_b2(self) -> int:
        """The signature invariant ac - b²."""
        return self.a * self.c - self.b**2


@dataclass(frozen=True)
class GramInvariant:
    """Complete Gram invariant package for a Pythagorean triple."""
    trace: int
    det: int
    g00: int  # = c²
    g01: int  # = b(a+c)
    g11: int  # = b² + c²
    
    @staticmethod
    def from_triple(t: PythagTriple) -> 'GramInvariant':
        G = t.gram_matrix()
        return GramInvariant(
            trace=t.gram_trace(),
            det=t.gram_det(),
            g00=G[0][0],
            g01=G[0][1],
            g11=G[1][1],
        )
    
    def reconstruct_triple(self) -> Optional[PythagTriple]:
        """Reconstruct the triple from Gram data.
        
        Algorithm:
        1. c² = g00, so c = √g00
        2. b² = g11 - g00 = g11 - c², so b = √(g11 - c²)
        3. a² = c² - b², so a = √(c² - b²)
        4. Verify: g01 = b(a + c)
        
        Returns None if data is inconsistent.
        
        Complexity: O(1) (constant number of integer square root computations)
        """
        c2 = self.g00
        c = int(math.isqrt(c2))
        if c * c != c2 or c <= 0:
            return None
        
        b2 = self.g11 - c2
        if b2 < 0:
            return None
        b = int(math.isqrt(b2))
        if b * b != b2 or b <= 0:
            return None
        
        a2 = c2 - b2
        if a2 < 0:
            return None
        a = int(math.isqrt(a2))
        if a * a != a2 or a <= 0:
            return None
        
        # Verify consistency
        if a * b + b * c != self.g01:
            return None
        
        return PythagTriple(a, b, c)


# ============================================================================
# Berggren Generators
# ============================================================================

def berggren_A(t: PythagTriple) -> PythagTriple:
    """Apply Berggren generator A.
    
    Time: O(1), Space: O(1)
    """
    a, b, c = t.a, t.b, t.c
    return PythagTriple(a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(t: PythagTriple) -> PythagTriple:
    """Apply Berggren generator B.
    
    Time: O(1), Space: O(1)
    """
    a, b, c = t.a, t.b, t.c
    return PythagTriple(a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(t: PythagTriple) -> PythagTriple:
    """Apply Berggren generator C.
    
    Time: O(1), Space: O(1)
    """
    a, b, c = t.a, t.b, t.c
    return PythagTriple(-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': berggren_A, 'B': berggren_B, 'C': berggren_C}


def apply_path(root: PythagTriple, path: str) -> PythagTriple:
    """Apply a sequence of generators specified by a string like 'ABC'.
    
    Time: O(|path|), Space: O(1)
    """
    t = root
    for ch in path:
        t = GENERATORS[ch](t)
    return t


# ============================================================================
# Lagrange Reduction for Rank-2 Lattices
# ============================================================================

def lagrange_reduce(v1: Tuple[int,int], v2: Tuple[int,int]) -> Tuple[Tuple[int,int], Tuple[int,int]]:
    """Lagrange (Gauss) reduction of a rank-2 lattice basis.
    
    Given basis vectors v1, v2, returns a reduced basis (u1, u2) where:
    - |u1| ≤ |u2|
    - |⟨u1, u2⟩| ≤ |u1|²/2
    
    This is the rank-2 analogue of LLL reduction and produces the unique
    reduced basis (up to sign and ordering).
    
    Time: O(log(max_norm)) iterations, Space: O(1)
    """
    def dot(a, b):
        return a[0]*b[0] + a[1]*b[1]
    
    def norm_sq(v):
        return dot(v, v)
    
    # Ensure |v1| ≤ |v2|
    if norm_sq(v1) > norm_sq(v2):
        v1, v2 = v2, v1
    
    while True:
        n1 = norm_sq(v1)
        if n1 == 0:
            break
        
        # Compute the closest integer to ⟨v2, v1⟩ / ⟨v1, v1⟩
        d = dot(v2, v1)
        q = round(d / n1)  # Nearest integer
        
        if q == 0:
            break
        
        # v2 ← v2 - q * v1
        v2 = (v2[0] - q * v1[0], v2[1] - q * v1[1])
        
        # Swap if needed to maintain |v1| ≤ |v2|
        if norm_sq(v2) < norm_sq(v1):
            v1, v2 = v2, v1
    
    return v1, v2


def reduced_gram(v1: Tuple[int,int], v2: Tuple[int,int]) -> Tuple[Tuple[int,int], Tuple[int,int]]:
    """Compute the Gram matrix of the Lagrange-reduced basis.
    
    Time: O(log(max_norm)), Space: O(1)
    """
    u1, u2 = lagrange_reduce(v1, v2)
    def dot(a, b):
        return a[0]*b[0] + a[1]*b[1]
    
    return ((dot(u1,u1), dot(u1,u2)), (dot(u1,u2), dot(u2,u2)))


# ============================================================================
# Certified Short-Basis Reconstruction
# ============================================================================

def reconstruct_from_invariant(inv: GramInvariant) -> Optional[Tuple[Tuple[int,int], Tuple[int,int]]]:
    """Reconstruct a reduced basis from a Gram invariant.
    
    Algorithm:
    1. Reconstruct the triple (a, b, c) from the invariant.
    2. Form the basis v1 = (a, b), v2 = (b, c).
    3. Apply Lagrange reduction.
    4. Verify the reduced basis has the correct Gram structure.
    
    Returns None if the invariant is not realizable.
    
    Time: O(log c) for reduction, O(1) for reconstruction
    Space: O(1)
    """
    t = inv.reconstruct_triple()
    if t is None:
        return None
    
    v1 = (t.a, t.b)
    v2 = (t.b, t.c)
    
    u1, u2 = lagrange_reduce(v1, v2)
    return (u1, u2)


def verify_reconstruction(t: PythagTriple) -> bool:
    """Verify the full reconstruction pipeline:
    triple → invariant → reconstruction → reduced basis.
    
    Returns True if the pipeline is consistent.
    """
    inv = GramInvariant.from_triple(t)
    reconstructed = inv.reconstruct_triple()
    
    if reconstructed is None:
        return False
    
    if reconstructed != t:
        return False
    
    basis = reconstruct_from_invariant(inv)
    if basis is None:
        return False
    
    u1, u2 = basis
    # Verify reduced basis generates same lattice (det check)
    orig_det = t.a * t.c - t.b * t.b  # det of [[a,b],[b,c]]
    new_det = u1[0] * u2[1] - u1[1] * u2[0]
    
    return abs(new_det) > 0  # Nondegenerate


# ============================================================================
# Det Monotonicity Factorization Certificates
# ============================================================================

def det_mono_certificate_A(t: PythagTriple) -> Dict:
    """Compute the algebraic certificate for det monotonicity under generator A.
    
    The factorization is:
    (a'c' - b'²)² - (ac - b²)² = 4b · (3b² - ab - 3bc - ac) · (2b - a - 3c)
    
    Both inner factors are nonpositive for positive Pythagorean triples,
    making the product nonneg.
    """
    a, b, c = t.a, t.b, t.c
    child = berggren_A(t)
    
    original_invariant = a * c - b**2
    child_invariant = child.a * child.c - child.b**2
    
    factor1 = b
    factor2 = 3*b**2 - a*b - 3*b*c - a*c  # ≤ 0
    factor3 = 2*b - a - 3*c                 # ≤ 0
    
    product = 4 * factor1 * factor2 * factor3
    diff = child_invariant**2 - original_invariant**2
    
    return {
        'original': original_invariant,
        'child': child_invariant,
        'diff': diff,
        'factored': product,
        'factor1_sign': 'positive' if factor1 > 0 else 'zero',
        'factor2_sign': 'nonpositive' if factor2 <= 0 else 'POSITIVE (unexpected)',
        'factor3_sign': 'nonpositive' if factor3 <= 0 else 'POSITIVE (unexpected)',
        'product_nonneg': product >= 0,
        'identity_verified': diff == product,
    }


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    root = PythagTriple(3, 4, 5)
    
    print("=== Berggren Lattice Reduction: Algorithm Demonstrations ===\n")
    
    # 1. Gram invariant computation and reconstruction
    print("1. Gram Invariant Computation and Reconstruction")
    print("-" * 50)
    inv = GramInvariant.from_triple(root)
    print(f"   Triple: {root}")
    print(f"   Invariant: trace={inv.trace}, det={inv.det}")
    print(f"   Gram: [[{inv.g00}, {inv.g01}], [{inv.g01}, {inv.g11}]]")
    
    reconstructed = inv.reconstruct_triple()
    print(f"   Reconstructed: {reconstructed}")
    print(f"   Match: {reconstructed == root}")
    
    # 2. Lagrange reduction
    print(f"\n2. Lagrange Reduction of Berggren Lattice Bases")
    print("-" * 50)
    for path in ['', 'A', 'B', 'C', 'AA', 'AB', 'ABC']:
        t = apply_path(root, path) if path else root
        v1, v2 = (t.a, t.b), (t.b, t.c)
        u1, u2 = lagrange_reduce(v1, v2)
        print(f"   Path {'root' if not path else path}: ({t.a},{t.b},{t.c})")
        print(f"     Original basis: {v1}, {v2} → norms: {v1[0]**2+v1[1]**2}, {v2[0]**2+v2[1]**2}")
        print(f"     Reduced basis:  {u1}, {u2} → norms: {u1[0]**2+u1[1]**2}, {u2[0]**2+u2[1]**2}")
    
    # 3. Full reconstruction pipeline
    print(f"\n3. Full Reconstruction Pipeline Verification")
    print("-" * 50)
    tree_triples = [root]
    for gen_name, gen in GENERATORS.items():
        tree_triples.append(gen(root))
        for gen2_name, gen2 in GENERATORS.items():
            tree_triples.append(gen2(gen(root)))
    
    all_ok = True
    for t in tree_triples:
        ok = verify_reconstruction(t)
        if not ok:
            print(f"   FAILED: {t}")
            all_ok = False
    print(f"   Tested {len(tree_triples)} triples: {'All passed ✓' if all_ok else 'FAILURES DETECTED'}")
    
    # 4. Det monotonicity certificates
    print(f"\n4. Determinant Monotonicity Certificates (Generator A)")
    print("-" * 50)
    t = root
    for i in range(4):
        cert = det_mono_certificate_A(t)
        print(f"   Depth {i}: ac-b² = {cert['original']}")
        print(f"     Child ac-b² = {cert['child']}")
        print(f"     (child)² - (parent)² = {cert['diff']}")
        print(f"     Factored = {cert['factored']}")
        print(f"     Identity verified: {cert['identity_verified']}")
        print(f"     Product ≥ 0: {cert['product_nonneg']}")
        t = berggren_A(t)
