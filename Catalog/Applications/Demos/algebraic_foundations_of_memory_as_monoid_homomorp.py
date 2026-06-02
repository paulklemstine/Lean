#!/usr/bin/env python3
"""
Memory Algebra: Demonstrations and Numerical Examples

Demonstrates the key theorems of memory algebra using concrete examples:
1. Lossy Memory Theorem — finite hash functions over infinite domains
2. Kernel Congruence — visualizing the structure of forgetting
3. Fiber Cardinality Bound — pigeonhole quantification
4. Idempotent Compression — convergence in one step
5. Salience Aggregation — lattice-based memory
"""

from typing import Callable, Dict, List, Set, Tuple
import random
import math


def demo_lossy_memory():
    """Demonstrate the Lossy Memory Theorem with a concrete hash function."""
    print("=" * 60)
    print("DEMO 1: Lossy Memory Theorem")
    print("=" * 60)
    print()

    # Memory system: hash function mod m (monoid hom from (Z, +) to (Z/mZ, +))
    m = 7  # number of memory states
    encode = lambda x: x % m

    # Generate experiences
    experiences = list(range(100))
    states = [encode(x) for x in experiences]

    # Find collisions
    state_to_exps: Dict[int, List[int]] = {}
    for x, s in zip(experiences, states):
        state_to_exps.setdefault(s, []).append(x)

    print(f"Experience domain: {{0, 1, ..., 99}} (100 elements)")
    print(f"State space: Z/{m}Z (7 elements)")
    print(f"Encoding: x ↦ x mod {m}")
    print()
    print("Fiber structure (state → experiences mapping to it):")
    for s in sorted(state_to_exps.keys()):
        exps = state_to_exps[s]
        print(f"  State {s}: {len(exps)} experiences (e.g., {exps[:5]}...)")
    print()

    # Verify kernel congruence property
    a1, a2 = 3, 10  # encode(3) = encode(10) = 3
    b1, b2 = 5, 12  # encode(5) = encode(12) = 5
    print(f"Kernel congruence verification:")
    print(f"  encode({a1}) = {encode(a1)}, encode({a2}) = {encode(a2)} (equal: {encode(a1) == encode(a2)})")
    print(f"  encode({b1}) = {encode(b1)}, encode({b2}) = {encode(b2)} (equal: {encode(b1) == encode(b2)})")
    print(f"  encode({a1}*{b1}) = encode({a1 + b1}) = {encode(a1 + b1)}")
    print(f"  encode({a2}*{b2}) = encode({a2 + b2}) = {encode(a2 + b2)}")
    print(f"  Products also equal: {encode(a1 + b1) == encode(a2 + b2)} ✓")
    print()

    # Fiber bound
    avg_fiber = len(experiences) // m
    max_fiber = max(len(v) for v in state_to_exps.values())
    min_fiber = min(len(v) for v in state_to_exps.values())
    print(f"Fiber Cardinality Bound: ⌊{len(experiences)}/{m}⌋ = {avg_fiber}")
    print(f"Actual min fiber: {min_fiber}, max fiber: {max_fiber}")
    print(f"Bound satisfied: {min_fiber >= avg_fiber} ✓")
    print()


def demo_composition_irreversibility():
    """Demonstrate that composition preserves lossiness."""
    print("=" * 60)
    print("DEMO 2: Irreversibility of Forgetting")
    print("=" * 60)
    print()

    # First memory: mod 6
    f = lambda x: x % 6
    # Post-processing: mod 3 (further compression)
    g = lambda s: s % 3
    # Composition: mod 6 then mod 3 = mod 3 (which is lossier)
    gf = lambda x: g(f(x))

    domain = list(range(30))

    # Show f is lossy
    f_collisions = [(a, b) for a in domain for b in domain if a < b and f(a) == f(b)]
    print(f"f(x) = x mod 6:  {len(f_collisions)} collisions in [0..29]")

    # Show g∘f is also lossy (more so)
    gf_collisions = [(a, b) for a in domain for b in domain if a < b and gf(a) == gf(b)]
    print(f"g∘f(x) = x mod 3: {len(gf_collisions)} collisions in [0..29]")
    print(f"Lossiness preserved (and amplified): {len(gf_collisions)} ≥ {len(f_collisions)} ✓")
    print()

    # Concrete example
    a, b = 1, 7
    print(f"Example: f({a}) = {f(a)}, f({b}) = {f(b)}")
    print(f"  f({a}) = f({b})? {f(a) == f(b)}")
    print(f"  g(f({a})) = {gf(a)}, g(f({b})) = {gf(b)}")
    print(f"  g∘f({a}) = g∘f({b})? {gf(a) == gf(b)} (lossiness preserved) ✓")
    print()


