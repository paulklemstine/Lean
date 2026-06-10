#!/usr/bin/env python3
"""
Applications of tropical theorem discovery to real-world problems.

1. Dependency Resolution (package managers)
2. Knowledge Base Inference (semantic web / AI)
3. Type Inference Propagation (compilers)
4. Network Protocol Convergence (distributed systems)
"""

from typing import Dict, List, Set, Tuple
from algorithms import (
    InferenceRule, monotone_closure, build_step_rules,
    tropical_bellman_ford, find_derivation, reconstruct_path
)


# ============================================================
# Application 1: Dependency Resolution
# ============================================================

def dependency_resolution_demo():
    """
    Model package dependency resolution as theorem discovery.

    Packages are "theorems"; dependencies are "inference rules";
    installed packages are "axioms"; the closure is the full
    dependency tree.
    """
    print("=" * 60)
    print("APPLICATION 1: Package Dependency Resolution")
    print("=" * 60)

    # Packages: web-app depends on framework, database, logging
    # framework depends on http-lib, template-engine
    # database depends on sql-driver, connection-pool
    rules = [
        InferenceRule(frozenset(), "stdlib", "system-provides"),
        InferenceRule(frozenset({"stdlib"}), "http-lib", "install"),
        InferenceRule(frozenset({"stdlib"}), "sql-driver", "install"),
        InferenceRule(frozenset({"stdlib"}), "logging", "install"),
        InferenceRule(frozenset({"http-lib"}), "template-engine", "install"),
        InferenceRule(frozenset({"http-lib", "template-engine"}), "framework", "install"),
        InferenceRule(frozenset({"sql-driver"}), "connection-pool", "install"),
        InferenceRule(frozenset({"sql-driver", "connection-pool"}), "database", "install"),
        InferenceRule(frozenset({"framework", "database", "logging"}), "web-app", "install"),
    ]

    step_fn = build_step_rules(rules)
    result = monotone_closure(step_fn, set())

    print(f"\nInstallation order (closure iteration):")
    for i, s in enumerate(result.chain):
        new = s - (result.chain[i-1] if i > 0 else set())
        if new:
            print(f"  Step {i}: install {sorted(new)}")

    print(f"\nAll packages resolved in {result.stabilization_step} steps")
    print(f"Total packages: {len(result.fixed_point)}")

    # Weighted version: installation time
    vertices = list(result.fixed_point)
    edges = [
        ("stdlib", "http-lib", 3),
        ("stdlib", "sql-driver", 2),
        ("stdlib", "logging", 1),
        ("http-lib", "template-engine", 4),
        ("template-engine", "framework", 2),
        ("http-lib", "framework", 1),
        ("sql-driver", "connection-pool", 2),
        ("connection-pool", "database", 3),
        ("sql-driver", "database", 1),
        ("framework", "web-app", 1),
        ("database", "web-app", 1),
        ("logging", "web-app", 1),
    ]

    bf = tropical_bellman_ford(vertices, edges, "stdlib")
    print(f"\nCritical path (min install time from stdlib):")
    for pkg in sorted(vertices):
        d = bf.distances[pkg]
        d_str = str(d) if d < float('inf') else "∞"
        print(f"  {pkg}: {d_str} time units")


# ============================================================
# Application 2: Knowledge Base Inference
# ============================================================

