
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
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
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
  "research_paper_tex": "RESEARCH_PAPER.tex",
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

**Title**: Metric filtration rank profiles as tropical valuation objects
**Domain**: Bridges
**Mathematical framing**: 
Research domain: Bridges
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 6ce4a7be_retry3_aristotle/Catalog/Geometry/SingleLinkageUltrametric.lean
import Mathlib

/-!
# The single-linkage ultrametric from finite Rips graph filtrations

For a finite type `α` equipped with a dissimilarity function `d : α → α → ℝ`, we
build the *Rips graph* `ripsGraphOf d ε` at scale `ε`, in which two distinct
points are adjacent when at least one of the two directed dissimilarities is at
most `ε`.  Two points are *connected at scale `ε`*, written `ConnAt d ε x y`,
when they are reachable in this graph.

The single-linkage threshold `connThreshold d x y` is the least scale (among the
finitely many relevant candidate scales) at which `x` and `y` become connected.
We prove that this threshold satisfies the strong (ultrametric) triangle
inequality

`connThreshold d x y ≤ max (connThreshold d x z) (connThreshold d z y)`

together with symmetry, the upper bound by the direct dissimilarity, and the
reflexive `connThreshold d x x = 0` (under nonnegativity of `d`).

The development is finite-combinatorial throughout: the candidate scales form a
`Finset` (`0` together with all values `d a b`), and the threshold is the `min'`
of the nonempty subset of candidate scales at which the points are connected.

The instance `[DecidableEq α]` is kept as part of the requested finite setting;
it turns out to be unnecessary for the mathematics below (only `[Fintype α]` is
used, with decidability of the predicates on `ℝ` supplied classically), so it is
explicitly `omit`-ted from the individual statements that do not need it.
-/

open scoped Classical

namespace SingleLinkage

/-! ## The Rips graph and connectivity at a scale -/

variable {α : Type*}

/-- The Rips graph of `d` at scale `ε`: distinct points are adjacent when one of
the two directed dissimilarities is at most `ε`. -/
def ripsGraphOf (d : α → α → ℝ) (ε : ℝ) : SimpleGraph α where
  Adj x y := x ≠ y ∧ (d x y ≤ ε ∨ d y x ≤ ε)
  symm := by
    intro x y h
    refine ⟨h.1.symm, ?_⟩
    rcases h.2 with h2 | h2
    · exact Or.inr h2
    · exact Or.inl h2
  loopless := ⟨fun x h => h.1 rfl⟩

/-- `x` and `y` are connected at scale `ε` when they are reachable in the Rips
graph at scale `ε`. -/
def ConnAt (d : α → α → ℝ) (ε : ℝ) (x y : α) : Prop :=
  (ripsGraphOf d ε).Reachable x y

/-- Adjacency in the Rips graph is monotone in the scale. -/
theorem ripsGraphOf_mono (d : α → α → ℝ) {ε ε' : ℝ} (h : ε ≤ ε') :
    ripsGraphOf d ε ≤ ripsGraphOf d ε' := by
  intro x y hxy
  refine ⟨hxy.1, ?_⟩
  rcases hxy.2 with hle | hle
  · exact Or.inl (le_trans hle h)
  · exact Or.inr (le_trans hle h)

/-- Connectivity is monotone in the scale. -/
theorem ConnAt.mono (d : α → α → ℝ) {ε ε' : ℝ} (h : ε ≤ ε') {x y : α}
    (hc : ConnAt d ε x y) : ConnAt d ε' x y :=
  SimpleGraph.Reachable.mono (ripsGraphOf_mono d h) hc

/-- Every point is connected to itself at every scale. -/
theorem ConnAt.refl (d : α → α → ℝ) (ε : ℝ) (x : α) : ConnAt d ε x x :=
  SimpleGraph.Reachable.refl x

/-- Connectivity is symmetric. -/
theorem ConnAt.symm (d : α → α → ℝ) {ε : ℝ} {x y : α} (hc : ConnAt d ε x y) :
    ConnAt d ε y x :=
  SimpleGraph.Reachable.symm hc

/-- Symmetric characterisation of connectivity. -/
theorem ConnAt.comm (d : α → α → ℝ) (ε : ℝ) (x y : α) :
    ConnAt d ε x y ↔ ConnAt d ε y x :=
  ⟨ConnAt.symm d, ConnAt.symm d⟩

