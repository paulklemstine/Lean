#!/usr/bin/env python3
"""
Applications of the SSH Newton-Order Phase Diagnostic

Demonstrates practical applications of the Newton ratio profile
as a phase detection tool for quantum systems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─── Core computational functions (self-contained) ────────────────────

def build_ssh_correlation_matrix(m, delta, n_k=8192):
    """Build the SSH half-chain correlation matrix."""
    t1, t2 = 1.0 + delta, 1.0 - delta
    k_vals = np.linspace(0, np.pi, n_k, endpoint=False) + np.pi / (2 * n_k)
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)
    c_coeffs = np.array([(2.0/n_k) * np.sum(f_k * np.cos(n*k_vals)) for n in range(m)])
    C = np.array([[c_coeffs[abs(i-j)] for j in range(m)] for i in range(m)])
    return C

def ssh_eigenvalues(m, delta):
    C = build_ssh_correlation_matrix(m, delta)
    eigs = np.clip(np.linalg.eigvalsh(C), 1e-15, 1-1e-15)
    return np.sort(eigs)

def esymm_stable(eigenvalues):
    m = len(eigenvalues)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e

def sup_newton_gap(e):
    m = len(e) - 1
    if m <= 1:
        return 0.0
    gaps = []
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            gap = np.log(e[k-1]) + np.log(e[k+1]) - 2*np.log(e[k])
            gaps.append(gap)
    return max(gaps) if gaps else 0.0

def entanglement_entropy(eigenvalues):
    """Compute von Neumann entanglement entropy from correlation eigenvalues."""
    S = 0.0
    for lam in eigenvalues:
        if 0 < lam < 1:
            S -= lam * np.log(lam) + (1-lam) * np.log(1-lam)
    return S


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Phase Boundary Detection
# ═══════════════════════════════════════════════════════════════════════

def app_phase_boundary():
    """
    Detect the phase boundary of the SSH model by scanning delta
    and measuring the Newton gap growth rate.
    """
    print("Application 1: Phase Boundary Detection")
    print("-" * 50)

    delta_range = np.linspace(-0.5, 0.5, 41)
    m_test = [16, 32]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for m in m_test:
        gaps = []
        entropies = []
        for delta in delta_range:
            eigs = ssh_eigenvalues(m, delta)
            e = esymm_stable(eigs)
            g = sup_newton_gap(e)
            S = entanglement_entropy(eigs)
            gaps.append(g)
            entropies.append(S)
        ax1.plot(delta_range, gaps, 'o-', label=f'm={m}', markersize=3)
        ax2.plot(delta_range, entropies, 'o-', label=f'm={m}', markersize=3)

    ax1.set_xlabel('δ (dimerization)', fontsize=12)
    ax1.set_ylabel('sup Newton gap', fontsize=12)
    ax1.set_title('Newton Gap vs Dimerization', fontsize=13)
    ax1.axvline(x=0, color='red', linestyle='--', alpha=0.7, label='critical')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.set_xlabel('δ (dimerization)', fontsize=12)
    ax2.set_ylabel('Entanglement entropy', fontsize=12)
    ax2.set_title('Entropy vs Dimerization', fontsize=13)
    ax2.axvline(x=0, color='red', linestyle='--', alpha=0.7, label='critical')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('app_phase_boundary.png', dpi=150)
    print("Saved: app_phase_boundary.png")

    # Print the transition
    for m in m_test:
        gaps = []
        for delta in delta_range:
            eigs = ssh_eigenvalues(m, delta)
            e = esymm_stable(eigs)
            gaps.append(sup_newton_gap(e))
        peak_idx = np.argmax(np.abs(gaps))
        print(f"  m={m}: peak Newton gap at δ = {delta_range[peak_idx]:.3f}, "
              f"gap = {gaps[peak_idx]:.4f}")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Comparison with Entanglement Entropy
# ═══════════════════════════════════════════════════════════════════════

def app_entropy_comparison():
    """
    Compare Newton gap diagnostic with standard entanglement entropy.
    Show that Newton gap provides complementary information.
    """
    print("\nApplication 2: Newton Gap vs Entropy Comparison")
    print("-" * 50)

    m_values = [4, 8, 12, 16, 24, 32, 48]
    deltas = [0.0, 0.1, 0.3]

    for delta in deltas:
        name = "critical" if delta == 0 else f"gapped (δ={delta})"
        print(f"\n  {name}:")
        print(f"  {'m':>4}  {'Newton gap':>12}  {'Entropy':>12}  {'Ratio':>12}")
        for m in m_values:
            eigs = ssh_eigenvalues(m, delta)
            e = esymm_stable(eigs)
            gap = sup_newton_gap(e)
            S = entanglement_entropy(eigs)
            ratio = gap / S if S > 0 else 0
            print(f"  {m:>4}  {gap:>12.6f}  {S:>12.6f}  {ratio:>12.6f}")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Random Matrix Benchmark
# ═══════════════════════════════════════════════════════════════════════

def app_random_matrix_benchmark():
    """
    Compare SSH Newton gaps with those from random correlation matrices.
    Shows that the SSH critical behavior is special.
    """
    print("\nApplication 3: Random Matrix Benchmark")
    print("-" * 50)

    np.random.seed(42)
    m = 32
    n_samples = 20

    # Random Wishart-type correlation matrices
    random_gaps = []
    for _ in range(n_samples):
        # Random eigenvalues uniformly in [0.1, 0.9]
        lam = np.random.uniform(0.1, 0.9, m)
        e = esymm_stable(lam)
        random_gaps.append(sup_newton_gap(e))

    # SSH critical
    ssh_crit_eigs = ssh_eigenvalues(m, 0.0)
    ssh_crit_gap = sup_newton_gap(esymm_stable(ssh_crit_eigs))

    # SSH gapped
    ssh_gap_eigs = ssh_eigenvalues(m, 0.3)
    ssh_gap_gap = sup_newton_gap(esymm_stable(ssh_gap_eigs))

    print(f"  Random (m={m}): mean gap = {np.mean(random_gaps):.4f} ± {np.std(random_gaps):.4f}")
    print(f"  SSH critical:   gap = {ssh_crit_gap:.4f}")
    print(f"  SSH gapped:     gap = {ssh_gap_gap:.4f}")


if __name__ == "__main__":
    app_phase_boundary()
    app_entropy_comparison()
    app_random_matrix_benchmark()
    print("\n✓ All applications complete.")


#!/usr/bin/env python3
"""
SSH Newton-Order Phase Diagnostic: Interactive Demonstration

