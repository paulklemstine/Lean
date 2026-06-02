#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of q-Casimir spectral algorithms.

Provides efficient computation of q-integers, q-Casimir eigenvalues,
spectral gaps, and the spectral gap dynamical system.
"""

from typing import Tuple, List, Optional
from dataclasses import dataclass
import math


def q_integer(q: float, n: int) -> float:
    """
    Compute the q-integer [n]_q = 1 + q + q^2 + ... + q^{n-1}.

    Uses Horner's method for numerical stability: ((q + 1)*q + 1)*q + 1) ...

    Args:
        q: Deformation parameter (any real number)
        n: Non-negative integer

    Returns:
        The q-integer [n]_q
    """
    if n <= 0:
        return 0.0
    result = 0.0
    for _ in range(n):
        result = result * q + 1.0
    return result


def q_casimir_eigenvalue(q: float, n: int) -> float:
    """
    Compute the q-Casimir eigenvalue λ_n(q) = [n]_q · [n+1]_q.

    Args:
        q: Deformation parameter (positive real)
        n: Non-negative integer (representation label)

    Returns:
        The q-Casimir eigenvalue
    """
    return q_integer(q, n) * q_integer(q, n + 1)


@dataclass
class SpectralGapState:
    """State of the spectral gap dynamical system."""
    gap: float    # Current spectral gap Δ_n
    power: float  # Running power q^n


def spectral_gap_dynamics_step(q: float, state: SpectralGapState) -> SpectralGapState:
    """
    One step of the spectral gap dynamical system.

    Implements the recurrence:
        Δ_{n+1} = q² · Δ_n + q^n · q · (1+q)
        q^{n+1} = q^n · q

    This is more efficient than computing spectral gaps from scratch,
    requiring only O(1) operations per step.

    Args:
        q: Deformation parameter
        state: Current (gap, power) state

    Returns:
        Next state
    """
    new_gap = q * q * state.gap + state.power * q * (1 + q)
    new_power = state.power * q
    return SpectralGapState(gap=new_gap, power=new_power)


def generate_spectral_gaps(q: float, count: int) -> List[float]:
    """
    Generate the first `count` spectral gaps using the dynamical system.

    O(count) time, O(1) working space (streaming).

    Args:
        q: Deformation parameter (positive real)
        count: Number of spectral gaps to generate

    Returns:
        List of spectral gaps [Δ_0, Δ_1, ..., Δ_{count-1}]
    """
    gaps: List[float] = []
    state = SpectralGapState(gap=1.0 + q, power=1.0)
    for _ in range(count):
        gaps.append(state.gap)
        state = spectral_gap_dynamics_step(q, state)
    return gaps


def q_integer_multiplication(q: float, n: int, m: int) -> float:
    """
    Compute [n*m]_q using the multiplication formula [n*m]_q = [n]_q · [m]_{q^n}.

    This is more efficient than direct computation for large n*m when
    n and m are moderate, as it reduces to two smaller q-integer computations.

    Args:
        q: Deformation parameter
        n, m: Non-negative integers

    Returns:
        [n*m]_q
    """
    return q_integer(q, n) * q_integer(q ** n, m)


def spectral_gap_ratio(q: float, n: int) -> float:
    """
    Compute the spectral gap ratio Δ_{n+1}/Δ_n = q · [n+2]_q / [n+1]_q.

    Args:
        q: Deformation parameter (positive)
        n: Gap index

    Returns:
        The ratio Δ_{n+1}/Δ_n
    """
    qn2 = q_integer(q, n + 2)
    qn1 = q_integer(q, n + 1)
    if abs(qn1) < 1e-15:
        return float('inf')
    return q * qn2 / qn1


def spectral_lyapunov_exponent(q: float, n_terms: int = 1000) -> float:
    """
    Estimate the spectral Lyapunov exponent by averaging log(Δ_{n+1}/Δ_n)
    over many terms.

    The theoretical prediction is:
        - log(q)   for 0 < q < 1
        - 2·log(q) for q > 1

    Args:
        q: Deformation parameter (positive, not 1)
        n_terms: Number of terms to average

    Returns:
        Estimated Lyapunov exponent
    """
    if q <= 0 or q == 1:
        raise ValueError("q must be positive and not equal to 1")

    log_ratios: List[float] = []
    state = SpectralGapState(gap=1.0 + q, power=1.0)

    prev_gap = state.gap
    for _ in range(n_terms):
        state = spectral_gap_dynamics_step(q, state)
        if prev_gap > 0 and state.gap > 0:
            log_ratios.append(math.log(state.gap / prev_gap))
        prev_gap = state.gap

    if not log_ratios:
        return float('nan')

    # Use the last half for better convergence
    half = len(log_ratios) // 2
    return sum(log_ratios[half:]) / len(log_ratios[half:])


def modular_spectral_gap_prng(q: int, p: int, count: int) -> List[int]:
    """
    Pseudorandom number generator based on the spectral gap recurrence mod p.

    Implements Δ_{n+1} ≡ q² · Δ_n + q^{n+1} · (1+q) (mod p).

    Args:
        q: Generator (should be a primitive root mod p)
        p: Prime modulus
        count: Number of outputs

    Returns:
        List of pseudorandom values in [0, p)
    """
    gap = (1 + q) % p
    power = 1
    q_sq = (q * q) % p
    q_plus_1 = (1 + q) % p
    outputs: List[int] = []

    for _ in range(count):
        outputs.append(gap)
        new_gap = (q_sq * gap + power * q % p * q_plus_1) % p
        power = (power * q) % p
        gap = new_gap

    return outputs


if __name__ == "__main__":
    # Quick self-test
    print("Self-test: q-integer multiplication formula")
    q = 0.7
    for n in range(1, 6):
        for m in range(1, 6):
            direct = q_integer(q, n * m)
            formula = q_integer_multiplication(q, n, m)
            assert abs(direct - formula) < 1e-10, f"Failed for n={n}, m={m}"
    print("  All tests passed.")

    print("\nSpectral Lyapunov exponents:")
    for q in [0.3, 0.5, 0.9, 1.1, 2.0, 5.0]:
        lyap = spectral_lyapunov_exponent(q, 5000)
        predicted = math.log(q) if q < 1 else 2 * math.log(q)
        print(f"  q={q:>4.1f}: computed={lyap:.6f}, predicted={predicted:.6f}")
