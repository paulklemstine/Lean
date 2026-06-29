#!/usr/bin/env python3
"""
Algorithms for Derived Compression Invariants

Implements the core computational algorithms for the cohomological
obstruction theory of compression. Includes:
1. κ¹ and κ² computation
2. Filtration defect analysis
3. Extension chain analysis
4. Spectrum computation for finite systems
5. Conjecture testing framework

Time complexity:
- kappa1, kappa2: O(1)
- total_filtration_defect: O(n) for n-step filtration
- compression_spectrum: O(n³) for n objects
- test_split_detection: O(n³) for n objects
"""

from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass
import itertools


# ─── Core Invariants ────────────────────────────────────────────────

def kappa1(kA: int, kB: int, kQ: int) -> int:
    """First derived compression invariant.

    κ¹(E) = κ(A) + κ(Q) - κ(B)

    Measures the failure of a compression functional κ to be additive
    on a short exact sequence 0 → A → B → Q → 0.

    Args:
        kA: Compression value of the kernel term
        kB: Compression value of the middle term
        kQ: Compression value of the quotient term

    Returns:
        The first derived invariant κ¹

    Time: O(1)
    Space: O(1)

    >>> kappa1(10, 15, 5)   # split
    0
    >>> kappa1(10, 12, 5)   # non-split, subadditive
    3
    """
    return kA + kQ - kB


def kappa2(k0: int, k1: int, k2: int, k3: int, k4: int) -> int:
    """Second derived compression invariant.

    κ²(T) = κ¹(e₁) + κ¹(e₂) - κ¹(composite)

    For an extension chain 0→X₀→X₁→X₂→0 and 0→X₁→X₃→X₄→0.

    THEOREM: This is identically zero for all inputs.
    The proof is: κ² = (k0+k2-k1) + (k1+k4-k3) - (k0+(k2+k4)-k3) = 0.

    Args:
        k0..k4: Compression values of chain terms

    Returns:
        Always 0

    Time: O(1)
    Space: O(1)

    >>> kappa2(1, 2, 3, 4, 5)
    0
    """
    return kappa1(k0, k1, k2) + kappa1(k1, k3, k4) - kappa1(k0, k3, k2 + k4)


# ─── Filtration Analysis ────────────────────────────────────────────

@dataclass
class FiltrationAnalysis:
    """Complete analysis of a filtration's compression defects."""
    n: int
    levels: List[int]
    graded: List[int]
    step_defects: List[int]
    total_defect: int
    is_subadditive: bool
    is_exact: bool
    telescoping_verified: bool


def analyze_filtration(levels: List[int], graded: List[int]) -> FiltrationAnalysis:
    """Analyze a filtration's compression defect structure.

    Given filtration levels κ(F₀), ..., κ(Fₙ) and graded pieces
    κ(gr₁), ..., κ(grₙ), computes all derived invariants.

    Verifies:
    - Step defects κ¹(Eᵢ) for each i
    - Total defect ∑ κ¹(Eᵢ)
    - Telescoping identity: total = κ(F₀) + Σκ(grᵢ) - κ(Fₙ)
    - Subadditivity and exactness

    Args:
        levels: κ values at filtration levels [κ(F₀), ..., κ(Fₙ)]
        graded: κ values of graded pieces [κ(gr₁), ..., κ(grₙ)]

    Returns:
        FiltrationAnalysis with all computed quantities

    Time: O(n)
    Space: O(n)
    """
    n = len(graded)
    assert len(levels) == n + 1

    step_defects = [kappa1(levels[i], levels[i + 1], graded[i]) for i in range(n)]
    total = sum(step_defects)
    telescoping = levels[0] + sum(graded) - levels[-1]

    return FiltrationAnalysis(
        n=n,
        levels=levels,
        graded=graded,
        step_defects=step_defects,
        total_defect=total,
        is_subadditive=all(d >= 0 for d in step_defects),
        is_exact=all(d == 0 for d in step_defects),
        telescoping_verified=(total == telescoping),
    )


# ─── Finite System Spectrum ─────────────────────────────────────────

@dataclass
class SpectrumResult:
    """Compression spectrum of a finite system."""
    system_size: int
    compressed_values: List[int]
    spectrum: Dict[int, int]  # κ¹ value → count
    valid_triples: int
    split_triples: int
    max_defect: int
    min_defect: int


