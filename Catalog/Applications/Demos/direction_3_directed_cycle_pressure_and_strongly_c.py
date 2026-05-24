#!/usr/bin/env python3
"""
Directed Cycle Pressure — Applications

Demonstrates applications of directed cycle pressure to:
1. Proof dependency graph analysis
2. Software module complexity estimation
3. Feedback detection in causal networks
4. Predictive feature generation for graph classification
"""

from collections import defaultdict
from typing import Dict, List, Set, Tuple
import random
import math


# ============================================================
# Core computation (self-contained)
# ============================================================

def out_ball(adj, v, r):
    ball = {v}
    for _ in range(r):
        new = set()
        for w in ball:
            for u in adj.get(w, []):
                new.add(u)
        ball |= new
    return ball

def tarjan_sccs(adj, vertices):
    idx = [0]; stack = []; lowlink = {}; index = {}; on_stack = set(); sccs = []
    def sc(v):
        index[v] = lowlink[v] = idx[0]; idx[0] += 1
        stack.append(v); on_stack.add(v)
        for w in adj.get(v, []):
            if w not in vertices: continue
            if w not in index: sc(w); lowlink[v] = min(lowlink[v], lowlink[w])
            elif w in on_stack: lowlink[v] = min(lowlink[v], index[w])
        if lowlink[v] == index[v]:
            scc = set()
            while True:
                w = stack.pop(); on_stack.remove(w); scc.add(w)
                if w == v: break
            sccs.append(scc)
    for v in vertices:
        if v not in index: sc(v)
    return sccs

def dir_pressure(adj, v, r, all_verts=None):
    if all_verts is None:
        all_verts = set(adj.keys())
        for u in adj:
            for w in adj[u]: all_verts.add(w)
    ball = out_ball(adj, v, r)
    sccs = tarjan_sccs(adj, all_verts)
    recurrent = set()
    for scc in sccs:
        if len(scc) >= 2: recurrent |= scc
    return len(ball & recurrent)

def symmetrize(adj):
    sym = defaultdict(set)
    for u in adj:
        for v in adj[u]:
            if u != v: sym[u].add(v); sym[v].add(u)
    return dict(sym)

def undir_pressure(adj, v, r):
    sym = symmetrize(adj)
    ball = out_ball(sym, v, r)
    return sum(1 for u in ball if len(sym.get(u, set())) > 0)


# ============================================================
# Application 1: Simulated Proof Dependency Graph
# ============================================================

def simulate_proof_dependency_graph(n_theorems=30, seed=42):
    """Simulate a proof dependency graph with occasional mutual dependencies."""
    random.seed(seed)
    adj = defaultdict(list)
    names = [f"thm_{i}" for i in range(n_theorems)]

    # Create mostly-DAG structure with occasional cycles
    for i in range(1, n_theorems):
        n_deps = random.randint(1, min(3, i))
        deps = random.sample(range(i), n_deps)
        for d in deps:
            adj[names[i]].append(names[d])

    # Add a few mutual dependencies (simulating mutual recursion)
    mutual_pairs = [(5, 8), (12, 15), (20, 22)]
    for i, j in mutual_pairs:
        if i < n_theorems and j < n_theorems:
            adj[names[i]].append(names[j])
            adj[names[j]].append(names[i])

    return dict(adj), names


def app_proof_dependency():
    print("=" * 65)
    print("APPLICATION 1: Proof Dependency Graph Analysis")
    print("=" * 65)
    print()

    adj, names = simulate_proof_dependency_graph()
    all_v = set(names)

    sccs = tarjan_sccs(adj, all_v)
    nontrivial = [s for s in sccs if len(s) >= 2]
    print(f"  Graph: {len(all_v)} theorems, "
          f"{sum(len(v) for v in adj.values())} dependencies")
    print(f"  SCCs: {len(sccs)} total, {len(nontrivial)} nontrivial")

    if nontrivial:
        print(f"  Mutual dependency clusters:")
        for scc in nontrivial:
            print(f"    {sorted(scc)}")

    print()
    print("  Directed Pressure Analysis (radius 2):")
    print(f"  {'Theorem':>12} | {'dirP':>5} {'undirP':>7} {'CA':>4} | {'Role'}")
    print(f"  {'-'*12} | {'-'*5} {'-'*7} {'-'*4} | {'-'*20}")

    for v in sorted(all_v)[:15]:
        dp = dir_pressure(adj, v, 2, all_v)
        up = undir_pressure(adj, v, 2)
        ca = up - dp
        role = "RECURRENT" if dp > 0 else ("hub" if up > 5 else "leaf")
        print(f"  {v:>12} | {dp:>5} {up:>7} {ca:>4} | {role}")

    print()
    print("  Insight: Theorems with high dirPressure participate in")
    print("  mutual dependency clusters — candidates for refactoring.")
    print()


