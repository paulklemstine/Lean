
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

**Title**: This cycle established, in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.
**Domain**: Combinatorics
**Mathematical framing**: # Future Directions — Categorical Tropical Rips Interleaving

This cycle established, in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`, a
self-contained, fully-verified bridge between **categorical persistence theory**,
**tropical / min-plus algebra**, and **geometry / topological data analysis**:

- Persistence modules as monotone functors `ℝ → α` (`PersMod`).
- `ε`-interleavings, with reflexivity, symmetry, monotone weakening, and the **composition
  law** `Interleaved.trans` (`ε`-interleaving ∘ `δ`-interleaving = `(ε+δ)`-interleaving).
- The `ℝ≥0∞`-valued **interleaving distance** `interleavingDist`, proven to be a pseudometric
  (`interleavingDist_self`, `interleavingDist_comm`, `interleavingDist_triangle`).
- The **tropical reformulation** `interleaving_tropical_submul`: the triangle inequality is
  *exactly* submultiplicativity of `trop ∘ interleavingDist` in `Tropical ℝ≥0∞`.
- **Vietoris–Rips stability** (`rips_stability`, `rips_interleavingDist_le`): sup-close
  dissimilarities yield interleaved Rips modules.

The following conjectures are precise, falsifiable targets for the next cycles.

## Conjecture 1 (Isometry / converse stability)
For Rips modules of pseudometrics `d, d'` on a fixed point set, the interleaving distance is
*equal* to (not just bounded by) the sup perturbation:
`interleavingDist (RipsMod d) (RipsMod d') = ENNReal.ofReal (⨆ x y, |d x y - d' x y|)`
whenever the sup is finite. **Test:** prove the `≥` direction by extracting, from any
`ε`-interleaving of edge-set modules, the pointwise bound `|d x y - d' x y| ≤ ε` (evaluate the
interleaving at `t = d x y`). This would upgrade §4 to a genuine isometry theorem.

## Conjecture 2 (Tropical semiring action on the distance lattice)
The map `(M, N) ↦ trop (interleavingDist M N)` is a lax functor into `Tropical ℝ≥0∞`: not only
submultiplicative under composition (proved), but the *self-distance is the tropical unit*
(`trop 0 = 1` in `Tropical ℝ≥0∞`) and constant shifts act by tropical multiplication, i.e.
`interleavingDist (shift c M) (shift c N) = interleavingDist M N` and the shift functor `M ↦
shift c M` satisfies `interleavingDist M (shift c M) ≤ ENNReal.ofReal c`. **Test:** define
`shift c M := ⟨fun t => M.obj (t + c), …⟩` and prove these three identities.

## Conjecture 3 (Stability is 1-Lipschitz / sub-additive in the tropical metric)
Composition of perturbations is tropically multiplicative end-to-end: for dissimilarities
`d, d', d''`,
`trop (interleavingDist (RipsMod d) (RipsMod d''))
   ≤ trop (idist (RipsMod d) (RipsMod d')) * trop (idist (RipsMod d') (RipsMod d''))`,
and moreover this is *tight* when the perturbations are aligned (same sign everywhere).
**Test:** the inequality is immediate from Conjecture-free results already proved; the tightness
clause is the falsifiable content and should be attacked with a 2-point metric space.

## Conjecture 4 (Lattice-valued generalization: persistence in any complete lattice is a
tropical module)
For any complete lattice `α`, the assignment `ε ↦ {(M,N) | Interleaved ε M N}` defines a graded
sub-relation whose graded pieces are closed under min-plus convolution: if `R_ε` and `R_δ` are
the `ε`- and `δ`-interleaving relations then `R_ε ∘ R_δ ⊆ R_{ε+δ}` (proved as
`Interleaved.trans`) and `R = ⋃_ε R_ε` is the relation of *finite* interleaving distance, which
is an equivalence relation refining bisimilarity. **Test:** prove `R` is transitive and that the
quotient `PersMod α / R` carries a well-defined `Tropical ℝ≥0∞`-valued metric.

