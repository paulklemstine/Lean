#!/usr/bin/env python3
"""
Demo: Cellular Automata as Algebraic Geometry over GF(2)

Demonstrates the key results:
1. ANF computation for all 256 rules
2. Fixed-point variety dimension computation
3. Correlation between algebraic degree and Wolfram complexity class
4. Subspace structure verification for additive rules
"""

from itertools import product
from collections import Counter
import math


# ─── GF(2) Arithmetic ───

def gf2_add(a, b):
    return (a + b) % 2

def gf2_mul(a, b):
    return a & b


# ─── ECA Rule Functions ───

def rule_truth_table(r):
    return {(a, b, c): (r >> (4*a + 2*b + c)) & 1
            for a, b, c in product([0, 1], repeat=3)}

def eca_update(state, rule_num):
    n = len(state)
    table = rule_truth_table(rule_num)
    return [table[(state[(i-1) % n], state[i], state[(i+1) % n])]
            for i in range(n)]


# ─── ANF Computation ───

def compute_anf(r):
    g = rule_truth_table(r)
    c0 = g[(0,0,0)]
    c1 = gf2_add(g[(1,0,0)], g[(0,0,0)])
    c2 = gf2_add(g[(0,1,0)], g[(0,0,0)])
    c3 = gf2_add(g[(0,0,1)], g[(0,0,0)])
    c4 = gf2_add(gf2_add(gf2_add(g[(1,1,0)], g[(1,0,0)]), g[(0,1,0)]), g[(0,0,0)])
    c5 = gf2_add(gf2_add(gf2_add(g[(1,0,1)], g[(1,0,0)]), g[(0,0,1)]), g[(0,0,0)])
    c6 = gf2_add(gf2_add(gf2_add(g[(0,1,1)], g[(0,1,0)]), g[(0,0,1)]), g[(0,0,0)])
    c7 = gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(
        g[(1,1,1)], g[(1,1,0)]), g[(1,0,1)]), g[(0,1,1)]),
        g[(1,0,0)]), g[(0,1,0)]), g[(0,0,1)]), g[(0,0,0)])
    return [c0, c1, c2, c3, c4, c5, c6, c7]

def anf_degree(coeffs):
    if coeffs[7]: return 3
    if any(coeffs[i] for i in [4,5,6]): return 2
    if any(coeffs[i] for i in [1,2,3]): return 1
    return 0

def anf_str(coeffs):
    labels = ["1", "a", "b", "c", "ab", "ac", "bc", "abc"]
    terms = [l for c, l in zip(coeffs, labels) if c]
    return " + ".join(terms) if terms else "0"


# ─── Fixed Point Analysis ───

def find_fixed_points(rule_num, n):
    fixed = []
    for state in product([0, 1], repeat=n):
        s = list(state)
        if eca_update(s, rule_num) == s:
            fixed.append(state)
    return fixed


def log2_if_power(x):
    if x == 0: return None
    l = math.log2(x)
    return int(l) if l == int(l) else None


# ─── Wolfram Classes (partial) ───

WOLFRAM_CLASS = {}
for r in [0, 8, 32, 40, 64, 96, 128, 136, 160, 168, 192, 224, 234, 235, 238, 239, 248, 249, 252, 253, 254, 255]:
    WOLFRAM_CLASS[r] = 1
for r in [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 19, 23, 24, 25, 26, 27, 28, 29, 33, 34, 35, 36, 37, 38, 42, 43, 44, 46, 50, 51, 56, 57, 58, 62, 72, 73, 74, 76, 77, 78, 94, 104, 108, 130, 132, 134, 138, 140, 142, 152, 154, 156, 162, 164, 170, 172, 174, 178, 184, 200, 204, 232]:
    WOLFRAM_CLASS[r] = 2
for r in [18, 22, 30, 45, 60, 90, 105, 122, 126, 146, 150, 161]:
    WOLFRAM_CLASS[r] = 3
for r in [41, 54, 106, 110]:
    WOLFRAM_CLASS[r] = 4


# ─── DEMO ───

