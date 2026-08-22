"""Assemble PACKAGE.json from the deliverables and the assets in this folder."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Pythagorean/GraphTheory/CliqueSum.lean",
    "Catalog/Pythagorean/GraphTheory/CliqueSumExact.lean",
    "Catalog/Pythagorean/GraphTheory/CliqueSumSharpness.lean",
]

lean_source = "\n\n".join(
    f"-- ==========================================================================\n"
    f"-- FILE: {name}\n"
    f"-- ==========================================================================\n\n"
    + read(ROOT / name)
    for name in LEAN_FILES
)

FUTURE_DIRECTIONS = r"""# Future directions: clique sums as a gluing calculus for graph invariants

This cycle formalised clique sums — both the strong notion, in which the weld $K$ is a clique on each side, and the weak notion, in which it is only a clique of the union — and established:

* an independent set meets a clique at most once;
* the **sharp** uniform bound $\alpha_1 + \alpha_2 \le \alpha(G) + \min(k, 2)$, together with the refutation of the folklore $\alpha_1 + \alpha_2 \le \alpha(G) + 1$ for $k \ge 2$ (Witness A) and attainment in all three regimes $k = 0, 1, \ge 2$ (Witnesses A, C, D);
* the **exact** trace decomposition $\alpha(G) = \max_{T \subseteq K,\ |T| \le 1} (\alpha_1(T) + \alpha_2(T) - |T|)$;
* $\chi(G) = \max(\chi_1, \chi_2)$, $\omega(G) = \max(\omega_1, \omega_2)$, preservation of $\chi = \omega$, and the automatic inequality $k \le n$ for the number of colours on a side;
* the sharp boundary: for *weak* clique sums, where the $k$-clique $K$ is a clique of $G$ but its edges are split between the sides so that $n < k$ colours suffice on each side, both $\chi(G) = \max(\chi_1, \chi_2)$ and even $\alpha_1 + \alpha_2 \le \alpha(G) + 2$ fail (Witness B).

The structural pattern that emerged is a **trace calculus**: gluing behaves well exactly for invariants that can be relativised to the trace $A \cap K$ of a witness set on the gluing clique, and the "loss" term is governed by how many trace values a witness can carry ($1$ for independent sets, $|K|$ for cliques, $0$ for colourings after a colour permutation). The directions below push that pattern.

## 1. Iterated clique sums and a tree-decomposition trace calculus

**The key insight is** that the trace formula is a *fold* over a tree of clique sums: $\alpha$ of a graph assembled by repeated clique sums along a tree should be computable by dynamic programming whose state is exactly the $\le 1$-element trace on each separator. **Why now?** The one-step exact formula and the supporting gluing infrastructure are in place, so the induction over a tree is the natural next step, and it yields a verified linear-time $\alpha$ for bounded-treewidth chordal-like assemblies.

## 2. Perfection is preserved by clique sums

**The key insight is** that $\chi = \omega$ was preserved *numerically* here, and the same colour-permutation argument applies verbatim to every induced subgraph of a clique sum, because induced subgraphs of a clique sum are clique sums of induced subgraphs along a sub-clique. **Why now?** The colouring transfer is proved; what remains is a hereditary bookkeeping lemma, giving a fully rigorous proof of a classical ingredient of the Strong Perfect Graph Theorem toolkit.

## 3. Fractional relaxations break at the same threshold $k = 2$

**The key insight is** that the integral obstruction found in Witness A (a maximum independent set can be forced to use a $K$-vertex whose neighbours on the other side are free) is exactly the obstruction that the fractional independence number $\alpha_f$ smooths out; we conjecture $\alpha_f(G) \ge \alpha_f(G_1) + \alpha_f(G_2) - 1$ for all clique sums, i.e. that the fractional relaxation obeys the folklore bound that the integral invariant violates, and that the integrality gap of the gluing step is exactly one.

## 4. Weighted and multi-way sums

Both the trace decomposition and the colour-transfer argument should extend to vertex-weighted independence and to simultaneous sums of $m$ graphs along a common clique, with the loss term becoming $\min(k, m)$ for the uniform bound and the trace state space remaining of size $k + 1$.

## 5. Other invariants with a trace calculus

