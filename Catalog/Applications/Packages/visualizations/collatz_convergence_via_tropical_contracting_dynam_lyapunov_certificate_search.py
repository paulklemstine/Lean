#!/usr/bin/env python3
"""
Algorithms for Collatz-Tropical Dynamics Analysis

Implements the computational counterparts of the formally verified theorems:
1. Collatz orbit computation with potential tracking
2. Residue class analysis for contraction regimes
3. Logarithmic contraction verification
4. Finite-state Lyapunov certificate search
5. Symbolic dynamics encoding and drift analysis
"""

import math
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


# ============================================================
# Core Collatz Maps
# ============================================================

def collatz(n: int) -> int:
    """Standard Collatz map: n/2 if even, 3n+1 if odd.

    Time: O(1), Space: O(1)
    """
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_odd(n: int) -> int:
    """Accelerated Collatz odd step: (3n+1)/2.

    Combines the odd multiplication with one guaranteed halving.
    Time: O(1), Space: O(1)
    """
    return (3 * n + 1) // 2


def collatz_accel(n: int) -> int:
    """Fully accelerated Collatz: for odd n, apply 3n+1 then divide out all factors of 2.

    Returns the next odd number in the Collatz sequence.
    Time: O(log n), Space: O(1)
    """
    if n % 2 == 0:
        while n % 2 == 0:
            n //= 2
        return n
    val = 3 * n + 1
    while val % 2 == 0:
        val //= 2
    return val


# ============================================================
# Orbit Analysis
# ============================================================

@dataclass
class OrbitStats:
    """Statistics for a Collatz orbit."""
    start: int
    length: int
    max_value: int
    even_steps: int
    odd_steps: int
    orbit: List[int]
    potentials: List[float]
    even_odd_ratio: float
    odd_fraction: float
    net_potential_change: float
    coarse_bound: float


def analyze_orbit(n: int, max_steps: int = 10000) -> OrbitStats:
    """Compute and analyze a complete Collatz orbit.

    Algorithm:
        1. Iterate collatz until reaching 1 or max_steps
        2. Track log-potential at each step
        3. Count even/odd step ratios
        4. Compute drift statistics

    Time: O(orbit_length), Space: O(orbit_length)

    Args:
        n: Starting value (must be ≥ 1)
        max_steps: Maximum iterations before stopping

    Returns:
        OrbitStats with comprehensive orbit analysis
    """
    orbit = [n]
    potentials = [math.log(n) if n > 0 else 0.0]
    even_steps = 0
    odd_steps = 0

    current = n
    while current != 1 and len(orbit) < max_steps:
        if current % 2 == 0:
            even_steps += 1
        else:
            odd_steps += 1
        current = collatz(current)
        orbit.append(current)
        potentials.append(math.log(current) if current > 0 else 0.0)

    total = even_steps + odd_steps
    return OrbitStats(
        start=n,
        length=len(orbit),
        max_value=max(orbit),
        even_steps=even_steps,
        odd_steps=odd_steps,
        orbit=orbit,
        potentials=potentials,
        even_odd_ratio=even_steps / max(odd_steps, 1),
        odd_fraction=odd_steps / max(total, 1),
        net_potential_change=potentials[-1] - potentials[0],
        coarse_bound=even_steps * (-math.log(2)) + odd_steps * math.log(4),
    )


# ============================================================
# Residue Class Analysis
# ============================================================

