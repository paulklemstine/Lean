#!/usr/bin/env python3
"""
Applications of Non-Well-Founded Proof Theory

Real-world applications of self-referential proof structures:
1. Circular reasoning detection in argument analysis
2. Self-referential software verification
3. Fixed-point semantics for recursive type systems
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Callable


# ============================================================
# Application 1: Circular Reasoning Detection
# ============================================================

@dataclass
class Argument:
    """An argument with premises and a conclusion."""
    name: str
    conclusion: str
    premises: list[str]


def detect_circular_reasoning(arguments: list[Argument]) -> list[list[str]]:
    """
    Detect circular reasoning chains in a set of arguments.

    Uses NWF proof theory: a circular chain corresponds to a
    self-referential proof tree. If the chain is "productive"
    (each step adds information), it may be a valid NWF proof.

    Returns: List of circular chains found.
    """
    # Build dependency graph
    conclusion_to_arg: dict[str, list[Argument]] = {}
    for arg in arguments:
        conclusion_to_arg.setdefault(arg.conclusion, []).append(arg)

    # Find cycles using DFS
    cycles: list[list[str]] = []
    visited: set[str] = set()
    path: list[str] = []

    def dfs(prop: str) -> None:
        if prop in path:
            cycle_start = path.index(prop)
            cycles.append(path[cycle_start:] + [prop])
            return
        if prop in visited:
            return
        visited.add(prop)
        path.append(prop)
        for arg in conclusion_to_arg.get(prop, []):
            for premise in arg.premises:
                dfs(premise)
        path.pop()

    for arg in arguments:
        dfs(arg.conclusion)

    return cycles


def classify_circular_argument(cycle: list[str],
                                arguments: list[Argument]) -> str:
    """
    Classify a circular argument as valid or invalid NWF proof.

    A circular argument is "valid" (in NWF terms) if each step
    in the cycle genuinely adds information (is productive).
    It's "invalid" (like the liar sentence) if it's purely circular
    with no information gain.
    """
    # Check if any step in the cycle introduces new information
    conclusions_in_cycle = set(cycle)
    for arg in arguments:
        if arg.conclusion in conclusions_in_cycle:
            external_premises = [p for p in arg.premises
                                if p not in conclusions_in_cycle]
            if external_premises:
                return "VALID_NWF (productive self-reference with external input)"
    return "INVALID (pure circularity, like the liar sentence)"


# ============================================================
# Application 2: Recursive Type System Verification
# ============================================================

@dataclass
class RecursiveType:
    """A potentially recursive type definition."""
    name: str
    fields: dict[str, str]  # field_name -> type_name


def verify_recursive_types(types: list[RecursiveType]) -> dict[str, str]:
    """
    Verify that recursive type definitions are well-founded.

    Uses NWF proof theory: a recursive type is valid if the
    self-reference goes through an indirection (like Option/List)
    that ensures termination. This corresponds to a valid NWF
    proof with finite ordinal height.
    """
    type_names = {t.name for t in types}
    results: dict[str, str] = {}

    for t in types:
        self_refs = [f for f, ft in t.fields.items()
                    if t.name in ft]
        if not self_refs:
            results[t.name] = "NON_RECURSIVE (ordinal height 0)"
            continue

        # Check for indirection
        indirect = all("Option" in t.fields[f] or "List" in t.fields[f]
                       for f in self_refs)
        if indirect:
            results[t.name] = "VALID_NWF (guarded recursion, finite height)"
        else:
            results[t.name] = "POTENTIALLY_INVALID (unguarded self-reference)"

    return results


# ============================================================
# Application 3: Fixed-Point Analysis of Feedback Systems
# ============================================================

def analyze_feedback_system(
    state_dim: int,
    feedback: Callable[[list[float]], list[float]],
    initial: list[float],
    tolerance: float = 1e-6,
    max_iter: int = 1000,
) -> dict:
    """
    Analyze a feedback system using NWF fixed-point theory.

    A feedback system is like a self-referential proof:
    the output depends on the input, which depends on the output.
    The system converges if it's a contraction (like a valid NWF proof).

    Returns analysis including convergence status and fixed point.
    """
    state = list(initial)
    history = [list(state)]

    for i in range(max_iter):
        new_state = feedback(state)
        history.append(list(new_state))

        # Check convergence
        max_diff = max(abs(a - b) for a, b in zip(state, new_state))
        if max_diff < tolerance:
            return {
                "converged": True,
                "iterations": i + 1,
                "fixed_point": new_state,
                "type": "VALID_NWF (contraction)",
            }
        state = new_state

    return {
        "converged": False,
        "iterations": max_iter,
        "final_state": state,
        "type": "POTENTIALLY_DIVERGENT (not a contraction)",
    }


# ============================================================
# Demonstrations
# ============================================================

def demo_circular_reasoning():
    """Demonstrate circular reasoning detection."""
    print("=" * 60)
    print("APPLICATION 1: Circular Reasoning Detection")
    print("=" * 60)

    arguments = [
        Argument("A1", "God exists", ["The Bible says so"]),
        Argument("A2", "The Bible is true", ["God wrote it"]),
        Argument("A3", "God wrote it", ["God exists"]),
        Argument("A4", "Electrons exist", ["We observe their effects"]),
        Argument("A5", "We observe their effects", ["Instruments detect them"]),
    ]

    cycles = detect_circular_reasoning(arguments)
    print(f"  Found {len(cycles)} circular chain(s):")
    for cycle in cycles:
        print(f"    {' → '.join(cycle)}")
        classification = classify_circular_argument(cycle, arguments)
        print(f"    Classification: {classification}")
    print()


def demo_recursive_types():
    """Demonstrate recursive type verification."""
    print("=" * 60)
    print("APPLICATION 2: Recursive Type Verification")
    print("=" * 60)

    types = [
        RecursiveType("Nat", {"zero": "Unit", "succ": "Nat"}),
        RecursiveType("List", {"nil": "Unit", "cons": "Pair(A, List)"}),
        RecursiveType("Tree", {"leaf": "A", "node": "Pair(Tree, Tree)"}),
        RecursiveType("SafeTree", {"leaf": "A", "node": "List(Option(SafeTree))"}),
        RecursiveType("Person", {"name": "String", "age": "Int"}),
    ]

    results = verify_recursive_types(types)
    for name, status in results.items():
        print(f"  {name}: {status}")
    print()


def demo_feedback_system():
    """Demonstrate feedback system analysis."""
    print("=" * 60)
    print("APPLICATION 3: Feedback System Analysis")
    print("=" * 60)

    # Contractive system (valid NWF proof analog)
    def contractive_feedback(state: list[float]) -> list[float]:
        return [0.5 * x + 1.0 for x in state]

    result = analyze_feedback_system(
        state_dim=3,
        feedback=contractive_feedback,
        initial=[0.0, 0.0, 0.0],
    )
    print(f"  Contractive system:")
    print(f"    Converged: {result['converged']}")
    print(f"    Iterations: {result['iterations']}")
    print(f"    Fixed point: {[f'{x:.4f}' for x in result.get('fixed_point', [])]}")
    print(f"    Type: {result['type']}")
    print()

    # Non-contractive system (invalid NWF proof analog)
    def expansive_feedback(state: list[float]) -> list[float]:
        return [2.0 * x + 0.1 for x in state]

    result = analyze_feedback_system(
        state_dim=2,
        feedback=expansive_feedback,
        initial=[0.1, 0.1],
        max_iter=20,
    )
    print(f"  Expansive system:")
    print(f"    Converged: {result['converged']}")
    print(f"    Type: {result['type']}")
    print()


if __name__ == "__main__":
    demo_circular_reasoning()
    demo_recursive_types()
    demo_feedback_system()


#!/usr/bin/env python3
"""
Non-Well-Founded Proofs: Demonstration Script