/-- Composition through an intermediate point at the `max` scale. -/
theorem ConnAt.trans_max (d : α → α → ℝ) {e1 e2 : ℝ} {x y z : α}
    (hxy : ConnAt d e1 x y) (hyz : ConnAt d e2 y z) :
    ConnAt d (max e1 e2) x z :=
  SimpleGraph.Reachable.trans
    (ConnAt.mono d (le_max_left e1 e2) hxy) (ConnAt.mono d (le_max_right e1 e2) hyz)

/-- A single edge connects distinct points at scale `d x y`. -/
theorem ConnAt.of_ne (d : α → α → ℝ) {x y : α} (h : x ≠ y) :
    ConnAt d (d x y) x y :=
  SimpleGraph.Adj.reachable ⟨h, Or.inl le_rfl⟩

/-- Any two points are connected at scale `d x y`. -/
theorem ConnAt.of_dist (d : α → α → ℝ) (x y : α) : ConnAt d (d x y) x y := by
  by_cases h : x = y
  · subst h; exact ConnAt.refl d (d x x) x
  · exact ConnAt.of_ne d h

/-! ## Candidate scales and the connectivity threshold -/

variable [Fintype α] [DecidableEq α]

/-- The finite set of candidate scales: `0` together with all values `d a b`. -/
noncomputable def scales (d : α → α → ℝ) : Finset ℝ :=
  insert 0 (Finset.image (fun p : α × α => d p.1 p.2) Finset.univ)

omit [DecidableEq α] in
/-- `0` is a candidate scale. -/
theorem zero_mem_scales (d : α → α → ℝ) : (0 : ℝ) ∈ scales d :=
  Finset.mem_insert_self _ _

omit [DecidableEq α] in
/-- Every dissimilarity value is a candidate scale. -/
theorem dist_mem_scales (d : α → α → ℝ) (x y : α) : d x y ∈ scales d :=
  Finset.mem_insert_of_mem (Finset.mem_image.mpr ⟨(x, y), Finset.mem_univ _, rfl⟩)

/-- The candidate scales at which `x` and `y` are connected. -/
noncomputable def connScales (d : α → α → ℝ) (x y : α) : Finset ℝ :=
  (scales d).filter (fun ε => ConnAt d ε x y)

omit [DecidableEq α] in
theorem mem_connScales {d : α → α → ℝ} {x y : α} {ε : ℝ} :
    ε ∈ connScales d x y ↔ ε ∈ scales d ∧ ConnAt d ε x y := by
  simp [connScales]

omit [DecidableEq α] in
/-- The set of connecting candidate scales is nonempty. -/
theorem connScales_nonempty (d : α → α → ℝ) (x y : α) :
    (connScales d x y).Nonempty :=
  ⟨d x y, mem_connScales.mpr ⟨dist_mem_scales d x y, ConnAt.of_dist d x y⟩⟩

/-- The single-linkage connectivity threshold: the least candidate scale at
which `x` and `y` are connected. -/
noncomputable def connThreshold (d : α → α → ℝ) (x y : α) : ℝ :=
  (connScales d x y).min' (connScales_nonempty d x y)

