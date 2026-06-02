#!/usr/bin/env python3
"""
Visualization: Tropical Depth Flow Orbit Diagrams

Creates a visualization of orbit structure, depth decay, and universality
class formation for tropical depth flows.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_orbits(step, n):
    """Compute orbits and universality classes."""
    orbits = {}
    classes = {}
    for x in range(n):
        orbit = [x]
        current = x
        for _ in range(n):
            current = step[current]
            orbit.append(current)
        fp = orbit[-1]
        orbits[x] = orbit
        if fp not in classes:
            classes[fp] = []
        classes[fp].append(x)
    return orbits, classes


def plot_flow_diagram():
    """Create a comprehensive flow diagram."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Example 1: A tree-like flow
    n1 = 8
    step1 = [0, 0, 0, 1, 0, 1, 2, 3]
    depth1 = [0, 1, 2, 3, 4, 5, 6, 7]
    
    ax = axes[0, 0]
    orbits1, classes1 = compute_orbits(step1, n1)
    colors = plt.cm.Set2(np.linspace(0, 1, max(len(classes1), 2)))
    
    for idx, (fp, members) in enumerate(sorted(classes1.items())):
        for x in members:
            orbit = orbits1[x]
            depths = [depth1[o] for o in orbit[:len(set(orbit))]]
            ax.plot(range(len(depths)), depths, 'o-', color=colors[idx], 
                    alpha=0.7, markersize=8, label=f'Class {fp}' if x == members[0] else None)
            ax.annotate(str(x), (0, depths[0]), textcoords="offset points",
                       xytext=(5, 5), fontsize=9)
    
    ax.set_xlabel('Iteration step')
    ax.set_ylabel('Depth')
    ax.set_title('Flow 1: All elements converge to single fixed point')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Example 2: Multiple fixed points
    n2 = 8
    step2 = [0, 1, 0, 1, 0, 1, 2, 3]
    depth2 = [0, 0, 1, 1, 2, 2, 3, 3]
    
    ax = axes[0, 1]
    orbits2, classes2 = compute_orbits(step2, n2)
    colors2 = plt.cm.Set1(np.linspace(0, 1, max(len(classes2), 2)))
    
    for idx, (fp, members) in enumerate(sorted(classes2.items())):
        for x in members:
            orbit = orbits2[x]
            depths = [depth2[o] for o in orbit[:len(set(orbit))]]
            ax.plot(range(len(depths)), depths, 'o-', color=colors2[idx],
                    alpha=0.7, markersize=8, label=f'Class {fp}' if x == members[0] else None)
            ax.annotate(str(x), (0, depths[0]), textcoords="offset points",
                       xytext=(5, 5), fontsize=9)
    
    ax.set_xlabel('Iteration step')
    ax.set_ylabel('Depth')
    ax.set_title('Flow 2: Two universality classes')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Example 3: Tropical step convergence
    ax = axes[1, 0]
    n3 = 5
    W3 = np.array([
        [0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0],
        [0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0]
    ], dtype=float)
    
    v_init = np.array([10.0, 0.0, 0.0, 0.0, 0.0])
    vs = [v_init.copy()]
    v = v_init.copy()
    for _ in range(20):
        v_new = np.zeros(n3)
        for i in range(n3):
            max_val = max(v[j] + W3[i, j] for j in range(n3))
            v_new[i] = (v[i] + max_val) / 2
        v = v_new
        vs.append(v.copy())
    
    vs = np.array(vs)
    for i in range(n3):
        ax.plot(range(len(vs)), vs[:, i], 'o-', markersize=4, label=f'Node {i}')
    
    ax.set_xlabel('Iteration step')
    ax.set_ylabel('Value')
    ax.set_title('Tropical max-plus step: convergence on 5-cycle')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Example 4: Non-expansion verification
    ax = axes[1, 1]
    np.random.seed(42)
    n4 = 10
    W4 = np.random.rand(n4, n4) * 0.5
    v4 = np.random.randn(n4) * 5
    w4 = np.random.randn(n4) * 5
    
    diffs = []
    for _ in range(30):
        diff = np.max(np.abs(v4 - w4))
        diffs.append(diff)
        v4_new = np.zeros(n4)
        w4_new = np.zeros(n4)
        for i in range(n4):
            max_v = max(v4[j] + W4[i, j] for j in range(n4))
            max_w = max(w4[j] + W4[i, j] for j in range(n4))
            v4_new[i] = (v4[i] + max_v) / 2
            w4_new[i] = (w4[i] + max_w) / 2
        v4 = v4_new
        w4 = w4_new
    
    ax.plot(range(len(diffs)), diffs, 'b-o', markersize=4)
    ax.axhline(y=diffs[0], color='r', linestyle='--', alpha=0.5, label='Initial ||v-w||∞')
    ax.set_xlabel('Iteration step')
    ax.set_ylabel('||v - w||∞')
    ax.set_title('Non-expansion: sup-norm distance never increases')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('tropical_flow_diagrams.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_flow_diagrams.png")


if __name__ == '__main__':
    plot_flow_diagram()
