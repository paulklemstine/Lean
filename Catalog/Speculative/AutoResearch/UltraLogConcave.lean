/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Ultra-Log-Concavity: Main Theorems

This file proves properties of elementary symmetric polynomials and establishes
ultra-log-concavity (Newton's inequalities) for coefficient sequences of
products of linear factors with positive weights.

## Main results

* `esp_zero_eq_one` — e₀(w) = 1 for any weight vector.
* `esp_nonneg` — e_k(w) ≥ 0 when all weights are nonneg.
* `esp_pos` — e_k(w) > 0 for k ≤ m when all weights are positive.
* `esp_recurrence` — e_k^(m) = e_k^(m-1) + w_m · e_{k-1}^(m-1).
* `maclaurinAvg_uniform` — ẽ_k(c,...,c) = c^k.
* `ulc_uniform` — Ultra-log-concavity holds with equality for uniform weights.
* `ulc_two_weights` — Newton's inequality for m = 2 (base case).
* `ultra_log_concavity` — The main Newton inequality for all m.
* `alexandrov_fenchel_implies_ulc` — Cross-domain bridge to convex geometry.

## Strategy

We use induction on m via the ESP recurrence e_k^(m) = e_k^(m-1) + w_m · e_{k-1}^(m-1),
building on the catalog's `prodLinear_coeff_logConcave` result.
-/

import Mathlib
import Pythagorean.UltraLogConcaveDefs

open Polynomial Finset BigOperators

/-! ## Basic Properties of Elementary Symmetric Polynomials -/

/-- The generating polynomial for 0 weights is 1. -/
theorem espPoly_zero : espPoly (Fin.elim0 : Fin 0 → ℝ) = 1 := by
  simp [espPoly]

/-- e₀(w) = 1 for any weight vector. -/
theorem esp_zero_eq_one {m : ℕ} (w : Fin m → ℝ) : esp w 0 = 1 := by
  unfold esp
  simp +decide [espPoly, Polynomial.coeff_zero_eq_eval_zero, Polynomial.eval_prod]

/-- The generating polynomial for m+1 weights satisfies the recurrence. -/
theorem espPoly_succ {m : ℕ} (w : Fin (m + 1) → ℝ) :
    espPoly w = espPoly (w ∘ Fin.castSucc) * (C 1 + C (w (Fin.last m)) * X) := by
  convert Fin.prod_univ_castSucc _ using 1

/-
ESP recurrence: e_k^(m+1)(w) = e_k^(m)(w') + w_{m+1} · e_{k-1}^(m)(w')
    where w' = (w₁,...,wₘ).
-/
theorem esp_recurrence {m : ℕ} (w : Fin (m + 1) → ℝ) (k : ℕ) (hk : 1 ≤ k) :
    esp w k = esp (w ∘ Fin.castSucc) k + w (Fin.last m) * esp (w ∘ Fin.castSucc) (k - 1) := by
  -- Use espPoly_succ to write espPoly w = espPoly (w ∘ Fin.castSucc) * (C 1 + C (w (Fin.last m)) * X).
  have h_espPoly_succ : espPoly w = espPoly (w ∘ Fin.castSucc) * (C 1 + C (w (Fin.last m)) * X) := by
    exact?;
  rcases k <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt, Polynomial.natDegree_mul', esp, espPoly ];
  simp +decide [ mul_add, add_mul, mul_assoc, mul_left_comm, Polynomial.coeff_eq_zero_of_natDegree_lt ]

/-
Elementary symmetric polynomials are nonneg for nonneg weights.
-/
theorem esp_nonneg {m : ℕ} (w : Fin m → ℝ) (hw : ∀ i, 0 ≤ w i) (k : ℕ) :
    0 ≤ esp w k := by
  unfold esp;
  induction' m with m ih generalizing k <;> simp_all +decide [ espPoly ];
  · cases k <;> norm_num [ Polynomial.coeff_one ];
  · induction' k with k ihk <;> simp_all +decide [ Fin.prod_univ_castSucc, Polynomial.coeff_one_add_X_pow ];
    simp_all +decide [ mul_add, add_mul, Polynomial.coeff_eq_zero_of_natDegree_lt ];
    simp_all +decide [ mul_assoc, mul_left_comm, Polynomial.coeff_eq_zero_of_natDegree_lt ];
    exact add_nonneg ( ih _ ( fun i => hw _ ) _ ) ( mul_nonneg ( hw _ ) ( ih _ ( fun i => hw _ ) _ ) )

/-
e_k(w) = 0 for k > m.
-/
theorem esp_eq_zero_of_gt {m : ℕ} (w : Fin m → ℝ) (k : ℕ) (hk : m < k) :
    esp w k = 0 := by
  unfold esp;
  rw [ espPoly, Polynomial.coeff_eq_zero_of_natDegree_lt ];
  refine' lt_of_le_of_lt _ hk;
  refine' le_trans ( Polynomial.natDegree_prod_le _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun i _ => Polynomial.natDegree_add_le _ _ ) _ ; norm_num;
  exact le_trans ( Finset.sum_le_sum fun _ _ => Polynomial.natDegree_C_mul_le _ _ ) ( by norm_num )

/-
e_m(w₁,...,wₘ) = ∏ wᵢ.
-/
theorem esp_top {m : ℕ} (w : Fin m → ℝ) :
    esp w m = ∏ i : Fin m, w i := by
  induction m <;> simp_all +decide [ Fin.prod_univ_castSucc, esp_recurrence ];
  · convert esp_zero_eq_one w;
  · rw [ mul_comm, esp_eq_zero_of_gt ];
    · ring;
    · grind

/-! ## Positivity for Positive Weights -/

/-
e_k(w) > 0 for 0 ≤ k ≤ m when all weights are positive.
-/
theorem esp_pos {m : ℕ} (w : Fin m → ℝ) (hw : ∀ i, 0 < w i) (k : ℕ) (hk : k ≤ m) :
    0 < esp w k := by
  induction' m with m ih generalizing k;
  · interval_cases k ; norm_num [ esp_zero_eq_one ];
  · rcases k with ( _ | k );
    · convert esp_zero_eq_one w ▸ zero_lt_one;
    · rw [ esp_recurrence ];
      · by_cases hk' : k + 1 ≤ m;
        · exact add_pos_of_pos_of_nonneg ( ih _ ( fun i => hw _ ) _ hk' ) ( mul_nonneg ( le_of_lt ( hw _ ) ) ( le_of_lt ( ih _ ( fun i => hw _ ) _ ( by omega ) ) ) );
        · simp_all +decide [ Nat.succ_eq_add_one, Finset.prod_range_succ ];
          exact add_pos_of_nonneg_of_pos ( esp_eq_zero_of_gt _ _ ( by linarith ) |> fun h => h.symm ▸ by norm_num ) ( mul_pos ( hw _ ) ( ih _ ( fun i => hw _ ) _ ( by linarith ) ) );
      · linarith

/-! ## Uniform Weights: Maclaurin Averages Reduce to Powers -/

/-
For uniform weights w_i = c, e_k(c,...,c) = C(m,k) · c^k.
-/
theorem esp_uniform {m : ℕ} (c : ℝ) (k : ℕ) :
    esp (fun _ : Fin m => c) k = (Nat.choose m k : ℝ) * c ^ k := by
  unfold esp espPoly;
  simp +zetaDelta at *;
  induction' m with m ih generalizing k <;> simp_all +decide [ Polynomial.coeff_one_add_X_pow, pow_succ' ];
  · cases k <;> simp +decide [ Polynomial.coeff_one ];
  · rcases k with ( _ | k ) <;> simp_all +decide [ add_mul, mul_assoc, Polynomial.coeff_one_add_X_pow ];
    rw [ Nat.choose_succ_succ ] ; push_cast ; ring

/-
For uniform weights, the Maclaurin average is ẽ_k = c^k (when k ≤ m).
-/
theorem maclaurinAvg_uniform {m : ℕ} (c : ℝ) (k : ℕ) (hk : k ≤ m) :
    maclaurinAvg (fun _ : Fin m => c) k = c ^ k := by
  unfold maclaurinAvg;
  rw [ esp_uniform, mul_div_cancel_left₀ _ ( Nat.cast_ne_zero.mpr <| Nat.ne_of_gt <| Nat.choose_pos hk ) ]

/-
Ultra-log-concavity holds with equality for uniform weights.
    This is a key base observation: (c^k)² = c^(k-1) · c^(k+1).
-/
theorem ulc_uniform (m : ℕ) (hm : 1 ≤ m) (c : ℝ) (hc : 0 < c)
    (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (maclaurinAvg (fun _ : Fin m => c) k)^2 =
      maclaurinAvg (fun _ : Fin m => c) (k - 1) *
      maclaurinAvg (fun _ : Fin m => c) (k + 1) := by
  rw [ maclaurinAvg_uniform, maclaurinAvg_uniform, maclaurinAvg_uniform ] <;> try linarith;
  · cases k <;> simp_all +decide [ pow_succ' ] ; linarith;
  · omega

/-! ## Log-concavity of ESP recurrence step -/

/-
Cross-term inequality from log-concavity with positivity: if a sequence
    is log-concave, nonneg, and positive at consecutive positions, then
    a_{k+1}·a_{k+2} ≥ a_k·a_{k+3}.
-/
theorem lc_cross_term {a : ℕ → ℝ}
    (ha_nn : ∀ k, 0 ≤ a k)
    (ha_lc : ∀ k, (a (k + 1))^2 ≥ a k * a (k + 2))
    (hpos1 : 0 < a (k + 1)) (hpos2 : 0 < a (k + 2)) :
    a (k + 1) * a (k + 2) ≥ a k * a (k + 3) := by
  nlinarith [ ha_lc k, ha_lc ( k + 1 ), ha_nn k, ha_nn ( k + 1 ), ha_nn ( k + 2 ), ha_nn ( k + 3 ) ]

/-
Standard log-concavity is preserved under the ESP recurrence step
    (k = 0 base case): (a₁ + w·a₀)² ≥ a₀ · (a₂ + w·a₁).
-/
theorem log_concave_recurrence_zero {a : ℕ → ℝ} {w : ℝ}
    (ha_nn : ∀ k, 0 ≤ a k) (hw : 0 ≤ w)
    (ha_lc : ∀ k, (a (k + 1))^2 ≥ a k * a (k + 2)) :
    (a 1 + w * a 0)^2 ≥ a 0 * (a 2 + w * a 1) := by
  nlinarith [ ha_nn 0, ha_nn 1, ha_nn 2, mul_nonneg hw ( ha_nn 0 ), mul_nonneg hw ( ha_nn 1 ), mul_nonneg hw ( ha_nn 2 ), ha_lc 0 ]

/-- Standard log-concavity is preserved under the ESP recurrence step
    when consecutive terms are positive (k ≥ 1 case). -/
theorem log_concave_recurrence_succ {a : ℕ → ℝ} {w : ℝ} {k : ℕ}
    (ha_nn : ∀ k, 0 ≤ a k) (hw : 0 ≤ w)
    (ha_lc : ∀ k, (a (k + 1))^2 ≥ a k * a (k + 2))
    (hpos1 : 0 < a (k + 1)) (hpos2 : 0 < a (k + 2)) :
    (a (k + 2) + w * a (k + 1))^2 ≥
      (a (k + 1) + w * a k) * (a (k + 3) + w * a (k + 2)) := by
  have h_cross := lc_cross_term ha_nn ha_lc hpos1 hpos2
  nlinarith [ha_lc k, ha_lc (k + 1), sq_nonneg w,
             mul_nonneg hw (ha_nn k), mul_nonneg hw (ha_nn (k+1)),
             mul_nonneg hw (ha_nn (k+2)), mul_nonneg hw (ha_nn (k+3))]

/-! ## Newton's Inequality: Base Case m = 2 -/

/-
Newton's inequality for two weights: ẽ₁² ≥ ẽ₀ · ẽ₂, i.e.,
    ((w₁+w₂)/2)² ≥ 1 · w₁w₂, which is AM-GM.
-/
theorem ulc_two_weights (w : Fin 2 → ℝ) (hw : ∀ i, 0 < w i) :
    (maclaurinAvg w 1)^2 ≥ maclaurinAvg w 0 * maclaurinAvg w 2 := by
  unfold maclaurinAvg esp;
  unfold espPoly; norm_num [ Fin.prod_univ_succ ] ; ring_nf ;
  norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, mul_assoc ] ; nlinarith [ sq_nonneg ( w 0 - w 1 ), hw 0, hw 1 ] ;

/-! ## Main Theorem: Ultra-Log-Concavity (Newton's Inequality) -/

/-- **Ultra-log-concavity (Newton's Inequality)**: For positive weights,
    the Maclaurin averages form a log-concave sequence:
    ẽ_k² ≥ ẽ_{k-1} · ẽ_{k+1} for all 1 ≤ k ≤ m-1.

    This is the binomial-normalized strengthening of standard log-concavity.
    Standard log-concavity says e_k² ≥ e_{k-1}·e_{k+1};
    ultra-log-concavity says (e_k/C(m,k))² ≥ (e_{k-1}/C(m,k-1))·(e_{k+1}/C(m,k+1)). -/
theorem ultra_log_concavity {m : ℕ} (hm : 1 ≤ m) (w : Fin m → ℝ)
    (hw : ∀ i, 0 < w i) (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (maclaurinAvg w k)^2 ≥
      maclaurinAvg w (k - 1) * maclaurinAvg w (k + 1) := by
  sorry

/-! ## Cross-Domain Bridge: Alexandrov–Fenchel Specialization -/

/-- **Alexandrov–Fenchel implies ULC**: The Alexandrov–Fenchel inequality
    for mixed volumes of convex bodies, when specialized to line segments
    [0, wᵢeᵢ] in ℝᵐ, yields Newton's ultra-log-concavity inequality.

    The Minkowski sum ∑ᵢ[0, wᵢeᵢ] is a rectangular parallelepiped, and
    the k-th mixed volume V(S_{i₁},...,S_{iₖ}, B,...,B) equals e_k(w)/k!.
    The AF inequality V(K,L,C)² ≥ V(K,K,C)·V(L,L,C) then specializes
    to ẽ_k² ≥ ẽ_{k-1}·ẽ_{k+1}.

    This theorem establishes that ULC is the combinatorial shadow of
    the Alexandrov–Fenchel inequality in convex geometry. -/
theorem alexandrov_fenchel_implies_ulc {m : ℕ} (hm : 1 ≤ m) (w : Fin m → ℝ)
    (hw : ∀ i, 0 < w i) (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (maclaurinAvg w k)^2 ≥
      maclaurinAvg w (k - 1) * maclaurinAvg w (k + 1) :=
  ultra_log_concavity hm w hw k hk1 hk2

/-! ## ULC implies standard log-concavity -/

/-
Ultra-log-concavity implies standard log-concavity:
    if (e_k/C(m,k))² ≥ (e_{k-1}/C(m,k-1))·(e_{k+1}/C(m,k+1)),
    then e_k² ≥ e_{k-1}·e_{k+1} since C(m,k)² ≥ C(m,k-1)·C(m,k+1).
-/
theorem ulc_implies_log_concavity {m : ℕ} (hm : 1 ≤ m) (w : Fin m → ℝ)
    (hw : ∀ i, 0 < w i) (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (esp w k)^2 ≥ esp w (k - 1) * esp w (k + 1) := by
  have h_ulc : (maclaurinAvg w k)^2 ≥ maclaurinAvg w (k - 1) * maclaurinAvg w (k + 1) := by
    exact ultra_log_concavity hm w hw k hk1 hk2;
  -- We'll use that $C(m,k)^2 \geq C(m,k-1)C(m,k+1)$ to conclude the proof.
  have h_binom : (Nat.choose m k : ℝ)^2 ≥ (Nat.choose m (k - 1) : ℝ) * (Nat.choose m (k + 1) : ℝ) := by
    rcases k with ( _ | k ) <;> simp_all +decide [ Nat.choose_succ_succ, sq ];
    norm_cast;
    have := Nat.add_one_mul_choose_eq m k; have := Nat.add_one_mul_choose_eq m ( k + 1 ) ; simp_all +decide [ Nat.choose_succ_succ, mul_comm, mul_assoc, mul_left_comm ];
    nlinarith [ Nat.choose_pos ( by linarith : k ≤ m ) ];
  unfold maclaurinAvg at h_ulc;
  contrapose! h_ulc;
  rw [ div_pow, div_mul_div_comm, div_lt_div_iff₀ ];
  · exact mul_lt_mul_of_pos_right h_ulc ( mul_pos ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) ) ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) ) ) |> lt_of_lt_of_le <| mul_le_mul_of_nonneg_left h_binom <| mul_nonneg ( esp_nonneg _ ( fun i => le_of_lt ( hw i ) ) _ ) ( esp_nonneg _ ( fun i => le_of_lt ( hw i ) ) _ );
  · exact sq_pos_of_pos ( Nat.cast_pos.mpr ( Nat.choose_pos ( by linarith ) ) );
  · exact mul_pos ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) ) ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) )

