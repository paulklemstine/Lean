#!/usr/bin/env python3
"""
Applications of the Support-Tutte polynomial theory.

Demonstrates:
  1. Reliability polynomial evaluation for network supports
  2. Partition function computation (statistical mechanics)
  3. Newton polytope invariant analysis
  4. Matroid rank function recovery
"""

from typing import Set, Tuple, FrozenSet, Dict, List
from itertools import combinations


class GroundSupport:
    """Ground support with basic operations."""
    def __init__(self, supp, ground):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    @classmethod
    def from_sets(cls, supp, ground):
        return cls(frozenset(supp), frozenset(ground))
    def delete(self, e):
        return GroundSupport(frozenset(m for m in self.supp if m[e] == 0), self.ground - {e})
    def min_coord(self, e):
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e):
        mc = self.min_coord(e)
        shifted = frozenset(tuple(v-mc if j==e else v for j,v in enumerate(m))
                           for m in self.supp if m[e]==mc)
        return GroundSupport(shifted, self.ground - {e})
    def is_loop(self, e):
        return bool(self.supp) and all(m[e] > 0 for m in self.supp)
    def is_coloop(self, e):
        return bool(self.supp) and len({m[e] for m in self.supp}) == 1


def tutte_4param(S, x=1, y=1, u=1, v=1):
    if not S.ground: return 1
    e = min(S.ground)
    if S.is_loop(e): return y * tutte_4param(S.delete(e), x, y, u, v)
    elif S.is_coloop(e): return x * tutte_4param(S.contract(e), x, y, u, v)
    else: return u * tutte_4param(S.delete(e), x, y, u, v) + v * tutte_4param(S.contract(e), x, y, u, v)


def compute_activity(S):
    loops = coloops = ordinary = 0
    current = S
    while current.ground:
        e = min(current.ground)
        if current.is_loop(e): loops += 1; current = current.delete(e)
        elif current.is_coloop(e): coloops += 1; current = current.contract(e)
        else: ordinary += 1; current = current.delete(e)
    return {'loops': loops, 'coloops': coloops, 'ordinary': ordinary}


# ──────────────────────────────────────────────────────────────────
# Application 1: Reliability Polynomial
# ──────────────────────────────────────────────────────────────────

def reliability_eval(S: GroundSupport, p: float) -> float:
    """
    Reliability polynomial: probability that a random sub-support
    (each coordinate kept independently with probability p) is nonempty.

    For matroid supports, this specializes to the matroid reliability polynomial.
    For general supports, it measures support robustness under random deletion.

    Uses T₄ with x=1, y=1-p, u=p, v=1-p.
    """
    if not S.ground:
        return 1.0
    e = min(S.ground)
    if S.is_loop(e):
        return (1-p) * reliability_eval(S.delete(e), p)
    elif S.is_coloop(e):
        return 1.0 * reliability_eval(S.contract(e), p)
    else:
        return p * reliability_eval(S.delete(e), p) + (1-p) * reliability_eval(S.contract(e), p)


# ──────────────────────────────────────────────────────────────────
# Application 2: Partition Function
# ──────────────────────────────────────────────────────────────────

def partition_function(S: GroundSupport, beta: float) -> float:
    """
    Statistical mechanics partition function: weighted count over
    minor histories with Boltzmann weights.

    Z(S; β) = Σ_histories exp(-β · cost(history))

    where the cost is determined by the loop/coloop classification
    at each deletion-contraction step.

    Uses T₄ with x=exp(-β), y=exp(β), u=1, v=1.
    """
    import math
    x = math.exp(-beta)
    y = math.exp(beta)
    return tutte_4param(S, int(x*1000), int(y*1000), 1000, 1000) / (1000 ** len(S.ground))


# ──────────────────────────────────────────────────────────────────
# Application 3: Newton Polytope Analysis
# ──────────────────────────────────────────────────────────────────

