"""
Applications of Newton Ratio Order Parameters
==============================================

Real-world applications of Newton ratio profiles as algebraic
order parameters for spectral analysis and quantum phase detection.
"""

import numpy as np
from typing import Tuple, List


def esymm_from_spectrum(spectrum: np.ndarray) -> np.ndarray:
    """Compute elementary symmetric polynomials recursively. O(n^2)."""
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


def newton_profile_energy(spectrum: np.ndarray) -> float:
    """max_k |log rho_k| — the Newton profile energy."""
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    mx = 0.0
    for k in range(1, n):
        d = e[k-1] * e[k+1]
        if abs(d) > 1e-300 and e[k] > 1e-300:
            r = e[k]**2 / d
            if r > 0:
                mx = max(mx, abs(np.log(r)))
    return mx


# === Application 1: Random Matrix Phase Detection ===

def detect_phase_random_matrix(N: int, beta: float) -> str:
    """Detect phase of a random matrix ensemble via Newton ratios.
    
    For Gaussian ensembles with inverse temperature beta:
    - beta large (ordered): Newton profile energy bounded
    - beta small (disordered): Newton profile energy diverges
    
    Args:
        N: Matrix size
        beta: Inverse temperature parameter
    
    Returns:
        Phase classification string
    """
    # Generate random symmetric matrix
    A = np.random.randn(N, N) / np.sqrt(beta * N)
    A = (A + A.T) / 2
    eigenvalues = np.linalg.eigvalsh(A)
    
    # Shift to make positive
    eigenvalues = eigenvalues - eigenvalues.min() + 0.1
    
    energy = newton_profile_energy(eigenvalues)
    
    if energy < 2.0:
        return f"ORDERED (energy={energy:.2f})"
    elif energy < 5.0:
        return f"INTERMEDIATE (energy={energy:.2f})"
    else:
        return f"DISORDERED (energy={energy:.2f})"


# === Application 2: Entanglement Spectrum Analysis ===

def analyze_entanglement_spectrum(spectrum: np.ndarray) -> dict:
    """Analyze an entanglement spectrum using Newton ratio diagnostics.
    
    For a reduced density matrix with eigenvalues (entanglement spectrum),
    compute Newton ratio diagnostics that distinguish:
    - Area-law states (gapped, bounded Newton energy)
    - Critical states (logarithmically growing Newton energy)
    - Volume-law states (extensively growing Newton energy)
    
    Args:
        spectrum: Entanglement spectrum (positive values)
    
    Returns:
        Dictionary with diagnostic information
    """
    spectrum = np.sort(spectrum)[::-1]  # Sort descending
    spectrum = spectrum[spectrum > 1e-15]  # Remove zeros
    
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    
    # Newton ratios
    ratios = []
    for k in range(1, n):
        d = e[k-1] * e[k+1]
        if abs(d) > 1e-300:
            ratios.append(e[k]**2 / d)
    
    energy = newton_profile_energy(spectrum)
    
    # Check geometric rigidity
    if len(ratios) > 0:
        max_deviation = max(abs(r - 1.0) for r in ratios if np.isfinite(r))
    else:
        max_deviation = 0.0
    
    # Classify
    if energy < 1.0:
        phase = "AREA-LAW (likely gapped)"
    elif energy < 3.0:
        phase = "INTERMEDIATE"
    else:
        phase = "CRITICAL or VOLUME-LAW"
    
    return {
        "newton_energy": energy,
        "max_ratio_deviation": max_deviation,
        "n_eigenvalues": n,
        "spectral_range": (spectrum.min(), spectrum.max()),
        "phase_classification": phase,
    }


# === Application 3: Spectral Pinching Certificate ===

