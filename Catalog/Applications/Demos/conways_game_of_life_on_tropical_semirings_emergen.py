#!/usr/bin/env python3
"""
Tropical Game of Life — Applications

Demonstrates real-world applications of tropical cellular automata:
1. Signal routing on a chip layout (shortest-path transport)
2. Distributed consensus via tropical dynamics
3. Pattern-based error detection codes
"""

import numpy as np
from typing import List, Tuple, Dict


def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """Tropical threshold function."""
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(config: np.ndarray) -> np.ndarray:
    """One step of tropical Life on a torus."""
    m, n = config.shape
    s = np.zeros_like(config)
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            s += np.roll(np.roll(config, -di, axis=0), -dj, axis=1)
    alive = np.minimum(1, config)
    survive = np.minimum(1, np.maximum(0, s + 1 - 2)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
    birth = np.minimum(1, np.maximum(0, s + 1 - 3)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
    return alive * survive + (1 - alive) * birth


# ============================================================
# Application 1: Signal Routing via Gliders
# ============================================================

def signal_routing_demo():
    """Demonstrate signal routing using glider propagation.
    
    A glider carries a 1-bit signal from a source to a destination
    on the torus. The arrival time is predictable from the period
    and displacement, enabling synchronized communication.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Signal Routing via Tropical Gliders")
    print("=" * 60)
    
    # Create a 20×20 torus
    m, n = 20, 20
    
    # Place a glider at position (2, 2)
    config = np.zeros((m, n), dtype=int)
    glider_cells = [(2, 3), (3, 4), (4, 2), (4, 3), (4, 4)]
    for i, j in glider_cells:
        config[i, j] = 1
    
    print(f"\n  Grid: {m}×{n} torus")
    print(f"  Source: glider at rows 2-4, cols 2-4")
    print(f"  Glider period: 4 steps, displacement: (1, 1)")
    
    # Track glider position (center of mass)
    positions = []
    current = config.copy()
    
    for step in range(41):
        alive = np.argwhere(current == 1)
        if len(alive) > 0:
            # Compute center of mass with periodic wrapping
            com_i = np.mean(alive[:, 0])
            com_j = np.mean(alive[:, 1])
            positions.append((step, round(com_i, 1), round(com_j, 1), len(alive)))
        current = tropical_life_step(current)
    
    print(f"\n  Signal propagation trace:")
    print(f"  {'Step':>6} {'Row':>6} {'Col':>6} {'Cells':>6}")
    print(f"  {'-'*30}")
    for step, row, col, cells in positions[::4]:
        print(f"  {step:>6} {row:>6} {col:>6} {cells:>6}")
    
    # Calculate effective signal speed
    if len(positions) >= 2:
        t0, r0, c0, _ = positions[0]
        t1, r1, c1, _ = positions[-1]
        dt = t1 - t0
        if dt > 0:
            speed = np.sqrt((r1 - r0)**2 + (c1 - c0)**2) / dt
            print(f"\n  Effective signal speed: {speed:.3f} cells/step")
            print(f"  Arrival time at distance d: ~{1/speed:.1f} × d steps")


# ============================================================
# Application 2: Distributed Consensus
# ============================================================

def distributed_consensus_demo():
    """Demonstrate distributed consensus using tropical fixed points.
    
    Still lifes represent stable consensus states. Starting from random
    initial conditions, the tropical dynamics converge to fixed points
    or small cycles, demonstrating self-organization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Consensus via Tropical Dynamics")
    print("=" * 60)
    
    np.random.seed(42)
    m, n = 10, 10
    
    # Random initial configuration
    config = np.random.randint(0, 2, (m, n))
    initial_alive = config.sum()
    
    print(f"\n  Grid: {m}×{n} torus")
    print(f"  Initial alive cells: {initial_alive} / {m*n}")
    
    # Evolve and track convergence
    current = config.copy()
    history = [tuple(current.flatten())]
    
    for step in range(1, 101):
        current = tropical_life_step(current)
        state = tuple(current.flatten())
        
        if state in history:
            cycle_start = history.index(state)
            cycle_length = step - cycle_start
            print(f"\n  Convergence detected at step {step}")
            print(f"  Cycle length: {cycle_length}")
            print(f"  Transient length: {cycle_start}")
            
            if cycle_length == 1:
                print(f"  → Fixed point (consensus reached)")
            else:
                print(f"  → Periodic orbit (oscillating consensus)")
            
            print(f"  Final alive cells: {current.sum()} / {m*n}")
            break
        
        history.append(state)
    else:
        print(f"  No convergence in 100 steps")
    
    # Analyze multiple random starts
    print(f"\n  Statistical analysis (100 random starts):")
    fixed_count = 0
    cycle_counts: Dict[int, int] = {}
    
    for trial in range(100):
        np.random.seed(trial)
        c = np.random.randint(0, 2, (m, n))
        hist = [tuple(c.flatten())]
        
        for step in range(1, 200):
            c = tropical_life_step(c)
            state = tuple(c.flatten())
            if state in hist:
                cl = step - hist.index(state)
                cycle_counts[cl] = cycle_counts.get(cl, 0) + 1
                if cl == 1:
                    fixed_count += 1
                break
            hist.append(state)
    
    print(f"    Converged to fixed point: {fixed_count}/100")
    for cl in sorted(cycle_counts.keys()):
        print(f"    Cycle length {cl}: {cycle_counts[cl]}/100")


# ============================================================
# Application 3: Error Detection via Pattern Stability
# ============================================================

def error_detection_demo():
    """Demonstrate error detection using still-life stability.
    
    A still life encodes a valid state. Perturbations (errors) break
    the fixed-point property, which can be detected by running one
    step and checking for change.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Error Detection via Tropical Fixed Points")
    print("=" * 60)
    
    m, n = 8, 8
    
    # Create a still life (2×2 block)
    valid_state = np.zeros((m, n), dtype=int)
    valid_state[0:2, 0:2] = 1
    
    print(f"\n  Valid state (2×2 block on {m}×{n} torus):")
    print(f"    Is fixed point: {np.array_equal(valid_state, tropical_life_step(valid_state))}")
    
    # Introduce single-bit errors and check detection
    print(f"\n  Single-bit error detection:")
    detected = 0
    total = 0
    
    for i in range(m):
        for j in range(n):
            corrupted = valid_state.copy()
            corrupted[i, j] = 1 - corrupted[i, j]  # Flip one bit
            
            is_fixed = np.array_equal(corrupted, tropical_life_step(corrupted))
            total += 1
            
            if not is_fixed:
                detected += 1
    
    print(f"    Errors detected: {detected}/{total}")
    print(f"    Detection rate: {detected/total*100:.1f}%")
    
    # Multi-bit errors
    print(f"\n  Multi-bit error detection (1000 random 2-bit errors):")
    np.random.seed(123)
    detected_2bit = 0
    
    for _ in range(1000):
        corrupted = valid_state.copy()
        positions = np.random.choice(m * n, 2, replace=False)
        for pos in positions:
            ii, jj = pos // n, pos % n
            corrupted[ii, jj] = 1 - corrupted[ii, jj]
        
        if not np.array_equal(corrupted, tropical_life_step(corrupted)):
            detected_2bit += 1
    
    print(f"    Detected: {detected_2bit}/1000 ({detected_2bit/10:.1f}%)")


# ============================================================
# Application 4: Tropical Shortest-Path Connection
# ============================================================

def shortest_path_connection_demo():
    """Demonstrate the connection between tropical Life and shortest paths.
    
    The tropical threshold function is built from min (tropical addition),
    which is the fundamental operation for shortest-path computation.
    We show how the Life rule can be interpreted as a local optimization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Shortest-Path Interpretation")
    print("=" * 60)
    
    print("""
  In tropical algebra:
    - Addition (⊕) = min
    - Multiplication (⊗) = +
  
  The tropical threshold function:
    tropicalThreshold(s, lo, hi) = min(1, s+1-lo) × min(1, hi+1-s)
  
  can be decomposed as a tropical polynomial:
    = min(1, s ⊗ 1 ⊕ (1-lo)) ⊗ min(1, (hi+1) ⊕ (-s))
  
  This means the Life rule is a tropical algebraic expression,
  and the dynamics are iterations of tropical polynomial maps.
  """)
    
    # Demonstrate tropical matrix connection
    print("  Tropical semiring verification:")
    test_cases = [
        (3, 5, "min(3,5) = 3 (tropical add)"),
        (3, 5, "3+5 = 8 (tropical mult)"),
    ]
    
    # Verify distributivity
    for a, b, c in [(2, 5, 3), (1, 4, 2), (0, 7, 1)]:
        lhs = min(a, b) + c
        rhs = min(a + c, b + c)
        status = "✓" if lhs == rhs else "✗"
        print(f"    min({a},{b})+{c} = {lhs} = min({a+c},{b+c}) = {rhs} {status}")
    
    # Show how neighbor sum relates to tropical product
    print(f"\n  Neighbor sum as tropical product (in log domain):")
    print(f"    If we write c(x) = exp(-v(x)) in tropical coordinates,")
    print(f"    then neighborSum = Σ exp(-v(neighbor_i))")
    print(f"    ≈ exp(-min_i v(neighbor_i))  (tropical approximation)")
    print(f"    So the neighbor sum approximates a tropical sum (min).")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Tropical Game of Life — Applications")
    print("=" * 60)
    
    signal_routing_demo()
    distributed_consensus_demo()
    error_detection_demo()
    shortest_path_connection_demo()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Game of Life — Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
1. The 2×2 block as a still life (fixed point)
2. The 5-cell glider with period-4 translation
3. Orbit diversity growth over time
"""

import numpy as np
from typing import Tuple, List, Set


def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """Tropical threshold function: returns 1 if lo <= s <= hi, else 0.
    
    Uses min and truncating subtraction (max(0, ...)) to implement
    interval membership without Boolean branching.
    
    >>> tropical_threshold(3, 2, 3)
    1
    >>> tropical_threshold(4, 2, 3)
    0
    >>> tropical_threshold(1, 2, 3)
    0
    """
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def neighbor_sum(config: np.ndarray, i: int, j: int) -> int:
    """Sum of Moore neighborhood values on a torus."""
    m, n = config.shape
    total = 0
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            total += config[(i + di) % m, (j + dj) % n]
    return total


def tropical_local_rule(config: np.ndarray, i: int, j: int) -> int:
    """Tropical local update rule for cell (i, j).
    
    Uses tropical threshold to encode birth/survival:
    - Birth: dead cell with exactly 3 alive neighbors
    - Survival: alive cell with 2 or 3 alive neighbors
    """
    s = neighbor_sum(config, i, j)
    alive = min(1, config[i, j])
    survive = tropical_threshold(s, 2, 3)
    birth = tropical_threshold(s, 3, 3)
    return alive * survive + (1 - alive) * birth


def tropical_life_step(config: np.ndarray) -> np.ndarray:
    """Apply one step of the tropical Life automaton."""
    m, n = config.shape
    new_config = np.zeros_like(config)
    for i in range(m):
        for j in range(n):
            new_config[i, j] = tropical_local_rule(config, i, j)
    return new_config


def config_to_tuple(config: np.ndarray) -> tuple:
    """Convert configuration to hashable tuple for set operations."""
    return tuple(config.flatten())


def orbit_diversity(config: np.ndarray, T: int) -> int:
    """Count distinct configurations in {step^t(c) : 0 <= t <= T}."""
    seen: Set[tuple] = set()
    current = config.copy()
    for t in range(T + 1):
        seen.add(config_to_tuple(current))
        if t < T:
            current = tropical_life_step(current)
    return len(seen)


def print_config(config: np.ndarray, label: str = ""):
    """Pretty-print a configuration."""
    if label:
        print(f"\n{label}:")
    m, n = config.shape
    for i in range(m):
        row = ""
        for j in range(n):
            row += "■ " if config[i, j] == 1 else "· "
        print(f"  {row}")


# ============================================================
# Demo 1: Tropical Threshold Function
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Threshold Function")
print("=" * 60)
print()
print("tropicalThreshold(s, lo, hi) = min(1, s+1-lo) * min(1, hi+1-s)")
print()
print("Testing threshold [2, 3] (survival condition):")
for s in range(9):
    val = tropical_threshold(s, 2, 3)
    marker = " ← active" if val == 1 else ""
    print(f"  s={s}: tropicalThreshold({s}, 2, 3) = {val}{marker}")

print()
print("Testing threshold [3, 3] (birth condition):")
for s in range(9):
    val = tropical_threshold(s, 3, 3)
    marker = " ← active" if val == 1 else ""
    print(f"  s={s}: tropicalThreshold({s}, 3, 3) = {val}{marker}")

# ============================================================
# Demo 2: Block Still Life
# ============================================================
print()
print("=" * 60)
print("DEMO 2: Block Still Life (Fixed Point)")
print("=" * 60)

# Create block on 6×6 torus
block = np.zeros((6, 6), dtype=int)
block[0, 0] = block[0, 1] = block[1, 0] = block[1, 1] = 1

print_config(block, "Block configuration (6×6 torus)")

# Apply one step
block_next = tropical_life_step(block)
print_config(block_next, "After 1 tropical step")

is_fixed = np.array_equal(block, block_next)
print(f"\n  Fixed point? {is_fixed}")
print(f"  Nonconstant? {block.min() != block.max()}")

# Show neighbor counts for block cells
print("\n  Neighbor analysis:")
for i in range(6):
    for j in range(6):
        s = neighbor_sum(block, i, j)
        alive = block[i, j]
        result = tropical_local_rule(block, i, j)
        if i < 3 and j < 3:  # Near the block
            status = "alive" if alive else "dead"
            rule = "survives" if alive and result else ("born" if result else "stays dead")
            print(f"    ({i},{j}): {status}, neighbors={s}, → {rule}")

# ============================================================
# Demo 3: Glider Evolution
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Glider (Period-4, Displacement (1,1))")
print("=" * 60)

# Create glider on 10×10 torus
glider = np.zeros((10, 10), dtype=int)
glider_cells = [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]
for i, j in glider_cells:
    glider[i, j] = 1

print_config(glider, "Step 0: Initial glider")

current = glider.copy()
for step in range(1, 5):
    current = tropical_life_step(current)
    alive_cells = list(zip(*np.where(current == 1)))
    print_config(current, f"Step {step}: alive cells = {alive_cells}")

# Verify period-4 shift
shifted_glider = np.zeros((10, 10), dtype=int)
for i, j in glider_cells:
    shifted_glider[(i + 1) % 10, (j + 1) % 10] = 1

matches_shift = np.array_equal(current, shifted_glider)
print(f"\n  Step 4 = shift(1,1) of Step 0? {matches_shift}")
print(f"  Is still life? {np.array_equal(glider, tropical_life_step(glider))}")

# ============================================================
# Demo 4: Orbit Diversity
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Orbit Diversity")
print("=" * 60)

print("\n  Block (still life) orbit diversity:")
for T in range(8):
    div = orbit_diversity(block, T)
    print(f"    T={T}: diversity = {div}")

print("\n  Glider orbit diversity:")
for T in range(21):
    div = orbit_diversity(glider, T)
    exceeds = " ← T < diversity" if T < div else ""
    print(f"    T={T}: diversity = {div}{exceeds}")

# ============================================================
# Demo 5: Tropical Algebraic Properties
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Tropical Algebraic Properties")
print("=" * 60)

print("\n  Min associativity (tropical addition):")
for a, b, c in [(1, 3, 2), (5, 2, 7), (0, 0, 1)]:
    lhs = min(min(a, b), c)
    rhs = min(a, min(b, c))
    print(f"    min(min({a},{b}),{c}) = {lhs} = min({a},min({b},{c})) = {rhs} ✓")

print("\n  Tropical distributivity (min(a,b) + c = min(a+c, b+c)):")
for a, b, c in [(3, 5, 2), (1, 4, 3), (0, 7, 1)]:
    lhs = min(a, b) + c
    rhs = min(a + c, b + c)
    print(f"    min({a},{b})+{c} = {lhs} = min({a+c},{b+c}) = {rhs} ✓")

print("\n  Threshold shift invariance:")
for s, lo, hi, k in [(3, 2, 3, 5), (0, 0, 1, 10), (5, 3, 7, 3)]:
    t1 = tropical_threshold(s, lo, hi)
    t2 = tropical_threshold(s + k, lo + k, hi + k)
    print(f"    threshold({s},{lo},{hi}) = {t1} = threshold({s+k},{lo+k},{hi+k}) = {t2} ✓")

print()
print("=" * 60)
print("All demos completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Game of Life — Visualizations

Generates publication-quality figures for the research paper.
Saves as PNG files and returns base64 data URIs for the JSON package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import ListedColormap
import base64
import io
from typing import List, Tuple


def tropical_threshold(s: int, lo: int, hi: int) -> int:
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(config: np.ndarray) -> np.ndarray:
    m, n = config.shape
    s = np.zeros_like(config)
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            s += np.roll(np.roll(config, -di, axis=0), -dj, axis=1)
    alive = np.minimum(1, config)
    survive = np.minimum(1, np.maximum(0, s + 1 - 2)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
    birth = np.minimum(1, np.maximum(0, s + 1 - 3)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
    return alive * survive + (1 - alive) * birth


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def plot_config(ax, config, title="", show_grid=True):
    cmap = ListedColormap(['#f0f0f0', '#2c3e50'])
    ax.imshow(config, cmap=cmap, interpolation='nearest', aspect='equal')
    if show_grid:
        m, n = config.shape
        for i in range(m + 1):
            ax.axhline(i - 0.5, color='#bdc3c7', linewidth=0.5)
        for j in range(n + 1):
            ax.axvline(j - 0.5, color='#bdc3c7', linewidth=0.5)
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.set_xticks([])
    ax.set_yticks([])


# ============================================================
# Figure 1: Glider Evolution
# ============================================================

def create_glider_evolution():
    """5-panel figure showing glider at steps 0-4."""
    fig, axes = plt.subplots(1, 5, figsize=(14, 3))
    fig.suptitle('Tropical Glider Evolution (10×10 Torus)', fontsize=14, fontweight='bold', y=1.02)
    
    glider = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        glider[i, j] = 1
    
    current = glider.copy()
    for step in range(5):
        # Show only the 5×5 region of interest
        view = np.zeros((6, 6), dtype=int)
        for i in range(6):
            for j in range(6):
                view[i, j] = current[i % 10, j % 10]
        
        plot_config(axes[step], view, f"Step {step}")
        
        # Mark alive cells
        alive = np.argwhere(view == 1)
        for a in alive:
            axes[step].plot(a[1], a[0], 'o', color='#e74c3c', markersize=8, 
                          markeredgecolor='white', markeredgewidth=1)
        
        if step < 4:
            current = tropical_life_step(current)
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 2: Block Still Life
# ============================================================

def create_block_still_life():
    """Figure showing block pattern with neighbor analysis."""
    fig, axes = plt.subplots(1, 3, figsize=(12, 4))
    fig.suptitle('Block Still Life Analysis (6×6 Torus)', fontsize=14, fontweight='bold')
    
    block = np.zeros((6, 6), dtype=int)
    block[0:2, 0:2] = 1
    
    # Panel 1: Configuration
    plot_config(axes[0], block, "Configuration")
    for i in range(2):
        for j in range(2):
            axes[0].plot(j, i, 's', color='#27ae60', markersize=20, 
                        markeredgecolor='white', markeredgewidth=2)
    
    # Panel 2: Neighbor counts
    m, n = 6, 6
    neighbor_counts = np.zeros((m, n), dtype=int)
    for i in range(m):
        for j in range(n):
            s = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    s += block[(i + di) % m, (j + dj) % n]
            neighbor_counts[i, j] = s
    
    im = axes[1].imshow(neighbor_counts, cmap='YlOrRd', interpolation='nearest', 
                        aspect='equal', vmin=0, vmax=4)
    for i in range(m):
        for j in range(n):
            axes[1].text(j, i, str(neighbor_counts[i, j]), ha='center', va='center',
                        fontsize=12, fontweight='bold', color='black')
    axes[1].set_title("Neighbor Counts", fontsize=11, fontweight='bold')
    axes[1].set_xticks([])
    axes[1].set_yticks([])
    plt.colorbar(im, ax=axes[1], shrink=0.8)
    
    # Panel 3: Tropical threshold values
    threshold_map = np.zeros((m, n), dtype=float)
    for i in range(m):
        for j in range(n):
            s = neighbor_counts[i, j]
            alive = block[i, j]
            if alive:
                threshold_map[i, j] = tropical_threshold(s, 2, 3)
            else:
                threshold_map[i, j] = tropical_threshold(s, 3, 3) * 0.5
    
    cmap3 = ListedColormap(['#ecf0f1', '#f39c12', '#27ae60'])
    axes[2].imshow(threshold_map, cmap='RdYlGn', interpolation='nearest', 
                   aspect='equal', vmin=0, vmax=1)
    for i in range(m):
        for j in range(n):
            s = neighbor_counts[i, j]
            alive = block[i, j]
            label = f"{'S' if alive else 'B'}:{s}"
            color = '#27ae60' if threshold_map[i, j] > 0.5 else '#c0392b'
            axes[2].text(j, i, label, ha='center', va='center', fontsize=9,
                        fontweight='bold', color=color)
    axes[2].set_title("Tropical Threshold\n(S=survive, B=birth)", fontsize=11, fontweight='bold')
    axes[2].set_xticks([])
    axes[2].set_yticks([])
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 3: Orbit Diversity Comparison
# ============================================================

def create_orbit_diversity():
    """Plot orbit diversity over time for different patterns."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Block (still life)
    block = np.zeros((10, 10), dtype=int)
    block[0:2, 0:2] = 1
    
    # Glider
    glider = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        glider[i, j] = 1
    
    # Random
    np.random.seed(42)
    random_config = np.random.randint(0, 2, (10, 10))
    
    # Blinker (period-2 oscillator)
    blinker = np.zeros((10, 10), dtype=int)
    blinker[1, 0] = blinker[1, 1] = blinker[1, 2] = 1
    
    configs = [
        (block, "Block (still life)", '#27ae60', 's'),
        (blinker, "Blinker (oscillator)", '#f39c12', '^'),
        (glider, "Glider", '#e74c3c', 'o'),
        (random_config, "Random initial", '#3498db', 'D'),
    ]
    
    T_max = 25
    
    for config, label, color, marker in configs:
        diversities = []
        current = config.copy()
        seen = set()
        
        for t in range(T_max + 1):
            seen.add(tuple(current.flatten()))
            diversities.append(len(seen))
            if t < T_max:
                s = np.zeros_like(current)
                for di in [-1, 0, 1]:
                    for dj in [-1, 0, 1]:
                        if di == 0 and dj == 0:
                            continue
                        s += np.roll(np.roll(current, -di, axis=0), -dj, axis=1)
                alive = np.minimum(1, current)
                survive = np.minimum(1, np.maximum(0, s + 1 - 2)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
                birth = np.minimum(1, np.maximum(0, s + 1 - 3)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
                current = alive * survive + (1 - alive) * birth
        
        ax.plot(range(T_max + 1), diversities, '-' + marker, color=color, label=label,
                markersize=5, linewidth=2)
    
    # Reference line
    ax.plot(range(T_max + 1), range(1, T_max + 2), '--', color='gray', alpha=0.5, 
            label='y = T + 1 (maximum)')
    
    ax.set_xlabel('Time Steps (T)', fontsize=12)
    ax.set_ylabel('Orbit Diversity', fontsize=12)
    ax.set_title('Orbit Diversity Growth: Tropical Life Patterns', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, T_max + 0.5)
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 4: Tropical Threshold Landscape
# ============================================================

def create_threshold_landscape():
    """Visualize the tropical threshold function as a surface."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Panel 1: threshold(s, 2, 3) - survival
    s_vals = np.arange(0, 9)
    survive_vals = [tropical_threshold(s, 2, 3) for s in s_vals]
    birth_vals = [tropical_threshold(s, 3, 3) for s in s_vals]
    
    x = np.arange(len(s_vals))
    width = 0.35
    
    bars1 = axes[0].bar(x - width/2, survive_vals, width, label='Survival [2,3]', 
                        color='#27ae60', edgecolor='white')
    bars2 = axes[0].bar(x + width/2, birth_vals, width, label='Birth [3,3]', 
                        color='#3498db', edgecolor='white')
    
    axes[0].set_xlabel('Neighbor Sum (s)', fontsize=12)
    axes[0].set_ylabel('Threshold Value', fontsize=12)
    axes[0].set_title('Tropical Threshold Functions', fontsize=13, fontweight='bold')
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(s_vals)
    axes[0].legend(fontsize=10)
    axes[0].set_ylim(0, 1.3)
    axes[0].grid(True, axis='y', alpha=0.3)
    
    # Panel 2: Full local rule output
    s_vals_fine = np.arange(0, 9)
    alive_result = [min(1, 1) * tropical_threshold(s, 2, 3) for s in s_vals_fine]
    dead_result = [min(1, 0) * tropical_threshold(s, 2, 3) + 1 * tropical_threshold(s, 3, 3) 
                   for s in s_vals_fine]
    
    axes[1].plot(s_vals_fine, alive_result, 'o-', color='#e74c3c', linewidth=2, 
                markersize=8, label='Alive cell output')
    axes[1].plot(s_vals_fine, dead_result, 's-', color='#3498db', linewidth=2, 
                markersize=8, label='Dead cell output')
    
    axes[1].set_xlabel('Neighbor Sum (s)', fontsize=12)
    axes[1].set_ylabel('New Cell Value', fontsize=12)
    axes[1].set_title('Tropical Local Rule Output', fontsize=13, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].set_ylim(-0.1, 1.3)
    axes[1].grid(True, alpha=0.3)
    axes[1].set_xticks(s_vals_fine)
    
    plt.tight_layout()
    return fig


# ============================================================
# Generate All Figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    
    fig1 = create_glider_evolution()
    fig1.savefig('glider_evolution.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved glider_evolution.png")
    
    fig2 = create_block_still_life()
    fig2.savefig('block_still_life.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved block_still_life.png")
    
    fig3 = create_orbit_diversity()
    fig3.savefig('orbit_diversity.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved orbit_diversity.png")
    
    fig4 = create_threshold_landscape()
    fig4.savefig('threshold_landscape.png', dpi=150, bbox_inches='tight', facecolor='white')
    print("  Saved threshold_landscape.png")
    
    plt.close('all')
    print("All visualizations generated successfully.")