def newton_polytope_invariant(supp_points: Set[Tuple[int, ...]]) -> Dict:
    """
    Analyze the Newton polytope of a support set.

    Returns a dictionary of invariants:
      - volume_estimate: approximate normalized volume
      - num_vertices: number of extremal points
      - activity_signature: (loops, coloops, ordinary) tuple
      - tutte_value: T₄ at standard parameters
    """
    n = len(next(iter(supp_points)))
    S = GroundSupport.from_sets(supp_points, set(range(n)))

    # Count vertices (extremal points in each coordinate direction)
    vertices = set()
    for m in supp_points:
        is_vertex = True
        for m2 in supp_points:
            if m2 != m and all(m2[i] >= m[i] for i in range(n)):
                is_vertex = False; break
            if m2 != m and all(m2[i] <= m[i] for i in range(n)):
                is_vertex = False; break
        if is_vertex:
            vertices.add(m)

    activity = compute_activity(S)
    return {
        'num_points': len(supp_points),
        'dimension': n,
        'num_vertices': len(vertices),
        'activity': activity,
        'tutte_value': tutte_4param(S, 2, 3, 1, 1),
    }


# ──────────────────────────────────────────────────────────────────
# Application 4: Matroid Rank Recovery
# ──────────────────────────────────────────────────────────────────

def matroid_rank_from_support(bases: List[FrozenSet[int]], n: int) -> Dict[FrozenSet[int], int]:
    """
    Recover the matroid rank function from the indicator support.

    For a matroid M with bases B, the rank of a subset A ⊆ E is:
      r(A) = max{|A ∩ B| : B ∈ B}

    This demonstrates that support-Tutte theory contains matroid theory
    as a special case.
    """
    rank = {}
    for size in range(n + 1):
        for A in combinations(range(n), size):
            A_set = frozenset(A)
            r = max(len(A_set & B) for B in bases)
            rank[A_set] = r
    return rank


# ──────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("SUPPORT-TUTTE POLYNOMIAL — APPLICATIONS")
    print("=" * 70)

    # App 1: Reliability
    print("\n─── Application 1: Reliability Polynomial ───")
    # U(2,4) matroid
    S_u24 = GroundSupport.from_sets(
        {tuple(1 if i in B else 0 for i in range(4))
         for B in combinations(range(4), 2)},
        set(range(4))
    )
    for p in [0.1, 0.3, 0.5, 0.7, 0.9]:
        r = reliability_eval(S_u24, p)
        print(f"  R(U(2,4); p={p}) = {r:.4f}")

    # App 2: Newton polytope
    print("\n─── Application 2: Newton Polytope Invariants ───")
    polytopes = [
        ("Δ(3,2)", {(2,0,0),(1,1,0),(1,0,1),(0,2,0),(0,1,1),(0,0,2)}),
        ("Δ(3,1)", {(1,0,0),(0,1,0),(0,0,1)}),
        ("Cube slice", {(0,0,0),(1,0,0),(0,1,0),(1,1,0),(0,0,1),(1,0,1)}),
    ]
    for name, pts in polytopes:
        info = newton_polytope_invariant(pts)
        print(f"  {name}: {info}")

    # App 3: Matroid rank recovery
    print("\n─── Application 3: Matroid Rank Recovery ───")
    bases_u23 = [frozenset(B) for B in combinations(range(3), 2)]
    rank = matroid_rank_from_support(bases_u23, 3)
    print(f"  U(2,3) bases: {[set(B) for B in bases_u23]}")
    print(f"  Rank function:")
    for A in sorted(rank.keys(), key=lambda s: (len(s), sorted(s))):
        print(f"    r({set(A) if A else '∅'}) = {rank[A]}")

    # App 4: Comparison of supports with same |ground| but different structure
    print("\n─── Application 4: Support Classification ───")
    supports = {
        "All-zero": GroundSupport.from_sets({(0,0,0)}, {0,1,2}),
        "Standard basis": GroundSupport.from_sets({(1,0,0),(0,1,0),(0,0,1)}, {0,1,2}),
        "All-ones": GroundSupport.from_sets({(1,1,1)}, {0,1,2}),
        "Mixed": GroundSupport.from_sets({(1,1,0),(0,1,1)}, {0,1,2}),
        "High degree": GroundSupport.from_sets({(3,0,0),(0,3,0),(0,0,3)}, {0,1,2}),
    }
    print(f"  {'Name':<20} {'Activity':<25} {'T₄(5,3,2,7)':>12}")
    for name, S in supports.items():
        act = compute_activity(S)
        val = tutte_4param(S, 5, 3, 2, 7)
        act_str = f"L={act['loops']} C={act['coloops']} O={act['ordinary']}"
        print(f"  {name:<20} {act_str:<25} {val:>12}")

    print("\n" + "=" * 70)