Demonstrates the key concepts from the formalization:
1. Building and validating non-well-founded proof trees
2. Computing ordinal heights
3. Fixed-point iteration for proof operators
4. Tropical semiring operations on proof heights
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable
import math


# ============================================================
# Section 1: Proof Tree Data Structure
# ============================================================

class NodeType(Enum):
    AXIOM = auto()
    MODUS_PONENS = auto()
    SELF_REF = auto()
    BOTTOM = auto()


@dataclass
class NWFProofTree:
    """Non-well-founded proof tree node."""
    node_type: NodeType
    conclusion: Optional[int] = None  # PropId
    premise: Optional[int] = None
    children: tuple['NWFProofTree', ...] = ()

    @staticmethod
    def axiom_(p: int) -> 'NWFProofTree':
        return NWFProofTree(NodeType.AXIOM, conclusion=p)

    @staticmethod
    def modus_ponens(t1: 'NWFProofTree', t2: 'NWFProofTree',
                     premise: int, conclusion: int) -> 'NWFProofTree':
        return NWFProofTree(NodeType.MODUS_PONENS, conclusion=conclusion,
                           premise=premise, children=(t1, t2))

    @staticmethod
    def self_ref(p: int, inner: 'NWFProofTree') -> 'NWFProofTree':
        return NWFProofTree(NodeType.SELF_REF, conclusion=p, children=(inner,))

    @staticmethod
    def bottom() -> 'NWFProofTree':
        return NWFProofTree(NodeType.BOTTOM)

    def depth(self) -> int:
        if self.node_type == NodeType.AXIOM:
            return 0
        elif self.node_type == NodeType.MODUS_PONENS:
            return 1 + max(self.children[0].depth(), self.children[1].depth())
        elif self.node_type == NodeType.SELF_REF:
            return 1 + self.children[0].depth()
        else:
            return 0

    def ordinal_height(self) -> int:
        """Ordinal height (finite approximation)."""
        if self.node_type == NodeType.AXIOM:
            return 0
        elif self.node_type == NodeType.MODUS_PONENS:
            return max(self.children[0].ordinal_height(),
                      self.children[1].ordinal_height()) + 1
        elif self.node_type == NodeType.SELF_REF:
            return self.children[0].ordinal_height() + 1
        else:
            return 0

    def is_valid(self) -> bool:
        if self.node_type == NodeType.AXIOM:
            return True
        elif self.node_type == NodeType.MODUS_PONENS:
            t1, t2 = self.children
            return (t1.conclusion == self.premise and
                    t2.conclusion == self.conclusion and
                    t1.is_valid() and t2.is_valid())
        elif self.node_type == NodeType.SELF_REF:
            inner = self.children[0]
            return inner.conclusion == self.conclusion and inner.is_valid()
        else:
            return False

    def has_self_ref(self) -> bool:
        if self.node_type == NodeType.SELF_REF:
            return True
        return any(c.has_self_ref() for c in self.children)

    def self_ref_depth(self) -> int:
        if self.node_type == NodeType.AXIOM or self.node_type == NodeType.BOTTOM:
            return 0
        elif self.node_type == NodeType.MODUS_PONENS:
            return max(c.self_ref_depth() for c in self.children)
        elif self.node_type == NodeType.SELF_REF:
            return 1 + self.children[0].self_ref_depth()
        return 0

    def __repr__(self) -> str:
        if self.node_type == NodeType.AXIOM:
            return f"Axiom({self.conclusion})"
        elif self.node_type == NodeType.MODUS_PONENS:
            return f"MP({self.children[0]}, {self.children[1]}, {self.premise}→{self.conclusion})"
        elif self.node_type == NodeType.SELF_REF:
            return f"SelfRef({self.conclusion}, {self.children[0]})"
        else:
            return "⊥"


