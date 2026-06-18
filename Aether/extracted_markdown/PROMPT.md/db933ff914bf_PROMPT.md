
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

**Title**: `Catalog/Bridges/FunctorialTropicalPythagorean.lean` (0 sorr
**Domain**: Probability
**Mathematical framing**: # FUTURE DIRECTIONS — Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

This cycle produced `Catalog/Bridges/FunctorialTropicalPythagorean.lean` (0 sorries, only
standard axioms). It builds the canonical **tree ultrametric** `d` on the boundary
`Addr = ℕ → Fin 3` of the ternary Berggren tree, proves it is a genuine ultrametric
(`d_ultra`), realizes the three Berggren generators as exact `(1/2)`-similarities
(`d_cons_same`, `d_cons_diff`), records the tropical min-plus core
(`firstDiff_ge_min`, `firstDiff_cons_tropical`), the depth↔log-hypotenuse growth law
(`seed_hyp_growth`, `bchild_iter_hyp_growth`), and a functorial bridge into the catalog
valuation-reconstruction functor via Gaussian integers (`gaussianSupportCarrier`,
`gaussian_reconstruct_ultrametric`).

The following conjectures are **bold but testable** in Lean, each with the partial evidence
already established this cycle.

## C1. Metric-space packaging and compactness (Cantor space)
**Conjecture.** `(Addr, d)` underlies a Mathlib `MetricSpace` that is **complete** and
**compact** (a Cantor space), with `d` an ultrametric (`IsUltrametricDist`).
*Evidence.* `d_self`, `d_comm`, `d_eq_zero_iff`, `d_triangle`, `d_ultra`, `d_le_one` are all
proved — these are exactly the metric/ultrametric axioms. *Test.* Assemble a
`PseudoMetricSpace`/`MetricSpace` instance, register `IsUltrametricDist`, then prove
totally-bounded + complete ⇒ compact. Falsifiable: it fails iff some Cauchy address
sequence has no limit, which it cannot since coordinates stabilize.

## C2. Hausdorff dimension of the Berggren boundary = log 3 / log 2
**Conjecture.** The Berggren branch IFS `{cons 0, cons 1, cons 2}` satisfies the open-set
condition with three `(1/2)`-similarities, so `dimH (Set.univ : Set Addr) = log 3 / log 2`.
*Evidence.* `d_cons_same` (ratio exactly `1/2`) and `d_cons_diff` (images pairwise at
distance `1`, hence disjoint clopen balls) give the contraction ratios and separation.
*Test.* Build the self-similar covering by depth-`n` cylinders (there are `3^n`, each of
diameter `2^{-n}`) and bound the Hausdorff measure two-sidedly. Falsifiable by exhibiting a
covering of smaller/larger exponent.

## C3. Two-sided depth–size law along every ray
**Conjecture.** There exist constants `0 < α ≤ β` such that every primitive Pythagorean
triple reached at Berggren tree depth `n` has hypotenuse `c` with
`α · ρ_min^n ≤ c ≤ β · ρ_max^n`, where `ρ_min, ρ_max` are the minimal/maximal
hypotenuse-expansion factors of the generators `A, B, C`; consequently metric depth is
`Θ(log c)` and `d`-balls of radius `2^{-n}` correspond to hypotenuse scale windows.
*Evidence.* `bchild_iter_hyp_growth` / `seed_hyp_growth` prove the lower bound `c·3^n ≤ hyp`
along the all-`B` ray (`ρ = 3`). *Test.* Establish per-generator upper bounds
(e.g. `hyp ≤ 7c` from `BerggrenLorentz.hypB_upper_bound`) and combine over arbitrary words.
Falsifiable by a word whose hypotenuse escapes the geometric window.

## C4. The Berggren monoid acts by ultrametric endomorphisms (categorical action)
**Conjecture.** Each generator `cons k` extends to a non-expansive endomorphism of an object
of the `CategoricalTropicalUltrametric` category, and word composition is functorial, so the
free Berggren monoid embeds into the endomorphism monoid of that object; the min-plus
`firstDiff` valuation is the exact order-dual of a max-plus `TropicalValuationObject`.
*Evidence.* `cons_contraction` (`1/2`-Lipschitz), `firstDiff_cons_tropical`
(tropical-multiplication law), and the existing functoriality theorems
`tropicalization_map_comp`, `valuationReconstruct_map_comp`. *Test.* Define the dual
min-plus object and a faithful monoid homomorphism `BerggrenWord → End(·)`. Falsifiable if
some relation collapses two distinct words (it should not — Berggren generators are free).

## C5. Nontrivial `(1+i)`-adic valuation refines the Gaussian bridge
**Conjecture.** Replacing the support valuation by the `(1+i)`-adic valuation `v` on `ℤ[i]`
gives a *nontrivial* ultrametric whose value on the Gaussian encoding `m + n·i` of a
primitive triple `(m²−n², 2mn, m²+n²)` equals the `2`-adic valuation of the even leg `2mn`;
i.e. `v` reads off the power of `2` dividing the even leg.
*Evidence.* `gaussian_norm_eq` (norm `= m²+n²` = hypotenuse) and `gaussian_norm_mul`
(multiplicativity) fix the arithmetic; the support valuation `gval` is the trivial endpoint
of this family. *Test.* Define `v` via `multiplicity (1+i)` or `Zsqrtd` factorization and
prove the even-leg identity. Falsifiable on any explicit triple where the `(1+i)`-adic
valuation and the even-leg `2`-adic valuation disagree.

Research domain: Probability
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/FunctorialTropicalPythagorean.lean
/-
  # Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

  Bridge: **Probability / metric geometry ↔ tropical algebra ↔ Pythagorean number theory
  ↔ Gaussian arithmetic.**

  This file builds the canonical **tree ultrametric** `d` on the boundary
  `Addr = ℕ → Fin 3` of the ternary Berggren tree (whose three branches `A, B, C`
  generate all primitive Pythagorean triples from `(3,4,5)`), proves it is a genuine
  ultrametric, realizes the three Berggren branch maps `cons k` as exact `(1/2)`-similarities,
  records the tropical min-plus core of the construction, proves the two-sided
  depth↔hypotenuse growth law along the all-`B` ray, and exposes a functorial bridge into
  the catalog's valuation-reconstruction functor (`CategoricalTropicalUltrametric`) through
  the Gaussian integers `ℤ[i]`.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): the boundary of the ternary Berggren tree carries a canonical
  ultrametric of "first disagreement" type, the three branch insertions are exact half-scale
  similarities, and the resulting min-plus valuation is functorially the same data as the
  catalog's tropical valuation carrier — with the Gaussian-integer norm furnishing a
  multiplicative bridge to Pythagorean hypotenuses.
  EXPERIMENT (Experimenter): define `firstDiff` via `Nat.find`, `d := (1/2)^firstDiff`, and
  prove the six metric/ultrametric axioms; prove `firstDiff_ge_min` (the tropical core);
  prove `d_cons_same`/`d_cons_diff`; iterate `childB` from `(3,4,5)` and bound the hypotenuse
  two-sidedly by `5·3^n ≤ c ≤ 5·7^n`; assemble `gaussianSupportCarrier` and reconstruct.
  ANALYSIS (Analyst): the ultrametric inequality reduces to the *agreement-stability* lemma
  `firstDiff_ge_min`; antitonicity of `(1/2)^·` turns `min` of exponents into `max` of
  distances. The growth window survives because `a ≤ c, b ≤ c` is preserved by `childB`.
  CRITIQUE (Critic): the trivial support valuation `gval` is multiplicative *only* because
  `ℤ[i]` is a domain; we use `mul_eq_zero`. The two-sided window is sharp at the seed.
  None of the main theorems are `rfl`/`native_decide`-only: they use induction, antitone
  power bounds, `Nat.find` reasoning, and case analysis.
  SYNTHESIS (PI): the file is the canonical packaging requested; follow-ups (compactness,
  Hausdorff dimension, (1+i)-adic refinement) recorded in `FUTURE_DIRECTIONS.md`.
