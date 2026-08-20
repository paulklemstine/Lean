/-
Copyright (c) 2026. Released under the Apache 2.0 license.
-/
import Catalog.Applications.ShallowProductCoinRigidity.Core

/-!
# How sharp is the rigidity gap?

`Core.lean` proves that every product coin loses at least `2/9` of the
Cauchy–Schwarz optimum on a non-box resonance set.  Here we bracket the optimal
universal constant

`c* := sup { c | ∀ non-box R, ∀ product coins, ‖A(ψ)‖² ≤ |R| - c }`

from above by an explicit rational, by exhibiting a *good* product coin for the
smallest non-box resonance set, the "L-shape"
`R = {(0,0), (0,1), (1,0)} ⊆ Bool × Bool`.

The optimal product coin for the L-shape is the golden-ratio eigenvector: the
supremum of `‖A(ψ)‖²` equals `φ² = (3+√5)/2 = 2.618…`, i.e. the true loss is
`3 - φ² = (3-√5)/2 = 0.3819…`.  We certify this numerically *and rigorously*
with the Pythagorean rational approximation `(45/53, 28/53)` of the golden
eigenvector (`28/45 = 0.6222… ≈ 1/φ = 0.6180…`), giving

`‖A(ψ)‖² = (4545/2809)² = 20657025/7890481 = 2.617965…`.

Consequently `c* ≤ 3014418/7890481 = 0.382034…`, while `Core.lean` gives
`c* ≥ 2/9 = 0.2222…`.  So the universal constant proved here is within a factor
`1.72` of optimal — the theorem is not merely qualitative.

A complementary lower bound (`row_attains`) shows that the *largest row* of `R`
is always achievable by a product coin, so the sup of `‖A(ψ)‖²` is squeezed
between `max_a |R_a|` and `4|R|²/(4|R|+1)`.
-/

open Finset

namespace ShallowProductCoin

/-! ### The L-shape and the golden coin -/

/-- The smallest non-box resonance set: the "L-shape" in `Bool × Bool`. -/
def Lshape : Finset (Bool × Bool) := {(false, false), (false, true), (true, false)}

theorem Lshape_card : Lshape.card = 3 := by decide

/-- The L-shape is not a combinatorial box. -/
theorem Lshape_not_isBox : ¬ IsBox Lshape := by
  intro h
  have h1 := h (true, false) (by decide) (false, true) (by decide)
  simp [Lshape] at h1

/-- The rational golden coin: a Pythagorean approximation `(45/53, 28/53)` of the
golden eigenvector `(φ, 1)/√(φ²+1)` of the L-shape pattern. -/
noncomputable def goldenCoin : Bool → ℂ := fun b => if b = false then 45 / 53 else 28 / 53

theorem goldenCoin_isCoin : IsCoin goldenCoin := by
  show ∑ b : Bool, ‖goldenCoin b‖ ^ 2 = 1
  rw [Fintype.sum_bool]
  norm_num [goldenCoin, Complex.norm_div]

theorem goldenCoin_amp : bipAmp Lshape goldenCoin goldenCoin = 4545 / 2809 := by
  unfold bipAmp Lshape goldenCoin
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide)]
  norm_num

/-- **Upper certificate.**  The golden coin achieves `‖A(ψ)‖² = 20657025/7890481
> 2.617` on the L-shape, whose optimum is `|R| = 3`. -/
theorem Lshape_golden_value :
    ‖bipAmp Lshape goldenCoin goldenCoin‖ ^ 2 = 20657025 / 7890481 := by
  rw [goldenCoin_amp]
  rw [show ((4545 : ℂ) / 2809) = ((4545 / 2809 : ℝ) : ℂ) by norm_num]
  rw [Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg (by norm_num)]
  norm_num

/-- **The universal additive gap constant is at most `0.382035`.**  If `c` is any
constant for which the rigidity gap `‖A(ψ)‖² ≤ |R| - c` holds for all product
coins on the L-shape, then `c ≤ 3014418/7890481 < 0.382035`.

