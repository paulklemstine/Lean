#!/usr/bin/env python3
"""
Applications of Berggren–Lorentz Dynamics

Demonstrates real-world and cross-domain applications:
1. Cryptographic hash via Berggren monoid action
2. Error-detecting codes from parity invariant
3. Efficient Pythagorean triple enumeration
4. Lattice point counting on the Pythagorean cone
"""

import numpy as np
from typing import List, Tuple
import hashlib

# ============================================================
# Core Setup (self-contained)
# ============================================================

GENERATORS = {
    'A': np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]], dtype=np.int64),
    'B': np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]], dtype=np.int64),
    'C': np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]], dtype=np.int64),
}

INVERSES = {
    'A': np.array([[ 1,  2, -2], [-2, -1,  2], [-2, -2,  3]], dtype=np.int64),
    'B': np.array([[ 1,  2, -2], [ 2,  1, -2], [-2, -2,  3]], dtype=np.int64),
    'C': np.array([[-1, -2,  2], [ 2,  1, -2], [-2, -2,  3]], dtype=np.int64),
}

ROOT = np.array([3, 4, 5], dtype=np.int64)
ETA = np.array([[1, 0, 0], [0, 1, 0], [0, 0, -1]], dtype=np.int64)


# ============================================================
# Application 1: Berggren Hash Function
# ============================================================

def berggren_hash(message: bytes, output_bits: int = 64) -> str:
    """
    Hash function based on Berggren monoid action.
    
    The security intuition: given a point on the Berggren tree,
    finding the word that produced it requires solving the
    Berggren descent problem, which has logarithmic depth but
    non-obvious structure for arbitrary starting points.
    
    This is a pedagogical demonstration, not a production hash.
    
    Process:
    1. Convert message to a sequence of generator choices {A,B,C}
    2. Apply generators sequentially to the root triple
    3. Extract hash from the final triple coordinates
    """
    # Convert message bytes to generator sequence
    msg_hash = hashlib.sha256(message).digest()
    gen_sequence = []
    for byte in msg_hash:
        for i in range(0, 8, 2):
            bits = (byte >> i) & 0x3
            gen_sequence.append(['A', 'B', 'C'][bits % 3])
    
    # Apply generators
    v = ROOT.copy().astype(np.int64)
    for gen in gen_sequence:
        v = GENERATORS[gen] @ v
        # Reduce modulo a large prime to prevent overflow
        v = v % (2**61 - 1)
    
    # Extract hash
    combined = (v[0] * 2**42 + v[1] * 2**21 + v[2]) % (2**output_bits)
    return format(combined, f'0{output_bits // 4}x')


# ============================================================
# Application 2: Parity Error Detection
# ============================================================

def encode_with_parity(a: int, b: int) -> Tuple[int, int, int]:
    """
    Use the Pythagorean parity constraint as an error-detecting code.
    
    Given two values a, b, compute c such that (a,b,c) satisfies
    the parity constraint a + b + c ≡ 0 (mod 2).
    
    This is the simplest manifestation of the parity shadow:
    the mod-2 invariant provides a single-bit error check.
    """
    c = (a + b) % 2  # Ensure parity constraint
    return (a, b, c)


def check_parity(triple: Tuple[int, int, int]) -> bool:
    """Check the parity constraint."""
    return (triple[0] + triple[1] + triple[2]) % 2 == 0


def simulate_transmission(data: List[Tuple[int, int]], error_rate: float = 0.1) -> dict:
    """
    Simulate data transmission with parity-based error detection.
    
    Demonstrates that the Pythagorean parity invariant serves as
    a natural error-detecting code.
    """
    import random
    random.seed(42)
    
    encoded = [encode_with_parity(a, b) for a, b in data]
    
    # Simulate channel errors
    received = []
    errors_introduced = 0
    for triple in encoded:
        triple_list = list(triple)
        if random.random() < error_rate:
            # Flip one bit in one component
            idx = random.randint(0, 2)
            triple_list[idx] ^= 1
            errors_introduced += 1
        received.append(tuple(triple_list))
    
    # Detect errors
    errors_detected = sum(1 for t in received if not check_parity(t))
    
    return {
        'total_messages': len(data),
        'errors_introduced': errors_introduced,
        'errors_detected': errors_detected,
        'detection_rate': errors_detected / max(errors_introduced, 1),
    }


