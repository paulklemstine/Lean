/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# GL₃ Tropical Satake Reconstruction from Rank-2 Levi Convolution Profiles

We prove that finitely-supported functions on `ℕ × ℕ` (modeling dominant GL₃ coweights
in chamber coordinates via `(x,y) ↦ (x+y, y, 0)`) are uniquely determined by their
2D cumulative convolution profiles.

## Mathematical overview

The dominant chamber of GL₃ coweights is
  `Λ⁺₃ = {(a,b,c) ∈ ℕ³ | a ≥ b ≥ c}`,
which we parametrize by `(x,y) ∈ ℕ²` via `(a,b,c) = (x+y, y, 0)`.

The two simple-root Levi directions give "segment test functions":
  `leviSeg1(t) = ∑_{i=0}^{t} δ_{(i,0)}`  and  `leviSeg2(u) = ∑_{j=0}^{u} δ_{(0,j)}`.

Convolution with these segments produces 2D rectangular prefix sums. The core insight is
**discrete 2D Möbius inversion**: a function on `ℕ × ℕ` is uniquely determined by its
rectangular prefix sums. This gives a reconstruction/faithfulness theorem for tropical
Hecke data from rank-2 Levi convolution profiles.

## Main results

* `prefixSum2D_eq_zero_imp_eq_zero` — 2D discrete Möbius inversion:
  vanishing prefix sums imply the zero function
* `rectProfile_eq_prefixSum2D` — convolution with Levi segments equals the prefix sum
* `gl3_tropical_satake_reconstruction` — the main faithfulness theorem:
  equality of all rank-2 Levi triple-convolution profiles implies equality of Hecke data
-/

open Finset

/-! ## Definitions -/

/-- The dominant chamber coordinate type for GL₃, parametrizing `(x+y, y, 0)`. -/
abbrev DomTri := ℕ × ℕ

/-- Finitely supported Hecke data on the dominant chamber.
    Uses `AddMonoidAlgebra` to get convolution as multiplication. -/
noncomputable abbrev HeckeData := AddMonoidAlgebra ℝ DomTri

/-- Shorthand for the single (delta) function in the monoid algebra. -/
noncomputable abbrev delta (p : DomTri) : HeckeData :=
  AddMonoidAlgebra.single p 1

/-- The 2D prefix (cumulative) sum of `h` at `(x, y)`:
    `S(x,y) = ∑_{a=0}^{x} ∑_{b=0}^{y} h(a, b)`. -/
noncomputable def prefixSum2D (h : HeckeData) (x y : ℕ) : ℝ :=
  ∑ a ∈ range (x + 1), ∑ b ∈ range (y + 1), h (a, b)

/-- Levi segment along the first simple root direction:
    `leviSeg1(t) = ∑_{i=0}^{t} δ_{(i,0)}` in the additive monoid algebra. -/
noncomputable def leviSeg1 (t : ℕ) : HeckeData :=
  ∑ i ∈ range (t + 1), delta (i, 0)

/-- Levi segment along the second simple root direction:
    `leviSeg2(u) = ∑_{j=0}^{u} δ_{(0,j)}` in the additive monoid algebra. -/
noncomputable def leviSeg2 (u : ℕ) : HeckeData :=
  ∑ j ∈ range (u + 1), delta (0, j)

/-- The rectangular convolution profile: evaluates the double convolution
    `h * leviSeg1(x) * leviSeg2(y)` at the point `(x, y)`.
    This captures the 2D cumulative sum of `h` over the rectangle `[0,x] × [0,y]`. -/
noncomputable def rectProfile (h : HeckeData) (x y : ℕ) : ℝ :=
  (h * leviSeg1 x * leviSeg2 y) (x, y)

/-! ## Core prefix sum identities

These lemmas express the coefficients of `h` in terms of its 2D prefix sums
via discrete inclusion-exclusion (Möbius inversion on the product order `ℕ × ℕ`).
-/

/-- Corner case: `h(0, 0) = S(0, 0)`. -/
lemma coeff_zero_zero_eq_prefixSum2D (h : HeckeData) :
    h (0, 0) = prefixSum2D h 0 0 := by
  simp [prefixSum2D]

/-
Boundary `x = 0`: `h(0, y+1) = S(0, y+1) - S(0, y)`.
-/
lemma coeff_zero_fst_succ (h : HeckeData) (y : ℕ) :
    h (0, y + 1) = prefixSum2D h 0 (y + 1) - prefixSum2D h 0 y := by
  simp [prefixSum2D];
  rw [ Finset.sum_range_succ, add_sub_cancel_left ]

