#!/usr/bin/env python3
"""
Algorithms for Quantum Casimir Spectral Theory

Type-hinted implementations of the core mathematical objects and algorithms.
"""

from typing import List, Tuple, Optional
import math


def q_integer(q: float, n: int) -> float:
    """
    Compute the symmetric q-integer [n]_q = Σ_{k=0}^{n-1} q^{n-1-2k}.
    
    For q = 1, returns n. For q ≠ 0, q ≠ 1, this equals (q^n - q^{-n})/(q - q^{-1}).
    
    Complexity: O(n) multiplications.
    """
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return sum(q ** (n - 1 - 2 * k) for k in range(n))


def q_integer_closed_form(q: float, n: int) -> float:
    """
    Compute [n]_q using the closed form (q^n - q^{-n})/(q - q^{-1}).
    
    Requires q > 0, q ≠ 1. More numerically stable for large n.
    Complexity: O(log n) for exponentiation.
    """
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - q**(-n)) / (q - q**(-1))


def q_casimir(q: float, n: int) -> float:
    """
    Compute the q-Casimir eigenvalue λ_n(q) = [n]_q · [n+1]_q.
    
    This is the eigenvalue of the Casimir element of U_q(sl_2) on
    the (n+1)-dimensional irreducible representation V_n.
    
    Complexity: O(n) multiplications.
    """
    return q_integer(q, n) * q_integer(q, n + 1)


def q_casimir_spectrum(q: float, max_n: int) -> List[float]:
    """
    Compute the first max_n q-Casimir eigenvalues.
    
    Returns [λ_0(q), λ_1(q), ..., λ_{max_n-1}(q)].
    """
    return [q_casimir(q, n) for n in range(max_n)]


def spectral_counting(q: float, T: float, max_n: int = 10000) -> int:
    """
    Compute N(T) = #{n ∈ ℕ : λ_n(q) ≤ T}.
    
    This is the spectral counting function for the q-Casimir operator.
    For q = 1: N(T) ~ √T (Weyl law).
    For q > 1: N(T) ~ log(T)/(2·log(q)) (logarithmic growth).
    """
    count = 0
    for n in range(max_n):
        if q_casimir(q, n) <= T:
            count += 1
        else:
            break
    return count


def recover_q_from_casimir(casimir_value: float) -> Tuple[float, float]:
    """
    Spectral Rigidity Algorithm: Recover q from the first Casimir eigenvalue.
    
    Given λ_1 = q + q^{-1}, solve the quadratic q² - λ₁·q + 1 = 0.
    Returns (q, q^{-1}), the two solutions related by Weyl symmetry.
    
    Requires λ₁ ≥ 2 (since q + q^{-1} ≥ 2 for q > 0 by AM-GM).
    """
    discriminant = casimir_value**2 - 4
    if discriminant < 0:
        raise ValueError(f"No positive real solutions: λ₁ = {casimir_value} < 2")
    
    sqrt_disc = math.sqrt(discriminant)
    q1 = (casimir_value + sqrt_disc) / 2
    q2 = (casimir_value - sqrt_disc) / 2
    return (q1, q2)


def spectral_gap_sequence(q: float, max_n: int) -> List[float]:
    """
    Compute the spectral gaps Δ_n = λ_{n+1}(q) - λ_n(q).
    
    For q = 1: Δ_n = 2(n+1) (linear growth, Weyl law).
    For q > 1: Δ_n grows exponentially.
    """
    spectrum = q_casimir_spectrum(q, max_n + 1)
    return [spectrum[n+1] - spectrum[n] for n in range(max_n)]


def q_from_riemann_zero(gamma: float) -> float:
    """
    Compute the quantum group parameter q from a Riemann zero γ.
    
    q = exp(2π/γ) gives a real deformation parameter.
    """
    return math.exp(2 * math.pi / gamma)


def nearest_level_repulsion(spectrum: List[float]) -> List[float]:
    """
    Compute the normalized nearest-neighbor spacings of a spectrum.
    
    Used to compare with GUE (Gaussian Unitary Ensemble) statistics.
    GUE level repulsion: P(s) ~ s² exp(-4s²/π) for small s.
    Poisson (uncorrelated): P(s) = exp(-s).
    """
    gaps = [spectrum[i+1] - spectrum[i] for i in range(len(spectrum)-1)]
    mean_gap = sum(gaps) / len(gaps) if gaps else 1.0
    return [g / mean_gap for g in gaps]


if __name__ == "__main__":
    print("=== Spectral Rigidity Demo ===")
    q_original = 2.5
    lambda1 = q_casimir(q_original, 1)
    q_recovered = recover_q_from_casimir(lambda1)
    print(f"Original q = {q_original}")
    print(f"First Casimir eigenvalue: λ₁ = {lambda1:.6f}")
    print(f"Recovered: q = {q_recovered[0]:.6f} or q = {q_recovered[1]:.6f}")
    print(f"Verify: q⁻¹ = {1/q_original:.6f}")
    
    print("\n=== Riemann Zero Connection ===")
    gamma1 = 14.134725
    q_riemann = q_from_riemann_zero(gamma1)
    print(f"γ₁ = {gamma1}, q = exp(2π/γ₁) = {q_riemann:.6f}")
    spectrum = q_casimir_spectrum(q_riemann, 10)
    for i, lam in enumerate(spectrum):
        print(f"  λ_{i} = {lam:.4f}")
