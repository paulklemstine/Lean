#!/usr/bin/env python3
"""
Algorithms for Variable Contraction Rate Renormalization

Implements the parameterized stability checker and budget evaluator
described in the formal theory.
"""

from typing import List, Tuple, Optional
import math


def contraction_factor(alpha: float) -> float:
    """
    Compute the contraction factor r = 1 - 1/α.

    Args:
        alpha: Contraction parameter, must be > 1.

    Returns:
        The contraction factor in (0, 1).

    Raises:
        ValueError: If alpha <= 1.

    >>> contraction_factor(2.0)
    0.5
    >>> contraction_factor(3.0)
    0.6666666666666667
    """
    if alpha <= 1.0:
        raise ValueError(f"alpha must be > 1, got {alpha}")
    return 1.0 - 1.0 / alpha


def renorm_const(C: float, alpha: float, m: int) -> float:
    """
    Renormalized Diophantine constant after m steps.

    C_m = C · (1 - 1/α)^m

    Args:
        C: Initial Diophantine constant, must be > 0.
        alpha: Contraction parameter, must be > 1.
        m: Number of renormalization steps, must be >= 0.

    Returns:
        The renormalized constant C_m.

    >>> renorm_const(1.0, 2.0, 3)
    0.125
    """
    return C * contraction_factor(alpha) ** m


def renorm_budget(C: float, K: float, alpha: float) -> float:
    """
    Total perturbation budget for infinite cascade.

    Budget = C · α / (K · (α - 1))

    For the normalized scheme where per-step allowance is C_j/(α·K),
    the total budget is C/K (independent of α).

    Args:
        C: Diophantine constant.
        K: Frequency scale parameter.
        alpha: Contraction parameter.

    Returns:
        The total budget.

    >>> renorm_budget(1.0, 1.0, 2.0)
    2.0
    """
    return C * alpha / (K * (alpha - 1.0))


def normalized_budget(C: float, K: float) -> float:
    """
    Normalized total perturbation budget (independent of α).

    In the normalized scheme, ∑ C·(1-1/α)^j / (α·K) = C/K.

    >>> normalized_budget(2.0, 3.0)
    0.6666666666666666
    """
    return C / K


def partial_budget(C: float, K: float, alpha: float, m: int) -> float:
    """
    Partial perturbation budget for m steps.

    ∑_{j=0}^{m-1} C·(1-1/α)^j / (α·K)

    Always ≤ C/K by the budget theorem.

    Args:
        C, K, alpha: Parameters as above.
        m: Number of steps.

    Returns:
        Partial budget sum.

    >>> partial_budget(1.0, 1.0, 2.0, 10)  # doctest: +ELLIPSIS
    0.999...
    """
    r = contraction_factor(alpha)
    return sum(C * r**j / (alpha * K) for j in range(m))


def lattice_inner(k: List[int], omega: List[float]) -> float:
    """
    Compute lattice inner product ⟨k, ω⟩ = Σ k_i · ω_i.

    >>> lattice_inner([1, -1], [0.5, 0.3])
    0.2
    """
    return sum(ki * oi for ki, oi in zip(k, omega))


def l1_norm(k: List[int]) -> int:
    """L1 norm of integer vector."""
    return sum(abs(ki) for ki in k)


def check_diophantine(K: int, C: float, omega: List[float],
                      search_depth: int = 1000) -> Tuple[bool, float]:
    """
    Numerically check the Diophantine condition.

    Tests |⟨k, ω⟩| ≥ C for random integer vectors k with 0 < ‖k‖₁ ≤ K.

    Args:
        K: Maximum L1 norm of test vectors.
        C: Diophantine constant threshold.
        omega: Frequency vector.
        search_depth: Number of random test vectors.

    Returns:
        (passed, min_value): Whether condition held, and the minimum observed.

    Time complexity: O(search_depth · n) where n = len(omega).
    Space complexity: O(n).
    """
    import random
    n = len(omega)
    min_val = float('inf')

    for _ in range(search_depth):
        k = [random.randint(-K, K) for _ in range(n)]
        if l1_norm(k) == 0 or l1_norm(k) > K:
            continue
        val = abs(lattice_inner(k, omega))
        min_val = min(min_val, val)

    # Also check canonical basis vectors
    for i in range(n):
        for sign in [1, -1]:
            k = [0] * n
            k[i] = sign
            val = abs(lattice_inner(k, omega))
            min_val = min(min_val, val)

    return min_val >= C, min_val


