/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.ShallowProductCoinRigidity

/-!
# Attainment and sharpness for shallow product coins

`Catalog/Geometry/ShallowProductCoinRigidity.lean` proves that a resonance set `R` which
is not a combinatorial box forces a *quantitative* loss `1/(9|R|)` for every product coin.
This file supplies the two missing halves of the picture.

## Main results

* `exists_optimal_productCoin_of_isBox` — the converse direction: a nonempty **box** does
  contain a product coin attaining the Cauchy–Schwarz optimum `|R|`.
* `productCoin_optimum_iff_isBox` — combining the two, for nonempty `R`
  *some* product coin is optimal **iff** `R` is a box.  This is the exact dichotomy
  behind "the optimum is never attained by a coin that does not already depend on `N`".
* `Lshape` and `Lshape_optimum` — the smallest non-box, `|R| = 3` in `Bool × Bool`.
  A **direct computation** identifies the exact product optimum as the square of the
  golden ratio, `(3 + √5)/2 = 2.618…`, strictly below `|R| = 3`.
* `Lshape_true_gap_gt_general_gap` — the true gap `3 - (3+√5)/2 = (3-√5)/2 ≈ 0.382`
  is strictly larger than the general guarantee `1/(9·3) = 1/27`, so the explicit
  constant of the general theorem is valid but not optimal.
-/

namespace Catalog.Geometry.ShallowProductCoin

open Finset

/-! ## 1. Boxes attain the Cauchy–Schwarz optimum -/

section Attainment

variable {A B : Type*} [Fintype A] [Fintype B] [DecidableEq A] [DecidableEq B]

