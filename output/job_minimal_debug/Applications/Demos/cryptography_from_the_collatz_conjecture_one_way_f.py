#!/usr/bin/env python3
"""
Collatz One-Way Functions: Interactive Demo

Demonstrates the key concepts from the formalization:
1. Forward computation vs. preimage search asymmetry
2. Collatz hash construction and collision resistance
3. Preimage tree growth
4. Security gap analysis
"""

import time
from algorithms import (
    collatz_step, collatz_iter, collatz_trajectory,
    collatz_preimage, collatz_preimage_tree,
    CollatzHashConfig, forward_cost, inverse_cost,
    security_gap, collatz_hash_fingerprint,
    verify_preimage_growth_conjecture,
)


def demo_collatz_basics():
    """Demonstrate basic Collatz map properties."""
    print("=" * 60)
    print("DEMO 1: Basic Collatz Map Properties")
    print("=" * 60)
    
    # Show even/odd behavior
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 27, 100]:
        step = collatz_step(n)
        branch = "even→n/2" if n % 2 == 0 else "odd→3n+1"
        print(f"  T({n:3d}) = {step:4d}  [{branch}]")
    
    print()
    
    # Famous trajectory of 27
    traj = collatz_trajectory(27, 111)
    print(f"  Trajectory of 27 (length {len(traj)}):")
    print(f"  First 20: {traj[:20]}")
    print(f"  Max value: {max(traj)}")
    print(f"  Reaches 1 at step: {traj.index(1) if 1 in traj else 'not found'}")


def demo_forward_inverse_asymmetry():
    """Demonstrate the forward-inverse computational gap."""
    print("\n" + "=" * 60)
    print("DEMO 2: Forward-Inverse Computational Asymmetry")
    print("=" * 60)
    
    n = 12345
    print(f"\n  Forward computation: T^k({n})")
    for k in [10, 20, 50, 100]:
        start = time.perf_counter()
        result = collatz_iter(k, n)
        elapsed = time.perf_counter() - start
        print(f"    k={k:3d}: T^k({n}) = {result:10d}  ({elapsed*1e6:.1f} μs)")
    
    print(f"\n  Preimage tree search: T^{{-k}}(1)")
    for k in range(1, 16):
        start = time.perf_counter()
        tree = collatz_preimage_tree(1, k)
        elapsed = time.perf_counter() - start
        size = len(tree[k])
        print(f"    k={k:2d}: |T^{{-k}}(1)| = {size:6d}  ({elapsed*1e3:.2f} ms)")
    
    print(f"\n  Security gap (inverse/forward cost ratio):")
    for k in [5, 10, 15, 20, 25, 30]:
        gap = security_gap(k)
        print(f"    k={k:2d}: gap = 2^k/k = {gap:,.1f}")


def demo_preimage_structure():
    """Demonstrate the branching structure of Collatz preimages."""
    print("\n" + "=" * 60)
    print("DEMO 3: Preimage Structure (Branching Factor)")
    print("=" * 60)
    
    targets = [1, 2, 4, 8, 16, 32]
    for m in targets:
        pre = collatz_preimage(m)
        print(f"  T^{{-1}}({m:3d}) = {sorted(pre)}  (|preimage| = {len(pre)})")
    
    print(f"\n  Preimage branching (how many values have 1 vs 2 preimages):")
    one_pre = 0
    two_pre = 0
    for m in range(1, 1001):
        size = len(collatz_preimage(m))
        if size == 1:
            one_pre += 1
        elif size == 2:
            two_pre += 1
    print(f"    Out of m in [1,1000]: {one_pre} have 1 preimage, {two_pre} have 2 preimages")
    print(f"    Fraction with 2 preimages: {two_pre/1000:.3f} (expected ≈ 1/6 = {1/6:.3f})")


