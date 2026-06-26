import Mathlib

/-!
# Generalized Gawron–Miska–Ulas unboundedness for arbitrary integer bases

For integers `b ≥ 2` and `m ≥ 1` let `T_{b,m}(n)` be the coefficient of `xⁿ` in the
formal power series `∏_{i=0}^{∞} (1 - x^{bⁱ})^m`, equivalently in the finite product
`∏_{i=0}^{n} (1 - x^{bⁱ})^m` (the extra factors only affect coefficients of degree
`≥ b^{n+1} > n`).

The **Gawron–Miska–Ulas conjecture** asserts that for every `b ≥ 2` and `m ≥ 2`
the sequence `n ↦ T_{b,m}(n)` is unbounded in absolute value.  The original paper
proves the case `b = 2` (all `m`).

This file proves the conjecture for **`m = 2` and every base `b ≥ 2`**, a slice
complementary to the published `b = 2` result.  The engine is:

* `factor_succ` — a **Mahler-type functional equation** for the truncated products:
  `Tpoly b m (N+1) = (1 - X)^m * expand b (Tpoly b m N)`.
* `coeff_eq_of_le` — the **finite = infinite equivalence**: the coefficient of `xⁿ`
  is the same in every truncation `∏_{i=0}^{N}` with `N ≥ n`.
* `T_repunit` — the closed form `T_{b,2}(R_k) = (−2)^k` at the base-`b` repunits
  `R_k = 1 + b + … + b^{k-1}`.
* `T_two_unbounded` — unboundedness for `m = 2`, every `b ≥ 2`.

-- !-- Lab Notes — Team loop -- !--
-- !-- Hypothesis (Hypothesizer): the in-range maxima of `T_{b,2}` sit at base-b
--     repunits R_k, with |T_{b,2}(R_k)| = 2^k. (5 conjectures tried; this and the
--     m=1 boundedness contrast were the survivors.) -- !--
-- !-- Experiment (Experimenter): computed T_{b,2}(R_k) for b=2..7, k=0..6; got
--     exactly (-2)^k every time. Mechanism: Mahler equation + (1-X)^2 = 1-2X+X^2
--     kills the j=0 and j=2 terms at n = b*R_k + 1, leaving T(R_{k+1}) = -2 T(R_k). -- !--
-- !-- Analysis (Analyst): the b=2 paper proof is 2-regular-sequence heavy; the
--     repunit identity is base-uniform and *elementary*, so it formalizes for all b.
--     The general m conjecture is "true but hard": the repunit trick gives only the
--     m=2 column because for m≥3 the (1-X)^m has interior binomial coefficients that
--     do not vanish at the repunit residues. -- !--
-- !-- Critique (Critic): unboundedness is a genuine ∀B∃n statement (not native_decide);
--     proof uses induction + the functional equation, not definitional unfolding.
--     m=1 is bounded, so the m≥2 hypothesis is load-bearing and honestly reflected. -- !--
-/

namespace GawronMiskaUlas

open Polynomial Finset

/-- The truncated product `∏_{i=0}^{N} (1 - x^{bⁱ})^m` as a polynomial over `ℤ`. -/
noncomputable def Tpoly (b m N : ℕ) : ℤ[X] :=
  ∏ i ∈ Finset.range (N + 1), (1 - X ^ (b ^ i)) ^ m

/-- `T_{b,m}(n)` = coefficient of `xⁿ` in `∏_{i=0}^{n} (1 - x^{bⁱ})^m`. -/
noncomputable def T (b m n : ℕ) : ℤ := (Tpoly b m n).coeff n

