
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

**Title**: Kripke-semantic core of Gödel–Löb provability logic
**Domain**: Applications
**Mathematical framing**: # Future Directions: Polymodal Provability, Ordinal Ranks, and the Category of GL Frames

## Synthesis

This cycle extended the Kripke-semantic core of Gödel–Löb provability logic
(`Catalog/Logic/GLKripke.lean`'s `GLFrame`, `gl_frame_validates_loeb`,
`gl_frame_well_founded`) in three directions that the previous GL cycle flagged as
open, and which together push the frame theory toward set theory, proof theory, and
category theory. The unifying structural insight is that **the defining feature of a
GL frame — converse well-foundedness of accessibility — is exactly enough to carry an
ordinal rank**, and that this rank, once available frame-internally, behaves
functorially under the polymodal and product constructions. Concretely, `GLFrame.rank`
assigns every world an ordinal from the well-foundedness of `flip R`, and
`gl_rank_lt_of_R` shows it strictly drops along accessibility; this is the qualitative,
*every-frame* generalization of the quantitative `natBox_iterate_eq_Iio` computation
from `Catalog/Logic/LobNatModel.lean`, where the rank of world `n` of the canonical
frame `(ℕ, >)` is literally `n`.

Building on that rank, we formalized **polymodal GLP frames** (`GLPFrame`): one world
set with a nested family `R₀ ⊇ R₁ ⊇ ⋯` of transitive irreflexive relations. The key
discovery here is a *reduction*, not a new soundness proof — each level `GLPFrame.level n`
is a genuine `GLFrame`, so the entire single-modal apparatus (Löb, well-foundedness,
rank) applies level by level (`glp_level_validates_loeb`, `glp_level_rank_lt`).
Monotonicity of the boxes in the index (`glp_box_mono_in_level`) is the frame-semantic
root of the GLP axiom `[n]φ → [n+1]φ`, and it falls directly out of the antitone
nesting of the relations (`R_anti`). What initially looked like it might need a separate
polymodal Löb argument turned out to be a corollary of the single-modal theory plus the
nesting bookkeeping.

The third strand opens the **category of GL frames**: the synchronized product
`GLFrame.prod` is again a GL frame, and the diamond of a rectangle factors *exactly* as
a rectangle of diamonds (`prod_diamond_rectangle`). The failure analysis is as
informative as the theorem: the box operator does **not** factor, because a world with
no successor in one coordinate makes `□` vacuously true there — so the categorical
product is detected by `◇`, not `□`. This asymmetry (◇ factors, □ does not) is the
seed for the next cycle's categorical-logic direction.

## Results Summary

- `GLFrame.flip_wellFounded`: proved — the converse accessibility relation of any GL frame is well-founded (converse well-foundedness), the structural fact underlying ordinal ranks.
- `gl_rank_lt_of_R`: proved — every GL frame carries an ordinal rank `GLFrame.rank` that strictly decreases along accessibility, a frame-internal ordinal analysis.
- `GLPFrame.R_anti`: proved — the polymodal accessibility family is antitone in the index (`R m ⊆ R n` for `n ≤ m`).
- `GLPFrame.glp_level_validates_loeb`: proved — every modality of a GLP frame validates Löb's axiom, reducing polymodal soundness to the single-modal case.
- `GLPFrame.glp_box_mono_in_level`: proved (axiom-free) — higher polymodal boxes are weaker (`□ₙS ⊆ □ₘS` for `n ≤ m`), the semantic content of `[n]φ → [n+1]φ`.
- `GLPFrame.glp_level_rank_lt`: proved — ordinal rank strictly decreases along each modality `R n`.
- `GLFrame.prod_diamond_rectangle`: proved — in the synchronized product, `◇(A ×ˢ B) = (◇A) ×ˢ (◇B)`, the modal signature of a categorical product.
- `GLFrame.prod_validates_loeb`: proved — synchronized products of GL frames preserve Löb's axiom (the product is an object of the same category).

## Research Directions

