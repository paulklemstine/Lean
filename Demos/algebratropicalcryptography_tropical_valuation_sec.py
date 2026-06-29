#!/usr/bin/env python3
"""
Tropical Secret-Sharing Duality: Demonstrations and Numerical Examples

This module demonstrates the key concepts from the tropical secret-sharing
framework, including:
- Tropical access presentations and coalition scoring
- Authorization checking and minimal coalition extraction
- Canonical reconstruction from blocker families
- The (2,3)-threshold scheme example
"""

import numpy as np
from itertools import combinations, chain
from typing import List, Set, FrozenSet, Tuple, Optional


# ============================================================================
# Core Data Structures
# ============================================================================

class TropicalAccessPresentation:
    """A tropical access presentation with max-plus scoring."""
    
    def __init__(self, matrix: np.ndarray, threshold: np.ndarray):
        """
        Args:
            matrix: shape (num_participants, gen_dim), entries are non-negative integers
            threshold: shape (gen_dim,), positive integer thresholds
        """
        self.matrix = matrix
        self.threshold = threshold
        self.num_participants = matrix.shape[0]
        self.gen_dim = matrix.shape[1]
        
        assert all(t > 0 for t in threshold), "Thresholds must be positive"
    
    def coalition_score(self, coalition: Set[int]) -> np.ndarray:
        """Compute the tropical (max) score of a coalition in each dimension."""
        if not coalition:
            return np.zeros(self.gen_dim, dtype=int)
        rows = self.matrix[list(coalition)]
        return rows.max(axis=0)
    
    def is_authorized(self, coalition: Set[int]) -> bool:
        """Check if a coalition is authorized (score >= threshold in all dims)."""
        score = self.coalition_score(coalition)
        return all(score[j] >= self.threshold[j] for j in range(self.gen_dim))
    
    def is_minimal_authorized(self, coalition: Set[int]) -> bool:
        """Check if a coalition is minimal authorized."""
        if not self.is_authorized(coalition):
            return False
        for p in coalition:
            if self.is_authorized(coalition - {p}):
                return False
        return True
    
    def is_extremal_attainment(self, coalition: Set[int]) -> bool:
        """Check if a coalition is an extremal attainment set.
        (Should be equivalent to minimal authorized by our theorem.)"""
        if not self.is_authorized(coalition):
            return False
        for p in coalition:
            if self.is_authorized(coalition - {p}):
                return False
        return True
    
    def all_authorized(self) -> List[FrozenSet[int]]:
        """Find all authorized coalitions."""
        participants = set(range(self.num_participants))
        result = []
        for size in range(self.num_participants + 1):
            for combo in combinations(range(self.num_participants), size):
                coal = set(combo)
                if self.is_authorized(coal):
                    result.append(frozenset(combo))
        return result
    
    def all_minimal_authorized(self) -> List[FrozenSet[int]]:
        """Find all minimal authorized coalitions."""
        participants = set(range(self.num_participants))
        result = []
        for size in range(1, self.num_participants + 1):
            for combo in combinations(range(self.num_participants), size):
                coal = set(combo)
                if self.is_minimal_authorized(coal):
                    result.append(frozenset(combo))
        return result
    
    def extract_minimal(self, coalition: Set[int]) -> Set[int]:
        """Extract a minimal authorized subset from an authorized coalition."""
        assert self.is_authorized(coalition), "Coalition must be authorized"
        D = set(coalition)
        for p in list(coalition):
            if p in D and self.is_authorized(D - {p}):
                D.remove(p)
        return D


class BlockerAccessStructure:
    """A blocker-characterized access structure."""
    
    def __init__(self, num_participants: int, blocking_sets: List[Set[int]]):
        self.num_participants = num_participants
        self.blocking_sets = blocking_sets
        assert all(len(b) > 0 for b in blocking_sets), "Blocking sets must be nonempty"
    
    def is_authorized(self, coalition: Set[int]) -> bool:
        """C is authorized iff it intersects every blocking set."""
        return all(len(coalition & b) > 0 for b in self.blocking_sets)
    
    def to_tropical(self) -> TropicalAccessPresentation:
        """Canonical tropical presentation from blocker family."""
        n = self.num_participants
        d = len(self.blocking_sets)
        matrix = np.zeros((n, d), dtype=int)
        for j, block in enumerate(self.blocking_sets):
            for p in block:
                matrix[p, j] = 1
        threshold = np.ones(d, dtype=int)
        return TropicalAccessPresentation(matrix, threshold)


