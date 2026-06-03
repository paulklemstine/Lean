#!/usr/bin/env python3
"""
Quantum Random Walks on Cayley Graphs: Numerical Demonstrations

Simulates classical and quantum random walks on Cayley graphs of
finite groups, measuring mixing times and spectral gaps.
"""

import numpy as np
from itertools import permutations


def cayley_adjacency_matrix(group_elements, generators, group_op):
    """Build adjacency matrix of Cayley graph Cay(G, S)."""
    n = len(group_elements)
    idx = {g: i for i, g in enumerate(group_elements)}
    A = np.zeros((n, n))
    for g in group_elements:
        for s in generators:
            h = group_op(g, s)
            A[idx[g], idx[h]] = 1
    return A


def spectral_gap(A):
    """Compute spectral gap of transition matrix P = A/d."""
    d = A.sum(axis=1)[0]  # regular graph
    P = A / d
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    lambda2 = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    return 1 - lambda2, eigenvalues


def classical_mixing_time(P, epsilon=0.01):
    """Compute classical mixing time by iterating P^t."""
    n = P.shape[0]
    uniform = np.ones(n) / n
    state = np.zeros(n)
    state[0] = 1.0
    for t in range(1, 10000):
        state = state @ P
        tv = 0.5 * np.sum(np.abs(state - uniform))
        if tv < epsilon:
            return t
    return 10000


def quantum_mixing_time(H, epsilon=0.01, max_steps=10000):
    """Compute quantum (continuous-time) mixing time.

    Evolution: |ψ(t)⟩ = exp(-iHt)|0⟩
    P_t(g) = |⟨g|exp(-iHt)|0⟩|^2
    """
    n = H.shape[0]
    uniform = np.ones(n) / n
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    best_t = max_steps
    # Sample times to find mixing
    for t_idx in range(1, max_steps):
        t = t_idx * 0.1
        U = eigenvectors @ np.diag(np.exp(-1j * eigenvalues * t)) @ eigenvectors.conj().T
        state = U[:, 0]
        probs = np.abs(state) ** 2
        tv = 0.5 * np.sum(np.abs(probs - uniform))
        if tv < epsilon:
            best_t = t_idx
            break
    return best_t


# ============================================================
# Demo 1: Cyclic group Z_n
# ============================================================
print("=" * 60)
print("Demo 1: Random walks on cyclic groups Z_n")
print("=" * 60)

for n in [5, 10, 20, 50, 100]:
    elements = list(range(n))
    generators = [1, n - 1]  # {+1, -1} mod n
    group_op = lambda g, s, n=n: (g + s) % n

    A = cayley_adjacency_matrix(elements, generators, group_op)
    gap, eigs = spectral_gap(A)
    P = A / A.sum(axis=1)[0]
    t_classical = classical_mixing_time(P)

    # Theoretical bound: gap ≈ 2π²/n² ≈ 2/n² (our proven bound)
    theoretical_gap = 2.0 / n**2
    predicted_mixing = int(np.ceil(1.0 / gap * np.log(n)))

    print(f"  Z_{n}: spectral_gap = {gap:.6f}, "
          f"2/n² = {theoretical_gap:.6f}, "
          f"classical_mix = {t_classical}, "
          f"predicted = {predicted_mixing}")

# ============================================================
# Demo 2: Symmetric group S_n with transposition generators
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Random walks on S_n with adjacent transpositions")
print("=" * 60)

for n in [3, 4, 5]:
    perms = list(permutations(range(n)))
    # Adjacent transpositions
    transpositions = []
    for i in range(n - 1):
        t = list(range(n))
        t[i], t[i + 1] = t[i + 1], t[i]
        transpositions.append(tuple(t))

    perm_op = lambda g, s: tuple(g[s[i]] for i in range(len(g)))

    A = cayley_adjacency_matrix(perms, transpositions, perm_op)
    gap, eigs = spectral_gap(A)
    P = A / A.sum(axis=1)[0]
    t_classical = classical_mixing_time(P)
    N = len(perms)

    # Quantum mixing (continuous-time)
    H = A.copy()
    t_quantum = quantum_mixing_time(H)
    sqrt_N = np.sqrt(N)

    print(f"  S_{n} (|G|={N}): spectral_gap = {gap:.4f}, "
          f"classical_mix = {t_classical}, "
          f"quantum_mix ≈ {t_quantum}, "
          f"√|G| = {sqrt_N:.1f}")

# ============================================================
# Demo 3: Spectral gap vs mixing time comparison
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Exponential decay bound verification")
print("=" * 60)

for gamma in [0.1, 0.2, 0.5]:
    print(f"\n  γ = {gamma}:")
    for t in [1, 5, 10, 20, 50]:
        lhs = (1 - gamma) ** t
        rhs = np.exp(-gamma * t)
        print(f"    t={t:3d}: (1-γ)^t = {lhs:.8f}, "
              f"exp(-γt) = {rhs:.8f}, "
              f"bound holds: {lhs <= rhs + 1e-15}")

# ============================================================
# Demo 4: Cyclic spectral gap lower bound verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Cyclic spectral gap bound: 2/n² ≤ 1-cos(2π/n)")
print("=" * 60)