Computes and visualizes the Newton ratio profile and supremal Newton gap
for the Su-Schrieffer-Heeger (SSH) model at various dimerization strengths.
Demonstrates bounded vs. divergent Newton order across the phase transition.

Usage:
    python demo.py
"""

import numpy as np
from numpy.polynomial.polynomial import polyfromroots
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─── SSH Correlation Eigenvalues ───────────────────────────────────────

def ssh_correlation_eigenvalues(m, delta):
    """
    Compute the m eigenvalues of the SSH half-chain correlation matrix
    for a block of size m at half filling with dimerization delta.

    The SSH Hamiltonian in momentum space has dispersion
      epsilon(k) = sqrt((1+delta)^2 + (1-delta)^2 + 2(1-delta^2)cos(k))
    The correlation eigenvalues of the half-chain block are the eigenvalues
    of the m×m matrix C_{ij} = (1/pi) int_0^pi f(k) cos((i-j)k) dk,
    where f(k) = (1 - h(k)/epsilon(k))/2 is the Fermi function at half filling.

    For simplicity and numerical stability, we construct C directly via
    Toeplitz structure.
    """
    if m == 0:
        return np.array([])

    t1 = 1.0 + delta  # intracell hopping
    t2 = 1.0 - delta  # intercell hopping

    # Build the m×m Toeplitz correlation matrix
    # C_{ij} depends on |i-j| via Fourier coefficients
    nk = max(4096, 8 * m)  # number of k-points for numerical integration
    k_vals = np.linspace(0, np.pi, nk, endpoint=False) + np.pi / (2 * nk)

    # SSH dispersion
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))

    # Lower band occupation (correlation function in k-space)
    # For SSH: f(k) = 1/2 (1 - (t1 + t2 cos k)/epsilon(k))
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)

    # Toeplitz matrix entries: c_n = (2/pi) int_0^pi f(k) cos(nk) dk
    C = np.zeros((m, m))
    for i in range(m):
        for j in range(m):
            n = abs(i - j)
            c_n = (2.0 / nk) * np.sum(f_k * np.cos(n * k_vals))
            C[i, j] = c_n

    eigenvalues = np.linalg.eigvalsh(C)
    eigenvalues = np.clip(eigenvalues, 1e-15, 1.0 - 1e-15)
    return np.sort(eigenvalues)


# ─── Elementary Symmetric Polynomials ──────────────────────────────────

def esymm_from_eigenvalues(lam):
    """
    Compute elementary symmetric polynomials e_0, ..., e_m from eigenvalues.
    Uses the generating function: prod_i (1 + lam_i * t) = sum_k e_k t^k.
    Numerically stable via polynomial multiplication.
    """
    m = len(lam)
    # Coefficients of prod_i (1 + lam_i * t)
    poly = np.array([1.0])
    for li in lam:
        poly = np.convolve(poly, [1.0, li])
    return poly  # e_0, e_1, ..., e_m


def newton_ratio_profile(e_k):
    """
    Compute the Newton ratio profile R_k = e_k^2 / (e_{k-1} * e_{k+1})
    for k = 1, ..., m-1.
    Returns log(R_k) values (negative of the Newton gap).
    """
    m = len(e_k) - 1
    if m <= 1:
        return np.array([])

    log_ratios = []
    for k in range(1, m):
        if e_k[k-1] > 0 and e_k[k] > 0 and e_k[k+1] > 0:
            log_R = 2 * np.log(e_k[k]) - np.log(e_k[k-1]) - np.log(e_k[k+1])
            log_ratios.append(log_R)
        else:
            log_ratios.append(0.0)
    return np.array(log_ratios)


def sup_newton_gap(e_k):
    """
    Compute the supremal Newton gap:
    sup_{1 <= k <= m-1} [log(e_{k-1} * e_{k+1}) - 2*log(e_k)]
    = sup_k (-log R_k) = -inf_k log R_k
    """
    log_ratios = newton_ratio_profile(e_k)
    if len(log_ratios) == 0:
        return 0.0
    # Newton gap at k = log(e_{k-1}) + log(e_{k+1}) - 2*log(e_k)
    # = -log(R_k)
    gaps = -log_ratios
    return np.max(gaps)


# ─── Main Demonstration ───────────────────────────────────────────────

def demo_gapped_vs_critical():
    """
    Compare Newton gap behavior for gapped (delta != 0) vs critical (delta = 0).
    """
    print("=" * 70)
    print("SSH Newton-Order Phase Diagnostic")
    print("=" * 70)

    # System sizes to test
    m_values = [4, 8, 12, 16, 20, 24, 32, 40, 48, 64]

    # Dimerization values: 0 = critical, nonzero = gapped
    delta_values = [0.0, 0.1, 0.3, 0.5]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: supNewtonGap vs m for different delta
    ax1 = axes[0, 0]
    for delta in delta_values:
        gaps = []
        for m in m_values:
            lam = ssh_correlation_eigenvalues(m, delta)
            e_k = esymm_from_eigenvalues(lam)
            g = sup_newton_gap(e_k)
            gaps.append(g)
        label = f"δ = {delta}" if delta > 0 else "δ = 0 (critical)"
        ax1.plot(m_values, gaps, 'o-', label=label, linewidth=2)
    ax1.set_xlabel("Subsystem size m", fontsize=12)
    ax1.set_ylabel("sup Newton gap", fontsize=12)
    ax1.set_title("Newton Gap vs System Size", fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: supNewtonGap vs log(m)
    ax2 = axes[0, 1]
    for delta in delta_values:
        gaps = []
        for m in m_values:
            lam = ssh_correlation_eigenvalues(m, delta)
            e_k = esymm_from_eigenvalues(lam)
            g = sup_newton_gap(e_k)
            gaps.append(g)
        label = f"δ = {delta}" if delta > 0 else "δ = 0 (critical)"
        ax2.plot(np.log(m_values), gaps, 'o-', label=label, linewidth=2)
    ax2.set_xlabel("log(m)", fontsize=12)
    ax2.set_ylabel("sup Newton gap", fontsize=12)
    ax2.set_title("Newton Gap vs log(m)", fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Newton ratio profile for fixed m, varying delta
    ax3 = axes[1, 0]
    m_fixed = 32
    for delta in delta_values:
        lam = ssh_correlation_eigenvalues(m_fixed, delta)
        e_k = esymm_from_eigenvalues(lam)
        profile = newton_ratio_profile(e_k)
        k_range = np.arange(1, len(profile) + 1)
        label = f"δ = {delta}" if delta > 0 else "δ = 0 (critical)"
        ax3.plot(k_range, profile, 'o-', label=label, markersize=3)
    ax3.set_xlabel("Index k", fontsize=12)
    ax3.set_ylabel("log(R_k)", fontsize=12)
    ax3.set_title(f"Newton Ratio Profile (m={m_fixed})", fontsize=13)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Eigenvalue spectrum for fixed m, varying delta
    ax4 = axes[1, 1]
    for delta in delta_values:
        lam = ssh_correlation_eigenvalues(m_fixed, delta)
        label = f"δ = {delta}" if delta > 0 else "δ = 0 (critical)"
        ax4.plot(range(len(lam)), lam, 'o-', label=label, markersize=4)
    ax4.set_xlabel("Eigenvalue index", fontsize=12)
    ax4.set_ylabel("λ_i", fontsize=12)
    ax4.set_title(f"Correlation Eigenvalue Spectrum (m={m_fixed})", fontsize=13)
    ax4.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax4.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("ssh_newton_order_demo.png", dpi=150)
    print("\nPlot saved to ssh_newton_order_demo.png")

    # Print numerical results
    print("\n" + "=" * 70)
    print("Numerical Results: sup Newton Gap")
    print("=" * 70)
    print(f"{'m':>6} | " + " | ".join(f"δ={d:.1f}" for d in delta_values))
    print("-" * 70)
    for m in m_values:
        row = f"{m:>6} | "
        for delta in delta_values:
            lam = ssh_correlation_eigenvalues(m, delta)
            e_k = esymm_from_eigenvalues(lam)
            g = sup_newton_gap(e_k)
            row += f"{g:>8.4f} | "
        print(row)


def demo_maximizing_index():
    """
    Track which index k*(m) achieves the supremal Newton gap.
    """
    print("\n" + "=" * 70)
    print("Maximizing Index k*(m) Analysis")
    print("=" * 70)

    m_values = [8, 16, 24, 32, 48, 64]

    for delta in [0.0, 0.3]:
        name = "critical" if delta == 0 else f"gapped (δ={delta})"
        print(f"\n  {name}:")
        print(f"  {'m':>4}  {'k*':>4}  {'k*/m':>8}  {'gap':>10}")
        for m in m_values:
            lam = ssh_correlation_eigenvalues(m, delta)
            e_k = esymm_from_eigenvalues(lam)
            profile = newton_ratio_profile(e_k)
            if len(profile) > 0:
                gaps = -profile
                k_star = np.argmax(gaps) + 1
                max_gap = np.max(gaps)
                print(f"  {m:>4}  {k_star:>4}  {k_star/m:>8.3f}  {max_gap:>10.4f}")


if __name__ == "__main__":
    demo_gapped_vs_critical()
    demo_maximizing_index()
    print("\n✓ Demo complete.")


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Spectrum and Newton Ratio Profile

Shows how the correlation eigenvalue spectrum changes from gapped to critical,
and how this manifests in the Newton ratio profile. The top row shows eigenvalues
clustering away from 0 and 1 in the gapped phase (spectral pinching), while
spreading to the full interval [0,1] at criticality. The bottom row shows the
corresponding Newton ratio profiles.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def build_ssh_correlation_matrix(m, delta, n_k=8192):
    t1, t2 = 1.0 + delta, 1.0 - delta
    k_vals = np.linspace(0, np.pi, n_k, endpoint=False) + np.pi / (2 * n_k)
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)
    c_coeffs = np.array([(2.0/n_k) * np.sum(f_k * np.cos(n*k_vals)) for n in range(m)])
    return np.array([[c_coeffs[abs(i-j)] for j in range(m)] for i in range(m)])

def ssh_eigenvalues(m, delta):
    C = build_ssh_correlation_matrix(m, delta)
    return np.sort(np.clip(np.linalg.eigvalsh(C), 1e-15, 1-1e-15))

def esymm_stable(eigenvalues):
    m = len(eigenvalues)
    e = np.zeros(m + 1); e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e

def newton_ratio_profile(e):
    m = len(e) - 1
    if m <= 1: return np.array([])
    log_R = np.zeros(m - 1)
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            log_R[k-1] = 2*np.log(e[k]) - np.log(e[k-1]) - np.log(e[k+1])
    return log_R

m = 32
delta_list = [0.0, 0.1, 0.3, 0.5]
fig, axes = plt.subplots(2, 4, figsize=(18, 8))

for col, delta in enumerate(delta_list):
    eigs = ssh_eigenvalues(m, delta)
    e = esymm_stable(eigs)
    profile = newton_ratio_profile(e)

    # Top: eigenvalue spectrum
    ax_top = axes[0, col]
    ax_top.bar(range(m), eigs, color='steelblue', alpha=0.8, width=0.8)
    ax_top.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax_top.axhline(y=1, color='red', linestyle='--', alpha=0.5)
    ax_top.set_ylim(-0.05, 1.05)
    ax_top.set_xlabel('Index i', fontsize=10)
    ax_top.set_ylabel('λᵢ', fontsize=11)
    title = f'δ = {delta}' if delta > 0 else 'δ = 0 (critical)'
    ax_top.set_title(title, fontsize=12, fontweight='bold')
    ax_top.grid(True, alpha=0.2)

    # Mark pinching region if gapped
    if delta > 0:
        eps = eigs.min()
        ax_top.axhspan(0, eps, alpha=0.1, color='red')
        ax_top.axhspan(1-eps, 1, alpha=0.1, color='red')

    # Bottom: Newton ratio profile
    ax_bot = axes[1, col]
    k_range = np.arange(1, len(profile) + 1)
    colors = ['green' if r > 0 else 'red' for r in profile]
    ax_bot.bar(k_range, profile, color=colors, alpha=0.7, width=0.8)
    ax_bot.axhline(y=0, color='black', linewidth=0.5)
    ax_bot.set_xlabel('Index k', fontsize=10)
    ax_bot.set_ylabel('log(Rₖ)', fontsize=11)
    ax_bot.set_title(f'Newton Ratios (m={m})', fontsize=11)
    ax_bot.grid(True, alpha=0.2)

plt.suptitle('SSH Model: Eigenvalue Spectrum and Newton Ratio Profile',
            fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: viz_eigenvalue_spectrum.png")


#!/usr/bin/env python3
"""
Visualization: Newton Ratio Profile Heatmap

