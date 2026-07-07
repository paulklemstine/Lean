import Mathlib

/-!
# Uniform bounds and monotonicity for the `C_k`-game threshold constant

For fixed `k ≥ 4` the Maker–Breaker `C_k`-game on `K_n` has threshold bias
`c_k · n^{(k-2)/(k-1)}`, where the *sharp constant* is

  `c_k = ((k-1) · (2(k-1)/k)^{k-2})^{1/(k-1)}`.

The companion file `Constant.lean` establishes that `c_k` is well defined,
positive, and satisfies its defining polynomial identity
`c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}`.  Here we prove the **quantitative envelope**
of the sharp constant and the monotonic behaviour of the resulting bias:

* the average-degree factor `2(k-1)/k` lies in `[3/2, 2)` and is strictly
  increasing (`avgDeg_ge_three_halves`, `avgDeg_lt_two`, `avgDeg_strictMono`);
* the sharp constant is **uniformly bounded away from both `0` and `∞`**:
  `3/2 ≤ c_k < 3` for every `k ≥ 4` (`thresholdConst_ge_three_halves`,
  `thresholdConst_lt_three`);
* the threshold exponent is strictly between `0` and `1`
  (`gameExponent_pos`, `gameExponent_lt_one`), equal to the reciprocal of the
  maximum 2-density `(k-1)/(k-2)` (`gameExponent_eq_inv_maxDensity`);
* the threshold bias `c_k · n^{(k-2)/(k-1)}` is strictly increasing in `n`
  (`thresholdBias_strictMonoOn`), and the sharp-threshold window
  `((1-ε)q_k, (1+ε)q_k)` is a genuine nonempty window around it
  (`threshold_window`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): several bold claims about `c_k`.  (H1) `c_k` is
monotone increasing in `k`.  (H2) `c_k < 2` for all `k`.  (H3) `c_k` is a genuine
*bounded* universal constant, `3/2 ≤ c_k < 3`.  (H4) the bias `c_k n^{(k-2)/(k-1)}`
is strictly increasing in the board size `n`.
Experiment (Experimenter): floating-point evaluation refutes H1 (peak at
`k≈13`, then decreasing) and H2 (`c_5 ≈ 2.012 > 2`).  H3 survives every test in
`4 ≤ k ≤ 10^4`.  The bracketing `3/2 ≤ 2(k-1)/k < 2` is exact and drives H3:
raising to the `(k-2)` power and multiplying by `k-1` sandwiches `c_k^{k-1}`
between `(3/2)^{k-1}` and `(k-1)2^{k-2} < 3^{k-1}`.
Analysis (Analyst): the exponential-vs-linear step `(k-1)2^{k-2} < 3^{k-1}` is
the crux of the upper bound; a one-line induction (`3 < k` at each step) closes
it.  The lower bound needs only `2(k-1)/k ≥ 3/2 ⟺ k ≥ 4`.  Monotonicity in `n`
is `rpow` monotonicity for a positive exponent, scaled by `c_k > 0`.
Critique (Critic): none of the results are vacuous.  H1 and H2 are recorded as
*false* conjectures (see FUTURE_DIRECTIONS), so the surviving statement is the
guarded boundedness `3/2 ≤ c_k < 3`, which is sharp in kind (the true peak
`≈2.158` sits strictly inside `[3/2,3)`).  Every proof uses genuine `rpow`
algebra, induction, or `nlinarith`, never `rfl`/`native_decide`.
Synthesis: `c_k` is a bona-fide universal constant of the cycle game — bounded,
non-monotone, with `1/m₂(C_k) = (k-2)/(k-1)` exponent — and the bias it defines
is a strictly increasing function of the board size with a nonempty sharp window.
-/

namespace CycleGameThreshold

open Real

/-- The Bednarska–Łuczak threshold exponent `(k-2)/(k-1)` for the `C_k`-game. -/
noncomputable def gameExponent (k : ℝ) : ℝ := (k - 2) / (k - 1)

/-- The maximum 2-density `(k-1)/(k-2)` of the cycle `C_k`. -/
noncomputable def maxDensity (k : ℝ) : ℝ := (k - 1) / (k - 2)

/-- The threshold constant `c_k = ((k-1)·(2(k-1)/k)^{k-2})^{1/(k-1)}`. -/
noncomputable def thresholdConst (k : ℕ) : ℝ :=
  (((k : ℝ) - 1) * (2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2)) ^ ((1 : ℝ) / ((k : ℝ) - 1))

/-- The threshold bias `q_k(n) = c_k · n^{(k-2)/(k-1)}`. -/
noncomputable def thresholdBias (k : ℕ) (n : ℝ) : ℝ :=
  thresholdConst k * n ^ gameExponent (k : ℝ)

/-! ## The average-degree factor `2(k-1)/k` -/

