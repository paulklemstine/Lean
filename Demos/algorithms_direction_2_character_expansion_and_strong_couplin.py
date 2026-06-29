#!/usr/bin/env python3
"""
Algorithms for Character Expansion Mass Gap Analysis

This module implements the core algorithms from the research paper:
1. Character coefficient computation for SU(2)-type models
2. Mass gap predictor from character expansion data
3. Sector dominance verification
4. Certified lower bound computation

All algorithms are implementations of the formally verified theorems
in Physics/CharacterExpansionMassGap.lean.
"""

import numpy as np
from typing import Dict, List, Tuple, Optional, Callable


class CharacterExpansionData:
    """
    Character expansion data for a transfer operator.
    
    Encodes the representation-theoretic decomposition of a transfer
    matrix at coupling parameter β. Each representation sector contributes
    an eigenvalue weight coeff(β, sector).
    
    This is the Python counterpart of the Lean structure
    `CharacterExpansionData`.
    
    Attributes:
        sector_names: List of sector names (strings)
        trivial: Name of the trivial sector
        fundamental: Name of the fundamental sector
        coeff_fn: Function (β, sector_name) -> coefficient value
        weight: Dict mapping sector names to Casimir weights
        dim: Dict mapping sector names to representation dimensions
    """
    
    def __init__(
        self,
        sector_names: List[str],
        trivial: str,
        fundamental: str,
        coeff_fn: Callable[[float, str], float],
        weight: Optional[Dict[str, float]] = None,
        dim: Optional[Dict[str, int]] = None,
    ):
        self.sector_names = sector_names
        self.trivial = trivial
        self.fundamental = fundamental
        self.coeff_fn = coeff_fn
        self.weight = weight or {}
        self.dim = dim or {}
    
    def coeff(self, beta: float, sector: str) -> float:
        """Compute the coefficient for a given sector at coupling β."""
        return self.coeff_fn(beta, sector)
    
    def all_coefficients(self, beta: float) -> Dict[str, float]:
        """Compute all sector coefficients at coupling β."""
        return {s: self.coeff(beta, s) for s in self.sector_names}
    
    def nontrivial_sectors(self) -> List[str]:
        """Return list of nontrivial sector names."""
        return [s for s in self.sector_names if s != self.trivial]


def first_order_gap_predictor(data: CharacterExpansionData, beta: float) -> float:
    """
    Compute the first-order gap predictor.
    
    gap_pred(β) = -log(coeff(β, fund) / coeff(β, triv))
    
    This is the Python implementation of `firstOrderGapPredictor` from the
    Lean formalization.
    
    Args:
        data: Character expansion data
        beta: Coupling parameter (must be positive)
    
    Returns:
        The predicted mass gap value
    
    Raises:
        ValueError: If coefficients are not positive
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    c_fund = data.coeff(beta, data.fundamental)
    c_triv = data.coeff(beta, data.trivial)
    
    if c_fund <= 0 or c_triv <= 0:
        raise ValueError(
            f"Coefficients must be positive: c_fund={c_fund}, c_triv={c_triv}"
        )
    
    return -np.log(c_fund / c_triv)


def verify_sector_dominance(
    data: CharacterExpansionData,
    beta: float,
) -> Tuple[bool, str, Dict[str, float]]:
    """
    Verify that the fundamental sector dominates all other nontrivial sectors.
    
    This implements the check corresponding to the theorem
    `fundamental_sector_dominates_higher`.
    
    Args:
        data: Character expansion data
        beta: Coupling parameter
    
    Returns:
        Tuple of (is_dominant, second_largest_sector, all_coefficients)
    
    Time complexity: O(|sectors|)
    Space complexity: O(|sectors|)
    """
    coeffs = data.all_coefficients(beta)
    c_fund = coeffs[data.fundamental]
    
    nontrivial = {k: v for k, v in coeffs.items() if k != data.trivial}
    
    if not nontrivial:
        return True, data.fundamental, coeffs
    
    second_name = max(nontrivial, key=nontrivial.get)
    is_dominant = (second_name == data.fundamental)
    
    return is_dominant, second_name, coeffs


def certified_gap_lower_bound(
    c1: float,
    c2: float,
    beta: float,
) -> float:
    """
    Compute the certified mass gap lower bound from character suppression.
    
    When the trivial sector is bounded below by c₁ and the fundamental sector
    is bounded above by c₂ * β, the gap is at least:
    
        log(c₁) - log(c₂) - log(β)
    
    This implements the bound from `mass_gap_lower_bound_from_character_suppression`.
    
    Args:
        c1: Lower bound on trivial sector coefficient
        c2: Upper bound coefficient for fundamental sector (coeff ≤ c2 * β)
        beta: Coupling parameter
    
    Returns:
        Certified lower bound on the mass gap
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    if c1 <= 0 or c2 <= 0 or beta <= 0:
        raise ValueError("All parameters must be positive")
    
    return np.log(c1) - np.log(c2) - np.log(beta)