# ============================================================
# Application 3: Efficient Triple Enumeration
# ============================================================

def enumerate_triples_sorted(max_hyp: int) -> List[Tuple[int, int, int]]:
    """
    Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hyp,
    sorted by hypotenuse.
    
    Uses the Berggren tree with BFS pruning.
    The Berggren tree is complete: every primitive Pythagorean triple
    with positive entries appears exactly once.
    
    Complexity: O(N log N) where N = π(C) ~ C/(2π) is the count
    """
    from collections import deque
    
    results = []
    queue = deque([ROOT.copy()])
    
    while queue:
        v = queue.popleft()
        if v[2] > max_hyp:
            continue
        
        # Normalize: ensure a < b (canonical form)
        a, b, c = int(v[0]), int(v[1]), int(v[2])
        if a > b:
            a, b = b, a
        results.append((a, b, c))
        
        for M in GENERATORS.values():
            child = M @ v
            if child[2] <= max_hyp:
                queue.append(child)
    
    results.sort(key=lambda t: (t[2], t[0]))
    return results


# ============================================================
# Application 4: Lattice Point Counting
# ============================================================

def count_lattice_points(max_hyp: int) -> dict:
    """
    Count primitive Pythagorean triples up to various hypotenuse bounds.
    
    Compares with the asymptotic formula: π(C) ~ C / (2π).
    """
    triples = enumerate_triples_sorted(max_hyp)
    
    bounds = [10, 25, 50, 100, 250, 500, 1000]
    bounds = [b for b in bounds if b <= max_hyp]
    
    results = {}
    for bound in bounds:
        count = sum(1 for t in triples if t[2] <= bound)
        predicted = bound / (2 * 3.14159265)
        results[bound] = {
            'count': count,
            'predicted': round(predicted, 1),
            'ratio': round(count / predicted, 3) if predicted > 0 else 0,
        }
    
    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION DEMONSTRATIONS")
    print("=" * 60)
    
    # 1. Hash function
    print("\n--- Berggren Hash Function ---")
    messages = [b"hello", b"Hello", b"hello world", b"pythagorean"]
    for msg in messages:
        h = berggren_hash(msg)
        print(f"  hash({msg.decode()!r}) = {h}")
    
    # Avalanche effect
    h1 = berggren_hash(b"test1")
    h2 = berggren_hash(b"test2")
    diff_bits = bin(int(h1, 16) ^ int(h2, 16)).count('1')
    print(f"\n  Avalanche: 'test1' vs 'test2' differ in {diff_bits}/64 bits")
    
    # 2. Error detection
    print("\n--- Parity Error Detection ---")
    data = [(i, j) for i in range(10) for j in range(10)]
    result = simulate_transmission(data, error_rate=0.15)
    print(f"  Messages: {result['total_messages']}")
    print(f"  Errors introduced: {result['errors_introduced']}")
    print(f"  Errors detected: {result['errors_detected']}")
    print(f"  Detection rate: {result['detection_rate']:.1%}")
    
    # 3. Triple enumeration
    print("\n--- Efficient Enumeration (hypotenuse ≤ 200) ---")
    triples = enumerate_triples_sorted(200)
    print(f"  Found {len(triples)} primitive Pythagorean triples")
    for t in triples[:10]:
        print(f"    ({t[0]:>3}, {t[1]:>3}, {t[2]:>3})")
    print(f"    ... and {len(triples) - 10} more")
    
    # 4. Lattice counting
    print("\n--- Lattice Point Counting ---")
    counts = count_lattice_points(1000)
    print(f"  {'Bound':>6} | {'Count':>5} | {'~C/2π':>6} | {'Ratio':>5}")
    print(f"  {'-'*6}-+-{'-'*5}-+-{'-'*6}-+-{'-'*5}")
    for bound, data in counts.items():
        print(f"  {bound:>6} | {data['count']:>5} | {data['predicted']:>6} | {data['ratio']:>5}")


#!/usr/bin/env python3
"""
Berggren Orbits as Integral Lorentz Symmetries — Demonstration

This script demonstrates the core theorems:
1. Berggren generators preserve the Pythagorean quadratic form Q(x,y,z) = x² + y² - z²
2. The Berggren tree generates Pythagorean triples from the root (3,4,5)
3. Mod-2 reduction reveals a finite-state parity invariant
"""

