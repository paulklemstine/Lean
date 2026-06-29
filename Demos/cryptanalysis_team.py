#!/usr/bin/env python3
"""
Geometric Cryptanalysis: Applications

Real-world applications of the bounded-box collision theorem:
1. Lattice-based cryptography parameter analysis
2. Subset-sum / knapsack attack thresholds
3. Modular knapsack collision attacks
4. Hidden number problem instances
"""

import math
import itertools
from collections import defaultdict
from algorithms import (
    collision_threshold, box_cardinality, find_collision,
    extract_short_kernel_vector, find_sis_witness, estimate_security_level
)


def application_sis_parameter_analysis():
    """
    Application 1: SIS Parameter Analysis for Lattice Signatures
    
    Analyze how the bounded-box collision theorem constrains parameter
    choices for SIS-based lattice signatures (e.g., Dilithium-like schemes).
    
    The security of SIS(n, m, q, β) relies on the hardness of finding
    z ∈ ℤ^m with ||z||_∞ ≤ β and Hz ≡ 0 (mod q).
    
    Our theorem says: if (2β+1)^m > q^n, such z must exist.
    So security requires (2β+1)^m ≤ q^n, i.e., m·log(2β+1) ≤ n·log(q).
    """
    print("=" * 70)
    print("APPLICATION 1: SIS Parameter Security Analysis")
    print("=" * 70)
    
    print("\nFor SIS(n, m, q, β): security requires (2β+1)^m ≤ q^n")
    print("i.e., m ≤ n · log(q) / log(2β+1)")
    print()
    
    # Analyze NIST-like parameters
    params = [
        ("Toy", 16, 32, 7681, 4),
        ("Small", 64, 128, 12289, 8),
        ("Medium", 256, 512, 8380417, 2**17),
        ("Dilithium-like", 256, 768, 8380417, 2**19),
    ]
    
    print(f"{'Name':<20} {'n':>6} {'m':>6} {'q':>12} {'β':>10} {'Max m':>8} {'Secure?':>10}")
    print("-" * 72)
    
    for name, n, m, q, beta in params:
        # Maximum m before collision is guaranteed
        max_m = n * math.log(q) / math.log(2 * beta + 1)
        secure = m <= max_m
        print(f"{name:<20} {n:>6} {m:>6} {q:>12} {beta:>10} {max_m:>8.1f} {'✓ Yes' if secure else '✗ NO':>10}")
    
    print("\nInterpretation: If m > max_m, the theorem guarantees a short SIS")
    print("solution exists — the scheme is broken by counting alone.")


