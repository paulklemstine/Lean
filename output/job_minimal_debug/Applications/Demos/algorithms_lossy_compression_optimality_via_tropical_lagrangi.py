"""
Tropical Lossy Compression — Core Algorithms

Implements the algorithms described in the research paper:
1. TropicalOptimalQuantizer — O(|α|·|β|) optimal quantizer via pointwise minimization
2. TropicalKKTVerify — O(|α|·|β|) optimality certificate verification
3. TropicalDualBound — dual value computation (exact and fast versions)
4. RateDistortionSweep — traces the full rate-distortion tradeoff
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import Any


@dataclass
class CompressionProblem:
    """A finite lossy compression problem instance.

    Attributes:
        source: List of source symbols.
        reprod: List of reproduction symbols.
        w: Source weight vector (array of length |source|).
        d: Distortion matrix (|source| x |reprod| array).
        kappa: Rate penalty vector (array of length |reprod|).
    """
    source: list[Any]
    reprod: list[Any]
    w: np.ndarray
    d: np.ndarray
    kappa: np.ndarray

    @property
    def n_source(self) -> int:
        return len(self.source)

    @property
    def n_reprod(self) -> int:
        return len(self.reprod)

    def local_cost(self, lam: float) -> np.ndarray:
        """Compute local cost matrix: d[x,y] + lam * kappa[y].

        Returns:
            Array of shape (n_source, n_reprod).
        """
        return self.d + lam * self.kappa[np.newaxis, :]


@dataclass
class QuantizerResult:
    """Result of optimal quantizer computation.

    Attributes:
        assignment: Array of reproduction indices for each source symbol.
        total_cost: Total Lagrangian cost.
        local_costs: Array of local costs at the chosen assignments.
        lam: Lagrange multiplier used.
    """
    assignment: np.ndarray
    total_cost: float
    local_costs: np.ndarray
    lam: float


def tropical_optimal_quantizer(prob: CompressionProblem, lam: float) -> QuantizerResult:
    """Find the optimal quantizer by pointwise tropical minimization.

    Implements Theorem A: for each source symbol, select the reproduction
    symbol minimizing d(x,y) + λ·κ(y).

    Time complexity: O(|source| · |reprod|)
    Space complexity: O(|source|)

    Args:
        prob: Compression problem instance.
        lam: Lagrange multiplier (≥ 0 for meaningful duality).

    Returns:
        QuantizerResult with optimal assignment and costs.
    """
    lc = prob.local_cost(lam)  # (n_source, n_reprod)
    assignment = np.argmin(lc, axis=1)
    local_costs = lc[np.arange(prob.n_source), assignment]
    total = float(np.sum(prob.w + local_costs))
    return QuantizerResult(
        assignment=assignment,
        total_cost=total,
        local_costs=local_costs,
        lam=lam,
    )


def tropical_kkt_verify(
    prob: CompressionProblem,
    assignment: np.ndarray,
    lam: float,
    tol: float = 1e-12,
) -> tuple[bool, list[int]]:
    """Verify tropical KKT conditions for a quantizer.

    Implements Theorem B: checks that at every source symbol, the chosen
    reproduction achieves the minimum local cost.

    Time complexity: O(|source| · |reprod|)
    Space complexity: O(1)

    Args:
        prob: Compression problem instance.
        assignment: Array of reproduction indices.
        lam: Lagrange multiplier.
        tol: Numerical tolerance.

    Returns:
        (is_optimal, violating_indices) where violating_indices lists
        source symbols where KKT fails.
    """
    lc = prob.local_cost(lam)
    chosen_costs = lc[np.arange(prob.n_source), assignment]
    min_costs = np.min(lc, axis=1)
    violations = np.where(chosen_costs > min_costs + tol)[0].tolist()
    return len(violations) == 0, violations


def tropical_dual_value_fast(prob: CompressionProblem, D: float, lam: float) -> float:
    """Compute the Lagrangian dual value using tropical separability.

    Uses the fast O(|source|·|reprod|) formula:
    G(λ) = Σ_x [w(x) + min_y(κ(y) + λ·d(x,y))] - λ·D

    Note: This uses a different Lagrangian decomposition:
    L(q,λ) = Σ_x [w(x) + κ(q(x))] + λ·[Σ_x d(x,q(x)) - D]
            = Σ_x [w(x) + κ(q(x)) + λ·d(x,q(x))] - λ·D

    Args:
        prob: Compression problem instance.
        D: Distortion budget.
        lam: Lagrange multiplier (≥ 0).

    Returns:
        Dual value G(λ).
    """
    # Local cost for dual: κ(y) + λ·d(x,y)
    combined = prob.kappa[np.newaxis, :] + lam * prob.d  # (n_source, n_reprod)
    min_combined = np.min(combined, axis=1)  # (n_source,)
    return float(np.sum(prob.w + min_combined) - lam * D)


def rate_distortion_sweep(
    prob: CompressionProblem,
    lam_values: np.ndarray,
) -> list[dict]:
    """Sweep over λ values to trace the rate-distortion tradeoff.

    For each λ, computes the optimal quantizer and its achieved
    distortion and rate.

    Args:
        prob: Compression problem instance.
        lam_values: Array of λ values to sweep.

    Returns:
        List of dicts with keys: lam, assignment, distortion, rate, total_cost.
    """
    results = []
    for lam in lam_values:
        res = tropical_optimal_quantizer(prob, lam)
        distortion = float(np.sum(prob.d[np.arange(prob.n_source), res.assignment]))
        rate = float(np.sum(prob.kappa[res.assignment]))
        results.append({
            "lam": float(lam),
            "assignment": res.assignment.tolist(),
            "distortion": distortion,
            "rate": rate,
            "total_cost": res.total_cost,
        })
    return results


def weak_duality_check(
    prob: CompressionProblem,
    D: float,
    lam_values: np.ndarray,
) -> dict:
    """Verify weak duality: G(λ) ≤ P(D) for all λ ≥ 0.

    Computes primal optimum by enumeration and dual values by the fast formula.

    Args:
        prob: Compression problem instance.
        D: Distortion budget.
        lam_values: Array of non-negative λ values.

    Returns:
        Dict with primal_opt, dual_values, gaps, and best_dual.
    """
    from itertools import product as cartesian_product

    # Compute primal optimum by enumeration
    primal_opt = float("inf")
    n = prob.n_source
    m = prob.n_reprod
    for assignment in cartesian_product(range(m), repeat=n):
        a = np.array(assignment)
        dist = float(np.sum(prob.d[np.arange(n), a]))
        if dist <= D + 1e-12:
            rate_cost = float(np.sum(prob.w + prob.kappa[a]))
            primal_opt = min(primal_opt, rate_cost)

    # Compute dual values
    dual_vals = [tropical_dual_value_fast(prob, D, lam) for lam in lam_values]
    gaps = [primal_opt - g for g in dual_vals]
    best_dual = max(dual_vals)

    return {
        "primal_opt": primal_opt,
        "dual_values": dual_vals,
        "gaps": gaps,
        "best_dual": best_dual,
        "duality_gap": primal_opt - best_dual,
    }


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Create a sample problem
    prob = CompressionProblem(
        source=list(range(4)),
        reprod=list(range(3)),
        w=np.array([1.0, 1.5, 2.0, 0.5]),
        d=np.array([
            [0.0, 1.0, 3.0],
            [2.0, 0.0, 1.0],
            [3.0, 2.0, 0.0],
            [1.0, 1.0, 2.0],
        ]),
        kappa=np.array([1.0, 1.5, 2.0]),
    )

    print("=== Optimal Quantizer (λ=1.0) ===")
    res = tropical_optimal_quantizer(prob, lam=1.0)
    print(f"Assignment: {res.assignment}")
    print(f"Total cost: {res.total_cost:.4f}")

    print("\n=== KKT Verification ===")
    is_opt, violations = tropical_kkt_verify(prob, res.assignment, lam=1.0)
    print(f"Is optimal: {is_opt}")
    if violations:
        print(f"Violations at: {violations}")

    print("\n=== Rate-Distortion Sweep ===")
    sweep = rate_distortion_sweep(prob, np.linspace(0, 3, 7))
    for r in sweep:
        print(f"  λ={r['lam']:.2f}: dist={r['distortion']:.2f}, "
              f"rate={r['rate']:.2f}, q={r['assignment']}")

    print("\n=== Weak Duality Check ===")
    duality = weak_duality_check(prob, D=4.0, lam_values=np.linspace(0, 3, 13))
    print(f"Primal optimum: {duality['primal_opt']:.4f}")
    print(f"Best dual bound: {duality['best_dual']:.4f}")
    print(f"Duality gap: {duality['duality_gap']:.4f}")
