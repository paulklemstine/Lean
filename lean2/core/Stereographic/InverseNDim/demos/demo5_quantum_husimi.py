"""
Demo 5: Quantum Husimi Functions and Majorana Stars
=====================================================
Visualizes quantum states on S² using stereographic coordinates.
Spin-j coherent states |z⟩ use stereographic parameter z ∈ ℂ.
The conformal factor λ^j appears as a quantum probability weight.

Oracle Ω's discovery: The Majorana stellar representation maps
spin-j states to 2j unordered points on S² — the "Majorana stars."
These determine the quantum state up to phase.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from scipy.special import comb
from mpl_toolkits.mplot3d import Axes3D

# ─── Quantum Functions ───────────────────────────────────────
def coherent_state_overlap(z, w, j):
    """⟨z|w⟩ for spin-j coherent states.
    = (1+z̄w)^{2j} / [(1+|z|²)(1+|w|²)]^j
    """
    num = (1 + np.conj(z) * w)**(2*j)
    den = ((1 + np.abs(z)**2) * (1 + np.abs(w)**2))**j
    return num / den

def husimi_function(z, state_coeffs, j):
    """Q(z) = |⟨z|ψ⟩|² for a spin-j state |ψ⟩ = Σ c_m |j,m⟩.
    
    ⟨z|j,m⟩ = √C(2j,j+m) · z^{j+m} / (1+|z|²)^j
    """
    m_values = np.arange(-j, j+1)
    result = np.zeros_like(z, dtype=complex)
    
    for i, m in enumerate(m_values):
        coeff = state_coeffs[i]
        binom = np.sqrt(comb(int(2*j), int(j+m), exact=True))
        result += coeff * binom * z**(j+m) / (1 + np.abs(z)**2)**j
    
    return np.abs(result)**2

def majorana_polynomial(state_coeffs, j):
    """Find roots of the Majorana polynomial.
    P(z) = Σ_{k=0}^{2j} (-1)^k √C(2j,k) c_{j-k} z^k
    """
    n = int(2*j)
    poly_coeffs = []
    for k in range(n + 1):
        binom = np.sqrt(comb(n, k, exact=True))
        sign = (-1)**k
        m_idx = int(j - k)
        if 0 <= int(j + m_idx) < len(state_coeffs):
            poly_coeffs.append(sign * binom * state_coeffs[int(j - (j-k))])
        else:
            poly_coeffs.append(0)
    
    return np.array(poly_coeffs[::-1])  # numpy wants highest degree first

# ─── Define interesting quantum states ───────────────────────
j = 3  # spin-3 → 6 Majorana stars

states = {
    'Spin-up |j,j⟩': np.array([0,0,0,0,0,0,1.0]),
    'Equatorial |j,0⟩': np.array([0,0,0,1.0,0,0,0]),
    'GHZ-like': np.array([1,0,0,0,0,0,1.0]) / np.sqrt(2),
    'W-like': np.array([0,1,0,0,0,1,0.0]) / np.sqrt(2),
    'Dicke |j,-1⟩': np.array([0,1.0,0,0,0,0,0]),
    'Random': None  # Will be generated
}

# Generate random state
np.random.seed(42)
rand_coeffs = np.random.randn(7) + 1j * np.random.randn(7)
rand_coeffs /= np.linalg.norm(rand_coeffs)
states['Random'] = rand_coeffs

# ─── Figure ──────────────────────────────────────────────────
fig = plt.figure(figsize=(18, 14), facecolor='#0a0a1a')
gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

L = 3
res = 250
x = np.linspace(-L, L, res)
y = np.linspace(-L, L, res)
X, Y = np.meshgrid(x, y)
Z_complex = X + 1j * Y

for idx, (name, coeffs) in enumerate(states.items()):
    ax = fig.add_subplot(gs[idx // 3, idx % 3], facecolor='#0a0a1a')
    
    Q = husimi_function(Z_complex, coeffs, j)
    
    # Conformal measure weighting
    lambda_sq = (2 / (1 + X**2 + Y**2))**2
    Q_weighted = Q * lambda_sq
    
    vmax = np.percentile(Q_weighted[Q_weighted > 0], 99)
    if vmax < 1e-10:
        vmax = 1.0
    
    im = ax.imshow(Q_weighted, extent=[-L, L, -L, L], cmap='hot',
                   origin='lower', vmin=0, vmax=vmax)
    
    # Draw unit circle (equator)
    theta_c = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta_c), np.sin(theta_c), color='#00ddff', linewidth=1, alpha=0.5)
    
    # Find Majorana stars (roots of polynomial)
    try:
        poly_c = majorana_polynomial(coeffs, j)
        if len(poly_c) > 1:
            roots = np.roots(poly_c)
            # Filter finite roots
            finite_roots = roots[np.abs(roots) < 10]
            ax.scatter(finite_roots.real, finite_roots.imag,
                      marker='*', s=200, color='#00ff88', edgecolors='white',
                      linewidth=0.5, zorder=5, label='Majorana stars')
    except Exception:
        pass
    
    ax.set_xlim(-L, L)
    ax.set_ylim(-L, L)
    ax.set_aspect('equal')
    ax.set_title(name, color='#ff6600', fontsize=12, fontweight='bold')
    if idx == 0:
        ax.legend(fontsize=8, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
    ax.tick_params(colors='white')
    for spine in ax.spines.values():
        spine.set_color('#333355')

fig.suptitle('QUANTUM HUSIMI FUNCTIONS IN STEREOGRAPHIC COORDINATES\n'
             'Spin-3 states on S²: probability density Q(z)·λ² with Majorana stars (★)',
             color='white', fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo5_quantum_husimi.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 5: Quantum Husimi — saved!")
