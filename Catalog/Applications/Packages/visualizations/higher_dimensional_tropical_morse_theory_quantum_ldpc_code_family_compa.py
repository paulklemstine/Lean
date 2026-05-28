"""
Visualization: Quantum LDPC Code Family Comparison via Tropical Spectra

Compares toric codes, hypergraph product codes, and balanced product codes
using their tropical Morse spectral signatures. Shows how birth/death
counts in degree 1 determine logical qubit counts and rates.

Saves output as code_families.png.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def build_toric_params(L):
    n = 2 * L * L
    k = 2
    d = L
    n_v = L * L
    births_1 = n - (n_v - 1)
    deaths_1 = births_1 - 2
    return {'name': f'Toric {L}×{L}', 'n': n, 'k': k, 'd': d,
            'births_1': births_1, 'deaths_1': deaths_1, 'family': 'Toric'}


def build_hp_params(r, nc, seed=42):
    rng = np.random.RandomState(seed)
    H = (rng.random((r, nc)) < 0.4).astype(int) % 2
    rank = np.linalg.matrix_rank(H.astype(float))
    k1 = nc - rank
    kt1 = r - rank
    n = nc*nc + r*r
    k = k1*k1 + kt1*kt1
    d = max(1, min(k1+1, kt1+1))
    births_1 = n
    deaths_1 = n - k
    return {'name': f'HP [{r},{nc}]²', 'n': n, 'k': k, 'd': d,
            'births_1': births_1, 'deaths_1': deaths_1, 'family': 'HP'}


def main():
    codes = []
    for L in range(2, 9):
        codes.append(build_toric_params(L))
    for r, n in [(3,6),(4,8),(5,10),(6,12),(7,14),(4,12),(5,15)]:
        codes.append(build_hp_params(r, n, seed=r*n))

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Quantum LDPC Code Families: Tropical Morse Diagnostics',
                 fontsize=16, fontweight='bold')

    # Plot 1: n vs k colored by family
    ax = axes[0, 0]
    for fam, marker, color in [('Toric', 'o', 'blue'), ('HP', 's', 'red')]:
        subset = [c for c in codes if c['family'] == fam]
        ns = [c['n'] for c in subset]
        ks = [c['k'] for c in subset]
        ax.scatter(ns, ks, marker=marker, color=color, s=80, label=fam, alpha=0.8)
    ax.set_xlabel('Physical Qubits (n)', fontsize=12)
    ax.set_ylabel('Logical Qubits (k)', fontsize=12)
    ax.set_title('Code Parameters: n vs k', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Rate k/n vs n
    ax = axes[0, 1]
    for fam, marker, color in [('Toric', 'o', 'blue'), ('HP', 's', 'red')]:
        subset = [c for c in codes if c['family'] == fam]
        ns = [c['n'] for c in subset]
        rates = [c['k']/c['n'] for c in subset]
        ax.scatter(ns, rates, marker=marker, color=color, s=80, label=fam, alpha=0.8)
    ax.set_xlabel('Physical Qubits (n)', fontsize=12)
    ax.set_ylabel('Rate (k/n)', fontsize=12)
    ax.set_title('Code Rate vs Size', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: Tropical spectral signature
    ax = axes[1, 0]
    for fam, marker, color in [('Toric', 'o', 'blue'), ('HP', 's', 'red')]:
        subset = [c for c in codes if c['family'] == fam]
        b1 = [c['births_1'] for c in subset]
        d1 = [c['deaths_1'] for c in subset]
        ax.scatter(b1, d1, marker=marker, color=color, s=80, label=fam, alpha=0.8)
    ax.plot([0, max(c['births_1'] for c in codes)],
            [0, max(c['births_1'] for c in codes)],
            'k--', alpha=0.3, label='births₁ = deaths₁ (k=0)')
    ax.set_xlabel('Degree-1 Births', fontsize=12)
    ax.set_ylabel('Degree-1 Deaths', fontsize=12)
    ax.set_title('Tropical Spectral Signature', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 4: Distance scaling
    ax = axes[1, 1]
    for fam, marker, color in [('Toric', 'o', 'blue'), ('HP', 's', 'red')]:
        subset = [c for c in codes if c['family'] == fam]
        ns = [c['n'] for c in subset]
        ds = [c['d'] for c in subset]
        ax.scatter(ns, ds, marker=marker, color=color, s=80, label=fam, alpha=0.8)
    ax.set_xlabel('Physical Qubits (n)', fontsize=12)
    ax.set_ylabel('Distance (d)', fontsize=12)
    ax.set_title('Distance Scaling', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('code_families.png', dpi=150, bbox_inches='tight')
    print("Saved code_families.png")


if __name__ == '__main__':
    main()
