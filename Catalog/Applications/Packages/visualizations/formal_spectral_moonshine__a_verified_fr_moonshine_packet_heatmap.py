#!/usr/bin/env python3
"""
Visualization: Moonshine Packet Heatmap

Creates a heatmap showing how McKay-Thompson series coefficients distribute
across conjugacy classes and grading degrees. This visualizes the core data
structure of moonshine: a matrix of values T_g(n) where rows are conjugacy
classes and columns are grading degrees.

The visualization reveals patterns in how representation-theoretic information
is encoded into q-series coefficients — the central mystery of moonshine.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# ============================================================
# Self-contained data
# ============================================================

def s3_data():
    table = np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex)
    sizes = np.array([1, 3, 2])
    return table, sizes, 6, ['triv', 'sign', 'std'], ['e', '(12)', '(123)']

def a5_data():
    phi = (1 + np.sqrt(5)) / 2
    psi = (1 - np.sqrt(5)) / 2
    table = np.array([
        [1,  1,   1,    1,    1   ],
        [3, -1,   0,    phi,  psi ],
        [3, -1,   0,    psi,  phi ],
        [4,  0,   1,   -1,   -1   ],
        [5,  1,  -1,    0,    0   ],
    ], dtype=complex)
    sizes = np.array([1, 15, 20, 12, 12])
    return table, sizes, 60, ['1', '3a', '3b', '4', '5'], \
           ['e', '(12)(34)', '(123)', '(12345)', '(13245)']

def decode(f, table, sizes, order):
    return np.array([np.sum(sizes * f * np.conj(table[i])) / order
                     for i in range(table.shape[0])])

# ============================================================
# Build moonshine packet data
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: S₃ McKay-Thompson coefficient matrix ---
ax = axes[0]
table, sizes, order, irr_names, class_names = s3_data()
n_max = 8

# Build coefficients: use symmetric powers of standard rep
# At identity: dim Sym^n(2-dim) = n+1
# Character values computed from traces
packet_data = np.zeros((len(class_names), n_max + 1))
for n in range(n_max + 1):
    # For the trivial class: always n+1
    packet_data[0, n] = n + 1
    # For transposition class: alternating ±1
    packet_data[1, n] = 1 if n % 2 == 0 else 0
    # For 3-cycle class: from generating function 1/((1-x)(1-x²))... simplified
    packet_data[2, n] = 1 if n % 3 == 0 else 0

im = ax.imshow(packet_data, aspect='auto', cmap='RdBu_r',
               vmin=-np.max(np.abs(packet_data)), vmax=np.max(np.abs(packet_data)))
ax.set_xticks(range(n_max + 1))
ax.set_yticks(range(len(class_names)))
ax.set_yticklabels(class_names, fontsize=10)
ax.set_xlabel('Degree n', fontsize=11)
ax.set_ylabel('Conjugacy class', fontsize=11)
ax.set_title('S₃: Moonshine Packet\nT_g(q) coefficients', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)

# Annotate values
for i in range(len(class_names)):
    for j in range(n_max + 1):
        ax.text(j, i, f'{packet_data[i,j]:.0f}', ha='center', va='center', fontsize=8,
                color='white' if abs(packet_data[i,j]) > np.max(packet_data)/2 else 'black')

# --- Panel 2: A₅ multiplicity matrix ---
ax = axes[1]
table, sizes, order, irr_names, class_names = a5_data()

# Build packet from dimensions of Sym^n(3a)
n_max_a5 = 10
mult_data = np.zeros((len(irr_names), n_max_a5 + 1))
for n in range(n_max_a5 + 1):
    sym_dim = comb(3 + n - 1, n)
    # At identity: the multiplicity decoding gives contributions from identity class only
    for i in range(len(irr_names)):
        mult_data[i, n] = np.real(sym_dim * np.conj(table[i, 0])) / order

im = ax.imshow(mult_data, aspect='auto', cmap='viridis')
ax.set_xticks(range(n_max_a5 + 1))
ax.set_yticks(range(len(irr_names)))
ax.set_yticklabels(irr_names, fontsize=10)
ax.set_xlabel('Degree n', fontsize=11)
ax.set_ylabel('Irreducible character', fontsize=11)
ax.set_title('A₅: Multiplicity Profile\nm_χ(Sym^n(3a))', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)

# --- Panel 3: Parseval energy distribution ---
ax = axes[2]
table, sizes, order, irr_names, class_names = a5_data()

# Show how total energy distributes across characters
n_range = range(1, 15)
total_energies = []
component_energies = {name: [] for name in irr_names}

for n in list(n_range):
    sym_dim = comb(3 + n - 1, n)
    class_fn = np.zeros(5, dtype=complex)
    class_fn[0] = sym_dim
    
    coeffs = decode(class_fn, table, sizes, order)
    total_e = np.sum(np.abs(coeffs) ** 2)
    total_energies.append(total_e)
    
    for i, name in enumerate(irr_names):
        component_energies[name].append(np.abs(coeffs[i]) ** 2)

# Stack plot
bottom = np.zeros(len(list(n_range)))
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
for i, name in enumerate(irr_names):
    vals = np.array(component_energies[name])
    ax.bar(list(n_range), vals, bottom=bottom, color=colors[i],
           alpha=0.8, label=name, width=0.8)
    bottom += vals

ax.set_xlabel('Degree n', fontsize=11)
ax.set_ylabel('Spectral energy |⟨f,χ⟩|²', fontsize=11)
ax.set_title('A₅: Parseval Energy\nDecomposition', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, title='Irrep', title_fontsize=9)

plt.suptitle('Moonshine Packets: From Traces to Spectra', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('moonshine_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved moonshine_heatmap.png")
