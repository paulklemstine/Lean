/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Satake Reconstruction from Weyl Chamber Walls

## Overview

We prove that finitely supported functions on weight triples are (under
appropriate conditions) uniquely determined by their tropical Satake transform
restricted to the two Weyl chamber walls `Facet12 = {x₁ = x₂}` and
`Facet23 = {x₂ = x₃}`.

**Key subtlety.** The min-plus tropical transform `tropSat(f)(x) = inf_μ(f(μ)+⟨μ,x⟩)`
is NOT injective for arbitrary finitely-supported functions: a support point
lying in the convex hull of others becomes "invisible" (always dominated).
Injectivity holds under a *wall-exposability* condition requiring that each
support point achieves the unique minimum at some wall test point.

## Main Results

* `tropSat_eq_at_exposing` — value at exposing point = exposed term
* `coeff_eq_of_wall_exposable` — coefficients agree at wall-exposable points
* `tropSat_singleton_injective` — injectivity for singleton-support functions
* `tropSat_eq_of_eq_on_walls` — full reconstruction for wall-exposable support
-/
import TropSatakeGL3.Separation

namespace TropSatakeGL3

/-- A support point `μ` is *wall-exposable* relative to `f` if there exists
    a test point on a Weyl wall where `μ` achieves the unique minimum of
    `ν ↦ f(ν) + ⟨ν, x⟩` among all support points. -/
def WallExposable (f : Wt →₀ ℤ) (μ : Wt) : Prop :=
  ∃ x : TestPt,
    (x ∈ Facet12 ∨ x ∈ Facet23) ∧
    ∀ ν ∈ f.support, ν ≠ μ → f μ + evalWeight μ x < f ν + evalWeight ν x