def application_subset_sum():
    """
    Application 2: Subset-Sum / Knapsack Attack Analysis
    
    The subset-sum problem: given a₁,...,aₙ ∈ ℤ_q and target t,
    find x ∈ {0,1}^n with ∑ aᵢxᵢ ≡ t (mod q).
    
    Our theorem with B=0 to B=1 gives: if 2^n > q (using {0,1}^n ⊂ [-1,1]^n),
    then a modular collision exists among subset sums.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Subset-Sum Attack Thresholds")
    print("=" * 70)
    
    print("\nSubset-sum over ℤ_q: need 2^n > q for guaranteed collision")
    print("(Actually (2·1+1)^n = 3^n > q suffices for [-1,1]^n box)")
    print()
    
    # Small example
    n, q = 5, 20
    a = [7, 13, 3, 19, 11]
    
    print(f"Example: n={n}, q={q}")
    print(f"Weights: a = {a}")
    print(f"Box [-1,1]^{n} size: 3^{n} = {3**n}")
    print(f"Condition: {3**n} > {q}: {'✓' if 3**n > q else '✗'}")
    
    # Find collision
    result = find_collision(a, q, 1)
    if result:
        inner_z = sum(ai * zi for ai, zi in zip(a, result.z))
        print(f"\nCollision: x={result.x}, y={result.y}")
        print(f"Difference z = {result.z}")
        print(f"⟨a,z⟩ = {inner_z} ≡ {inner_z % q} (mod {q})")
    
    # Density analysis
    print("\n\nDensity analysis: d = n / log₂(max aᵢ)")
    print("Low density (d < 1): lattice attacks work well")
    print("High density (d > 1): our counting bound is tighter")
    print()
    print(f"{'n':>4} {'log₂(q)':>8} {'d = n/log₂(q)':>14} {'3^n':>12} {'> q?':>6}")
    print("-" * 48)
    for n in [8, 16, 32, 64, 128]:
        for log_q in [8, 16, 32]:
            q = 2 ** log_q
            density = n / log_q
            box = 3 ** n
            if density > 0.5 and density < 3:
                print(f"{n:>4} {log_q:>8} {density:>14.2f} {box:>12} {'✓' if box > q else '':>6}")


def application_hidden_number():
    """
    Application 3: Hidden Number Problem
    
    The Hidden Number Problem (HNP): given known multipliers tᵢ ∈ ℤ_q
    and approximate values uᵢ ≈ t_i · s (mod q) with |error| ≤ B,
    recover the secret s.
    
    This reduces to finding a short vector in a specific lattice.
    Our theorem quantifies when the error bound B is small enough
    that collisions in the approximation force a unique solution.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Hidden Number Problem Analysis")
    print("=" * 70)
    
    # Small HNP instance
    q = 101
    s = 42  # secret
    n = 5
    
    import random
    random.seed(42)
    
    t = [random.randint(1, q - 1) for _ in range(n)]
    B = 5  # error bound
    
    # Generate noisy samples
    errors = [random.randint(-B, B) for _ in range(n)]
    u = [(ti * s + ei) % q for ti, ei in zip(t, errors)]
    
    print(f"\nHNP instance: q={q}, n={n}, B={B}")
    print(f"Secret s = {s}")
    print(f"Multipliers t = {t}")
    print(f"Approximate values u = {u}")
    print(f"Errors (unknown): e = {errors}")
    
    # The lattice approach: find short z with ∑ t_i z_i ≡ 0 (mod q)
    print(f"\nCollision threshold: need (2B+1)^n = {(2*B+1)**n} > {q}")
    print(f"Condition satisfied: {(2*B+1)**n > q}")
    
    kv = extract_short_kernel_vector(t, q, B)
    if kv:
        print(f"\nKernel vector found: z = {kv.z}")
        print(f"‖z‖_∞ = {kv.sup_norm} ≤ 2B = {2*B}")
        print(f"⟨t,z⟩ = {kv.inner_product} ≡ {kv.inner_product % q} (mod {q})")


def application_lattice_security_landscape():
    """
    Application 4: Security Landscape Visualization Data
    
    Generate data showing how the collision threshold varies with
    dimension n and modulus q, creating a "security landscape" for
    lattice-based constructions.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Lattice Security Landscape")
    print("=" * 70)
    
    print("\nMinimum B for collision existence (attack threshold):")
    print(f"\n{'':>12}", end="")
    dims = [4, 8, 16, 32, 64, 128, 256]
    for n in dims:
        print(f"{'n='+str(n):>8}", end="")
    print()
    print("-" * (12 + 8 * len(dims)))
    
    for log_q in [8, 10, 12, 14, 16, 20, 24, 32]:
        q = 2 ** log_q
        print(f"{'q=2^'+str(log_q):>12}", end="")
        for n in dims:
            B = collision_threshold(n, q)
            print(f"{B:>8}", end="")
        print()
    
    print("\nInterpretation: smaller B = easier to find short vectors = less secure")
    print("The table shows minimum attack box radius for guaranteed collision.")
    
    # Security level estimates for standard parameters
    print("\n\nSecurity level estimates (bits):")
    print(f"{'n':>6} {'log₂(q)':>8} {'B_threshold':>12} {'Security':>10}")
    print("-" * 40)
    for n, log_q in [(128, 12), (256, 13), (512, 14), (1024, 15)]:
        q = 2 ** log_q
        result = estimate_security_level(n, q, 1.0)
        print(f"{n:>6} {log_q:>8} {result['threshold_B']:>12} {result['security_bits']:>10.1f}")


if __name__ == "__main__":
    application_sis_parameter_analysis()
    application_subset_sum()
    application_hidden_number()
    application_lattice_security_landscape()
    
    print("\n" + "=" * 70)
    print("All applications completed.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Geometric Cryptanalysis: Demonstrations

Concrete numerical examples showing the bounded-box collision theorem
and short kernel vector extraction in action.
"""