Which further invariants admit a trace calculus? Natural candidates are the domination number, the fractional chromatic number and the Lovász theta function; each requires identifying the correct notion of "what a witness carries across a clique separator", and the size of that state space is precisely the algorithmic price of decomposition.
"""
INTERACTIVE_LAYOUT = read(ASSETS / "interactive_layout.md")

package: Dict[str, Any] = {
    "title": "Clique Sums and the Trace Calculus: Exact Composition Laws for the "
             "Independence, Clique and Chromatic Numbers",
    "domain": "Pythagorean",
    "description": (
        "A complete and sharp account of how the independence, clique and chromatic numbers "
        "behave when two graphs are glued along a shared clique: the folklore bound "
        "alpha_1 + alpha_2 <= alpha(G) + 1 is refuted for welds of size at least two, the sharp "
        "replacement alpha_1 + alpha_2 <= alpha(G) + min(k,2) and an exact trace decomposition of "
        "alpha(G) are established, and the colouring and clique laws chi(G) = max(chi_1,chi_2) and "
        "omega(G) = max(omega_1,omega_2) are proved and shown to fail as soon as the weld is a "
        "clique of the union only."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-21",
    "key_results": [
        "An independent set meets a clique in at most one vertex, so a witness carries at most "
        "one weld vertex across a clique separator.",
        "Sharp uniform gluing bound: for a clique sum along a clique of size k, "
        "alpha_1 + alpha_2 <= alpha(G) + min(k, 2), attained in each of the regimes k = 0, k = 1 "
        "and k >= 2.",
        "Refutation of the folklore bound: alpha_1 + alpha_2 <= alpha(G) + 1 is false for every "
        "weld of size at least two, the minimal counterexample being the path on four vertices.",
        "Exact trace decomposition of the independence number: alpha(G) is the maximum over the "
        "at most k+1 traces T of size at most one of alpha_1(T) + alpha_2(T) - |T|.",
        "Composition of colourings and cliques: chi(G) = max(chi_1, chi_2) and "
        "omega(G) = max(omega_1, omega_2), the identity chi = omega is preserved, and a side "
        "colourable with n colours automatically satisfies k <= n.",
        "Sharp boundary: when the weld is a clique of the union only, with its edges split "
        "between the sides so that fewer colours than weld vertices suffice on each side, both "
        "the colouring law and the bound alpha_1 + alpha_2 <= alpha(G) + 2 fail on three vertices.",
    ],
    "keywords": [
        "clique sum",
        "independence number",
        "chromatic number",
        "clique number",
        "graph gluing",
        "trace decomposition",
        "tree decomposition",
        "perfect graphs",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Exhaustive Verification of the Clique-Sum Composition Laws on Four Witnesses",
            "description": (
                "Builds the four extremal presentations by hand — the path on four vertices glued "
                "along a 2-clique, the edgeless cut-vertex example, the disjoint union, and the "
                "triangle split as an edge plus a path — and computes every relevant invariant by "
                "exhaustive search: the restricted independence numbers of the two sides, the "
                "independence number of the sum, the clique numbers, the chromatic numbers, and "
                "the full trace table T -> (alpha_1(T), alpha_2(T), alpha_1(T)+alpha_2(T)-|T|). "
                "For each witness it prints a verdict for the folklore bound, the proved -2 bound, "
                "the sharp min(k,2) bound, the colouring law, the clique law, the exact trace law "
                "and the automatic inequality k <= n, making visible exactly which statements hold "
                "for genuine clique sums and which collapse in the weak setting. It then verifies "
                "the One-Point Trace lemma exhaustively over all graphs on four vertices (every "
                "independent set against every clique) and stress-tests all composition laws on "
                "sixty randomly generated strong clique sums."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Trace-Decomposed Computation of the Independence Number of a Clique Sum",
            "description": (
                "Computes alpha(G) for a clique sum exactly, by exploiting the fact that an "
                "independent set meets the weld clique K in at most one vertex. Instead of "
                "searching the whole graph, the algorithm enumerates the k+1 admissible traces "
                "(the empty set and each single weld vertex) and, for each, solves two constrained "
                "independent-set problems, one on each side: for a singleton trace {v} it deletes "
                "the closed neighbourhood of v and the rest of the weld and adds one to the "
                "unconstrained answer; for the empty trace it simply deletes the weld. The exact "
                "value is then the maximum of alpha_1(T) + alpha_2(T) - |T|, the subtraction "
                "correcting the double count of the shared trace. Complexity: 2(k+1) calls to an "
                "independence-number oracle on graphs no larger than the sides, i.e. "
                "O(k(2^{n1} + 2^{n2})) with the included branch-and-bound solver, against "
                "O(2^{n1+n2-k}) for a direct attack; polynomial whenever the sides themselves are "
                "tractable. The routine also certifies the strong hypothesis, checking that the "
                "weld is a clique on each side before any composition law is applied."
            ),
            "pseudocode": (
                "Input : sides s, t with graphs G1, G2; weld K = s ∩ t\n"
                "Output: alpha(G) for G = G1 ∪ G2\n"
                "\n"
                "1  assert K is a clique of G1 and of G2          // the strong hypothesis\n"
                "2  best ← 0\n"
                "3  for each T in {∅} ∪ {{v} : v ∈ K} do          // k+1 admissible traces\n"
                "4      if T = ∅ then\n"
                "5          a1 ← MaxIndependentSet(G1, s \\ K)\n"
                "6          a2 ← MaxIndependentSet(G2, t \\ K)\n"
                "7      else  ({v} ← T)\n"
                "8          a1 ← 1 + MaxIndependentSet(G1, (s \\ K) \\ N(v))\n"
                "9          a2 ← 1 + MaxIndependentSet(G2, (t \\ K) \\ N(v))\n"
                "10     best ← max(best, a1 + a2 − |T|)\n"
                "11 return best\n"
                "\n"
                "MaxIndependentSet(G, U):                          // branch and bound\n"
                "  if U = ∅ return 0\n"
                "  take all isolated vertices of G[U] greedily\n"
                "  pick a vertex p of maximum degree in G[U]\n"
                "  return max( 1 + MaxIndependentSet(G, U \\ N[p]),\n"
                "                  MaxIndependentSet(G, U \\ {p}) )"
            ),
            "code": read(ASSETS / "algorithm_trace_alpha.py"),
        },
        {
            "name": "Colour-Permutation Gluing of Proper Colourings Across a Clique Weld",
            "description": (
                "Turns proper n-colourings of the two sides of a clique sum into a proper "
                "n-colouring of the glued graph, which is the constructive content of "
                "chi(G) = max(chi_1, chi_2). Because the weld is a clique on each side, both "
                "colourings are injective on it — this is also why a side colourable with n "
                "colours forces k <= n — so the assignment c2(v) -> c1(v) for weld vertices v is a "
                "well-defined bijection between two k-element subsets of the palette. The "
                "algorithm extends that bijection to a permutation sigma of all n colours by "
                "matching the two complements in order, recolours the right side by sigma ∘ c2, "
                "which is still proper and now agrees with the left colouring on every weld "
                "vertex, and finally reads off the glued colouring. Every edge of the sum lies "
                "inside one side, so properness is inherited edge by edge. Complexity: O(n + k) "
                "beyond the two side colourings, i.e. linear; the routine refuses to proceed, with "
                "an explicit diagnostic, if a colouring is not injective on the weld or if k > n, "
                "the two symptoms of a merely weak clique sum."
            ),
            "pseudocode": (
                "Input : sides s, t; proper n-colourings c1 of G1 and c2 of G2; weld K = s ∩ t\n"
                "Output: a proper n-colouring of G = G1 ∪ G2\n"
                "\n"
                "1  if c1 or c2 is not injective on K, or |K| > n then\n"
                "2      abort: the presentation is not a (strong) clique sum\n"
                "3  partial ← { c2(v) ↦ c1(v) : v ∈ K }           // injective, |partial| = k\n"
                "4  sigma ← ExtendToPermutation(partial, n)        // match the complements\n"
                "5  for v ∈ s        do c(v) ← c1(v)\n"
                "6  for v ∈ t \\ s    do c(v) ← sigma(c2(v))\n"
                "7  return c\n"
                "\n"
                "ExtendToPermutation(partial, n):\n"
                "  sigma ← partial\n"
                "  sources ← the colours not in the domain of partial, in order\n"
                "  targets ← the colours not in the image  of partial, in order\n"
                "  pair them off; return sigma"
            ),
            "code": read(ASSETS / "algorithm_colour_transfer.py"),
        },
        {
            "name": "Trace-State Dynamic Programming for Iterated Clique Sums Along a Tree",
            "description": (
                "Extends the one-step trace decomposition to a graph assembled from many bags by "
                "repeated clique sums along a tree, which is exactly the situation of a tree "
                "decomposition whose separators are cliques (chordal graphs, junction trees, "
                "nested dissection). Each bag reports to its parent a table indexed by the trace "
                "the partial solution leaves on the shared separator; because that separator is a "
                "clique, the trace is either empty or a single vertex, so the table has |K|+1 "
                "entries rather than 2^{|K|}. The fold at a bag maximises, over independent "
                "subsets A of the bag with the prescribed parent trace, the quantity "
                "|A| + sum over children of (child table at A ∩ K_child − |A ∩ K_child|), the "
                "subtraction again removing the double count of shared vertices. The answer is the "
                "maximum entry of the root table, computed with an empty separator. Complexity: "
                "linear in the number of bags, with a per-bag cost of 2^{|bag|} times the number "
                "of admissible traces — that is, exponential only in the bag size and merely "
                "*linear* in the separator size, which is the payoff of the trace calculus."
            ),
            "pseudocode": (
                "Fold(bag B, separator K shared with the parent):\n"
                "1  for each child C of B:\n"
                "2      K_C ← B ∩ C\n"
                "3      tab_C ← Fold(C, K_C)\n"
                "4  table ← empty map\n"
                "5  for each admissible trace T of K   (T = ∅ or T = {v}, v ∈ K):\n"
                "6      best ← −∞\n"
                "7      for each independent A ⊆ B with A ∩ K = T:\n"
                "8          total ← |A|\n"
                "9          for each child C:\n"
                "10             local ← A ∩ K_C\n"
                "11             if |local| > 1 then skip A          // a clique carries ≤ 1 vertex\n"
                "12             total ← total + tab_C[local] − |local|\n"
                "13         best ← max(best, total)\n"
                "14     if best > −∞ then table[T] ← best\n"
                "15 return table\n"
                "\n"
                "alpha(assembly) = max over T of Fold(root, ∅)[T]"
            ),
            "code": read(ASSETS / "algorithm_tree_fold.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Two Locally Optimal Independent Sets That Cannot Be Glued",
            "description": (
                "A four-panel figure built from the minimal counterexample to the folklore bound: "
                "the left side (the path 2–1–0 with its maximum independent set {0,2} highlighted), "
                "the right side (the path 1–0–3 with witness {1,3}), the glued path 2–1–0–3 whose "
                "independence number is only 2, and a bar chart of the trace table. The picture "
                "makes the failure visible: the two side-optimal witnesses claim *different* "
                "vertices of the weld {0,1}, which are adjacent, so their union is not independent, "
                "while the bar chart shows that every admissible trace yields exactly "
                "alpha_1(T) + alpha_2(T) − |T| = 2, the true value of alpha(G)."
            ),
            "code": read(ASSETS / "viz_witness_a.py"),
        },
        {
            "name": "The Gluing Gap and Its Sharp Ceiling min(k, 2)",
            "description": (
                "Samples random clique sums for weld sizes k = 0,…,4, computes the gluing gap "
                "alpha_1 + alpha_2 − alpha(G) by exhaustive search, and plots its distribution "
                "against the proved ceiling min(k,2). The left panel, for genuine clique sums "
                "(weld completed on both sides), shows every sample below the ceiling and the "
                "ceiling attained in each regime; the right panel repeats the experiment for weak "
                "clique sums, where the weld's edges are handed out at random between the sides, "
                "and the gap climbs freely past the ceiling as soon as k >= 3. The two panels "
                "side by side are the experimental signature of the strong/weak boundary."
            ),
            "code": read(ASSETS / "viz_gap_distribution.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Clique Sum Laboratory: Glue, Break, and Repair Three Graph Invariants",
            "description": (
                "A live workbench for clique sums. Choose a weld size and how many private "
                "vertices each side gets, then click pairs of vertices to add or remove edges; the "
                "widget maintains the two sides and their union, and recomputes — by exhaustive "
                "search, in the browser — the independence, clique and chromatic numbers of both "
                "sides and of the sum, together with the full trace table showing, for every "
                "admissible trace T, the best independent set of each side with that trace. A "
                "verdict panel reports in real time whether the folklore bound alpha_1 + alpha_2 "
                "<= alpha(G) + 1 survives, whether the sharp ceiling min(k,2) is respected, "
                "whether chi(G) = max(chi_1,chi_2) and omega(G) = max(omega_1,omega_2) hold, "
                "whether the exact trace formula reproduces alpha(G), and whether the automatic "
                "inequality k <= n is satisfied. A mode switch turns the weld from a clique on "
                "*each* side into a clique of the union only, whose edges the user hands out "
                "between the sides — and the laws visibly collapse. Five presets load the extremal "
                "witnesses discussed in the paper, including the path on four vertices that "
                "refutes the folklore bound and the split triangle that destroys the weak theory."
            ),
            "html": read(ASSETS / "widget_clique_sum_lab.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_source,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Visualisation: the gluing gap alpha_1 + alpha_2 - alpha(G) never exceeds min(k,2).

Samples random strong clique sums for weld sizes k = 0,1,2,3,4, computes the gap
by exhaustive search, and plots its distribution against the proved ceiling
min(k,2). Also plots the corresponding gaps for *weak* clique sums, which are
unbounded by the same ceiling. Produces `gluing_gap.png`.
"""