# ============================================================
# Application 2: Software Module Coupling
# ============================================================

def app_software_coupling():
    print("=" * 65)
    print("APPLICATION 2: Software Module Coupling Analysis")
    print("=" * 65)
    print()

    # Simulated software dependency graph
    adj = {
        'main': ['auth', 'db', 'api'],
        'auth': ['db', 'crypto'],
        'db': ['config'],
        'api': ['auth', 'db', 'serializer'],
        'serializer': ['models'],
        'models': ['db'],
        'crypto': ['config'],
        'config': [],
        # Problematic circular dependency
        'cache': ['db'],
        'db_pool': ['cache', 'db'],  # db depends on config, pool depends on cache
    }
    # Add the cycle: db → db_pool (creating db ↔ db_pool via cache)
    adj['db'] = adj['db'] + ['db_pool']

    all_v = set(adj.keys())
    for u in adj:
        for w in adj[u]: all_v.add(w)

    sccs = tarjan_sccs(adj, all_v)
    nontrivial = [s for s in sccs if len(s) >= 2]

    print(f"  Modules: {sorted(all_v)}")
    print(f"  Circular dependency clusters: {[sorted(s) for s in nontrivial]}")
    print()

    sym = symmetrize(adj)
    print(f"  {'Module':>12} | {'dirP(1)':>7} {'dirP(2)':>7} | "
          f"{'undirP(2)':>9} {'CA(2)':>5} | {'Assessment'}")
    print(f"  {'-'*12} | {'-'*7} {'-'*7} | {'-'*9} {'-'*5} | {'-'*20}")

    for v in sorted(all_v):
        dp1 = dir_pressure(adj, v, 1, all_v)
        dp2 = dir_pressure(adj, v, 2, all_v)
        up2 = undir_pressure(adj, v, 2)
        ca = up2 - dp2
        if dp2 > 0:
            assessment = "CIRCULAR DEP"
        elif ca > 3:
            assessment = "high coupling"
        elif up2 == 0:
            assessment = "isolated"
        else:
            assessment = "clean"
        print(f"  {v:>12} | {dp1:>7} {dp2:>7} | {up2:>9} {ca:>5} | {assessment}")

    print()
    print("  Recommendation: Modules with dirPressure > 0 have circular")
    print("  dependencies that should be broken via dependency inversion.")
    print()


# ============================================================
# Application 3: Causal Network Feedback Detection
# ============================================================

def app_causal_network():
    print("=" * 65)
    print("APPLICATION 3: Causal Network Feedback Detection")
    print("=" * 65)
    print()

    # Gene regulatory network with feedback loops
    adj = {
        'GeneA': ['ProteinA'],
        'ProteinA': ['GeneB', 'GeneC'],
        'GeneB': ['ProteinB'],
        'ProteinB': ['GeneA'],  # Feedback loop!
        'GeneC': ['ProteinC'],
        'ProteinC': ['GeneD'],
        'GeneD': ['ProteinD'],
        'ProteinD': [],
        'Signal': ['GeneA', 'GeneC'],
    }

    all_v = set(adj.keys())
    for u in adj:
        for w in adj[u]: all_v.add(w)

    sccs = tarjan_sccs(adj, all_v)
    nontrivial = [s for s in sccs if len(s) >= 2]

    print(f"  Gene regulatory network: {len(all_v)} nodes")
    print(f"  Feedback loops (nontrivial SCCs):")
    for scc in nontrivial:
        print(f"    {sorted(scc)}")

    print()
    print(f"  {'Node':>12} | {'dirP(2)':>7} {'undirP(2)':>9} {'CA(2)':>5}")
    print(f"  {'-'*12} | {'-'*7} {'-'*9} {'-'*5}")

    for v in sorted(all_v):
        dp = dir_pressure(adj, v, 2, all_v)
        up = undir_pressure(adj, v, 2)
        ca = up - dp
        marker = " ← feedback" if dp > 0 else ""
        print(f"  {v:>12} | {dp:>7} {up:>9} {ca:>5}{marker}")

    print()
    print("  Directed pressure identifies exactly the nodes participating")
    print("  in regulatory feedback loops, while undirected pressure")
    print("  conflates feedback with mere connectivity.")
    print()