for n in range(3, 51):
    lhs = 2.0 / n**2
    rhs = 1 - np.cos(2 * np.pi / n)
    ratio = rhs / lhs
    if n <= 10 or n % 10 == 0:
        print(f"  n={n:3d}: 2/n² = {lhs:.6f}, "
              f"1-cos(2π/n) = {rhs:.6f}, "
              f"ratio = {ratio:.4f}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Classical vs Quantum Mixing on Cayley Graphs

Plots the total variation distance over time for both classical and
quantum random walks on cyclic and symmetric group Cayley graphs.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def cayley_adjacency(elements, generators, group_op):
    n = len(elements)
    idx = {g: i for i, g in enumerate(elements)}
    A = np.zeros((n, n))
    for g in elements:
        for s in generators:
            A[idx[g], idx[group_op(g, s)]] = 1
    return A


def tv_classical(P, max_t=500):
    n = P.shape[0]
    uniform = np.ones(n) / n
    state = np.zeros(n); state[0] = 1.0
    tvs = []
    for t in range(max_t):
        tv = 0.5 * np.sum(np.abs(state - uniform))
        tvs.append(tv)
        state = state @ P
    return tvs


def tv_quantum(H, dt=0.1, max_steps=5000):
    n = H.shape[0]
    uniform = np.ones(n) / n
    evals, evecs = np.linalg.eigh(H)
    tvs = []
    times = []
    for step in range(max_steps):
        t = step * dt
        U = evecs @ np.diag(np.exp(-1j * evals * t)) @ evecs.conj().T
        probs = np.abs(U[:, 0]) ** 2
        tv = 0.5 * np.sum(np.abs(probs - uniform))
        tvs.append(tv)
        times.append(t)
    return times, tvs


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Classical vs Quantum Mixing on Cayley Graphs", fontsize=16, fontweight='bold')

# Panel 1: Z_20
n = 20
A = cayley_adjacency(list(range(n)), [1, n-1], lambda g, s: (g+s) % n)
P = A / 2
tvs_cl = tv_classical(P, 500)
times_q, tvs_q = tv_quantum(A, dt=0.5, max_steps=1000)

ax = axes[0, 0]
ax.plot(range(len(tvs_cl)), tvs_cl, 'b-', label='Classical', linewidth=2)
ax.plot(times_q, tvs_q, 'r-', alpha=0.7, label='Quantum', linewidth=1)
ax.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01')
ax.set_xlabel('Steps / Time')
ax.set_ylabel('Total Variation Distance')
ax.set_title(f'Z_{n} (cycle graph)')
ax.legend()
ax.set_yscale('log')
ax.set_ylim(1e-4, 1)

# Panel 2: Z_50
n = 50
A = cayley_adjacency(list(range(n)), [1, n-1], lambda g, s: (g+s) % n)
P = A / 2
tvs_cl = tv_classical(P, 2000)
times_q, tvs_q = tv_quantum(A, dt=0.5, max_steps=2000)

ax = axes[0, 1]
ax.plot(range(len(tvs_cl)), tvs_cl, 'b-', label='Classical', linewidth=2)
ax.plot(times_q, tvs_q, 'r-', alpha=0.7, label='Quantum', linewidth=1)
ax.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01')
ax.set_xlabel('Steps / Time')
ax.set_ylabel('Total Variation Distance')
ax.set_title(f'Z_{n} (cycle graph)')
ax.legend()
ax.set_yscale('log')
ax.set_ylim(1e-4, 1)

# Panel 3: Spectral gap scaling
ns = list(range(3, 101))
gaps = []
bounds = []
for nn in ns:
    gap_exact = 1 - np.cos(2 * np.pi / nn)
    gaps.append(gap_exact)
    bounds.append(2.0 / nn**2)

ax = axes[1, 0]
ax.plot(ns, gaps, 'b-', label='Exact: 1 - cos(2π/n)', linewidth=2)
ax.plot(ns, bounds, 'r--', label='Lower bound: 2/n²', linewidth=2)
ax.set_xlabel('n (group order)')
ax.set_ylabel('Spectral gap')
ax.set_title('Spectral Gap of Cycle Graph')
ax.legend()
ax.set_yscale('log')
ax.set_xscale('log')

# Panel 4: S_4 with adjacent transpositions
perms = list(permutations(range(4)))
trans = []
for i in range(3):
    t = list(range(4))
    t[i], t[i+1] = t[i+1], t[i]
    trans.append(tuple(t))
    trans.append(tuple(t))  # include inverse (same for transpositions)
# Deduplicate
trans = list(set(trans))

perm_op = lambda g, s: tuple(g[s[i]] for i in range(len(g)))
A = cayley_adjacency(perms, trans, perm_op)
P = A / A.sum(axis=1)[0]
tvs_cl = tv_classical(P, 100)
times_q, tvs_q = tv_quantum(A, dt=0.1, max_steps=1000)

ax = axes[1, 1]
ax.plot(range(len(tvs_cl)), tvs_cl, 'b-', label='Classical', linewidth=2)
ax.plot(times_q, tvs_q, 'r-', alpha=0.7, label='Quantum', linewidth=1)
ax.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='ε = 0.01')
ax.set_xlabel('Steps / Time')
ax.set_ylabel('Total Variation Distance')
ax.set_title('S₄ with adjacent transpositions')
ax.legend()
ax.set_yscale('log')
ax.set_ylim(1e-4, 1)

plt.tight_layout()
plt.savefig('mixing_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved mixing_comparison.png")
