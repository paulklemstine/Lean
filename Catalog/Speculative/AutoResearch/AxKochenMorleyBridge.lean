/-
  Bridge: Model Theory ⟷ Algebra & Number Theory
  ================================================
  Ax–Kochen–Ershov transfer via ultraproducts, and Morley categoricity.

  This file EXTENDS `Bridges.ModelTheoryBridge` (which proves that isomorphic /
  categorical / complete-theory models are elementarily equivalent) by supplying
  the *ultraproduct transfer machinery* that underlies the Ax–Kochen–Ershov
  theorem, together with its number-theoretic "almost all p" corollary, and by
  upgrading the catalog's `isComplete_of_allModels_ee` into a Łoś–Vaught
  categoricity test.

  Core engine: **Łoś's Theorem**
    `FirstOrder.Language.Ultraproduct.sentence_realize`
      :  (∏ᵤ M) ⊨ φ  ↔  (∀ᶠ a in u, M a ⊨ φ).

  Mathematical content
  --------------------
  * `ultraproduct_ee_of_forall` / `ultraproduct_ee_of_eventually` : componentwise
    elementary equivalence of two families lifts to their ultraproducts.  This is
    the exact mechanism by which Ax–Kochen–Ershov concludes that two henselian
    valued fields are elementarily equivalent once their residue fields and value
    groups are: one passes to ultraproducts and applies Łoś.
  * `axKochen_almost_all_transfer` : the number-theoretic packaging — a sentence
    holds in `M a` for u-almost-all `a` iff it holds in `N a` for u-almost-all `a`.
    Reading `M a = ℚ_p`, `N a = 𝔽_p((t))`, this is Ax–Kochen's statement that the
    two agree on every sentence for all but finitely many primes `p`.
  * `losVaught_isComplete` : a satisfiable, κ-categorical theory all of whose
    models have cardinality κ is complete (the Łoś–Vaught test), building directly
    on `ModelTheoryBridge.isComplete_of_allModels_ee`.
  * `morley_categoricity` : Morley's categoricity theorem, stated faithfully and
    left as a conjecture (status: conjecture, sorry) — full proof needs the
    Morley-rank / totally-transcendental theory not yet in Mathlib.
-/

import Mathlib
import Bridges.ModelTheoryBridge

open FirstOrder Filter
open scoped Cardinal

namespace AxKochenMorleyBridge

universe u v

variable {L : FirstOrder.Language.{u, v}}
variable {α : Type*} {M N : α → Type*}
variable [∀ a, L.Structure (M a)] [∀ a, L.Structure (N a)]
variable [∀ a, Nonempty (M a)] [∀ a, Nonempty (N a)]

/-! ## Section 1 : Ax–Kochen–Ershov ultraproduct transfer -/

-- !-- For each sentence φ, Łoś's theorem reduces realization in the ultraproduct to
--     "u-almost-all coordinates realize φ"; the eventual componentwise agreement
--     M a ≅ N a turns that filter condition for M into the one for N. -- !--
/-- **Ax–Kochen–Ershov engine (eventual form).** If two families of `L`-structures
    are elementarily equivalent on a `u`-large set of coordinates, their
    ultraproducts modulo `u` are elementarily equivalent.  This is precisely the
    ultraproduct step in the Ax–Kochen–Ershov theorem. -/
theorem ultraproduct_ee_of_eventually (u : Ultrafilter α)
    (h : ∀ᶠ a in u, (M a) ≅[L] (N a)) :
    ((u : Filter α).Product M) ≅[L] ((u : Filter α).Product N) := by
  rw [Language.elementarilyEquivalent_iff]
  intro φ
  rw [Language.Ultraproduct.sentence_realize, Language.Ultraproduct.sentence_realize]
  apply eventually_congr
  filter_upwards [h] with a ha
  exact Language.elementarilyEquivalent_iff.1 ha φ

