#!/usr/bin/env python3
"""
Algorithms for Spectral Contraction Analysis of Collatz Dynamics

Type-hinted implementations of the core algorithms from the research paper.
"""

import math
from dataclasses import dataclass
from typing import Optional


# ============================================================
# Core Constants
# ============================================================

CRITICAL_DENSITY: float = math.log(2) / math.log(3)
CRITICAL_SPECTRAL_ENERGY: float = CRITICAL_DENSITY ** 2
STOPPING_BOUND_CONSTANT: float = 1.0 / (math.log(2) - 0.5 * math.log(3))


# ============================================================
# Data Structures
# ============================================================

@dataclass
class ContractionSystem:
    """A binary parity word's contraction data."""
    word_length: int  # k: total steps
    ones_count: int   # s: odd steps

    def __post_init__(self) -> None:
        assert self.word_length > 0, "Word length must be positive"
        assert self.ones_count <= self.word_length, "Ones count must be ≤ word length"

    @property
    def exponent(self) -> float:
        """Contraction exponent ξ(k,s) = k·log(2) - s·log(3)."""
        return self.word_length * math.log(2) - self.ones_count * math.log(3)

    @property
    def density(self) -> float:
        """Ones-density s/k."""
        return self.ones_count / self.word_length

    @property
    def contracts(self) -> bool:
        """Whether the system contracts (ξ > 0)."""
        return self.exponent > 0

    @property
    def multiplicative_factor(self) -> float:
        """The multiplicative factor 3^s / 2^k."""
        return math.exp(-self.exponent)

    @property
    def dc_spectral_energy(self) -> float:
        """DC spectral energy (density²)."""
        return self.density ** 2

    @property
    def drift_per_step(self) -> float:
        """Average contraction per step."""
        return self.exponent / self.word_length

    @property
    def contraction_gap(self) -> float:
        """Gap Δ = k·ρ* - s measuring distance from threshold."""
        return self.word_length * CRITICAL_DENSITY - self.ones_count


@dataclass
class TropicalCertificate:
    """A certified contraction bound with rational density bound."""
    system: ContractionSystem
    rational_bound: float  # Rational upper bound on density

    @property
    def is_valid(self) -> bool:
        """Check certificate validity."""
        return (self.system.density <= self.rational_bound and
                self.rational_bound < CRITICAL_DENSITY)

    @property
    def certifies_contraction(self) -> bool:
        """A valid certificate implies contraction."""
        return self.is_valid


# ============================================================
# Collatz Map
# ============================================================

def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, (3n+1)/2 if odd."""
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    """Compute Collatz orbit until reaching 1 or max_steps."""
    orbit: list[int] = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_word(orbit: list[int]) -> list[int]:
    """Extract binary parity word from orbit."""
    return [x % 2 for x in orbit[:-1]]


# ============================================================
# Contraction Analysis
# ============================================================

def contraction_exponent(k: int, s: int) -> float:
    """Compute ξ(k,s) = k·log(2) - s·log(3)."""
    return k * math.log(2) - s * math.log(3)


def ones_density(word: list[int]) -> float:
    """Ones-density of a binary word."""
    return sum(word) / len(word) if word else 0.0


def dc_spectral_energy(word: list[int]) -> float:
    """DC spectral energy = density²."""
    d = ones_density(word)
    return d * d


def full_spectral_energy(word: list[int]) -> list[float]:
    """Compute the full DFT spectral energy of a binary word."""
    k = len(word)
    if k == 0:
        return []
    energies: list[float] = []
    for omega in range(k):
        # DFT: ŵ(ω) = (1/k) Σ w_j · e^{-2πi·j·ω/k}
        real_part = sum(word[j] * math.cos(-2 * math.pi * j * omega / k) for j in range(k)) / k
        imag_part = sum(word[j] * math.sin(-2 * math.pi * j * omega / k) for j in range(k)) / k
        energies.append(real_part**2 + imag_part**2)
    return energies


# ============================================================
# Certificate Construction
# ============================================================

def build_tropical_certificate(
    k: int, s: int, precision: int = 6
) -> Optional[TropicalCertificate]:
    """Attempt to construct a tropical contraction certificate."""
    system = ContractionSystem(k, s)
    # Round density up to rational bound
    q = math.ceil(system.density * 10**precision) / 10**precision
    cert = TropicalCertificate(system, q)
    return cert if cert.is_valid else None


# ============================================================
# Full Orbit Analysis
# ============================================================

def analyze_collatz_orbit(n: int) -> dict:
    """Complete spectral contraction analysis of a Collatz orbit."""
    orbit = collatz_orbit(n)
    word = parity_word(orbit)
    k = len(word)
    s = sum(word)
    system = ContractionSystem(k, s)
    cert = build_tropical_certificate(k, s)

    return {
        "starting_value": n,
        "orbit_length": len(orbit),
        "system": system,
        "contraction_exponent": system.exponent,
        "ones_density": system.density,
        "critical_density": CRITICAL_DENSITY,
        "dc_spectral_energy": system.dc_spectral_energy,
        "critical_spectral_energy": CRITICAL_SPECTRAL_ENERGY,
        "contracts": system.contracts,
        "multiplicative_factor": system.multiplicative_factor,
        "drift_per_step": system.drift_per_step,
        "contraction_gap": system.contraction_gap,
        "certificate": cert,
        "certified": cert is not None and cert.is_valid,
    }


# ============================================================
# Batch Analysis
# ============================================================

def batch_analyze(start: int, end: int) -> dict:
    """Analyze all odd numbers in [start, end]."""
    results: list[dict] = []
    max_density = 0.0
    all_contract = True

    for n in range(start, end + 1):
        if n % 2 == 0 or n <= 1:
            continue
        result = analyze_collatz_orbit(n)
        results.append(result)
        if result["ones_density"] > max_density:
            max_density = result["ones_density"]
        if not result["contracts"]:
            all_contract = False

    return {
        "count": len(results),
        "all_contract": all_contract,
        "max_density": max_density,
        "critical_density": CRITICAL_DENSITY,
        "density_margin": CRITICAL_DENSITY - max_density,
    }


if __name__ == "__main__":
    # Quick demo
    for n in [7, 27, 97, 871, 6171, 837799]:
        r = analyze_collatz_orbit(n)
        print(f"n={n}: d={r['ones_density']:.4f}, ξ={r['contraction_exponent']:.3f}, "
              f"contracts={r['contracts']}, certified={r['certified']}")
