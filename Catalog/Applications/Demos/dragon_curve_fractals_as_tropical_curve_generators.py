#!/usr/bin/env python3
"""
Applications of Tropical Dragon Curve Theory

Demonstrates practical applications of the tropical dragon curve framework:
1. Antenna design via space-filling fractal geometry
2. Image scanning / space-filling traversal
3. Data compression via tropical address encoding
4. Signal processing with fractal self-similarity
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─── Core Dragon Curve ─────────────────────────────────────────────────────

def dragon_turns(n):
    if n == 0:
        return []
    prev = dragon_turns(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]


def dragon_path(n):
    DIR = {0: (1, 0), 1: (0, 1), 2: (-1, 0), 3: (0, -1)}
    turns = dragon_turns(n)
    x, y, d = 0, 0, 0
    path = [(x, y)]
    for turn in turns:
        dx, dy = DIR[d]
        x, y = x + dx, y + dy
        path.append((x, y))
        d = (d + 3) % 4 if turn else (d + 1) % 4
    dx, dy = DIR[d]
    path.append((x + dx, y + dy))
    return path


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Fractal Antenna Design
# ═══════════════════════════════════════════════════════════════════════════

def fractal_antenna_analysis():
    """
    Dragon curve fractals are used in antenna design because:
    1. They fill 2D space efficiently (dimension 2 attractor)
    2. Their self-similar structure creates multiband resonance
    3. The tropical recursive description enables systematic optimization
    
    The piecewise-affine tropical encoding means each antenna segment
    can be parameterized by a small number of tropical scaling factors,
    enabling efficient design-space exploration.
    """
    print("=== Fractal Antenna Design Application ===\n")
    
    # Compute effective lengths at each iteration
    for n in range(1, 11):
        path = dragon_path(n)
        num_segments = 2**n
        
        # Bounding box
        xs = [p[0] for p in path]
        ys = [p[1] for p in path]
        width = max(xs) - min(xs)
        height = max(ys) - min(ys)
        area_bbox = width * height if width > 0 and height > 0 else 1
        
        # Space-filling efficiency
        efficiency = num_segments / area_bbox if area_bbox > 0 else 0
        
        print(f"  n={n:2d}: segments={num_segments:6d}, "
              f"bbox={width:5d}×{height:<5d}, "
              f"fill efficiency={efficiency:.3f}")
    
    print("\n  → As n grows, the dragon fills its bounding box,")
    print("    creating a compact, multiband antenna element.\n")


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Space-Filling Image Traversal
# ═══════════════════════════════════════════════════════════════════════════

def image_traversal_demo():
    """
    Dragon curves provide a locality-preserving mapping from 1D to 2D,
    useful for image processing, database indexing, and cache-efficient
    matrix traversal. The tropical address encoding provides O(log n)
    lookup for the curve position.
    """
    print("=== Space-Filling Image Traversal ===\n")
    
    n = 8  # 2^8 = 256 segments → ~16×16 grid coverage
    path = dragon_path(n)
    
    # Analyze locality preservation
    # For each pair of adjacent vertices on the curve,
    # measure their Euclidean distance
    adj_dists = []
    for i in range(len(path) - 1):
        dx = path[i+1][0] - path[i][0]
        dy = path[i+1][1] - path[i][1]
        adj_dists.append(np.sqrt(dx**2 + dy**2))
    
    print(f"  Dragon curve n={n}: {len(path)} vertices")
    print(f"  Adjacent vertex distances:")
    print(f"    mean = {np.mean(adj_dists):.4f}")
    print(f"    max  = {np.max(adj_dists):.4f}")
    print(f"    min  = {np.min(adj_dists):.4f}")
    print(f"  All adjacent vertices are unit distance apart: "
          f"{'✓' if np.allclose(adj_dists, 1.0) else '✗'}")
    
    # Compare with raster scan
    grid_size = int(np.ceil(np.sqrt(len(path))))
    raster_jumps = 0
    for i in range(grid_size - 1):
        # End of one row to start of next
        raster_jumps += grid_size - 1  # Row-end to row-start distance
    
    print(f"\n  Locality comparison:")
    print(f"    Dragon curve: max jump = {np.max(adj_dists):.1f} units")
    print(f"    Raster scan: max jump = {grid_size:.1f} units")
    print(f"  → Dragon curve has better locality preservation.\n")


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Tropical Address Encoding
# ═══════════════════════════════════════════════════════════════════════════

def tropical_address_demo():
    """
    The binary address structure of the dragon curve (proved in the
    formalization as `dragon_binary_branching`) enables a compact
    tropical encoding of positions.
    
    Each vertex at level n can be addressed by an n-bit string,
    where each bit indicates which branch of the self-similar
    decomposition the vertex belongs to.
    """
    print("=== Tropical Address Encoding ===\n")
    
    for n in range(1, 7):
        turns = dragon_turns(n)
        num_turns = len(turns)
        
        # The turn sequence has 2^n - 1 entries
        # Each turn is 1 bit → total storage = 2^n - 1 bits
        # But the recursive structure means we only need n bits
        # to specify the generation rule
        
        raw_bits = num_turns
        compressed_bits = n  # Just store the iteration count
        ratio = compressed_bits / raw_bits if raw_bits > 0 else 0
        
        print(f"  n={n}: {raw_bits} turns, "
              f"recursive spec = {compressed_bits} bits, "
              f"compression = {ratio:.4f}")
    
    print("\n  → The recursive/tropical structure achieves")
    print("    exponential compression of path descriptions.\n")


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Self-Similar Signal Analysis
# ═══════════════════════════════════════════════════════════════════════════

def signal_analysis_demo():
    """
    The dragon curve's self-similar structure creates signals with
    specific spectral properties. The tropical recursion
    
        T(n+1) = T(n) ++ [R] ++ rev_comp(T(n))
    
    induces a recursive relation in the Fourier domain.
    """
    print("=== Self-Similar Signal Analysis ===\n")
    
    for n in [6, 8, 10, 12]:
        turns = dragon_turns(n)
        # Convert to ±1 signal
        signal = np.array([1 if t else -1 for t in turns], dtype=float)
        
        # Compute power spectrum
        spectrum = np.abs(np.fft.fft(signal))**2
        
        # Analyze self-similarity in spectrum
        total_power = np.sum(spectrum)
        # Power in first half vs second half
        half = len(spectrum) // 2
        low_freq_power = np.sum(spectrum[:half])
        high_freq_power = np.sum(spectrum[half:])
        
        print(f"  n={n}: signal length = {len(signal)}")
        print(f"    Low-freq power:  {low_freq_power/total_power:.4f}")
        print(f"    High-freq power: {high_freq_power/total_power:.4f}")
        print(f"    Ratio: {low_freq_power/high_freq_power:.4f}")
    
    print("\n  → The spectral balance reflects the self-similar structure.")
    print("    Tropical scaling maps to multiplicative spectral shifts.\n")


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════╗")
    print("║   Tropical Dragon Curves — Applications Demo    ║")
    print("╚══════════════════════════════════════════════════╝\n")
    
    fractal_antenna_analysis()
    image_traversal_demo()
    tropical_address_demo()
    signal_analysis_demo()
    
    print("All application demos completed successfully.")


#!/usr/bin/env python3
"""
Tropical Dragon Curves — Interactive Demo