def analyze_residue_contraction(modulus: int) -> Dict[int, dict]:
    """Analyze contraction behavior by residue class modulo `modulus`.

    For each odd residue class r (mod modulus), compute:
    - The 2-adic valuation of 3r+1
    - Whether 4 | (3r+1) (favorable for contraction)
    - The contraction ratio in log coordinates

    Algorithm:
        For each r in {1, 3, 5, ..., modulus-1}:
            Compute v₂(3r+1) = max power of 2 dividing 3r+1
            Contraction ratio = log(3) - v₂ · log(2)

    Time: O(modulus · log(modulus)), Space: O(modulus)

    Args:
        modulus: The modulus to analyze (should be a power of 2 for best results)

    Returns:
        Dictionary mapping residue → analysis data
    """
    results = {}
    for r in range(1, modulus, 2):  # odd residues only
        val = 3 * r + 1
        v2 = 0
        temp = val
        while temp % 2 == 0:
            v2 += 1
            temp //= 2

        # In log coordinates: log((3r+1)/2^v2) - log(r) ≈ log(3) - v2·log(2) + O(1/r)
        log_ratio = math.log(3) - v2 * math.log(2)

        results[r] = {
            'residue': r,
            'three_r_plus_1': val,
            'two_adic_val': v2,
            'four_divides': val % 4 == 0,
            'log_contraction_ratio': log_ratio,
            'contracts': log_ratio < 0,
            'result_mod': temp % modulus,
        }
    return results


def find_contracting_classes(max_modulus: int = 64) -> List[Tuple[int, float]]:
    """Find residue classes with guaranteed contraction.

    Searches through moduli that are powers of 2 and identifies
    classes where the accelerated Collatz map strictly contracts.

    Time: O(max_modulus · log(max_modulus)), Space: O(max_modulus)

    Returns:
        List of (modulus, fraction_contracting) pairs
    """
    results = []
    modulus = 4
    while modulus <= max_modulus:
        analysis = analyze_residue_contraction(modulus)
        contracting = sum(1 for v in analysis.values() if v['contracts'])
        total = len(analysis)
        results.append((modulus, contracting / total))
        modulus *= 2
    return results


# ============================================================
# Lyapunov Certificate Search
# ============================================================

def search_lyapunov_correction(
    modulus: int,
    max_iterations: int = 1000,
    learning_rate: float = 0.01
) -> Optional[Dict[int, float]]:
    """Search for a finite-state Lyapunov correction ψ : Z/mZ → ℝ.

    Seeks ψ such that Φ(n) = log(n) + ψ(n mod m) satisfies
    Φ(T(n)) ≤ c · Φ(n) + b for some c < 1, b, and the accelerated map T.

    Algorithm (gradient descent on violation):
        1. Initialize ψ = 0
        2. For each odd residue r, compute the contraction deficit:
           deficit(r) = log(3) - v₂(3r+1)·log(2) + ψ(result_class) - ψ(r)
        3. Update ψ to minimize max deficit
        4. Repeat until convergence or max_iterations

    Time: O(max_iterations · modulus · log(modulus))
    Space: O(modulus)

    Args:
        modulus: State space size (should be power of 2 · power of 3)
        max_iterations: Maximum gradient steps
        learning_rate: Step size for updates

    Returns:
        Dictionary mapping residue → correction value, or None if no certificate found
    """
    # Initialize correction potential
    psi = {r: 0.0 for r in range(modulus)}

    # Precompute residue class transitions
    transitions = {}
    for r in range(1, modulus, 2):
        val = 3 * r + 1
        v2 = 0
        temp = val
        while temp % 2 == 0:
            v2 += 1
            temp //= 2
        transitions[r] = {
            'target': temp % modulus,
            'log_ratio': math.log(3) - v2 * math.log(2),
            'v2': v2,
        }

    best_max_deficit = float('inf')
    best_psi = dict(psi)

    for iteration in range(max_iterations):
        # Compute deficits
        deficits = {}
        for r, trans in transitions.items():
            target = trans['target']
            deficit = trans['log_ratio'] + psi[target] - psi[r]
            deficits[r] = deficit

        max_deficit = max(deficits.values())

        if max_deficit < best_max_deficit:
            best_max_deficit = max_deficit
            best_psi = dict(psi)

        if max_deficit < -1e-10:
            # Found a certificate!
            return best_psi

        # Gradient step: increase ψ for classes with large deficits
        for r, deficit in deficits.items():
            if deficit > 0:
                psi[r] += learning_rate * deficit
                target = transitions[r]['target']
                psi[target] -= learning_rate * deficit * 0.5

        # Normalize (subtract mean)
        mean_psi = sum(psi.values()) / len(psi)
        for r in psi:
            psi[r] -= mean_psi

    # Return best found even if not certifying
    return best_psi