def demo_hash_construction():
    """Demonstrate the Collatz hash function."""
    print("\n" + "=" * 60)
    print("DEMO 4: Collatz Hash Function Construction")
    print("=" * 60)
    
    cfg = CollatzHashConfig(
        depths=[10, 15, 20, 25],
        seeds=[1, 3, 5, 7]
    )
    
    print(f"\n  Hash config: {cfg.num_chains} chains")
    print(f"  Depths: {cfg.depths}")
    print(f"  Seeds:  {cfg.seeds}")
    
    print(f"\n  Hash values:")
    for x in [42, 43, 44, 100, 1000, 9999]:
        h = cfg.hash(x)
        fp = collatz_hash_fingerprint(x)[:16]
        print(f"    hash({x:5d}) = {h}  fingerprint={fp}...")
    
    print(f"\n  Collision search in [0, 10000):")
    start = time.perf_counter()
    collision = cfg.find_collision(range(10000))
    elapsed = time.perf_counter() - start
    if collision:
        x, y = collision
        print(f"    Found collision: hash({x}) = hash({y}) = {cfg.hash(x)}")
    else:
        print(f"    No collision found ({elapsed:.2f}s)")


def demo_sensitivity():
    """Demonstrate sensitivity to initial conditions."""
    print("\n" + "=" * 60)
    print("DEMO 5: Sensitivity to Initial Conditions")
    print("=" * 60)
    
    n1, n2 = 1000, 1001
    depth = 30
    t1 = collatz_trajectory(n1, depth)
    t2 = collatz_trajectory(n2, depth)
    
    print(f"\n  Trajectories of {n1} vs {n1+1} (depth {depth}):")
    print(f"  {'k':>4s}  {'T^k({})'.format(n1):>10s}  {'T^k({})'.format(n2):>10s}  {'match':>6s}")
    for k in range(depth + 1):
        match = "✓" if t1[k] == t2[k] else "✗"
        print(f"  {k:4d}  {t1[k]:10d}  {t2[k]:10d}  {match:>6s}")


def demo_conjecture_test():
    """Test the preimage growth conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 6: Preimage Growth Conjecture Test")
    print("=" * 60)
    
    print(f"\n  Conjecture: |T^{{-k}}(1)| ≥ k for all k ≥ 10")
    print(f"\n  {'k':>4s}  {'|T^{-k}(1)|':>12s}  {'k':>4s}  {'satisfies?':>10s}")
    
    results = verify_preimage_growth_conjecture(25)
    for k in range(10, 26):
        size = results[k]
        satisfies = "✓" if size >= k else "✗ REFUTED"
        print(f"  {k:4d}  {size:12d}  {k:4d}  {satisfies:>10s}")


if __name__ == "__main__":
    demo_collatz_basics()
    demo_forward_inverse_asymmetry()
    demo_preimage_structure()
    demo_hash_construction()
    demo_sensitivity()
    demo_conjecture_test()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Collatz Trajectory Sensitivity and Divergence

Shows how nearby starting values produce wildly different trajectories,
illustrating the "sensitivity to initial conditions" that makes the
Collatz map useful as a cryptographic primitive.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n):
    if n <= 0:
        return 0
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_trajectory(n, k):
    traj = [n]
    current = n
    for _ in range(k):
        current = collatz_step(current)
        traj.append(current)
    return traj


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Collatz Trajectories: Sensitivity and Cryptographic Properties",
             fontsize=15, fontweight='bold')

# Plot 1: Nearby starting values diverge
ax = axes[0, 0]
depth = 60
colors = plt.cm.viridis(np.linspace(0, 0.9, 5))
for i, n in enumerate([100, 101, 102, 103, 104]):
    traj = collatz_trajectory(n, depth)
    ax.plot(traj, color=colors[i], alpha=0.8, linewidth=1.2, label=f'n={n}')
ax.set_xlabel('Step')
ax.set_ylabel('Value')
ax.set_title('Nearby Inputs → Divergent Trajectories')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 2: Famous trajectory of 27
ax = axes[0, 1]
traj_27 = collatz_trajectory(27, 111)
ax.plot(traj_27, color='darkblue', linewidth=0.8)
ax.set_xlabel('Step')
ax.set_ylabel('Value')
ax.set_title('Trajectory of n=27 (reaches 1 at step 111)')
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)

# Plot 3: Parity pattern (even/odd bit sequence)
ax = axes[1, 0]
n_vals = [27, 31, 255]
for n in n_vals:
    traj = collatz_trajectory(n, 50)
    parities = [v % 2 for v in traj[:50]]
    ax.plot(parities, 'o', markersize=2, label=f'n={n}')
ax.set_xlabel('Step')
ax.set_ylabel('Parity (0=even, 1=odd)')
ax.set_title('Parity Sequences (Pseudo-Random Appearance)')
ax.legend(fontsize=8)
ax.set_yticks([0, 1])
ax.grid(True, alpha=0.3)

# Plot 4: Hamming distance between trajectories
ax = axes[1, 1]
depth = 40
n_base = 1000
diffs = []
for delta in range(1, 51):
    t1 = collatz_trajectory(n_base, depth)
    t2 = collatz_trajectory(n_base + delta, depth)
    matching = sum(1 for a, b in zip(t1, t2) if a == b)
    diffs.append(matching)
ax.bar(range(1, 51), diffs, color='steelblue', alpha=0.7)
ax.set_xlabel('Input difference (Δ)')
ax.set_ylabel(f'Matching steps (out of {depth+1})')
ax.set_title(f'Trajectory Overlap: T^k({n_base}) vs T^k({n_base}+Δ)')
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_collatz_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved viz_collatz_trajectories.png")


#!/usr/bin/env python3
"""
Visualization: Forward-Inverse Security Gap for Collatz One-Way Functions