/-- The normalised indicator of a nonempty finite set is a unit coin. -/
lemma sum_sq_normalised_indicator {Y : Type*} [Fintype Y] [DecidableEq Y]
    (S : Finset Y) (hS : S.Nonempty) :
    ∑ y, (if y ∈ S then 1 / Real.sqrt S.card else 0) ^ 2 = 1 := by
  have hcard : (0:ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hsq : Real.sqrt (S.card : ℝ) ^ 2 = (S.card : ℝ) :=
    Real.sq_sqrt (le_of_lt hcard)
  have hne : Real.sqrt (S.card : ℝ) ≠ 0 := by
    intro h; rw [h] at hsq; simp at hsq; linarith
  have hpt : ∀ y : Y, (if y ∈ S then 1 / Real.sqrt S.card else 0) ^ 2
      = if y ∈ S then 1 / (S.card : ℝ) else 0 := by
    intro y
    by_cases hy : y ∈ S <;> simp [hy, hsq]
  simp only [hpt]
  rw [Finset.sum_ite_mem]
  simp only [Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
  field_simp

/-- The total mass of the normalised indicator of a nonempty finite set is `√|S|`. -/
lemma sum_normalised_indicator {Y : Type*} [Fintype Y] [DecidableEq Y]
    (S : Finset Y) (hS : S.Nonempty) :
    ∑ y ∈ S, (if y ∈ S then 1 / Real.sqrt S.card else 0) = Real.sqrt S.card := by
  have hcard : (0:ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hsq : Real.sqrt (S.card : ℝ) ^ 2 = (S.card : ℝ) :=
    Real.sq_sqrt (le_of_lt hcard)
  have hne : Real.sqrt (S.card : ℝ) ≠ 0 := by
    intro h; rw [h] at hsq; simp at hsq; linarith
  rw [Finset.sum_congr rfl (fun y hy => if_pos hy)]
  simp only [Finset.sum_const, nsmul_eq_mul]
  field_simp
  linarith [hsq]

/-- **Converse to the rigidity gap.**  A nonempty combinatorial box admits a product coin
attaining the Cauchy–Schwarz optimum exactly. -/
theorem exists_optimal_productCoin_of_isBox (R : Finset (A × B)) (hR : R.Nonempty)
    (hbox : IsBox R) :
    ∃ (f : A → ℝ) (g : B → ℝ), (∑ a, f a ^ 2 = 1) ∧ (∑ b, g b ^ 2 = 1) ∧
      resonanceAmplitude R (prodCoin f g) ^ 2 = (R.card : ℝ) := by
  set S := R.image Prod.fst with hSdef
  set T := R.image Prod.snd with hTdef
  have hRST : R = S ×ˢ T := (isBox_iff_eq_product R).mp hbox
  have hS : S.Nonempty := hR.image _
  have hT : T.Nonempty := hR.image _
  refine ⟨fun a => if a ∈ S then 1 / Real.sqrt S.card else 0,
          fun b => if b ∈ T then 1 / Real.sqrt T.card else 0,
          sum_sq_normalised_indicator S hS, sum_sq_normalised_indicator T hT, ?_⟩
  have hamp : resonanceAmplitude R
      (prodCoin (fun a => if a ∈ S then 1 / Real.sqrt S.card else 0)
                (fun b => if b ∈ T then 1 / Real.sqrt T.card else 0))
      = Real.sqrt S.card * Real.sqrt T.card := by
    have key : ∑ p ∈ S ×ˢ T, ((if p.1 ∈ S then 1 / Real.sqrt S.card else 0)
          * (if p.2 ∈ T then 1 / Real.sqrt T.card else 0))
        = (∑ a ∈ S, (if a ∈ S then 1 / Real.sqrt S.card else 0))
          * (∑ b ∈ T, (if b ∈ T then 1 / Real.sqrt T.card else 0)) := by
      rw [Finset.sum_product, Finset.sum_mul_sum]
    simp only [resonanceAmplitude, prodCoin]
    rw [hRST, key, sum_normalised_indicator S hS, sum_normalised_indicator T hT]
  rw [hamp, mul_pow]
  have hSc : (0:ℝ) ≤ (S.card : ℝ) := Nat.cast_nonneg _
  have hTc : (0:ℝ) ≤ (T.card : ℝ) := Nat.cast_nonneg _
  rw [Real.sq_sqrt hSc, Real.sq_sqrt hTc]
  rw [hRST, Finset.card_product]
  push_cast
  ring

/-- **The exact dichotomy.**  For a nonempty resonance set, a product coin attains the
Cauchy–Schwarz optimum if and only if the set is a combinatorial box. -/
theorem productCoin_optimum_iff_isBox (R : Finset (A × B)) (hR : R.Nonempty) :
    (∃ (f : A → ℝ) (g : B → ℝ), (∑ a, f a ^ 2 = 1) ∧ (∑ b, g b ^ 2 = 1) ∧
      resonanceAmplitude R (prodCoin f g) ^ 2 = (R.card : ℝ)) ↔ IsBox R := by
  constructor
  · rintro ⟨f, g, hf, hg, hopt⟩
    exact isBox_of_productCoin_optimal R f g hf hg hopt
  · exact exists_optimal_productCoin_of_isBox R hR

end Attainment

/-! ## 2. The smallest non-box: a direct computation at depth 2

The `L`-shape `{(ff,ff), (ff,tt), (tt,ff)} ⊆ Bool × Bool` is the smallest resonance set
that is not a combinatorial box.  Its indicator matrix is `!![1,1;1,0]`, whose largest
singular value is the golden ratio; hence the exact product optimum is `(3+√5)/2`. -/

section Lshape

/-- The `L`-shaped resonance set inside `Bool × Bool`. -/
def Lshape : Finset (Bool × Bool) := {(false, false), (false, true), (true, false)}

@[simp] lemma Lshape_card : Lshape.card = 3 := by decide

lemma Lshape_not_isBox : ¬ IsBox Lshape := by
  unfold IsBox Lshape
  decide

lemma Lshape_amplitude (f g : Bool → ℝ) :
    resonanceAmplitude Lshape (prodCoin f g)
      = f false * g false + f false * g true + f true * g false := by
  simp only [resonanceAmplitude, Lshape, prodCoin]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  ring

/-- Golden-ratio constant: the exact product optimum for the `L`-shape. -/
noncomputable def goldenOpt : ℝ := (3 + Real.sqrt 5) / 2

lemma sqrt5_sq : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)

lemma sqrt5_bounds : 2 < Real.sqrt 5 ∧ Real.sqrt 5 < 3 := by
  constructor
  · nlinarith [sqrt5_sq, Real.sqrt_nonneg (5:ℝ)]
  · nlinarith [sqrt5_sq, Real.sqrt_nonneg (5:ℝ)]

/-- **Upper bound (direct computation).**  Every unit product coin on `Bool × Bool` has
`L`-shape amplitude squared at most `(3+√5)/2`. -/
theorem Lshape_amplitude_sq_le (f g : Bool → ℝ)
    (hf : ∑ a, f a ^ 2 = 1) (hg : ∑ b, g b ^ 2 = 1) :
    resonanceAmplitude Lshape (prodCoin f g) ^ 2 ≤ goldenOpt := by
  rw [Lshape_amplitude, goldenOpt]
  have hf' : f false ^ 2 + f true ^ 2 = 1 := by
    rw [← hf]; simp; ring
  have hg' : g false ^ 2 + g true ^ 2 = 1 := by
    rw [← hg]; simp; ring
  set s := Real.sqrt 5 with hs
  have hs2 : s ^ 2 = 5 := sqrt5_sq
  have hslb : 2 < s := sqrt5_bounds.1
  -- Cauchy–Schwarz in the `g` variable
  have hCS : (f false * g false + f false * g true + f true * g false) ^ 2
      ≤ ((f false + f true) ^ 2 + f false ^ 2) * (g false ^ 2 + g true ^ 2) := by
    nlinarith [sq_nonneg ((f false + f true) * g true - f false * g false)]
  -- the quadratic form bound, sharp at the golden ratio
  have hquad : (f false + f true) ^ 2 + f false ^ 2 ≤ (3 + s) / 2 := by
    nlinarith [sq_nonneg ((s - 1) / 2 * f false - f true), hs2, hslb, hf']
  rw [hg'] at hCS
  linarith

/-- **Attainment (direct computation).**  The bound `(3+√5)/2` is achieved by an explicit
unit product coin, so it is the exact product optimum for the `L`-shape. -/
theorem Lshape_optimum :
    ∃ f g : Bool → ℝ, (∑ a, f a ^ 2 = 1) ∧ (∑ b, g b ^ 2 = 1) ∧
      resonanceAmplitude Lshape (prodCoin f g) ^ 2 = goldenOpt := by
  set s := Real.sqrt 5 with hs
  have hs2 : s ^ 2 = 5 := sqrt5_sq
  have hslb : 2 < s := sqrt5_bounds.1
  have hsub : s < 3 := sqrt5_bounds.2
  obtain ⟨u, hu⟩ : ∃ u : ℝ, u = (s - 1) / 2 := ⟨_, rfl⟩
  obtain ⟨N, hNdef⟩ : ∃ N : ℝ, N = Real.sqrt ((5 - s) / 2) := ⟨_, rfl⟩
  obtain ⟨L, hLdef⟩ : ∃ L : ℝ, L = Real.sqrt ((3 + s) / 2) := ⟨_, rfl⟩
  have hNpos : 0 < N := by rw [hNdef]; exact Real.sqrt_pos.mpr (by linarith)
  have hLpos : 0 < L := by rw [hLdef]; exact Real.sqrt_pos.mpr (by linarith)
  have hN2 : N ^ 2 = (5 - s) / 2 := by rw [hNdef]; exact Real.sq_sqrt (by linarith)
  have hL2 : L ^ 2 = (3 + s) / 2 := by rw [hLdef]; exact Real.sq_sqrt (by linarith)
  have h1 : 1 + u ^ 2 = N ^ 2 := by rw [hu, hN2]; nlinarith [hs2]
  have h2 : (1 + u) ^ 2 + 1 = N ^ 2 * L ^ 2 := by rw [hu, hN2, hL2]; nlinarith [hs2]
  have hNne : N ≠ 0 := ne_of_gt hNpos
  have hLne : L ≠ 0 := ne_of_gt hLpos
  refine ⟨fun a => if a then u / N else 1 / N,
          fun b => if b then 1 / (N * L) else (1 + u) / (N * L), ?_, ?_, ?_⟩
  · rw [Fintype.sum_bool]
    norm_num
    field_simp
    linarith [h1]
  · rw [Fintype.sum_bool]
    norm_num
    field_simp
    nlinarith [h2]
  · rw [Lshape_amplitude]
    show (1 / N * ((1 + u) / (N * L)) + 1 / N * (1 / (N * L))
      + u / N * ((1 + u) / (N * L))) ^ 2 = goldenOpt
    have hA : 1 / N * ((1 + u) / (N * L)) + 1 / N * (1 / (N * L))
        + u / N * ((1 + u) / (N * L)) = L := by
      field_simp
      nlinarith [h2]
    rw [hA, goldenOpt, hL2]

/-- The general constant `1/(9|R|)` of `productCoin_amplitude_sq_le_of_not_box` is a valid
but **not** optimal gap for the `L`-shape: the true gap `(3-√5)/2` is much larger. -/
theorem Lshape_true_gap_gt_general_gap :
    1 / (9 * (Lshape.card : ℝ)) < (Lshape.card : ℝ) - goldenOpt := by
  rw [Lshape_card, goldenOpt]
  have hsub : Real.sqrt 5 < 3 := sqrt5_bounds.2
  have := sqrt5_bounds.1
  norm_num
  nlinarith [sqrt5_sq]

/-- Instantiating the general depth-2 theorem at the `L`-shape. -/
theorem Lshape_general_bound (f g : Bool → ℝ)
    (hf : ∑ a, f a ^ 2 = 1) (hg : ∑ b, g b ^ 2 = 1) :
    resonanceAmplitude Lshape (prodCoin f g) ^ 2 ≤ 3 - 1 / 27 := by
  have h := productCoin_amplitude_sq_le_of_not_box Lshape f g hf hg Lshape_not_isBox
  rw [Lshape_card] at h
  norm_num at h ⊢
  linarith

end Lshape

end Catalog.Geometry.ShallowProductCoin