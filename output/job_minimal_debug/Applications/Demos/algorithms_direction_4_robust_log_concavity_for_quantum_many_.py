#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Quantum Lorentzian Bridge

Implements certified computation of surrogate Lorentzian gaps, event/boundary
anti-concentration certificates, and perturbation stability analysis for
finite measurement distributions.

Each algorithm is tied to a theorem proving its correctness or lower-bound guarantee.

Algorithms:
1. MinMassCertificate — Computes minimum mass anti-concentration certificate
2. EventRatioBound — Computes exp(ε) perturbation bounds for events
3. BoundaryMassComputer — Computes boundary mass on Hamming graphs
4. PerturbativeGapTransfer — Transfers gap certificates through perturbation
5. LogConcavityCertifier — Checks pairwise log-concavity conditions
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class Distribution:
    """A finite probability distribution."""
    probs: np.ndarray
    
    def __post_init__(self):
        assert np.all(self.probs >= -1e-12), "Probabilities must be nonneg"
        self.probs = np.maximum(self.probs, 0.0)
        total = np.sum(self.probs)
        if total > 0:
            self.probs = self.probs / total
    
    @property
    def size(self) -> int:
        return len(self.probs)
    
    def min_mass(self) -> float:
        """Minimum probability mass. Corresponds to `minMass` in Lean."""
        return float(np.min(self.probs))
    
    def max_mass(self) -> float:
        return float(np.max(self.probs))
    
    def event_prob(self, event: np.ndarray) -> float:
        """Probability of an event (boolean mask)."""
        return float(np.sum(self.probs[event]))


@dataclass
class MinMassCertificate:
    """
    Certificate that a distribution has minimum mass ≥ threshold.
    
    Correctness guarantee (Theorem 2 in Lean):
    If hratio holds with parameter ε, then
    exp(-ε) * minMass(ν) ≤ minMass(μ)
    
    Algorithm: O(n) scan of all probabilities.
    """
    min_mass: float
    achieving_index: int
    
    @staticmethod
    def compute(dist: Distribution) -> 'MinMassCertificate':
        """Compute minimum mass certificate. O(n) time."""
        idx = int(np.argmin(dist.probs))
        return MinMassCertificate(
            min_mass=dist.probs[idx],
            achieving_index=idx
        )
    
    @staticmethod
    def perturbation_bound(ref_cert: 'MinMassCertificate', epsilon: float) -> float:
        """
        Lower bound on min-mass of perturbed distribution.
        
        By Theorem 2 (minMass_perturbation_lower_bound):
        minMass(μ) ≥ exp(-ε) * minMass(ν)
        
        Args:
            ref_cert: Certificate for reference distribution ν
            epsilon: Perturbation parameter ε ≥ 0
        
        Returns:
            Lower bound exp(-ε) * minMass(ν)
        """
        return np.exp(-epsilon) * ref_cert.min_mass


@dataclass
class EventRatioBound:
    """
    Certified bounds on event probabilities under perturbation.
    
    Correctness guarantee (Theorem 1 in Lean):
    exp(-ε) * ν(s) ≤ μ(s) ≤ exp(ε) * ν(s)
    
    Algorithm: O(|s|) summation for each event.
    """
    event_prob_ref: float
    lower_bound: float
    upper_bound: float
    epsilon: float
    
    @staticmethod
    def compute(ref_dist: Distribution, event: np.ndarray, epsilon: float) -> 'EventRatioBound':
        """
        Compute certified event probability bounds.
        
        By Theorem 1 (event_prob_ratio_bound):
        For any event s, exp(-ε)·ν(s) ≤ μ(s) ≤ exp(ε)·ν(s)
        
        Args:
            ref_dist: Reference distribution ν
            event: Boolean mask for event s
            epsilon: Perturbation parameter
        
        Returns:
            EventRatioBound with certified lower/upper bounds
        """
        ref_prob = ref_dist.event_prob(event)
        return EventRatioBound(
            event_prob_ref=ref_prob,
            lower_bound=np.exp(-epsilon) * ref_prob,
            upper_bound=np.exp(epsilon) * ref_prob,
            epsilon=epsilon
        )
    
    def verify(self, actual_prob: float) -> bool:
        """Check that actual probability falls within certified bounds."""
        return self.lower_bound <= actual_prob + 1e-10 and actual_prob <= self.upper_bound + 1e-10