from __future__ import annotations

import random
from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence, Set, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

Vertex = int
Edge = FrozenSet[Vertex]


def independence_number(vertices: Sequence[Vertex], edges: Set[Edge]) -> int:
    best = 0
    items = list(vertices)
    for mask in range(1 << len(items)):
        subset = [items[i] for i in range(len(items)) if mask >> i & 1]
        if len(subset) <= best:
            continue
        if all(frozenset((a, b)) not in edges for a, b in combinations(subset, 2)):
            best = len(subset)
    return best


def random_strong_clique_sum(rng: random.Random, k: int, p1: int, p2: int,
                             density: float) -> Tuple[int, int, int]:
    """Return (alpha_1, alpha_2, alpha(G)) for a random strong clique sum."""
    weld = list(range(k))
    left = weld + list(range(k, k + p1))
    right = weld + list(range(k + p1, k + p1 + p2))
    e1: Set[Edge] = {frozenset(e) for e in combinations(weld, 2)}
    e2: Set[Edge] = set(e1)
    for a, b in combinations(left, 2):
        if rng.random() < density:
            e1.add(frozenset((a, b)))
    for a, b in combinations(right, 2):
        if rng.random() < density:
            e2.add(frozenset((a, b)))
    a1 = independence_number(left, e1)
    a2 = independence_number(right, e2)
    a = independence_number(sorted(set(left) | set(right)), e1 | e2)
    return a1, a2, a


