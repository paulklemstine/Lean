#!/usr/bin/env python3
"""
Visualization 1: Pressure Landscape across Scales and Temperatures

Visualizes how the ensemble pressure Π(β) varies as a function of
inverse temperature β for symmetric groups S_2, S_3, S_4. Shows the
intensive pressure Π/n to reveal scale-invariant structure and the
emergence of a thermodynamic limit.
"""

import math
import itertools
import numpy as np
import matplotlib.pyplot as plt


# ── Self-contained group utilities ──

def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity_perm(n):
    return tuple(range(n))

def generate_subgroup(generators, n):
    ident = identity_perm(n)
    subgroup = {ident}
    frontier = set(generators)
    while frontier:
        new = set()
        subgroup |= frontier
        for g in frontier:
            for h in subgroup:
                for p in [compose_perm(g, h), compose_perm(h, g), inverse_perm(g)]:
                    if p not in subgroup:
                        new.add(p)
        frontier = new
    return frozenset(subgroup)

def all_subgroups_sn(n):
    perms = list(itertools.permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity_perm(n)]))
    for g in perms:
        sg = generate_subgroup([g], n)
        subgroups.add(sg)
        for h in perms:
            sg2 = generate_subgroup([g, h], n)
            subgroups.add(sg2)
    return [set(s) for s in subgroups]

def pressure_sn(n, beta):
    subs = all_subgroups_sn(n)
    G_order = math.factorial(n)
    Z = sum(math.exp(-beta * math.log(max(1, G_order / len(H)))) for H in subs)
    return math.log(Z) if Z > 0 else 0


# ── Compute pressure data ──

betas = np.linspace(0.01, 5.0, 100)
groups = [2, 3, 4]
colors = ['#2196F3', '#FF5722', '#4CAF50']
labels = [f'$S_{n}$' for n in groups]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Raw pressure
ax1 = axes[0]
for n, color, label in zip(groups, colors, labels):
    pressures = [pressure_sn(n, b) for b in betas]
    ax1.plot(betas, pressures, color=color, linewidth=2, label=label)
ax1.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax1.set_ylabel(r'Pressure $\Pi(\beta)$', fontsize=12)
ax1.set_title('Subgroup Pressure', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Panel 2: Intensive pressure
ax2 = axes[1]
for n, color, label in zip(groups, colors, labels):
    pressures = [pressure_sn(n, b) / n for b in betas]
    ax2.plot(betas, pressures, color=color, linewidth=2, label=label)
ax2.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax2.set_ylabel(r'Intensive pressure $\Pi(\beta)/n$', fontsize=12)
ax2.set_title('Intensive Pressure (Thermodynamic Limit)', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Panel 3: Susceptibility
ax3 = axes[2]
h = 0.02
for n, color, label in zip(groups, colors, labels):
    suscept = []
    for b in betas:
        P = pressure_sn(n, b)
        chi = (pressure_sn(n, b + h) - 2 * P + pressure_sn(n, b - h)) / h**2
        suscept.append(chi)
    ax3.plot(betas, suscept, color=color, linewidth=2, label=label)
ax3.set_xlabel(r'Inverse temperature $\beta$', fontsize=12)
ax3.set_ylabel(r'Susceptibility $\chi(\beta)$', fontsize=12)
ax3.set_title('Susceptibility (Phase Transition Signature)', fontsize=14)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.suptitle('Renormalization Group for Subgroup Ensembles: Pressure Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_pressure_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_pressure_landscape.png")