def demo_idempotent_compression():
    """Demonstrate idempotent memory compression."""
    print("=" * 60)
    print("DEMO 3: Idempotent Memory Compression")
    print("=" * 60)
    print()

    # Compression operator: round to nearest multiple of 5
    def compress(x: int) -> int:
        return 5 * round(x / 5)

    # Show idempotence
    test_values = [0, 1, 2, 3, 7, 12, 17, 23, 48, 99]
    print("Idempotent compression r(x) = 5 * round(x/5):")
    print(f"{'x':>5} | {'r(x)':>5} | {'r(r(x))':>7} | {'r(x)=r(r(x))':>12}")
    print("-" * 40)
    for x in test_values:
        rx = compress(x)
        rrx = compress(rx)
        print(f"{x:>5} | {rx:>5} | {rrx:>7} | {'✓' if rx == rrx else '✗':>12}")

    # Fixed points = image of r
    image = sorted(set(compress(x) for x in range(100)))
    print(f"\nImage of r (stable states): {image}")
    print(f"All are fixed points: {all(compress(s) == s for s in image)} ✓")
    print()


def demo_salience_aggregation():
    """Demonstrate salience-based memory aggregation."""
    print("=" * 60)
    print("DEMO 4: Salience Aggregation (Lattice Sup)")
    print("=" * 60)
    print()

    # Salience values for experiences (higher = more salient)
    experiences = {
        "breakfast": 3,
        "commute": 1,
        "meeting": 7,
        "lunch": 4,
        "email": 2,
        "crisis": 9,
        "coffee": 3,
        "sunset": 6,
    }

    # Salience aggregator: sup (max) over experience stream
    state = 0  # initial state
    history = []
    print("Sequential memory accumulation (salience = max):")
    for name, salience in experiences.items():
        new_state = max(state, salience)
        changed = "← updated!" if new_state > state else "  (no change)"
        history.append((name, salience, new_state))
        print(f"  Experience '{name}' (salience {salience}): "
              f"state {state} → {new_state} {changed}")
        state = new_state

    print(f"\nFinal state: {state} (remembers the most salient experience)")
    print()

    # Demonstrate idempotence
    print("Idempotence: re-processing any remembered experience doesn't change state:")
    for name, salience, _ in history:
        new_state = max(state, salience)
        print(f"  Re-experience '{name}' (salience {salience}): "
              f"state {state} → {new_state} {'✓ unchanged' if new_state == state else '✗ changed!'}")
    print()


def demo_refinement_lattice():
    """Demonstrate the refinement lattice of memory systems."""
    print("=" * 60)
    print("DEMO 5: Refinement Lattice of Memory Systems")
    print("=" * 60)
    print()

    # Memory systems over Z/12Z
    n = 12
    domain = list(range(n))

    # Different memory systems (group homomorphisms Z/12Z → Z/mZ)
    systems = {
        "perfect": lambda x: x % 12,  # identity (finest)
        "mod_6": lambda x: x % 6,
        "mod_4": lambda x: x % 4,
        "mod_3": lambda x: x % 3,
        "mod_2": lambda x: x % 2,
        "trivial": lambda x: 0,  # total forgetting (coarsest)
    }

    # Compute kernel sizes
    print(f"Memory systems over Z/12Z:")
    print(f"{'System':>10} | {'States':>6} | {'Kernel size':>11} | {'Info bits':>9}")
    print("-" * 45)
    for name, enc in systems.items():
        image_size = len(set(enc(x) for x in domain))
        kernel_size = n // image_size
        info_bits = math.log2(image_size) if image_size > 0 else 0
        print(f"{name:>10} | {image_size:>6} | {kernel_size:>11} | {info_bits:>9.2f}")

    # Refinement relations
    print("\nRefinement partial order (→ means 'refines'):")
    print("  perfect → mod_6, mod_4")
    print("  mod_6 → mod_3, mod_2")
    print("  mod_4 → mod_2")
    print("  mod_3 → trivial")
    print("  mod_2 → trivial")
    print()

    # Verify kernel containment
    print("Verification: mod_6 refines mod_3?")
    m6_kernel = {(a, b) for a in domain for b in domain
                 if a != b and a % 6 == b % 6}
    m3_kernel = {(a, b) for a in domain for b in domain
                 if a != b and a % 3 == b % 3}
    print(f"  ker(mod_6) ⊆ ker(mod_3): {m6_kernel.issubset(m3_kernel)} ✓")
    print(f"  |ker(mod_6)| = {len(m6_kernel)}, |ker(mod_3)| = {len(m3_kernel)}")
    print()

    # Non-comparable systems
    print("Non-comparable: mod_4 vs mod_3?")
    m4_kernel = {(a, b) for a in domain for b in domain
                 if a != b and a % 4 == b % 4}
    print(f"  ker(mod_4) ⊆ ker(mod_3): {m4_kernel.issubset(m3_kernel)}")
    print(f"  ker(mod_3) ⊆ ker(mod_4): {m3_kernel.issubset(m4_kernel)}")
    print(f"  Neither refines the other — they are incomparable! ✓")
    print()