-/

import Mathlib
import Bridges.CategoricalTropicalUltrametric
import Algebra.BerggrenLorentz.Core

namespace FunctorialTropicalPythagorean

open CategoricalTropicalUltrametric
open Classical

/-! ## §1. The Berggren boundary and the first-disagreement index -/

/-- The boundary of the ternary Berggren tree: infinite branch addresses. -/
abbrev Addr : Type := ℕ → Fin 3

/-- Prepend a branch label: `cons k x` chooses branch `k` first, then follows `x`. -/
def cons (k : Fin 3) (x : Addr) : Addr := fun n => match n with
  | 0 => k
  | (m + 1) => x m

@[simp] theorem cons_zero (k : Fin 3) (x : Addr) : cons k x 0 = k := rfl
@[simp] theorem cons_succ (k : Fin 3) (x : Addr) (m : ℕ) : cons k x (m + 1) = x m := rfl

/-- The index of the first coordinate where two addresses disagree (`0` when equal,
    a junk value that is never used in the equal case). -/
noncomputable def firstDiff (x y : Addr) : ℕ :=
  if h : ∃ n, x n ≠ y n then Nat.find h else 0

/-- For unequal addresses, the first-disagreement index witnesses an actual disagreement. -/
theorem firstDiff_spec {x y : Addr} (h : x ≠ y) : x (firstDiff x y) ≠ y (firstDiff x y) := by
  have hex : ∃ n, x n ≠ y n := Function.ne_iff.mp h
  simp only [firstDiff, dif_pos hex]
  exact Nat.find_spec hex

