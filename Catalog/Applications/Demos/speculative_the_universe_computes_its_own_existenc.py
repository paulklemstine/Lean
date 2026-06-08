#!/usr/bin/env python3
"""
Demo: Self-Simulating Universe Fixed-Point Theory

Demonstrates the SimulatorAlgebra framework with concrete numerical examples.
Shows how monotone binary operators on complete lattices produce self-consistent
fixed points — the mathematical skeleton behind "physics = computation."
"""

import numpy as np
from typing import Callable, Tuple, List


def example_1_powerset_lattice():
    """
    Example 1: Powerset lattice on {0,1,2,3} with a monotone binary sim operator.
    
    The complete lattice is P({0,1,2,3}) ordered by inclusion.
    sim(A, B) = A ∪ B ∪ {min element adjacent to A∩B}.
    Self-consistent sets satisfy sim(L, L) = L.
    """
    print("=" * 60)
    print("Example 1: Powerset Lattice Self-Simulation")
    print("=" * 60)
    
    universe = {0, 1, 2, 3}
    
    def sim(A: frozenset, B: frozenset) -> frozenset:
        """Monotone binary simulation operator."""
        intersection = A & B
        result = A | B
        # Add adjacency: if intersection is nonempty, add min+1 mod 4
        if intersection:
            m = min(intersection)
            result = result | frozenset({(m + 1) % 4})
        return result
    
    # Find all self-consistent sets: sim(L, L) = L
    fixed_points = []
    for mask in range(2**4):
        L = frozenset(i for i in range(4) if mask & (1 << i))
        if sim(L, L) == L:
            fixed_points.append(L)
    
    print(f"\nAll self-consistent law configurations:")
    for fp in sorted(fixed_points, key=lambda s: (len(s), sorted(s))):
        print(f"  L = {set(fp) if fp else '{}'}")
    
    # Find minimal and maximal
    minimal = min(fixed_points, key=lambda s: len(s))
    maximal = max(fixed_points, key=lambda s: len(s))
    print(f"\nMinimal law (simplest): {set(minimal) if minimal else '{}'}")
    print(f"Maximal law (richest):  {set(maximal)}")
    
    # Verify iteration convergence from bottom
    print(f"\nIteration from ⊥ = {{}}:")
    L = frozenset()
    for i in range(8):
        L_next = sim(L, L)
        print(f"  Φ^{i}(⊥) = {set(L) if L else '{}'}")
        if L_next == L:
            print(f"  → Converged at step {i}!")
            break
        L = L_next


def example_2_real_interval():
    """
    Example 2: The unit interval [0,1] with sim(a,b) = (a+b)/2 + c
    for various constants c.
    
    Fixed point of Φ(L) = sim(L,L) = L + c satisfies L = L + c,
    so c = 0 gives every point as fixed, and c > 0 has no fixed point
    in [0,1] unless we use the lattice completion.
    """
    print("\n" + "=" * 60)
    print("Example 2: Real Interval Self-Simulation")
    print("=" * 60)
    
    def sim_averaging(a: float, b: float) -> float:
        """sim(a,b) = (a+b)/2: every point is a fixed point."""
        return (a + b) / 2
    
    def sim_contractive(a: float, b: float) -> float:
        """sim(a,b) = (a+b+1)/3: unique fixed point at 1/2."""
        return min(1.0, max(0.0, (a + b + 0.5) / 3))
    
    for name, sim_fn, desc in [
        ("Averaging", sim_averaging, "sim(a,b) = (a+b)/2"),
        ("Contractive", sim_contractive, "sim(a,b) = (a+b+0.5)/3"),
    ]:
        print(f"\n  {name}: {desc}")
        
        # Find fixed points by iteration from 0
        L = 0.0
        print(f"    Iteration from ⊥ = 0:")
        for i in range(15):
            L_new = sim_fn(L, L)
            print(f"      Φ^{i+1}(0) = {L_new:.6f}")
            if abs(L_new - L) < 1e-10:
                print(f"      → Converged to {L_new:.6f}")
                break
            L = L_new
        
        # Find fixed points by iteration from 1
        L = 1.0
        print(f"    Iteration from ⊤ = 1:")
        for i in range(15):
            L_new = sim_fn(L, L)
            print(f"      Φ^{i+1}(1) = {L_new:.6f}")
            if abs(L_new - L) < 1e-10:
                print(f"      → Converged to {L_new:.6f}")
                break
            L = L_new