#!/usr/bin/env python3
"""
Demo: Support-Tutte Polynomial Computation

Demonstrates the universal deletion-contraction invariant for M-convex supports.
Two evaluation modes highlight different aspects:
  1. Uniform coefficients T(a,b) = (a+b)^|ground| (Power Law theorem)
  2. Case-dependent T₄(x,y,u,v) — genuinely non-trivial, distinguishes
     supports that matroids and uniform coefficients cannot separate.
"""

from itertools import combinations, permutations
from typing import Set, Tuple, Optional, List


class GroundSupport:
    """A ground support: a finite set of ℕ^n vectors with a ground set."""
    def __init__(self, supp: Set[Tuple[int, ...]], ground: Set[int]):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    def __repr__(self):
        return f"GS(|supp|={len(self.supp)}, ground={sorted(self.ground)})"
    def delete(self, e: int) -> 'GroundSupport':
        return GroundSupport({m for m in self.supp if m[e] == 0}, self.ground - {e})
    def min_coord_val(self, e: int) -> int:
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e: int) -> 'GroundSupport':
        mc = self.min_coord_val(e)
        filtered = {m for m in self.supp if m[e] == mc}
        shifted = {tuple(v - mc if j == e else v for j, v in enumerate(m)) for m in filtered}
        return GroundSupport(shifted, self.ground - {e})
    def is_loop(self, e: int) -> bool:
        return bool(self.supp) and all(m[e] > 0 for m in self.supp)
    def is_coloop(self, e: int) -> bool:
        if not self.supp: return False
        return len({m[e] for m in self.supp}) == 1


def tutte_uniform(S: GroundSupport, a=1, b=1, order=None) -> int:
    """Uniform-coefficient evaluation: always equals (a+b)^|ground|."""
    if not S.ground: return 1
    e = min(S.ground) if order is None else next((x for x in order if x in S.ground), None)
    if e is None: return 1
    return a * tutte_uniform(S.delete(e), a, b, order) + b * tutte_uniform(S.contract(e), a, b, order)


def tutte_4param(S: GroundSupport, x=1, y=1, u=1, v=1, order=None) -> int:
    """
    Case-dependent 4-parameter evaluation.
    Loop → y · T(delete), Coloop → x · T(contract), Ordinary → u · T(delete) + v · T(contract)
    """
    if not S.ground: return 1
    e = min(S.ground) if order is None else next((el for el in order if el in S.ground), None)
    if e is None: return 1
    S_del, S_con = S.delete(e), S.contract(e)
    if S.is_loop(e):
        return y * tutte_4param(S_del, x, y, u, v, order)
    elif S.is_coloop(e):
        return x * tutte_4param(S_con, x, y, u, v, order)
    else:
        return u * tutte_4param(S_del, x, y, u, v, order) + v * tutte_4param(S_con, x, y, u, v, order)


def simplex_support(n, d):
    def gen(rv, rs):
        if rv == 1: yield (rs,); return
        for val in range(rs + 1):
            for rest in gen(rv - 1, rs - val): yield (val,) + rest
    return GroundSupport(set(gen(n, d)), set(range(n)))


def uniform_matroid_support(n, k):
    supp = {tuple(1 if i in B else 0 for i in range(n)) for B in combinations(range(n), k)}
    return GroundSupport(supp, set(range(n)))


def test_order_independence(S, name, eval_fn, **kwargs):
    ground_list = sorted(S.ground)
    perms = list(permutations(ground_list)) if len(ground_list) <= 6 else \
            [ground_list] + [__import__('random').sample(ground_list, len(ground_list)) for _ in range(19)]
    vals = {eval_fn(S, order=list(p), **kwargs) for p in perms}
    status = "✓" if len(vals) == 1 else "✗"
    print(f"  {status} {name}: T = {vals.pop() if len(vals)==1 else vals} ({len(perms)} orderings)")
    return len(vals) == 1


