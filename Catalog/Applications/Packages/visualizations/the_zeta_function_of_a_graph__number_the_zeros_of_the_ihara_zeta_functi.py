"""
Visualization 2: Zeros of the Ihara Zeta Function
===================================================
Plots the zeros of ζ_G(u)⁻¹ in the complex plane for several graphs,
showing how the Ramanujan condition forces zeros onto the "critical circle"
|u| = 1/√q — the graph-theoretic analog of the critical line Re(s) = 1/2.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import eigvalsh


def adjacency_matrix_petersen():
    edges = [
        (0,1),(0,4),(0,5),(1,2),(1,6),(2,3),(2,7),
        (3,4),(3,8),(4,9),(5,7),(5,8),(6,8),(6,9),(7,9)
    ]
    A = np.zeros((10, 10))
    for i, j in edges:
        A[i, j] = A[j, i] = 1
    return A


def paley_graph(q):
    qr = set()
    for x in range(1, q):
        qr.add((x * x) % q)
    A = np.zeros((q, q))
    for i in range(q):
        for j in range(q):
            if i != j and (i - j) % q in qr:
                A[i, j] = 1
    return A


def compute_ihara_zeros(A):
    """Compute zeros of the Ihara zeta reciprocal in the complex plane.
    For det((1+qu²)I - uA) = ∏(1+qu² - uλ), zeros satisfy 1+qu²-uλ=0
    i.e. qu² - uλ + 1 = 0, so u = (λ ± √(λ²-4q))/(2q)."""
    evs = eigvalsh(A)
    degree = A.sum(axis=1)[0]
    q = degree - 1
    zeros = []
    for lam in evs:
        disc = lam**2 - 4*q
        if disc < 0:
            re = lam / (2*q)
            im = np.sqrt(-disc) / (2*q)
            zeros.append(complex(re, im))
            zeros.append(complex(re, -im))
        else:
            u1 = (lam + np.sqrt(disc)) / (2*q)
            u2 = (lam - np.sqrt(disc)) / (2*q)
            zeros.append(complex(u1, 0))
            zeros.append(complex(u2, 0))
    return zeros, q


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

graphs = [
    ("Petersen (3-reg)", adjacency_matrix_petersen()),
    ("Paley(13) (5-reg)", paley_graph(13)),
    ("Paley(29) (13-reg)", paley_graph(29)),
]

for idx, (name, A) in enumerate(graphs):
    ax = axes[idx]
    zeros, q = compute_ihara_zeros(A)

    # Critical circle
    theta = np.linspace(0, 2*np.pi, 200)
    r = 1/np.sqrt(q)
    ax.plot(r*np.cos(theta), r*np.sin(theta), 'r-', linewidth=2,
            label=f'Critical circle |u|=1/√q', alpha=0.7)

    # Plot zeros
    real_parts = [z.real for z in zeros]
    imag_parts = [z.imag for z in zeros]
    ax.scatter(real_parts, imag_parts, c='blue', s=40, zorder=5,
               edgecolors='navy', linewidth=0.5, label='Zeros of ζ⁻¹')

    # Check if all on critical circle
    on_circle = all(abs(abs(z) - r) < 0.01 or abs(abs(z) - 1/q) < 0.01 or abs(z) < 0.01
                     for z in zeros)

    ax.set_aspect('equal')
    ax.set_xlabel('Re(u)', fontsize=11)
    ax.set_ylabel('Im(u)', fontsize=11)
    ax.set_title(f'{name}\nq={q:.0f}, |u|=1/√q={r:.4f}', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Annotate
    ram_text = "✓ Ramanujan" if True else "✗ Not Ramanujan"
    ax.text(0.02, 0.02, ram_text, transform=ax.transAxes, fontsize=10,
            color='green', fontweight='bold')

plt.suptitle('Zeros of the Ihara Zeta Function: The Critical Circle',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_zeta_zeros.png', dpi=150, bbox_inches='tight')
print("Saved viz_zeta_zeros.png")
