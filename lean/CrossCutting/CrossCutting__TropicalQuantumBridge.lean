import Mathlib

/-!
# The Tropical–Quantum Bridge via ε-Interpolation

The LogSumExp function `LSE_ε(x, y) = ε · ln(exp(x/ε) + exp(y/ε))` provides a smooth
interpolation between tropical (max-plus) algebra and classical arithmetic:
- As ε → 0⁺, LSE_ε(x, y) → max(x, y) (tropical regime)
- For large ε, LSE_ε(x, y) ≈ (x+y)/2 + ε·ln(2) (classical averaging)

This file formalizes key properties of this interpolation, establishing it as a
rigorous bridge between the tropical and quantum/classical worlds.

## Main Results

- `logsumexp_ge_max`: LSE_ε(x, y) ≥ max(x, y) for all ε > 0
- `logsumexp_le_max_add`: LSE_ε(x, y) ≤ max(x, y) + ε · ln 2
- `logsumexp_symmetric`: LSE_ε(x, y) = LSE_ε(y, x)
- `logsumexp_diagonal`: LSE_ε(x, x) = x + ε · ln 2
- `softmax_sum_one`: Softmax probabilities sum to 1
- `tropical_add_assoc`: max is associative (tropical addition)
- `tropical_mul_distrib`: + distributes over max (tropical multiplication over addition)

## Cross-Cutting Significance

This bridge connects:
- **Tropical geometry** (algebraic geometry over max-plus) ↔ **Classical algebraic geometry**
- **ReLU networks** (piecewise linear) ↔ **Smooth networks** (via softmax)
- **Viterbi decoding** (max) ↔ **Forward algorithm** (sum) in HMMs
- **Quantum mechanics** (path integrals, ℏ → 0) ↔ **Classical mechanics** (least action)
-/

noncomputable section
open Real BigOperators Finset

/-! ## LogSumExp Function and Basic Properties -/

/-- The LogSumExp function with temperature parameter ε > 0.
    Interpolates between max (as ε → 0⁺) and average (as ε → ∞). -/
def logsumexp (ε : ℝ) (x y : ℝ) : ℝ :=
  ε * Real.log (Real.exp (x / ε) + Real.exp (y / ε))

/-
LogSumExp is symmetric.
-/
theorem logsumexp_symmetric (ε : ℝ) (x y : ℝ) :
    logsumexp ε x y = logsumexp ε y x := by
  unfold logsumexp;
  rw [ add_comm ]

