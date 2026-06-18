
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

**Title**: This cycle added `Geometry/QuasiSymmetricIterate.lean`, which closes the loop on
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Iteration & Semigroup Theory for Set-Local Distortion of Hausdorff Dimension

## Synthesis

This cycle added `Geometry/QuasiSymmetricIterate.lean`, which closes the loop on
the set-local Hausdorff-dimension distortion programme begun in
`Geometry/FractalDimension.lean` and continued in
`Geometry/QuasiSymmetricComposition.lean`. The first file built single-map
set-local invariance and the two-sided Hölder distortion estimate; the second
proved closure of the set-local antilipschitz class under *composition*
(`AntilipschitzOnWith.comp`) and the product-exponent composite bound
(`dimH_image_comp_bounds_of_biholderOn`). This cycle specialises composition to
the **self-map / iteration** setting — the actual home of iterated function
systems, dynamical attractors and conjugacy semigroups — proving that on an
invariant piece `s` (`MapsTo f s s`):

* `AntilipschitzOnWith.iterate` / `lipschitzOnWith_iterate`: the (anti)Lipschitz
  constant of `f^[n]` is `K^n`;
* `holderOnWith_iterate`: the Hölder exponent of `f^[n]` is the power `r^n`;
* `dimH_image_iterate_eq` (**main**): a set-local bi-Lipschitz self-map preserves
  Hausdorff dimension under *every* iterate, `dimH (f^[n] '' s) = dimH s`;
* `dimH_image_iterate_le`: the iterated Hölder distortion bound
  `dimH (f^[n] '' s) ≤ dimH s / r^n`.

The pieces are now in place for a genuine *semigroup* theory of set-local
distortion. The directions below are concrete, falsifiable next steps.

---

## Direction 1 — From discrete iterates to the monoid of distortion exponents

Right now `dimH_image_iterate_le` lives over `ℕ`: one map iterated `n` times. The
natural object is the free monoid generated by a finite family `{f_1, …, f_m}` of
maps that are each bi-Hölder on a common invariant `s`, indexed by words
`w ∈ {1,…,m}^*`. The conjecture is that for every word the composite
`f_w := f_{w_1} ∘ ⋯ ∘ f_{w_k}` satisfies `dimH (f_w '' s) ≤ dimH s / ∏ r_{w_i}`,
i.e. distortion exponents form a *multiplicative homomorphism* from the free
monoid into `(ℝ≥0, ·)`, with `dimH_image_iterate_le` the single-generator
restriction.

**The key insight is** that `HolderOnWith.comp` already multiplies exponents at
each composition step, so the only new content is bookkeeping a `List.prod` over
the word and an induction on word length — the per-letter invariance hypothesis
is exactly what the current iterate lemmas package per step.

**Why now?** The single-generator case (`holderOnWith_iterate`) is proved and
its induction is structurally identical to a `List.foldr`/`List.prod` induction;
the generalisation is reachable in one cycle rather than requiring new geometry.

---

## Direction 2 — Invariant-set dimension as a fixed point: the attractor bound

For a contraction `f` (`LipschitzOnWith K f s` with `K < 1`) mapping `s` into
itself, the orbit pieces `f^[n] '' s` are nested and shrink. The conjecture is a
*self-similarity dimension* statement: if `s` is the attractor (so
`f '' s = s` up to the relevant closure), then `dimH_image_iterate_eq` forces
`dimH (f^[n] '' s)` to be a constant sequence, and combined with a Moran-type
open set condition the common value is pinned to the similarity dimension
`log m / log (1/K)` for an `m`-map system.

**The key insight is** that `dimH_image_iterate_eq` already proves the sequence
`n ↦ dimH (f^[n] '' s)` is *constant* whenever `f` is set-local bi-Lipschitz, so
the attractor's dimension is a genuine fixed point of the iteration — the only
missing ingredient is the lower bound from a separation/open-set condition.

