#!/usr/bin/env python3
"""
Dynamical Proof Complexity: Algorithms

Implements the core algorithms from the research:
1. Stabilization depth computation
2. Idempotence testing
3. Hardness level classification
4. Evidence accumulation simulation
5. Oracle iteration complexity analysis
"""

import numpy as np
from typing import Callable, List, Tuple, Optional, TypeVar, Generic
from dataclasses import dataclass


T = TypeVar('T')


# ============================================================
# Algorithm 1: Stabilization Depth Computation
# ============================================================
def compute_stabilization_depth(
    f: Callable[[np.ndarray], np.ndarray],
    x: np.ndarray,
    max_depth: int = 1000,
    atol: float = 1e-10
) -> Tuple[int, List[np.ndarray]]:
    """
    Compute the stabilization depth of f starting from x.
    
    Returns the smallest k such that f^[k+1](x) ≈ f^[k](x),
    along with the full trajectory.
    
    Time complexity: O(max_depth * cost(f))
    Space complexity: O(max_depth * dim(x))
    
    Args:
        f: The update function
        x: Initial state
        max_depth: Maximum depth to search
        atol: Absolute tolerance for equality check
    
    Returns:
        (depth, trajectory) where trajectory[i] = f^[i](x)
    
    Example:
        >>> f = lambda x: np.abs(x)
        >>> depth, traj = compute_stabilization_depth(f, np.array([-3.0, 2.0]))
        >>> depth  # 1, since ||-3, 2|| = |3, 2| and ||3, 2|| = |3, 2|
        1
    """
    trajectory = [x.copy()]
    current = x.copy()
    
    for k in range(max_depth):
        next_val = f(current)
        trajectory.append(next_val.copy())
        
        if np.allclose(next_val, current, atol=atol):
            return k, trajectory
        
        current = next_val
    
    return max_depth, trajectory


# ============================================================
# Algorithm 2: Idempotence Testing
# ============================================================
def test_idempotence(
    f: Callable[[np.ndarray], np.ndarray],
    domain_samples: List[np.ndarray],
    atol: float = 1e-10
) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test whether f is idempotent (f∘f = f) on sampled points.
    
    Returns (is_idempotent, counterexample) where counterexample
    is None if idempotent, or a point x where f(f(x)) ≠ f(x).
    
    Time complexity: O(|samples| * cost(f))
    
    Args:
        f: The function to test
        domain_samples: Points to test on
        atol: Tolerance for equality
    
    Returns:
        (True, None) if idempotent on all samples,
        (False, counterexample) otherwise
    
    Example:
        >>> f = lambda x: np.floor(x)
        >>> is_idem, cx = test_idempotence(f, [np.array([1.5, 2.7])])
        >>> is_idem
        True
    """
    for x in domain_samples:
        fx = f(x)
        ffx = f(fx)
        if not np.allclose(ffx, fx, atol=atol):
            return False, x
    return True, None


# ============================================================
# Algorithm 3: Hardness Level Classification
# ============================================================
@dataclass
class HardnessProfile:
    """Classification of a function's dynamical complexity."""
    max_depth: int
    avg_depth: float
    is_idempotent: bool
    nontrivial_depths: List[int]
    classification: str  # "trivial", "idempotent", "bounded", "deep"


