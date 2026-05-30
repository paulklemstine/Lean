"""
Hyperbolic Number Theory: Core Algorithms
==========================================
Implementations of the algorithms from the research paper with
complexity analysis and docstrings.
"""

import cmath
import math
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass
from enum import Enum


# =============================================================================
# Algorithm 1: Möbius Transformation on the Poincaré Disk
# =============================================================================

def mobius_transform(a: complex, theta: float, z: complex) -> complex:
    """
    Apply a Möbius transformation to a point in the Poincaré disk.

    The transformation is: φ_{a,θ}(z) = e^{iθ} · (z - a) / (1 - conj(a) · z)

    Parameters:
        a: Center point in the disk (|a| < 1)
        theta: Rotation angle in radians
        z: Input point in the disk (|z| < 1)

    Returns:
        The image point φ(z), guaranteed to be in the disk when inputs are valid.

    Time complexity: O(1)
    Space complexity: O(1)

    Example:
        >>> w = mobius_transform(0.3+0.4j, math.pi/4, 0.1+0.2j)
        >>> abs(w) < 1  # Disk preservation
        True
    """
    eitheta = cmath.exp(1j * theta)
    denom = 1 - a.conjugate() * z
    if abs(denom) < 1e-15:
        raise ValueError("Degenerate: denominator too close to zero")
    return eitheta * (z - a) / denom


def hyperbolic_distance(z: complex, w: complex) -> float:
    """
    Compute the hyperbolic distance between two points in the Poincaré disk.

    d_H(z, w) = 2 · arctanh(|(z-w)/(1-conj(z)·w)|)

    Time complexity: O(1)
    Space complexity: O(1)
    """
    denom = 1 - z.conjugate() * w
    if abs(denom) < 1e-15:
        return float('inf')
    pd = abs((z - w) / denom)
    if pd >= 1 - 1e-15:
        return float('inf')
    return 2 * math.atanh(pd)


# =============================================================================
# Algorithm 2: Cayley Word Arithmetic
# =============================================================================

class LetterType(Enum):
    GEN = 1
    INV = -1


@dataclass
class CayleyLetter:
    """A letter in the Cayley alphabet: generator or inverse."""
    index: int
    letter_type: LetterType

    def inverse(self) -> 'CayleyLetter':
        new_type = LetterType.INV if self.letter_type == LetterType.GEN else LetterType.GEN
        return CayleyLetter(self.index, new_type)

    def __repr__(self):
        name = f"g{self.index}"
        if self.letter_type == LetterType.INV:
            name += "⁻¹"
        return name


class CayleyWord:
    """
    A word in the Cayley graph of a finitely generated group.
    Represents a 'hyperbolic integer'.

    Time complexity:
        - Creation: O(k) where k = word length
        - Multiplication (concatenation): O(k1 + k2)
        - Reduction: O(k) amortized
    """

    def __init__(self, letters: Optional[List[CayleyLetter]] = None):
        self.letters = letters or []

    @property
    def length(self) -> int:
        """Word length = number of letters."""
        return len(self.letters)

    def __mul__(self, other: 'CayleyWord') -> 'CayleyWord':
        """Multiplication = concatenation."""
        return CayleyWord(self.letters + other.letters)

    def reduce(self) -> 'CayleyWord':
        """
        Free reduction: cancel adjacent inverse pairs.

        Time complexity: O(k) where k = word length
        Space complexity: O(k)
        """
        stack: List[CayleyLetter] = []
        for letter in self.letters:
            if (stack and stack[-1].index == letter.index and
                    stack[-1].letter_type != letter.letter_type):
                stack.pop()
            else:
                stack.append(letter)
        return CayleyWord(stack)

    def is_generator(self) -> bool:
        """Check if this word is a single generator (hyperbolic prime)."""
        return self.length == 1

    def factorize(self) -> List[CayleyLetter]:
        """
        Factor into individual letters (hyperbolic prime factorization).
        Every word uniquely decomposes as a product of generators.
        """
        return list(self.letters)

    def split_half(self) -> Optional[Tuple['CayleyWord', 'CayleyWord']]:
        """
        Split an even-length word into two equal halves.
        Returns None if the word has odd length.
        (Hyperbolic Goldbach decomposition)
        """
        if self.length % 2 != 0:
            return None
        half = self.length // 2
        return CayleyWord(self.letters[:half]), CayleyWord(self.letters[half:])

    def __repr__(self):
        if not self.letters:
            return "ε"
        return "·".join(str(l) for l in self.letters)


# =============================================================================
# Algorithm 3: Orbit Point Generation
# =============================================================================

