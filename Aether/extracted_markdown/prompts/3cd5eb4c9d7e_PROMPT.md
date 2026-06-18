
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` formalizes th
**Domain**: Novelty
**Mathematical framing**: # Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

## Synthesis

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` formalizes the
degree-`0` total-persistence law in a fully constructive, computable setting. The
mathematical core turned out to be far cleaner than the homological framing
suggests: once the *death multiset* `D` of the `H₀` persistence diagram is fixed,
the entire connectivity history of a single-linkage filtration is recoverable by
elementary counting. We proved

- `layer_cake` — the discrete Fubini / layer-cake identity
  `∑_{t<T} #{d∈D : t<d} = ∑_{d∈D} min d T`, the engine of everything else;
- `totalPersistence_eq_sum` — **the MST Law**: for a horizon dominating every
  death, total `H₀` persistence equals `∑_{d∈D} d`, i.e. the total weight of a
  minimum spanning tree;
- `beta0_antitone` and `beta0_eventually_one` — the component-count curve is
  monotone non-increasing and reaches a single component above the largest death;
- a constructive Kruskal merge process (`kruskalDeaths`) plus a `decide`-checked
  optimality theorem (`mst_optimal_ex`) and the capstone
  `mst_persistence_law_example`, which on an explicit `4`-vertex graph ties the
  persistence side to the optimization side.

This is a deliberate cross-domain bridge: it links **topological data analysis**
(`H₀` persistence), **combinatorial optimization** (minimum spanning trees /
Kruskal), and **order-theoretic counting** (the layer-cake identity), and it
connects naturally to the catalog's Fibonacci/entry-point work in
`CarmichaelComposite.lean` and `FibPrimitive.lean` only at the meta level of
"extract the decisive discrete invariant, then count."

## Results Summary

Four `sorry`-free theorems of genuine content (`layer_cake`,
`totalPersistence_eq_sum`, `beta0_antitone`, `beta0_eventually_one`), three
`rfl`/`decide`-level verification theorems (`kruskalDeaths_ex`,
`kruskal_weight_ex`, `mst_optimal_ex`), and one capstone conjunction
(`mst_persistence_law_example`). All depend only on `propext`,
`Classical.choice`, `Quot.sound`. Everything is computable: `kruskalDeaths`,
`beta0`, `totalPersistence`, `spans`, and `wsum` all run under `#eval`.

## Research Directions

### 1. Kruskal correctness in general: deaths = MST edge weights for arbitrary graphs

Right now MST optimality is verified only on an explicit graph by `decide`. The
falsifiable claim is that for *every* finite weighted graph whose edge list is
sorted by weight, the multiset `kruskalDeaths es` equals the multiset of edge
weights of some minimum spanning tree, and its sum is `≤ wsum s` for every
spanning subset `s`. **The key insight is** that a merge happens precisely when an
edge joins two distinct components, so the merge-edges form an independent set of
the graphic matroid grown greedily — the matroid exchange property then forces
optimality with no geometry involved. **Why now?** The constructive `kstep`/`kruskalAux`
fold already exposes exactly the "distinct component" test the matroid argument
needs, so the proof reduces to a clean invariant on the labelling function rather
than to homology.

### 2. The `β₀` curve is the right-continuous step function with exactly `card D` jumps

We proved `beta0` is antitone and eventually `1`. The sharper, falsifiable
statement is that `beta0 D` jumps by exactly the multiplicity of each death value
and is otherwise constant, so that `beta0 D 0 - 1 = (D.filter (0 < ·)).card`
counts all finite bars and the total number of jumps equals `D.card`. **The key
insight is** that `#{d∈D : t<d}` decreases by `count v D` exactly as `t` crosses
`v`, making `beta0` a literal survival function of the death distribution. **Why
now?** With `layer_cake` in hand, the jump structure is the differenced version of
an identity we already control, so it is a short step rather than new theory.

### 3. Stability: total persistence is `1`-Lipschitz in the death multiset

A cornerstone of TDA is the stability theorem. Here it specializes to a sharp,
falsifiable bound: if two death multisets `D`, `D'` of equal cardinality are
matched so that the `k`-th smallest deaths differ by at most `ε`, then
`|totalPersistence D T − totalPersistence D' T| ≤ card D · ε`, and in fact the
bottleneck/Wasserstein-1 distance equals `∑_k |sort(D)_k − sort(D')_k|`. **The key
insight is** that under the MST Law total persistence is a sorted-`ℓ¹` functional
of the death vector, so classical rearrangement inequalities give stability
directly. **Why now?** The `min d T` truncation already proven in
`totalPersistence_eq_min_sum` is exactly the clipping that makes the Lipschitz
constant finite and explicit.

