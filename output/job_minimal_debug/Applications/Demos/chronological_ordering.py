#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Chronological Ordering

Demonstrates how the tropical chronological ordering theorem applies to:
1. Distributed systems causality (Lamport-style)
2. Project scheduling (PERT/CPM critical paths)
3. Gene regulatory network hierarchy
4. Network security influence analysis
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional

INF = float('inf')


def floyd_warshall(n: int, edges: List[Tuple[int, int, float]]) -> np.ndarray:
    """All-pairs shortest paths."""
    d = np.full((n, n), INF)
    for i in range(n):
        d[i, i] = 0.0
    for u, v, w in edges:
        d[u, v] = min(d[u, v], w)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    return d


def chrono_relation(d: np.ndarray, tol=1e-12) -> Set[Tuple[int, int]]:
    n = d.shape[0]
    return {(i, j) for i in range(n) for j in range(n)
            if d[i, j] != INF and abs(d[i, j]) < tol}


def covers(rel: Set[Tuple[int, int]], n: int) -> Set[Tuple[int, int]]:
    result = set()
    for i, j in rel:
        if i == j:
            continue
        is_cover = not any(
            k != i and k != j and (i, k) in rel and (k, j) in rel
            for k in range(n)
        )
        if is_cover:
            result.add((i, j))
    return result


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Distributed Systems — Lamport Causality
# ═══════════════════════════════════════════════════════════════════════

