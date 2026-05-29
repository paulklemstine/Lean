"""
Visualization: Universality Test for Persistence Summaries

This script tests the central conjecture: that persistence summaries of
random walks on SL₂(𝔽_p) become independent of the generating measure
above a critical time scale T ~ C·log(p).

Three different generating measures are compared:
- Standard generators (S, T) — the classical modular group generators
- Unipotent generators (U, L) — upper/lower triangular
- Biased unipotent — same support, non-uniform weights

If universality holds, normalized curves should collapse as p grows.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


# ---- Inline all needed functions ----

def mat_mul_mod(A, B, p):
    return (A @ B) % p

def mat_to_tuple(A):
    return tuple(A.flatten())

def reduce_mod_p(A, p):
    return A % p

def sl2_order(p):
    return p * (p * p - 1)

def standard_generators():
    S = np.array([[0, -1], [1, 0]])
    T = np.array([[1, 1], [0, 1]])
    return [S, np.array([[0, 1], [-1, 0]]), T, np.array([[1, -1], [0, 1]])]

def unipotent_generators():
    U = np.array([[1, 1], [0, 1]])
    L = np.array([[1, 0], [1, 1]])
    return [U, np.array([[1, -1], [0, 1]]), L, np.array([[1, 0], [-1, 1]])]

def simulate_walk(generators, p, T, weights=None, seed=None):
    rng = np.random.RandomState(seed)
    if weights is None:
        weights = [1.0 / len(generators)] * len(generators)
    gens_mod = [reduce_mod_p(g, p) for g in generators]
    identity = np.eye(2, dtype=int) % p
    trajectory = [identity.copy()]
    current = identity.copy()
    for _ in range(T):
        idx = rng.choice(len(gens_mod), p=weights)
        current = mat_mul_mod(current, gens_mod[idx], p)
        trajectory.append(current.copy())
    return trajectory

def visited_set_growth(trajectory):
    seen = set()
    counts = []
    for state in trajectory:
        seen.add(mat_to_tuple(state))
        counts.append(len(seen))
    return counts

def compute_collapse_time(trajectory):
    first_time = {}
    for t, state in enumerate(trajectory):
        key = mat_to_tuple(state)
        if key not in first_time:
            first_time[key] = t
    return max(first_time.values()) if first_time else 0


# ---- Main Visualization ----

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

configs = {
    'Standard (S,T)': (standard_generators(), None, 'tab:blue'),
    'Unipotent (U,L)': (unipotent_generators(), None, 'tab:orange'),
    'Biased Unipotent': (unipotent_generators(), [0.4, 0.1, 0.1, 0.4], 'tab:green'),
}

primes = [7, 11, 19, 31, 43, 53]
n_trials = 25

# Top row: visited-set growth curves
for pi, p in enumerate(primes[:3]):
    ax = axes[0][pi]
    T = max(int(5 * math.log(p)), 15)
    times_norm = np.arange(T + 1) / max(math.log(p), 1)

    for name, (gens, weights, color) in configs.items():
        all_growths = []
        for trial in range(n_trials):
            traj = simulate_walk(gens, p, T, weights, seed=trial + p * 1000)
            all_growths.append(visited_set_growth(traj))
        avg = np.mean(all_growths, axis=0)
        std = np.std(all_growths, axis=0)
        norm = sl2_order(p)
        ax.plot(times_norm, avg / norm, color=color, linewidth=2, label=name)
        ax.fill_between(times_norm, (avg - std) / norm, (avg + std) / norm,
                        alpha=0.15, color=color)

    ax.set_title(f'p = {p}, |SL₂| = {sl2_order(p)}', fontsize=11)
    ax.set_xlabel('t / log(p)')
    if pi == 0:
        ax.set_ylabel('Visited fraction')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

# Bottom row: larger primes
for pi, p in enumerate(primes[3:]):
    ax = axes[1][pi]
    T = max(int(5 * math.log(p)), 15)
    times_norm = np.arange(T + 1) / max(math.log(p), 1)

    for name, (gens, weights, color) in configs.items():
        all_growths = []
        for trial in range(n_trials):
            traj = simulate_walk(gens, p, T, weights, seed=trial + p * 2000)
            all_growths.append(visited_set_growth(traj))
        avg = np.mean(all_growths, axis=0)
        std = np.std(all_growths, axis=0)
        norm = sl2_order(p)
        ax.plot(times_norm, avg / norm, color=color, linewidth=2, label=name)
        ax.fill_between(times_norm, (avg - std) / norm, (avg + std) / norm,
                        alpha=0.15, color=color)

    ax.set_title(f'p = {p}, |SL₂| = {sl2_order(p)}', fontsize=11)
    ax.set_xlabel('t / log(p)')
    if pi == 0:
        ax.set_ylabel('Visited fraction')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

# Summary panel
ax = axes[1][2]
# Plot inter-measure distance vs prime
primes_dist = [5, 7, 11, 13, 17, 23, 29, 37, 43, 53]
config_list = list(configs.items())

for i in range(len(config_list)):
    for j in range(i + 1, len(config_list)):
        n1, (g1, w1, c1) = config_list[i]
        n2, (g2, w2, c2) = config_list[j]
        distances = []
        for p in primes_dist:
            T = max(int(4 * math.log(p)), 10)
            g1_avg = []
            g2_avg = []
            for trial in range(15):
                t1 = simulate_walk(g1, p, T, w1, seed=trial + p * 3000)
                t2 = simulate_walk(g2, p, T, w2, seed=trial + p * 4000)
                v1 = np.array(visited_set_growth(t1)) / sl2_order(p)
                v2 = np.array(visited_set_growth(t2)) / sl2_order(p)
                g1_avg.append(v1)
                g2_avg.append(v2)
            m1 = np.mean(g1_avg, axis=0)
            m2 = np.mean(g2_avg, axis=0)
            dist = np.sqrt(np.mean((m1 - m2) ** 2))
            distances.append(dist)
        ax.plot([math.log(p) for p in primes_dist], distances,
                'o-', linewidth=1.5, markersize=5,
                label=f'{n1[:8]} vs {n2[:8]}')

ax.set_xlabel('log(p)', fontsize=11)
ax.set_ylabel('Inter-measure distance', fontsize=11)
ax.set_title('Universality: Distance → 0?', fontsize=11)
ax.legend(fontsize=7)
ax.grid(True, alpha=0.3)

plt.suptitle('Universality Test: Do Persistence Summaries Collapse Across Measures?',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_universality_test.png', dpi=150, bbox_inches='tight')
plt.close()