Shows the exponential gap between forward computation cost O(k) and
inverse search cost O(2^k), demonstrating the one-way function property.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def collatz_step(n):
    if n <= 0:
        return 0
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_preimage(m):
    if m <= 0:
        return {0}
    preimages = {2 * m}
    if (m - 1) % 3 == 0:
        candidate = (m - 1) // 3
        if candidate > 0 and candidate % 2 == 1:
            preimages.add(candidate)
    return preimages

def preimage_tree_size(m, depth):
    current = {m}
    for _ in range(depth):
        next_level = set()
        for val in current:
            next_level |= collatz_preimage(val)
        current = next_level
    return len(current)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Collatz One-Way Functions: Security Analysis", fontsize=16, fontweight='bold')

# Plot 1: Forward vs Inverse Cost
ax = axes[0, 0]
k_vals = np.arange(1, 26)
forward = k_vals
inverse = 2.0 ** k_vals
ax.semilogy(k_vals, forward, 'b-o', markersize=4, label='Forward cost = k')
ax.semilogy(k_vals, inverse, 'r-s', markersize=4, label='Inverse cost = 2^k')
ax.fill_between(k_vals, forward, inverse, alpha=0.2, color='red', label='Security gap')
ax.set_xlabel('Iteration depth k')
ax.set_ylabel('Computational cost')
ax.set_title('Forward-Inverse Asymmetry')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Security Gap Ratio
ax = axes[0, 1]
gap = inverse / forward
ax.semilogy(k_vals, gap, 'g-^', markersize=5, color='darkgreen')
ax.set_xlabel('Iteration depth k')
ax.set_ylabel('Gap ratio (2^k / k)')
ax.set_title('Security Gap Growth')
ax.grid(True, alpha=0.3)
ax.axhline(y=1e6, color='red', linestyle='--', alpha=0.5, label='1M barrier')
ax.legend()

# Plot 3: k^2 vs 2^k (proved theorem)
ax = axes[1, 0]
k2 = k_vals ** 2
ax.semilogy(k_vals, k2, 'b-o', markersize=4, label='k²')
ax.semilogy(k_vals, k_vals ** 2 + k_vals, 'm-d', markersize=4, label='k² + k')
ax.semilogy(k_vals, inverse, 'r-s', markersize=4, label='2^k')
ax.axvline(x=5, color='green', linestyle='--', alpha=0.7, label='k = 5 (proved threshold)')
ax.set_xlabel('Iteration depth k')
ax.set_ylabel('Value')
ax.set_title('Proved: k² + k < 2^k for k ≥ 5')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 4: Preimage Tree Growth
ax = axes[1, 1]
depths = range(1, 21)
tree_sizes = [preimage_tree_size(1, d) for d in depths]
ax.plot(list(depths), tree_sizes, 'b-o', markersize=5, label='|T^{-k}(1)|')
ax.plot(list(depths), [2**d for d in depths], 'r--', alpha=0.5, label='2^k upper bound')
ax.plot(list(depths), list(depths), 'g--', alpha=0.5, label='k (conjecture lower bound)')
ax.set_xlabel('Preimage depth k')
ax.set_ylabel('Preimage tree size')
ax.set_title('Preimage Tree Growth')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_security_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_security_gap.png")