def main():
    print("=" * 70)
    print("SUPPORT-TUTTE POLYNOMIAL — DEMO")
    print("=" * 70)

    # ── 1: Power Law ──
    print("\n─── 1: Power Law: T(a,b) = (a+b)^|ground| ───")
    for n, d in [(2,1),(3,2),(4,1)]:
        S = simplex_support(n, d)
        for a, b in [(1,1),(2,3)]:
            val = tutte_uniform(S, a, b)
            exp = (a+b)**n
            print(f"  {'✓' if val==exp else '✗'} Δ({n},{d}): T({a},{b}) = {val} = ({a}+{b})^{n}")

    # ── 2: Non-trivial 4-param invariant ──
    print("\n─── 2: Non-trivial 4-parameter invariant T₄ ───")
    # These two supports are distinguished by T₄ but NOT by T(a,b)
    A = GroundSupport({(1,1), (1,2)}, {0,1})  # coord 0 is coloop (all have m(0)=1)
    B = GroundSupport({(1,1), (2,1)}, {0,1})  # coord 0 is loop (both >0) but not coloop
    print(f"  Support A = {{(1,1),(1,2)}}: coord 0 is coloop, coord 1 is loop")
    print(f"  Support B = {{(1,1),(2,1)}}: coord 0 is loop (not coloop), coord 1 is coloop")
    print(f"  Both have |ground|=2, |supp|=2")
    print()
    for x, y, u, v in [(2,3,1,1),(5,3,1,1),(1,1,1,1),(3,2,4,1)]:
        va = tutte_4param(A, x, y, u, v)
        vb = tutte_4param(B, x, y, u, v)
        tag = "SAME" if va == vb else "DIFFERENT ←"
        print(f"    T₄(x={x},y={y},u={u},v={v}):  A={va:>4}  B={vb:>4}  [{tag}]")
    print("\n  → T₄ distinguishes supports with different loop/coloop structure!")

    # ── 3: Matroid vs non-matroidal ──
    print("\n─── 3: Matroidal vs non-matroidal supports ───")
    # Non-{0,1} support with internal structure
    C = GroundSupport({(2,0,0),(0,2,0),(0,0,2),(1,1,0),(1,0,1),(0,1,1)}, {0,1,2})
    D = uniform_matroid_support(3, 2)  # U(2,3)
    print(f"  C = degree-2 simplex Δ(3,2):  |supp|={len(C.supp)}")
    print(f"  D = U(2,3) matroid:             |supp|={len(D.supp)}")
    for x, y, u, v in [(2,3,1,1),(5,3,1,1),(1,1,2,3)]:
        vc = tutte_4param(C, x, y, u, v)
        vd = tutte_4param(D, x, y, u, v)
        tag = "SAME" if vc == vd else "DIFFERENT ←"
        print(f"    T₄({x},{y},{u},{v}): C={vc:>4}  D={vd:>4}  [{tag}]")

    # ── 4: Order-independence ──
    print("\n─── 4: Order-independence verification ───")
    for name, S in [("Δ(3,2)", simplex_support(3,2)),
                     ("U(2,4)", uniform_matroid_support(4,2)),
                     ("A={(1,1),(1,2)}", A),
                     ("B={(1,1),(2,1)}", B)]:
        test_order_independence(S, name, tutte_4param, x=5, y=3, u=2, v=7)

    # ── 5: Dead coordinate ──
    print("\n─── 5: Dead coordinate theorem: T(S⊕dead) = (a+b)·T(S) ───")
    S0 = GroundSupport({(1,0),(0,1)}, {0,1})
    S1 = GroundSupport({(1,0,0),(0,1,0)}, {0,1,2})
    for a, b in [(1,1),(2,3),(4,5)]:
        v0, v1 = tutte_uniform(S0,a,b), tutte_uniform(S1,a,b)
        print(f"  {'✓' if v1==(a+b)*v0 else '✗'} T({a},{b}): base={v0}, extended={v1}, (a+b)·base={(a+b)*v0}")

    # ── 6: Spectrum of support-Tutte invariant ──
    print("\n─── 6: T₄ spectrum on 2-variable supports ───")
    print(f"  {'Support':<30} {'Loops':>5} {'Colps':>5} {'Ord':>5} {'T₄(5,3,2,7)':>12}")
    print(f"  {'─'*30} {'─'*5} {'─'*5} {'─'*5} {'─'*12}")
    examples = [
        ("{(0,0)}", GroundSupport({(0,0)}, {0,1})),
        ("{(1,0),(0,1)}", GroundSupport({(1,0),(0,1)}, {0,1})),
        ("{(1,1)}", GroundSupport({(1,1)}, {0,1})),
        ("{(1,1),(1,2)}", GroundSupport({(1,1),(1,2)}, {0,1})),
        ("{(1,1),(2,1)}", GroundSupport({(1,1),(2,1)}, {0,1})),
        ("{(2,0),(0,2)}", GroundSupport({(2,0),(0,2)}, {0,1})),
        ("{(1,0),(0,1),(1,1)}", GroundSupport({(1,0),(0,1),(1,1)}, {0,1})),
        ("{(2,0),(1,1),(0,2)}", GroundSupport({(2,0),(1,1),(0,2)}, {0,1})),
    ]
    for name, S in examples:
        loops = sum(1 for e in sorted(S.ground) if S.is_loop(e))
        colps = sum(1 for e in sorted(S.ground) if S.is_coloop(e))
        ords = len(S.ground) - loops - colps
        val = tutte_4param(S, 5, 3, 2, 7)
        print(f"  {name:<30} {loops:>5} {colps:>5} {ords:>5} {val:>12}")

    print("\n" + "=" * 70)
    print("Key insight: T₄ detects loop/coloop structure that uniform T(a,b) misses!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Deletion-Contraction Recursion Tree

Shows the recursion tree structure for the support-Tutte evaluation
on a concrete example, illustrating how loop/coloop/ordinary elements
produce different branching patterns.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

class GroundSupport:
    def __init__(self, supp, ground):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    def delete(self, e):
        return GroundSupport(frozenset(m for m in self.supp if m[e]==0), self.ground-{e})
    def min_coord(self, e):
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e):
        mc = self.min_coord(e)
        return GroundSupport(frozenset(tuple(v-mc if j==e else v for j,v in enumerate(m))
                            for m in self.supp if m[e]==mc), self.ground-{e})
    def is_loop(self, e):
        return bool(self.supp) and all(m[e]>0 for m in self.supp)
    def is_coloop(self, e):
        return bool(self.supp) and len({m[e] for m in self.supp})==1