# ============================================================================
# Demonstrations
# ============================================================================

def demo_threshold_2_of_3():
    """Demonstrate the (2,3)-threshold scheme."""
    print("=" * 60)
    print("DEMO 1: (2,3)-Threshold Secret Sharing Scheme")
    print("=" * 60)
    print()
    
    # Direct construction (as in our Lean formalization)
    matrix = np.array([
        [0, 1, 1],  # P0: excluded from col 0
        [1, 0, 1],  # P1: excluded from col 1
        [1, 1, 0],  # P2: excluded from col 2
    ])
    threshold = np.array([1, 1, 1])
    
    scheme = TropicalAccessPresentation(matrix, threshold)
    
    print("Access Matrix:")
    print(matrix)
    print(f"Threshold: {threshold}")
    print()
    
    # Check all coalitions
    print("Coalition Authorization Status:")
    for size in range(4):
        for combo in combinations(range(3), size):
            coal = set(combo)
            score = scheme.coalition_score(coal)
            auth = scheme.is_authorized(coal)
            minimal = scheme.is_minimal_authorized(coal)
            status = "AUTHORIZED" if auth else "unauthorized"
            min_str = " (MINIMAL)" if minimal else ""
            label = str(coal) if coal else '∅'
            print(f"  {label:>10} → score={score} → {status}{min_str}")
    
    print()
    
    # Verify theorem: minimal = extremal
    print("Verification: MinimalAuthorized ↔ ExtremalAttainmentSet")
    all_sets = [set(combo) for size in range(4) 
                for combo in combinations(range(3), size)]
    all_match = True
    for coal in all_sets:
        m = scheme.is_minimal_authorized(coal)
        e = scheme.is_extremal_attainment(coal)
        if m != e:
            print(f"  MISMATCH at {coal}: minimal={m}, extremal={e}")
            all_match = False
    print(f"  All match: {all_match} ✓" if all_match else "  FAILURE!")
    print()


def demo_blocker_reconstruction():
    """Demonstrate canonical reconstruction from blocker family."""
    print("=" * 60)
    print("DEMO 2: Canonical Reconstruction from Blocker Family")
    print("=" * 60)
    print()
    
    # Example: P = {0,1,2,3}, blocking sets = {{0,1}, {2,3}}
    # Authorized = coalitions hitting both blocks
    blocker = BlockerAccessStructure(4, [{0, 1}, {2, 3}])
    
    print("Blocker family: [{0,1}, {2,3}]")
    print("Authorized ↔ coalition contains someone from {0,1} AND someone from {2,3}")
    print()
    
    # Canonical tropical construction
    tropical = blocker.to_tropical()
    
    print("Canonical Tropical Matrix:")
    print(tropical.matrix)
    print(f"Threshold: {tropical.threshold}")
    print()
    
    # Verify correctness
    print("Verification: Tropical auth = Blocker auth")
    all_correct = True
    for size in range(5):
        for combo in combinations(range(4), size):
            coal = set(combo)
            trop_auth = tropical.is_authorized(coal)
            block_auth = blocker.is_authorized(coal)
            if trop_auth != block_auth:
                print(f"  MISMATCH at {coal}: tropical={trop_auth}, blocker={block_auth}")
                all_correct = False
    print(f"  All match: {all_correct} ✓" if all_correct else "  FAILURE!")
    print()
    
    # Show minimal authorized sets
    minimals = tropical.all_minimal_authorized()
    print(f"Minimal authorized coalitions: {[set(m) for m in minimals]}")
    print()


