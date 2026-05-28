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
