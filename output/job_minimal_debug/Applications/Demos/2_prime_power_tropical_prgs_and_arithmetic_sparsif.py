#!/usr/bin/env python3
"""
applications.py — Real-world applications of Prime-Power Arithmetic Sparsification.

Demonstrates how the uniform error bound from prime-power sampling applies to:
1. Cryptographic PRG design
2. Monte Carlo variance reduction
3. Signal processing with lacunary sampling
4. Network security parameter selection
"""

import numpy as np
from typing import Tuple


# ═══════════════════════════════════════════════════════════════
# Application 1: Cryptographic PRG Security Parameters
# ═══════════════════════════════════════════════════════════════

def prg_security_analysis(
    security_bits: int = 128,
    contraction_rates: list = None
) -> dict:
    """
    Determine PRG parameters for a target security level.

    In a prime-power PRG, the total statistical distance from ideal
    is bounded by ε₀/(1-r). For λ-bit security, we need this ≤ 2^(-λ).

    Returns parameter choices and their implications.
    """
    if contraction_rates is None:
        contraction_rates = [0.5, 0.7, 0.9, 0.95, 0.99]

    target = 2.0 ** (-security_bits)
    results = {}

    for r in contraction_rates:
        # ε₀/(1-r) ≤ 2^(-λ)  =>  ε₀ ≤ 2^(-λ) · (1-r)
        eps0_needed = target * (1.0 - r)
        eps0_bits = -np.log2(eps0_needed)

        # Dense orbit would need T ≤ 2^(-λ)/ε₀ - 1 for same security
        # With PP sampling, T is unlimited
        max_dense_T = int(1.0 / (1.0 - r)) - 1

        results[r] = {
            'contraction_rate': r,
            'eps0_needed': eps0_needed,
            'eps0_bits': eps0_bits,
            'max_dense_T_for_same_security': max_dense_T,
            'pp_max_T': 'unlimited',
        }

    return results


# ═══════════════════════════════════════════════════════════════
# Application 2: Monte Carlo Variance Reduction
# ═══════════════════════════════════════════════════════════════

def monte_carlo_comparison(
    n_trials: int = 10000,
    eps0: float = 0.1,
    r: float = 0.6,
    T_values: list = None
) -> dict:
    """
    Compare Monte Carlo estimation using dense vs prime-power sampling.

    Simulates estimating a quantity where each sample has error
    that decays geometrically at prime-power indices.
    """
    if T_values is None:
        T_values = [10, 50, 100, 500]

    rng = np.random.default_rng(42)
    results = {}

    for T in T_values:
        # Prime-power sampling: errors decay geometrically
        pp_errors = eps0 * r ** np.arange(T + 1)
        pp_samples = rng.normal(0, pp_errors)
        pp_cumulative = np.cumsum(np.abs(pp_samples))

        # Dense sampling: errors stay constant at eps0
        dense_errors = np.full(T + 1, eps0)
        dense_samples = rng.normal(0, dense_errors)
        dense_cumulative = np.cumsum(np.abs(dense_samples))

        results[T] = {
            'T': T,
            'pp_total_error': float(pp_cumulative[-1]),
            'pp_bound': eps0 / (1.0 - r),
            'dense_total_error': float(dense_cumulative[-1]),
            'dense_bound': (T + 1) * eps0,
            'improvement_factor': float(dense_cumulative[-1] / max(pp_cumulative[-1], 1e-15)),
        }

    return results


# ═══════════════════════════════════════════════════════════════
# Application 3: Network Security Parameter Selection
# ═══════════════════════════════════════════════════════════════

def network_security_parameters(
    num_rounds: list = None,
    base_collision_prob: float = 0.01,
    contraction: float = 0.7
) -> dict:
    """
    Design secure network protocols using prime-power round scheduling.

    In a multi-round protocol, collision/attack probability accumulates.
    Dense rounds: total prob ≈ T · p_base (linear growth, eventually insecure).
    PP rounds: total prob ≤ p_base / (1-r) (bounded, perpetually secure).
    """
    if num_rounds is None:
        num_rounds = [10, 100, 1000, 10000]

    pp_bound = base_collision_prob / (1.0 - contraction)
    results = {}

    for T in num_rounds:
        dense_prob = min(T * base_collision_prob, 1.0)
        pp_actual = sum(
            base_collision_prob * contraction ** j
            for j in range(T)
        )
        results[T] = {
            'rounds': T,
            'dense_collision_prob': dense_prob,
            'pp_collision_prob': pp_actual,
            'pp_bound': pp_bound,
            'secure_dense': dense_prob < 0.01,
            'secure_pp': pp_bound < 0.01 or pp_actual < 0.01,
        }

    return results


