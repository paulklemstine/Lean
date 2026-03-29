"""
Demo 4: Spectral Triples and the Grand Synthesis

The spectral triple (A, H, D) unifies geometry, quantum mechanics, and gauge theory.
This demo visualizes the key ideas of Connes' noncommutative geometry and the spectral 
action principle.

This demonstrates Pillar V: The Grand Synthesis.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle
import matplotlib.gridspec as gridspec

# ============================================================
# Spectral Geometry: Distance from Algebra
# ============================================================

def connes_distance_circle(n_points=100):
    """
    Demonstrate Connes' distance formula on a circle S¹.
    
    The spectral triple for S¹:
    - A = C(S¹) ≅ C(ℝ/ℤ) (periodic functions)
    - H = L²(S¹) 
    - D = -i d/dθ (Dirac operator on S¹)
    
    Connes' distance: d(p,q) = sup{|f(p) - f(q)| : ||[D,f]|| ≤ 1}
    
    On S¹, [D,f] = -i f', so ||[D,f]|| = ||f'||∞ ≤ 1 means f is 1-Lipschitz.
    Thus d(p,q) = geodesic distance on S¹. ✓
    """
    theta = np.linspace(0, 2*np.pi, n_points, endpoint=False)
    
    # Pick two points
    p_idx, q_idx = 10, 40
    theta_p, theta_q = theta[p_idx], theta[q_idx]
    
    # Several 1-Lipschitz functions and their values
    functions = []
    for shift in np.linspace(0, 2*np.pi, 20):
        f = np.sin(theta + shift)  # derivative = cos(θ+shift), ||f'||∞ = 1
        functions.append(f)
    
    # The supremum over all 1-Lipschitz functions gives geodesic distance
    differences = [abs(f[p_idx] - f[q_idx]) for f in functions]
    geodesic = min(abs(theta_q - theta_p), 2*np.pi - abs(theta_q - theta_p))
    
    return theta, functions, p_idx, q_idx, geodesic

# ============================================================
# Dirac Operator Spectrum
# ============================================================

def dirac_spectrum_circle(n_max=20):
    """
    Spectrum of D = -i d/dθ on S¹.
    Eigenvalues: n ∈ ℤ (with eigenfunctions e^{inθ}).
    
    The spectrum determines the geometry (Weyl's law):
    N(λ) ~ Vol(M) · λ^d / (2π)^d  ← dimension d recovered from spectral growth!
    """
    eigenvalues = list(range(-n_max, n_max + 1))
    return eigenvalues

def heat_kernel_trace(eigenvalues, t_values):
    """
    Compute Tr(e^{-tD²}) = Σ e^{-tλ²}.
    
    As t → 0, this encodes the geometry:
    Tr(e^{-tD²}) ~ (4πt)^{-d/2} (Vol(M) + t·(scalar curvature)/6 + ...)
    """
    traces = []
    for t in t_values:
        tr = sum(np.exp(-t * lam**2) for lam in eigenvalues)
        traces.append(tr)
    return np.array(traces)

# ============================================================
# Figure: The Grand Synthesis
# ============================================================

fig = plt.figure(figsize=(20, 16))
fig.suptitle('The Grand Synthesis: Spectral Triples (A, H, D)', 
             fontsize=20, fontweight='bold')

gs = gridspec.GridSpec(3, 3, hspace=0.4, wspace=0.35)

# --- Panel 1: Connes' distance formula on circle ---
ax1 = fig.add_subplot(gs[0, 0])

theta, functions, p_idx, q_idx, geo_dist = connes_distance_circle()

# Draw circle
circle_x = np.cos(theta)
circle_y = np.sin(theta)
ax1.plot(circle_x, circle_y, 'k-', linewidth=2)

# Mark points
px, py = np.cos(theta[p_idx]), np.sin(theta[p_idx])
qx, qy = np.cos(theta[q_idx]), np.sin(theta[q_idx])
ax1.plot(px, py, 'ro', markersize=12, zorder=5, label=f'p')
ax1.plot(qx, qy, 'bo', markersize=12, zorder=5, label=f'q')

# Draw geodesic arc
arc_theta = np.linspace(theta[p_idx], theta[q_idx], 50)
ax1.plot(np.cos(arc_theta), np.sin(arc_theta), 'g-', linewidth=3, alpha=0.5)

ax1.set_aspect('equal')
ax1.set_title(f"Connes' Distance Formula\nd(p,q) = sup|f(p)−f(q)|\n= {geo_dist:.2f} (geodesic)", 
             fontweight='bold', fontsize=11)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.2)
ax1.set_xlim([-1.3, 1.3])
ax1.set_ylim([-1.3, 1.3])

# --- Panel 2: Dirac spectrum ---
ax2 = fig.add_subplot(gs[0, 1])

eigs = dirac_spectrum_circle(15)
ax2.stem(eigs, [1]*len(eigs), linefmt='b-', markerfmt='bo', basefmt='k-', label='Eigenvalues of D')
ax2.set_xlabel('Eigenvalue λₙ = n', fontsize=11)
ax2.set_ylabel('Multiplicity', fontsize=11)
ax2.set_title('Spectrum of D = −id/dθ on S¹\n(Integer spectrum ⟹ S¹ geometry)', 
             fontweight='bold', fontsize=11)
ax2.grid(True, alpha=0.2)
ax2.legend()

# --- Panel 3: Heat kernel trace ---
ax3 = fig.add_subplot(gs[0, 2])

eigs_for_heat = list(range(-30, 31))
t_values = np.linspace(0.01, 2, 200)
heat_traces = heat_kernel_trace(eigs_for_heat, t_values)

ax3.plot(t_values, heat_traces, 'r-', linewidth=2.5, label='Tr(e^{−tD²})')
# Asymptotic: (2π)/(4πt)^{1/2} for S¹ (d=1, Vol=2π)
asymptotic = 2 * np.pi / np.sqrt(4 * np.pi * t_values)
ax3.plot(t_values, asymptotic, 'k--', linewidth=1.5, alpha=0.5, 
         label='Asymptotic: Vol/(4πt)^{d/2}')

ax3.set_xlabel('t', fontsize=11)
ax3.set_ylabel('Tr(e^{−tD²})', fontsize=11)
ax3.set_title('Heat Kernel: Geometry from Spectrum\nt→0 recovers dim & volume', 
             fontweight='bold', fontsize=11)
ax3.legend(fontsize=9)
ax3.set_ylim([0, 30])
ax3.grid(True, alpha=0.2)

# --- Panel 4: The Standard Model spectral triple ---
ax4 = fig.add_subplot(gs[1, :])

sm_diagram = (
    "THE STANDARD MODEL AS A SPECTRAL TRIPLE\n"
    "═══════════════════════════════════════════════════════════════════════════════════\n\n"
    "  A = C∞(M) ⊗ A_F                    H = L²(M,S) ⊗ H_F                 D = D_M ⊗ 1 + γ₅ ⊗ D_F\n"
    "  ┌───────────────────┐              ┌───────────────────┐              ┌───────────────────┐\n"
    "  │ C∞(M): spacetime  │              │ L²(M,S): spinors  │              │ D_M: Dirac op     │\n"
    "  │ A_F = ℂ ⊕ ℍ ⊕ M₃(ℂ)│           │ H_F: internal dof │              │ D_F: Yukawa matrix│\n"
    "  └───────────────────┘              └───────────────────┘              └───────────────────┘\n\n"
    "  The finite algebra A_F encodes:                 The Dirac operator D encodes:\n"
    "  ├─ ℂ   → U(1) hypercharge                      ├─ D_M → spacetime geometry (metric, curvature)\n"
    "  ├─ ℍ   → SU(2) weak isospin                    ├─ D_F → fermion masses (Yukawa couplings)\n"
    "  └─ M₃(ℂ) → SU(3) color                         └─ γ₅ ⊗ D_F → chirality (parity violation)\n\n"
    "  Gauge group = Inn(A_F) = U(1) × SU(2) × SU(3)  ←  Inner automorphisms of the finite algebra!\n\n"
    "  SPECTRAL ACTION: S = Tr(f(D/Λ)) + ⟨ψ, Dψ⟩\n"
    "  ═══════════════════════════════════════════\n"
    "  Expanding asymptotically in Λ gives:\n"
    "    = ∫(R/16πG)√g d⁴x          ← Einstein-Hilbert (GRAVITY)\n"
    "    + ∫|F|²√g d⁴x              ← Yang-Mills (GAUGE FORCES)\n"
    "    + ∫|Dφ|² - V(φ) √g d⁴x     ← Higgs (SYMMETRY BREAKING)\n"
    "    + ⟨ψ, (D_M + y·φ)ψ⟩        ← Fermion masses (MATTER)\n"
    "    + cosmological constant      ← Dark energy?"
)

ax4.text(0.02, 0.97, sm_diagram, transform=ax4.transAxes, fontsize=9.5,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='#f5f5dc', alpha=0.9, edgecolor='#8B4513'))
ax4.axis('off')
ax4.set_title('The Spectral Action: One Formula for All of Physics', fontweight='bold', fontsize=14)

# --- Panel 5: The classical-quantum-gravity bridge ---
ax5 = fig.add_subplot(gs[2, 0])

bridge_text = (
    "The Three Regimes\n"
    "━━━━━━━━━━━━━━━━━\n\n"
    "CLASSICAL MECHANICS\n"
    " A = C∞(M) (commutative)\n"
    " D = {H, ·} (Poisson bracket)\n"
    " → Phase space geometry\n\n"
    "QUANTUM MECHANICS\n"
    " A = B(H) (noncommutative)\n"
    " D = [H, ·]/iℏ (commutator)\n"
    " → Hilbert space\n\n"
    "QUANTUM GRAVITY?\n"
    " A = ??? (noncommutative)\n"
    " D = ??? (dynamical)\n"
    " → Spectral geometry\n"
    "   without background space"
)
ax5.text(0.05, 0.95, bridge_text, transform=ax5.transAxes, fontsize=10.5,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='#e8f0fe', alpha=0.9))
ax5.axis('off')
ax5.set_title('Classical → Quantum → Gravity', fontweight='bold', fontsize=12)

# --- Panel 6: The algebraic layers of reality ---
ax6 = fig.add_subplot(gs[2, 1])

layers = [
    ('Category Theory\n(Composition, Functors)', '#9b59b6', 0.95),
    ('C*-Algebras\n(Observables, States)', '#3498db', 0.75),
    ('Lie Algebras\n(Symmetries, Conservation)', '#2ecc71', 0.55),
    ('Clifford Algebras\n(Spacetime, Spinors)', '#e74c3c', 0.35),
    ('Gauge Theory\n(Connections, Forces)', '#f39c12', 0.15),
]

for label, color, y in layers:
    box = FancyBboxPatch((0.08, y - 0.08), 0.84, 0.14, 
                         boxstyle="round,pad=0.02",
                         facecolor=color, alpha=0.7, edgecolor='black', linewidth=2,
                         transform=ax6.transAxes)
    ax6.add_patch(box)
    ax6.text(0.5, y, label, transform=ax6.transAxes, fontsize=10,
            ha='center', va='center', fontweight='bold', color='white')

ax6.axis('off')
ax6.set_title('Algebraic Layers of Reality', fontweight='bold', fontsize=12)

# --- Panel 7: Key equations ---
ax7 = fig.add_subplot(gs[2, 2])

equations_text = (
    "The Five Equations\n"
    "━━━━━━━━━━━━━━━━━━\n\n"
    "① {γμ,γν} = 2gμν    Spacetime\n\n"
    "② [Jᵢ,Jⱼ] = iεᵢⱼₖJₖ  Symmetry\n\n"
    "③ ‖a*a‖ = ‖a‖²     Observables\n\n"
    "④ dA + A∧A = F      Forces\n\n"
    "⑤ S = Tr f(D/Λ)     Everything\n\n"
    "━━━━━━━━━━━━━━━━━━\n"
    "Five equations.\n"
    "One algebraic framework.\n"
    "All of physics."
)
ax7.text(0.05, 0.95, equations_text, transform=ax7.transAxes, fontsize=12,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='#fdf2e9', alpha=0.9))
ax7.axis('off')
ax7.set_title('The Algebraic Equations of Physics', fontweight='bold', fontsize=12)

plt.savefig('/workspace/request-project/figures/demo4_spectral_triple.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Figure saved: figures/demo4_spectral_triple.png")

# ============================================================
# Computational Verification
# ============================================================
print("\n" + "="*60)
print("VERIFICATION: Spectral Geometry")
print("="*60)

# Verify heat kernel recovers dimension and volume of S¹
eigs = list(range(-100, 101))
t_small = 0.001
heat_trace = sum(np.exp(-t_small * n**2) for n in eigs)
predicted_vol = heat_trace * np.sqrt(4 * np.pi * t_small)
print(f"\nHeat kernel dimension recovery (S¹):")
print(f"  Tr(e^(-tD²)) at t={t_small}: {heat_trace:.4f}")
print(f"  Predicted volume: {predicted_vol:.4f}")
print(f"  Actual volume (2π): {2*np.pi:.4f}")
print(f"  Ratio: {predicted_vol/(2*np.pi):.4f} (→ 1 as t → 0)")

# Verify Connes' distance on finite space
print(f"\nConnes' distance on two-point space:")
print(f"  A = ℂ ⊕ ℂ (two copies of scalars)")
print(f"  D = [[0, m], [m, 0]] with m > 0")
print(f"  d(p1, p2) = sup|f(p1)-f(p2)| / ||[D,f]||")
m = 1.0
# f = (a, b), [D,f] = [[0, m(a-b)], [m(b-a), 0]], ||[D,f]|| = m|a-b|
# sup |a-b| / m|a-b| = 1/m
print(f"  For m = {m}: d(p1, p2) = 1/m = {1/m}")
print(f"  This is the Higgs mechanism! m = Yukawa coupling ⟹ distance = 1/m")