def random_weak_clique_sum(rng: random.Random, k: int, p1: int, p2: int,
                           density: float) -> Tuple[int, int, int]:
    """A weak clique sum: the weld's edges are shared out at random."""
    weld = list(range(k))
    left = weld + list(range(k, k + p1))
    right = weld + list(range(k + p1, k + p1 + p2))
    e1: Set[Edge] = set()
    e2: Set[Edge] = set()
    for e in combinations(weld, 2):
        (e1 if rng.random() < 0.5 else e2).add(frozenset(e))
    for a, b in combinations(left, 2):
        if frozenset((a, b)) not in e1 and rng.random() < density:
            e1.add(frozenset((a, b)))
    for a, b in combinations(right, 2):
        if frozenset((a, b)) not in e2 and rng.random() < density:
            e2.add(frozenset((a, b)))
    a1 = independence_number(left, e1)
    a2 = independence_number(right, e2)
    a = independence_number(sorted(set(left) | set(right)), e1 | e2)
    return a1, a2, a


def main() -> None:
    rng = random.Random(20260821)
    weld_sizes = [0, 1, 2, 3, 4]
    trials = 120
    strong_gaps: Dict[int, List[int]] = {k: [] for k in weld_sizes}
    weak_gaps: Dict[int, List[int]] = {k: [] for k in weld_sizes}

    for k in weld_sizes:
        for _ in range(trials):
            a1, a2, a = random_strong_clique_sum(rng, k, 4, 4, 0.3)
            strong_gaps[k].append(a1 + a2 - a)
            b1, b2, b = random_weak_clique_sum(rng, k, 4, 4, 0.3)
            weak_gaps[k].append(b1 + b2 - b)

    fig, axes = plt.subplots(1, 2, figsize=(11.5, 4.6), sharey=True)

    for ax, gaps, title in (
        (axes[0], strong_gaps, "Strong clique sums: gap $\\leq \\min(k,2)$"),
        (axes[1], weak_gaps, "Weak clique sums: the ceiling is violated"),
    ):
        for k in weld_sizes:
            jitter = [k + (i % 11 - 5) * 0.03 for i in range(len(gaps[k]))]
            ax.scatter(jitter, gaps[k], s=14, alpha=0.45, color="#3d6fb4")
            ax.scatter([k], [max(gaps[k])], s=70, color="#d94f4f", zorder=3)
        ax.plot(weld_sizes, [min(k, 2) for k in weld_sizes], color="#d94f4f",
                linewidth=2.0, linestyle="--", label="ceiling $\\min(k,2)$")
        ax.set_xlabel("weld size $k = |K|$")
        ax.set_title(title, fontsize=11)
        ax.set_xticks(weld_sizes)
        ax.grid(alpha=0.25)
        ax.legend(fontsize=9)

    axes[0].set_ylabel("gluing gap $\\alpha_1+\\alpha_2-\\alpha(G)$")
    fig.suptitle("The gluing gap and its sharp ceiling (red dots: observed maxima)",
                 fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig("gluing_gap.png", dpi=160)
    print("wrote gluing_gap.png")


if __name__ == "__main__":
    main()


"""Visualisation: why the folklore bound fails on the path with four vertices.

Draws the two sides of the clique sum, the glued graph, and the trace table
showing that the two sides' optimal independent sets want *different* vertices
of the weld. Produces `witness_a.png`.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

Vertex = int
Position = Tuple[float, float]

POS: Dict[Vertex, Position] = {2: (0.0, 0.0), 1: (1.0, 0.0), 0: (2.0, 0.0), 3: (3.0, 0.0)}

G1_EDGES: List[Tuple[Vertex, Vertex]] = [(0, 1), (1, 2)]
G2_EDGES: List[Tuple[Vertex, Vertex]] = [(0, 1), (0, 3)]
WELD: List[Vertex] = [0, 1]


def draw_graph(ax: plt.Axes, vertices: Sequence[Vertex],
               edges: Sequence[Tuple[Vertex, Vertex]],
               highlight: Sequence[Vertex], title: str) -> None:
    for a, b in edges:
        xa, ya = POS[a]
        xb, yb = POS[b]
        ax.plot([xa, xb], [ya, yb], color="#444444", linewidth=2.0, zorder=1)
    for v in vertices:
        x, y = POS[v]
        in_weld = v in WELD
        chosen = v in highlight
        ax.scatter([x], [y], s=900,
                   facecolor="#f4b942" if chosen else ("#c9d6ea" if in_weld else "#ffffff"),
                   edgecolor="#d94f4f" if in_weld else "#333333",
                   linewidth=3.0 if in_weld else 1.5, zorder=2)
        ax.text(x, y, str(v), ha="center", va="center", fontsize=13, zorder=3)
    ax.set_title(title, fontsize=11)
    ax.set_xlim(-0.6, 3.6)
    ax.set_ylim(-0.9, 0.9)
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(11.0, 6.4))

    draw_graph(axes[0][0], [2, 1, 0], G1_EDGES, [0, 2],
               "Left side $G_1$ on $s=\\{0,1,2\\}$\n"
               "$\\alpha_1 = 2$, witness $\\{0,2\\}$ uses weld vertex $0$")
    draw_graph(axes[0][1], [1, 0, 3], G2_EDGES, [1, 3],
               "Right side $G_2$ on $t=\\{0,1,3\\}$\n"
               "$\\alpha_2 = 2$, witness $\\{1,3\\}$ uses weld vertex $1$")
    draw_graph(axes[1][0], [2, 1, 0, 3], G1_EDGES + G2_EDGES, [2, 3],
               "Clique sum $G = G_1 \\cup G_2$ (the path $2-1-0-3$)\n"
               "$\\alpha(G) = 2$, so $\\alpha_1+\\alpha_2 = 4 > 3 = \\alpha(G)+1$")

    ax = axes[1][1]
    labels = ["$T=\\varnothing$", "$T=\\{0\\}$", "$T=\\{1\\}$"]
    alpha1 = [1, 2, 1]
    alpha2 = [1, 1, 2]
    sizes = [0, 1, 1]
    values = [a + b - c for a, b, c in zip(alpha1, alpha2, sizes)]
    x = range(len(labels))
    ax.bar([i - 0.22 for i in x], alpha1, width=0.2, label="$\\alpha_1(T)$", color="#6fa8dc")
    ax.bar([i for i in x], alpha2, width=0.2, label="$\\alpha_2(T)$", color="#93c47d")
    ax.bar([i + 0.22 for i in x], values, width=0.2,
           label="$\\alpha_1(T)+\\alpha_2(T)-|T|$", color="#f4b942")
    ax.axhline(2, color="#d94f4f", linestyle="--", linewidth=1.5,
               label="$\\alpha(G) = 2$")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, fontsize=11)
    ax.set_ylim(0, 3)
    ax.set_title("Trace decomposition: the maximum over traces is exactly $\\alpha(G)$",
                 fontsize=11)
    ax.legend(fontsize=8, loc="upper left")

    fig.suptitle("Witness A: two locally optimal independent sets that cannot be glued",
                 fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("witness_a.png", dpi=160)
    print("wrote witness_a.png")


if __name__ == "__main__":
    main()


"""
Clique sums: numerical demonstration of the composition laws for the
independence number, the clique number and the chromatic number.

Everything is self-contained: graphs are represented as (vertices, edges) with
vertices a frozenset of integers and edges a frozenset of frozensets of size 2.
All invariants are computed by exhaustive search, which is fine for the tiny
witnesses used here and for the random tests at the end.

Demonstrated facts
------------------
1.  An independent set meets a clique in at most one vertex.
2.  For a (strong) clique sum along a clique K of size k:
        alpha_1 + alpha_2 <= alpha(G) + min(k, 2),
    and this is sharp for k = 0, k = 1 and k >= 2.
3.  The folklore bound alpha_1 + alpha_2 <= alpha(G) + 1 is FALSE for k >= 2
    (Witness A: the path on four vertices).
4.  Exact trace decomposition:
        alpha(G) = max over T subset of K with |T| <= 1 of
                   (alpha_1(T) + alpha_2(T) - |T|).
5.  omega(G) = max(omega_1, omega_2)   and   chi(G) = max(chi_1, chi_2).
6.  A side that is n-colourable forces k <= n.
7.  For WEAK clique sums (K a clique of the union only) 2, 4, 5 and 6 all fail
    (Witness B: the triangle split as an edge plus a path).

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]


