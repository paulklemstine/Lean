/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Newton's Inequality via Elementary Symmetric Polynomials

This file proves Newton's inequality: the elementary symmetric polynomials
of nonnegative weights form a log-concave sequence:
    e_k(w)² ≥ e_{k-1}(w) · e_{k+1}(w)
for all 1 ≤ k ≤ m-1 and nonneg weights w₁,...,wₘ.

## Main Results

* `esp_zero_eq_one` — e₀(w) = 1.
* `esp_nonneg` — e_k(w) ≥ 0 for nonneg weights.
* `esp_eq_zero_of_gt` — e_k(w) = 0 for k > m.
* `esp_zero_tail` — If e_k(w) = 0 then e_j(w) = 0 for all j ≥ k (nonneg weights).
* `espPoly_succ` — Recurrence for the generating polynomial.
* `esp_recurrence` — e_k^{m+1} = e_k^m + w_{m+1} · e_{k-1}^m.
* `esp_uniform` — e_k(c,...,c) = C(m,k) · c^k.
* `newton_inequality` — Newton's inequality (log-concavity of ESPs).
* `ulc_uniform` — ULC for uniform weights with equality.

## Strategy

We prove Newton's inequality by induction on m using the ESP recurrence.

## References

* Newton, I. "Arithmetica Universalis", 1707.
* Hardy, Littlewood, Pólya. "Inequalities", Cambridge, 1934.
* Brändén, P. and Huh, J. "Lorentzian polynomials", Annals of Mathematics, 2020.
-/

import Mathlib

open Polynomial Finset BigOperators

/-! ## Definitions -/

/-- The generating polynomial ∏ᵢ(1 + wᵢX) whose k-th coefficient is e_k(w). -/
noncomputable def espPoly {m : ℕ} (w : Fin m → ℝ) : ℝ[X] :=
  ∏ i : Fin m, (C 1 + C (w i) * X)

/-- The k-th elementary symmetric polynomial e_k(w₁,...,wₘ). -/
noncomputable def esp {m : ℕ} (w : Fin m → ℝ) (k : ℕ) : ℝ :=
  (espPoly w).coeff k

/-- The k-th Maclaurin average (normalized ESP): ẽ_k = e_k / C(m,k). -/
noncomputable def maclaurinAvg {m : ℕ} (w : Fin m → ℝ) (k : ℕ) : ℝ :=
  esp w k / (Nat.choose m k : ℝ)

/-- A sequence is log-concave on [0, m]. -/
def IsLogConcave (a : ℕ → ℝ) (m : ℕ) : Prop :=
  ∀ k, 1 ≤ k → k + 1 ≤ m → (a k) ^ 2 ≥ a (k - 1) * a (k + 1)

/-! ## Basic Properties -/

/-
e₀(w) = 1 for any weight vector.
-/
theorem esp_zero_eq_one {m : ℕ} (w : Fin m → ℝ) : esp w 0 = 1 := by
  -- The constant coefficient of the product of polynomials is the product of their constant coefficients.
  have h_const : Polynomial.coeff (∏ x : Fin m, (1 + Polynomial.C (w x) * Polynomial.X)) 0 = ∏ x : Fin m, Polynomial.coeff (1 + Polynomial.C (w x) * Polynomial.X) 0 := by
    simp +decide [ Polynomial.coeff_zero_eq_eval_zero, Polynomial.eval_prod ];
  convert h_const using 1;
  norm_num [ Polynomial.coeff_zero_eq_eval_zero ]