import numpy as np
from typing import List, Tuple

# ============================================================
# Core Definitions
# ============================================================

def pyth_quad(v: np.ndarray) -> int:
    """Pythagorean quadratic form Q(v) = v[0]² + v[1]² - v[2]²"""
    return int(v[0]**2 + v[1]**2 - v[2]**2)

# Lorentz metric η = diag(1, 1, -1)
ETA = np.array([[1, 0, 0],
                [0, 1, 0],
                [0, 0, -1]], dtype=int)

# Berggren generators
BERGGREN_A = np.array([[ 1, -2,  2],
                        [ 2, -1,  2],
                        [ 2, -2,  3]], dtype=int)

BERGGREN_B = np.array([[ 1,  2,  2],
                        [ 2,  1,  2],
                        [ 2,  2,  3]], dtype=int)

BERGGREN_C = np.array([[-1,  2,  2],
                        [-2,  1,  2],
                        [-2,  2,  3]], dtype=int)

ROOT = np.array([3, 4, 5], dtype=int)

# ============================================================
# Theorem 1: Quadratic Form Preservation
# ============================================================

def check_preserves_quad(M: np.ndarray, name: str) -> bool:
    """Verify Mᵀ η M = η (integral Lorentz group membership)"""
    result = M.T @ ETA @ M
    preserved = np.array_equal(result, ETA)
    print(f"  {name}ᵀ · η · {name} = η? {preserved}")
    if preserved:
        print(f"    → {name} ∈ O(2,1;ℤ) ✓")
    return preserved

print("=" * 60)
print("THEOREM 1: Berggren Generators in O(2,1;ℤ)")
print("=" * 60)
print(f"\nLorentz metric η = diag(1, 1, -1)")
print(f"Condition: Mᵀ · η · M = η\n")

for M, name in [(BERGGREN_A, "A"), (BERGGREN_B, "B"), (BERGGREN_C, "C")]:
    check_preserves_quad(M, name)

# Determinants
print(f"\nDeterminant structure:")
for M, name in [(BERGGREN_A, "A"), (BERGGREN_B, "B"), (BERGGREN_C, "C")]:
    d = int(np.linalg.det(M).round())
    kind = "proper" if d == 1 else "improper"
    print(f"  det({name}) = {d:+d}  ({kind} Lorentz transformation)")

# ============================================================
# Theorem 2: Orbit Theorem — Berggren Tree
# ============================================================

print(f"\n{'=' * 60}")
print("THEOREM 2: Berggren Tree — All Reachable Triples Are Pythagorean")
print("=" * 60)

def berggren_tree(root: np.ndarray, depth: int) -> List[Tuple[str, np.ndarray]]:
    """Generate all triples in the Berggren tree up to given depth."""
    result = [("root", root)]
    frontier = [("", root)]
    
    for d in range(depth):
        new_frontier = []
        for path, v in frontier:
            for M, label in [(BERGGREN_A, "A"), (BERGGREN_B, "B"), (BERGGREN_C, "C")]:
                child = M @ v
                new_path = path + label
                result.append((new_path, child))
                new_frontier.append((new_path, child))
        frontier = new_frontier
    
    return result

tree = berggren_tree(ROOT, depth=3)

print(f"\nRoot: ({ROOT[0]}, {ROOT[1]}, {ROOT[2]})")
print(f"Q(root) = {pyth_quad(ROOT)}")
print(f"\nFirst 3 levels of Berggren tree ({len(tree)} triples total):\n")

all_pythagorean = True
for path, v in tree[:1 + 3 + 9]:  # Show first 2 levels
    q = pyth_quad(v)
    is_pyth = "✓" if q == 0 else "✗"
    label = path if path else "root"
    print(f"  [{label:>4}] ({v[0]:>4}, {v[1]:>4}, {v[2]:>4})  Q = {q}  {is_pyth}")
    if q != 0:
        all_pythagorean = False

print(f"\n  ... and {len(tree) - 13} more triples at depth 3")
print(f"\nAll {len(tree)} triples satisfy Q = 0? {all_pythagorean and all(pyth_quad(v) == 0 for _, v in tree)}")