**Why now?** The constancy of the dimension under iteration is exactly the new
theorem proved this cycle; the open-set condition is a *combinatorial* hypothesis
(disjointness of images) that can be stated and consumed without new analysis.

---

## Direction 3 — Quantitative failure of invariance for genuinely Hölder maps

`dimH_image_iterate_le` only gives an upper bound `dimH s / r^n` when `r < 1`.
The companion *lower* bound (via a Hölder left inverse with exponent `r'`) would
give `dimH (f^[n] '' s) ≥ dimH s / (r')^{-n}`-type control, squeezing the
iterated image dimension into a shrinking-or-growing geometric corridor. The
falsifiable claim: there exist explicit snowflake maps on `[0,1]` for which the
two iterated bounds are *both tight*, so the corridor cannot be narrowed without
extra hypotheses.

**The key insight is** that the two-sided composite estimate
`dimH_image_comp_bounds_of_biholderOn` already supplies both directions for a
single composition; iterating the *inverse* exponent `r'` in parallel with `r`
yields the lower corridor wall, and a concrete `x ↦ x^a` example on `[0,1]`
witnesses tightness.

**Why now?** Both one-step bounds exist (forward in this file, two-sided in
`QuasiSymmetricComposition.lean`); assembling the iterated lower wall is the same
induction already written for the upper wall, and the counterexample is a
`Real.rpow` computation Mathlib supports directly.

---

## Direction 4 — Topological-entropy lower bound from antilipschitz iteration

`AntilipschitzOnWith.iterate` says distances can be recovered up to a factor
`K^n` after `n` steps. In dynamics this is precisely the separation rate that
lower-bounds topological entropy: an `(n, ε)`-separated set survives iteration
because the antilipschitz constant keeps images apart. The conjecture is a
clean inequality `h_top(f|_s) ≥ log(1/K_{anti})` whenever `f` is set-local
antilipschitz with constant `K_anti < 1` on a compact invariant `s`.

**The key insight is** that antilipschitz-on-`s` with constant `< 1` is exactly
an *expansivity* certificate, and `AntilipschitzOnWith.iterate` turns one-step
expansivity into the `K^n` separation needed for the standard Bowen entropy
lower bound — the dynamical content is already proved, only the entropy
definition needs wiring in.

**Why now?** Mathlib has compactness and the metric machinery; the bridge from
the newly-proved iterate separation to a span/separated-set count is a finite
combinatorial counting argument, not new analysis.

---

## Direction 5 — Bi-Lipschitz iteration invariance for box / Assouad dimension

`dimH_image_iterate_eq` is stated for Hausdorff dimension because that is what
Mathlib supports. The same iteration argument — `f^[n]` is bi-Lipschitz with
constants `K^n`, `K'^n`, and bi-Lipschitz maps preserve the dimension — should
hold verbatim for *box-counting* and *Assouad* dimension once those are
available. The conjecture: define a minimal set-local box-dimension in Lean and
prove `boxDim (f^[n] '' s) = boxDim s` by the identical composition/iteration
skeleton.

**The key insight is** that the entire iteration argument is *dimension-agnostic*
— it only uses that the chosen dimension is monotone under set-local Lipschitz
images and invariant under set-local bi-Lipschitz maps; abstracting these two
properties into a typeclass makes `dimH_image_iterate_eq` a one-line corollary
for every conforming dimension.

**Why now?** The proof of `dimH_image_iterate_eq` already factors through exactly
two interface lemmas (`LipschitzOnWith.dimH_image_le` and the bi-Lipschitz
invariance corollary); extracting them into a `SetLocalDimension` class is a
refactor that immediately pays off the moment any second dimension is formalised.

Research domain: Novelty
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



-- NEW_FILE: Catalog/Geometry/QuasiSymmetricComposition.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Set-local distortion of Hausdorff dimension: the composition layer