def spectral_pinching_certificate(spectrum: np.ndarray) -> dict:
    """Compute a spectral pinching certificate.
    
    Given a positive spectrum in [a, b], compute the theoretical
    upper bound on Newton ratios from the spectral pinching theorem,
    and compare with the actual Newton ratios.
    
    Args:
        spectrum: Positive real values
    
    Returns:
        Certificate dictionary
    """
    a = spectrum.min()
    b = spectrum.max()
    n = len(spectrum)
    
    if a <= 0:
        return {"error": "Spectrum must be strictly positive"}
    
    e = esymm_from_spectrum(spectrum)
    
    # Theoretical bounds
    from math import comb
    
    actual_ratios = []
    theoretical_bounds = []
    
    for k in range(1, n):
        denom = e[k-1] * e[k+1]
        if abs(denom) > 1e-300:
            actual = e[k]**2 / denom
            actual_ratios.append(actual)
            
            # Upper bound from pinching: C(n,k)^2 * b^{2k} / (C(n,k-1)*C(n,k+1) * a^{2k})
            if k + 1 <= n and k - 1 >= 0:
                num = comb(n, k)**2 * b**(2*k)
                den = comb(n, k-1) * comb(n, k+1) * a**(2*k)
                if den > 0:
                    theoretical_bounds.append(num / den)
                else:
                    theoretical_bounds.append(float('inf'))
    
    return {
        "spectral_range": (a, b),
        "pinching_ratio": b / a,
        "n": n,
        "actual_max_ratio": max(actual_ratios) if actual_ratios else 0,
        "theoretical_max_bound": max(theoretical_bounds) if theoretical_bounds else 0,
        "certificate_valid": all(
            ar <= tb * 1.01 for ar, tb in zip(actual_ratios, theoretical_bounds)
            if np.isfinite(tb)
        ),
    }


if __name__ == "__main__":
    print("=" * 60)
    print("Newton Ratio Applications")
    print("=" * 60)
    
    # Application 1: Random Matrix Phase Detection
    print("\n--- Application 1: Random Matrix Phase Detection ---")
    np.random.seed(42)
    for beta in [0.1, 1.0, 10.0, 100.0]:
        result = detect_phase_random_matrix(20, beta)
        print(f"  beta={beta:6.1f}: {result}")
    
    # Application 2: Entanglement Spectrum Analysis
    print("\n--- Application 2: Entanglement Spectrum Analysis ---")
    
    # Simulated area-law spectrum (exponentially decaying)
    area_law = np.exp(-np.arange(10) * 0.5)
    result = analyze_entanglement_spectrum(area_law)
    print(f"  Area-law spectrum: {result['phase_classification']}")
    print(f"    Newton energy: {result['newton_energy']:.4f}")
    
    # Simulated flat spectrum (volume-law)
    volume_law = np.ones(10) * 0.5 + np.random.randn(10) * 0.01
    result = analyze_entanglement_spectrum(volume_law)
    print(f"  Near-flat spectrum: {result['phase_classification']}")
    print(f"    Newton energy: {result['newton_energy']:.4f}")
    
    # Application 3: Spectral Pinching Certificate
    print("\n--- Application 3: Spectral Pinching Certificate ---")
    spectrum = np.random.uniform(0.3, 0.7, 8)
    cert = spectral_pinching_certificate(spectrum)
    print(f"  Spectrum in [{cert['spectral_range'][0]:.3f}, {cert['spectral_range'][1]:.3f}]")
    print(f"  Pinching ratio: {cert['pinching_ratio']:.3f}")
    print(f"  Actual max ratio: {cert['actual_max_ratio']:.4f}")
    print(f"  Theoretical bound: {cert['theoretical_max_bound']:.4f}")
    print(f"  Certificate valid: {cert['certificate_valid']}")


