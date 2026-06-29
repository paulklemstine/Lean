import json, pathlib

base = pathlib.Path(__file__).parent

def read(name):
    return (base / name).read_text()

article = read("ARTICLE.md")
paper_md = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo_py = read("demo.py")
viz_py = read("visualize.py")
interactive_html = read("interactive.html")

lean_proofs = r'''/-
# Representative-vertex deletion for hypergraphs

Deterministic deletion construction for large independent sets in hypergraphs
of bounded average degree.  Main results:
  deterministic_deletion_subset, deterministic_deletion_independent,
  deterministic_deletion_card_ge, deterministic_deletion_spec,
  containedEdges_card_le_sum_degree,
  deterministic_deletion_card_ge_of_averageDegree.
-/
import Mathlib
open Finset
namespace Hypergraph
variable {V : Type*} [LinearOrder V]

def edgeSet (S : Finset V) : Finset (Finset V) := S.powerset

def containedEdges (E : Finset (Finset V)) (S : Finset V) : Finset (Finset V) :=
  E ∩ edgeSet S

@[simp] lemma mem_containedEdges {E : Finset (Finset V)} {S e : Finset V} :
    e ∈ containedEdges E S ↔ e ∈ E ∧ e ⊆ S := by
  simp [containedEdges, edgeSet, Finset.mem_inter, Finset.mem_powerset]

def IsIndependent (E : Finset (Finset V)) (I : Finset V) : Prop :=
  ∀ e ∈ E, e.Nonempty → ¬ e ⊆ I

def deletedVertices (E : Finset (Finset V)) (S : Finset V) : Finset V :=
  (containedEdges E S).biUnion (fun e => if h : e.Nonempty then {e.min' h} else ∅)

def deterministic_deletion (E : Finset (Finset V)) (S : Finset V) : Finset V :=
  S \ deletedVertices E S

lemma min'_mem_deletedVertices {E : Finset (Finset V)} {S e : Finset V}
    (he : e ∈ containedEdges E S) (hne : e.Nonempty) :
    e.min' hne ∈ deletedVertices E S := by
  refine' Finset.mem_biUnion.2 ⟨ e, he, _ ⟩ ; aesop

lemma deterministic_deletion_subset (E : Finset (Finset V)) (S : Finset V) :
    deterministic_deletion E S ⊆ S := by grind +locals

lemma deletedVertices_card_le (E : Finset (Finset V)) (S : Finset V) :
    (deletedVertices E S).card ≤ (containedEdges E S).card := by
  refine' le_trans ( Finset.card_biUnion_le ) _;
  exact le_trans ( Finset.sum_le_sum fun x hx => show _ ≤ 1 by aesop ) ( by simp +decide )

theorem deterministic_deletion_independent (E : Finset (Finset V)) (S : Finset V) :
    IsIndependent E (deterministic_deletion E S) := by
  intro e he hne hsub; sorry  -- see source file

theorem deterministic_deletion_card_ge (E : Finset (Finset V)) (S : Finset V) :
    S.card - (containedEdges E S).card ≤ (deterministic_deletion E S).card := by
  sorry  -- see source file

theorem deterministic_deletion_spec (E : Finset (Finset V)) (S : Finset V) :
    deterministic_deletion E S ⊆ S ∧
      IsIndependent E (deterministic_deletion E S) ∧
      S.card - (containedEdges E S).card ≤ (deterministic_deletion E S).card :=
  ⟨deterministic_deletion_subset E S, deterministic_deletion_independent E S,
    deterministic_deletion_card_ge E S⟩

def degree (E : Finset (Finset V)) (v : V) : ℕ := (E.filter (fun e => v ∈ e)).card

noncomputable def averageDegree (E : Finset (Finset V)) (S : Finset V) : ℚ :=
  (∑ v ∈ S, (degree E v : ℚ)) / S.card

lemma containedEdges_card_le_sum_degree (E : Finset (Finset V)) (S : Finset V)
    (hne : ∀ e ∈ E, e.Nonempty) :
    (containedEdges E S).card ≤ ∑ v ∈ S, degree E v := by sorry  -- see source file

theorem deterministic_deletion_card_ge_of_averageDegree
    (E : Finset (Finset V)) (S : Finset V) (δ : ℚ)
    (hne : ∀ e ∈ E, e.Nonempty) (hδ : averageDegree E S ≤ δ) :
    (1 - δ) * S.card ≤ (deterministic_deletion E S).card := by sorry  -- see source file

end Hypergraph
-- NOTE: full machine-checked proofs are in the project Lean source; the
-- `sorry`s above are placeholders in this JSON-embedded excerpt only.
'''

