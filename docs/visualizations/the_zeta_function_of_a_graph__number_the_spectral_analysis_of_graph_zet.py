"""
Visualization 1: Spectral Analysis of Graph Zeta Functions
===========================================================
Visualizes the eigenvalue distribution of regular graphs compared to the
Ramanujan bound and the Kesten-McKay distribution. Shows how Ramanujan
graphs satisfy the graph-theoretic Riemann hypothesis.
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


def kesten_mckay_density(x, q):
    if abs(x) >= 2 * np.sqrt(q):
        return 0.0
    num = (q + 1) * np.sqrt(4 * q - x**2)
    den = 2 * np.pi * ((q + 1)**2 - x**2)
    return num / den


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Petersen graph eigenvalues
ax = axes[0, 0]
A = adjacency_matrix_petersen()
evs = eigvalsh(A)
q = 2
bound = 2 * np.sqrt(q)
ax.stem(range(len(evs)), np.sort(evs)[::-1], linefmt='b-', markerfmt='bo', basefmt='k-')
ax.axhline(y=bound, color='r', linestyle='--', label=f'2√q = {bound:.2f}')
ax.axhline(y=-bound, color='r', linestyle='--')
ax.axhline(y=3, color='g', linestyle=':', alpha=0.5, label='Trivial eigenvalue')
ax.set_title('Petersen Graph Eigenvalues (3-regular)', fontsize=12, fontweight='bold')
ax.set_xlabel('Index')
ax.set_ylabel('Eigenvalue')
ax.legend()

# Panel 2: Paley(29) eigenvalue histogram vs Kesten-McKay
ax = axes[0, 1]
A = paley_graph(29)
evs = eigvalsh(A)
degree = A.sum(axis=1)[0]
q = degree - 1
bound = 2 * np.sqrt(q)
nontrivial = [ev for ev in evs if abs(abs(ev) - degree) > 1e-10]
ax.hist(nontrivial, bins=15, density=True, alpha=0.7, color='steelblue', label='Empirical')
x_km = np.linspace(-bound - 0.5, bound + 0.5, 300)
y_km = [kesten_mckay_density(x, q) for x in x_km]
ax.plot(x_km, y_km, 'r-', linewidth=2, label='Kesten-McKay')
ax.axvline(x=bound, color='orange', linestyle='--', alpha=0.8, label=f'±2√q = ±{bound:.1f}')
ax.axvline(x=-bound, color='orange', linestyle='--', alpha=0.8)
ax.set_title('Paley(29): Spectrum vs Kesten-McKay', fontsize=12, fontweight='bold')
ax.set_xlabel('Eigenvalue')
ax.set_ylabel('Density')
ax.legend(fontsize=9)

# Panel 3: Ramanujan margin across Paley graphs
ax = axes[1, 0]
primes = [5, 13, 17, 29, 37, 41, 53, 61, 73, 89]
margins = []
max_nts = []
bounds_list = []
for p in primes:
    A = paley_graph(p)
    degree = A.sum(axis=1)[0]
    q = degree - 1
    bound = 2 * np.sqrt(q)
    evs = eigvalsh(A)
    nontrivial = [ev for ev in evs if abs(abs(ev) - degree) > 1e-10]
    max_nt = max(abs(ev) for ev in nontrivial)
    margins.append(bound - max_nt)
    max_nts.append(max_nt)
    bounds_list.append(bound)

ax.bar(range(len(primes)), margins, color='forestgreen', alpha=0.8)
ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=9)
ax.set_xlabel('Paley Graph Order (prime q)')
ax.set_ylabel('Ramanujan Margin (2√q - max|λ_nt|)')
ax.set_title('Ramanujan Margin: All Paley Graphs Pass', fontsize=12, fontweight='bold')
ax.axhline(y=0, color='r', linestyle='-', linewidth=0.8)

# Panel 4: Max non-trivial eigenvalue vs bound
ax = axes[1, 1]
ax.plot(primes, max_nts, 'bo-', label='max|λ_nt|', markersize=6)
ax.plot(primes, bounds_list, 'r^--', label='2√q (Ramanujan bound)', markersize=6)
ax.fill_between(primes, 0, bounds_list, alpha=0.1, color='red')
ax.set_xlabel('Paley Graph Order (prime q)')
ax.set_ylabel('Eigenvalue')
ax.set_title('Eigenvalue vs Ramanujan Bound', fontsize=12, fontweight='bold')
ax.legend()

plt.suptitle('Spectral Analysis of Graph Zeta Functions', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral.png")