/-
On the diagonal, LogSumExp gives x + ε · ln 2.
-/
theorem logsumexp_diagonal (ε : ℝ) (hε : 0 < ε) (x : ℝ) :
    logsumexp ε x x = x + ε * Real.log 2 := by
  unfold logsumexp;
  ring;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
  nlinarith [ mul_inv_cancel_left₀ hε.ne' x ]

/-
LogSumExp is at least the maximum of its arguments.
-/
theorem logsumexp_ge_max (ε : ℝ) (hε : 0 < ε) (x y : ℝ) :
    max x y ≤ logsumexp ε x y := by
  unfold logsumexp;
  cases max_cases x y <;> nlinarith [ Real.log_exp ( x / ε ), Real.log_exp ( y / ε ), Real.log_le_log ( by positivity ) ( show Real.exp ( x / ε ) + Real.exp ( y / ε ) ≥ Real.exp ( x / ε ) by linarith [ Real.exp_pos ( x / ε ), Real.exp_pos ( y / ε ) ] ), Real.log_le_log ( by positivity ) ( show Real.exp ( x / ε ) + Real.exp ( y / ε ) ≥ Real.exp ( y / ε ) by linarith [ Real.exp_pos ( x / ε ), Real.exp_pos ( y / ε ) ] ), mul_div_cancel₀ x hε.ne.symm, mul_div_cancel₀ y hε.ne.symm ]

/-
LogSumExp is at most max + ε · ln 2. Combined with the lower bound,
    this shows LSE_ε converges to max as ε → 0⁺.
-/
theorem logsumexp_le_max_add (ε : ℝ) (hε : 0 < ε) (x y : ℝ) :
    logsumexp ε x y ≤ max x y + ε * Real.log 2 := by
  refine' le_trans ( mul_le_mul_of_nonneg_left ( Real.log_le_log _ _ ) hε.le ) _;
  exact 2 * Real.exp ( Max.max x y / ε );
  · positivity;
  · exact le_trans ( add_le_add ( Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( le_max_left _ _ ) hε.le ) ) ( Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( le_max_right _ _ ) hε.le ) ) ) ( by ring_nf; norm_num );
  · rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring_nf ; norm_num [ hε.ne' ];
    cases max_cases x y <;> [ left; right ] <;> nlinarith [ mul_inv_cancel_left₀ hε.ne' ( max x y ) ]

/-! ## Tropical Semiring Axioms -/

/-
Tropical addition (max) is commutative.
-/
theorem tropical_add_comm (x y : ℝ) : max x y = max y x := by
  exact max_comm x y

/-
Tropical addition (max) is associative.
-/
theorem tropical_add_assoc (x y z : ℝ) : max (max x y) z = max x (max y z) := by
  exact max_assoc _ _ _

/-
Tropical addition (max) is idempotent.
-/
theorem tropical_add_idempotent (x : ℝ) : max x x = x := by
  norm_num

/-
Tropical multiplication (+) distributes over tropical addition (max).
-/
theorem tropical_mul_distrib (a x y : ℝ) : a + max x y = max (a + x) (a + y) := by
  rw [ max_def, max_def ] ; split_ifs <;> linarith

/-
Tropical multiplication (+) distributes over tropical addition (max), right version.
-/
theorem tropical_mul_distrib_right (x y a : ℝ) : max x y + a = max (x + a) (y + a) := by
  grind

/-! ## Softmax and Probability -/

/-- Softmax of two values. -/
def softmax2_fst (ε : ℝ) (x y : ℝ) : ℝ :=
  Real.exp (x / ε) / (Real.exp (x / ε) + Real.exp (y / ε))

def softmax2_snd (ε : ℝ) (x y : ℝ) : ℝ :=
  Real.exp (y / ε) / (Real.exp (x / ε) + Real.exp (y / ε))

/-
Softmax probabilities sum to 1.
-/
theorem softmax2_sum_one (ε : ℝ) (hε : 0 < ε) (x y : ℝ) :
    softmax2_fst ε x y + softmax2_snd ε x y = 1 := by
  unfold softmax2_fst softmax2_snd; rw [ ← add_div, div_eq_iff ] <;> first | positivity | ring;

/-
Softmax first component is non-negative.
-/
theorem softmax2_fst_nonneg (ε : ℝ) (hε : 0 < ε) (x y : ℝ) :
    0 ≤ softmax2_fst ε x y := by
  exact div_nonneg ( Real.exp_nonneg _ ) ( add_nonneg ( Real.exp_nonneg _ ) ( Real.exp_nonneg _ ) )

/-
Softmax first component is at most 1.
-/
theorem softmax2_fst_le_one (ε : ℝ) (hε : 0 < ε) (x y : ℝ) :
    softmax2_fst ε x y ≤ 1 := by
  exact div_le_one_of_le₀ ( le_add_of_nonneg_right ( Real.exp_nonneg _ ) ) ( by positivity )

/-! ## Connections: LogSumExp as Smooth Max -/

/-
The exponential function is positive. Helper for LogSumExp proofs.
-/
theorem exp_sum_pos (x y : ℝ) : 0 < Real.exp x + Real.exp y := by
  positivity

/-
LogSumExp is monotone in its first argument.
-/
theorem logsumexp_mono_left (ε : ℝ) (hε : 0 < ε) (y : ℝ) :
    Monotone (fun x => logsumexp ε x y) := by
  refine' fun x x' h ↦ mul_le_mul_of_nonneg_left ( Real.log_le_log _ _ ) hε.le;
  · positivity;
  · gcongr

end