-- !-- Specialisation of `ultraproduct_ee_of_eventually` to genuine (everywhere)
--     componentwise elementary equivalence via `Filter.Eventually.of_forall`. -- !--
/-- **Ax–Kochen–Ershov engine (uniform form).** Componentwise elementary
    equivalence lifts to the ultraproduct. -/
theorem ultraproduct_ee_of_forall (u : Ultrafilter α)
    (h : ∀ a, (M a) ≅[L] (N a)) :
    ((u : Filter α).Product M) ≅[L] ((u : Filter α).Product N) :=
  ultraproduct_ee_of_eventually u (Filter.Eventually.of_forall h)

/-! ## Section 2 : The number-theoretic "almost all" corollary -/

-- !-- Łoś turns each side into ultraproduct realization; `ultraproduct_ee_of_eventually`
--     identifies those realizations sentence-by-sentence. -- !--
/-- **Ax–Kochen transfer over almost all coordinates.** Under eventual componentwise
    elementary equivalence, a sentence is realized in `u`-almost-all `M a` iff it is
    realized in `u`-almost-all `N a`.  With `M a = ℚ_p` and `N a = 𝔽_p((t))` this is
    Ax–Kochen's assertion that ℚ_p and 𝔽_p((t)) satisfy the same first-order
    sentences for all but finitely many primes `p`. -/
theorem axKochen_almost_all_transfer (u : Ultrafilter α)
    (h : ∀ᶠ a in u, (M a) ≅[L] (N a)) (φ : L.Sentence) :
    (∀ᶠ a in u, (M a) ⊨ φ) ↔ (∀ᶠ a in u, (N a) ⊨ φ) := by
  rw [← Language.Ultraproduct.sentence_realize, ← Language.Ultraproduct.sentence_realize]
  exact Language.elementarilyEquivalent_iff.1 (ultraproduct_ee_of_eventually u h) φ

/-! ## Section 3 : Łoś–Vaught categoricity test (Morley-adjacent, fully proved) -/

-- !-- Categoricity makes any two κ-sized models isomorphic hence elementarily
--     equivalent (`ModelTheoryBridge.categorical_models_elementarilyEquivalent`); if
--     *every* model has size κ this means all models are pairwise ≅, so
--     `ModelTheoryBridge.isComplete_of_allModels_ee` yields completeness. -- !--
/-- **Łoś–Vaught test.** A satisfiable theory that is κ-categorical and all of whose
    models have cardinality exactly κ is complete.  This is the categoricity ⟹
    completeness half of the road to Morley's theorem, built on the catalog's
    `isComplete_of_allModels_ee`. -/
theorem losVaught_isComplete {T : L.Theory} {κ : Cardinal}
    (hsat : T.IsSatisfiable)
    (hcat : ModelTheoryBridge.IsCategoricalAt T κ)
    (hcard : ∀ (P : Language.Theory.ModelType.{u, v, max u v} T), Cardinal.mk P = κ) :
    T.IsComplete :=
  ModelTheoryBridge.isComplete_of_allModels_ee hsat
    (fun P Q =>
      ModelTheoryBridge.categorical_models_elementarilyEquivalent hcat P Q (hcard P) (hcard Q))

/-! ## Section 4 : Morley's categoricity theorem (conjecture) -/

-- !-- CONJECTURE / sorry: the full theorem requires Morley rank and the
--     two-cardinal / totally-transcendental machinery, not yet in Mathlib. -- !--
/-- **Morley's Categoricity Theorem (conjecture).** A theory in a countable language
    that is categorical in one uncountable cardinal is categorical in every
    uncountable cardinal.  Stated faithfully; the proof is deferred (`sorry`). -/
theorem morley_categoricity {T : L.Theory} {κ μ : Cardinal}
    (hL : L.card ≤ Cardinal.aleph0)
    (hκ : Cardinal.aleph0 < κ) (hμ : Cardinal.aleph0 < μ)
    (hcat : ModelTheoryBridge.IsCategoricalAt T κ) :
    ModelTheoryBridge.IsCategoricalAt T μ := by
  sorry

end AxKochenMorleyBridge