### 4. Higher horizons and the integrated lifetime functional

Generalize `totalPersistence` to a weighted area `∑_{t<T} g(t)·(beta0 D t − 1)`
for monotone weights `g`, modelling persistence-weighted descriptors used in
protein contact maps. The falsifiable claim: this equals `∑_{d∈D} G(min d T)`
where `G` is the discrete antiderivative of `g`, a weighted layer-cake identity.
**The key insight is** that the unweighted proof is the `g ≡ 1` case of an Abel
summation that goes through verbatim for any nonnegative weight. **Why now?** The
inductive `layer_cake` proof is structured exactly as the cons-step accumulation
that Abel summation needs, so the generalization reuses the same skeleton.

### 5. From multiset to point cloud: a verified single-linkage dendrogram

Close the modelling gap by defining a metric point cloud on `Fin n`, deriving its
sorted edge list, and proving the produced `kruskalDeaths` multiset is an
*invariant* of the cloud (independent of tie-breaking order among equal weights).
The falsifiable claim: two different sorted edge orders of the same weighted graph
yield equal `kruskalDeaths` multisets. **The key insight is** that ties merge the
same components regardless of order because the union-find state after processing
all edges of a given weight is order-independent — a confluence property of the
fold. **Why now?** `kruskalAux` is already a deterministic fold over an explicit
list, so order-independence is a concrete commutation lemma we can state and test
with `#eval` before proving.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean
import Mathlib

/-! # The Minimum-Spanning-Tree Law for `H₀` Persistence

This file formalizes the degree-`0` total-persistence law of topological data
analysis in a fully constructive, computable setting.  The homological framing
("persistent `H₀` of a single-linkage filtration") collapses, once the *death
multiset* `D` of the persistence diagram is fixed, to elementary order-theoretic
counting:

* `layer_cake` — the discrete Fubini / layer-cake identity
  `∑_{t<T} #{d ∈ D : t < d} = ∑_{d ∈ D} min d T`.
* `totalPersistence_eq_sum` — **the MST Law**: for a horizon `T` dominating every
  death, total `H₀` persistence equals `∑_{d ∈ D} d`, the total weight of a
  minimum spanning tree.
* `beta0_antitone`, `beta0_eventually_one` — the component-count curve `β₀` is
  monotone non-increasing and reaches a single component above the largest death.
* A constructive Kruskal merge process (`kruskalDeaths`) with `decide`-checked
  optimality (`mst_optimal_ex`) and a capstone (`mst_persistence_law_example`)
  tying the persistence side to the optimization side on an explicit graph.

This is a cross-domain bridge between **topological data analysis** (`H₀`
persistence), **combinatorial optimization** (minimum spanning trees / Kruskal),
and **order-theoretic counting** (the layer-cake identity).
-/

namespace ProteinFoldingMST

/-! ## Persistence-side definitions

`D : Multiset ℕ` is the multiset of *death* values of the `H₀` persistence
diagram (equivalently, the edge weights of a minimum spanning tree of the
single-linkage filtration).  A point cloud with `N` points produces a diagram
with `N - 1` finite bars `[0, d)`; the one essential bar `[0, ∞)` is the `+1`
appearing in `beta0`. -/

/-- The `β₀` curve: number of connected components present at filtration value
`t`.  It is `1` (the essential component) plus the number of bars still alive,
i.e. the number of deaths strictly exceeding `t`. -/
def beta0 (D : Multiset ℕ) (t : ℕ) : ℕ := (D.filter (fun d => t < d)).card + 1

/-- Total `H₀` persistence accumulated up to horizon `T`: the discrete area under
the curve `t ↦ β₀(t) - 1`, i.e. `∑_{t<T} #{d ∈ D : t < d}`. -/
def totalPersistence (D : Multiset ℕ) (T : ℕ) : ℕ :=
  ∑ t ∈ Finset.range T, (D.filter (fun d => t < d)).card

-- !-- Proof sketch (layer_cake): induct on `T`. The cons-step adds the single
-- new column `t = T`, whose height is `#{d : T < d}`, which is exactly
-- `∑_d (min d (T+1) - min d T)` since `min d (T+1) = min d T + [T < d]`. -- !--
/-- **Layer-cake / discrete Fubini identity.** Summing the survival counts
column-by-column equals summing the truncated deaths row-by-row. This is the
engine behind every quantitative statement in the file. -/
theorem layer_cake (D : Multiset ℕ) (T : ℕ) :
    totalPersistence D T = (D.map (fun d => min d T)).sum := by
  unfold totalPersistence
  induction' D using Multiset.induction with d D ih generalizing T <;> simp_all +decide
  simp_all +decide [ ← ih ]
  induction T <;> simp_all +decide [ Finset.sum_range_succ, Multiset.filter_cons ]
  split_ifs <;> simp_all +arith +decide
  · linarith
  · grind +splitIndPred