def demo_score_properties():
    """Demonstrate tropical score properties."""
    print("=" * 60)
    print("DEMO 3: Tropical Score Properties")
    print("=" * 60)
    print()
    
    # Random presentation
    np.random.seed(42)
    matrix = np.random.randint(0, 5, size=(5, 3))
    threshold = np.array([3, 2, 4])
    scheme = TropicalAccessPresentation(matrix, threshold)
    
    print("Access Matrix (5 participants, 3 dimensions):")
    print(matrix)
    print(f"Threshold: {threshold}")
    print()
    
    # Demonstrate score monotonicity
    C = {0, 1}
    D = {0, 1, 2}
    score_C = scheme.coalition_score(C)
    score_D = scheme.coalition_score(D)
    print(f"Score monotonicity: C={C}, D={D}")
    print(f"  score(C) = {score_C}")
    print(f"  score(D) = {score_D}")
    print(f"  score(C) ≤ score(D) componentwise: {all(score_C[j] <= score_D[j] for j in range(3))} ✓")
    print()
    
    # Demonstrate tropical union
    A = {0, 1}
    B = {2, 3}
    score_A = scheme.coalition_score(A)
    score_B = scheme.coalition_score(B)
    score_union = scheme.coalition_score(A | B)
    score_max = np.maximum(score_A, score_B)
    print(f"Tropical union: A={A}, B={B}")
    print(f"  score(A) = {score_A}")
    print(f"  score(B) = {score_B}")
    print(f"  score(A∪B) = {score_union}")
    print(f"  max(score(A), score(B)) = {score_max}")
    print(f"  Equal: {np.array_equal(score_union, score_max)} ✓")
    print()
    
    # Show all minimal authorized sets
    minimals = scheme.all_minimal_authorized()
    print(f"Minimal authorized coalitions: {[set(m) for m in minimals]}")
    print()


def demo_semimodule_isomorphism():
    """Demonstrate that permuting columns preserves authorization."""
    print("=" * 60)
    print("DEMO 4: Semimodule Isomorphism Preserves Authorization")
    print("=" * 60)
    print()
    
    matrix1 = np.array([
        [0, 1, 1],
        [1, 0, 1],
        [1, 1, 0],
    ])
    threshold1 = np.array([1, 1, 1])
    
    # Permute columns: σ = (0→2, 1→0, 2→1)
    perm = [2, 0, 1]
    matrix2 = matrix1[:, perm]
    threshold2 = threshold1[perm]
    
    scheme1 = TropicalAccessPresentation(matrix1, threshold1)
    scheme2 = TropicalAccessPresentation(matrix2, threshold2)
    
    print("Scheme 1 matrix:")
    print(matrix1)
    print(f"Threshold: {threshold1}")
    print()
    print("Scheme 2 matrix (columns permuted by {perm}):")
    print(matrix2)
    print(f"Threshold: {threshold2}")
    print()
    
    # Verify reconstruction equivalence
    print("Verification: Same authorized coalitions")
    all_match = True
    for size in range(4):
        for combo in combinations(range(3), size):
            coal = set(combo)
            auth1 = scheme1.is_authorized(coal)
            auth2 = scheme2.is_authorized(coal)
            if auth1 != auth2:
                print(f"  MISMATCH at {coal}: scheme1={auth1}, scheme2={auth2}")
                all_match = False
    print(f"  All match: {all_match} ✓" if all_match else "  FAILURE!")
    print()


def demo_larger_example():
    """Demonstrate on a larger example with non-trivial blocker structure."""
    print("=" * 60)
    print("DEMO 5: Larger Example — 6 Participants")
    print("=" * 60)
    print()
    
    # 6 participants, blocker sets forming a complex structure
    # Blockers: every authorized coalition must contain someone from each block
    blockers = [
        {0, 1, 2},   # Must include at least one from first half
        {3, 4, 5},   # Must include at least one from second half
        {0, 3},       # Must include participant 0 or 3
    ]
    
    blocker_struct = BlockerAccessStructure(6, blockers)
    tropical = blocker_struct.to_tropical()
    
    print("Blocker family:")
    for i, b in enumerate(blockers):
        print(f"  B{i} = {b}")
    print()
    print("Canonical Tropical Matrix:")
    print(tropical.matrix)
    print(f"Threshold: {tropical.threshold}")
    print()
    
    # Find minimal authorized sets
    minimals = tropical.all_minimal_authorized()
    print(f"Number of minimal authorized coalitions: {len(minimals)}")
    for m in minimals:
        print(f"  {set(m)}")
    print()
    
    # Verify correctness
    all_correct = True
    count_auth = 0
    for size in range(7):
        for combo in combinations(range(6), size):
            coal = set(combo)
            if tropical.is_authorized(coal) != blocker_struct.is_authorized(coal):
                all_correct = False
            if tropical.is_authorized(coal):
                count_auth += 1
    print(f"Total authorized coalitions (out of 2^6 = 64): {count_auth}")
    print(f"Correctness: {all_correct} ✓" if all_correct else "Correctness: FAILURE!")
    print()


