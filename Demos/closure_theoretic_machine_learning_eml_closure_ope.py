#!/usr/bin/env python3
"""
Closure-Theoretic Machine Learning: Interactive Demo

Demonstrates the core concepts formalized in Lean 4:
1. The closure fiber operator cl_f(A) = f⁻¹(f(A))
2. EML properties (Extensive, Monotone, Idempotent)
3. Certified robustness radii via distance to fiber boundaries
4. Adversarial training convergence in one step
5. Closure one-way function security bounds

Run: python3 demo.py
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import ListedColormap
from collections import Counter

# =============================================================================
# Part 1: The Closure Fiber Operator
# =============================================================================

def closure_fiber(f, A, X):
    """
    Compute cl_f(A) = f⁻¹(f(A)) = {x ∈ X : ∃ y ∈ A, f(x) = f(y)}
    
    Args:
        f: classifier function (dict or callable)
        A: subset of X (set)
        X: universe (set)
    Returns:
        cl_f(A) as a set
    """
    # Compute image f(A)
    image_A = {f[x] if isinstance(f, dict) else f(x) for x in A}
    # Compute preimage f⁻¹(f(A))
    return {x for x in X if (f[x] if isinstance(f, dict) else f(x)) in image_A}


def demo_closure_fiber():
    """Demonstrate the closure fiber operator on a simple classifier."""
    print("=" * 60)
    print("DEMO 1: The Closure Fiber Operator")
    print("=" * 60)
    
    # Universe: 12 points
    X = set(range(12))
    # Classifier: 3 classes (colors)
    f = {0: 'R', 1: 'R', 2: 'R', 3: 'R',  # Red cluster
         4: 'G', 5: 'G', 6: 'G', 7: 'G',  # Green cluster
         8: 'B', 9: 'B', 10: 'B', 11: 'B'} # Blue cluster
    
    print(f"\nUniverse X = {X}")
    print(f"Classifier f: {f}")
    
    # Test with a small set
    A = {1, 5}
    cl_A = closure_fiber(f, A, X)
    print(f"\nA = {A}")
    fA = {f[x] for x in A}
    print(f"f(A) = {fA}")
    print(f"cl_f(A) = f⁻¹(f(A)) = {cl_A}")
    print(f"  → Contains all Red and Green points")
    
    # Verify EML properties
    print("\n--- Verifying EML Properties ---")
    
    # Extensivity: A ⊆ cl_f(A)
    assert A <= cl_A, "FAIL: Extensivity violated!"
    print(f"✓ Extensivity: A ⊆ cl_f(A)")
    
    # Monotonicity: A ⊆ B → cl_f(A) ⊆ cl_f(B)
    B = {1, 5, 9}
    cl_B = closure_fiber(f, B, X)
    assert A <= B
    assert cl_A <= cl_B, "FAIL: Monotonicity violated!"
    print(f"✓ Monotonicity: A ⊆ B → cl_f(A) ⊆ cl_f(B)")
    print(f"  A={A}, B={B}, cl(A)={cl_A}, cl(B)={cl_B}")
    
    # Idempotence: cl_f(cl_f(A)) = cl_f(A)
    cl_cl_A = closure_fiber(f, cl_A, X)
    assert cl_cl_A == cl_A, "FAIL: Idempotence violated!"
    print(f"✓ Idempotence: cl_f(cl_f(A)) = cl_f(A)")
    
    # Union distributes
    C_set = {9}
    cl_C = closure_fiber(f, C_set, X)
    cl_union = closure_fiber(f, A | C_set, X)
    assert cl_union == cl_A | cl_C, "FAIL: Union distribution violated!"
    print(f"✓ Union distributes: cl_f(A∪C) = cl_f(A) ∪ cl_f(C)")
    
    return True


# =============================================================================
# Part 2: Certified Robustness Visualization
# =============================================================================

def certified_robustness_radius(f_values, x_idx, points):
    """
    Compute the certified robustness radius at point x:
    r(x) = inf{d(x,y) : f(y) ≠ f(x)}
    """
    x_label = f_values[x_idx]
    x_point = points[x_idx]
    
    min_dist = float('inf')
    for i, (p, label) in enumerate(zip(points, f_values)):
        if label != x_label:
            d = np.linalg.norm(x_point - p)
            min_dist = min(min_dist, d)
    
    return min_dist


def demo_certified_robustness():
    """Visualize certified robustness radii for a 2D classifier."""
    print("\n" + "=" * 60)
    print("DEMO 2: Certified Robustness via Closure Boundaries")
    print("=" * 60)
    
    np.random.seed(42)
    
    # Generate 2D classification data: 3 clusters
    n_per_class = 30
    centers = np.array([[0, 0], [3, 0], [1.5, 2.5]])
    points = []
    labels = []
    for i, center in enumerate(centers):
        pts = center + 0.5 * np.random.randn(n_per_class, 2)
        points.extend(pts)
        labels.extend([i] * n_per_class)
    
    points = np.array(points)
    labels = np.array(labels)
    
    # Compute certified radius for each point
    radii = np.array([certified_robustness_radius(labels, i, points) 
                       for i in range(len(points))])
    
    print(f"\nGenerated {len(points)} points in 3 classes")
    print(f"Average certified radius: {radii.mean():.3f}")
    print(f"Min certified radius: {radii.min():.3f}")
    print(f"Max certified radius: {radii.max():.3f}")
    
    # Verify robustness triangle inequality: |r(x) - r(y)| ≤ d(x,y)
    print("\n--- Verifying Robustness Lipschitz Property ---")
    violations = 0
    for i in range(min(100, len(points))):
        for j in range(i+1, min(100, len(points))):
            d = np.linalg.norm(points[i] - points[j])
            if abs(radii[i] - radii[j]) > d + 1e-10:
                violations += 1
    print(f"✓ Lipschitz violations (out of {min(100,len(points))*(min(100,len(points))-1)//2} pairs): {violations}")
    
    # Verify same-label guarantee
    print("\n--- Verifying Same-Label Guarantee ---")
    label_violations = 0
    for i in range(len(points)):
        for j in range(len(points)):
            if i != j and np.linalg.norm(points[i] - points[j]) < radii[i]:
                if labels[j] != labels[i]:
                    label_violations += 1
    print(f"✓ Same-label violations within certified radius: {label_violations}")
    
    # Create visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Classification with robustness circles
    ax = axes[0]
    colors = ['#e74c3c', '#2ecc71', '#3498db']
    for i in range(3):
        mask = labels == i
        ax.scatter(points[mask, 0], points[mask, 1], c=colors[i], 
                  alpha=0.7, s=30, label=f'Class {i}')
    
    # Draw certified radius circles for a few points
    for idx in [0, 30, 60]:
        circle = plt.Circle(points[idx], radii[idx], fill=False, 
                           color=colors[labels[idx]], linestyle='--', linewidth=2)
        ax.add_patch(circle)
        ax.annotate(f'r={radii[idx]:.2f}', points[idx], 
                   fontsize=8, ha='center', va='bottom')
    
    ax.set_title('Certified Robustness Radii\n(dashed circles = certified balls)')
    ax.legend()
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Heatmap of certified radii
    ax = axes[1]
    scatter = ax.scatter(points[:, 0], points[:, 1], c=radii, 
                        cmap='viridis', s=40, edgecolors='gray', linewidth=0.5)
    plt.colorbar(scatter, ax=ax, label='Certified Radius')
    ax.set_title('Certified Robustness Heatmap\n(distance to nearest decision boundary)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('robustness_visualization.png', dpi=150, bbox_inches='tight')
    print(f"\n→ Saved visualization to robustness_visualization.png")
    plt.close()


# =============================================================================
# Part 3: Adversarial Training Convergence
# =============================================================================

def demo_adversarial_convergence():
    """Demonstrate one-step convergence of adversarial training via idempotence."""
    print("\n" + "=" * 60)
    print("DEMO 3: Adversarial Training One-Step Convergence")
    print("=" * 60)
    
    # Simulate: X = {0,...,99}, f assigns labels based on x mod 5
    X = set(range(100))
    f = {x: x % 5 for x in X}
    
    # Start with a small training set
    training_set = {3, 17, 42, 68, 91}
    print(f"\nInitial training set: {training_set}")
    label_str = ', '.join(f'{x}: {f[x]}' for x in sorted(training_set))
    print(f"Labels: {{{label_str}}}")
    
    # One round of adversarial expansion
    round1 = closure_fiber(f, training_set, X)
    print(f"\nAfter 1 round: |cl_f(T)| = {len(round1)}")
    print(f"Labels covered: {sorted({f[x] for x in round1})}")
    
    # Second round
    round2 = closure_fiber(f, round1, X)
    print(f"After 2 rounds: |cl_f(cl_f(T))| = {len(round2)}")
    
    # Verify idempotence: round2 == round1
    assert round2 == round1, "FAIL: Idempotence violated!"
    print(f"\n✓ Idempotence verified: cl_f(cl_f(T)) = cl_f(T)")
    print(f"✓ Adversarial training converges in exactly 1 step!")
    
    # Compare with general iterative expansion
    print("\n--- Convergence Comparison ---")
    print(f"{'Round':>6} | {'Set Size':>10} | {'Converged?':>10}")
    print("-" * 35)
    current = training_set
    for i in range(5):
        next_set = closure_fiber(f, current, X)
        converged = next_set == current
        print(f"{i+1:>6} | {len(next_set):>10} | {'YES ✓' if converged else 'no':>10}")
        if converged:
            break
        current = next_set


# =============================================================================
# Part 4: Closure One-Way Function Security
# =============================================================================

def demo_closure_owf():
    """Demonstrate closure one-way function security bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: Closure One-Way Function Security")
    print("=" * 60)
    
    # Create a "hash-like" function with controlled fiber sizes
    np.random.seed(123)
    N = 256  # domain size
    K = 16   # range size
    
    # Random surjective function with roughly equal fibers
    f = {x: x % K for x in range(N)}
    
    # Compute fiber sizes
    fibers = Counter(f.values())
    min_fiber = min(fibers.values())
    
    print(f"\nDomain size |X| = {N}")
    print(f"Range size  |C| = {K}")
    print(f"Min fiber card  = {min_fiber}")
    print(f"Max fiber card  = {max(fibers.values())}")
    
    # Verify pigeonhole bound: minFiberCard * |range| ≤ |X|
    range_size = len(set(f.values()))
    pigeonhole = min_fiber * range_size
    print(f"\nPigeonhole bound: {min_fiber} × {range_size} = {pigeonhole} ≤ {N} ✓")
    assert pigeonhole <= N
    
    # Preimage resistance: probability of guessing a preimage
    print(f"\n--- Preimage Resistance ---")
    print(f"Given label c, probability of guessing correct preimage:")
    for c in sorted(fibers.keys())[:5]:
        prob = 1.0 / fibers[c]
        print(f"  Label {c:>2}: 1/{fibers[c]} = {prob:.4f}")
    
    print(f"  ... (showing first 5 of {K} labels)")
    avg_prob = 1.0 / (N / K)
    print(f"\nAverage guessing probability: 1/{N/K:.0f} = {avg_prob:.4f}")
    print(f"Security parameter: log₂(1/p) = {np.log2(1/avg_prob):.1f} bits")