# ============================================================
# Section 2: Key Examples
# ============================================================

def demo_identity_proof():
    """Demonstrate: P → P has a valid self-referential proof of height 1."""
    print("=" * 60)
    print("DEMO 1: The Identity Proof (P → P)")
    print("=" * 60)

    p = 42  # Arbitrary proposition ID
    identity = NWFProofTree.self_ref(p, NWFProofTree.axiom_(p))

    print(f"  Proof tree: {identity}")
    print(f"  Conclusion: {identity.conclusion}")
    print(f"  Valid: {identity.is_valid()}")
    print(f"  Ordinal height: {identity.ordinal_height()}")
    print(f"  Has self-reference: {identity.has_self_ref()}")
    print(f"  Self-ref depth: {identity.self_ref_depth()}")
    print(f"  Structural depth: {identity.depth()}")
    print()
    assert identity.is_valid()
    assert identity.ordinal_height() == 1
    assert identity.has_self_ref()
    print("  ✓ All assertions passed!")
    print()


def demo_liar_sentence():
    """Demonstrate: The liar sentence is NOT a valid NWF proof."""
    print("=" * 60)
    print("DEMO 2: The Liar Sentence")
    print("=" * 60)

    p = 99
    liar = NWFProofTree.self_ref(p, NWFProofTree.bottom())

    print(f"  Proof tree: {liar}")
    print(f"  Conclusion: {liar.conclusion}")
    print(f"  Valid: {liar.is_valid()}")
    print(f"  Ordinal height: {liar.ordinal_height()}")
    print(f"  Has self-reference: {liar.has_self_ref()}")
    print()
    assert not liar.is_valid()
    print("  ✓ Liar sentence correctly identified as invalid!")
    print()