/-- Each factor transforms under `expand b` (i.e. `x ↦ x^b`) by shifting its index. -/
lemma expand_factor (b m i : ℕ) :
    (expand ℤ b) ((1 - X ^ (b ^ i)) ^ m) = (1 - X ^ (b ^ (i + 1))) ^ m := by
  rw [map_pow, map_sub, map_one, map_pow, expand_X, ← pow_mul, pow_succ']

/-
**Mahler-type functional equation** for the truncated products:
`Q_{N+1}(x) = (1 - x)^m · Q_N(x^b)`.
-/
lemma factor_succ (b m N : ℕ) :
    Tpoly b m (N + 1) = (1 - X) ^ m * (expand ℤ b) (Tpoly b m N) := by
  unfold Tpoly
  rw [Finset.prod_range_succ']
  norm_num [pow_succ', pow_mul]
  ring

/-- `(1 - x^e)^m = expand e ((1-x)^m)`: it is a polynomial in `x^e`. -/
lemma one_sub_Xpow_pow_eq_expand (m e : ℕ) :
    ((1 - X ^ e) ^ m : ℤ[X]) = (expand ℤ e) ((1 - X) ^ m) := by
  rw [map_pow, map_sub, map_one, expand_X]

/-
Multiplying by `(1 - x^e)^m` does not change coefficients in degrees `< e`.
-/
lemma coeff_mul_one_sub_Xpow_pow (p : ℤ[X]) (m e n : ℕ) (he : 0 < e) (h : n < e) :
    (p * (1 - X ^ e) ^ m).coeff n = p.coeff n := by
  rw [ Polynomial.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk ];
  rw [ Finset.sum_eq_single n ] <;> simp_all +decide [ Polynomial.coeff_zero_eq_eval_zero ];
  · norm_num [ he.ne' ];
  · rw [ one_sub_Xpow_pow_eq_expand ];
    intro b hb₁ hb₂; rw [ Polynomial.coeff_expand ] ;
    · exact Or.inr ( if_neg ( Nat.not_dvd_of_pos_of_lt ( Nat.sub_pos_of_lt ( lt_of_le_of_ne hb₁ hb₂ ) ) ( Nat.lt_of_le_of_lt ( Nat.sub_le _ _ ) h ) ) );
    · linarith

/-
One truncation step does not change the coefficient at degree `n ≤ N`.
-/
lemma coeff_stable_step (b m n N : ℕ) (hb : 2 ≤ b) (h : n ≤ N) :
    (Tpoly b m (N + 1)).coeff n = (Tpoly b m N).coeff n := by
  convert Tpoly b m N |> fun p => coeff_mul_one_sub_Xpow_pow p m ( b ^ ( N + 1 ) ) n ?_ ?_ using 1;
  · unfold Tpoly; simp +decide [ Finset.prod_range_succ ] ;
  · positivity;
  · -- Using the inequalities $N < 2^N$ and $2^N \leq b^N$, we get $n \leq N < 2^N \leq b^N \leq b^{N+1}$.
    have h_ineq : n ≤ N ∧ N < 2^N ∧ 2^N ≤ b^N ∧ b^N ≤ b^(N+1) := by
      exact ⟨ h, Nat.recOn N ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ], Nat.pow_le_pow_left hb _, pow_le_pow_right₀ ( by linarith ) ( by linarith ) ⟩
    linarith [h_ineq]

/-
**Finite = infinite equivalence**: the coefficient of `xⁿ` is the same in every
truncation `∏_{i=0}^{N}` with `N ≥ n`.
-/
lemma coeff_eq_of_le (b m n N : ℕ) (hb : 2 ≤ b) (h : n ≤ N) :
    (Tpoly b m N).coeff n = T b m n := by
  induction' N using Nat.strong_induction_on with N ih generalizing n;
  rcases N with ( _ | N ) <;> simp_all +decide [ T ];
  cases h <;> simp_all +decide [ coeff_stable_step ]

/-- The base-`b` repunits `R_k = 1 + b + … + b^{k-1}` (so `R_{k+1} = b·R_k + 1`). -/
def R (b : ℕ) : ℕ → ℕ
  | 0 => 0
  | k + 1 => b * R b k + 1

/-
The recurrence at repunits for `m = 2`: `T_{b,2}(R_{k+1}) = -2 · T_{b,2}(R_k)`.
-/
lemma T_repunit_step (b k : ℕ) (hb : 2 ≤ b) :
    T b 2 (R b (k + 1)) = -2 * T b 2 (R b k) := by
  rw [ show R b ( k + 1 ) = b * R b k + 1 from rfl ];
  have h_coeff : (Tpoly b 2 (b * R b k + 1)).coeff (b * R b k + 1) = -2 * (Tpoly b 2 (b * R b k)).coeff (R b k) := by
    rw [ factor_succ ];
    norm_num [ sub_sq, mul_assoc, Polynomial.coeff_one, Polynomial.coeff_X ];
    norm_num [ add_mul, sub_mul, mul_assoc, Polynomial.coeff_X_pow ];
    rw [ Polynomial.coeff_mul, Finset.sum_eq_single ( 0, b * R b k + 1 ) ] <;> norm_num;
    · rw [ Polynomial.coeff_expand, Polynomial.coeff_expand ];
      · norm_num [ Nat.dvd_add_right, Nat.mul_div_cancel_left _ ( by linarith : 0 < b ) ];
        aesop;
      · linarith;
      · linarith;
    · intros; rw [ Polynomial.coeff_expand ] ;
      · split_ifs <;> simp_all +decide [ Nat.dvd_iff_mod_eq_zero ];
        have := congr_arg ( · % b ) ‹2 + _ = b * R b k + 1›; norm_num [ Nat.add_mod, Nat.mul_mod, ‹_ % b = 0› ] at this; rcases b with ( _ | _ | _ | b ) <;> simp_all +arith +decide [ Nat.mod_eq_of_lt ] ;
      · linarith;
  rw [ ← coeff_eq_of_le b 2 ( R b k ) ( b * R b k ) hb ( by nlinarith ), ← coeff_eq_of_le b 2 ( b * R b k + 1 ) ( b * R b k + 1 ) hb ( by nlinarith ), h_coeff ]

/-
Base value `T_{b,2}(0) = 1`.
-/
lemma T_two_zero (b : ℕ) : T b 2 0 = 1 := by
  unfold T;
  unfold Tpoly; norm_num [ Polynomial.coeff_zero_eq_eval_zero ] ;

/-
**Closed form**: `T_{b,2}(R_k) = (−2)^k` for every base `b ≥ 2`.
-/
lemma T_repunit (b k : ℕ) (hb : 2 ≤ b) : T b 2 (R b k) = (-2) ^ k := by
  induction' k with k ih;
  · exact T_two_zero b;
  · convert T_repunit_step b k hb using 1 ; rw [ ih ] ; ring

/-- The absolute value at a repunit is `2^k`. -/
lemma abs_T_repunit (b k : ℕ) (hb : 2 ≤ b) : |T b 2 (R b k)| = 2 ^ k := by
  rw [T_repunit b k hb, abs_pow]
  norm_num

/-
**Generalized Gawron–Miska–Ulas unboundedness for `m = 2`, every base `b ≥ 2`.**
For every bound `B` there is an `n` with `|T_{b,2}(n)| > B`.
-/
theorem T_two_unbounded (b : ℕ) (hb : 2 ≤ b) (B : ℤ) :
    ∃ n, B < |T b 2 n| := by
  -- Choose k such that B < 2^k.
  obtain ⟨k, hk⟩ : ∃ k, B < (2 : ℤ) ^ k := by
    exact pow_unbounded_of_one_lt B one_lt_two;
  exact ⟨ R b k, by rw [ abs_T_repunit b k hb ] ; exact hk ⟩

/-- Equivalent phrasing: no uniform bound exists for `T_{b,2}`. -/
theorem T_two_not_bounded (b : ℕ) (hb : 2 ≤ b) :
    ¬ ∃ B : ℤ, ∀ n, |T b 2 n| ≤ B := by
  rintro ⟨B, hB⟩
  obtain ⟨n, hn⟩ := T_two_unbounded b hb B
  exact absurd (hB n) (not_le.mpr hn)

end GawronMiskaUlas