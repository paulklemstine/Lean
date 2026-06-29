#!/usr/bin/env python3
"""
Applications of Tropical Alien Algebra

Real-world applications demonstrating the practical value of the theorems:
1. Distributed consensus via max-tropical spreading
2. Image processing: morphological erosion/dilation
3. Shortest-path computation via min-plus dynamics
4. Fault-tolerant computing with mutation bounds
"""

import numpy as np
from typing import List, Tuple


# ──────────────────────────────────────────────────────
# Application 1: Distributed Consensus
# ──────────────────────────────────────────────────────

def distributed_max_consensus(
    initial_values: np.ndarray,
    adjacency: np.ndarray,
    max_rounds: int = 100
) -> Tuple[np.ndarray, int]:
    """
    Distributed max-consensus on a network.
    
    Each node updates its value to the max of its own value and
    all neighbors' values. This is a max-tropical CA on a graph.
    
    By the emergence theorem, this always converges to the global
    maximum in at most diameter(graph) rounds.
    
    Args:
        initial_values: Value at each node.
        adjacency: Binary adjacency matrix (including self-loops).
        max_rounds: Safety bound.
    
    Returns:
        (final_values, num_rounds).
    """
    N = len(initial_values)
    x = initial_values.copy()
    
    for round_num in range(max_rounds):
        x_new = x.copy()
        for i in range(N):
            neighbors = np.where(adjacency[i] > 0)[0]
            x_new[i] = max(x[j] for j in neighbors)
        
        if np.array_equal(x_new, x):
            return x, round_num
        x = x_new
    
    return x, max_rounds


def demo_consensus():
    """Demo: distributed consensus on a ring network."""
    print("=" * 60)
    print("APPLICATION 1: Distributed Max-Consensus")
    print("=" * 60)
    
    N = 8
    # Ring adjacency (each node connected to self and two neighbors)
    adj = np.zeros((N, N), dtype=int)
    for i in range(N):
        adj[i, i] = 1
        adj[i, (i + 1) % N] = 1
        adj[i, (i - 1) % N] = 1
    
    values = np.array([3, 7, 1, 9, 2, 5, 4, 8])
    print(f"\n  Network: ring of {N} nodes")
    print(f"  Initial values: {values}")
    print(f"  Expected consensus: {np.max(values)} (global max)")
    
    final, rounds = distributed_max_consensus(values, adj)
    print(f"  Final values: {final}")
    print(f"  Rounds to consensus: {rounds}")
    print(f"  Theoretical bound: diameter = {N // 2} = {N // 2}")
    
    # Test fault tolerance (mutation stability)
    print(f"\n  --- Fault Tolerance Test ---")
    for eps in [1, 3]:
        noise = np.random.randint(-eps, eps + 1, size=N)
        perturbed = np.clip(values + noise, 0, None)
        final_orig, _ = distributed_max_consensus(values, adj)
        final_pert, _ = distributed_max_consensus(perturbed, adj)
        dist = np.max(np.abs(final_orig.astype(int) - final_pert.astype(int)))
        print(f"  ε={eps}: |consensus_orig - consensus_pert| = {dist}")


# ──────────────────────────────────────────────────────
# Application 2: Mathematical Morphology
# ──────────────────────────────────────────────────────

def morphological_erosion(image: np.ndarray, iterations: int = 1) -> np.ndarray:
    """
    Morphological erosion using min-tropical CA.
    
    This is the min-tropical CA applied to a 2D grid (image).
    Each pixel takes the minimum of itself and its 4-neighbors.
    
    Properties (from our theorems):
    - Monotone: darker input → darker output
    - Anti-inflationary: erosion only darkens
    - Converges to uniform min in bounded steps
    
    Args:
        image: 2D grayscale image (values in [0, 255]).
        iterations: Number of erosion steps.
    
    Returns:
        Eroded image.
    """
    result = image.copy()
    for _ in range(iterations):
        result = np.minimum.reduce([
            result,
            np.roll(result, 1, axis=0),
            np.roll(result, -1, axis=0),
            np.roll(result, 1, axis=1),
            np.roll(result, -1, axis=1)
        ])
    return result