/-
Boundary `y = 0`: `h(x+1, 0) = S(x+1, 0) - S(x, 0)`.
-/
lemma coeff_zero_snd_succ (h : HeckeData) (x : ℕ) :
    h (x + 1, 0) = prefixSum2D h (x + 1) 0 - prefixSum2D h x 0 := by
  unfold prefixSum2D;
  simp +decide [ Finset.sum_range_succ ]

/-
Interior inclusion-exclusion:
    `h(x+1, y+1) = S(x+1,y+1) - S(x,y+1) - S(x+1,y) + S(x,y)`.
    This is the discrete analogue of `∂²S/∂x∂y = h`.
-/
lemma coeff_succ_succ (h : HeckeData) (x y : ℕ) :
    h (x + 1, y + 1) = prefixSum2D h (x + 1) (y + 1) - prefixSum2D h x (y + 1) -
      prefixSum2D h (x + 1) y + prefixSum2D h x y := by
  unfold prefixSum2D;
  norm_num [ Finset.sum_range_succ ] ; ring

/-! ## 2D Möbius inversion -/

/-- **Discrete 2D Möbius inversion**: if all 2D prefix sums of `h` vanish,
    then `h` is the zero function. This is the discrete analogue of
    "a function whose integral over all axis-aligned rectangles vanishes must be zero."

    The proof works by case analysis on `(x, y)`:
    - At `(0, 0)`: `h(0,0) = S(0,0) = 0`
    - At `(0, y+1)`: `h(0,y+1) = S(0,y+1) - S(0,y) = 0`
    - At `(x+1, 0)`: `h(x+1,0) = S(x+1,0) - S(x,0) = 0`
    - At `(x+1, y+1)`: `h(x+1,y+1) = S(x+1,y+1) - S(x,y+1) - S(x+1,y) + S(x,y) = 0` -/
theorem prefixSum2D_eq_zero_imp_eq_zero (h : HeckeData)
    (hpf : ∀ x y, prefixSum2D h x y = 0) : h = 0 := by
  ext ⟨x, y⟩
  match x, y with
  | 0, 0 => rw [coeff_zero_zero_eq_prefixSum2D]; exact hpf 0 0
  | 0, y + 1 => rw [coeff_zero_fst_succ]; simp [hpf]
  | x + 1, 0 => rw [coeff_zero_snd_succ]; simp [hpf]
  | x + 1, y + 1 => rw [coeff_succ_succ]; simp [hpf]

/-! ## Convolution evaluation formula

We show that the rectangular convolution profile `rectProfile h x y` equals
the 2D prefix sum `prefixSum2D h x y`, establishing the connection between
the algebraic (convolution) and combinatorial (prefix sum) viewpoints.
-/

/-
Evaluating `h * δ_{p}` at `q`: nonzero only when `p` can be subtracted from `q`
    in `ℕ × ℕ`, i.e., when `p.1 ≤ q.1` and `p.2 ≤ q.2`.
-/
lemma mul_delta_apply (h : HeckeData) (p q : DomTri) :
    (h * delta p) q = if p.1 ≤ q.1 ∧ p.2 ≤ q.2 then h (q.1 - p.1, q.2 - p.2) else 0 := by
  convert AddMonoidAlgebra.mul_apply h ( AddMonoidAlgebra.single p 1 ) q using 1;
  split_ifs <;> simp_all +decide [ Finsupp.sum_single_index ];
  · rw [ Finsupp.sum_eq_single ( q - p ) ] <;> simp_all +decide [ Prod.ext_iff ];
    · congr;
    · intros; omega;
  · exact Eq.symm ( Finset.sum_eq_zero fun x hx => if_neg <| by intro H; have := congr_arg Prod.fst H; have := congr_arg Prod.snd H; aesop )

/-
**Rectangular prefix sum formula**: the double convolution profile equals the
    2D prefix sum. This is the key computational identity connecting convolution
    with Levi segments to rectangular cumulative sums.
