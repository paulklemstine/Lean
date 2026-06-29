#!/usr/bin/env python3
"""
PAC-Bayes Certified Algorithms

Implements the verified algorithms for computing PAC-Bayes generalization
certificates, matching the formal Lean 4 definitions.

Classes:
    GaussianPosteriorFamily — Gaussian posterior N(w, σq²I) with prior N(0, σp²I)
    PACBayesCertificate — Certified generalization bound
    RobustPACBayesCertificate — Robustness-augmented certificate

Functions:
    gaussian_kl_div — KL divergence for Gaussian distributions
    mcallester_bound — McAllester PAC-Bayes bound
    catoni_bound — Catoni exponential PAC-Bayes bound
    optimize_posterior_scale — Find optimal σq for tightest bound
"""

import math
from dataclasses import dataclass
from typing import Optional, Tuple


@dataclass
class GaussianPosteriorFamily:
    """Gaussian posterior perturbation family N(w, σq²I) with prior N(0, σp²I).
    
    Matches the Lean 4 structure `PACBayes.GaussianPosteriorFamily`.
    
    Attributes:
        d: Dimension of parameter space
        norm_w: Euclidean norm of the center ||w||
        sigma_p: Prior standard deviation (> 0)
        sigma_q: Posterior standard deviation (> 0)
    """
    d: int
    norm_w: float
    sigma_p: float
    sigma_q: float
    
    def __post_init__(self):
        assert self.sigma_p > 0, "Prior scale must be positive"
        assert self.sigma_q > 0, "Posterior scale must be positive"
        assert self.d >= 0, "Dimension must be non-negative"
    
    def kl_divergence(self) -> float:
        """KL(N(w, σq²I) || N(0, σp²I)).
        
        = ||w||² / (2σp²) + (d/2)(σq²/σp² - 1 - log(σq²/σp²))
        
        Time complexity: O(1)
        Space complexity: O(1)
        """
        ratio = (self.sigma_q / self.sigma_p) ** 2
        energy = self.norm_w ** 2 / (2 * self.sigma_p ** 2)
        entropy = (self.d / 2) * (ratio - 1 - math.log(ratio))
        return energy + entropy
    
    def energy_term(self) -> float:
        """The mean-shift energy: ||w||² / (2σp²)."""
        return self.norm_w ** 2 / (2 * self.sigma_p ** 2)
    
    def entropy_term(self) -> float:
        """The variance-mismatch entropy: (d/2)(σq²/σp² - 1 - log(σq²/σp²))."""
        ratio = (self.sigma_q / self.sigma_p) ** 2
        return (self.d / 2) * (ratio - 1 - math.log(ratio))


@dataclass
class PACBayesCertificate:
    """A PAC-Bayes generalization certificate.
    
    Matches the Lean 4 structure `PACBayes.PACBayesCertificate`.
    
    Attributes:
        emp_risk: Empirical (training) Gibbs risk
        complexity: KL-based complexity penalty
        bound: Final generalization bound
        confidence: Confidence level (1 - δ)
    
    Validity invariant: emp_risk + complexity ≤ bound
    """
    emp_risk: float
    complexity: float
    bound: float
    confidence: float
    
    @property
    def valid(self) -> bool:
        """Check the validity invariant."""
        return self.emp_risk + self.complexity <= self.bound + 1e-12
    
    def generalization_gap(self) -> float:
        """The gap between bound and empirical risk."""
        return self.bound - self.emp_risk


@dataclass 
class RobustPACBayesCertificate:
    """A robust PAC-Bayes certificate connecting perturbation stability
    to generalization.
    
    Matches the Lean 4 structure `PACBayes.RobustPACBayesCertificate`.
    """
    margin_lower: float
    perturb_radius: float
    empirical_bound: float
    kl_penalty: float
    generalization_bound: float
    
    @property
    def is_robust(self) -> bool:
        """Whether the margin exceeds the perturbation."""
        return self.margin_lower > self.perturb_radius