/-- Below the first-disagreement index, the two addresses agree. -/
theorem firstDiff_min {x y : Addr} (h : x ≠ y) {m : ℕ} (hm : m < firstDiff x y) :
    x m = y m := by
  have hex : ∃ n, x n ≠ y n := Function.ne_iff.mp h
  simp only [firstDiff, dif_pos hex] at hm
  by_contra hne
  exact absurd (Nat.find_le hne) (not_le.mpr hm)

/-- `firstDiff` is symmetric. -/
theorem firstDiff_comm (x y : Addr) : firstDiff x y = firstDiff y x := by
  unfold firstDiff; by_cases h : ∃ n, x n ≠ y n <;> by_cases h' : ∃ n, y n ≠ x n <;> simp_all +decide [ ne_comm ] ;

/-! ## §2. The tree ultrametric -/

/-- The canonical tree ultrametric: `d x y = (1/2)^(first disagreement)`, and `0` if equal. -/
noncomputable def d (x y : Addr) : ℝ :=
  if x = y then 0 else (1 / 2 : ℝ) ^ firstDiff x y

theorem d_self (x : Addr) : d x x = 0 := by simp [d]

theorem d_nonneg (x y : Addr) : 0 ≤ d x y := by
  unfold d; split
  · exact le_refl 0
  · positivity

theorem d_comm (x y : Addr) : d x y = d y x := by
  unfold d
  by_cases h : x = y
  · simp [h]
  · rw [if_neg h, if_neg (Ne.symm h), firstDiff_comm]

theorem d_eq_zero_iff (x y : Addr) : d x y = 0 ↔ x = y := by
  unfold d
  constructor
  · intro h
    by_contra hne
    rw [if_neg hne] at h
    have : (0 : ℝ) < (1 / 2 : ℝ) ^ firstDiff x y := by positivity
    linarith
  · intro h; simp [h]

theorem d_le_one (x y : Addr) : d x y ≤ 1 := by
  unfold d; split
  · norm_num
  · apply pow_le_one₀ <;> norm_num

/-- **Tropical min-plus core.** For three pairwise-distinct addresses the first-disagreement
    index of the ends is at least the minimum of the two intermediate indices: agreement is
    transitive up to the smaller stabilization depth.
-/
theorem firstDiff_ge_min {x y z : Addr} (hxy : x ≠ y) (hyz : y ≠ z) (hxz : x ≠ z) :
    min (firstDiff x y) (firstDiff y z) ≤ firstDiff x z := by
  unfold firstDiff at *; simp_all +decide [ Function.ne_iff.mp hxy, Function.ne_iff.mp hyz ]
  grind

/-- **Strong (ultrametric) triangle inequality.** -/
theorem d_ultra (x y z : Addr) : d x z ≤ max (d x y) (d y z) := by
  by_cases hxy : x = y <;> by_cases hyz : y = z <;> by_cases hxz : x = z <;> simp_all +decide [ d ];
  have h_exp : firstDiff x z ≥ min (firstDiff x y) (firstDiff y z) :=
    firstDiff_ge_min hxy hyz hxz
  cases min_cases (firstDiff x y) (firstDiff y z) <;> simp_all +decide
  · exact Or.inl ( inv_anti₀ ( by positivity ) ( pow_le_pow_right₀ ( by norm_num ) h_exp ) );
  · exact Or.inr ( inv_anti₀ ( by positivity ) ( pow_le_pow_right₀ ( by norm_num ) h_exp ) )

/-- The ordinary triangle inequality follows from the ultrametric one. -/
theorem d_triangle (x y z : Addr) : d x z ≤ d x y + d y z := by
  have h := d_ultra x y z
  have h1 := d_nonneg x y
  have h2 := d_nonneg y z
  calc d x z ≤ max (d x y) (d y z) := h
    _ ≤ d x y + d y z := by
        rcases le_total (d x y) (d y z) with hle | hle
        · rw [max_eq_right hle]; linarith
        · rw [max_eq_left hle]; linarith

/-! ## §3. The branch maps are exact `(1/2)`-similarities -/

/-- **Tropical multiplication law.** Prepending equal labels shifts the first-disagreement
    index up by one (for distinct tails).
