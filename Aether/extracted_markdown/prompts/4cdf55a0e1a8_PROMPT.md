
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

**Title**: The file `Catalog/Applications/CombinatorialSpecies.lean` established the expone
**Domain**: Novelty
**Mathematical framing**: # Future Directions — The Taylor Tower of Combinatorial Species

## Synthesis

The file `Catalog/Applications/CombinatorialSpecies.lean` established the exponential-generating-function (EGF) dictionary for the *monoidal* (sum `egf_add`, Day-convolution product `egf_mul` / `egf_card_prodSpecies`) and *first-order differential* (`egf_derivative`, `EGF_derivativeSpecies`, `EGF_pointedSpecies`, `egf_injective`) structure of Joyal's species. Subsequent cycles bundled the convolution **ring** of counting sequences (`Catalog/Applications/SpeciesConvolutionRing.lean`: `binConv_assoc`, `binConv_one_left/right`, `binConv_leibniz`, `egf_binConvPow`), proved `egf` **bijective** (`Catalog/Applications/SpeciesAnalyticBridge.lean`: `egf_surjective`, `egf_bijective`, `egf_seqDeriv`, `egf_seqPoint`), and gave the **homotopy / groupoid-cardinality** reading (`Catalog/Applications/SpeciesHomotopyCardinality.lean`: `Species.EGF_coeff_eq_actionGroupoidCard`).

This cycle (`Catalog/Applications/SpeciesTaylorCalculus.lean`) **iterates** the first-order differential bridge into the full **Taylor tower**. Whereas `EGF_derivativeSpecies` is the `k = 1` shadow, the new results handle all `k` at once and culminate in a reconstruction theorem:

- `egf_seqDeriv_iterate` — the `k`-fold shift `a ↦ a(·+k)` of counting sequences is intertwined with the `k`-fold formal derivative `derivativeFun^[k]` on `ℚ⟦X⟧`.
- `coeffSeq_iterate_derivative` — `F^{(k)}[n] = F[n+k]`: iterating Joyal's derivative species adds `k` ghost points.
- `taylor_coeffSeq` — `F^{(k)}[0] = F[k]`: evaluating the tower at the origin reads off the counting sequence one coefficient at a time.
- `EGF_iterate_derivative` — `(F^{(k)}).EGF = derivativeFun^[k] (F.EGF)`: the tower of derivative species is the analytic tower of formal derivatives.
- `species_maclaurin` — `coeff₀ (derivativeFun^[k] (F.EGF)) = F[k]`: the constant term of the `k`-fold formal derivative of the EGF recovers the *un-normalised* count `F[k]`, because the exponential normalisation `/n!` exactly cancels the `k!` of an ordinary Maclaurin expansion.

## Results Summary

Five new theorems, zero `sorry` on main results, all depending only on the standard axioms `propext, Classical.choice, Quot.sound`. The Taylor tower is realised as the iterated derivative functor on the core groupoid, and `species_maclaurin` exhibits the EGF as the natural transform whose iterated formal derivatives reconstruct the species coefficient-by-coefficient. The whole development reduces, by `egf_injective`, to assembling the already-proved `k=1` bridges under `Function.iterate` inductions.

## Research Directions

### 1. The exponential formula `EGF(E ∘ G) = exp(EGF G)` for connected structures

Composition (substitution / plethysm) `F ∘ G` remains the one major operation absent from the formalized dictionary, and its flagship instance `F = E` is the celebrated exponential formula: assembling a set of `G`-structures over a partition of the labels has EGF `exp(EGF G)` whenever `G` carries no structure on the empty set. The falsifiable target is `(setSpecies.comp G).EGF = PowerSeries.rescale/substitute (PowerSeries.exp ℚ) (G.EGF)` under the hypothesis `G.coeffSeq 0 = 0`. **The key insight is** that the partition-indexed sum defining composition is governed coefficientwise by the Bell / Faà di Bruno expansion, which is precisely the expansion of `exp` applied to a power series with zero constant term; and with the new `species_maclaurin` in hand, both sides can be compared *coefficient-by-coefficient* against the derivative tower rather than by constructing the natural isomorphism of structure sets. **Why now?** `EGF_setSpecies` pins the `E ↔ exp` half and `card_prodSpecies` provides the proof template; the only genuinely new lemma is `card_compSpecies`, a cardinality count over set partitions (`Finset` of blocks) structurally analogous to the already-proved product count.