def demo_composition():
    """Demonstrate proof composition via modus ponens."""
    print("=" * 60)
    print("DEMO 3: Proof Composition")
    print("=" * 60)

    # Build: axiom(1), axiom(2), compose via MP
    t1 = NWFProofTree.axiom_(1)
    t2 = NWFProofTree.axiom_(2)
    composed = NWFProofTree.modus_ponens(t1, t2, 1, 2)

    print(f"  t1: {t1} (height {t1.ordinal_height()})")
    print(f"  t2: {t2} (height {t2.ordinal_height()})")
    print(f"  MP(t1, t2): {composed} (height {composed.ordinal_height()})")
    print(f"  Valid: {composed.is_valid()}")
    print()

    # Build nested self-referential proof
    inner = NWFProofTree.self_ref(3, NWFProofTree.axiom_(3))
    nested = NWFProofTree.self_ref(3, inner)
    print(f"  Nested self-ref: {nested}")
    print(f"  Height: {nested.ordinal_height()}")
    print(f"  Self-ref depth: {nested.self_ref_depth()}")
    print(f"  Structural depth: {nested.depth()}")
    print(f"  self_ref_depth ≤ depth: {nested.self_ref_depth() <= nested.depth()}")
    print()
    assert nested.self_ref_depth() <= nested.depth()
    print("  ✓ Self-reference depth bounded by structural depth!")
    print()


# ============================================================
# Section 3: Fixed-Point Iteration
# ============================================================

def demo_fixed_point():
    """Demonstrate Kleene fixed-point iteration for proof operators."""
    print("=" * 60)
    print("DEMO 4: Fixed-Point Iteration")
    print("=" * 60)

    # Define a simple proof operator: step(a)(p) = min(a(p) + 1, 5)
    # for axiom propositions, otherwise a(p)
    axioms = {0, 1, 2}

    def step(approx: dict[int, int]) -> dict[int, int]:
        result = dict(approx)
        for p in range(10):
            if p in axioms:
                result[p] = max(result.get(p, 0), 1)
            # Derive p+3 from p (simulating a deduction rule)
            if result.get(p, 0) > 0 and p + 3 < 10:
                result[p + 3] = max(result.get(p + 3, 0), result[p])
        return result

    # Iterate from bottom
    approx = {p: 0 for p in range(10)}
    print("  Kleene iteration:")
    for i in range(8):
        approx = step(approx)
        nonzero = {p: v for p, v in approx.items() if v > 0}
        print(f"    Step {i+1}: {nonzero}")

    # Check stabilization
    prev = dict(approx)
    approx = step(approx)
    if approx == prev:
        print(f"\n  ✓ Fixed point reached! Stable approximation found.")
    print()


