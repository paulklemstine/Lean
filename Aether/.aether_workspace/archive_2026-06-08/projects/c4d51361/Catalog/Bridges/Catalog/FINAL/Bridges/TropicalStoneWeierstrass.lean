/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Stone–Weierstrass Theorem

## Overview

This file establishes a tropical analogue of the Stone–Weierstrass theorem for
continuous real-valued functions on compact Hausdorff spaces. The theorem shows
that a set `A ⊆ C(X, ℝ)` satisfying tropical closure properties (closure under
pointwise `max`, pointwise `min`, and constant shifts) together with a tropical
point-separation condition is uniformly dense in `C(X, ℝ)`.

## Mathematical Context

In max-plus (tropical) algebra, the basic operations are:
- **Tropical addition** = pointwise `max` (supremum)
- **Tropical scalar multiplication** = additive shift by a real constant

A natural question is whether classical approximation theorems survive
tropicalization. This file answers affirmatively: the Stone–Weierstrass density
theorem holds for sets of continuous functions closed under tropical operations,
provided we include closure under pointwise `min` (infimum) as well.

### Why inf closure is necessary

Without inf closure, the theorem is false. The set of continuous convex functions
on `[0, 1]` is closed under `max`, constant shifts, contains all constants,
and tropically separates points (via affine functions), yet it is a closed proper
subset of `C([0,1], ℝ)` — it cannot approximate concave functions.

## Proof Strategy

The proof follows a direct two-pass compactness argument:

1. **First pass (inf):** For each anchor point `x`, use tropical separation to
   find functions `h_{x,y} ∈ A` with `h_{x,y}(x) ≈ f(x)` and `h_{x,y}(y) ≈ f(y)`.
   By continuity, `h_{x,y} < f + ε` on a neighborhood of `y`. Extract a finite
   subcover, then take `g_x = inf_i h_{x,y_i}`. This gives `g_x ≤ f + ε` globally
   and `g_x(x) > f(x) - ε`.

2. **Second pass (sup):** The sets `{z : g_x(z) > f(z) - ε}` cover `X`. Extract
   finitely many anchor points, take `g = sup_j g_{x_j}`. Then `f - ε < g ≤ f + ε`.

## Main Results

- `tropical_stone_weierstrass_eml`: Uniform density of `A` in `C(X, ℝ)`
- `tropical_stone_weierstrass_eml_dense`: `A` is dense in the metric topology

## References

- Stone, M.H., "The generalized Weierstrass approximation theorem" (1948)
- Litvinov, G.L., Maslov, V.P., "Idempotent mathematics and mathematical physics" (2005)
-/

import Mathlib

open scoped Topology
open Set Filter

noncomputable section

variable {X : Type*} [TopologicalSpace X]

/-! ## Definitions -/

/-- A set of continuous functions is closed under constant shifts:
    if `f ∈ A` then `x ↦ c + f(x)` is in `A` for every `c : ℝ`.
    This corresponds to tropical scalar multiplication. -/
def IsTropicallyClosedShift (A : Set C(X, ℝ)) : Prop :=
  ∀ (f : C(X, ℝ)), f ∈ A → ∀ (c : ℝ),
    (⟨fun x => c + f x, by fun_prop⟩ : C(X, ℝ)) ∈ A

/-- A set of continuous functions is closed under pointwise supremum (max).
    This corresponds to tropical addition. -/
def IsTropicallyClosedSup (A : Set C(X, ℝ)) : Prop :=
  ∀ (f g : C(X, ℝ)), f ∈ A → g ∈ A → (f ⊔ g) ∈ A

/-- A set of continuous functions is closed under pointwise infimum (min).
    This is needed for the tropical Stone–Weierstrass theorem;
    see the module docstring for why it cannot be dropped. -/
def IsTropicallyClosedInf (A : Set C(X, ℝ)) : Prop :=
  ∀ (f g : C(X, ℝ)), f ∈ A → g ∈ A → (f ⊓ g) ∈ A

/-- A set of continuous functions contains all real constant functions. -/
def ContainsTropicalConstants (A : Set C(X, ℝ)) : Prop :=
  ∀ c : ℝ, (ContinuousMap.const X c) ∈ A

/-- A set of continuous functions tropically separates points:
    for any two distinct points and any target values, there exists
    a function in `A` approximately interpolating those values.
    This is the tropical analogue of point separation. -/
def TropicallySeparatesPoints (A : Set C(X, ℝ)) : Prop :=
  ∀ x y : X, x ≠ y → ∀ a b : ℝ, ∀ ε > 0,
    ∃ f : C(X, ℝ), f ∈ A ∧ |f x - a| < ε ∧ |f y - b| < ε

/-- A continuous function is a finite tropical sup-shift envelope of elements of `A`:
    it has the form `sup_i (c_i + u_i)` for finitely many `c_i ∈ ℝ` and `u_i ∈ A`. -/