Visualizes the full Newton ratio profile in the (m, k) plane for both
gapped and critical SSH phases. The heatmap reveals where log-concavity
violations concentrate as system size grows.

Key insight: At criticality (δ=0), a bright "ridge" of large Newton gaps
emerges near k ~ m/2, growing with m. In the gapped phase, the heatmap
stays uniformly dark (small gaps).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def build_ssh_correlation_matrix(m, delta, n_k=8192):
    t1, t2 = 1.0 + delta, 1.0 - delta
    k_vals = np.linspace(0, np.pi, n_k, endpoint=False) + np.pi / (2 * n_k)
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)
    c_coeffs = np.array([(2.0/n_k) * np.sum(f_k * np.cos(n*k_vals)) for n in range(m)])
    C = np.array([[c_coeffs[abs(i-j)] for j in range(m)] for i in range(m)])
    return C

def ssh_eigenvalues(m, delta):
    C = build_ssh_correlation_matrix(m, delta)
    eigs = np.clip(np.linalg.eigvalsh(C), 1e-15, 1-1e-15)
    return np.sort(eigs)

def esymm_stable(eigenvalues):
    m = len(eigenvalues)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e

def newton_gap_profile(e):
    m = len(e) - 1
    gaps = np.zeros(m - 1) if m > 1 else np.array([])
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            gaps[k-1] = np.log(e[k-1]) + np.log(e[k+1]) - 2*np.log(e[k])
    return gaps

