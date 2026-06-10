#!/usr/bin/env python3
"""
Spectral Proof Complexity: Numerical Demonstrations

Demonstrates the key results:
1. Proof ball growth under expansion
2. Depth class hierarchy stratification
3. Directed conductance computation
4. Layered derivation tight bounds
"""

import math
from typing import Dict, List, Set, Tuple


def compute_proof_ball(adj: Dict[int, Set[int]], S: Set[int], k: int) -> Set[int]:
    """Compute the proof ball of radius k around set S."""
    ball = set(S)
    for _ in range(k):
        neighbors = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        ball = ball | neighbors
    return ball


def compute_depth_classes(adj: Dict[int, Set[int]], S: Set[int], max_k: int) -> List[Set[int]]:
    """Compute depth classes D(0), D(1), ..., D(max_k)."""
    classes = [set(S)]
    ball = set(S)
    for k in range(1, max_k + 1):
        neighbors = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        new_ball = ball | neighbors
        classes.append(new_ball - ball)
        if not classes[-1]:
            break
        ball = new_ball
    return classes


def compute_boundary(adj: Dict[int, Set[int]], S: Set[int]) -> Set[int]:
    """Compute the boundary ∂⁺S = N⁺(S) \\ S."""
    neighbors = set()
    for v in S:
        neighbors.update(adj.get(v, set()))
    return neighbors - S


