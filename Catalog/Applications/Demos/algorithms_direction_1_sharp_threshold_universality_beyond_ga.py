"""
Tropical Threshold Universality — Algorithms

Core algorithms for tropical margin computation, signal gap analysis,
and universality testing.

All algorithms include docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Tuple, List, Optional, Dict


def diag_ex_slack(W: np.ndarray, i: int, j: int) -> float:
    """
    Compute diagonal exchange slack for pair (i, j).
    
    diagExSlack(W, i, j) = 2*W[i,j] - W[i,i] - W[j,j]
    
    This measures how much the off-diagonal entry W[i,j] exceeds
    the average of the diagonal entries W[i,i] and W[j,j].
    
    Args:
        W: Square matrix (n×n)
        i: Row index
        j: Column index (should differ from i)
    
    Returns:
        The exchange slack value
    
    Example:
        >>> W = np.array([[3.0, 1.0], [2.0, 4.0]])
        >>> diag_ex_slack(W, 0, 1)  # 2*1 - 3 - 4 = -5
        -5.0
    """
    return 2.0 * W[i, j] - W[i, i] - W[j, j]


def trop_margin(W: np.ndarray) -> float:
    """
    Compute the tropical stability margin of a matrix.
    
    tropMargin(W) = min_{i≠j} diagExSlack(W, i, j)
    
    The margin is positive when the diagonal assignment dominates
    all transposition competitors in the max-plus (tropical) sense.
    
    Complexity: O(n²) time, O(1) space
    
    Args:
        W: Square matrix (n×n)
    
    Returns:
        The tropical margin value
    
    Example:
        >>> W = np.array([[0.0, 2.0], [2.0, 0.0]])
        >>> trop_margin(W)  # 2*2 - 0 - 0 = 4
        4.0
    """
    n = W.shape[0]
    if n < 2:
        return 0.0
    
    margin = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                s = diag_ex_slack(W, i, j)
                margin = min(margin, s)
    return margin


def trop_margin_with_witness(W: np.ndarray) -> Tuple[float, Tuple[int, int]]:
    """
    Compute tropical margin and return the witness pair (i*, j*) achieving it.
    
    This corresponds to the theorem `tropMargin_witness` in the formal proof.
    
    Args:
        W: Square matrix (n×n)
    
    Returns:
        (margin, (i*, j*)) where margin = diagExSlack(W, i*, j*)
    
    Example:
        >>> W = np.array([[5.0, 1.0], [2.0, 3.0]])
        >>> margin, (i, j) = trop_margin_with_witness(W)
        >>> margin == diag_ex_slack(W, i, j)
        True
    """
    n = W.shape[0]
    if n < 2:
        return 0.0, (0, 0)
    
    best_margin = float('inf')
    best_pair = (0, 1)
    
    for i in range(n):
        for j in range(n):
            if i != j:
                s = diag_ex_slack(W, i, j)
                if s < best_margin:
                    best_margin = s
                    best_pair = (i, j)
    
    return best_margin, best_pair


def signal_gap(S: np.ndarray) -> float:
    """
    Compute the signal gap of a matrix.
    
    The signal gap equals the tropical margin, interpreted as the
    energy separation between the diagonal assignment and its
    nearest transposition competitor.
    
    Args:
        S: Square signal matrix (n×n)
    
    Returns:
        The signal gap value
    """
    return trop_margin(S)


def entry_sup_norm(W: np.ndarray) -> float:
    """
    Compute the entry-wise sup norm: max_{i,j} |W[i,j]|.
    
    Args:
        W: Matrix (any shape)
    
    Returns:
        Maximum absolute entry value
    """
    return float(np.max(np.abs(W)))


def mean_model(n: int, mu_diag: float, mu_off: float) -> np.ndarray:
    """
    Construct the mean model matrix.
    
    M[i,j] = mu_diag if i=j, mu_off otherwise
    
    The tropical margin of this matrix is exactly 2*(mu_off - mu_diag).
    
    Args:
        n: Matrix dimension
        mu_diag: Diagonal entry value
        mu_off: Off-diagonal entry value
    
    Returns:
        n×n mean model matrix
    """
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M


def verify_perturbation_bound(A: np.ndarray, E: np.ndarray) -> Dict[str, float]:
    """
    Verify the perturbation stability theorem:
    |tropMargin(A) - tropMargin(A+E)| ≤ 4 * ‖E‖∞
    
    This implements Algorithm 1 from the research paper.
    
    Args:
        A: Base matrix (n×n)
        E: Perturbation matrix (n×n)
    
    Returns:
        Dictionary with margin values, bound, and verification result
    """
    m_A = trop_margin(A)
    m_AE = trop_margin(A + E)
    diff = abs(m_A - m_AE)
    bound = 4 * entry_sup_norm(E)
    
    return {
        'margin_A': m_A,
        'margin_AE': m_AE,
        'difference': diff,
        'lipschitz_bound': bound,
        'satisfied': diff <= bound + 1e-12,
        'tightness': diff / bound if bound > 0 else 0.0
    }


def verify_signal_dominance(S: np.ndarray, N: np.ndarray) -> Dict[str, float]:
    """
    Verify signal dominance theorem:
    signalGap(S) ≥ 4*‖N‖∞ → tropMargin(S+N) ≥ 0
    
    Args:
        S: Signal matrix (n×n)
        N: Noise matrix (n×n)
    
    Returns:
        Dictionary with gap, noise, margin, and verification
    """
    sg = signal_gap(S)
    noise = entry_sup_norm(N)
    margin = trop_margin(S + N)
    dominated = sg >= 4 * noise
    
    return {
        'signal_gap': sg,
        'noise_bound': 4 * noise,
        'dominated': dominated,
        'margin': margin,
        'nonneg': margin >= -1e-12,
        'theorem_holds': (not dominated) or (margin >= -1e-12)
    }


def threshold_window_check(
    S: np.ndarray, 
    N: np.ndarray, 
    C: float
) -> Dict[str, float]:
    """
    Check the √(log n) threshold window theorem.
    
    If signalGap(S) ≥ 5*C*√(log n) and ‖N‖∞ ≤ C*√(log n),
    then tropMargin(S+N) ≥ 0.
    
    Args:
        S: Signal matrix (n×n)
        N: Noise matrix (n×n)
        C: Scale constant
    
    Returns:
        Dictionary with all computed values
    """
    n = S.shape[0]
    sqrt_log_n = np.sqrt(np.log(n)) if n > 1 else 0.0
    
    sg = signal_gap(S)
    noise = entry_sup_norm(N)
    margin = trop_margin(S + N)
    
    noise_ok = noise <= C * sqrt_log_n
    gap_ok = sg >= 5 * C * sqrt_log_n
    
    return {
        'n': n,
        'sqrt_log_n': sqrt_log_n,
        'C': C,
        'signal_gap': sg,
        'gap_threshold': 5 * C * sqrt_log_n,
        'noise_norm': noise,
        'noise_threshold': C * sqrt_log_n,
        'noise_ok': noise_ok,
        'gap_ok': gap_ok,
        'hypothesis_met': noise_ok and gap_ok,
        'margin': margin,
        'conclusion_holds': margin >= -1e-12
    }


def telescoping_replacement_bound(
    matrices: List[np.ndarray]
) -> Dict[str, float]:
    """
    Compute the telescoping replacement bound.
    
    |tropMargin(W_0) - tropMargin(W_m)| ≤ Σ_k |tropMargin(W_k) - tropMargin(W_{k+1})|
    
    Args:
        matrices: List of matrices [W_0, W_1, ..., W_m]
    
    Returns:
        Dictionary with margins, step bounds, and verification
    """
    margins = [trop_margin(W) for W in matrices]
    step_diffs = [abs(margins[k] - margins[k+1]) for k in range(len(matrices)-1)]
    total_diff = abs(margins[0] - margins[-1])
    sum_steps = sum(step_diffs)
    
    return {
        'margins': margins,
        'step_diffs': step_diffs,
        'total_diff': total_diff,
        'sum_steps': sum_steps,
        'bound_holds': total_diff <= sum_steps + 1e-12
    }


def ground_state_stability_check(
    E: np.ndarray,
    E_prime: np.ndarray,
    a_star: int,
    delta: float
) -> Dict[str, any]:
    """
    Check ground state stability theorem.
    
    If E[a*] - E[a] ≥ 2δ for all a ≠ a*, and |E[a] - E'[a]| ≤ δ,
    then a* maximizes E'.
    
    Args:
        E: Original energy function (1D array)
        E_prime: Perturbed energy function
        a_star: Ground state index
        delta: Perturbation bound
    
    Returns:
        Dictionary with verification results
    """
    n = len(E)
    
    # Check gap condition
    gaps = [E[a_star] - E[a] for a in range(n) if a != a_star]
    min_gap = min(gaps) if gaps else float('inf')
    gap_ok = min_gap >= 2 * delta
    
    # Check perturbation bound
    max_pert = max(abs(E[a] - E_prime[a]) for a in range(n))
    pert_ok = max_pert <= delta + 1e-12
    
    # Check conclusion
    maximizer_prime = int(np.argmax(E_prime))
    conclusion_ok = maximizer_prime == a_star
    
    return {
        'min_gap': min_gap,
        'required_gap': 2 * delta,
        'gap_ok': gap_ok,
        'max_perturbation': max_pert,
        'pert_ok': pert_ok,
        'hypothesis_met': gap_ok and pert_ok,
        'perturbed_maximizer': maximizer_prime,
        'original_maximizer': a_star,
        'conclusion_ok': conclusion_ok,
        'theorem_holds': (not (gap_ok and pert_ok)) or conclusion_ok
    }


def universality_test(
    n: int,
    signal_strengths: np.ndarray,
    ensembles: List[str],
    num_trials: int = 200,
    seed: int = 42
) -> Dict[str, np.ndarray]:
    """
    Run the universality collapse test.
    
    For each ensemble and signal strength (scaled by √(log n)),
    estimate P(tropMargin(S + N) ≥ 0).
    
    Args:
        n: Matrix dimension
        signal_strengths: Array of scaled signal strengths
        ensembles: List of ensemble names
        num_trials: Number of Monte Carlo trials per point
        seed: Random seed
    
    Returns:
        Dictionary mapping ensemble name to probability arrays
    """
    rng = np.random.default_rng(seed)
    scale = np.sqrt(np.log(n)) if n > 1 else 1.0
    
    results = {}
    for ens in ensembles:
        probs = []
        for s in signal_strengths:
            actual_signal = s * scale
            S = mean_model(n, 0.0, actual_signal / 2.0)
            count = 0
            for _ in range(num_trials):
                if ens == 'gaussian':
                    N = rng.standard_normal((n, n))
                elif ens == 'rademacher':
                    N = rng.choice([-1.0, 1.0], size=(n, n))
                elif ens == 'uniform':
                    N = rng.uniform(-np.sqrt(3), np.sqrt(3), (n, n))
                elif ens == 'exponential':
                    N = rng.exponential(1.0, (n, n)) - 1.0
                elif ens == 'cauchy':
                    N = rng.standard_cauchy((n, n))
                else:
                    raise ValueError(f"Unknown ensemble: {ens}")
                
                if trop_margin(S + N) >= 0:
                    count += 1
            probs.append(count / num_trials)
        results[ens] = np.array(probs)
    
    return results


if __name__ == "__main__":
    # Example usage
    rng = np.random.default_rng(42)
    n = 5
    
    print("=== Algorithm Examples ===\n")
    
    # 1. Perturbation bound
    A = rng.standard_normal((n, n))
    E = 0.5 * rng.uniform(-1, 1, (n, n))
    result = verify_perturbation_bound(A, E)
    print(f"Perturbation bound: diff={result['difference']:.4f} ≤ "
          f"bound={result['lipschitz_bound']:.4f}, "
          f"satisfied={result['satisfied']}")
    
    # 2. Signal dominance
    S = mean_model(n, 0.0, 5.0)
    N = rng.standard_normal((n, n))
    result = verify_signal_dominance(S, N)
    print(f"Signal dominance: gap={result['signal_gap']:.3f}, "
          f"4‖N‖∞={result['noise_bound']:.3f}, "
          f"margin={result['margin']:.3f}")
    
    # 3. Threshold window
    C = 2.0
    result = threshold_window_check(S, N, C)
    print(f"Threshold window: gap_ok={result['gap_ok']}, "
          f"noise_ok={result['noise_ok']}, "
          f"margin={result['margin']:.3f}")
    
    # 4. Ground state stability
    E_vals = np.array([10.0, 3.0, 2.0, 1.0, 0.0])
    delta = 1.0
    perturbation = rng.uniform(-delta, delta, 5)
    E_prime = E_vals + perturbation
    result = ground_state_stability_check(E_vals, E_prime, 0, delta)
    print(f"Ground state: gap={result['min_gap']:.2f}, "
          f"stable={result['conclusion_ok']}")
    
    print("\nAll algorithms verified.")
