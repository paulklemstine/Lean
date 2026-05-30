#!/usr/bin/env python3
"""
Algorithms for the Universal Spectral Law of Lorentzian Polynomials

Implements:
1. SpectralStabilityChecker — certify Lorentzian stability under perturbation
2. MinSpectralGapComputer — compute γ_min for a Hessian family
3. LorentzianProductGenerator — generate random Lorentzian polynomials
4. ConditionNumberAnalyzer — analyze spectral condition numbers

Complexity Analysis:
- SpectralStabilityChecker: O(n³) per leaf (eigenvalue computation)
- MinSpectralGapComputer: O(k·n³) for k leaves of dimension n
- LorentzianProductGenerator: O(d·n²) for degree d, dimension n
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class LorentzianHessianFamily:
    """A family of leaf Hessians from a Lorentzian polynomial.

    Attributes:
        n: ambient dimension
        leaves: list of n×n symmetric matrices (leaf Hessians)
        coeff_bound: maximum absolute entry across all leaves
        min_gap: minimum spectral gap across all leaves
    """
    n: int
    leaves: List[np.ndarray]
    coeff_bound: float
    min_gap: float


@dataclass
class StabilityResult:
    """Result of a stability check.

    Attributes:
        is_stable: whether the perturbed family is Lorentzian
        stability_radius: predicted stability radius γ_min/(n·M)
        condition_number: spectral condition number M/γ_min
        residual_gaps: list of residual spectral gaps per leaf
    """
    is_stable: bool
    stability_radius: float
    condition_number: float
    residual_gaps: List[float]


class SpectralStabilityChecker:
    """Certify Lorentzian stability under coefficient perturbation.

    Algorithm:
    1. Compute eigenvalues of each leaf Hessian
    2. Verify each has at most one positive eigenvalue
    3. Compute the minimum spectral gap γ_min
    4. Check if perturbation entries are within γ_min/n

    Time complexity: O(k·n³) for k leaves of dimension n
    Space complexity: O(k·n²)
    """

    @staticmethod
    def check_lorentzian(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, float]:
        """Check if a symmetric matrix has at most one positive eigenvalue.

        Returns:
            (is_lorentzian, spectral_gap)
        """
        eigs = np.linalg.eigvalsh(A)
        n_positive = np.sum(eigs > tol)
        if n_positive > 1:
            return False, 0.0

        negative_eigs = eigs[eigs < -tol]
        if len(negative_eigs) == 0:
            return True, 0.0

        gap = float(np.min(np.abs(negative_eigs)))
        return True, gap

    @staticmethod
    def check_stability(family: LorentzianHessianFamily,
                        perturbations: List[np.ndarray]) -> StabilityResult:
        """Check if perturbations preserve Lorentzian signature.

        Args:
            family: the Lorentzian Hessian family
            perturbations: list of perturbation matrices (one per leaf)

        Returns:
            StabilityResult with detailed diagnostics
        """
        n = family.n
        gamma = family.min_gap
        M = family.coeff_bound

        stability_radius = gamma / (n * M) if n * M > 0 else float('inf')
        condition_number = M / gamma if gamma > 0 else float('inf')

        residual_gaps = []
        all_stable = True

        for leaf, E in zip(family.leaves, perturbations):
            perturbed = leaf + E
            is_lor, gap = SpectralStabilityChecker.check_lorentzian(perturbed)
            residual_gaps.append(gap)
            if not is_lor:
                all_stable = False

        return StabilityResult(
            is_stable=all_stable,
            stability_radius=stability_radius,
            condition_number=condition_number,
            residual_gaps=residual_gaps
        )


class MinSpectralGapComputer:
    """Compute the minimum spectral gap of a Hessian family.

    For each leaf Hessian, compute eigenvalues and extract the spectral gap
    (smallest magnitude of negative eigenvalues). Return the minimum across leaves.

    Time complexity: O(k·n³)
    """

    @staticmethod
    def compute(leaves: List[np.ndarray], tol: float = 1e-10) -> float:
        """Compute γ_min across all leaf Hessians.

        Args:
            leaves: list of symmetric matrices
            tol: numerical tolerance

        Returns:
            minimum spectral gap (0 if any leaf is degenerate)
        """
        min_gap = float('inf')
        for leaf in leaves:
            eigs = np.linalg.eigvalsh(leaf)
            negative_eigs = eigs[eigs < -tol]
            if len(negative_eigs) == 0:
                return 0.0
            gap = float(np.min(np.abs(negative_eigs)))
            min_gap = min(min_gap, gap)
        return min_gap

    @staticmethod
    def compute_with_details(leaves: List[np.ndarray]) -> Dict:
        """Compute γ_min with full spectral details.

        Returns dictionary with:
        - min_gap: the minimum spectral gap
        - per_leaf_gaps: gap for each leaf
        - per_leaf_eigenvalues: sorted eigenvalues per leaf
        - worst_leaf_index: index of the leaf with smallest gap
        """
        gaps = []
        all_eigs = []
        for leaf in leaves:
            eigs = np.sort(np.linalg.eigvalsh(leaf))
            all_eigs.append(eigs)
            negative_eigs = eigs[eigs < -1e-10]
            if len(negative_eigs) == 0:
                gaps.append(0.0)
            else:
                gaps.append(float(np.min(np.abs(negative_eigs))))

        min_gap = min(gaps) if gaps else 0.0
        worst_idx = np.argmin(gaps) if gaps else -1

        return {
            'min_gap': min_gap,
            'per_leaf_gaps': gaps,
            'per_leaf_eigenvalues': all_eigs,
            'worst_leaf_index': int(worst_idx)
        }


class LorentzianProductGenerator:
    """Generate random Lorentzian polynomials as products of linear forms.

    A product f = ℓ₁·ℓ₂·...·ℓ_d where ℓ_k(x) = ∑ a_{k,i} x_i with a_{k,i} > 0
    is always Lorentzian. The leaf Hessians are rank-one matrices
    H = a⊗b + b⊗a where a, b are coefficient vectors.

    Time complexity: O(d²·n²) for all leaves
    """

    @staticmethod
    def generate(n: int, d: int, M: float = 1.0,
                 seed: Optional[int] = None) -> LorentzianHessianFamily:
        """Generate a random Lorentzian polynomial via products of linear forms.

        Args:
            n: number of variables
            d: degree of the polynomial
            M: coefficient bound
            seed: random seed for reproducibility

        Returns:
            LorentzianHessianFamily with the leaf Hessians
        """
        if seed is not None:
            np.random.seed(seed)

        # Generate d linear forms with positive coefficients
        coeffs = np.random.uniform(0.1 * M, M, (d, n))

        # Generate all leaf Hessians (choose d-2 directions to differentiate)
        leaves = []
        for i in range(d):
            for j in range(i + 1, d):
                a, b = coeffs[i], coeffs[j]
                H = np.outer(a, b) + np.outer(b, a)
                leaves.append(H)

        if not leaves:
            # Degree ≤ 1: trivial
            leaves = [np.zeros((n, n))]

        coeff_bound = max(np.max(np.abs(leaf)) for leaf in leaves)
        min_gap = MinSpectralGapComputer.compute(leaves)

        return LorentzianHessianFamily(
            n=n, leaves=leaves, coeff_bound=coeff_bound, min_gap=min_gap
        )


class ConditionNumberAnalyzer:
    """Analyze spectral condition numbers of Lorentzian polynomial families.

    The condition number κ = M/γ_min measures fragility of the Lorentzian property.
    Lower κ means more robust; higher κ means more fragile.
    """

    @staticmethod
    def analyze(family: LorentzianHessianFamily) -> Dict:
        """Full condition number analysis.

        Returns:
            Dictionary with condition number, stability radius, and diagnostics
        """
        n = family.n
        gamma = family.min_gap
        M = family.coeff_bound

        kappa = M / gamma if gamma > 0 else float('inf')
        rho = gamma / (n * M) if n * M > 0 else float('inf')
        product = rho * n * kappa  # Should be 1.0

        return {
            'dimension': n,
            'num_leaves': len(family.leaves),
            'coeff_bound': M,
            'min_spectral_gap': gamma,
            'condition_number': kappa,
            'stability_radius': rho,
            'rho_n_kappa': product,
            'is_well_conditioned': kappa < 100,
        }


# =============================================================================
# Example usage
# =============================================================================
if __name__ == "__main__":
    print("=" * 70)
    print("Lorentzian Polynomial Stability Analysis")
    print("=" * 70)

    # Generate a random Lorentzian polynomial
    for n, d in [(3, 3), (4, 4), (5, 3), (6, 4), (8, 3)]:
        family = LorentzianProductGenerator.generate(n, d, M=1.0, seed=42)
        analysis = ConditionNumberAnalyzer.analyze(family)

        print(f"\n  n={n}, d={d}: {analysis['num_leaves']} leaves")
        print(f"    M = {analysis['coeff_bound']:.4f}")
        print(f"    γ_min = {analysis['min_spectral_gap']:.6f}")
        print(f"    κ = {analysis['condition_number']:.4f}")
        print(f"    ρ = {analysis['stability_radius']:.6f}")
        print(f"    ρ·n·κ = {analysis['rho_n_kappa']:.6f} (should be 1.0)")

        # Test stability
        perturbations = [
            np.random.uniform(-0.5 * analysis['stability_radius'],
                              0.5 * analysis['stability_radius'], (n, n))
            for _ in family.leaves
        ]
        perturbations = [(p + p.T) / 2 for p in perturbations]

        result = SpectralStabilityChecker.check_stability(family, perturbations)
        print(f"    Stability at 50% radius: {'✓' if result.is_stable else '✗'}")
