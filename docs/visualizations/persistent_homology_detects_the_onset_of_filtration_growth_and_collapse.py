"""
Visualization: Meeting-Time Filtration Growth and Collapse

This script visualizes how the meeting-time filtration evolves over time
for random walks on SL₂(𝔽_p). It shows:
1. Visited-set growth curves for different primes (normalized by T/log p)
2. Collapse time markers
3. Edge density evolution

The key insight: after collapse time, the filtration graph becomes complete
and all topological features die — this is the deterministic mechanism
behind the universality conjecture.
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

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Growth curves across primes
ax = axes[0][0]
primes = [7, 13, 23, 37, 53]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(primes)))

for pi, p in enumerate(primes):
    T = max(int(5 * math.log(p)), 15)
    growths = []
    for trial in range(20):
        traj = simulate_walk(standard_generators(), p, T, seed=trial + p * 100)
        growths.append(visited_set_growth(traj))
    avg = np.mean(growths, axis=0)
    times = np.arange(T + 1) / max(math.log(p), 1)
    ax.plot(times, avg / sl2_order(p), color=colors[pi], linewidth=2,
            label=f'p={p}')

ax.set_xlabel('t / log(p)', fontsize=11)
ax.set_ylabel('Visited fraction of SL₂(𝔽_p)', fontsize=11)
ax.set_title('Visited-Set Growth (Standard Generators)', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Collapse time vs log(p)
ax = axes[0][1]
all_primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
gen_configs = {
    'Standard': standard_generators(),
    'Unipotent': unipotent_generators(),
}
markers = ['o', 's']

for gi, (name, gens) in enumerate(gen_configs.items()):
    log_ps = []
    avg_ct = []
    for p in all_primes:
        T = max(int(6 * math.log(p)), 20)
        cts = []
        for trial in range(15):
            traj = simulate_walk(gens, p, T, seed=trial + p * 200 + gi * 50000)
            cts.append(compute_collapse_time(traj))
        log_ps.append(math.log(p))
        avg_ct.append(np.mean(cts))

    ax.scatter(log_ps, avg_ct, marker=markers[gi], s=60, label=name, zorder=5)
    c = np.polyfit(log_ps, avg_ct, 1)
    xx = np.linspace(min(log_ps), max(log_ps), 50)
    ax.plot(xx, np.polyval(c, xx), '--', alpha=0.6,
            label=f'{name}: slope={c[0]:.2f}')

ax.set_xlabel('log(p)', fontsize=11)
ax.set_ylabel('Collapse time', fontsize=11)
ax.set_title('Collapse Time ~ C · log(p)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Edge density evolution
ax = axes[1][0]
p = 23
T = 30
traj = simulate_walk(standard_generators(), p, T, seed=777)
growth = visited_set_growth(traj)
ct = compute_collapse_time(traj)

V = np.array(growth)
edges = V * (V - 1) // 2  # complete graph on visited set
max_possible = sl2_order(p) * (sl2_order(p) - 1) // 2
density = edges / max(max_possible, 1)

ax.fill_between(range(T + 1), density, alpha=0.3, color='steelblue')
ax.plot(range(T + 1), density, color='steelblue', linewidth=2, label='Edge density')
ax.axvline(x=ct, color='red', linestyle='--', linewidth=1.5,
           label=f'Collapse time = {ct}')
ax.set_xlabel('Time step', fontsize=11)
ax.set_ylabel('Edge density (of full group)', fontsize=11)
ax.set_title(f'Edge Density Evolution (p={p})', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: Heatmap of visited-set sizes across (p, t/log(p))
ax = axes[1][1]
primes_heat = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
t_ratios = np.linspace(0, 5, 25)
heatmap = np.zeros((len(primes_heat), len(t_ratios)))

for pi, p in enumerate(primes_heat):
    for ti, ratio in enumerate(t_ratios):
        T = max(int(ratio * math.log(p)), 1)
        fracs = []
        for trial in range(10):
            traj = simulate_walk(standard_generators(), p, T, seed=trial + p * 300)
            g = visited_set_growth(traj)
            fracs.append(g[-1] / sl2_order(p))
        heatmap[pi, ti] = np.mean(fracs)

im = ax.imshow(heatmap, aspect='auto', origin='lower', cmap='inferno',
               extent=[t_ratios[0], t_ratios[-1], 0, len(primes_heat)])
ax.set_yticks(np.arange(len(primes_heat)) + 0.5)
ax.set_yticklabels([str(p) for p in primes_heat])
ax.set_xlabel('t / log(p)', fontsize=11)
ax.set_ylabel('Prime p', fontsize=11)
ax.set_title('Coverage Heatmap', fontsize=12)
plt.colorbar(im, ax=ax, label='Fraction visited')

plt.suptitle('Meeting-Time Filtration: Growth, Collapse, and Coverage',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_filtration_growth.png', dpi=150, bbox_inches='tight')
plt.close()
