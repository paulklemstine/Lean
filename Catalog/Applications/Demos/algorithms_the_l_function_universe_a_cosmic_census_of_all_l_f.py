#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the L-Function Universe

Type-hinted implementations of:
1. Selberg data enumeration
2. Spectral complexity computation
3. Conductor counting
4. Dirichlet character counting
5. Density estimation
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import math


@dataclass(frozen=True)
class SelbergDatum:
    """Finite invariant data of a Selberg class L-function.
    
    Attributes:
        degree: Number of Gamma factors (non-negative integer)
        conductor: Positive integer measuring arithmetic complexity
        spectral_params: List of (re, im) pairs for Gamma factor shifts
        root_number_arg: Argument of root number as rational multiple of 2π
    """
    degree: int
    conductor: int
    spectral_params: tuple[tuple[float, float], ...]
    root_number_arg: float
    
    def __post_init__(self) -> None:
        assert self.conductor > 0, "Conductor must be positive"
        assert len(self.spectral_params) == self.degree, \
            "Number of spectral params must equal degree"
    
    def spectral_complexity(self) -> float:
        """Compute the spectral complexity invariant.
        
        C(S) = degree + conductor + Σ(|re_i| + |im_i|)
        """
        param_sum = sum(abs(r) + abs(s) for r, s in self.spectral_params)
        return self.degree + self.conductor + param_sum
    
    @staticmethod
    def product(s1: SelbergDatum, s2: SelbergDatum) -> SelbergDatum:
        """Rankin-Selberg product: degree additive, conductor multiplicative."""
        return SelbergDatum(
            degree=s1.degree + s2.degree,
            conductor=s1.conductor * s2.conductor,
            spectral_params=s1.spectral_params + s2.spectral_params,
            root_number_arg=s1.root_number_arg + s2.root_number_arg,
        )
    
    @staticmethod
    def zeta() -> SelbergDatum:
        """The Riemann zeta function datum."""
        return SelbergDatum(
            degree=1, conductor=1,
            spectral_params=((0.0, 0.0),),
            root_number_arg=0.0,
        )
    
    @staticmethod
    def dirichlet(conductor: int, parity: int = 0) -> SelbergDatum:
        """A Dirichlet L-function datum with given conductor.
        
        Args:
            conductor: Positive integer conductor
            parity: 0 for even, 1 for odd character
        """
        mu = (parity, 0.0)
        return SelbergDatum(
            degree=1, conductor=conductor,
            spectral_params=(mu,),
            root_number_arg=0.0,
        )


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n).
    
    Uses the product formula: φ(n) = n · ∏_{p|n} (1 - 1/p)
    
    Time complexity: O(√n)
    """
    if n <= 0:
        return 0
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def count_dirichlet_characters_up_to(Q: int) -> list[int]:
    """Count Dirichlet characters with modulus ≤ n for each n ≤ Q.
    
    Returns a list where result[n] = ∑_{k=1}^{n} φ(k).
    
    This is the conductor counting function for degree-1 L-functions.
    """
    counts = [0] * (Q + 1)
    running = 0
    for n in range(1, Q + 1):
        running += euler_totient(n)
        counts[n] = running
    return counts


def enumerate_selberg_data_bounded(
    max_degree: int,
    max_conductor: int,
    max_param_height: int = 0,
) -> list[SelbergDatum]:
    """Enumerate Selberg data with bounded invariants.
    
    This demonstrates the finiteness of bounded subsets of the Selberg class.
    Restricts spectral parameters to integers for computability.
    
    Args:
        max_degree: Maximum degree (number of Gamma factors)
        max_conductor: Maximum conductor
        max_param_height: Maximum |re| + |im| for each spectral parameter
    
    Returns:
        List of SelbergDatum sorted by spectral complexity
    """
    results: list[SelbergDatum] = []
    
    for d in range(max_degree + 1):
        for q in range(1, max_conductor + 1):
            if d == 0:
                results.append(SelbergDatum(d, q, (), 0.0))
            else:
                # Generate all integer spectral parameter tuples
                param_lists = _generate_param_tuples(d, max_param_height)
                for params in param_lists:
                    results.append(SelbergDatum(d, q, tuple(params), 0.0))
    
    results.sort(key=lambda s: s.spectral_complexity())
    return results


def _generate_param_tuples(
    d: int, max_height: int
) -> list[list[tuple[float, float]]]:
    """Generate all d-tuples of integer pairs (r, s) with |r| + |s| ≤ max_height."""
    if d == 0:
        return [[]]
    
    single_params: list[tuple[float, float]] = []
    for r in range(-max_height, max_height + 1):
        s_bound = max_height - abs(r)
        for s in range(-s_bound, s_bound + 1):
            single_params.append((float(r), float(s)))
    
    if d == 1:
        return [[(r, s)] for r, s in single_params]
    
    # For d > 1, take Cartesian product (limited for tractability)
    sub = _generate_param_tuples(d - 1, max_height)
    result: list[list[tuple[float, float]]] = []
    for prefix in sub:
        for p in single_params:
            result.append(prefix + [p])
    return result


def density_estimate(Q: int) -> dict[str, float]:
    """Estimate L-function density up to conductor Q.
    
    Returns estimates for:
    - degree_1: Number of primitive Dirichlet characters ≈ 3Q²/π²
    - degree_2: Estimated holomorphic newforms ≈ Q²/(12·2π)
    - total_estimate: Combined estimate
    """
    d1_actual = sum(euler_totient(n) for n in range(1, Q + 1))
    d1_asymptotic = 3 * Q**2 / math.pi**2
    
    # Degree 2: crude estimate from dimension formula for modular forms
    # dim S_k(Γ₀(N)) ≈ (k-1)N/12 for large N
    # Summing over weight k=2 and all levels N ≤ Q: ≈ Q/12 · Q ≈ Q²/12
    d2_estimate = Q**2 / 12.0
    
    return {
        'degree_1_actual': float(d1_actual),
        'degree_1_asymptotic': d1_asymptotic,
        'degree_2_estimate': d2_estimate,
        'total_estimate': d1_asymptotic + d2_estimate,
        'conductor_bound': Q,
    }


def verify_subadditivity(s1: SelbergDatum, s2: SelbergDatum) -> dict[str, float]:
    """Verify the spectral complexity identity for products.
    
    For S₁ · S₂, spectral complexity equals degree sum + conductor product +
    sum of individual spectral parameter contributions.
    """
    prod = SelbergDatum.product(s1, s2)
    c1 = s1.spectral_complexity()
    c2 = s2.spectral_complexity()
    c_prod = prod.spectral_complexity()
    
    return {
        'C(S1)': c1,
        'C(S2)': c2,
        'C(S1·S2)': c_prod,
        'C(S1)+C(S2)': c1 + c2,
        'difference': c_prod - (c1 + c2),
        'identity_check': abs(c_prod - (
            s1.degree + s2.degree +
            s1.conductor * s2.conductor +
            sum(abs(r) + abs(s) for r, s in s1.spectral_params) +
            sum(abs(r) + abs(s) for r, s in s2.spectral_params)
        )) < 1e-10,
    }


if __name__ == "__main__":
    # Quick self-test
    zeta = SelbergDatum.zeta()
    print(f"ζ(s) datum: degree={zeta.degree}, conductor={zeta.conductor}, "
          f"complexity={zeta.spectral_complexity()}")
    
    chi4 = SelbergDatum.dirichlet(4, parity=1)
    print(f"L(s,χ₄) datum: degree={chi4.degree}, conductor={chi4.conductor}, "
          f"complexity={chi4.spectral_complexity()}")
    
    prod = SelbergDatum.product(zeta, chi4)
    print(f"ζ·L(s,χ₄): degree={prod.degree}, conductor={prod.conductor}, "
          f"complexity={prod.spectral_complexity()}")
    
    sub = verify_subadditivity(zeta, chi4)
    print(f"Subadditivity check: {sub}")
    
    density = density_estimate(1000)
    print(f"\nDensity at Q=1000: {density}")