-/
theorem rectProfile_eq_prefixSum2D (h : HeckeData) (x y : ℕ) :
    rectProfile h x y = prefixSum2D h x y := by
  -- By definition of convolution, we can expand $(h * leviSeg1 x * leviSeg2 y) (x, y)$ as $\sum_{i=0}^{x} \sum_{j=0}^{y} h(x-i, y-j)$.
  have h_conv : (h * leviSeg1 x * leviSeg2 y) (x, y) = ∑ i ∈ Finset.range (x + 1), ∑ j ∈ Finset.range (y + 1), h (x - i, y - j) := by
    unfold leviSeg1 leviSeg2;
    simp +decide [ mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul ];
    rw [ Finset.sum_comm, Finsupp.finset_sum_apply ];
    refine' Finset.sum_congr rfl fun i hi => _;
    rw [ Finset.sum_apply' ];
    refine' Finset.sum_congr rfl fun j hj => _;
    rw [ mul_delta_apply ] ; aesop;
  convert h_conv using 1;
  apply Finset.sum_bij (fun i _ => x - i);
  · exact fun i hi => Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.sub_le _ _ ) );
  · grind;
  · exact fun b hb => ⟨ x - b, Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.sub_le _ _ ) ), Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hb ) ⟩;
  · intro i hi; rw [ ← Finset.sum_flip ] ;
    rw [ Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hi ) ]

/-! ## Main reconstruction theorems -/

/-- **Kernel triviality**: if all rectangular convolution profiles of `h` vanish,
    then `h = 0`. This is the "difference version" of the reconstruction theorem. -/
theorem zero_of_vanishing_rectProfiles (h : HeckeData)
    (hprof : ∀ x y : ℕ, rectProfile h x y = 0) : h = 0 := by
  apply prefixSum2D_eq_zero_imp_eq_zero
  intro x y
  rw [← rectProfile_eq_prefixSum2D]
  exact hprof x y

/-
**GL₃ tropical Satake reconstruction theorem**: two finitely-supported Hecke data
    functions on the dominant chamber are equal if and only if all their rank-2 Levi
    triple-convolution profiles agree.

    Concretely, `f = g` if for all `x, y : ℕ`,
    `(f * leviSeg1(x) * leviSeg2(y))(x,y) = (g * leviSeg1(x) * leviSeg2(y))(x,y)`.

    This is a faithful reconstruction result: the rank-2 Levi convolution profiles
    completely determine the Hecke data without any additional edge-moment information.
-/
theorem gl3_tropical_satake_reconstruction (f g : HeckeData)
    (hprof : ∀ x y : ℕ, rectProfile f x y = rectProfile g x y) :
    f = g := by
  -- Set h := f - g. Then rectProfile h x y = rectProfile f x y - rectProfile g x y = 0 for all x,y (from hprof).
  set h := f - g
  have h_zero : ∀ x y : ℕ, rectProfile h x y = 0 := by
    intros x y
    unfold rectProfile;
    rw [ sub_mul, sub_mul ];
    rw [ Finsupp.sub_apply, sub_eq_zero ] ; aesop;
  exact sub_eq_zero.mp ( zero_of_vanishing_rectProfiles h h_zero )

/-- **Reconstruction with edge moments (redundant but instructive)**:
    Edge moments are implied by the convolution profiles, so they need not be
    assumed separately. This version includes them for compatibility with the
    standard formulation of the tropical Satake reconstruction principle. -/
theorem reconstruct_from_rank2Levi_profiles_and_edge_moments
    (f g : HeckeData)
    (hprof : ∀ x y : ℕ, rectProfile f x y = rectProfile g x y)
    (_hedge_x : ∀ m : ℕ, ∑ y ∈ f.support.image Prod.snd, f (m, y) =
                         ∑ y ∈ g.support.image Prod.snd, g (m, y))
    (_hedge_y : ∀ m : ℕ, ∑ x ∈ f.support.image Prod.fst, f (x, m) =
                         ∑ x ∈ g.support.image Prod.fst, g (x, m)) :
    f = g :=
  gl3_tropical_satake_reconstruction f g hprof

/-! ## Strengthened version: full convolution profile equality -/

/-- **Strong reconstruction**: if the full convolution functions `f * leviSeg1(t) * leviSeg2(u)`
    and `g * leviSeg1(t) * leviSeg2(u)` agree for all `t, u`, then `f = g`.
    This is an immediate consequence since full equality implies pointwise equality. -/
theorem gl3_reconstruction_from_full_profiles (f g : HeckeData)
    (hprof : ∀ t u : ℕ,
      f * leviSeg1 t * leviSeg2 u = g * leviSeg1 t * leviSeg2 u) :
    f = g := by
  apply gl3_tropical_satake_reconstruction
  intro x y
  simp only [rectProfile]
  have := hprof x y
  exact congrFun (congrArg Finsupp.toFun this) (x, y)