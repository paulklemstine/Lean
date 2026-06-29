"""Assemble PACKAGE.json from the package source files."""
import json
import pathlib

HERE = pathlib.Path(__file__).parent


def read(name: str) -> str:
    return (HERE / name).read_text(encoding="utf-8")


article = read("ARTICLE.md")
paper_md = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo_py = read("demo.py")
viz_py = read("visualize.py")
interactive_html = read("interactive.html")
lean_src = read("lean_source.txt")

future_directions = """# Future Directions — Eulerian Trails and the Parity Obstruction

This cycle proved, from first principles, the parity obstruction to Eulerian
trails on finite multigraphs: the degree/walk-step double-counting identity, the
endpoint-correction identity exhibiting the corrected degree as an even number,
even degree for interior vertices, endpoint-membership of odd vertices, and the
bound of at most two odd-degree vertices (the half of Euler's theorem responsible
for impossibility results such as Königsberg).

## 1. The constructive converse (Euler–Hierholzer).
**Statement.** A *connected* multigraph with at most two odd-degree vertices admits
an Eulerian trail, and one can be constructed explicitly.
**The key insight is** Hierholzer's cycle-splicing: repeatedly extract closed walks
and splice them at shared vertices until every edge is consumed. This complements
the parity *obstruction* proved here with a matching *existence* statement, turning
the necessary condition into an exact criterion.

## 2. Directed and mixed multigraphs.
**Statement.** Replace degree parity by the balance condition in-degree = out-degree
(with at most two exceptional vertices off by one) to characterize directed Eulerian
trails; extend to *mixed* graphs where some edges are oriented.
**The key insight is** that the in/out pairing at each interior vertex is the
directed analogue of the endpoint-correction identity. This is the relevant model
for one-way-street route inspection and for de Bruijn–graph genome assembly.

## 3. Quantitative route inspection (Chinese postman).
**Statement.** When the obstruction fails, the minimum number of repeated
edge-traversals for a closed covering walk equals the minimum-weight perfect
matching on the odd-degree vertex set, with respect to shortest-path distances.
**The key insight is** that the always-even set of odd-degree vertices (the
handshake lemma) must be paired up and the connecting shortest paths duplicated;
this upgrades the lower bound to a certified optimum.

## 4. Higher-dimensional parity obstructions.
**Statement.** Investigate analogues of the endpoint-correction identity for
"trails" in simplicial complexes, where boundary operators generalize the in/out
pairing that drives the parity argument, connecting Eulerian theory to
combinatorial Hodge theory.
"""