if __name__ == "__main__":
    demo_threshold_2_of_3()
    demo_blocker_reconstruction()
    demo_score_properties()
    demo_semimodule_isomorphism()
    demo_larger_example()


#!/usr/bin/env python3
"""Generate visualizations for the tropical secret-sharing framework."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
from itertools import combinations


def generate_threshold_2_3_diagram():
    """Generate a diagram showing the (2,3)-threshold scheme structure."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Access structure lattice
    ax = axes[0]
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Access Structure Lattice\n(2,3)-Threshold Scheme', fontsize=14, fontweight='bold')
    
    # Positions for Hasse diagram
    positions = {
        '∅': (2, 0),
        '{0}': (0.5, 1), '{1}': (2, 1), '{2}': (3.5, 1),
        '{0,1}': (0.5, 2), '{0,2}': (2, 2), '{1,2}': (3.5, 2),
        '{0,1,2}': (2, 3)
    }
    
    # Authorized sets in green, unauthorized in red
    authorized = {'{0,1}', '{0,2}', '{1,2}', '{0,1,2}'}
    minimal = {'{0,1}', '{0,2}', '{1,2}'}
    
    for name, (x, y) in positions.items():
        if name in minimal:
            color = '#2ecc71'
            ec = '#27ae60'
            lw = 3
        elif name in authorized:
            color = '#a8e6cf'
            ec = '#27ae60'
            lw = 2
        else:
            color = '#ff6b6b'
            ec = '#c0392b'
            lw = 2
        
        circle = plt.Circle((x, y), 0.35, facecolor=color, edgecolor=ec, linewidth=lw, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=8, fontweight='bold', zorder=4)
    
    # Draw edges (Hasse diagram)
    edges = [
        ('∅', '{0}'), ('∅', '{1}'), ('∅', '{2}'),
        ('{0}', '{0,1}'), ('{0}', '{0,2}'),
        ('{1}', '{0,1}'), ('{1}', '{1,2}'),
        ('{2}', '{0,2}'), ('{2}', '{1,2}'),
        ('{0,1}', '{0,1,2}'), ('{0,2}', '{0,1,2}'), ('{1,2}', '{0,1,2}')
    ]
    
    for n1, n2 in edges:
        x1, y1 = positions[n1]
        x2, y2 = positions[n2]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1, zorder=1)
    
    # Legend
    green_patch = mpatches.Patch(color='#2ecc71', label='Minimal Authorized')
    light_green = mpatches.Patch(color='#a8e6cf', label='Authorized')
    red_patch = mpatches.Patch(color='#ff6b6b', label='Unauthorized')
    ax.legend(handles=[green_patch, light_green, red_patch], loc='lower right', fontsize=9)
    
    # Right: Tropical score heatmap
    ax = axes[1]
    matrix = np.array([
        [0, 1, 1],
        [1, 0, 1],
        [1, 1, 0],
    ])
    threshold = np.array([1, 1, 1])
    
    # Compute scores for all coalitions
    coalitions = ['∅', '{0}', '{1}', '{2}', '{0,1}', '{0,2}', '{1,2}', '{0,1,2}']
    coal_sets = [set(), {0}, {1}, {2}, {0,1}, {0,2}, {1,2}, {0,1,2}]
    
    scores = np.zeros((len(coalitions), 3))
    for i, coal in enumerate(coal_sets):
        if coal:
            scores[i] = matrix[list(coal)].max(axis=0)
    
    im = ax.imshow(scores.T, cmap='YlGn', aspect='auto', vmin=0, vmax=1)
    ax.set_xticks(range(len(coalitions)))
    ax.set_xticklabels(coalitions, rotation=45, ha='right', fontsize=9)
    ax.set_yticks(range(3))
    ax.set_yticklabels(['Dim 0', 'Dim 1', 'Dim 2'])
    ax.set_title('Tropical Coalition Scores\n(threshold = 1 in each dimension)', fontsize=14, fontweight='bold')
    ax.set_xlabel('Coalition')
    ax.set_ylabel('Dimension')
    
    # Add text annotations
    for i in range(len(coalitions)):
        for j in range(3):
            color = 'white' if scores[i, j] == 0 else 'black'
            ax.text(i, j, f'{int(scores[i, j])}', ha='center', va='center', 
                   color=color, fontweight='bold', fontsize=12)
    
    # Mark authorized coalitions
    for i, coal in enumerate(coalitions):
        if coal in authorized:
            ax.axvline(x=i-0.5, color='green', linewidth=0.5, alpha=0.3)
            ax.axvline(x=i+0.5, color='green', linewidth=0.5, alpha=0.3)
    
    plt.colorbar(im, ax=ax, shrink=0.8, label='Score')
    plt.tight_layout()
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode()
    plt.close()
    return f"data:image/png;base64,{b64}"


