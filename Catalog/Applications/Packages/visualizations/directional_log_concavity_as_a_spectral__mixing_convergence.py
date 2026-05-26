"""
Visualization: Mixing Time Convergence under DLC

Shows how the Dobrushin constant c and theoretical mixing time change
as repulsion strength (β) increases. Demonstrates the core prediction:
stronger DLC → smaller Dobrushin constant → faster mixing.

Also shows empirical convergence of Glauber dynamics marginals to confirm
the theoretical mixing time bounds.
"""

import numpy as np
import matplotlib.pyplot as plt


def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        if i in S and j in S: w11 += ws
        elif i in S: w10 += ws
        elif j in S: w01 += ws
        else: w00 += ws
    return w11, w10, w01, w00


def compute_dobrushin(w, n):
    if n <= 1:
        return 0.0
    c = 0.0
    for i in range(n):
        total = 0.0
        for j in range(n):
            if j == i:
                continue
            w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
            d1, d0 = w11 + w01, w10 + w00
            p1 = w11 / d1 if d1 > 0 else 0
            p0 = w10 / d0 if d0 > 0 else 0
            total += abs(p1 - p0)
        c = max(c, total)
    return c


def repulsive_weights(n, beta):
    def adj(S):
        return sum(1 for x in S if x + 1 in S)
    return {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}


def glauber_step(w, n, x, rng):
    x = x.copy()
    site = rng.integers(0, n)
    w_on = w_off = 0.0
    for S in subsets_of(n):
        if all(((j in S) == bool(x[j])) for j in range(n) if j != site):
            ws = w.get(S, 0.0)
            if site in S:
                w_on += ws
            else:
                w_off += ws
    total = w_on + w_off
    if total > 0:
        x[site] = 1 if rng.random() < w_on / total else 0
    return x


# --- Panel 1: Dobrushin constant vs β ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

n = 5
betas = np.linspace(0.1, 8.0, 40)
dob_constants = []
for beta in betas:
    w = repulsive_weights(n, beta)
    dob_constants.append(compute_dobrushin(w, n))

ax = axes[0]
ax.plot(betas, dob_constants, 'b-', linewidth=2)
ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='c = 1 (mixing threshold)')
ax.set_xlabel('Repulsion strength β', fontsize=11)
ax.set_ylabel('Dobrushin constant c', fontsize=11)
ax.set_title('Dobrushin Constant vs Repulsion', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(bottom=0)
ax.grid(True, alpha=0.3)

# --- Panel 2: Mixing time vs β ---
ax = axes[1]
mix_times = [(n / (1 - c)) * np.log(n / 0.01) if c < 1 else np.nan for c in dob_constants]
ax.plot(betas, mix_times, 'g-', linewidth=2)
ax.set_xlabel('Repulsion strength β', fontsize=11)
ax.set_ylabel('Mixing time bound T_mix', fontsize=11)
ax.set_title('Certified Mixing Time vs Repulsion', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.3)

# --- Panel 3: Empirical convergence ---
ax = axes[2]
n = 4
rng = np.random.default_rng(42)

for beta, color in [(0.5, 'blue'), (2.0, 'green'), (5.0, 'red')]:
    w = repulsive_weights(n, beta)
    Z = sum(w.values())
    exact_p0 = sum(ws for S, ws in w.items() if 0 in S) / Z

    steps = list(range(0, 201, 5))
    errors = []
    for T in steps:
        empirical_sum = 0
        n_samples = 100
        for _ in range(n_samples):
            x = np.zeros(n, dtype=int)
            for _ in range(T):
                x = glauber_step(w, n, x, rng)
            empirical_sum += x[0]
        emp_p0 = empirical_sum / n_samples
        errors.append(abs(emp_p0 - exact_p0))

    ax.plot(steps, errors, color=color, linewidth=1.5, alpha=0.8, label=f'β={beta}')

ax.set_xlabel('Glauber steps', fontsize=11)
ax.set_ylabel('|Pr[X₀=1] - exact|', fontsize=11)
ax.set_title('Empirical Convergence (n=4)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

fig.suptitle('DLC Controls Mixing: Theory and Empirics',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mixing_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing_convergence.png")
