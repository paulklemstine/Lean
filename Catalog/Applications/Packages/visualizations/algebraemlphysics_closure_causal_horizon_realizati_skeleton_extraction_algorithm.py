#!/usr/bin/env python3
"""
Closure-Causal Horizon Duality: Demo and Visualization

Demonstrates the finite causal reconstruction theorem with concrete examples:
1. Chain (total order) causal structure
2. Diamond causal structure
3. Random DAG reconstruction

Implements the skeleton extraction algorithm and visualizes results.
"""

import itertools
from collections import defaultdict
from typing import Dict, FrozenSet, List, Set, Tuple, Optional
import json
import base64
import io

# ============================================================
# Core Data Structures
# ============================================================

class FiniteCausalClosure:
    """A finite causal closure structure on a set X."""

    def __init__(self, elements: List[str], successors: Dict[str, Set[str]]):
        """
        Args:
            elements: List of element names
            successors: Dict mapping each element to its causal successors
        """
        self.elements = elements
        self.successors = successors
        # Build transitive closure of successor relation for the closure operator
        self._reachable = self._compute_reachability()

    def _compute_reachability(self) -> Dict[str, Set[str]]:
        """Compute transitive closure of successor relation."""
        reach = {x: set(self.successors.get(x, set())) for x in self.elements}
        # Warshall's algorithm
        for k in self.elements:
            for i in self.elements:
                if k in reach[i]:
                    reach[i] |= reach[k]
        return reach

    def cl(self, A: FrozenSet[str]) -> FrozenSet[str]:
        """Closure operator: close A under causal reachability and interval completion."""
        result = set(A)
        # Add everything reachable from elements of A
        for x in A:
            result |= self._reachable.get(x, set())
        # Interval completion: if a, c ∈ result and a → b → c, add b
        changed = True
        while changed:
            changed = False
            for b in self.elements:
                if b not in result:
                    # Check if b is on a causal path between two elements of result
                    has_pred = any(b in self._reachable.get(a, set()) for a in result)
                    has_succ = any(c in self._reachable.get(b, set()) for c in result)
                    if has_pred and has_succ:
                        result.add(b)
                        changed = True
        return frozenset(result)

    def principal_future(self, x: str) -> FrozenSet[str]:
        """Principal future of x: cl({x})."""
        return self.cl(frozenset([x]))

    def is_closed(self, A: FrozenSet[str]) -> bool:
        """Check if A is a fixed point of cl."""
        return self.cl(A) == A

    def all_closed_sets(self) -> List[FrozenSet[str]]:
        """Enumerate all closed sets (subsets that are fixed points of cl)."""
        closed = []
        for r in range(len(self.elements) + 1):
            for subset in itertools.combinations(self.elements, r):
                s = frozenset(subset)
                if self.is_closed(s):
                    closed.append(s)
        return closed

    def is_join_irreducible(self, A: FrozenSet[str]) -> bool:
        """Check if closed set A is join-irreducible."""
        if not A or not self.is_closed(A):
            return False
        closed_sets = self.all_closed_sets()
        for B in closed_sets:
            for D in closed_sets:
                if B | D == A and B != A and D != A:
                    return False
        return True

    def join_irreducible_closed_sets(self) -> List[FrozenSet[str]]:
        """Find all join-irreducible closed sets."""
        return [A for A in self.all_closed_sets() if self.is_join_irreducible(A)]

    def skeleton_edges(self) -> List[Tuple[FrozenSet[str], FrozenSet[str]]]:
        """Compute skeleton edges (cover relation on join-irreducibles)."""
        ji = self.join_irreducible_closed_sets()
        edges = []
        for A in ji:
            for B in ji:
                if A < B:  # strict subset
                    # Check no join-irreducible D between A and B
                    has_between = any(
                        A < D < B for D in ji if D != A and D != B
                    )
                    if not has_between:
                        edges.append((A, B))
        return edges

    def closure_rank(self, A: FrozenSet[str]) -> int:
        """Closure rank: number of strictly smaller closed sets."""
        return sum(1 for B in self.all_closed_sets() if B < A)

    def horizon_layers(self) -> Dict[int, List[FrozenSet[str]]]:
        """Organize join-irreducible closed sets by closure rank."""
        layers = defaultdict(list)
        for A in self.join_irreducible_closed_sets():
            layers[self.closure_rank(A)].append(A)
        return dict(layers)

    def interval_separated(self) -> bool:
        """Check if distinct elements have distinct principal futures."""
        for x in self.elements:
            for y in self.elements:
                if x != y and self.principal_future(x) == self.principal_future(y):
                    return False
        return True


