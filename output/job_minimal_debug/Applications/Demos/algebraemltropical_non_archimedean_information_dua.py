"""
Non-Archimedean Information Duality: Demonstrations

Concrete numerical examples of closure capacities, tropical information,
pullback contraction, and ultrametric information distance.
"""

import itertools
from typing import Callable, Optional
import math

# ==============================================================================
# Core Types
# ==============================================================================

# We represent sets as frozensets and WithTop N as Optional[int]
# None = ⊤ (top/infinity), int = finite value

def le_top(a: Optional[int], b: Optional[int]) -> bool:
    """a ≤ b in WithTop N."""
    if b is None:
        return True
    if a is None:
        return False
    return a <= b

def max_top(a: Optional[int], b: Optional[int]) -> Optional[int]:
    """max(a, b) in WithTop N."""
    if a is None or b is None:
        return None
    return max(a, b)

# ==============================================================================
# Closure Operators
# ==============================================================================

def identity_closure(universe: frozenset) -> Callable:
    """Identity closure: cl(S) = S."""
    def cl(s: frozenset) -> frozenset:
        return s
    return cl

def powerset_closure(universe: frozenset) -> Callable:
    """Total closure: cl(∅) = ∅, cl(S) = universe for S ≠ ∅."""
    def cl(s: frozenset) -> frozenset:
        return frozenset() if len(s) == 0 else universe
    return cl

def downward_closure(universe: frozenset) -> Callable:
    """Downward closure on ordered elements: cl(S) = {x ∈ universe : x ≤ max(S)}."""
    def cl(s: frozenset) -> frozenset:
        if not s:
            return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)
    return cl