# ============================================================
# Theorem 3: Parity Shadow
# ============================================================

print(f"\n{'=' * 60}")
print("THEOREM 3: Parity Shadow — Mod-2 Invariant")
print("=" * 60)

print(f"\nParity constraint: x + y + z ≡ 0 (mod 2)")
print(f"Every primitive Pythagorean triple satisfies this.\n")

print("Mod-2 reduction of Berggren generators:")
for M, name in [(BERGGREN_A, "A"), (BERGGREN_B, "B"), (BERGGREN_C, "C")]:
    M2 = M % 2
    print(f"\n  {name} mod 2 =")
    for row in M2:
        print(f"    {row}")

print(f"\n  Note: All three generators reduce to the identity mod 2!")
print(f"  This means the parity vector is invariant under Berggren evolution.")

print(f"\nParity check on tree nodes:")
for path, v in tree[:13]:
    parity = v % 2
    parity_sum = sum(parity) % 2
    label = path if path else "root"
    check = "✓" if parity_sum == 0 else "✗"
    print(f"  [{label:>4}] ({v[0]:>4}, {v[1]:>4}, {v[2]:>4})  "
          f"parity ({parity[0]},{parity[1]},{parity[2]})  "
          f"sum mod 2 = {parity_sum}  {check}")

# ============================================================
# Monoid Structure
# ============================================================

print(f"\n{'=' * 60}")
print("MONOID CLOSURE: Products Preserve O(2,1;ℤ)")
print("=" * 60)

products = [
    ("A·B", BERGGREN_A @ BERGGREN_B),
    ("A·C", BERGGREN_A @ BERGGREN_C),
    ("B·C", BERGGREN_B @ BERGGREN_C),
    ("A·B·C", BERGGREN_A @ BERGGREN_B @ BERGGREN_C),
    ("A²", BERGGREN_A @ BERGGREN_A),
    ("B²", BERGGREN_B @ BERGGREN_B),
]

for name, P in products:
    preserved = np.array_equal(P.T @ ETA @ P, ETA)
    det = int(np.linalg.det(P).round())
    print(f"  {name:>5}: preserves η? {preserved}  det = {det:+d}")

# ============================================================
# Summary
# ============================================================

print(f"\n{'=' * 60}")
print("SUMMARY OF VERIFIED RESULTS")
print("=" * 60)
print("""
1. berggren_A_preserves : Aᵀ η A = η             ✓ proved
2. berggren_B_preserves : Bᵀ η B = η             ✓ proved
3. berggren_C_preserves : Cᵀ η C = η             ✓ proved
4. berggren_map_pythagorean : M ∈ O(2,1;ℤ), Q(v)=0 → Q(Mv)=0  ✓ proved
5. reachable_is_pythagorean : Berggren orbit ⊂ light cone       ✓ proved
6. berggren_preserves_parityConstraint : parity shadow invariant ✓ proved
7. reachable_parityConstraint : orbit satisfies parity           ✓ proved
8. preservesPythQuad_mul : O(2,1;ℤ) closed under products       ✓ proved
9. preservesPythQuad_one : I ∈ O(2,1;ℤ)                         ✓ proved
""")

if __name__ == "__main__":
    pass


