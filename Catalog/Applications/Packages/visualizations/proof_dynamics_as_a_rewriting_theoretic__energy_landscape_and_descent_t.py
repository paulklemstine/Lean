#!/usr/bin/env python3
"""
Visualization: Energy Landscape and Descent Trajectories

Visualizes the core mathematical concepts of proof dynamics:
- Energy descent trajectories during normalization
- Basin of attraction structure
- Redundancy distribution across proof sketches

Uses matplotlib for static plots. Self-contained (no local imports).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional, List, Tuple, Dict
from collections import defaultdict


# ============================================================
# Inline proof sketch implementation (self-contained)
# ============================================================

class NodeType(Enum):
    AXIOM = auto()
    LEMMA = auto()
    TRANS = auto()
    CASES = auto()
    REDUNDANT = auto()
    DUPLICATE = auto()


@dataclass(frozen=True)
class PS:
    t: NodeType
    label: Optional[str] = None
    left: Optional['PS'] = None
    right: Optional['PS'] = None

    @staticmethod
    def ax(l): return PS(NodeType.AXIOM, label=l)
    @staticmethod
    def lem(l, c): return PS(NodeType.LEMMA, label=l, left=c)
    @staticmethod
    def red(c): return PS(NodeType.REDUNDANT, left=c)
    @staticmethod
    def dup(c): return PS(NodeType.DUPLICATE, left=c)
    @staticmethod
    def tr(a, b): return PS(NodeType.TRANS, left=a, right=b)

    def __repr__(self):
        if self.t == NodeType.AXIOM: return f"ax({self.label})"
        if self.t == NodeType.LEMMA: return f"lem({self.label},{self.left})"
        if self.t == NodeType.REDUNDANT: return f"red({self.left})"
        if self.t == NodeType.DUPLICATE: return f"dup({self.left})"
        if self.t == NodeType.TRANS: return f"tr({self.left},{self.right})"
        return "?"


def sz(p):
    if p.t == NodeType.AXIOM: return 1
    if p.t in (NodeType.LEMMA, NodeType.REDUNDANT, NodeType.DUPLICATE): return 1 + sz(p.left)
    if p.t in (NodeType.TRANS, NodeType.CASES): return 1 + sz(p.left) + sz(p.right)
    return 0

def dp(p):
    if p.t == NodeType.AXIOM: return 0
    if p.t in (NodeType.LEMMA, NodeType.REDUNDANT, NodeType.DUPLICATE): return 1 + dp(p.left)
    if p.t in (NodeType.TRANS, NodeType.CASES): return 1 + max(dp(p.left), dp(p.right))
    return 0

def lc(p):
    if p.t == NodeType.AXIOM: return 0
    if p.t == NodeType.LEMMA: return 1 + lc(p.left)
    if p.t in (NodeType.REDUNDANT, NodeType.DUPLICATE): return lc(p.left)
    if p.t in (NodeType.TRANS, NodeType.CASES): return lc(p.left) + lc(p.right)
    return 0

def E(p): return sz(p) + dp(p) + lc(p)

def sm(p):
    if p.t == NodeType.AXIOM: return p.label
    if p.t == NodeType.LEMMA: return p.label
    return sm(p.left)

def reducts(p):
    results = []
    if p.t == NodeType.REDUNDANT: results.append(p.left)
    elif p.t == NodeType.DUPLICATE: results.append(p.left)
    elif p.t == NodeType.LEMMA:
        if p.left.t == NodeType.REDUNDANT: results.append(PS.lem(p.label, p.left.left))
        if p.left.t == NodeType.AXIOM: results.append(PS.ax(p.label))
    if p.t == NodeType.LEMMA:
        for r in reducts(p.left): results.append(PS.lem(p.label, r))
    elif p.t == NodeType.TRANS:
        for r in reducts(p.left): results.append(PS.tr(r, p.right))
        for r in reducts(p.right): results.append(PS.tr(p.left, r))
    elif p.t == NodeType.REDUNDANT:
        for r in reducts(p.left): results.append(PS.red(r))
    elif p.t == NodeType.DUPLICATE:
        for r in reducts(p.left): results.append(PS.dup(r))
    seen = set()
    unique = []
    for r in results:
        k = repr(r)
        if k not in seen: seen.add(k); unique.append(r)
    return unique

def normalize(p):
    traj = [(p, E(p))]
    cur = p
    for _ in range(200):
        rs = reducts(cur)
        if not rs: break
        cur = min(rs, key=E)
        traj.append((cur, E(cur)))
    return cur, traj

def enum_sketches(labels, max_e):
    results = []
    atoms = [PS.ax(l) for l in labels]
    results.extend(a for a in atoms if E(a) <= max_e)
    prev = list(results)
    seen = {repr(p) for p in results}
    for _ in range(max_e):
        new = []
        for p in prev:
            for c in [PS.red, PS.dup]:
                q = c(p)
                k = repr(q)
                if E(q) <= max_e and k not in seen: seen.add(k); new.append(q); results.append(q)
            for l in labels:
                q = PS.lem(l, p)
                k = repr(q)
                if E(q) <= max_e and k not in seen: seen.add(k); new.append(q); results.append(q)
        if not new: break
        prev = new
    return results


# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Proof Dynamics: Energy Landscape and Descent Trajectories",
             fontsize=14, fontweight='bold')

# --- Plot 1: Energy Descent Trajectories ---
ax1 = axes[0, 0]
examples = [
    ("red(ax(P))", PS.red(PS.ax("P"))),
    ("dup(red(ax(P)))", PS.dup(PS.red(PS.ax("P")))),
    ("red(dup(red(ax(P))))", PS.red(PS.dup(PS.red(PS.ax("P"))))),
    ("lem(A,red(ax(B)))", PS.lem("A", PS.red(PS.ax("B")))),
    ("red(dup(red(dup(ax(P)))))", PS.red(PS.dup(PS.red(PS.dup(PS.ax("P")))))),
]

colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(examples)))
for (name, sketch), color in zip(examples, colors):
    _, traj = normalize(sketch)
    energies = [e for _, e in traj]
    steps = list(range(len(energies)))
    ax1.plot(steps, energies, 'o-', color=color, label=name, markersize=5, linewidth=2)

ax1.set_xlabel("Normalization Step", fontsize=11)
ax1.set_ylabel("Energy (Lyapunov Function)", fontsize=11)
ax1.set_title("Energy Descent Trajectories", fontsize=12)
ax1.legend(fontsize=7, loc='upper right')
ax1.grid(True, alpha=0.3)

# --- Plot 2: Redundancy Distribution ---
ax2 = axes[0, 1]
labels_list = ["A", "B"]
sketches = enum_sketches(labels_list, 8)
redundancies = []
for p in sketches:
    nf, _ = normalize(p)
    redundancies.append(E(p) - E(nf))

bins = range(max(redundancies) + 2)
ax2.hist(redundancies, bins=bins, color='steelblue', edgecolor='white', alpha=0.8)
ax2.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Normal forms (RI=0)')
ax2.set_xlabel("Redundancy Index", fontsize=11)
ax2.set_ylabel("Count", fontsize=11)
ax2.set_title("Redundancy Distribution", fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Plot 3: Basin Sizes vs Energy Bound ---
ax3 = axes[1, 0]
n_values = []
max_basins = []
total_counts = []

for n in range(1, 10):
    sk = enum_sketches(labels_list, n)
    basins = defaultdict(list)
    for p in sk:
        nf, _ = normalize(p)
        basins[repr(nf)].append(p)
    max_b = max(len(v) for v in basins.values()) if basins else 0
    n_values.append(n)
    max_basins.append(max_b)
    total_counts.append(len(sk))

ax3.plot(n_values, max_basins, 's-', color='darkgreen', linewidth=2, markersize=6, label='Max basin size')
ax3.plot(n_values, total_counts, 'o-', color='coral', linewidth=2, markersize=6, label='Total sketches')
ax3.set_xlabel("Energy Bound", fontsize=11)
ax3.set_ylabel("Count", fontsize=11)
ax3.set_title("Basin Growth vs Energy Bound", fontsize=12)
ax3.legend(fontsize=9)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

# --- Plot 4: Steps vs Energy (Complexity Bound) ---
ax4 = axes[1, 1]
steps_data = []
energy_data = []
for p in sketches:
    rs = reducts(p)
    if not rs: continue
    _, traj = normalize(p)
    steps_data.append(len(traj) - 1)
    energy_data.append(E(p))

ax4.scatter(energy_data, steps_data, alpha=0.4, s=15, color='purple')
max_e = max(energy_data) if energy_data else 10
ax4.plot([0, max_e], [0, max_e], 'r--', linewidth=2, label='y = x (upper bound)')
ax4.set_xlabel("Initial Energy", fontsize=11)
ax4.set_ylabel("Normalization Steps", fontsize=11)
ax4.set_title("Steps vs Energy Bound (Theorem 3)", fontsize=12)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("energy_landscape.png", dpi=150, bbox_inches='tight')
print("Saved energy_landscape.png")