# ============================================================
# Section 4: Tropical Proof Heights
# ============================================================

def demo_tropical():
    """Demonstrate tropical semiring operations on proof heights."""
    print("=" * 60)
    print("DEMO 5: Tropical Proof Heights")
    print("=" * 60)

    INF = float('inf')

    def trop_add(a: float, b: float) -> float:
        """Tropical addition = min (shortest proof)."""
        return min(a, b)

    def trop_mul(a: float, b: float) -> float:
        """Tropical multiplication = + (compose proofs)."""
        return a + b

    # Demonstrate properties
    heights = [1, 3, 5, 7, INF]
    print("  Tropical addition (min):")
    for a in heights:
        for b in heights:
            print(f"    {a} ⊕ {b} = {trop_add(a, b)}")

    print("\n  Tropical multiplication (add):")
    for a in [1, 2, 3]:
        for b in [1, 2, 3]:
            print(f"    {a} ⊗ {b} = {trop_mul(a, b)}")

    # Verify distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
    print("\n  Distributivity check:")
    for a in [1, 2, 3]:
        for b in [1, 2, 3]:
            for c in [1, 2, 3]:
                lhs = trop_mul(a, trop_add(b, c))
                rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
                ok = "✓" if lhs == rhs else "✗"
                if lhs != rhs:
                    print(f"    {ok} {a} ⊗ ({b} ⊕ {c}) = {lhs} vs {rhs}")
                else:
                    print(f"    {ok} {a} ⊗ ({b} ⊕ {c}) = {lhs}")

    print()


# ============================================================
# Run all demos
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  NON-WELL-FOUNDED PROOFS: DEMONSTRATION")
    print("=" * 60 + "\n")

    demo_identity_proof()
    demo_liar_sentence()
    demo_composition()
    demo_fixed_point()
    demo_tropical()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualization 2: Fixed-Point Convergence of Proof Operators

Visualizes how Kleene iteration converges to a fixed point
for proof operators, showing the proof approximation lattice
evolving over iterations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def proof_operator_step(approx, axiom_set, rules):
    """Apply one step of a proof operator."""
    result = dict(approx)
    # Axioms get evidence
    for p in axiom_set:
        result[p] = max(result.get(p, 0), 1)
    # Apply deduction rules
    for (premise, conclusion) in rules:
        if result.get(premise, 0) > 0:
            result[conclusion] = max(result.get(conclusion, 0),
                                     result.get(premise, 0))
    return result


# Set up proof system
num_props = 8
axioms = {0, 1}
rules = [(0, 2), (1, 3), (2, 4), (3, 5), (4, 6), (5, 7), (2, 5)]

# Run Kleene iteration
history = []
approx = {p: 0 for p in range(num_props)}
history.append(list(approx.values()))

for _ in range(10):
    approx = proof_operator_step(approx, axioms, rules)
    history.append(list(approx.values()))

history = np.array(history)

# Create visualization
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Fixed-Point Convergence of Proof Operators',
             fontsize=14, fontweight='bold')