def demo_group_kernel():
    """Demonstrate group kernel structure and coset decomposition."""
    print("=" * 60)
    print("DEMO 6: Group Kernel and Coset Decomposition")
    print("=" * 60)
    print()

    # Group homomorphism: Z/12Z → Z/4Z (x ↦ x mod 4)
    n = 12
    m = 4
    f = lambda x: x % m

    print(f"Group homomorphism f: Z/{n}Z → Z/{m}Z, f(x) = x mod {m}")
    print()

    # Kernel
    kernel = [x for x in range(n) if f(x) == 0]
    print(f"Kernel = {{x : f(x) = 0}} = {kernel}")
    print(f"|Kernel| = {len(kernel)}")
    print()

    # Coset decomposition (fibers)
    print("Coset decomposition (each fiber is a coset of the kernel):")
    for s in range(m):
        fiber = [x for x in range(n) if f(x) == s]
        # Show it's a coset: fiber = s + kernel
        coset = [(s + k) % n for k in kernel]
        print(f"  f⁻¹({s}) = {fiber} = {s} + Kernel = {sorted(coset)}")
        assert sorted(fiber) == sorted(coset), "Coset structure violated!"

    print()
    print("All fibers have equal size |Kernel| = 3 ✓")
    print("Information loss per element: log₂(|Kernel|) = "
          f"log₂({len(kernel)}) ≈ {math.log2(len(kernel)):.2f} bits")
    print()

    # Verify kernel collision theorem
    a, k = 5, 4  # k is in kernel (f(4) = 0)
    print(f"Kernel collision: f({a} * {k}) = f({(a + k) % n}) = "
          f"{f((a + k) % n)} = f({a}) = {f(a)} ✓")


if __name__ == "__main__":
    demo_lossy_memory()
    demo_composition_irreversibility()
    demo_idempotent_compression()
    demo_salience_aggregation()
    demo_refinement_lattice()
    demo_group_kernel()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Fiber Structure of Memory Systems

Shows how a memory encoding maps experiences to states,
visualizing the fiber (pre-image) structure and the
pigeonhole bound on fiber cardinality.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_fibers(encode, domain):
    """Compute fibers of encode over domain."""
    fibers = {}
    for x in domain:
        s = encode(x)
        fibers.setdefault(s, []).append(x)
    return fibers