def IsFiniteTropicalSupShift (A : Set C(X, ℝ)) (g : C(X, ℝ)) : Prop :=
  ∃ (n : ℕ) (_ : 0 < n) (c : Fin n → ℝ) (u : Fin n → C(X, ℝ)),
    (∀ i, u i ∈ A) ∧
    g = Finset.sup' Finset.univ ⟨⟨0, ‹0 < n›⟩, Finset.mem_univ _⟩ fun i =>
      (⟨fun x => c i + u i x, by fun_prop⟩ : C(X, ℝ))

/-! ## Infrastructure Lemmas -/

/-- Two-point tropical interpolation: directly from the separation hypothesis. -/
theorem tropical_two_point_approx
    (A : Set C(X, ℝ))
    (hsep : TropicallySeparatesPoints A) :
    ∀ x y : X, x ≠ y → ∀ a b : ℝ, ∀ ε > 0,
      ∃ u : C(X, ℝ), u ∈ A ∧ |u x - a| < ε ∧ |u y - b| < ε := by
  exact hsep

/-
Finite infimum of elements of `A` remains in `A` when `A` is inf-closed.
-/
theorem IsTropicallyClosedInf.finset_inf' {A : Set C(X, ℝ)} (hinf : IsTropicallyClosedInf A)
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (u : ι → C(X, ℝ)) (hu : ∀ i ∈ s, u i ∈ A) :
    s.inf' hs u ∈ A := by
  induction' hs using Finset.Nonempty.cons_induction with i s hs ih;
  · aesop;
  · simp_all +decide [ Finset.inf'_cons ];
    exact hinf _ _ hu.1 ‹_›

/-
Finite supremum of elements of `A` remains in `A` when `A` is sup-closed.
-/
theorem IsTropicallyClosedSup.finset_sup' {A : Set C(X, ℝ)} (hsup : IsTropicallyClosedSup A)
    {ι : Type*} (s : Finset ι) (hs : s.Nonempty) (u : ι → C(X, ℝ)) (hu : ∀ i ∈ s, u i ∈ A) :
    s.sup' hs u ∈ A := by
  induction' hs using Finset.Nonempty.cons_induction with i s hs ih;
  · aesop;
  · simp_all +decide;
    exact hsup _ _ hu.1 ‹_›

/-! ## Local Approximation Lemmas -/

/-
**First-pass local approximation (upper-bounded).**
For a fixed anchor point `x`, we construct `g_x ∈ A` with:
- `g_x(z) < f(z) + ε` for all `z ∈ X` (global upper control)
- `g_x(x) > f(x) - ε` (lower control at the anchor)

This uses inf closure and the separation hypothesis, plus one compactness argument.
-/
theorem tropical_local_upper_bound [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hinf : IsTropicallyClosedInf A)
    (hsep : TropicallySeparatesPoints A)
    (hconst : ContainsTropicalConstants A)
    (f : C(X, ℝ)) (x : X) (ε : ℝ) (hε : ε > 0) :
    ∃ g : C(X, ℝ), g ∈ A ∧
      (∀ z : X, g z < f z + ε) ∧
      g x > f x - ε := by
  rcases isEmpty_or_nonempty X with ( ⟨ ⟩ | ⟨ y ⟩ );
  · exact False.elim ( ‹IsEmpty X›.elim x );
  · -- For each $z \in X$, choose $h_z \in A$ such that $|h_z(z) - f(z)| < \frac{\epsilon}{2}$ and $|h_z(x) - f(x)| < \frac{\epsilon}{2}$.
    have h_choose_hz : ∀ z : X, ∃ hz ∈ A, |hz z - f z| < ε / 2 ∧ |hz x - f x| < ε / 2 := by
      intro z
      by_cases hzx : z = x;
      · exact ⟨ ContinuousMap.const X ( f x ), hconst _, by simp +decide [ hzx ] ; linarith ⟩;
      · exact hsep z x hzx ( f z ) ( f x ) ( ε / 2 ) ( half_pos hε );
    choose! h hA hh using h_choose_hz;
    -- By compactness, extract a finite subcover indexed by some finset t ⊆ X.
    obtain ⟨t, ht⟩ : ∃ t : Finset X, ⋃ z ∈ t, {w : X | (h z) w < f w + ε} = Set.univ := by
      have h_open_cover : ∀ z : X, IsOpen {w : X | (h z) w < f w + ε} := by
        exact fun z => isOpen_lt ( h z |> ContinuousMap.continuous ) ( f.continuous.add continuous_const );
      have := @CompactSpace.elim_nhds_subcover X _ _;
      exact this _ fun z => IsOpen.mem_nhds ( h_open_cover z ) ( show ( h z ) z < f z + ε from by linarith [ abs_lt.mp ( hh z |>.1 ) ] );
    refine' ⟨ Finset.inf' t ( Finset.nonempty_of_ne_empty ( by rintro rfl; simp_all +decide [ Set.ext_iff ] ) ) h, _, _, _ ⟩;
    · exact IsTropicallyClosedInf.finset_inf' hinf t ( Finset.nonempty_of_ne_empty ( by rintro rfl; simp_all +decide [ Set.ext_iff ] ) ) h fun z hz => hA z;
    · exact fun z => by simpa using Set.ext_iff.mp ht z;
    · simp_all +decide [ Finset.inf'_apply ];
      exact fun z hz => by linarith [ abs_lt.mp ( hh z |>.2 ) ] ;

/-
**Main theorem: Tropical Stone–Weierstrass.**

If `A ⊆ C(X, ℝ)` on a compact Hausdorff space satisfies:
1. Contains all constants
2. Closed under pointwise `max` (tropical addition)
3. Closed under pointwise `min`
4. Closed under constant shifts (tropical scalar multiplication)
5. Tropically separates points

Then `A` is uniformly dense: for every `f ∈ C(X, ℝ)` and `ε > 0`,
there exists `g ∈ A` with `‖f - g‖ < ε`.
-/
theorem tropical_stone_weierstrass_eml
    [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ContainsTropicalConstants A)
    (hsup : IsTropicallyClosedSup A)
    (hinf : IsTropicallyClosedInf A)
    (_hshift : IsTropicallyClosedShift A)
    (hsep : TropicallySeparatesPoints A) :
    ∀ (f : C(X, ℝ)) (ε : ℝ), ε > 0 →
      ∃ g : C(X, ℝ), g ∈ A ∧ ‖f - g‖ < ε := by
  intro f ε hε;
  -- By tropical_local_upper_bound, for each x ∈ X, there exists g_x ∈ A with:
  -- - g_x(z) < f(z) + ε for all z (global upper bound)
  -- - g_x(x) > f(x) - ε (lower bound at anchor)
  have h_local_upper_bound : ∀ x : X, ∃ g_x ∈ A, (∀ z : X, g_x z < f z + ε / 2) ∧ (g_x x > f x - ε / 2) := by
    exact fun x => tropical_local_upper_bound A hinf hsep hconst f x ( ε / 2 ) ( half_pos hε );
  choose g hgA hg₁ hg₂ using h_local_upper_bound;
  -- By compactness, extract a finite subcover indexed by finset t.
  obtain ⟨t, ht⟩ : ∃ t : Finset X, ⋃ x ∈ t, {z : X | g x z > f z - ε / 2} = Set.univ := by
    have h_open_cover : ∀ x : X, IsOpen {z : X | g x z > f z - ε / 2} := by
      exact fun x => isOpen_lt ( f.continuous.sub continuous_const ) ( g x |> ContinuousMap.continuous );
    have := @CompactSpace.elim_nhds_subcover X _ _;
    exact this _ fun x => IsOpen.mem_nhds ( h_open_cover x ) ( hg₂ x );
  -- Define g = Finset.sup' t g_x (the finite sup of the selected g_x's). By IsTropicallyClosedSup.finset_sup', g ∈ A.
  obtain ⟨g', hg'A, hg'⟩ : ∃ g' ∈ A, ∀ z : X, g' z < f z + ε / 2 ∧ ∃ x ∈ t, g' z ≥ g x z ∧ g x z > f z - ε / 2 := by
    by_cases ht_empty : t.Nonempty;
    · refine' ⟨ Finset.sup' t ht_empty g, _, _ ⟩;
      · exact IsTropicallyClosedSup.finset_sup' hsup t ht_empty g fun x hx => hgA x;
      · simp_all +decide [ Set.ext_iff ];
        exact fun z => by obtain ⟨ x, hx₁, hx₂ ⟩ := ht z; exact ⟨ x, hx₁, ⟨ x, hx₁, le_rfl ⟩, hx₂ ⟩ ;
    · cases isEmpty_or_nonempty X <;> simp_all +decide [ Set.ext_iff ];
      exact ⟨ _, hconst 0 ⟩;
  refine' ⟨ g', hg'A, _ ⟩;
  rw [ ContinuousMap.norm_lt_iff _ hε ];
  intro x; specialize hg' x; rcases hg' with ⟨ hg₁, x, hx, hg₂, hg₃ ⟩ ; exact abs_lt.mpr ⟨ by norm_num; linarith, by norm_num; linarith ⟩ ;

/-
**Density corollary.** Under the tropical hypotheses, `A` is dense in `C(X, ℝ)`.
-/
theorem tropical_stone_weierstrass_eml_dense
    [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ContainsTropicalConstants A)
    (hsup : IsTropicallyClosedSup A)
    (hinf : IsTropicallyClosedInf A)
    (hshift : IsTropicallyClosedShift A)
    (hsep : TropicallySeparatesPoints A) :
    Dense A := by
  exact fun f => Metric.mem_closure_iff.2 fun ε εpos => by
    rcases tropical_stone_weierstrass_eml A hconst hsup hinf hshift hsep f ε εpos with ⟨g, hg, hg'⟩
    exact ⟨g, hg, by simpa [dist_eq_norm] using hg'⟩

end