import itertools
import random
from collections import defaultdict


def bounded_box(n: int, B: int) -> list[tuple[int, ...]]:
    """Generate all integer vectors in [-B, B]^n."""
    return list(itertools.product(range(-B, B + 1), repeat=n))


def mod_linear_form(a: list[int], x: tuple[int, ...], q: int) -> int:
    """Compute sum(a_i * x_i) mod q."""
    return sum(ai * xi for ai, xi in zip(a, x)) % q


def find_collision(a: list[int], q: int, B: int) -> tuple:
    """
    Find a collision in the modular linear form over the bounded box.
    Returns (x, y, z) where x != y, f(x) = f(y), z = x - y.
    """
    n = len(a)
    box = bounded_box(n, B)
    
    # Hash table: residue -> list of vectors mapping to it
    residue_map: dict[int, list[tuple[int, ...]]] = defaultdict(list)
    
    for x in box:
        r = mod_linear_form(a, x, q)
        if residue_map[r]:
            y = residue_map[r][0]
            z = tuple(xi - yi for xi, yi in zip(x, y))
            return x, y, z
        residue_map[r].append(x)
    
    return None  # No collision found (shouldn't happen if (2B+1)^n > q)


def demo_basic_collision():
    """Demo 1: Basic collision in 2D with small parameters."""
    print("=" * 70)
    print("DEMO 1: Basic Bounded-Box Collision")
    print("=" * 70)
    
    n, q, B = 2, 5, 2
    a = [3, 7]
    
    box_size = (2 * B + 1) ** n
    print(f"\nParameters: n={n}, q={q}, B={B}")
    print(f"Linear form: f(x) = {a[0]}*x₁ + {a[1]}*x₂ (mod {q})")
    print(f"Box size: (2·{B}+1)^{n} = {box_size}")
    print(f"Modulus: q = {q}")
    print(f"Condition: {box_size} > {q} ✓" if box_size > q else f"Condition: {box_size} ≤ {q} ✗")
    
    result = find_collision(a, q, B)
    if result:
        x, y, z = result
        fx = mod_linear_form(a, x, q)
        fy = mod_linear_form(a, y, q)
        inner_z = sum(ai * zi for ai, zi in zip(a, z))
        
        print(f"\nCollision found!")
        print(f"  x = {x}, f(x) = {fx}")
        print(f"  y = {y}, f(y) = {fy}")
        print(f"  z = x - y = {z}")
        print(f"  |z_i| ≤ 2B = {2*B}: {all(abs(zi) <= 2*B for zi in z)}")
        print(f"  ⟨a, z⟩ = {inner_z} ≡ {inner_z % q} (mod {q})")
        print(f"  Kernel vector: {inner_z % q == 0} ✓" if inner_z % q == 0 else "  NOT kernel ✗")


def demo_higher_dimension():
    """Demo 2: Higher-dimensional collision."""
    print("\n" + "=" * 70)
    print("DEMO 2: Higher-Dimensional Collision (n=4)")
    print("=" * 70)
    
    n, q, B = 4, 100, 3
    a = [17, 31, 53, 79]
    
    box_size = (2 * B + 1) ** n
    print(f"\nParameters: n={n}, q={q}, B={B}")
    print(f"Linear form: f(x) = {' + '.join(f'{ai}·x_{i+1}' for i, ai in enumerate(a))} (mod {q})")
    print(f"Box size: (2·{B}+1)^{n} = {box_size}")
    print(f"Modulus: q = {q}")
    print(f"Condition: {box_size} > {q} ✓" if box_size > q else f"Condition FAILS")
    
    result = find_collision(a, q, B)
    if result:
        x, y, z = result
        fx = mod_linear_form(a, x, q)
        inner_z = sum(ai * zi for ai, zi in zip(a, z))
        sup_norm = max(abs(zi) for zi in z)
        
        print(f"\nCollision found!")
        print(f"  x = {x}")
        print(f"  y = {y}")
        print(f"  z = x - y = {z}")
        print(f"  ‖z‖_∞ = {sup_norm} ≤ 2B = {2*B}: {'✓' if sup_norm <= 2*B else '✗'}")
        print(f"  ⟨a, z⟩ = {inner_z} ≡ {inner_z % q} (mod {q}): {'✓' if inner_z % q == 0 else '✗'}")


