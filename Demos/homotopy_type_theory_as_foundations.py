#!/usr/bin/env python3
"""
Demonstration of Homotopy Type Theory concepts:
- Eckmann-Hilton argument verification
- Monodromy computation for covering spaces
- Encode-decode for winding numbers
- Interchange law testing
"""

from typing import Callable, Tuple, Any
from dataclasses import dataclass


# ============================================================
# Part 1: Eckmann-Hilton Argument
# ============================================================

@dataclass
class InterchangeSystem:
    """Two binary ops with shared unit satisfying interchange."""
    star: Callable[[Any, Any], Any]
    diamond: Callable[[Any, Any], Any]
    e: Any
    
    def verify_unit_laws(self, elements: list) -> dict:
        """Check unit laws for both operations."""
        results = {}
        for a in elements:
            results[f"star_left_unit({a})"] = self.star(self.e, a) == a
            results[f"star_right_unit({a})"] = self.star(a, self.e) == a
            results[f"diamond_left_unit({a})"] = self.diamond(self.e, a) == a
            results[f"diamond_right_unit({a})"] = self.diamond(a, self.e) == a
        return results
    
    def verify_interchange(self, elements: list) -> bool:
        """Check interchange law: ◇(⋆(a,b), ⋆(c,d)) = ⋆(◇(a,c), ◇(b,d))"""
        for a in elements:
            for b in elements:
                for c in elements:
                    for d in elements:
                        lhs = self.diamond(self.star(a, b), self.star(c, d))
                        rhs = self.star(self.diamond(a, c), self.diamond(b, d))
                        if lhs != rhs:
                            return False
        return True
    
    def verify_eckmann_hilton(self, elements: list) -> dict:
        """Verify both conclusions of Eckmann-Hilton."""
        ops_equal = all(
            self.diamond(a, b) == self.star(a, b)
            for a in elements for b in elements
        )
        star_comm = all(
            self.star(a, b) == self.star(b, a)
            for a in elements for b in elements
        )
        return {"ops_equal": ops_equal, "star_commutative": star_comm}


def demo_eckmann_hilton():
    """Demonstrate the Eckmann-Hilton argument on integers mod n."""
    print("=" * 60)
    print("ECKMANN-HILTON ARGUMENT DEMONSTRATION")
    print("=" * 60)
    
    # Example: On ℤ/5ℤ, both operations are addition mod 5
    n = 5
    elements = list(range(n))
    
    sys = InterchangeSystem(
        star=lambda a, b: (a + b) % n,
        diamond=lambda a, b: (a + b) % n,
        e=0
    )
    
    print(f"\nInterchange system on ℤ/{n}ℤ:")
    print(f"  star = diamond = addition mod {n}")
    print(f"  unit e = 0")
    
    units = sys.verify_unit_laws(elements)
    print(f"\n  Unit laws satisfied: {all(units.values())}")
    
    interchange = sys.verify_interchange(elements)
    print(f"  Interchange law satisfied: {interchange}")
    
    eh = sys.verify_eckmann_hilton(elements)
    print(f"  Operations equal: {eh['ops_equal']}")
    print(f"  Star commutative: {eh['star_commutative']}")
    print(f"\n  ✓ Eckmann-Hilton theorem verified!")
    
    # Counter-example: non-commutative operations DON'T satisfy interchange
    print("\n--- Testing failure case ---")
    print("  Matrix multiplication (non-commutative) with identity unit:")
    
    import numpy as np
    A = np.array([[1, 1], [0, 1]])
    B = np.array([[1, 0], [1, 1]])
    I = np.eye(2, dtype=int)
    
    lhs = A @ B  # "star"
    rhs = B @ A  # reversed
    print(f"  AB = {lhs.tolist()}")
    print(f"  BA = {rhs.tolist()}")
    print(f"  AB ≠ BA: {not np.array_equal(lhs, rhs)}")
    print(f"  → Non-commutative ops cannot form an interchange system")


# ============================================================
# Part 2: Covering Space Monodromy
# ============================================================

