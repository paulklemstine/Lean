"""
Algorithms for Hyperbolic Number Theory
========================================
Implements the core algorithms from the research paper with
full docstrings, type hints, and complexity analysis.
"""

import cmath
import math
from typing import List, Tuple, Optional
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Möbius Map Evaluation
# ═══════════════════════════════════════════════════════════════

def moebius_map(a: complex, z: complex) -> complex:
    """
    Compute the Möbius automorphism φ_a(z) = (a - z) / (1 - conj(a) * z).

    This maps the unit disk to itself when |a| < 1 and |z| < 1.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        a: Center point in the unit disk (|a| < 1)
        z: Point to transform (|z| < 1)

    Returns:
        The transformed point φ_a(z), also in the unit disk.

    Example:
        >>> w = moebius_map(0.3+0.4j, 0.1+0.2j)
        >>> abs(w) < 1  # Always true for disk points
        True
    """
    denom = 1 - a.conjugate() * z
    if abs(denom) < 1e-15:
        raise ValueError("Denominator too close to zero")
    return (a - z) / denom


def moebius_compose(generators: List[complex], word: List[int]) -> complex:
    """
    Evaluate a word in the Möbius group by composing transformations.

    Starting from 0, applies φ_{g_{w[0]}}, then φ_{g_{w[1]}}, etc.

    Time complexity: O(|word|)
    Space complexity: O(1)

    Args:
        generators: List of generator points in the disk
        word: List of generator indices

    Returns:
        The image of 0 under the composed transformation.

    Example:
        >>> gens = [0.5+0.0j, 0.0+0.5j]
        >>> z = moebius_compose(gens, [0, 1, 0])
        >>> abs(z) < 1
        True
    """
    z = 0 + 0j
    for idx in word:
        z = moebius_map(generators[idx], z)
    return z


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Hyperbolic Lattice Enumeration
# ═══════════════════════════════════════════════════════════════

def enumerate_hyperbolic_integers(
    generators: List[complex],
    max_word_length: int
) -> List[Tuple[complex, List[int]]]:
    """
    Enumerate all hyperbolic integers up to a given word length.

    Uses breadth-first search on the Cayley graph to find all
    orbit points of 0 under words of length ≤ max_word_length.

    Time complexity: O(k^n) where k = |generators|, n = max_word_length
    Space complexity: O(k^n)

    Args:
        generators: Generator points in the unit disk
        max_word_length: Maximum word length to enumerate

    Returns:
        List of (point, word) pairs, sorted by word length.
    """
    k = len(generators)
    results = [(0 + 0j, [])]  # Origin = empty word

    current_words = [[]]
    for length in range(1, max_word_length + 1):
        next_words = []
        for word in current_words:
            for i in range(k):
                new_word = word + [i]
                z = moebius_compose(generators, new_word)
                results.append((z, new_word))
                next_words.append(new_word)
        current_words = next_words

    return results


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Primitive Word Detection (Hyperbolic Primes)
# ═══════════════════════════════════════════════════════════════

def is_primitive_word(word: List[int]) -> bool:
    """
    Check if a word is primitive (not a proper power of a shorter word).

    A word w is primitive if there is no shorter word u such that
    w = u^k for some k ≥ 2.

    Time complexity: O(n²) where n = len(word)
    Space complexity: O(n)

    Args:
        word: A word (list of generator indices)

    Returns:
        True if the word is primitive, False otherwise.

    Example:
        >>> is_primitive_word([0, 1, 0, 1])  # (01)² - not primitive
        False
        >>> is_primitive_word([0, 1, 1])  # primitive
        True
    """
    n = len(word)
    if n == 0:
        return False
    for period in range(1, n):
        if n % period == 0:
            is_power = True
            for i in range(n):
                if word[i] != word[i % period]:
                    is_power = False
                    break
            if is_power:
                return False
    return True


