"""
Visualization: Spectral Gap Recovery Accuracy

Demonstrates that spectral gaps are exactly recovered from mod-p data
when sufficiently many primes are used. Shows the transition from
approximate to exact recovery as more primes are added.

SELF-CONTAINED: All functions are defined inline.
"""

import numpy as np
import matplotlib.pyplot as plt
from functools import reduce


def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True


def primes_up_to(bound):
    return [p for p in range(2, bound + 1) if is_prime(p)]


def extended_gcd(a, b):
    if a == 0: return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def crt_recover(residues, moduli):
    M = reduce(lambda a, b: a * b, moduli, 1)
    x = 0
    for r, m in zip(residues, moduli):
        Mi = M // m
        _, inv, _ = extended_gcd(Mi, m)
        x = (x + r * Mi * inv) % M
    if x > M // 2: x -= M
    return x


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj


def spectral_gap(L):
    eigs = np.sort(np.linalg.eigvalsh(L))
    nonzero = [e for e in eigs if e > 1e-10]
    return float(nonzero[0]) if nonzero else 0.0


def recover_laplacian(L, primes):
    n = L.shape[0]
    L_rec = np.zeros_like(L)
    for i in range(n):
        for j in range(n):
            residues = [int(L[i, j] % p) for p in primes]
            L_rec[i, j] = crt_recover(residues, primes)
    return L_rec


# Create several test graphs
np.random.seed(42)
test_graphs = []

# Graph 1: Path graph
n1 = 6
adj1 = np.zeros((n1, n1), dtype=int)
for i in range(n1 - 1):
    adj1[i, i+1] = adj1[i+1, i] = 1
test_graphs.append(("Path (n=6)", adj1))

# Graph 2: Cycle graph
n2 = 8
adj2 = np.zeros((n2, n2), dtype=int)
for i in range(n2):
    adj2[i, (i+1) % n2] = adj2[(i+1) % n2, i] = 1
test_graphs.append(("Cycle (n=8)", adj2))

# Graph 3: Complete graph
n3 = 5
adj3 = np.ones((n3, n3), dtype=int) - np.eye(n3, dtype=int)
test_graphs.append(("Complete (n=5)", adj3))

# Graph 4: Star graph
n4 = 7
adj4 = np.zeros((n4, n4), dtype=int)
for i in range(1, n4):
    adj4[0, i] = adj4[i, 0] = 1
test_graphs.append(("Star (n=7)", adj4))

# Graph 5: Petersen-like
n5 = 6
adj5 = np.zeros((n5, n5), dtype=int)
edges = [(0,1),(0,2),(0,3),(1,2),(1,4),(2,5),(3,4),(3,5),(4,5)]
for i, j in edges:
    adj5[i, j] = adj5[j, i] = 1
test_graphs.append(("Petersen-like (n=6)", adj5))


fig, axes = plt.subplots(2, 3, figsize=(18, 11))
fig.suptitle('Spectral Gap Recovery from Mod-p Data',
             fontsize=16, fontweight='bold')

all_primes = primes_up_to(50)

# Panel 1-5: Recovery accuracy vs number of primes for each graph
for idx, (name, adj) in enumerate(test_graphs):
    ax = axes[idx // 3, idx % 3]
    L = graph_laplacian(adj)
    true_gap = spectral_gap(L)
    max_entry = int(np.max(np.abs(L)))

    num_primes_list = range(1, min(len(all_primes), 15) + 1)
    gaps = []
    errors = []
    products = []
    threshold = 2 * max_entry

    for k in num_primes_list:
        ps = all_primes[:k]
        L_rec = recover_laplacian(L, ps)
        rec_gap = spectral_gap(L_rec.astype(float))
        gaps.append(rec_gap)
        errors.append(abs(true_gap - rec_gap))
        products.append(reduce(lambda a, b: a * b, ps))

    # Find where recovery becomes exact
    exact_idx = None
    for i, prod in enumerate(products):
        if prod > threshold:
            exact_idx = i
            break

    ax.plot(list(num_primes_list), errors, 'ro-', linewidth=2, markersize=6,
            label='Recovery error')
    if exact_idx is not None:
        ax.axvline(x=exact_idx + 1, color='green', linestyle='--', alpha=0.7,
                   label=f'Exact recovery (k={exact_idx+1})')
        ax.fill_betweenx([0, max(errors) * 1.1 if max(errors) > 0 else 1],
                         exact_idx + 1, max(num_primes_list),
                         alpha=0.1, color='green')

    ax.set_xlabel('Number of primes', fontsize=11)
    ax.set_ylabel('|true gap - recovered gap|', fontsize=11)
    ax.set_title(f'{name}\nTrue gap = {true_gap:.4f}', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    if max(errors) > 0:
        ax.set_ylim(-0.01 * max(errors), max(errors) * 1.2)

# Panel 6: Summary - all graphs together
ax = axes[1, 2]
for name, adj in test_graphs:
    L = graph_laplacian(adj)
    true_gap = spectral_gap(L)
    max_entry = int(np.max(np.abs(L)))

    num_primes_list = range(1, min(len(all_primes), 15) + 1)
    errors = []
    for k in num_primes_list:
        ps = all_primes[:k]
        L_rec = recover_laplacian(L, ps)
        rec_gap = spectral_gap(L_rec.astype(float))
        errors.append(abs(true_gap - rec_gap))

    ax.semilogy(list(num_primes_list), [e + 1e-16 for e in errors],
                'o-', linewidth=1.5, markersize=4, label=name)

ax.set_xlabel('Number of primes', fontsize=11)
ax.set_ylabel('Recovery error (log scale)', fontsize=11)
ax.set_title('All Graphs: Error vs. Primes', fontsize=12, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.axhline(y=1e-15, color='gray', linestyle=':', alpha=0.5, label='Machine eps')

plt.tight_layout()
plt.savefig('viz_spectral_gap_recovery.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_spectral_gap_recovery.png")