# ----------------------------------------------------------------------------
# Graph representation and basic invariants
# ----------------------------------------------------------------------------


class Graph:
    """A finite simple undirected graph on an explicit vertex set."""

    def __init__(self, vertices: Iterable[Vertex], edges: Iterable[Iterable[Vertex]]) -> None:
        self.vertices: FrozenSet[Vertex] = frozenset(vertices)
        self.edges: FrozenSet[Edge] = frozenset(
            frozenset(e) for e in edges if len(frozenset(e)) == 2
        )
        for e in self.edges:
            if not e <= self.vertices:
                raise ValueError(f"edge {set(e)} leaves the vertex set")

    def adjacent(self, a: Vertex, b: Vertex) -> bool:
        return frozenset((a, b)) in self.edges

    def union(self, other: "Graph") -> "Graph":
        return Graph(self.vertices | other.vertices, self.edges | other.edges)

    def is_independent(self, a_set: Iterable[Vertex]) -> bool:
        s = list(a_set)
        return all(not self.adjacent(a, b) for a, b in combinations(s, 2))

    def is_clique(self, c_set: Iterable[Vertex]) -> bool:
        s = list(c_set)
        return all(self.adjacent(a, b) for a, b in combinations(s, 2))

    def __repr__(self) -> str:
        es = sorted(tuple(sorted(e)) for e in self.edges)
        return f"Graph(V={sorted(self.vertices)}, E={es})"


