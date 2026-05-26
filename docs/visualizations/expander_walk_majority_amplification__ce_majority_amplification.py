#!/usr/bin/env python3
"""
Visualization: Majority Vote Amplification on S_5

Shows how the majority error decreases with walk length k for different
bias levels δ. Compares empirical error with the certified Chebyshev bound:
    Pr[majority fails] ≤ (1+ρ)/((1-ρ) · 4δ² · k)

Also shows the random-bit savings of the expander walk vs independent sampling.

SELF-CONTAINED — does not import from local modules.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (14, 5.5),
})

# ── Build S_5 Cayley graph ──────────────────────────────────────

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0]*len(p)
    for i,v in enumerate(p): inv[v] = i
    return tuple(inv)

IDENTITY = (0,1,2,3,4)
SIGMA = (1,2,3,4,0)
TAU = (1,0,2,3,4)
GENS = [SIGMA, inverse(SIGMA), TAU, inverse(TAU)]

elements = {IDENTITY}
frontier = [IDENTITY]
while frontier:
    nxt = []
    for g in frontier:
        for s in GENS:
            h = compose(s, g)
            if h not in elements:
                elements.add(h)
                nxt.append(h)
    frontier = nxt
S5 = sorted(elements)
IDX = {p:i for i,p in enumerate(S5)}
N = len(S5)

P = np.zeros((N,N))
for i,g in enumerate(S5):
    for s in GENS:
        P[i, IDX[compose(s,g)]] += 0.25

evals = np.sort(np.linalg.eigvalsh(P))[::-1]
rho = max(abs(evals[1]), abs(evals[-1]))
C_rho = (1+rho)/(1-rho)

# ── Compute majority errors ────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

k_values = [1, 2, 3, 5, 7, 10, 15, 20, 30, 50]
delta_configs = [
    (0.05, 'tab:blue', 'δ = 0.05'),
    (0.10, 'tab:orange', 'δ = 0.10'),
    (0.15, 'tab:green', 'δ = 0.15'),
    (0.20, 'tab:red', 'δ = 0.20'),
]

rng = np.random.RandomState(123)

for delta, color, label in delta_configs:
    bias = 0.5 + delta
    num_ones = int(round(bias * N))
    perm = rng.permutation(N)
    f = np.zeros(N)
    f[perm[:num_ones]] = 1
    actual_mean = f.mean()
    actual_delta = actual_mean - 0.5

    empirical_errors = []
    certified_bounds = []

    for k in k_values:
        failures = 0
        for start in range(N):
            state = np.zeros(N)
            state[start] = 1
            total = 0
            for _ in range(k):
                total += f @ state
                state = P.T @ state
            if total / k <= 0.5:
                failures += 1
        emp_err = failures / N
        cert_bound = C_rho / (4 * actual_delta**2 * k) if actual_delta > 0 else 999
        empirical_errors.append(max(emp_err, 1e-4))
        certified_bounds.append(min(cert_bound, 10))

    ax1.semilogy(k_values, empirical_errors, 'o-', color=color,
                 label=f'{label} (empirical)', linewidth=2, markersize=5)
    ax1.semilogy(k_values, certified_bounds, '--', color=color,
                 label=f'{label} (certified)', linewidth=1.5, alpha=0.6)

ax1.set_xlabel('Walk length k')
ax1.set_ylabel('Majority failure probability')
ax1.set_title('Majority Amplification: Error vs Walk Length')
ax1.legend(loc='upper right', framealpha=0.9, fontsize=9, ncol=2)
ax1.set_ylim(1e-4, 15)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

# ── Panel 2: Random-bit savings ─────────────────────────────────

k_range = np.arange(1, 101)
init_bits = math.ceil(math.log2(N))
step_bits = math.ceil(math.log2(4))

walk_bits = init_bits + k_range * step_bits
indep_bits = k_range * init_bits

ax2.plot(k_range, indep_bits, 'r-', linewidth=2.5, label='Independent sampling')
ax2.plot(k_range, walk_bits, 'b-', linewidth=2.5, label='Expander walk')
ax2.fill_between(k_range, walk_bits, indep_bits, alpha=0.15, color='green',
                  label='Random-bit savings')

ax2.set_xlabel('Number of samples k')
ax2.set_ylabel('Random bits required')
ax2.set_title('Random-Bit Cost: Walk vs Independent')
ax2.legend(loc='upper left', framealpha=0.9)
ax2.grid(True, alpha=0.3)

# Annotate savings
k_anno = 50
saving_pct = (1 - (init_bits + k_anno*step_bits) / (k_anno*init_bits)) * 100
ax2.annotate(f'{saving_pct:.0f}% savings\nat k={k_anno}',
             xy=(k_anno, init_bits + k_anno*step_bits),
             xytext=(k_anno+15, init_bits + k_anno*step_bits + 100),
             arrowprops=dict(arrowstyle='->', color='green', lw=2),
             fontsize=12, color='darkgreen', fontweight='bold')

plt.suptitle(f'Expander-Walk Majority Amplification on Cay(S₅), ρ = {rho:.4f}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_majority_amplification.png', dpi=150, bbox_inches='tight')
print("Saved viz_majority_amplification.png")