def example_3_non_triviality():
    """
    Example 3: Non-triviality criterion.
    
    Demonstrates the theorem: if sim(⊥,⊥) > ⊥, then the minimal
    self-consistent law is nontrivial.
    """
    print("\n" + "=" * 60)
    print("Example 3: Non-Triviality Criterion")
    print("=" * 60)
    
    def sim_trivial(a: float, b: float) -> float:
        """sim(⊥,⊥) = ⊥: minimal law IS ⊥."""
        return (a * b)  # sim(0,0) = 0
    
    def sim_nontrivial(a: float, b: float) -> float:
        """sim(⊥,⊥) > ⊥: minimal law is NONTRIVIAL."""
        return min(1.0, max(0.0, (a + b) / 2 + 0.1))  # sim(0,0) = 0.1 > 0
    
    for name, sim_fn in [("Trivial", sim_trivial), ("Nontrivial", sim_nontrivial)]:
        bottom_val = sim_fn(0.0, 0.0)
        print(f"\n  {name}: sim(⊥,⊥) = {bottom_val}")
        
        # Iterate to find minimal fixed point
        L = 0.0
        for i in range(50):
            L_new = sim_fn(L, L)
            if abs(L_new - L) < 1e-12:
                break
            L = L_new
        
        print(f"  Minimal fixed point ≈ {L:.6f}")
        if bottom_val > 0:
            print(f"  ✓ sim(⊥,⊥) = {bottom_val} > 0, so minimal law > ⊥ = 0")
        else:
            print(f"  ✓ sim(⊥,⊥) = 0, so minimal law = ⊥ = 0")


def example_4_composition():
    """
    Example 4: Composition of simulator algebras.
    
    (S ∘ T).sim(a,b) = S.sim(T.sim(a,b), T.sim(a,b))
    
    If L is a fixed point of both S and T, it's a fixed point of S ∘ T.
    """
    print("\n" + "=" * 60)
    print("Example 4: Composition of Simulators")
    print("=" * 60)
    
    def sim_S(a: float, b: float) -> float:
        return min(1.0, (a + b) / 2 + 0.05)
    
    def sim_T(a: float, b: float) -> float:
        return min(1.0, (a + b * 2) / 3 + 0.02)
    
    def sim_compose(a: float, b: float) -> float:
        t_val = sim_T(a, b)
        return sim_S(t_val, t_val)
    
    print(f"\n  Finding fixed points by iteration from ⊥ = 0:")
    for name, sim_fn in [("S", sim_S), ("T", sim_T), ("S∘T", sim_compose)]:
        L = 0.0
        for i in range(100):
            L_new = sim_fn(L, L)
            if abs(L_new - L) < 1e-12:
                break
            L = L_new
        print(f"    {name}: minimal fixed point ≈ {L:.6f}")


def example_5_idempotent():
    """
    Example 5: Idempotent simulator.
    
    If Φ² = Φ, then every image point of Φ is a fixed point.
    The minimal law = Φ(⊥) and maximal law = Φ(⊤).
    """
    print("\n" + "=" * 60)
    print("Example 5: Idempotent Simulator (Φ² = Φ)")
    print("=" * 60)
    
    def sim_idem(a: float, b: float) -> float:
        """An idempotent sim: projects to [0.3, 0.7]."""
        raw = (a + b) / 2
        return max(0.3, min(0.7, raw))
    
    # Verify idempotence
    test_vals = np.linspace(0, 1, 20)
    max_error = 0
    for x in test_vals:
        phi_x = sim_idem(x, x)
        phi_phi_x = sim_idem(phi_x, phi_x)
        max_error = max(max_error, abs(phi_phi_x - phi_x))
    
    print(f"\n  Max |Φ²(x) - Φ(x)| over test grid: {max_error:.2e}")
    print(f"  Φ(⊥) = Φ(0) = {sim_idem(0, 0):.1f} (minimal law)")
    print(f"  Φ(⊤) = Φ(1) = {sim_idem(1, 1):.1f} (maximal law)")
    
    print(f"\n  Every output of Φ is a fixed point:")
    for x in [0.0, 0.2, 0.5, 0.8, 1.0]:
        phi_x = sim_idem(x, x)
        phi_phi_x = sim_idem(phi_x, phi_x)
        print(f"    Φ({x}) = {phi_x:.1f}, Φ(Φ({x})) = {phi_phi_x:.1f} ✓")