def format_set(s: FrozenSet[str]) -> str:
    """Pretty-print a frozenset."""
    if not s:
        return "∅"
    return "{" + ", ".join(sorted(s)) + "}"


# ============================================================
# Example 1: Chain (Total Order)
# ============================================================

def demo_chain():
    """Chain causal structure: 0 → 1 → 2 → 3."""
    print("=" * 60)
    print("EXAMPLE 1: Chain (Total Order)")
    print("Causal structure: 0 → 1 → 2 → 3")
    print("=" * 60)

    elements = ["0", "1", "2", "3"]
    successors = {
        "0": {"1"},
        "1": {"2"},
        "2": {"3"},
        "3": set()
    }
    C = FiniteCausalClosure(elements, successors)

    print("\nPrincipal futures:")
    for x in elements:
        print(f"  pf({x}) = {format_set(C.principal_future(x))}")

    print(f"\nInterval separated: {C.interval_separated()}")

    closed = C.all_closed_sets()
    print(f"\nAll closed sets ({len(closed)}):")
    for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
        ji = "  [JOIN-IRREDUCIBLE]" if C.is_join_irreducible(s) else ""
        print(f"  {format_set(s):30s} rank={C.closure_rank(s)}{ji}")

    ji_sets = C.join_irreducible_closed_sets()
    print(f"\nJoin-irreducible closed sets ({len(ji_sets)}):")
    for s in ji_sets:
        print(f"  {format_set(s)}")

    edges = C.skeleton_edges()
    print(f"\nSkeleton edges ({len(edges)}):")
    for A, B in edges:
        print(f"  {format_set(A)} → {format_set(B)}")

    layers = C.horizon_layers()
    print(f"\nHorizon layers:")
    for k in sorted(layers.keys()):
        print(f"  Layer {k}: {[format_set(s) for s in layers[k]]}")

    print()
    return C


# ============================================================
# Example 2: Diamond
# ============================================================

def demo_diamond():
    """Diamond causal structure: a → {b, c} → d."""
    print("=" * 60)
    print("EXAMPLE 2: Diamond Causal Structure")
    print("Causal structure: a → b → d, a → c → d")
    print("=" * 60)

    elements = ["a", "b", "c", "d"]
    successors = {
        "a": {"b", "c"},
        "b": {"d"},
        "c": {"d"},
        "d": set()
    }
    C = FiniteCausalClosure(elements, successors)

    print("\nPrincipal futures:")
    for x in elements:
        print(f"  pf({x}) = {format_set(C.principal_future(x))}")

    print(f"\nInterval separated: {C.interval_separated()}")

    closed = C.all_closed_sets()
    print(f"\nAll closed sets ({len(closed)}):")
    for s in sorted(closed, key=lambda x: (len(x), sorted(x))):
        ji = "  [JOIN-IRREDUCIBLE]" if C.is_join_irreducible(s) else ""
        print(f"  {format_set(s):30s} rank={C.closure_rank(s)}{ji}")

    ji_sets = C.join_irreducible_closed_sets()
    print(f"\nJoin-irreducible closed sets ({len(ji_sets)}):")
    for s in ji_sets:
        print(f"  {format_set(s)}")

    edges = C.skeleton_edges()
    print(f"\nSkeleton edges ({len(edges)}):")
    for A, B in edges:
        print(f"  {format_set(A)} → {format_set(B)}")

    layers = C.horizon_layers()
    print(f"\nHorizon layers:")
    for k in sorted(layers.keys()):
        print(f"  Layer {k}: {[format_set(s) for s in layers[k]]}")

    print()
    return C


# ============================================================
# Example 3: Pentagon / Non-distributive
# ============================================================