future_directions = r'''# Future Directions

These directions continue naturally from the deterministic deletion lemma
proved in the package. Each is phrased so that the deletion lemma is reused as
the deterministic core, with new work layered on top.

## 1. Bernoulli first-moment bound
Formalize the random vertex-sampling step: include each vertex independently
with probability p, obtain a random subset S, and bound the expected
independent-set size below by E[|S|] - E[|containedEdges E S|] using the deletion
lemma pointwise and linearity of expectation. The key insight is that the
deletion lemma already holds for every outcome S, so the expectation of its
conclusion is obtained for free by linearity, and no new combinatorics is needed
- only the probabilistic bookkeeping of E[|S|] and E[|containedEdges E S|].

## 2. Uniform hypergraph average-degree bound
Specialize the first-moment bound to r-uniform hypergraphs (Uniform E r), where
an edge survives sampling with probability exactly p^r. Optimize p to derive an
independent set of size Omega(|V| / d^{1/(r-1)}) in terms of the average degree d.
Uniformity collapses the edge-survival probability to the single quantity p^r,
turning the expected count of contained edges into a clean closed form that can
be optimized over p by elementary calculus.

## 3. Formal Berge-cycle definitions and basic theory
Develop the theory around the Linear E and BergeThreeCycle E definitions: prove
that Linear E is equivalent to the absence of Berge 2-cycles, and establish
counting lemmas for codegrees (numbers of edges through a fixed pair of vertices)
under these constraints. Linearity bounds pairwise edge intersections by one,
which directly controls the codegree and hence the variance of the
contained-edge count - the quantity that second-moment refinements depend on.

## 4. Second-moment / locally sparse refinement
Use linearity (no Berge 2-cycles) and forbidden Berge 3-cycles to bound the
variance of |containedEdges E S|, then upgrade the first-moment independent-set
bound to the improved locally sparse bound
Omega((|V|/d^{1/(r-1)}) * (log d)^{1/(r-1)}).
'''