if __name__ == "__main__":
    print("Self-Simulating Universe: Fixed-Point Theory Demonstrations")
    print("=" * 60)
    
    example_1_powerset_lattice()
    example_2_real_interval()
    example_3_non_triviality()
    example_4_composition()
    example_5_idempotent()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("Key insight: Self-consistent physical laws correspond to")
    print("fixed points of the diagonal self-simulation operator Φ(L) = sim(L,L).")
    print("The Knaster-Tarski theorem guarantees existence in any")
    print("complete lattice, and the minimal fixed point represents")
    print("the 'simplest' self-consistent law of physics.")


#!/usr/bin/env python3
"""
Visualization: Fixed-Point Landscape of Self-Simulating Universes

Generates plots showing:
1. Cobweb diagram of self-simulation iteration
2. Fixed-point defect landscape
3. Composition of simulators
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_cobweb_diagram():
    """
    Cobweb diagram showing iteration of Φ(L) = sim(L, L) from ⊥ = 0.
    Multiple sim operators compared side by side.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    sims = [
        ("Averaging: (x+0.5)/2", lambda x: (x + 0.5) / 2, 0.5),
        ("Contractive: (x+0.3)/2", lambda x: (x + 0.3) / 2, 0.3),
        ("Inflationary: min(1, x+0.15)", lambda x: min(1.0, x + 0.15), 1.0),
    ]
    
    for ax, (title, phi, fp) in zip(axes, sims):
        x = np.linspace(0, 1, 200)
        y = np.array([phi(xi) for xi in x])
        
        ax.plot(x, y, 'b-', linewidth=2, label='Φ(L)')
        ax.plot(x, x, 'k--', linewidth=1, label='L = Φ(L)')
        
        # Cobweb iteration from 0
        L = 0.0
        cobweb_x, cobweb_y = [L], [0.0]
        for _ in range(20):
            L_new = phi(L)
            cobweb_x.extend([L, L_new])
            cobweb_y.extend([L_new, L_new])
            if abs(L_new - L) < 1e-10:
                break
            L = L_new
        
        ax.plot(cobweb_x, cobweb_y, 'r-', linewidth=1, alpha=0.7, label='Iteration')
        ax.plot(fp, fp, 'go', markersize=10, zorder=5, label=f'Fixed pt ≈ {fp:.2f}')
        
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('L')
        ax.set_ylabel('Φ(L)')
        ax.legend(fontsize=8)
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Self-Simulation Iteration: Cobweb Diagrams', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_cobweb.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_cobweb.png")


