#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Lorentzian Gap Surrogates

Implements algorithms from the research paper with correctness guarantees
tied to the formally verified theorems.

Algorithms:
1. CertifiedMinMass — compute minimum singleton mass with perturbation bounds
2. BoundaryMassComputer — compute boundary mass on Hamming/spin-flip graphs
3. EventRatioVerifier — verify event probability ratio bounds
4. LogConcavityCertifier — compute surrogate log-concavity certificates
5. GapBridgeEstimator — estimate the quantum-to-classical gap chain
"""

import numpy as np
from typing import Tuple, List, Optional, Dict, Set
from dataclasses import dataclass


@dataclass
class RobustCertificate:
    """
    Robust Lorentzian certificate for a probability distribution.
    Corresponds to RobustLorentzianCertificate in the Lean formalization.
    """
    probs: np.ndarray
    pointwise_lower: float
    pointwise_upper: float
    is_valid: bool
    log_concavity_ratio: float

    def __repr__(self):
        return (f"RobustCertificate(lower={self.pointwise_lower:.6e}, "
                f"upper={self.pointwise_upper:.6e}, "
                f"LC_ratio={self.log_concavity_ratio:.6f}, "
                f"valid={self.is_valid})")


@dataclass
class GapBridgeResult:
    """
    Result of gap bridge estimation.
    Corresponds to GappedMeasurementLift in the Lean formalization.
    """
    quantum_gap: float
    lorentzian_gap: float  # surrogate
    classical_gap: float   # conductance estimate
    probs: np.ndarray

    @property
    def chain_valid(self) -> bool:
        """Check if the gap chain inequality holds."""
        return self.quantum_gap <= self.lorentzian_gap + 1e-10 and \
               self.lorentzian_gap <= self.classical_gap + 1e-10


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Certified Minimum Mass
# ──────────────────────────────────────────────────────────────────────

def certified_min_mass(
    probs: np.ndarray,
    epsilon: float = 0.0
) -> Tuple[float, float]:
    """
    Compute minimum singleton mass with perturbation bound.

    If the distribution is a perturbation of a reference with multiplicative
    error exp(ε), then the minimum mass is at least exp(-ε) * min_mass(reference).

    Corresponds to theorem `minMass_perturbation_lower_bound`.

    Args:
        probs: probability distribution (nonneg, sums to 1)
        epsilon: perturbation parameter

    Returns:
        (min_mass, certified_lower_bound)

    Time complexity: O(n) where n = len(probs)
    Space complexity: O(1) additional
    """
    assert np.all(probs >= -1e-15), "Probabilities must be nonneg"
    assert abs(np.sum(probs) - 1.0) < 1e-10, "Probabilities must sum to 1"

    mm = float(np.min(probs))
    certified_lower = np.exp(-epsilon) * mm

    return mm, certified_lower


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Boundary Mass on Hamming Graph
# ──────────────────────────────────────────────────────────────────────

def boundary_mass_hamming(
    probs: np.ndarray,
    n_bits: int,
    subset: Optional[Set[int]] = None
) -> float:
    """
    Compute boundary mass for a subset of configurations on the Hamming graph.

    Corresponds to `boundaryMass` in the Lean formalization.

    The Hamming graph connects configurations differing in exactly one bit,
    modeling single-spin-flip Glauber dynamics.

    Args:
        probs: probability distribution on 2^n_bits configurations
        n_bits: number of bits/spins
        subset: the set A (defaults to heavy half by median)

    Returns:
        boundary mass of A

    Time complexity: O(|A| * n_bits)
    Space complexity: O(|A|)
    """
    dim = 2**n_bits
    assert len(probs) == dim

    if subset is None:
        median = np.median(probs)
        subset = set(i for i in range(dim) if probs[i] >= median)

    boundary = 0.0
    for x in subset:
        is_boundary = False
        for bit in range(n_bits):
            y = x ^ (1 << bit)
            if y not in subset:
                is_boundary = True
                break
        if is_boundary:
            boundary += probs[x]

    return boundary


def perturbative_boundary_bound(
    boundary_ref: float,
    epsilon: float
) -> float:
    """
    Compute the perturbative lower bound on boundary mass.

    By theorem `perturbative_boundaryMass_lower_bound`:
    boundaryMass(S, A) ≥ exp(-ε) * boundaryMass(T, A)

    Args:
        boundary_ref: boundary mass of the reference distribution
        epsilon: perturbation parameter

    Returns:
        certified lower bound on perturbed boundary mass
    """
    return np.exp(-epsilon) * boundary_ref


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Event Ratio Verifier
# ──────────────────────────────────────────────────────────────────────

def verify_event_ratio_bound(
    mu: np.ndarray,
    nu: np.ndarray,
    epsilon: float,
    event_indices: Optional[List[int]] = None
) -> Dict:
    """
    Verify event probability ratio bounds between two distributions.

    Corresponds to theorem `event_prob_ratio_bound`.

    Args:
        mu: perturbed distribution
        nu: reference distribution
        epsilon: ratio parameter
        event_indices: indices of the event (default: all)

    Returns:
        dict with verification results

    Time complexity: O(n)
    """
    n = len(mu)
    assert len(nu) == n

    if event_indices is None:
        event_indices = list(range(n))

    # Check pointwise bounds
    exp_neg = np.exp(-epsilon)
    exp_pos = np.exp(epsilon)

    pointwise_ok = True
    violations = []
    for i in range(n):
        lower_ok = exp_neg * nu[i] <= mu[i] + 1e-15
        upper_ok = mu[i] <= exp_pos * nu[i] + 1e-15
        if not (lower_ok and upper_ok):
            pointwise_ok = False
            violations.append(i)

    # Check event bounds
    mu_event = sum(mu[i] for i in event_indices)
    nu_event = sum(nu[i] for i in event_indices)

    event_lower = exp_neg * nu_event
    event_upper = exp_pos * nu_event

    return {
        'pointwise_ok': pointwise_ok,
        'violations': violations,
        'mu_event': mu_event,
        'nu_event': nu_event,
        'lower_bound': event_lower,
        'upper_bound': event_upper,
        'lower_satisfied': event_lower <= mu_event + 1e-15,
        'upper_satisfied': mu_event <= event_upper + 1e-15,
        'epsilon': epsilon
    }


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Log-Concavity Certifier
# ──────────────────────────────────────────────────────────────────────

def certify_log_concavity(probs: np.ndarray) -> RobustCertificate:
    """
    Compute a robust Lorentzian certificate for a probability distribution.

    Corresponds to `RobustLorentzianCertificate` in the Lean formalization.

    The certificate includes:
    - pointwise lower/upper bounds
    - pair log-concavity ratio: min_{x,y} μ(x)μ(y) / max(μ)^2

    Time complexity: O(n) for bounds, O(n^2) for pair log-concavity
    Space complexity: O(1) additional
    """
    assert np.all(probs >= -1e-15)
    assert abs(np.sum(probs) - 1.0) < 1e-10

    pw_lower = float(np.min(probs))
    pw_upper = float(np.max(probs))

    # Pair log-concavity: min_{x,y} μ(x)μ(y) / max^2
    if pw_upper > 0:
        lc_ratio = (pw_lower * pw_lower) / (pw_upper * pw_upper)
    else:
        lc_ratio = 0.0

    # Check pair log-concavity condition: μ(x)μ(y) ≤ upper^2 for all x,y
    is_valid = True  # Always true by definition of upper

    return RobustCertificate(
        probs=probs,
        pointwise_lower=pw_lower,
        pointwise_upper=pw_upper,
        is_valid=is_valid,
        log_concavity_ratio=lc_ratio
    )


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Gap Bridge Estimator
# ──────────────────────────────────────────────────────────────────────

def estimate_gap_bridge(
    hamiltonian: np.ndarray,
    n_bits: int,
    n_random_cuts: int = 100
) -> GapBridgeResult:
    """
    Estimate the quantum-to-classical gap chain for a Hamiltonian.

    Computes:
    1. Quantum spectral gap Δ(H)
    2. Surrogate Lorentzian gap (log-concavity ratio * min_mass)
    3. Classical conductance estimate Φ

    Then checks the chain inequality:
        Δ_quantum ≤ Δ_Lorentzian ≤ Δ_classical

    Note: The chain may not hold with these particular surrogate definitions;
    the formal theorem uses an abstract structure where the chain is axiomatized.
    The numerical evidence helps calibrate the right definitions.

    Time complexity: O(2^{2n} + n_random_cuts * 2^n * n)
    """
    eigenvalues, eigenvectors = np.linalg.eigh(hamiltonian)
    idx = np.argsort(eigenvalues)
    quantum_gap = float(eigenvalues[idx[1]] - eigenvalues[idx[0]])
    psi = eigenvectors[:, idx[0]]
    probs = np.abs(psi)**2

    # Surrogate Lorentzian gap
    cert = certify_log_concavity(probs)
    lorentzian_gap = cert.log_concavity_ratio * cert.pointwise_lower * len(probs)

    # Classical conductance
    dim = 2**n_bits
    best_cond = float('inf')

    # Threshold cuts
    sorted_p = np.sort(probs)[::-1]
    for k in range(1, dim):
        A = set(i for i in range(dim) if probs[i] >= sorted_p[k - 1])
        mu_A = sum(probs[i] for i in A)
        if mu_A <= 1e-15 or mu_A >= 1 - 1e-15:
            continue
        bdry = 0.0
        for x in A:
            for bit in range(n_bits):
                y = x ^ (1 << bit)
                if y not in A:
                    bdry += probs[x]
                    break
        cond = bdry / (mu_A * (1 - mu_A))
        best_cond = min(best_cond, cond)

    classical_gap = best_cond if best_cond < float('inf') else 0.0

    return GapBridgeResult(
        quantum_gap=quantum_gap,
        lorentzian_gap=lorentzian_gap,
        classical_gap=classical_gap,
        probs=probs
    )


# ──────────────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS: Certified Lorentzian Gap Surrogates")
    print("=" * 60)

    # Example: uniform distribution
    n = 4
    dim = 2**n
    uniform = np.ones(dim) / dim

    print(f"\n--- Uniform distribution on {dim} configs ---")
    mm, lb = certified_min_mass(uniform, epsilon=0.1)
    print(f"Min mass: {mm:.6f}, Certified lower (ε=0.1): {lb:.6f}")

    cert = certify_log_concavity(uniform)
    print(f"Certificate: {cert}")

    bm = boundary_mass_hamming(uniform, n)
    print(f"Boundary mass (median cut): {bm:.6f}")

    # Example: peaked distribution
    peaked = np.zeros(dim)
    peaked[0] = 0.5
    peaked[1:] = 0.5 / (dim - 1)

    print(f"\n--- Peaked distribution ---")
    mm, lb = certified_min_mass(peaked, epsilon=0.1)
    print(f"Min mass: {mm:.6f}, Certified lower (ε=0.1): {lb:.6f}")

    cert = certify_log_concavity(peaked)
    print(f"Certificate: {cert}")

    # Event ratio verification
    print(f"\n--- Event ratio verification ---")
    mu = uniform * np.exp(0.05 * np.random.randn(dim))
    mu /= mu.sum()
    result = verify_event_ratio_bound(mu, uniform, epsilon=0.2,
                                       event_indices=list(range(dim // 2)))
    print(f"Pointwise OK: {result['pointwise_ok']}")
    print(f"Event lower satisfied: {result['lower_satisfied']}")
    print(f"Event upper satisfied: {result['upper_satisfied']}")

    print("\nAll algorithms executed successfully.")