Mathlib records how *global* maps distort Hausdorff dimension:
`LipschitzOnWith.dimH_image_le` (Lipschitz maps do not increase `dimH`),
`HolderOnWith.dimH_image_le` (a Hölder map of exponent `r` divides `dimH` by `r`),
and `AntilipschitzWith.le_dimH_image` (a *globally* antilipschitz map does not
decrease `dimH`).  The last one is only available globally; there is no
set-local antilipschitz predicate in Mathlib.

This file introduces `QuasiSymmetricComposition.AntilipschitzOnWith`, the
set-local analogue of `AntilipschitzWith`, and develops exactly the closure and
distortion theory needed to run a *composition / semigroup* programme on
Hausdorff dimension:

* `AntilipschitzOnWith.injOn` — a set-local antilipschitz map is injective on `s`;
* `AntilipschitzOnWith.le_dimH_image` — the missing set-local lower bound
  `dimH s ≤ dimH (f '' s)`, proved by feeding the (Lipschitz) left inverse
  `Function.invFunOn f s` into `LipschitzOnWith.dimH_image_le`;
* `AntilipschitzOnWith.comp` — closure under composition, constants multiplying;
* `dimH_image_eq` — a set-local bi-Lipschitz map preserves `dimH (f '' s)`;
* `dimH_image_comp_eq` — bi-Lipschitz maps compose to a dimension-preserving map;
* `dimH_image_comp_holder_le` — the product-exponent composite Hölder bound.

These are the foundations consumed by `Geometry/QuasiSymmetricIterate.lean`,
which specialises composition to the self-map / iteration setting.
-/

import Mathlib

open MeasureTheory Set Function
open scoped NNReal ENNReal

namespace QuasiSymmetricComposition