### 2. The species Taylor series: reconstructing `F.EGF` from its tower at the origin

`species_maclaurin` extracts each coefficient `F[k]` as `coeff₀ (derivativeFun^[k] (F.EGF))`; the natural next theorem assembles them back into the whole series: `F.EGF = PowerSeries.mk (fun k => coeff₀ (derivativeFun^[k] (F.EGF)) / k!)`, i.e. the species *is* the formal Taylor series of its own derivative tower. The falsifiable claim is the identity `egf (fun k => (coeff₀ (derivativeFun^[k] (F.EGF)) : ℚ)) = F.EGF`. **The key insight is** that, because `egf` is a bijection (`egf_bijective`) and `species_maclaurin` shows the tower-at-origin map is its *inverse* on counting data, the Taylor expansion is not an analytic limit but an exact algebraic inversion — the discrete (1-truncated) core groupoid makes the Taylor "tower" literally finite at each coefficient. **Why now?** `species_maclaurin` already supplies the per-coefficient extraction, so the remaining step is a single `PowerSeries.ext` comparing `coeff k` on both sides via `coeff_egf` — a one-lemma assembly.

### 3. The higher Leibniz rule (Faà di Bruno backbone) for the derivative tower

`binConv_leibniz` (one cycle ago) gives the first-order product rule; iterating it with the new `egf_seqDeriv_iterate` should yield the binomial Leibniz expansion `(F·G)^{(k)} ≅ Σ_{i+j=k} C(k,i) · F^{(i)} · G^{(j)}` at the EGF level. The falsifiable target is `derivativeFun^[k] (F.EGF * G.EGF) = Σ_{i ∈ range (k+1)} C(k,i) • (derivativeFun^[i] F.EGF) * (derivativeFun^[k-i] G.EGF)`. **The key insight is** that the Cauchy product on `ℚ⟦X⟧` turns the `k`-fold derivative of a product into the *binomial* convolution of derivative towers — exactly the `n!`-twist that already governs `binConv` — so the higher Leibniz rule is the species shadow of a pure `derivativeFun_mul` induction. **Why now?** `derivativeFun_mul` is in Mathlib, `egf_mul` translates the product, and `egf_seqDeriv_iterate` translates each tower entry; the direction is a `Finset.sum`-indexed induction whose base and step are both already-proved bridges.

### 4. Iterated pointing and the Euler-operator powers `(X d/dX)^k`

`EGF_pointedSpecies` gives `EGF(F•) = X · (F.EGF)′`, the Euler operator `θ = X d/dX`. Iterating pointing weights the `n`-th coefficient by `n^k`, so the conjecture is `EGF(F^{•k}) = θ^[k] (F.EGF)` together with the Stirling-number expansion `θ^k = Σ_j S(k,j) Xʲ (d/dX)ʲ` connecting iterated pointing to the *falling-factorial* / ordinary-derivative towers of Direction 2. The falsifiable claim is `(Species.pointed^[k] F).coeffSeq n = n^k * F.coeffSeq n` and its EGF shadow `(Species.pointed^[k] F).EGF = (fun s => X * s.derivativeFun)^[k] (F.EGF)`. **The key insight is** that pointing and the derivative are the *two* lifts of `d/dX` to species — multiplicative (`θ`) versus shift — and their interaction is exactly the Stirling transform that converts moment weighting `n^k` into factorial weighting `n!/(n-j)!`. **Why now?** `coeffSeq_pointed` and `EGF_pointedSpecies` are the `k=1` instances, and the iteration mirrors the `Function.iterate` inductions just completed for the derivative tower, so the proof architecture is a known quantity.