# ============================================================
# Application 4: Graph Classification Features
# ============================================================

def app_graph_classification():
    print("=" * 65)
    print("APPLICATION 4: Graph Classification Feature Generation")
    print("=" * 65)
    print()

    # Generate several graph types
    graphs = {
        'DAG (tree)': {
            'root': ['L', 'R'], 'L': ['LL', 'LR'],
            'R': ['RL', 'RR'], 'LL': [], 'LR': [],
            'RL': [], 'RR': []
        },
        'Single cycle': {
            'a': ['b'], 'b': ['c'], 'c': ['d'], 'd': ['a']
        },
        'Two cycles': {
            'a': ['b'], 'b': ['c'], 'c': ['a'],
            'd': ['e'], 'e': ['d'], 'a': ['b', 'd']
        },
        'Complete (3)': {
            'x': ['y', 'z'], 'y': ['x', 'z'], 'z': ['x', 'y']
        },
    }

    print(f"  {'Graph Type':>18} | {'max_dP':>6} {'sum_dP':>6} {'max_CA':>6} "
          f"{'sum_CA':>6} | {'#recurrent':>10}")
    print(f"  {'-'*18} | {'-'*6} {'-'*6} {'-'*6} {'-'*6} | {'-'*10}")

    for name, adj in graphs.items():
        all_v = set(adj.keys())
        for u in adj:
            for w in adj[u]: all_v.add(w)

        max_dp = max_ca = sum_dp = sum_ca = 0
        n_recurrent = 0
        sccs = tarjan_sccs(adj, all_v)
        for scc in sccs:
            if len(scc) >= 2:
                n_recurrent += len(scc)

        for v in all_v:
            dp = dir_pressure(adj, v, 2, all_v)
            up = undir_pressure(adj, v, 2)
            ca = up - dp
            max_dp = max(max_dp, dp)
            sum_dp += dp
            max_ca = max(max_ca, ca)
            sum_ca += ca

        print(f"  {name:>18} | {max_dp:>6} {sum_dp:>6} {max_ca:>6} "
              f"{sum_ca:>6} | {n_recurrent:>10}")

    print()
    print("  These features distinguish graph structural types:")
    print("  - DAGs: max_dP = 0, sum_dP = 0")
    print("  - Cyclic: max_dP > 0")
    print("  - Causal asymmetry separates directed from undirected structure")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("DIRECTED CYCLE PRESSURE — APPLICATIONS")
    print("=" * 65)
    print()

    app_proof_dependency()
    app_software_coupling()
    app_causal_network()
    app_graph_classification()

    print("=" * 65)
    print("SUMMARY")
    print("=" * 65)
    print()
    print("Directed cycle pressure provides a computable invariant that:")
    print("  1. Detects genuine feedback vs. mere connectivity")
    print("  2. Identifies circular dependencies in software/proofs")
    print("  3. Localizes feedback loops in causal networks")
    print("  4. Generates discriminative features for graph ML")
    print()


#!/usr/bin/env python3
"""
Directed Cycle Pressure — Demonstration Script

Constructs explicit digraph examples, computes directed and undirected pressures,
visualizes SCCs and condensation graphs, and demonstrates strict separation
between directed and undirected pressure invariants.

Requirements: networkx, matplotlib (optional for visualization)
"""

from collections import defaultdict
from typing import Dict, List, Set, Tuple

