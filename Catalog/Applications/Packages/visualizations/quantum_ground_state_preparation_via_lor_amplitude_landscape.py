"""
Visualization 1: Amplitude Landscape of Certificate-Compiled Quantum States

Visualizes how the coefficient state amplitudes are distributed across
basis states for the transverse-field Ising model at different field
strengths. Shows the quantum phase transition through amplitude structure.

The key insight: Lorentzian certificate compilation produces quantum
states whose amplitudes reflect the polynomial's coefficient geometry.
Near a quantum phase transition, this geometry changes dramatically.
"""

import numpy as np
import matplotlib.pyplot as plt


def transverse_field_ising(n, J=1.0, h=1.0):
    dim = 2 ** n
    H = np.zeros((dim, dim))
    for state in range(dim):
        for i in range(n - 1):
            si = 1 - 2 * ((state >> i) & 1)
            sj = 1 - 2 * ((state >> (i + 1)) & 1)
            H[state, state] -= J * si * sj
        for i in range(n):
            flipped = state ^ (1 << i)
            H[state, flipped] -= h
    return H


def ground_state(H):
    evals, evecs = np.linalg.eigh(H)
    idx = np.argmin(evals)
    psi = evecs[:, idx]
    if np.sum(psi) < 0:
        psi = -psi
    return evals[idx], psi


def coeff_state(w):
    norm = np.sqrt(np.sum(w ** 2))
    return w / norm if norm > 1e-15 else w


# Parameters
n = 6
dim = 2 ** n
h_values = [0.3, 0.7, 1.0, 1.5, 2.5]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Coefficient State Amplitudes: Transverse-Field Ising Model\n'
             f'n = {n} sites, {dim} basis states',
             fontsize=14, fontweight='bold')

# Top row: amplitude bar charts
for idx, h in enumerate(h_values):
    if idx >= 3:
        break
    ax = axes[0, idx]
    H = transverse_field_ising(n, J=1.0, h=h)
    E0, psi = ground_state(H)
    psi_norm = coeff_state(np.abs(psi))

    # Sort by amplitude for clarity
    sorted_idx = np.argsort(-psi_norm)
    colors = plt.cm.viridis(psi_norm[sorted_idx] / max(psi_norm[sorted_idx]))
    ax.bar(range(dim), psi_norm[sorted_idx], color=colors, width=1.0)
    ax.set_title(f'h/J = {h}', fontsize=12)
    ax.set_xlabel('Basis state (sorted)')
    ax.set_ylabel('Amplitude |ψᵢ|')
    ax.set_xlim(-1, dim)

# Bottom left: heatmap across h values
ax = axes[1, 0]
h_scan = np.linspace(0.1, 3.0, 50)
amplitude_matrix = np.zeros((len(h_scan), dim))
for i, h in enumerate(h_scan):
    H = transverse_field_ising(n, J=1.0, h=h)
    _, psi = ground_state(H)
    psi_norm = coeff_state(np.abs(psi))
    amplitude_matrix[i] = psi_norm

im = ax.imshow(amplitude_matrix, aspect='auto', cmap='hot',
               extent=[0, dim, h_scan[-1], h_scan[0]])
ax.set_xlabel('Basis state index')
ax.set_ylabel('h/J')
ax.set_title('Amplitude Heatmap', fontsize=12)
plt.colorbar(im, ax=ax, label='|ψᵢ|')
ax.axhline(y=1.0, color='cyan', linestyle='--', alpha=0.7, label='QPT')
ax.legend(loc='upper right')

# Bottom middle: participation entropy
ax = axes[1, 1]
entropies = []
gaps = []
for h in h_scan:
    H = transverse_field_ising(n, J=1.0, h=h)
    evals = np.linalg.eigvalsh(H)
    _, psi = ground_state(H)
    probs = psi ** 2
    probs = probs[probs > 1e-15]
    entropy = -np.sum(probs * np.log2(probs))
    entropies.append(entropy)
    gaps.append(evals[1] - evals[0])

ax.plot(h_scan, entropies, 'b-', linewidth=2, label='Entropy')
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='QPT (h/J=1)')
ax.set_xlabel('h/J')
ax.set_ylabel('Participation Entropy (bits)')
ax.set_title('Entropy vs Field Strength', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Bottom right: spectral gap
ax = axes[1, 2]
ax.plot(h_scan, gaps, 'r-', linewidth=2)
ax.axvline(x=1.0, color='blue', linestyle='--', alpha=0.5, label='QPT')
ax.set_xlabel('h/J')
ax.set_ylabel('Spectral Gap (E₁ - E₀)')
ax.set_title('Spectral Gap', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Top row remaining
for idx, h in enumerate(h_values[3:]):
    ax = axes[0, idx + 3] if idx + 3 < 3 else None

plt.tight_layout()
plt.savefig('viz_amplitude_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_amplitude_landscape.png")