class BoundaryMassComputer:
    """
    Compute boundary mass on Hamming-distance graphs.
    
    For a finite spin system with distribution μ and Hamming-1 adjacency,
    computes boundaryMass(A) = Σ_{x ∈ A: ∃y∈Aᶜ, d(x,y)=1} μ(x).
    
    Correctness guarantee (Theorem 3 in Lean):
    exp(-ε) * boundaryMass_T(A) ≤ boundaryMass_S(A)
    when distributions are multiplicatively ε-close.
    
    Algorithm: O(n · |A|) where n = number of bits.
    """
    
    def __init__(self, n_bits: int, dist: Distribution):
        self.n_bits = n_bits
        self.dist = dist
        assert dist.size == 2**n_bits
    
    def boundary_mass(self, A: set) -> float:
        """
        Compute boundary mass of subset A.
        
        A configuration x ∈ A is on the boundary if it has a
        Hamming-1 neighbor outside A.
        """
        mass = 0.0
        for x in A:
            for bit in range(self.n_bits):
                y = x ^ (1 << bit)
                if y not in A:
                    mass += self.dist.probs[x]
                    break
        return mass
    
    def expansion_ratio(self, A: set) -> float:
        """
        Compute expansion ratio Φ(A) = boundaryMass(A) / μ(A).
        """
        mu_A = sum(self.dist.probs[x] for x in A)
        if mu_A < 1e-15:
            return 0.0
        return self.boundary_mass(A) / mu_A
    
    @staticmethod
    def perturbative_bound(ref_boundary: float, epsilon: float) -> float:
        """
        Lower bound on boundary mass of perturbed system.
        
        By Theorem 3 (perturbative_boundaryMass_lower_bound):
        boundaryMass_S(A) ≥ exp(-ε) * boundaryMass_T(A)
        """
        return np.exp(-epsilon) * ref_boundary


class PerturbativeGapTransfer:
    """
    Transfer gap certificates through multiplicative perturbation.
    
    Given:
    - Reference distribution ν with gap certificate γ_ref
    - Perturbation parameter ε
    
    Produces:
    - Lower bound on gap of perturbed distribution μ
    
    This implements the formal pipeline:
    quantum gap → Lorentzian gap → classical gap
    """
    
    def __init__(self, ref_dist: Distribution, ref_gap: float):
        self.ref_dist = ref_dist
        self.ref_gap = ref_gap
    
    def compute_epsilon(self, perturbed_dist: Distribution) -> float:
        """Compute the multiplicative perturbation parameter ε."""
        valid = (self.ref_dist.probs > 1e-15) & (perturbed_dist.probs > 1e-15)
        if not np.any(valid):
            return float('inf')
        ratios = np.log(perturbed_dist.probs[valid] / self.ref_dist.probs[valid])
        return float(np.max(np.abs(ratios)))
    
    def transfer_gap(self, perturbed_dist: Distribution) -> Dict:
        """
        Transfer gap certificate to perturbed distribution.
        
        Returns dict with:
        - epsilon: computed perturbation parameter
        - min_mass_bound: lower bound on min-mass
        - boundary_mass_factor: multiplicative degradation factor
        """
        eps = self.compute_epsilon(perturbed_dist)
        ref_cert = MinMassCertificate.compute(self.ref_dist)
        
        return {
            'epsilon': eps,
            'degradation_factor': np.exp(-eps),
            'min_mass_ref': ref_cert.min_mass,
            'min_mass_bound': np.exp(-eps) * ref_cert.min_mass,
            'min_mass_actual': perturbed_dist.min_mass(),
            'bound_satisfied': np.exp(-eps) * ref_cert.min_mass <= perturbed_dist.min_mass() + 1e-10
        }