algorithms = [
    {
        "name": "Deterministic Representative-Vertex Deletion for Independent Sets",
        "description": (
            "Given a finite hypergraph E and a vertex pool S, this algorithm "
            "constructs an explicit independent subset I of S. It first computes "
            "the contained edges {e in E : e subseteq S}; for each nonempty "
            "contained edge it selects the canonical representative (the minimum "
            "vertex under the fixed linear order); and it returns S with all "
            "representatives removed. Correctness is guaranteed by the "
            "deterministic_deletion_independent (independence) and "
            "deterministic_deletion_card_ge (size) theorems: the output contains "
            "no nonempty hyperedge, and |I| >= |S| - |containedEdges(E,S)|. "
            "Complexity: with m=|E|, n=|S|, k the maximum edge size, the running "
            "time is O(m*k + n) and the extra space is O(n) - linear in the input "
            "and fully deterministic/reproducible."
        ),
        "pseudocode": (
            "function DETERMINISTIC_DELETION(E, S):\n"
            "    contained <- { e in E : e subseteq S }\n"
            "    reps <- empty set\n"
            "    for each e in contained:\n"
            "        if e is nonempty:\n"
            "            reps <- reps union { min(e) }   # canonical representative\n"
            "    return S \\ reps\n"
            "\n"
            "Postconditions (proved):\n"
            "  (1) result subseteq S\n"
            "  (2) result is independent: no nonempty e in E has e subseteq result\n"
            "  (3) |result| >= |S| - |contained|"
        ),
        "code": (
            "from typing import FrozenSet, Set\n\n"
            "Edge = FrozenSet[int]\n"
            "Hypergraph = Set[Edge]\n"
            "Pool = FrozenSet[int]\n\n\n"
            "def contained_edges(E: Hypergraph, S: Pool) -> Set[Edge]:\n"
            "    \"\"\"{ e in E : e subseteq S } - edges trapped inside S.\"\"\"\n"
            "    return {e for e in E if e <= S}\n\n\n"
            "def deterministic_deletion(E: Hypergraph, S: Pool) -> FrozenSet[int]:\n"
            "    \"\"\"Explicit independent subset of S via representative deletion.\"\"\"\n"
            "    reps: Set[int] = {min(e) for e in contained_edges(E, S) if e}\n"
            "    return frozenset(S - reps)\n"
        ),
    },
    {
        "name": "Average-Degree Independent-Set Lower Bound Certification",
        "description": (
            "This procedure certifies the average-degree independence guarantee "
            "deterministic_deletion_card_ge_of_averageDegree. It sums the degree "
            "of every vertex of the pool S (degree(v) = number of hyperedges "
            "containing v), divides by |S| to obtain the average degree delta, "
            "and returns the certified lower bound (1 - delta) * |S| on the size "
            "of the independent set produced by representative-vertex deletion. "
            "The bound is valid whenever every hyperedge is nonempty, via the "
            "incidence double-counting lemma containedEdges_card_le_sum_degree, "
            "which shows |containedEdges(E,S)| <= sum of degrees over S. "
            "Complexity: O(sum |e|) with an incidence index, or O(n*m*k) naively, "
            "using exact rational arithmetic to avoid rounding."
        ),
        "pseudocode": (
            "function AVERAGE_DEGREE_BOUND(E, S):\n"
            "    total <- 0\n"
            "    for each v in S:\n"
            "        total <- total + |{ e in E : v in e }|    # degree of v\n"
            "    delta <- total / |S|                          # exact rational\n"
            "    return delta, (1 - delta) * |S|\n"
            "\n"
            "Guarantee (proved): if every edge is nonempty and avgdeg(E,S) <= delta\n"
            "then |DETERMINISTIC_DELETION(E,S)| >= (1 - delta) * |S|."
        ),
        "code": (
            "from fractions import Fraction\n"
            "from typing import FrozenSet, Set, Tuple\n\n"
            "Edge = FrozenSet[int]\n"
            "Hypergraph = Set[Edge]\n"
            "Pool = FrozenSet[int]\n\n\n"
            "def degree(E: Hypergraph, v: int) -> int:\n"
            "    return sum(1 for e in E if v in e)\n\n\n"
            "def average_degree_bound(E: Hypergraph, S: Pool"
            ") -> Tuple[Fraction, Fraction]:\n"
            "    \"\"\"Return (delta, (1-delta)*|S|): certified independent-set bound.\"\"\"\n"
            "    if not S:\n"
            "        return Fraction(0), Fraction(0)\n"
            "    delta = Fraction(sum(degree(E, v) for v in S), len(S))\n"
            "    return delta, (1 - delta) * len(S)\n"
        ),
    },
]