def compute_directed_conductance(adj: Dict[int, Set[int]], n: int) -> float:
    """Compute the directed conductance (exact, exponential time)."""
    from itertools import combinations
    min_ratio = float('inf')
    vertices = list(range(n))
    for size in range(1, n // 2 + 1):
        for subset in combinations(vertices, size):
            S = set(subset)
            boundary = compute_boundary(adj, S)
            ratio = len(boundary) / len(S)
            min_ratio = min(min_ratio, ratio)
    return min_ratio


def build_cycle_graph(n: int) -> Dict[int, Set[int]]:
    """Build directed cycle ℤ/nℤ."""
    return {i: {(i + 1) % n} for i in range(n)}


def build_expander_graph(n: int, d: int) -> Dict[int, Set[int]]:
    """Build a d-regular expander-like graph on n vertices (Cayley-style)."""
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    generators = list(range(1, d + 1))
    for i in range(n):
        for g in generators:
            adj[i].add((i + g) % n)
    return adj


def demo_ball_growth():
    """Demo 1: Proof ball growth under expansion."""
    print("=" * 60)
    print("DEMO 1: Proof Ball Growth Under Expansion")
    print("=" * 60)

    n = 50
    adj = build_expander_graph(n, 3)  # 3-regular expander-like
    S = {0}

    print(f"\nGraph: ℤ/{n}ℤ with generators {{1, 2, 3}}")
    print(f"Initial set S = {S}")
    print(f"{'Step k':>8} {'|Ball(k)|':>12} {'|D(k)|':>10} {'Growth':>10}")
    print("-" * 44)

    prev_ball_size = len(S)
    for k in range(15):
        ball = compute_proof_ball(adj, S, k)
        if k == 0:
            dk_size = len(S)
        else:
            prev_ball = compute_proof_ball(adj, S, k - 1)
            dk_size = len(ball - prev_ball)

        growth = len(ball) / prev_ball_size if prev_ball_size > 0 else 0
        print(f"{k:>8} {len(ball):>12} {dk_size:>10} {growth:>10.3f}")
        prev_ball_size = len(ball)

    # Compute conductance for small graph
    small_n = 12
    small_adj = build_expander_graph(small_n, 3)
    phi = compute_directed_conductance(small_adj, small_n)
    print(f"\nDirected conductance for n={small_n}: φ = {phi:.4f}")
    print(f"Predicted growth factor: 1 + φ = {1 + phi:.4f}")


def demo_depth_hierarchy():
    """Demo 2: Depth class stratification."""
    print("\n" + "=" * 60)
    print("DEMO 2: Depth Class Hierarchy Stratification")
    print("=" * 60)

    n = 30
    adj = build_expander_graph(n, 2)
    S = {0}

    classes = compute_depth_classes(adj, S, 20)

    print(f"\nGraph: ℤ/{n}ℤ with generators {{1, 2}}")
    print(f"Initial set S = {{0}}")
    print(f"\n{'Depth k':>8} {'|D(k)|':>10} {'Cumulative':>12} {'Fraction':>10}")
    print("-" * 44)

    cumulative = 0
    for k, dc in enumerate(classes):
        if not dc:
            break
        cumulative += len(dc)
        print(f"{k:>8} {len(dc):>10} {cumulative:>12} {cumulative/n:>10.3f}")

    print(f"\nReachable component size: {cumulative}/{n}")
    print(f"Number of non-empty depth classes: {sum(1 for dc in classes if dc)}")


def demo_layered_derivation():
    """Demo 3: Layered derivation tight bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Layered Derivation — Tight Layer Bounds")
    print("=" * 60)

    # Build a layered graph: 4 layers, 5 vertices per layer
    n_layers = 5
    n_per_layer = 4
    n = n_layers * n_per_layer
    layer_of = {}
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}

    for ell in range(n_layers):
        for i in range(n_per_layer):
            v = ell * n_per_layer + i
            layer_of[v] = ell
            if ell < n_layers - 1:
                # Connect to 2 vertices in next layer
                for j in range(min(2, n_per_layer)):
                    w = (ell + 1) * n_per_layer + (i + j) % n_per_layer
                    adj[v].add(w)

    S = set(range(n_per_layer))  # Layer 0

    print(f"\nLayered graph: {n_layers} layers × {n_per_layer} vertices per layer")
    print(f"Initial set S = layer 0 = {S}")
    print(f"\n{'Step k':>8} {'|Ball(k)|':>12} {'Max layer in Ball':>20} {'Predicted max':>15}")
    print("-" * 59)

    for k in range(n_layers + 2):
        ball = compute_proof_ball(adj, S, k)
        max_layer = max(layer_of[v] for v in ball) if ball else -1
        predicted = min(k, n_layers - 1)
        print(f"{k:>8} {len(ball):>12} {max_layer:>20} {predicted:>15}")


def demo_cheeger_conjecture():
    """Demo 4: Numerical test of directed Cheeger conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 4: Directed Cheeger Conjecture — Numerical Test")
    print("=" * 60)

    print(f"\nFor directed cycle ℤ/nℤ (d=1):")
    print(f"{'n':>8} {'φ':>12} {'λ₂':>12} {'φ²/2':>12} {'2φ':>12} {'φ²/2 ≤ λ₂?':>14} {'λ₂ ≤ 2φ?':>12}")
    print("-" * 78)

    for n in [10, 20, 50, 100, 200, 500]:
        phi = 1.0 / (n // 2)
        lambda2 = 1 - math.cos(2 * math.pi / n)
        lower = phi ** 2 / 2
        upper = 2 * phi

        check_lower = "✓" if lower <= lambda2 + 1e-10 else "✗"
        check_upper = "✓" if lambda2 <= upper + 1e-10 else "✗"

        print(f"{n:>8} {phi:>12.6f} {lambda2:>12.6f} {lower:>12.6f} {upper:>12.6f} {check_lower:>14} {check_upper:>12}")

    print(f"\nFor Cayley graph ℤ/nℤ with generators {{1, 2}} (d=2):")
    print(f"{'n':>8} {'φ (exact)':>12} {'φ²/4':>12}")
    print("-" * 36)

    for n in [8, 10, 12, 14]:
        adj = build_expander_graph(n, 2)
        phi = compute_directed_conductance(adj, n)
        print(f"{n:>8} {phi:>12.4f} {phi**2/4:>12.6f}")


def demo_reachability_dichotomy():
    """Demo 5: Reachability dichotomy in a graph with disconnected components."""
    print("\n" + "=" * 60)
    print("DEMO 5: Reachability Dichotomy")
    print("=" * 60)

    # Two disconnected cycles
    adj: Dict[int, Set[int]] = {}
    n1, n2 = 5, 7
    for i in range(n1):
        adj[i] = {(i + 1) % n1}
    for i in range(n1, n1 + n2):
        adj[i] = {n1 + (i - n1 + 1) % n2}

    S = {0}
    n = n1 + n2

    print(f"\nGraph: Two disconnected directed cycles (sizes {n1} and {n2})")
    print(f"Initial set S = {{0}} (in first cycle)")

    rc = compute_proof_ball(adj, S, n)
    print(f"\nReachable component from S: {sorted(rc)}")
    print(f"Unreachable vertices: {sorted(set(range(n)) - rc)}")

    print(f"\nVerifying dichotomy:")
    for v in range(n):
        if v in rc:
            # Find first step it appears
            for k in range(n + 1):
                if v in compute_proof_ball(adj, S, k):
                    print(f"  Vertex {v}: REACHABLE at step {k}")
                    break
        else:
            reachable_ever = any(v in compute_proof_ball(adj, S, k) for k in range(2 * n))
            status = "never reachable ✓" if not reachable_ever else "BUG!"
            print(f"  Vertex {v}: UNREACHABLE — {status}")


if __name__ == "__main__":
    demo_ball_growth()
    demo_depth_hierarchy()
    demo_layered_derivation()
    demo_cheeger_conjecture()
    demo_reachability_dichotomy()


#!/usr/bin/env python3
"""
Visualization: Proof Ball Growth Under Expansion

Shows exponential growth of proof balls in expander-like derivation graphs,
compared with the theoretical lower bound (1+φ)^k.
"""

import math
from typing import Dict, Set, List


def compute_proof_ball(adj: Dict[int, Set[int]], S: Set[int], k: int) -> Set[int]:
    ball = set(S)
    for _ in range(k):
        neighbors = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        ball = ball | neighbors
    return ball


def boundary(adj: Dict[int, Set[int]], S: Set[int]) -> Set[int]:
    neighbors = set()
    for v in S:
        neighbors.update(adj.get(v, set()))
    return neighbors - S


def directed_conductance(adj: Dict[int, Set[int]], n: int) -> float:
    from itertools import combinations
    min_ratio = float('inf')
    for size in range(1, n // 2 + 1):
        for subset in combinations(range(n), size):
            S = set(subset)
            bdry = boundary(adj, S)
            ratio = len(bdry) / len(S)
            min_ratio = min(min_ratio, ratio)
    return min_ratio


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Panel 1: Ball growth for different expansion rates ---
    configs = [
        (30, [1], "d=1 (cycle)"),
        (30, [1, 2], "d=2"),
        (30, [1, 2, 3], "d=3"),
    ]

    ax = axes[0]
    for n, gens, label in configs:
        adj = {i: {(i + g) % n for g in gens} for i in range(n)}
        sizes = []
        for k in range(16):
            ball = compute_proof_ball(adj, {0}, k)
            sizes.append(len(ball))
        ax.plot(range(len(sizes)), sizes, 'o-', label=label, markersize=4)

    ax.set_xlabel("Step k", fontsize=12)
    ax.set_ylabel("|Ball(S, k)|", fontsize=12)
    ax.set_title("Proof Ball Growth vs. Expansion Rate", fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Actual vs. theoretical growth for d=2 ---
    n = 16
    gens = [1, 2]
    adj = {i: {(i + g) % n for g in gens} for i in range(n)}
    phi = directed_conductance(adj, n)

    ax = axes[1]
    actual_sizes = []
    theoretical = []
    steps = list(range(10))
    for k in steps:
        ball = compute_proof_ball(adj, {0}, k)
        actual_sizes.append(len(ball))
        theoretical.append(min(n, (1 + phi) ** k))

    ax.plot(steps, actual_sizes, 'bo-', label=f"Actual |Ball(k)|", markersize=6)
    ax.plot(steps, theoretical, 'r--', label=f"(1+φ)^k, φ={phi:.3f}", linewidth=2)
    ax.axhline(y=n, color='gray', linestyle=':', alpha=0.5, label=f"|V| = {n}")
    ax.set_xlabel("Step k", fontsize=12)
    ax.set_ylabel("Size", fontsize=12)
    ax.set_title(f"Actual vs. Theoretical Growth (ℤ/{n}ℤ, d=2)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("viz_ball_growth.png", dpi=150, bbox_inches='tight')
    print("Saved viz_ball_growth.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Depth Class Hierarchy

Shows the stratification of reachable vertices into depth classes,
demonstrating the strict hierarchy under expansion.
"""

from typing import Dict, Set, List


def compute_depth_classes(adj: Dict[int, Set[int]], S: Set[int], max_k: int) -> List[Set[int]]:
    classes = [set(S)]
    ball = set(S)
    for k in range(1, max_k + 1):
        neighbors = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        new_ball = ball | neighbors
        dc = new_ball - ball
        classes.append(dc)
        if not dc:
            break
        ball = new_ball
    return classes


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    configs = [
        (40, [1], "Cycle (d=1)"),
        (40, [1, 3], "Cayley d=2, gens={1,3}"),
        (40, [1, 2, 5], "Cayley d=3, gens={1,2,5}"),
    ]

    for idx, (n, gens, title) in enumerate(configs):
        adj = {i: {(i + g) % n for g in gens} for i in range(n)}
        classes = compute_depth_classes(adj, {0}, n)

        ax = axes[idx]
        sizes = [len(c) for c in classes if c]
        colors = plt.cm.viridis([k / max(len(sizes), 1) for k in range(len(sizes))])

        bars = ax.bar(range(len(sizes)), sizes, color=colors, edgecolor='black', linewidth=0.5)
        ax.set_xlabel("Depth k", fontsize=11)
        ax.set_ylabel("|D(S, k)|", fontsize=11)
        ax.set_title(f"{title}\nn={n}", fontsize=12)
        ax.grid(True, alpha=0.2, axis='y')

        # Annotate total
        total = sum(sizes)
        ax.text(0.95, 0.95, f"RC = {total}/{n}",
                transform=ax.transAxes, ha='right', va='top',
                fontsize=10, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.suptitle("Depth Class Hierarchy Stratification", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("viz_depth_classes.png", dpi=150, bbox_inches='tight')
    print("Saved viz_depth_classes.png")


if __name__ == "__main__":
    main()