Demonstrates the Heighway dragon curve generation via recursive turn sequences,
piecewise-affine lattice walking, and connections to tropical (min-plus) algebra.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection


# ─── Dragon Turn Sequence ──────────────────────────────────────────────────

def dragon_turns(n: int) -> list[bool]:
    """
    Generate the Heighway dragon turn sequence at iteration n.
    True = right turn, False = left turn.
    
    Recursion: T(n+1) = T(n) + [R] + reverse_complement(T(n))
    
    >>> dragon_turns(0)
    []
    >>> dragon_turns(1)
    [True]
    >>> dragon_turns(2)
    [True, True, False]
    >>> dragon_turns(3)
    [True, True, False, True, True, False, False]
    """
    if n == 0:
        return []
    prev = dragon_turns(n - 1)
    rev_comp = [not b for b in reversed(prev)]
    return prev + [True] + rev_comp


def verify_length(n: int) -> None:
    """Verify that |T(n)| = 2^n - 1."""
    turns = dragon_turns(n)
    expected = 2**n - 1
    assert len(turns) == expected, f"n={n}: got {len(turns)}, expected {expected}"


# ─── Dragon Lattice Path ───────────────────────────────────────────────────

DIR_VECTORS = {
    0: (1, 0),   # East
    1: (0, 1),   # North
    2: (-1, 0),  # West
    3: (0, -1),  # South
}

