"""
Applications of Quantum Phase Transition Theory via Lorentzian Polynomials

This module demonstrates real-world applications of the formally verified
theorems connecting Lorentzian polynomial geometry to quantum sampling
robustness. Each application shows how the theoretical framework produces
actionable predictions.

Applications:
1. Boson sampling interferometer design selection
2. Noise budget allocation for quantum photonic experiments
3. Classical simulation feasibility prediction
4. Graph-based quantum advantage benchmarking
"""

import numpy as np
from typing import Dict, List, Tuple


# ============================================================================
# Self-contained core algorithms
# ============================================================================

def compute_lorentzian_gap(A: np.ndarray) -> Tuple[float, np.ndarray]:
    eigenvalues, eigenvectors = np.linalg.eigh(A)
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    gap = -eigenvalues[1] if A.shape[0] >= 2 else float('inf')
    return gap, eigenvectors[:, 0]


def certified_threshold(A: np.ndarray) -> float:
    gap, _ = compute_lorentzian_gap(A)
    return gap / 2


# ============================================================================
# Application 1: Interferometer Design Selection
# ============================================================================

def select_optimal_interferometer(candidates: List[np.ndarray]) -> Dict:
    """Select the most noise-robust interferometer design.

    Given candidate unitary matrices (representing linear optical networks),
    compute the Lorentzian stability radius of each and recommend the most
    robust design.

    Args:
        candidates: List of n×n matrices representing interferometer designs

    Returns:
        Dictionary with rankings and analysis
    """
    results = []
    for i, U in enumerate(candidates):
        # Hessian proxy: -U^T U (negative of the Gram matrix)
        H = -(U.T @ U)
        gap, witness = compute_lorentzian_gap(H)
        threshold = certified_threshold(H)
        eigenvalues = np.linalg.eigvalsh(H)
        results.append({
            'index': i,
            'gap': gap,
            'threshold': threshold,
            'min_eigenvalue': eigenvalues[0],
            'max_eigenvalue': eigenvalues[-1],
            'condition': eigenvalues[-1] / eigenvalues[0] if eigenvalues[0] != 0 else float('inf')
        })

    results.sort(key=lambda x: x['threshold'], reverse=True)
    return {
        'rankings': results,
        'best_index': results[0]['index'],
        'best_threshold': results[0]['threshold']
    }


# ============================================================================
# Application 2: Noise Budget Allocation
# ============================================================================

def allocate_noise_budget(H: np.ndarray, total_budget: float,
                          num_components: int) -> Dict:
    """Allocate noise budget across components of a quantum optical system.

    Given a total noise budget and a Hessian proxy, determine how to
    distribute noise across components while maintaining quantum advantage.

    Uses Theorem 5 (iterated perturbation): the gap after k perturbations
    of size δ each is ε - k·δ. So δ_per_component = (ε - safety_margin) / k.

    Args:
        H: n×n Hessian proxy matrix
        total_budget: total allowable perturbation (operator norm)
        num_components: number of optical components

    Returns:
        Allocation strategy with per-component budgets
    """
    gap, _ = compute_lorentzian_gap(H)
    threshold = certified_threshold(H)

    # Per-component budget ensuring total stays below threshold
    safe_per_component = threshold / num_components
    requested_per_component = total_budget / num_components

    is_feasible = total_budget < threshold

    return {
        'base_gap': gap,
        'certified_threshold': threshold,
        'total_budget': total_budget,
        'num_components': num_components,
        'safe_per_component': safe_per_component,
        'requested_per_component': requested_per_component,
        'is_feasible': is_feasible,
        'residual_gap': max(gap - total_budget, 0),
        'safety_margin': threshold - total_budget if is_feasible else 0
    }


# ============================================================================
# Application 3: Classical Simulation Feasibility
# ============================================================================