def plot_defect_landscape():
    """
    Plot the fixed-point defect |Φ(L) - L| across the lattice.
    Zeros of this function are self-consistent laws.
    """
    fig, ax = plt.subplots(figsize=(10, 6))
    
    sims = [
        ("(x+0.5)/2", lambda x: (x + 0.5) / 2),
        ("(x² + 0.2)", lambda x: min(1.0, x**2 + 0.2)),
        ("x·(1-x) + x", lambda x: min(1.0, x*(1-x) + x)),
        ("(2x+0.1)/3", lambda x: (2*x + 0.1) / 3),
    ]
    
    x = np.linspace(0, 1, 500)
    
    for label, phi in sims:
        defect = np.array([abs(phi(xi) - xi) for xi in x])
        ax.plot(x, defect, linewidth=2, label=f'Φ(L) = {label}')
    
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlabel('Law Configuration L', fontsize=12)
    ax.set_ylabel('Fixed-Point Defect |Φ(L) - L|', fontsize=12)
    ax.set_title('Fixed-Point Defect Landscape\n(Zeros = Self-Consistent Laws)', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    
    plt.tight_layout()
    plt.savefig('viz_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_defect.png")


def plot_fixed_point_lattice():
    """
    Visualize the lattice structure of fixed points for a powerset lattice.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: iteration trajectory on [0,1]²  
    ax = axes[0]
    
    def sim_2d(x, y):
        return (min(1, (x + y) / 2 + 0.1), min(1, (x * y) + 0.05))
    
    def phi_2d(x, y):
        return sim_2d(x, y)  # diagonal: sim(L,L) where L = (x,y)
    
    # Show vector field
    xx, yy = np.meshgrid(np.linspace(0, 1, 15), np.linspace(0, 1, 15))
    dx = np.zeros_like(xx)
    dy = np.zeros_like(yy)
    for i in range(xx.shape[0]):
        for j in range(xx.shape[1]):
            px, py = phi_2d(xx[i,j], yy[i,j])
            dx[i,j] = px - xx[i,j]
            dy[i,j] = py - yy[i,j]
    
    ax.quiver(xx, yy, dx, dy, alpha=0.4, color='blue')
    
    # Iterate from several starting points
    starts = [(0, 0), (1, 1), (0.5, 0), (0, 0.5), (1, 0.5)]
    colors = ['red', 'green', 'orange', 'purple', 'brown']
    for (x0, y0), c in zip(starts, colors):
        traj_x, traj_y = [x0], [y0]
        x, y = x0, y0
        for _ in range(30):
            x_new, y_new = phi_2d(x, y)
            traj_x.append(x_new)
            traj_y.append(y_new)
            if abs(x_new - x) + abs(y_new - y) < 1e-8:
                break
            x, y = x_new, y_new
        ax.plot(traj_x, traj_y, '-o', color=c, markersize=3, linewidth=1.5,
                label=f'From ({x0},{y0})')
        ax.plot(traj_x[-1], traj_y[-1], '*', color=c, markersize=15)
    
    ax.set_xlabel('Component 1', fontsize=11)
    ax.set_ylabel('Component 2', fontsize=11)
    ax.set_title('2D Self-Simulation Flow Field', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8, loc='lower right')
    ax.grid(True, alpha=0.3)
    
    # Right: minimal vs maximal law comparison
    ax = axes[1]
    
    # Several 1D simulators with different parameters
    params = np.linspace(0.0, 0.4, 20)
    lfps = []
    gfps = []
    
    for c in params:
        phi = lambda x, c=c: min(1.0, max(0.0, (x + c) / 2 + c))
        
        # LFP from bottom
        x = 0.0
        for _ in range(200):
            x_new = phi(x)
            if abs(x_new - x) < 1e-14:
                break
            x = x_new
        lfps.append(x)
        
        # GFP from top
        x = 1.0
        for _ in range(200):
            x_new = phi(x)
            if abs(x_new - x) < 1e-14:
                break
            x = x_new
        gfps.append(x)
    
    ax.fill_between(params, lfps, gfps, alpha=0.3, color='blue', label='Fixed-point interval')
    ax.plot(params, lfps, 'b-', linewidth=2, label='Minimal law (LFP)')
    ax.plot(params, gfps, 'r-', linewidth=2, label='Maximal law (GFP)')
    ax.set_xlabel('Simulation Strength c', fontsize=11)
    ax.set_ylabel('Fixed-Point Value', fontsize=11)
    ax.set_title('Min/Max Law Gap vs Simulation Strength', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_lattice.png")


if __name__ == "__main__":
    plot_cobweb_diagram()
    plot_defect_landscape()
    plot_fixed_point_lattice()
    print("\nAll visualizations generated successfully.")