### Direction 1: An ε₀-valued rank for the standard polymodal frame
**Hypothesis**: There is a concrete `GLPFrame` on an ordinal-indexed world set whose
level-0 `GLFrame.rank` of the standard world equals `ε₀`, with higher levels realizing
the Veblen/Japaridze tower `ω`, `ω^ω`, …, reproducing the proof-theoretic ordinal of PA.
**Test**: Instantiate `GLPFrame` with `World := Ordinal` below ε₀ and `R n` a level-shifted
order, then compute `(level 0).rank` of the top world and prove it equals `ε₀` using the
already-proved `gl_rank_lt_of_R` as the descent lemma.
**Why now**: This cycle just produced a *general* ordinal rank (`GLFrame.rank`) valid in
every GL frame; previously there was only the ℕ-valued rank of `(ℕ,>)`. The rank now
takes ordinal values, so an ε₀ target is type-correct and the descent inequality is in hand.
**If true**: First machine-verified bridge from polymodal frame semantics to a named
proof-theoretic ordinal.
**If false**: Pinpoints that the GLP–ordinal correspondence needs arithmetical
interpretation beyond the bare frame, sharpening exactly what extra structure is required.

### Direction 2: Box does not factor — a categorical obstruction theorem
**Hypothesis**: For the synchronized product, `(F.prod G).boxSet (A ×ˢ B)` strictly
contains `(F.boxSet A) ×ˢ (G.boxSet B)` whenever either frame has a world with no
successor, and the two coincide iff both frames are successor-total (serial).
**Test**: Prove the inclusion `⊇` in general, then construct an explicit two-world
counterexample to equality using a dead-end world, and prove the seriality
characterization.
**Why now**: `prod_diamond_rectangle` shows ◇ factors perfectly; the failure analysis
already located the obstruction (vacuous box at dead ends). Formalizing the obstruction
turns an informal remark into a theorem.
**If true**: Gives a clean criterion separating ◇ (a product-preserving functor) from □,
the categorical core of why GL is a "◇-natural" logic.
**If false**: Would reveal an unexpected coincidence forcing reexamination of the product's
universal property.

### Direction 3: Coproducts and a full categorical structure on GL frames
**Hypothesis**: The disjoint union of GL frames (accessibility internal to each summand)
is the coproduct, and together with `GLFrame.prod` it makes finite GL frames a category
with finite products and coproducts; bounded morphisms (p-morphisms) are the maps that
preserve `boxSet` along preimages.
**Test**: Define `GLFrame.disjointUnion` and `GLFrameMorphism`, prove the universal
properties of product and coproduct, and verify rank is additive/maximizing under the two
operations.
**Why now**: `GLFrame.prod` and `prod_validates_loeb` already give one half; the rank
machinery gives an invariant to test functoriality against.
**If true**: Provability logic acquires a verified categorical semantics, enabling
limit/colimit arguments about consistency strength.
**If false**: Identifies which closure property (probably equalizers) fails, bounding how
"complete" the category can be.

### Direction 4: Rank as a quantitative Löb / consistency-strength gauge
**Hypothesis**: In any GL frame, `GLFrame.rank w` equals the length of the longest
ascending accessibility chain from `w`, and the iterated box `□^k ⊥` is satisfied exactly
at worlds of rank `< k` — generalizing `natBox_iterate_eq_Iio` from `(ℕ,>)` to every GL
frame.
**Test**: Prove `rank w = sSup {chain lengths}` (finite frames), then prove the
rank-stratification of `boxSet^[k] ∅` by induction using `gl_rank_lt_of_R`.
**Why now**: We now have both the ordinal rank and the single-frame Löb validation in the
same file; the only missing link is the chain-length identity.
**If true**: Makes "consistency strength = ordinal rank" a theorem for arbitrary GL
frames, unifying the semantic and the `LobNatModel` quantitative pictures.
**If false**: Shows rank and box-iteration depth diverge on branching frames, revealing a
genuinely two-dimensional notion of provability depth.

### Direction 5: Tropical/cost semantics layered on the rank
**Hypothesis**: Replacing the boolean `boxSet` by a cost function
`cost(w, □φ) = sup over successors + 1` yields a real-valued semantics in which
`cost(w, □^k⊥)` grows linearly in `k`, and the growth rate is bounded below by
`GLFrame.rank w`.
**Test**: Define `tropicalForces` by well-founded recursion on `flip R` (reusing
`flip_wellFounded`), prove a tropical Löb inequality, and relate the cost to the ordinal
rank.
**Why now**: `flip_wellFounded` gives exactly the well-founded relation needed to define a
total recursive cost function, which was the missing ingredient for a tropical layer.
**If true**: Produces a quantitative "tropical incompleteness" gauge tying proof cost to
ordinal rank.
**If false**: Indicates the cost recursion is not monotone under the GL axioms, isolating
where quantitative and qualitative provability part ways.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/GLProductBox.lean
import Mathlib
import Logic.PolymodalGL