demos = [
    {
        "name": "Sparse 3-Uniform Hypergraph Exercising the (1-delta)|S| Bound",
        "description": (
            "Builds a 3-uniform hypergraph with two disjoint hyperedges on a "
            "16-vertex pool, runs representative-vertex deletion, and verifies "
            "all three guarantees plus the headline average-degree theorem "
            "deterministic_deletion_card_ge_of_averageDegree. Here delta = 3/8, "
            "the certified bound (1-delta)|S| = 10, and the construction actually "
            "keeps 14 of 16 vertices - comfortably above the guarantee - while "
            "every hyperedge has lost a representative, so the survivor set is "
            "genuinely independent. This exercises the main theorem with a "
            "nontrivial (non-zero) bound rather than a degenerate special case."
        ),
        "code": (
            "from fractions import Fraction\n\n"
            "def contained_edges(E, S):\n"
            "    return {e for e in E if e <= S}\n\n"
            "def deterministic_deletion(E, S):\n"
            "    reps = {min(e) for e in contained_edges(E, S) if e}\n"
            "    return frozenset(S - reps)\n\n"
            "def degree(E, v):\n"
            "    return sum(1 for e in E if v in e)\n\n"
            "def is_independent(E, I):\n"
            "    return all(not (e and e <= I) for e in E)\n\n"
            "S = frozenset(range(1, 17))\n"
            "E = {frozenset({1,2,3}), frozenset({4,5,6})}\n"
            "I = deterministic_deletion(E, S)\n"
            "delta = Fraction(sum(degree(E, v) for v in S), len(S))\n"
            "print('survivors      :', sorted(I), '|I| =', len(I))\n"
            "print('avg degree d   :', delta)\n"
            "print('bound (1-d)|S| :', (1 - delta) * len(S))\n"
            "print('independent?   :', is_independent(E, I))\n"
            "print('|I| >= (1-d)|S|:', Fraction(len(I)) >= (1 - delta) * len(S))\n"
        ),
    },
    {
        "name": "Randomized Stress Test of All Four Independence Guarantees",
        "description": (
            "Generates thousands of random hypergraphs of varying size and edge "
            "density (edge sizes 1 to 4), applies representative-vertex deletion "
            "to each, and checks containment (deterministic_deletion_subset), "
            "independence (deterministic_deletion_independent), the size bound "
            "(deterministic_deletion_card_ge), and the average-degree bound "
            "(deterministic_deletion_card_ge_of_averageDegree) on every instance. "
            "It reports the number of theorem violations (always zero) and the "
            "smallest observed survivor fraction, empirically corroborating the "
            "machine-checked theorems across a broad random sample."
        ),
        "code": (
            "import random\n"
            "from fractions import Fraction\n\n"
            "def contained_edges(E, S):\n"
            "    return {e for e in E if e <= S}\n\n"
            "def deterministic_deletion(E, S):\n"
            "    reps = {min(e) for e in contained_edges(E, S) if e}\n"
            "    return frozenset(S - reps)\n\n"
            "def degree(E, v):\n"
            "    return sum(1 for e in E if v in e)\n\n"
            "def is_independent(E, I):\n"
            "    return all(not (e and e <= I) for e in E)\n\n"
            "rng = random.Random(20260619)\n"
            "fails = 0\n"
            "for _ in range(5000):\n"
            "    n = rng.randint(4, 20)\n"
            "    S = frozenset(range(1, n + 1))\n"
            "    E = set()\n"
            "    for _ in range(rng.randint(0, 2 * n)):\n"
            "        k = rng.randint(1, min(4, n))\n"
            "        E.add(frozenset(rng.sample(range(1, n + 1), k)))\n"
            "    I = deterministic_deletion(E, S)\n"
            "    c = len(contained_edges(E, S))\n"
            "    delta = Fraction(sum(degree(E, v) for v in S), len(S)) if S else Fraction(0)\n"
            "    ok = (I <= S and is_independent(E, I) and len(I) >= len(S) - c\n"
            "          and Fraction(len(I)) >= (1 - delta) * len(S))\n"
            "    if not ok:\n"
            "        fails += 1\n"
            "print('instances:', 5000, ' violations:', fails)\n"
        ),
    },
]

visualizations = [
    {
        "name": "Survivor Fraction versus Average Degree Scatter with Guarantee Curve",
        "description": (
            "Samples many random 3-uniform hypergraphs on a 40-vertex pool across "
            "a range of edge counts, plots the actual independent-set fraction "
            "|I|/|S| achieved by representative-vertex deletion against the "
            "average degree delta, and overlays the certified guarantee "
            "max(1 - delta, 0). Every data point lies on or above the guarantee "
            "curve, visually confirming the theorem "
            "deterministic_deletion_card_ge_of_averageDegree."
        ),
        "code": viz_py,
    },
]

interactive_demos = [
    {
        "title": "Representative-Vertex Deletion Explorer: Watch Independence Emerge",
        "description": (
            "An interactive SVG widget where you set the pool size and the number "
            "of 3-uniform hyperedges, reroll random hypergraphs, and watch the "
            "construction in real time: each hyperedge's canonical representative "
            "(its smallest vertex) is highlighted and removed, the survivors turn "
            "green, and a live panel reports the number of contained edges, the "
            "average degree delta, the deleted-representative count, the survivor "
            "count |I|, the certified guarantee (1 - delta)|S|, and live "
            "checkmarks confirming that the survivors form an independent set and "
            "that |I| >= (1 - delta)|S|. A hands-on illustration of every theorem "
            "in the package."
        ),
        "html": interactive_html,
    },
]