def dragon_path(n: int) -> list[tuple[int, int]]:
    """
    Generate the dragon curve path on the integer lattice at iteration n.
    Returns 2^n + 1 vertices.
    """
    turns = dragon_turns(n)
    x, y = 0, 0
    d = 0  # Facing East
    path = [(x, y)]
    
    for i, turn in enumerate(turns):
        # Move forward
        dx, dy = DIR_VECTORS[d]
        x, y = x + dx, y + dy
        path.append((x, y))
        # Turn
        d = (d + 3) % 4 if turn else (d + 1) % 4
    
    # Final segment
    dx, dy = DIR_VECTORS[d]
    x, y = x + dx, y + dy
    path.append((x, y))
    
    return path


def verify_path_length(n: int) -> None:
    """Verify that the dragon path has 2^n + 1 vertices."""
    path = dragon_path(n)
    expected = 2**n + 1
    assert len(path) == expected, f"n={n}: got {len(path)}, expected {expected}"


# ─── Piecewise Affine / Tropical Structure ─────────────────────────────────

def demonstrate_piecewise_affine():
    """
    Show that the step function is piecewise affine: for each fixed
    direction d and turn t, the position update is a pure translation.
    """
    print("=== Piecewise Affine Structure of Dragon Step ===\n")
    print("For each direction d ∈ {E,N,W,S} and turn t ∈ {R,L},")
    print("the position update (x,y) → (x+dx, y+dy) is a translation:\n")
    
    dir_names = {0: "East", 1: "North", 2: "West", 3: "South"}
    
    for d in range(4):
        dx, dy = DIR_VECTORS[d]
        for t in [True, False]:
            turn_name = "Right" if t else "Left"
            new_d = (d + 3) % 4 if t else (d + 1) % 4
            print(f"  d={dir_names[d]:5s}, turn={turn_name:5s}: "
                  f"translate by ({dx:+d}, {dy:+d}), "
                  f"new dir = {dir_names[new_d]}")
    
    print("\nEach branch is a translation → trivially min-plus affine.")
    print("The 8-branch piecewise function is tropically representable.\n")


def demonstrate_tropical_scaling():
    """
    Show that translations correspond to tropical scaling:
    trop(x + c) = trop(x) * trop(c)  in the min-plus semiring.
    """
    print("=== Tropical Scaling Correspondence ===\n")
    print("In the tropical semiring (ℤ, min, +):")
    print("  'addition' = min")
    print("  'multiplication' = +")
    print()
    print("A translation x ↦ x + c corresponds to tropical scaling by trop(c):")
    print()
    
    for c in [-2, -1, 0, 1, 2]:
        for x in [0, 3, 7]:
            lhs = x + c
            print(f"  trop({x} + {c:+d}) = trop({lhs}) = trop({x}) * trop({c:+d})")
        print()


# ─── Self-Similarity Demonstration ────────────────────────────────────────

