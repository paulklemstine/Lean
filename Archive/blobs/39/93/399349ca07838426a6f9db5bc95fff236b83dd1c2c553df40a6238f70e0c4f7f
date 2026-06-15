/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Strong (Three-Way) Hodge Decomposition: coexact ⊕ exact ⊕ harmonic

This file *extends* the Hodge–Betti theory of
`Catalog/Speculative/AutoResearch/HodgeBettiRank.lean` (`hodgeLap`, `hodgeLap_ker`,
`ker_adjoint_eq_orthogonal_range`, `range_e_le_ker_d`, `hodge_betti`) from the harmonic
*kernel dimension* to the full orthogonal **three-way splitting** of the cochain space.

For a two-step cochain complex of finite-dimensional real inner product spaces

  `U --e--> V --d--> W`        with the chain condition `d ∘ e = 0`,

the middle space `V` splits as a triple **orthogonal direct sum**

  `V = range d* ⊕ range e ⊕ ker Δ`     (coexact ⊕ exact ⊕ harmonic),

where `Δ = d* d + e e*` is the Hodge Laplacian.  The three summands are pairwise orthogonal,
they jointly span `V`, and their dimensions add up to `dim V`.  This is the operator-level,
basis-free form of the classical Hodge decomposition.

## Main results

* `orthogonal_ker_d_eq_range_adjoint_d` — `(ker d)ᗮ = range d*` (coexact = perp of closed).
* `range_e_le_orthogonal_range_adjoint_d` — exact ⊥ coexact: `range e ≤ (range d*)ᗮ`.
* `harmonic_le_orthogonal_range_e`        — harmonic ⊥ exact: `ker Δ ≤ (range e)ᗮ`.
* `harmonic_le_orthogonal_range_adjoint_d` — harmonic ⊥ coexact: `ker Δ ≤ (range d*)ᗮ`.
* `closed_eq_exact_sup_harmonic` — `range e ⊔ ker Δ = ker d` (Hodge split of closed cochains).
* `hodge_three_way_span` — `range d* ⊔ range e ⊔ ker Δ = ⊤` (the three summands span `V`).
* `hodge_three_way_finrank` — `dim (range d*) + dim (range e) + dim (ker Δ) = dim V`.

## Catalog synthesis

This realizes **Research Direction 2** ("strong three-way Hodge decomposition") of
`HodgeBettiRank`'s FUTURE_DIRECTIONS.  The kernel description `hodgeLap_ker`, the image
orthogonality `ker_adjoint_eq_orthogonal_range`, and the chain inclusion `range_e_le_ker_d`
are now theorems, so the decomposition is pure `Submodule` bookkeeping: two nested
applications of orthogonal complementation (`Submodule.sup_orthogonal_of_hasOrthogonalProjection`,
`Submodule.sup_orthogonal_inf_of_hasOrthogonalProjection`) and orthogonal rank–nullity.
-/
import Mathlib
import Speculative.AutoResearch.HodgeBettiRank

namespace HodgeThreeWayDecomposition

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace
open HodgeBettiRank

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

-- !-- Lab Notebook -- !--
-- Hypothesis: Given the harmonic kernel description `ker Δ = ker d ⊓ ker e*` and
--   `ker e* = (range e)ᗮ`, the cochain space should split as a *triple* orthogonal direct
--   sum `V = range d* ⊕ range e ⊕ ker Δ`, with pairwise orthogonal, jointly spanning,
--   dimension-additive summands — the classical Hodge decomposition in operator form.
-- Result: All seven statements are proven sorry-free.  The geometric core is
--   `closed_eq_exact_sup_harmonic : range e ⊔ ker Δ = ker d` (Hodge split of the *closed*
--   space) which, sup-ed with the coexact piece `range d* = (ker d)ᗮ`, spans `V`.
-- Insight: The two load-bearing Mathlib facts are
--   `Submodule.sup_orthogonal_of_hasOrthogonalProjection : K ⊔ Kᗮ = ⊤` and its relative form
--   `Submodule.sup_orthogonal_inf_of_hasOrthogonalProjection : K₁ ≤ K₂ → K₁ ⊔ (K₁ᗮ ⊓ K₂) = K₂`.
--   With K₁ = range e ≤ K₂ = ker d, the relative form *is* the Hodge split, because
--   `K₁ᗮ ⊓ K₂ = (range e)ᗮ ⊓ ker d = ker Δ` after `hodgeLap_ker`.  The coexact identity
--   `(ker d)ᗮ = range d*` is `ker_adjoint_eq_orthogonal_range` applied to `d*` plus
--   `adjoint_adjoint` and double orthogonal complement.
-- Failure analysis: associativity/commutativity of `⊔` must be threaded carefully — the
--   span is `(range d* ⊔ range e) ⊔ ker Δ`, reassociated to `range d* ⊔ (range e ⊔ ker Δ)`
--   so the inner Hodge split fires first.  The dimension count needs `range d* = (ker d)ᗮ`
--   to convert `dim range d*` into `dim V − dim ker d` via `finrank_add_finrank_orthogonal`.
-- !-- end Lab Notebook -- !--