def main():
    print("=" * 72)
    print("CELLULAR AUTOMATA AS ALGEBRAIC GEOMETRY OVER GF(2)")
    print("=" * 72)

    # Demo 1: ANF of notable rules
    print("\n─── Demo 1: Algebraic Normal Form ───")
    print(f"{'Rule':>6} {'ANF Polynomial':>25} {'Degree':>8} {'Additive':>10}")
    print("-" * 55)
    notable = [0, 30, 60, 90, 110, 150, 204, 255]
    for r in notable:
        c = compute_anf(r)
        print(f"{r:>6} {anf_str(c):>25} {anf_degree(c):>8} {'Yes' if anf_degree(c) <= 1 else 'No':>10}")

    # Demo 2: Degree distribution
    print("\n─── Demo 2: ANF Degree Distribution ───")
    degrees = [anf_degree(compute_anf(r)) for r in range(256)]
    for d in range(4):
        count = degrees.count(d)
        print(f"  Degree {d}: {count:3d} rules ({100*count/256:.1f}%)")

    # Demo 3: Fixed points for small n
    print("\n─── Demo 3: Fixed Point Counts (n=8) ───")
    print(f"{'Rule':>6} {'Class':>6} {'#FP':>6} {'log₂(#FP)':>10} {'Degree':>8}")
    print("-" * 42)
    for r in [0, 30, 51, 90, 110, 150, 204, 255]:
        fps = find_fixed_points(r, 8)
        nfp = len(fps)
        l = log2_if_power(nfp)
        cls = WOLFRAM_CLASS.get(r, "?")
        deg = anf_degree(compute_anf(r))
        l_str = str(l) if l is not None else f"~{math.log2(nfp):.2f}" if nfp > 0 else "∅"
        print(f"{r:>6} {cls:>6} {nfp:>6} {l_str:>10} {deg:>8}")

    # Demo 4: Verify subspace structure for additive rules
    print("\n─── Demo 4: Subspace Structure Verification ───")
    print("For additive rules, fixed points should form a vector subspace.")
    for r in [90, 150]:
        for n in [4, 5, 6, 7, 8]:
            fps = find_fixed_points(r, n)
            nfp = len(fps)
            is_power_2 = (nfp & (nfp - 1) == 0) if nfp > 0 else True
            # Verify closure under XOR
            closed = True
            for s1 in fps:
                for s2 in fps:
                    xor = tuple(gf2_add(a, b) for a, b in zip(s1, s2))
                    if xor not in fps:
                        closed = False
                        break
                if not closed:
                    break
            dim = log2_if_power(nfp) if nfp > 0 else 0
            status = "✓" if (is_power_2 and closed) else "✗"
            print(f"  Rule {r}, n={n}: |V| = {nfp:4d}, dim = {dim}, "
                  f"subspace = {status}")

    # Demo 5: Degree vs Wolfram class correlation
    print("\n─── Demo 5: Degree-Complexity Correlation ───")
    print("Average ANF degree by Wolfram complexity class:")
    class_degrees = {1: [], 2: [], 3: [], 4: []}
    for r in range(256):
        if r in WOLFRAM_CLASS:
            class_degrees[WOLFRAM_CLASS[r]].append(anf_degree(compute_anf(r)))
    for cls in [1, 2, 3, 4]:
        degs = class_degrees[cls]
        if degs:
            avg = sum(degs) / len(degs)
            print(f"  Class {cls}: avg degree = {avg:.2f} "
                  f"(n={len(degs)}, deg distribution: {dict(Counter(degs))})")

    # Demo 6: Fixed-point dimension vs Wolfram class
    print("\n─── Demo 6: Fixed-Point Dimension vs Wolfram Class (n=10) ───")
    n = 10
    class_dims = {1: [], 2: [], 3: [], 4: []}
    for r in [0, 90, 110, 150, 204, 255, 30, 51, 60, 105, 54, 41]:
        if r in WOLFRAM_CLASS:
            fps = find_fixed_points(r, n)
            nfp = len(fps)
            dim = log2_if_power(nfp)
            cls = WOLFRAM_CLASS[r]
            if dim is not None:
                class_dims[cls].append(dim)
            print(f"  Rule {r:3d} (Class {cls}): "
                  f"|V| = {nfp:5d}, dim = {dim if dim is not None else '?'}")

    print("\n" + "=" * 72)
    print("KEY FINDINGS:")
    print("  1. Every ECA rule has a unique ANF polynomial over GF(2)")
    print("  2. Additive rules (degree ≤ 1) have subspace fixed-point varieties")
    print("  3. Rule 110 (Turing-complete) has maximal ANF degree 3")
    print("  4. Non-additive rules can have non-subspace fixed-point sets")
    print("=" * 72)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: ANF Degree Distribution and Fixed-Point Counts for all 256 ECA Rules.
Standalone script using matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def gf2_add(a, b):
    return (a + b) % 2


def rule_truth_table(r):
    return {(a, b, c): (r >> (4*a + 2*b + c)) & 1
            for a, b, c in product([0, 1], repeat=3)}