def knowledge_base_demo():
    """
    Model semantic web / AI knowledge inference as theorem discovery.

    Facts are "axioms"; ontological rules are "inference rules";
    the closure is all inferrable knowledge.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Knowledge Base Inference (AI)")
    print("=" * 60)

    # Simple ontological knowledge base
    rules = [
        InferenceRule(frozenset({"Socrates-is-human"}), "Socrates-is-mortal",
                     "humans-are-mortal"),
        InferenceRule(frozenset({"Socrates-is-mortal"}), "Socrates-can-die",
                     "mortals-can-die"),
        InferenceRule(frozenset({"Plato-is-human"}), "Plato-is-mortal",
                     "humans-are-mortal"),
        InferenceRule(frozenset({"Socrates-is-human", "Plato-is-human"}),
                     "some-humans-exist", "existential"),
        InferenceRule(frozenset({"some-humans-exist"}),
                     "some-mortals-exist", "subset-inference"),
        InferenceRule(frozenset({"Socrates-is-human"}), "Socrates-is-animal",
                     "humans-are-animals"),
        InferenceRule(frozenset({"Plato-is-human"}), "Plato-is-animal",
                     "humans-are-animals"),
    ]

    axioms = {"Socrates-is-human", "Plato-is-human"}

    step_fn = build_step_rules(rules)
    result = monotone_closure(step_fn, axioms)

    print(f"\nKnown facts (axioms): {sorted(axioms)}")
    print(f"\nInferred knowledge (closure):")
    inferred = result.fixed_point - axioms
    for fact in sorted(inferred):
        tree = find_derivation(rules, axioms, fact)
        depth = tree.depth if tree else "?"
        print(f"  {fact} (depth {depth})")

    print(f"\nTotal facts: {len(result.fixed_point)} "
          f"({len(axioms)} axioms + {len(inferred)} inferred)")
    print(f"Inference completed in {result.stabilization_step} steps")

    # Show a derivation
    tree = find_derivation(rules, axioms, "some-mortals-exist")
    if tree:
        print(f"\nDerivation of 'some-mortals-exist':")
        print(tree.pretty())


# ============================================================
# Application 3: Type Inference Propagation
# ============================================================

def type_inference_demo():
    """
    Model type inference as constraint propagation / theorem discovery.

    Type constraints are "rules"; known types are "axioms";
    the closure gives all inferred types.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Type Inference Propagation")
    print("=" * 60)

    # Simple type inference scenario:
    # x : Int, y = x + 1, z = y * 2, w = if z > 0 then "yes" else "no"
    rules = [
        InferenceRule(frozenset({"x:Int"}), "y:Int", "x+1:Int→Int"),
        InferenceRule(frozenset({"y:Int"}), "z:Int", "y*2:Int→Int"),
        InferenceRule(frozenset({"z:Int"}), "z>0:Bool", "compare:Int→Bool"),
        InferenceRule(frozenset({"z>0:Bool"}), "w:String", "if-then-else:Bool→String"),
        InferenceRule(frozenset({"x:Int", "y:Int"}), "x+y:Int", "add:Int×Int→Int"),
        InferenceRule(frozenset({"z:Int", "w:String"}), "result:(Int,String)",
                     "pair:Int×String→(Int,String)"),
    ]

    axioms = {"x:Int"}

    step_fn = build_step_rules(rules)
    result = monotone_closure(step_fn, axioms)

    print(f"\nKnown types: {sorted(axioms)}")
    print(f"\nType propagation:")
    for i, s in enumerate(result.chain):
        new = s - (result.chain[i-1] if i > 0 else set())
        if new:
            print(f"  Round {i}: {sorted(new)}")

    print(f"\nAll types inferred in {result.stabilization_step} rounds")
    print(f"Total type facts: {len(result.fixed_point)}")


# ============================================================
# Application 4: Network Protocol Convergence
# ============================================================

