#!/usr/bin/env python3
"""
Tropical Renormalization Flow: Demonstrations

Demonstrates the key concepts from the tropical renormalization framework:
1. Computing universality classes for concrete flows
2. Verifying the Merging Principle on examples
3. Testing the Logarithmic Class Conjecture
4. Tropical max-plus step dynamics
"""

import numpy as np
from typing import Callable


def iterate_flow(step: Callable[[int], int], x: int, n: int) -> int:
    """Iterate flow step n times starting from x."""
    for _ in range(n):
        x = step(x)
    return x


def compute_universality_classes(step: Callable[[int], int], size: int) -> dict[int, list[int]]:
    """Compute universality classes by iterating to fixed points."""
    fixed = {}
    for x in range(size):
        fp = iterate_flow(step, x, size)
        if fp not in fixed:
            fixed[fp] = []
        fixed[fp].append(x)
    return fixed


def verify_merging_principle(
    step_f: Callable[[int], int], size_f: int,
    step_g: Callable[[int], int], size_g: int,
    phi: Callable[[int], int]
) -> bool:
    """Verify the Merging Principle: if x ~_F y then phi(x) ~_G phi(y)."""
    classes_f = compute_universality_classes(step_f, size_f)
    classes_g = compute_universality_classes(step_g, size_g)
    
    for fp, members in classes_f.items():
        # All members of the same F-class should map to the same G-class
        mapped_fps = set()
        for x in members:
            g_fp = iterate_flow(step_g, phi(x), size_g)
            mapped_fps.add(g_fp)
        if len(mapped_fps) > 1:
            return False
    return True


def tropical_step(W: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Max-plus averaging step: v_i <- (v_i + max_j(v_j + W_ij)) / 2."""
    n = len(v)
    result = np.zeros(n)
    for i in range(n):
        max_val = max(v[j] + W[i, j] for j in range(n))
        result[i] = (v[i] + max_val) / 2
    return result


def test_nonexpansion(W: np.ndarray, v: np.ndarray, w: np.ndarray) -> tuple[float, float]:
    """Test that ||T(v) - T(w)||_inf <= ||v - w||_inf."""
    tv = tropical_step(W, v)
    tw = tropical_step(W, w)
    before = np.max(np.abs(v - w))
    after = np.max(np.abs(tv - tw))
    return before, after


def count_strict_contraction_classes(n: int) -> int:
    """
    For a given n, find the maximum number of universality classes
    achievable by a strictly contracting flow on {0, ..., n-1}.
    
    Uses exhaustive search for small n.
    """
    from itertools import product
    
    max_classes = 0
    
    # Try all possible step functions and depth functions
    # For efficiency, we fix depth[i] = i (identity depth) and vary step
    depth = list(range(n))
    
    # Generate all step functions that are strictly contracting
    # step(i) must have depth(step(i)) < depth(i) unless step(i) == i
    def is_valid_step(step_list):
        for i in range(n):
            si = step_list[i]
            if si != i and depth[si] >= depth[i]:
                return False
        return True
    
    # For each element i, valid targets are: i itself, or any j with depth[j] < depth[i]
    valid_targets = []
    for i in range(n):
        targets = [i]  # can be fixed
        for j in range(n):
            if j != i and depth[j] < depth[i]:
                targets.append(j)
        valid_targets.append(targets)
    
    def enumerate_steps(idx, current):
        nonlocal max_classes
        if idx == n:
            step_fn = lambda x, c=current[:]: c[x]
            classes = compute_universality_classes(step_fn, n)
            num = len(classes)
            max_classes = max(max_classes, num)
            return
        for t in valid_targets[idx]:
            current.append(t)
            enumerate_steps(idx + 1, current)
            current.pop()
    
    enumerate_steps(0, [])
    return max_classes


# ============================================================
# Demo 1: Basic flow and universality classes
# ============================================================
print("=" * 60)
print("Demo 1: Universality Classes of a Tropical Depth Flow")
print("=" * 60)

# A flow on {0,1,...,7} with depth = value
# step: 7->3, 6->2, 5->1, 4->0, 3->1, 2->0, 1->0, 0->0
step1 = lambda x: [0, 0, 0, 1, 0, 1, 2, 3][x]

classes1 = compute_universality_classes(step1, 8)
print(f"\nFlow on {{0,...,7}}:")
print(f"step = [0, 0, 0, 1, 0, 1, 2, 3]")
print(f"Number of universality classes: {len(classes1)}")
for fp, members in sorted(classes1.items()):
    print(f"  Fixed point {fp}: class = {members}")
print(f"  log2(8) + 2 = {np.log2(8) + 2:.0f} (conjecture bound)")

# ============================================================
# Demo 2: Merging Principle verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Verifying the Merging Principle")
print("=" * 60)

# F on {0,...,5}: step = [0, 0, 0, 1, 2, 3]
step_f = lambda x: [0, 0, 0, 1, 2, 3][x]
# G on {0,1,2}: step = [0, 0, 1]  
step_g = lambda x: [0, 0, 1][x]
# phi: 0->0, 1->0, 2->1, 3->1, 4->2, 5->2
phi = lambda x: [0, 0, 1, 1, 2, 2][x]

classes_f = compute_universality_classes(step_f, 6)
classes_g = compute_universality_classes(step_g, 3)

print(f"\nF classes: {classes_f}")
print(f"G classes: {classes_g}")
print(f"phi = [0, 0, 1, 1, 2, 2]")

result = verify_merging_principle(step_f, 6, step_g, 3, phi)
print(f"Merging Principle holds: {result}")

# ============================================================
# Demo 3: Tropical step dynamics
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Tropical Max-Plus Step Dynamics")
print("=" * 60)

n = 4
W = np.array([
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1],
    [1, 0, 0, 0]
], dtype=float)

v = np.array([10.0, 0.0, 0.0, 0.0])
print(f"\nWeighted cycle graph (4 nodes), W = cycle with weight 1")
print(f"Initial: v = {v}")
for k in range(8):
    v = tropical_step(W, v)
    print(f"Step {k+1}: v = {np.round(v, 3)}")

# ============================================================
# Demo 4: Non-expansion verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Non-Expansion Theorem Verification")
print("=" * 60)

np.random.seed(42)
W_rand = np.random.rand(5, 5)
v_rand = np.random.randn(5) * 10
w_rand = np.random.randn(5) * 10

print(f"\nRandom 5x5 weight matrix, random initial vectors")
for k in range(10):
    before, after = test_nonexpansion(W_rand, v_rand, w_rand)
    print(f"Step {k}: ||v-w||_inf = {before:.4f} -> ||Tv-Tw||_inf = {after:.4f}  "
          f"(ratio: {after/before:.4f})")
    v_rand = tropical_step(W_rand, v_rand)
    w_rand = tropical_step(W_rand, w_rand)

# ============================================================
# Demo 5: Universality class count for strictly contracting flows
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Maximum Universality Class Count")
print("=" * 60)

print(f"\nFor strictly contracting flows on Fin(n):")
print(f"{'n':>4} | {'max classes':>12} | {'= n?':>6}")
print("-" * 30)
for n_test in range(2, 9):
    max_c = count_strict_contraction_classes(n_test)
    print(f"{n_test:>4} | {max_c:>12} | {'  YES' if max_c == n_test else '   NO':>6}")
print("\nObservation: The maximum is always n (achieved when step = identity,")
print("i.e., every element is a fixed point). Under strict contraction,")
print("fixed points are allowed — only non-fixed points must decrease depth.")

print("\nDone!")


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