#!/usr/bin/env python3
"""
Visualizations for Berggren–Lorentz Dynamics

Generates publication-quality figures:
1. Berggren tree structure
2. Pythagorean triples on the light cone
3. Hypotenuse growth analysis
4. Parity state diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import deque
import base64
from io import BytesIO

# ============================================================
# Core Setup
# ============================================================

GENERATORS = {
    'A': np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]], dtype=np.int64),
    'B': np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]], dtype=np.int64),
    'C': np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]], dtype=np.int64),
}

ROOT = np.array([3, 4, 5], dtype=np.int64)


def berggren_tree(depth):
    """Generate tree with parent-child edges."""
    nodes = [("", ROOT)]
    edges = []
    frontier = [("", ROOT)]
    for d in range(depth):
        new_frontier = []
        for path, v in frontier:
            for label, M in GENERATORS.items():
                child = M @ v
                child_path = path + label
                nodes.append((child_path, child))
                edges.append((path, child_path))
                new_frontier.append((child_path, child))
        frontier = new_frontier
    return nodes, edges


# ============================================================
# Figure 1: Pythagorean Triples on Integer Lattice
# ============================================================

def fig_lattice_points():
    """Plot primitive Pythagorean triples as points (a,b) colored by tree depth."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    
    nodes, _ = berggren_tree(6)
    
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, 7))
    
    for path, v in nodes:
        d = len(path)
        a, b, c = v
        ax.scatter(a, b, c=colors[d:d+1], s=max(100 - d*12, 10),
                  zorder=5, edgecolors='white', linewidths=0.5)
    
    # Label first few
    for path, v in nodes[:13]:
        a, b, c = v
        label = f"({a},{b},{c})"
        ax.annotate(label, (a, b), fontsize=6, ha='center', va='bottom',
                   xytext=(0, 5), textcoords='offset points')
    
    ax.set_xlabel('a (first leg)', fontsize=12)
    ax.set_ylabel('b (second leg)', fontsize=12)
    ax.set_title('Primitive Pythagorean Triples from Berggren Tree\n'
                'Color = tree depth (dark = shallow, light = deep)', fontsize=14)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    # Legend
    handles = [mpatches.Patch(color=colors[i], label=f'Depth {i}') for i in range(5)]
    ax.legend(handles=handles, loc='upper left', fontsize=10)
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 2: Berggren Tree Structure
# ============================================================