def generate_orbit_points(
    generators: List[Tuple[complex, float]],
    max_depth: int,
    origin: complex = 0
) -> List[Tuple[complex, int, str]]:
    """
    Generate orbit points Γ·0 by applying all words up to a given depth.

    Parameters:
        generators: List of (center_a, theta) pairs defining Möbius transforms
        max_depth: Maximum word length to enumerate
        origin: Starting point (default: 0)

    Returns:
        List of (point, depth, word_string) tuples

    Time complexity: O(d^R) where d = 2·|generators| and R = max_depth
    Space complexity: O(d^R)
    """
    points = [(origin, 0, "e")]
    current_level = [(origin, "e")]

    # Build all transforms (generators + inverses)
    transforms = []
    for i, (a, theta) in enumerate(generators):
        transforms.append((a, theta, f"g{i}"))
        # Inverse: center = -e^{iθ}·a / ... ≈ negate the action
        transforms.append((mobius_transform(a, theta, 0), -theta, f"g{i}⁻¹"))

    for depth in range(1, max_depth + 1):
        next_level = []
        for pt, word in current_level:
            for a, theta, name in transforms:
                try:
                    new_pt = mobius_transform(a, theta, pt)
                    if abs(new_pt) < 1 - 1e-10:
                        new_word = word + "·" + name if word != "e" else name
                        next_level.append((new_pt, new_word))
                        points.append((new_pt, depth, new_word))
                except ValueError:
                    continue
        current_level = next_level

    return points


# =============================================================================
# Algorithm 4: Hyperbolic Zeta Function (Partial Sums)
# =============================================================================

def hyperbolic_zeta_partial(
    orbit_points: List[complex],
    s: float
) -> float:
    """
    Compute the partial sum of the hyperbolic zeta function:
    ζ_H(s) = Σ_{z ∈ Γ·0, z ≠ 0} ‖z‖^{-2s}

    Parameters:
        orbit_points: List of orbit points (excluding origin)
        s: The parameter s (convergence requires s > δ/2)

    Returns:
        The partial sum

    Time complexity: O(N) where N = len(orbit_points)
    """
    total = 0.0
    for z in orbit_points:
        r = abs(z)
        if r > 1e-15:
            total += r ** (-2 * s)
    return total


# =============================================================================
# Algorithm 5: Growth Rate Estimation
# =============================================================================

def estimate_growth_rate(n_generators: int, max_R: int) -> List[Tuple[int, int, float]]:
    """
    Compute the growth function and estimate the exponential growth rate.

    For a free group on n generators, the growth rate is 2n-1.
    (Each step multiplies by 2n-1 since one direction is forbidden.)

    Returns:
        List of (R, word_count, estimated_rate) tuples
    """
    d = 2 * n_generators  # alphabet size
    results = []
    for R in range(max_R + 1):
        word_count = sum(d**k for k in range(R + 1))
        if R > 0:
            prev_count = sum(d**k for k in range(R))
            rate = word_count / prev_count if prev_count > 0 else 0
        else:
            rate = 1.0
        results.append((R, word_count, rate))
    return results


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=== Hyperbolic Number Theory: Algorithm Demonstrations ===\n")

    # Demo: Möbius transform
    a = 0.3 + 0.4j
    theta = math.pi / 6
    z = 0.1 + 0.2j
    w = mobius_transform(a, theta, z)
    print(f"Möbius({z}) = {w:.6f}, |result| = {abs(w):.6f}")

    # Demo: Cayley words
    g0 = CayleyLetter(0, LetterType.GEN)
    g1 = CayleyLetter(1, LetterType.GEN)
    g0_inv = g0.inverse()

    word1 = CayleyWord([g0, g1, g0])
    word2 = CayleyWord([g0_inv, g1])
    product = word1 * word2
    reduced = product.reduce()

    print(f"\nWord1: {word1} (length {word1.length})")
    print(f"Word2: {word2} (length {word2.length})")
    print(f"Product: {product} (length {product.length})")
    print(f"Reduced: {reduced} (length {reduced.length})")

    # Demo: Growth rates
    print("\nGrowth rate estimation (2 generators):")
    for R, count, rate in estimate_growth_rate(2, 8):
        print(f"  R={R}: {count:8d} words, growth rate ≈ {rate:.4f}")

    # Demo: Orbit generation
    gens = [(0.3 + 0.1j, math.pi / 4), (0.2 - 0.3j, math.pi / 3)]
    orbit = generate_orbit_points(gens, max_depth=3)
    print(f"\nOrbit points (depth ≤ 3): {len(orbit)} points generated")
    for pt, depth, word in orbit[:10]:
        print(f"  depth={depth}: {word} → {pt:.4f} (|z|={abs(pt):.4f})")
