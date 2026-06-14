/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Hodge Isomorphism: the harmonic space *is* the cohomology

This file *extends* the Hodge–Betti dimension count of
`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` (`hodge_betti`, `hodgeLap_ker`) and
the three-way splitting of
`Catalog/Speculative/AutoResearch/HodgeThreeWayDecomposition.lean`
(`closed_eq_exact_sup_harmonic`, `harmonic_le_orthogonal_range_e`) from an *equidimensional*
statement (`dim (ker Δ) = dim ker d − rank e`) to a genuine **linear isomorphism**

  `ker Δ  ≅  Hᵏ = ker d / range e`            (`hodgeCohomologyEquiv`),

the classical **Hodge isomorphism**: every cohomology class of the cochain complex
`U --e--> V --d--> W` (with `d ∘ e = 0`) contains exactly one harmonic representative.

The content is split into the two halves of "exactly one":

* **Existence.** Every closed cochain is harmonic plus exact (`harmonic_representative_exists`).
* **Uniqueness.** Two harmonic cochains in the same cohomology class are equal
  (`harmonic_representative_unique`), because harmonic ∩ exact `= 0`
  (`harmonic_inf_exact_eq_bot`).

These combine into the explicit `LinearEquiv` `hodgeCohomologyEquiv`, built by
`Submodule.quotientEquivOfIsCompl` from the fact that, *inside the closed space* `ker d`, the
exact part `range e` and the harmonic part `ker Δ` are complementary (`hodge_isCompl`).

## Main results

* `harmonic_le_ker_d`            — harmonic cochains are closed: `ker Δ ≤ ker d`.
* `harmonic_inf_exact_eq_bot`    — harmonic ∩ exact `= ⊥` (orthogonality of the summands).
* `harmonic_representative_unique` — at most one harmonic representative per class.
* `harmonic_representative_exists` — at least one: every closed cochain `= exact + harmonic`.
* `hodge_isCompl`                — `range e` and `ker Δ` are complementary inside `ker d`.
* `hodgeCohomologyEquiv`         — **Hodge isomorphism** `(ker d / range e) ≃ₗ ker Δ`.

## Catalog synthesis

This realizes **Research Direction 1** ("the Hodge isomorphism, not just equidimensionality")
of `HodgeBettiRank`'s FUTURE_DIRECTIONS.  `closed_eq_exact_sup_harmonic` (from the three-way
file) supplies *existence/codisjointness*, while `harmonic_le_orthogonal_range_e` plus
`Submodule.inf_orthogonal_eq_bot` supplies *uniqueness/disjointness*; together they give
`IsCompl` inside `ker d`, and `Submodule.quotientEquivOfIsCompl` upgrades the dimension count
`hodge_betti` to a canonical isomorphism.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank
import Speculative.AutoResearch.HodgeThreeWayDecomposition

namespace HodgeIsomorphism

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank HodgeThreeWayDecomposition

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

-- !-- Lab Notebook -- !--
-- Hypothesis: The Hodge–Betti equality `dim ker Δ = dim ker d − rank e` should refine to a
--   canonical *linear isomorphism* `ker Δ ≅ ker d / range e`: the harmonic representative of
--   each cohomology class, existing and unique.  Inside the closed space `ker d`, the exact
--   part `range e` and the harmonic part `ker Δ` should be complementary submodules.
-- Result: All six statements are proven sorry-free.  `hodge_isCompl` is the structural core,
--   and `hodgeCohomologyEquiv` is the explicit Hodge isomorphism built from it.
-- Insight: Disjointness `range e ⊓ ker Δ = ⊥` is orthogonality (`ker Δ ≤ (range e)ᗮ` and
--   `K ⊓ Kᗮ = ⊥`); codisjointness `range e ⊔ ker Δ = ker d` is the Hodge split
--   `closed_eq_exact_sup_harmonic`.  Pulling both back along `(ker d).subtype` (which is
--   injective, so `Submodule.map` reflects equalities) turns these into `IsCompl` *inside*
--   `↥(ker d)`, exactly the hypothesis of `Submodule.quotientEquivOfIsCompl`.
-- Failure analysis: the isomorphism must be assembled in the ambient module `↥(ker d)`, not
--   `V` — `range e` and `ker Δ` are NOT complementary in `V` (their sup is `ker d ≠ ⊤`
--   whenever `d ≠ 0`).  `Submodule.comapSubtypeEquivOfLe` re-identifies the pulled-back
--   harmonic submodule with `ker Δ` itself, closing the type mismatch.
-- !-- end Lab Notebook -- !--

-- !-- Harmonic cochains are closed.  `ker Δ = ker d ⊓ ker e* ≤ ker d` (`hodgeLap_ker`). -- !--
theorem harmonic_le_ker_d (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) ≤ LinearMap.ker d := by
  rw [hodgeLap_ker]; exact inf_le_left