def plot_fiber_structure():
    """Plot the fiber structure of x mod 5 over [0, 24]."""
    m = 5
    domain = list(range(25))
    encode = lambda x: x % m
    fibers = compute_fibers(encode, domain)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: mapping diagram
    ax = axes[0]
    ax.set_title("Memory Encoding: x ↦ x mod 5", fontsize=14)
    ax.set_xlim(-1, 3)
    ax.set_ylim(-1, max(len(domain), m * 3) + 1)
    ax.axis('off')

    # Draw domain points
    colors = plt.cm.Set2(np.linspace(0, 1, m))
    for i, x in enumerate(domain):
        s = encode(x)
        color = colors[s]
        ax.plot(0, i, 'o', color=color, markersize=6)
        ax.text(-0.3, i, str(x), ha='right', va='center', fontsize=7)

    # Draw codomain points
    for s in range(m):
        y_pos = s * 5 + 2
        ax.plot(2, y_pos, 's', color=colors[s], markersize=12)
        ax.text(2.3, y_pos, f"State {s}", ha='left', va='center', fontsize=10)

    # Draw arrows
    for x in domain:
        s = encode(x)
        y_target = s * 5 + 2
        ax.annotate('', xy=(1.9, y_target), xytext=(0.1, x),
                    arrowprops=dict(arrowstyle='->', color=colors[s],
                                   alpha=0.3, lw=0.8))

    ax.text(0, -0.8, "Experiences", ha='center', fontsize=11, fontweight='bold')
    ax.text(2, -0.8, "States", ha='center', fontsize=11, fontweight='bold')

    # Right: fiber sizes
    ax2 = axes[1]
    states = sorted(fibers.keys())
    sizes = [len(fibers[s]) for s in states]
    bars = ax2.bar(states, sizes, color=[colors[s] for s in states],
                   edgecolor='black', linewidth=1.2)

    # Pigeonhole bound line
    bound = len(domain) // m
    ax2.axhline(y=bound, color='red', linestyle='--', linewidth=2,
                label=f'Pigeonhole bound ⌊{len(domain)}/{m}⌋ = {bound}')

    ax2.set_xlabel("Memory State", fontsize=12)
    ax2.set_ylabel("Fiber Size (# experiences)", fontsize=12)
    ax2.set_title("Fiber Cardinality Bound", fontsize=14)
    ax2.legend(fontsize=11)
    ax2.set_xticks(states)

    for bar, size in zip(bars, sizes):
        ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                str(size), ha='center', va='bottom', fontsize=12, fontweight='bold')

    plt.tight_layout()
    plt.savefig("fiber_structure.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fiber_structure.png")


def plot_refinement_lattice():
    """Plot the refinement lattice of memory systems over Z/12Z."""
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.set_title("Refinement Lattice of Memory Systems over ℤ/12ℤ", fontsize=14)
    ax.axis('off')

    # Positions in the Hasse diagram
    positions = {
        'perfect\n(mod 12)': (4, 5),
        'mod 6': (2, 4),
        'mod 4': (6, 4),
        'mod 3': (1, 3),
        'mod 2': (5, 3),
        'trivial\n(mod 1)': (3, 1.5),
    }

    # Edges (Hasse diagram - only covering relations)
    edges = [
        ('perfect\n(mod 12)', 'mod 6'),
        ('perfect\n(mod 12)', 'mod 4'),
        ('mod 6', 'mod 3'),
        ('mod 6', 'mod 2'),
        ('mod 4', 'mod 2'),
        ('mod 3', 'trivial\n(mod 1)'),
        ('mod 2', 'trivial\n(mod 1)'),
    ]

    # Node info
    info = {
        'perfect\n(mod 12)': '12 states\n0 bits lost',
        'mod 6': '6 states\n1 bit lost',
        'mod 4': '4 states\n1.58 bits lost',
        'mod 3': '3 states\n2 bits lost',
        'mod 2': '2 states\n2.58 bits lost',
        'trivial\n(mod 1)': '1 state\n3.58 bits lost',
    }

    # Draw edges
    for a, b in edges:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], 'k-', linewidth=1.5, zorder=1)

    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.4, color='lightblue',
                           ec='navy', linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, name, ha='center', va='center',
               fontsize=9, fontweight='bold', zorder=3)
        ax.text(x, y - 0.65, info[name], ha='center', va='top',
               fontsize=7, color='gray', zorder=3)

    ax.set_xlim(-0.5, 8)
    ax.set_ylim(0.5, 6)
    ax.text(4, 0.8, "↑ finer (more states, less forgetting)", ha='center',
           fontsize=10, fontstyle='italic', color='navy')

    plt.savefig("refinement_lattice.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: refinement_lattice.png")


if __name__ == "__main__":
    plot_fiber_structure()
    plot_refinement_lattice()


#!/usr/bin/env python3
"""
Visualization: Idempotent Memory Compression

Shows how idempotent compression operators converge in one step,
mapping transient states to fixed points (the retract).
"""
import matplotlib.pyplot as plt
import numpy as np


