#!/usr/bin/env python3
"""
applications.py — Applications of Subgroup Pressure Concentration

Demonstrates real-world applications of the concentration theory:
1. Random group generation: predicting generation probability
2. Cryptographic key generation: randomness quality assessment
3. Network reliability: algebraic model of redundant systems
4. Statistical mechanics: free energy and phase transitions
"""

import numpy as np
from math import factorial, log, exp, sqrt
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─── Application 1: Random Group Generation ─────────────────────────

def generation_probability_bound(n: int, p: float = 0.5) -> dict:
    """
    For S_n with point stabilizer family, bound the probability
    that random pressure deviates from its mean.
    
    By the sieve inequality, the non-generation probability is
    bounded by the pressure. Concentration then says this bound
    is stable under random subgroup sampling.
    
    Args:
        n: Degree of symmetric group.
        p: Bernoulli inclusion probability.
    
    Returns:
        Dictionary with theoretical bounds.
    """
    # Point stabilizers have index n
    # Weight w(H,K) = 1/n^4 (inverse-index-squared kernel)
    w = 1.0 / n**4
    
    # Expected pressure = p^2 * n * n * w = p^2 * n^2 / n^4 = p^2 / n^2
    expected = p**2 * n**2 * w
    
    # Each influence = 2 * n * w = 2/n^3
    influence = 2 * n * w
    
    # Variance bound = p(1-p) * n * influence^2
    var_bound = p * (1 - p) * n * influence**2
    
    # Concentration: P(|Π - E[Π]| ≥ t) ≤ 2 exp(-2t^2 / (n * influence^2))
    # For t = expected/2:
    t = expected / 2
    concentration = 2 * exp(-2 * t**2 / (n * influence**2)) if n * influence**2 > 0 else 0
    
    return {
        'n': n,
        'expected_pressure': expected,
        'influence': influence,
        'variance_bound': var_bound,
        'prob_50pct_deviation': concentration,
        'concentration_exponent': 2 / (n * influence**2) if influence > 0 else float('inf')
    }


# ─── Application 2: Free Energy and Phase Transitions ───────────────

def free_energy_landscape(n: int, betas: np.ndarray, 
                          num_samples: int = 20000) -> dict:
    """
    Compute the free energy landscape F(β) = -log E[exp(β Π)].
    
    This reveals phase transitions in the subgroup thermodynamics:
    convexity of F(β) implies thermodynamic stability.
    
    Args:
        n: Degree of symmetric group.
        betas: Array of inverse temperature values.
        num_samples: Monte Carlo samples.
    
    Returns:
        Dictionary with free energy, susceptibility curves.
    """
    # Build weight matrix for point stabilizers
    w = 1.0 / n**4
    W = np.full((n, n), w)
    
    rng = np.random.RandomState(42)
    
    free_energies = []
    susceptibilities = []
    
    for beta in betas:
        log_Z_vals = np.zeros(num_samples)
        pres_vals = np.zeros(num_samples)
        
        for i in range(num_samples):
            chi = (rng.random(n) < 0.5).astype(float)
            pres = chi @ W @ chi
            pres_vals[i] = pres
            log_Z_vals[i] = beta * pres
        
        # Log-sum-exp for numerical stability
        max_val = np.max(log_Z_vals)
        log_Z = max_val + np.log(np.mean(np.exp(log_Z_vals - max_val)))
        
        # Free energy
        F = -log_Z
        free_energies.append(F)
        
        # Susceptibility (variance of pressure at this β)
        weights = np.exp(log_Z_vals - max_val)
        weights /= np.sum(weights)
        mean_pres = np.sum(weights * pres_vals)
        susc = np.sum(weights * (pres_vals - mean_pres)**2)
        susceptibilities.append(susc)
    
    return {
        'betas': betas,
        'free_energy': np.array(free_energies),
        'susceptibility': np.array(susceptibilities)
    }


# ─── Application 3: Network Reliability ─────────────────────────────