def morphological_dilation(image: np.ndarray, iterations: int = 1) -> np.ndarray:
    """
    Morphological dilation using max-tropical CA.
    
    Properties (from our theorems):
    - Monotone: brighter input → brighter output
    - Inflationary: dilation only brightens
    - Converges to uniform max in bounded steps
    
    Args:
        image: 2D grayscale image.
        iterations: Number of dilation steps.
    
    Returns:
        Dilated image.
    """
    result = image.copy()
    for _ in range(iterations):
        result = np.maximum.reduce([
            result,
            np.roll(result, 1, axis=0),
            np.roll(result, -1, axis=0),
            np.roll(result, 1, axis=1),
            np.roll(result, -1, axis=1)
        ])
    return result


def demo_morphology():
    """Demo: mathematical morphology as tropical CA."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Mathematical Morphology (Image Processing)")
    print("=" * 60)
    
    # Create a simple test image: bright square on dark background
    img = np.zeros((20, 20), dtype=int)
    img[5:15, 5:15] = 200
    img[8:12, 8:12] = 255
    
    print(f"\n  Image size: {img.shape}")
    print(f"  Original range: [{img.min()}, {img.max()}]")
    
    # Apply erosion
    eroded = morphological_erosion(img, iterations=2)
    print(f"  After 2 erosions: [{eroded.min()}, {eroded.max()}]")
    print(f"  Bright region shrunk (erosion removes boundaries)")
    
    # Apply dilation
    dilated = morphological_dilation(img, iterations=2)
    print(f"  After 2 dilations: [{dilated.min()}, {dilated.max()}]")
    print(f"  Bright region expanded (dilation fills boundaries)")
    
    # Verify monotonicity
    img2 = img + 10  # brighter version
    print(f"\n  Monotonicity check:")
    print(f"    img ≤ img+10: {np.all(img <= img2)}")
    print(f"    erode(img) ≤ erode(img+10): {np.all(morphological_erosion(img) <= morphological_erosion(img2))}")
    print(f"    dilate(img) ≤ dilate(img+10): {np.all(morphological_dilation(img) <= morphological_dilation(img2))}")
    
    # Convergence
    print(f"\n  Convergence test (erosion):")
    x = img.copy()
    for step in range(30):
        x_new = morphological_erosion(x)
        if np.array_equal(x_new, x):
            print(f"    Converged at step {step}: all pixels = {x.min()}")
            break
        x = x_new


# ──────────────────────────────────────────────────────
# Application 3: Shortest-Path Computation
# ──────────────────────────────────────────────────────

def tropical_shortest_path(
    dist_matrix: np.ndarray,
    max_iterations: int = 100
) -> Tuple[np.ndarray, int]:
    """
    Compute all-pairs shortest paths using min-plus (tropical) 
    matrix iteration.
    
    This is the Bellman-Ford/Floyd-Warshall algorithm viewed as
    convergence of a monotone (decreasing) tropical dynamical system.
    
    By the emergence theorem on the dual order, this converges in
    at most N steps for N nodes.
    
    Args:
        dist_matrix: N×N distance matrix (use large values for no edge).
    
    Returns:
        (shortest_paths, iterations).
    """
    N = dist_matrix.shape[0]
    D = dist_matrix.copy()
    INF = 10**9
    
    for iteration in range(max_iterations):
        D_new = D.copy()
        for i in range(N):
            for j in range(N):
                for k in range(N):
                    D_new[i, j] = min(D_new[i, j], D[i, k] + D[k, j])
        
        if np.array_equal(D_new, D):
            return D, iteration
        D = D_new
    
    return D, max_iterations


def demo_shortest_path():
    """Demo: shortest paths as tropical dynamics."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Shortest Paths via Tropical Dynamics")
    print("=" * 60)
    
    INF = 10**9
    # Simple graph: 5 nodes
    N = 5
    D = np.full((N, N), INF)
    np.fill_diagonal(D, 0)
    
    edges = [(0, 1, 3), (1, 2, 2), (2, 3, 4), (3, 4, 1),
             (0, 3, 10), (1, 4, 8), (0, 2, 7)]
    for u, v, w in edges:
        D[u, v] = w
        D[v, u] = w
    
    print(f"\n  Graph: {N} nodes, {len(edges)} edges")
    for u, v, w in edges:
        print(f"    {u} -- {v} (weight {w})")
    
    result, iters = tropical_shortest_path(D)
    print(f"\n  Shortest path matrix (converged in {iters} iterations):")
    for i in range(N):
        row = [str(result[i, j]) if result[i, j] < INF else "∞" for j in range(N)]
        print(f"    {row}")
    
    print(f"\n  Shortest 0→4: {result[0, 4]} (via 0→1→2→3→4 = 3+2+4+1 = 10)")


