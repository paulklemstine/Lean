#!/usr/bin/env python3
"""
Visualization: Derived Series Spectroscopy

Shows the "spectral fingerprints" of various groups — how their derived series
decays, analogous to emission spectra of chemical elements.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def cyclic_group(n):
    return [[(i + j) % n for j in range(n)] for i in range(n)]

def dihedral_group(n):
    order = 2 * n
    table = [[0]*order for _ in range(order)]
    for a in range(order):
        for b in range(order):
            ai, bi = a % n, b % n
            if a < n and b < n: table[a][b] = (ai + bi) % n
            elif a < n: table[a][b] = n + (ai + bi) % n
            elif b < n: table[a][b] = n + (ai - bi) % n
            else: table[a][b] = (ai - bi) % n
    return table

def direct_product(t1, t2):
    n1, n2 = len(t1), len(t2)
    order = n1 * n2
    table = [[0]*order for _ in range(order)]
    for a in range(order):
        for b in range(order):
            table[a][b] = t1[a//n2][b//n2] * n2 + t2[a%n2][b%n2]
    return table

def compute_inverses(table):
    n = len(table)
    inv = [0]*n
    for i in range(n):
        for j in range(n):
            if table[i][j] == 0:
                inv[i] = j; break
    return inv

def generate_subgroup(table, generators):
    subgroup = set(generators) | {0}
    changed = True
    while changed:
        changed = False
        new = set()
        for a in subgroup:
            for b in subgroup:
                p = table[a][b]
                if p not in subgroup:
                    new.add(p); changed = True
        subgroup |= new
    return sorted(subgroup)

def derived_series_sizes(table, max_depth=15):
    n = len(table)
    current = list(range(n))
    sizes = [n]
    inv = compute_inverses(table)

    for _ in range(max_depth):
        comms = set()
        for a in current:
            for b in current:
                ab = table[a][b]
                ainv_binv = table[inv[a]][inv[b]]
                comms.add(table[ab][ainv_binv])
        next_sub = generate_subgroup(table, comms)
        if len(next_sub) == len(current): break
        current = next_sub
        sizes.append(len(current))
        if len(current) == 1: break

    return sizes


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Groups to analyze
    groups = [
        ("Noble Gases (Cyclic)", [
            ("Z/6Z", cyclic_group(6)),
            ("Z/12Z", cyclic_group(12)),
            ("Z/15Z", cyclic_group(15)),
        ], axes[0, 0]),
        ("Alkaline Earths (Abelian non-cyclic)", [
            ("V₄ = Z₂×Z₂", direct_product(cyclic_group(2), cyclic_group(2))),
            ("Z₂×Z₄", direct_product(cyclic_group(2), cyclic_group(4))),
            ("Z₃×Z₃", direct_product(cyclic_group(3), cyclic_group(3))),
        ], axes[0, 1]),
        ("Alkali Metals (Nilpotent non-abelian)", [
            ("D₄", dihedral_group(4)),
            ("D₄×Z₂", direct_product(dihedral_group(4), cyclic_group(2))),
        ], axes[1, 0]),
        ("Compounds (Solvable non-nilpotent)", [
            ("D₃ ≅ S₃", dihedral_group(3)),
            ("D₅", dihedral_group(5)),
            ("D₇", dihedral_group(7)),
        ], axes[1, 1]),
    ]

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

    for title, group_list, ax in groups:
        for idx, (name, table) in enumerate(group_list):
            sizes = derived_series_sizes(table)
            steps = list(range(len(sizes)))
            color = colors[idx % len(colors)]

            # Plot as spectral lines
            ax.plot(steps, sizes, 'o-', color=color, label=name,
                    linewidth=2, markersize=8)

            # Add spectral "glow"
            for i, s in enumerate(sizes):
                ax.barh(s, 0.3, left=i-0.15, height=max(sizes)*0.02,
                        color=color, alpha=0.3)

        ax.set_xlabel("Derived Series Step", fontsize=10)
        ax.set_ylabel("Subgroup Order", fontsize=10)
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.legend(fontsize=8)
        ax.set_yscale('log')
        ax.grid(True, alpha=0.3)

    fig.suptitle("Derived Series Spectroscopy: Group Fingerprints",
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("derived_spectra.png", dpi=150, bbox_inches='tight')
    print("Saved: derived_spectra.png")


if __name__ == "__main__":
    main()