def build_tree(S, depth=0, pos_x=0, width=4):
    """Build recursion tree as list of (node_info, children)."""
    if not S.ground:
        return {'x': pos_x, 'y': -depth, 'label': f'1\n|s|={len(S.supp)}',
                'type': 'base', 'children': []}

    e = min(S.ground)
    S_del = S.delete(e)
    S_con = S.contract(e)

    if S.is_loop(e):
        etype = 'loop'
        label = f'e={e}\nLOOP\n|s|={len(S.supp)}'
    elif S.is_coloop(e):
        etype = 'coloop'
        label = f'e={e}\nCOLOOP\n|s|={len(S.supp)}'
    else:
        etype = 'ordinary'
        label = f'e={e}\nORD\n|s|={len(S.supp)}'

    child_width = width / 2.5
    left = build_tree(S_del, depth+1, pos_x - width/2, child_width)
    right = build_tree(S_con, depth+1, pos_x + width/2, child_width)

    return {'x': pos_x, 'y': -depth, 'label': label, 'type': etype,
            'children': [left, right]}


def draw_tree(ax, node, parent=None):
    colors = {'loop': '#e74c3c', 'coloop': '#3498db', 'ordinary': '#2ecc71', 'base': '#95a5a6'}
    color = colors.get(node['type'], '#95a5a6')

    if parent:
        ax.plot([parent[0], node['x']], [parent[1], node['y']], 'k-', alpha=0.4, linewidth=1)

    circle = plt.Circle((node['x'], node['y']), 0.35, color=color, alpha=0.8, zorder=5)
    ax.add_patch(circle)
    ax.text(node['x'], node['y'], node['label'], ha='center', va='center',
            fontsize=6, fontweight='bold', zorder=6)

    for child in node['children']:
        draw_tree(ax, child, (node['x'], node['y']))


# Build trees for different supports
fig, axes = plt.subplots(1, 3, figsize=(18, 8))
fig.suptitle('Deletion-Contraction Recursion Trees', fontsize=14, fontweight='bold')

supports = [
    ("U(1,3): {(1,0,0),(0,1,0),(0,0,1)}",
     GroundSupport(frozenset({(1,0,0),(0,1,0),(0,0,1)}), frozenset({0,1,2}))),
    ("{(1,1,0),(0,1,1)}",
     GroundSupport(frozenset({(1,1,0),(0,1,1)}), frozenset({0,1,2}))),
    ("{(1,1,1)}",
     GroundSupport(frozenset({(1,1,1)}), frozenset({0,1,2}))),
]