# ──────────────────────────────────────────────────────
# Application 4: Fault-Tolerant Tropical Computing
# ──────────────────────────────────────────────────────

def demo_fault_tolerance():
    """Demo: fault-tolerant computing via mutation bounds."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Fault-Tolerant Tropical Computing")
    print("=" * 60)
    
    N = 10
    
    # Tropical "circuit": composition of min/max operations
    # Simulates a robust computation that tolerates input noise
    def tropical_circuit(x: np.ndarray) -> np.ndarray:
        """A tropical circuit: robust sorting-like operation."""
        # Layer 1: local min-max
        y = np.zeros_like(x)
        for i in range(N):
            left = x[(i - 1) % N]
            right = x[(i + 1) % N]
            y[i] = max(min(x[i], left), min(x[i], right))
        # Layer 2: clamp
        return np.clip(y, 5, 95)
    
    # Test fault tolerance
    print(f"\n  Tropical circuit on {N} cells")
    print(f"  Testing fault tolerance (mutation non-amplification):")
    
    base_input = np.random.randint(0, 100, size=N)
    base_output = tropical_circuit(base_input)
    
    print(f"\n  Base input:  {base_input}")
    print(f"  Base output: {base_output}")
    
    for eps in [1, 2, 5, 10]:
        max_output_error = 0
        for _ in range(1000):
            noise = np.random.randint(-eps, eps + 1, size=N)
            noisy_input = np.clip(base_input + noise, 0, None)
            
            input_dist = np.max(np.abs(base_input.astype(int) - noisy_input.astype(int)))
            if input_dist > eps:
                continue
            
            noisy_output = tropical_circuit(noisy_input)
            output_dist = np.max(np.abs(base_output.astype(int) - noisy_output.astype(int)))
            max_output_error = max(max_output_error, output_dist)
        
        amplification = max_output_error / eps if eps > 0 else 0
        print(f"  ε={eps:2d}: max output error = {max_output_error:3d}, "
              f"amplification = {amplification:.2f}x")


if __name__ == "__main__":
    np.random.seed(42)
    demo_consensus()
    demo_morphology()
    demo_shortest_path()
    demo_fault_tolerance()
    print("\n" + "=" * 60)
    print("All application demos completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Alien Algebra: Demos and Numerical Experiments

Demonstrates the main theorems with concrete numerical examples:
- Theorem A: Image = Fixed Points for idempotent functions
- Theorem B: Convergence of monotone inflationary dynamics
- Theorem C: Mutation non-amplification
- Theorem D: Tropical cellular automata on 1D tori
"""

import numpy as np
from typing import Callable

# ──────────────────────────────────────────────────────
# Demo 1: Idempotent function — Image = Fixed Points
# ──────────────────────────────────────────────────────

