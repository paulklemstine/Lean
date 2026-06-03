"""
Algorithms for Spectral Contraction Analysis of Collatz Dynamics

Implements the core computational framework connecting parity words,
contraction exponents, and spectral analysis of Collatz orbits.
"""
from typing import List, Tuple, Optional
import math


def collatz_step(n: int) -> int:
    """The standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the Collatz orbit of n until it reaches 1 or max_steps."""
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def parity_word(n: int, max_steps: int = 10000) -> List[int]:
    """
    Compute the parity word of the Collatz orbit of n.
    Returns a list of 0s and 1s: 1 for odd, 0 for even.
    """
    orbit = collatz_orbit(n, max_steps)
    return [x % 2 for x in orbit[:-1]]  # exclude the final 1


def ones_density(word: List[int]) -> float:
    """Compute the ones-density (fraction of 1s) of a binary word."""
    if not word:
        return 0.0
    return sum(word) / len(word)


def contraction_exponent(j: int, k: int) -> float:
    """
    Compute the contraction exponent ξ(j, k) = k·log(2) - j·log(3).
    Positive values indicate orbit contraction.
    """
    return k * math.log(2) - j * math.log(3)


def critical_density() -> float:
    """The critical density threshold ρ* = log(2)/log(3) ≈ 0.6309."""
    return math.log(2) / math.log(3)


class ParityVector:
    """
    A binary word with tracked ones-count, modeling a Collatz orbit segment.

    Attributes:
        length: Length of the binary word
        ones: Number of 1s (odd steps)
    """

    def __init__(self, length: int, ones: int):
        assert 0 <= ones <= length, f"ones ({ones}) must be in [0, {length}]"
        self.length = length
        self.ones = ones

    @property
    def zeros(self) -> int:
        return self.length - self.ones

    @property
    def density(self) -> float:
        return self.ones / self.length if self.length > 0 else 0.0

    @property
    def contraction(self) -> float:
        return contraction_exponent(self.ones, self.length)

    def compose(self, other: 'ParityVector') -> 'ParityVector':
        """Concatenate two parity vectors (additive statistics)."""
        return ParityVector(self.length + other.length, self.ones + other.ones)

    def __repr__(self) -> str:
        return f"ParityVector(len={self.length}, ones={self.ones}, ρ={self.density:.4f}, ξ={self.contraction:.4f})"


def segment_orbit(word: List[int], segment_size: int) -> List[ParityVector]:
    """
    Partition a parity word into segments of given size.
    The last segment may be shorter.
    """
    segments = []
    for i in range(0, len(word), segment_size):
        chunk = word[i:i + segment_size]
        segments.append(ParityVector(len(chunk), sum(chunk)))
    return segments


def spectral_energy(word: List[int], omega: float) -> float:
    """
    Compute the spectral energy |Ŵ(ω)|² of a parity word at frequency ω.

    Ŵ(ω) = Σ_k w[k] · exp(2πi·ω·k)
    |Ŵ(ω)|² = (Σ w[k]·cos(2πωk))² + (Σ w[k]·sin(2πωk))²
    """
    cos_sum = sum(w * math.cos(2 * math.pi * omega * k)
                  for k, w in enumerate(word))
    sin_sum = sum(w * math.sin(2 * math.pi * omega * k)
                  for k, w in enumerate(word))
    return cos_sum ** 2 + sin_sum ** 2


def spectral_profile(word: List[int], num_freqs: int = 100) -> List[Tuple[float, float]]:
    """
    Compute the spectral energy at num_freqs equally spaced frequencies in [0, 0.5].
    Returns list of (frequency, energy) pairs.
    """
    freqs = [i / (2 * num_freqs) for i in range(num_freqs + 1)]
    return [(f, spectral_energy(word, f)) for f in freqs]


def verify_segment_conjecture(n: int, segment_size: int = 50) -> Tuple[bool, float]:
    """
    Verify the segment-wise density conjecture for a single n.

    Returns (passed, max_density) where passed is True if all segments
    have density < log(2)/log(3).
    """
    word = parity_word(n)
    if not word:
        return True, 0.0

    segments = segment_orbit(word, segment_size)
    rho_star = critical_density()
    max_density = max(s.density for s in segments)
    return max_density < rho_star, max_density


def batch_verify_conjecture(
    n_max: int = 10000,
    segment_size: int = 50
) -> dict:
    """
    Batch-verify the segment-wise density conjecture for n in [2, n_max].

    Returns statistics dictionary.
    """
    total = 0
    passed = 0
    max_density_overall = 0.0
    worst_n = 2
    densities = []

    for n in range(2, n_max + 1):
        total += 1
        ok, max_d = verify_segment_conjecture(n, segment_size)
        if ok:
            passed += 1
        densities.append(max_d)
        if max_d > max_density_overall:
            max_density_overall = max_d
            worst_n = n

    return {
        "total": total,
        "passed": passed,
        "pass_rate": passed / total,
        "max_density": max_density_overall,
        "worst_n": worst_n,
        "critical_density": critical_density(),
        "margin": critical_density() - max_density_overall,
    }


if __name__ == "__main__":
    # Quick demonstration
    rho_star = critical_density()
    print(f"Critical density ρ* = log(2)/log(3) = {rho_star:.6f}")
    print(f"Fundamental inequality: log(3) = {math.log(3):.6f} < {2*math.log(2):.6f} = 2·log(2)")
    print()

    for n in [7, 27, 97, 871]:
        word = parity_word(n)
        rho = ones_density(word)
        xi = contraction_exponent(sum(word), len(word))
        print(f"n={n}: orbit length={len(word)}, density={rho:.4f}, ξ={xi:.4f}, contracts={xi > 0}")