/-- The generating polynomial satisfies the recurrence
    P_{m+1}(w) = P_m(w') · (1 + w_{m+1} X). -/
theorem espPoly_succ {m : ℕ} (w : Fin (m + 1) → ℝ) :
    espPoly w = espPoly (w ∘ Fin.castSucc) * (C 1 + C (w (Fin.last m)) * X) := by
  simp [espPoly]
  exact Fin.prod_univ_castSucc _

/-
e_k(w) = 0 for k > m.
-/
theorem esp_eq_zero_of_gt {m : ℕ} (w : Fin m → ℝ) (k : ℕ) (hk : m < k) :
    esp w k = 0 := by
      refine' Polynomial.coeff_eq_zero_of_natDegree_lt _;
      refine' lt_of_le_of_lt _ hk;
      refine' le_trans ( Polynomial.natDegree_prod_le _ _ ) _;
      refine' le_trans ( Finset.sum_le_sum fun _ _ => Polynomial.natDegree_add_le _ _ ) _ ; norm_num;
      exact le_trans ( Finset.sum_le_sum fun _ _ => Polynomial.natDegree_C_mul_le _ _ ) ( by norm_num )

/-
Elementary symmetric polynomials are nonneg for nonneg weights.
-/
theorem esp_nonneg {m : ℕ} (w : Fin m → ℝ) (hw : ∀ i, 0 ≤ w i) (k : ℕ) :
    0 ≤ esp w k := by
      -- By induction on $m$, we can show that the coefficients of the polynomial $P$ are nonneg.
      have h_coeff_nonneg : ∀ m : ℕ, ∀ w : Fin m → ℝ, (∀ i, 0 ≤ w i) → ∀ k, 0 ≤ (espPoly w).coeff k := by
        intro m w hw; induction' m with m ih generalizing k <;> simp_all +decide [ Fin.prod_univ_succ, espPoly ] ;
        · exact fun k => by rw [ Polynomial.coeff_one ] ; positivity;
        · intro k; rw [ Polynomial.coeff_mul ] ; refine' Finset.sum_nonneg fun _ _ => mul_nonneg _ _ <;> aesop;
      exact h_coeff_nonneg m w hw k

/-
ESP recurrence: e_k^{m+1}(w) = e_k^m(w') + w_{m+1} · e_{k-1}^m(w').
-/
theorem esp_recurrence {m : ℕ} (w : Fin (m + 1) → ℝ) (k : ℕ) (hk : 1 ≤ k) :
    esp w k = esp (w ∘ Fin.castSucc) k +
      w (Fin.last m) * esp (w ∘ Fin.castSucc) (k - 1) := by
        unfold esp espPoly; rcases k with ( _ | k ) <;> simp_all +decide [ Polynomial.coeff_one, Polynomial.coeff_X, mul_assoc, add_mul, Finset.prod_mul_distrib ] ; ring;
        rw [ Fin.prod_univ_castSucc ] ; ring;
        norm_num [ add_comm 1, mul_assoc, Polynomial.coeff_C, Polynomial.coeff_X ];
        ring

/-
For uniform weights, e_k(c,...,c) = C(m,k) · c^k.
-/
theorem esp_uniform {m : ℕ} (c : ℝ) (k : ℕ) :
    esp (fun _ : Fin m => c) k = (Nat.choose m k : ℝ) * c ^ k := by
      -- We start by considering the generating polynomial for uniform weights.
      have h_poly : espPoly (fun (x : Fin m) => c) = (1 + C c * X) ^ m := by
        -- By definition of espPoly, we have espPoly (fun _ => c) = ∏ i : Fin m, (C 1 + C c * X).
        simp [espPoly];
      -- By definition of ESP, we know that esp (fun _ => c) k is the coefficient of X^k in the polynomial (1 + C c * X)^m.
      unfold esp
      simp [h_poly];
      induction' m with m ih generalizing k <;> simp_all +decide [ add_mul, mul_assoc, pow_succ', mul_add, Nat.choose_succ_succ, Polynomial.coeff_one, Polynomial.coeff_X ];
      · cases k <;> aesop;
      · rcases k with ( _ | k ) <;> simp_all +decide [ Nat.choose_succ_succ, add_mul, mul_assoc, Polynomial.coeff_eq_zero_of_natDegree_lt ];
        · norm_num [ Polynomial.coeff_zero_eq_eval_zero ];
        · rw [ ih, ih ] <;> ring;
          · unfold espPoly; aesop;
          · unfold espPoly; aesop;

/-
e_m(w₁,...,wₘ) = ∏ wᵢ.
-/
theorem esp_top {m : ℕ} (w : Fin m → ℝ) :
    esp w m = ∏ i : Fin m, w i := by
      induction' m with m ih;
      · convert esp_zero_eq_one w;
      · convert esp_recurrence w ( m + 1 ) ( by linarith ) using 1;
        rw [ esp_eq_zero_of_gt ] <;> norm_num [ ih ];
        rw [ Fin.prod_univ_castSucc, mul_comm ]

/-
If e_k = 0 with nonneg weights then e_{k+1} = 0.
    This is because e_k is a sum of products of k nonneg weights;
    if the sum is 0 then every product is 0, meaning at most k-1
    weights are positive, so every product of k+1 weights is also 0.