def classify_hardness(
    f: Callable[[np.ndarray], np.ndarray],
    domain_samples: List[np.ndarray],
    max_depth: int = 100
) -> HardnessProfile:
    """
    Classify the hardness level of a function based on stabilization behavior.
    
    Pseudocode:
        1. For each sample point x:
           a. Compute stabilization depth d(x)
           b. Record if d(x) > 0 (nontrivial)
        2. Compute max and average depth
        3. Test idempotence
        4. Classify:
           - "trivial" if max_depth = 0 (identity-like)
           - "idempotent" if max_depth = 1 and idempotent
           - "bounded" if max_depth is small (≤ 10)
           - "deep" if max_depth is large
    
    Time: O(|samples| * max_depth * cost(f))
    
    Example:
        >>> f = lambda x: np.abs(x)
        >>> profile = classify_hardness(f, [np.array([-1.0]), np.array([2.0])])
        >>> profile.classification
        'idempotent'
    """
    depths = []
    nontrivial = []
    
    for x in domain_samples:
        depth, _ = compute_stabilization_depth(f, x, max_depth=max_depth)
        depths.append(depth)
        if depth > 0:
            nontrivial.append(depth)
    
    max_d = max(depths) if depths else 0
    avg_d = np.mean(depths) if depths else 0.0
    
    is_idem, _ = test_idempotence(f, domain_samples)
    
    if max_d == 0:
        classification = "trivial"
    elif max_d <= 1 and is_idem:
        classification = "idempotent"
    elif max_d <= 10:
        classification = "bounded"
    else:
        classification = "deep"
    
    return HardnessProfile(
        max_depth=max_d,
        avg_depth=float(avg_d),
        is_idempotent=is_idem,
        nontrivial_depths=nontrivial,
        classification=classification
    )


# ============================================================
# Algorithm 4: Evidence Accumulation Simulation
# ============================================================
@dataclass
class EvidenceResult:
    """Result of evidence accumulation simulation."""
    evidence_scores: List[float]
    upper_envelope: float
    regret_bound: float
    belief_trajectory: List[np.ndarray]


def simulate_evidence_accumulation(
    n_hypotheses: int,
    initial_belief: np.ndarray,
    likelihood_sequence: List[np.ndarray],
    T: Optional[int] = None
) -> EvidenceResult:
    """
    Simulate Bayesian evidence accumulation and compute bounds.
    
    Algorithm:
        1. Initialize belief state b = initial_belief
        2. For each round t:
           a. Receive likelihoods l_t
           b. Compute evidence_t = Σ b_i * l_t(i)
           c. Update belief: b_i ← b_i * l_t(i) / evidence_t
        3. Compute upper envelope and regret bound
    
    Time: O(T * n_hypotheses)
    Space: O(T * n_hypotheses)
    
    Args:
        n_hypotheses: Number of competing hypotheses
        initial_belief: Prior probability distribution
        likelihood_sequence: List of likelihood vectors, one per round
        T: Number of rounds (defaults to len(likelihood_sequence))
    
    Returns:
        EvidenceResult with scores, bounds, and trajectory
    """
    if T is None:
        T = len(likelihood_sequence)
    
    belief = initial_belief.copy()
    evidence_scores = []
    belief_trajectory = [belief.copy()]
    
    for t in range(min(T, len(likelihood_sequence))):
        likelihoods = likelihood_sequence[t]
        
        # Evidence score
        evidence = np.dot(belief, likelihoods)
        evidence_scores.append(evidence)
        
        # Bayesian update
        if evidence > 0:
            belief = belief * likelihoods / evidence
        
        belief_trajectory.append(belief.copy())
    
    # Upper envelope: max likelihood across all rounds and hypotheses
    all_likelihoods = np.array(likelihood_sequence[:T])
    upper_envelope = float(np.max(all_likelihoods))
    
    # Regret bound
    regret_bound = float(np.sqrt(T * np.log(n_hypotheses) / 2))
    
    return EvidenceResult(
        evidence_scores=evidence_scores,
        upper_envelope=upper_envelope,
        regret_bound=regret_bound,
        belief_trajectory=belief_trajectory
    )


# ============================================================
# Algorithm 5: Oracle Iteration Complexity Analysis
# ============================================================
@dataclass
class OracleAnalysis:
    """Complete analysis of oracle iteration dynamics."""
    stabilization_depths: List[int]
    hardness_profile: HardnessProfile
    collapse_detected: bool
    separation_witness: Optional[np.ndarray]