def network_convergence_demo():
    """
    Model network routing convergence as Bellman-Ford in the
    tropical semiring — this IS the Bellman-Ford algorithm.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Network Routing Convergence")
    print("=" * 60)

    # Network topology
    vertices = list(range(6))  # Routers 0-5
    edges = [
        (0, 1, 4), (0, 2, 2),
        (1, 2, 1), (1, 3, 5),
        (2, 3, 8), (2, 4, 10),
        (3, 4, 2), (3, 5, 6),
        (4, 5, 3),
    ]
    # Add reverse edges (undirected)
    edges_bidir = edges + [(v, u, w) for u, v, w in edges]

    print(f"\nNetwork: {len(vertices)} routers, {len(edges)} links")
    print(f"Links: ")
    for u, v, w in edges:
        print(f"  Router {u} ↔ Router {v} (latency {w}ms)")

    bf = tropical_bellman_ford(vertices, edges_bidir, 0)

    print(f"\nRouting table from Router 0 (converged in {bf.stabilization_step} rounds):")
    for v in vertices:
        d = bf.distances[v]
        d_str = f"{d}ms" if d < float('inf') else "unreachable"
        path = reconstruct_path(bf.parent, 0, v)
        path_str = " → ".join(map(str, path)) if path else "N/A"
        print(f"  To Router {v}: {d_str} via {path_str}")

    print(f"\nConvergence guarantee: N ≤ |V| = {len(vertices)}")
    print(f"Actual convergence: N = {bf.stabilization_step}")
    print(f"This is EXACTLY the tropical fixed-point theorem in action!")


if __name__ == "__main__":
    dependency_resolution_demo()
    knowledge_base_demo()
    type_inference_demo()
    network_convergence_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of emergent theorem discovery in idempotent algebras.

This script implements the core algorithms from the formal development:
- Monotone extensive closure on finite sets
- Rule-based consequence operators
- Derivability vs. closure equivalence
- Min-plus (tropical) Bellman-Ford shortest-path computation
"""

from typing import Dict, List, Set, Tuple, Optional
import itertools


# ============================================================
# Part 1: Monotone Closure on Finite Sets
# ============================================================

def iterate_step(step, initial: Set, max_iter: int = 100) -> List[Set]:
    """Iterate a monotone extensive operator until fixed point."""
    chain = [initial]
    current = initial
    for i in range(max_iter):
        next_set = step(current)
        chain.append(next_set)
        if next_set == current:
            break
        current = next_set
    return chain


def demonstrate_closure():
    """Demonstrate finite closure stabilization."""
    print("=" * 60)
    print("PART 1: Finite Monotone Closure Stabilization")
    print("=" * 60)

    # Universe: {0, 1, 2, 3, 4, 5}
    universe = set(range(6))

    # Rules: pairs -> conclusions
    rules = [
        (frozenset(), 0),         # 0 is always derivable
        (frozenset({0}), 1),      # 0 => 1
        (frozenset({0}), 2),      # 0 => 2
        (frozenset({1, 2}), 3),   # 1, 2 => 3
        (frozenset({3}), 4),      # 3 => 4
        (frozenset({4, 2}), 5),   # 4, 2 => 5
    ]

    def step(s: Set) -> Set:
        result = set(s)
        for premises, conclusion in rules:
            if premises.issubset(s):
                result.add(conclusion)
        return result

    axioms = {0}
    chain = iterate_step(step, axioms)

    print(f"\nUniverse: {universe}")
    print(f"Axioms: {axioms}")
    print(f"\nRules:")
    for premises, conclusion in rules:
        if premises:
            print(f"  {set(premises)} => {conclusion}")
        else:
            print(f"  (always) => {conclusion}")

    print(f"\nIteration chain:")
    for i, s in enumerate(chain):
        marker = " (FIXED POINT)" if i > 0 and s == chain[i-1] else ""
        print(f"  T({i}) = {sorted(s)}{marker}")

    N = len(chain) - 1
    print(f"\nStabilization step N = {N - 1}")
    print(f"Universe size |σ| = {len(universe)}")
    print(f"N ≤ |σ|: {N - 1 <= len(universe)} ✓")


# ============================================================
# Part 2: Rule-Based Derivability
# ============================================================

class Rule:
    def __init__(self, premises: Set, conclusion):
        self.premises = frozenset(premises)
        self.conclusion = conclusion

    def __repr__(self):
        return f"Rule({set(self.premises)} ⊢ {self.conclusion})"


def step_rules(rules: List[Rule], s: Set) -> Set:
    """One-step consequence operator."""
    result = set(s)
    for r in rules:
        if r.premises.issubset(s):
            result.add(r.conclusion)
    return result


def compute_closure(rules: List[Rule], axioms: Set) -> Tuple[Set, int]:
    """Compute the closure and return (closure, stabilization_step)."""
    current = set(axioms)
    step_count = 0
    while True:
        next_set = step_rules(rules, current)
        step_count += 1
        if next_set == current:
            return current, step_count - 1
        current = next_set