def demo_pentagon():
    """Pentagon causal structure demonstrating non-distributive lattice."""
    print("=" * 60)
    print("EXAMPLE 3: Pentagon Causal Structure")
    print("a → b → d → e, a → c → e")
    print("=" * 60)

    elements = ["a", "b", "c", "d", "e"]
    successors = {
        "a": {"b", "c"},
        "b": {"d"},
        "c": {"e"},
        "d": {"e"},
        "e": set()
    }
    C = FiniteCausalClosure(elements, successors)

    print("\nPrincipal futures:")
    for x in elements:
        print(f"  pf({x}) = {format_set(C.principal_future(x))}")

    print(f"\nInterval separated: {C.interval_separated()}")

    ji_sets = C.join_irreducible_closed_sets()
    print(f"\nJoin-irreducible closed sets ({len(ji_sets)}):")
    for s in ji_sets:
        print(f"  {format_set(s):30s} rank={C.closure_rank(s)}")

    edges = C.skeleton_edges()
    print(f"\nSkeleton edges ({len(edges)}):")
    for A, B in edges:
        print(f"  {format_set(A)} → {format_set(B)}")

    layers = C.horizon_layers()
    print(f"\nHorizon layers:")
    for k in sorted(layers.keys()):
        print(f"  Layer {k}: {[format_set(s) for s in layers[k]]}")

    # Verify reconstruction
    print("\nReconstruction verification:")
    all_closed = C.all_closed_sets()
    for s in all_closed:
        if s:
            # Check: is s the union of some join-irreducibles?
            contributing = [j for j in ji_sets if j <= s]
            union = frozenset().union(*contributing) if contributing else frozenset()
            match = union == s
            print(f"  {format_set(s):30s} = ∪(JI ⊆ it) = {format_set(union):30s} {'✓' if match else '✗'}")

    print()
    return C


# ============================================================
# Semimodule Structure Demo
# ============================================================

def demo_semimodule(C: FiniteCausalClosure, name: str):
    """Demonstrate the idempotent semimodule structure."""
    print("=" * 60)
    print(f"SEMIMODULE STRUCTURE: {name}")
    print("=" * 60)

    closed = [s for s in C.all_closed_sets() if s]
    ji = C.join_irreducible_closed_sets()

    print(f"\nCarrier (closed sets): {len(closed)} elements")
    print(f"Generators (join-irreducible): {len(ji)} elements")

    # Demonstrate idempotence of join
    print("\nJoin idempotence (A ⊔ A = A):")
    for A in closed[:5]:
        join_AA = C.cl(A | A)
        print(f"  {format_set(A)} ⊔ {format_set(A)} = {format_set(join_AA)}"
              f"  {'✓' if join_AA == A else '✗'}")

    # Demonstrate commutativity
    print("\nJoin commutativity (A ⊔ B = B ⊔ A):")
    pairs_shown = 0
    for A in closed:
        for B in closed:
            if A != B and pairs_shown < 5:
                join_AB = C.cl(A | B)
                join_BA = C.cl(B | A)
                print(f"  {format_set(A)} ⊔ {format_set(B)} = {format_set(join_AB)}"
                      f"  {'✓' if join_AB == join_BA else '✗'}")
                pairs_shown += 1

    # Identify extremal generators
    print("\nExtremal generators (not decomposable):")
    for A in ji:
        is_extremal = True
        for B in ji:
            for D in ji:
                if B != A and D != A:
                    if C.cl(B | D) == A:
                        is_extremal = False
                        break
            if not is_extremal:
                break
        status = "EXTREMAL" if is_extremal else "decomposable"
        print(f"  {format_set(A):30s} [{status}]")

    print()


# ============================================================
# Visualization (text-based)
# ============================================================

def visualize_skeleton(C: FiniteCausalClosure, name: str):
    """Create a text-based visualization of the skeleton."""
    print("=" * 60)
    print(f"SKELETON VISUALIZATION: {name}")
    print("=" * 60)

    ji = C.join_irreducible_closed_sets()
    edges = C.skeleton_edges()
    layers = C.horizon_layers()

    # Display layer by layer
    max_rank = max(layers.keys()) if layers else 0
    for rank in range(max_rank, -1, -1):
        if rank in layers:
            layer_sets = layers[rank]
            layer_strs = [format_set(s) for s in layer_sets]
            print(f"  Layer {rank}: {' | '.join(layer_strs)}")

            # Show edges going down
            if rank > 0:
                for A in layer_sets:
                    for edge_a, edge_b in edges:
                        if edge_b == A:
                            print(f"           ↑ from {format_set(edge_a)}")

    print()