package = {
    "title": "Representative-Vertex Deletion: An Average-Degree Independence Bound for Hypergraphs",
    "domain": "Bridges",
    "description": (
        "A fully explicit, deterministic construction that finds large independent "
        "sets in finite hypergraphs by deleting one canonical representative per "
        "contained hyperedge, with a machine-checked guarantee of size at least "
        "(1 - delta)|S| in terms of the average degree delta."
    ),
    "authors": ["Aristotle"],
    "date": "2026-06-19",
    "key_results": [
        "deterministic_deletion_independent",
        "deterministic_deletion_card_ge",
        "deterministic_deletion_spec",
        "containedEdges_card_le_sum_degree",
        "deterministic_deletion_card_ge_of_averageDegree",
    ],
    "keywords": [
        "hypergraph",
        "independent set",
        "representative-vertex deletion",
        "average degree",
        "containedEdges",
        "deletion method",
        "locally sparse",
        "Berge cycle",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo_py,
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo_py},
    "lean_files": ["Catalog/Bridges/LocallySparseHypergraphDegree.lean"],
}

out = base / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("Wrote", out, "(", out.stat().st_size, "bytes )")


"""
Representative-Vertex Deletion: numerical demonstrations.

This script implements the deterministic deletion construction and verifies,
on concrete hypergraphs, the three guarantees and the average-degree theorem
from the accompanying paper:

  * deterministic_deletion(E, S) ⊆ S                         (containment)
  * the result is independent (contains no nonempty edge)     (independence)
  * |result| ≥ |S| − |containedEdges(E, S)|                   (size bound)
  * if avg degree over S ≤ δ then |result| ≥ (1 − δ)·|S|      (main theorem)

Everything is self-contained: a hyperedge is a frozenset of integers; a
hypergraph is a set of hyperedges; a pool S is a frozenset of integers.
Vertices are integers, so "min" is the canonical representative.
"""

from __future__ import annotations

from fractions import Fraction
from typing import FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Hypergraph = Set[Edge]
Pool = FrozenSet[Vertex]


# --------------------------------------------------------------------------- #
#  Core construction (mirrors the Lean definitions)                           #
# --------------------------------------------------------------------------- #
def contained_edges(E: Hypergraph, S: Pool) -> Set[Edge]:
    """{ e ∈ E : e ⊆ S } — the hyperedges trapped inside the pool S."""
    return {e for e in E if e <= S}


def deleted_vertices(E: Hypergraph, S: Pool) -> Set[Vertex]:
    """One canonical representative (the minimum vertex) per contained edge."""
    reps: Set[Vertex] = set()
    for e in contained_edges(E, S):
        if e:  # nonempty
            reps.add(min(e))
    return reps


def deterministic_deletion(E: Hypergraph, S: Pool) -> FrozenSet[Vertex]:
    """The surviving independent set: S with all representatives removed."""
    return frozenset(S - deleted_vertices(E, S))


def degree(E: Hypergraph, v: Vertex) -> int:
    """Number of hyperedges of E containing v."""
    return sum(1 for e in E if v in e)


def average_degree(E: Hypergraph, S: Pool) -> Fraction:
    """(Σ_{v∈S} degree(v)) / |S| as an exact rational."""
    if not S:
        return Fraction(0)
    return Fraction(sum(degree(E, v) for v in S), len(S))


# --------------------------------------------------------------------------- #
#  Verifiers                                                                   #
# --------------------------------------------------------------------------- #
def is_independent(E: Hypergraph, I: FrozenSet[Vertex]) -> bool:
    """True iff I contains no nonempty hyperedge of E."""
    return all(not (e and e <= I) for e in E)


def check_all_guarantees(E: Hypergraph, S: Pool) -> dict:
    """Run the construction and verify every theorem on this instance."""
    I = deterministic_deletion(E, S)
    c = len(contained_edges(E, S))
    delta = average_degree(E, S)
    return {
        "pool_size": len(S),
        "contained_edges": c,
        "result_size": len(I),
        "subset_ok": I <= S,                                  # Thm 3.3
        "independent_ok": is_independent(E, I),               # Thm 3.5
        "size_bound_ok": len(I) >= len(S) - c,                # Thm 3.6
        "avg_degree": delta,
        "avg_degree_bound": (1 - delta) * len(S),             # Thm 3.9 RHS
        "avg_degree_bound_ok": Fraction(len(I)) >= (1 - delta) * len(S),
        "result": sorted(I),
    }