def matroid_closure_k4():
    """Cycle matroid of K4: ground set = edges, closure = span in cycle matroid.
    Edges: {(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)}
    A set is closed if removing any element not in S doesn't create a new circuit in S.
    Simplified: rank function r(S) = |V(S)| - components(S).
    Closure: cl(S) = {e : r(S ∪ {e}) = r(S)}."""
    edges = [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
    universe = frozenset(range(6))  # index edges 0..5
    
    def vertices_of(s):
        verts = set()
        for i in s:
            e = edges[i]
            verts.add(e[0])
            verts.add(e[1])
        return verts
    
    def components(s):
        if not s:
            return 0
        verts = vertices_of(s)
        parent = {v: v for v in verts}
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py
        for i in s:
            e = edges[i]
            union(e[0], e[1])
        return len(set(find(v) for v in verts))
    
    def rank(s):
        if not s:
            return 0
        return len(vertices_of(s)) - components(s)
    
    def cl(s: frozenset) -> frozenset:
        r_s = rank(s)
        result = set(s)
        for e in universe:
            if e not in s:
                if rank(s | {e}) == r_s:
                    result.add(e)
        return frozenset(result)
    
    return cl, universe, rank

# ==============================================================================
# Closure Capacity
# ==============================================================================

class ClosureCapacity:
    """A closure capacity: v : P(α) → WithTop N with closure invariance,
    monotonicity, normalization, and ultrametric join."""
    
    def __init__(self, universe: frozenset, cl: Callable, v: Callable):
        self.universe = universe
        self.cl = cl
        self.v = v  # v : frozenset -> Optional[int]
    
    def verify(self, verbose=False) -> bool:
        """Verify all axioms on all subsets."""
        subsets = list(powerset(self.universe))
        ok = True
        
        # Normalized
        if self.v(frozenset()) != 0:
            if verbose: print(f"FAIL: normalized_bot: v(∅) = {self.v(frozenset())} ≠ 0")
            ok = False
        
        for s in subsets:
            # Closure invariance
            vs = self.v(s)
            vcls = self.v(self.cl(s))
            if vs != vcls:
                if verbose: print(f"FAIL: closure_invariant: v({set(s)}) = {vs} ≠ {vcls} = v(cl({set(s)}))")
                ok = False
            
            # Monotonicity
            for t in subsets:
                if s <= t:  # s ⊆ t
                    if not le_top(self.v(s), self.v(t)):
                        if verbose: print(f"FAIL: monotone: v({set(s)}) = {self.v(s)} > {self.v(t)} = v({set(t)})")
                        ok = False
            
            # Ultrametric join
            for t in subsets:
                v_union = self.v(self.cl(s | t))
                v_max = max_top(self.v(s), self.v(t))
                if not le_top(v_union, v_max):
                    if verbose: print(f"FAIL: ultrametric: v(cl({set(s)} ∪ {set(t)})) = {v_union} > max({self.v(s)}, {self.v(t)}) = {v_max}")
                    ok = False
        
        return ok

def powerset(s):
    """Generate all subsets of s as frozensets."""
    s = list(s)
    for r in range(len(s) + 1):
        for combo in itertools.combinations(s, r):
            yield frozenset(combo)

# ==============================================================================
# Ultrametric Information Distance
# ==============================================================================

def info_dist(cap: ClosureCapacity, s: frozenset, t: frozenset) -> Optional[int]:
    """d(S, T) = v(cl(S ∪ T))."""
    return cap.v(cap.cl(s | t))

def verify_ultrametric_triangle(cap: ClosureCapacity, verbose=False) -> bool:
    """Verify d(S,U) ≤ max(d(S,T), d(T,U)) for all S, T, U."""
    subsets = list(powerset(cap.universe))
    ok = True
    for s in subsets:
        for t in subsets:
            for u in subsets:
                d_su = info_dist(cap, s, u)
                d_st = info_dist(cap, s, t)
                d_tu = info_dist(cap, t, u)
                if not le_top(d_su, max_top(d_st, d_tu)):
                    if verbose:
                        print(f"FAIL: d({set(s)},{set(u)})={d_su} > max(d({set(s)},{set(t)})={d_st}, d({set(t)},{set(u)})={d_tu})")
                    ok = False
    return ok

# ==============================================================================
# Pullback Along Closure Morphisms
# ==============================================================================

def is_closure_morphism(cl_a, cl_b, f, universe_a):
    """Check if f is a closure morphism: f(cl_a(S)) ⊆ cl_b(f(S))."""
    for s in powerset(universe_a):
        f_cls = frozenset(f(x) for x in cl_a(s))
        clf_s = cl_b(frozenset(f(x) for x in s))
        if not f_cls <= clf_s:
            return False
    return True

def pullback_capacity(cap_b, cl_a, f):
    """Pullback: (f*I_b)(S) = I_b(f(S))."""
    def v(s):
        return cap_b.v(frozenset(f(x) for x in s))
    return v

# ==============================================================================
# Demonstrations
# ==============================================================================

def demo_1_identity_closure():
    """Demo 1: Valid ultrametric capacity on {0,1,2} with identity closure."""
    print("=" * 60)
    print("DEMO 1: Ultrametric Capacity on {0,1,2} with Identity Closure")
    print("=" * 60)
    
    universe = frozenset({0, 1, 2})
    cl = identity_closure(universe)
    
    # Valid ultrametric capacity: v(∅) = 0, v(S) = max element + 1
    # This satisfies v(cl(S∪T)) = v(S∪T) ≤ max(v(S), v(T))
    # because max(S∪T) = max(max(S), max(T))
    def v(s):
        if not s:
            return 0
        return max(s) + 1
    
    cap = ClosureCapacity(universe, cl, v)
    
    print("\nCapacity values (v(S) = max(S)+1 for S≠∅, v(∅)=0):")
    for s in sorted(powerset(universe), key=len):
        print(f"  v({set(s) if s else '{}'}) = {cap.v(s)}")
    
    print(f"\nAll axioms verified: {cap.verify(verbose=True)}")
    
    print("\nNote: v(S)=|S| would NOT be ultrametric (it's additive).")
    print("The ultrametric law v(S∪T) ≤ max(v(S),v(T)) requires")
    print("the dominant source to absorb the other.")
    
    print("\nUltrametric distances:")
    elements = [frozenset({i}) for i in sorted(universe)]
    for i, s in enumerate(elements):
        for j, t in enumerate(elements):
            if i < j:
                d = info_dist(cap, s, t)
                print(f"  d({set(s)}, {set(t)}) = {d}")
    
    print(f"Ultrametric triangle inequality holds: {verify_ultrametric_triangle(cap)}")

def demo_2_total_closure():
    """Demo 2: Total closure — all nonempty sets close to universe."""
    print("\n" + "=" * 60)
    print("DEMO 2: Total Closure on {0,1,2}")
    print("=" * 60)
    
    universe = frozenset({0, 1, 2})
    cl = powerset_closure(universe)
    
    # Since cl(S) = universe for S ≠ ∅, closure invariance forces
    # v(S) = v(universe) for all S ≠ ∅.
    def v(s):
        return 0 if len(s) == 0 else 3
    
    cap = ClosureCapacity(universe, cl, v)
    
    print("\nClosure classes:")
    print("  [∅] = {∅}")
    print(f"  [universe] = all nonempty subsets")
    
    print("\nCapacity values:")
    for s in sorted(powerset(universe), key=len):
        print(f"  v({set(s) if s else '{}'}) = {cap.v(s)}, cl(S) = {set(cl(s)) if cl(s) else '{}'}")
    
    print(f"\nAll axioms verified: {cap.verify(verbose=True)}")
    
    # Verify closure class invariance
    print("\nClosure class invariance:")
    for s in powerset(universe):
        for t in powerset(universe):
            if cl(s) == cl(t) and s != t:
                print(f"  cl({set(s)}) = cl({set(t)}) => v(S)={cap.v(s)}, v(T)={cap.v(t)}, equal={cap.v(s)==cap.v(t)}")
                break

def demo_3_pullback_contraction():
    """Demo 3: Pullback contracts information."""
    print("\n" + "=" * 60)
    print("DEMO 3: Pullback Contraction (Data Processing Inequality)")
    print("=" * 60)
    
    # α = {0,1,2,3}, β = {0,1}
    # f : α → β, f(0)=f(1)=0, f(2)=f(3)=1
    universe_a = frozenset({0, 1, 2, 3})
    universe_b = frozenset({0, 1})
    
    cl_a = identity_closure(universe_a)
    cl_b = identity_closure(universe_b)
    
    def f(x):
        return 0 if x <= 1 else 1
    
    # Check closure morphism
    print(f"\nf is closure morphism: {is_closure_morphism(cl_a, cl_b, f, universe_a)}")
    
    # Information on β: v({}) = 0, v({0}) = 2, v({1}) = 3, v({0,1}) = 3
    def v_b(s):
        if len(s) == 0:
            return 0
        if s == frozenset({0}):
            return 2
        if s == frozenset({1}):
            return 3
        return 3  # max(2,3)
    
    cap_b = ClosureCapacity(universe_b, cl_b, v_b)
    print(f"Iβ axioms verified: {cap_b.verify()}")
    
    # Pullback
    v_a = pullback_capacity(cap_b, cl_a, f)
    cap_a = ClosureCapacity(universe_a, cl_a, v_a)
    
    print("\nPullback values and contraction check:")
    for s in sorted(powerset(universe_a), key=len):
        f_s = frozenset(f(x) for x in s)
        Ia = v_a(s)
        Ib = v_b(f_s)
        contracted = le_top(Ia, Ib)
        print(f"  S={set(s) if s else '{}'}: Iα(S)={Ia}, Iβ(f(S))={Ib}, Iα≤Iβ: {contracted}")
    
    print(f"\nPullback axioms verified: {cap_a.verify()}")

def demo_4_matroid():
    """Demo 4: Matroid closure capacity."""
    print("\n" + "=" * 60)
    print("DEMO 4: Cycle Matroid of K₄")
    print("=" * 60)
    
    cl, universe, rank = matroid_closure_k4()
    edges = [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
    
    # Note: matroid rank is submodular but NOT ultrametric.
    # Use an ultrametric-compatible capacity instead: v(S) = 1 if rank(S) > 0, else 0
    # This is ultrametric because max(0,0)=0 and max(1,x)=1 for all x.
    def v_ultra(s):
        return 0 if rank(s) == 0 else 1
    
    cap = ClosureCapacity(universe, cl, v_ultra)
    
    print("\nEdge labels:")
    for i, e in enumerate(edges):
        print(f"  {i}: {e}")
    
    print("\nMatroid rank values (NOT ultrametric):")
    examples = [
        frozenset(),
        frozenset({0}),
        frozenset({0, 1}),
        frozenset({0, 1, 3}),  # triangle
        frozenset({0, 1, 2}),
        universe,
    ]
    for s in examples:
        edge_names = [str(edges[i]) for i in sorted(s)]
        print(f"  {edge_names}: rank={rank(s)}, cl has {len(cl(s))} edges")
    
    print("\nNote: rank is submodular (r(A∪B)+r(A∩B) ≤ r(A)+r(B))")
    print("but NOT ultrametric (r(A∪B) ≤ max(r(A),r(B)) fails).")
    print("Using ultrametric capacity v(S) = [rank(S) > 0]:")
    
    for s in examples:
        edge_names = [str(edges[i]) for i in sorted(s)]
        print(f"  {edge_names}: v={v_ultra(s)}")
    
    print(f"\nUltrametric axioms verified: {cap.verify()}")

def demo_5_downward_closure():
    """Demo 5: Downward closure on {1,2,3,4}."""
    print("\n" + "=" * 60)
    print("DEMO 5: Downward Closure on {1,2,3,4}")
    print("=" * 60)
    
    universe = frozenset({1, 2, 3, 4})
    cl = downward_closure(universe)
    
    # Capacity: v(S) = max(S) if S nonempty, 0 if empty
    def v(s):
        if not s:
            return 0
        return max(s)
    
    cap = ClosureCapacity(universe, cl, v)
    
    print("\nClosure examples:")
    examples = [frozenset({2}), frozenset({1,3}), frozenset({4}), frozenset({2,4})]
    for s in examples:
        print(f"  cl({set(s)}) = {set(cl(s))}, v = {v(s)}")
    
    print(f"\nAll axioms verified: {cap.verify(verbose=True)}")
    print(f"Ultrametric triangle inequality holds: {verify_ultrametric_triangle(cap)}")
    
    print("\nClosure class invariance verification:")
    count = 0
    for s in powerset(universe):
        for t in powerset(universe):
            if s < t and cl(s) == cl(t):
                assert v(s) == v(t), f"FAIL: v({set(s)})={v(s)} ≠ {v(t)}=v({set(t)})"
                count += 1
    print(f"  Checked {count} pairs with same closure, all have equal capacity ✓")

def demo_6_composition():
    """Demo 6: Composition of closure morphisms."""
    print("\n" + "=" * 60)
    print("DEMO 6: Composition of Closure Morphisms")
    print("=" * 60)
    
    # α = {0,1,2,3}, β = {0,1,2}, γ = {0,1}
    u_a = frozenset({0,1,2,3})
    u_b = frozenset({0,1,2})
    u_c = frozenset({0,1})
    
    cl_a = identity_closure(u_a)
    cl_b = identity_closure(u_b)
    cl_c = identity_closure(u_c)
    
    def f(x): return min(x, 2)  # 0→0, 1→1, 2→2, 3→2
    def g(x): return min(x, 1)  # 0→0, 1→1, 2→1
    def gf(x): return g(f(x))
    
    print(f"f: α→β is closure morphism: {is_closure_morphism(cl_a, cl_b, f, u_a)}")
    print(f"g: β→γ is closure morphism: {is_closure_morphism(cl_b, cl_c, g, u_b)}")
    print(f"g∘f: α→γ is closure morphism: {is_closure_morphism(cl_a, cl_c, gf, u_a)}")
    
    # Information on γ
    def v_c(s):
        return len(s)
    cap_c = ClosureCapacity(u_c, cl_c, v_c)
    
    # Pullback along g∘f
    v_a_direct = pullback_capacity(cap_c, cl_a, gf)
    
    # Pullback along f then g
    v_b_g = pullback_capacity(cap_c, cl_b, g)
    cap_b_g = ClosureCapacity(u_b, cl_b, v_b_g)
    v_a_compose = pullback_capacity(cap_b_g, cl_a, f)
    
    print("\nFunctoriality check: pullback(g∘f) = pullback(f) ∘ pullback(g)")
    for s in sorted(powerset(u_a), key=len):
        direct = v_a_direct(s)
        composed = v_a_compose(s)
        match = direct == composed
        print(f"  S={set(s) if s else '{}'}: direct={direct}, composed={composed}, match={match}")

# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    demo_1_identity_closure()
    demo_2_total_closure()
    demo_3_pullback_contraction()
    demo_4_matroid()
    demo_5_downward_closure()
    demo_6_composition()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


"""Generate PACKAGE.json with all artifacts embedded."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
lean_code = read_file('Bridges/AlgebraEMLTropical/PadicClosureInformationDuality.lean')
lattice_svg = read_file('lattice_diagram.svg')
tree_svg = read_file('ultrametric_tree.svg')
duality_svg = read_file('duality_diagram.svg')

package = {
    "title": "Non-Archimedean Information Duality via p-adic Closure Capacities and Min-Plus Rate Functions",
    "domain": "Bridges: Algebra × Information Theory × Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Closure Capacity Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Capacity Evaluation",
            "pseudocode": "Input: Closure operator cl, capacity v, set S\nOutput: v(S)\n\n1. Compute cl(S)\n2. Look up v(cl(S)) in capacity table\n3. Return v(cl(S))  [= v(S) by closure invariance]\n\nTime: O(|α|) for closure + O(1) lookup"
        },
        {
            "name": "Decomposition Cost (Tropical Residuation)",
            "pseudocode": "Input: Closure operator cl, capacity v, set S\nOutput: min{v(T) : cl(T) = cl(S)}\n\n1. Return v(S)  [by Theorem 3.7, infimum = v(S) since v constant on classes]\n\nTime: O(|α|)"
        },
        {
            "name": "Information Pullback",
            "pseudocode": "Input: Closure morphism f : α → β, information Iβ, set S ⊆ α\nOutput: Pullback information Iα(S)\n\n1. Compute f(S) = {f(a) : a ∈ S}\n2. Return Iβ(f(S))\n\nTime: O(|S| + T_Iβ)"
        },
        {
            "name": "Ultrametric Information Distance",
            "pseudocode": "Input: Closure operator cl, capacity v, sets S, T\nOutput: d(S, T) satisfying strong triangle inequality\n\n1. Compute U = S ∪ T\n2. Compute cl(U)\n3. Return v(cl(U))\n\nTime: O(|α|)\nProperty: d(S,U) ≤ max(d(S,T), d(T,U)) for all S,T,U"
        }
    ],
    "visualizations": [
        {
            "name": "Closure Lattice with Capacity Values",
            "data": lattice_svg
        },
        {
            "name": "Ultrametric Tree from Information Distance",
            "data": tree_svg
        },
        {
            "name": "Capacity–Information Duality Diagram",
            "data": duality_svg
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


"""
Visualizations for Non-Archimedean Information Duality.
Generates closure lattice diagrams and ultrametric distance matrices.
"""
import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def generate_lattice_svg():
    """Generate SVG of the closure lattice for downward closure on {1,2,3}."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 350" width="400" height="350">
  <style>
    .node { fill: #4A90D9; stroke: #2C5F8A; stroke-width: 2; }
    .label { font-family: monospace; font-size: 11px; text-anchor: middle; fill: white; }
    .edge { stroke: #888; stroke-width: 1.5; fill: none; }
    .title { font-family: sans-serif; font-size: 14px; text-anchor: middle; font-weight: bold; fill: #333; }
    .vlabel { font-family: sans-serif; font-size: 10px; text-anchor: start; fill: #D9534F; font-weight: bold; }
    .class-box { fill: #F0F0FF; stroke: #AAA; stroke-width: 1; stroke-dasharray: 4,2; rx: 8; }
  </style>
  <text x="200" y="25" class="title">Closure Lattice: Downward Closure on {1,2,3}</text>
  <text x="200" y="42" style="font-family:sans-serif;font-size:10px;text-anchor:middle;fill:#666;">
    cl(S) = {x : x ≤ max(S)}, v(S) = max(S)
  </text>

  <!-- Closure class boxes -->
  <rect x="155" y="52" width="90" height="40" class="class-box"/>
  <rect x="75" y="125" width="110" height="75" class="class-box"/>
  <rect x="215" y="125" width="110" height="75" class="class-box"/>
  <rect x="80" y="230" width="240" height="75" class="class-box"/>

  <!-- Edges (Hasse diagram of closure lattice) -->
  <line x1="200" y1="85" x2="130" y2="145" class="edge"/>
  <line x1="200" y1="85" x2="270" y2="145" class="edge"/>
  <line x1="200" y1="85" x2="200" y2="250" class="edge"/>
  <line x1="130" y1="185" x2="130" y2="250" class="edge"/>
  <line x1="130" y1="185" x2="200" y2="250" class="edge"/>
  <line x1="270" y1="185" x2="270" y2="250" class="edge"/>
  <line x1="270" y1="185" x2="200" y2="250" class="edge"/>

  <!-- Nodes -->
  <circle cx="200" cy="72" r="18" class="node"/>
  <text x="200" y="76" class="label">∅</text>
  <text x="245" y="72" class="vlabel">v=0</text>

  <circle cx="130" cy="155" r="18" class="node"/>
  <text x="130" y="159" class="label">{1}</text>
  <text x="89" y="150" class="vlabel">v=1</text>

  <circle cx="130" cy="185" r="18" class="node" style="fill:#6AAF6A;stroke:#3A7A3A;"/>
  <text x="130" y="189" class="label">{1,2}</text>

  <circle cx="270" cy="155" r="18" class="node"/>
  <text x="270" y="159" class="label">{2}</text>
  <text x="309" y="155" class="vlabel">v=2</text>

  <circle cx="270" cy="185" r="18" class="node" style="fill:#6AAF6A;stroke:#3A7A3A;"/>
  <text x="270" y="189" class="label">{1,3}</text>

  <circle cx="200" cy="260" r="18" class="node" style="fill:#D9534F;stroke:#A33;"/>
  <text x="200" y="264" class="label">{1,2,3}</text>
  <text x="240" y="260" class="vlabel">v=3</text>

  <!-- Additional nodes in same class -->
  <circle cx="130" cy="260" r="14" class="node" style="fill:#D9534F;stroke:#A33;opacity:0.7;"/>
  <text x="130" y="264" style="font-family:monospace;font-size:9px;text-anchor:middle;fill:white;">{3}</text>

  <circle cx="270" cy="260" r="14" class="node" style="fill:#D9534F;stroke:#A33;opacity:0.7;"/>
  <text x="270" y="264" style="font-family:monospace;font-size:9px;text-anchor:middle;fill:white;">{2,3}</text>

  <!-- Legend -->
  <text x="200" y="330" style="font-family:sans-serif;font-size:9px;text-anchor:middle;fill:#666;">
    Dashed boxes = closure classes (same capacity value). Colors = distinct classes.
  </text>
</svg>"""
    return svg


def generate_ultrametric_tree_svg():
    """Generate SVG showing ultrametric tree structure of info distances."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 280" width="400" height="280">
  <style>
    .branch { stroke: #4A90D9; stroke-width: 2.5; fill: none; }
    .leaf { fill: #D9534F; stroke: #A33; stroke-width: 2; }
    .leaf-label { font-family: monospace; font-size: 12px; text-anchor: middle; fill: #333; }
    .dist-label { font-family: sans-serif; font-size: 10px; text-anchor: middle; fill: #4A90D9; font-weight: bold; }
    .title { font-family: sans-serif; font-size: 14px; text-anchor: middle; font-weight: bold; fill: #333; }
    .axis-label { font-family: sans-serif; font-size: 9px; fill: #999; }
  </style>
  <text x="200" y="25" class="title">Ultrametric Tree from Information Distance</text>
  <text x="200" y="42" style="font-family:sans-serif;font-size:10px;text-anchor:middle;fill:#666;">
    d(S,T) = v(cl(S∪T)), satisfying d(A,C) ≤ max(d(A,B), d(B,C))
  </text>

  <!-- Cost axis -->
  <line x1="30" y1="60" x2="30" y2="240" stroke="#CCC" stroke-width="1"/>
  <text x="20" y="95" class="axis-label" text-anchor="end">3</text>
  <text x="20" y="155" class="axis-label" text-anchor="end">2</text>
  <text x="20" y="215" class="axis-label" text-anchor="end">1</text>
  <line x1="25" y1="90" x2="35" y2="90" stroke="#CCC" stroke-width="1"/>
  <line x1="25" y1="150" x2="35" y2="150" stroke="#CCC" stroke-width="1"/>
  <line x1="25" y1="210" x2="35" y2="210" stroke="#CCC" stroke-width="1"/>

  <!-- Tree structure for {0},{1},{2} with d({0},{1})=2, d({0},{2})=3, d({1},{2})=3 -->
  <!-- Root at height 3 -->
  <line x1="200" y1="90" x2="120" y2="150" class="branch"/>
  <line x1="200" y1="90" x2="280" y2="150" class="branch"/>
  
  <!-- Left subtree at height 2 -->
  <line x1="120" y1="150" x2="80" y2="230" class="branch"/>
  <line x1="120" y1="150" x2="160" y2="230" class="branch"/>
  
  <!-- Right leaf at height 3 -->
  <line x1="280" y1="150" x2="280" y2="230" class="branch"/>

  <!-- Junction points -->
  <circle cx="200" cy="90" r="4" fill="#4A90D9"/>
  <circle cx="120" cy="150" r="4" fill="#4A90D9"/>

  <!-- Leaves -->
  <circle cx="80" cy="240" r="12" class="leaf"/>
  <text x="80" y="262" class="leaf-label">{0}</text>
  
  <circle cx="160" cy="240" r="12" class="leaf"/>
  <text x="160" y="262" class="leaf-label">{1}</text>
  
  <circle cx="280" cy="240" r="12" class="leaf"/>
  <text x="280" y="262" class="leaf-label">{2}</text>

  <!-- Distance labels -->
  <text x="120" y="140" class="dist-label">d=2</text>
  <text x="200" y="80" class="dist-label">d=3</text>
</svg>"""
    return svg


def generate_duality_diagram_svg():
    """Generate SVG showing the capacity ≃ information duality."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 200" width="500" height="200">
  <style>
    .box { rx: 10; ry: 10; stroke-width: 2; }
    .box-label { font-family: sans-serif; font-size: 13px; text-anchor: middle; font-weight: bold; }
    .box-sub { font-family: sans-serif; font-size: 9px; text-anchor: middle; fill: #666; }
    .arrow { stroke-width: 2; fill: none; marker-end: url(#arrowhead); }
    .arrow-label { font-family: sans-serif; font-size: 10px; text-anchor: middle; fill: #4A90D9; }
    .equiv { font-family: sans-serif; font-size: 20px; text-anchor: middle; fill: #D9534F; font-weight: bold; }
  </style>
  <defs>
    <marker id="arrowhead" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <polygon points="0 0, 8 3, 0 6" fill="#4A90D9"/>
    </marker>
  </defs>

  <text x="250" y="25" style="font-family:sans-serif;font-size:14px;text-anchor:middle;font-weight:bold;fill:#333;">
    Capacity–Information Duality (Theorem C)
  </text>

  <!-- Left box: ClosureCapacity -->
  <rect x="30" y="50" width="180" height="120" class="box" fill="#E8F4FD" stroke="#4A90D9"/>
  <text x="120" y="80" class="box-label" fill="#2C5F8A">ClosureCapacity</text>
  <text x="120" y="100" class="box-sub">• closure_invariant</text>
  <text x="120" y="115" class="box-sub">• monotone</text>
  <text x="120" y="130" class="box-sub">• normalized_bot</text>
  <text x="120" y="145" class="box-sub">• ultrametric_join</text>

  <!-- Right box: TropicalClosureInformation -->
  <rect x="290" y="50" width="180" height="120" class="box" fill="#FDE8E8" stroke="#D9534F"/>
  <text x="380" y="80" class="box-label" fill="#A33">TropicalClosure</text>
  <text x="380" y="95" class="box-label" fill="#A33">Information</text>
  <text x="380" y="115" class="box-sub">• all capacity axioms</text>
  <text x="380" y="130" class="box-sub">• + residuated</text>
  <text x="380" y="145" class="box-sub">(auto from finiteness!)</text>

  <!-- Arrows -->
  <path d="M 210 90 Q 250 70 290 90" class="arrow" stroke="#4A90D9"/>
  <text x="250" y="67" class="arrow-label">capacityToInfo</text>
  
  <path d="M 290 140 Q 250 160 210 140" class="arrow" stroke="#D9534F"/>
  <text x="250" y="170" class="arrow-label" fill="#D9534F">infoToCapacity</text>

  <!-- Equivalence symbol -->
  <text x="250" y="120" class="equiv">≃</text>
</svg>"""
    return svg


if __name__ == "__main__":
    # Save SVGs
    with open("lattice_diagram.svg", "w") as f:
        f.write(generate_lattice_svg())
    with open("ultrametric_tree.svg", "w") as f:
        f.write(generate_ultrametric_tree_svg())
    with open("duality_diagram.svg", "w") as f:
        f.write(generate_duality_diagram_svg())
    print("SVG visualizations saved.")