"""
SSH Newton Ratio Profile Demo
==============================

Interactive demonstration of the SSH Newton-order conjecture:
- Builds finite SSH correlation matrices
- Computes Newton ratio profiles
- Visualizes max |log rho_k| across subsystem size and phase parameter

This demonstrates the core thesis: Newton ratios function as algebraic
order parameters that distinguish gapped from critical quantum phases.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_from_spectrum(spectrum):
    """Compute elementary symmetric polynomials e_0, ..., e_n recursively."""
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] = e[k] + spectrum[i] * e[k - 1]
    return e


def newton_profile_energy(spectrum):
    """Compute max_k |log rho_k| — the Newton profile energy."""
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    max_log = 0.0
    for k in range(1, n):
        denom = e[k - 1] * e[k + 1]
        if abs(denom) > 1e-300 and e[k] > 1e-300:
            ratio = e[k] ** 2 / denom
            if ratio > 0:
                max_log = max(max_log, abs(np.log(ratio)))
    return max_log


def ssh_correlation_matrix(L, delta):
    """Build subsystem correlation matrix for half-filled SSH chain."""
    N_total = max(4 * L, 100)
    if N_total % 2 != 0:
        N_total += 1
    
    H = np.zeros((N_total, N_total))
    for i in range(N_total - 1):
        t = (1.0 + delta) if i % 2 == 0 else (1.0 - delta)
        H[i, i + 1] = t
        H[i + 1, i] = t
    
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    n_occ = N_total // 2
    C_full = eigenvectors[:, :n_occ] @ eigenvectors[:, :n_occ].T
    return C_full[:L, :L]


def ssh_newton_energy(L, delta):
    """Compute Newton profile energy for SSH subsystem."""
    C = ssh_correlation_matrix(L, delta)
    eigs = np.linalg.eigvalsh(C)
    eigs = np.clip(eigs, 1e-15, 1 - 1e-15)
    return newton_profile_energy(eigs)


def main():
    print("=" * 60)
    print("SSH Newton Ratio Profile — Phase Diagnostic Demo")
    print("=" * 60)
    
    # === Figure 1: Newton energy vs subsystem size ===
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Newton energy vs L for different delta
    L_values = list(range(4, 25, 2))
    deltas = [0.0, 0.1, 0.3, 0.5, 0.8]
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(deltas)))
    
    for delta, color in zip(deltas, colors):
        energies = [ssh_newton_energy(L, delta) for L in L_values]
        label = f"δ = {delta:.1f}" + (" (critical)" if delta == 0.0 else "")
        axes[0].plot(L_values, energies, 'o-', color=color, label=label, markersize=4)
    
    axes[0].set_xlabel("Subsystem size L")
    axes[0].set_ylabel("Newton profile energy  max|log ρₖ|")
    axes[0].set_title("Newton Energy vs Subsystem Size")
    axes[0].legend(fontsize=8)
    axes[0].grid(True, alpha=0.3)
    
    # Panel 2: Newton energy vs delta for fixed L
    delta_values = np.linspace(0, 0.9, 30)
    L_fixed = [6, 10, 16, 20]
    colors2 = plt.cm.plasma(np.linspace(0.1, 0.9, len(L_fixed)))
    
    for L, color in zip(L_fixed, colors2):
        energies = [ssh_newton_energy(L, d) for d in delta_values]
        axes[1].plot(delta_values, energies, '-', color=color, label=f"L = {L}", linewidth=1.5)
    
    axes[1].set_xlabel("Dimerization parameter δ")
    axes[1].set_ylabel("Newton profile energy")
    axes[1].set_title("Phase Transition Signature")
    axes[1].axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Critical point')
    axes[1].legend(fontsize=8)
    axes[1].grid(True, alpha=0.3)
    
    # Panel 3: Full Newton ratio profile for L=12
    L = 12
    for delta in [0.0, 0.3, 0.6]:
        C = ssh_correlation_matrix(L, delta)
        eigs = np.linalg.eigvalsh(C)
        eigs = np.clip(eigs, 1e-15, 1 - 1e-15)
        e = esymm_from_spectrum(eigs)
        
        log_ratios = []
        ks = []
        for k in range(1, L):
            denom = e[k-1] * e[k+1]
            if abs(denom) > 1e-300 and e[k] > 1e-300:
                ratio = e[k]**2 / denom
                if ratio > 0:
                    log_ratios.append(np.log(ratio))
                    ks.append(k)
        
        label = f"δ = {delta:.1f}"
        axes[2].plot(ks, log_ratios, 'o-', label=label, markersize=4)
    
    axes[2].set_xlabel("Index k")
    axes[2].set_ylabel("log ρₖ")
    axes[2].set_title(f"Newton Ratio Profile (L={L})")
    axes[2].axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    axes[2].legend(fontsize=8)
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig("newton_ssh_demo.png", dpi=150, bbox_inches='tight')
    print("\nSaved figure: newton_ssh_demo.png")
    
    # Print numerical results
    print("\n" + "=" * 60)
    print("Numerical Results")
    print("=" * 60)
    
    print("\n--- Newton Profile Energy: max|log ρ_k| ---")
    print(f"{'L':>4} {'δ=0.0':>10} {'δ=0.1':>10} {'δ=0.3':>10} {'δ=0.5':>10}")
    for L in [4, 6, 8, 10, 12, 16, 20]:
        vals = [ssh_newton_energy(L, d) for d in [0.0, 0.1, 0.3, 0.5]]
        print(f"{L:>4} {vals[0]:>10.4f} {vals[1]:>10.4f} {vals[2]:>10.4f} {vals[3]:>10.4f}")
    
    # Test geometric rigidity
    print("\n--- Geometric Rigidity Test ---")
    print("Constant spectrum [c, c, ..., c] should have near-zero Newton defects:")
    for n in [3, 5, 8]:
        spectrum = np.ones(n) * 0.5
        e = esymm_from_spectrum(spectrum)
        max_defect = 0
        for k in range(1, n):
            defect = e[k]**2 - e[k-1]*e[k+1]
            max_defect = max(max_defect, abs(defect))
        print(f"  n={n}: max |defect| = {max_defect:.2e}")
    
    # Test spectral pinching
    print("\n--- Spectral Pinching Test ---")
    print("Spectrum in [a, b] → bounded Newton ratios:")
    for a, b in [(0.1, 0.9), (0.3, 0.7), (0.45, 0.55)]:
        spectrum = np.random.uniform(a, b, 10)
        energy = newton_profile_energy(spectrum)
        print(f"  [{a}, {b}]: Newton energy = {energy:.4f}")


if __name__ == "__main__":
    main()


"""
Visualization 1: Newton Ratio Profiles Across Quantum Phases
=============================================================