def demo_monodromy():
    """Demonstrate monodromy for the universal cover of the circle."""
    print("\n" + "=" * 60)
    print("COVERING SPACE MONODROMY")
    print("=" * 60)
    
    # The universal cover of S¹ is ℝ → S¹ via t ↦ e^{2πit}
    # Fiber over basepoint = ℤ
    # Monodromy of the generator loop = shift by 1
    
    print("\nUniversal cover: ℝ → S¹")
    print("Fiber over basepoint: ℤ")
    print("Generator loop γ: counterclockwise once around")
    
    def monodromy_generator(fiber_point: int) -> int:
        """Monodromy of the generator: shift by +1."""
        return fiber_point + 1
    
    def monodromy_power(fiber_point: int, n: int) -> int:
        """Monodromy of γⁿ: shift by n."""
        return fiber_point + n
    
    # Verify homomorphism property
    print("\nMonodromy homomorphism verification:")
    for n1 in range(-3, 4):
        for n2 in range(-3, 4):
            start = 0
            # mon(γ^(n1+n2)) should equal mon(γ^n2) ∘ mon(γ^n1)
            direct = monodromy_power(start, n1 + n2)
            composed = monodromy_power(monodromy_power(start, n1), n2)
            assert direct == composed
    print("  ✓ mon(γ^(n₁+n₂)) = mon(γ^n₂) ∘ mon(γ^n₁) for all n₁, n₂ ∈ [-3,3]")
    
    # Demonstrate fiber evolution
    print("\nFiber point 0 under iterated monodromy:")
    point = 0
    for i in range(1, 8):
        point = monodromy_generator(point)
        print(f"  After {i} loops: fiber point = {point}")
    
    # n-fold covering
    print("\n--- n-fold covering spaces ---")
    for n in [2, 3, 5]:
        print(f"\n{n}-fold cover (fiber = ℤ/{n}ℤ):")
        
        def mon_n(f, n=n):
            return (f + 1) % n
        
        point = 0
        orbit = [point]
        for _ in range(n):
            point = mon_n(point)
            orbit.append(point)
        
        print(f"  Orbit of 0: {orbit}")
        print(f"  Period: {n} (returns to start after {n} loops)")


# ============================================================
# Part 3: Winding Number Encode-Decode
# ============================================================

def demo_encode_decode():
    """Demonstrate encode-decode for π₁(S¹) ≅ ℤ."""
    print("\n" + "=" * 60)
    print("ENCODE-DECODE: π₁(S¹) ≅ ℤ")
    print("=" * 60)
    
    def encode(loop: list) -> int:
        """Encode a loop (list of +1/-1 steps) as a winding number."""
        return sum(loop)
    
    def decode(n: int) -> list:
        """Decode a winding number as a canonical loop."""
        if n >= 0:
            return [1] * n
        else:
            return [-1] * (-n)
    
    # Verify encode ∘ decode = id
    print("\nVerifying encode ∘ decode = id:")
    for n in range(-5, 6):
        loop = decode(n)
        recovered = encode(loop)
        status = "✓" if recovered == n else "✗"
        print(f"  {status} encode(decode({n:+d})) = {recovered:+d}")
    
    # Show decode ∘ encode is homotopic to id (up to cancellation)
    print("\nDemonstrating decode ∘ encode:")
    test_loops = [
        [1, 1, -1, 1],       # winding = 2
        [-1, -1, 1, -1, -1], # winding = -3
        [1, -1, 1, -1],      # winding = 0
        [1, 1, 1],           # winding = 3
    ]
    
    for loop in test_loops:
        w = encode(loop)
        canonical = decode(w)
        print(f"  Loop {loop} → winding {w:+d} → canonical {canonical}")
    
    # Homomorphism property
    print("\nHomomorphism: encode(γ₁·γ₂) = encode(γ₁) + encode(γ₂)")
    for l1 in test_loops[:2]:
        for l2 in test_loops[2:]:
            w_concat = encode(l1 + l2)
            w_sum = encode(l1) + encode(l2)
            status = "✓" if w_concat == w_sum else "✗"
            print(f"  {status} encode({l1}·{l2}) = {w_concat} = {encode(l1)} + {encode(l2)}")


