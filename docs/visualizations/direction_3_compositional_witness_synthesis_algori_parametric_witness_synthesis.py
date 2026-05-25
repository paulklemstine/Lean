#!/usr/bin/env python3
"""
Algorithms for Compositional Witness Synthesis of Pythagorean Triples

This module implements the core algorithms from the research paper:
1. Parametric witness synthesis
2. Berggren tree enumeration and path-finding
3. Gaussian composition via Brahmagupta-Fibonacci identity
4. Berggren path descent (inverse synthesis)
5. Witness size analysis

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from math import gcd, log2, log
from typing import Tuple, List, Optional, Generator
from dataclasses import dataclass

# ============================================================
# Core Types
# ============================================================

Triple = Tuple[int, int, int]
BerggrenPath = List[int]  # Each element in {0, 1, 2} = {A, B, C}

# ============================================================
# Berggren Matrices and Inverses
# ============================================================

BERGGREN = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64),   # A
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64),      # B
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64),   # C
]

# Inverse Berggren matrices (for descent)
BERGGREN_INV = [
    np.array([[1, 2, -2], [-2, -1, 2], [2, 2, -3]], dtype=np.int64),    # A⁻¹
    np.array([[1, -2, -2], [-2, -1, 2], [-2, 2, -3]], dtype=np.int64),  # B⁻¹  -- FIX LATER
    np.array([[-1, -2, 2], [2, -1, 2], [-2, -2, 3]], dtype=np.int64),  # C⁻¹  -- FIX LATER
]

# Recompute inverses properly
for i in range(3):
    M = BERGGREN[i].astype(float)
    inv = np.round(np.linalg.inv(M)).astype(np.int64)
    BERGGREN_INV[i] = inv

ROOT = np.array([3, 4, 5], dtype=np.int64)

# ============================================================
# §1. Parametric Witness Synthesis
# ============================================================

def parametric_witness(m: int, n: int) -> Triple:
    """Synthesize a Pythagorean triple from parameters (m, n).
    
    Produces (m² - n², 2mn, m² + n²), which always satisfies a² + b² = c².
    
    Complexity: O(1) arithmetic operations.
    
    Args:
        m: First parameter (positive integer)
        n: Second parameter (positive integer, n < m)
    
    Returns:
        Triple (a, b, c) with a² + b² = c²
    
    Examples:
        >>> parametric_witness(2, 1)
        (3, 4, 5)
        >>> parametric_witness(3, 2)
        (5, 12, 13)
        >>> parametric_witness(4, 3)
        (7, 24, 25)
    """
    return (m**2 - n**2, 2*m*n, m**2 + n**2)


def is_primitive_params(m: int, n: int) -> bool:
    """Check if parameters (m, n) generate a primitive triple.
    
    The triple is primitive iff gcd(m, n) = 1 and m - n is odd.
    
    Args:
        m, n: Parametric witness parameters
    
    Returns:
        True if the generated triple would be primitive
    """
    return gcd(m, n) == 1 and (m - n) % 2 == 1


def enumerate_parametric(max_hyp: int) -> List[Triple]:
    """Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hyp.
    
    Uses the parametric family with primitivity criterion.
    
    Complexity: O(max_hyp) triples generated.
    
    Args:
        max_hyp: Upper bound on hypotenuse
    
    Returns:
        Sorted list of primitive Pythagorean triples
    """
    triples = []
    m = 2
    while m**2 + 1 <= max_hyp:
        for n in range(1, m):
            c = m**2 + n**2
            if c > max_hyp:
                break
            if is_primitive_params(m, n):
                a = m**2 - n**2
                b = 2 * m * n
                if a > b:
                    a, b = b, a
                triples.append((a, b, c))
        m += 1
    return sorted(triples, key=lambda t: t[2])


# ============================================================
# §2. Berggren Tree Synthesis
# ============================================================

def berggren_synth(path: BerggrenPath) -> Triple:
    """Synthesize a Pythagorean triple by following a Berggren path from (3,4,5).
    
    The path is applied right-to-left: path = [i₁, i₂, ..., iₖ] gives
    B_{i₁}(B_{i₂}(...B_{iₖ}(3,4,5)...)).
    
    Complexity: O(k) matrix-vector multiplications where k = len(path).
    
    Args:
        path: List of Berggren matrix indices (0=A, 1=B, 2=C)
    
    Returns:
        Synthesized Pythagorean triple
    """
    v = ROOT.copy()
    for idx in reversed(path):
        v = BERGGREN[idx] @ v
    return (int(v[0]), int(v[1]), int(v[2]))


def berggren_enumerate_depth(depth: int) -> Generator[Tuple[BerggrenPath, Triple], None, None]:
    """Generate all Berggren tree triples at exactly the given depth.
    
    Complexity: O(3^depth) triples, each in O(depth) time.
    
    Args:
        depth: Tree depth (0 = root only)
    
    Yields:
        (path, triple) pairs
    """
    if depth == 0:
        yield ([], (3, 4, 5))
        return
    
    def _gen(d: int, current_path: list, current_vec: np.ndarray):
        if d == 0:
            yield (list(current_path), 
                   (int(current_vec[0]), int(current_vec[1]), int(current_vec[2])))
            return
        for i in range(3):
            new_vec = BERGGREN[i] @ current_vec
            current_path.append(i)
            yield from _gen(d - 1, current_path, new_vec)
            current_path.pop()
    
    yield from _gen(depth, [], ROOT.copy())


def berggren_enumerate_up_to(max_depth: int) -> List[Tuple[BerggrenPath, Triple]]:
    """Enumerate all Berggren tree triples up to given depth.
    
    Complexity: O(3^{max_depth+1}) total triples.
    
    Args:
        max_depth: Maximum tree depth
    
    Returns:
        List of (path, triple) pairs
    """
    results = []
    for d in range(max_depth + 1):
        for item in berggren_enumerate_depth(d):
            results.append(item)
    return results


# ============================================================
# §3. Gaussian Composition
# ============================================================

def gaussian_compose(t1: Triple, t2: Triple) -> Triple:
    """Compose two Pythagorean triples via Brahmagupta-Fibonacci identity.
    
    Uses: (a₁² + b₁²)(a₂² + b₂²) = (a₁a₂ - b₁b₂)² + (a₁b₂ + b₁a₂)²
    
    Complexity: O(1) arithmetic operations.
    
    Args:
        t1: First Pythagorean triple (a₁, b₁, c₁)
        t2: Second Pythagorean triple (a₂, b₂, c₂)
    
    Returns:
        Composed triple (a₁a₂ - b₁b₂, a₁b₂ + b₁a₂, c₁c₂)
    """
    a1, b1, c1 = t1
    a2, b2, c2 = t2
    return (a1*a2 - b1*b2, a1*b2 + b1*a2, c1*c2)


def iterated_compose(t: Triple, n: int) -> Triple:
    """Compose a Pythagorean triple with itself n times.
    
    Uses fast exponentiation: T^n = T^{n//2} ⊗ T^{n//2} [⊗ T if n odd].
    
    Complexity: O(log n) compositions.
    
    Args:
        t: Base Pythagorean triple
        n: Number of compositions (n ≥ 1)
    
    Returns:
        n-fold Gaussian composition of t
    """
    if n == 1:
        return t
    if n % 2 == 0:
        half = iterated_compose(t, n // 2)
        return gaussian_compose(half, half)
    else:
        return gaussian_compose(t, iterated_compose(t, n - 1))


# ============================================================
# §4. Berggren Path Descent
# ============================================================

def berggren_descent(triple: Triple) -> Optional[BerggrenPath]:
    """Find the Berggren path from (3,4,5) to the given primitive triple.
    
    Uses the descent algorithm: apply inverse matrices until reaching (3,4,5).
    The correct inverse is the one that produces all-positive components.
    
    Complexity: O(log c) steps where c is the hypotenuse.
    
    Args:
        triple: A primitive Pythagorean triple with positive components
    
    Returns:
        Berggren path, or None if the triple is not primitive/positive
    """
    v = np.array(triple, dtype=np.int64)
    path = []
    max_iterations = 1000
    
    for _ in range(max_iterations):
        if v[0] == 3 and v[1] == 4 and v[2] == 5:
            return path
        
        # Try each inverse matrix
        found = False
        for i in range(3):
            w = BERGGREN_INV[i] @ v
            if w[0] > 0 and w[1] > 0 and w[2] > 0:
                path.append(i)
                v = w
                found = True
                break
        
        if not found:
            return None  # Not in the Berggren tree
    
    return None  # Didn't converge


# ============================================================
# §5. Witness Size Analysis
# ============================================================

@dataclass
class WitnessAnalysis:
    """Analysis of a synthesized witness."""
    triple: Triple
    hypotenuse: int
    log_hypotenuse: float
    is_pythagorean: bool
    is_primitive: bool
    path_length: Optional[int]
    
    def __repr__(self):
        return (f"WitnessAnalysis(triple={self.triple}, hyp={self.hypotenuse}, "
                f"log₂(hyp)={self.log_hypotenuse:.2f}, pyth={self.is_pythagorean}, "
                f"prim={self.is_primitive}, path_len={self.path_length})")


def analyze_witness(triple: Triple, path: Optional[BerggrenPath] = None) -> WitnessAnalysis:
    """Analyze a synthesized Pythagorean triple witness.
    
    Args:
        triple: The Pythagorean triple
        path: Optional Berggren path used to generate it
    
    Returns:
        WitnessAnalysis with size and validity information
    """
    a, b, c = triple
    return WitnessAnalysis(
        triple=triple,
        hypotenuse=c,
        log_hypotenuse=log2(c) if c > 0 else 0,
        is_pythagorean=(a**2 + b**2 == c**2),
        is_primitive=(gcd(abs(a), abs(b)) == 1),
        path_length=len(path) if path is not None else None
    )


def lorentz_form(triple: Triple) -> int:
    """Compute the Lorentz form Q(a,b,c) = a² + b² - c².
    
    For a Pythagorean triple, this is always 0.
    The Berggren matrices preserve this form (they lie in O(2,1;ℤ)).
    """
    a, b, c = triple
    return a**2 + b**2 - c**2


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Parametric Witness ===")
    for m in range(2, 6):
        for n in range(1, m):
            if is_primitive_params(m, n):
                t = parametric_witness(m, n)
                analysis = analyze_witness(t)
                print(f"  W({m},{n}) = {t}  {analysis}")
    
    print("\n=== Berggren Tree (depth 2) ===")
    for path, triple in berggren_enumerate_up_to(2):
        path_str = ''.join('ABC'[i] for i in path) or 'root'
        q = lorentz_form(triple)
        print(f"  {path_str:5s} → {triple}  Q={q}")
    
    print("\n=== Gaussian Composition ===")
    t1, t2 = (3, 4, 5), (5, 12, 13)
    composed = gaussian_compose(t1, t2)
    print(f"  {t1} ⊗ {t2} = {composed}")
    print(f"  Verification: {composed[0]}² + {composed[1]}² = {composed[0]**2 + composed[1]**2} = {composed[2]}² = {composed[2]**2}")
    
    print("\n=== Berggren Descent ===")
    test_triples = [(5, 12, 13), (21, 20, 29), (15, 8, 17), (7, 24, 25)]
    for t in test_triples:
        path = berggren_descent(t)
        if path is not None:
            path_str = ''.join('ABC'[i] for i in path)
            reconstructed = berggren_synth(path)
            print(f"  {t} → path={path_str}, reconstructed={reconstructed}")
        else:
            print(f"  {t} → not found in tree")
    
    print("\n=== Iterated Composition ===")
    base = (3, 4, 5)
    for n in range(1, 6):
        result = iterated_compose(base, n)
        print(f"  (3,4,5)^{n} = {result}, hyp={result[2]}, valid={result[0]**2 + result[1]**2 == result[2]**2}")