# Parameters
m_values = list(range(4, 52, 2))
max_k = max(m_values) - 1

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, (delta, title) in enumerate([(0.0, 'Critical (δ = 0)'),
                                        (0.3, 'Gapped (δ = 0.3)')]):
    # Build heatmap data
    heatmap = np.full((len(m_values), max_k), np.nan)
    for i, m in enumerate(m_values):
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        gaps = newton_gap_profile(e)
        for j in range(len(gaps)):
            heatmap[i, j] = gaps[j]

    ax = axes[idx]
    im = ax.imshow(heatmap.T, aspect='auto', origin='lower',
                   extent=[m_values[0], m_values[-1], 1, max_k],
                   cmap='RdYlBu_r', interpolation='nearest')
    ax.set_xlabel('System size m', fontsize=12)
    ax.set_ylabel('Index k', fontsize=12)
    ax.set_title(title, fontsize=13)
    plt.colorbar(im, ax=ax, label='Newton gap')

plt.suptitle('Newton Ratio Profile Heatmap: SSH Model', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_newton_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_newton_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Phase Diagnostic — Bounded vs Divergent Newton Order

Creates a clear visual comparison of the Newton gap scaling behavior
in the gapped vs critical phases of the SSH model. The gapped phase
shows saturation (bounded), while the critical phase shows logarithmic
growth (divergent). This directly illustrates Theorems A and C.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def build_ssh_correlation_matrix(m, delta, n_k=8192):
    t1, t2 = 1.0 + delta, 1.0 - delta
    k_vals = np.linspace(0, np.pi, n_k, endpoint=False) + np.pi / (2 * n_k)
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)
    c_coeffs = np.array([(2.0/n_k) * np.sum(f_k * np.cos(n*k_vals)) for n in range(m)])
    return np.array([[c_coeffs[abs(i-j)] for j in range(m)] for i in range(m)])