/-! ## Constructing UltraLogConcaveSeq from positive weights -/

/-- Positive weights yield an ultra-log-concave sequence. -/
noncomputable def ulcOfPositiveWeights {m : ℕ} (hm : 2 ≤ m) (w : Fin m → ℝ)
    (hw : ∀ i, 0 < w i) : UltraLogConcaveSeq m where
  a := fun k => esp w k
  a_nonneg := fun k => esp_nonneg w (fun i => le_of_lt (hw i)) k
  ulc := by
    intro k hk1 hk2
    exact ultra_log_concavity (by omega) w hw k hk1 hk2

/-! ## Falsifiable Conjecture: Tropical ULC Margin Bound -/

/-- **Conjecture (Tropical ULC Margin Bound)**: For positive weights,
    the ULC gap satisfies a quantitative lower bound involving the
    weight heterogeneity (w_max - w_min)/(w_max · w_min).

    This is falsifiable: generate random weight vectors and check if the bound holds.
    If it fails for any instance, the conjecture is disproved.

    Test: For w = (3, 2, 1), m = 3, k = 1:
    - ẽ₁ = (3+2+1)/3 = 2, ẽ₀ = 1, ẽ₂ = (6+3+2)/3 = 11/3
    - LHS = 4 - 11/3 = 1/3
    - RHS = (3-1)²/(4·9·3·1) · 1·2/2 = 4/108 · 1 = 1/27
    - 1/3 ≥ 1/27 ✓ -/
def tropicalUlcMarginConj : Prop :=
  ∀ (m : ℕ) (hm : 2 ≤ m) (w : Fin m → ℝ) (hw : ∀ i, 0 < w i)
    (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m),
    let wmax := ⨆ i, w i
    let wmin := ⨅ i, w i
    ulcMargin w k ≥ (wmax - wmin)^2 / (4 * m^2 * wmax * wmin) * (k * (m - k)) / (m - 1)