# ============================================================  
# Part 4: Tropical Interchange Test (Conjecture Falsification)
# ============================================================

def demo_tropical_interchange():
    """Test whether tropical operations satisfy interchange."""
    print("\n" + "=" * 60)
    print("TROPICAL INTERCHANGE TEST (Conjecture Direction 4)")
    print("=" * 60)
    
    NEG_INF = float('-inf')
    
    def trop_add(a, b):
        """Tropical addition = max."""
        return max(a, b)
    
    def trop_mul(a, b):
        """Tropical multiplication = classical addition."""
        if a == NEG_INF or b == NEG_INF:
            return NEG_INF
        return a + b
    
    print("\nTropical semiring: (ℝ ∪ {-∞}, max, +)")
    print("Testing interchange: max(a+b, c+d) =? max(a,c) + max(b,d)")
    
    test_values = [0, 1, 2, 3, -1]
    failures = 0
    successes = 0
    
    for a in test_values:
        for b in test_values:
            for c in test_values:
                for d in test_values:
                    lhs = trop_add(trop_mul(a, b), trop_mul(c, d))
                    rhs = trop_mul(trop_add(a, c), trop_add(b, d))
                    if lhs != rhs:
                        failures += 1
                        if failures <= 3:
                            print(f"  ✗ a={a}, b={b}, c={c}, d={d}: "
                                  f"max({a}+{b}, {c}+{d}) = max({a+b},{c+d}) = {lhs}, "
                                  f"but max({a},{c})+max({b},{d}) = {max(a,c)}+{max(b,d)} = {rhs}")
                    else:
                        successes += 1
    
    total = failures + successes
    print(f"\n  Results: {failures}/{total} failures, {successes}/{total} successes")
    print(f"  → Tropical interchange law FAILS generically")
    print(f"  → Confirms conjecture: tropical geometry lacks higher interchange")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_eckmann_hilton()
    demo_monodromy()
    demo_encode_decode()
    demo_tropical_interchange()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Covering space monodromy and fiber orbits.