variable {X Y Z : Type*} [EMetricSpace X] [EMetricSpace Y] [EMetricSpace Z]
variable {K K' : ℝ≥0} {f : X → Y} {s : Set X}

/-
!-- Lab Notebook -- !--
Hypothesis:  The bi-Lipschitz invariance `dimH (f '' s) = dimH s` should be
  recoverable set-locally, even though Mathlib only exposes the antilipschitz
  lower bound for *globally* defined maps (`AntilipschitzWith.le_dimH_image`).
Result:      Defining `AntilipschitzOnWith` and routing through the Lipschitz
  left inverse `Function.invFunOn f s` recovers the lower bound, giving
  `dimH_image_eq` with no global hypotheses on `f`.
Insight:     The set-local lower bound is *not* new geometry — it is the
  global upper bound `LipschitzOnWith.dimH_image_le` applied to the inverse map.
  Antilipschitz-on-`s` is precisely "the inverse is Lipschitz on `f '' s`".
Failure:     A direct `rw [← LeftInvOn.image_image]` rewrote *both* copies of `s`
  in `dimH s ≤ dimH (f '' s)`; isolating the left-hand `s` via a `calc` step
  (rewriting only the equality's RHS) fixed it.
-/

/-- `f` is **set-local antilipschitz** with constant `K` on `s`: distances between
points of `s` are recovered, up to the factor `K`, from the distances of their
images.  This is the set-local analogue of `AntilipschitzWith`. -/
def AntilipschitzOnWith (K : ℝ≥0) (f : X → Y) (s : Set X) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist x y ≤ K * edist (f x) (f y)

/-
!-- If `f x = f y` for `x, y ∈ s` then `edist x y ≤ K · 0 = 0`, so `x = y`. -!--
A set-local antilipschitz map is injective on its set. -/
theorem AntilipschitzOnWith.injOn (h : AntilipschitzOnWith K f s) : InjOn f s := by
  intro x hx y hy hfxy
  have := h hx hy
  rw [hfxy, edist_self, mul_zero, nonpos_iff_eq_zero, edist_eq_zero] at this
  exact this

/-
!-- The left inverse `g = invFunOn f s` is `K`-Lipschitz on `f '' s` (this is
exactly the antilipschitz inequality read backwards), and `g '' (f '' s) = s`, so
`dimH s = dimH (g '' (f '' s)) ≤ dimH (f '' s)` by `LipschitzOnWith.dimH_image_le`. -!--

The set-local lower bound: a set-local antilipschitz map does not decrease the
Hausdorff dimension of `s`.  This is the set-local analogue of
`AntilipschitzWith.le_dimH_image`. -/
theorem AntilipschitzOnWith.le_dimH_image [Nonempty X] (h : AntilipschitzOnWith K f s) :
    dimH s ≤ dimH (f '' s) := by
  have hinj := h.injOn
  have hlinv : LeftInvOn (invFunOn f s) f s := hinj.leftInvOn_invFunOn
  have hlip : LipschitzOnWith K (invFunOn f s) (f '' s) := by
    intro u hu v hv
    obtain ⟨a, ha, rfl⟩ := hu
    obtain ⟨b, hb, rfl⟩ := hv
    rw [hlinv ha, hlinv hb]
    exact h ha hb
  calc dimH s = dimH (invFunOn f s '' (f '' s)) := by rw [hlinv.image_image]
    _ ≤ dimH (f '' s) := hlip.dimH_image_le

/-
!-- Chain the two antilipschitz inequalities: `edist x y ≤ Kf · edist (f x) (f y)`
and `edist (f x) (f y) ≤ Kg · edist (g (f x)) (g (f y))`, multiplying constants. -!--

Closure under composition: set-local antilipschitz maps compose, with constants
multiplying.  (Here `f` maps `s` into `t` and `g` is antilipschitz on `t`.) -/
theorem AntilipschitzOnWith.comp {Kg Kf : ℝ≥0} {g : Y → Z} {f : X → Y} {t : Set Y}
    (hg : AntilipschitzOnWith Kg g t) (hf : AntilipschitzOnWith Kf f s)
    (hmaps : MapsTo f s t) : AntilipschitzOnWith (Kf * Kg) (g ∘ f) s := by
  intro x hx y hy
  calc edist x y ≤ Kf * edist (f x) (f y) := hf hx hy
    _ ≤ (Kf : ℝ≥0∞) * (Kg * edist (g (f x)) (g (f y))) := by
        gcongr; exact hg (hmaps hx) (hmaps hy)
    _ = ((Kf * Kg : ℝ≥0) : ℝ≥0∞) * edist (g (f x)) (g (f y)) := by
        rw [ENNReal.coe_mul]; ring

/-
!-- Antisymmetry of `≤`: the Lipschitz hypothesis gives `≤`, the antilipschitz
hypothesis gives `≥`. -!--

A set-local bi-Lipschitz map preserves the Hausdorff dimension of `s`. -/
theorem dimH_image_eq [Nonempty X] (hL : LipschitzOnWith K f s)
    (hA : AntilipschitzOnWith K' f s) : dimH (f '' s) = dimH s :=
  le_antisymm hL.dimH_image_le hA.le_dimH_image

/-
!-- `LipschitzOnWith.comp` and `AntilipschitzOnWith.comp` make `g ∘ f` bi-Lipschitz
on `s`; apply `dimH_image_eq`. -!--

Bi-Lipschitz maps compose to a dimension-preserving map: if `f` is set-local
bi-Lipschitz on `s` into `t` and `g` is set-local bi-Lipschitz on `t`, then
`g ∘ f` preserves `dimH (· '' s)`. -/
theorem dimH_image_comp_eq [Nonempty X] {Kf Kf' Kg Kg' : ℝ≥0} {g : Y → Z} {f : X → Y}
    {t : Set Y} (hLf : LipschitzOnWith Kf f s) (hAf : AntilipschitzOnWith Kf' f s)
    (hLg : LipschitzOnWith Kg g t) (hAg : AntilipschitzOnWith Kg' g t)
    (hmaps : MapsTo f s t) : dimH ((g ∘ f) '' s) = dimH s :=
  dimH_image_eq (hLg.comp hLf hmaps) (hAg.comp hAf hmaps)

/-
!-- `HolderOnWith.comp` multiplies the exponents to `rg * rf`; feed the composite
into `HolderOnWith.dimH_image_le` with `0 < rg * rf`. -!--

The product-exponent composite Hölder distortion bound: composing Hölder maps of
exponents `rf`, `rg` divides the dimension by their product `rg * rf`. -/
theorem dimH_image_comp_holder_le {Cf rf Cg rg : ℝ≥0} {g : Y → Z} {f : X → Y} {t : Set Y}
    (hg : HolderOnWith Cg rg g t) (hf :
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Iteration & Semigroup Theory for Set-Local Distortion of Hausdorff Dimension

## Synthesis

This cycle built, from scratch, the *set-local distortion* programme for Hausdorff
dimension in two Lean files under `Catalog/Geometry/`:

* `QuasiSymmetricComposition.lean` introduces the predicate
  `AntilipschitzOnWith K f s` — the genuinely new object, since Mathlib only has
  the *global* `AntilipschitzWith` and the global lower bound
  `AntilipschitzWith.le_dimH_image`. The file proves the set-local lower bound
  `AntilipschitzOnWith.le_dimH_image` (`dimH s ≤ dimH (f '' s)`), the injectivity
  `AntilipschitzOnWith.injOn`, closure under composition
  `AntilipschitzOnWith.comp`, the bi-Lipschitz invariance `dimH_image_eq`, the
  composite invariance `dimH_image_comp_eq`, and the product-exponent Hölder
  bound `dimH_image_comp_holder_le`.
* `QuasiSymmetricIterate.lean` specialises composition to the self-map / iteration
  setting on an invariant piece `s` (`MapsTo f s s`):
  `lipschitzOnWith_iterate` / `antilipschitzOnWith_iterate` (the constant of
  `f^[n]` is `K^n`), `holderOnWith_iterate` (the exponent of `f^[n]` is `r^n`),
  the **main** theorem `dimH_image_iterate_eq` (`dimH (f^[n] '' s) = dimH s` for
  every iterate), its restatement `dimH_image_iterate_const` (the orbit-piece
  dimension is a constant sequence — a fixed point of the iteration), and the
  iterated Hölder bound `dimH_image_iterate_le` (`dimH (f^[n] '' s) ≤ dimH s / r^n`).

The set-local lower bound is the conceptual keystone: it is *not* new geometry but
the Mathlib upper bound `LipschitzOnWith.dimH_image_le` applied to the Lipschitz
left inverse `Function.invFunOn f s`. With it, a genuine *semigroup* theory of
set-local distortion is now in place. The directions below are concrete,
falsifiable next steps.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `AntilipschitzOnWith.le_dimH_image` | `dimH s ≤ dimH (f '' s)` for set-local antilipschitz `f` | proved, axioms = {propext, Classical.choice, Quot.sound} |
| `AntilipschitzOnWith.comp` | set-local antilipschitz closed under composition | proved |
| `dimH_image_comp_eq` | bi-Lipschitz maps compose to a dimension-preserving map | proved |
| `dimH_image_iterate_eq` (main) | `dimH (f^[n] '' s) = dimH s` for set-local bi-Lipschitz self-maps | proved |
| `dimH_image_iterate_le` | `dimH (f^[n] '' s) ≤ dimH s / r^n` | proved |

---

## Direction 1 — From discrete iterates to the monoid of distortion exponents

`dimH_image_iterate_le` lives over `ℕ`: one map iterated `n` times. The natural
object is the free monoid on a finite family `{f_1, …, f_m}` of maps each
bi-Hölder on a common invariant `s`, indexed by words `w ∈ {1,…,m}^*`. Conjecture:
for every word the composite `f_w := f_{w_1} ∘ ⋯ ∘ f_{w_k}` satisfies
`dimH (f_w '' s) ≤ dimH s / ∏ r_{w_i}`, i.e. the distortion exponents form a
multiplicative homomorphism from the free monoid into `(ℝ≥0, ·)`, with
`dimH_image_iterate_le` the single-genera
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