def derivable_tree(rules: List[Rule], axioms: Set, target) -> Optional[dict]:
    """Build a derivation tree for target, if possible."""
    if target in axioms:
        return {"formula": target, "justification": "axiom"}

    closure, _ = compute_closure(rules, axioms)
    if target not in closure:
        return None

    for r in rules:
        if r.conclusion == target:
            subtrees = []
            all_ok = True
            for p in r.premises:
                sub = derivable_tree(rules, axioms, p)
                if sub is None:
                    all_ok = False
                    break
                subtrees.append(sub)
            if all_ok:
                return {
                    "formula": target,
                    "justification": f"rule {r}",
                    "subtrees": subtrees
                }
    return None


def print_tree(tree, indent=0):
    """Pretty-print a derivation tree."""
    prefix = "  " * indent
    if tree["justification"] == "axiom":
        print(f"{prefix}├─ {tree['formula']} [AXIOM]")
    else:
        print(f"{prefix}├─ {tree['formula']} by {tree['justification']}")
        for sub in tree.get("subtrees", []):
            print_tree(sub, indent + 1)


def demonstrate_derivability():
    """Demonstrate derivability ↔ closure membership."""
    print("\n" + "=" * 60)
    print("PART 2: Derivability ↔ Closure Completeness")
    print("=" * 60)

    rules = [
        Rule({0}, 1),      # 0 ⊢ 1
        Rule({1}, 2),      # 1 ⊢ 2
        Rule({0}, 2),      # 0 ⊢ 2 (redundant but different depth)
        Rule({2}, 3),      # 2 ⊢ 3
    ]
    axioms = {0}

    closure, N = compute_closure(rules, axioms)

    print(f"\nRules: {rules}")
    print(f"Axioms: {axioms}")
    print(f"Closure: {sorted(closure)}")
    print(f"Stabilization step: {N}")

    print(f"\nDerivability check (derivable ↔ ∈ closure):")
    for φ in range(5):
        in_closure = φ in closure
        tree = derivable_tree(rules, axioms, φ)
        derivable = tree is not None
        status = "✓" if derivable == in_closure else "✗"
        print(f"  φ={φ}: derivable={derivable}, ∈closure={in_closure} {status}")
        if tree:
            print_tree(tree, indent=2)


# ============================================================
# Part 3: Min-Plus Bellman-Ford Shortest Paths
# ============================================================

INF = float('inf')


def bellman_step(edges: List[Tuple[int, int, int]], d: Dict[int, float]) -> Dict[int, float]:
    """One step of Bellman-Ford relaxation in the min-plus semiring."""
    new_d = dict(d)
    for u, v, w in edges:
        if d[u] + w < new_d[v]:
            new_d[v] = d[u] + w
    return new_d


def bellman_ford(edges: List[Tuple[int, int, int]], src: int,
                 vertices: List[int]) -> Tuple[Dict[int, float], int, List[Dict[int, float]]]:
    """Run Bellman-Ford and return (distances, stabilization_step, history)."""
    d = {v: 0 if v == src else INF for v in vertices}
    history = [dict(d)]

    for i in range(len(vertices)):
        new_d = bellman_step(edges, d)
        history.append(dict(new_d))
        if new_d == d:
            return d, i, history
        d = new_d

    return d, len(vertices), history


def demonstrate_minplus():
    """Demonstrate min-plus shortest-path computation."""
    print("\n" + "=" * 60)
    print("PART 3: Min-Plus Bellman-Ford Shortest Paths")
    print("=" * 60)

    # Demo graph: same as the formal development
    vertices = [0, 1, 2, 3]
    edges = [
        (0, 1, 2),   # 0 → 1, weight 2
        (1, 2, 1),   # 1 → 2, weight 1
        (0, 2, 5),   # 0 → 2, weight 5
        (2, 3, 3),   # 2 → 3, weight 3
    ]

    print(f"\nGraph: {len(vertices)} vertices, {len(edges)} edges")
    print(f"Edges:")
    for u, v, w in edges:
        print(f"  {u} → {v} (weight {w})")

    d, N, history = bellman_ford(edges, 0, vertices)

    print(f"\nBellman-Ford iteration history:")
    for i, h in enumerate(history):
        dists = {v: (h[v] if h[v] < INF else "∞") for v in vertices}
        marker = " (STABLE)" if i > 0 and h == history[i-1] else ""
        print(f"  Step {i}: {dists}{marker}")

    print(f"\nOptimal distances from source 0:")
    for v in vertices:
        dist = d[v] if d[v] < INF else "∞"
        print(f"  d({v}) = {dist}")

    print(f"\nKey result: d(2) = {d[2]} (via 0→1→2, not 5 via 0→2 directly)")
    print(f"Stabilization at step {N}")
    print(f"|V| = {len(vertices)}, N ≤ |V|: {N <= len(vertices)} ✓")