def stability_checker(
    omega: List[float],
    K: int,
    C: float,
    alpha: float,
    perturbations: List[List[float]],
    search_depth: int = 500
) -> dict:
    """
    Parameterized stability checker.

    Given:
      - frequency vector ω
      - Diophantine parameters K, C
      - contraction parameter α > 1
      - sequence of perturbation vectors δ_0, δ_1, ...

    Checks:
      1. Coordinatewise perturbation bounds |δ_j_i| < C_j/(α·K)
      2. Predicted lower bound C·(1-1/α)^m
      3. Observed resonance minima

    Args:
        omega: Initial frequency vector.
        K: L1 norm bound.
        C: Initial Diophantine constant.
        alpha: Contraction parameter > 1.
        perturbations: List of perturbation vectors.
        search_depth: Number of random test vectors.

    Returns:
        Dictionary with analysis results.

    Time complexity: O(m · search_depth · n).
    """
    if alpha <= 1.0:
        raise ValueError("alpha must be > 1")

    n = len(omega)
    m = len(perturbations)
    r = contraction_factor(alpha)

    results = {
        'alpha': alpha,
        'contraction_factor': r,
        'n': n,
        'm': m,
        'steps': [],
        'bounds_satisfied': True,
        'prediction_verified': True,
    }

    omega_current = list(omega)

    for j in range(m):
        C_j = C * r ** j
        bound = C_j / (alpha * K)
        delta = perturbations[j]

        # Check coordinatewise bounds
        max_delta = max(abs(d) for d in delta)
        bound_ok = max_delta < bound

        # Check observed Diophantine constant
        predicted = C * r ** j
        _, observed = check_diophantine(K, predicted, omega_current, search_depth)

        step_info = {
            'step': j,
            'predicted_constant': predicted,
            'observed_min': observed,
            'perturbation_bound': bound,
            'max_perturbation': max_delta,
            'bound_satisfied': bound_ok,
            'prediction_ok': observed >= predicted * 0.99,
        }
        results['steps'].append(step_info)

        if not bound_ok:
            results['bounds_satisfied'] = False
        if not step_info['prediction_ok']:
            results['prediction_verified'] = False

        # Apply perturbation
        omega_current = [oi + di for oi, di in zip(omega_current, delta)]

    # Final check
    predicted_final = C * r ** m
    _, observed_final = check_diophantine(K, predicted_final, omega_current, search_depth)
    results['final_predicted'] = predicted_final
    results['final_observed'] = observed_final
    results['final_ok'] = observed_final >= predicted_final * 0.99
    results['total_budget_used'] = sum(
        max(abs(d) for d in p) for p in perturbations
    )
    results['total_budget_limit'] = normalized_budget(C, K)

    return results


def optimal_alpha_search(
    C: float, K: float, m: int,
    epsilon: float,
    alpha_range: Tuple[float, float] = (1.01, 100.0),
    num_samples: int = 1000
) -> Tuple[float, float]:
    """
    Search for optimal α given a fixed perturbation size ε.

    For fixed ε, the constraint is ε < C·(1-1/α)^j/(α·K) for all j < m.
    The binding constraint is at j = m-1: ε < C·(1-1/α)^{m-1}/(α·K).
    The final constant is C·(1-1/α)^m.

    We maximize the final constant subject to the perturbation feasibility.

    Args:
        C: Diophantine constant.
        K: Frequency scale.
        m: Number of steps.
        epsilon: Fixed perturbation size.
        alpha_range: Search interval for α.
        num_samples: Number of samples.

    Returns:
        (best_alpha, best_final_constant).

    Time complexity: O(num_samples · m).
    """
    best_alpha = None
    best_final = -1.0

    for i in range(num_samples):
        alpha = alpha_range[0] + (alpha_range[1] - alpha_range[0]) * i / num_samples
        r = contraction_factor(alpha)

        # Check feasibility at each step
        feasible = True
        for j in range(m):
            bound = C * r**j / (alpha * K)
            if epsilon >= bound:
                feasible = False
                break

        if feasible:
            final = C * r**m
            if final > best_final:
                best_final = final
                best_alpha = alpha

    return best_alpha, best_final


if __name__ == "__main__":
    print("=== Stability Checker Example ===")
    import random
    random.seed(42)

    omega = [0.7, 0.3, 0.5]
    K = 3
    C = 0.2
    alpha = 3.0
    r = contraction_factor(alpha)

    # Generate small perturbations
    perturbations = []
    for j in range(5):
        bound = C * r**j / (alpha * K) * 0.9
        delta = [random.uniform(-bound, bound) for _ in range(3)]
        perturbations.append(delta)

    result = stability_checker(omega, K, C, alpha, perturbations)
    print(f"α = {result['alpha']}, r = {result['contraction_factor']:.4f}")
    print(f"Bounds satisfied: {result['bounds_satisfied']}")
    print(f"Prediction verified: {result['prediction_verified']}")
    for s in result['steps']:
        print(f"  Step {s['step']}: predicted={s['predicted_constant']:.6f}, "
              f"observed={s['observed_min']:.6f}, ok={s['prediction_ok']}")
    print(f"Final: predicted={result['final_predicted']:.6f}, "
          f"observed={result['final_observed']:.6f}")

    print("\n=== Optimal α Search ===")
    best_a, best_f = optimal_alpha_search(1.0, 1.0, 10, 0.01)
    print(f"Best α = {best_a:.2f}, final constant = {best_f:.6f}")