def demo_idempotent_image():
    """Demonstrate that the image of an idempotent function equals its fixed points."""
    print("=" * 60)
    print("DEMO 1: Idempotent Function — Image = Fixed Points")
    print("=" * 60)
    
    # Define an idempotent function on {0,...,9}^3
    # F(x) = coordinatewise min with [5, 3, 7] then max with [2, 1, 4]
    # This is a "clamping" operation, which is idempotent
    def F(x: np.ndarray) -> np.ndarray:
        return np.clip(x, [2, 1, 4], [5, 3, 7])
    
    # Verify idempotence: F(F(x)) == F(x) for random inputs
    print("\nVerifying idempotence on 1000 random inputs...")
    all_idempotent = True
    for _ in range(1000):
        x = np.random.randint(0, 10, size=3)
        if not np.array_equal(F(F(x)), F(x)):
            all_idempotent = False
            break
    print(f"  Idempotence verified: {all_idempotent}")
    
    # Compute the image by exhaustive enumeration
    image = set()
    for a in range(10):
        for b in range(10):
            for c in range(10):
                x = np.array([a, b, c])
                y = F(x)
                image.add(tuple(y))
    
    # Compute fixed points
    fixed_points = set()
    for a in range(10):
        for b in range(10):
            for c in range(10):
                x = np.array([a, b, c])
                if np.array_equal(F(x), x):
                    fixed_points.add(tuple(x))
    
    print(f"\n  |Image| = {len(image)}")
    print(f"  |Fixed Points| = {len(fixed_points)}")
    print(f"  Image == Fixed Points: {image == fixed_points}")
    print(f"\n  Sample fixed points: {list(fixed_points)[:5]}")
    print(f"  These are vectors with coords in [2,5]×[1,3]×[4,7]")
    print(f"  Expected: 4 × 3 × 4 = {4*3*4} elements")


# ──────────────────────────────────────────────────────
# Demo 2: Monotone inflationary convergence
# ──────────────────────────────────────────────────────

def demo_convergence():
    """Demonstrate that monotone inflationary maps converge uniformly."""
    print("\n" + "=" * 60)
    print("DEMO 2: Monotone Inflationary Convergence")
    print("=" * 60)
    
    N = 8  # dimension
    M = 5  # max value
    
    # Define F on {0,...,M}^N: F(x)_i = min(x_i + 1, M)
    # This is monotone and inflationary
    def F(x: np.ndarray) -> np.ndarray:
        return np.minimum(x + 1, M)
    
    print(f"\n  State space: {{0,...,{M}}}^{N}")
    print(f"  F(x)_i = min(x_i + 1, {M})")
    print(f"  Theoretical max convergence steps: {N * M}")
    
    # Test convergence from several initial states
    results = []
    for trial in range(5):
        x0 = np.random.randint(0, M + 1, size=N)
        x = x0.copy()
        steps = 0
        while not np.array_equal(F(x), x):
            x = F(x)
            steps += 1
        results.append((x0, x, steps))
    
    print(f"\n  {'Initial':30s} {'Fixed Point':30s} {'Steps':>5s}")
    print("  " + "-" * 67)
    for x0, xf, s in results:
        print(f"  {str(x0):30s} {str(xf):30s} {s:5d}")
    
    print(f"\n  All converge to [{M}]*{N} in at most {M} steps (= max value)")
    print(f"  Uniform bound confirmed: max steps = {max(s for _, _, s in results)}")


# ──────────────────────────────────────────────────────
# Demo 3: Mutation non-amplification
# ──────────────────────────────────────────────────────

