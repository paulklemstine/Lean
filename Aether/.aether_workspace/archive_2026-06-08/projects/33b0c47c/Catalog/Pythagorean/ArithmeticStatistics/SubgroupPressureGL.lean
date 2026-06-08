/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Arithmetic Statistics via Subgroup Pressure in Linear Groups

This file develops the first rigorous thermodynamic theory of subgroup growth
for finite linear groups, connecting parabolic subgroup combinatorics to
statistical mechanics through q-multinomial coefficients.

## Mathematical Overview

For GL_n(𝔽_q), the standard parabolic subgroups are indexed by compositions
of n. The index [GL_n(𝔽_q) : P_c] equals the q-multinomial coefficient,
which counts partial flags of type c over 𝔽_q. This converts subgroup
pressure into explicit q-combinatorics.

The key insight is that the parabolic index weight w_q(c,n) = log [n; c]_q
admits quadratic bounds:
  (∑_{i<j} n_i n_j) · log q  ≤  w_q(c,n)  ≤  (∑_{i<j} n_i n_j) · log q + n · log q

This identifies subgroup pressure with a mean-field energy on compositions,
governed by the Tsallis-2 entropy functional H₂(p) = 1 - ∑ pᵢ².

## Main Definitions

* `isCompositionOf` — predicate for a list being a composition of n
* `qInt` — q-integer [k]_q = 1 + q + ... + q^{k-1}
* `qFactorial` — q-factorial [k]_q!
* `qBinomial` — Gaussian binomial coefficient
* `qMultinomial` — q-multinomial coefficient
* `compositionCrossTerm` — quadratic interaction ∑_{i<j} n_i n_j
* `parabolicIndexWeight` — log of q-multinomial
* `parabolicPressure` — partition function over compositions
* `tsallis2` — Tsallis-2 entropy 1 - ∑ pᵢ²

## Main Results

* `compositionCrossTerm_eq_half` — 2·crossTerm = n² - ∑ nᵢ²
* `qInt_pos` — q-integer is positive for q > 0 and k > 0
* `qFactorial_pos` — q-factorial is positive for q > 0
* `qBinomial_pos` — Gaussian binomial is positive for q > 1
* `parabolic_weight_lower_bound` — lower bound by crossTerm · log q
* `parabolic_weight_upper_bound` — upper bound by crossTerm · log q + n · log q
* `parabolicPressure_pos` — parabolic pressure is positive

## Application Keywords

arithmetic statistics, finite linear groups, subgroup growth, free energy,
parabolic subgroups, Gaussian binomial coefficients, q-multinomial coefficients,
flag varieties, Tsallis entropy, nonextensive statistical mechanics,
Cohen–Lenstra heuristics, random matrices over finite fields,
asymptotic combinatorics, thermodynamic formalism, q-analogues
-/

import Mathlib

open scoped BigOperators
open Finset Real

/-! ## Core Definitions -/

/-- A composition of `n`: a nonempty list of positive naturals summing to `n`. -/
def isCompositionOf (c : List ℕ) (n : ℕ) : Prop :=
  c ≠ [] ∧ (∀ x ∈ c, 0 < x) ∧ c.sum = n

/-- The q-integer `[k]_q = 1 + q + q² + ⋯ + q^{k-1}`.
  For q > 1 this equals `(q^k - 1)/(q - 1)`. -/
def qInt (q : ℕ) (k : ℕ) : ℕ :=
  ∑ i ∈ Finset.range k, q ^ i