def app_distributed_systems():
    """
    In a distributed system, processes communicate via messages.
    Each message has a propagation delay (edge weight).
    The chronological order captures "instantaneous influence":
    event A can influence event B at zero cost iff d(A, B) = 0.

    The theorem guarantees this is a partial order when there are
    no zero-delay feedback loops (a natural physical assumption).
    """
    print("=" * 60)
    print("APPLICATION 1: Distributed Systems Causality")
    print("=" * 60)
    print()

    # Model: 3 processes, each with local events
    # Process 1: events 0, 1
    # Process 2: events 2, 3
    # Process 3: events 4, 5
    labels = ["P1:init", "P1:compute", "P2:init", "P2:recv",
              "P3:init", "P3:aggregate"]
    n = 6
    edges = [
        # Local transitions (zero delay — same process)
        (0, 1, 0),   # P1:init → P1:compute (instant)
        (2, 3, 0),   # P2:init → P2:recv (instant)
        (4, 5, 0),   # P3:init → P3:aggregate (instant)
        # Network messages (positive delay)
        (1, 3, 5),   # P1:compute → P2:recv (5ms network delay)
        (3, 5, 3),   # P2:recv → P3:aggregate (3ms delay)
        (1, 5, 10),  # P1:compute → P3:aggregate (10ms direct)
    ]

    d = floyd_warshall(n, edges)
    rel = chrono_relation(d)
    covs = covers(rel, n)

    print("Scenario: 3 processes communicate with message delays.")
    print("Local transitions within a process are instantaneous (weight 0).")
    print("Network messages have positive delay.")
    print()
    print("Chronological order (instantaneous influence):")
    for i, j in sorted(rel):
        if i != j:
            print(f"  {labels[i]} ≼ {labels[j]}")
    print()
    print("Interpretation: Events connected by zero-delay chains are")
    print("'causally simultaneous' — one can influence the other instantly.")
    print("The partial order guarantees no circular instantaneous influence.")
    print()

    # Verify antisymmetry
    antisym = True
    for i in range(n):
        for j in range(i+1, n):
            if (i, j) in rel and (j, i) in rel:
                antisym = False
    print(f"Antisymmetric (no zero-delay cycles)? {antisym}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Project Scheduling (PERT/CPM)
# ═══════════════════════════════════════════════════════════════════════

def app_project_scheduling():
    """
    In PERT/CPM, activities have durations.
    Some activities can start instantly after a predecessor (zero slack).
    The chronological order identifies which activities are
    "critically linked" — zero slack between them.
    """
    print("=" * 60)
    print("APPLICATION 2: Project Scheduling (PERT/CPM)")
    print("=" * 60)
    print()

    labels = ["Design", "Prototype", "Testing", "Documentation",
              "Review", "Release"]
    n = 6
    edges = [
        (0, 1, 0),   # Design → Prototype (immediate successor)
        (0, 3, 0),   # Design → Documentation (starts with design)
        (1, 2, 2),   # Prototype → Testing (2 day delay)
        (3, 4, 1),   # Documentation → Review (1 day delay)
        (2, 5, 0),   # Testing → Release (immediate)
        (4, 5, 0),   # Review → Release (immediate)
    ]

    d = floyd_warshall(n, edges)
    rel = chrono_relation(d)
    covs = covers(rel, n)

    print("Project schedule with instant and delayed dependencies.")
    print()
    print("Critical links (zero-delay dependencies):")
    for i, j in sorted(covs):
        print(f"  {labels[i]} → {labels[j]} (immediate)")
    print()
    print("Full chronological order (zero-slack chains):")
    for i, j in sorted(rel):
        if i != j:
            print(f"  {labels[i]} ≼ {labels[j]}")
    print()
    print("Meaning: If any activity in a zero-slack chain is delayed,")
    print("the delay propagates INSTANTLY to all successors in the chain.")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Gene Regulatory Network Hierarchy
# ═══════════════════════════════════════════════════════════════════════

def app_gene_regulation():
    """
    Gene regulatory networks: edges represent regulatory influence.
    Weight = activation cost/delay.
    Zero-weight edges = constitutive (always-on) regulation.
    The chronological order gives the hierarchy of constitutive control.
    """
    print("=" * 60)
    print("APPLICATION 3: Gene Regulatory Network")
    print("=" * 60)
    print()

    labels = ["MasterTF", "TF_A", "TF_B", "Gene1", "Gene2",
              "Gene3", "Effector"]
    n = 7
    edges = [
        # Master transcription factor controls subordinate TFs
        (0, 1, 0),   # MasterTF → TF_A (constitutive)
        (0, 2, 0),   # MasterTF → TF_B (constitutive)
        # TFs control genes with varying activation costs
        (1, 3, 0),   # TF_A → Gene1 (constitutive)
        (1, 4, 2),   # TF_A → Gene2 (needs inducer, cost 2)
        (2, 4, 0),   # TF_B → Gene2 (constitutive via TF_B)
        (2, 5, 1),   # TF_B → Gene3 (partial cost)
        # Genes produce effector
        (3, 6, 0),   # Gene1 → Effector (direct)
        (5, 6, 3),   # Gene3 → Effector (indirect, cost 3)
    ]

    d = floyd_warshall(n, edges)
    rel = chrono_relation(d)

    print("Gene regulatory network with constitutive (free) and")
    print("inducible (costly) regulatory interactions.")
    print()
    print("Constitutive control hierarchy (chronological order):")
    for i, j in sorted(rel):
        if i != j:
            print(f"  {labels[i]} ≼ {labels[j]} (d = {d[i,j]:.0f})")
    print()
    print("Interpretation: The constitutive hierarchy shows which")
    print("genes are always under the control of which regulators,")
    print("without needing any inducing signal.")
    print()

    # Check for feedback
    antisym = all(
        not ((i, j) in rel and (j, i) in rel)
        for i in range(n) for j in range(i+1, n)
    )
    print(f"No constitutive feedback loops? {antisym}")
    print("(Guaranteed by theorem since no zero-weight directed cycles)")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Network Security — Influence Propagation
# ═══════════════════════════════════════════════════════════════════════

def app_network_security():
    """
    In a network, edge weights represent the cost of compromising
    a connection. Zero-weight edges = already compromised or free.
    The chronological order shows which nodes can be reached at zero cost
    from a compromised node — the "blast radius" of a breach.
    """
    print("=" * 60)
    print("APPLICATION 4: Network Security — Blast Radius Analysis")
    print("=" * 60)
    print()

    labels = ["Internet", "DMZ", "WebServer", "AppServer",
              "Database", "AdminPanel", "InternalNet"]
    n = 7
    edges = [
        (0, 1, 0),   # Internet → DMZ (no firewall)
        (1, 2, 0),   # DMZ → WebServer (same zone)
        (2, 3, 1),   # WebServer → AppServer (requires exploit)
        (3, 4, 2),   # AppServer → Database (credential theft)
        (1, 5, 3),   # DMZ → AdminPanel (strong auth)
        (5, 6, 0),   # AdminPanel → InternalNet (once admin, game over)
        (5, 3, 0),   # AdminPanel → AppServer (admin access)
        (5, 4, 0),   # AdminPanel → Database (admin access)
    ]

    d = floyd_warshall(n, edges)
    rel = chrono_relation(d)

    print("Network topology with penetration costs on edges.")
    print()
    print("Zero-cost reachability from Internet (blast radius of open access):")
    internet_reach = [j for j in range(n) if (0, j) in rel and j != 0]
    for j in internet_reach:
        print(f"  Internet ≼ {labels[j]}")
    if not internet_reach:
        print("  (No zero-cost targets — network is well-segmented)")
    print()

    print("Full zero-cost influence map:")
    for i, j in sorted(rel):
        if i != j:
            print(f"  {labels[i]} → {labels[j]} (free access)")
    print()

    print("Security insight: Zero-cost reachability chains represent")
    print("paths where no additional exploit or credential is needed.")
    print("The chronological order theorem guarantees this forms a")
    print("clean hierarchy (partial order) when there are no zero-cost")
    print("feedback loops — meaning influence flows one way.")
    print()


# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    app_distributed_systems()
    app_project_scheduling()
    app_gene_regulation()
    app_network_security()

    print("=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print()
    print("In all four applications, the same mathematical theorem applies:")
    print("the zero-distance relation from tropical shortest paths forms")
    print("a partial order whenever there are no zero-cost directed cycles.")
    print()
    print("This single result unifies causality analysis across:")
    print("  • Distributed systems (message ordering)")
    print("  • Project management (critical path analysis)")
    print("  • Biology (gene regulatory hierarchies)")
    print("  • Security (influence propagation bounds)")


#!/usr/bin/env python3
"""
demo.py — Tropical Chronological Ordering: Demonstrations

Concrete numerical examples showing how tropical shortest-path distance
canonically generates a causal (partial) order on weighted directed graphs.
"""

import numpy as np
from typing import Dict, List, Tuple, Set, Optional

INF = float('inf')


def floyd_warshall(n: int, edges: List[Tuple[int, int, float]]) -> np.ndarray:
    """Compute all-pairs shortest paths using Floyd-Warshall.

    Args:
        n: Number of vertices (labeled 0..n-1).
        edges: List of (u, v, weight) directed edges.

    Returns:
        n×n distance matrix.
    """
    d = np.full((n, n), INF)
    for i in range(n):
        d[i, i] = 0.0
    for u, v, w in edges:
        d[u, v] = min(d[u, v], w)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    return d


def chronological_relation(d: np.ndarray) -> Set[Tuple[int, int]]:
    """Extract the chronological relation: u ≼ v iff d(u,v) = 0."""
    n = d.shape[0]
    return {(i, j) for i in range(n) for j in range(n)
            if abs(d[i, j]) < 1e-12}


def check_partial_order(rel: Set[Tuple[int, int]], n: int) -> dict:
    """Check reflexivity, transitivity, antisymmetry of a relation on {0,..,n-1}."""
    reflexive = all((i, i) in rel for i in range(n))
    transitive = all(
        (i, k) in rel
        for i in range(n) for j in range(n) for k in range(n)
        if (i, j) in rel and (j, k) in rel
    )
    antisymmetric = all(
        i == j
        for i in range(n) for j in range(n)
        if (i, j) in rel and (j, i) in rel
    )
    return {
        "reflexive": reflexive,
        "transitive": transitive,
        "antisymmetric": antisymmetric,
        "is_partial_order": reflexive and transitive and antisymmetric,
    }


def hasse_diagram(rel: Set[Tuple[int, int]], n: int,
                  labels: Optional[List[str]] = None) -> str:
    """Produce a text representation of the Hasse diagram."""
    if labels is None:
        labels = [str(i) for i in range(n)]
    # Remove reflexive and transitive edges
    covers = set()
    for i, j in rel:
        if i == j:
            continue
        # (i, j) is a cover iff there's no k with i ≼ k ≼ j, k ∉ {i,j}
        is_cover = not any(
            (i, k) in rel and (k, j) in rel
            for k in range(n) if k != i and k != j
        )
        if is_cover:
            covers.add((i, j))
    lines = ["Hasse diagram (covers):"]
    for i, j in sorted(covers):
        lines.append(f"  {labels[i]} → {labels[j]}")
    if not covers:
        lines.append("  (trivial order — no proper covers)")
    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────────────
# EXAMPLE 1: Simple DAG with zero-weight edges
# ─────────────────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 1: Simple DAG with zero-weight edges")
print("=" * 60)
print()

# Vertices: 0=A, 1=B, 2=C, 3=D
labels1 = ["A", "B", "C", "D"]
edges1 = [
    (0, 1, 0),   # A → B, free
    (1, 2, 3),   # B → C, cost 3
    (0, 2, 5),   # A → C, cost 5
    (2, 3, 0),   # C → D, free
    (3, 1, 2),   # D → B, cost 2  (no zero-cost cycle!)
]
d1 = floyd_warshall(4, edges1)
chrono1 = chronological_relation(d1)
props1 = check_partial_order(chrono1, 4)

print("Distance matrix:")
for i in range(4):
    row = [f"{d1[i,j]:5.1f}" if d1[i,j] < INF else "  INF" for j in range(4)]
    print(f"  {labels1[i]}: [{', '.join(row)}]")
print()
print(f"Chronological pairs (d=0): {[(labels1[i], labels1[j]) for i,j in sorted(chrono1) if i != j]}")
print(f"Properties: {props1}")
print(hasse_diagram(chrono1, 4, labels1))
print()

# ─────────────────────────────────────────────────────────────────────
# EXAMPLE 2: Graph WITH a zero-weight cycle (antisymmetry fails)
# ─────────────────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 2: Graph WITH a zero-weight cycle")
print("=" * 60)
print()

labels2 = ["X", "Y", "Z"]
edges2 = [
    (0, 1, 0),   # X → Y, free
    (1, 2, 5),   # Y → Z, cost 5
    (1, 0, 0),   # Y → X, free  ← creates zero-weight cycle X→Y→X
]
d2 = floyd_warshall(3, edges2)
chrono2 = chronological_relation(d2)
props2 = check_partial_order(chrono2, 3)

print("Distance matrix:")
for i in range(3):
    row = [f"{d2[i,j]:5.1f}" if d2[i,j] < INF else "  INF" for j in range(3)]
    print(f"  {labels2[i]}: [{', '.join(row)}]")
print()
print(f"Chronological pairs (d=0): {[(labels2[i], labels2[j]) for i,j in sorted(chrono2) if i != j]}")
print(f"Properties: {props2}")
print("⚠ Antisymmetry FAILS because X ≼ Y and Y ≼ X but X ≠ Y")
print()

# ─────────────────────────────────────────────────────────────────────
# EXAMPLE 3: Timed automaton (scheduling application)
# ─────────────────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 3: Timed automaton / scheduling")
print("=" * 60)
print()

labels3 = ["Start", "TaskA", "TaskB", "TaskC", "TaskD", "End"]
n3 = 6
edges3 = [
    (0, 1, 0),   # Start → TaskA, instant
    (0, 2, 0),   # Start → TaskB, instant
    (1, 3, 2),   # TaskA → TaskC, delay 2
    (2, 3, 3),   # TaskB → TaskC, delay 3
    (1, 4, 0),   # TaskA → TaskD, instant
    (4, 5, 1),   # TaskD → End, delay 1
    (3, 5, 0),   # TaskC → End, instant
]
d3 = floyd_warshall(n3, edges3)
chrono3 = chronological_relation(d3)
props3 = check_partial_order(chrono3, n3)

print("This models a project schedule where some tasks are instantaneous.")
print()
print("Distance matrix:")
for i in range(n3):
    row = [f"{d3[i,j]:5.1f}" if d3[i,j] < INF else "  INF" for j in range(n3)]
    print(f"  {labels3[i]:>6}: [{', '.join(row)}]")
print()
print(f"Chronological pairs (d=0):")
for i, j in sorted(chrono3):
    if i != j:
        print(f"  {labels3[i]} ≼ {labels3[j]}")
print(f"\nProperties: {props3}")
print(hasse_diagram(chrono3, n3, labels3))
print()

# ─────────────────────────────────────────────────────────────────────
# EXAMPLE 4: Random nonneg DAG
# ─────────────────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 4: Random DAG with nonneg weights")
print("=" * 60)
print()

np.random.seed(42)
n4 = 8
edges4 = []
for i in range(n4):
    for j in range(i + 1, n4):
        if np.random.random() < 0.4:
            w = np.random.choice([0, 0, 1, 2, 3, 5])  # some zero-weight edges
            edges4.append((i, j, w))

d4 = floyd_warshall(n4, edges4)
chrono4 = chronological_relation(d4)
props4 = check_partial_order(chrono4, n4)

print(f"Graph has {len(edges4)} edges, {sum(1 for _,_,w in edges4 if w == 0)} with zero weight")
print(f"Chronological pairs (d=0, non-reflexive): {sum(1 for i,j in chrono4 if i != j)}")
print(f"Properties: {props4}")
print(hasse_diagram(chrono4, n4))
print()

# ─────────────────────────────────────────────────────────────────────
# EXAMPLE 5: Zero-walk decomposition
# ─────────────────────────────────────────────────────────────────────
print("=" * 60)
print("EXAMPLE 5: Zero-walk edge decomposition")
print("=" * 60)
print()

print("Theorem: If all edge weights ≥ 0 and a path has total weight 0,")
print("then EVERY edge along the path has weight 0.")
print()

# Demonstrate with a concrete path
path_weights = {
    (0, 1): 0, (1, 2): 0, (2, 3): 0, (3, 4): 0
}
path = [0, 1, 2, 3, 4]
total = sum(path_weights[(path[i], path[i+1])] for i in range(len(path)-1))
print(f"Path: {' → '.join(map(str, path))}")
print(f"Edge weights: {[path_weights[(path[i], path[i+1])] for i in range(len(path)-1)]}")
print(f"Total weight: {total}")
print(f"All edges zero? {all(w == 0 for w in path_weights.values())}")
print()

# Counterexample attempt: can we have total = 0 with a positive edge?
print("Can we have total weight 0 with a positive edge and nonneg weights?")
print("No! If w_i ≥ 0 for all i and Σ w_i = 0, then each w_i = 0.")
print("This is the zero-walk decomposition theorem.")
print()

# ─────────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────────
print("=" * 60)
print("SUMMARY")
print("=" * 60)
print()
print("The tropical chronological ordering theorem states that the")
print("zero-distance relation d(u,v) = 0 is a partial order whenever:")
print("  1. d(v,v) = 0           (reflexivity of distance)")
print("  2. d(u,v) ≥ 0           (nonnegativity)")
print("  3. d(u,w) ≤ d(u,v)+d(v,w) (triangle inequality)")
print("  4. d(u,v)=0 ∧ d(v,u)=0 ⟹ u=v (no zero-cost cycles)")
print()
print("Condition 4 is the 'no closed causal curves' condition.")
print("Without it, we only get a preorder (Example 2).")
print("With it, we get a true partial order (Examples 1, 3, 4).")


#!/usr/bin/env python3
"""Generate PACKAGE.json by assembling all deliverables."""
import json

# Read all files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Tropical/ChronologicalOrder.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations
with open('visualizations.json', 'r') as f:
    visualizations = json.load(f)

package = {
    "title": "Tropical Chronological Ordering: Extracting Causal Structure from Shortest-Path Geometry",
    "domain": "Tropical Geometry / Causal Order Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Chronological Order Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Floyd-Warshall All-Pairs Shortest Paths",
            "pseudocode": "Algorithm: FloydWarshall(G, w)\nInput: Weighted digraph G = (V, E), weight function w\nOutput: Distance matrix d[u][v]\n\n1. Initialize d[u][v] = w(u,v) if edge exists, INF otherwise\n2. Set d[v][v] = 0 for all v\n3. For k = 1 to n:\n4.   For i = 1 to n:\n5.     For j = 1 to n:\n6.       d[i][j] = min(d[i][j], d[i][k] + d[k][j])\n7. Return d\n\nTime: O(n³), Space: O(n²)",
            "code": algorithms_code
        },
        {
            "name": "Chronological Order Extraction",
            "pseudocode": "Algorithm: ComputeChronologicalOrder(G, w)\nInput: Weighted digraph G = (V, E), nonneg weight function w\nOutput: Partial order (V, ≼) or FAILURE\n\n1. d ← FloydWarshall(G, w)\n2. For each u ≠ v:\n3.   If d[u][v] = 0 and d[v][u] = 0:\n4.     Return FAILURE (zero-weight cycle detected)\n5. Return {(u, v) : d[u][v] = 0}\n\nTime: O(n³), Space: O(n²)",
            "code": "# See algorithms.py compute_chronological_order function\n" + algorithms_code
        },
        {
            "name": "Zero-Weight Cycle Detection via Tarjan SCC",
            "pseudocode": "Algorithm: HasZeroWeightCycle(G, w)\nInput: Weighted digraph G = (V, E), nonneg weight function w\nOutput: Boolean\n\n1. E₀ ← {e ∈ E : w(e) = 0}\n2. G₀ ← (V, E₀)\n3. SCCs ← TarjanSCC(G₀)\n4. Return any(|S| > 1 for S in SCCs)\n\nTime: O(n + m), Space: O(n + m)",
            "code": "# See algorithms.py detect_zero_weight_cycles and tarjan_scc functions\n" + algorithms_code
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"Size: {len(json.dumps(package))} bytes")


#!/usr/bin/env python3
"""
visualizations.py — Generate visualizations for tropical chronological ordering.
Produces base64-encoded PNG images for embedding in PACKAGE.json.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from io import BytesIO
import base64
import json

INF = float('inf')


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def floyd_warshall(n, edges):
    d = np.full((n, n), INF)
    for i in range(n):
        d[i, i] = 0.0
    for u, v, w in edges:
        d[u, v] = min(d[u, v], w)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    return d


def viz_distance_heatmap():
    """Distance matrix heatmap with chronological relation highlighted."""
    labels = ["A", "B", "C", "D", "E"]
    n = 5
    edges = [
        (0, 1, 0), (0, 2, 3), (1, 2, 2),
        (2, 3, 0), (3, 4, 1), (2, 4, 0),
    ]
    d = floyd_warshall(n, edges)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Distance matrix
    d_display = d.copy()
    d_display[d_display == INF] = np.nan
    im = ax1.imshow(d_display, cmap='YlOrRd', aspect='equal')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels(labels, fontsize=12)
    ax1.set_yticklabels(labels, fontsize=12)
    ax1.set_title('Tropical Distance Matrix d(u,v)', fontsize=14, fontweight='bold')
    for i in range(n):
        for j in range(n):
            val = d[i, j]
            if val == INF:
                text = '∞'
            else:
                text = f'{val:.0f}'
            color = 'white' if (val != INF and val > 2) else 'black'
            ax1.text(j, i, text, ha='center', va='center', fontsize=14,
                     fontweight='bold', color=color)
    plt.colorbar(im, ax=ax1, shrink=0.8)

    # Chronological relation (binary)
    chrono = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if d[i, j] != INF and abs(d[i, j]) < 1e-12:
                chrono[i, j] = 1

    ax2.imshow(chrono, cmap='Blues', aspect='equal', vmin=0, vmax=1)
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(labels, fontsize=12)
    ax2.set_yticklabels(labels, fontsize=12)
    ax2.set_title('Chronological Relation u ≼ v\n(d(u,v) = 0)', fontsize=14, fontweight='bold')
    for i in range(n):
        for j in range(n):
            text = '≼' if chrono[i, j] == 1 else '·'
            color = 'white' if chrono[i, j] == 1 else 'gray'
            ax2.text(j, i, text, ha='center', va='center', fontsize=16,
                     fontweight='bold', color=color)

    fig.suptitle('From Distance to Causal Order', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_partial_order_vs_preorder():
    """Side-by-side comparison: partial order (no zero cycles) vs preorder (with zero cycles)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    # Left: DAG (partial order)
    positions1 = {0: (1, 3), 1: (0, 2), 2: (2, 2), 3: (1, 1), 4: (1, 0)}
    labels1 = ['A', 'B', 'C', 'D', 'E']
    edges1 = [(0, 1, 0), (0, 2, 3), (1, 3, 0), (2, 3, 2), (3, 4, 1)]

    for u, v, w in edges1:
        x0, y0 = positions1[u]
        x1, y1 = positions1[v]
        color = '#2196F3' if w == 0 else '#9E9E9E'
        width = 3 if w == 0 else 1
        ax1.annotate('', xy=(x1, y1), xytext=(x0, y0),
                     arrowprops=dict(arrowstyle='->', color=color, lw=width))
        mx, my = (x0 + x1) / 2 + 0.15, (y0 + y1) / 2
        ax1.text(mx, my, f'w={w}', fontsize=10, color=color, fontweight='bold')

    for i, (x, y) in positions1.items():
        circle = plt.Circle((x, y), 0.2, color='#E3F2FD', ec='#1565C0', lw=2, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, labels1[i], ha='center', va='center', fontsize=14,
                 fontweight='bold', zorder=6)

    ax1.set_xlim(-0.5, 2.5)
    ax1.set_ylim(-0.5, 3.5)
    ax1.set_aspect('equal')
    ax1.set_title('No Zero-Weight Cycles\n→ PARTIAL ORDER ✓', fontsize=14,
                  fontweight='bold', color='#1B5E20')
    ax1.axis('off')

    # Right: Graph with zero cycle (only preorder)
    positions2 = {0: (0, 2), 1: (2, 2), 2: (1, 0)}
    labels2 = ['X', 'Y', 'Z']
    edges2_draw = [
        (0, 1, 0, 0.1), (1, 0, 0, -0.1), (1, 2, 5, 0)
    ]

    for u, v, w, offset in edges2_draw:
        x0, y0 = positions2[u]
        x1, y1 = positions2[v]
        color = '#F44336' if w == 0 else '#9E9E9E'
        width = 3 if w == 0 else 1
        ax2.annotate('', xy=(x1, y1 + offset), xytext=(x0, y0 + offset),
                     arrowprops=dict(arrowstyle='->', color=color, lw=width,
                                    connectionstyle=f'arc3,rad={0.2 if offset != 0 else 0}'))
        mx = (x0 + x1) / 2
        my = (y0 + y1) / 2 + offset + 0.2
        ax2.text(mx, my, f'w={w}', fontsize=10, color=color, fontweight='bold')

    for i, (x, y) in positions2.items():
        circle = plt.Circle((x, y), 0.2, color='#FFEBEE', ec='#C62828', lw=2, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x, y, labels2[i], ha='center', va='center', fontsize=14,
                 fontweight='bold', zorder=6)

    # Highlight the zero cycle
    ax2.text(1, 2.7, '⚠ Zero-weight cycle: X→Y→X', fontsize=12,
             ha='center', color='#C62828', fontweight='bold',
             bbox=dict(boxstyle='round', facecolor='#FFCDD2', alpha=0.8))

    ax2.set_xlim(-0.5, 2.5)
    ax2.set_ylim(-0.5, 3.2)
    ax2.set_aspect('equal')
    ax2.set_title('Zero-Weight Cycle Present\n→ Only PREORDER ✗', fontsize=14,
                  fontweight='bold', color='#B71C1C')
    ax2.axis('off')

    fig.suptitle('The Chronology Condition: What Makes Causality Work',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_proof_structure():
    """Diagram showing the logical structure of the proof."""
    fig, ax = plt.subplots(figsize=(10, 7))

    boxes = {
        'refl': (2, 6, 'd(v,v) = 0', '#E8F5E9', '#2E7D32'),
        'nonneg': (5, 6, 'd(u,v) ≥ 0', '#E8F5E9', '#2E7D32'),
        'tri': (8, 6, 'd(u,w) ≤ d(u,v)+d(v,w)', '#E8F5E9', '#2E7D32'),
        'rigid': (5, 4.5, 'd(u,v)=0 ∧ d(v,u)=0\n⟹ u=v', '#FFF3E0', '#E65100'),
        'preorder': (3.5, 3, 'PREORDER\n(refl + trans)', '#E3F2FD', '#1565C0'),
        'partial': (6.5, 1.5, 'PARTIAL ORDER\n(refl + trans + antisymm)', '#F3E5F5', '#6A1B9A'),
    }

    for key, (x, y, text, bg, ec) in boxes.items():
        w, h = (2.8, 0.8) if key not in ('preorder', 'partial') else (3.2, 1.0)
        rect = mpatches.FancyBboxPatch((x - w/2, y - h/2), w, h,
                                        boxstyle='round,pad=0.15',
                                        facecolor=bg, edgecolor=ec, lw=2)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=10,
                fontweight='bold', color=ec)

    # Arrows
    arrows = [
        ('refl', 'preorder'), ('nonneg', 'preorder'), ('tri', 'preorder'),
        ('preorder', 'partial'), ('rigid', 'partial'),
    ]
    arrow_coords = {
        ('refl', 'preorder'): ((2, 5.6), (3, 3.5)),
        ('nonneg', 'preorder'): ((5, 5.6), (4, 3.5)),
        ('tri', 'preorder'): ((8, 5.6), (4.5, 3.5)),
        ('preorder', 'partial'): ((4.5, 2.5), (5.5, 2.0)),
        ('rigid', 'partial'): ((5, 4.0), (6.0, 2.0)),
    }

    for (src, tgt) in arrows:
        (x0, y0), (x1, y1) = arrow_coords[(src, tgt)]
        ax.annotate('', xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle='->', color='#37474F', lw=2))

    ax.set_xlim(0, 10)
    ax.set_ylim(0.5, 7)
    ax.set_aspect('equal')
    ax.set_title('Proof Architecture: From Axioms to Partial Order',
                 fontsize=16, fontweight='bold', pad=20)
    ax.axis('off')
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_application_network():
    """Network security blast radius visualization."""
    fig, ax = plt.subplots(figsize=(10, 6))

    nodes = {
        0: (1, 5, 'Internet', '#FFCDD2'),
        1: (3, 5, 'DMZ', '#FFCDD2'),
        2: (5, 5, 'WebServer', '#FFCDD2'),
        3: (5, 3, 'AppServer', '#C8E6C9'),
        4: (7, 3, 'Database', '#C8E6C9'),
        5: (3, 3, 'AdminPanel', '#C8E6C9'),
        6: (3, 1, 'InternalNet', '#C8E6C9'),
    }

    edges = [
        (0, 1, 0), (1, 2, 0), (2, 3, 1), (3, 4, 2),
        (1, 5, 3), (5, 6, 0), (5, 3, 0), (5, 4, 0),
    ]

    for u, v, w in edges:
        x0, y0, _, _ = nodes[u]
        x1, y1, _, _ = nodes[v]
        color = '#F44336' if w == 0 else '#78909C'
        style = '-' if w == 0 else '--'
        width = 2.5 if w == 0 else 1
        ax.annotate('', xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle='->', color=color, lw=width,
                                    linestyle=style))
        mx, my = (x0 + x1) / 2 + 0.2, (y0 + y1) / 2 + 0.2
        ax.text(mx, my, f'cost={w}', fontsize=8, color=color)

    for i, (x, y, label, color) in nodes.items():
        circle = plt.Circle((x, y), 0.4, color=color, ec='#37474F', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=6)

    # Legend
    red_patch = mpatches.Patch(facecolor='#FFCDD2', edgecolor='#F44336', label='Zero-cost reachable from Internet')
    green_patch = mpatches.Patch(facecolor='#C8E6C9', edgecolor='#4CAF50', label='Protected (positive cost)')
    ax.legend(handles=[red_patch, green_patch], loc='lower right', fontsize=10)

    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(0, 6.5)
    ax.set_aspect('equal')
    ax.set_title('Network Security: Zero-Cost Blast Radius Analysis\nRed arrows = free access (chronological relation)',
                 fontsize=14, fontweight='bold')
    ax.axis('off')
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz1 = viz_distance_heatmap()
    viz2 = viz_partial_order_vs_preorder()
    viz3 = viz_proof_structure()
    viz4 = viz_application_network()

    vizs = [
        {"name": "Distance Matrix and Chronological Relation", "data": viz1},
        {"name": "Partial Order vs Preorder: The Chronology Condition", "data": viz2},
        {"name": "Proof Architecture", "data": viz3},
        {"name": "Network Security Blast Radius", "data": viz4},
    ]

    with open("visualizations.json", "w") as f:
        json.dump(vizs, f)

    print(f"Generated {len(vizs)} visualizations.")
    print("Saved to visualizations.json")