def compute_anf(r):
    g = rule_truth_table(r)
    c0 = g[(0,0,0)]
    c1 = gf2_add(g[(1,0,0)], g[(0,0,0)])
    c2 = gf2_add(g[(0,1,0)], g[(0,0,0)])
    c3 = gf2_add(g[(0,0,1)], g[(0,0,0)])
    c4 = gf2_add(gf2_add(gf2_add(g[(1,1,0)], g[(1,0,0)]), g[(0,1,0)]), g[(0,0,0)])
    c5 = gf2_add(gf2_add(gf2_add(g[(1,0,1)], g[(1,0,0)]), g[(0,0,1)]), g[(0,0,0)])
    c6 = gf2_add(gf2_add(gf2_add(g[(0,1,1)], g[(0,1,0)]), g[(0,0,1)]), g[(0,0,0)])
    c7 = gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(
        g[(1,1,1)], g[(1,1,0)]), g[(1,0,1)]), g[(0,1,1)]),
        g[(1,0,0)]), g[(0,1,0)]), g[(0,0,1)]), g[(0,0,0)])
    return [c0, c1, c2, c3, c4, c5, c6, c7]


def anf_degree(coeffs):
    if coeffs[7]: return 3
    if any(coeffs[i] for i in [4,5,6]): return 2
    if any(coeffs[i] for i in [1,2,3]): return 1
    return 0


def eca_update(state, rule_num):
    n = len(state)
    table = rule_truth_table(rule_num)
    return [table[(state[(i-1)%n], state[i], state[(i+1)%n])] for i in range(n)]


def count_fixed_points(rule_num, n):
    count = 0
    for state in product([0, 1], repeat=n):
        s = list(state)
        if eca_update(s, rule_num) == s:
            count += 1
    return count


def main():
    # Compute ANF degrees
    degrees = [anf_degree(compute_anf(r)) for r in range(256)]
    
    # Compute fixed-point counts for n=8
    fp_counts = [count_fixed_points(r, 8) for r in range(256)]
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Cellular Automata as Algebraic Geometry over GF(2)', fontsize=16, fontweight='bold')
    
    # Plot 1: ANF degree distribution
    ax = axes[0, 0]
    counts = [degrees.count(d) for d in range(4)]
    colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']
    bars = ax.bar(range(4), counts, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('ANF Degree')
    ax.set_ylabel('Number of Rules')
    ax.set_title('ANF Degree Distribution (256 Rules)')
    for bar, count in zip(bars, counts):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
                f'{count}\n({100*count/256:.1f}%)', ha='center', va='bottom', fontsize=9)
    ax.set_xticks(range(4))
    
    # Plot 2: Fixed-point count vs rule number
    ax = axes[0, 1]
    color_map = [colors[d] for d in degrees]
    ax.scatter(range(256), fp_counts, c=color_map, s=8, alpha=0.7)
    ax.set_xlabel('Rule Number')
    ax.set_ylabel('Fixed Points (n=8)')
    ax.set_title('Fixed-Point Count by Rule')
    ax.set_yscale('symlog', linthresh=1)
    
    # Plot 3: Fixed-point count vs ANF degree
    ax = axes[1, 0]
    for d in range(4):
        fps = [fp_counts[r] for r in range(256) if degrees[r] == d]
        if fps:
            positions = np.random.normal(d, 0.12, len(fps))
            ax.scatter(positions, fps, c=colors[d], s=15, alpha=0.5, label=f'Degree {d}')
    ax.set_xlabel('ANF Degree')
    ax.set_ylabel('Fixed Points (n=8)')
    ax.set_title('Fixed Points vs ANF Degree')
    ax.set_yscale('symlog', linthresh=1)
    ax.legend()
    
    # Plot 4: Rule 90 fixed-point dimension vs cycle length
    ax = axes[1, 1]
    ns = list(range(3, 25))
    dims_90 = []
    dims_150 = []
    for n in ns:
        fp90 = count_fixed_points(90, n)
        fp150 = count_fixed_points(150, n)
        import math
        dims_90.append(int(math.log2(fp90)) if fp90 > 0 else -1)
        dims_150.append(int(math.log2(fp150)) if fp150 > 0 else -1)
    ax.plot(ns, dims_90, 'o-', color='#e74c3c', label='Rule 90', markersize=5)
    ax.plot(ns, dims_150, 's-', color='#3498db', label='Rule 150', markersize=5)
    ax.set_xlabel('Cycle Length n')
    ax.set_ylabel('Fixed-Point Variety Dimension')
    ax.set_title('Fixed-Point Dimension vs Cycle Length')
    ax.legend()
    ax.set_ylim(-0.5, max(max(dims_90), max(dims_150)) + 1)
    
    plt.tight_layout()
    plt.savefig('eca_algebraic_geometry.png', dpi=150, bbox_inches='tight')
    print("Saved: eca_algebraic_geometry.png")


if __name__ == "__main__":
    main()