def plot_idempotent_convergence():
    """Visualize idempotent compression on a 2D state space."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    np.random.seed(42)
    n_points = 50
    points = np.random.randn(n_points, 2) * 2

    # Idempotent compression: project onto nearest grid point (grid spacing 1)
    def compress(p):
        return np.round(p)

    compressed = np.array([compress(p) for p in points])
    # Verify idempotence
    double_compressed = np.array([compress(c) for c in compressed])
    assert np.allclose(compressed, double_compressed), "Not idempotent!"

    # Fixed points (points that don't move)
    fixed_mask = np.all(np.abs(points - compressed) < 1e-10, axis=1)

    # Plot 1: Original states with compression arrows
    ax = axes[0]
    ax.set_title("Step 1: Original States", fontsize=13)
    ax.scatter(points[~fixed_mask, 0], points[~fixed_mask, 1],
              c='salmon', s=40, label='Transient', zorder=3, edgecolors='darkred')
    ax.scatter(points[fixed_mask, 0], points[fixed_mask, 1],
              c='limegreen', s=60, marker='s', label='Fixed points', zorder=3,
              edgecolors='darkgreen')
    ax.legend(fontsize=9)
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Plot 2: Compression arrows
    ax = axes[1]
    ax.set_title("Step 2: Apply Compression r", fontsize=13)
    for i in range(n_points):
        if not fixed_mask[i]:
            dx = compressed[i, 0] - points[i, 0]
            dy = compressed[i, 1] - points[i, 1]
            ax.annotate('', xy=compressed[i], xytext=points[i],
                       arrowprops=dict(arrowstyle='->', color='blue', alpha=0.4))
    ax.scatter(compressed[:, 0], compressed[:, 1],
              c='limegreen', s=60, marker='s', label='After r(x)', zorder=3,
              edgecolors='darkgreen')
    ax.scatter(points[~fixed_mask, 0], points[~fixed_mask, 1],
              c='salmon', s=20, alpha=0.5, zorder=2)
    ax.legend(fontsize=9)
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Plot 3: Idempotence - second application does nothing
    ax = axes[2]
    ax.set_title("Step 3: Apply r Again (r∘r = r)", fontsize=13)
    ax.scatter(compressed[:, 0], compressed[:, 1],
              c='limegreen', s=60, marker='s', zorder=3, edgecolors='darkgreen')
    ax.scatter(double_compressed[:, 0], double_compressed[:, 1],
              c='gold', s=120, marker='*', alpha=0.7, zorder=2,
              label='r(r(x)) = r(x) ✓')
    ax.legend(fontsize=9)
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.text(0, -4.5, "Idempotent: no change!", ha='center',
           fontsize=12, fontweight='bold', color='darkgreen')

    plt.suptitle("Idempotent Memory Compression: r ∘ r = r",
                fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig("idempotent_compression.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: idempotent_compression.png")


def plot_tropical_convergence():
    """Show convergence of tropical (min-plus) matrix iteration."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # 3x3 tropical matrix (weights of a directed graph)
    W = np.array([[0, 2, 5],
                  [3, 0, 1],
                  [1, 4, 0]], dtype=float)

    def tropical_step(W, x):
        n = len(x)
        return np.array([min(W[i, j] + x[j] for j in range(n)) for i in range(n)])

    # Initial state
    x0 = np.array([10.0, 20.0, 30.0])

    # Iterate
    trajectory = [x0.copy()]
    x = x0.copy()
    for _ in range(15):
        x = tropical_step(W, x)
        trajectory.append(x.copy())

    trajectory = np.array(trajectory)

    # Plot
    colors = ['#e74c3c', '#2ecc71', '#3498db']
    labels = ['State 1', 'State 2', 'State 3']
    for i in range(3):
        ax.plot(trajectory[:, i], 'o-', color=colors[i], label=labels[i],
               linewidth=2, markersize=6)

    # Mark convergence point
    converge_step = None
    for t in range(1, len(trajectory)):
        if np.allclose(trajectory[t], trajectory[t-1], atol=1e-10):
            converge_step = t
            break

    if converge_step:
        ax.axvline(x=converge_step, color='gray', linestyle='--', alpha=0.7)
        ax.text(converge_step + 0.2, max(trajectory[0]) * 0.9,
               f'Converged\n(step {converge_step})',
               fontsize=10, color='gray')

    ax.set_xlabel("Iteration", fontsize=12)
    ax.set_ylabel("State Value", fontsize=12)
    ax.set_title("Tropical (Min-Plus) Memory Iteration Convergence", fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("tropical_convergence.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_convergence.png")


if __name__ == "__main__":
    plot_idempotent_convergence()
    plot_tropical_convergence()