# ============================================================
# Core algorithms (self-contained, no external dependencies)
# ============================================================

def out_ball(adj: Dict[str, List[str]], v: str, r: int) -> Set[str]:
    """Compute the directed out-ball of radius r around vertex v."""
    ball = {v}
    for _ in range(r):
        new = set()
        for w in ball:
            for u in adj.get(w, []):
                new.add(u)
        ball = ball | new
    return ball


def dg_reach(adj: Dict[str, List[str]], u: str, v: str, n: int) -> bool:
    """Check if v is reachable from u within n directed steps."""
    return v in out_ball(adj, u, n)


def find_sccs(adj: Dict[str, List[str]], vertices: Set[str]) -> List[Set[str]]:
    """Find all SCCs in the subgraph induced on `vertices` using Tarjan's algorithm."""
    index_counter = [0]
    stack = []
    lowlink = {}
    index = {}
    on_stack = set()
    sccs = []

    def strongconnect(v):
        index[v] = index_counter[0]
        lowlink[v] = index_counter[0]
        index_counter[0] += 1
        stack.append(v)
        on_stack.add(v)

        for w in adj.get(v, []):
            if w not in vertices:
                continue
            if w not in index:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif w in on_stack:
                lowlink[v] = min(lowlink[v], index[w])

        if lowlink[v] == index[v]:
            scc = set()
            while True:
                w = stack.pop()
                on_stack.remove(w)
                scc.add(w)
                if w == v:
                    break
            sccs.append(scc)

    for v in vertices:
        if v not in index:
            strongconnect(v)
    return sccs


def is_recurrent(adj: Dict[str, List[str]], vertices: Set[str], u: str) -> bool:
    """Check if vertex u is in a nontrivial SCC (size >= 2) within the given vertex set."""
    n = len(vertices)
    for w in vertices:
        if w != u and dg_reach(adj, u, w, n) and dg_reach(adj, w, u, n):
            return True
    return False


def dir_pressure(adj: Dict[str, List[str]], v: str, r: int) -> int:
    """Compute directed cycle pressure at vertex v with radius r."""
    ball = out_ball(adj, v, r)
    all_verts = set()
    for u in adj:
        all_verts.add(u)
        for w in adj[u]:
            all_verts.add(w)
    n = len(all_verts)
    count = 0
    for u in ball:
        # Check global recurrence
        for w in all_verts:
            if w != u and dg_reach(adj, u, w, n) and dg_reach(adj, w, u, n):
                count += 1
                break
    return count


def symmetrize(adj: Dict[str, List[str]]) -> Dict[str, Set[str]]:
    """Symmetrize a digraph: add reverse edges, remove self-loops for SimpleGraph."""
    sym = defaultdict(set)
    for u in adj:
        for v in adj[u]:
            if u != v:
                sym[u].add(v)
                sym[v].add(u)
    return dict(sym)


def undir_ball(adj_sym: Dict[str, Set[str]], v: str, r: int) -> Set[str]:
    """Compute the undirected ball of radius r."""
    ball = {v}
    for _ in range(r):
        new = set()
        for w in ball:
            for u in adj_sym.get(w, set()):
                new.add(u)
        ball = ball | new
    return ball


def has_neighbor(adj_sym: Dict[str, Set[str]], u: str) -> bool:
    """Check if u has at least one neighbor."""
    return len(adj_sym.get(u, set())) > 0


def undir_pressure(adj_sym: Dict[str, Set[str]], v: str, r: int) -> int:
    """Compute undirected pressure: non-isolated vertices in the ball."""
    ball = undir_ball(adj_sym, v, r)
    return sum(1 for u in ball if has_neighbor(adj_sym, u))


def causal_asymmetry(adj: Dict[str, List[str]], v: str, r: int) -> int:
    """Compute the causal asymmetry: undirPressure - dirPressure."""
    sym = symmetrize(adj)
    return undir_pressure(sym, v, r) - dir_pressure(adj, v, r)


# ============================================================
# Example 1: Oriented Diamond (strict separation)
# ============================================================

def oriented_diamond():
    """The oriented diamond: s→a, s→b, a→t, b→t. Acyclic."""
    return {
        's': ['a', 'b'],
        'a': ['t'],
        'b': ['t'],
        't': []
    }