def gaussian_kl_div(d: int, norm_w: float, sigma_q: float, sigma_p: float) -> float:
    """KL(N(w, σq²I) || N(0, σp²I)) in d dimensions.
    
    Args:
        d: Dimension
        norm_w: Parameter norm ||w||
        sigma_q: Posterior standard deviation
        sigma_p: Prior standard deviation
    
    Returns:
        KL divergence value (≥ 0)
    
    Time complexity: O(1)
    """
    ratio = (sigma_q / sigma_p) ** 2
    energy = norm_w ** 2 / (2 * sigma_p ** 2)
    entropy = (d / 2) * (ratio - 1 - math.log(ratio))
    return energy + entropy


def mcallester_bound(emp_risk: float, kl: float, n: int, delta: float) -> float:
    """McAllester PAC-Bayes generalization bound.
    
    bound = empRisk + √((KL + log(2√n/δ)) / (2(n-1)))
    
    Args:
        emp_risk: Empirical Gibbs risk
        kl: KL divergence KL(Q||P)
        n: Sample size (must be > 1)
        delta: Confidence parameter (0 < δ < 1)
    
    Returns:
        Upper bound on population risk (with probability ≥ 1-δ)
    
    Time complexity: O(1)
    """
    if n <= 1:
        return float('inf')
    inside = (kl + math.log(2 * math.sqrt(n) / delta)) / (2 * (n - 1))
    return emp_risk + math.sqrt(max(0, inside))


def catoni_bound(emp_risk: float, kl: float, n: int, delta: float, lam: float) -> float:
    """Catoni PAC-Bayes bound with inverse temperature λ.
    
    bound = (1/(1-e^{-λ})) · (1 - exp(-λ·empRisk - (KL + log(1/δ))/n))
    
    Args:
        emp_risk: Empirical Gibbs risk
        kl: KL divergence KL(Q||P)
        n: Sample size (must be > 0)
        delta: Confidence parameter (0 < δ < 1)
        lam: Inverse temperature (> 0)
    
    Returns:
        Upper bound on population risk
    
    Time complexity: O(1)
    """
    if lam <= 0 or n <= 0:
        return float('inf')
    denom = 1 - math.exp(-lam)
    exponent = -lam * emp_risk - (kl + math.log(1 / delta)) / n
    return (1 / denom) * (1 - math.exp(exponent))