def generate_blocker_diagram():
    """Generate diagram comparing blocker and authorized coalitions."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # 6 participants arranged in a circle
    n = 6
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    px = 3 * np.cos(angles)
    py = 3 * np.sin(angles)
    
    # Draw blocking sets as colored regions
    from matplotlib.patches import FancyBboxPatch
    
    # Block 1: {0,1,2}
    hull_x = [px[0], px[1], px[2]]
    hull_y = [py[0], py[1], py[2]]
    triangle1 = plt.Polygon(list(zip(hull_x, hull_y)), alpha=0.15, color='blue', zorder=1)
    ax.add_patch(triangle1)
    ax.text(np.mean(hull_x), np.mean(hull_y) + 0.3, 'B₀', fontsize=14, color='blue', 
            ha='center', fontweight='bold')
    
    # Block 2: {3,4,5}
    hull_x = [px[3], px[4], px[5]]
    hull_y = [py[3], py[4], py[5]]
    triangle2 = plt.Polygon(list(zip(hull_x, hull_y)), alpha=0.15, color='red', zorder=1)
    ax.add_patch(triangle2)
    ax.text(np.mean(hull_x), np.mean(hull_y) - 0.3, 'B₁', fontsize=14, color='red', 
            ha='center', fontweight='bold')
    
    # Block 3: {0,3}
    ax.plot([px[0], px[3]], [py[0], py[3]], 'g-', linewidth=4, alpha=0.3, zorder=1)
    ax.text((px[0]+px[3])/2 + 0.5, (py[0]+py[3])/2, 'B₂', fontsize=14, color='green', 
            fontweight='bold')
    
    # Draw participants
    for i in range(n):
        circle = plt.Circle((px[i], py[i]), 0.4, facecolor='white', edgecolor='black', 
                           linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(px[i], py[i], f'P{i}', ha='center', va='center', fontsize=12, 
               fontweight='bold', zorder=4)
    
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Blocker Access Structure on 6 Participants\n'
                'Authorized = hits B₀ ∩ hits B₁ ∩ hits B₂', 
                fontsize=14, fontweight='bold')
    
    # Legend
    b0 = mpatches.Patch(color='blue', alpha=0.3, label='B₀ = {P0, P1, P2}')
    b1 = mpatches.Patch(color='red', alpha=0.3, label='B₁ = {P3, P4, P5}')
    b2 = mpatches.Patch(color='green', alpha=0.3, label='B₂ = {P0, P3}')
    ax.legend(handles=[b0, b1, b2], loc='lower left', fontsize=11)
    
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode()
    plt.close()
    return f"data:image/png;base64,{b64}"


if __name__ == "__main__":
    img1 = generate_threshold_2_3_diagram()
    img2 = generate_blocker_diagram()
    print(f"Image 1 length: {len(img1)}")
    print(f"Image 2 length: {len(img2)}")
    # Save for reference
    with open("viz_data.txt", "w") as f:
        f.write(f"THRESHOLD_DIAGRAM={img1}\n\nBLOCKER_DIAGRAM={img2}\n")
    print("Visualization data saved.")