# Plot 1: Heatmap of iterations
im = ax1.imshow(history.T, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax1.set_xlabel('Iteration', fontsize=11)
ax1.set_ylabel('Proposition', fontsize=11)
ax1.set_title('Proof Status per Iteration', fontsize=12)
ax1.set_yticks(range(num_props))
ax1.set_yticklabels([f'P{i}' for i in range(num_props)])
plt.colorbar(im, ax=ax1, label='Evidence Level')

# Mark convergence point
for p in range(num_props):
    for i in range(len(history) - 1):
        if history[i, p] == history[-1, p] and history[i, p] > 0:
            ax1.plot(i, p, 'g*', markersize=8, zorder=5)
            break

# Plot 2: Convergence curves
colors = plt.cm.tab10(np.linspace(0, 1, num_props))
for p in range(num_props):
    ax2.plot(range(len(history)), history[:, p], 'o-',
             color=colors[p], label=f'P{p}', linewidth=2, markersize=4)
ax2.set_xlabel('Iteration', fontsize=11)
ax2.set_ylabel('Evidence Level', fontsize=11)
ax2.set_title('Convergence Trajectories', fontsize=12)
ax2.legend(ncol=2, fontsize=8)
ax2.grid(True, alpha=0.3)

# Plot 3: Deductive closure growth
closure_sizes = [sum(1 for v in row if v > 0) for row in history]
ax3.bar(range(len(closure_sizes)), closure_sizes, color='#2196F3', alpha=0.7)
ax3.plot(range(len(closure_sizes)), closure_sizes, 'r-o', linewidth=2)
ax3.set_xlabel('Iteration', fontsize=11)
ax3.set_ylabel('|Deductive Closure|', fontsize=11)
ax3.set_title('Growth of Deductive Closure', fontsize=12)
ax3.set_ylim(0, num_props + 0.5)
ax3.grid(True, alpha=0.3, axis='y')

# Add annotation for fixed point
final_size = closure_sizes[-1]
ax3.axhline(y=final_size, color='green', linestyle='--', alpha=0.5)
ax3.text(len(closure_sizes) - 1, final_size + 0.3, f'Fixed point: {final_size} props',
         ha='right', fontsize=9, color='green')

plt.tight_layout()
plt.savefig('viz_fixed_point.png', dpi=150, bbox_inches='tight')
print("Saved viz_fixed_point.png")


#!/usr/bin/env python3
"""
Visualization 1: Non-Well-Founded Proof Tree Structure

Visualizes the structure of different NWF proof trees,
showing valid vs invalid proofs, self-referential nodes,
and ordinal heights using a tree layout.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_proof_tree(ax, tree_type, title, positions, edges, colors, labels, heights):
    """Draw a proof tree on the given axes."""
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw edges
    for (x1, y1), (x2, y2) in edges:
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, zorder=1)

    # Draw nodes
    for (x, y), color, label, h in zip(positions, colors, labels, heights):
        circle = plt.Circle((x, y), 0.3, facecolor=color, edgecolor='black',
                            linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, label, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=3)
        ax.text(x, y - 0.15, f'h={h}', ha='center', va='center', fontsize=7,
                color='gray', zorder=3)


fig, axes = plt.subplots(1, 4, figsize=(16, 5))
fig.suptitle('Non-Well-Founded Proof Trees', fontsize=14, fontweight='bold', y=0.98)

# Tree 1: Axiom (trivial)
draw_proof_tree(axes[0], 'axiom', 'Axiom\n(Well-Founded)',
    positions=[(1.5, 1.5)],
    edges=[],
    colors=['#4CAF50'],
    labels=['Ax(P)'],
    heights=[0])
axes[0].text(1.5, 0.3, 'Valid ✓\nNo self-reference',
             ha='center', fontsize=9, color='green')

# Tree 2: Identity proof (P → P via self-reference)
draw_proof_tree(axes[1], 'identity', 'Identity (P→P)\n(Valid NWF)',
    positions=[(1.5, 2.5), (1.5, 1.0)],
    edges=[((1.5, 2.5), (1.5, 1.0))],
    colors=['#FF9800', '#4CAF50'],
    labels=['Self(P)', 'Ax(P)'],
    heights=[1, 0])
# Draw self-reference arrow
angle = np.linspace(0, 2*np.pi*0.6, 50)
r = 0.6
cx, cy = 2.3, 2.5
ax_arrow_x = cx + r * np.cos(angle)
ax_arrow_y = cy + r * np.sin(angle)
axes[1].plot(ax_arrow_x, ax_arrow_y, 'b--', linewidth=1.5, alpha=0.5)
axes[1].annotate('', xy=(1.8, 2.5), xytext=(2.1, 2.9),
                arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))
axes[1].text(1.5, 0.1, 'Valid ✓\nHeight = 1',
             ha='center', fontsize=9, color='green')

# Tree 3: Liar sentence (invalid)
draw_proof_tree(axes[2], 'liar', 'Liar Sentence\n(Invalid NWF)',
    positions=[(1.5, 2.5), (1.5, 1.0)],
    edges=[((1.5, 2.5), (1.5, 1.0))],
    colors=['#FF9800', '#F44336'],
    labels=['Self(P)', '⊥'],
    heights=[1, 0])
axes[2].text(1.5, 0.1, 'Invalid ✗\nBottom has no conclusion',
             ha='center', fontsize=9, color='red')

# Tree 4: Modus Ponens composition
draw_proof_tree(axes[3], 'mp', 'Modus Ponens\n(Composition)',
    positions=[(1.5, 2.8), (0.5, 1.5), (2.5, 1.5),
               (0.5, 0.3), (2.5, 0.3)],
    edges=[((1.5, 2.8), (0.5, 1.5)), ((1.5, 2.8), (2.5, 1.5)),
           ((0.5, 1.5), (0.5, 0.3)), ((2.5, 1.5), (2.5, 0.3))],
    colors=['#2196F3', '#FF9800', '#4CAF50', '#4CAF50', '#4CAF50'],
    labels=['MP', 'Self(Q)', 'Ax(Q)', 'Ax(P)', 'Ax(Q)'],
    heights=[2, 1, 0, 0, 0])
axes[3].text(1.5, -0.4, 'Valid ✓\nHeight = 2',
             ha='center', fontsize=9, color='green')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#4CAF50', edgecolor='black', label='Axiom'),
    mpatches.Patch(facecolor='#FF9800', edgecolor='black', label='Self-Reference'),
    mpatches.Patch(facecolor='#2196F3', edgecolor='black', label='Modus Ponens'),
    mpatches.Patch(facecolor='#F44336', edgecolor='black', label='Bottom (⊥)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4,
          fontsize=10, bbox_to_anchor=(0.5, 0.01))

plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_proof_trees.png', dpi=150, bbox_inches='tight')
print("Saved viz_proof_trees.png")


#!/usr/bin/env python3
"""
Visualization 3: Tropical Proof Height Geometry

Visualizes the tropical semiring structure of proof heights,
showing how min/plus operations create tropical geometric
structures in proof complexity space.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_add(a, b):
    """Tropical addition = min."""
    return np.minimum(a, b)


def tropical_mul(a, b):
    """Tropical multiplication = +."""
    return a + b


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Tropical Geometry of Proof Heights',
             fontsize=15, fontweight='bold', y=0.98)

