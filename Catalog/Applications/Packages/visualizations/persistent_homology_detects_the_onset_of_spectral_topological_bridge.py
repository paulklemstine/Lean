"""
Visualization: Spectral-Topological Bridge

This script illustrates the connection between spectral gap (expansion)
and topological collapse in the meeting-time filtration. It compares:
1. SL₂(𝔽_p) walks (strong expanders, spectral gap ~1)
2. Abelian walks on (ℤ/pℤ)² (no expansion, spectral gap → 0)
3. Cyclic walks on ℤ/Nℤ (poor expansion)

The key theorem: expansion forces rapid coverage, which forces topological
collapse. Non-expanding groups retain topological complexity much longer.
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

def simulate_abelian_walk(p, T, seed=None):
    rng = np.random.RandomState(seed)
    steps = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    pos = (0, 0)
    trajectory = [pos]
    for _ in range(T):
        dx, dy = steps[rng.randint(4)]
        pos = ((pos[0] + dx) % p, (pos[1] + dy) % p)
        trajectory.append(pos)
    return trajectory

def simulate_cyclic_walk(N, T, seed=None):
    rng = np.random.RandomState(seed)
    pos = 0
    trajectory = [pos]
    for _ in range(T):
        pos = (pos + rng.choice([-1, 1])) % N
        trajectory.append(pos)
    return trajectory

def generic_visited_growth(trajectory):
    seen = set()
    counts = []
    for state in trajectory:
        if isinstance(state, np.ndarray):
            state = tuple(state.flatten())
        seen.add(state)
        counts.append(len(seen))
    return counts


# ---- Main Visualization ----

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Growth comparison for a single prime
ax = axes[0][0]
p = 23
N_sl2 = sl2_order(p)
N_ab = p * p
N_cyc = N_sl2  # use same group order for fair comparison
T = 60
n_trials = 20

# SL₂ growth
sl2_growths = []
for trial in range(n_trials):
    traj = simulate_walk(standard_generators(), p, T, seed=trial)
    sl2_growths.append(np.array(visited_set_growth(traj)) / N_sl2)
sl2_mean = np.mean(sl2_growths, axis=0)

# Abelian growth
ab_growths = []
for trial in range(n_trials):
    traj = simulate_abelian_walk(p, T, seed=trial + 10000)
    ab_growths.append(np.array(generic_visited_growth(traj)) / N_ab)
ab_mean = np.mean(ab_growths, axis=0)

# Cyclic growth (on group of size ~N_sl2, use ℤ/NZ with N=p²)
cyc_N = p * p
cyc_growths = []
for trial in range(n_trials):
    traj = simulate_cyclic_walk(cyc_N, T, seed=trial + 20000)
    cyc_growths.append(np.array(generic_visited_growth(traj)) / cyc_N)
cyc_mean = np.mean(cyc_growths, axis=0)

times = np.arange(T + 1)
ax.plot(times, sl2_mean, 'b-', linewidth=2.5, label=f'SL₂(𝔽_{p}) (expander)')
ax.plot(times, ab_mean, 'r--', linewidth=2, label=f'(ℤ/{p}ℤ)² (abelian)')
ax.plot(times, cyc_mean, 'g:', linewidth=2, label=f'ℤ/{cyc_N}ℤ (cyclic)')
ax.set_xlabel('Time step', fontsize=11)
ax.set_ylabel('Visited fraction', fontsize=11)
ax.set_title(f'Expansion Drives Coverage (p={p})', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Cycle defect proxy (H₁ surrogate)
ax = axes[0][1]

def cycle_defect_profile(growth_curve, group_size):
    """Cycle rank = E - V + 1 where E = V(V-1)/2 for complete graph on visited set."""
    V = np.array(growth_curve, dtype=float)
    return np.maximum(0, (V - 1) * (V - 2) / 2)

sl2_cycles = cycle_defect_profile(sl2_mean * N_sl2, N_sl2) / max(N_sl2, 1)
ab_cycles = cycle_defect_profile(ab_mean * N_ab, N_ab) / max(N_ab, 1)

ax.plot(times, sl2_cycles, 'b-', linewidth=2.5, label='SL₂ cycle rank')
ax.plot(times, ab_cycles, 'r--', linewidth=2, label='Abelian cycle rank')
ax.set_xlabel('Time step', fontsize=11)
ax.set_ylabel('Normalized cycle rank', fontsize=11)
ax.set_title('1-Cycle Proxy: Rapid Growth = Rapid Collapse', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Collapse time scaling comparison
ax = axes[1][0]
primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]

sl2_collapse = []
ab_collapse = []
for p in primes:
    T_walk = max(int(8 * math.log(p)), 20)

    cts_sl2 = []
    for trial in range(15):
        traj = simulate_walk(standard_generators(), p, T_walk, seed=trial + p * 500)
        cts_sl2.append(compute_collapse_time(traj))
    sl2_collapse.append(np.mean(cts_sl2))

    cts_ab = []
    for trial in range(15):
        traj = simulate_abelian_walk(p, T_walk, seed=trial + p * 600)
        first_time = {}
        for t, state in enumerate(traj):
            if state not in first_time:
                first_time[state] = t
        cts_ab.append(max(first_time.values()) if first_time else 0)
    ab_collapse.append(np.mean(cts_ab))

log_ps = [math.log(p) for p in primes]
ax.scatter(log_ps, sl2_collapse, color='blue', s=60, zorder=5, label='SL₂ collapse')
ax.scatter(log_ps, ab_collapse, color='red', s=60, marker='s', zorder=5,
           label='Abelian collapse')

# Fit lines
c_sl2 = np.polyfit(log_ps, sl2_collapse, 1)
c_ab = np.polyfit(log_ps, ab_collapse, 1)
xx = np.linspace(min(log_ps), max(log_ps), 50)
ax.plot(xx, np.polyval(c_sl2, xx), 'b--', alpha=0.7,
        label=f'SL₂ fit: {c_sl2[0]:.1f}·log(p)')
ax.plot(xx, np.polyval(c_ab, xx), 'r--', alpha=0.7,
        label=f'Abelian fit: {c_ab[0]:.1f}·log(p)')

ax.set_xlabel('log(p)', fontsize=11)
ax.set_ylabel('Collapse time', fontsize=11)
ax.set_title('Collapse Scaling: Expanders Win', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Phase diagram
ax = axes[1][1]
primes_phase = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
c_values = np.linspace(0.5, 6, 20)
phase = np.zeros((len(primes_phase), len(c_values)))

for pi, p in enumerate(primes_phase):
    for ci, c in enumerate(c_values):
        T_test = max(int(c * math.log(p)), 2)
        fracs = []
        for trial in range(10):
            traj = simulate_walk(standard_generators(), p, T_test,
                                 seed=trial + p * 700 + ci * 100)
            g = visited_set_growth(traj)
            fracs.append(g[-1] / sl2_order(p))
        phase[pi, ci] = np.mean(fracs)

im = ax.imshow(phase, aspect='auto', origin='lower', cmap='RdYlBu_r',
               extent=[c_values[0], c_values[-1], 0, len(primes_phase)],
               vmin=0, vmax=0.5)
ax.set_yticks(np.arange(len(primes_phase)) + 0.5)
ax.set_yticklabels([str(p) for p in primes_phase])
ax.set_xlabel('c in T = c·log(p)', fontsize=11)
ax.set_ylabel('Prime p', fontsize=11)
ax.set_title('Phase Diagram: Coverage vs Scale', fontsize=12)
plt.colorbar(im, ax=ax, label='Coverage fraction')

# Mark approximate phase boundary
ax.axvline(x=2.5, color='white', linestyle='--', linewidth=2, alpha=0.8)
ax.text(2.7, len(primes_phase) - 1, 'Phase\nboundary', color='white',
        fontsize=9, va='top')

plt.suptitle('Spectral-Topological Bridge: Expansion Forces Persistence Collapse',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_spectral_bridge.png', dpi=150, bbox_inches='tight')
plt.close()