def demo_collision_statistics():
    """Demo 3: Statistics on collision counts as box grows."""
    print("\n" + "=" * 70)
    print("DEMO 3: Collision Count vs Box Size")
    print("=" * 70)
    
    n, q = 2, 17
    a = [5, 11]
    
    print(f"\nFixed: n={n}, q={q}, a={a}")
    print(f"{'B':>4} {'Box Size':>10} {'Ratio':>8} {'Collisions':>12} {'Min ‖z‖_∞':>12}")
    print("-" * 50)
    
    for B in range(1, 8):
        box = bounded_box(n, B)
        box_size = len(box)
        
        # Count all collisions and find shortest kernel vector
        residue_map = defaultdict(list)
        for x in box:
            r = mod_linear_form(a, x, q)
            residue_map[r].append(x)
        
        collision_count = 0
        min_norm = float('inf')
        for vectors in residue_map.values():
            k = len(vectors)
            collision_count += k * (k - 1) // 2
            for i in range(len(vectors)):
                for j in range(i + 1, len(vectors)):
                    z = tuple(vectors[i][c] - vectors[j][c] for c in range(n))
                    if any(zi != 0 for zi in z):
                        norm = max(abs(zi) for zi in z)
                        min_norm = min(min_norm, norm)
        
        ratio = box_size / q
        min_norm_str = str(min_norm) if min_norm < float('inf') else "—"
        print(f"{B:>4} {box_size:>10} {ratio:>8.1f} {collision_count:>12} {min_norm_str:>12}")


def demo_matrix_sis():
    """Demo 4: Matrix SIS witness extraction."""
    print("\n" + "=" * 70)
    print("DEMO 4: Matrix SIS Witness (m=2, n=4)")
    print("=" * 70)
    
    m, n, q, B = 2, 4, 7, 2
    A = [[3, 1, 4, 1], [5, 9, 2, 6]]
    
    box_size = (2 * B + 1) ** n
    syndrome_space = q ** m
    
    print(f"\nParameters: m={m}, n={n}, q={q}, B={B}")
    print(f"Matrix A:")
    for row in A:
        print(f"  {row}")
    print(f"Box size: (2·{B}+1)^{n} = {box_size}")
    print(f"Syndrome space: {q}^{m} = {syndrome_space}")
    print(f"Condition: {box_size} > {syndrome_space} {'✓' if box_size > syndrome_space else '✗'}")
    
    # Find collision by syndrome
    box = bounded_box(n, B)
    syndrome_map = defaultdict(list)
    
    for x in box:
        syndrome = tuple(
            sum(A[j][i] * x[i] for i in range(n)) % q
            for j in range(m)
        )
        if syndrome_map[syndrome]:
            y = syndrome_map[syndrome][0]
            z = tuple(xi - yi for xi, yi in zip(x, y))
            
            print(f"\nSIS witness found!")
            print(f"  x = {x}")
            print(f"  y = {y}")
            print(f"  z = x - y = {z}")
            print(f"  ‖z‖_∞ = {max(abs(zi) for zi in z)} ≤ 2B = {2*B}")
            
            for j in range(m):
                val = sum(A[j][i] * z[i] for i in range(n))
                print(f"  Row {j}: ⟨A[{j}], z⟩ = {val} ≡ {val % q} (mod {q})")
            break
        syndrome_map[syndrome].append(x)