def ssh_eigenvalues(m, delta):
    C = build_ssh_correlation_matrix(m, delta)
    return np.sort(np.clip(np.linalg.eigvalsh(C), 1e-15, 1-1e-15))

def esymm_stable(eigenvalues):
    m = len(eigenvalues)
    e = np.zeros(m + 1); e[0] = 1.0
    for i in range(m):
        for k in range(min(i+1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k-1]
    return e

def sup_newton_gap(e):
    m = len(e) - 1
    if m <= 1: return 0.0
    gaps = []
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            gaps.append(np.log(e[k-1]) + np.log(e[k+1]) - 2*np.log(e[k]))
    return max(gaps) if gaps else 0.0

# Compute data
m_values = [4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48]
delta_values = [0.0, 0.05, 0.1, 0.2, 0.3, 0.5]
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4', '#9467bd', '#8c564b']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: gap vs m (linear scale)
for delta, color in zip(delta_values, colors):
    gaps = []
    for m in m_values:
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        gaps.append(sup_newton_gap(e))
    label = 'δ = 0 (CRITICAL)' if delta == 0 else f'δ = {delta}'
    lw = 3 if delta == 0 else 1.5
    ax1.plot(m_values, gaps, 'o-', color=color, label=label, linewidth=lw, markersize=5)

ax1.set_xlabel('Subsystem size m', fontsize=13)
ax1.set_ylabel('sup Newton gap', fontsize=13)
ax1.set_title('Newton Gap: Linear Scale', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right: gap vs log(m) — test for logarithmic scaling
for delta, color in zip(delta_values, colors):
    gaps = []
    for m in m_values:
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        gaps.append(sup_newton_gap(e))
    label = 'δ = 0 (CRITICAL)' if delta == 0 else f'δ = {delta}'
    lw = 3 if delta == 0 else 1.5
    ax2.plot(np.log(m_values), gaps, 'o-', color=color, label=label, linewidth=lw, markersize=5)

# Add linear fit for critical case
crit_gaps = []
for m in m_values:
    eigs = ssh_eigenvalues(m, 0.0)
    e = esymm_stable(eigs)
    crit_gaps.append(sup_newton_gap(e))
log_m = np.log(m_values)
slope, intercept = np.polyfit(log_m, crit_gaps, 1)
fit_line = slope * log_m + intercept
ax2.plot(log_m, fit_line, '--', color='gray', linewidth=2,
         label=f'Linear fit: slope={slope:.3f}')

ax2.set_xlabel('log(m)', fontsize=13)
ax2.set_ylabel('sup Newton gap', fontsize=13)
ax2.set_title('Newton Gap vs log(m): Testing Logarithmic Divergence', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate('Bounded\n(gapped)', xy=(log_m[-1], 0.1), fontsize=11,
            ha='right', color='#1f77b4', weight='bold')
ax2.annotate('Growing\n(critical)', xy=(log_m[-1], crit_gaps[-1]),
            fontsize=11, ha='right', color='#d62728', weight='bold')

plt.tight_layout()
plt.savefig('viz_phase_diagnostic.png', dpi=150, bbox_inches='tight')
print("Saved: viz_phase_diagnostic.png")