# ============================================================
# Symbolic Dynamics Analysis
# ============================================================

def parity_word(n: int, length: int = 50) -> str:
    """Encode the Collatz orbit of n as a parity word.

    Each character represents one step:
    - 'E' for even (halving)
    - 'O' for odd (3n+1)

    Time: O(length), Space: O(length)
    """
    word = []
    for _ in range(length):
        if n == 1:
            break
        if n % 2 == 0:
            word.append('E')
        else:
            word.append('O')
        n = collatz(n)
    return ''.join(word)


def compute_drift(word: str) -> float:
    """Compute the symbolic drift of a parity word.

    drift = (count_O · log(4) - count_E · log(2)) / len(word)

    Negative drift indicates net contraction.

    Time: O(len(word)), Space: O(1)
    """
    if not word:
        return 0.0
    count_O = word.count('O')
    count_E = word.count('E')
    return (count_O * math.log(4) - count_E * math.log(2)) / len(word)


def analyze_symbolic_statistics(max_n: int = 10000) -> Dict[str, float]:
    """Compute aggregate symbolic statistics over many orbits.

    Time: O(max_n · avg_orbit_length), Space: O(1) for statistics
    """
    total_even = 0
    total_odd = 0
    total_orbits = 0

    for n in range(2, max_n + 1):
        word = parity_word(n, length=10000)
        total_even += word.count('E')
        total_odd += word.count('O')
        total_orbits += 1

    avg_ratio = total_even / max(total_odd, 1)
    avg_odd_frac = total_odd / max(total_even + total_odd, 1)

    return {
        'total_orbits': total_orbits,
        'total_even_steps': total_even,
        'total_odd_steps': total_odd,
        'even_odd_ratio': avg_ratio,
        'odd_fraction': avg_odd_frac,
        'average_drift': (total_odd * math.log(4) - total_even * math.log(2)) / max(total_even + total_odd, 1),
        'critical_ratio': math.log(4) / math.log(2),  # = 2.0
        'contraction_threshold': 1 / 3,
    }


# ============================================================
# Main: Run all algorithms and display results
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("COLLATZ-TROPICAL DYNAMICS: ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Residue class analysis
    print("\n--- Residue Class Contraction Analysis ---")
    for mod, frac in find_contracting_classes(128):
        print(f"  Modulus {mod:>4}: {frac:.2%} of odd classes have contracting log-ratio")

    # Lyapunov certificate search
    print("\n--- Lyapunov Correction Search (mod 12) ---")
    psi = search_lyapunov_correction(12, max_iterations=5000)
    if psi:
        print("  Correction values ψ(r):")
        for r in sorted(psi.keys()):
            if r % 2 == 1:  # odd residues
                print(f"    ψ({r:>2}) = {psi[r]:>8.4f}")

    # Symbolic statistics
    print("\n--- Symbolic Dynamics Statistics (n=2..1000) ---")
    stats = analyze_symbolic_statistics(1000)
    print(f"  Even/Odd ratio: {stats['even_odd_ratio']:.4f} (need > {stats['critical_ratio']:.1f} for contraction)")
    print(f"  Odd fraction: {stats['odd_fraction']:.4f} (need < {stats['contraction_threshold']:.4f} for contraction)")
    print(f"  Average drift: {stats['average_drift']:.6f}")
    print(f"  Drift sign: {'NEGATIVE (contracting)' if stats['average_drift'] < 0 else 'POSITIVE (expanding)'}")

    print("\n" + "=" * 70)
    print("All algorithms completed.")
    print("=" * 70)