-- !-- Proof sketch (eq_sum): apply `layer_cake`; when every death is `≤ T`,
-- `min d T = d`, so the truncated sum collapses to `D.sum`. -- !--
/-- **The MST Law.** For a horizon `T` dominating every death, total `H₀`
persistence equals the sum of the deaths — the total weight of a minimum
spanning tree of the single-linkage filtration. -/
theorem totalPersistence_eq_sum (D : Multiset ℕ) (T : ℕ) (hT : ∀ d ∈ D, d ≤ T) :
    totalPersistence D T = D.sum := by
  convert layer_cake D T;
  rw [ Multiset.map_congr rfl ];
  exacts [ by rw [ Multiset.map_id ], fun x hx => min_eq_left ( hT x hx ) ]

-- !-- Proof sketch (antitone): `s ≤ t` implies `{d : t < d} ⊆ {d : s < d}` as
-- a sub-multiset, so the filtered cardinalities are monotone, hence `beta0`
-- is antitone. -- !--
/-- The component-count curve `β₀` is monotone non-increasing in the filtration
value: merging only ever decreases the number of components. -/
theorem beta0_antitone (D : Multiset ℕ) : Antitone (beta0 D) := by
  intro s t hst; unfold beta0;
  exact Nat.succ_le_succ ( Multiset.card_le_card <| Multiset.le_iff_count.mpr fun x => by by_cases hx : t < x <;> by_cases hx' : s < x <;> simp_all +decide ; linarith )

-- !-- Proof sketch (eventually_one): if every death is `≤ t` then the filter
-- `t < d` is empty, its card is `0`, and `beta0 = 0 + 1 = 1`. -- !--
/-- Above the largest death there is a single connected component: `β₀ ≡ 1`. -/
theorem beta0_eventually_one (D : Multiset ℕ) (t : ℕ) (ht : ∀ d ∈ D, d ≤ t) :
    beta0 D t = 1 := by
  -- By definition of `beta0`, we have `beta0 D t = (D.filter (fun d => t < d)).card + 1`.
  simp [beta0];
  assumption

/-! ## Optimization side: a constructive Kruskal merge process

Vertices are `0, …, n-1`; an edge is a triple `(w, a, b)` (weight, endpoints).
The component structure is a `List ℕ` of labels indexed by vertex; processing the
edges in weight order, an edge whose endpoints lie in distinct components merges
them and records its weight as a *death*.  The recorded death multiset is exactly
the multiset of edge weights of the minimum spanning tree (Kruskal). -/

/-- Relabel every vertex currently carrying component id `old` to `new`. -/
def relabel (labels : List ℕ) (old new : ℕ) : List ℕ :=
  labels.map (fun c => if c = old then new else c)

/-- One Kruskal step: merge the endpoints' components and record the weight as a
death iff the endpoints lie in distinct components. -/
def kstep (st : List ℕ × List ℕ) (e : ℕ × ℕ × ℕ) : List ℕ × List ℕ :=
  let labels := st.1
  let deaths := st.2
  let ca := labels.getD e.2.1 0
  let cb := labels.getD e.2.2 0
  if ca = cb then st else (relabel labels cb ca, deaths ++ [e.1])

/-- Fold the Kruskal step over a (weight-sorted) edge list, starting from the
discrete partition `List.range n`. -/
def kruskalRun (n : ℕ) (es : List (ℕ × ℕ × ℕ)) : List ℕ × List ℕ :=
  es.foldl kstep (List.range n, [])

/-- The multiset (here, list) of recorded deaths = MST edge weights. -/
def kruskalDeaths (n : ℕ) (es : List (ℕ × ℕ × ℕ)) : List ℕ := (kruskalRun n es).2

/-- All entries of a label list are equal (one connected component). -/
def allEqual (l : List ℕ) : Bool := l.all (· == l.headD 0)

/-- A set of edges spans all `n` vertices (single component after union). -/
def spans (n : ℕ) (es : List (ℕ × ℕ × ℕ)) : Bool := allEqual (kruskalRun n es).1

/-- Total weight of an edge set. -/
def wsum (es : List (ℕ × ℕ × ℕ)) : ℕ := (es.map Prod.fst).sum

/-- A concrete `4`-vertex graph (a path plus one cycle-closing chord). -/
def exampleEdges : List (ℕ × ℕ × ℕ) := [(1,0,1),(2,1,2),(3,2,3),(4,0,3)]

/-- Kruskal on the example records exactly the path weights `[1,2,3]`. -/
theorem kruskalDeaths_ex : kruskalDeaths 4 exampleEdges = [1, 2, 3] := by decide

/-- The MST weight of the example is `6`. -/
theorem kruskal_weight_ex : (kruskalDeaths 4 exampleEdges).sum = 6 := by decide

-- !-- Proof sketch (optimality): brute-force over all `2^4` edge subsets; every
-- spanning subset has weight `≥ 6`, the Kruskal optimum. Verified by `decide`. -- !--
/-- **MST optimality (explicit graph).** Among all spanning subsets of the
example graph, the Kruskal selection has minimum total weight. -/
theorem mst_optimal_ex :
    ∀ s ∈ exampleEdges.sublists, spans 4 s = true →
      (kruskalDeaths 4 exampleEdges).sum ≤ wsum s := by decide

-- !-- Proof sketch (capstone): combine `kruskal_weight_ex` with `mst_optimal_ex`
-- and `totalPersistence_eq_sum` (horizon `3`) to identify the persistence-side
-- area with the optimization-side minimum weight, both equal to `6`. -- !--
/-- **Capstone: the MST persistence law on an explicit graph.** The
persistence-side area (`totalPersistence` of the death multiset, with a horizon
dominating all deaths) equals the optimization-side minimum spanning weight,
both equal to `6`, and the Kruskal selection is 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

## Synthesis

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` formalizes the
degree-`0` total-persistence law in a fully constructive, computable setting. The
mathematical core turned out to be far cleaner than the homological framing
suggests: once the *death multiset* `D` of the `H₀` persistence diagram is fixed,
the entire connectivity history of a single-linkage filtration is recoverable by
elementary counting. We proved

- `layer_cake` — the discrete Fubini / layer-cake identity
  `∑_{t<T} #{d∈D : t<d} = ∑_{d∈D} min d T`, the engine of everything else;
- `totalPersistence_eq_sum` — **the MST Law**: for a horizon dominating every
  death, total `H₀` persistence equals `∑_{d∈D} d`, i.e. the total weight of a
  minimum spanning tree;
- `beta0_antitone` and `beta0_eventually_one` — the component-count curve is
  monotone non-increasing and reaches a single component above the largest death;
- a constructive Kruskal merge process (`kruskalDeaths`) plus a `decide`-checked
  optimality theorem (`mst_optimal_ex`) and the capstone
  `mst_persistence_law_example`, which on an explicit `4`-vertex graph ties the
  persistence side to the optimization side.

This is a deliberate cross-domain bridge: it links **topological data analysis**
(`H₀` persistence), **combinatorial optimization** (minimum spanning trees /
Kruskal), and **order-theoretic counting** (the layer-cake identity), and it
connects naturally to the catalog's Fibonacci/entry-point work in
`CarmichaelComposite.lean` and `FibPrimitive.lean` only at the meta level of
"extract the decisive discrete invariant, then count."

## Results Summary

Four `sorry`-free theorems of genuine content (`layer_cake`,
`totalPersistence_eq_sum`, `beta0_antitone`, `beta0_eventually_one`), two
`decide`-level verification theorems (`kruskalDeaths_ex`, `kruskal_weight_ex`),
an explicit-graph optimality theorem (`mst_optimal_ex`), and one capstone
conjunction (`mst_persistence_law_example`). All depend only on `propext`,
`Classical.choice`, `Quot.sound` (the brute-force optimality theorem needs only
`propext`). Everything is computable: `kruskalDeaths`, `beta0`,
`totalPersistence`, `spans`, and `wsum` all run under `#eval`.

## Research Directions

### 1. Kruskal correctness in general: deaths = MST edge weights for arbitrary graphs

Right now MST optimality is verified only on an explicit graph by `decide`. The
falsifiable claim is that for *every* finite weighted graph whose edge list is
sorted by weight, the multiset `kruskalDeaths es` equals the multiset of edge
weights of some minimum spanning tree, and its sum is `≤ wsum s` for every
spanning subset `s`. **The key insight is** that a merge happens precisely when an
edge joins two distinct components, so the merge-edges form an independent set of
the graphic matroid grown greedily — the matroid exchange property then forces
optimality with no geometry involv
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