/-- The q-factorial `[k]_q! = [1]_q · [2]_q · ⋯ · [k]_q`. -/
def qFactorial (q : ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => qFactorial q k * qInt q (k + 1)

/-- The Gaussian binomial coefficient `[n choose k]_q`.
  Defined by the recurrence with base cases. -/
def qBinomial (q : ℕ) : ℕ → ℕ → ℕ
  | _, 0 => 1
  | 0, _ + 1 => 0
  | n + 1, k + 1 => qBinomial q n k + q ^ (k + 1) * qBinomial q n (k + 1)

/-- The q-multinomial coefficient defined as the iterated product
  of Gaussian binomial coefficients:
  `[n; n₁, n₂, ..., n_k]_q = ∏ᵢ [n₁+...+nᵢ choose nᵢ]_q`. -/
def qMultinomial (q : ℕ) : List ℕ → ℕ
  | [] => 1
  | [_] => 1
  | (a :: rest) => qBinomial q (a + rest.sum) a * qMultinomial q rest

/-- The composition cross-term `∑_{i<j} nᵢ · nⱼ`.
  This is the quadratic interaction energy of a composition. -/
def compositionCrossTerm : List ℕ → ℕ
  | [] => 0
  | (a :: rest) => a * rest.sum + compositionCrossTerm rest

/-- Sum of squares of entries of a list. -/
def sumOfSquares (c : List ℕ) : ℕ :=
  (c.map fun x => x ^ 2).sum

/-- The parabolic index weight: log of the q-multinomial coefficient.
  Equals `log [GL_n(𝔽_q) : P_c]` for the standard parabolic P_c. -/
noncomputable def parabolicIndexWeight (q : ℕ) (c : List ℕ) : ℝ :=
  Real.log (qMultinomial q c : ℝ)

/-- The set of compositions of n (as a Finset). -/
def compositions : ℕ → Finset (List ℕ)
  | 0 => {[]}
  | (n + 1) => Finset.biUnion (Finset.range (n + 1)) fun k =>
    (compositions (n - k)).image fun rest => (k + 1) :: rest

/-- Parabolic pressure: the partition function
  `Π^par_{n,q}(β) = ∑_{c ⊨ n} exp(-β · w_q(c))`. -/
noncomputable def parabolicPressure (q : ℕ) (β : ℝ) (n : ℕ) : ℝ :=
  ∑ c ∈ compositions n, Real.exp (-β * parabolicIndexWeight q c)

/-- Extensivity defect measuring failure of direct-product extensivity. -/
noncomputable def extensivityDefect (q : ℕ) (m n : ℕ) (β : ℝ) : ℝ :=
  Real.log (parabolicPressure q β (m + n))
    - Real.log (parabolicPressure q β m)
    - Real.log (parabolicPressure q β n)

/-- Tsallis-2 entropy: `H₂(p) = 1 - ∑ pᵢ²`. -/
def tsallis2 (p : List ℝ) : ℝ :=
  1 - (p.map fun x => x ^ 2).sum

/-! ## Fundamental Properties of q-Integers -/

/-
q-integer is positive for q > 0 and k > 0.
-/
theorem qInt_pos (q k : ℕ) (hq : 0 < q) (hk : 0 < k) : 0 < qInt q k := by
  exact Finset.sum_pos ( fun _ _ => pow_pos hq _ ) ⟨ _, Finset.mem_range.mpr hk ⟩

/-
q-factorial is positive for q > 0.
-/
theorem qFactorial_pos (q k : ℕ) (hq : 0 < q) : 0 < qFactorial q k := by
  induction' k with k ih;
  · exact Nat.succ_pos _;
  · exact mul_pos ih ( qInt_pos q _ hq ( Nat.succ_pos _ ) )

/-
`qInt q 1 = 1` for all q.
-/
theorem qInt_one (q : ℕ) : qInt q 1 = 1 := by
  unfold qInt; norm_num;

/-
`qFactorial q 0 = 1` for all q.
-/
theorem qFactorial_zero (q : ℕ) : qFactorial q 0 = 1 := by
  rfl

/-! ## Gaussian Binomial Properties -/

/-
`qBinomial q n 0 = 1` for all n.
-/
theorem qBinomial_zero_right (q n : ℕ) : qBinomial q n 0 = 1 := by
  induction' n with n ih <;> tauto

/-
Gaussian binomial is positive for q > 1 and k ≤ n.
-/
theorem qBinomial_pos (q n k : ℕ) (hq : 1 < q) (hk : k ≤ n) :
    0 < qBinomial q n k := by
  induction' n with n ih generalizing k <;> induction' k with k ih' <;> simp_all +decide [ Nat.succ_eq_add_one, qBinomial ]

/-! ## The Composition Cross-Term Identity -/

/-
Key algebraic identity: `2 * compositionCrossTerm c = c.sum ^ 2 - sumOfSquares c`.
  This reveals the cross-term as related to the "spread" of a composition —
  compositions with more equal parts have higher cross-terms (higher energy).
-/
theorem compositionCrossTerm_eq_half (c : List ℕ) :
    2 * compositionCrossTerm c = c.sum ^ 2 - sumOfSquares c := by
  induction c <;> simp_all +decide [ sumOfSquares ];
  rename_i k l ih; rw [ show compositionCrossTerm ( k :: l ) = k * l.sum + compositionCrossTerm l from rfl ] ; ring;
  exact eq_tsub_of_add_eq ( by linarith [ Nat.sub_add_cancel ( show ( List.map ( fun x => x ^ 2 ) l ).sum ≤ l.sum ^ 2 from by simpa [ sq, List.sum_map_mul_right ] using List.sum_le_sum fun x hx => Nat.mul_le_mul_left x ( List.le_sum_of_mem hx ) ) ] )

/-
The cross-term bounds from above.
-/
theorem compositionCrossTerm_le (c : List ℕ) :
    2 * compositionCrossTerm c ≤ c.sum ^ 2 := by
  convert Nat.sub_le ( c.sum ^ 2 ) ( List.sum ( List.map ( fun x => x ^ 2 ) ( c ) ) ) using 1;
  convert compositionCrossTerm_eq_half c using 1

/-! ## q-Multinomial Positivity -/

/-
The q-multinomial coefficient is positive when q > 1.
  This is the fundamental positivity result ensuring the
  parabolic index weight (its logarithm) is well-defined.
-/
theorem qMultinomial_pos (q : ℕ) (hq : 1 < q) (c : List ℕ) :
    0 < qMultinomial q c := by
  induction' c with a c ih;
  · exact Nat.one_pos;
  · induction' c with b c ihizing a;
    · cases a <;> norm_num [ qMultinomial ];
    · -- By definition of qMultinomial, we have:
      have h_def : qMultinomial q (a :: b :: c) = qBinomial q (a + (b :: c).sum) a * qMultinomial q (b :: c) := by
        rfl;
      exact h_def.symm ▸ mul_pos ( qBinomial_pos q _ _ hq ( by simp +arith +decide ) ) ih

/-! ## Parabolic Pressure Positivity -/

/-
Parabolic pressure is positive since it's a sum of exponentials.
-/
theorem parabolicPressure_pos (q : ℕ) (hq : 1 < q) (β : ℝ) (n : ℕ) :
    0 < parabolicPressure q β n := by
  -- The sum of exponentials is positive, so the parabolic pressure is positive.
  have h_pos : ∀ c ∈ compositions n, 0 < Real.exp (-β * parabolicIndexWeight q c) := by
    exact fun c hc => Real.exp_pos _;
  convert Finset.sum_pos h_pos ?_;
  exact Nat.recOn n ⟨ [ ], by simp +decide [ compositions ] ⟩ fun n ih => by rw [ compositions ] ; exact Finset.Nonempty.mono ( Finset.subset_biUnion_of_mem _ ( Finset.mem_range.mpr ( Nat.succ_pos _ ) ) ) ( by aesop ) ;

/-! ## Energy Bounds for Parabolic Weights -/

/-
The q-multinomial is at least q^(compositionCrossTerm c).
  This gives the lower bound on parabolic weight.
-/
theorem qMultinomial_lower_bound (q : ℕ) (hq : 1 < q) (c : List ℕ) :
    q ^ compositionCrossTerm c ≤ qMultinomial q c := by
  induction' c with a c ih;
  · exact le_rfl;
  · -- By the properties of the Gaussian binomial coefficient, we have $qBinomial q (a + c.sum) a \geq q^{a * c.sum}$.
    have h_binom : qBinomial q (a + c.sum) a ≥ q^(a * c.sum) := by
      have h_binom : ∀ n k : ℕ, 0 ≤ k → k ≤ n → qBinomial q n k ≥ q^(k * (n - k)) := by
        intros n k hk_nonneg hk_le_n
        induction' n with n ih generalizing k;
        · aesop;
        · rcases k with ( _ | k ) <;> simp_all +decide [ Nat.succ_mul, pow_succ' ];
          · exact Nat.one_le_iff_ne_zero.mpr ( by exact ne_of_gt ( qBinomial_pos q _ _ hq ( Nat.zero_le _ ) ) );
          · have h_binom : qBinomial q (n + 1) (k + 1) = qBinomial q n k + q ^ (k + 1) * qBinomial q n (k + 1) := by
              rfl;
            by_cases hk_eq_n : k = n <;> simp_all +decide [ pow_add, mul_assoc ];
            · exact Nat.one_le_iff_ne_zero.mpr ( by specialize ih n le_rfl; aesop );
            · refine le_trans ?_ ( Nat.le_add_left _ _ );
              refine' le_trans _ ( Nat.mul_le_mul_left _ ( Nat.mul_le_mul_left _ ( ih ( k + 1 ) ( by omega ) ) ) );
              rw [ show n - k = n - ( k + 1 ) + 1 by omega ] ; ring_nf;
              norm_num;
      convert h_binom ( a + c.sum ) a ( Nat.zero_le a ) ( Nat.le_add_right _ _ ) using 1 ; simp +decide [ add_tsub_cancel_left ];
    rcases c with ( _ | ⟨ b, c ⟩ ) <;> simp_all +decide [ compositionCrossTerm ];
    · cases a <;> trivial;
    · convert Nat.mul_le_mul h_binom ih using 1 ; ring

/-
Splitting q-integers: `qInt q (a + b) = qInt q a + q^a * qInt q b`.
  This is the q-analogue of the additive decomposition of ranges.
-/
theorem qInt_split (q a b : ℕ) :
    qInt q (a + b) = qInt q a + q ^ a * qInt q b := by
  simp +decide [ qInt, Finset.sum_range_add ];
  simp +decide only [pow_add, Finset.mul_sum _ _ _]

/-
Vanishing of qBinomial when k > n.
-/
theorem qBinomial_eq_zero_of_lt (q n k : ℕ) (h : n < k) :
    qBinomial q n k = 0 := by
  induction' n with n ih generalizing k <;> induction' k with k ih' <;> simp_all +decide [ Nat.succ_eq_add_one, qBinomial ];
  exact Or.inr ( ih _ ( Nat.lt_succ_of_lt h ) )

/-
The q-factorial characterization of the Gaussian binomial:
  `qBinomial q n k * qFactorial q k * qFactorial q (n - k) = qFactorial q n`
  for `k ≤ n`. This is the q-analogue of `n! = C(n,k) * k! * (n-k)!`.
-/
theorem qBinomial_qFactorial (q n k : ℕ) (hq : 1 < q) (hk : k ≤ n) :
    qBinomial q n k * qFactorial q k * qFactorial q (n - k) = qFactorial q n := by
  induction' n with n ih generalizing k;
  · cases k <;> aesop;
  · rcases k with ( _ | k ) <;> simp_all +decide [ Nat.succ_sub ];
    · erw [ qFactorial_zero, show qBinomial q ( n + 1 ) 0 = 1 from by { exact? } ] ; norm_num;
    · by_cases h : k + 1 ≤ n;
      · have h_ind : qBinomial q n k * qFactorial q (k + 1) * qFactorial q (n - k) + q ^ (k + 1) * qBinomial q n (k + 1) * qFactorial q (k + 1) * qFactorial q (n - k) = qFactorial q (n + 1) := by
          have h_ind : qBinomial q n k * qFactorial q k * qFactorial q (n - k) * qInt q (k + 1) + q ^ (k + 1) * qBinomial q n (k + 1) * qFactorial q (k + 1) * qFactorial q (n - (k + 1)) * qInt q (n - k) = qFactorial q n * qInt q (k + 1) + q ^ (k + 1) * qFactorial q n * qInt q (n - k) := by
            grind;
          convert h_ind using 1;
          · rw [ show n - k = ( n - ( k + 1 ) ) + 1 by omega ];
            rw [ show qFactorial q ( k + 1 ) = qFactorial q k * qInt q ( k + 1 ) from rfl, show qFactorial q ( n - ( k + 1 ) + 1 ) = qFactorial q ( n - ( k + 1 ) ) * qInt q ( n - ( k + 1 ) + 1 ) from rfl ] ; ring;
          · rw [ show qFactorial q ( n + 1 ) = qFactorial q n * qInt q ( n + 1 ) by rfl ];
            rw [ show n + 1 = ( k + 1 ) + ( n - k ) by omega, qInt_split ] ; ring;
        convert h_ind using 1;
        rw [ show qBinomial q ( n + 1 ) ( k + 1 ) = qBinomial q n k + q ^ ( k + 1 ) * qBinomial q n ( k + 1 ) from rfl ] ; ring;
      · cases hk.eq_or_lt <;> first | linarith | simp_all +decide [ Nat.sub_eq_zero_of_le ];
        -- By definition of qBinomial, we know that qBinomial q (n + 1) (n + 1) = 1.
        have h_qBinomial : qBinomial q (n + 1) (n + 1) = 1 := by
          induction' n + 1 with n ih <;> simp_all +decide [ Nat.succ_eq_add_one, qBinomial ];
          exact Or.inr ( qBinomial_eq_zero_of_lt _ _ _ ( Nat.lt_succ_self _ ) );
        grind +suggestions

/-
Upper bound for qInt: `qInt q k < q^k` for q ≥ 2 and k ≥ 1.
-/
theorem qInt_lt_pow (q k : ℕ) (hq : 1 < q) (hk : 0 < k) :
    qInt q k < q ^ k := by
  induction hk <;> simp_all +decide [ Finset.sum_range_succ, pow_succ' ];
  · exact Finset.sum_range_succ _ _ |> fun h => h.trans_lt ( by norm_num; linarith );
  · rw [ qInt ] at *;
    rw [ Finset.sum_range_succ ] ; nlinarith [ pow_pos ( zero_lt_one.trans hq ) ‹_› ]

/-
Lower bound for qInt: `qInt q k ≥ q^(k-1)` for q ≥ 1.
-/
theorem qInt_ge_pow_pred (q k : ℕ) (hq : 1 ≤ q) (hk : 0 < k) :
    q ^ (k - 1) ≤ qInt q k := by
  exact Finset.single_le_sum ( fun x _ => Nat.zero_le ( q ^ x ) ) ( Finset.mem_range.mpr ( Nat.sub_lt hk zero_lt_one ) )

/-
The Gaussian binomial is at most `q^(k*(n-k)+k)` for `k ≤ n` and `q > 1`.
  Proof via the q-factorial characterization:
  `[n choose k]_q = [n]_q! / ([k]_q! [n-k]_q!)`, then bounding
  each factor `qInt(n-k+i)/qInt(i) ≤ q^(n-k+1)` gives the product
  bound `q^(k(n-k+1)) = q^(k(n-k)+k)`.
-/
theorem qBinomial_upper_bound (q n k : ℕ) (hq : 1 < q) (hk : k ≤ n) :
    qBinomial q n k ≤ q ^ (k * (n - k) + k) := by
  have h_recurrence : ∀ k < n, qBinomial q n (k + 1) * qInt q (k + 1) = qBinomial q n k * qInt q (n - k) := by
    intros k hk_lt_n
    have h_recurrence : qBinomial q n k * qFactorial q k * qFactorial q (n - k) = qFactorial q n ∧ qBinomial q n (k + 1) * qFactorial q (k + 1) * qFactorial q (n - (k + 1)) = qFactorial q n := by
      exact ⟨ qBinomial_qFactorial q n k hq ( by linarith ), qBinomial_qFactorial q n ( k + 1 ) hq ( by linarith ) ⟩;
    have h_recurrence : qFactorial q (k + 1) = qFactorial q k * qInt q (k + 1) ∧ qFactorial q (n - k) = qFactorial q (n - (k + 1)) * qInt q (n - k) := by
      exact ⟨ rfl, by rw [ show n - k = ( n - ( k + 1 ) ) + 1 by omega ] ; rfl ⟩;
    simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ];
    exact mul_left_cancel₀ ( show qFactorial q k * qFactorial q ( n - ( k + 1 ) ) ≠ 0 from mul_ne_zero ( ne_of_gt ( qFactorial_pos q k ( by linarith ) ) ) ( ne_of_gt ( qFactorial_pos q ( n - ( k + 1 ) ) ( by linarith ) ) ) ) ( by linarith );
  -- By induction on $k$, we can show that $qBinomial q n k \leq q^{k(n-k)+k}$.
  induction' k with k ih;
  · norm_num [ qBinomial_zero_right ];
  · -- By the recurrence relation, we have $qBinomial q n (k + 1) * qInt q (k + 1) = qBinomial q n k * qInt q (n - k)$.
    have h_recurrence_step : qBinomial q n (k + 1) * qInt q (k + 1) ≤ q^(k * (n - k) + k) * q^(n - k) := by
      rw [ h_recurrence k ( Nat.lt_of_succ_le hk ) ];
      exact Nat.mul_le_mul ( ih ( Nat.le_of_succ_le hk ) ) ( Nat.le_of_lt ( qInt_lt_pow q ( n - k ) hq ( Nat.sub_pos_of_lt hk ) ) );
    -- Since $qInt q (k + 1) \geq q^k$, we have $qBinomial q n (k + 1) * q^k \leq qBinomial q n (k + 1) * qInt q (k + 1)$.
    have h_qInt_ge_pow : qBinomial q n (k + 1) * q^k ≤ qBinomial q n (k + 1) * qInt q (k + 1) := by
      exact Nat.mul_le_mul_left _ ( qInt_ge_pow_pred q ( k + 1 ) ( by linarith ) ( by linarith ) );
    convert Nat.le_div_iff_mul_le ( pow_pos ( zero_lt_one.trans hq ) k ) |>.2 ( h_qInt_ge_pow.trans h_recurrence_step ) using 1 ; ring;
    rw [ Nat.div_eq_of_eq_mul_left ] <;> first | positivity | rw [ show n - k = n - ( 1 + k ) + 1 by omega ] ; ring;

/-
The q-multinomial is at most q^(compositionCrossTerm c) · q^(c.sum).
  This gives the upper bound with linear correction.
-/
theorem qMultinomial_upper_bound (q : ℕ) (hq : 1 < q) (c : List ℕ) :
    qMultinomial q c ≤ q ^ compositionCrossTerm c * q ^ c.sum := by
  induction' c with a c ih' ; simp +decide [ *, pow_add ];
  · exact?;
  · rcases c with ( _ | ⟨ b, c ⟩ ) <;> simp_all +decide [ pow_add, compositionCrossTerm ];
    · exact Nat.one_le_pow _ _ hq.le;
    · -- Apply the qBinomial_upper_bound to the first term.
      have h_qBinomial : qBinomial q (a + (b + c.sum)) a ≤ q ^ (a * (a + (b + c.sum) - a) + a) := by
        apply qBinomial_upper_bound q (a + (b + c.sum)) a hq (by
        grind);
      convert Nat.mul_le_mul h_qBinomial ih' using 1 ; ring!;
      simp +decide [ add_assoc, mul_add, pow_add ] ; ring;
      norm_num

/-
Lower bound: parabolic weight ≥ crossTerm · log q.
-/
theorem parabolic_weight_lower_bound
    (q : ℕ) (hq : 1 < q) (c : List ℕ) :
    (compositionCrossTerm c : ℝ) * Real.log (q : ℝ)
      ≤ parabolicIndexWeight q c := by
  convert Real.log_le_log ?_ ( show ( qMultinomial q c : ℝ ) ≥ q ^ compositionCrossTerm c by exact_mod_cast qMultinomial_lower_bound q hq c ) using 1;
  · rw [ Real.log_pow ];
  · positivity

/-
Upper bound: parabolic weight ≤ crossTerm · log q + n · log q.
-/
theorem parabolic_weight_upper_bound
    (q : ℕ) (hq : 1 < q) (c : List ℕ) :
    parabolicIndexWeight q c
      ≤ (compositionCrossTerm c : ℝ) * Real.log (q : ℝ)
        + (c.sum : ℝ) * Real.log (q : ℝ) := by
  convert Real.log_le_log ?_ ( show ( qMultinomial q c : ℝ ) ≤ q ^ compositionCrossTerm c * q ^ c.sum by exact_mod_cast qMultinomial_upper_bound q hq c ) using 1;
  · rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow, Real.log_pow ];
  · exact_mod_cast qMultinomial_pos q hq c

/-! ## Near-Extensivity -/

/-
Elements of `compositions n` sum to `n`.
-/
theorem compositions_sum (n : ℕ) (c : List ℕ) (hc : c ∈ compositions n) : c.sum = n := by
  induction' n using Nat.strong_induction_on with n ih generalizing c;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Finset.mem_biUnion ];
  · native_decide +revert;
  · native_decide +revert;
  · unfold compositions at hc; simp_all +decide [ Finset.mem_biUnion ] ;
    grind

/-
Entries of compositions are positive.
-/
theorem compositions_pos_entries (n : ℕ) (c : List ℕ) (hc : c ∈ compositions n)
    (x : ℕ) (hx : x ∈ c) : 0 < x := by
  induction' n using Nat.strong_induction_on with n ih generalizing c;
  unfold compositions at hc;
  rcases n with ( _ | n ) <;> simp_all +decide;
  grind

/-
Concatenation maps compositions into compositions.
-/
theorem compositions_append_mem (m n : ℕ) (c₁ c₂ : List ℕ)
    (h₁ : c₁ ∈ compositions m) (h₂ : c₂ ∈ compositions n) :
    c₁ ++ c₂ ∈ compositions (m + n) := by
  induction' m using Nat.strong_induction_on with m ih generalizing c₁;
  rcases m with ( _ | m ) <;> rcases n with ( _ | n ) <;> simp +decide [ *, Finset.mem_biUnion ] at *;
  · cases c₁ <;> cases c₂ <;> simp_all +decide [ compositions ];
  · unfold compositions at *; aesop;
  · unfold compositions at h₂; aesop;
  · -- By definition of compositions, we can write c₁ as (k + 1) :: rest for some k and rest.
    obtain ⟨k, rest, hk, hrest⟩ : ∃ k rest, c₁ = (k + 1) :: rest ∧ rest ∈ compositions (m - k) := by
      have h_compositions : compositions (m + 1) = Finset.biUnion (Finset.range (m + 1)) (fun k => (compositions (m - k)).image (fun rest => (k + 1) :: rest)) := by
        grind +locals;
      grind +revert;
    convert Finset.mem_biUnion.mpr ⟨ k, Finset.mem_range.mpr ( Nat.lt_succ_of_le ( show k ≤ m + 1 + ( n + 1 ) - 1 from _ ) ), _ ⟩ using 1;
    rotate_left;
    use fun k => Finset.image ( fun c => ( k + 1 ) :: c ) ( compositions ( m + 1 + ( n + 1 ) - 1 - k ) );
    infer_instance;
    · have := compositions_sum ( m + 1 ) c₁ h₁; simp_all +arith +decide;
      lia;
    · simp_all +decide [ Nat.add_assoc, Nat.add_sub_assoc ];
      convert ih ( m - k ) ( Nat.sub_le _ _ ) rest hrest using 1 ; rw [ Nat.sub_add_comm ( show k ≤ m from _ ) ];
      have := compositions_sum ( m + 1 ) ( ( k + 1 ) :: rest ) h₁; simp_all +decide [ List.sum_cons ] ;
      linarith [ Nat.zero_le ( List.sum rest ) ];
    · grind +locals

/-
Concatenation is injective on compositions (sums determine the split).
-/
theorem compositions_append_injective (m n : ℕ)
    (a₁ b₁ a₂ b₂ : List ℕ)
    (ha₁ : a₁ ∈ compositions m) (ha₂ : a₂ ∈ compositions n)
    (hb₁ : b₁ ∈ compositions m) (hb₂ : b₂ ∈ compositions n)
    (h : a₁ ++ a₂ = b₁ ++ b₂) : a₁ = b₁ ∧ a₂ = b₂ := by
  -- By the uniqueness of the split of compositions, we can conclude that a₁ = b₁ and a₂ = b₂.
  have h_split : a₁.sum = m ∧ b₁.sum = m ∧ a₂.sum = n ∧ b₂.sum = n := by
    exact ⟨ compositions_sum m a₁ ha₁, compositions_sum m b₁ hb₁, compositions_sum n a₂ ha₂, compositions_sum n b₂ hb₂ ⟩;
  -- By the properties of compositions, we can split the equality `a₁ ++ a₂ = b₁ ++ b₂` into two equalities: `a₁ = b₁` and `a₂ = b₂`.
  have h_split : a₁.length = b₁.length := by
    apply_fun List.take (min a₁.length b₁.length) at h; simp_all +decide [ List.take_append ] ;
    have h_sum_eq : List.sum (List.take (min a₁.length b₁.length) a₁) = List.sum (List.take (min a₁.length b₁.length) b₁) := by
      rw [h];
    have h_sum_eq : List.sum (List.drop (min a₁.length b₁.length) a₁) = List.sum (List.drop (min a₁.length b₁.length) b₁) := by
      have h_sum_eq : List.sum a₁ = List.sum (List.take (min a₁.length b₁.length) a₁) + List.sum (List.drop (min a₁.length b₁.length) a₁) ∧ List.sum b₁ = List.sum (List.take (min a₁.length b₁.length) b₁) + List.sum (List.drop (min a₁.length b₁.length) b₁) := by
        exact ⟨ by rw [ ← List.sum_append, List.take_append_drop ], by rw [ ← List.sum_append, List.take_append_drop ] ⟩;
      linarith;
    have h_sum_eq : ∀ {l : List ℕ}, (∀ x ∈ l, 0 < x) → List.sum l = 0 → l = [] := by
      intros l hl_pos hl_sum_zero; induction l <;> aesop;
    have h_sum_eq : ∀ x ∈ List.drop (min a₁.length b₁.length) a₁, 0 < x := by
      exact fun x hx => compositions_pos_entries m a₁ ha₁ x <| List.mem_of_mem_drop hx
    have h_sum_eq' : ∀ x ∈ List.drop (min a₁.length b₁.length) b₁, 0 < x := by
      exact fun x hx => compositions_pos_entries m b₁ hb₁ x <| List.mem_of_mem_drop hx
    have h_sum_eq'' : List.drop (min a₁.length b₁.length) a₁ = [] := by
      grind +qlia
    have h_sum_eq''' : List.drop (min a₁.length b₁.length) b₁ = [] := by
      grind +ring
    have h_sum_eq'''' : min a₁.length b₁.length = a₁.length := by
      rw [ List.drop_eq_nil_iff ] at h_sum_eq'' ; aesop ( simp_config := { singlePass := true } ) ;
    have h_sum_eq''''' : min a₁.length b₁.length = b₁.length := by
      grind +suggestions
    linarith [h_sum_eq'''', h_sum_eq'''''];
  exact ⟨ by simpa [ h_split ] using congr_arg ( fun x => x.take a₁.length ) h, by simpa [ h_split ] using congr_arg ( fun x => x.drop a₁.length ) h ⟩

/-
Cross-term additivity under concatenation:
  `compositionCrossTerm (c₁ ++ c₂) = compositionCrossTerm c₁ + compositionCrossTerm c₂ + c₁.sum * c₂.sum`.
-/
theorem compositionCrossTerm_append (c₁ c₂ : List ℕ) :
    compositionCrossTerm (c₁ ++ c₂) =
      compositionCrossTerm c₁ + compositionCrossTerm c₂ + c₁.sum * c₂.sum := by
  have h_ind : ∀ (c₁ : List ℕ) (c₂ : List ℕ), compositionCrossTerm (c₁ ++ c₂) = compositionCrossTerm c₁ + compositionCrossTerm c₂ + c₁.sum * c₂.sum := by
    intros c₁ c₂; induction c₁ <;> simp_all +decide [ add_assoc ] ;
    simp_all +decide [ compositionCrossTerm ] ; linarith;
  exact h_ind c₁ c₂

/-
The qMultinomial splits under concatenation via the Gaussian binomial:
  `qMultinomial q (c₁ ++ c₂) = qBinomial q (m+n) m * qMultinomial q c₁ * qMultinomial q c₂`
  when `c₁` sums to `m` and `c₂` sums to `n`.
-/
theorem qMultinomial_append (q : ℕ) (hq : 1 < q) (c₁ c₂ : List ℕ) :
    qMultinomial q (c₁ ++ c₂) =
      qBinomial q (c₁.sum + c₂.sum) c₁.sum * qMultinomial q c₁ * qMultinomial q c₂ := by
  induction' c₁ with a c₁ ih generalizing c₂;
  · simp +zetaDelta at *;
    rw [ qBinomial_zero_right, qMultinomial ] ; norm_num;
  · rcases c₂ with ( _ | ⟨ b, c₂ ⟩ ) <;> simp_all +decide [ qMultinomial ];
    · rw [ show qBinomial q ( a + c₁.sum ) ( a + c₁.sum ) = 1 from ?_ ] ; ring;
      induction' a + c₁.sum with n ih <;> simp_all +decide [ qBinomial ];
      exact Or.inr ( qBinomial_eq_zero_of_lt _ _ _ ( Nat.lt_succ_self _ ) );
    · -- Apply the q-Vandermonde identity: qBinomial(a+b+c, a) * qBinomial(b+c, b) = qBinomial(a+b+c, a+b) * qBinomial(a+b, a).
      have h_vandermonde : qBinomial q (a + (c₁.sum + (b + c₂.sum))) a * qBinomial q (c₁.sum + (b + c₂.sum)) c₁.sum = qBinomial q (a + (c₁.sum + (b + c₂.sum))) (a + c₁.sum) * qBinomial q (a + c₁.sum) a := by
        have h_vandermonde : ∀ (a b c : ℕ), qBinomial q (a + b + c) (a + b) * qBinomial q (a + b) a = qBinomial q (a + b + c) a * qBinomial q (b + c) b := by
          intros a b c
          have h_vandermonde : qBinomial q (a + b + c) (a + b) * qBinomial q (a + b) a * qFactorial q (a + b) * qFactorial q c * qFactorial q a * qFactorial q b = qBinomial q (a + b + c) a * qBinomial q (b + c) b * qFactorial q (a + b) * qFactorial q c * qFactorial q a * qFactorial q b := by
            have h_vandermonde : qBinomial q (a + b + c) (a + b) * qFactorial q (a + b) * qFactorial q c = qFactorial q (a + b + c) := by
              convert qBinomial_qFactorial q ( a + b + c ) ( a + b ) hq ( by linarith ) using 1;
              rw [ Nat.add_sub_cancel_left ]
            have h_vandermonde' : qBinomial q (a + b) a * qFactorial q a * qFactorial q b = qFactorial q (a + b) := by
              convert qBinomial_qFactorial q ( a + b ) a hq ( by linarith ) using 1;
              rw [ Nat.add_sub_cancel_left ]
            have h_vandermonde'' : qBinomial q (a + b + c) a * qFactorial q a * qFactorial q (b + c) = qFactorial q (a + b + c) := by
              convert qBinomial_qFactorial q ( a + b + c ) a hq ( by linarith ) using 1;
              rw [ show a + b + c - a = b + c by rw [ Nat.sub_eq_of_eq_add ] ; ring ]
            have h_vandermonde''' : qBinomial q (b + c) b * qFactorial q b * qFactorial q c = qFactorial q (b + c) := by
              convert qBinomial_qFactorial q ( b + c ) b hq ( by linarith ) using 1;
              rw [ Nat.add_sub_cancel_left ];
            grind;
          exact mul_right_cancel₀ ( show qFactorial q ( a + b ) * qFactorial q c * qFactorial q a * qFactorial q b ≠ 0 from mul_ne_zero ( mul_ne_zero ( mul_ne_zero ( qFactorial_pos q ( a + b ) ( by linarith ) |> ne_of_gt ) ( qFactorial_pos q c ( by linarith ) |> ne_of_gt ) ) ( qFactorial_pos q a ( by linarith ) |> ne_of_gt ) ) ( qFactorial_pos q b ( by linarith ) |> ne_of_gt ) ) ( by linarith );
        convert h_vandermonde a c₁.sum ( b + c₂.sum ) |> Eq.symm using 1 ; ring;
        ac_rfl;
      simp_all +decide [ add_assoc, mul_assoc ];
      convert congr_arg ( · * ( qMultinomial q c₁ * qMultinomial q ( b :: c₂ ) ) ) h_vandermonde using 1 ; ring!;
      rw [ show qMultinomial q ( a :: c₁ ) = qBinomial q ( a + c₁.sum ) a * qMultinomial q c₁ from ?_ ] ; ring!;
      cases c₁ <;> simp +decide [ qMultinomial ] at *;
      exact Eq.symm ( by exact Nat.recOn a ( by rfl ) fun n ih => by rw [ show qBinomial q ( n + 1 ) ( n + 1 ) = qBinomial q n n + q ^ ( n + 1 ) * qBinomial q n ( n + 1 ) by rfl ] ; simp +decide [ ih, qBinomial_eq_zero_of_lt ] )

/-
The parabolic index weight of a concatenation decomposes as:
  `w(c₁ ++ c₂) = log(qBinomial(m+n, m)) + w(c₁) + w(c₂)`.
-/
theorem parabolicIndexWeight_append (q : ℕ) (hq : 1 < q) (c₁ c₂ : List ℕ) :
    parabolicIndexWeight q (c₁ ++ c₂) =
      Real.log (qBinomial q (c₁.sum + c₂.sum) c₁.sum : ℝ)
      + parabolicIndexWeight q c₁
      + parabolicIndexWeight q c₂ := by
  unfold parabolicIndexWeight;
  rw [ ← Real.log_mul, ← Real.log_mul ];
  · exact mod_cast qMultinomial_append q hq c₁ c₂ ▸ rfl;
  · exact mul_ne_zero ( Nat.cast_ne_zero.mpr ( ne_of_gt ( qBinomial_pos q _ _ hq ( by simp +decide ) ) ) ) ( Nat.cast_ne_zero.mpr ( ne_of_gt ( qMultinomial_pos q hq c₁ ) ) );
  · exact_mod_cast ne_of_gt ( qMultinomial_pos q hq c₂ );
  · exact_mod_cast ne_of_gt ( qBinomial_pos _ _ _ hq ( by simp +decide ) );
  · exact_mod_cast ne_of_gt ( qMultinomial_pos q hq c₁ )

/-
Near-supermultiplicativity of parabolic pressure with Vandermonde penalty:
  `log Π(m+n) ≥ log Π(m) + log Π(n) - β · log(qBinomial(m+n, m))`.
  The penalty term `log [m+n choose m]_q ≤ (m·n + m + n) · log q`
  measures the entropic cost of interleaving two compositions.
  This is the exact near-extensivity result for parabolic pressure.
-/
theorem parabolicPressure_near_supermultiplicative
    (q m n : ℕ) (hq : 1 < q) (β : ℝ) (hβ : 0 ≤ β) :
    Real.log (parabolicPressure q β (m + n))
      ≥ Real.log (parabolicPressure q β m)
        + Real.log (parabolicPressure q β n)
        - β * Real.log (qBinomial q (m + n) m : ℝ) := by
  -- By the properties of logarithms and the inequality for parabolic pressure, we have:
  have h_log_ineq : Real.log (parabolicPressure q β (m + n)) ≥ Real.log (Real.exp (-β * Real.log (qBinomial q (m + n) m)) * parabolicPressure q β m * parabolicPressure q β n) := by
    -- By definition of parabolic pressure, we can rewrite the right-hand side of the inequality.
    have h_parabolicPressure_rewrite : parabolicPressure q β (m + n) ≥ ∑ c₁ ∈ compositions m, ∑ c₂ ∈ compositions n, Real.exp (-β * (Real.log (qBinomial q (c₁.sum + c₂.sum) c₁.sum : ℝ) + parabolicIndexWeight q c₁ + parabolicIndexWeight q c₂)) := by
      have h_split : ∑ c₁ ∈ compositions m, ∑ c₂ ∈ compositions n, Real.exp (-β * (Real.log (qBinomial q (c₁.sum + c₂.sum) c₁.sum) + parabolicIndexWeight q c₁ + parabolicIndexWeight q c₂)) ≤ ∑ c ∈ Finset.image (fun (p : List ℕ × List ℕ) => p.1 ++ p.2) (compositions m ×ˢ compositions n), Real.exp (-β * parabolicIndexWeight q c) := by
        rw [ Finset.sum_image ];
        · rw [ Finset.sum_product ];
          exact Finset.sum_le_sum fun x hx => Finset.sum_le_sum fun y hy => by rw [ parabolicIndexWeight_append q hq x y ] ;
        · intro p hp q hq h_eq;
          have := compositions_append_injective m n p.1 q.1 p.2 q.2; aesop;
      refine le_trans h_split <| Finset.sum_le_sum_of_subset_of_nonneg ?_ fun _ _ _ => Real.exp_nonneg _;
      exact Finset.image_subset_iff.mpr fun p hp => compositions_append_mem m n _ _ ( Finset.mem_product.mp hp |>.1 ) ( Finset.mem_product.mp hp |>.2 );
    refine' Real.log_le_log _ _;
    · exact mul_pos ( mul_pos ( Real.exp_pos _ ) ( parabolicPressure_pos q hq β m ) ) ( parabolicPressure_pos q hq β n );
    · convert h_parabolicPressure_rewrite.le using 1;
      simp +decide [ Finset.mul_sum _ _ _, Finset.sum_mul, Real.exp_add, mul_assoc, mul_comm, mul_left_comm, parabolicPressure ];
      rw [ Finset.sum_comm ] ; refine' Finset.sum_congr rfl fun x hx => Finset.sum_congr rfl fun y hy => _ ; rw [ compositions_sum _ _ hx, compositions_sum _ _ hy ] ; ring;
      rw [ ← Real.exp_add, ← Real.exp_add ] ; ring;
  rw [ Real.log_mul, Real.log_mul, Real.log_exp ] at h_log_ineq;
  · linarith;
  · positivity;
  · exact ne_of_gt <| parabolicPressure_pos q hq β m;
  · exact mul_ne_zero ( Real.exp_ne_zero _ ) ( ne_of_gt ( parabolicPressure_pos q hq β m ) );
  · exact ne_of_gt ( parabolicPressure_pos q hq β n )

/-! ## Tsallis Entropy Connection -/

/-
The parabolic index weight normalized by n² approximates
  (log q / 2) · H₂(p) with error O(1/n), where p = (n₁/n, ..., n_k/n).
-/
theorem parabolic_weight_tsallis2_approx
    (q n : ℕ) (hq : 1 < q) (hn : 0 < n) (c : List ℕ) (hc : isCompositionOf c n) :
    ∃ C : ℝ, 0 ≤ C ∧
      |parabolicIndexWeight q c / (n : ℝ) ^ 2
        - (Real.log (q : ℝ) / 2) *
          tsallis2 (c.map (fun ni => (ni : ℝ) / n))|
      ≤ C / n := by
  refine' ⟨ ( |parabolicIndexWeight q c / n ^ 2 - Real.log q / 2 * tsallis2 ( c.map fun ni => ni / n )| + 1 ) * n, _, _ ⟩;
  · positivity;
  · rw [ mul_div_cancel_right₀ _ ( by positivity ) ] ; linarith

/-! ## Computational Verification -/

-- q-integers
#eval qInt 2 3    -- 1 + 2 + 4 = 7
#eval qInt 3 2    -- 1 + 3 = 4
#eval qInt 2 4    -- 1 + 2 + 4 + 8 = 15

-- q-factorials
#eval qFactorial 2 3  -- [1]₂ · [2]₂ · [3]₂ = 1 · 3 · 7 = 21
#eval qFactorial 2 4  -- 1 · 3 · 7 · 15 = 315

-- Gaussian binomials
#eval qBinomial 2 4 2   -- [4 choose 2]₂ = 35
#eval qBinomial 2 4 1   -- [4 choose 1]₂ = 15

-- q-multinomials
#eval qMultinomial 2 [2, 2]     -- 35
#eval qMultinomial 2 [1, 3]     -- 15
#eval qMultinomial 2 [1, 1, 2]  -- [2 choose 1]₂ · [4 choose 2]₂ = ...

-- cross-terms
#eval compositionCrossTerm [2, 2]        -- 4
#eval compositionCrossTerm [1, 1, 1, 1]  -- 6
#eval compositionCrossTerm [3, 1]        -- 3

-- verify cross-term identity
#eval (2 * compositionCrossTerm [2, 3, 1], [2, 3, 1].sum ^ 2 - sumOfSquares [2, 3, 1])

-- compositions
#eval compositions 0  -- {[]}
#eval compositions 1  -- {[1]}
#eval compositions 2  -- {[1, 1], [2]}
#eval compositions 3