def demo_mutation():
    """Demonstrate that Lipschitz-1 idempotent maps don't amplify mutations."""
    print("\n" + "=" * 60)
    print("DEMO 3: Mutation Non-Amplification")
    print("=" * 60)
    
    N = 10
    
    # Idempotent, Lipschitz-1 function: coordinatewise clamp
    lo = np.array([2, 0, 3, 1, 4, 2, 0, 3, 1, 5])
    hi = np.array([8, 6, 9, 7, 8, 6, 4, 7, 5, 9])
    
    def F(x: np.ndarray) -> np.ndarray:
        return np.clip(x, lo, hi)
    
    print(f"\n  F = coordinatewise clamp to [{lo}, {hi}]")
    print(f"  F is idempotent (clamp is idempotent)")
    print(f"  F is Lipschitz-1 (clamp contracts distances)")
    
    for eps in [1, 3, 5, 10]:
        print(f"\n  Testing ε = {eps}:")
        max_output_dist = 0
        for _ in range(1000):
            x = np.random.randint(0, 20, size=N)
            noise = np.random.randint(-eps, eps + 1, size=N)
            y = np.clip(x + noise, 0, None)  # ensure non-negative
            
            # Ensure input distance ≤ eps
            input_dist = np.max(np.abs(x.astype(int) - y.astype(int)))
            if input_dist > eps:
                continue
            
            output_dist = np.max(np.abs(F(x).astype(int) - F(y).astype(int)))
            max_output_dist = max(max_output_dist, output_dist)
        
        print(f"    Max d∞(F(x), F(y)) over 1000 trials: {max_output_dist}")
        print(f"    Bound ε = {eps}: {'✓ satisfied' if max_output_dist <= eps else '✗ violated'}")
        
        # Verify fixed-point property
        x_sample = np.random.randint(0, 20, size=N)
        fx = F(x_sample)
        print(f"    F(F(x)) == F(x): {np.array_equal(F(fx), fx)}")


# ──────────────────────────────────────────────────────
# Demo 4: Tropical Cellular Automata
# ──────────────────────────────────────────────────────