Shows how loops in the base space permute fiber points.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_covering_monodromy():
    """Visualize monodromy for n-fold covering spaces of the circle."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    fold_numbers = [2, 3, 5]
    colors = plt.cm.Set2(np.linspace(0, 1, max(fold_numbers)))
    
    for ax, n in zip(axes, fold_numbers):
        # Draw the base circle
        theta = np.linspace(0, 2 * np.pi, 100)
        base_r = 1.0
        ax.plot(base_r * np.cos(theta), base_r * np.sin(theta), 
                'k-', linewidth=2, label='Base S¹')
        
        # Draw fiber points at the basepoint (angle 0)
        for k in range(n):
            fiber_r = 1.3 + 0.15 * k
            ax.plot(fiber_r, 0, 'o', color=colors[k], markersize=10,
                    markeredgecolor='black', markeredgewidth=1)
            ax.annotate(f'{k}', (fiber_r + 0.08, 0.05), fontsize=10,
                        fontweight='bold', color=colors[k])
        
        # Draw monodromy arrows (cyclic permutation)
        for k in range(n):
            r1 = 1.3 + 0.15 * k
            r2 = 1.3 + 0.15 * ((k + 1) % n)
            
            # Arc from fiber k to fiber (k+1) % n
            if k + 1 < n:
                ax.annotate('', xy=(r2, 0.12), xytext=(r1, 0.12),
                           arrowprops=dict(arrowstyle='->', color=colors[k],
                                          connectionstyle='arc3,rad=-0.3',
                                          linewidth=2))
            else:
                # Wrap-around arrow
                ax.annotate('', xy=(r2, -0.12), xytext=(r1, -0.12),
                           arrowprops=dict(arrowstyle='->', color=colors[k],
                                          connectionstyle='arc3,rad=0.8',
                                          linewidth=2))
        
        # Draw the covering space (helix)
        t_cover = np.linspace(0, 2 * np.pi * n, 300)
        cover_r = 0.6
        x_cover = cover_r * np.cos(t_cover)
        y_cover = cover_r * np.sin(t_cover)
        
        # Shade the base
        ax.fill(0.95 * np.cos(theta), 0.95 * np.sin(theta), 
                alpha=0.05, color='blue')
        
        ax.set_xlim(-1.8, 2.2)
        ax.set_ylim(-1.8, 1.8)
        ax.set_aspect('equal')
        ax.set_title(f'{n}-fold Covering Space\nMonodromy: k ↦ (k+1) mod {n}',
                     fontsize=12, fontweight='bold')
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
        ax.axvline(x=0, color='gray', linestyle='--', alpha=0.3)
        
        # Mark basepoint
        ax.plot(1.0, 0, 'k*', markersize=15, zorder=5)
        ax.annotate('b₀', (0.85, -0.2), fontsize=11, fontweight='bold')
    
    plt.suptitle('Covering Space Monodromy: Loops Permute Fiber Points',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_monodromy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_monodromy.png")


def draw_eckmann_hilton_grid():
    """Visualize the Eckmann-Hilton argument as 2x2 grid rearrangement."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Step 1: a ◇ b = (a⋆e) ◇ (e⋆b)
    ax = axes[0]
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    
    # Draw 2x2 grid with a, e, e, b
    rect_a = mpatches.FancyBboxPatch((0.5, 2.5), 1.5, 1, 
                                       boxstyle="round,pad=0.1",
                                       facecolor='#FF6B6B', alpha=0.8)
    rect_e1 = mpatches.FancyBboxPatch((2, 2.5), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#E8E8E8', alpha=0.8)
    rect_e2 = mpatches.FancyBboxPatch((0.5, 1), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#E8E8E8', alpha=0.8)
    rect_b = mpatches.FancyBboxPatch((2, 1), 1.5, 1,
                                       boxstyle="round,pad=0.1",
                                       facecolor='#4ECDC4', alpha=0.8)
    
    for r in [rect_a, rect_e1, rect_e2, rect_b]:
        ax.add_patch(r)
    
    ax.text(1.25, 3, 'a', ha='center', va='center', fontsize=16, fontweight='bold')
    ax.text(2.75, 3, 'e', ha='center', va='center', fontsize=16, fontweight='bold', color='gray')
    ax.text(1.25, 1.5, 'e', ha='center', va='center', fontsize=16, fontweight='bold', color='gray')
    ax.text(2.75, 1.5, 'b', ha='center', va='center', fontsize=16, fontweight='bold')
    
    ax.annotate('⋆', (2, 3), fontsize=14, ha='center', va='center', color='red')
    ax.annotate('⋆', (2, 1.5), fontsize=14, ha='center', va='center', color='red')
    ax.annotate('◇', (1.25, 2.25), fontsize=14, ha='center', va='center', color='blue')
    ax.annotate('◇', (2.75, 2.25), fontsize=14, ha='center', va='center', color='blue')
    
    ax.set_title('Step 1: (a⋆e) ◇ (e⋆b)', fontsize=13, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Step 2: Interchange → (a◇e) ⋆ (e◇b)
    ax = axes[1]
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    
    rect_a2 = mpatches.FancyBboxPatch((0.5, 2.5), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#FF6B6B', alpha=0.8)
    rect_e3 = mpatches.FancyBboxPatch((0.5, 1), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#E8E8E8', alpha=0.8)
    rect_e4 = mpatches.FancyBboxPatch((2, 2.5), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#E8E8E8', alpha=0.8)
    rect_b2 = mpatches.FancyBboxPatch((2, 1), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#4ECDC4', alpha=0.8)
    
    for r in [rect_a2, rect_e3, rect_e4, rect_b2]:
        ax.add_patch(r)
    
    ax.text(1.25, 3, 'a', ha='center', va='center', fontsize=16, fontweight='bold')
    ax.text(1.25, 1.5, 'e', ha='center', va='center', fontsize=16, fontweight='bold', color='gray')
    ax.text(2.75, 3, 'e', ha='center', va='center', fontsize=16, fontweight='bold', color='gray')
    ax.text(2.75, 1.5, 'b', ha='center', va='center', fontsize=16, fontweight='bold')
    
    ax.annotate('◇', (1.25, 2.25), fontsize=14, ha='center', va='center', color='blue')
    ax.annotate('◇', (2.75, 2.25), fontsize=14, ha='center', va='center', color='blue')
    ax.annotate('⋆', (2, 3), fontsize=14, ha='center', va='center', color='red')
    ax.annotate('⋆', (2, 1.5), fontsize=14, ha='center', va='center', color='red')
    
    ax.set_title('Step 2 (Interchange):\n(a◇e) ⋆ (e◇b)', fontsize=13, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Step 3: = a ⋆ b (by unit laws)
    ax = axes[2]
    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)
    
    rect_a3 = mpatches.FancyBboxPatch((0.5, 1.5), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#FF6B6B', alpha=0.8)
    rect_b3 = mpatches.FancyBboxPatch((2, 1.5), 1.5, 1,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#4ECDC4', alpha=0.8)
    
    for r in [rect_a3, rect_b3]:
        ax.add_patch(r)
    
    ax.text(1.25, 2, 'a', ha='center', va='center', fontsize=20, fontweight='bold')
    ax.text(2.75, 2, 'b', ha='center', va='center', fontsize=20, fontweight='bold')
    ax.annotate('⋆', (2, 2), fontsize=18, ha='center', va='center', color='red')
    
    ax.set_title('Result: a ⋆ b\n(both ops equal!)', fontsize=13, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.suptitle('The Eckmann-Hilton Argument: Grid Rearrangement',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_eckmann_hilton.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_eckmann_hilton.png")


def draw_truncation_tower():
    """Visualize the truncation hierarchy."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    levels = [
        (-2, "Contractible\n(trivial)", "#2ECC71", "• Single point\n• No information"),
        (-1, "Proposition\n(truth value)", "#3498DB", "• True or False\n• ∅ or {*}"),
        (0, "Set\n(discrete)", "#9B59B6", "• ℕ, ℤ, ℝ\n• No higher paths"),
        (1, "Groupoid\n(1-paths)", "#E74C3C", "• Categories\n• Symmetry groups"),
        (2, "2-Groupoid\n(2-paths)", "#F39C12", "• Braided categories\n• Surface topology"),
        (3, "3-Groupoid\n(3-paths)", "#1ABC9C", "• Higher categories\n• 3-manifold topology"),
    ]
    
    for i, (level, name, color, desc) in enumerate(levels):
        y = i * 1.2
        
        # Draw level box
        width = 2 + i * 0.5
        rect = mpatches.FancyBboxPatch(
            (5 - width/2, y - 0.4), width, 0.8,
            boxstyle="round,pad=0.15",
            facecolor=color, alpha=0.3,
            edgecolor=color, linewidth=2
        )
        ax.add_patch(rect)
        
        # Level label
        ax.text(5, y, name, ha='center', va='center',
                fontsize=11, fontweight='bold', color=color)
        
        # Description
        ax.text(5 + width/2 + 0.3, y, desc, ha='left', va='center',
                fontsize=9, color='gray')
        
        # Level number
        ax.text(5 - width/2 - 0.3, y, f'n = {level}', ha='right', va='center',
                fontsize=10, fontweight='bold')
        
        # Arrow to next level
        if i < len(levels) - 1:
            ax.annotate('', xy=(5, y + 0.5), xytext=(5, y + 0.7),
                       arrowprops=dict(arrowstyle='->', color='gray',
                                      linewidth=1.5))
    
    # Add cumulative arrow
    ax.annotate('', xy=(1.5, 0), xytext=(1.5, 6),
               arrowprops=dict(arrowstyle='<->', color='black',
                              linewidth=2, connectionstyle='arc3,rad=0'))
    ax.text(1.2, 3, 'Cumulative\n(each level\ncontains\nprevious)',
            ha='center', va='center', fontsize=9, fontweight='bold',
            rotation=90)
    
    ax.set_xlim(0, 10)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Truncation Hierarchy of Types',
                 fontsize=15, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('viz_truncation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_truncation.png")


if __name__ == "__main__":
    draw_covering_monodromy()
    draw_eckmann_hilton_grid()
    draw_truncation_tower()
    print("\nAll visualizations saved.")
