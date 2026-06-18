
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

**Title**: Close Proofs: The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` mod
**Domain**: Applications
**Mathematical framing**: Cycle d9001a1b (Q=0.487) proved 10 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — The Minimum-Spanning-Tree Law for `H₀` Persistence and Beyond

## Synthesis

The file `Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean` models the degree-`0` total
persis
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- DIFF: Catalog/Applications/SpeciesAnalyticBridge.lean
--- a/Applications/SpeciesAnalyticBridge.lean
+++ b/Applications/SpeciesAnalyticBridge.lean
@@ -62,10 +62,14 @@
 @[simp] lemma egf_seqOf (f : ℚ⟦X⟧) : egf (seqOf f) = f := by
   ext n; rw [coeff_egf, seqOf]; field_simp
 
-/-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
-exponential generating functions. -/
-theorem egf_injective : Function.Injective egf := by
-  intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]
+-- NOTE (build fix): `egf_injective` is already declared in
+-- `Catalog/Applications/CombinatorialSpecies.lean` in this same namespace, so re-declaring it
+-- here is a duplicate declaration that breaks compilation.  Commented out; all references below
+-- resolve to `CombinatorialSpecies.egf_injective` from the imported base file.
+-- /-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
+-- exponential generating functions. -/
+-- theorem egf_injective : Function.Injective egf := by
+--   intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]
 
 /-- **Surjectivity.** Every formal power series over `ℚ` is the EGF of some counting
 sequence (namely `seqOf`). -/



-- NEW_FILE: Catalog/Speculative/AutoResearch/ProteinFoldingMST.lean
import Mathlib

/-! # The Minimum-Spanning-Tree Law for `H₀` Persistence

This file develops, in a fully constructive and computable setting, the
*Minimum-Spanning-Tree (MST) Law* for degree-`0` persistent homology, the
combinatorial backbone of single-linkage clustering used in (among other things)
protein-folding contact analysis.

## The mathematics

Given a finite point cloud with a symmetric weight (distance) function, the
Vietoris–Rips filtration produces a degree-`0` persistence module.  Its finite
bars are born at time `0` and die exactly at the weights of the edges of a
*minimum spanning tree* (Kruskal's algorithm = single-linkage clustering).  Thus
the multiset of **death times** of `H₀` is precisely the multiset of MST edge
weights.

We package the death times as a `Multiset ℕ` `D`.  The connected-component count
at threshold `t` is

  `β₀(t) = 1 + #{ d ∈ D : t < d }`,

i.e. the one essential class plus every finite bar still alive at time `t`.  The
**total `H₀` persistence** up to a horizon `T` is the discrete area under the
`β₀ - 1` curve,

  `P(T) = ∑_{t < T} (β₀(t) - 1)`.

The central theorem (`layer_cake`) is a discrete Fubini / layer-cake identity:

  `∑_{t < T} #{ d ∈ D : t < d } = ∑_{d ∈ D} min d T`,

whose immediate corollary (`totalPersistence_eq_sum`) is the **MST Law**: once
the horizon dominates every death time,

  `P(T) = ∑_{d ∈ D} d`  =  total weight of the minimum spanning tree.

A concrete Kruskal merge process (`kruskalDeaths`) closes the loop computationally:
on an explicit `4`-vertex graph we verify that its death multiset realises the
*minimum* spanning weight (`mst_persistence_law_example`).

-- !-- Lab Notebook -- !--
-- Hypothesis:  Total H₀ persistence (area under the component-count curve) is an
--   exactly computable telescoping quantity, equal to the sum of death times,
--   which under Kruskal's algorithm is the MST weight.
-- Result:  Proved the discrete layer-cake identity `layer_cake` in full
--   generality over `Multiset ℕ`, giving `totalPersistence_eq_sum`.  Verified the
--   Kruskal correspondence and MST optimality computationally on an explicit graph.
-- Insight:  Persistence ↔ MST is, at the level of *counting*, pure Fubini:
--   `∑_t #{d > t} = ∑_d #{t < d} = ∑_d d`.  No homology machinery is needed for
--   the H₀ *total persistence* — only the death multiset, which Kruskal supplies.
-- Failure analysis:  A real-weighted formulation drags in measure-theoretic
--   integration; restricting to `ℕ` weights keeps everything decidable/`#eval`-able
--   while losing no combinatorial content (rationals rescale to ℕ).
-- !-- Lab Notebook -- !--
-/

namespace ProteinFoldingMST

open Finset

/-! ## The `β₀` curve and total persistence -/

/-- `β₀(t)`: the number of connected components at threshold `t`, given the
multiset `D` of `H₀` death times.  It is the one essential (never-dying) class
plus every finite bar still alive at time `t`. -/
def beta0 (D : Multiset ℕ) (t : ℕ) : ℕ := 1 + (D.filter (fun d => t < d)).card