-/
theorem esp_zero_succ {m : ℕ} (w : Fin m → ℝ) (hw : ∀ i, 0 ≤ w i)
    (k : ℕ) (hk : esp w k = 0) : esp w (k + 1) = 0 := by
      induction' m with m ih generalizing k;
      · unfold esp at *;
        unfold espPoly; aesop;
      · rcases k with ( _ | k ) <;> simp_all +decide [ esp_recurrence ];
        · exact absurd hk ( by rw [ esp_zero_eq_one ] ; norm_num );
        · -- Since $w (Fin.last m) \geq 0$ and $esp (w ∘ Fin.castSucc) k \geq 0$, their product is non-negative.
          have h_nonneg : 0 ≤ w (Fin.last m) * esp (w ∘ Fin.castSucc) k := by
            exact mul_nonneg ( hw _ ) ( esp_nonneg _ ( fun i => hw _ ) _ );
          convert ih ( w ∘ Fin.castSucc ) ( fun i => hw _ ) ( k + 1 ) _ using 1;
          · rw [ show esp ( w ∘ Fin.castSucc ) ( k + 1 ) = 0 by linarith [ show 0 ≤ esp ( w ∘ Fin.castSucc ) ( k + 1 ) from esp_nonneg _ ( fun i => hw _ ) _ ] ] ; ring;
          · linarith [ show 0 ≤ esp ( w ∘ Fin.castSucc ) ( k + 1 ) from esp_nonneg _ ( fun i => hw _ ) _ ]

/-! ## Newton's Inequality Helper Lemmas -/

/-
Cross-term inequality from log-concavity with tail-zero property:
    If b₁² ≥ b₀·b₂ and b₂² ≥ b₁·b₃, with all bᵢ ≥ 0 and b₂=0 → b₃=0,
    then b₁·b₂ ≥ b₀·b₃.
-/
theorem nonneg_cross_term (b0 b1 b2 b3 : ℝ)
    (h0 : 0 ≤ b0) (h1 : 0 ≤ b1) (h2 : 0 ≤ b2) (h3 : 0 ≤ b3)
    (hlc1 : b1 ^ 2 ≥ b0 * b2) (hlc2 : b2 ^ 2 ≥ b1 * b3)
    (htail : b2 = 0 → b3 = 0) :
    b1 * b2 ≥ b0 * b3 := by
      by_cases hb2 : b2 = 0;
      · aesop;
      · nlinarith [ mul_self_pos.2 hb2, mul_nonneg h0 h1, mul_nonneg h0 h2, mul_nonneg h0 h3, mul_nonneg h1 h2, mul_nonneg h1 h3, mul_nonneg h2 h3 ]

/-
The algebraic core of the inductive step: given log-concavity of (bᵢ),
    the recurrence (b₂ + a·b₁)² ≥ (b₁ + a·b₀)·(b₃ + a·b₂)
    follows from three nonneg pieces.
-/
theorem recurrence_preserves_lc (a b0 b1 b2 b3 : ℝ)
    (ha : 0 ≤ a) (h0 : 0 ≤ b0) (h1 : 0 ≤ b1) (h2 : 0 ≤ b2) (h3 : 0 ≤ b3)
    (hlc1 : b1 ^ 2 ≥ b0 * b2)
    (hlc2 : b2 ^ 2 ≥ b1 * b3)
    (hcross : b1 * b2 ≥ b0 * b3) :
    (b2 + a * b1) ^ 2 ≥ (b1 + a * b0) * (b3 + a * b2) := by
      nlinarith [ mul_le_mul_of_nonneg_left hcross ha, mul_le_mul_of_nonneg_left hlc1 ha, mul_le_mul_of_nonneg_left hlc2 ha ]

/-! ## Newton's Inequality -/

/-
**Newton's Inequality (Log-Concavity of ESPs):**
    For nonneg weights w₁,...,wₘ and 1 ≤ k ≤ m-1:
        e_k(w)² ≥ e_{k-1}(w) · e_{k+1}(w).

    Proved by induction on m using the ESP recurrence and
    `recurrence_preserves_lc`.