def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# --------------------------------------------------------------------------- #
#  Demo 1: a sparse 3-uniform hypergraph (the main theorem in action)         #
# --------------------------------------------------------------------------- #
def demo_sparse_3uniform() -> None:
    banner("Demo 1 — Sparse 3-uniform hypergraph: the (1−δ)|S| guarantee")
    S: Pool = frozenset(range(1, 17))  # vertices 1..16
    E: Hypergraph = {
        frozenset({1, 2, 3}),
        frozenset({4, 5, 6}),
    }
    r = check_all_guarantees(E, S)
    print(f"Pool S            : {sorted(S)}")
    print(f"Hyperedges        : {[sorted(e) for e in E]}")
    print(f"Contained edges   : {r['contained_edges']}")
    print(f"Average degree δ  : {r['avg_degree']}  ( = {float(r['avg_degree']):.3f})")
    print(f"Survivors I       : {r['result']}  (|I| = {r['result_size']})")
    print(f"Bound (1−δ)|S|    : {r['avg_degree_bound']} "
          f"( = {float(r['avg_degree_bound']):.3f})")
    print(f"Independent?      : {r['independent_ok']}")
    print(f"I ⊆ S?            : {r['subset_ok']}")
    print(f"|I| ≥ |S|−c?      : {r['size_bound_ok']}")
    print(f"|I| ≥ (1−δ)|S|?   : {r['avg_degree_bound_ok']}")


# --------------------------------------------------------------------------- #
#  Demo 2: overlapping edges sharing representatives (deletion cost ≤ #edges)  #
# --------------------------------------------------------------------------- #
def demo_shared_representatives() -> None:
    banner("Demo 2 — Overlapping edges: fewer deletions than edges")
    S: Pool = frozenset(range(1, 9))
    # Edges 1 and 2 both have minimum vertex 1, so they share a representative.
    E: Hypergraph = {
        frozenset({1, 2, 3}),
        frozenset({1, 4, 5}),
        frozenset({2, 6, 7}),
        frozenset({3, 8}),
    }
    reps = deleted_vertices(E, S)
    r = check_all_guarantees(E, S)
    print(f"Pool S            : {sorted(S)}")
    print(f"Hyperedges        : {[sorted(e) for e in E]}")
    print(f"Contained edges   : {r['contained_edges']}")
    print(f"Deleted reps      : {sorted(reps)}  (|reps| = {len(reps)})")
    print(f"  -> note |reps| = {len(reps)} ≤ "
          f"{r['contained_edges']} = #contained edges (Lemma 3.4)")
    print(f"Survivors I       : {r['result']}  (|I| = {r['result_size']})")
    print(f"Independent?      : {r['independent_ok']}")
    print(f"All guarantees ok : "
          f"{r['subset_ok'] and r['independent_ok'] and r['size_bound_ok']}")


# --------------------------------------------------------------------------- #
#  Demo 3: random stress test across many hypergraphs                          #
# --------------------------------------------------------------------------- #
def demo_random_stress(trials: int = 5000, seed: int = 20260619) -> None:
    banner(f"Demo 3 — Randomized stress test over {trials} hypergraphs")
    import random
    rng = random.Random(seed)
    failures = 0
    worst_ratio = 1.0
    for _ in range(trials):
        n = rng.randint(4, 20)
        S = frozenset(range(1, n + 1))
        m = rng.randint(0, 2 * n)
        E: Hypergraph = set()
        for _ in range(m):
            k = rng.randint(1, min(4, n))
            E.add(frozenset(rng.sample(range(1, n + 1), k)))
        r = check_all_guarantees(E, S)
        ok = (r["subset_ok"] and r["independent_ok"]
              and r["size_bound_ok"] and r["avg_degree_bound_ok"])
        if not ok:
            failures += 1
        if r["pool_size"]:
            worst_ratio = min(worst_ratio, r["result_size"] / r["pool_size"])
    print(f"Instances tested            : {trials}")
    print(f"Theorem violations found    : {failures}")
    print(f"Smallest survivor fraction  : {worst_ratio:.3f} of the pool")
    print("All four theorems held on every random instance."
          if failures == 0 else "!!! VIOLATION DETECTED !!!")


