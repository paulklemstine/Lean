"""
Applications of Finite-Size Susceptibility Theory.

Demonstrates real-world applications of the susceptibility framework
for optimization phase transitions in random combinatorial structures.
"""

import numpy as np
from scipy.optimize import linprog
from itertools import combinations
import warnings


# ── Core LP Solver ──────────────────────────────────────────────────────

def compute_frac_transversal_num(n, edges):
    """Compute τ*(H) via LP."""
    if not edges:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    return result.fun if result.success else float('inf')


def generate_random_hypergraph(n, m, d, rng):
    all_edges = list(combinations(range(n), d))
    if m > len(all_edges):
        m = len(all_edges)
    indices = rng.choice(len(all_edges), size=m, replace=False)
    return [all_edges[i] for i in indices]


# ── Application 1: Identifying Hard Optimization Densities ─────────────

def app1_hard_density_detection():
    """Find densities where optimization is hardest (peak susceptibility).

    In combinatorial optimization, the hardest instances often occur near
    phase transitions. This application uses susceptibility to locate them.
    """
    print("=" * 60)
    print("APPLICATION 1: Detecting Hard Optimization Densities")
    print("=" * 60)
    print()

    n, d = 15, 3
    rng = np.random.default_rng(42)
    samples = 30

    m_values = list(range(1, int(3 * n), 2))
    results = []

    for m in m_values:
        taus = [compute_frac_transversal_num(n, generate_random_hypergraph(n, m, d, rng))
                for _ in range(samples)]
        var_tau = np.var(taus)
        results.append((m / n, var_tau, np.mean(taus)))

    # Find the hardest density
    hardest = max(results, key=lambda x: x[1])
    print(f"  System: {d}-uniform hypergraph, n={n}")
    print(f"  Hardest density: c = {hardest[0]:.3f} (m/n)")
    print(f"  Variance at peak: {hardest[1]:.6f}")
    print(f"  Mean τ* at peak: {hardest[2]:.4f}")
    print()
    print("  Interpretation: Near this density, the LP optimum fluctuates most.")
    print("  Approximation algorithms will have the worst guarantees here.")
    print()
    return results


# ── Application 2: Quality Assessment of LP Relaxations ────────────────

def app2_relaxation_quality():
    """Assess LP relaxation quality across densities using susceptibility.

    When χ_avg is small, the LP optimum is stable under perturbations,
    suggesting the relaxation tightly captures problem structure.
    """
    print("=" * 60)
    print("APPLICATION 2: LP Relaxation Quality Assessment")
    print("=" * 60)
    print()

    n, d = 12, 3
    rng = np.random.default_rng(123)

    densities = [0.3, 0.8, 1.5, 2.5]
    all_edges = list(combinations(range(n), d))

    for c in densities:
        m = max(1, int(c * n))
        edges = generate_random_hypergraph(n, m, d, rng)
        tau = compute_frac_transversal_num(n, edges)

        # Measure susceptibility
        edge_set = set(edges)
        candidates = [e for e in all_edges if e not in edge_set][:20]
        deltas = []
        for e in candidates:
            tau_new = compute_frac_transversal_num(n, edges + [e])
            deltas.append(tau_new - tau)

        chi_avg = np.mean(np.abs(deltas)) if deltas else 0.0
        chi_max = np.max(np.abs(deltas)) if deltas else 0.0

        quality = "TIGHT" if chi_avg < 0.3 else ("MODERATE" if chi_avg < 0.6 else "LOOSE")
        print(f"  c={c:.1f}: τ*={tau:.3f}, χ_avg={chi_avg:.4f}, χ_max={chi_max:.4f} → {quality}")

    print()
    print("  Low susceptibility = stable LP relaxation = good approximation.")
    print("  High susceptibility = unstable relaxation = hard instances.")
    print()


# ── Application 3: Finite-Size Scaling Analysis ───────────────────────

def app3_scaling_analysis():
    """Perform finite-size scaling analysis to estimate critical exponents.

    Tests the prediction that peak susceptibility grows as n^γ.
    """
    print("=" * 60)
    print("APPLICATION 3: Finite-Size Scaling Analysis")
    print("=" * 60)
    print()

    d = 3
    n_values = [8, 10, 12, 15]
    rng = np.random.default_rng(42)
    samples = 20

    print(f"  d={d}-uniform hypergraphs")
    print(f"  System sizes: {n_values}")
    print()

    peaks = []
    pc_densities = []

    for n in n_values:
        from math import comb
        m_max = min(comb(n, d), int(3 * n))
        m_vals = list(range(0, m_max + 1, max(1, m_max // 20)))
        best_var = 0
        best_c = 0

        for m in m_vals:
            taus = [compute_frac_transversal_num(n, generate_random_hypergraph(n, m, d, rng))
                    for _ in range(samples)]
            v = np.var(taus)
            if v > best_var:
                best_var = v
                best_c = m / n

        peaks.append(best_var)
        pc_densities.append(best_c)
        print(f"  n={n:3d}: c* ≈ {best_c:.3f}, peak Var(τ*) = {best_var:.6f}")

    # Estimate gamma
    if len(n_values) >= 2:
        log_n = np.log(np.array(n_values, dtype=float))
        log_peaks = np.log(np.array(peaks) + 1e-12)
        gamma = np.polyfit(log_n, log_peaks, 1)[0]
        print(f"\n  Estimated γ(d={d}) ≈ {gamma:.3f}")
        if gamma > 0:
            print("  → Divergent susceptibility: consistent with phase transition.")
        else:
            print("  → Bounded fluctuations: larger sizes may be needed.")
    print()


if __name__ == "__main__":
    app1_hard_density_detection()
    app2_relaxation_quality()
    app3_scaling_analysis()