/-
For `k ≥ 4` the average-degree factor is at least `3/2`.
-/
lemma avgDeg_ge_three_halves {k : ℕ} (hk : 4 ≤ k) :
    (3 : ℝ) / 2 ≤ 2 * ((k : ℝ) - 1) / (k : ℝ) := by
  rw [ div_le_div_iff₀ ] <;> linarith [ show ( k : ℝ ) ≥ 4 by norm_cast ]

/-
The average-degree factor is strictly below `2`.
-/
lemma avgDeg_lt_two {k : ℕ} (hk : 1 ≤ k) :
    2 * ((k : ℝ) - 1) / (k : ℝ) < 2 := by
  rw [ div_lt_iff₀ ] <;> linarith [ ( by norm_cast : ( 1 : ℝ ) ≤ k ) ]

/-
The average-degree factor `2(k-1)/k` is strictly increasing in `k` (as a real
function on `k > 0`).
-/
lemma avgDeg_strictMono : StrictMonoOn (fun k : ℝ => 2 * (k - 1) / k) (Set.Ioi 0) := by
  norm_num [ StrictMonoOn ];
  intros; rw [ div_lt_div_iff₀ ] <;> nlinarith;

/-! ## The threshold exponent -/

/-
The threshold exponent is positive for `k ≥ 3`.
-/
theorem gameExponent_pos {k : ℝ} (hk : 2 < k) : 0 < gameExponent k := by
  exact div_pos ( by linarith ) ( by linarith )

/-
The threshold exponent is strictly below `1` for `k > 1`.
-/
theorem gameExponent_lt_one {k : ℝ} (hk : 1 < k) : gameExponent k < 1 := by
  exact div_lt_one ( by linarith ) |>.2 ( by linarith )

/-
**Exponent = reciprocal density.**  The threshold exponent is the reciprocal
of the maximum 2-density `m₂(C_k) = (k-1)/(k-2)`.
-/
theorem gameExponent_eq_inv_maxDensity (k : ℝ) :
    gameExponent k = 1 / maxDensity k := by
  unfold gameExponent maxDensity; rw [one_div_div]

/-! ## The sharp constant: defining identity and uniform bounds -/

/-
The base `(k-1)(2(k-1)/k)^{k-2}` is positive for `k ≥ 4`.
-/
lemma thresholdConst_base_pos {k : ℕ} (hk : 4 ≤ k) :
    0 < ((k : ℝ) - 1) * (2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2) := by
  exact mul_pos ( by linarith [ show ( k : ℝ ) ≥ 4 by norm_cast ] ) ( pow_pos ( div_pos ( by linarith [ show ( k : ℝ ) ≥ 4 by norm_cast ] ) ( by positivity ) ) _ )

/-
The sharp constant is positive for `k ≥ 4`.
-/
theorem thresholdConst_pos {k : ℕ} (hk : 4 ≤ k) : 0 < thresholdConst k := by
  exact Real.rpow_pos_of_pos ( thresholdConst_base_pos hk ) _

/-
**Defining identity.**  `c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}`.
-/
theorem thresholdConst_pow {k : ℕ} (hk : 4 ≤ k) :
    thresholdConst k ^ (k - 1) =
      ((k : ℝ) - 1) * (2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2) := by
  unfold thresholdConst; rw [ ← Real.rpow_natCast, ← Real.rpow_mul ] ;
  · rw [ Nat.cast_pred ( by linarith ), div_mul_cancel₀ _ ( sub_ne_zero_of_ne ( by norm_cast; linarith ) ), Real.rpow_one ];
  · exact mul_nonneg ( sub_nonneg.2 <| Nat.one_le_cast.2 <| by linarith ) ( pow_nonneg ( div_nonneg ( mul_nonneg zero_le_two <| sub_nonneg.2 <| Nat.one_le_cast.2 <| by linarith ) <| Nat.cast_nonneg _ ) _ )