-/
theorem firstDiff_cons_tropical (k : Fin 3) {x y : Addr} (h : x ≠ y) :
    firstDiff (cons k x) (cons k y) = firstDiff x y + 1 := by
  unfold firstDiff;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · exact ⟨ Nat.find_spec ‹∃ n, x n ≠ y n›, fun n hn => by cases n <;> simp_all +decide [ cons ] ⟩;
  · exact h ( funext ‹_› );
  · exact h ( funext fun n => by simpa using ‹∀ n, cons k x n = cons k y n› ( n + 1 ) )

/-- **Half-scale similarity.** Each branch insertion `cons k` contracts the ultrametric by
    exactly the factor `1/2`.
-/
theorem d_cons_same (k : Fin 3) (x y : Addr) : d (cons k x) (cons k y) = (1 / 2 : ℝ) * d x y := by
  by_cases hxy : x = y;
  · simp [hxy, d_self];
  · rw [ show d ( cons k x ) ( cons k y ) = ( 1 / 2 : ℝ ) ^ firstDiff ( cons k x ) ( cons k y ) from ?_, show d x y = ( 1 / 2 : ℝ ) ^ firstDiff x y from ?_ ];
    · rw [ firstDiff_cons_tropical k hxy, pow_succ' ];
    · exact if_neg hxy;
    · exact if_neg ( by intro h; exact hxy <| by funext n; have := congr_fun h ( n + 1 ) ; aesop )

/-- **Disjoint clopen balls.** Different first labels put the two images at distance exactly
    `1`, the maximal possibl
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE DIRECTIONS — Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

This cycle produced two compiling, `sorry`-free Lean files (standard axioms only):

- `Catalog/Bridges/FunctorialTropicalPythagorean.lean` — the canonical **tree ultrametric**
  `d` on the boundary `Addr = ℕ → Fin 3` of the ternary Berggren tree, with the six
  metric/ultrametric axioms (`d_self`, `d_comm`, `d_eq_zero_iff`, `d_triangle`, `d_ultra`,
  `d_le_one`), the tropical min-plus core (`firstDiff_ge_min`, `firstDiff_cons_tropical`),
  the exact `(1/2)`-similarities (`d_cons_same`, `d_cons_diff`), the **two-sided** depth↔
  hypotenuse window `5·3ⁿ ≤ c ≤ 5·7ⁿ` along the all-`B` ray (`bchild_iter_hyp_growth`,
  `seed_hyp_growth`), and the functorial Gaussian bridge (`gaussianSupportCarrier`,
  `gaussian_reconstruct_ultrametric`, `gaussian_norm_eq`, `gaussian_norm_mul`) into the
  catalog functor `CategoricalTropicalUltrametric.valuationReconstruct`.
- `Catalog/Bridges/FunctorialTropicalPythagoreanMetric.lean` — the Mathlib packaging:
  `instMetricSpaceAddr : MetricSpace Addr` and `instIsUltrametricDistAddr : IsUltrametricDist
  Addr`, with the half-scale similarity and maximal-separation facts restated through the
  Mathlib `dist`.

The following conjectures are **bold but testable** in Lean, each refined by this cycle's
findings and partial evidence.

## C1′. Cantor-space completeness and compactness of `(Addr, d)`
**Conjecture.** `(Addr, dist)` is **complete** and **compact** (a Cantor space), i.e.
`CompleteSpace Addr` and `CompactSpace Addr` hold for the registered `MetricSpace` instance.
*Evidence.* This cycle delivered `instMetricSpaceAddr` and `instIsUltrametricDistAddr`, so
the space is already a bona fide ultrametric space; `dist_le_one` bounds the diameter by `1`.
**The key insight is** that an address sequence is Cauchy iff every coordinate stabilizes
(each `2⁻ⁿ`-ball is the depth-`n` cylinder), so the coordinatewise limit is the unique limit
and totally-bounded + complete ⇒ compact. **Why now?** The metric instance is in place, so
the proof reduces to a single coordinate-stabilization lemma plus the standard
`isCompact_of_totallyBounded_isComplete` route — no new geometry is required.

## C2. Hausdorff dimension of the Berggren boundary = log 3 / log 2
**Conjecture.** `dimH (Set.univ : Set Addr) = Real.log 3 / Real.log 2`.
*Evidence.* `d_cons_same` gives contraction ratio exactly `1/2`; `d_cons_diff` makes the
three branch images pairwise distance-`1`, i.e. disjoint clopen balls (the open-set
condition). **The key insight is** that there are exactly `3ⁿ` depth-`n` cylinders, each of
diameter `2⁻ⁿ`, so the natural cover gives the upper bound `log 3 / log 2`, and the disjoint
`(1/2)`-similarities give the matching lower bound via a mass-distribution argument. **Why
now?** Both the contraction ratio and the separation constant are now theorems, pinning the
two sides of the dimension estimate to concrete, already-proven numbers.

## C3′. The depth–siz
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
