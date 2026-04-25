import Mathlib

/-! # Tropical–Neural Network Bridge

New theorems formalizing the connection between tropical algebra and neural networks.
ReLU networks compute piecewise-linear functions, which are precisely the functions
expressible as differences of tropical polynomials. This file establishes key
theoretical foundations.

## Main Results

- `relu_max_form`: ReLU(x) = max(0, x)
- `relu_lipschitz`: ReLU is 1-Lipschitz
- `relu_idempotent`: ReLU(ReLU(x)) = ReLU(x)
- `relu_homogeneous`: ReLU(c·x) = c·ReLU(x) for c ≥ 0
- `max_as_relu`: max(a,b) = b + ReLU(a - b)
- `tropical_add_comm/assoc`: max is commutative and associative (tropical addition)
- `softplus_bounds`: Softplus approximation bounds
- `composition_lipschitz_bridge`: Composition of Lipschitz functions bound
-/

noncomputable section

open Real

/-- The ReLU (Rectified Linear Unit) function. -/
def relu (x : ℝ) : ℝ := max 0 x

/-- ReLU(x) = max(0, x). -/
@[simp] theorem relu_eq_max (x : ℝ) : relu x = max 0 x := rfl

/-- ReLU(x) ≥ 0. -/
theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_left 0 x

/-- ReLU(x) ≥ x. -/
theorem relu_ge (x : ℝ) : x ≤ relu x := le_max_right 0 x

/-- ReLU(0) = 0. -/
@[simp] theorem relu_zero : relu 0 = 0 := by simp [relu]

/-- ReLU is idempotent: ReLU(ReLU(x)) = ReLU(x). -/
theorem relu_idempotent (x : ℝ) : relu (relu x) = relu x := by
  simp [relu]

/-
ReLU is positively homogeneous: ReLU(c·x) = c·ReLU(x) for c ≥ 0.
-/
theorem relu_pos_homogeneous (c x : ℝ) (hc : 0 ≤ c) :
    relu (c * x) = c * relu x := by
  unfold relu;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) ( c * x ) <;> nlinarith

/-
max(a, b) = b + ReLU(a - b) — expressing max via ReLU.
-/
theorem max_as_relu (a b : ℝ) : max a b = b + relu (a - b) := by
  cases max_cases a b <;> cases max_cases 0 ( a - b ) <;> linarith!

/-
ReLU is 1-Lipschitz: |ReLU(x) - ReLU(y)| ≤ |x - y|.
-/
theorem relu_lipschitz (x y : ℝ) : |relu x - relu y| ≤ |x - y| := by
  unfold relu;
  cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( max 0 x - max 0 y ) <;> linarith

/-
Composition of Lipschitz functions: if f is L₁-Lipschitz and g is L₂-Lipschitz,
    then f ∘ g is (L₁ · L₂)-Lipschitz.
-/
theorem composition_lipschitz_bridge {f g : ℝ → ℝ} {L₁ L₂ : ℝ}
    (hf : ∀ x y, |f x - f y| ≤ L₁ * |x - y|)
    (hg : ∀ x y, |g x - g y| ≤ L₂ * |x - y|)
    (hL₁ : 0 ≤ L₁) :
    ∀ x y, |f (g x) - f (g y)| ≤ L₁ * L₂ * |x - y| := by
  exact fun x y => le_trans ( hf _ _ ) ( by rw [ mul_assoc ] ; exact mul_le_mul_of_nonneg_left ( hg _ _ ) hL₁ )

/-- The softplus function: softplus(x) = ln(1 + e^x). -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-
softplus(x) > 0 for all x.
-/
theorem softplus_pos (x : ℝ) : 0 < softplus x := by
  exact Real.log_pos ( by linarith [ Real.exp_pos x ] )

/-
softplus(x) ≥ ReLU(x).
-/
theorem softplus_ge_relu (x : ℝ) : relu x ≤ softplus x := by
  unfold relu softplus;
  cases max_cases ( 0 : ℝ ) x <;> simp +decide [ * ];
  · exact Real.log_nonneg ( by linarith [ Real.exp_pos x ] );
  · rw [ Real.le_log_iff_exp_le ] <;> linarith [ Real.exp_pos x ]

/-
softplus(x) ≤ ReLU(x) + ln(2).
-/
theorem softplus_le_relu_add_log2 (x : ℝ) :
    softplus x ≤ relu x + Real.log 2 := by
  unfold softplus relu;
  rw [ Real.log_le_iff_le_exp ];
  · cases max_cases ( 0 : ℝ ) x <;> simp +decide [ *, Real.exp_add, Real.exp_log ];
    · linarith [ Real.exp_le_one_iff.2 ( by linarith : x ≤ 0 ) ];
    · linarith [ Real.add_one_le_exp x ];
  · positivity

/-- Tropical addition (max) is commutative. -/
theorem trop_add_comm (a b : ℝ) : max a b = max b a := max_comm a b

/-- Tropical addition (max) is associative. -/
theorem trop_add_assoc (a b c : ℝ) : max (max a b) c = max a (max b c) :=
  max_assoc a b c

/-
Tropical multiplication (addition) distributes over tropical addition (max):
    a + max(b, c) = max(a + b, a + c).
-/
theorem trop_mul_dist (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  cases max_cases b c <;> cases max_cases ( a + b ) ( a + c ) <;> linarith

/-- LogSumExp is the smooth approximation of max. -/
def logSumExp (a b : ℝ) : ℝ := Real.log (Real.exp a + Real.exp b)

/-
LogSumExp ≥ max.
-/
theorem lse_ge_max (a b : ℝ) : max a b ≤ logSumExp a b := by
  unfold logSumExp;
  cases max_cases a b <;> linarith [ Real.log_exp a, Real.log_exp b, Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_pos a, Real.exp_pos b ] : Real.exp a ≤ Real.exp a + Real.exp b ), Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_pos a, Real.exp_pos b ] : Real.exp b ≤ Real.exp a + Real.exp b ) ]

/-
LogSumExp ≤ max + ln(2).
-/
theorem lse_le_max_log2 (a b : ℝ) : logSumExp a b ≤ max a b + Real.log 2 := by
  rw [ logSumExp, ← Real.log_exp ( max a b ) ];
  rw [ ← Real.log_mul ( by positivity ) ( by positivity ) ] ; gcongr;
  cases max_cases a b <;> linarith [ Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ]

/-- LogSumExp is commutative. -/
theorem lse_comm (a b : ℝ) : logSumExp a b = logSumExp b a := by
  unfold logSumExp; ring_nf

end