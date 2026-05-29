#!/usr/bin/env python3
"""
Visualization: Tropical Initial Supports and Weight Stability

Shows how tropical weight vectors partition an M-convex support into
initial support faces, and how exchange structure is preserved within
equal-weight coordinate classes. This illustrates the bridge between
discrete convex analysis and tropical geometry.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import Set, Tuple


Exponent = Tuple[int, ...]


def schur_support(partition, n):
    lam = list(partition)
    support = set()
    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)
    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return support


def is_m_convex(s):
    s_set = set(s)
    for alpha in s:
        for beta in s:
            for i in range(len(alpha)):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(len(alpha)):
                        if alpha[j] < beta[j]:
                            ex = list(alpha)
                            ex[i] -= 1
                            ex[j] += 1
                            if tuple(ex) in s_set:
                                found = True
                                break
                    if not found:
                        return False
    return True


def tropical_dot(w, m):
    return sum(wi * mi for wi, mi in zip(w, m))


def initial_support(w, s):
    min_val = min(tropical_dot(w, m) for m in s)
    return {m for m in s if tropical_dot(w, m) == min_val}


# ─── Generate data ──────────────────────────────────────────────────

s = schur_support((2, 1), 4)
nodes = sorted(s)

# Sample weight vectors on a grid
theta_vals = np.linspace(0, 2 * np.pi, 60, endpoint=False)
face_map = {}  # frozenset -> list of angles

for theta in theta_vals:
    # Weight vector in the plane w1 + w2 + w3 = 0
    w = (int(round(10 * np.cos(theta))),
         int(round(10 * np.sin(theta))),
         -int(round(10 * np.cos(theta))) - int(round(10 * np.sin(theta))))
    init = frozenset(initial_support(w, s))
    if init not in face_map:
        face_map[init] = []
    face_map[init].append(theta)

# ─── Create visualization ───────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Support in barycentric coordinates with tropical faces
ax1 = axes[0]
ax1.set_title("Schur s₍₂,₁₎(x₁,...,x₄): Support & Faces\n"
              "(projected to first 3 coordinates)", fontsize=10, fontweight='bold')

# Project 4D to 2D using first 3 coordinates (barycentric-ish)
def project(v):
    return (v[1] + 0.5 * v[2] + 0.3 * v[3],
            v[2] * np.sqrt(3)/2 + v[3] * 0.4)

pos = {v: project(v) for v in nodes}

# Color by number of faces containing each node
face_count = {v: 0 for v in nodes}
for face in face_map:
    for v in face:
        face_count[v] += 1

max_fc = max(face_count.values())
colors = [plt.cm.viridis(face_count[v] / max_fc) for v in nodes]

for i, v in enumerate(nodes):
    x, y = pos[v]
    ax1.scatter(x, y, s=120, c=[colors[i]], edgecolors='black',
               linewidth=1, zorder=5)

ax1.set_aspect('equal')
ax1.axis('off')

# Panel 2: Tropical face sizes
ax2 = axes[1]
ax2.set_title("Tropical Face Size Distribution\n"
              "(how weight vectors partition the support)", fontsize=10, fontweight='bold')

face_sizes = sorted([len(f) for f in face_map])
unique_sizes = sorted(set(face_sizes))
size_counts = {sz: face_sizes.count(sz) for sz in unique_sizes}

ax2.bar(unique_sizes, [size_counts[sz] for sz in unique_sizes],
        color='teal', alpha=0.8, edgecolor='black')
ax2.set_xlabel("Face size")
ax2.set_ylabel("Number of distinct faces")

# Panel 3: M-convexity preservation under tropicalization
ax3 = axes[2]
ax3.set_title("M-Convexity of Initial Supports\n"
              "(exchange stability under tropicalization)", fontsize=10, fontweight='bold')

# Check M-convexity of each face
mconvex_faces = 0
non_mconvex_faces = 0
face_data = []
for face, angles in face_map.items():
    if len(face) >= 2:
        mc = is_m_convex(face)
    else:
        mc = True  # singletons are trivially M-convex
    if mc:
        mconvex_faces += 1
    else:
        non_mconvex_faces += 1
    face_data.append((len(face), mc))

# Plot
sizes_mc = [sz for sz, mc in face_data if mc]
sizes_nmc = [sz for sz, mc in face_data if not mc]

ax3.hist([sizes_mc, sizes_nmc], bins=range(1, max(len(f) for f in face_map) + 2),
         label=['M-convex', 'Not M-convex'],
         color=['forestgreen', 'tomato'], alpha=0.8, edgecolor='black',
         stacked=True)
ax3.set_xlabel("Face size")
ax3.set_ylabel("Count")
ax3.legend(fontsize=9)

# Add summary text
total_faces = mconvex_faces + non_mconvex_faces
ax3.text(0.95, 0.95,
         f"Total faces: {total_faces}\n"
         f"M-convex: {mconvex_faces} ({100*mconvex_faces/total_faces:.0f}%)\n"
         f"Non-M-convex: {non_mconvex_faces}",
         transform=ax3.transAxes, ha='right', va='top',
         fontsize=9, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig("tropical_faces_and_exchange.png", dpi=150, bbox_inches='tight')
print("Saved tropical_faces_and_exchange.png")