### 5. Functoriality of the derivative tower under species isomorphism (homotopy invariance of `d/dX`)

`Catalog/Applications/SpeciesHomotopyCardinality.lean` shows the EGF is a groupoid-cardinality invariant; the derivative functor should respect that invariance: isomorphic species have isomorphic derivative towers, `F ≅ G ⇒ F^{(k)} ≅ G^{(k)}` and hence (already, via the EGF) `F^{(k)}.EGF = G^{(k)}.EGF`. The falsifiable target is a `Species.Iso`-preservation lemma `Species.Iso F G → Species.Iso (Species.derivative F) (Species.derivative G)`, upgraded to `derivative^[k]` by the present `coeffSeq_iterate_derivative`. **The key insight is** that `Species.derivative` is built from `Equiv.Perm.viaEmbeddingHom (Fin.castSuccEmb)`, an equivariant lift, so it descends to the localization that inverts relabelling equivalences — `d/dX` is a functor on the *homotopy category* of species, not merely on the skeletal one. **Why now?** The `act` field and the homotopy-cardinality theorem are already in place, and `coeffSeq_iterate_derivative` reduces the `k`-fold case to the `k=1` case, so only the single-step iso-preservation lemma is missing to make the entire differential calculus homotopy-invariant.

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



-- NEW_FILE: Catalog/Speculative/AutoResearch/SpeciesTaylorReconstruction.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Taylor Reconstruction, Iterated Pointing, and the Higher Leibniz Rule for Species

This file iterates the *differential* dictionary of combinatorial species one further turn,
building directly on the Taylor tower of
`Catalog/Speculative/AutoResearch/SpeciesTaylorCalculus.lean` and the bridges of
`Catalog/Applications/CombinatorialSpecies.lean` /
`Catalog/Applications/SpeciesAnalyticBridge.lean`.

Three independent extensions are formalized:

* **Taylor reconstruction (FUTURE_DIRECTIONS #2).** `species_maclaurin` extracts each
  coefficient `F[k]` as `coeff₀ (derivativeFun^[k] (F.EGF))`.  Here we *assemble* the tower
  back into the whole series: a power series `f` over `ℚ` is the formal Taylor series of its
  own derivative tower, `egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`.  Because `egf` is a
  bijection (`egf_seqOf`) and the tower-at-origin map is its inverse on counting data, the
  Taylor expansion is an exact *algebraic* inversion, finite at each coefficient.

* **Iterated pointing and the Euler operator `(X d/dX)^k` (FUTURE_DIRECTIONS #4).** Iterating
  Joyal's pointed species `F•[n] = [n] × F[n]` weights the `n`-th count by `n^k`,
  `(F^{•k})[n] = n^k · F[n]`, and on the analytic side this is the `k`-fold Euler operator
  `θ = X · d/dX`, `(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`.

* **The higher Leibniz rule (FUTURE_DIRECTIONS #3).** The `k`-fold formal derivative of a
  product is the binomial convolution of the derivative towers,
  `(f·g)^{(k)} = Σ_{i≤k} C(k,i) · f^{(i)} · g^{(k-i)}` — the Faà-di-Bruno backbone whose
  species shadow is the higher product rule for `binConv`.

## Main results
* `coeff_zero_iterate_derivativeFun` — `coeff₀ (derivativeFun^[k] (egf a)) = a k`.
* `taylor_reconstruction`           — `egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`.
* `coeffSeq_iterate_pointed`        — `(F^{•k})[n] = n^k · F[n]`.
* `EGF_iterate_pointed`             — `(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`.
* `derivativeFun_iterate_mul`       — the higher (binomial) Leibniz rule on `ℚ⟦X⟧`.
-/
import Mathlib
import Catalog.Applications.SpeciesAnalyticBridge
import Catalog.Speculative.AutoResearch.SpeciesTaylorCalculus

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-
-- !-- Lab Notebook -- !--
Hypothesis: `species_maclaurin` gives a per-coefficient *extraction* `coeff₀ (d/dX)^[k] f = a k`;
  the natural dual is a per-coefficient *reconstruction* that re-assembles the whole series.
  Iterated pointing should weight counts by `n^k` (the Euler operator `θ = X d/dX`), and the
  k-fold derivative of a product should obey a binomial Leibniz expansion.

Result: All five theorems proved with no `sorry`.  Reconstruction follows from
  `egf_seqDeriv_iterate` (the k-fold shift bridge) read at `coeff 0`, combined with
  `egf_seqOf`/surjectivity.  Iterated pointing is two clean `Function.iterate` inductions
  (`coeffSeq_pointed` + `EGF_pointedSpecies` as the one-step bridges).  The higher Leibniz rule
  is a single induction on `k` using Mathlib's `derivativeFun_mul` and the Pascal identity.

Insight: the Taylor tower is *invertible*: `coeff₀ ∘ (d/dX)^[·]` and `egf` are mutually inverse
  on counting data, so the discrete species "Taylor series" is an exact algebraic identity, not
  an analytic limit.  Pointing (`θ`, multiplicative) and the derivative species (shift) are the
  two lifts of `d/dX` to species; their EGF shadows are `X·d/dX` and `d/dX` respectively.

Failure analysis: the reconstruction proof must avoid re-deriving `species_maclaurin` per `k`;
  routing through `egf_seqDeriv_iterate` at `coeff 0` (where `0 + k = k`) keeps it a one-liner.
  The Leibniz induction needs the index split `range (k+2)` via `Finset.sum_range_succ'`/Pascal;
  delegating the algebra to `derivativeFun` linearity avoids antidiagonal bookkeeping.
-/

/-! ### Taylor reconstruction: a power series is the Taylor series of its derivative tower -/

/-
!-- Read `egf_seqDeriv_iterate a k` at `coeff 0`: LHS `coeff 0 (egf (a(·+k))) = a(0+k)/0! = a k`,
RHS `coeff 0 (derivativeFun^[k] (egf a))`; equate. -- !--

**Taylor coefficient extraction (analytic form).** The constant term of the `k`-fold formal
derivative of `egf a` is exactly `a k`: the exponential normalisation cancels the factorial.
-/
theorem coeff_zero_iterate_derivativeFun (a : ℕ → ℚ) (k : ℕ) :
    PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] (egf a)) = a k := by
  rw [ ← egf_seqDeriv_iterate ];
  simp +decide [ egf, Nat.factorial ]

/-
!-- Write `f = egf (seqOf f)` via `egf_seqOf`; then `coeff₀ (derivativeFun^[k] f) = seqOf f k`
by `coeff_zero_iterate_derivativeFun`, so the LHS is `egf (seqOf f) = f`. -- !--

**Taylor reconstruction.** Every formal power series over `ℚ` is the exponential generating
function of its own derivative tower evaluated at the origin:
`egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`.  Since `egf` is a bijection and the
tower-at-origin map is its inverse on counting data, this is an exact algebraic inversion.
-/
theorem taylor_reconstruction (f : ℚ⟦X⟧) :
    egf (fun k => PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] f)) = f := by
  rw [ ← egf_seqOf f ];
  exact congr_arg _ ( funext fun k => by rw [ coeff_zero_iterate_derivativeFun ] )

/-- **Species Taylor series.** A species is the formal Taylor series of its own derivative
tower: `egf (k ↦ coeff₀ (derivativeFun^[k] (F.EGF))) = F.EGF`. -/
theorem species_taylor_series (F : Species) :
    egf (fun k => PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] F.EGF)) = F.EGF :=
  taylor_reconstruction F.EGF

/-! ### Iterated pointing and the Euler operator `(X d/dX)^k` -/

/-
!-- Induction on `k` generalizing nothing; step uses `Function.iterate_succ_apply'` to expose
the outer `pointed`, then `coeffSeq_pointed` and the IH, finishing with `pow_succ`. -- !--

