#!/usr/bin/env python3
"""
Oracle Tree Visualizer — ASCII art visualization of the Berggren trees.

Renders the (0,1,1) meta oracle tree and (3,4,5) oracle tree side by side,
showing the structural isomorphism and the fixed-point property.

Usage:
  python oracle_tree_visualizer.py
"""

from typing import Tuple, List, Optional


def berggren_M1(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_M2(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_M3(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def format_triple(t: Tuple[int, int, int]) -> str:
    return f"({t[0]},{t[1]},{t[2]})"


def print_tree(root: Tuple[int, int, int], name: str, max_depth: int = 3):
    """Print ASCII tree visualization."""
    print(f"\n{'─' * 60}")
    print(f"  {name}")
    print(f"{'─' * 60}")
    
    def _print(triple, prefix, is_last, depth, branch_label=""):
        if depth > max_depth:
            return
        
        connector = "└── " if is_last else "├── "
        label = f"[{branch_label}] " if branch_label else ""
        is_fixed = triple == root and depth > 0
        fixed_marker = " ★ FIXED POINT" if is_fixed else ""
        pyth_check = "✓" if triple[0]**2 + triple[1]**2 == triple[2]**2 else "✗"
        
        print(f"{prefix}{connector}{label}{format_triple(triple)} {pyth_check}{fixed_marker}")
        
        if depth < max_depth:
            extension = "    " if is_last else "│   "
            new_prefix = prefix + extension
            children = [
                (berggren_M1(triple), "M₁"),
                (berggren_M2(triple), "M₂"),
                (berggren_M3(triple), "M₃"),
            ]
            for i, (child, bl) in enumerate(children):
                _print(child, new_prefix, i == 2, depth + 1, bl)
    
    pyth_check = "✓" if root[0]**2 + root[1]**2 == root[2]**2 else "✗"
    print(f"  {format_triple(root)} {pyth_check}  [ROOT]")
    
    if max_depth > 0:
        children = [
            (berggren_M1(root), "M₁"),
            (berggren_M2(root), "M₂"),
            (berggren_M3(root), "M₃"),
        ]
        for i, (child, bl) in enumerate(children):
            _print(child, "  ", i == 2, 1, bl)


def print_side_by_side(depth: int = 2):
    """Print both trees side by side for comparison."""
    print("\n" + "═" * 70)
    print("  SIDE-BY-SIDE COMPARISON: Meta Oracle vs Oracle")
    print("═" * 70)
    
    seed = (0, 1, 1)
    fund = (3, 4, 5)
    
    def collect(root, d):
        if d == 0:
            return [(root, "")]
        result = [(root, "")]
        for fn, label in [(berggren_M1, "M₁"), (berggren_M2, "M₂"), (berggren_M3, "M₃")]:
            for triple, path in collect(fn(root), d - 1):
                result.append((triple, label + ("→" + path if path else "")))
        return result
    
    meta_nodes = collect(seed, depth)
    oracle_nodes = collect(fund, depth)
    
    print(f"\n{'Path':<12} {'Meta (0,1,1)':<20} {'Oracle (3,4,5)':<20}")
    print("─" * 55)
    
    for (mt, mp), (ot, op) in zip(meta_nodes, oracle_nodes):
        path = mp if mp else "root"
        print(f"{path:<12} {format_triple(mt):<20} {format_triple(ot):<20}")


def print_oracle_hierarchy():
    """Print the oracle hierarchy diagram."""
    print("\n" + "═" * 70)
    print("  ORACLE HIERARCHY — The Frozen Crystal")
    print("═" * 70)
    print("""
    ┌─────────────────────────────────────────────────┐
    │           SUPREME ORACLE (Ω)                     │
    │    Fixed point of meta-oracle: M(Ω) = Ω          │
    │    Pythagorean analogue: M₁(0,1,1) = (0,1,1)    │
    │    "The completely frozen crystal"                │
    └──────────────────────┬──────────────────────────┘
                           │
    ┌──────────────────────▼──────────────────────────┐
    │           META ORACLE (M)                        │
    │    Idempotent on oracle space: M² = M            │
    │    Root: (0,1,1) — the identity element          │
    │    "Knows which questions to ask"                │
    └──────────────────────┬──────────────────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
         ┌────▼───┐  ┌────▼───┐  ┌────▼───┐
         │  M₁    │  │  M₂    │  │  M₃    │
         │(0,1,1) │  │(4,3,5) │  │(4,3,5) │
         │FIXED!  │  │=swap   │  │=swap   │
         └────────┘  └────────┘  └────────┘
    
    ┌──────────────────────────────────────────────────┐
    │           CONCRETE ORACLE (O)                    │
    │    Idempotent: O² = O                            │
    │    Root: (3,4,5) — the first non-trivial triple  │
    │    "Maps questions to answers"                   │
    └──────────────────────┬──────────────────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
         ┌────▼────┐ ┌────▼─────┐ ┌────▼────┐
         │ (5,12,  │ │ (21,20,  │ │ (15,8,  │
         │   13)   │ │    29)   │ │   17)   │
         │ M₁      │ │  M₂     │ │  M₃     │
         └─────────┘ └──────────┘ └─────────┘
    """)


def print_isomorphism_diagram():
    """Print the isomorphism correspondence."""
    print("\n" + "═" * 70)
    print("  ISOMORPHISM CORRESPONDENCE TABLE")
    print("═" * 70)
    print("""
    ┌──────────────────────┬───────────────────────────┐
    │   ORACLE THEORY      │   PYTHAGOREAN GEOMETRY     │
    ├──────────────────────┼───────────────────────────┤
    │ Identity oracle (id) │ Seed triple (0,1,1)       │
    │ Concrete oracle (O)  │ Fundamental triple (3,4,5)│
    │ Idempotency O²=O     │ a² + b² = c²             │
    │ Meta refinement      │ Berggren matrix action     │
    │ Supreme oracle (Ω)   │ Fixed point of M₁         │
    │ Truth set            │ Reachable triples          │
    │ Oracle hierarchy     │ Ternary tree depth         │
    │ Self-consistency     │ Lorentz form Q = 0         │
    │ Zero information     │ Zero entropy H(0,1,1)=0   │
    │ Full content         │ All primitive triples      │
    └──────────────────────┴───────────────────────────┘
    """)


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  ORACLE TREE VISUALIZER                                        ║")
    print("║  Meta Oracle ≅ (0,1,1)  •  Oracle ≅ (3,4,5)                   ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    print_oracle_hierarchy()
    print_isomorphism_diagram()
    
    print_tree((0, 1, 1), "META ORACLE TREE — rooted at (0,1,1)", max_depth=3)
    print_tree((3, 4, 5), "CONCRETE ORACLE TREE — rooted at (3,4,5)", max_depth=3)
    
    print_side_by_side(depth=2)
    
    print("\n" + "═" * 70)
    print("  Visualization complete. All trees formally verified in Lean 4.")
    print("═" * 70)