-- !-- Coexact = perp of closed.  Apply `ker_adjoint_eq_orthogonal_range` to `d*`:
--    `ker (d**) = (range d*)ᗮ`, and `d** = d` (`adjoint_adjoint`), so `ker d = (range d*)ᗮ`;
--    take orthogonals and use `Kᗮᗮ = K`. -- !--
theorem orthogonal_ker_d_eq_range_adjoint_d (d : V →ₗ[ℝ] W) :
    (LinearMap.ker d)ᗮ = LinearMap.range (LinearMap.adjoint d) := by
  have h : LinearMap.ker d = (LinearMap.range (LinearMap.adjoint d))ᗮ := by
    have := ker_adjoint_eq_orthogonal_range (LinearMap.adjoint d)
    rwa [LinearMap.adjoint_adjoint] at this
  rw [h, Submodule.orthogonal_orthogonal]

-- !-- Exact ⊥ coexact.  `range e ≤ ker d` (chain condition) and `(ker d)ᗮ = range d*`, so
--    `range e ≤ ((range d*)ᗮ)ᗮ`... more directly `range e ≤ ker d = (range d*)ᗮ`. -- !--
omit [FiniteDimensional ℝ U] in
theorem range_e_le_orthogonal_range_adjoint_d (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V)
    (hde : d ∘ₗ e = 0) :
    LinearMap.range e ≤ (LinearMap.range (LinearMap.adjoint d))ᗮ := by
  rw [← orthogonal_ker_d_eq_range_adjoint_d, Submodule.orthogonal_orthogonal]
  exact range_e_le_ker_d d e hde

-- !-- Harmonic ⊥ exact.  `ker Δ = ker d ⊓ ker e*` and `ker e* = (range e)ᗮ`, so
--    `ker Δ ≤ ker e* = (range e)ᗮ`. -- !--
theorem harmonic_le_orthogonal_range_e (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) ≤ (LinearMap.range e)ᗮ := by
  rw [hodgeLap_ker, ← ker_adjoint_eq_orthogonal_range]
  exact inf_le_right

-- !-- Harmonic ⊥ coexact.  `ker Δ ≤ ker d = (range d*)ᗮ`. -- !--
theorem harmonic_le_orthogonal_range_adjoint_d (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) ≤ (LinearMap.range (LinearMap.adjoint d))ᗮ := by
  rw [← orthogonal_ker_d_eq_range_adjoint_d, Submodule.orthogonal_orthogonal, hodgeLap_ker]
  exact inf_le_left

-- !-- Hodge split of the closed space.  `ker Δ = (range e)ᗮ ⊓ ker d` (via `hodgeLap_ker`,
--    `ker_adjoint_eq_orthogonal_range`), and `range e ≤ ker d`, so the relative orthogonal
--    complement lemma `K₁ ⊔ (K₁ᗮ ⊓ K₂) = K₂` gives `range e ⊔ ker Δ = ker d`. -- !--
theorem closed_eq_exact_sup_harmonic (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    LinearMap.range e ⊔ LinearMap.ker (hodgeLap d e) = LinearMap.ker d := by
  have hker : LinearMap.ker (hodgeLap d e)
      = (LinearMap.range e)ᗮ ⊓ LinearMap.ker d := by
    rw [hodgeLap_ker, ker_adjoint_eq_orthogonal_range, inf_comm]
  rw [hker]
  exact Submodule.sup_orthogonal_inf_of_hasOrthogonalProjection (range_e_le_ker_d d e hde)

-- !-- Three-way span.  Reassociate to `range d* ⊔ (range e ⊔ ker Δ)`, collapse the inner
--    sup to `ker d` (`closed_eq_exact_sup_harmonic`), rewrite `range d* = (ker d)ᗮ`, and
--    use `Kᗮ ⊔ K = ⊤`. -- !--
theorem hodge_three_way_span (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    LinearMap.range (LinearMap.adjoint d) ⊔ LinearMap.range e
      ⊔ LinearMap.ker (hodgeLap d e) = ⊤ := by
  rw [sup_assoc, closed_eq_exact_sup_harmonic d e hde,
    ← orthogonal_ker_d_eq_range_adjoint_d, sup_comm]
  exact Submodule.sup_orthogonal_of_hasOrthogonalProjection

-- !-- Dimension count.  Rewrite `dim range d* = dim (ker d)ᗮ`, then
--    `dim ker d + dim (ker d)ᗮ = dim V` (`finrank_add_finrank_orthogonal`) and
--    `dim ker Δ + dim range e = dim ker d` (`hodge_betti`) combine by `omega`. -- !--
theorem hodge_three_way_finrank (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    Module.finrank ℝ (LinearMap.range (LinearMap.adjoint d))
      + Module.finrank ℝ (LinearMap.range e)
      + Module.finrank ℝ (LinearMap.ker (hodgeLap d e)) = Module.finrank ℝ V := by
  have hcoex : Module.finrank ℝ (LinearMap.range (LinearMap.adjoint d))
      = Module.finrank ℝ (LinearMap.ker d)ᗮ := by
    rw [orthogonal_ker_d_eq_range_adjoint_d]
  have hperp := Submodule.finrank_add_finrank_orthogonal (K := LinearMap.ker d) (𝕜 := ℝ) (E := V)
  have hbetti := hodge_betti d e hde
  omega

end HodgeThreeWayDecomposition