-- !-- Harmonic ∩ exact = 0.  `ker Δ ≤ (range e)ᗮ` (`harmonic_le_orthogonal_range_e`), so the
--    intersection sits inside `(range e)ᗮ ⊓ range e = ⊥` (`Submodule.inf_orthogonal_eq_bot`). -- !--
theorem harmonic_inf_exact_eq_bot (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) ⊓ LinearMap.range e = ⊥ := by
  have h : LinearMap.ker (hodgeLap d e) ⊓ LinearMap.range e
      ≤ (LinearMap.range e)ᗮ ⊓ LinearMap.range e :=
    inf_le_inf_right _ (harmonic_le_orthogonal_range_e d e)
  have hbot : (LinearMap.range e)ᗮ ⊓ LinearMap.range e = ⊥ := by
    rw [inf_comm]; exact Submodule.inf_orthogonal_eq_bot _
  rw [hbot] at h
  exact le_bot_iff.mp h

-- !-- Uniqueness of harmonic representatives.  If `h₁, h₂ ∈ ker Δ` and `h₁ - h₂ ∈ range e`,
--    then `h₁ - h₂ ∈ ker Δ ⊓ range e = ⊥`, so `h₁ = h₂`. -- !--
theorem harmonic_representative_unique (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (h₁ h₂ : V) (hh₁ : h₁ ∈ LinearMap.ker (hodgeLap d e))
    (hh₂ : h₂ ∈ LinearMap.ker (hodgeLap d e))
    (hdiff : h₁ - h₂ ∈ LinearMap.range e) : h₁ = h₂ := by
  have hmem : h₁ - h₂ ∈ LinearMap.ker (hodgeLap d e) ⊓ LinearMap.range e :=
    Submodule.mem_inf.mpr ⟨Submodule.sub_mem _ hh₁ hh₂, hdiff⟩
  rw [harmonic_inf_exact_eq_bot, Submodule.mem_bot] at hmem
  exact sub_eq_zero.mp hmem

-- !-- Existence of harmonic representatives.  A closed cochain `x ∈ ker d = range e ⊔ ker Δ`
--    (`closed_eq_exact_sup_harmonic`) lies in the sup, so `Submodule.mem_sup` gives an exact
--    part `e u` and a harmonic part `h` with `x = e u + h`. -- !--
theorem harmonic_representative_exists (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0)
    (x : V) (hx : x ∈ LinearMap.ker d) :
    ∃ u : U, ∃ h ∈ LinearMap.ker (hodgeLap d e), x = e u + h := by
  rw [← closed_eq_exact_sup_harmonic d e hde, Submodule.mem_sup] at hx
  obtain ⟨a, ha, h, hh, hsum⟩ := hx
  obtain ⟨u, rfl⟩ := ha
  exact ⟨u, h, hh, hsum.symm⟩

-- !-- Complementarity inside the closed space.  Pull `range e` and `ker Δ` back along
--    `(ker d).subtype`.  Disjoint: `comap` preserves `⊓`, and `range e ⊓ ker Δ = ⊥`.
--    Codisjoint: `Submodule.map (ker d).subtype` is injective and sends the sup to
--    `range e ⊔ ker Δ = ker d = map subtype ⊤`. -- !--
theorem hodge_isCompl (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    IsCompl (Submodule.comap (LinearMap.ker d).subtype (LinearMap.range e))
      (Submodule.comap (LinearMap.ker d).subtype (LinearMap.ker (hodgeLap d e))) := by
  constructor
  · rw [disjoint_iff, ← Submodule.comap_inf]
    have hbot : LinearMap.range e ⊓ LinearMap.ker (hodgeLap d e) = ⊥ := by
      rw [inf_comm]; exact harmonic_inf_exact_eq_bot d e
    rw [hbot, Submodule.comap_bot, Submodule.ker_subtype]
  · rw [codisjoint_iff]
    apply Submodule.map_injective_of_injective
      (Submodule.injective_subtype (LinearMap.ker d))
    rw [Submodule.map_sup, Submodule.map_comap_subtype, Submodule.map_comap_subtype,
      Submodule.map_subtype_top, inf_of_le_right (range_e_le_ker_d d e hde),
      inf_of_le_right (harmonic_le_ker_d d e)]
    exact closed_eq_exact_sup_harmonic d e hde

/-- The **Hodge isomorphism**: the cohomology `Hᵏ = ker d / range e` is canonically
isomorphic to the harmonic space `ker Δ`.  Each cohomology class has a unique harmonic
representative. -/
noncomputable def hodgeCohomologyEquiv (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    (↥(LinearMap.ker d) ⧸ Submodule.comap (LinearMap.ker d).subtype (LinearMap.range e))
      ≃ₗ[ℝ] ↥(LinearMap.ker (hodgeLap d e)) :=
  (Submodule.quotientEquivOfIsCompl _ _ (hodge_isCompl d e hde)).trans
    (Submodule.comapSubtypeEquivOfLe (harmonic_le_ker_d d e))

end HodgeIsomorphism