# ============================================================
# Generate SVG diagram
# ============================================================

def generate_skeleton_svg(C: FiniteCausalClosure, name: str) -> str:
    """Generate an SVG diagram of the skeleton."""
    ji = C.join_irreducible_closed_sets()
    edges = C.skeleton_edges()
    layers = C.horizon_layers()

    if not layers:
        return "<svg></svg>"

    max_rank = max(layers.keys())
    max_width = max(len(v) for v in layers.values())

    # SVG dimensions
    node_w = 120
    node_h = 30
    h_gap = 40
    v_gap = 80
    margin = 40

    width = max_width * (node_w + h_gap) + 2 * margin
    height = (max_rank + 1) * (node_h + v_gap) + 2 * margin

    # Compute positions
    positions = {}
    for rank in range(max_rank + 1):
        layer = layers.get(rank, [])
        n = len(layer)
        total_w = n * node_w + (n - 1) * h_gap
        start_x = (width - total_w) / 2
        y = margin + (max_rank - rank) * (node_h + v_gap)
        for i, s in enumerate(layer):
            x = start_x + i * (node_w + h_gap)
            positions[s] = (x + node_w / 2, y + node_h / 2)

    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}">',
        f'<rect width="{width}" height="{height}" fill="white"/>',
        f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" '
        f'font-weight="bold" fill="#333">{name}</text>'
    ]

    # Draw edges
    for A, B in edges:
        if A in positions and B in positions:
            x1, y1 = positions[A]
            x2, y2 = positions[B]
            svg_parts.append(
                f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
                f'stroke="#666" stroke-width="2" marker-end="url(#arrow)"/>'
            )

    # Arrow marker
    svg_parts.append(
        '<defs><marker id="arrow" markerWidth="10" markerHeight="7" '
        'refX="10" refY="3.5" orient="auto"><polygon points="0 0, 10 3.5, 0 7" '
        'fill="#666"/></marker></defs>'
    )

    # Draw nodes
    for s, (x, y) in positions.items():
        label = format_set(s)
        svg_parts.append(
            f'<rect x="{x - node_w/2}" y="{y - node_h/2}" '
            f'width="{node_w}" height="{node_h}" rx="5" '
            f'fill="#e3f2fd" stroke="#1976d2" stroke-width="2"/>'
        )
        svg_parts.append(
            f'<text x="{x}" y="{y + 5}" text-anchor="middle" '
            f'font-size="11" fill="#333">{label}</text>'
        )

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


# ============================================================
# Main
# ============================================================

def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Closure-Causal Horizon Duality: Demonstration           ║")
    print("║  Finite Causality Reconstruction from Closure Algebra    ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

    # Run demos
    C1 = demo_chain()
    C2 = demo_diamond()
    C3 = demo_pentagon()

    # Semimodule demos
    demo_semimodule(C2, "Diamond")
    demo_semimodule(C3, "Pentagon")

    # Skeleton visualizations
    visualize_skeleton(C1, "Chain")
    visualize_skeleton(C2, "Diamond")
    visualize_skeleton(C3, "Pentagon")

    # Generate SVG
    for C, name in [(C1, "Chain"), (C2, "Diamond"), (C3, "Pentagon")]:
        svg = generate_skeleton_svg(C, f"{name} Skeleton")
        filename = f"skeleton_{name.lower()}.svg"
        with open(filename, "w") as f:
            f.write(svg)
        print(f"Saved {filename}")

    print("\n" + "=" * 60)
    print("SUMMARY OF RESULTS")
    print("=" * 60)
    for C, name in [(C1, "Chain"), (C2, "Diamond"), (C3, "Pentagon")]:
        ji = C.join_irreducible_closed_sets()
        edges = C.skeleton_edges()
        closed = C.all_closed_sets()
        print(f"\n{name}:")
        print(f"  Elements:       {len(C.elements)}")
        print(f"  Closed sets:    {len(closed)}")
        print(f"  Join-irred.:    {len(ji)}")
        print(f"  Skeleton edges: {len(edges)}")
        print(f"  Separated:      {C.interval_separated()}")


if __name__ == "__main__":
    main()