-/
theorem newton_inequality {m : ℕ} (w : Fin m → ℝ) (hw : ∀ i, 0 ≤ w i)
    (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (esp w k) ^ 2 ≥ esp w (k - 1) * esp w (k + 1) := by
      induction' m with m ih generalizing k;
      · contradiction;
      · rcases k with ( _ | k ) <;> simp_all +decide [ esp_recurrence ];
        by_cases hk : 1 ≤ k <;> simp_all +decide [ esp_recurrence ];
        · -- By the induction hypothesis, we have:
          have h_ind : (esp (w ∘ Fin.castSucc) (k - 1)) * (esp (w ∘ Fin.castSucc) (k + 1)) ≤ (esp (w ∘ Fin.castSucc) k) ^ 2 ∧ (esp (w ∘ Fin.castSucc) k) * (esp (w ∘ Fin.castSucc) (k + 2)) ≤ (esp (w ∘ Fin.castSucc) (k + 1)) ^ 2 := by
            by_cases hk3 : k + 1 < m;
            · exact ⟨ ih _ ( fun i => hw _ ) _ hk hk2, ih _ ( fun i => hw _ ) _ ( Nat.succ_pos _ ) hk3 ⟩;
            · rcases eq_or_lt_of_le ( Nat.succ_le_of_lt hk2 ) <;> simp_all +decide [ Nat.succ_eq_add_one ];
              subst_vars; simp_all +decide [ esp_eq_zero_of_gt ] ;
              positivity;
          grind +suggestions;
        · rcases m with ( _ | _ | m ) <;> simp_all +decide [ esp_zero_eq_one ];
          · unfold esp; ring_nf;
            unfold espPoly; norm_num [ Fin.prod_univ_succ ] ; ring_nf;
            norm_num [ Polynomial.coeff_one, Polynomial.coeff_X ] ; nlinarith [ sq_nonneg ( w 0 - w 1 ) ];
          · have := ih ( w ∘ Fin.castSucc ) ( fun i => hw _ ) 1 ( by norm_num ) ( by linarith ) ; norm_num [ esp_zero_eq_one ] at this;
            nlinarith [ hw ( Fin.last _ ), show 0 ≤ esp ( w ∘ Fin.castSucc ) 1 from esp_nonneg _ ( fun i => hw _ ) _ ]

/-! ## Consequences -/

/-- Newton's inequality implies esp forms a log-concave sequence. -/
theorem esp_is_log_concave {m : ℕ} (w : Fin m → ℝ) (hw : ∀ i, 0 ≤ w i) :
    IsLogConcave (esp w) m :=
  fun k hk1 hk2 => newton_inequality w hw k hk1 hk2

/-
For uniform weights, Maclaurin averages satisfy ẽ_k = c^k.
-/
theorem maclaurinAvg_uniform {m : ℕ} (c : ℝ) (k : ℕ) (hk : k ≤ m) :
    maclaurinAvg (fun _ : Fin m => c) k = c ^ k := by
      convert congr_arg ( fun x : ℝ => x / ( m.choose k : ℝ ) ) ( esp_uniform c k ) using 1;
      rw [ mul_div_cancel_left₀ _ ( Nat.cast_ne_zero.mpr <| Nat.ne_of_gt <| Nat.choose_pos hk ) ]

/-- Newton's inequality for two weights is AM-GM. -/
theorem newton_two_weights (w : Fin 2 → ℝ) (hw : ∀ i, 0 ≤ w i) :
    (esp w 1) ^ 2 ≥ esp w 0 * esp w 2 :=
  newton_inequality w hw 1 (by omega) (by omega)

/-
Cross-term from log-concavity with positive consecutive terms.
-/
theorem lc_cross_term {a : ℕ → ℝ}
    (ha_nn : ∀ k, 0 ≤ a k)
    (ha_lc : ∀ k, (a (k + 1)) ^ 2 ≥ a k * a (k + 2))
    {k : ℕ} (hpos1 : 0 < a (k + 1)) (hpos2 : 0 < a (k + 2)) :
    a (k + 1) * a (k + 2) ≥ a k * a (k + 3) := by
      nlinarith [ ha_lc k, ha_lc ( k + 1 ), ha_nn k, ha_nn ( k + 1 ), ha_nn ( k + 2 ), ha_nn ( k + 3 ) ]

/-
Ultra-log-concavity for uniform weights holds with equality.
-/
theorem ulc_uniform (m : ℕ) (c : ℝ)
    (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (maclaurinAvg (fun _ : Fin m => c) k) ^ 2 =
      maclaurinAvg (fun _ : Fin m => c) (k - 1) *
      maclaurinAvg (fun _ : Fin m => c) (k + 1) := by
        -- By maclaurinAvg_uniform, we know that maclaurinAvg (fun _ : Fin m => c) k = c^k.
        have h_k : maclaurinAvg (fun _ : Fin m => c) k = c^k := by
          convert maclaurinAvg_uniform c k ( by linarith ) using 1
        have h_k1 : maclaurinAvg (fun _ : Fin m => c) (k - 1) = c^(k - 1) := by
          exact maclaurinAvg_uniform _ _ ( Nat.sub_le_of_le_add <| by linarith )
        have h_k2 : maclaurinAvg (fun _ : Fin m => c) (k + 1) = c^(k + 1) := by
          convert maclaurinAvg_uniform c ( k + 1 ) ( by linarith ) using 1;
        cases k <;> simp_all +decide [ pow_succ' ] ; linarith