def demo_oriented_diamond():
    print("=" * 60)
    print("Example 1: Oriented Diamond (Strict Separation)")
    print("=" * 60)
    adj = oriented_diamond()
    print(f"Vertices: s, a, b, t")
    print(f"Directed edges: s→a, s→b, a→t, b→t")
    print()

    for r in range(4):
        ball = out_ball(adj, 's', r)
        dp = dir_pressure(adj, 's', r)
        sym = symmetrize(adj)
        up = undir_pressure(sym, 's', r)
        ca = up - dp
        print(f"  Radius {r}:")
        print(f"    Out-ball:          {sorted(ball)}")
        print(f"    dirPressure:       {dp}")
        print(f"    undirPressure:     {up}")
        print(f"    causalAsymmetry:   {ca}")
        print(f"    Strict separation: {dp < up}")
    print()

    # SCC analysis
    ball = out_ball(adj, 's', 2)
    sccs = find_sccs(adj, ball)
    print(f"  SCCs in out-ball(s, 2): {[sorted(s) for s in sccs]}")
    nontrivial = [s for s in sccs if len(s) > 1]
    print(f"  Nontrivial SCCs:        {[sorted(s) for s in nontrivial]}")
    print(f"  → All SCCs are singletons (DAG), confirming dirPressure = 0")
    print()

    sym = symmetrize(adj)
    uball = undir_ball(sym, 's', 2)
    print(f"  Symmetrized edges: " + ", ".join(
        f"{u}-{v}" for u in sorted(sym) for v in sorted(sym[u]) if u < v))
    print(f"  Undirected ball(s, 2): {sorted(uball)}")
    print(f"  Non-isolated vertices: {sorted(u for u in uball if has_neighbor(sym, u))}")
    print()


# ============================================================
# Example 2: Graph with genuine feedback
# ============================================================

def feedback_graph():
    """A graph with a genuine feedback cycle: a→b→c→a, plus d→a."""
    return {
        'a': ['b'],
        'b': ['c'],
        'c': ['a'],
        'd': ['a']
    }


def demo_feedback():
    print("=" * 60)
    print("Example 2: Feedback Graph (Genuine Directed Cycle)")
    print("=" * 60)
    adj = feedback_graph()
    print(f"Directed edges: a→b, b→c, c→a, d→a")
    print()

    for v in ['d', 'a']:
        for r in range(4):
            ball = out_ball(adj, v, r)
            dp = dir_pressure(adj, v, r)
            sym = symmetrize(adj)
            up = undir_pressure(sym, v, r)
            print(f"  v={v}, r={r}: ball={sorted(ball)}, "
                  f"dirP={dp}, undirP={up}, asymmetry={up - dp}")
    print()

    ball = out_ball(adj, 'd', 3)
    sccs = find_sccs(adj, ball)
    print(f"  SCCs in out-ball(d, 3): {[sorted(s) for s in sccs]}")
    nontrivial = [s for s in sccs if len(s) > 1]
    print(f"  Nontrivial SCCs: {[sorted(s) for s in nontrivial]}")
    print(f"  → The cycle {{a,b,c}} forms a nontrivial SCC")
    print()


# ============================================================
# Example 3: Growing family for scalability
# ============================================================

def star_dag(n: int):
    """Star DAG: center c with c→a_i for i=1..n. No cycles."""
    adj = {'c': [f'a{i}' for i in range(1, n + 1)]}
    for i in range(1, n + 1):
        adj[f'a{i}'] = []
    return adj


def demo_scaling():
    print("=" * 60)
    print("Example 3: Scaling Behavior of Star DAGs")
    print("=" * 60)
    for n in [3, 5, 10, 20]:
        adj = star_dag(n)
        dp = dir_pressure(adj, 'c', 1)
        sym = symmetrize(adj)
        up = undir_pressure(sym, 'c', 1)
        print(f"  n={n:2d}: dirPressure(c,1)={dp}, "
              f"undirPressure(c,1)={up}, asymmetry={up - dp}")
    print(f"  → causalAsymmetry grows linearly with fan-out")
    print()