package = {
    "title": "The Parity Theorem for Eulerian Trails: Why You Can't Cross Every Bridge Once",
    "domain": "Bridges",
    "description": (
        "A self-contained, fully formal treatment of the parity obstruction to "
        "Eulerian trails on finite multigraphs: two double-counting identities force "
        "interior vertices to have even degree and bound the number of odd-degree "
        "vertices by two, recovering Euler's impossibility verdict for the Königsberg "
        "bridges in one line."
    ),
    "authors": ["The Catalog Project"],
    "date": "2026-06-16",
    "key_results": [
        "Degree double-counting identity: deg(v) equals the sum over Eulerian-trail steps of the indicators that the two consecutive walk vertices equal v.",
        "Endpoint-correction identity: deg(v) plus the start/end indicators equals 2 times the number of trail positions at v, hence an even number.",
        "Every vertex that is neither the start nor the end of an Eulerian trail has even degree.",
        "Every odd-degree vertex must be the trail's start or end; hence at most two vertices have odd degree.",
        "Corollary: the seven bridges of Königsberg (four odd-degree landmasses) admit no Eulerian trail.",
    ],
    "keywords": [
        "Eulerian trail", "multigraph", "degree parity", "handshake lemma",
        "double counting", "Königsberg bridges", "route inspection", "graph theory",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo_py,
    "demos": [
        {
            "name": "Identity and Parity Verifier for Eulerian Trails",
            "description": (
                "Encodes finite multigraphs by an endpoint list exactly as in the "
                "formal development, then for several example trails (a path, an "
                "Eulerian circuit on a triangle, and a loop-with-tail exercising the "
                "loops-count-twice convention) numerically verifies the degree "
                "double-counting identity (Theorem A), the endpoint-correction "
                "identity (Theorem B), even degree of interior vertices (Theorem C), "
                "endpoint-membership of odd vertices (Theorem D), and the at-most-two "
                "odd-vertices bound (Theorem E). Finally it computes the degrees of "
                "the seven-bridge Königsberg multigraph and reports the impossibility "
                "verdict."
            ),
            "code": demo_py,
        },
    ],
    "algorithms": [
        {
            "name": "Linear-Time Degree-Parity Obstruction Test",
            "description": (
                "Computes the degree of every vertex of a multigraph in a single pass "
                "over the endpoint list (a loop adds 2 to its vertex), counts the "
                "odd-degree vertices, and returns whether the necessary parity "
                "condition of Theorem E (at most two odd-degree vertices) holds. "
                "Combined with a connectivity test it yields the exact "
                "Euler–Hierholzer criterion. Runs in O(nV + nE) time and O(nV) space."
            ),
            "pseudocode": (
                "function DEGREE-PARITY-CHECK(ends[0..nE-1], nV):\n"
                "    deg[v] <- 0 for all v in 0..nV-1\n"
                "    for e in 0..nE-1:\n"
                "        (u, w) <- ends[e]\n"
                "        deg[u] <- deg[u] + 1\n"
                "        deg[w] <- deg[w] + 1        # loop u=w adds 2 to deg[u]\n"
                "    odd <- count of v with deg[v] odd\n"
                "    return (odd, odd <= 2)          # parity necessary condition"
            ),
            "code": (
                "from typing import Dict, List, Tuple\n\n"
                "Edge = Tuple[int, int]\n\n\n"
                "def degree_parity_check(ends: List[Edge], n_vertices: int) -> Tuple[int, bool]:\n"
                "    \"\"\"Return (#odd-degree vertices, whether <= 2 so a trail may exist).\"\"\"\n"
                "    deg: Dict[int, int] = {v: 0 for v in range(n_vertices)}\n"
                "    for (u, w) in ends:\n"
                "        deg[u] += 1\n"
                "        deg[w] += 1  # a loop (u == w) adds 2 to deg[u]\n"
                "    odd = sum(1 for v in range(n_vertices) if deg[v] % 2 == 1)\n"
                "    return odd, odd <= 2\n"
            ),
        },
        {
            "name": "Route-Inspection Repetition Lower Bound via Odd-Vertex Pairing",
            "description": (
                "Given a connected multigraph for which an Eulerian circuit may not "
                "exist, computes a lower bound on the number of edge-traversals that "
                "must be repeated by any closed covering walk. The odd-degree vertex "
                "set is always even in size (handshake lemma); the minimum extra cost "
                "is the minimum-weight perfect matching of those vertices under "
                "shortest-path distance. The routine reports the odd set and a greedy "
                "pairing cost as a bound."
            ),
            "pseudocode": (
                "function ROUTE-INSPECTION-LOWER-BOUND(G):\n"
                "    D <- { v : deg[v] is odd }          # |D| is even\n"
                "    if D is empty: return 0             # Eulerian circuit exists\n"
                "    dist <- all-pairs shortest paths on D\n"
                "    pair D into |D|/2 pairs minimizing total dist\n"
                "    return total distance of the minimizing pairing"
            ),
            "code": (
                "from itertools import combinations\n"
                "from typing import Dict, List, Tuple\n\n"
                "Edge = Tuple[int, int]\n\n\n"
                "def odd_vertices(ends: List[Edge], n_vertices: int) -> List[int]:\n"
                "    deg = {v: 0 for v in range(n_vertices)}\n"
                "    for (u, w) in ends:\n"
                "        deg[u] += 1\n"
                "        deg[w] += 1\n"
                "    return [v for v in range(n_vertices) if deg[v] % 2 == 1]\n\n\n"
                "def min_pairing_cost(verts: List[int],\n"
                "                     dist: Dict[Tuple[int, int], float]) -> float:\n"
                "    \"\"\"Exact minimum-weight perfect matching (small |verts|).\"\"\"\n"
                "    if not verts:\n"
                "        return 0.0\n"
                "    first, rest = verts[0], verts[1:]\n"
                "    best = float('inf')\n"
                "    for i, partner in enumerate(rest):\n"
                "        remaining = rest[:i] + rest[i + 1:]\n"
                "        cost = dist[(first, partner)] + min_pairing_cost(remaining, dist)\n"
                "        best = min(best, cost)\n"
                "    return best\n"
            ),
        },
    ],
    "visualizations": [
        {
            "name": "Königsberg Multigraph with Degree Annotations",
            "description": (
                "Renders the four landmasses and seven bridges of Königsberg with "
                "curved arcs for multi-edges, annotates each vertex with its degree, "
                "colors odd-degree vertices red and even ones green, and titles the "
                "figure with the Theorem E impossibility verdict. Saves koenigsberg.png."
            ),
            "code": viz_py,
        },
    ],
    "interactive_demos": [
        {
            "title": "Eulerian Trail Parity Explorer",
            "description": (
                "An interactive SVG widget where users build their own multigraph by "
                "clicking pairs of dots to add bridges (including loops) and clicking "
                "bridges to remove them. Each vertex is colored by the parity of its "
                "degree, a live table lists all degrees, and the verdict updates in "
                "real time: an Eulerian trail is possible only when at most two "
                "vertices have odd degree. A one-click button loads the historical "
                "seven bridges of Königsberg to see the impossibility verdict."
            ),
            "html": interactive_html,
        },
    ],
    "lean_proofs": lean_src,
    "future_directions": future_directions,
    "modules": {
        "demo": demo_py,
        "visualize": viz_py,
    },
    "lean_files": ["Catalog/Bridges/EulerianTrailParity.lean"],
}

out = HERE / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print("Wrote", out, "(%d bytes)" % out.stat().st_size)
# sanity: re-read
json.loads(out.read_text(encoding="utf-8"))
print("JSON valid. Top-level keys:", list(package.keys()))


"""
Numerical demonstration of the parity theorem for Eulerian trails on finite
multigraphs.

This script is fully self-contained (standard library only) and mirrors, in
executable Python, the five results proved formally:

  Theorem A  degree(v) = sum over walk steps of [walk[i]=v] + [walk[i+1]=v]
  Theorem B  degree(v) + ([walk[0]=v] + [walk[last]=v]) = 2 * #{j : walk[j]=v}
  Theorem C  interior vertices have even degree
  Theorem D  odd-degree vertices are trail endpoints
  Theorem E  at most two odd-degree vertices

A multigraph is encoded exactly as in the formal development: by an "ends" list
assigning to each edge an ordered pair of vertices.  Degree counts edge
*endpoints*, so a loop contributes 2.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

Vertex = int
Edge = Tuple[Vertex, Vertex]


# ---------------------------------------------------------------------------
# Core definitions (Definitions 2.1-2.3)
# ---------------------------------------------------------------------------

def degree(ends: List[Edge], n_vertices: int) -> Dict[Vertex, int]:
    """Degree of every vertex: number of incident edge endpoints (loops count 2)."""
    deg: Dict[Vertex, int] = {v: 0 for v in range(n_vertices)}
    for (u, w) in ends:
        deg[u] += 1
        deg[w] += 1
    return deg


def odd_degree_vertices(ends: List[Edge], n_vertices: int) -> List[Vertex]:
    """The set of vertices whose degree is odd."""
    deg = degree(ends, n_vertices)
    return [v for v in range(n_vertices) if deg[v] % 2 == 1]


def walk_step_count(walk: List[Vertex], v: Vertex) -> int:
    """RHS of Theorem A: sum over steps of [walk[i]=v] + [walk[i+1]=v]."""
    total = 0
    for i in range(len(walk) - 1):
        total += (1 if walk[i] == v else 0) + (1 if walk[i + 1] == v else 0)
        # i+1 is the next position; together they range over all consecutive pairs
    return total


def positions_equal(walk: List[Vertex], v: Vertex) -> int:
    """Number of trail positions equal to v (the N_v of Theorem B)."""
    return sum(1 for x in walk if x == v)


def is_eulerian_trail(ends: List[Edge], walk: List[Vertex],
                      edge_at: List[int]) -> bool:
    """Check the Eulerian-trail compatibility condition (Definition 2.3)."""
    n_e = len(ends)
    if len(walk) != n_e + 1:
        return False
    if sorted(edge_at) != list(range(n_e)):  # edge_at must be a permutation
        return False
    for i in range(n_e):
        e = edge_at[i]
        forward = ends[e] == (walk[i], walk[i + 1])
        backward = ends[e] == (walk[i + 1], walk[i])
        if not (forward or backward):
            return False
    return True


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def check_identities(name: str, ends: List[Edge], n_vertices: int,
                     walk: List[Vertex], edge_at: List[int]) -> None:
    print(f"\n=== {name} ===")
    print(f"edges (ends)   : {ends}")
    print(f"walk           : {walk}")
    print(f"edgeAt (perm)  : {edge_at}")

    assert is_eulerian_trail(ends, walk, edge_at), "not a valid Eulerian trail!"
    print("valid Eulerian trail: YES")

    deg = degree(ends, n_vertices)
    start, end = walk[0], walk[-1]
    print(f"degrees        : {deg}")
    print(f"start={start}, end={end}")

    for v in range(n_vertices):
        # Theorem A
        lhs_a, rhs_a = deg[v], walk_step_count(walk, v)
        assert lhs_a == rhs_a, (v, lhs_a, rhs_a)

        # Theorem B
        corr = (1 if start == v else 0) + (1 if end == v else 0)
        rhs_b = 2 * positions_equal(walk, v)
        assert deg[v] + corr == rhs_b, (v, deg[v], corr, rhs_b)

        # Theorem C / D
        if v != start and v != end:
            assert deg[v] % 2 == 0, f"interior vertex {v} has odd degree!"
        if deg[v] % 2 == 1:
            assert v == start or v == end, f"odd vertex {v} is not an endpoint!"

    print("Theorem A (degree = walk-step count) .......... verified for all v")
    print("Theorem B (endpoint correction = 2*N_v) ....... verified for all v")
    print("Theorem C (interior vertices even degree) ..... verified")
    print("Theorem D (odd vertices are endpoints) ........ verified")

    odd = odd_degree_vertices(ends, n_vertices)
    print(f"odd-degree vertices: {odd}  (count = {len(odd)})")
    assert len(odd) <= 2, "Theorem E violated!"
    print("Theorem E (at most two odd vertices) .......... verified")


def konigsberg() -> None:
    """The seven bridges: 4 odd vertices => no Eulerian trail (Theorem E)."""
    print("\n=== The Seven Bridges of Koenigsberg ===")
    # vertices: A=0 (big island), B=1 (small island), N=2 (north), S=3 (south)
    ends: List[Edge] = [
        (0, 2), (0, 2),          # A-N twice
        (0, 3), (0, 3),          # A-S twice
        (0, 1),                  # A-B
        (1, 2),                  # B-N
        (1, 3),                  # B-S
    ]
    n_vertices = 4
    deg = degree(ends, n_vertices)
    names = {0: "A", 1: "B", 2: "N", 3: "S"}
    print("degrees:", {names[v]: deg[v] for v in range(n_vertices)})
    odd = odd_degree_vertices(ends, n_vertices)
    print(f"odd-degree vertices: {[names[v] for v in odd]}  (count = {len(odd)})")
    if len(odd) > 2:
        print("Theorem E: count > 2  =>  NO Eulerian trail can exist.")
        print("Conclusion: it is IMPOSSIBLE to cross every bridge exactly once.")


def main() -> None:
    # Example 1: a path on 4 vertices (open trail, two odd endpoints).
    check_identities(
        "Path 0-1-2-3",
        ends=[(0, 1), (1, 2), (2, 3)],
        n_vertices=4,
        walk=[0, 1, 2, 3],
        edge_at=[0, 1, 2],
    )

    # Example 2: a triangle (closed trail / Eulerian circuit, all even degree).
    check_identities(
        "Triangle 0-1-2-0",
        ends=[(0, 1), (1, 2), (2, 0)],
        n_vertices=3,
        walk=[0, 1, 2, 0],
        edge_at=[0, 1, 2],
    )

    # Example 3: a loop plus a tail, exercising the loop-counts-twice convention.
    check_identities(
        "Loop at 1 with tail 0-1",
        ends=[(0, 1), (1, 1)],
        n_vertices=2,
        walk=[0, 1, 1],
        edge_at=[0, 1],
    )

    # Example 4: the Koenigsberg impossibility verdict.
    konigsberg()

    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()


"""
Visualization of the Eulerian-trail parity theorem on the Koenigsberg multigraph.

Draws the four landmasses and seven bridges, annotates each vertex with its degree,
colors odd-degree vertices, and reports the Theorem E verdict.  Requires matplotlib.
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

Vertex = int
Edge = Tuple[Vertex, Vertex]


def degree(ends: List[Edge], n_vertices: int) -> Dict[Vertex, int]:
    deg = {v: 0 for v in range(n_vertices)}
    for (u, w) in ends:
        deg[u] += 1
        deg[w] += 1
    return deg


def main() -> None:
    # A=0 big island, B=1 small island, N=2 north bank, S=3 south bank
    pos: Dict[Vertex, Tuple[float, float]] = {
        0: (0.0, 0.0), 1: (2.0, 0.0), 2: (1.0, 1.5), 3: (1.0, -1.5),
    }
    names = {0: "A", 1: "B", 2: "N", 3: "S"}
    ends: List[Edge] = [(0, 2), (0, 2), (0, 3), (0, 3), (0, 1), (1, 2), (1, 3)]
    deg = degree(ends, 4)

    fig, ax = plt.subplots(figsize=(7, 7))

    # Draw bridges; multiple edges get curved so they are distinguishable.
    seen: Dict[Tuple[int, int], int] = {}
    for (u, w) in ends:
        key = (min(u, w), max(u, w))
        k = seen.get(key, 0)
        seen[key] = k + 1
        rad = 0.0 if k == 0 else 0.3 * (1 if k % 2 else -1) * ((k + 1) // 2)
        arrow = FancyArrowPatch(
            pos[u], pos[w], connectionstyle=f"arc3,rad={rad}",
            arrowstyle="-", lw=2, color="#3b6ea5",
        )
        ax.add_patch(arrow)

    for v, (x, y) in pos.items():
        odd = deg[v] % 2 == 1
        ax.scatter([x], [y], s=2200,
                   color="#e2574c" if odd else "#5cb85c",
                   edgecolors="black", zorder=3)
        ax.text(x, y, f"{names[v]}\ndeg={deg[v]}",
                ha="center", va="center", fontsize=11, fontweight="bold",
                zorder=4)

    odd_count = sum(1 for v in range(4) if deg[v] % 2 == 1)
    verdict = ("NO Eulerian trail (Theorem E: %d > 2 odd vertices)" % odd_count)
    ax.set_title("Seven Bridges of Koenigsberg\n" + verdict, fontsize=13)
    ax.set_xlim(-1.2, 3.2)
    ax.set_ylim(-2.4, 2.4)
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("koenigsberg.png", dpi=140)
    print("Saved koenigsberg.png ;", verdict)


if __name__ == "__main__":
    main()