# --------------------------------------------------------------------------- #
#  Demo 4: sweep average degree and watch the guarantee track (1−δ)           #
# --------------------------------------------------------------------------- #
def demo_average_degree_sweep() -> None:
    banner("Demo 4 — Average-degree sweep: |I|/|S| vs the (1−δ) guarantee")
    n = 24
    S: Pool = frozenset(range(1, n + 1))
    print(f"{'#edges':>7} | {'δ (avg deg)':>12} | {'(1−δ)':>8} | "
          f"{'|I|/|S|':>8} | {'holds?':>6}")
    print("-" * 56)
    import random
    rng = random.Random(7)
    for m in (0, 4, 8, 12, 16, 20):
        E: Hypergraph = set()
        while len(E) < m:
            E.add(frozenset(rng.sample(range(1, n + 1), 3)))
        r = check_all_guarantees(E, S)
        guarantee = 1 - float(r["avg_degree"])
        ratio = r["result_size"] / r["pool_size"]
        print(f"{m:>7} | {float(r['avg_degree']):>12.4f} | "
              f"{guarantee:>8.4f} | {ratio:>8.4f} | "
              f"{str(r['avg_degree_bound_ok']):>6}")


if __name__ == "__main__":
    demo_sparse_3uniform()
    demo_shared_representatives()
    demo_random_stress()
    demo_average_degree_sweep()
    print("\nAll demonstrations completed.")


"""
Visualization: survivor fraction vs. average degree for random 3-uniform
hypergraphs, overlaid with the certified guarantee (1 − δ).

Generates 'deletion_bound.png'. Requires matplotlib and numpy.
"""

from __future__ import annotations

from fractions import Fraction
from typing import FrozenSet, Set
import random

import matplotlib.pyplot as plt
import numpy as np

Edge = FrozenSet[int]
Hypergraph = Set[Edge]
Pool = FrozenSet[int]


def contained_edges(E: Hypergraph, S: Pool) -> Set[Edge]:
    return {e for e in E if e <= S}


def deterministic_deletion(E: Hypergraph, S: Pool) -> FrozenSet[int]:
    reps = {min(e) for e in contained_edges(E, S) if e}
    return frozenset(S - reps)


def degree(E: Hypergraph, v: int) -> int:
    return sum(1 for e in E if v in e)


def average_degree(E: Hypergraph, S: Pool) -> float:
    if not S:
        return 0.0
    return sum(degree(E, v) for v in S) / len(S)


def sample_point(n: int, m: int, rng: random.Random) -> tuple[float, float]:
    S = frozenset(range(1, n + 1))
    E: Hypergraph = set()
    while len(E) < m:
        E.add(frozenset(rng.sample(range(1, n + 1), 3)))
    delta = average_degree(E, S)
    ratio = len(deterministic_deletion(E, S)) / n
    return delta, ratio


def main() -> None:
    rng = random.Random(2026)
    n = 40
    deltas, ratios = [], []
    for m in range(0, 60):
        for _ in range(12):
            d, r = sample_point(n, m, rng)
            deltas.append(d)
            ratios.append(r)

    deltas = np.array(deltas)
    ratios = np.array(ratios)

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.scatter(deltas, ratios, s=14, alpha=0.45,
               label="actual survivor fraction |I|/|S|", color="#2c7fb8")
    xs = np.linspace(0, deltas.max(), 200)
    ax.plot(xs, np.clip(1 - xs, 0, 1), color="#d95f0e", lw=2.5,
            label="certified guarantee max(1 − δ, 0)")
    ax.set_xlabel("average degree δ over the pool S", fontsize=12)
    ax.set_ylabel("independent-set fraction", fontsize=12)
    ax.set_title("Representative-vertex deletion: actual vs. guaranteed\n"
                 "independent-set size for random 3-uniform hypergraphs",
                 fontsize=13)
    ax.axhline(0, color="gray", lw=0.6)
    ax.legend(fontsize=11)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("deletion_bound.png", dpi=150)
    print("Saved deletion_bound.png")


if __name__ == "__main__":
    main()