## Conjecture 5 (Stability of derived invariants: rank/Betti curves are 1-Lipschitz)
Define, for a Rips module over a *finite* point set, the rank curve `r(t) = card {(x,y) | d x y
≤ t}`. Then `t ↦ r(t)` is monotone and any `ε`-interleaving of Rips modules forces
`r_d(t) ≤ r_{d'}(t + ε)` and symmetrically, hence the rank curves are `ε`-interleaved as
ℕ-valued persistence modules. **Test:** prove the rank functor `PersMod (Set (X×X)) → PersMod ℕ`
(for `Fintype X`) sends `ε`-interleavings to `ε`-interleavings, i.e. it is a 1-Lipschitz functor
for the interleaving distance — a baby "algebraic stability of the rank invariant".

Research domain: Combinatorics
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/CategoricalTropicalRipsRank.lean
/-
  # Categorical Tropical Rips Interleaving — Rank / Betti Curve Stability
  ## Algebraic stability of the rank invariant: the rank functor
  ## `PersMod (Set β) → PersMod ℕ` (for finite `β`) is 1-Lipschitz for the
  ## interleaving distance.

  This file develops **Conjecture 5** of
  `Bridges.CategoricalTropicalRipsInterleaving` (rank/Betti curves are 1-Lipschitz).

  Given a persistence module valued in the lattice of subsets of a *finite* type `β`,
  the **rank curve** sends a scale `t` to the cardinality `ncard (M.obj t)` of the
  scale-`t` object. We prove:

  * `rankMod` is a genuine persistence module valued in `ℕ` (the rank curve is monotone);
  * `rank_preserves_interleaving`: the rank functor sends `ε`-interleavings to
    `ε`-interleavings — the categorical heart of "algebraic stability of the rank
    invariant";
  * `rank_interleavingDist_le`: the rank functor is **1-Lipschitz** for the interleaving
    distance;
  * `rips_rank_stability` / `rips_rank_interleavingDist_le`: specialising to Vietoris–Rips,
    sup-close dissimilarities give `ε`-interleaved rank curves over a finite point set,
    with controlled interleaving distance.

  -- !-- Lab Notes -- !--
  -- HYPOTHESIS (Hypothesizer): The catalog's lattice-valued model `PersMod (Set β)` is the
  --   right place to define the rank invariant: `ncard` is monotone under inclusion exactly
  --   when sets are finite, so over a `Finite` type the rank functor is total and monotone.
  --   The interleaving inequalities `M.obj t ⊆ N.obj (t+ε)` should pass through `ncard`
  --   verbatim, giving 1-Lipschitzness *for free* from `Set.ncard_le_ncard`.
  -- EXPERIMENT (Experimenter): formalised `rankMod`, proved `rank_preserves_interleaving`
  --   by pushing both inclusion bounds of `Interleaved` through `Set.ncard_le_ncard`, then
  --   `rank_interleavingDist_le` by a `sInf`-monotonicity (subset of interleaving sets).
  -- ANALYSIS (Analyst): SURVIVED. The crucial finiteness hypothesis is `Finite β`
  --   (equivalently `Fintype X` for the Rips case, since `Finite (X × X)`); without it
  --   `Set.ncard` of an infinite set is `0` and monotonicity fails — a genuine, not
  --   cosmetic, hypothesis. `rank_interleavingDist_le` is an inequality, NOT an equality:
  --   the rank functor forgets information, so distances can strictly contract.
  -- CRITIQUE (Critic): the results are non-vacuous — `rankMod` is monotone but not constant
  --   (it is the Betti-0/edge-count curve), and the interleaving conclusions use the real
  --   shift `ε` nontrivially. No `native_decide`, no `True`, no definitional wrappers.
-/

import Mathlib
import Bridges.CategoricalTropicalRipsInterleaving

open scoped ENNReal
open Tropical
open CategoricalTropicalRipsInterleaving

noncomputable section

namespace CategoricalTropicalRipsRank

universe u

/-! ## §1. The rank functor `PersMod (Set β) → PersMod ℕ`. -/

/-- The **rank curve** of a lattice-valued persistence module over a finite type `β`:
    at scale `t` it returns the cardinality `ncard (M.obj t)` of the scale-`t` object.
    Monotone in `t` because `ncard` is monotone under inclusion for finite sets. -/
def rankMod {β : Type u} [Finite β] (M : PersMod (Set β)) : PersMod ℕ where
  obj t := (M.obj t).ncard
  mono := fun _ _ hab => Set.ncard_le_ncard (M.mono hab) (Set.toFinite _)

