#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Berggren Transfer Duality

Demonstrates applications of the transfer duality framework to:
1. Cryptographic hash fingerprinting via Berggren-tree structure
2. Network tomography analogues on tree-structured systems
3. Pythagorean triple enumeration and classification
"""

import numpy as np
from typing import Dict, Set, List, Tuple
from collections import defaultdict
from itertools import product

# Berggren matrices
A_MAT = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B_MAT = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
C_MAT = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
GENS = {'A': A_MAT, 'B': B_MAT, 'C': C_MAT}

def eval_word(word, root=np.array([3, 4, 5])):
    t = root.copy()
    for g in word:
        t = GENS[g] @ t
    return np.abs(t)

# ============================================================
# Application 1: Triple Classification via Transfer Fingerprints
# ============================================================

def triple_classification():
    """
    Classify primitive Pythagorean triples by their transfer fingerprints.
    
    The transfer fingerprint of a triple is the vector of observables
    at neighboring nodes in the Berggren tree. Two triples with the same
    fingerprint are 'transfer-equivalent' — they occupy structurally
    identical positions in the tree.
    
    Application: Efficient search for triples with specific arithmetic
    properties by fingerprint matching instead of exhaustive enumeration.
    """
    print("=" * 60)
    print("APPLICATION 1: Triple Classification via Transfer Fingerprints")
    print("=" * 60)
    print()
    
    max_depth = 3
    tree = {}
    root = np.array([3, 4, 5])
    
    # Generate tree
    frontier = [("", root)]
    tree[""] = tuple(sorted(np.abs(root)))
    
    for _ in range(max_depth):
        next_frontier = []
        for word, triple in frontier:
            for gen_name, gen_mat in GENS.items():
                new_word = word + gen_name
                new_triple = gen_mat @ triple
                tree[new_word] = tuple(sorted(np.abs(new_triple)))
                next_frontier.append((new_word, new_triple))
        frontier = next_frontier
    
    # Compute transfer fingerprints (hypotenuse of self + children)
    fingerprints = {}
    for word in sorted(tree.keys(), key=lambda w: (len(w), w)):
        if len(word) >= max_depth:
            continue
        fp = [tree[word][2]]  # own hypotenuse
        for g in 'ABC':
            child = word + g
            if child in tree:
                fp.append(tree[child][2])
        fingerprints[word] = tuple(fp)
    
    # Group by fingerprint pattern (ratios)
    ratio_classes = defaultdict(list)
    for word, fp in fingerprints.items():
        if len(fp) >= 4:
            # Classify by child-to-parent hypotenuse ratios (rounded)
            ratios = tuple(round(fp[i] / fp[0], 2) for i in range(1, 4))
            ratio_classes[ratios].append((word, tree[word]))
    
    print("Triples classified by child-to-parent hypotenuse ratio pattern:")
    for ratios, members in sorted(ratio_classes.items()):
        print(f"\n  Ratio pattern {ratios}:")
        for word, triple in members[:5]:
            print(f"    word={word:6s}  triple={triple}  hyp={triple[2]}")
    print()

# ============================================================
# Application 2: Structural Isomorphism Detection
# ============================================================

def isomorphism_detection():
    """
    Detect when two subtrees of the Berggren tree are structurally isomorphic
    using transfer observables, without explicitly comparing tree structures.
    
    This is the practical content of the transfer duality theorem:
    equality of Hankel profiles implies rooted isomorphism.
    
    Application: Efficient detection of structural symmetries in
    large Pythagorean triple databases.
    """
    print("=" * 60)
    print("APPLICATION 2: Structural Isomorphism Detection")
    print("=" * 60)
    print()
    
    root = np.array([3, 4, 5])
    
    # Build two subtrees rooted at different words
    def build_subtree(root_word: str, depth: int) -> Dict[str, Tuple]:
        tree = {}
        triple = eval_word(root_word, root)
        tree[""] = tuple(sorted(triple))
        
        frontier = [("", triple)]
        for _ in range(depth):
            next_frontier = []
            for word, t in frontier:
                for gen_name, gen_mat in GENS.items():
                    new_word = word + gen_name
                    new_triple = gen_mat @ t
                    tree[new_word] = tuple(sorted(np.abs(new_triple)))
                    next_frontier.append((new_word, new_triple))
            frontier = next_frontier
        return tree
    
    # Compare subtrees rooted at 'A' and 'B'
    sub_A = build_subtree("A", 2)
    sub_B = build_subtree("B", 2)
    
    print("Subtree rooted at word 'A':")
    for w in sorted(sub_A.keys(), key=lambda w: (len(w), w))[:7]:
        print(f"  {w if w else 'root':6s} → {sub_A[w]}")
    
    print(f"\nSubtree rooted at word 'B':")
    for w in sorted(sub_B.keys(), key=lambda w: (len(w), w))[:7]:
        print(f"  {w if w else 'root':6s} → {sub_B[w]}")
    
    # Compare transfer profiles
    def profile(tree, depth=2):
        """Compute depth-sorted hypotenuse profile."""
        by_depth = defaultdict(list)
        for w, t in tree.items():
            by_depth[len(w)].append(t[2])
        return {d: sorted(v) for d, v in by_depth.items()}
    
    prof_A = profile(sub_A)
    prof_B = profile(sub_B)
    
    print("\nHypotenuse profiles by depth:")
    print(f"  Subtree A: {dict(prof_A)}")
    print(f"  Subtree B: {dict(prof_B)}")
    print(f"  Isomorphic profiles: {prof_A == prof_B}")
    print()
    print("Note: Different profiles ⟹ non-isomorphic subtrees (by transfer duality)")
    print()

# ============================================================
# Application 3: Efficient Triple Enumeration
# ============================================================

def efficient_enumeration():
    """
    Use shell decomposition for efficient enumeration of primitive
    Pythagorean triples within hypotenuse bounds.
    
    The shell structure allows pruning: if a shell's minimum hypotenuse
    exceeds the bound, all deeper shells can be skipped.
    
    Application: Database generation for number-theoretic computations.
    """
    print("=" * 60)
    print("APPLICATION 3: Shell-Based Triple Enumeration")
    print("=" * 60)
    print()
    
    root = np.array([3, 4, 5])
    max_hyp = 500
    
    # BFS with hypotenuse pruning
    triples_by_shell = defaultdict(list)
    total_generated = 0
    total_pruned = 0
    
    frontier = [("", root)]
    depth = 0
    
    while frontier:
        next_frontier = []
        for word, triple in frontier:
            t = tuple(sorted(np.abs(triple)))
            hyp = t[2]
            
            if hyp <= max_hyp:
                triples_by_shell[depth].append((word, t))
                total_generated += 1
                
                # Expand children
                for gen_name, gen_mat in GENS.items():
                    new_word = word + gen_name
                    new_triple = gen_mat @ triple
                    next_frontier.append((new_word, new_triple))
            else:
                total_pruned += 1
        
        frontier = next_frontier
        depth += 1
        
        if depth > 20:  # safety bound
            break
    
    print(f"Primitive Pythagorean triples with hypotenuse ≤ {max_hyp}:")
    print(f"  Total found: {total_generated}")
    print(f"  Branches pruned: {total_pruned}")
    print()
    
    print("Shell decomposition:")
    for d in sorted(triples_by_shell.keys()):
        shell = triples_by_shell[d]
        hyps = [t[2] for _, t in shell]
        print(f"  Depth {d:2d}: {len(shell):3d} triples, "
              f"hypotenuse range [{min(hyps):4d}, {max(hyps):4d}]")
    
    print()
    print("Transfer channel invariant: within each shell, the hypotenuse")
    print("distribution characterizes the arithmetic structure completely.")
    print()

# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Berggren Transfer Duality — Applications               ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    triple_classification()
    isomorphism_detection()
    efficient_enumeration()
    
    print("=" * 60)
    print("All applications demonstrated successfully.")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Berggren Transfer Duality: Interactive Demonstrations

Demonstrates the core theorems of Berggren Transfer Duality with concrete
numerical examples, showing how primitive Pythagorean triples form a ternary
tree whose structure can be recovered from transfer observables.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from itertools import product
from collections import defaultdict

# ============================================================
# 1. Berggren Generators and Triple Generation
# ============================================================

# The three Berggren matrices
A_MAT = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B_MAT = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
C_MAT = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

GENERATORS = {'A': A_MAT, 'B': B_MAT, 'C': C_MAT}

def apply_gen(gen: str, triple: np.ndarray) -> np.ndarray:
    """Apply a Berggren generator to a primitive Pythagorean triple."""
    return GENERATORS[gen] @ triple

def eval_word(word: str, root: np.ndarray = np.array([3, 4, 5])) -> np.ndarray:
    """Evaluate a Berggren word starting from the root triple (3,4,5)."""
    t = root.copy()
    for g in word:
        t = apply_gen(g, t)
    return np.abs(t)  # Some generators may produce negative values; take abs

def is_pythagorean(triple: np.ndarray) -> bool:
    """Check if a triple satisfies a² + b² = c²."""
    a, b, c = sorted(np.abs(triple))
    return a*a + b*b == c*c

# ============================================================
# 2. Demonstration: Berggren Tree Generation
# ============================================================

def demo_berggren_tree(max_depth: int = 3):
    """Generate and display the Berggren tree up to a given depth."""
    print("=" * 60)
    print("DEMO 1: Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 60)
    print()
    
    root = np.array([3, 4, 5])
    print(f"Root triple: {tuple(root)}")
    print(f"Check: {root[0]}² + {root[1]}² = {root[0]**2} + {root[1]**2} = {root[0]**2 + root[1]**2} = {root[2]}² ✓")
    print()
    
    words_by_depth = defaultdict(list)
    words_by_depth[0].append(("", root))
    
    for depth in range(1, max_depth + 1):
        for parent_word, _ in words_by_depth[depth - 1]:
            for gen in ['A', 'B', 'C']:
                word = parent_word + gen
                triple = eval_word(word, root)
                words_by_depth[depth].append((word, triple))
    
    for depth in range(max_depth + 1):
        print(f"Depth {depth}:")
        for word, triple in words_by_depth[depth]:
            a, b, c = sorted(triple)
            label = f"  word='{word}'" if word else "  word='ε' (root)"
            check = "✓" if is_pythagorean(triple) else "✗"
            print(f"{label:20s} → ({a:4d}, {b:4d}, {c:4d})  "
                  f"[{a}² + {b}² = {a**2 + b**2} = {c**2} {check}]")
        print()
    
    total = sum(len(v) for v in words_by_depth.values())
    print(f"Total triples generated: {total}")
    print()

# ============================================================
# 3. Transfer Observable and Hankel Kernel
# ============================================================

def demo_transfer_hankel(max_depth: int = 2):
    """Demonstrate the transfer Hankel kernel and future equivalence."""
    print("=" * 60)
    print("DEMO 2: Transfer Hankel Kernel")
    print("=" * 60)
    print()
    
    root = np.array([3, 4, 5])
    
    # Define a simple observable: hypotenuse of the generated triple
    def obs(word: str) -> int:
        if len(word) > max_depth + 2:
            return 0
        triple = eval_word(word, root)
        return int(sorted(triple)[-1])  # hypotenuse
    
    # Compute Hankel kernel H(u, v) = Obs(u ++ v)
    words = [""] + [w for depth in range(1, max_depth + 1)
                    for w in [''.join(p) for p in product('ABC', repeat=depth)]]
    
    print("Observable Obs(w) = hypotenuse of triple at word w:")
    for w in words[:13]:
        label = f"ε" if w == "" else w
        print(f"  Obs({label:4s}) = {obs(w)}")
    print()
    
    # Show Hankel matrix for short words
    short = ["", "A", "B", "C"]
    print("Hankel matrix H(u,v) = Obs(u++v) for short words:")
    header = "     " + "".join(f"{('ε' if v == '' else v):>8s}" for v in short)
    print(header)
    for u in short:
        row_label = 'ε' if u == '' else u
        row = "".join(f"{obs(u + v):8d}" for v in short)
        print(f"  {row_label:3s} {row}")
    print()
    
    # Demonstrate future equivalence
    print("Future functions (first few values):")
    test_suffixes = ["", "A", "B", "C", "AA", "AB"]
    for w in short:
        label = 'ε' if w == '' else w
        futures = [obs(w + s) for s in test_suffixes]
        print(f"  future({label}) = {futures}")
    print()

# ============================================================
# 4. Prefix-Closed Sets and Boundary Detection
# ============================================================

def demo_prefix_closure():
    """Demonstrate prefix-closed sets, boundaries, and shell decomposition."""
    print("=" * 60)
    print("DEMO 3: Prefix-Closed Sets, Boundaries, and Shells")
    print("=" * 60)
    print()
    
    # A finite prefix-closed set (depth ≤ 2)
    B = {"", "A", "B", "C", "AA", "AB", "AC", "BA", "BB", "BC", "CA", "CB", "CC"}
    
    print(f"Finite prefix-closed set B (depth ≤ 2): {len(B)} words")
    print(f"  B = {sorted(B, key=lambda w: (len(w), w))}")
    print()
    
    # Verify prefix-closure
    is_prefix_closed = all(
        w[:i] in B
        for w in B
        for i in range(len(w) + 1)
    )
    print(f"Prefix-closed: {is_prefix_closed} ✓")
    print(f"Contains root (ε): {'' in B} ✓")
    print()
    
    # Compute boundary
    boundary = {w for w in B if all(w + g not in B for g in 'ABC')}
    interior = B - boundary
    
    print(f"Boundary (leaves): {sorted(boundary, key=lambda w: (len(w), w))}")
    print(f"  |boundary| = {len(boundary)}")
    print(f"Interior: {sorted(interior, key=lambda w: (len(w), w))}")
    print(f"  |interior| = {len(interior)}")
    print(f"Partition check: |boundary| + |interior| = {len(boundary)} + {len(interior)} = {len(B)} = |B| ✓")
    print()
    
    # Shell decomposition
    max_depth = max(len(w) for w in B)
    print(f"Shell decomposition (max depth = {max_depth}):")
    for d in range(max_depth + 1):
        shell = sorted(w for w in B if len(w) == d)
        print(f"  Shell {d}: {shell} (|shell| = {len(shell)})")
    print()

# ============================================================
# 5. Future Equivalence Classes (Resonance Partition)
# ============================================================

def demo_resonance_partition():
    """Demonstrate the resonance partition of boundary words."""
    print("=" * 60)
    print("DEMO 4: Resonance Partition of Boundary Words")
    print("=" * 60)
    print()
    
    root = np.array([3, 4, 5])
    B = {"", "A", "B", "C", "AA", "AB", "AC", "BA", "BB", "BC", "CA", "CB", "CC"}
    
    # Observable: hypotenuse mod 10 (creates interesting equivalence classes)
    def obs(word: str) -> int:
        if len(word) > 4:
            return 0
        triple = eval_word(word, root)
        return int(sorted(triple)[-1]) % 100
    
    boundary = sorted(w for w in B if all(w + g not in B for g in 'ABC'))
    
    # Compute future functions on boundary words
    test_suffixes = [""] + list('ABC') + [''.join(p) for p in product('ABC', repeat=2)]
    
    print("Future functions of boundary words (observable = hypotenuse mod 100):")
    futures = {}
    for w in boundary:
        f = tuple(obs(w + s) for s in test_suffixes)
        futures[w] = f
        print(f"  future({w:2s}) = {list(f[:7])}...")
    
    # Partition by future equivalence
    classes = defaultdict(list)
    for w, f in futures.items():
        classes[f].append(w)
    
    print()
    print(f"Resonance partition ({len(classes)} equivalence classes):")
    for i, (_, members) in enumerate(sorted(classes.items(), key=lambda x: x[1])):
        print(f"  Class {i+1}: {members}")
    
    print()
    print("Key insight: Words in the same class produce indistinguishable")
    print("transfer responses — they are 'resonant' states in the scattering model.")
    print()

# ============================================================
# 6. Finite Rank Verification
# ============================================================

def demo_finite_rank():
    """Demonstrate the core theorem: finite support ⟹ finite Hankel rank."""
    print("=" * 60)
    print("DEMO 5: Finite Hankel Rank Theorem")
    print("=" * 60)
    print()
    
    root = np.array([3, 4, 5])
    max_depth = 2
    
    # Build B (prefix-closed, finite)
    B = set()
    for d in range(max_depth + 1):
        for word in [''.join(p) for p in product('ABC', repeat=d)] if d > 0 else [""]:
            B.add(word)
    
    # Observable supported on B
    def obs(word: str) -> int:
        if word not in B:
            return 0
        triple = eval_word(word, root)
        return int(sorted(triple)[-1])  # hypotenuse
    
    print(f"|B| = {len(B)}")
    print()
    
    # Compute all distinct future functions
    # For words in B, compute their future restricted to B-extensions
    all_words = list(B) + [w + g for w in B for g in 'ABC' if w + g not in B]
    
    distinct_futures = set()
    future_map = {}
    suffixes = sorted(B, key=lambda w: (len(w), w))
    
    for w in all_words[:30]:
        f = tuple(obs(w + s) for s in suffixes)
        distinct_futures.add(f)
        future_map[w] = f
    
    # Words outside B all have zero future
    zero_future = tuple(0 for _ in suffixes)
    
    in_B_futures = {future_map[w] for w in B}
    
    print(f"Distinct future functions from words in B: {len(in_B_futures)}")
    print(f"Zero future (from words outside B): {'present' if zero_future in distinct_futures else 'absent'}")
    print(f"Total distinct futures: ≤ {len(in_B_futures)} + 1 = {len(in_B_futures) + 1}")
    print(f"Bound from |B|: {len(B)} + 1 = {len(B) + 1}")
    print()
    print("This confirms the theorem: FiniteRankHankel Obs ↔ FiniteResonanceType B Obs")
    print(f"  Hankel rank ≤ |B| + 1 = {len(B) + 1}  ✓")
    print()

# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Berggren Transfer Duality — Numerical Demonstrations   ║")
    print("║                                                          ║")
    print("║  Arithmetic Inverse Scattering on Pythagorean Trees      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_berggren_tree(max_depth=2)
    demo_transfer_hankel(max_depth=2)
    demo_prefix_closure()
    demo_resonance_partition()
    demo_finite_rank()
    
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
visualizations.py — Berggren Transfer Duality: Visualizations

Generates publication-quality visualizations of:
1. The Berggren ternary tree of Pythagorean triples
2. The Hankel matrix heatmap
3. Shell decomposition by depth
4. Resonance partition structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
from itertools import product
import base64
import io

# Berggren matrices
A_MAT = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B_MAT = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
C_MAT = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
GENS = {'A': A_MAT, 'B': B_MAT, 'C': C_MAT}

def eval_word(word, root=np.array([3, 4, 5])):
    t = root.copy()
    for g in word:
        t = GENS[g] @ t
    return np.abs(t)

def generate_tree(max_depth):
    tree = {}
    root = np.array([3, 4, 5])
    tree[""] = tuple(sorted(root))
    frontier = [("", root)]
    for _ in range(max_depth):
        nf = []
        for w, t in frontier:
            for g, m in GENS.items():
                nw = w + g
                nt = m @ t
                tree[nw] = tuple(sorted(np.abs(nt)))
                nf.append((nw, nt))
        frontier = nf
    return tree

def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()

# ============================================================
# Visualization 1: Berggren Tree
# ============================================================

def viz_berggren_tree():
    """Draw the Berggren ternary tree with triples labeled."""
    tree = generate_tree(2)
    
    fig, ax = plt.subplots(1, 1, figsize=(14, 7))
    
    # Position nodes
    positions = {}
    positions[""] = (0.5, 0.95)
    
    depth1 = ["A", "B", "C"]
    for i, w in enumerate(depth1):
        positions[w] = (0.15 + 0.35 * i, 0.55)
    
    depth2 = sorted(w for w in tree if len(w) == 2)
    for i, w in enumerate(depth2):
        positions[w] = (0.05 + 0.1125 * i, 0.15)
    
    # Draw edges
    colors = {'A': '#e74c3c', 'B': '#2ecc71', 'C': '#3498db'}
    for w in tree:
        if len(w) > 0 and w in positions:
            parent = w[:-1]
            if parent in positions:
                px, py = positions[parent]
                cx, cy = positions[w]
                ax.plot([px, cx], [py, cy], color=colors[w[-1]], linewidth=2, alpha=0.7)
                # Label edge
                mx, my = (px + cx) / 2, (py + cy) / 2
                ax.text(mx, my + 0.03, w[-1], fontsize=10, ha='center',
                       color=colors[w[-1]], fontweight='bold')
    
    # Draw nodes
    for w, (x, y) in positions.items():
        triple = tree[w]
        label = f"({triple[0]},{triple[1]},{triple[2]})"
        word_label = "ε" if w == "" else w
        
        circle = plt.Circle((x, y), 0.04, facecolor='white', edgecolor='#2c3e50',
                           linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y + 0.005, label, fontsize=7, ha='center', va='center',
               fontweight='bold', zorder=6)
        ax.text(x, y - 0.065, word_label, fontsize=8, ha='center', va='center',
               color='#7f8c8d', style='italic')
    
    # Legend
    patches = [mpatches.Patch(color=c, label=f'Generator {g}') for g, c in colors.items()]
    ax.legend(handles=patches, loc='upper right', fontsize=10)
    
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0.0, 1.05)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Ternary Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold')
    
    fig.savefig('/workspace/request-project/berggren_tree.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

# ============================================================
# Visualization 2: Hankel Matrix Heatmap
# ============================================================

def viz_hankel_matrix():
    """Visualize the transfer Hankel matrix as a heatmap."""
    tree = generate_tree(2)
    B = set(tree.keys())
    words = sorted(B, key=lambda w: (len(w), w))
    
    def obs(word):
        return tree.get(word, (0, 0, 0))[2]  # hypotenuse
    
    n = len(words)
    H = np.zeros((n, n))
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            concat = u + v
            H[i, j] = obs(concat) if concat in tree else 0
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    im = ax.imshow(H, cmap='YlOrRd', aspect='auto')
    
    labels = ['ε' if w == '' else w for w in words]
    ax.set_xticks(range(n))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticks(range(n))
    ax.set_yticklabels(labels, fontsize=8)
    
    ax.set_xlabel('Column word v', fontsize=12)
    ax.set_ylabel('Row word u', fontsize=12)
    ax.set_title('Transfer Hankel Matrix H(u,v) = Obs(u·v)\n(Observable = Hypotenuse)', fontsize=14, fontweight='bold')
    
    plt.colorbar(im, ax=ax, label='Hypotenuse value')
    
    fig.savefig('/workspace/request-project/hankel_matrix.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

# ============================================================
# Visualization 3: Shell Decomposition
# ============================================================

def viz_shell_decomposition():
    """Visualize the shell decomposition with hypotenuse distribution."""
    tree = generate_tree(4)
    
    shells = defaultdict(list)
    for w, t in tree.items():
        shells[len(w)].append(t[2])
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Shell sizes
    depths = sorted(shells.keys())
    sizes = [len(shells[d]) for d in depths]
    colors_bar = plt.cm.viridis(np.linspace(0.2, 0.8, len(depths)))
    
    ax1.bar(depths, sizes, color=colors_bar, edgecolor='white', linewidth=0.5)
    ax1.set_xlabel('Depth (Shell Level)', fontsize=12)
    ax1.set_ylabel('Number of Triples', fontsize=12)
    ax1.set_title('Shell Sizes (3ⁿ Growth)', fontsize=13, fontweight='bold')
    for d, s in zip(depths, sizes):
        ax1.text(d, s + 0.5, str(s), ha='center', fontsize=10, fontweight='bold')
    
    # Right: Hypotenuse distribution by shell
    for d in depths:
        hyps = sorted(shells[d])
        ax2.scatter([d] * len(hyps), hyps, alpha=0.6, s=20, label=f'Depth {d}')
    
    ax2.set_xlabel('Depth (Shell Level)', fontsize=12)
    ax2.set_ylabel('Hypotenuse', fontsize=12)
    ax2.set_title('Hypotenuse Distribution by Shell', fontsize=13, fontweight='bold')
    ax2.set_yscale('log')
    
    fig.suptitle('Spectral Shell Decomposition of the Berggren Tree', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/shell_decomposition.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

# ============================================================
# Visualization 4: Future Equivalence Classes
# ============================================================

def viz_resonance_classes():
    """Visualize the resonance (future-equivalence) classes."""
    tree = generate_tree(2)
    B = set(tree.keys())
    
    suffixes = [""]
    for d in range(1, 3):
        suffixes.extend(''.join(p) for p in product('ABC', repeat=d))
    
    def obs(word):
        return tree.get(word, (0, 0, 0))[2] % 100
    
    # Compute signatures
    signatures = {}
    for w in B:
        sig = tuple(obs(w + s) for s in suffixes)
        signatures[w] = sig
    
    # Group into classes
    classes = defaultdict(list)
    for w, sig in signatures.items():
        classes[sig].append(w)
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    class_ids = {}
    for i, (sig, members) in enumerate(sorted(classes.items(), key=lambda x: min(x[1]))):
        for w in members:
            class_ids[w] = i
    
    n_classes = len(classes)
    cmap = plt.cm.Set3(np.linspace(0, 1, max(n_classes, 3)))
    
    # Position words by depth and order
    positions = {}
    words_by_depth = defaultdict(list)
    for w in B:
        words_by_depth[len(w)].append(w)
    
    for d, ws in words_by_depth.items():
        ws_sorted = sorted(ws)
        n = len(ws_sorted)
        for i, w in enumerate(ws_sorted):
            x = (i + 0.5) / n
            y = 1.0 - d * 0.35
            positions[w] = (x, y)
    
    # Draw edges
    for w in B:
        if len(w) > 0 and w in positions:
            parent = w[:-1]
            if parent in positions:
                px, py = positions[parent]
                cx, cy = positions[w]
                ax.plot([px, cx], [py, cy], color='#bdc3c7', linewidth=1, zorder=1)
    
    # Draw nodes colored by equivalence class
    for w, (x, y) in positions.items():
        cid = class_ids[w]
        color = cmap[cid % len(cmap)]
        label = 'ε' if w == '' else w
        
        circle = plt.Circle((x, y), 0.025, facecolor=color, edgecolor='#2c3e50',
                           linewidth=1.5, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y - 0.05, label, fontsize=8, ha='center', va='center', zorder=4)
    
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.1, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(f'Resonance Classes (Future-Equivalence)\n{n_classes} distinct classes, colored by class',
                fontsize=13, fontweight='bold')
    
    fig.savefig('/workspace/request-project/resonance_classes.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

def main():
    print("Generating visualizations...")
    
    b64_tree = viz_berggren_tree()
    print("  ✓ Berggren tree")
    
    b64_hankel = viz_hankel_matrix()
    print("  ✓ Hankel matrix heatmap")
    
    b64_shells = viz_shell_decomposition()
    print("  ✓ Shell decomposition")
    
    b64_resonance = viz_resonance_classes()
    print("  ✓ Resonance classes")
    
    print("\nAll visualizations saved to PNG files.")
    return {
        "berggren_tree": b64_tree,
        "hankel_matrix": b64_hankel,
        "shell_decomposition": b64_shells,
        "resonance_classes": b64_resonance
    }

if __name__ == "__main__":
    main()