def subsets(ground: Iterable[Vertex]) -> Iterable[FrozenSet[Vertex]]:
    """All subsets of a finite set, as frozensets."""
    items = sorted(ground)
    for mask in range(1 << len(items)):
        yield frozenset(items[i] for i in range(len(items)) if mask >> i & 1)


def independence_number(graph: Graph, inside: Optional[Iterable[Vertex]] = None) -> int:
    """alpha(graph; inside): largest independent set contained in `inside`."""
    ground = graph.vertices if inside is None else frozenset(inside)
    return max((len(a) for a in subsets(ground) if graph.is_independent(a)), default=0)


def clique_number(graph: Graph, inside: Optional[Iterable[Vertex]] = None) -> int:
    """omega(graph; inside): largest clique contained in `inside`."""
    ground = graph.vertices if inside is None else frozenset(inside)
    return max((len(c) for c in subsets(ground) if graph.is_clique(c)), default=0)


def is_colourable(graph: Graph, n: int) -> bool:
    """Does `graph` admit a proper colouring with n colours? (brute force)"""
    verts = sorted(graph.vertices)
    if n == 0:
        return len(verts) == 0
    for assignment in product(range(n), repeat=len(verts)):
        colour = dict(zip(verts, assignment))
        if all(colour[min(e)] != colour[max(e)] for e in graph.edges):
            return True
    return False


def chromatic_number(graph: Graph) -> int:
    """chi(graph), by brute-force search over palettes of increasing size."""
    for n in range(len(graph.vertices) + 1):
        if is_colourable(graph, n):
            return n
    raise RuntimeError("unreachable: a graph is always |V|-colourable")


def traced_independence_number(
    graph: Graph, side: Iterable[Vertex], weld: Iterable[Vertex], trace: Iterable[Vertex]
) -> int:
    """alpha_i(T): largest independent A inside `side` with A ∩ weld == trace."""
    side_set, weld_set, trace_set = frozenset(side), frozenset(weld), frozenset(trace)
    best = -1
    for a in subsets(side_set):
        if a & weld_set == trace_set and graph.is_independent(a):
            best = max(best, len(a))
    return best  # -1 signals "no independent set has this trace"


# ----------------------------------------------------------------------------
# Clique-sum presentations
# ----------------------------------------------------------------------------


class CliqueSumPresentation:
    """A presentation G = G1 ∪ G2 with sides s, t and weld K = s ∩ t."""

    def __init__(
        self,
        name: str,
        g1: Graph,
        g2: Graph,
        side_s: Iterable[Vertex],
        side_t: Iterable[Vertex],
    ) -> None:
        self.name = name
        self.g1 = g1
        self.g2 = g2
        self.s = frozenset(side_s)
        self.t = frozenset(side_t)
        self.k = self.s & self.t
        self.g = g1.union(g2)

    # --- structural checks -------------------------------------------------

    def covers(self) -> bool:
        return self.s | self.t == self.g.vertices

    def edges_respect_sides(self) -> bool:
        return all(e <= self.s for e in self.g1.edges) and all(
            e <= self.t for e in self.g2.edges
        )

    def is_weak_clique_sum(self) -> bool:
        return self.covers() and self.edges_respect_sides() and self.g.is_clique(self.k)

    def is_strong_clique_sum(self) -> bool:
        return (
            self.covers()
            and self.edges_respect_sides()
            and self.g1.is_clique(self.k)
            and self.g2.is_clique(self.k)
        )

    # --- invariants --------------------------------------------------------

    def alpha_1(self) -> int:
        return independence_number(self.g1, self.s)

    def alpha_2(self) -> int:
        return independence_number(self.g2, self.t)

    def alpha(self) -> int:
        return independence_number(self.g)

    def omega_1(self) -> int:
        return clique_number(self.g1, self.s)

    def omega_2(self) -> int:
        return clique_number(self.g2, self.t)

    def omega(self) -> int:
        return clique_number(self.g)

    def chi_1(self) -> int:
        return chromatic_number(Graph(self.s, [e for e in self.g1.edges if e <= self.s]))

    def chi_2(self) -> int:
        return chromatic_number(Graph(self.t, [e for e in self.g2.edges if e <= self.t]))

    def chi(self) -> int:
        return chromatic_number(self.g)

    def admissible_traces(self) -> List[FrozenSet[Vertex]]:
        """The at most k+1 traces a witness can carry: ∅ and the singletons."""
        return [frozenset()] + [frozenset({v}) for v in sorted(self.k)]

    def trace_formula(self) -> int:
        """max over admissible T of alpha_1(T) + alpha_2(T) - |T|."""
        best = 0
        for trace in self.admissible_traces():
            a1 = traced_independence_number(self.g1, self.s, self.k, trace)
            a2 = traced_independence_number(self.g2, self.t, self.k, trace)
            if a1 >= 0 and a2 >= 0:
                best = max(best, a1 + a2 - len(trace))
        return best

    def trace_table(self) -> Dict[Tuple[Vertex, ...], Tuple[int, int, int]]:
        table: Dict[Tuple[Vertex, ...], Tuple[int, int, int]] = {}
        for trace in self.admissible_traces():
            a1 = traced_independence_number(self.g1, self.s, self.k, trace)
            a2 = traced_independence_number(self.g2, self.t, self.k, trace)
            value = a1 + a2 - len(trace) if a1 >= 0 and a2 >= 0 else -1
            table[tuple(sorted(trace))] = (a1, a2, value)
        return table