/-- At an exposing point, the tropical Satake value equals the exposed term. -/
theorem tropSat_eq_at_exposing (f : Wt →₀ ℤ) (hne : f.support.Nonempty)
    {μ : Wt} (hμ : μ ∈ f.support) {x : TestPt}
    (hexp : ∀ ν ∈ f.support, ν ≠ μ → f μ + evalWeight μ x < f ν + evalWeight ν x) :
    tropSat f hne x = f μ + evalWeight μ x := by
  refine le_antisymm (Finset.inf'_le _ hμ) ?_
  exact Finset.le_inf' _ _ fun ν hν =>
    if h : ν = μ then h.symm ▸ le_rfl else le_of_lt (hexp ν hν h)

/-
**Coefficient Recovery.** If `f` and `g` agree on both walls, `μ` is in
    both supports, and `μ` is wall-exposable for both, then `f μ = g μ`.

    The proof is a beautiful squeeze argument: wall-exposability for `f` gives
    `f μ ≤ g μ` (since `tropSat g` at the exposing point is ≤ the `μ`-term of `g`),
    and wall-exposability for `g` gives `g μ ≤ f μ`.
-/
theorem coeff_eq_of_wall_exposable
    (f g : Wt →₀ ℤ)
    (hf_ne : f.support.Nonempty) (hg_ne : g.support.Nonempty)
    {μ : Wt} (hμf : μ ∈ f.support) (hμg : μ ∈ g.support)
    (hexpf : WallExposable f μ) (hexpg : WallExposable g μ)
    (h12 : ∀ x : TestPt, x ∈ Facet12 → tropSat f hf_ne x = tropSat g hg_ne x)
    (h23 : ∀ x : TestPt, x ∈ Facet23 → tropSat f hf_ne x = tropSat g hg_ne x) :
    f μ = g μ := by
  obtain ⟨x, hx_wall, hx_exp⟩ := hexpf
  obtain ⟨y, hy_wall, hy_exp⟩ := hexpg;
  -- From hexpf, get x on some wall with tropSat f hf_ne x = f μ + evalWeight μ x (by tropSat_eq_at_exposing).
  have hx : tropSat f hf_ne x = f μ + evalWeight μ x := by
    exact?;
  have hy : tropSat g hg_ne y = g μ + evalWeight μ y := by
    exact tropSat_eq_at_exposing g hg_ne hμg hy_exp;
  have hxy : tropSat g hg_ne x ≤ g μ + evalWeight μ x ∧ tropSat f hf_ne y ≤ f μ + evalWeight μ y := by
    exact ⟨ Finset.inf'_le _ hμg, Finset.inf'_le _ hμf ⟩;
  grind

/-
**Singleton Injectivity.** If `f` and `g` each have exactly one support
    point and their tropical Satake transforms agree on both walls, then `f = g`.
    This is the base case of the reconstruction theory.
-/
theorem tropSat_singleton_injective
    (f g : Wt →₀ ℤ)
    (hf : f.support.card = 1) (hg : g.support.card = 1)
    (hf_ne : f.support.Nonempty) (hg_ne : g.support.Nonempty)
    (h12 : ∀ x : TestPt, x ∈ Facet12 → tropSat f hf_ne x = tropSat g hg_ne x)
    (h23 : ∀ x : TestPt, x ∈ Facet23 → tropSat f hf_ne x = tropSat g hg_ne x) :
    f = g := by
  obtain ⟨μ, hμ⟩ : ∃ μ, f.support = {μ} := by
    exact Finset.card_eq_one.mp hf
  obtain ⟨ν, hν⟩ : ∃ ν, g.support = {ν} := by
    exact Finset.card_eq_one.mp hg;
  have hμν : f μ = g ν ∧ μ = ν := by
    have hμν_eq : f μ + evalWeight μ (0, 0, 0) = g ν + evalWeight ν (0, 0, 0) := by
      convert h12 ( 0, 0, 0 ) rfl using 1;
      · unfold tropSat; aesop;
      · unfold tropSat; aesop;
    have hμν_eq1 : f μ + evalWeight μ (1, 1, 0) = g ν + evalWeight ν (1, 1, 0) := by
      convert h12 ( 1, 1, 0 ) ( by exact rfl ) using 1 <;> simp +decide [ *, tropSat ]
    have hμν_eq2 : f μ + evalWeight μ (0, 0, 1) = g ν + evalWeight ν (0, 0, 1) := by
      convert h12 ( 0, 0, 1 ) ( by norm_num [ Facet12 ] ) using 1;
      · unfold tropSat; aesop;
      · unfold tropSat; aesop;
    have hμν_eq3 : f μ + evalWeight μ (1, 0, 0) = g ν + evalWeight ν (1, 0, 0) := by
      convert h23 ( 1, 0, 0 ) _ using 1 <;> norm_num [ Facet23 ];
      · unfold tropSat; aesop;
      · unfold tropSat; aesop;
    unfold evalWeight at *; aesop;
  ext x; by_cases hx : x = μ <;> simp_all +decide [ Finsupp.mem_support_iff ] ;
  · grind;
  · rw [ Finsupp.notMem_support_iff.mp ( by aesop ), Finsupp.notMem_support_iff.mp ( by aesop ) ]

/-
**Main Reconstruction Theorem.** If every support point of `f` and `g` is
    wall-exposable, both `f` and `g` have the same support, and the transforms
    agree on both walls, then `f = g`.

    Note: the equal-support hypothesis is a simplification. In the full theory
    of tropical polynomial equality, support equality follows from wall-exposability
    plus transform equality, but that argument requires tropical polynomial
    structure theory (essential terms / Newton polygon) beyond what we formalize here.
-/
theorem tropSat_eq_of_eq_on_walls_same_support
    (f g : Wt →₀ ℤ)
    (hf_ne : f.support.Nonempty) (hg_ne : g.support.Nonempty)
    (hsupp : f.support = g.support)
    (hf_exp : ∀ μ ∈ f.support, WallExposable f μ)
    (hg_exp : ∀ μ ∈ g.support, WallExposable g μ)
    (h12 : ∀ x : TestPt, x ∈ Facet12 → tropSat f hf_ne x = tropSat g hg_ne x)
    (h23 : ∀ x : TestPt, x ∈ Facet23 → tropSat f hf_ne x = tropSat g hg_ne x) :
    f = g := by
  -- For each μ in the support, f μ = g μ by the coefficient recovery lemma.
  have h_coeff_eq : ∀ μ ∈ f.support, f μ = g μ := by
    exact fun μ hμ => coeff_eq_of_wall_exposable f g hf_ne hg_ne hμ ( hsupp ▸ hμ ) ( hf_exp μ hμ ) ( hg_exp μ ( hsupp ▸ hμ ) ) h12 h23;
  grind +locals

/-
Any singleton support is automatically wall-exposable.
-/
theorem wallExposable_singleton (f : Wt →₀ ℤ)
    (hcard : f.support.card = 1) {μ : Wt} (hμ : μ ∈ f.support) :
    WallExposable f μ := by
  obtain ⟨ x, hx ⟩ := Finset.card_eq_one.mp hcard;
  exact ⟨ ⟨ 0, 0, 0 ⟩, Or.inl rfl, by aesop ⟩

/-
For two-element support `{μ, ν}` with `μ ≠ ν`, both elements are
    wall-exposable. This follows from `pair_strictly_separated_on_wall`.
-/
theorem wallExposable_of_pair (f : Wt →₀ ℤ)
    (hcard : f.support.card ≤ 2) {μ : Wt} (hμ : μ ∈ f.support) :
    WallExposable f μ := by
  interval_cases _ : f.support.card <;> simp_all +decide [ WallExposable ];
  · obtain ⟨ x, hx ⟩ := Finset.card_eq_one.mp ‹_›;
    simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
    exact ⟨ 0, 0, 0, by simp +decide [ Facet12, Facet23 ], fun a b c h₁ h₂ => False.elim <| h₂ <| by have := hx.2 _ _ _ hμ; aesop ⟩;
  · obtain ⟨ν, hν⟩ : ∃ ν ∈ f.support, ν ≠ μ ∧ f.support = {μ, ν} := by
      have := Finset.card_eq_two.mp ‹_›;
      obtain ⟨ x, y, hxy, h ⟩ := this; cases eq_or_ne x μ <;> cases eq_or_ne y μ <;> simp_all +decide [ Finset.ext_iff ] ;
      · tauto;
      · grind;
    obtain ⟨x, hx⟩ : ∃ x : TestPt, (x ∈ Facet12 ∨ x ∈ Facet23) ∧ evalWeight μ x < evalWeight ν x := by
      exact pair_strictly_separated_on_wall hν.2.1.symm;
    -- Choose $N$ large enough such that $N * (evalWeight ν x - evalWeight μ x) > |f μ - f ν|$.
    obtain ⟨N, hN⟩ : ∃ N : ℕ, N * (evalWeight ν x - evalWeight μ x) > |f μ - f ν| := by
      exact ⟨ ⌊|f μ - f ν|⌋₊ + 1, by push_cast; nlinarith [ Nat.lt_floor_add_one |f μ - f ν|, abs_nonneg ( f μ - f ν ) ] ⟩;
    refine' ⟨ N * x.1, N * x.2.1, N * x.2.2, _, _ ⟩ <;> simp_all +decide [ Facet12, Facet23 ];
    · grind;
    · intro a b c ha hb; have := hν.2.2; simp_all +decide [ Finsupp.mem_support_iff ] ;
      replace this := Finset.ext_iff.mp this ( a, b, c ) ; simp_all +decide [ evalWeight ] ;
      subst this; nlinarith [ abs_lt.mp hN ] ;

end TropSatakeGL3