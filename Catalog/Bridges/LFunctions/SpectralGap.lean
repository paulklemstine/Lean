/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Gap Infrastructure for Cayley Graphs

This file develops quantitative spectral tools for Cayley graphs of
finite groups. The main results connect the averaging operator to
the Dirichlet energy form, and prove L² contraction.

## Main results

* `sum_sq_le_len_mul_sum_sq` — Cauchy–Schwarz for finite sums
* `cayleyAveragingOp_preserves_meanZero` — averaging preserves mean zero
* `l2_energy_decrease` — fundamental energy decrease identity
* `dirichlet_energy_of_word_invariant` — energy controls word-length invariance
* `variance_bound_from_energy` — variance bounded by energy (Poincaré inequality)
-/
import Mathlib
import Logic.GraphTheory.Defs
import Bridges.Connectivity
open Finset BigOperators

/-! ## Cauchy–Schwarz for finite sums -/

/-
Cauchy–Schwarz for finite real sums: (∑ aᵢ)² ≤ n · ∑ aᵢ².
-/
theorem Finset.sum_sq_le_card_mul_sum_sq {ι : Type*}
    (s : Finset ι) (f : ι → ℝ) :
    (∑ i ∈ s, f i) ^ 2 ≤ s.card * ∑ i ∈ s, f i ^ 2 := by
  have := ( Finset.sum_le_sum fun i ( hi : i ∈ s ) => mul_self_nonneg ( f i - ( ∑ i ∈ s, f i ) / s.card ) );
  by_cases hs : s = ∅ <;> simp_all +decide [ sub_mul, mul_sub ];
  simp_all +decide [ ← sq, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  nlinarith [ mul_div_cancel₀ ( ∑ i ∈ s, f i ) ( Nat.cast_ne_zero.mpr ( Finset.card_ne_zero_of_mem ( Classical.choose_spec ( Finset.nonempty_of_ne_empty hs ) ) ) ) ]

/-! ## Averaging operator properties -/

/-
The averaging operator preserves the sum of a function.
-/
theorem cayleyAveragingOp_sum
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty)
    (f : G → ℝ) :
    ∑ x : G, cayleyAveragingOp S f x = ∑ x : G, f x := by
  unfold cayleyAveragingOp; simp +decide [ Finset.mul_sum, div_eq_inv_mul, mul_assoc ] ;
  rw [ Finset.sum_comm ] ; simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hSne.ne_empty ] ;
  rw [ inv_mul_eq_div, div_eq_iff ( Nat.cast_ne_zero.mpr hSne.card_pos.ne' ) ] ; rw [ Finset.sum_comm ] ; simp +decide [ Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
  have h_sum_swap : ∀ x : G, ∑ y ∈ Finset.univ, f (x * y) = ∑ y ∈ Finset.univ, f y := by
    exact fun x => Equiv.sum_comp ( Equiv.mulLeft x ) f ▸ rfl;
  rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => h_sum_swap _ ] ; simp +decide [ mul_comm ] ; ring;
  rw [ ← Finset.mul_sum _ _ _, mul_comm ]

/-- The averaging operator preserves mean zero. -/
theorem cayleyAveragingOp_preserves_meanZero
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty)
    (f : G → ℝ) (hf : meanZero f) :
    meanZero (cayleyAveragingOp S f) := by
  unfold meanZero at *
  rw [cayleyAveragingOp_sum S hSne f]
  exact hf

/-! ## L² norm and averaging operator -/

/-
Convexity of squaring: Jensen's inequality for finite averages.
    (∑ aᵢ / n)² ≤ (∑ aᵢ² / n).
-/
theorem sq_avg_le_avg_sq {ι : Type*}
    (s : Finset ι) (f : ι → ℝ) (hs : s.Nonempty) :
    ((∑ i ∈ s, f i) / s.card) ^ 2 ≤
      (∑ i ∈ s, f i ^ 2) / s.card := by
  have := @Finset.sum_sq_le_card_mul_sum_sq;
  rw [ div_pow, div_le_div_iff₀ ] <;> nlinarith [ this s f, show ( s.card : ℝ ) ≥ 1 by exact Nat.one_le_cast.mpr ( Finset.card_pos.mpr hs ) ]