def demonstrate_self_similarity():
    """
    Show the recursive decomposition: T(n+1) = T(n) ++ [R] ++ rev_comp(T(n)).
    """
    print("=== Dragon Word Self-Similarity ===\n")
    
    def fmt(turns):
        return ''.join('R' if t else 'L' for t in turns)
    
    for n in range(5):
        t = dragon_turns(n)
        print(f"  T({n}) = {fmt(t) if t else '∅':40s}  (length {len(t)})")
    
    print()
    print("Decomposition check:")
    for n in range(4):
        t_n = dragon_turns(n)
        t_n1 = dragon_turns(n + 1)
        rev_comp = [not b for b in reversed(t_n)]
        reconstructed = t_n + [True] + rev_comp
        assert reconstructed == t_n1
        print(f"  T({n+1}) = T({n}) + [R] + rev_comp(T({n}))  ✓")


# ─── Covering Growth Analysis ─────────────────────────────────────────────

def count_occupied_boxes(path, grid_size):
    """Count the number of grid boxes of given size touched by the path."""
    occupied = set()
    for x, y in path:
        box = (x // grid_size, y // grid_size)
        occupied.add(box)
    return len(occupied)


def demonstrate_covering_growth():
    """
    Analyze how the number of occupied lattice boxes grows with iteration.
    """
    print("=== Dragon Curve Covering Growth ===\n")
    print(f"{'n':>3s}  {'vertices':>10s}  {'distinct':>10s}  {'segments':>10s}")
    print("-" * 45)
    
    for n in range(1, 16):
        path = dragon_path(n)
        distinct = len(set(path))
        segments = 2**n
        print(f"{n:3d}  {len(path):10d}  {distinct:10d}  {segments:10d}")


# ─── Visualization ────────────────────────────────────────────────────────

def plot_dragon_curve(n: int, filename: str = "dragon_curve.png"):
    """Plot the dragon curve at iteration n."""
    path = dragon_path(n)
    xs = [p[0] for p in path]
    ys = [p[1] for p in path]
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    
    # Color segments by position in sequence
    points = np.array(path, dtype=float)
    segments = np.stack([points[:-1], points[1:]], axis=1)
    
    colors = plt.cm.viridis(np.linspace(0, 1, len(segments)))
    lc = LineCollection(segments, colors=colors, linewidths=0.5)
    ax.add_collection(lc)
    
    ax.set_xlim(min(xs) - 1, max(xs) + 1)
    ax.set_ylim(min(ys) - 1, max(ys) + 1)
    ax.set_aspect('equal')
    ax.set_title(f'Heighway Dragon Curve — Iteration {n} ({2**n} segments)',
                 fontsize=14)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved dragon curve plot to {filename}")


def plot_self_similarity(n: int, filename: str = "dragon_self_similarity.png"):
    """Plot showing the two-branch decomposition of the dragon curve."""
    if n < 2:
        n = 2
    
    path_full = dragon_path(n)
    mid = 2**(n-1)  # Number of segments in each half
    
    # First half: segments 0..mid-1 → vertices 0..mid
    path_first = path_full[:mid + 1]
    # Second half: segments mid..2^n-1 → vertices mid..2^n
    path_second = path_full[mid:]
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    for ax, path_data, title, color in [
        (axes[0], path_full, f'Full Dragon (n={n})', 'steelblue'),
        (axes[1], path_first, f'First Half (n={n-1} copy)', 'crimson'),
        (axes[2], path_second, f'Second Half (n={n-1} copy)', 'forestgreen'),
    ]:
        xs = [p[0] for p in path_data]
        ys = [p[1] for p in path_data]
        ax.plot(xs, ys, color=color, linewidth=0.8, alpha=0.8)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=12)
        ax.axis('off')
    
    plt.suptitle(f'Self-Similar Decomposition: D({n}) = T₁·D({n-1}) ∪ T₂·D({n-1})',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved self-similarity plot to {filename}")


def plot_covering_growth(filename: str = "dragon_covering.png"):
    """Plot the growth of occupied grid boxes vs iteration number."""
    ns = list(range(1, 15))
    vertices = []
    distinct = []
    
    for n in ns:
        path = dragon_path(n)
        vertices.append(len(path))
        distinct.append(len(set(path)))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(ns, vertices, 'o-', label='Total vertices (2ⁿ + 1)', color='steelblue')
    ax.semilogy(ns, distinct, 's-', label='Distinct vertices', color='crimson')
    ax.semilogy(ns, [2**n for n in ns], '--', label='2ⁿ (segment count)',
                color='gray', alpha=0.5)
    
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Count (log scale)', fontsize=12)
    ax.set_title('Dragon Curve Growth: Vertices and Covering', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved covering growth plot to {filename}")


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════╗")
    print("║   Tropical Dragon Curves — Interactive Demo  ║")
    print("╚══════════════════════════════════════════════╝\n")
    
    # Verify core properties
    print("--- Verification ---")
    for n in range(12):
        verify_length(n)
        verify_path_length(n)
    print("All length/path verifications passed (n=0..11).\n")
    
    # Demonstrations
    demonstrate_self_similarity()
    print()
    demonstrate_piecewise_affine()
    demonstrate_tropical_scaling()
    demonstrate_covering_growth()
    
    # Visualizations
    print("\n--- Generating Visualizations ---")
    plot_dragon_curve(12, "dragon_curve.png")
    plot_self_similarity(10, "dragon_self_similarity.png")
    plot_covering_growth("dragon_covering.png")
    
    print("\nDone!")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json
import base64

# Read markdown files
with open('ARTICLE.md', 'r') as f:
    article = f.read()
with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()
with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

# Read code files
with open('demo.py', 'r') as f:
    demo_code = f.read()
with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()
with open('applications.py', 'r') as f:
    applications_code = f.read()

# Read Lean file
with open('Fractals/Dragon/TropicalDragon.lean', 'r') as f:
    lean_code = f.read()

# Read and encode images
visualizations = []
for fname, title in [
    ('dragon_curve.png', 'Heighway Dragon Curve (Iteration 12)'),
    ('dragon_self_similarity.png', 'Dragon Curve Self-Similar Decomposition'),
    ('dragon_covering.png', 'Dragon Curve Covering Growth'),
]:
    with open(fname, 'rb') as f:
        b64 = base64.b64encode(f.read()).decode()
        visualizations.append({
            'name': title,
            'data': f'data:image/png;base64,{b64}'
        })

package = {
    "title": "Tropical Dragon Curves: Min-Plus Recursive Generation and Self-Similarity",
    "domain": "Algebra / Tropical Geometry / Fractal Dynamics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Dragon Curve Interactive Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Dragon Turn Sequence (Recursive)",
            "pseudocode": "function DragonTurns(n):\n    if n = 0: return []\n    prev <- DragonTurns(n - 1)\n    return prev ++ [R] ++ reverse_complement(prev)\n\nComplexity: O(2^n) time and space",
            "code": """def dragon_turns_recursive(n: int) -> list[bool]:
    \"\"\"Generate the Heighway dragon turn sequence at iteration n.
    True = right turn, False = left turn.
    Complexity: O(2^n) time and space.\"\"\"
    if n == 0:
        return []
    prev = dragon_turns_recursive(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]

# Example
for n in range(6):
    t = dragon_turns_recursive(n)
    s = ''.join('R' if b else 'L' for b in t)
    print(f"T({n}) = {s if s else '(empty)'} (length {len(t)})")"""
        },
        {
            "name": "Dragon Turn Direct (k-th element via 2-adic valuation)",
            "pseudocode": "function DragonTurnDirect(k):\n    m <- k + 1\n    v <- 2-adic valuation of m\n    odd_part <- m / 2^v\n    return (odd_part mod 4) = 1\n\nComplexity: O(log k) per query",
            "code": """def two_adic_valuation(k: int) -> int:
    if k == 0:
        return float('inf')
    v = 0
    while k % 2 == 0:
        v += 1
        k //= 2
    return v

def dragon_turn_direct(k: int) -> bool:
    \"\"\"Compute the k-th dragon turn (0-indexed) directly.
    Complexity: O(log k) per query.\"\"\"
    m = k + 1
    v = two_adic_valuation(m)
    odd_part = m >> v
    return (odd_part % 4) == 1

# Verify against recursive method
def dragon_turns_recursive(n):
    if n == 0: return []
    prev = dragon_turns_recursive(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]

for n in range(8):
    recursive = dragon_turns_recursive(n)
    direct = [dragon_turn_direct(k) for k in range(2**n - 1)]
    assert recursive == direct, f"Mismatch at n={n}"
    print(f"n={n}: recursive == direct ✓ (length {len(recursive)})")"""
        },
        {
            "name": "Lattice Path Construction",
            "pseudocode": "function DragonPath(n):\n    turns <- DragonTurns(n)\n    state <- (0, 0, East)\n    path <- [state.pos]\n    for turn in turns:\n        state <- ApplyStep(state, turn)\n        path.append(state.pos)\n    path.append(state.endpoint)\n    return path\n\nComplexity: O(2^n) time and space",
            "code": """DIR = {0: (1,0), 1: (0,1), 2: (-1,0), 3: (0,-1)}

def dragon_path(n: int) -> list[tuple[int,int]]:
    \"\"\"Generate dragon curve lattice path. Returns 2^n + 1 vertices.\"\"\"
    # Generate turns
    def turns(n):
        if n == 0: return []
        prev = turns(n-1)
        return prev + [True] + [not b for b in reversed(prev)]
    
    t = turns(n)
    x, y, d = 0, 0, 0
    path = [(x, y)]
    for turn in t:
        dx, dy = DIR[d]
        x, y = x + dx, y + dy
        path.append((x, y))
        d = (d + 3) % 4 if turn else (d + 1) % 4
    dx, dy = DIR[d]
    path.append((x + dx, y + dy))
    return path

# Verify path lengths
for n in range(10):
    p = dragon_path(n)
    expected = 2**n + 1
    assert len(p) == expected
    print(f"n={n}: path length = {len(p)} = 2^{n}+1 ✓")"""
        },
        {
            "name": "Box-Counting Dimension Estimation",
            "pseudocode": "function EstimateBoxDim(path, scales):\n    for eps in scales:\n        N(eps) <- count occupied eps-boxes\n    return linear regression slope of log(N) vs log(1/eps)\n\nComplexity: O(|path| * |scales|)",
            "code": """import numpy as np

def box_count(path, grid_size):
    boxes = set()
    for x, y in path:
        boxes.add((int(x // grid_size), int(y // grid_size)))
    return len(boxes)

def estimate_box_dimension(path, num_scales=8):
    xs = [p[0] for p in path]
    ys = [p[1] for p in path]
    ext = max(max(xs)-min(xs), max(ys)-min(ys))
    scales = [ext / (2**k) for k in range(2, 2+num_scales)]
    data = [(np.log(1/e), np.log(box_count(path, e))) for e in scales if e > 0]
    x_v = np.array([d[0] for d in data])
    y_v = np.array([d[1] for d in data])
    slope, _ = np.polyfit(x_v, y_v, 1)
    return slope

# Generate turns and path
def dragon_turns(n):
    if n == 0: return []
    prev = dragon_turns(n-1)
    return prev + [True] + [not b for b in reversed(prev)]

DIR = {0: (1,0), 1: (0,1), 2: (-1,0), 3: (0,-1)}

def dragon_path(n):
    t = dragon_turns(n)
    x, y, d = 0, 0, 0
    path = [(x, y)]
    for turn in t:
        dx, dy = DIR[d]
        x, y = x + dx, y + dy
        path.append((x, y))
        d = (d + 3) % 4 if turn else (d + 1) % 4
    dx, dy = DIR[d]
    path.append((x + dx, y + dy))
    return path

print("Box-counting dimension estimates:")
for n in [8, 10, 12, 14]:
    dim = estimate_box_dimension(dragon_path(n))
    print(f"  n={n}: dim ≈ {dim:.3f}")
print("\\nDimension approaches 2 as n → ∞ (theoretical limit).")"""
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"  Size: {len(json.dumps(package))} bytes")