def demo_tropical_ca():
    """Demonstrate tropical CA convergence on a 1D torus."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Cellular Automata on 1D Torus")
    print("=" * 60)
    
    N = 12
    
    def min_ca(x: np.ndarray) -> np.ndarray:
        """Min-tropical CA: each cell takes min of self and neighbors."""
        return np.minimum(x, np.minimum(np.roll(x, 1), np.roll(x, -1)))
    
    def max_ca(x: np.ndarray) -> np.ndarray:
        """Max-tropical CA: each cell takes max of self and neighbors."""
        return np.maximum(x, np.maximum(np.roll(x, 1), np.roll(x, -1)))
    
    # Min CA demo
    print(f"\n  --- Min-Tropical CA (N={N}) ---")
    x0 = np.random.randint(0, 50, size=N)
    print(f"  Initial: {x0}")
    x = x0.copy()
    for step in range(N):
        x_new = min_ca(x)
        if np.array_equal(x_new, x):
            print(f"  Converged at step {step}!")
            break
        x = x_new
        print(f"  Step {step+1}: {x}")
    print(f"  Fixed point: all cells = {np.min(x0)} (global minimum)")
    
    # Max CA demo
    print(f"\n  --- Max-Tropical CA (N={N}) ---")
    x0 = np.random.randint(0, 50, size=N)
    print(f"  Initial: {x0}")
    x = x0.copy()
    for step in range(N):
        x_new = max_ca(x)
        if np.array_equal(x_new, x):
            print(f"  Converged at step {step}!")
            break
        x = x_new
        print(f"  Step {step+1}: {x}")
    print(f"  Fixed point: all cells = {np.max(x0)} (global maximum)")
    
    # Verify inflationarity of max CA
    print(f"\n  --- Inflationarity Check (Max CA) ---")
    x = np.random.randint(0, 100, size=N)
    y = max_ca(x)
    print(f"  x = {x}")
    print(f"  max_ca(x) = {y}")
    print(f"  x ≤ max_ca(x): {np.all(x <= y)}")
    
    # Verify monotonicity
    print(f"\n  --- Monotonicity Check ---")
    x = np.random.randint(0, 50, size=N)
    y = x + np.random.randint(0, 10, size=N)  # y ≥ x
    print(f"  x ≤ y: {np.all(x <= y)}")
    print(f"  min_ca(x) ≤ min_ca(y): {np.all(min_ca(x) <= min_ca(y))}")
    print(f"  max_ca(x) ≤ max_ca(y): {np.all(max_ca(x) <= max_ca(y))}")


# ──────────────────────────────────────────────────────
# Demo 5: Composition of commuting idempotent maps
# ──────────────────────────────────────────────────────

def demo_composition():
    """Demonstrate that commuting idempotent functions compose to idempotent."""
    print("\n" + "=" * 60)
    print("DEMO 5: Composition of Commuting Idempotent Maps")
    print("=" * 60)
    
    N = 5
    
    # F = clamp to [2, 8] coordinatewise
    # G = clamp to [0, 6] coordinatewise
    # Both are idempotent. They commute because clamp operations
    # on the same coordinates commute when their ranges overlap.
    
    def F(x: np.ndarray) -> np.ndarray:
        return np.clip(x, 2, 8)
    
    def G(x: np.ndarray) -> np.ndarray:
        return np.clip(x, 0, 6)
    
    def FG(x: np.ndarray) -> np.ndarray:
        return F(G(x))
    
    # Verify commutativity
    print("\n  Checking commutativity F(G(x)) == G(F(x))...")
    commutes = True
    for _ in range(1000):
        x = np.random.randint(0, 15, size=N)
        if not np.array_equal(F(G(x)), G(F(x))):
            commutes = False
            break
    print(f"  Commutes: {commutes}")
    
    # Verify idempotence of F, G
    print("  Checking idempotence of F, G...")
    f_idem = all(np.array_equal(F(F(np.random.randint(0,15,N))), 
                                 F(np.random.randint(0,15,N))) 
                 or True for _ in range(100))
    # More careful check
    f_idem = True
    g_idem = True
    fg_idem = True
    for _ in range(1000):
        x = np.random.randint(0, 15, size=N)
        if not np.array_equal(F(F(x)), F(x)):
            f_idem = False
        if not np.array_equal(G(G(x)), G(x)):
            g_idem = False
        if not np.array_equal(FG(FG(x)), FG(x)):
            fg_idem = False
    
    print(f"  F idempotent: {f_idem}")
    print(f"  G idempotent: {g_idem}")
    print(f"  F∘G idempotent: {fg_idem}")
    
    # Show the composed fixed points
    composed_fps = []
    for val in range(15):
        x = np.full(N, val)
        y = FG(x)
        if np.array_equal(FG(y), y):
            composed_fps.append((val, tuple(y)))
    
    print(f"\n  Composed F∘G fixed points (constant inputs):")
    for v, fp in composed_fps[:8]:
        print(f"    F(G({v},...,{v})) = {fp}")
    print(f"  Range of F∘G: [2, 6] (intersection of [2,8] and [0,6])")


if __name__ == "__main__":
    np.random.seed(42)
    demo_idempotent_image()
    demo_convergence()
    demo_mutation()
    demo_tropical_ca()
    demo_composition()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Alien Algebra

Generates publication-quality figures showing:
1. Tropical CA convergence dynamics
2. Attractor landscape
3. Mutation stability diagram
4. 2D tropical CA evolution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def visualize_ca_convergence():
    """Visualize tropical CA convergence on a 1D torus."""
    N = 20
    np.random.seed(42)
    x0 = np.random.randint(0, 100, size=N)
    
    # Max CA trajectory
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    for ax_idx, (ca_name, ca_fn) in enumerate([
        ("Min-Tropical CA", lambda x: np.minimum(x, np.minimum(np.roll(x, 1), np.roll(x, -1)))),
        ("Max-Tropical CA", lambda x: np.maximum(x, np.maximum(np.roll(x, 1), np.roll(x, -1))))
    ]):
        x = x0.copy()
        trajectory = [x.copy()]
        for _ in range(15):
            x = ca_fn(x)
            trajectory.append(x.copy())
            if np.array_equal(trajectory[-1], trajectory[-2]):
                break
        
        traj = np.array(trajectory)
        ax = axes[ax_idx]
        im = ax.imshow(traj, aspect='auto', cmap='viridis', interpolation='nearest')
        ax.set_xlabel('Cell Index', fontsize=12)
        ax.set_ylabel('Time Step', fontsize=12)
        ax.set_title(ca_name, fontsize=14, fontweight='bold')
        plt.colorbar(im, ax=ax, label='Cell Value')
    
    fig.suptitle('Tropical CA Convergence: Every Orbit Reaches a Fixed Point',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/fig_ca_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def visualize_attractor_landscape():
    """Visualize the attractor structure of a tropical replicator."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # 2D state space visualization
    # F(x, y) = (clamp(x, 2, 8), clamp(y, 1, 7)) — idempotent
    ax = axes[0]
    
    # Draw arrows from states to their images
    for x in range(11):
        for y in range(11):
            fx = np.clip(x, 2, 8)
            fy = np.clip(y, 1, 7)
            if x != fx or y != fy:
                ax.annotate('', xy=(fx, fy), xytext=(x, y),
                           arrowprops=dict(arrowstyle='->', color='lightblue',
                                         alpha=0.4, lw=0.8))
    
    # Highlight fixed points
    fps_x, fps_y = [], []
    for x in range(11):
        for y in range(11):
            fx = np.clip(x, 2, 8)
            fy = np.clip(y, 1, 7)
            if x == fx and y == fy:
                fps_x.append(x)
                fps_y.append(y)
    
    ax.scatter(fps_x, fps_y, c='red', s=80, zorder=5, label='Fixed Points (Organisms)')
    
    # Highlight non-fixed points
    nfp_x, nfp_y = [], []
    for x in range(11):
        for y in range(11):
            if x not in range(2, 9) or y not in range(1, 8):
                nfp_x.append(x)
                nfp_y.append(y)
    ax.scatter(nfp_x, nfp_y, c='lightgray', s=30, zorder=4, label='Transient States')
    
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Attractor Landscape\n(Image = Fixed Points)', fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 10.5)
    ax.grid(True, alpha=0.2)
    
    # Convergence time histogram
    ax2 = axes[1]
    np.random.seed(42)
    N = 15
    convergence_times = []
    for _ in range(500):
        x = np.random.randint(0, 50, size=N)
        steps = 0
        for s in range(100):
            x_new = np.maximum(x, np.maximum(np.roll(x, 1), np.roll(x, -1)))
            if np.array_equal(x_new, x):
                steps = s
                break
            x = x_new
        convergence_times.append(steps)
    
    ax2.hist(convergence_times, bins=range(max(convergence_times) + 2),
             color='steelblue', edgecolor='navy', alpha=0.8)
    ax2.axvline(np.mean(convergence_times), color='red', linestyle='--',
                label=f'Mean = {np.mean(convergence_times):.1f}')
    ax2.set_xlabel('Steps to Convergence', fontsize=12)
    ax2.set_ylabel('Frequency', fontsize=12)
    ax2.set_title(f'Convergence Time Distribution\n(Max CA, N={N})', 
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_attractor_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def visualize_mutation_stability():
    """Visualize mutation non-amplification."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    N = 20
    np.random.seed(42)
    
    # Plot 1: Input vs output distance for Lipschitz-1 map
    ax = axes[0]
    
    def F(x):
        return np.clip(x, 5, 45)
    
    input_dists = []
    output_dists = []
    
    for _ in range(2000):
        x = np.random.randint(0, 50, size=N)
        eps = np.random.randint(0, 20)
        noise = np.random.randint(-eps, eps + 1, size=N)
        y = np.clip(x + noise, 0, None)
        
        d_in = np.max(np.abs(x.astype(int) - y.astype(int)))
        d_out = np.max(np.abs(F(x).astype(int) - F(y).astype(int)))
        
        input_dists.append(d_in)
        output_dists.append(d_out)
    
    ax.scatter(input_dists, output_dists, alpha=0.3, s=10, c='steelblue')
    max_d = max(max(input_dists), max(output_dists))
    ax.plot([0, max_d], [0, max_d], 'r--', lw=2, label='d_out = d_in (Lipschitz-1)')
    ax.set_xlabel('Input Distance d∞(x, y)', fontsize=12)
    ax.set_ylabel('Output Distance d∞(F(x), F(y))', fontsize=12)
    ax.set_title('Mutation Non-Amplification\n(All points below the line)', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_aspect('equal')
    
    # Plot 2: Mutation spread over CA iterations
    ax2 = axes[1]
    
    x0 = np.random.randint(10, 40, size=30)
    epsilons = [1, 3, 5, 10]
    
    for eps in epsilons:
        noise = np.random.randint(-eps, eps + 1, size=30)
        y0 = np.clip(x0 + noise, 0, None)
        
        x, y = x0.copy(), y0.copy()
        distances = [np.max(np.abs(x.astype(int) - y.astype(int)))]
        
        for _ in range(20):
            x = np.maximum(x, np.maximum(np.roll(x, 1), np.roll(x, -1)))
            y = np.maximum(y, np.maximum(np.roll(y, 1), np.roll(y, -1)))
            distances.append(np.max(np.abs(x.astype(int) - y.astype(int))))
        
        ax2.plot(distances, label=f'ε = {eps}', linewidth=2)
    
    ax2.set_xlabel('CA Step', fontsize=12)
    ax2.set_ylabel('Sup-norm Distance', fontsize=12)
    ax2.set_title('Mutation Distance During CA Evolution\n(Never exceeds initial ε)',
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_mutation_stability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def visualize_2d_ca():
    """Visualize 2D tropical CA evolution."""
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    
    np.random.seed(42)
    grid = np.random.randint(0, 100, size=(30, 30))
    
    # Max CA evolution
    x = grid.copy()
    steps = [0, 2, 5, 14]
    step_idx = 0
    
    for s in range(15):
        if s in steps:
            ax = axes[0, step_idx]
            im = ax.imshow(x, cmap='inferno', vmin=0, vmax=100)
            ax.set_title(f'Max CA, t={s}', fontsize=12, fontweight='bold')
            ax.axis('off')
            step_idx += 1
        x = np.maximum.reduce([
            x, np.roll(x, 1, axis=0), np.roll(x, -1, axis=0),
            np.roll(x, 1, axis=1), np.roll(x, -1, axis=1)
        ])
    
    # Min CA evolution
    x = grid.copy()
    step_idx = 0
    
    for s in range(15):
        if s in steps:
            ax = axes[1, step_idx]
            im = ax.imshow(x, cmap='inferno', vmin=0, vmax=100)
            ax.set_title(f'Min CA, t={s}', fontsize=12, fontweight='bold')
            ax.axis('off')
            step_idx += 1
        x = np.minimum.reduce([
            x, np.roll(x, 1, axis=0), np.roll(x, -1, axis=0),
            np.roll(x, 1, axis=1), np.roll(x, -1, axis=1)
        ])
    
    fig.suptitle('2D Tropical Cellular Automata: Convergence to Fixed Points',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/fig_2d_ca.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = visualize_ca_convergence()
    print(f"  CA convergence: saved to fig_ca_convergence.png ({len(b64_1)} chars)")
    
    b64_2 = visualize_attractor_landscape()
    print(f"  Attractor landscape: saved to fig_attractor_landscape.png ({len(b64_2)} chars)")
    
    b64_3 = visualize_mutation_stability()
    print(f"  Mutation stability: saved to fig_mutation_stability.png ({len(b64_3)} chars)")
    
    b64_4 = visualize_2d_ca()
    print(f"  2D CA: saved to fig_2d_ca.png ({len(b64_4)} chars)")
    
    print("\nAll visualizations generated!")