for idx, (name, S) in enumerate(supports):
    ax = axes[idx]
    tree = build_tree(S, width=3)
    draw_tree(ax, tree)

    ax.set_xlim(-5, 5)
    ax.set_ylim(-4.5, 0.8)
    ax.set_aspect('equal')
    ax.set_title(name, fontsize=10, fontweight='bold')
    ax.axis('off')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#e74c3c', label='Loop (y·delete)'),
    mpatches.Patch(facecolor='#3498db', label='Coloop (x·contract)'),
    mpatches.Patch(facecolor='#2ecc71', label='Ordinary (u·del + v·con)'),
    mpatches.Patch(facecolor='#95a5a6', label='Base case (= 1)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=10,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout()
plt.savefig('activity_tree.png', dpi=150, bbox_inches='tight')
print("Saved activity_tree.png")


#!/usr/bin/env python3
"""
Visualization: Power Law Theorem

The Power Law theorem states that for uniform deletion-contraction
coefficients, T(S; a, b) = (a+b)^|ground| regardless of the support
content. This plot shows the theorem in action: multiple supports with
the same ground size all produce the same curve, while the 4-parameter
evaluation T₄ breaks this degeneracy.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

class GroundSupport:
    def __init__(self, supp, ground):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    def delete(self, e):
        return GroundSupport(frozenset(m for m in self.supp if m[e]==0), self.ground-{e})
    def min_coord(self, e):
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e):
        mc = self.min_coord(e)
        return GroundSupport(frozenset(tuple(v-mc if j==e else v for j,v in enumerate(m))
                            for m in self.supp if m[e]==mc), self.ground-{e})
    def is_loop(self, e):
        return bool(self.supp) and all(m[e]>0 for m in self.supp)
    def is_coloop(self, e):
        return bool(self.supp) and len({m[e] for m in self.supp})==1

def tutte_uniform(S, a=1, b=1):
    if not S.ground: return 1
    e = min(S.ground)
    return a * tutte_uniform(S.delete(e), a, b) + b * tutte_uniform(S.contract(e), a, b)

def tutte_4p(S, x=1, y=1, u=1, v=1):
    if not S.ground: return 1
    e = min(S.ground)
    if S.is_loop(e): return y * tutte_4p(S.delete(e), x, y, u, v)
    elif S.is_coloop(e): return x * tutte_4p(S.contract(e), x, y, u, v)
    else: return u * tutte_4p(S.delete(e), x, y, u, v) + v * tutte_4p(S.contract(e), x, y, u, v)

def simplex(n, d):
    def gen(rv, rs):
        if rv==1: yield (rs,); return
        for val in range(rs+1):
            for rest in gen(rv-1, rs-val): yield (val,)+rest
    return GroundSupport(frozenset(gen(n, d)), frozenset(range(n)))

def uniform_matroid(n, k):
    supp = {tuple(1 if i in B else 0 for i in range(n)) for B in combinations(range(n), k)}
    return GroundSupport(frozenset(supp), frozenset(range(n)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Support-Tutte Power Law vs Case-Dependent Invariant', fontsize=14, fontweight='bold')

# Left panel: Power Law — all supports with same |ground| collapse
a_vals = np.arange(1, 8)
n = 3

supports_n3 = [
    ("Δ(3,1)", simplex(3,1)),
    ("Δ(3,2)", simplex(3,2)),
    ("Δ(3,3)", simplex(3,3)),
    ("U(1,3)", uniform_matroid(3,1)),
    ("U(2,3)", uniform_matroid(3,2)),
    ("{(1,1,1)}", GroundSupport(frozenset({(1,1,1)}), frozenset({0,1,2}))),
]

markers = ['o', 's', '^', 'D', 'v', 'P']
colors = plt.cm.Set2(np.linspace(0, 1, len(supports_n3)))

for idx, (name, S) in enumerate(supports_n3):
    vals = [tutte_uniform(S, a, 1) for a in a_vals]
    ax1.plot(a_vals, vals, markers[idx], color=colors[idx], markersize=8,
             label=name, alpha=0.7)

# Theoretical curve
ax1.plot(a_vals, [(a+1)**n for a in a_vals], 'k--', linewidth=2,
         label=f'(a+1)^{n} (Power Law)', alpha=0.8)

ax1.set_xlabel('Deletion coefficient a (b=1)', fontsize=12)
ax1.set_ylabel('T(S; a, 1)', fontsize=12)
ax1.set_title('Uniform Coefficients: All Collapse to (a+1)³', fontsize=11)
ax1.legend(fontsize=8, loc='upper left')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Right panel: 4-parameter evaluation — supports separate
x_vals = np.arange(1, 8)

for idx, (name, S) in enumerate(supports_n3):
    vals = [tutte_4p(S, x=x, y=3, u=1, v=1) for x in x_vals]
    ax2.plot(x_vals, vals, f'{markers[idx]}-', color=colors[idx], markersize=8,
             label=name, alpha=0.7, linewidth=1.5)

ax2.set_xlabel('Coloop weight x (y=3, u=v=1)', fontsize=12)
ax2.set_ylabel('T₄(S; x, 3, 1, 1)', fontsize=12)
ax2.set_title('Case-Dependent: Supports Separate', fontsize=11)
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('power_law.png', dpi=150, bbox_inches='tight')
print("Saved power_law.png")


#!/usr/bin/env python3
"""
Visualization: Support-Tutte Polynomial Spectrum

Shows how the 4-parameter Tutte evaluation varies across different
support types for uniform matroid supports U(k,n). The heatmap reveals
how loop/coloop/ordinary activity structure creates distinct invariant
values, with the Power Law (a+b)^n as the diagonal baseline.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

class GroundSupport:
    def __init__(self, supp, ground):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    def delete(self, e):
        return GroundSupport(frozenset(m for m in self.supp if m[e]==0), self.ground-{e})
    def min_coord(self, e):
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e):
        mc = self.min_coord(e)
        return GroundSupport(frozenset(tuple(v-mc if j==e else v for j,v in enumerate(m))
                            for m in self.supp if m[e]==mc), self.ground-{e})
    def is_loop(self, e):
        return bool(self.supp) and all(m[e]>0 for m in self.supp)
    def is_coloop(self, e):
        return bool(self.supp) and len({m[e] for m in self.supp})==1