Together with `bipAmp_sq_le_card_sub` (which establishes `c = 2/9` universally)
this brackets the optimal universal constant:
`0.2222… ≤ c* ≤ 0.382035…`. -/
theorem gap_constant_le (c : ℝ)
    (h : ∀ f g : Bool → ℂ, IsCoin f → IsCoin g →
      ‖bipAmp Lshape f g‖ ^ 2 ≤ (Lshape.card : ℝ) - c) :
    c ≤ 3014418 / 7890481 := by
  have hval := h goldenCoin goldenCoin goldenCoin_isCoin goldenCoin_isCoin
  rw [Lshape_golden_value, Lshape_card] at hval
  norm_num at hval
  linarith

/-- The constant `2/9` of `bipAmp_sq_le_card_sub` really is admissible for the
L-shape, so the bracket `[2/9, 3014418/7890481]` is nonempty. -/
theorem gap_constant_two_ninths_admissible (f g : Bool → ℂ) (hf : IsCoin f) (hg : IsCoin g) :
    ‖bipAmp Lshape f g‖ ^ 2 ≤ (Lshape.card : ℝ) - 2 / 9 :=
  bipAmp_sq_le_card_sub Lshape f g hf hg (a := true) (b := false) (a' := false) (b' := true)
    (by decide) (by decide) (by decide)

/-! ### A matching lower bound: rows are always achievable -/

variable {A B : Type*} [Fintype A] [Fintype B] [DecidableEq A] [DecidableEq B]

/-- The `a`-th row of a resonance set. -/
def row (R : Finset (A × B)) (a : A) : Finset B := (R.filter fun x => x.1 = a).image Prod.snd

/-- **Lower bound on the achievable resonance.**  Concentrating the first coin on
one register letter `a` and spreading the second uniformly over the row `R_a`
gives a product coin whose squared amplitude equals `|R_a|`.  Hence for a
non-box `R` we obtain the combinatorial squeeze
`max_a |R_a| ≤ sup_ψ ‖A(ψ)‖² ≤ 4|R|²/(4|R|+1)`. -/
theorem row_attains (R : Finset (A × B)) (a : A) (hne : (row R a).Nonempty) :
    ∃ f : A → ℂ, ∃ g : B → ℂ, IsCoin f ∧ IsCoin g ∧
      ‖bipAmp R f g‖ ^ 2 = ((row R a).card : ℝ) := by
  classical
  set Ra := row R a with hRa
  have hc : (0 : ℝ) < (Ra.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hne
  refine ⟨fun a' => if a' = a then 1 else 0,
          fun b => if b ∈ Ra then ((Real.sqrt Ra.card : ℝ) : ℂ)⁻¹ else 0, ?_,
          uniform_isCoin Ra hne, ?_⟩
  · show ∑ a' : A, _ = _
    have hnorm : ∀ a' : A, ‖(if a' = a then (1 : ℂ) else 0)‖ ^ 2 = if a' = a then (1 : ℝ) else 0 := by
      intro a'; by_cases h : a' = a <;> simp [h]
    rw [Finset.sum_congr rfl fun a' _ => hnorm a']
    simp
  · -- the amplitude collapses to the row sum
    set cst : ℂ := ((Real.sqrt Ra.card : ℝ) : ℂ)⁻¹ with hcst
    have hterm : ∀ x : A × B,
        (if x.1 = a then (1 : ℂ) else 0) * (if x.2 ∈ Ra then cst else 0)
          = if x.1 = a then (if x.2 ∈ Ra then cst else 0) else 0 := by
      intro x; by_cases h : x.1 = a <;> simp [h]
    have hinj : ∀ x ∈ R.filter fun x : A × B => x.1 = a, ∀ y ∈ R.filter fun x : A × B => x.1 = a,
        x.2 = y.2 → x = y := by
      intro x hx y hy hxy
      simp only [Finset.mem_filter] at hx hy
      exact Prod.ext (hx.2.trans hy.2.symm) hxy
    have hamp : bipAmp R (fun a' => if a' = a then (1 : ℂ) else 0)
        (fun b => if b ∈ Ra then cst else 0)
        = ∑ b ∈ Ra, (if b ∈ Ra then cst else 0) := by
      unfold bipAmp
      rw [Finset.sum_congr rfl fun x _ => hterm x, ← Finset.sum_filter]
      rw [hRa, row, Finset.sum_image hinj]
    rw [hamp, uniform_sum Ra hne, Complex.norm_real, Real.norm_eq_abs,
      abs_of_nonneg (Real.sqrt_nonneg _), Real.sq_sqrt hc.le]

end ShallowProductCoin