/-! ## §2. The rank functor is 1-Lipschitz. -/

/-- **Algebraic stability of the rank invariant.** The rank functor sends `ε`-interleavings
    to `ε`-interleavings: an `ε`-interleaving of lattice-valued modules forces the rank
    curves to be `ε`-interleaved as `ℕ`-valued persistence modules. -/
theorem rank_preserves_interleaving {β : Type u} [Finite β] {ε : ℝ}
    {M N : PersMod (Set β)} (h : Interleaved ε M N) :
    Interleaved ε (rankMod M) (rankMod N) :=
  ⟨fun t => Set.ncard_le_ncard (h.1 t) (Set.toFinite _),
   fun t => Set.ncard_le_ncard (h.2 t) (Set.toFinite _)⟩

/-- The rank functor is **1-Lipschitz** for the interleaving distance: passing to rank
    curves can only contract distances. -/
theorem rank_interleavingDist_le {β : Type u} [Finite β] (M N : PersMod (Set β)) :
    interleavingDist (rankMod M) (rankMod N) ≤ interleavingDist M N := by
  apply sInf_le_sInf
  rintro x ⟨ε, hε, hI, rfl⟩
  exact ⟨ε, hε, rank_preserves_interleaving hI, rfl⟩

/-! ## §3. Vietoris–Rips rank/Betti curves over a finite point set. -/

variable {X : Type u} [Finite X]

/-- The Vietoris–Rips **rank (edge-count) curve** of a dissimilarity on a finite point set:
    at scale `t` it counts the pairs `(x,y)` with `d x y ≤ t`. -/
def ripsRankCurve (d : X → X → ℝ) : PersMod ℕ := rankMod (RipsMod d)

/-- **Stability of the rank curve.** Sup-close dissimilarities on a finite point set have
    `ε`-interleaved Vietoris–Rips rank curves. -/