def analyze_oracle_dynamics(
    f: Callable[[np.ndarray], np.ndarray],
    domain_samples: List[np.ndarray],
    max_depth: int = 100
) -> OracleAnalysis:
    """
    Complete analysis of oracle iteration dynamics.
    
    Algorithm:
        1. Compute stabilization depth for each sample
        2. Classify hardness
        3. Detect collapse (all depths ≤ 1)
        4. Find separation witness (point with depth > 1)
    
    Time: O(|samples| * max_depth * cost(f))
    
    Args:
        f: Oracle update function
        domain_samples: Points to analyze
        max_depth: Maximum iteration depth
    
    Returns:
        OracleAnalysis with complete dynamical characterization
    """
    depths = []
    separation_witness = None
    
    for x in domain_samples:
        depth, _ = compute_stabilization_depth(f, x, max_depth)
        depths.append(depth)
        if depth > 1 and separation_witness is None:
            separation_witness = x
    
    profile = classify_hardness(f, domain_samples, max_depth)
    collapse = all(d <= 1 for d in depths)
    
    return OracleAnalysis(
        stabilization_depths=depths,
        hardness_profile=profile,
        collapse_detected=collapse,
        separation_witness=separation_witness
    )


# ============================================================
# Main: Run all algorithms with example data
# ============================================================
if __name__ == "__main__":
    print("Dynamical Proof Complexity: Algorithm Demonstrations")
    print("=" * 60)
    
    # Generate test data
    np.random.seed(42)
    dim = 4
    samples = [np.random.randn(dim) for _ in range(20)]
    
    # Test Algorithm 1: Stabilization depth
    print("\n--- Algorithm 1: Stabilization Depth ---")
    f_project = lambda x: np.array([x[0], 0, 0, 0])
    depth, traj = compute_stabilization_depth(f_project, np.array([1.0, 2.0, 3.0, 4.0]))
    print(f"Projection: depth = {depth}")
    
    f_rotate = lambda x: np.roll(x, 1)
    depth, traj = compute_stabilization_depth(f_rotate, np.array([1.0, 0.0, 0.0, 0.0]), max_depth=10)
    print(f"Rotation: depth = {depth}")
    
    # Test Algorithm 2: Idempotence
    print("\n--- Algorithm 2: Idempotence Testing ---")
    is_idem, cx = test_idempotence(f_project, samples)
    print(f"Projection idempotent: {is_idem}")
    is_idem, cx = test_idempotence(f_rotate, samples)
    print(f"Rotation idempotent: {is_idem}, counterexample: {cx}")
    
    # Test Algorithm 3: Hardness classification
    print("\n--- Algorithm 3: Hardness Classification ---")
    for name, f in [("Projection", f_project), ("Rotation", f_rotate),
                     ("Identity", lambda x: x.copy()), ("Abs", np.abs)]:
        profile = classify_hardness(f, samples)
        print(f"{name}: {profile.classification} (max_depth={profile.max_depth}, "
              f"avg={profile.avg_depth:.1f})")
    
    # Test Algorithm 4: Evidence accumulation
    print("\n--- Algorithm 4: Evidence Accumulation ---")
    n_hyp = 5
    belief = np.ones(n_hyp) / n_hyp
    likelihoods = [np.random.dirichlet(np.ones(n_hyp)) * 2 for _ in range(50)]
    result = simulate_evidence_accumulation(n_hyp, belief, likelihoods)
    print(f"Final evidence: {result.evidence_scores[-1]:.4f}")
    print(f"Upper envelope: {result.upper_envelope:.4f}")
    print(f"Regret bound: {result.regret_bound:.4f}")
    print(f"Evidence ≤ envelope: {all(e <= result.upper_envelope + 1e-10 for e in result.evidence_scores)}")
    
    # Test Algorithm 5: Oracle analysis
    print("\n--- Algorithm 5: Oracle Analysis ---")
    analysis = analyze_oracle_dynamics(f_project, samples)
    print(f"Collapse detected: {analysis.collapse_detected}")
    print(f"Classification: {analysis.hardness_profile.classification}")
    
    analysis = analyze_oracle_dynamics(f_rotate, samples)
    print(f"Rotation collapse: {analysis.collapse_detected}")
    print(f"Separation witness exists: {analysis.separation_witness is not None}")
    
    print("\n✓ All algorithms executed successfully")