# ============================================================
# Part 4: Comparison — Closure vs Shortest Paths
# ============================================================

def demonstrate_correspondence():
    """Show the correspondence between closure iteration and shortest paths."""
    print("\n" + "=" * 60)
    print("PART 4: Closure ↔ Shortest-Path Correspondence")
    print("=" * 60)

    rules = [
        Rule({0}, 1),
        Rule({1}, 2),
        Rule({0}, 2),
        Rule({2}, 3),
    ]
    axioms = {0}

    # Closure iteration
    chain = iterate_step(lambda s: step_rules(rules, s), axioms)

    # Bellman-Ford
    edges = [(0, 1, 2), (1, 2, 1), (0, 2, 5), (2, 3, 3)]
    d, _, _ = bellman_ford(edges, 0, [0, 1, 2, 3])

    print(f"\nClosure iteration (when does each formula first appear?):")
    first_appearance = {}
    for φ in range(4):
        for i, s in enumerate(chain):
            if φ in s:
                first_appearance[φ] = i
                break

    for φ in range(4):
        fa = first_appearance.get(φ, "never")
        depth = d.get(φ, INF)
        depth_str = str(int(depth)) if depth < INF else "∞"
        print(f"  φ={φ}: first appears at step {fa}, "
              f"shortest-path depth = {depth_str}")

    print(f"\nCorrespondence:")
    print(f"  - Closure iteration gives WHICH formulas are derivable")
    print(f"  - Bellman-Ford gives HOW DEEP the derivations are")
    print(f"  - Both stabilize on finite universes (Knaster-Tarski)")
    print(f"  - Discovery depth ≤ |universe| (spectral bound)")


if __name__ == "__main__":
    demonstrate_closure()
    demonstrate_derivability()
    demonstrate_minplus()
    demonstrate_correspondence()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for emergent theorem discovery in idempotent algebras.