def predict_simulation_feasibility(H: np.ndarray, noise_level: float) -> Dict:
    """Predict whether a noisy quantum sampling instance is classically simulable.

    Uses the Lorentzian stability framework:
    - If noise < certified threshold → quantum advantage predicted (Theorem 1)
    - If noise > gap → classical simulation likely feasible
    - In between → uncertain regime

    Args:
        H: n×n Hessian proxy matrix
        noise_level: estimated noise in the experiment

    Returns:
        Prediction with confidence level and regime classification
    """
    gap, _ = compute_lorentzian_gap(H)
    threshold = certified_threshold(H)

    if noise_level < threshold:
        regime = "QUANTUM_HARD"
        confidence = min(1.0, (threshold - noise_level) / threshold)
        residual_gap = gap - noise_level
    elif noise_level < gap:
        regime = "UNCERTAIN"
        confidence = 0.5 * (gap - noise_level) / (gap - threshold)
        residual_gap = gap - noise_level
    else:
        regime = "CLASSICALLY_SIMULABLE"
        confidence = min(1.0, (noise_level - gap) / gap)
        residual_gap = 0

    return {
        'regime': regime,
        'confidence': confidence,
        'gap': gap,
        'threshold': threshold,
        'noise_level': noise_level,
        'residual_gap': residual_gap,
        'separation_ratio': gap / noise_level if noise_level > 0 else float('inf')
    }


# ============================================================================
# Application 4: Graph-Based Quantum Advantage Benchmarking
# ============================================================================

def benchmark_graph_family(sizes: List[int], graph_type: str = 'complete') -> Dict:
    """Benchmark quantum advantage scaling across a graph family.

    For each graph size, compute the Lorentzian gap and certified threshold,
    revealing how quantum advantage scales with instance size.

    Args:
        sizes: list of graph sizes to benchmark
        graph_type: 'complete', 'cycle', or 'path'

    Returns:
        Benchmark results with scaling analysis
    """
    results = []
    for n in sizes:
        if graph_type == 'complete':
            adj = np.ones((n, n)) - np.eye(n)
        elif graph_type == 'cycle':
            adj = np.zeros((n, n))
            for i in range(n):
                adj[i, (i + 1) % n] = 1
                adj[(i + 1) % n, i] = 1
        elif graph_type == 'path':
            adj = np.zeros((n, n))
            for i in range(n - 1):
                adj[i, i + 1] = 1
                adj[i + 1, i] = 1
        else:
            raise ValueError(f"Unknown graph type: {graph_type}")

        H = adj.astype(float)
        gap, _ = compute_lorentzian_gap(H)
        threshold = certified_threshold(H)

        results.append({
            'n': n,
            'gap': gap,
            'threshold': threshold,
            'gap_per_edge': gap / (np.sum(adj) / 2) if np.sum(adj) > 0 else 0
        })

    return {'results': results, 'graph_type': graph_type}


# ============================================================================
# Main demonstration
# ============================================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 70)
    print("APPLICATION 1: Interferometer Design Selection")
    print("=" * 70)
    candidates = []
    for i in range(5):
        n = 4
        Q, _ = np.linalg.qr(np.random.randn(n, n))
        scaling = 1.0 + 0.5 * i  # Varying designs
        candidates.append(Q * scaling)

    result = select_optimal_interferometer(candidates)
    print(f"Best design: #{result['best_index']} (threshold={result['best_threshold']:.4f})")
    for r in result['rankings']:
        print(f"  Design #{r['index']}: gap={r['gap']:.4f}, threshold={r['threshold']:.4f}")

    print()
    print("=" * 70)
    print("APPLICATION 2: Noise Budget Allocation")
    print("=" * 70)
    H = np.ones((5, 5)) - np.eye(5)  # K5 adjacency
    alloc = allocate_noise_budget(H, total_budget=1.0, num_components=4)
    print(f"Base gap: {alloc['base_gap']:.4f}")
    print(f"Certified threshold: {alloc['certified_threshold']:.4f}")
    print(f"Budget per component: {alloc['requested_per_component']:.4f}")
    print(f"Safe per component: {alloc['safe_per_component']:.4f}")
    print(f"Feasible: {alloc['is_feasible']}")

    print()
    print("=" * 70)
    print("APPLICATION 3: Classical Simulation Feasibility")
    print("=" * 70)
    H = np.ones((6, 6)) - np.eye(6)  # K6 adjacency
    for noise in [0.5, 1.5, 3.0, 5.0, 7.0]:
        pred = predict_simulation_feasibility(H, noise)
        print(f"  noise={noise:.1f}: {pred['regime']:<25} "
              f"confidence={pred['confidence']:.2f}")

    print()
    print("=" * 70)
    print("APPLICATION 4: Graph Family Benchmarking")
    print("=" * 70)
    for gtype in ['complete', 'cycle', 'path']:
        bench = benchmark_graph_family(list(range(3, 9)), graph_type=gtype)
        print(f"\n  {gtype.upper()} graphs:")
        for r in bench['results']:
            print(f"    n={r['n']}: gap={r['gap']:.4f}, threshold={r['threshold']:.4f}")