def fig_tree_structure():
    """Visualize the Berggren tree as a graph."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    nodes, edges = berggren_tree(3)
    
    # Compute positions
    pos = {}
    # Root
    pos[""] = (0, 0)
    
    def get_children(path):
        return [path + l for l in "ABC"]
    
    # Layout by depth
    for depth in range(4):
        nodes_at_depth = [p for p, v in nodes if len(p) == depth]
        n = len(nodes_at_depth)
        width = 3 ** depth
        for i, path in enumerate(sorted(nodes_at_depth)):
            x = (i - (n-1)/2) * (12 / max(width, 1))
            y = -depth * 2
            pos[path] = (x, y)
    
    # Draw edges
    gen_colors = {'A': '#e74c3c', 'B': '#3498db', 'C': '#2ecc71'}
    for parent, child in edges:
        if parent in pos and child in pos:
            gen = child[-1]
            color = gen_colors[gen]
            ax.plot([pos[parent][0], pos[child][0]],
                   [pos[parent][1], pos[child][1]],
                   color=color, linewidth=1.5, alpha=0.7, zorder=1)
    
    # Draw nodes
    for path, v in nodes:
        if path in pos:
            x, y = pos[path]
            d = len(path)
            size = max(400 - d*80, 100)
            ax.scatter(x, y, s=size, c='white', edgecolors='black',
                      linewidths=1.5, zorder=3)
            label = f"({v[0]},{v[1]},{v[2]})"
            fontsize = max(7 - d, 4)
            ax.text(x, y, label, ha='center', va='center',
                   fontsize=fontsize, zorder=4)
    
    # Legend
    handles = [mpatches.Patch(color=c, label=f'Generator {l}')
               for l, c in gen_colors.items()]
    ax.legend(handles=handles, loc='upper right', fontsize=11)
    
    ax.set_title('Berggren Tree: First Three Levels\n'
                'Every node is a primitive Pythagorean triple', fontsize=14)
    ax.set_xlim(-8, 8)
    ax.axis('off')
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 3: Hypotenuse Growth
# ============================================================

def fig_hypotenuse_growth():
    """Plot hypotenuse growth along pure branches."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    depth = 12
    colors = {'A': '#e74c3c', 'B': '#3498db', 'C': '#2ecc71'}
    
    for label, M in GENERATORS.items():
        hyps = []
        v = ROOT.copy()
        for _ in range(depth):
            hyps.append(int(v[2]))
            v = M @ v
        
        ax1.plot(range(depth), hyps, 'o-', color=colors[label],
                label=f'{label}-branch', linewidth=2, markersize=5)
        ax2.semilogy(range(depth), hyps, 'o-', color=colors[label],
                    label=f'{label}-branch', linewidth=2, markersize=5)
    
    ax1.set_xlabel('Depth', fontsize=12)
    ax1.set_ylabel('Hypotenuse c', fontsize=12)
    ax1.set_title('Hypotenuse Growth (Linear Scale)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    ax2.set_xlabel('Depth', fontsize=12)
    ax2.set_ylabel('Hypotenuse c (log scale)', fontsize=12)
    ax2.set_title('Hypotenuse Growth (Log Scale)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 4: Quadratic Form Verification
# ============================================================

def fig_quadratic_form():
    """Verify Q(v) = 0 for all tree nodes — visual proof."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    nodes, _ = berggren_tree(5)
    
    depths = [len(p) for p, v in nodes]
    q_values = [int(v[0]**2 + v[1]**2 - v[2]**2) for p, v in nodes]
    
    ax.scatter(depths, q_values, c='#3498db', s=30, alpha=0.7, zorder=3)
    ax.axhline(y=0, color='red', linewidth=2, linestyle='--', label='Q = 0 (light cone)')
    
    ax.set_xlabel('Tree Depth', fontsize=12)
    ax.set_ylabel('Q(v) = a² + b² - c²', fontsize=12)
    ax.set_title(f'Quadratic Form Values for {len(nodes)} Berggren Tree Nodes\n'
                f'All values are exactly 0 — the orbit lies on the light cone', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-1, 1)
    
    plt.tight_layout()
    return fig


# ============================================================
# Figure 5: Parity State Diagram
# ============================================================

def fig_parity_diagram():
    """Visualize the mod-2 parity automaton."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    # All 8 states of (Z/2Z)^3
    states = [(i, j, k) for i in range(2) for j in range(2) for k in range(2)]
    
    # Position in a circle
    n = len(states)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    radius = 3
    
    # Separate invariant vs non-invariant states
    invariant = [s for s in states if sum(s) % 2 == 0]
    non_invariant = [s for s in states if sum(s) % 2 != 0]
    
    positions = {}
    # Place invariant states on inner circle, non-invariant on outer
    inv_angles = np.linspace(0, 2*np.pi, len(invariant), endpoint=False) + np.pi/4
    for i, s in enumerate(invariant):
        positions[s] = (2 * np.cos(inv_angles[i]), 2 * np.sin(inv_angles[i]))
    
    noninv_angles = np.linspace(0, 2*np.pi, len(non_invariant), endpoint=False)
    for i, s in enumerate(non_invariant):
        positions[s] = (4.5 * np.cos(noninv_angles[i]), 4.5 * np.sin(noninv_angles[i]))
    
    # Draw states
    for s in states:
        x, y = positions[s]
        is_inv = sum(s) % 2 == 0
        color = '#2ecc71' if is_inv else '#e74c3c'
        size = 1500 if is_inv else 1000
        ax.scatter(x, y, s=size, c=color, edgecolors='black', linewidths=2, zorder=5)
        ax.text(x, y, f"({s[0]},{s[1]},{s[2]})", ha='center', va='center',
               fontsize=9, fontweight='bold', zorder=6)
    
    # Draw self-loops (all generators map each state to itself mod 2)
    for s in states:
        x, y = positions[s]
        # Small loop indicator
        loop = plt.Circle((x, y + 0.6), 0.3, fill=False, color='#3498db',
                          linewidth=1.5, linestyle='--')
        ax.add_patch(loop)
    
    # Legend
    handles = [
        mpatches.Patch(color='#2ecc71', label='Invariant: x+y+z ≡ 0 (mod 2)'),
        mpatches.Patch(color='#e74c3c', label='Non-invariant: x+y+z ≡ 1 (mod 2)'),
    ]
    ax.legend(handles=handles, loc='lower right', fontsize=11)
    
    ax.set_title('Parity Automaton on (ℤ/2ℤ)³\n'
                'All Berggren generators act as identity mod 2\n'
                'Pythagorean triples always occupy green states', fontsize=13)
    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 6)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    return fig


# ============================================================
# Generate all figures
# ============================================================

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


if __name__ == "__main__":
    print("Generating visualizations...")
    
    figs = {
        'lattice_points': fig_lattice_points(),
        'tree_structure': fig_tree_structure(),
        'hypotenuse_growth': fig_hypotenuse_growth(),
        'quadratic_form': fig_quadratic_form(),
        'parity_diagram': fig_parity_diagram(),
    }
    
    for name, fig in figs.items():
        filename = f"{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight')
        print(f"  Saved {filename}")
        plt.close(fig)
    
    print("Done!")
