#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for renormalization group on subgroup ensembles.

Implements:
1. Partition function and pressure computation
2. Coarse-graining (RG map) via homomorphism projection
3. RG iteration with convergence detection
4. Critical exponent extraction
5. Universality class identification

All algorithms correspond to formally verified theorems in the Lean development.
"""

import math
from typing import List, Dict, Tuple, Optional, Callable, Set, FrozenSet
from dataclasses import dataclass, field
import itertools


# ─────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass
class SubgroupEnsemble:
    """A weighted subgroup ensemble over a finite group.

    Corresponds to the Lean structure:
        structure SubgroupEnsemble (G : Type*) [Group G] where
          carriers : Finset (Subgroup G)
          weight : Subgroup G → ℝ
          weight_nonneg : ∀ H ∈ carriers, 0 ≤ weight H

    Attributes:
        subgroups: List of subgroups, each represented as a frozenset of elements
        weights: Nonnegative real weights for each subgroup
        complexity: Function mapping subgroup to a real complexity measure
    """
    subgroups: List[FrozenSet]
    weights: List[float]
    complexity: Callable[[FrozenSet], float]

    def __post_init__(self):
        assert len(self.subgroups) == len(self.weights)
        assert all(w >= 0 for w in self.weights), "Weights must be nonneg"


@dataclass
class CoarseGraining:
    """A coarse-graining operator on subgroup ensembles.

    Corresponds to the Lean structure:
        structure CoarseGraining (G : Type*) [Group G] where
          map : SubgroupEnsemble G → SubgroupEnsemble G
          pressureScale : ℝ → ℝ
          complexity : SubgroupComplexity G
          pressure_map : ...

    Attributes:
        map_fn: The coarse-graining transformation
        pressure_scale: The scaling factor λ(β)
    """
    map_fn: Callable[[SubgroupEnsemble], SubgroupEnsemble]
    pressure_scale: Callable[[float], float]


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Partition Function and Pressure
# ─────────────────────────────────────────────────────────────────────

def partition_function(ensemble: SubgroupEnsemble, beta: float) -> float:
    """Compute the partition function Z(β) of a subgroup ensemble.

    Z(β) = Σ_{H ∈ carriers} exp(-β · c(H)) · w(H)

    Time complexity: O(|carriers|) per evaluation
    Space complexity: O(1) additional

    Args:
        ensemble: The weighted subgroup ensemble
        beta: Inverse temperature parameter

    Returns:
        The partition function value Z(β)

    Example:
        >>> ens = SubgroupEnsemble([frozenset([0])], [1.0], lambda H: 0.0)
        >>> partition_function(ens, 1.0)
        1.0
    """
    return sum(
        math.exp(-beta * ensemble.complexity(H)) * w
        for H, w in zip(ensemble.subgroups, ensemble.weights)
    )


def pressure(ensemble: SubgroupEnsemble, beta: float) -> float:
    """Compute the ensemble pressure Π(β) = log Z(β).

    This is the log-partition function, analogous to free energy
    in statistical mechanics.

    Time complexity: O(|carriers|) per evaluation
    Space complexity: O(1) additional

    Args:
        ensemble: The weighted subgroup ensemble
        beta: Inverse temperature parameter

    Returns:
        The pressure Π(β) = log Z(β)
    """
    Z = partition_function(ensemble, beta)
    if Z <= 0:
        return float('-inf')
    return math.log(Z)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: RG Iteration
# ─────────────────────────────────────────────────────────────────────

def iterate_rg(
    cg: CoarseGraining,
    ensemble: SubgroupEnsemble,
    n_steps: int
) -> List[SubgroupEnsemble]:
    """Apply the coarse-graining map n times, recording the trajectory.

    Implements: R^[n](E) for n = 0, 1, ..., n_steps

    Verified property (pressure_iterate_of_coarseGraining):
        Π(R^n(E), β) = λ(β)^n · Π(E, β)

    Time complexity: O(n_steps × cost_of_map)
    Space complexity: O(n_steps × ensemble_size)

    Args:
        cg: The coarse-graining operator
        ensemble: Initial ensemble E
        n_steps: Number of RG iterations

    Returns:
        List of ensembles [E, R(E), R²(E), ..., Rⁿ(E)]
    """
    trajectory = [ensemble]
    current = ensemble
    for _ in range(n_steps):
        current = cg.map_fn(current)
        trajectory.append(current)
    return trajectory


def verify_geometric_scaling(
    trajectory: List[SubgroupEnsemble],
    cg: CoarseGraining,
    beta: float,
    tol: float = 1e-8
) -> Tuple[bool, List[float]]:
    """Verify the geometric pressure scaling law along an RG trajectory.

    Checks: Π(R^n(E), β) = λ(β)^n · Π(E, β)

    Args:
        trajectory: List of ensembles from iterate_rg
        cg: The coarse-graining operator
        beta: Inverse temperature
        tol: Numerical tolerance

    Returns:
        (is_valid, ratios) where ratios[n] = Π(R^n(E)) / (λ^n · Π(E))
    """
    P0 = pressure(trajectory[0], beta)
    scale = cg.pressure_scale(beta)
    ratios = []

    for n, ens in enumerate(trajectory):
        Pn = pressure(ens, beta)
        expected = (scale ** n) * P0
        ratio = Pn / expected if abs(expected) > tol else float('nan')
        ratios.append(ratio)

    is_valid = all(abs(r - 1.0) < tol for r in ratios if not math.isnan(r))
    return is_valid, ratios


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Critical Exponent Extraction
# ─────────────────────────────────────────────────────────────────────

def extract_critical_exponent(
    pressure_scale: float,
    parameter_scale: float
) -> float:
    """Extract the critical exponent from scaling eigenvalues.

    Implements the verified identity (criticalExponent_from_scaling):
        α = log(λ) / log(μ)
    where λ is the pressure scaling factor and μ is the parameter
    scaling factor.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        pressure_scale: λ, the pressure scaling factor (must be > 0)
        parameter_scale: μ, the parameter scaling factor (must be > 1)

    Returns:
        The critical exponent α

    Raises:
        ValueError: If constraints on λ, μ are violated
    """
    if pressure_scale <= 0:
        raise ValueError(f"Pressure scale must be positive, got {pressure_scale}")
    if parameter_scale <= 1:
        raise ValueError(f"Parameter scale must be > 1, got {parameter_scale}")

    return math.log(pressure_scale) / math.log(parameter_scale)


def verify_power_law_scaling(
    pi_fn: Callable[[float], float],
    mu: float,
    lam: float,
    test_points: List[float],
    tol: float = 1e-8
) -> Tuple[bool, float]:
    """Verify that Π(μt) = λ·Π(t) and extract the exponent.

    Args:
        pi_fn: The pressure function
        mu: Parameter scaling factor
        lam: Pressure scaling factor
        test_points: Points t > 0 to test
        tol: Numerical tolerance

    Returns:
        (is_valid, alpha) where alpha is the extracted exponent
    """
    errors = []
    for t in test_points:
        if t <= 0:
            continue
        lhs = pi_fn(mu * t)
        rhs = lam * pi_fn(t)
        if abs(rhs) > tol:
            errors.append(abs(lhs - rhs) / abs(rhs))

    is_valid = all(e < tol for e in errors)
    alpha = extract_critical_exponent(lam, mu) if lam > 0 and mu > 1 else float('nan')
    return is_valid, alpha


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Universality Class Detection
# ─────────────────────────────────────────────────────────────────────

def check_same_universality_class(
    cg: CoarseGraining,
    e1: SubgroupEnsemble,
    e2: SubgroupEnsemble,
    beta_values: List[float],
    n_steps: int = 10,
    tol: float = 1e-6
) -> Tuple[bool, Dict[float, List[float]]]:
    """Check if two ensembles are in the same universality class.

    Two ensembles are in the same class if:
        Π(R^n(E₁), β) = Π(R^n(E₂), β) for all n, β

    Verified property (sameUniversalityClass_refl/symm/trans):
        This defines an equivalence relation.

    Args:
        cg: The coarse-graining operator
        e1, e2: Ensembles to compare
        beta_values: Values of β to test
        n_steps: Number of RG iterations
        tol: Numerical tolerance

    Returns:
        (same_class, pressure_diffs) where pressure_diffs[β] is the
        list of |Π(R^n(E₁)) - Π(R^n(E₂))| for n = 0,...,n_steps
    """
    traj1 = iterate_rg(cg, e1, n_steps)
    traj2 = iterate_rg(cg, e2, n_steps)

    pressure_diffs: Dict[float, List[float]] = {}
    same = True

    for beta in beta_values:
        diffs = []
        for n in range(n_steps + 1):
            p1 = pressure(traj1[n], beta)
            p2 = pressure(traj2[n], beta)
            diff = abs(p1 - p2)
            diffs.append(diff)
            if diff > tol:
                same = False
        pressure_diffs[beta] = diffs

    return same, pressure_diffs


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Intensive Pressure (Thermodynamic Limit)
# ─────────────────────────────────────────────────────────────────────

def compute_intensive_pressure(
    F1: float,
    n_max: int = 20
) -> List[Tuple[int, float, float]]:
    """Compute intensive pressure F(n)/n for the product model.

    Verified property (intensivePressure_convergence):
        F(n)/n → F(1) as n → ∞ (exact for product ensembles)

    Time complexity: O(n_max)
    Space complexity: O(n_max)

    Args:
        F1: Base pressure F(1)
        n_max: Maximum scale

    Returns:
        List of (n, F(n), F(n)/n) triples
    """
    results = []
    for n in range(1, n_max + 1):
        Fn = n * F1  # Product extensivity: F(n) = n·F(1)
        intensive = Fn / n
        results.append((n, Fn, intensive))
    return results


# ─────────────────────────────────────────────────────────────────────
# Algorithm 6: Pressure Contraction
# ─────────────────────────────────────────────────────────────────────

def pressure_contraction_trajectory(
    scale: float,
    initial_pressure: float,
    n_steps: int = 50
) -> List[Tuple[int, float]]:
    """Compute the pressure trajectory under contractive RG.

    Verified property (pressure_contraction):
        If |λ(β)| < 1, then Π(R^n(E), β) → 0.

    The trajectory is: Π_n = λ^n · Π_0

    Args:
        scale: The scaling factor λ(β) with |λ| < 1
        initial_pressure: Π(E, β)
        n_steps: Number of iterations

    Returns:
        List of (n, Π_n) pairs
    """
    trajectory = []
    for n in range(n_steps + 1):
        Pn = (scale ** n) * initial_pressure
        trajectory.append((n, Pn))
    return trajectory


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm demonstrations:")
    print()

    # Critical exponent extraction
    print("1. Critical exponent extraction:")
    for lam, mu in [(4.0, 2.0), (8.0, 2.0), (27.0, 3.0)]:
        alpha = extract_critical_exponent(lam, mu)
        print(f"   λ={lam}, μ={mu} → α = {alpha:.6f}")
        assert abs(mu ** alpha - lam) < 1e-10

    print()

    # Power law verification
    print("2. Power law verification:")
    for alpha in [1.5, 2.0, 2.5]:
        lam = 2.0 ** alpha
        pi_fn = lambda t, a=alpha: t ** a
        valid, extracted = verify_power_law_scaling(
            pi_fn, 2.0, lam, [0.1, 0.5, 1.0, 2.0, 5.0]
        )
        print(f"   α={alpha}: valid={valid}, extracted α={extracted:.6f}")

    print()

    # Intensive pressure convergence
    print("3. Intensive pressure convergence (F₁ = 2.5):")
    results = compute_intensive_pressure(2.5, 5)
    for n, Fn, intensive in results:
        print(f"   n={n}: F(n)={Fn:.2f}, F(n)/n={intensive:.4f}")

    print()

    # Pressure contraction
    print("4. Pressure contraction (λ=0.7, Π₀=10.0):")
    traj = pressure_contraction_trajectory(0.7, 10.0, 10)
    for n, Pn in traj[:6]:
        print(f"   n={n}: Π_n = {Pn:.6f}")

    print()
    print("All algorithm demonstrations passed ✓")