def demo_threshold_behavior():
    """Demo 5: Phase transition at the collision threshold."""
    print("\n" + "=" * 70)
    print("DEMO 5: Phase Transition at Collision Threshold")
    print("=" * 70)
    
    n = 3
    a = [1, 1, 1]  # Simple sum
    
    print(f"\nFixed: n={n}, a={a}")
    print(f"Testing: does (2B+1)^n > q predict collision existence?")
    print(f"\n{'q':>6} {'B':>4} {'Box':>8} {'Box > q?':>10} {'Collision?':>12} {'Match?':>8}")
    print("-" * 52)
    
    for q in [10, 20, 50, 100, 200]:
        for B in range(1, 10):
            box_size = (2 * B + 1) ** n
            predicted = box_size > q
            
            # Actually check
            box = bounded_box(n, B)
            seen = set()
            found = False
            for x in box:
                r = mod_linear_form(a, x, q)
                if r in seen:
                    found = True
                    break
                seen.add(r)
            
            # Only print transition region
            if abs(box_size - q) < 2 * q:
                match = "✓" if predicted == found else "✗ MISMATCH"
                print(f"{q:>6} {B:>4} {box_size:>8} {'Yes' if predicted else 'No':>10} {'Yes' if found else 'No':>12} {match:>8}")


if __name__ == "__main__":
    demo_basic_collision()
    demo_higher_dimension()
    demo_collision_statistics()
    demo_matrix_sis()
    demo_threshold_behavior()
    
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Geometric Cryptanalysis: Visualizations