def compression_spectrum(compressed: List[int]) -> SpectrumResult:
    """Compute the full compression spectrum of a finite system.

    The spectrum is the multiset of all κ¹ values over valid
    (subadditive) extension triples.

    Args:
        compressed: List of compressed sizes

    Returns:
        SpectrumResult with spectrum data

    Time: O(n³) where n = len(compressed)
    Space: O(n³) worst case for spectrum storage
    """
    n = len(compressed)
    spectrum: Dict[int, int] = {}
    valid = 0
    split = 0

    for iA, iB, iQ in itertools.product(range(n), repeat=3):
        kA, kB, kQ = compressed[iA], compressed[iB], compressed[iQ]
        if kB <= kA + kQ:
            k1 = kappa1(kA, kB, kQ)
            valid += 1
            if k1 == 0:
                split += 1
            spectrum[k1] = spectrum.get(k1, 0) + 1

    return SpectrumResult(
        system_size=n,
        compressed_values=compressed,
        spectrum=spectrum,
        valid_triples=valid,
        split_triples=split,
        max_defect=max(spectrum.keys()) if spectrum else 0,
        min_defect=min(spectrum.keys()) if spectrum else 0,
    )


# ─── Conjecture Testing ─────────────────────────────────────────────

def test_split_detection(max_val: int = 10) -> Tuple[bool, int, int]:
    """Test the split-detection conjecture:
    κ¹(E) = 0 ↔ κ(B) = κ(A) + κ(Q).

    Args:
        max_val: Maximum compression value to test

    Returns:
        (conjecture_holds, total_tested, violations)

    Time: O(max_val³)
    """
    total = 0
    violations = 0
    for kA in range(max_val + 1):
        for kQ in range(max_val + 1):
            for kB in range(kA + kQ + 1):
                k1 = kappa1(kA, kB, kQ)
                is_split = (kB == kA + kQ)
                total += 1
                if (k1 == 0) != is_split:
                    violations += 1
    return violations == 0, total, violations


def test_kappa2_vanishing(max_val: int = 5) -> Tuple[bool, int, int]:
    """Test universal vanishing of κ².

    Args:
        max_val: Range [-max_val, max_val] for each variable

    Returns:
        (vanishes, total_tested, violations)

    Time: O((2*max_val+1)⁵)
    """
    total = 0
    violations = 0
    rng = range(-max_val, max_val + 1)
    for k0, k1, k2, k3, k4 in itertools.product(rng, repeat=5):
        total += 1
        if kappa2(k0, k1, k2, k3, k4) != 0:
            violations += 1
    return violations == 0, total, violations


def test_euler_identity(n_filtrations: int = 1000, max_n: int = 8,
                         max_val: int = 20) -> Tuple[bool, int]:
    """Test the telescoping Euler identity on random filtrations.

    Args:
        n_filtrations: Number of random filtrations to test
        max_n: Maximum filtration length
        max_val: Maximum κ value

    Returns:
        (identity_holds, total_tested)
    """
    import random
    random.seed(42)
    total = 0
    for _ in range(n_filtrations):
        n = random.randint(1, max_n)
        levels = [random.randint(0, max_val) for _ in range(n + 1)]
        graded = [random.randint(0, max_val) for _ in range(n)]
        analysis = analyze_filtration(levels, graded)
        total += 1
        if not analysis.telescoping_verified:
            return False, total
    return True, total


# ─── Main ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Derived Compression Invariants: Algorithm Tests ===\n")

    # Test κ¹
    print("κ¹ examples:")
    for kA, kB, kQ in [(10, 15, 5), (10, 12, 5), (7, 10, 7)]:
        print(f"  κ¹({kA}, {kB}, {kQ}) = {kappa1(kA, kB, kQ)}")

    # Test κ²
    print(f"\nκ² vanishing test:")
    vanishes, total, viol = test_kappa2_vanishing(3)
    print(f"  Tested {total} cases: {'PASS' if vanishes else 'FAIL'}")

    # Test split detection
    print(f"\nSplit-detection conjecture:")
    holds, total, viol = test_split_detection(8)
    print(f"  Tested {total} cases: {'CONFIRMED' if holds else f'FAILED ({viol} violations)'}")

    # Test Euler identity
    print(f"\nTelescoping identity:")
    holds, total = test_euler_identity(5000)
    print(f"  Tested {total} random filtrations: {'CONFIRMED' if holds else 'FAILED'}")

    # Spectrum example
    print(f"\nCompression spectrum of [3, 5, 8, 12]:")
    spec = compression_spectrum([3, 5, 8, 12])
    print(f"  Valid triples: {spec.valid_triples}")
    print(f"  Split triples: {spec.split_triples}")
    print(f"  Max κ¹: {spec.max_defect}")
    print(f"  Spectrum: {dict(sorted(spec.spectrum.items()))}")