def count_primitive_words(k: int, n: int) -> int:
    """
    Count primitive words of length n over k letters using Witt's formula.

    M(k, n) = (1/n) Σ_{d|n} μ(n/d) · k^d

    This is the exact count of "hyperbolic primes" at word-length n.

    Time complexity: O(√n · log(n))
    Space complexity: O(√n)

    Args:
        k: Alphabet size (number of generators)
        n: Word length

    Returns:
        Number of primitive necklaces of length n.
    """
    if n == 0:
        return 0

    def moebius_mu(m: int) -> int:
        if m == 1:
            return 1
        result = 1
        d = 2
        temp = m
        while d * d <= temp:
            if temp % d == 0:
                temp //= d
                if temp % d == 0:
                    return 0
                result *= -1
            d += 1
        if temp > 1:
            result *= -1
        return result

    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += moebius_mu(n // d) * k**d
    return total // n


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: SL(2,R) Trace Classification
# ═══════════════════════════════════════════════════════════════

class SL2R:
    """
    An element of SL(2,R) represented as a 2x2 matrix with det = 1.

    Classification by trace:
    - Elliptic:   |tr| < 2 (rotation-like, complex eigenvalues on unit circle)
    - Parabolic:  |tr| = 2 (translation-like, repeated eigenvalue ±1)
    - Hyperbolic: |tr| > 2 (dilation-like, real eigenvalues λ, 1/λ)
    """

    def __init__(self, a: float, b: float, c: float, d: float):
        det = a * d - b * c
        if abs(det - 1.0) > 1e-10:
            raise ValueError(f"Not in SL(2,R): det = {det}")
        self.a, self.b, self.c, self.d = a, b, c, d

    @property
    def trace(self) -> float:
        return self.a + self.d

    @property
    def discriminant(self) -> float:
        return self.trace**2 - 4

    def classify(self) -> str:
        tr = abs(self.trace)
        if tr < 2 - 1e-10:
            return "elliptic"
        elif tr < 2 + 1e-10:
            return "parabolic"
        else:
            return "hyperbolic"

    def __mul__(self, other: 'SL2R') -> 'SL2R':
        return SL2R(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inv(self) -> 'SL2R':
        return SL2R(self.d, -self.b, -self.c, self.a)

    def verify_fricke_vogt(self, other: 'SL2R') -> float:
        """Verify tr(AB) + tr(AB⁻¹) = tr(A)·tr(B)."""
        lhs = (self * other).trace + (self * other.inv()).trace
        rhs = self.trace * other.trace
        return abs(lhs - rhs)


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Tropical Shadow Computation
# ═══════════════════════════════════════════════════════════════

def tropical_shadow(r: float) -> float:
    """
    Compute the tropical shadow T(r) = -log(1 - r²).

    This maps the pseudohyperbolic distance to tropical geometry,
    where multiplicative composition becomes additive.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        r: A value in [0, 1)

    Returns:
        The tropical shadow value, always ≥ 0.

    Properties:
    - T(0) = 0
    - T is monotone increasing on [0, 1)
    - T(r) → ∞ as r → 1⁻
    """
    if r < 0 or r >= 1:
        raise ValueError(f"r must be in [0, 1), got {r}")
    return -math.log(1 - r**2)


def pseudohyperbolic_distance(a: complex, z: complex) -> float:
    """
    Compute the pseudohyperbolic distance ρ(a, z) = |φ_a(z)|.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return abs(moebius_map(a, z))


# ═══════════════════════════════════════════════════════════════
# Algorithm 6: Cayley Ball Growth Analysis
# ═══════════════════════════════════════════════════════════════

def analyze_growth(k: int, max_n: int = 20) -> dict:
    """
    Analyze growth rates of the Cayley graph for a k-generator group.

    Computes:
    - Ball sizes |B(n)| for the Cayley graph
    - Shell sizes |S(n)| = |B(n)| - |B(n-1)|
    - Growth ratio |B(n)| / |B(n-1)|
    - Primitive word counts (hyperbolic primes)

    Time complexity: O(n · d(n)) per level, O(n² · √n) total
    Space complexity: O(n)

    Returns:
        Dictionary with growth statistics.
    """
    stats = {
        'ball_sizes': [],
        'shell_sizes': [],
        'growth_ratios': [],
        'primitive_counts': [],
        'prime_density': [],
    }

    for n in range(max_n + 1):
        ball = sum(k**i for i in range(n + 1))
        shell = k**n
        ratio = ball / max(stats['ball_sizes'][-1], 1) if n > 0 else float('inf')
        prim = count_primitive_words(k, n) if n > 0 else 0
        density = prim / shell if shell > 0 and n > 0 else 0

        stats['ball_sizes'].append(ball)
        stats['shell_sizes'].append(shell)
        stats['growth_ratios'].append(ratio)
        stats['primitive_counts'].append(prim)
        stats['prime_density'].append(density)

    return stats


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Demonstrate all algorithms
    print("=== Möbius Map ===")
    a = 0.3 + 0.4j
    z = 0.1 + 0.2j
    w = moebius_map(a, z)
    print(f"φ_{a}({z}) = {w:.6f}, |w| = {abs(w):.6f}")

    print("\n=== Hyperbolic Lattice ===")
    gens = [0.5 + 0.0j, 0.0 + 0.5j]
    lattice = enumerate_hyperbolic_integers(gens, 3)
    print(f"Points up to word length 3: {len(lattice)}")
    for pt, word in lattice[:10]:
        print(f"  word={word}, point={pt:.4f}, |pt|={abs(pt):.4f}")

    print("\n=== Primitive Words (Hyperbolic Primes) ===")
    for n in range(1, 11):
        count = count_primitive_words(2, n)
        print(f"  n={n}: {count} primitive words of length {n}")

    print("\n=== Fricke-Vogt Identity ===")
    A = SL2R(2, 1, 1, 1)
    B = SL2R(1, 1, 0, 1)
    err = A.verify_fricke_vogt(B)
    print(f"  |tr(AB) + tr(AB⁻¹) - tr(A)·tr(B)| = {err:.2e}")

    print("\n=== Growth Analysis ===")
    stats = analyze_growth(2, 15)
    for n in range(16):
        print(f"  n={n:>2}: ball={stats['ball_sizes'][n]:>8,}, "
              f"primes={stats['primitive_counts'][n]:>6,}, "
              f"density={stats['prime_density'][n]:.4f}")