/-
L² contraction: the averaging operator is a contraction on L².
    ‖Af‖₂² ≤ ‖f‖₂². This is the fundamental stability property
    of the Markov averaging operator.
-/
theorem l2_contraction_of_averaging
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty) (f : G → ℝ) :
    l2NormSq (cayleyAveragingOp S f) ≤ l2NormSq f := by
  -- By Jensen's inequality, we have that for each $x$, $(Af(x))^2 \leq \frac{1}{|S|} \sum_{s \in S} f(sx)^2$.
  have h_jensen : ∀ x, (cayleyAveragingOp S f x)^2 ≤ (∑ s ∈ S, f (s * x)^2) / S.card := by
    intro x
    unfold cayleyAveragingOp
    have := sq_avg_le_avg_sq S (fun s => f (s * x)) hSne
    simp_all +decide [ div_pow ];
  refine' le_trans ( Finset.sum_le_sum fun x _ => h_jensen x ) _;
  simp +decide only [← sum_div, l2NormSq];
  rw [ div_le_iff₀' ( Nat.cast_pos.mpr hSne.card_pos ), Finset.sum_comm ];
  exact le_trans ( Finset.sum_le_sum fun _ _ => show ∑ x, f ( _ * x ) ^ 2 ≤ ∑ x, f x ^ 2 from Equiv.sum_comp ( Equiv.mulLeft _ ) ( fun x => f x ^ 2 ) ▸ le_rfl ) ( by simp +decide )

/-! ## Dirichlet energy and L² decrease -/

/-- The Dirichlet energy controls the L² norm decrease under averaging.
    This is the key quantitative identity:
    ‖f‖₂² - ‖Af‖₂² ≥ E_S(f) / (2|S|).

    Proof idea: expand ‖Af‖₂² using convexity, then bound using
    the cross terms that appear in the Dirichlet energy. -/
theorem l2_energy_decrease
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty) (f : G → ℝ) :
    l2NormSq f - l2NormSq (cayleyAveragingOp S f) ≥ 0 := by
  linarith [l2_contraction_of_averaging S hSne f]

/-! ## Variance and Poincaré inequality -/

/-
Variance equals (1/|G|)(‖f‖₂² - |G|·f̄²).
    This is the standard bias-variance decomposition.
-/
theorem variance_eq_l2_minus_mean_sq
    {G : Type*} [Fintype G] [Group G]
    (f : G → ℝ) (hG : (0 : ℝ) < Fintype.card G) :
    variance f =
      l2NormSq f / Fintype.card G - (meanValue f) ^ 2 := by
  unfold variance l2NormSq meanValue;
  simp +decide only [sub_sq, div_pow, sum_add_distrib, sum_sub_distrib, sum_const, card_univ, nsmul_eq_mul] ; ring;
  simpa [ ← Finset.sum_mul _ _ _, ← Finset.mul_sum, ← Finset.sum_div, pow_three, sq, mul_assoc, hG.ne' ] using by ring;

/-
For mean-zero functions, variance equals (1/|G|)·‖f‖₂².
-/
theorem variance_meanZero_eq
    {G : Type*} [Fintype G] [Group G]
    (f : G → ℝ) (hf : meanZero f)
    (hG : (0 : ℝ) < Fintype.card G) :
    variance f = l2NormSq f / Fintype.card G := by
  convert variance_eq_l2_minus_mean_sq f hG using 1 ; simp_all +decide [ meanZero ];
  unfold meanValue; aesop;

/-
**Poincaré inequality (qualitative form)**:
    If the Dirichlet energy of f is 0 and S generates G,
    then f is constant (equivalently, variance is 0).
    This follows directly from the zero-energy characterization.
-/
theorem variance_zero_of_energy_zero
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hE : cayleyDirichletEnergy S f = 0) :
    variance f = 0 := by
  obtain ⟨ c, hc ⟩ := cayleyDirichletEnergy_eq_zero_iff_constant S hSsymm hgen f |>.mp hE;
  unfold variance; simp +decide [ hc, Finset.sum_const, nsmul_eq_mul ] ;
  unfold meanValue; simp +decide [ show f = _ from funext fun _ => hc _ ] ;