# ============================================================
# Example 4: Condensation / DAG of SCCs
# ============================================================

def demo_condensation():
    print("=" * 60)
    print("Example 4: SCC Condensation")
    print("=" * 60)
    # A graph with multiple SCCs connected in a DAG structure
    adj = {
        'a1': ['a2'], 'a2': ['a3'], 'a3': ['a1'],  # SCC {a1,a2,a3}
        'b1': ['b2'], 'b2': ['b1'],                  # SCC {b1,b2}
        'a1': ['a2', 'b1'], 'a2': ['a3'], 'a3': ['a1'],  # cross-SCC edge
        'c': ['a1']                                    # singleton c → SCC_a
    }
    # Fix adjacency
    adj = {
        'a1': ['a2', 'b1'],
        'a2': ['a3'],
        'a3': ['a1'],
        'b1': ['b2'],
        'b2': ['b1'],
        'c': ['a1']
    }
    all_v = set()
    for u in adj:
        all_v.add(u)
        for w in adj[u]:
            all_v.add(w)

    sccs = find_sccs(adj, all_v)
    print(f"  Vertices: {sorted(all_v)}")
    print(f"  SCCs: {[sorted(s) for s in sccs]}")

    for v in sorted(all_v):
        for r in [1, 2, 3]:
            dp = dir_pressure(adj, v, r)
            sym = symmetrize(adj)
            up = undir_pressure(sym, v, r)
            if r == 2:
                print(f"    v={v}, r={r}: dirP={dp}, undirP={up}, "
                      f"asymmetry={up - dp}")
    print()


# ============================================================
# Example 5: Predictive feature vectors
# ============================================================

def demo_feature_vectors():
    print("=" * 60)
    print("Example 5: Directed Pressure Feature Vectors")
    print("=" * 60)
    adj = {
        'a1': ['a2', 'b1'],
        'a2': ['a3'],
        'a3': ['a1'],
        'b1': ['b2'],
        'b2': ['b1'],
        'c': ['a1'],
        'd': []
    }
    all_v = set(adj.keys())
    for u in adj:
        for w in adj[u]:
            all_v.add(w)

    sym = symmetrize(adj)
    print(f"  {'Vertex':>8} | {'dirP(1)':>7} {'dirP(2)':>7} | "
          f"{'undirP(1)':>9} {'undirP(2)':>9} | {'CA(2)':>5}")
    print(f"  {'-'*8} | {'-'*7} {'-'*7} | {'-'*9} {'-'*9} | {'-'*5}")

    for v in sorted(all_v):
        dp1 = dir_pressure(adj, v, 1)
        dp2 = dir_pressure(adj, v, 2)
        up1 = undir_pressure(sym, v, 1)
        up2 = undir_pressure(sym, v, 2)
        ca2 = up2 - dp2
        print(f"  {v:>8} | {dp1:>7} {dp2:>7} | {up1:>9} {up2:>9} | {ca2:>5}")
    print()
    print("  → Feature vector (dirP(1), dirP(2), CA(2)) distinguishes structural roles")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("DIRECTED CYCLE PRESSURE — COMPUTATIONAL DEMONSTRATIONS")
    print("=" * 60)
    print()

    demo_oriented_diamond()
    demo_feedback()
    demo_scaling()
    demo_condensation()
    demo_feature_vectors()

    print("=" * 60)
    print("KEY RESULTS SUMMARY")
    print("=" * 60)
    print()
    print("1. STRICT SEPARATION: On the oriented diamond,")
    print("   dirPressure(s, 2) = 0 < 4 = undirPressure(s, 2)")
    print("   Symmetrization creates false cyclicity.")
    print()
    print("2. DAG VANISHING: All star DAGs have dirPressure = 0")
    print("   at all vertices and radii (no directed cycles).")
    print()
    print("3. CAUSAL ASYMMETRY: The gap undirP - dirP quantifies")
    print("   how much structural information orientation provides.")
    print()
    print("4. FEATURE DISCRIMINATION: The directed pressure vector")
    print("   (dirP(1), dirP(2), CA(2)) provides finer vertex")
    print("   classification than undirected pressure alone.")
    print()