# =============================================================================
# Part 5: Fiber Lattice Visualization
# =============================================================================

def demo_fiber_lattice():
    """Visualize the fiber lattice structure."""
    print("\n" + "=" * 60)
    print("DEMO 5: Fiber Lattice Structure")
    print("=" * 60)
    
    # Simple classifier with 3 classes
    X = set(range(9))
    f = {0: 'A', 1: 'A', 2: 'A',
         3: 'B', 4: 'B', 5: 'B',
         6: 'C', 7: 'C', 8: 'C'}
    
    # Compute all fiber-closed sets
    labels = set(f.values())
    fibers = {c: frozenset(x for x in X if f[x] == c) for c in labels}
    
    print(f"\nFibers:")
    for c, fiber in sorted(fibers.items()):
        print(f"  f⁻¹({c}) = {set(fiber)}")
    
    # The fiber-closed sets are exactly unions of fibers
    from itertools import combinations
    fiber_closed = [frozenset()]
    for r in range(1, len(labels) + 1):
        for combo in combinations(labels, r):
            closed_set = frozenset().union(*[fibers[c] for c in combo])
            fiber_closed.append(closed_set)
    
    print(f"\nFiber-closed sets ({len(fiber_closed)} total = 2^{len(labels)}):")
    for s in sorted(fiber_closed, key=len):
        print(f"  {set(s) if s else '∅'}")
    
    # Lattice height = number of labels
    print(f"\nLattice height = |labels| = {len(labels)}")
    print(f"Number of fiber-closed sets = 2^{len(labels)} = {2**len(labels)}")
    
    # Create Hasse diagram
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    # Position nodes by level (cardinality)
    levels = {}
    for s in fiber_closed:
        level = len(s) // 3  # Group by number of fibers
        if level not in levels:
            levels[level] = []
        levels[level].append(s)
    
    positions = {}
    for level, sets in levels.items():
        for i, s in enumerate(sorted(sets, key=str)):
            x = (i - (len(sets) - 1) / 2) * 2
            y = level * 2
            positions[s] = (x, y)
    
    # Draw edges (covering relations)
    for s1 in fiber_closed:
        for s2 in fiber_closed:
            if s1 < s2 and len(s2) - len(s1) == 3:  # One fiber difference
                p1, p2 = positions[s1], positions[s2]
                ax.plot([p1[0], p2[0]], [p1[1], p2[1]], 'k-', alpha=0.3)
    
    # Draw nodes
    for s, (x, y) in positions.items():
        label = '∅' if not s else str(set(s))
        color = '#3498db' if len(s) in [0, 9] else '#e74c3c' if len(s) == 3 else '#2ecc71'
        ax.plot(x, y, 'o', markersize=15, color=color, zorder=5)
        ax.annotate(label, (x, y), fontsize=6, ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))
    
    ax.set_title('Hasse Diagram: Fiber-Closed Set Lattice\n(3-class classifier, height = 3)')
    ax.set_axis_off()
    plt.tight_layout()
    plt.savefig('fiber_lattice.png', dpi=150, bbox_inches='tight')
    print(f"\n→ Saved lattice diagram to fiber_lattice.png")
    plt.close()


# =============================================================================
# Main
# =============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     Closure-Theoretic Machine Learning: Interactive Demo    ║")
    print("║                                                            ║")
    print("║  Demonstrates the EML closure operator framework for       ║")
    print("║  certified robustness, adversarial training convergence,   ║")
    print("║  and cryptographic security bounds.                        ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    demo_closure_fiber()
    demo_certified_robustness()
    demo_adversarial_convergence()
    demo_closure_owf()
    demo_fiber_lattice()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully! ✓")
    print("=" * 60)