# ----------------------------------------------------------------------------
# The four witnesses
# ----------------------------------------------------------------------------


def witness_a() -> CliqueSumPresentation:
    """Path 2-1-0-3 as a clique sum along the 2-clique K = {0,1}."""
    g1 = Graph({0, 1, 2}, [(0, 1), (1, 2)])
    g2 = Graph({0, 1, 3}, [(0, 1), (0, 3)])
    return CliqueSumPresentation("A: path P4, k = 2", g1, g2, {0, 1, 2}, {0, 1, 3})


def witness_b() -> CliqueSumPresentation:
    """Triangle split as one edge plus a path: a WEAK clique sum with k = 3."""
    g1 = Graph({0, 1, 2}, [(0, 1)])
    g2 = Graph({0, 1, 2}, [(0, 2), (1, 2)])
    return CliqueSumPresentation("B: split triangle (weak), k = 3", g1, g2, {0, 1, 2}, {0, 1, 2})


def witness_c() -> CliqueSumPresentation:
    """Three isolated vertices glued at a cut vertex: k = 1."""
    g1 = Graph({0, 1}, [])
    g2 = Graph({0, 2}, [])
    return CliqueSumPresentation("C: edgeless, k = 1", g1, g2, {0, 1}, {0, 2})


def witness_d() -> CliqueSumPresentation:
    """Disjoint union: k = 0."""
    g1 = Graph({0}, [])
    g2 = Graph({1}, [])
    return CliqueSumPresentation("D: disjoint union, k = 0", g1, g2, {0}, {1})


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def report(pres: CliqueSumPresentation) -> None:
    k = len(pres.k)
    strong = pres.is_strong_clique_sum()
    weak = pres.is_weak_clique_sum()
    a1, a2, a = pres.alpha_1(), pres.alpha_2(), pres.alpha()
    w1, w2, w = pres.omega_1(), pres.omega_2(), pres.omega()
    c1, c2, c = pres.chi_1(), pres.chi_2(), pres.chi()

    rule(f"Witness {pres.name}")
    print(f"  G1 = {pres.g1}")
    print(f"  G2 = {pres.g2}")
    print(f"  G  = {pres.g}")
    print(f"  s  = {sorted(pres.s)}   t = {sorted(pres.t)}   K = {sorted(pres.k)}   k = {k}")
    print(f"  strong clique sum: {strong}      weak clique sum: {weak}")
    print()
    print(f"  alpha_1 = {a1}   alpha_2 = {a2}   alpha(G) = {a}")
    print(f"  omega_1 = {w1}   omega_2 = {w2}   omega(G) = {w}")
    print(f"  chi_1   = {c1}   chi_2   = {c2}   chi(G)   = {c}")
    print()
    print("  trace table   T -> (alpha_1(T), alpha_2(T), alpha_1+alpha_2-|T|)"
          "      [-1 = trace unrealisable]")
    for trace, values in pres.trace_table().items():
        label = "{}" if not trace else "{" + ",".join(map(str, trace)) + "}"
        print(f"    T = {label:<9} -> {values}")
    print(f"  trace formula value = {pres.trace_formula()}   (alpha(G) = {a})")
    print()

    print(f"  folklore bound  a1 + a2 <= alpha + 1 : "
          f"{a1 + a2} <= {a + 1} ... {'HOLDS' if a1 + a2 <= a + 1 else 'FAILS'}")
    print(f"  proved bound    a1 + a2 <= alpha + 2 : "
          f"{a1 + a2} <= {a + 2} ... {'HOLDS' if a1 + a2 <= a + 2 else 'FAILS'}")
    print(f"  sharp bound     a1 + a2 <= alpha + min(k,2) : "
          f"{a1 + a2} <= {a + min(k, 2)} ... "
          f"{'HOLDS' if a1 + a2 <= a + min(k, 2) else 'FAILS'}")
    print(f"  chi law         chi(G) = max(chi1, chi2)    : "
          f"{c} = {max(c1, c2)} ... {'HOLDS' if c == max(c1, c2) else 'FAILS'}")
    print(f"  omega law       omega(G) = max(w1, w2)      : "
          f"{w} = {max(w1, w2)} ... {'HOLDS' if w == max(w1, w2) else 'FAILS'}")
    print(f"  trace law       alpha(G) = trace formula    : "
          f"{a} = {pres.trace_formula()} ... "
          f"{'HOLDS' if a == pres.trace_formula() else 'FAILS'}")
    print(f"  automatic k<=n  (n = chi_1)                 : "
          f"k = {k}, n = {c1} ... {'HOLDS' if k <= c1 else 'FAILS'}")