**Iterated pointing weights counts by `n^k`.** Distinguishing `k` (ordered, with repetition)
labels multiplies the `n`-th count by `n^k`: `(F^{•k})[n] = n^k · F[n]`.
-/
theorem coeffSeq_iterate_pointed (F : Species) (k n : ℕ) :
    (Species.pointed^[k] F).coeffSeq n = n ^ k * F.coeffSeq n := by
  induction' k with k ih generalizing n <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ, mul_assoc ];
  ring

/-
!-- Induction on `k`; step rewrites both sides with `Function.iterate_succ_apply'`, applies
`EGF_pointedSpecies` to the outer pointing, then the IH. -- !--

**EGF of the iterated pointed species is the `k`-fold Euler operator.**
`(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`.
-/
theorem EGF_iterate_pointed (F : Species) (k : ℕ) :
    (Species.pointed^[k] F).EGF
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Taylor Reconstruction, Iterated Pointing, and Higher Leibniz for Species

## Synthesis

The species program had, before this cycle, built the exponential-generating-function (EGF)
dictionary for the *monoidal* structure (sum `egf_add`, Day-convolution product `egf_mul` /
`egf_card_prodSpecies`), the *first-order differential* structure (`egf_derivative`,
`EGF_derivativeSpecies`, `EGF_pointedSpecies`, `egf_injective`), the convolution **ring** of
counting sequences (`binConv_assoc`, `binConv_leibniz`, `egf_binConvPow`,
`ConvSeq.egfRingEquiv`), the **bijectivity** of `egf` (`egf_surjective`, `egf_bijective`,
`seqOf`), and the **Taylor tower** of higher derivatives
(`Catalog/Speculative/AutoResearch/SpeciesTaylorCalculus.lean`:
`egf_seqDeriv_iterate`, `coeffSeq_iterate_derivative`, `EGF_iterate_derivative`,
`species_maclaurin`).

This cycle (`Catalog/Speculative/AutoResearch/SpeciesTaylorReconstruction.lean`) closes the
*inverse* of the Taylor tower and opens two adjacent towers. `species_maclaurin` extracted a
single coefficient `F[k] = coeff₀ (derivativeFun^[k] (F.EGF))`; we now invert that extraction,
iterate the *pointing* operator, and prove the *higher* product rule:

- `coeff_zero_iterate_derivativeFun` — `coeff₀ (derivativeFun^[k] (egf a)) = a k`: the analytic,
  species-free form of Maclaurin extraction.
- `taylor_reconstruction` — `egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`: **every** power
  series over `ℚ` is the formal Taylor series of its own derivative tower. Because `egf` is a
  bijection and the tower-at-origin map is its set-theoretic inverse on counting data, this is an
  exact algebraic inversion that terminates at each coefficient — not an analytic limit.
- `species_taylor_series` — the species specialization: `F.EGF` is reconstructed from its own
  derivative tower at the origin.
- `coeffSeq_iterate_pointed` — `(F^{•k})[n] = n^k · F[n]`: iterated pointing is moment weighting.
- `EGF_iterate_pointed` — `(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`: the iterated pointed species is
  the `k`-fold Euler operator `θ = X d/dX` on the EGF.
- `derivativeFun_iterate_mul` — the higher (binomial) Leibniz rule
  `(f·g)^{(k)} = Σ_{i≤k} C(k,i) · f^{(i)} · g^{(k-i)}` on `ℚ⟦X⟧`, the Faà-di-Bruno backbone.

## Results Summary

Six new theorems, zero `sorry` on main results, all depending only on the standard axioms
`propext, Classical.choice, Quot.sound`. The derivative tower is now known to be *invertible*
(`taylor_reconstruction` exhibits the inverse of `species_maclaurin`), the *moment* tower
(iterated pointing) is identified with the iterated Euler operator, and the *higher product*
tower (binomial Leibniz) is established on power series. As a side effect, a pre-existing
duplicate-declaration build error in `Catalog/Applications/SpeciesAnalyticBridge.lean`
(`egf_injective` re-declared) was repaired, so the whole species stack now compiles, and a
`lean_lib` entry covering the `Catalog.` module prefix was added to `lakef
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