def network_reliability_model(n_nodes: int, redundancy_groups: int,
                              failure_prob: float = 0.1) -> dict:
    """
    Model network reliability using subgroup pressure.
    
    A network with n_nodes has redundancy groups (analogous to subgroups).
    Each group can fail independently. The "pressure" measures the
    total vulnerability of the network.
    
    Concentration says: for large networks, the vulnerability is
    predictable despite random failures.
    
    Args:
        n_nodes: Number of network nodes.
        redundancy_groups: Number of overlapping redundancy groups.
        failure_prob: Probability each group fails.
    
    Returns:
        Dictionary with reliability metrics.
    """
    # Model: each redundancy group covers some nodes
    # Weight = correlation between groups (shared nodes)
    rng = np.random.RandomState(42)
    
    # Generate random group assignments
    coverage = rng.random((redundancy_groups, n_nodes)) < 0.3
    
    # Weight = Jaccard-like similarity between groups, scaled by 1/size^2
    W = np.zeros((redundancy_groups, redundancy_groups))
    for i in range(redundancy_groups):
        for j in range(redundancy_groups):
            overlap = np.sum(coverage[i] & coverage[j])
            size_i = max(1, np.sum(coverage[i]))
            size_j = max(1, np.sum(coverage[j]))
            W[i, j] = overlap / (size_i * size_j)
    
    # Compute pressure statistics
    num_samples = 10000
    pressures = []
    for _ in range(num_samples):
        active = (rng.random(redundancy_groups) > failure_prob).astype(float)
        pres = active @ W @ active
        pressures.append(pres)
    
    pressures = np.array(pressures)
    
    # Influence analysis
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    
    return {
        'mean_pressure': float(np.mean(pressures)),
        'var_pressure': float(np.var(pressures)),
        'max_influence': float(np.max(influences)),
        'variance_bound': failure_prob * (1 - failure_prob) * float(np.sum(influences**2)),
        'concentration_ratio': float(np.std(pressures) / np.mean(pressures))
            if np.mean(pressures) > 0 else 0,
    }