Generates PNG figures showing convergence, depth stratification, and graph structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_closure_convergence():
    """Plot the closure iteration chain showing set growth."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Demo 1: 6-element universe
    chain1 = [{0}, {0, 1, 2}, {0, 1, 2, 3}, {0, 1, 2, 3, 4},
              {0, 1, 2, 3, 4, 5}, {0, 1, 2, 3, 4, 5}]
    cards1 = [len(s) for s in chain1]

    ax1.step(range(len(cards1)), cards1, where='post', linewidth=2.5,
             color='#2196F3', marker='o', markersize=8)
    ax1.axhline(y=6, color='#F44336', linestyle='--', alpha=0.7,
                label='Universe size |σ| = 6')
    ax1.fill_between(range(len(cards1)), cards1, alpha=0.15, color='#2196F3',
                     step='post')
    ax1.set_xlabel('Iteration step n', fontsize=12)
    ax1.set_ylabel('|T(n)| (theory size)', fontsize=12)
    ax1.set_title('Closure Convergence (6-element universe)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 7.5)
    ax1.grid(True, alpha=0.3)

    # Annotate fixed point
    ax1.annotate('Fixed point!', xy=(4, 6), xytext=(3.5, 7),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=11, color='green', fontweight='bold')

    # Demo 2: 4-element demo
    chain2 = [{0}, {0, 1, 2}, {0, 1, 2, 3}, {0, 1, 2, 3}]
    cards2 = [len(s) for s in chain2]

    ax2.step(range(len(cards2)), cards2, where='post', linewidth=2.5,
             color='#4CAF50', marker='s', markersize=8)
    ax2.axhline(y=4, color='#F44336', linestyle='--', alpha=0.7,
                label='Universe size |σ| = 4')
    ax2.fill_between(range(len(cards2)), cards2, alpha=0.15, color='#4CAF50',
                     step='post')
    ax2.set_xlabel('Iteration step n', fontsize=12)
    ax2.set_ylabel('|T(n)| (theory size)', fontsize=12)
    ax2.set_title('Demo: 4-proposition theorem discovery', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 5.5)
    ax2.grid(True, alpha=0.3)

    ax2.annotate('N = 2 ≤ |σ| = 4', xy=(2, 4), xytext=(1.5, 5),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=11, color='green', fontweight='bold')

    plt.suptitle('Theorem Discovery Stabilization\n'
                 '(Monotone extensive operators on finite sets)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_bellman_ford_convergence():
    """Plot Bellman-Ford iteration showing distance relaxation."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # History from demo
    history = [
        {0: 0, 1: float('inf'), 2: float('inf'), 3: float('inf')},
        {0: 0, 1: 2, 2: 5, 3: float('inf')},
        {0: 0, 1: 2, 2: 3, 3: 8},
        {0: 0, 1: 2, 2: 3, 3: 6},
        {0: 0, 1: 2, 2: 3, 3: 6},
    ]

    colors = ['#2196F3', '#FF9800', '#4CAF50', '#9C27B0']
    labels = ['d(0)', 'd(1)', 'd(2)', 'd(3)']

    steps = range(len(history))
    for v in range(4):
        vals = [min(h[v], 12) for h in history]  # cap inf for plotting
        style = '-' if v > 0 else '--'
        ax1.plot(steps, vals, style, linewidth=2.5, color=colors[v],
                marker='o', markersize=7, label=labels[v])

    ax1.set_xlabel('Bellman-Ford iteration', fontsize=12)
    ax1.set_ylabel('Distance (min-plus)', fontsize=12)
    ax1.set_title('Tropical Relaxation: Distances converge', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.5, 13)
    ax1.grid(True, alpha=0.3)
    ax1.axvline(x=3, color='red', linestyle=':', alpha=0.5,
                label='Stabilization')

    # Graph visualization
    positions = {0: (0, 1), 1: (1, 2), 2: (2, 1), 3: (3, 0)}
    edges = [(0, 1, 2), (1, 2, 1), (0, 2, 5), (2, 3, 3)]

    for v, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.2, color=colors[v], alpha=0.8)
        ax2.add_patch(circle)
        ax2.text(x, y, str(v), ha='center', va='center',
                fontsize=14, fontweight='bold', color='white')

    for u, v, w in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        dx, dy = x2 - x1, y2 - y1
        dist = (dx**2 + dy**2)**0.5
        # Shorten arrow
        fx, fy = dx/dist * 0.25, dy/dist * 0.25
        is_shortest = (u, v) in [(0, 1), (1, 2), (2, 3)]
        lw = 3 if is_shortest else 1.5
        color = '#2196F3' if is_shortest else '#999'
        ax2.annotate('', xy=(x2 - fx, y2 - fy), xytext=(x1 + fx, y1 + fy),
                    arrowprops=dict(arrowstyle='->', lw=lw, color=color))
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        offset = 0.15 if u == 0 and v == 2 else 0.2
        ax2.text(mx, my + offset, f'w={w}', ha='center', fontsize=11,
                fontweight='bold' if is_shortest else 'normal',
                color=color)

    ax2.set_xlim(-0.5, 3.7)
    ax2.set_ylim(-0.5, 2.7)
    ax2.set_aspect('equal')
    ax2.set_title('Demo graph (shortest path in blue)', fontsize=13)
    ax2.axis('off')

    sp = mpatches.Patch(color='#2196F3', label='Shortest path edges')
    other = mpatches.Patch(color='#999', label='Non-optimal edges')
    ax2.legend(handles=[sp, other], loc='lower left', fontsize=9)

    plt.suptitle('Min-Plus (Tropical) Theorem Depth Discovery',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_kleene_star():
    """Plot Kleene star matrix power convergence."""
    INF = float('inf')

    M = np.full((4, 4), INF)
    M[0, 1] = 2
    M[1, 2] = 1
    M[0, 2] = 5
    M[2, 3] = 3

    def minplus_mul(A, B):
        n = A.shape[0]
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C

    I = np.full((4, 4), INF)
    np.fill_diagonal(I, 0)

    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    K = I.copy()
    P = I.copy()

    for idx in range(4):
        P = minplus_mul(P, M)
        K = np.minimum(K, P)

        ax = axes[idx]
        display = np.where(K < INF, K, np.nan)
        im = ax.imshow(display, cmap='YlOrRd_r', vmin=0, vmax=10)

        for i in range(4):
            for j in range(4):
                val = K[i, j]
                text = str(int(val)) if val < INF else '∞'
                color = 'black' if val < 6 else 'white'
                ax.text(j, i, text, ha='center', va='center',
                       fontsize=14, fontweight='bold', color=color)

        ax.set_title(f'K*({idx+1})', fontsize=13, fontweight='bold')
        ax.set_xticks(range(4))
        ax.set_yticks(range(4))
        ax.set_xticklabels(range(4))
        ax.set_yticklabels(range(4))

        if idx == 2:
            ax.set_title(f'K*(3) = K*(4)\n(stabilized!)',
                        fontsize=12, fontweight='bold', color='green')

    plt.suptitle('Kleene Star Convergence in Min-Plus Semiring\n'
                 'Shortest-path distances stabilize at N = |V| - 1',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def plot_depth_stratification():
    """Plot depth stratification of discovered theorems."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Larger example: 8 theorems with various depths
    theorems = ['A₀', 'A₁', 'T₂', 'T₃', 'T₄', 'T₅', 'T₆', 'T₇']
    depths = [0, 0, 1, 1, 2, 2, 3, 4]
    colors_map = {0: '#4CAF50', 1: '#2196F3', 2: '#FF9800',
                  3: '#F44336', 4: '#9C27B0'}

    bars = ax.barh(range(len(theorems)), depths,
                   color=[colors_map[d] for d in depths],
                   edgecolor='white', linewidth=1.5, height=0.6)

    ax.set_yticks(range(len(theorems)))
    ax.set_yticklabels(theorems, fontsize=12)
    ax.set_xlabel('Discovery depth (iteration step)', fontsize=12)
    ax.set_title('Depth Stratification of Discovered Theorems\n'
                 'Axioms (green) → Shallow (blue) → Deep (red/purple)',
                 fontsize=13, fontweight='bold')
    ax.invert_yaxis()
    ax.grid(True, axis='x', alpha=0.3)

    # Add depth labels
    for i, (bar, d) in enumerate(zip(bars, depths)):
        label = 'axiom' if d == 0 else f'depth {d}'
        ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
               label, va='center', fontsize=10, fontweight='bold',
               color=colors_map[d])

    # Legend
    legend_patches = [
        mpatches.Patch(color=colors_map[i], label=f'Depth {i}')
        for i in sorted(colors_map.keys())
    ]
    ax.legend(handles=legend_patches, loc='lower right', fontsize=10)

    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_closure_convergence()
    fig1.savefig('closure_convergence.png', dpi=150, bbox_inches='tight')
    print("  Saved closure_convergence.png")

    fig2 = plot_bellman_ford_convergence()
    fig2.savefig('bellman_ford.png', dpi=150, bbox_inches='tight')
    print("  Saved bellman_ford.png")

    fig3 = plot_kleene_star()
    fig3.savefig('kleene_star.png', dpi=150, bbox_inches='tight')
    print("  Saved kleene_star.png")

    fig4 = plot_depth_stratification()
    fig4.savefig('depth_stratification.png', dpi=150, bbox_inches='tight')
    print("  Saved depth_stratification.png")

    print("All visualizations generated.")