/-- Total `H₀` persistence accumulated up to horizon `T`: the discrete area under
the `β₀ - 1` curve. -/
def totalPersistence (D : Multiset ℕ) (T : ℕ) : ℕ :=
  ∑ t ∈ Finset.range T, (beta0 D t - 1)

/-- The integrand of total persistence is exactly the number of bars alive at
`t`: `β₀(t) - 1 = #{ d ∈ D : t < d }`. -/
-- !-- `beta0` adds one then we subtract one; `Nat.add_sub_cancel_left`. -- !--
theorem beta0_sub_one (D : Multiset ℕ) (t : ℕ) :
    beta0 D t - 1 = (D.filter (fun d => t < d)).card := by
  simp [beta0]

/-- `totalPersistence` written directly as a sum of alive-bar counts. -/
theorem totalPersistence_eq_card_sum (D : Multiset ℕ) (T : ℕ) :
    totalPersistence D T = ∑ t ∈ Finset.range T, (D.filter (fun d => t < d)).card := by
  simp [totalPersistence, beta0_sub_one]

/-! ## The discrete layer-cake / Fubini identity (heart of the MST Law) -/

/-
!-- The double count `∑_{t<T} #{d∈D : t<d} = ∑_{d∈D} #{t<T : t<d} = ∑_{d∈D} min d T`.
Proven by `Multiset` induction on `D`: the cons step contributes
`∑_{t<T} [t < a] = min a T` on each side. -- !--
-/
theorem layer_cake (D : Multiset ℕ) (T : ℕ) :
    (∑ t ∈ Finset.range T, (D.filter (fun d => t < d)).card)
      = (D.map (fun d => min d T)).sum := by
  induction' D using Multiset.induction with a D ih generalizing T <;> simp_all +decide;
  simp_all +decide [ Finset.sum_add_distrib, Multiset.filter_cons ];
  convert Finset.card_range T |> fun h => congr_arg Finset.card ( show Finset.filter ( fun x => x < a ) ( Finset.range T ) = Finset.range ( Min.min a T ) from ?_ ) using 1;
  · rw [ Finset.card_filter ] ; exact Finset.sum_congr rfl fun x hx => by aesop;
  · grind;
  · grind

/-- `totalPersistence` is the truncated sum of death times. -/
theorem totalPersistence_eq_min_sum (D : Multiset ℕ) (T : ℕ) :
    totalPersistence D T = (D.map (fun d => min d T)).sum := by
  rw [totalPersistence_eq_card_sum, layer_cake]

/-
**The MST Law for `H₀` persistence.**  Once the horizon `T` dominates every
death time, the total `H₀` persistence equals the sum of the death times — i.e.
the total weight of the minimum spanning tree.

!-- Each `min d T = d` since `d ≤ T`, so the truncated sum is `D.sum`. -- !--
-/
theorem totalPersistence_eq_sum (D : Multiset ℕ) (T : ℕ) (hT : ∀ d ∈ D, d ≤ T) :
    totalPersistence D T = D.sum := by
  rw [ totalPersistence_eq_min_sum, Multiset.map_congr rfl fun x hx => min_eq_left ( hT x hx ) ] ; simp +decide

/-! ## Structural properties of the component-count curve -/

/-
`β₀` is antitone in the threshold: raising the connectivity radius can only
merge components, never split them.

!-- Larger `t` shrinks the filtered multiset, hence its card; `Multiset.card_le_card`
of `Multiset.filter_le_filter` (monotone predicate). -- !--
-/
theorem beta0_antitone (D : Multiset ℕ) : Antitone (beta0 D) := by
  intro a b h; unfold beta0;
  gcongr;
  rw [ Multiset.le_iff_count ];
  intro x; by_cases hx : b < x <;> by_cases hx' : a < x <;> simp_all +decide;
  linarith

/-
Above the largest death time the cloud is connected: a single component.

!-- All `d ≤ T`, so `filter (T < ·)` is empty and `β₀ T = 1 + 0`. -- !--
-/
theorem beta0_eventually_one (D : Multiset ℕ) (T : ℕ) (hT : ∀ d ∈ D, d ≤ T) :
    beta0 D T = 1 := by
  unfold beta0; aesop;

/-- At threshold `0` there are `1 + #{positive deaths}` components. -/
theorem beta0_zero (D : Multiset ℕ) :
    beta0 D 0 = 1 + (D.filter (fun d => 0 < d)).card := by
  rfl

/-! ## Constructive Kruskal merge process (single-linkage clustering)

We process edges (already sorted by weight) maintaining a vertex labelling
`ℕ → ℕ` (the component representatives).  An edge whose endpoints lie in distinct
components records a **death** at its w
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
fold already exposes exactly the "
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