def compute_certificate(family: GaussianPosteriorFamily, n: int, delta: float,
                         emp_risk: float, lam: float = 1.0) -> PACBayesCertificate:
    """Compute a PAC-Bayes certificate from a Gaussian posterior family.
    
    This is the verified algorithm matching `gaussianPacBayesCertificate` in Lean.
    
    Args:
        family: Gaussian posterior/prior specification
        n: Sample size
        delta: Confidence parameter
        emp_risk: Empirical risk
        lam: Inverse temperature for Catoni bound
    
    Returns:
        A valid PACBayesCertificate
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    kl = family.kl_divergence()
    mc = mcallester_bound(emp_risk, kl, n, delta)
    complexity = mc - emp_risk
    
    return PACBayesCertificate(
        emp_risk=emp_risk,
        complexity=complexity,
        bound=mc,
        confidence=1 - delta,
    )


def optimize_posterior_scale(d: int, norm_w: float, sigma_p: float,
                              n: int, delta: float, emp_risk: float,
                              bound_type: str = 'mcallester',
                              lam: float = 1.0,
                              search_range: Tuple[float, float] = (0.01, 5.0),
                              num_points: int = 1000) -> Tuple[float, float]:
    """Find the optimal posterior scale σq that minimizes the PAC-Bayes bound.
    
    Uses grid search over σq values.
    
    Args:
        d: Dimension
        norm_w: Parameter norm
        sigma_p: Prior standard deviation
        n: Sample size
        delta: Confidence parameter
        emp_risk: Empirical risk
        bound_type: 'mcallester' or 'catoni'
        lam: Inverse temperature (for Catoni)
        search_range: (min_sigma_q, max_sigma_q)
        num_points: Number of grid points
    
    Returns:
        (optimal_sigma_q, optimal_bound)
    
    Time complexity: O(num_points)
    """
    best_sq = search_range[0]
    best_bound = float('inf')
    
    for i in range(num_points):
        sq = search_range[0] + (search_range[1] - search_range[0]) * i / num_points
        kl = gaussian_kl_div(d, norm_w, sq, sigma_p)
        
        if bound_type == 'mcallester':
            bound = mcallester_bound(emp_risk, kl, n, delta)
        else:
            bound = catoni_bound(emp_risk, kl, n, delta, lam)
        
        if bound < best_bound:
            best_bound = bound
            best_sq = sq
    
    return best_sq, best_bound


def compute_robust_certificate(margin: float, perturb_radius: float,
                                 kl: float, n: int, delta: float) -> RobustPACBayesCertificate:
    """Compute a robust PAC-Bayes certificate.
    
    If margin > perturb_radius, the empirical risk is 0 (perfect robustness),
    and the bound is just the KL complexity term.
    
    Args:
        margin: Classification margin (γ)
        perturb_radius: Perturbation radius (σ)
        kl: KL divergence
        n: Sample size
        delta: Confidence parameter
    
    Returns:
        A RobustPACBayesCertificate
    """
    emp = 0.0 if margin > perturb_radius else min(1.0, perturb_radius / margin - 1)
    bound = mcallester_bound(emp, kl, n, delta)
    penalty = bound - emp
    
    return RobustPACBayesCertificate(
        margin_lower=margin,
        perturb_radius=perturb_radius,
        empirical_bound=emp,
        kl_penalty=penalty,
        generalization_bound=bound,
    )


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("PAC-Bayes Certified Algorithms — Example Usage")
    print("=" * 50)
    
    # Create a Gaussian posterior family
    family = GaussianPosteriorFamily(d=50, norm_w=3.0, sigma_p=1.0, sigma_q=0.5)
    print(f"\nGaussian family: d={family.d}, ||w||={family.norm_w}")
    print(f"  Prior: N(0, {family.sigma_p}²I)")
    print(f"  Posterior: N(w, {family.sigma_q}²I)")
    print(f"  KL divergence: {family.kl_divergence():.4f}")
    print(f"    Energy: {family.energy_term():.4f}")
    print(f"    Entropy: {family.entropy_term():.4f}")
    
    # Compute certificate
    cert = compute_certificate(family, n=1000, delta=0.05, emp_risk=0.05)
    print(f"\nCertificate (n=1000, δ=0.05):")
    print(f"  Empirical risk: {cert.emp_risk:.4f}")
    print(f"  Complexity: {cert.complexity:.4f}")
    print(f"  Bound: {cert.bound:.4f}")
    print(f"  Valid: {cert.valid}")
    
    # Optimize posterior scale
    opt_sq, opt_bound = optimize_posterior_scale(
        d=50, norm_w=3.0, sigma_p=1.0, n=1000, delta=0.05, emp_risk=0.05
    )
    print(f"\nOptimized posterior scale: σq = {opt_sq:.3f}")
    print(f"Optimized bound: {opt_bound:.6f}")
    
    # Robust certificate
    rcert = compute_robust_certificate(margin=1.5, perturb_radius=0.5,
                                        kl=family.kl_divergence(),
                                        n=1000, delta=0.05)
    print(f"\nRobust certificate (γ=1.5, σ=0.5):")
    print(f"  Robust: {rcert.is_robust}")
    print(f"  Empirical bound: {rcert.empirical_bound:.4f}")
    print(f"  KL penalty: {rcert.kl_penalty:.4f}")
    print(f"  Generalization bound: {rcert.generalization_bound:.6f}")