/-!
# Box does not factor over the synchronized product of GL frames

This file pursues **Direction 2** ("Box does not factor — a categorical obstruction
theorem") of the polymodal-GL research cycle, building directly on
`Catalog/Logic/PolymodalGL.lean`'s synchronized product `GLFrame.prod` and its
diamond-factorization theorem `GLFrame.prod_diamond_rectangle`
(`◇(A ×ˢ B) = (◇A) ×ˢ (◇B)`).

The cycle's `prod_diamond_rectangle` showed the **diamond** of a rectangle factors
*exactly* as a rectangle of diamonds — the modal signature of a categorical product.
The accompanying failure analysis conjectured that **box does not factor**, because a
world with no successor makes `□` vacuously true.  Here we turn that informal remark
into theorems.

## Main results

* `GLFrame.prod_box_rectangle_subset` — the *easy* inclusion always holds:
  `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` in the product frame.

* `GLFrame.prod_box_rectangle_of_edgeless` — when **both** factor frames are edgeless
  (no accessibility at all), the inclusion is an equality.  This is the only nonempty
  situation in which box factors.

* `GLFrame.prod_box_not_factor` — the **obstruction**: an explicit two-world frame `F`
  (one edge) and one-world dead-end frame `G`, with concrete sets `A`, `B`, for which
  `(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)` is a *strict* inclusion.  Box genuinely fails to factor.

## Correction to the cycle's Direction 2

Direction 2 conjectured that box factors *iff both frames are serial* (every world
has a successor).  This is **vacuous in the GL setting**: a serial GL frame is empty,
because converse well-foundedness (`GLFrame.flip_wellFounded`, hence
`exists_maximal_world`) always produces a dead-end world in any *nonempty* frame.  The
correct coincidence criterion is therefore **edge-freeness** of the factors, recorded
in `prod_box_rectangle_of_edgeless` and witnessed sharp by `prod_box_not_factor`.

-- !-- Lab Notebook -- !--
**Hypothesis.** The box of a rectangle does *not* factor as a rectangle of boxes in
the synchronized product, even though the diamond does (`prod_diamond_rectangle`).

**Result.** Confirmed. The inclusion `(□A)×ˢ(□B) ⊆ □(A×ˢB)` always holds; equality
holds when both frames are edgeless; and an explicit dead-end witness makes the
inclusion strict otherwise.

**Insight.** ◇ is an existential over a *synchronized* step, so the witness splits
coordinate-wise — a product. □ is a universal over synchronized steps, and a dead end
in one coordinate empties the quantifier, making □ vacuously true regardless of the
other coordinate. Asymmetry of ∃ vs ∀ over the product step is the categorical core of
why GL is "◇-natural".

**Failure analysis.** The seriality criterion conjectured in Direction 2 collapses:
converse well-foundedness forces every nonempty GL frame to have a dead end, so the
only serial GL frame is empty. Edge-freeness is the corrected criterion.
-- !-- end Lab Notebook -- !--
-/

open Set Function

namespace GLFrame

/-
!-- The easy inclusion: if every F-successor of w₁ is in A and every G-successor of
w₂ is in B, then every synchronized product-successor of (w₁,w₂) is in A ×ˢ B. -- !--

**The box rectangle inclusion (always holds).**  In the synchronized product,
`(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)`.  This is the half of the factorization that survives.
-/
theorem prod_box_rectangle_subset (F G : GLFrame) (A : Set F.World) (B : Set G.World) :
    (F.boxSet A) ×ˢ (G.boxSet B) ⊆ (F.prod G).boxSet (A ×ˢ B) := by
  intro x hx; simp_all +decide [ Set.mem_prod, GLFrame.boxSet ] ;
  exact fun v hv₁ hv₂ => ⟨ hx.1 _ hv₁, hx.2 _ hv₂ ⟩

/-
!-- If both frames are edgeless, every box is `univ` (vacuously) and the product is
edgeless too, so both sides equal `univ`. -- !--

**Box factors when both frames are edgeless.**  If neither `F` nor `G` has any
accessibility edge, then `(□A) ×ˢ (□B) = □(A ×ˢ B)` in the product.  This is the only
way box can factor over a nonempty product (serial GL frames being empty).
-/
theorem prod_box_rectangle_of_edgeless (F G : GLFrame)
    (hF : ∀ w v, ¬ F.R w v) (hG : ∀ w v, ¬ G.R w v)
    (A : Set F.World) (B : Set G.World) :
    (F.prod G).boxSet (A ×ˢ B) = (F.boxSet A) ×ˢ (G.boxSet B) := by
  ext ⟨w1, w2⟩; simp [GLFrame.boxSet, GLFrame.prod, Set.mem_prod];
  grind

/-! ## The obstruction: explicit frames where box fails to factor -/

/-- A two-world GL frame on `Bool` with the single edge `true → false`. -/
def boolEdge : GLFrame where
  World := Bool
  R := fun x y => x = true ∧ y = false
  irrefl := by rintro w ⟨h1, h2⟩; rw [h1] at h2; exact Bool.noConfusion h2
  trans := by rintro w v u ⟨-, hv⟩ ⟨hv', -⟩; rw [hv] at hv'; exact absurd hv' (by decide)

/-- A one-world dead-end GL frame on `Unit` with no edges. -/
def unitDead : GLFrame where
  World := Unit
  R := fun _ _ => False
  irrefl := by intro w h; exact h
  trans := by intro w v u h _; exact h.elim

/-
!-- At `(true, ())`: the product box of the rectangle holds vacuously because `()`
is a dead end, but `true` is *not* in `□{true}` because it sees `false ∉ {true}`. -- !--

**Box does not factor (the obstruction).**  For the concrete frames `boolEdge`
(one edge) and `unitDead` (a dead end), with `A = {true}` and `B = univ`, the box of
the rectangle *strictly* contains the rectangle of boxes:
`(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)`.  The point `(true, ())` lies in the right side (vacuously,
since `()` is a dead end) but not the left (since `true` sees `false ∉ A`).
-/
theorem prod_box_not_factor :
    (boolEdge.boxSet {true}) ×ˢ (unitDead.boxSet (Set.univ))
      ⊂ (boolEdge.prod unitDead).boxSet (({true} : Set Bool) ×ˢ (Set.univ : Set Unit)) := by
  unfold boolEdge unitDead GLFrame.boxSet GLFrame.prod; simp +decide [ Set.ssubset_def ] ;
  simp +decide [ Set.Subset.antisymm_iff, Set.subset_def ]

end GLFrame


-- NEW_FILE: Catalog/Logic/GLRankStratification.lean
import Mathlib
import Logic.PolymodalGL

/-!
# Rank stratification of iterated box: a quantitative Löb for every GL frame

This file pursues **Direction 4** ("Rank as a quantitative Löb / consistency-strength
gauge") of the polymodal-GL research cycle, building on the ordinal rank
`GLFrame.rank` and its descent lemma `gl_rank_lt_of_R` from
`Catalog/Logic/PolymodalGL.lean`, together with `GLFrame.boxSet` and
`GLFrame.IsMaximal` from `Catalog/Logic/GLKripke.lean`.

The concrete model file `Catalog/Logic/LobNatModel.lean` proved the *quantitative*
identity `natBox^[k] ∅ = Set.Iio k` for the canonical frame `(ℕ, >)`: the `k`-fold
"inconsistency" statement is exactly the set of worlds of depth `< k`.  Here we lift
that computation to an **arbitrary** GL frame, replacing the literal depth by the
ordinal rank:

## Main results

* `GLFrame.boxSet_empty_eq_maximal` — `□∅` is exactly the set of dead-end (maximal)
  worlds.

* `GLFrame.rank_eq_zero_iff_maximal` — a world has ordinal rank `0` iff it is a dead
  end; rank `0` is the bottom layer of the stratification.

* `GLFrame.boxSet_iterate_eq_rank_lt` — **the rank stratification**: for every `k`,
  `□^k ∅ = { w | rank w < k }`.  The `k`-fold falsity is satisfied exactly at worlds of
  ordinal rank below `k`, generalizing `natBox_iterate_eq_Iio` (where `rank n = n`) to
  every GL frame.

-- !-- Lab Notebook -- !--
**Hypothesis.** In any GL frame the iterated box of the empty set stratifies the
worlds by ordinal rank: `□^k ∅ = {w | rank w < k}`, generalizing the `(ℕ,>)`
computation `natBox^[k] ∅ = Iio k`.

**Result.** Confirmed. The base case `□^0 ∅ = ∅ = {rank < 0}` is trivial; the step
uses `rank w = ⨆_{R w v} succ (rank v)`, so `rank w ≤ k ↔ ∀ v, R w v → rank v < k`,
which is exactly membership of `w` in `□{rank < k}` by the induction hypothesis.

**Insight.** Provability rank is not extra data: the ordinal rank of a world *equals*
the least `k` for which `□^k ⊥` fails there. Gödel-style "consistency strength" and the
set-theoretic ordinal rank of the accessibility tree are the same invariant.

**Failure analysis.** T
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Categorical and Ordinal Geometry of GL Frames

## Synthesis

This cycle pushed the Kripke-semantic core of Gödel–Löb provability logic
(`Catalog/Logic/GLKripke.lean`, `Catalog/Logic/PolymodalGL.lean`) in two of the
directions that the previous polymodal cycle flagged as open — the *categorical
obstruction* (Direction 2) and the *quantitative-Löb rank stratification*
(Direction 4) — and in doing so turned two informal remarks into machine-checked
theorems while *correcting* one conjecture that turned out to be vacuous.

The first thread (`Catalog/Logic/GLProductBox.lean`) confronts the asymmetry first
observed in `prod_diamond_rectangle`: the diamond of a rectangle factors exactly
(`◇(A ×ˢ B) = ◇A ×ˢ ◇B`), but the box does not. We proved the surviving half
`(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` in general (`prod_box_rectangle_subset`), proved that
equality is recovered when both factors are *edgeless*
(`prod_box_rectangle_of_edgeless`), and built an explicit two-world witness
(`prod_box_not_factor`) on `Bool` (one edge) and `Unit` (a dead end) where the
inclusion is **strict**. The decisive structural discovery is a correction to the
previous cycle's Direction 2: it conjectured that box factors *iff both frames are
serial*, but a serial GL frame is **empty** — converse well-foundedness
(`GLFrame.flip_wellFounded`) forces every nonempty GL frame to have a dead end. So the
right coincidence criterion is not seriality but **edge-freeness**, and the dead end is
exactly the obstruction (it empties the universal quantifier behind `□`).

The second thread (`Catalog/Logic/GLRankStratification.lean`) lifts the concrete
computation `natBox^[k] ∅ = Set.Iio k` of `Catalog/Logic/LobNatModel.lean` from the
single frame `(ℕ, >)` to *every* GL frame. We proved `□∅ = {dead ends}`
(`boxSet_empty_eq_maximal`), characterized the bottom ordinal layer
`rank w = 0 ↔ IsMaximal w` (`rank_eq_zero_iff_maximal`), and proved the full
stratification `□^k ∅ = { w | rank w < k }` (`boxSet_iterate_eq_rank_lt`). This is a
clean identity *consistency strength = ordinal rank*: the iterated falsity `□^k⊥` is
satisfied exactly at worlds whose ordinal rank is below `k`. The `(ℕ, >)` picture, where
`rank n = n` and `Iio k = {n | n < k}`, is now the special case of an every-frame
theorem.

## Results Summary

- `GLFrame.prod_box_rectangle_subset` — proved: `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` always, the
  surviving half of box-factorization in the synchronized product.
- `GLFrame.prod_box_rectangle_of_edgeless` — proved: box factors (`□(A ×ˢ B) = □A ×ˢ □B`)
  when both factor frames are edgeless — the only way box can factor over a nonempty
  product.
- `GLFrame.prod_box_not_factor` — proved (explicit `Bool`/`Unit` witness): the inclusion
  is *strict*, `(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)`; box genuinely fails to factor. The point
  `(true, ())` is in the right side vacuously (dead end) but not the left.
- `GLFrame.boxSet_empty_eq_maximal` — proved: `□∅` is exactly the set of dead-end worlds.

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