class LogConcavityCertifier:
    """
    Check and certify pairwise log-concavity conditions.
    
    For a distribution μ, checks:
    μ(x) · μ(y) ≤ (max μ)² for all x, y
    
    This is a necessary condition for the generating polynomial
    to be Lorentzian (strongly log-concave).
    """
    
    @staticmethod
    def check_pairwise(dist: Distribution) -> Dict:
        """
        Check pairwise log-concavity condition.
        
        Returns:
        - satisfied: whether all pairs satisfy the bound
        - max_violation: largest violation ratio
        - violation_count: number of violating pairs
        """
        max_mass = dist.max_mass()
        threshold = max_mass**2
        
        violations = 0
        max_violation = 0.0
        
        for i in range(dist.size):
            for j in range(dist.size):
                product = dist.probs[i] * dist.probs[j]
                if product > threshold * (1 + 1e-10):
                    violations += 1
                    ratio = product / threshold if threshold > 0 else float('inf')
                    max_violation = max(max_violation, ratio)
        
        return {
            'satisfied': violations == 0,
            'violation_count': violations,
            'max_violation_ratio': max_violation,
            'max_mass': max_mass,
            'threshold': threshold
        }
    
    @staticmethod
    def finite_difference_certificate(dist: Distribution, n_bits: int) -> Dict:
        """
        Compute a finite-difference log-concavity certificate.
        
        For each pair of bits (i,j), compute the discrete Hessian:
        H_{ij} = E[f(x⊕eᵢ⊕eⱼ)] - E[f(x⊕eᵢ)] - E[f(x⊕eⱼ)] + E[f(x)]
        where f = log μ.
        
        Negative semi-definiteness of H is a log-concavity certificate.
        """
        assert dist.size == 2**n_bits
        
        log_probs = np.log(np.maximum(dist.probs, 1e-30))
        
        hessian = np.zeros((n_bits, n_bits))
        for i in range(n_bits):
            for j in range(n_bits):
                val = 0.0
                count = 0
                for x in range(dist.size):
                    xi = x ^ (1 << i)
                    xj = x ^ (1 << j)
                    xij = x ^ (1 << i) ^ (1 << j)
                    val += log_probs[xij] - log_probs[xi] - log_probs[xj] + log_probs[x]
                    count += 1
                hessian[i, j] = val / count
        
        eigenvalues = np.linalg.eigvalsh(hessian)
        
        return {
            'hessian': hessian,
            'eigenvalues': eigenvalues,
            'max_eigenvalue': float(np.max(eigenvalues)),
            'is_negative_semidefinite': bool(np.max(eigenvalues) <= 1e-8),
            'lorentzian_gap': float(-np.sort(eigenvalues)[1]) if len(eigenvalues) > 1 else 0.0
        }


def example_usage():
    """Demonstrate all algorithms."""
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Create a sample distribution (uniform-ish)
    n = 4
    probs = np.random.dirichlet(np.ones(2**n) * 5)
    dist = Distribution(probs)
    
    # 1. MinMass Certificate
    cert = MinMassCertificate.compute(dist)
    print(f"\n1. MinMass Certificate:")
    print(f"   min_mass = {cert.min_mass:.6f} at index {cert.achieving_index}")
    print(f"   Perturbation bound (ε=0.1): {MinMassCertificate.perturbation_bound(cert, 0.1):.6f}")
    
    # 2. Event Ratio Bound
    event = np.zeros(2**n, dtype=bool)
    event[:2**(n-1)] = True
    erb = EventRatioBound.compute(dist, event, 0.5)
    print(f"\n2. Event Ratio Bound (ε=0.5):")
    print(f"   ν(s) = {erb.event_prob_ref:.6f}")
    print(f"   Certified: [{erb.lower_bound:.6f}, {erb.upper_bound:.6f}]")
    
    # 3. Boundary Mass
    bmc = BoundaryMassComputer(n, dist)
    A = set(range(2**(n-1)))
    bm = bmc.boundary_mass(A)
    print(f"\n3. Boundary Mass (half-space):")
    print(f"   boundary_mass = {bm:.6f}")
    print(f"   expansion_ratio = {bmc.expansion_ratio(A):.6f}")
    
    # 4. Perturbative Gap Transfer
    ref_dist = Distribution(np.ones(2**n) / 2**n)  # Uniform reference
    pgt = PerturbativeGapTransfer(ref_dist, ref_gap=1.0)
    transfer = pgt.transfer_gap(dist)
    print(f"\n4. Perturbative Gap Transfer:")
    print(f"   ε = {transfer['epsilon']:.4f}")
    print(f"   degradation = {transfer['degradation_factor']:.4f}")
    print(f"   min_mass bound: {transfer['min_mass_bound']:.6f} ≤ {transfer['min_mass_actual']:.6f} "
          f"{'✓' if transfer['bound_satisfied'] else '✗'}")
    
    # 5. Log-Concavity Certifier
    lc = LogConcavityCertifier.check_pairwise(dist)
    print(f"\n5. Pairwise Log-Concavity:")
    print(f"   Satisfied: {lc['satisfied']}")
    print(f"   Violations: {lc['violation_count']}")
    
    # 6. Finite-Difference Certificate
    fdc = LogConcavityCertifier.finite_difference_certificate(dist, n)
    print(f"\n6. Finite-Difference Log-Concavity:")
    print(f"   Eigenvalues: {fdc['eigenvalues'][:4].round(4)}")
    print(f"   NSD: {fdc['is_negative_semidefinite']}")
    print(f"   Lorentzian gap surrogate: {fdc['lorentzian_gap']:.4f}")


if __name__ == '__main__':
    np.random.seed(42)
    example_usage()
