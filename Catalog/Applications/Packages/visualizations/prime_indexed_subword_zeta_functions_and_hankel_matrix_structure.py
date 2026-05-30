"""
Visualization 3: Hankel Matrix Structure and Rank

Visualizes the Hankel matrices of different sequences and their rank profiles.
The Hankel matrix H[i,j] = s(i+j) connects sequences to formal power series
and algebraicity — a cross-domain bridge between automata theory and algebra.
"""

import matplotlib.pyplot as plt
import numpy as np

def thue_morse(n):
    return bin(n).count('1') % 2

def rudin_shapiro(n):
    bits = bin(n)[2:]
    pairs = sum(1 for i in range(len(bits)-1) if bits[i]=='1' and bits[i+1]=='1')
    return pairs % 2

def hankel_matrix(seq, n):
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i + j < len(seq):
                H[i, j] = seq[i + j]
    return H

# Generate sequences
N = 200
tm = [thue_morse(n) for n in range(N)]
rs = [rudin_shapiro(n) for n in range(N)]
const = [1] * N
periodic = [n % 3 for n in range(N)]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Hankel matrices
matrix_size = 15
sequences_for_matrix = [
    ('Thue-Morse', tm),
    ('Rudin-Shapiro', rs),
    ('Period-3', periodic),
]

for idx, (name, seq) in enumerate(sequences_for_matrix):
    H = hankel_matrix(seq, matrix_size)
    im = axes[0, idx].imshow(H, cmap='coolwarm', interpolation='nearest',
                              aspect='equal')
    axes[0, idx].set_title(f'Hankel Matrix: {name}', fontsize=12, fontweight='bold')
    axes[0, idx].set_xlabel('j')
    axes[0, idx].set_ylabel('i')
    plt.colorbar(im, ax=axes[0, idx], shrink=0.8)

    # Show symmetry line
    axes[0, idx].plot([-0.5, matrix_size-0.5], [-0.5, matrix_size-0.5],
                      'k--', alpha=0.3, linewidth=1)

# Row 2: Rank profiles
max_rank_size = 30
all_seqs = {
    'Thue-Morse': tm,
    'Rudin-Shapiro': rs,
    'Constant': const,
    'Period-3': periodic,
    'Period-7': [n % 7 for n in range(N)],
}

colors = ['#e74c3c', '#9b59b6', '#2ecc71', '#3498db', '#f39c12']

# Rank vs size
for (name, seq), color in zip(all_seqs.items(), colors):
    ranks = [int(np.linalg.matrix_rank(hankel_matrix(seq, n)))
             for n in range(1, max_rank_size + 1)]
    axes[1, 0].plot(range(1, max_rank_size + 1), ranks, 'o-',
                    label=name, color=color, markersize=3, linewidth=1.5)

axes[1, 0].plot(range(1, max_rank_size + 1), range(1, max_rank_size + 1),
                'k:', alpha=0.3, label='rank = n')
axes[1, 0].set_xlabel('Matrix size n', fontsize=11)
axes[1, 0].set_ylabel('Rank', fontsize=11)
axes[1, 0].set_title('Hankel Rank Profile', fontsize=12, fontweight='bold')
axes[1, 0].legend(fontsize=8)
axes[1, 0].grid(True, alpha=0.3)

# Determinant (absolute value) vs size
for (name, seq), color in zip(list(all_seqs.items())[:3], colors):
    dets = []
    for n in range(1, 16):
        H = hankel_matrix(seq, n)
        d = abs(np.linalg.det(H))
        dets.append(max(d, 1e-15))  # Avoid log(0)
    axes[1, 1].semilogy(range(1, 16), dets, 'o-',
                         label=name, color=color, markersize=4, linewidth=1.5)

axes[1, 1].set_xlabel('Matrix size n', fontsize=11)
axes[1, 1].set_ylabel('|det(H_n)| (log scale)', fontsize=11)
axes[1, 1].set_title('Hankel Determinant Decay', fontsize=12, fontweight='bold')
axes[1, 1].legend(fontsize=9)
axes[1, 1].grid(True, alpha=0.3)
axes[1, 1].axhline(y=1e-10, color='red', linestyle='--', alpha=0.3,
                    label='Numerical zero')

# Eigenvalue spectrum of Hankel matrix
n_eig = 20
for (name, seq), color in zip(list(all_seqs.items())[:3], colors):
    H = hankel_matrix(seq, n_eig)
    eigvals = np.sort(np.linalg.eigvalsh(H))[::-1]
    axes[1, 2].plot(range(1, n_eig + 1), eigvals, 'o-',
                    label=name, color=color, markersize=3, linewidth=1.5)

axes[1, 2].axhline(y=0, color='k', linestyle='-', alpha=0.2)
axes[1, 2].set_xlabel('Eigenvalue index', fontsize=11)
axes[1, 2].set_ylabel('Eigenvalue', fontsize=11)
axes[1, 2].set_title('Hankel Eigenvalue Spectrum', fontsize=12, fontweight='bold')
axes[1, 2].legend(fontsize=9)
axes[1, 2].grid(True, alpha=0.3)

fig.suptitle('Hankel Matrix Structure: The Bridge Between Sequences and Algebra',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_hankel.png', dpi=150, bbox_inches='tight')
print("Saved viz_hankel.png")