# ═══════════════════════════════════════════════════════════════
# Application 4: Signal Reconstruction Quality
# ═══════════════════════════════════════════════════════════════

def signal_reconstruction_quality(
    signal_length: int = 1024,
    p: int = 2,
    T: int = 10,
    noise_decay: float = 0.5
) -> dict:
    """
    Analyze signal reconstruction quality with lacunary (prime-power) sampling.

    When sampling a signal at positions p^0, p^1, ..., p^T,
    the reconstruction error at each level decays geometrically,
    giving bounded total error regardless of signal length.
    """
    sample_positions = [p ** k for k in range(T + 1) if p ** k < signal_length]
    T_actual = len(sample_positions) - 1

    errors = [noise_decay ** k for k in range(T_actual + 1)]
    total_error = sum(errors)
    bound = 1.0 / (1.0 - noise_decay)

    # Uniform sampling comparison
    n_uniform = T_actual + 1
    uniform_error = n_uniform  # each sample contributes ~1 unit of error

    return {
        'signal_length': signal_length,
        'prime': p,
        'sample_positions': sample_positions,
        'num_samples': len(sample_positions),
        'per_sample_errors': errors,
        'total_error': total_error,
        'uniform_bound': bound,
        'uniform_sampling_error': uniform_error,
        'improvement': uniform_error / total_error,
    }


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Cryptographic PRG Security Parameters")
    print("=" * 70)
    results = prg_security_analysis(128)
    for r, info in results.items():
        print(f"  r={r:.2f}: need ε₀ ≤ 2^(-{info['eps0_bits']:.1f}), "
              f"dense limited to T≤{info['max_dense_T_for_same_security']}")

    print()
    print("=" * 70)
    print("APPLICATION 2: Monte Carlo Variance Reduction")
    print("=" * 70)
    results = monte_carlo_comparison()
    for T, info in results.items():
        print(f"  T={T:4d}: PP={info['pp_total_error']:.4f} "
              f"(bound {info['pp_bound']:.4f}), "
              f"Dense={info['dense_total_error']:.4f} "
              f"(bound {info['dense_bound']:.1f}), "
              f"improvement={info['improvement_factor']:.1f}×")

    print()
    print("=" * 70)
    print("APPLICATION 3: Network Security Parameters")
    print("=" * 70)
    results = network_security_parameters()
    for T, info in results.items():
        print(f"  T={T:5d}: Dense prob={info['dense_collision_prob']:.4f} "
              f"({'SECURE' if info['secure_dense'] else 'INSECURE'}), "
              f"PP prob={info['pp_collision_prob']:.6f} "
              f"({'SECURE' if info['secure_pp'] else 'INSECURE'})")

    print()
    print("=" * 70)
    print("APPLICATION 4: Signal Reconstruction Quality")
    print("=" * 70)
    result = signal_reconstruction_quality()
    print(f"  Samples: {result['num_samples']} at positions {result['sample_positions']}")
    print(f"  Total error: {result['total_error']:.4f} ≤ {result['uniform_bound']:.4f}")
    print(f"  vs uniform: {result['uniform_sampling_error']:.4f}")
    print(f"  Improvement: {result['improvement']:.1f}×")

    print("\nAll applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of Prime-Power Tropical PRG Error Bounds.

Shows concrete examples of how arithmetic sparsification (sampling at prime-power
indices) yields uniformly bounded cumulative error, in contrast to linear growth
for dense orbit sampling.
"""

import numpy as np

def stagewise_decay(eps0: float, r: float, T: int) -> np.ndarray:
    """Compute err(j) = eps0 * r^j for j = 0, ..., T."""
    return eps0 * r ** np.arange(T + 1)

def cumulative_error(eps0: float, r: float, T: int) -> float:
    """Sum of err(j) for j = 0, ..., T."""
    return np.sum(stagewise_decay(eps0, r, T))

def geometric_bound(eps0: float, r: float) -> float:
    """The uniform bound eps0 / (1 - r)."""
    return eps0 / (1.0 - r)

def dense_orbit_bound(eps0: float, T: int) -> float:
    """The naive dense-orbit bound (T+1) * eps0."""
    return (T + 1) * eps0


# ─────────────────────────────────────────────────
# Demo 1: Stagewise decay visualization
# ─────────────────────────────────────────────────
def demo_stagewise():
    eps0, r = 0.1, 0.6
    T = 20
    errors = stagewise_decay(eps0, r, T)
    print("═" * 60)
    print("DEMO 1: Stagewise Geometric Decay")
    print(f"  ε₀ = {eps0}, r = {r}")
    print("═" * 60)
    for j, e in enumerate(errors):
        bar = "█" * int(e * 500)
        print(f"  j={j:2d}  err(j) = {e:.6f}  {bar}")
    print()


# ─────────────────────────────────────────────────
# Demo 2: Cumulative error vs uniform bound
# ─────────────────────────────────────────────────
def demo_cumulative():
    eps0, r = 0.1, 0.7
    bound = geometric_bound(eps0, r)
    print("═" * 60)
    print("DEMO 2: Cumulative Error vs Uniform Bound")
    print(f"  ε₀ = {eps0}, r = {r}, bound = ε₀/(1-r) = {bound:.6f}")
    print("═" * 60)
    for T in [1, 2, 5, 10, 20, 50, 100, 500, 1000]:
        cum = cumulative_error(eps0, r, T)
        ratio = cum / bound * 100
        print(f"  T={T:4d}  Σerr = {cum:.6f}  bound = {bound:.6f}  "
              f"({ratio:.1f}% of bound)")
    print()


# ─────────────────────────────────────────────────
# Demo 3: Prime-power vs dense orbit comparison
# ─────────────────────────────────────────────────
def demo_comparison():
    eps0 = 0.05
    r = 0.5
    pp_bound = geometric_bound(eps0, r)
    print("═" * 60)
    print("DEMO 3: Prime-Power vs Dense Orbit Bounds")
    print(f"  ε₀ = {eps0}, r = {r}")
    print(f"  Prime-power bound: {pp_bound:.4f} (UNIFORM for all T)")
    print("═" * 60)
    for T in [1, 5, 10, 50, 100, 500, 1000]:
        dense = dense_orbit_bound(eps0, T)
        ratio = dense / pp_bound
        print(f"  T={T:4d}  Dense: {dense:8.2f}  PP: {pp_bound:.4f}  "
              f"Dense/PP = {ratio:.1f}×")
    print()


# ─────────────────────────────────────────────────
# Demo 4: Fiber decorrelation
# ─────────────────────────────────────────────────
def demo_decorrelation():
    C0, rho = 1.0, 0.4
    print("═" * 60)
    print("DEMO 4: Prime-Power Fiber Decorrelation Matrix")
    print(f"  C₀ = {C0}, ρ = {rho}")
    print(f"  C(p^i, p^j) ≤ C₀ · ρ^|i-j|")
    print("═" * 60)
    N = 8
    print("      ", end="")
    for j in range(N):
        print(f"  j={j:d}   ", end="")
    print()
    for i in range(N):
        print(f"  i={i:d}", end="")
        for j in range(N):
            val = C0 * rho ** abs(i - j)
            print(f"  {val:.4f}", end="")
        print()
    bound = C0 * (2.0 / (1 - rho) - 1)
    print(f"\n  Row sum bound: C₀ · (2/(1-ρ) - 1) = {bound:.4f}")
    for i in range(N):
        row_sum = sum(C0 * rho ** abs(i - j) for j in range(100))
        print(f"  Row i={i}: sum (T=99) = {row_sum:.4f} ≤ {bound:.4f}")
    print()


# ─────────────────────────────────────────────────
# Demo 5: Varying contraction rate
# ─────────────────────────────────────────────────
def demo_varying_r():
    eps0 = 0.1
    print("═" * 60)
    print("DEMO 5: Effect of Contraction Rate r")
    print(f"  ε₀ = {eps0}")
    print("═" * 60)
    for r in [0.1, 0.2, 0.3, 0.5, 0.7, 0.8, 0.9, 0.95, 0.99]:
        bound = geometric_bound(eps0, r)
        T_crossover = int(np.ceil(1.0 / (1.0 - r)))
        print(f"  r={r:.2f}  bound={bound:.4f}  "
              f"PP beats dense at T≥{T_crossover}")
    print()


if __name__ == "__main__":
    demo_stagewise()
    demo_cumulative()
    demo_comparison()
    demo_decorrelation()
    demo_varying_r()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables bundled."""

import json
from visualizations import generate_all_figures

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Tropical/PRG/PrimePowerAmplification.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations
print("Generating visualizations...")
figs = generate_all_figures()

package = {
    "title": "Prime-Power Tropical PRGs and Arithmetic Sparsification",
    "domain": "Tropical Mathematics / Pseudorandom Generation / Arithmetic Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Prime-Power Error Bound Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Geometric Error Bound Computation",
            "pseudocode": "ComputeGeometricBound(eps0, r, T):\n  For j = 0..T: err[j] = eps0 * r^j\n  cumulative = sum(err)\n  bound = eps0 / (1 - r)\n  Return (err, cumulative, bound)\n\nTime: O(T), Space: O(T)",
            "code": algorithms_code
        },
        {
            "name": "Fiber Decorrelation Analysis",
            "pseudocode": "FiberDecorrelation(C0, rho, N):\n  For i,j = 0..N-1: C[i,j] = C0 * rho^|i-j|\n  row_sums[i] = sum_j C[i,j]\n  bound = C0 * (2/(1-rho) - 1)\n  Return (C, row_sums, bound)\n\nTime: O(N^2), Space: O(N^2)",
            "code": algorithms_code
        },
        {
            "name": "Crossover Point Computation",
            "pseudocode": "CrossoverPoint(eps0, r):\n  T* = ceil(1/(1-r))\n  Return T*\n\nTime: O(1), Space: O(1)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Stagewise Geometric Decay of Prime-Power Errors",
            "data": figs['stagewise_decay']
        },
        {
            "name": "Prime-Power vs Dense Orbit Cumulative Error",
            "data": figs['cumulative_comparison']
        },
        {
            "name": "Fiber Decorrelation Heatmap",
            "data": figs['decorrelation_heatmap']
        },
        {
            "name": "Contraction Rate Sensitivity Analysis",
            "data": figs['contraction_sensitivity']
        },
        {
            "name": "Error Decay Across Different Prime Bases",
            "data": figs['multi_prime']
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
visualizations.py — Generate figures for Prime-Power Arithmetic Sparsification.

Produces publication-quality charts showing:
1. Stagewise geometric decay of errors
2. Cumulative error: prime-power vs dense orbit
3. Fiber decorrelation heatmap
4. Contraction rate sensitivity analysis
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_stagewise_decay():
    """Figure 1: Stagewise geometric decay of prime-power errors."""
    fig, ax = plt.subplots(figsize=(10, 6))

    eps0 = 0.1
    T = 20
    js = np.arange(T + 1)

    for r, color, ls in [(0.3, '#2196F3', '-'),
                          (0.5, '#4CAF50', '--'),
                          (0.7, '#FF9800', '-.'),
                          (0.9, '#F44336', ':')]:
        errors = eps0 * r ** js
        ax.semilogy(js, errors, color=color, linestyle=ls, linewidth=2.5,
                    marker='o', markersize=5, label=f'r = {r}')

    ax.set_xlabel('Stage j (prime-power index p^j)', fontsize=14)
    ax.set_ylabel('Error err(j)', fontsize=14)
    ax.set_title('Stagewise Geometric Decay of Prime-Power Errors',
                fontsize=16, fontweight='bold')
    ax.legend(fontsize=12, framealpha=0.9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, T + 0.5)

    return fig


def plot_cumulative_comparison():
    """Figure 2: Cumulative error — prime-power bound vs dense orbit."""
    fig, ax = plt.subplots(figsize=(10, 6))

    eps0 = 0.1
    r = 0.6
    T_max = 50
    Ts = np.arange(1, T_max + 1)

    # Prime-power cumulative
    pp_cum = np.array([np.sum(eps0 * r ** np.arange(T + 1)) for T in Ts])
    pp_bound = eps0 / (1.0 - r)

    # Dense orbit cumulative
    dense_cum = (Ts + 1) * eps0

    ax.plot(Ts, pp_cum, color='#2196F3', linewidth=2.5,
            label='Prime-power cumulative error')
    ax.axhline(y=pp_bound, color='#2196F3', linestyle='--', linewidth=1.5,
              label=f'PP uniform bound: ε₀/(1-r) = {pp_bound:.3f}')
    ax.plot(Ts, dense_cum, color='#F44336', linewidth=2.5,
            label='Dense orbit cumulative error')

    # Shade the gap
    ax.fill_between(Ts, pp_cum, dense_cum, alpha=0.15, color='#F44336')

    # Mark crossover
    crossover = int(np.ceil(1.0 / (1.0 - r)))
    ax.axvline(x=crossover, color='gray', linestyle=':', linewidth=1.5,
              label=f'Crossover at T = {crossover}')

    ax.set_xlabel('Truncation length T', fontsize=14)
    ax.set_ylabel('Cumulative error', fontsize=14)
    ax.set_title('Prime-Power vs Dense Orbit: Cumulative Error Growth',
                fontsize=16, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left', framealpha=0.9)
    ax.grid(True, alpha=0.3)

    return fig


def plot_decorrelation_heatmap():
    """Figure 3: Fiber decorrelation heatmap C(p^i, p^j) ≤ C₀ · ρ^|i-j|."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    N = 12
    for ax, (rho, title) in zip(axes, [(0.3, 'Strong decorrelation (ρ=0.3)'),
                                         (0.8, 'Weak decorrelation (ρ=0.8)')]):
        C = np.array([[rho ** abs(i - j) for j in range(N)] for i in range(N)])
        im = ax.imshow(C, cmap='YlOrRd_r', vmin=0, vmax=1, aspect='equal')
        ax.set_xlabel('Stage j', fontsize=12)
        ax.set_ylabel('Stage i', fontsize=12)
        ax.set_title(title, fontsize=14, fontweight='bold')
        plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('Prime-Power Fiber Collision Bounds C(p^i, p^j)',
                fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig


def plot_contraction_sensitivity():
    """Figure 4: Uniform bound as a function of contraction rate."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    eps0 = 0.1
    rs = np.linspace(0.01, 0.99, 200)
    bounds = eps0 / (1.0 - rs)

    # Left: bound vs r
    ax1.plot(rs, bounds, color='#2196F3', linewidth=2.5)
    ax1.fill_between(rs, 0, bounds, alpha=0.1, color='#2196F3')
    ax1.set_xlabel('Contraction rate r', fontsize=14)
    ax1.set_ylabel('Uniform bound ε₀/(1-r)', fontsize=14)
    ax1.set_title('Uniform Error Bound vs Contraction Rate',
                 fontsize=14, fontweight='bold')
    ax1.set_ylim(0, 5)
    ax1.grid(True, alpha=0.3)

    # Annotate key points
    for r_val in [0.5, 0.7, 0.9]:
        b = eps0 / (1.0 - r_val)
        ax1.plot(r_val, b, 'ro', markersize=8)
        ax1.annotate(f'r={r_val}\nbound={b:.2f}',
                    xy=(r_val, b), xytext=(r_val - 0.15, b + 0.3),
                    fontsize=10, ha='center',
                    arrowprops=dict(arrowstyle='->', color='gray'))

    # Right: crossover T vs r
    crossovers = 1.0 / (1.0 - rs)
    ax2.semilogy(rs, crossovers, color='#4CAF50', linewidth=2.5)
    ax2.set_xlabel('Contraction rate r', fontsize=14)
    ax2.set_ylabel('Crossover length T*', fontsize=14)
    ax2.set_title('Crossover: When PP Beats Dense Orbit',
                 fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


def plot_multi_prime():
    """Figure 5: Comparison across different primes."""
    fig, ax = plt.subplots(figsize=(10, 6))

    eps0 = 0.1
    r = 0.5
    T = 15

    primes = [2, 3, 5, 7, 11]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']

    for p, color in zip(primes, colors):
        js = np.arange(T + 1)
        orbit_times = p ** js
        errors = eps0 * r ** js

        ax.semilogy(orbit_times, errors, 'o-', color=color,
                   linewidth=1.5, markersize=6, label=f'p = {p}')

    bound = eps0 / (1.0 - r)
    ax.axhline(y=bound, color='black', linestyle='--', linewidth=1.5,
              label=f'Uniform bound = {bound:.2f}', alpha=0.5)

    ax.set_xlabel('Orbit time n = p^j', fontsize=14)
    ax.set_ylabel('Stage error err(j)', fontsize=14)
    ax.set_title('Error Decay Across Different Prime Bases',
                fontsize=16, fontweight='bold')
    ax.legend(fontsize=11, framealpha=0.9)
    ax.grid(True, alpha=0.3)
    ax.set_xscale('log')

    return fig


def generate_all_figures():
    """Generate all figures and return as base64 data URIs."""
    figures = {}

    print("Generating Figure 1: Stagewise decay...")
    figures['stagewise_decay'] = fig_to_base64(plot_stagewise_decay())

    print("Generating Figure 2: Cumulative comparison...")
    figures['cumulative_comparison'] = fig_to_base64(plot_cumulative_comparison())

    print("Generating Figure 3: Decorrelation heatmap...")
    figures['decorrelation_heatmap'] = fig_to_base64(plot_decorrelation_heatmap())

    print("Generating Figure 4: Contraction sensitivity...")
    figures['contraction_sensitivity'] = fig_to_base64(plot_contraction_sensitivity())

    print("Generating Figure 5: Multi-prime comparison...")
    figures['multi_prime'] = fig_to_base64(plot_multi_prime())

    return figures


if __name__ == "__main__":
    # Generate and save figures
    figs = generate_all_figures()
    for name, data in figs.items():
        # Save as standalone files too
        img_data = base64.b64decode(data.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(img_data)
        print(f"Saved {name}.png ({len(img_data)} bytes)")

    print(f"\nGenerated {len(figs)} figures successfully.")