Generate publication-quality figures showing the key mathematical structures.
"""

import math
import itertools
import base64
import io
from collections import defaultdict

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_collision_2d():
    """
    Visualization 1: 2D collision in the bounded box.
    Shows vectors in [-B,B]^2 colored by their residue mod q.
    """
    n, q, B = 2, 7, 3
    a = [3, 5]
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Color map for residues
    colors = plt.cm.Set1(np.linspace(0, 1, q))
    
    # Plot all box vectors colored by residue
    for x1 in range(-B, B + 1):
        for x2 in range(-B, B + 1):
            r = (a[0] * x1 + a[1] * x2) % q
            ax.scatter(x1, x2, c=[colors[r]], s=80, zorder=3, edgecolors='black', linewidth=0.5)
    
    # Find and highlight a collision pair
    residue_map = defaultdict(list)
    collision_pair = None
    for x in itertools.product(range(-B, B + 1), repeat=2):
        r = (a[0] * x[0] + a[1] * x[1]) % q
        if residue_map[r] and collision_pair is None:
            collision_pair = (residue_map[r][0], x)
        residue_map[r].append(x)
    
    if collision_pair:
        x, y = collision_pair
        ax.scatter(*x, c='red', s=200, zorder=5, marker='*', edgecolors='black', linewidth=1.5)
        ax.scatter(*y, c='red', s=200, zorder=5, marker='*', edgecolors='black', linewidth=1.5)
        ax.annotate('', xy=y, xytext=x,
                    arrowprops=dict(arrowstyle='->', color='red', lw=2))
        z = (x[0] - y[0], x[1] - y[1])
        ax.set_title(f'Collision: z = ({z[0]}, {z[1]}), ⟨a,z⟩ = {a[0]*z[0]+a[1]*z[1]} ≡ 0 (mod {q})',
                     fontsize=12)
    
    # Draw box boundary
    rect = patches.Rectangle((-B - 0.5, -B - 0.5), 2*B + 1, 2*B + 1,
                              linewidth=2, edgecolor='black', facecolor='none', linestyle='--')
    ax.add_patch(rect)
    
    ax.set_xlabel('x₁', fontsize=14)
    ax.set_ylabel('x₂', fontsize=14)
    ax.set_xlim(-B - 1, B + 1)
    ax.set_ylim(-B - 1, B + 1)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title(f'Bounded Box [-{B},{B}]² colored by f(x) = {a[0]}x₁+{a[1]}x₂ mod {q}\n'
                 f'Box size = {(2*B+1)**2} > q = {q} ⟹ collision guaranteed',
                 fontsize=11)
    
    fig.savefig('/workspace/request-project/viz_collision_2d.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_phase_transition():
    """
    Visualization 2: Phase transition at collision threshold.
    Shows collision probability as box size crosses q.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: collision count vs box size ratio
    ax = axes[0]
    for q in [11, 23, 47, 97]:
        ratios = []
        collision_counts = []
        for B in range(1, 12):
            box_size = (2 * B + 1) ** 2
            ratio = box_size / q
            
            # Count collisions
            residue_map = defaultdict(int)
            for x1 in range(-B, B + 1):
                for x2 in range(-B, B + 1):
                    r = (3 * x1 + 7 * x2) % q
                    residue_map[r] += 1
            
            collisions = sum(c * (c - 1) // 2 for c in residue_map.values())
            ratios.append(ratio)
            collision_counts.append(collisions)
        
        ax.plot(ratios, collision_counts, 'o-', label=f'q={q}', markersize=4)
    
    ax.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Threshold (ratio=1)')
    ax.set_xlabel('Box size / q', fontsize=12)
    ax.set_ylabel('Number of collisions', fontsize=12)
    ax.set_title('Collision Count vs Box/Modulus Ratio', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')
    
    # Right: minimum kernel vector norm vs dimension
    ax = axes[1]
    for q in [50, 100, 200]:
        dims = range(2, 8)
        min_norms = []
        for n_dim in dims:
            a = list(range(1, n_dim + 1))
            B_thresh = 1
            while (2 * B_thresh + 1) ** n_dim <= q:
                B_thresh += 1
            
            # Find shortest kernel vector
            min_norm = float('inf')
            box = list(itertools.product(range(-B_thresh, B_thresh + 1), repeat=n_dim))
            residue_map = defaultdict(list)
            for x in box:
                r = sum(ai * xi for ai, xi in zip(a, x)) % q
                if residue_map[r]:
                    for y in residue_map[r]:
                        z = tuple(xi - yi for xi, yi in zip(x, y))
                        norm = max(abs(zi) for zi in z)
                        if norm > 0:
                            min_norm = min(min_norm, norm)
                residue_map[r].append(x)
                if len(box) > 10000:
                    break
            
            min_norms.append(min_norm if min_norm < float('inf') else None)
        
        valid = [(d, n) for d, n in zip(dims, min_norms) if n is not None]
        if valid:
            ax.plot([d for d, _ in valid], [n for _, n in valid], 'o-', 
                    label=f'q={q}', markersize=6)
    
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Min ‖z‖_∞ of kernel vector', fontsize=12)
    ax.set_title('Shortest Kernel Vector vs Dimension', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_phase_transition.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_security_landscape():
    """
    Visualization 3: Security landscape heatmap.
    Shows log₂(threshold box size) as function of (n, log q).
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    
    dims = [2, 4, 8, 16, 32, 64, 128, 256]
    log_qs = list(range(4, 33, 2))
    
    data = np.zeros((len(log_qs), len(dims)))
    
    for i, log_q in enumerate(log_qs):
        q = 2 ** log_q
        for j, n in enumerate(dims):
            # Threshold B
            root = q ** (1.0 / n)
            B = int(math.ceil((root - 1) / 2))
            while (2 * B + 1) ** n <= q:
                B += 1
            # Security = log2(box size at threshold)
            security = n * math.log2(2 * B + 1)
            data[i, j] = security
    
    im = ax.imshow(data, aspect='auto', cmap='RdYlGn',
                   extent=[0, len(dims), 0, len(log_qs)],
                   origin='lower', interpolation='nearest')
    
    ax.set_xticks(np.arange(len(dims)) + 0.5)
    ax.set_xticklabels(dims)
    ax.set_yticks(np.arange(len(log_qs)) + 0.5)
    ax.set_yticklabels(log_qs)
    ax.set_xlabel('Dimension n', fontsize=13)
    ax.set_ylabel('log₂(q)', fontsize=13)
    ax.set_title('Security Level (bits) from Collision Threshold\n'
                 'Green = high security, Red = low security', fontsize=12)
    
    cbar = plt.colorbar(im, ax=ax, label='log₂(box size at threshold)')
    
    fig.savefig('/workspace/request-project/viz_security_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_kernel_lattice():
    """
    Visualization 4: Kernel lattice structure in 2D.
    Shows the kernel lattice points and their relationship to the box.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    
    q = 11
    a = [3, 7]
    B = 5
    
    # Plot kernel lattice points (those with a·z ≡ 0 mod q)
    kernel_points = []
    other_points = []
    for z1 in range(-2*B, 2*B + 1):
        for z2 in range(-2*B, 2*B + 1):
            val = a[0] * z1 + a[1] * z2
            if val % q == 0:
                kernel_points.append((z1, z2))
            else:
                other_points.append((z1, z2))
    
    # Plot non-kernel points lightly
    if other_points:
        ox, oy = zip(*other_points)
        ax.scatter(ox, oy, c='lightgray', s=5, alpha=0.3, zorder=1)
    
    # Plot kernel points
    if kernel_points:
        kx, ky = zip(*kernel_points)
        ax.scatter(kx, ky, c='blue', s=30, zorder=3, edgecolors='navy', linewidth=0.5)
    
    # Highlight short kernel vectors (within 2B box)
    short_kernel = [(z1, z2) for z1, z2 in kernel_points 
                    if max(abs(z1), abs(z2)) <= 2*B and (z1 != 0 or z2 != 0)]
    if short_kernel:
        sx, sy = zip(*short_kernel)
        ax.scatter(sx, sy, c='green', s=60, zorder=4, edgecolors='darkgreen', linewidth=1)
    
    # Draw original box
    rect1 = patches.Rectangle((-B - 0.3, -B - 0.3), 2*B + 0.6, 2*B + 0.6,
                               linewidth=2, edgecolor='red', facecolor='none', 
                               linestyle='--', label=f'Original box [-{B},{B}]²')
    ax.add_patch(rect1)
    
    # Draw difference box
    rect2 = patches.Rectangle((-2*B - 0.3, -2*B - 0.3), 4*B + 0.6, 4*B + 0.6,
                               linewidth=2, edgecolor='orange', facecolor='none',
                               linestyle=':', label=f'Difference box [-{2*B},{2*B}]²')
    ax.add_patch(rect2)
    
    # Mark origin
    ax.scatter(0, 0, c='red', s=100, marker='x', zorder=5, linewidth=2)
    
    # Find shortest nonzero kernel vector
    shortest = min(short_kernel, key=lambda p: max(abs(p[0]), abs(p[1])))
    ax.annotate(f'Shortest: ({shortest[0]},{shortest[1]})',
                xy=shortest, xytext=(shortest[0]+1.5, shortest[1]+1.5),
                fontsize=10, color='darkgreen',
                arrowprops=dict(arrowstyle='->', color='darkgreen'))
    
    ax.set_xlabel('z₁', fontsize=14)
    ax.set_ylabel('z₂', fontsize=14)
    ax.set_title(f'Kernel Lattice: {{z : {a[0]}z₁+{a[1]}z₂ ≡ 0 (mod {q})}}\n'
                 f'Blue = kernel points, Green = short kernel vectors (‖z‖_∞ ≤ {2*B})',
                 fontsize=11)
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    fig.savefig('/workspace/request-project/viz_kernel_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = viz_collision_2d()
    print(f"  ✓ viz_collision_2d.png ({len(b64_1)} chars)")
    
    b64_2 = viz_phase_transition()
    print(f"  ✓ viz_phase_transition.png ({len(b64_2)} chars)")
    
    b64_3 = viz_security_landscape()
    print(f"  ✓ viz_security_landscape.png ({len(b64_3)} chars)")
    
    b64_4 = viz_kernel_lattice()
    print(f"  ✓ viz_kernel_lattice.png ({len(b64_4)} chars)")
    
    print("\nAll visualizations generated successfully.")
    
    # Save base64 data for JSON package
    import json
    viz_data = {
        "collision_2d": b64_1,
        "phase_transition": b64_2,
        "security_landscape": b64_3,
        "kernel_lattice": b64_4,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Visualization data saved to viz_data.json")