This script visualizes how Newton ratio profiles change as a quantum
system transitions from a gapped to a critical phase. The SSH model
serves as the physical test case, with the dimerization parameter
delta controlling the phase.

Key insight: In the gapped phase (delta != 0), Newton ratios stay
bounded. At the critical point (delta = 0), they grow without bound
as the subsystem size increases — functioning as an algebraic order
parameter for the quantum phase transition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def esymm_from_spectrum(spectrum):
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


def newton_ratios(spectrum):
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    ratios = []
    for k in range(1, n):
        d = e[k-1] * e[k+1]
        if abs(d) > 1e-300 and e[k] > 1e-300:
            ratios.append((k, e[k]**2 / d))
        else:
            ratios.append((k, np.nan))
    return ratios


def ssh_spectrum(L, delta):
    N = max(4 * L, 100)
    if N % 2: N += 1
    H = np.zeros((N, N))
    for i in range(N - 1):
        t = (1.0 + delta) if i % 2 == 0 else (1.0 - delta)
        H[i, i+1] = t
        H[i+1, i] = t
    evals, evecs = np.linalg.eigh(H)
    C = evecs[:, :N//2] @ evecs[:, :N//2].T
    eigs = np.linalg.eigvalsh(C[:L, :L])
    return np.clip(eigs, 1e-15, 1 - 1e-15)


fig = plt.figure(figsize=(16, 10))
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: Newton ratio profiles for different delta, fixed L
ax1 = fig.add_subplot(gs[0, 0])
L = 14
for delta, color, ls in [(0.0, '#e74c3c', '-'), (0.2, '#f39c12', '--'),
                          (0.5, '#2ecc71', '-.'), (0.8, '#3498db', ':')]:
    spec = ssh_spectrum(L, delta)
    rats = newton_ratios(spec)
    ks = [r[0] for r in rats if not np.isnan(r[1])]
    vals = [np.log(r[1]) for r in rats if not np.isnan(r[1])]
    label = f"δ={delta:.1f}" + (" (critical)" if delta == 0 else "")
    ax1.plot(ks, vals, color=color, linestyle=ls, marker='o', markersize=3, label=label)

ax1.axhline(0, color='gray', alpha=0.3)
ax1.set_xlabel("Index k")
ax1.set_ylabel("log ρₖ")
ax1.set_title(f"Newton Ratio Profiles (L={L})")
ax1.legend(fontsize=7)
ax1.grid(True, alpha=0.2)

# Panel 2: Newton profile energy vs L
ax2 = fig.add_subplot(gs[0, 1])
L_range = range(4, 24, 2)
for delta, color in [(0.0, '#e74c3c'), (0.1, '#e67e22'), (0.3, '#27ae60'),
                     (0.5, '#2980b9'), (0.8, '#8e44ad')]:
    energies = []
    for L in L_range:
        spec = ssh_spectrum(L, delta)
        e = esymm_from_spectrum(spec)
        mx = 0
        for k in range(1, L):
            d = e[k-1]*e[k+1]
            if abs(d) > 1e-300 and e[k] > 1e-300:
                r = e[k]**2/d
                if r > 0: mx = max(mx, abs(np.log(r)))
        energies.append(mx)
    ax2.plot(list(L_range), energies, 'o-', color=color, markersize=3, label=f"δ={delta:.1f}")

ax2.set_xlabel("Subsystem size L")
ax2.set_ylabel("Newton profile energy")
ax2.set_title("Phase Separation via Newton Energy")
ax2.legend(fontsize=7)
ax2.grid(True, alpha=0.2)

# Panel 3: Heatmap of Newton energy vs (delta, L)
ax3 = fig.add_subplot(gs[0, 2])
delta_vals = np.linspace(0, 0.9, 25)
L_vals = range(4, 22, 2)
Z = np.zeros((len(L_vals), len(delta_vals)))
for i, L in enumerate(L_vals):
    for j, d in enumerate(delta_vals):
        spec = ssh_spectrum(L, d)
        e = esymm_from_spectrum(spec)
        mx = 0
        for k in range(1, L):
            dn = e[k-1]*e[k+1]
            if abs(dn) > 1e-300 and e[k] > 1e-300:
                r = e[k]**2/dn
                if r > 0: mx = max(mx, abs(np.log(r)))
        Z[i, j] = mx

im = ax3.imshow(Z, aspect='auto', origin='lower',
                extent=[0, 0.9, min(L_vals), max(L_vals)],
                cmap='inferno')
plt.colorbar(im, ax=ax3, label='Newton energy')
ax3.set_xlabel("Dimerization δ")
ax3.set_ylabel("Subsystem size L")
ax3.set_title("Newton Energy Phase Diagram")

# Panel 4: Newton defects (showing nonnegativity)
ax4 = fig.add_subplot(gs[1, 0])
for L, color in [(6, '#e74c3c'), (10, '#3498db'), (14, '#2ecc71')]:
    spec = ssh_spectrum(L, 0.3)
    e = esymm_from_spectrum(spec)
    defects = [e[k]**2 - e[k-1]*e[k+1] for k in range(1, L)]
    ax4.semilogy(range(1, L), [max(d, 1e-20) for d in defects], 'o-',
                 color=color, markersize=3, label=f"L={L}")

ax4.set_xlabel("Index k")
ax4.set_ylabel("Newton defect Δₖ (log scale)")
ax4.set_title("Newton Defects (always ≥ 0)")
ax4.legend(fontsize=7)
ax4.grid(True, alpha=0.2)

# Panel 5: Log-esymm profile (approximate affinity)
ax5 = fig.add_subplot(gs[1, 1])
L = 14
for delta, color, ls in [(0.0, '#e74c3c', '-'), (0.3, '#27ae60', '--'), (0.7, '#2980b9', '-.')]:
    spec = ssh_spectrum(L, delta)
    e = esymm_from_spectrum(spec)
    log_e = [np.log(e[k]) if e[k] > 0 else np.nan for k in range(L+1)]
    ax5.plot(range(L+1), log_e, color=color, linestyle=ls, marker='s',
             markersize=3, label=f"δ={delta:.1f}")
    # Plot linear interpolant
    if not np.isnan(log_e[0]) and not np.isnan(log_e[L]):
        interp = [log_e[0] + k/L * (log_e[L] - log_e[0]) for k in range(L+1)]
        ax5.plot(range(L+1), interp, color=color, alpha=0.3, linewidth=1)

ax5.set_xlabel("Index k")
ax5.set_ylabel("log eₖ")
ax5.set_title("Log-esymm Profile (lines = interpolants)")
ax5.legend(fontsize=7)
ax5.grid(True, alpha=0.2)

# Panel 6: Spectral pinching demonstration
ax6 = fig.add_subplot(gs[1, 2])
np.random.seed(42)
for a, b, color in [(0.1, 0.9, '#e74c3c'), (0.3, 0.7, '#27ae60'), (0.45, 0.55, '#2980b9')]:
    energies = []
    for _ in range(50):
        spec = np.random.uniform(a, b, 12)
        energies.append(max(0.01, newton_ratios(spec)[5][1] if len(newton_ratios(spec)) > 5 else 1))
    ax6.hist(energies, bins=15, alpha=0.5, color=color, label=f"[{a},{b}]", density=True)

ax6.set_xlabel("Newton ratio ρ₆")
ax6.set_ylabel("Density")
ax6.set_title("Spectral Pinching → Bounded Ratios")
ax6.legend(fontsize=7)
ax6.grid(True, alpha=0.2)

fig.suptitle("Newton Ratios as Algebraic Order Parameters for Quantum Phases",
             fontsize=14, fontweight='bold', y=0.98)

plt.savefig("newton_profiles.png", dpi=150, bbox_inches='tight')
print("Saved: newton_profiles.png")


"""
Visualization 2: Geometric Rigidity and Newton Defects
========================================================

This script visualizes the geometric rigidity theorem:
when all Newton defects vanish, the esymm sequence must be geometric.
We show how increasing Newton defects correspond to deviations from
geometric structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_from_spectrum(spectrum):
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


def newton_defects(spectrum):
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    return [e[k]**2 - e[k-1]*e[k+1] for k in range(1, n)]


def geometric_fit(e_vals):
    """Find best geometric fit a*b^k to a positive sequence."""
    n = len(e_vals) - 1
    valid = [(k, e_vals[k]) for k in range(n+1) if e_vals[k] > 0]
    if len(valid) < 2:
        return None, None
    log_e = [np.log(v) for _, v in valid]
    ks = [k for k, _ in valid]
    # Linear regression on log scale
    coeffs = np.polyfit(ks, log_e, 1)
    b = np.exp(coeffs[0])
    a = np.exp(coeffs[1])
    return a, b


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Panel 1: Constant spectrum -> geometric esymm
n = 8
spectrum = np.ones(n) * 2.0
e = esymm_from_spectrum(spectrum)
a, b = geometric_fit(e)
axes[0, 0].semilogy(range(n+1), e, 'bo-', markersize=6, label='e_k (constant spectrum)')
if a and b:
    fit = [a * b**k for k in range(n+1)]
    axes[0, 0].semilogy(range(n+1), fit, 'r--', alpha=0.7, label=f'Geometric fit: {a:.2f}·{b:.2f}^k')
axes[0, 0].set_xlabel('k')
axes[0, 0].set_ylabel('e_k (log scale)')
axes[0, 0].set_title('Constant Spectrum [2,2,...,2]')
axes[0, 0].legend(fontsize=7)
axes[0, 0].grid(True, alpha=0.2)

# Panel 2: Nearly constant spectrum
spectrum2 = np.ones(n) * 2.0 + np.random.RandomState(42).randn(n) * 0.1
e2 = esymm_from_spectrum(spectrum2)
a2, b2 = geometric_fit(e2)
axes[0, 1].semilogy(range(n+1), e2, 'bo-', markersize=6, label='e_k (perturbed)')
if a2 and b2:
    fit2 = [a2 * b2**k for k in range(n+1)]
    axes[0, 1].semilogy(range(n+1), fit2, 'r--', alpha=0.7, label=f'Geometric fit')
axes[0, 1].set_xlabel('k')
axes[0, 1].set_ylabel('e_k (log scale)')
axes[0, 1].set_title('Near-Constant Spectrum (σ=0.1)')
axes[0, 1].legend(fontsize=7)
axes[0, 1].grid(True, alpha=0.2)

# Panel 3: Widely varying spectrum
spectrum3 = np.array([0.1, 0.5, 1.0, 2.0, 3.0, 5.0, 8.0, 10.0])
e3 = esymm_from_spectrum(spectrum3)
a3, b3 = geometric_fit(e3)
axes[0, 2].semilogy(range(n+1), e3, 'bo-', markersize=6, label='e_k (varying)')
if a3 and b3:
    fit3 = [a3 * b3**k for k in range(n+1)]
    axes[0, 2].semilogy(range(n+1), fit3, 'r--', alpha=0.7, label='Geometric fit')
axes[0, 2].set_xlabel('k')
axes[0, 2].set_ylabel('e_k (log scale)')
axes[0, 2].set_title('Widely Varying Spectrum')
axes[0, 2].legend(fontsize=7)
axes[0, 2].grid(True, alpha=0.2)

# Panel 4: Newton defects comparison
defects1 = newton_defects(np.ones(n) * 2.0)
defects2 = newton_defects(spectrum2)
defects3 = newton_defects(spectrum3)

x = np.arange(1, n)
width = 0.25
axes[1, 0].bar(x - width, [max(d, 1e-20) for d in defects1], width, label='Constant', color='#3498db', alpha=0.8)
axes[1, 0].bar(x, [max(d, 1e-20) for d in defects2], width, label='Perturbed', color='#e74c3c', alpha=0.8)
axes[1, 0].bar(x + width, [max(d, 1e-20) for d in defects3], width, label='Varying', color='#2ecc71', alpha=0.8)
axes[1, 0].set_yscale('log')
axes[1, 0].set_xlabel('Index k')
axes[1, 0].set_ylabel('Newton defect Δ_k')
axes[1, 0].set_title('Newton Defects (always ≥ 0)')
axes[1, 0].legend(fontsize=7)
axes[1, 0].grid(True, alpha=0.2)

# Panel 5: Deviation from geometric as function of spectral spread
spreads = np.linspace(0, 3, 30)
deviations = []
max_defects = []
for spread in spreads:
    np.random.seed(42)
    spec = np.exp(np.random.randn(n) * spread)
    e = esymm_from_spectrum(spec)
    a, b = geometric_fit(e)
    if a and b and a > 0 and b > 0:
        fit = np.array([a * b**k for k in range(n+1)])
        dev = np.max(np.abs(np.log(e / fit + 1e-30)))
        deviations.append(dev)
    else:
        deviations.append(0)
    defs = newton_defects(spec)
    max_defects.append(max(defs))

axes[1, 1].plot(spreads, deviations, 'b-', linewidth=2, label='Max log deviation from geometric')
axes[1, 1].set_xlabel('Spectral spread (std of log-spectrum)')
axes[1, 1].set_ylabel('Deviation from geometric')
axes[1, 1].set_title('Rigidity: Spread → Deviation')
axes[1, 1].legend(fontsize=7)
axes[1, 1].grid(True, alpha=0.2)

# Panel 6: Newton energy vs spectral spread
axes[1, 2].plot(spreads, [np.log(max(d, 1e-30)) for d in max_defects], 'r-', linewidth=2)
axes[1, 2].set_xlabel('Spectral spread')
axes[1, 2].set_ylabel('log(max Newton defect)')
axes[1, 2].set_title('Newton Defect Growth')
axes[1, 2].grid(True, alpha=0.2)

fig.suptitle('Geometric Rigidity: Newton Defects Measure Deviation from Geometric Structure',
             fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_rigidity.png")


"""
Visualization 3: Discrete Semiconcavity and Shape Control
==========================================================

This script visualizes the discrete semiconcavity theorem:
bounded second differences confine a sequence within a parabolic
envelope around any linear interpolant.

Applied to log(e_k), bounded Newton ratios force the log-esymm
profile to be approximately affine — connecting algebraic
combinatorics to discrete convex analysis.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_from_spectrum(spectrum):
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Abstract semiconcavity illustration
N = 20
C = 0.3
np.random.seed(42)

# Generate a sequence with bounded second differences
f = np.zeros(N + 1)
f[0] = 0
increments = np.random.uniform(-0.5, 0.5, N)
for i in range(N):
    f[i + 1] = f[i] + increments[i]
    if i > 0:
        second_diff = f[i+1] - 2*f[i] + f[i-1]
        if second_diff > C:
            f[i+1] = 2*f[i] - f[i-1] + C
        elif second_diff < -C:
            f[i+1] = 2*f[i] - f[i-1] - C

# Linear interpolant
L = np.array([(N-j)/N * f[0] + j/N * f[N] for j in range(N+1)])

# Parabolic envelope
j_vals = np.arange(N+1)
upper_env = L + C * j_vals * (N - j_vals) / 2
lower_env = L - C * j_vals * (N - j_vals) / 2

axes[0, 0].fill_between(j_vals, lower_env, upper_env, alpha=0.15, color='blue', label='Parabolic envelope')
axes[0, 0].plot(j_vals, f, 'ko-', markersize=3, linewidth=1.5, label='f(j)')
axes[0, 0].plot(j_vals, L, 'r--', linewidth=1.5, label='Linear interpolant')
axes[0, 0].plot(j_vals, upper_env, 'b:', linewidth=1, alpha=0.7)
axes[0, 0].plot(j_vals, lower_env, 'b:', linewidth=1, alpha=0.7)
axes[0, 0].set_xlabel('j')
axes[0, 0].set_ylabel('f(j)')
axes[0, 0].set_title(f'Semiconcavity: |D²f| ≤ {C} → parabolic envelope')
axes[0, 0].legend(fontsize=8)
axes[0, 0].grid(True, alpha=0.2)

# Panel 2: Varying C values
for C_val, color, ls in [(0.1, '#2ecc71', '-'), (0.3, '#3498db', '--'),
                          (0.8, '#e74c3c', '-.')]:
    env_upper = L + C_val * j_vals * (N - j_vals) / 2
    env_lower = L - C_val * j_vals * (N - j_vals) / 2
    axes[0, 1].fill_between(j_vals, env_lower, env_upper, alpha=0.1, color=color)
    axes[0, 1].plot(j_vals, env_upper, color=color, linestyle=ls, linewidth=1.5,
                    label=f'C = {C_val}')
    axes[0, 1].plot(j_vals, env_lower, color=color, linestyle=ls, linewidth=1.5)

axes[0, 1].plot(j_vals, L, 'k-', linewidth=1, alpha=0.5, label='Interpolant')
axes[0, 1].set_xlabel('j')
axes[0, 1].set_ylabel('Envelope bounds')
axes[0, 1].set_title('Envelope Width Grows with C')
axes[0, 1].legend(fontsize=8)
axes[0, 1].grid(True, alpha=0.2)

# Panel 3: Application to log(e_k) profiles
n = 12
spectra = {
    'Pinched [0.4, 0.6]': np.random.RandomState(42).uniform(0.4, 0.6, n),
    'Moderate [0.2, 0.8]': np.random.RandomState(42).uniform(0.2, 0.8, n),
    'Wide [0.05, 0.95]': np.random.RandomState(42).uniform(0.05, 0.95, n),
}
colors = ['#2ecc71', '#3498db', '#e74c3c']

for (name, spec), color in zip(spectra.items(), colors):
    e = esymm_from_spectrum(spec)
    log_e = [np.log(e[k]) if e[k] > 0 else np.nan for k in range(n+1)]
    
    # Compute max |second difference| = max |log rho_k|
    max_C = 0
    for k in range(1, n):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            sd = abs(log_e[k+1] - 2*log_e[k] + log_e[k-1])
            max_C = max(max_C, sd)
    
    axes[1, 0].plot(range(n+1), log_e, 'o-', color=color, markersize=4,
                    label=f'{name} (C={max_C:.2f})')
    
    # Show interpolant
    if not np.isnan(log_e[0]) and not np.isnan(log_e[n]):
        interp = [(n-j)/n * log_e[0] + j/n * log_e[n] for j in range(n+1)]
        axes[1, 0].plot(range(n+1), interp, '--', color=color, alpha=0.3)

axes[1, 0].set_xlabel('Index k')
axes[1, 0].set_ylabel('log e_k')
axes[1, 0].set_title('Log-esymm Profiles (dashed = interpolants)')
axes[1, 0].legend(fontsize=7)
axes[1, 0].grid(True, alpha=0.2)

# Panel 4: Envelope tightness vs spectral pinching
pinching_ratios = np.linspace(1.0, 10.0, 30)
max_second_diffs = []

for ratio in pinching_ratios:
    a = 1.0
    b = ratio
    np.random.seed(42)
    spec = np.random.uniform(a, b, 10)
    e = esymm_from_spectrum(spec)
    max_sd = 0
    for k in range(1, 10):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            sd = abs(np.log(e[k+1]) - 2*np.log(e[k]) + np.log(e[k-1]))
            max_sd = max(max_sd, sd)
    max_second_diffs.append(max_sd)

axes[1, 1].plot(pinching_ratios, max_second_diffs, 'b-', linewidth=2)
axes[1, 1].set_xlabel('Pinching ratio b/a')
axes[1, 1].set_ylabel('max |D² log e_k|')
axes[1, 1].set_title('Wider Spectral Range → Larger Curvature Bound')
axes[1, 1].axhline(y=0, color='gray', alpha=0.3)
axes[1, 1].grid(True, alpha=0.2)

fig.suptitle('Discrete Semiconcavity: Bounded Curvature Controls Global Shape',
             fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_semiconcavity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_semiconcavity.png")