def compute_representation_concentration(
    data: CharacterExpansionData,
    beta: float,
) -> Dict[str, float]:
    """
    Compute the normalized representation distribution.
    
    p_i(β) = coeff(β, i) / Σ_j coeff(β, j)
    
    This corresponds to the cross-domain theorem
    `representation_concentration_nontrivial_vanishes`.
    
    Args:
        data: Character expansion data
        beta: Coupling parameter
    
    Returns:
        Dict mapping sector names to normalized probabilities
    
    Time complexity: O(|sectors|)
    Space complexity: O(|sectors|)
    """
    coeffs = data.all_coefficients(beta)
    total = sum(max(0, v) for v in coeffs.values())
    
    if total <= 0:
        raise ValueError("Total coefficient sum must be positive")
    
    return {k: max(0, v) / total for k, v in coeffs.items()}


def spectral_gap_sweep(
    data: CharacterExpansionData,
    betas: np.ndarray,
    n_higher: int = 5,
) -> Dict[str, np.ndarray]:
    """
    Sweep over coupling values and compute gap-related quantities.
    
    For each β, computes:
    - exact_gap: log(triv/second) where second = max nontrivial coefficient
    - predictor: first-order gap predictor
    - lower_bound: certified lower bound
    - p_trivial: trivial sector probability
    - is_fund_dominant: whether fundamental sector is second-largest
    
    Args:
        data: Character expansion data
        betas: Array of coupling values
        n_higher: Number of higher sectors
    
    Returns:
        Dict of arrays with computed quantities
    
    Time complexity: O(|betas| × |sectors|)
    Space complexity: O(|betas| × |sectors|)
    """
    results = {
        'beta': betas,
        'exact_gap': np.zeros_like(betas),
        'predictor': np.zeros_like(betas),
        'residual': np.zeros_like(betas),
        'lower_bound': np.zeros_like(betas),
        'p_trivial': np.zeros_like(betas),
        'is_fund_dominant': np.zeros(len(betas), dtype=bool),
    }
    
    for i, beta in enumerate(betas):
        # Exact gap
        is_dom, second, coeffs = verify_sector_dominance(data, beta)
        c_triv = coeffs[data.trivial]
        c_second = coeffs[second]
        
        if c_second > 0 and c_triv > 0:
            results['exact_gap'][i] = np.log(c_triv / c_second)
        
        # Predictor
        try:
            results['predictor'][i] = first_order_gap_predictor(data, beta)
        except ValueError:
            results['predictor'][i] = np.nan
        
        # Residual
        results['residual'][i] = results['exact_gap'][i] - results['predictor'][i]
        
        # Lower bound (using c1=1 for trivial, c2=2 for fundamental in SU(2) model)
        try:
            results['lower_bound'][i] = certified_gap_lower_bound(1.0, 2.0, beta)
        except ValueError:
            results['lower_bound'][i] = np.nan
        
        # Concentration
        probs = compute_representation_concentration(data, beta)
        results['p_trivial'][i] = probs[data.trivial]
        
        # Dominance
        results['is_fund_dominant'][i] = is_dom
    
    return results


# ─── SU(2) Truncated Model Factory ───

def make_su2_truncated_model(n_higher: int = 5) -> CharacterExpansionData:
    """
    Create an SU(2)-inspired truncated character expansion model.
    
    Sector coefficients:
    - trivial: 1 (constant)
    - fundamental: 2β (linear)
    - adjoint: β² (quadratic)
    - higher_k: β^(k+3) (higher suppression)
    
    Args:
        n_higher: Number of higher representation sectors
    
    Returns:
        CharacterExpansionData for the truncated model
    """
    sectors = ['triv', 'fund', 'adj'] + [f'higher_{k}' for k in range(n_higher)]
    
    def coeff_fn(beta: float, sector: str) -> float:
        if sector == 'triv':
            return 1.0
        elif sector == 'fund':
            return 2.0 * beta
        elif sector == 'adj':
            return beta ** 2
        elif sector.startswith('higher_'):
            k = int(sector.split('_')[1])
            return beta ** (k + 3)
        else:
            raise ValueError(f"Unknown sector: {sector}")
    
    weights = {
        'triv': 0.0,
        'fund': 0.75,   # Casimir for spin-1/2
        'adj': 2.0,     # Casimir for spin-1
    }
    for k in range(n_higher):
        weights[f'higher_{k}'] = (k + 2) * (k + 3) / 2
    
    dims = {
        'triv': 1,
        'fund': 2,
        'adj': 3,
    }
    for k in range(n_higher):
        dims[f'higher_{k}'] = 2 * k + 4
    
    return CharacterExpansionData(
        sector_names=sectors,
        trivial='triv',
        fundamental='fund',
        coeff_fn=coeff_fn,
        weight=weights,
        dim=dims,
    )


# ─── Example Usage ───

if __name__ == "__main__":
    model = make_su2_truncated_model()
    betas = np.linspace(0.01, 1.0, 100)
    results = spectral_gap_sweep(model, betas)
    
    print("Algorithm Results Summary")
    print("=" * 50)
    print(f"β range: [{betas[0]:.2f}, {betas[-1]:.2f}]")
    print(f"Max exact gap: {results['exact_gap'].max():.4f}")
    print(f"Min exact gap: {results['exact_gap'].min():.4f}")
    print(f"Max |residual|: {np.abs(results['residual']).max():.6f}")
    print(f"Fund dominant for all β: {results['is_fund_dominant'].all()}")
    print(f"Max p_trivial: {results['p_trivial'].max():.6f}")
    print(f"Min p_trivial: {results['p_trivial'].min():.6f}")