omit [DecidableEq α] in
/-- The threshold is itself a candidate scale. -/
theorem connThreshold_mem_scales (d : α → α → ℝ) (x y : α) :
    connThreshold d x y ∈ scales d :=
  (mem_connScales.mp (Finset.min'_mem _ _)).1

omit [DecidableEq α] in
/-- **Specification.** The points are connected at the threshold scale. -/
theorem connThreshold_spec (d : α → α → ℝ) (x y : α) :
    ConnAt d (connThreshold d x y) x y :=
  (mem_connScales.mp (Finset.min'_mem _ _)).2

omit [DecidableEq α] in
/-- **Minimality.** The threshold is at most any candidate scale at which the
points are connected. -/
theorem connThreshold_le_of_mem (d : α → α → ℝ) {x y : α} {ε : ℝ}
    (hε : ε ∈ scales d) (hc : ConnAt d ε x y) :
    connThreshold d x y ≤ ε :=
  Finset.min'_le _ _ (mem_connScales.mpr ⟨hε, hc⟩)

omit [DecidableEq α] in
/-- The self-threshold is at most `0`. -/
theorem connThreshold_self_le_zero (d : α → α → ℝ) (x : α) :
    connThreshold d x x ≤ 0 :=
  connThreshold_le_of_mem d (zero_mem_scales d) (ConnAt.refl d 0 x)

omit [DecidableEq α] in
/-- **Reflexivity.** Under nonnegativity of `d`, the self-threshold is `0`.

The nonnegativity hypothesis is genuinely required: without it the candidate
scales can be negative, and the self-threshold equals the smallest candidate
scale, which may be below `0`. -/
theorem connThreshold_self (d : α → α → ℝ) (hd : ∀ a b, 0 ≤ d a b) (x : α) :
    connThreshold d x x = 0 := by
  refine le_antisymm (connThreshold_self_le_zero d x) ?_
  have hmem := connThreshold_mem_scales d x x
  rcases Finset.mem_insert.mp hmem with h | h
  · exact h.ge
  · obtain ⟨p, -, hp⟩ := Finset.mem_image.mp h
    rw [← hp]
    exact hd p.1 p.2

omit [DecidableEq α] in
/-- **Symmetry.** The threshold is symmetric in its two arguments. -/
theorem connThreshold_comm (d : α → α → ℝ) (x y : α) :
    connThreshold d x y = connThreshold d y x := by
  apply le_antisymm
  · exact connThreshold_le_of_mem d (connThreshold_mem_scales d y x)
      (ConnAt.symm d (connThreshold_spec d y x))
  · exact connThreshold_le_of_mem d (connThreshold_mem_scales d x y)
      (ConnAt.symm d (connThreshold_spec d x y))

omit [DecidableEq α] in
/-- **Upper bound.** The threshold never exceeds the direct dissimilarity. -/
theorem connThreshold_le_dist (d : α → α → ℝ) (x y : α) :
    connThreshold d x y ≤ d x y :=
  connThreshold_le_of_mem d (dist_mem_scales d x y) (ConnAt.of_dist d x y)

omit [DecidableEq α] in
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Metric Filtration Rank Profiles as Tropical Valuation Objects

This research cycle established (file
`Catalog/Bridges/MetricFiltrationTropicalProfile.lean`, all theorems verified, 0 sorries,
axioms `propext`/`Classical.choice`/`Quot.sound` only) that the connectivity data of a finite
metric (Rips) filtration is a **tropical valuation object**:

* the *merge scale* `connThreshold` is an ultrametric whose strong triangle inequality is the
  tropical `max`-additive law (`connThreshold_isUltrametric`);
* it is *attained* / minimax (`connThreshold_attained`, `connAt_iff_threshold_le`);
* it is *subdominant* (`connThreshold_le_dist`) and, in fact, **the greatest** subdominant
  ultrametric (`isUltrametric_le_connThreshold` — was Conjecture C1, now proved);
* the construction is **idempotent** on ultrametric spaces
  (`connThreshold_eq_dist_of_isUltrametric` — was Conjecture C5, now proved);
* it is *functorial* under nonexpansive maps (`connThreshold_nonexpansive_map`);
* the π₀ rank profile `compCount` is antitone in scale (`compCount_antitone`).

Below are bold, falsifiable conjectures for the next cycles. Each is stated so it can be
formalized directly as a Lean theorem (or disproved by a counterexample).

## Conjecture C2 — π₀ persistence / barcode identity
The rank profile is a step function whose jumps are exactly the distinct merge scales.
Formally, for a finite nonempty space, `compCount α ε` equals `Nat.card α` minus the number
of "independent" merges with threshold `≤ ε`; equivalently the number of distinct values of
`connThreshold` that are `≤ ε` (counted with merge multiplicity) equals
`Nat.card α - compCount α ε`. **Test:** induct on `criticalScales`; relate component merges
to edges of a minimum spanning tree (Kruskal / single-linkage dendrogram).

## Conjecture C3 — Bottleneck / Lipschitz stability of the profile
The merge-scale ultrametric is `1`-Lipschitz in the underlying metric: if `d₁, d₂` are two
pseudometrics on the same finite carrier with `∀ a b, |d₁ a b - d₂ a b| ≤ δ`, then
`|connThreshold₁ x y - connThreshold₂ x y| ≤ δ` for all `x, y`. This is the π₀ case of the
persistence stability theorem. **Test:** symmetric application of the functoriality method
(`connAt_map_of_nonexpansive`) with the identity map between the two metrics.

## Conjecture C4 — Genuine tropical-valuation-object instance and a faithful functor
Construct an explicit `CategoricalTropicalUltrametric.TropicalValuationObject` whose order
and `max_op` are realized by `connThreshold`, and assemble a `TropHom` (resp. `UltraHom`)
from each nonexpansive map (using `connThreshold_nonexpansive_map`). Conjecture: this
assignment is a **faithful functor** from the category of finite pseudometric spaces &
nonexpansive maps to tropical valuation objects. **Test:** discharge the structure axioms;
faithfulness from injectivity of the induced map on merge-scale tables.

## Conjecture C6 — Kruskal / minimum-spanning-tree identity
On a finite metric space, 
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
