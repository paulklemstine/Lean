import Mathlib

/-!
# A dyadic Diophantine compiler for a ReLU network

This file connects binary Diophantine approximation with neural-network execution.
At depth `n`, the network state is the integer `⌊2^n π⌋`. Its transition bias is
the next binary digit of π, and its readout divides by `2^n`.

Unlike a claim based only on the number of linear pieces, the resulting theorem
records the arithmetic restriction on parameters: every hidden weight is `2` and
every hidden bias is a bit (`0` or `1`).
-/

namespace ReLUPi

/-- The scalar rectified linear unit. -/
def relu (x : ℝ) : ℝ := max x 0

/-- The integer represented by the first `n` binary places of `π`. -/
noncomputable def piPrefix (n : ℕ) : ℤ := ⌊(2 : ℝ) ^ n * Real.pi⌋

/-- The bias at layer `n`; arithmetically, this is the next binary digit of `π`. -/
noncomputable def piBit (n : ℕ) : ℤ := piPrefix (n + 1) - 2 * piPrefix n

/-- Hidden state of a width-one ReLU network. Every layer has weight `2` and
bias equal to one binary digit of `π`. -/
noncomputable def hiddenState : ℕ → ℝ
  | 0 => 3
  | n + 1 => relu (2 * hiddenState n + (piBit n : ℝ))

/-- Linear readout from the depth-`n` hidden state. -/
noncomputable def piApprox (n : ℕ) : ℝ := hiddenState n / (2 : ℝ) ^ n

lemma piPrefix_zero : piPrefix 0 = 3 := by
  simp only [piPrefix, pow_zero, one_mul]
  rw [Int.floor_eq_iff]
  constructor
  · exact le_of_lt Real.pi_gt_three
  · norm_num
    exact Real.pi_lt_four

lemma piPrefix_nonneg (n : ℕ) : 0 ≤ piPrefix n := by
  exact Int.floor_nonneg.2 ( mul_nonneg ( by positivity ) Real.pi_pos.le )

/-
The floor transition really contributes only a binary digit.
-/
theorem piBit_is_binary (n : ℕ) : piBit n = 0 ∨ piBit n = 1 := by
  unfold piBit piPrefix;
  ring_nf at *;
  norm_num [ sub_eq_iff_eq_add', Int.floor_eq_iff ];
  exact Classical.or_iff_not_imp_left.2 fun h => ⟨ le_of_not_gt fun h' => h ⟨ Int.floor_le _, h' ⟩, by linarith [ Int.lt_floor_add_one ( Real.pi * 2 ^ n ) ] ⟩

/-
Exact compiler correctness: the neural state equals the dyadic numerator.
-/
theorem hiddenState_eq_prefix (n : ℕ) : hiddenState n = (piPrefix n : ℝ) := by
  induction' n with n ih;
  · norm_num [ piPrefix_zero, hiddenState ];
  · -- By definition of `hiddenState`, we have:
    have h_hiddenState_succ : hiddenState (n + 1) = max (2 * hiddenState n + (piBit n : ℝ)) 0 := by
      rfl;
    simp_all +decide [ piBit ];
    exact piPrefix_nonneg _

/-
The central bridge theorem. A width-one, depth-`n` ReLU computation with
binary biases produces a dyadic approximation from below, with error less than
`2⁻ⁿ`. Irrationality of `π` makes the lower inequality strict.
-/
theorem relu_pi_diophantine_bridge (n : ℕ) :
    0 < Real.pi - piApprox n ∧
      Real.pi - piApprox n < 1 / (2 : ℝ) ^ n := by
  rw [ show piApprox n = ( piPrefix n : ℝ ) / ( 2 : ℝ ) ^ n by rw [ piApprox, hiddenState_eq_prefix ] ];
  rw [ sub_div' ];
  · rw [ lt_div_iff₀, div_lt_div_iff_of_pos_right ] <;> norm_num;
    exact ⟨ lt_of_le_of_ne ( by rw [ mul_comm ] ; exact Int.floor_le _ ) fun h => irrational_pi <| ⟨ ↑ ( piPrefix n ) / 2 ^ n, by push_cast; rw [ h, mul_div_cancel_right₀ _ ( by positivity ) ] ⟩, sub_lt_iff_lt_add'.mpr <| by rw [ mul_comm ] ; exact Int.lt_floor_add_one _ ⟩;
  · positivity

/-
Consequently every positive error tolerance is met at some depth.
-/
theorem exists_depth_piApprox (ε : ℝ) (hε : 0 < ε) :
    ∃ n : ℕ, |piApprox n - Real.pi| < ε := by
  -- Use `exists_pow_lt` with `a = 1 / 2` and `b = ε` to find `n` such that `(1 / 2) ^ n < ε`.
  have h_pow_lt : ∃ n : ℕ, (1 / 2 : ℝ) ^ n < ε := by
    exact exists_pow_lt_of_lt_one hε one_half_lt_one;
  exact h_pow_lt.imp fun n hn => by rw [ abs_sub_comm, abs_of_nonneg ( by linarith [ relu_pi_diophantine_bridge n ] ) ] ; exact lt_of_lt_of_le ( relu_pi_diophantine_bridge n |>.2 ) ( by simpa using hn.le ) ;

end ReLUPi