# ----------------------------------------------------------------------------
# One-Point Trace lemma, checked exhaustively on small graphs
# ----------------------------------------------------------------------------


def check_one_point_trace(n_vertices: int = 5) -> Tuple[int, int]:
    """Exhaustively verify |A ∩ K| <= 1 for all graphs on n vertices."""
    verts = list(range(n_vertices))
    possible_edges = [frozenset(e) for e in combinations(verts, 2)]
    checked = 0
    for mask in range(1 << len(possible_edges)):
        edges = [possible_edges[i] for i in range(len(possible_edges)) if mask >> i & 1]
        g = Graph(verts, edges)
        for a_set in subsets(verts):
            if not g.is_independent(a_set):
                continue
            for k_set in subsets(verts):
                if not g.is_clique(k_set):
                    continue
                checked += 1
                assert len(a_set & k_set) <= 1, (edges, a_set, k_set)
    return checked, n_vertices


# ----------------------------------------------------------------------------
# Randomised stress test of the theorems on genuine clique sums
# ----------------------------------------------------------------------------


def random_clique_sum(rng_state: List[int], n_private1: int, n_private2: int, k: int
                      ) -> CliqueSumPresentation:
    """Build a random strong clique sum: weld K = {0..k-1} is completed on both sides."""

    def next_bit() -> int:
        # xorshift, so the demo has no external dependencies
        x = rng_state[0]
        x ^= (x << 13) & 0xFFFFFFFFFFFFFFFF
        x ^= x >> 7
        x ^= (x << 17) & 0xFFFFFFFFFFFFFFFF
        rng_state[0] = x
        return x & 1

    weld = list(range(k))
    left = weld + list(range(k, k + n_private1))
    right = weld + list(range(k + n_private1, k + n_private1 + n_private2))

    e1: Set[Edge] = {frozenset(e) for e in combinations(weld, 2)}
    e2: Set[Edge] = set(e1)
    for a, b in combinations(left, 2):
        if frozenset((a, b)) not in e1 and next_bit():
            e1.add(frozenset((a, b)))
    for a, b in combinations(right, 2):
        if frozenset((a, b)) not in e2 and next_bit():
            e2.add(frozenset((a, b)))

    g1 = Graph(left, e1)
    g2 = Graph(right, e2)
    return CliqueSumPresentation("random", g1, g2, left, right)


def stress_test(trials: int = 60) -> None:
    state = [0x2545F4914F6CDD1D]
    failures = 0
    for i in range(trials):
        k = i % 4
        pres = random_clique_sum(state, 2 + (i % 3), 2 + ((i + 1) % 3), k)
        assert pres.is_strong_clique_sum(), "construction should be a strong clique sum"
        a1, a2, a = pres.alpha_1(), pres.alpha_2(), pres.alpha()
        ok_uniform = a1 + a2 <= a + min(len(pres.k), 2)
        ok_trace = a == pres.trace_formula()
        ok_chi = pres.chi() == max(pres.chi_1(), pres.chi_2())
        ok_omega = pres.omega() == max(pres.omega_1(), pres.omega_2())
        ok_kn = len(pres.k) <= pres.chi_1() and len(pres.k) <= pres.chi_2()
        if not (ok_uniform and ok_trace and ok_chi and ok_omega and ok_kn):
            failures += 1
            print(f"  FAILURE on trial {i}: {pres.g1} {pres.g2}")
    print(f"  {trials} random strong clique sums tested, {failures} failures.")


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------


def main() -> None:
    rule("CLIQUE SUMS: composition laws for alpha, omega and chi")
    print(
        "A clique sum glues G1 and G2 along sides s, t with weld K = s ∩ t,\n"
        "requiring K to be a clique on EACH side. A weak clique sum only asks\n"
        "that K be a clique of the union G = G1 ∪ G2."
    )

    for pres in (witness_a(), witness_c(), witness_d(), witness_b()):
        report(pres)

    rule("Headline numbers")
    a = witness_a()
    print(f"  Witness A (strong, k=2): alpha_1 + alpha_2 = {a.alpha_1() + a.alpha_2()}, "
          f"alpha(G) + 1 = {a.alpha() + 1}  ->  folklore bound is FALSE")
    print(f"                            alpha_1 + alpha_2 = {a.alpha_1() + a.alpha_2()}, "
          f"alpha(G) + 2 = {a.alpha() + 2}  ->  the -2 bound is SHARP")
    b = witness_b()
    print(f"  Witness B (weak,   k=3): chi(G) = {b.chi()} but max(chi1, chi2) = "
          f"{max(b.chi_1(), b.chi_2())}  ->  colour law FAILS")
    print(f"                            alpha_1 + alpha_2 = {b.alpha_1() + b.alpha_2()} > "
          f"{b.alpha() + 2} = alpha(G) + 2  ->  even the -2 bound FAILS")
    print(f"                            n = {b.chi_1()} < k = {len(b.k)}: impossible for a "
          f"strong clique sum")

    rule("Exhaustive check of the One-Point Trace lemma")
    checked, n = check_one_point_trace(4)
    print(f"  All graphs on {n} vertices, all independent sets A, all cliques K:")
    print(f"  {checked} (A, K) pairs checked, every one satisfies |A ∩ K| <= 1.")

    rule("Randomised stress test of all composition laws")
    stress_test(60)

    rule("Done")


if __name__ == "__main__":
    main()