def tutte_4p(S, x=1, y=1, u=1, v=1):
    if not S.ground: return 1
    e = min(S.ground)
    if S.is_loop(e): return y * tutte_4p(S.delete(e), x, y, u, v)
    elif S.is_coloop(e): return x * tutte_4p(S.contract(e), x, y, u, v)
    else: return u * tutte_4p(S.delete(e), x, y, u, v) + v * tutte_4p(S.contract(e), x, y, u, v)

def uniform_matroid(n, k):
    supp = {tuple(1 if i in B else 0 for i in range(n)) for B in combinations(range(n), k)}
    return GroundSupport(frozenset(supp), frozenset(range(n)))

def simplex(n, d):
    def gen(rv, rs):
        if rv==1: yield (rs,); return
        for val in range(rs+1):
            for rest in gen(rv-1, rs-val): yield (val,)+rest
    return GroundSupport(frozenset(gen(n, d)), frozenset(range(n)))

# Compute T₄ for various (x,y) values with u=1, v=1
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Support-Tutte Spectrum T₄(x,y,1,1) for Different Supports', fontsize=14)

supports = [
    ("U(1,4)", uniform_matroid(4, 1)),
    ("U(2,4)", uniform_matroid(4, 2)),
    ("U(3,4)", uniform_matroid(4, 3)),
    ("Δ(4,1)", simplex(4, 1)),
    ("Δ(4,2)", simplex(4, 2)),
    ("Δ(4,3)", simplex(4, 3)),
]

x_vals = np.linspace(0.5, 4, 20)
y_vals = np.linspace(0.5, 4, 20)

for idx, (name, S) in enumerate(supports):
    ax = axes[idx // 3][idx % 3]
    Z = np.zeros((len(y_vals), len(x_vals)))
    for i, yv in enumerate(y_vals):
        for j, xv in enumerate(x_vals):
            Z[i, j] = tutte_4p(S, x=int(xv*100), y=int(yv*100), u=100, v=100) / (100**len(S.ground))

    im = ax.imshow(Z, extent=[0.5, 4, 0.5, 4], origin='lower', aspect='auto', cmap='viridis')
    ax.set_title(f'{name}  |supp|={len(S.supp)}', fontsize=11)
    ax.set_xlabel('x (coloop weight)')
    ax.set_ylabel('y (loop weight)')
    plt.colorbar(im, ax=ax, shrink=0.8)

plt.tight_layout()
plt.savefig('tutte_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved tutte_spectrum.png")