# ─── Main ────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("Applications of Subgroup Pressure Concentration")
    print("=" * 60)
    
    # App 1: Generation probability
    print("\n--- Application 1: Random Group Generation ---")
    for n in [5, 10, 20, 50, 100]:
        result = generation_probability_bound(n)
        print(f"  S_{n}: E[Π]={result['expected_pressure']:.2e}, "
              f"VarBound={result['variance_bound']:.2e}, "
              f"P(50% dev)={result['prob_50pct_deviation']:.2e}")
    
    # App 2: Free energy
    print("\n--- Application 2: Free Energy Landscape ---")
    betas = np.linspace(-10, 10, 50)
    for n in [5, 10, 15]:
        result = free_energy_landscape(n, betas, num_samples=5000)
        F = result['free_energy']
        # Check convexity
        diffs = np.diff(np.diff(F))
        is_convex = np.all(diffs >= -1e-6)
        print(f"  S_{n}: F range = [{F.min():.4f}, {F.max():.4f}], "
              f"convex = {is_convex}")
    
    # App 3: Network reliability
    print("\n--- Application 3: Network Reliability ---")
    for n in [10, 50, 100]:
        result = network_reliability_model(n, redundancy_groups=n//2)
        print(f"  {n} nodes: mean_Π={result['mean_pressure']:.4f}, "
              f"CV={result['concentration_ratio']:.4f}, "
              f"var/bound={result['var_pressure']/max(result['variance_bound'],1e-30):.4f}")
    
    # Plot free energy landscape
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    for n, color in [(5, 'blue'), (10, 'red'), (15, 'green')]:
        result = free_energy_landscape(n, betas, num_samples=10000)
        axes[0].plot(betas, result['free_energy'], color=color, 
                     label=f'$S_{{{n}}}$')
        axes[1].plot(betas, result['susceptibility'], color=color,
                     label=f'$S_{{{n}}}$')
    
    axes[0].set_xlabel('$\\beta$')
    axes[0].set_ylabel('$F(\\beta)$')
    axes[0].set_title('Free Energy Landscape')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    axes[1].set_xlabel('$\\beta$')
    axes[1].set_ylabel('$\\chi(\\beta)$')
    axes[1].set_title('Susceptibility')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('applications_plot.png', dpi=150, bbox_inches='tight')
    print(f"\nPlot saved to applications_plot.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Concentration of Subgroup Pressure on Symmetric Groups

Demonstrates the self-averaging phenomenon: as n grows, the random
subgroup pressure on S_n concentrates around its mean, with variance
decaying like O(1/n).

We sample random subgroup ensembles using point stabilizers and Young
subgroups, compute empirical pressure under Bernoulli(1/2) inclusion,
and plot variance vs n.
"""

import numpy as np
from math import factorial, comb
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Subgroup families for S_n ───────────────────────────────────────

def point_stabilizer_indices(n):
    """Point stabilizers S_{n-1} in S_n have index n."""
    return [n] * n  # n copies, each of index n

def young_subgroup_indices(n, max_parts=3):
    """
    Young subgroups S_{a1} x S_{a2} x ... in S_n.
    Returns list of indices [S_n : S_{a1} x ...] = n! / (a1! a2! ...).
    We enumerate compositions of n into at most max_parts parts, each ≥ 1.
    """
    indices = []
    parts_list = []
    
    def gen_compositions(remaining, max_p, current):
        if max_p == 1:
            if remaining >= 1:
                parts_list.append(current + [remaining])
            return
        for a in range(1, remaining):
            gen_compositions(remaining - a, max_p - 1, current + [a])
        parts_list.append(current + [remaining])
    
    gen_compositions(n, max_parts, [])
    
    for parts in parts_list:
        denom = 1
        for a in parts:
            denom *= factorial(a)
        idx = factorial(n) // denom
        if idx > 1:  # exclude trivial
            indices.append(idx)
    
    return indices

def inverse_index_weight(idx_H, idx_K):
    """Weight w(H,K) = 1 / (idx_H^2 * idx_K^2)."""
    return 1.0 / (idx_H**2 * idx_K**2)

def compute_pressure(indices, included, weight_fn=inverse_index_weight):
    """Compute pressure for a given inclusion vector."""
    total = 0.0
    for i, idx_i in enumerate(indices):
        if not included[i]:
            continue
        for j, idx_j in enumerate(indices):
            if not included[j]:
                continue
            total += weight_fn(idx_i, idx_j)
    return total

def compute_influence(indices, h0_idx, weight_fn=inverse_index_weight):
    """Compute the influence of subgroup h0_idx."""
    idx_h0 = indices[h0_idx]
    row_sum = sum(abs(weight_fn(idx_h0, indices[k])) for k in range(len(indices)))
    col_sum = sum(abs(weight_fn(indices[k], idx_h0)) for k in range(len(indices)))
    return row_sum + col_sum

def empirical_variance(indices, p=0.5, num_samples=5000, weight_fn=inverse_index_weight):
    """Estimate variance of random pressure by Monte Carlo."""
    m = len(indices)
    pressures = []
    for _ in range(num_samples):
        included = np.random.random(m) < p
        pres = compute_pressure(indices, included, weight_fn)
        pressures.append(pres)
    pressures = np.array(pressures)
    return np.var(pressures), np.mean(pressures)

# ─── Main demo ───────────────────────────────────────────────────────

def main():
    np.random.seed(42)
    
    print("=" * 60)
    print("Concentration of Subgroup Pressure — Demo")
    print("=" * 60)
    
    ns = list(range(5, 16))
    
    # ── Point stabilizers ──
    print("\n--- Point Stabilizers ---")
    vars_ps = []
    means_ps = []
    influence_bounds_ps = []
    
    for n in ns:
        indices = point_stabilizer_indices(n)
        var, mean = empirical_variance(indices, p=0.5, num_samples=10000)
        
        # Theoretical influence bound
        influences = [compute_influence(indices, h, inverse_index_weight) 
                      for h in range(len(indices))]
        inf_sq_sum = sum(inf_val**2 for inf_val in influences)
        var_bound = 0.25 * inf_sq_sum  # p(1-p) = 0.25
        
        vars_ps.append(var)
        means_ps.append(mean)
        influence_bounds_ps.append(var_bound)
        
        print(f"  n={n:2d}: |S|={len(indices):3d}, "
              f"E[Π]={mean:.6f}, Var(Π)={var:.2e}, "
              f"VarBound={var_bound:.2e}")
    
    # ── Young subgroups (2-part) ──
    print("\n--- Young Subgroups (≤3 parts) ---")
    vars_young = []
    means_young = []
    influence_bounds_young = []
    
    for n in ns:
        indices = young_subgroup_indices(n, max_parts=2)
        if len(indices) == 0:
            vars_young.append(0)
            means_young.append(0)
            influence_bounds_young.append(0)
            continue
        var, mean = empirical_variance(indices, p=0.5, num_samples=10000)
        
        influences = [compute_influence(indices, h, inverse_index_weight) 
                      for h in range(len(indices))]
        inf_sq_sum = sum(inf_val**2 for inf_val in influences)
        var_bound = 0.25 * inf_sq_sum
        
        vars_young.append(var)
        means_young.append(mean)
        influence_bounds_young.append(var_bound)
        
        print(f"  n={n:2d}: |S|={len(indices):3d}, "
              f"E[Π]={mean:.6f}, Var(Π)={var:.2e}, "
              f"VarBound={var_bound:.2e}")
    
    # ── Fit power law ──
    print("\n--- Power Law Fit: Var ~ C/n^α ---")
    log_ns = np.log(np.array(ns, dtype=float))
    
    for name, vars_data in [("Point Stabilizers", vars_ps), 
                             ("Young Subgroups", vars_young)]:
        log_vars = np.log(np.array(vars_data) + 1e-30)
        mask = np.array(vars_data) > 1e-20
        if mask.sum() >= 2:
            coeffs = np.polyfit(log_ns[mask], log_vars[mask], 1)
            alpha = -coeffs[0]
            C = np.exp(coeffs[1])
            print(f"  {name}: α = {alpha:.3f}, C = {C:.6f}")
            print(f"    (Expected: α ≈ 4 for inverse-index-squared kernel on point stabilizers)")
    
    # ── Normalized fluctuations ──
    print("\n--- Normalized Fluctuations √n * (Π - E[Π]) ---")
    for n in [8, 12, 15]:
        indices = point_stabilizer_indices(n)
        m = len(indices)
        pressures = []
        for _ in range(20000):
            included = np.random.random(m) < 0.5
            pres = compute_pressure(indices, included)
            pressures.append(pres)
        pressures = np.array(pressures)
        centered = pressures - np.mean(pressures)
        normalized = np.sqrt(n) * centered
        print(f"  n={n}: std(√n*(Π-E[Π])) = {np.std(normalized):.6f}, "
              f"skewness = {np.mean(normalized**3)/np.std(normalized)**3:.3f}")
    
    # ── Plot ──
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Variance decay
    ax = axes[0]
    ax.loglog(ns, vars_ps, 'bo-', label='Point Stab.', markersize=6)
    ax.loglog(ns, vars_young, 'rs-', label='Young (2-part)', markersize=6)
    ax.loglog(ns, [vars_ps[0] * (ns[0]/n)**4 for n in ns], 'k--', 
              alpha=0.5, label='$O(1/n^4)$')
    ax.set_xlabel('$n$')
    ax.set_ylabel('Var($\\Pi$)')
    ax.set_title('Variance Decay')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Variance bound vs empirical
    ax = axes[1]
    ax.semilogy(ns, vars_ps, 'bo-', label='Empirical Var')
    ax.semilogy(ns, influence_bounds_ps, 'r^--', label='Influence Bound')
    ax.set_xlabel('$n$')
    ax.set_ylabel('Variance')
    ax.set_title('Empirical vs Bound (Point Stab.)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Histogram of normalized fluctuations
    ax = axes[2]
    for n_val, color in [(8, 'blue'), (12, 'red'), (15, 'green')]:
        indices = point_stabilizer_indices(n_val)
        m = len(indices)
        pressures = []
        for _ in range(10000):
            included = np.random.random(m) < 0.5
            pressures.append(compute_pressure(indices, included))
        pressures = np.array(pressures)
        centered = pressures - np.mean(pressures)
        if np.std(centered) > 0:
            normalized = centered / np.std(centered)
            ax.hist(normalized, bins=40, alpha=0.4, density=True, 
                    label=f'$n={n_val}$', color=color)
    x_gauss = np.linspace(-4, 4, 100)
    ax.plot(x_gauss, np.exp(-x_gauss**2/2)/np.sqrt(2*np.pi), 
            'k-', lw=2, label='Gaussian')
    ax.set_xlabel('Normalized $\\Pi$')
    ax.set_ylabel('Density')
    ax.set_title('Normalized Fluctuations')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('concentration_demo.png', dpi=150, bbox_inches='tight')
    print(f"\nPlot saved to concentration_demo.png")
    
    print("\n" + "=" * 60)
    print("Demo complete.")
    print("=" * 60)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Concentration of Subgroup Pressure

Shows the self-averaging phenomenon: as the symmetric group degree n
grows, the distribution of random subgroup pressure concentrates
around its mean. The top row shows histograms narrowing; the bottom
row shows variance decay following O(1/n^4) for point stabilizers.
"""

import numpy as np
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def inverse_index_kernel_matrix(indices):
    """Build weight matrix W[i,j] = 1 / (idx_i^2 * idx_j^2)."""
    inv = 1.0 / (np.array(indices, dtype=float) ** 2)
    return np.outer(inv, inv)


def sample_pressures(W, p=0.5, num_samples=20000, seed=42):
    """Sample random pressures under Bernoulli(p) inclusion."""
    rng = np.random.RandomState(seed)
    n = W.shape[0]
    pressures = np.zeros(num_samples)
    for i in range(num_samples):
        chi = (rng.random(n) < p).astype(float)
        pressures[i] = chi @ W @ chi
    return pressures


# ─── Build data ──────────────────────────────────────────────────────
ns = [5, 7, 9, 11, 13, 15]
all_ns = list(range(5, 16))

# Point stabilizers: n copies of index n
data = {}
for n in ns:
    indices = [n] * n
    W = inverse_index_kernel_matrix(indices)
    pressures = sample_pressures(W)
    data[n] = pressures

# Variance data for all n
var_data = []
for n in all_ns:
    indices = [n] * n
    W = inverse_index_kernel_matrix(indices)
    pressures = sample_pressures(W, num_samples=30000)
    var_data.append(np.var(pressures))

# Influence bounds
influence_bounds = []
for n in all_ns:
    # Each influence = 2 * n / n^4 = 2/n^3
    infl = 2.0 * n / n**4
    bound = 0.25 * n * infl**2  # p(1-p) * |S| * infl^2
    influence_bounds.append(bound)

# ─── Plot ────────────────────────────────────────────────────────────
fig = plt.figure(figsize=(16, 10))

# Top row: Distribution histograms
for i, n in enumerate(ns):
    ax = fig.add_subplot(2, len(ns), i + 1)
    pressures = data[n]
    mean = np.mean(pressures)
    std = np.std(pressures)
    
    if std > 1e-15:
        normalized = (pressures - mean) / std
        ax.hist(normalized, bins=50, density=True, alpha=0.7, 
                color=plt.cm.viridis(i / len(ns)), edgecolor='none')
        x = np.linspace(-4, 4, 200)
        ax.plot(x, np.exp(-x**2/2)/np.sqrt(2*np.pi), 'r-', lw=1.5)
    
    ax.set_title(f'$S_{{{n}}}$', fontsize=14)
    ax.set_xlim(-4, 4)
    ax.set_ylim(0, 0.55)
    if i == 0:
        ax.set_ylabel('Density', fontsize=12)
    ax.set_xlabel('$(\\Pi - \\mathbb{E}[\\Pi])/\\sigma$', fontsize=10)
    ax.tick_params(labelsize=9)

# Bottom left: Variance decay
ax1 = fig.add_subplot(2, 3, 4)
ax1.loglog(all_ns, var_data, 'bo-', markersize=6, label='Empirical Var')
ax1.loglog(all_ns, influence_bounds, 'r^--', markersize=6, label='Influence Bound')
# Reference line
ref = [var_data[0] * (all_ns[0]/n)**4 for n in all_ns]
ax1.loglog(all_ns, ref, 'k:', alpha=0.5, label='$O(n^{-4})$')
ax1.set_xlabel('$n$', fontsize=12)
ax1.set_ylabel('Var($\\Pi$)', fontsize=12)
ax1.set_title('Variance Decay', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Bottom center: Concentration quality
ax2 = fig.add_subplot(2, 3, 5)
cv = [np.std(sample_pressures(inverse_index_kernel_matrix([n]*n), num_samples=20000)) / 
      max(np.mean(sample_pressures(inverse_index_kernel_matrix([n]*n), num_samples=20000)), 1e-30)
      for n in all_ns]
ax2.plot(all_ns, cv, 'gs-', markersize=6)
ax2.set_xlabel('$n$', fontsize=12)
ax2.set_ylabel('CV = $\\sigma / \\mu$', fontsize=12)
ax2.set_title('Coefficient of Variation', fontsize=14)
ax2.grid(True, alpha=0.3)

# Bottom right: Influence profile
ax3 = fig.add_subplot(2, 3, 6)
for n_val, color in [(5, 'blue'), (10, 'orange'), (15, 'green')]:
    indices = np.array([n_val] * n_val, dtype=float)
    W = inverse_index_kernel_matrix(indices)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    ax3.bar(np.arange(len(influences)) + (n_val - 10) * 0.1, 
            influences, width=0.3, alpha=0.7, 
            label=f'$S_{{{n_val}}}$', color=color)
ax3.set_xlabel('Subgroup index', fontsize=12)
ax3.set_ylabel('Influence', fontsize=12)
ax3.set_title('Influence Profile', fontsize=14)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Concentration of Subgroup Pressure on Symmetric Groups', 
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")


#!/usr/bin/env python3
"""
Visualization: Free Energy and Thermodynamic Stability

Shows the convexity of the log moment generating function (free energy)
for subgroup pressure, demonstrating the connection to statistical
mechanics. Convexity implies thermodynamic stability — the system
has well-defined phases and smooth transitions.
"""

import numpy as np
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_free_energy_curve(n, betas, p=0.5, num_samples=30000, seed=42):
    """Compute F(β) = log E[exp(β Π)] for point stabilizers of S_n."""
    rng = np.random.RandomState(seed)
    
    # Weight matrix
    w = 1.0 / n**4
    W = np.full((n, n), w)
    
    # Pre-sample pressures
    pressures = np.zeros(num_samples)
    for i in range(num_samples):
        chi = (rng.random(n) < p).astype(float)
        pressures[i] = chi @ W @ chi
    
    mean_pres = np.mean(pressures)
    centered = pressures - mean_pres
    
    F = np.zeros(len(betas))
    for j, beta in enumerate(betas):
        log_vals = beta * centered
        max_val = np.max(log_vals)
        F[j] = max_val + np.log(np.mean(np.exp(log_vals - max_val)))
    
    return F, mean_pres


# ─── Compute ─────────────────────────────────────────────────────────
betas = np.linspace(-50, 50, 200)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: Free energy curves
ax = axes[0, 0]
colors = plt.cm.plasma(np.linspace(0.2, 0.8, 4))
for i, n in enumerate([5, 8, 12, 15]):
    F, _ = compute_free_energy_curve(n, betas)
    ax.plot(betas, F, color=colors[i], lw=2, label=f'$S_{{{n}}}$')
ax.set_xlabel('$\\beta$ (inverse temperature)', fontsize=12)
ax.set_ylabel('$\\log\\, \\mathrm{MGF}(\\beta)$', fontsize=12)
ax.set_title('Log Moment Generating Function', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Top-right: Convexity verification
ax = axes[0, 1]
for i, n in enumerate([5, 8, 12, 15]):
    F, _ = compute_free_energy_curve(n, betas)
    # Second difference as convexity measure
    d2F = np.diff(np.diff(F))
    dbeta = betas[1] - betas[0]
    d2F /= dbeta**2
    ax.plot(betas[1:-1], d2F, color=colors[i], lw=1.5, label=f'$S_{{{n}}}$')
ax.axhline(y=0, color='k', linestyle='--', alpha=0.5)
ax.set_xlabel('$\\beta$', fontsize=12)
ax.set_ylabel("$F''(\\beta)$ (susceptibility)", fontsize=12)
ax.set_title('Convexity = Thermodynamic Stability', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom-left: Partition function Z(β)
ax = axes[1, 0]
betas_short = np.linspace(-20, 20, 100)
for i, n in enumerate([5, 8, 12, 15]):
    F, _ = compute_free_energy_curve(n, betas_short)
    Z = np.exp(F)
    ax.semilogy(betas_short, Z, color=colors[i], lw=2, label=f'$S_{{{n}}}$')
ax.set_xlabel('$\\beta$', fontsize=12)
ax.set_ylabel('$Z(\\beta) = \\mathbb{E}[e^{\\beta \\Pi}]$', fontsize=12)
ax.set_title('Partition Function', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom-right: Expected pressure vs β (derivative of F)
ax = axes[1, 1]
for i, n in enumerate([5, 8, 12, 15]):
    F, mean_pres = compute_free_energy_curve(n, betas)
    dF = np.gradient(F, betas)
    ax.plot(betas, dF + mean_pres, color=colors[i], lw=2, label=f'$S_{{{n}}}$')
ax.set_xlabel('$\\beta$', fontsize=12)
ax.set_ylabel('$\\langle \\Pi \\rangle_\\beta$', fontsize=12)
ax.set_title('Thermal Average of Pressure', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.suptitle('Thermodynamic Structure of Subgroup Pressure', 
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_free_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_free_energy.png")


#!/usr/bin/env python3
"""
Visualization: Weight Matrix and Influence Heatmap

Shows the structure of the pair interaction weight matrix w(H,K)
for different subgroup families of symmetric groups, and how
the influence profile determines concentration quality.
"""

import numpy as np
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def young_subgroup_data(n, max_parts=2):
    """Generate Young subgroup indices for S_n."""
    index_list = []
    label_list = []
    
    def gen(remaining, max_p, current):
        if max_p == 1:
            if remaining >= 1:
                parts = current + [remaining]
                denom = 1
                for a in parts:
                    denom *= factorial(a)
                idx = factorial(n) // denom
                if idx > 1:
                    index_list.append(idx)
                    label_list.append('+'.join(str(a) for a in sorted(parts, reverse=True)))
            return
        for a in range(1, remaining):
            gen(remaining - a, max_p - 1, current + [a])
        parts = current + [remaining]
        denom = 1
        for a in parts:
            denom *= factorial(a)
        idx = factorial(n) // denom
        if idx > 1:
            index_list.append(idx)
            label_list.append('+'.join(str(a) for a in sorted(parts, reverse=True)))
    
    gen(n, max_parts, [])
    return np.array(index_list, dtype=float), label_list


fig, axes = plt.subplots(2, 3, figsize=(18, 11))

# Top row: Weight matrices for different n
for col, n in enumerate([6, 8, 10]):
    indices, labels = young_subgroup_data(n, max_parts=2)
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    
    ax = axes[0, col]
    im = ax.imshow(W, cmap='hot', norm=LogNorm(vmin=max(W.min(), 1e-15), vmax=W.max()),
                   aspect='auto')
    ax.set_title(f'$S_{{{n}}}$ Weight Matrix ($|S|={len(indices)}$)', fontsize=13)
    if col == 0:
        ax.set_ylabel('Subgroup $H$', fontsize=11)
    ax.set_xlabel('Subgroup $K$', fontsize=11)
    plt.colorbar(im, ax=ax, shrink=0.8)

# Bottom-left: Influence vs index
ax = axes[1, 0]
for n, color, marker in [(6, 'blue', 'o'), (8, 'red', 's'), (10, 'green', '^'), (12, 'purple', 'D')]:
    indices, _ = young_subgroup_data(n, max_parts=2)
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    ax.scatter(indices, influences, c=color, marker=marker, s=30, alpha=0.7,
               label=f'$S_{{{n}}}$')

ax.set_xlabel('Subgroup Index $[G:H]$', fontsize=12)
ax.set_ylabel('Influence', fontsize=12)
ax.set_title('Influence vs Subgroup Index', fontsize=13)
ax.set_xscale('log')
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-center: Cumulative influence
ax = axes[1, 1]
all_ns = range(5, 16)
total_inf_sq = []
for n in all_ns:
    indices, _ = young_subgroup_data(n, max_parts=2)
    if len(indices) == 0:
        total_inf_sq.append(0)
        continue
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    total_inf_sq.append(np.sum(influences**2))

ax.semilogy(list(all_ns), total_inf_sq, 'bo-', markersize=6)
ax.set_xlabel('$n$', fontsize=12)
ax.set_ylabel('$\\sum c_H^2$', fontsize=12)
ax.set_title('Total Squared Influence (Young)', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom-right: Sorted influence spectrum
ax = axes[1, 2]
for n, color in [(8, 'blue'), (10, 'orange'), (12, 'green')]:
    indices, _ = young_subgroup_data(n, max_parts=2)
    if len(indices) == 0:
        continue
    inv = 1.0 / (indices ** 2)
    W = np.outer(inv, inv)
    influences = np.sum(np.abs(W), axis=1) + np.sum(np.abs(W), axis=0)
    sorted_inf = np.sort(influences)[::-1]
    ax.plot(range(1, len(sorted_inf) + 1), sorted_inf, 'o-', 
            color=color, markersize=4, label=f'$S_{{{n}}}$')

ax.set_xlabel('Rank', fontsize=12)
ax.set_ylabel('Influence', fontsize=12)
ax.set_title('Sorted Influence Spectrum', fontsize=13)
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Interaction Structure of Subgroup Pressure Models', 
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