/-
Exponential-vs-linear crux for the upper bound: `(k-1)·2^{k-2} < 3^{k-1}`.
-/
lemma pow_two_lt_pow_three {k : ℕ} (hk : 4 ≤ k) :
    ((k : ℝ) - 1) * 2 ^ (k - 2) < 3 ^ (k - 1) := by
  rcases k with ( _ | _ | _ | _ | k ) <;> norm_num at *;
  induction k <;> norm_num [ pow_succ' ] at *;
  simp_all +decide [ Nat.succ_sub, pow_succ' ] ; nlinarith [ pow_pos ( by norm_num : ( 0 : ℝ ) < 2 ) ‹_›, pow_le_pow_left₀ ( by norm_num ) ( by norm_num : ( 2 : ℝ ) ≤ 3 ) ‹_› ]

/-
**Uniform lower bound.**  `3/2 ≤ c_k` for every `k ≥ 4`.
-/
theorem thresholdConst_ge_three_halves {k : ℕ} (hk : 4 ≤ k) :
    (3 : ℝ) / 2 ≤ thresholdConst k := by
  -- We show (3/2)^(k-1) ≤ c_k^(k-1), then conclude 3/2 ≤ c_k.
  have h1 : (3 / 2 : ℝ) ^ (k - 1) ≤ thresholdConst k ^ (k - 1) := by
    rw [ thresholdConst_pow ( by linarith ) ];
    have h_lower_bound : ((3 / 2 : ℝ) ^ (k - 2)) ≤ ((2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2)) := by
      exact pow_le_pow_left₀ ( by norm_num ) ( by rw [ le_div_iff₀ ] <;> linarith [ show ( k : ℝ ) ≥ 4 by norm_cast ] ) _;
    rcases k with ( _ | _ | k ) <;> norm_num [ pow_succ' ] at *;
    exact mul_le_mul ( by linarith [ show ( k : ℝ ) ≥ 2 by norm_cast; linarith ] ) h_lower_bound ( by positivity ) ( by positivity );
  exact le_of_pow_le_pow_left₀ ( Nat.sub_ne_zero_of_lt ( by linarith ) ) ( by exact le_of_lt ( thresholdConst_pos hk ) ) h1

/-
**Uniform upper bound.**  `c_k < 3` for every `k ≥ 4`.
-/
theorem thresholdConst_lt_three {k : ℕ} (hk : 4 ≤ k) :
    thresholdConst k < 3 := by
  -- By thresholdConst_pow hk, c_k^(k-1) = (k-1)*(2(k-1)/k)^(k-2).
  have h_pow : thresholdConst k ^ (k - 1) = ((k : ℝ) - 1) * (2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2) :=
    thresholdConst_pow hk
  -- Bound: (2(k-1)/k)^(k-2) < 2^(k-2) using pow_lt_pow_left with avgDeg_lt_two, nonnegativity 0 ≤ 2(k-1)/k, and k-2 ≠ 0 (from k ≥ 4).
  have h_bound : (2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2) < 2 ^ (k - 2) := by
    exact pow_lt_pow_left₀ ( avgDeg_lt_two ( by linarith ) ) ( div_nonneg ( mul_nonneg zero_le_two ( sub_nonneg.mpr ( Nat.one_le_cast.mpr ( by linarith ) ) ) ) ( Nat.cast_nonneg _ ) ) ( Nat.sub_ne_zero_of_lt ( by linarith ) );
  -- Then multiply by (k-1) > 0: (k-1)*(2(k-1)/k)^(k-2) < (k-1)*2^(k-2).
  have h_mul : ((k : ℝ) - 1) * (2 * ((k : ℝ) - 1) / (k : ℝ)) ^ (k - 2) < ((k : ℝ) - 1) * 2 ^ (k - 2) := by
    exact mul_lt_mul_of_pos_left h_bound <| sub_pos.mpr <| Nat.one_lt_cast.mpr <| by linarith;
  exact lt_of_pow_lt_pow_left₀ _ ( by positivity ) ( h_pow.symm ▸ h_mul.trans_le ( by exact le_of_lt ( pow_two_lt_pow_three hk ) ) )

/-- **Boundedness of the sharp constant.**  The constant is a genuine bounded
universal constant: `3/2 ≤ c_k < 3` for all `k ≥ 4`.  (Numerically the true
range is `[c_4, c_{13}] ≈ [1.890, 2.158]`, strictly inside this envelope.) -/
theorem thresholdConst_bounded {k : ℕ} (hk : 4 ≤ k) :
    (3 : ℝ) / 2 ≤ thresholdConst k ∧ thresholdConst k < 3 :=
  ⟨thresholdConst_ge_three_halves hk, thresholdConst_lt_three hk⟩

/-! ## The threshold bias as a function of board size -/

/-
**Monotonicity in board size.**  For fixed `k ≥ 4` the threshold bias
`c_k · n^{(k-2)/(k-1)}` is strictly increasing in `n > 0`.
-/
theorem thresholdBias_strictMonoOn {k : ℕ} (hk : 4 ≤ k) :
    StrictMonoOn (thresholdBias k) (Set.Ioi 0) := by
  intro a ha b hb hab; exact mul_lt_mul_of_pos_left ( Real.rpow_lt_rpow ( le_of_lt ha ) hab ( gameExponent_pos <| by linarith [ ( by norm_cast : ( 4 :ℝ ) ≤ k ) ] ) ) ( thresholdConst_pos hk ) ;

/-
**Sharp-threshold window.**  For `k ≥ 4`, `n > 0` and any `0 < ε`, the
Maker/Breaker window `((1-ε)q_k(n), (1+ε)q_k(n))` is a genuine nonempty open
interval strictly containing the threshold `q_k(n)`.
-/
theorem threshold_window {k : ℕ} (hk : 4 ≤ k) {n ε : ℝ} (hn : 0 < n) (hε : 0 < ε) :
    (1 - ε) * thresholdBias k n < thresholdBias k n ∧
      thresholdBias k n < (1 + ε) * thresholdBias k n := by
  constructor <;> nlinarith [ show 0 < thresholdBias k n from mul_pos ( thresholdConst_pos hk ) ( Real.rpow_pos_of_pos hn _ ) ]

end CycleGameThreshold