theorem rips_rank_stability (d d' : X → X → ℝ) {ε : ℝ}
    (h : ∀ x y, |d x y - d' x y| ≤ ε) :
    Interleaved ε (ripsRankCurve d) (ripsRankCurve d') :=
  rank_preserves_interleaving (rips_stability d d' h)

/-- The interleaving distance of the Rips rank curves is bounded by the sup perturbation. -/
theorem rips_rank_interleavingDist_le (d d' : X → X → ℝ) {ε : ℝ} (hε : 0 ≤ ε)
    (h : ∀ x y, |d x y - d' x y| ≤ ε) :
    interleavingDist (ripsRankCurve d) (ripsRankCurve d') ≤ ENNReal.ofReal ε :=
  le_trans (rank_interleavingDist_le _ _) (rips_interleavingDist_le d d' hε h)

-- !-- Lab Notes -- !--
-- SYNTHESIS (Principal Investigator): Conjecture 5 is fully discharged with 0 sorries.
--   The rank functor is a 1-Lipschitz functor `PersMod (Set β) → PersMod ℕ` and, composed
--   with `RipsMod`, yields a stability theorem for the edge-count / Betti-0 curve. The
--   remaining open content (whether the contraction `rank_interleavingDist_le` is ever
--   strict, and a multiset-of-bars refinement) is recorded in FUTURE_DIRECTIONS.md.

end CategoricalTropicalRipsRank



-- NEW_FILE: Catalog/Bridges/CategoricalTropicalRipsShift.lean
/-
  # Categorical Tropical Rips Interleaving — Shift Action & Finite-Distance Equivalence
  ## The constant-shift functor acts by tropical multiplication on the interleaving
  ## distance, and "finite interleaving distance" is an equivalence relation.

  This file develops **Conjecture 2** (tropical/shift action) and **Conjecture 4**
  (lattice-valued finite-distance equivalence) of
  `Bridges.CategoricalTropicalRipsInterleaving`.

  * `shift c M`: precompose the parameter line with `· + c`.
  * `interleaved_shift_iff`: simultaneously shifting both modules leaves the interleaving
    relation invariant — the shift is an *isometry* of the interleaving distance
    (`interleavingDist_shift`).
  * `interleavingDist_self_shift`: a module is `c`-close to its own `c`-shift,
    `interleavingDist M (shift c M) ≤ ENNReal.ofReal c` — the shift functor moves a module
    by at most `c` (tropical multiplication by `c`).
  * `trop_interleavingDist_self`: the self-distance is the **tropical unit**
    `trop 0 = (1 : Tropical ℝ≥0∞)`.
  * `FinInterleaved` and `finInterleaved_equivalence`: having *some* finite interleaving is
    an equivalence relation (reflexive/symmetric/transitive via the catalog's composition
    law), and `finInterleaved_iff_dist_ne_top` identifies it with `interleavingDist ≠ ⊤`.

  -- !-- Lab Notes -- !--
  -- HYPOTHESIS (Hypothesizer): the constant-shift reparametrisation `t ↦ t + c` is the
  --   "tropical scalar action" on persistence modules. Conjecturally it (a) is an isometry
  --   on pairs, (b) displaces a module by ≤ c, and (c) the self-distance is the tropical
  --   multiplicative unit. Separately, the union over ε of the ε-interleaving relations
  --   should be an equivalence relation because the catalog already proved the composition
  --   law `Interleaved.trans`.
  -- EXPERIMENT (Experimenter): `interleaved_shift_iff` is proved by evaluating the shifted
  --   inequalities at the translated parameter `t - c` / `t + c`; `interleavingDist_shift`
  --   then follow
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Categorical Tropical Rips Interleaving (Rank & Shift cycle)

This cycle added two fully-verified files (0 sorries) extending
`Bridges.CategoricalTropicalRipsInterleaving`:

- `Bridges.CategoricalTropicalRipsRank` — **Conjecture 5** discharged: the rank functor
  `rankMod : PersMod (Set β) → PersMod ℕ` (finite `β`) is a 1-Lipschitz functor for the
  interleaving distance (`rank_preserves_interleaving`, `rank_interleavingDist_le`), giving
  Vietoris–Rips rank/Betti-0 curve stability over a finite point set (`rips_rank_stability`,
  `rips_rank_interleavingDist_le`).
- `Bridges.CategoricalTropicalRipsShift` — **Conjectures 2 & 4** discharged: the constant
  shift is a strict isometry of the interleaving distance (`interleavingDist_shift`),
  displaces a module by at most `c` (`interleavingDist_self_shift`), the self-distance is
  the tropical unit (`trop_interleavingDist_self`), and *finite interleaving distance* is an
  equivalence relation (`finInterleaved_equivalence`) equal to `interleavingDist ≠ ⊤`
  (`finInterleaved_iff_dist_ne_top`).

The following are bold, falsifiable targets for the next cycles.

## Conjecture A (The rank contraction is generically strict)
`rank_interleavingDist_le` proves `interleavingDist (rankMod M) (rankMod N) ≤
interleavingDist M N`. Claim: this inequality is **strict** for some explicit pair of Rips
modules on a 3-point set, i.e. the rank invariant strictly forgets geometry.
**The key insight is** that `ncard` collapses two non-nested edge sets of equal cardinality
to the *same* number, so a permutation-type perturbation that is invisible to the rank curve
still costs a positive interleaving distance at the lattice level.
**Why now?** We have both sides of the inequality formalized; constructing a 3-point
counterexample to equality is a finite `decide`-free computation that immediately upgrades
"1-Lipschitz" to "strictly contracting", a quantitative information-loss statement.

## Conjecture B (Shift is the unique tropical scalar action)
Beyond `interleavingDist_self_shift : d(M, shift c M) ≤ ofReal c`, claim the bound is
**tight**: `interleavingDist M (shift c M) = ENNReal.ofReal c` whenever `M` is *strictly*
monotone on a real interval of length `> c`.
**The key insight is** that strict monotonicity blocks any cheaper interleaving: an
`ε`-interleaving with `ε < c` would force `M.obj t < M.obj t` after composing the two
shifted dominations, a contradiction extracted by evaluating at an interior point.
**Why now?** The `≤` direction and the isometry `interleavingDist_shift` are already proved,
so only the `≥` direction (a single strict-monotonicity extraction) remains — the same
"evaluate the interleaving at a witness point" technique used for the catalog's stability.

## Conjecture C (The finite-distance quotient carries a tropical metric)
`finInterleaved_equivalence` makes `FinInterleaved` an equivalence relation. Claim: the
quotient `PersMod α / FinInterleaved` carries a well-defined `Tropical
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
