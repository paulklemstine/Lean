/-
# Cramér's Random Model for Prime Gaps

This file formalizes the deterministic side of Cramér's probabilistic model:
- The Cramér weight function `1 / log m` for integers `m ≥ 2`.
- The expected number of "model primes" in an interval.
- Rigorous upper and lower bounds on these expectations via monotonicity of log.
- The formal statement of Cramér's conjecture.

These are certified arithmetic inequalities, not probabilistic handwaving.
-/
import Mathlib
import Speculative.NumberTheory.PrimeGapFramework

open Nat Real

/-! ## Cramér weight function -/

/-- The Cramér weight: probability of being "prime-like" in the random model.
For `m ≥ 2`, this is `1 / log m`; otherwise 0. -/
noncomputable def cramerWeight (m : ℕ) : ℝ :=
  if (2 : ℕ) ≤ m then 1 / Real.log (m : ℝ) else 0

/-- The expected number of model-primes in the interval `[N, N+H]`. -/
noncomputable def expectedPrimeLikesInInterval (N H : ℕ) : ℝ :=
  ∑ m ∈ Finset.Icc N (N + H), cramerWeight m

/-! ## Auxiliary logarithm lemmas -/

theorem log_pos_of_two_le {m : ℕ} (hm : 2 ≤ m) : 0 < Real.log (m : ℝ) := by
  exact Real.log_pos <| Nat.one_lt_cast.mpr hm

theorem log_mono_nat {a b : ℕ} (ha : 2 ≤ a) (hab : a ≤ b) :
    Real.log (a : ℝ) ≤ Real.log (b : ℝ) := by
  -- Apply the fact that the logarithm function is strictly increasing.
  apply Real.log_le_log; exact_mod_cast by linarith; ; exact_mod_cast by linarith;

theorem cramerWeight_nonneg (m : ℕ) : 0 ≤ cramerWeight m := by
  unfold cramerWeight;
  positivity <;> first | positivity | exact one_div_nonneg_of_nonneg ( Real.log_nonneg ( by norm_cast; linarith ) )

theorem cramerWeight_pos_of_two_le {m : ℕ} (hm : 2 ≤ m) : 0 < cramerWeight m := by
  exact div_pos zero_lt_one ( log_pos_of_two_le hm ) |> fun h => by unfold cramerWeight; split_ifs ; linarith;

/-! ## Interval expectation bounds

These are the key deterministic estimates: the expected number of model-primes
in `[N, N+H]` is sandwiched between `(H+1)/log(N+H)` and `(H+1)/log(N)`.
This uses monotonicity of `1/log` on `[2, ∞)`. -/

/-
Upper bound: each weight is at most `1/log N`, and there are `H+1` terms.
-/
theorem expectedPrimeLikes_interval_upper (N H : ℕ) (hN : 3 ≤ N) :
    expectedPrimeLikesInInterval N H ≤ ((H + 1 : ℕ) : ℝ) / Real.log (N : ℝ) := by
  refine' le_trans ( Finset.sum_le_sum fun i hi => show cramerWeight i ≤ 1 / Real.log N from _ ) _;
  · unfold cramerWeight;
    split_ifs <;> [ exact one_div_le_one_div_of_le ( Real.log_pos <| by norm_cast ; linarith ) ( Real.log_le_log ( by positivity ) <| by norm_cast ; linarith [ Finset.mem_Icc.mp hi ] ) ; exact one_div_nonneg.mpr <| Real.log_nonneg <| by norm_cast ; linarith ];
  · norm_num [ div_eq_mul_inv ];
    rw [ Nat.cast_sub ] <;> push_cast <;> linarith

/-
Lower bound: each weight is at least `1/log(N+H)`, and there are `H+1` terms.
-/
theorem expectedPrimeLikes_interval_lower (N H : ℕ) (hN : 3 ≤ N) :
    ((H + 1 : ℕ) : ℝ) / Real.log ((N + H : ℕ) : ℝ) ≤ expectedPrimeLikesInInterval N H := by
  have h_cramerWeight_lower : ∀ m ∈ Finset.Icc N (N + H), cramerWeight m ≥ 1 / Real.log (N + H) := by
    intro m hm;
    unfold cramerWeight;
    split_ifs <;> norm_num at *;
    · exact inv_anti₀ ( Real.log_pos <| by norm_cast ) ( Real.log_le_log ( by positivity ) <| by norm_cast; linarith );
    · linarith;
  convert Finset.sum_le_sum h_cramerWeight_lower using 1 ; norm_num;
  rw [ Nat.cast_sub ] <;> push_cast <;> ring ; linarith

/-! ## Cramér's Conjecture: formal statement -/

/-- Cramér's conjecture (next-prime-after version): prime gaps are `O((log n)²)`.
This is stated as a definition (a `Prop`), not a theorem — it is an open problem. -/
def CramerConjecture : Prop :=
  ∃ C : ℝ, ∃ N₀ : ℕ, 0 < C ∧
    ∀ n ≥ N₀, (primeGapAfter n : ℝ) ≤ C * (Real.log (n : ℝ))^2

/-! ## Normalized gap observable -/

/-- The log-compressed prime gap observable: `gap(n) / (log n)²`.
This is the quantity that Cramér's conjecture asserts is bounded. -/
noncomputable def normalizedGap (n : ℕ) : ℝ :=
  if 2 ≤ n then (primeGapAfter n : ℝ) / (Real.log (n : ℝ))^2 else 0

/-
Cramér's conjecture is equivalent to `normalizedGap` being eventually bounded.
-/
theorem cramerConjecture_iff_normalizedGap_bounded :
    CramerConjecture ↔
      ∃ C : ℝ, ∃ N₀ : ℕ, 0 < C ∧ ∀ n ≥ N₀, normalizedGap n ≤ C := by
  constructor;
  · rintro ⟨ C, N₀, hC, h ⟩;
    -- Let's choose $N₀' = \max(N₀, 2)$.
    use C, max N₀ 2;
    simp_all +decide [ normalizedGap ];
    exact fun n hn hn' => div_le_iff₀ ( sq_pos_of_pos ( Real.log_pos ( Nat.one_lt_cast.mpr hn' ) ) ) |>.2 ( h n hn );
  · rintro ⟨ C, N₀, hC, h ⟩;
    refine' ⟨ C, N₀ + 2, hC, fun n hn => _ ⟩;
    have := h n ( by linarith );
    unfold normalizedGap at this;
    rw [ if_pos ( by linarith ), div_le_iff₀ ] at this <;> nlinarith [ show 0 < Real.log n from Real.log_pos <| Nat.one_lt_cast.mpr <| by linarith ]

/-! ## Bertrand implies a weak form: gaps are O(n), hence normalizedGap is O(n/(log n)²) -/

/-
The certified unconditional bound: prime gaps grow at most linearly.
This is `primeGapAfter_le_self` restated in the asymptotic language.
-/
theorem prime_gap_linear_bound :
    ∃ C : ℝ, ∃ N₀ : ℕ, 0 < C ∧
      ∀ n ≥ N₀, (primeGapAfter n : ℝ) ≤ C * (n : ℝ) := by
  exact ⟨ 1, 1, by norm_num, fun n hn => by rw [ one_mul ] ; exact_mod_cast ( primeGapAfter_le_self n hn ) ⟩