# Plot 1: Tropical "lines" (piecewise linear functions)
ax = axes[0, 0]
x = np.linspace(-3, 5, 300)

# Tropical polynomial: min(2+x, 3, 1+2x) — each term is a "proof strategy"
y1 = 2 + x
y2 = np.full_like(x, 3.0)
y3 = 1 + 2*x
tropical_poly = np.minimum(np.minimum(y1, y2), y3)

ax.plot(x, y1, '--', color='#FF9800', alpha=0.5, label='Strategy 1: 2+x')
ax.plot(x, y2, '--', color='#2196F3', alpha=0.5, label='Strategy 2: 3')
ax.plot(x, y3, '--', color='#4CAF50', alpha=0.5, label='Strategy 3: 1+2x')
ax.plot(x, tropical_poly, 'k-', linewidth=3, label='Optimal (tropical min)')
ax.fill_between(x, tropical_poly, 8, alpha=0.1, color='gray')
ax.set_xlabel('Input complexity parameter', fontsize=10)
ax.set_ylabel('Proof height', fontsize=10)
ax.set_title('Tropical Proof "Polynomial"\n(Best strategy = min of all options)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 8)

# Plot 2: Tropical proof distance heatmap
ax = axes[0, 1]
n = 8
# Simulate proof heights for different systems
np.random.seed(42)
systems = []
for i in range(n):
    heights = np.random.randint(1, 10, size=5).astype(float)
    if np.random.random() < 0.3:
        heights[np.random.randint(0, 5)] = np.inf
    systems.append(heights)

# Compute tropical distances
dist_matrix = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        max_diff = 0
        for k in range(5):
            a, b = systems[i][k], systems[j][k]
            if np.isinf(a) and np.isinf(b):
                continue
            if np.isinf(a) or np.isinf(b):
                max_diff = 20  # cap for visualization
                break
            max_diff = max(max_diff, abs(a - b))
        dist_matrix[i, j] = max_diff

im = ax.imshow(dist_matrix, cmap='viridis', interpolation='nearest')
ax.set_xlabel('Proof System', fontsize=10)
ax.set_ylabel('Proof System', fontsize=10)
ax.set_title('Tropical Distance Between\nProof Systems', fontsize=11)
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels([f'S{i}' for i in range(n)])
ax.set_yticklabels([f'S{i}' for i in range(n)])
plt.colorbar(im, ax=ax, label='Max height difference')

# Plot 3: Self-reference depth vs ordinal height
ax = axes[1, 0]
depths = list(range(8))
# For each self-ref depth, show range of possible heights
for d in depths:
    # Height ≥ depth (from selfRefDepth_le_depth theorem)
    heights_range = range(d, d + 5)
    ax.barh(d, len(heights_range), left=d, height=0.6,
            color=plt.cm.Oranges(d / 8), edgecolor='black', alpha=0.7)
    ax.plot(d, d, 'r*', markersize=12, zorder=5)

# Draw the diagonal bound
ax.plot(depths, depths, 'r--', linewidth=2, label='selfRefDepth ≤ height (proved)')
ax.set_xlabel('Ordinal Height', fontsize=10)
ax.set_ylabel('Self-Reference Depth', fontsize=10)
ax.set_title('Self-Reference Depth vs Height\n(Proved: depth ≤ height)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 4: Tropical distributivity visualization
ax = axes[1, 1]
a_vals = np.arange(0, 6)
b_vals = np.arange(0, 6)
A, B = np.meshgrid(a_vals, b_vals)

c = 2  # fixed c value
# LHS: a ⊗ (b ⊕ c) = a + min(b, c)
LHS = A + np.minimum(B, c)
# RHS: (a ⊗ b) ⊕ (a ⊗ c) = min(a+b, a+c)
RHS = np.minimum(A + B, A + c)

# They should be equal (proved in Lean!)
diff = np.abs(LHS - RHS)
im = ax.imshow(diff, cmap='RdYlGn_r', interpolation='nearest',
               extent=[0, 5, 5, 0], vmin=0, vmax=0.1)
ax.set_xlabel('a (proof composition cost)', fontsize=10)
ax.set_ylabel('b (proof height)', fontsize=10)
ax.set_title(f'Tropical Distributivity Verification\na ⊗ (b ⊕ {c}) = (a ⊗ b) ⊕ (a ⊗ {c})\n(All green = theorem holds)', fontsize=11)
plt.colorbar(im, ax=ax, label='|LHS - RHS|')

# Add "VERIFIED" stamp
ax.text(2.5, 2.5, '✓ VERIFIED', fontsize=18, fontweight='bold',
        color='green', ha='center', va='center', alpha=0.7,
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical.png")
