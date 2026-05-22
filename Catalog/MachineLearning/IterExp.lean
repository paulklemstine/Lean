import Mathlib

/-!
# Iterated Exponentials: Derivative Theory

This file develops the derivative theory of iterated exponentials, establishing that
derivative growth is a semantic shadow of compositional depth.

## Main Definitions

- `iterExp k x`: the k-fold iterated exponential, `exp^[k](x)`
- `depthMajorant d M`: the tower bound `iterExp d M`
- `iterExpDerivProd k x`: the closed-form derivative `∏ i < k, iterExp (i+1) x`

## Main Results

- `iterExp_hasDerivAt`: closed-form derivative formula for iterExp
- `iterExp_deriv_lower_bound_at_one`: derivative of `iterExp (k+1)` at 1 is ≥ `iterExp (k+1) 1`
- `exp_sq_le`: key inequality `t² ≤ exp(t)` for `t ≥ 0`
- `iterExp_ge_self`: `iterExp k M ≥ M` for `M ≥ 0`

These results form the analytic foundation for depth separation via derivative obstruction.
-/

noncomputable section
open Real Finset

/-! ## Core Definitions -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (k+1) x = exp(iterExp k x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-- The depth majorant: the tower bound for derivative growth at depth `d` with
    subexpression bound `M`. This is simply `iterExp d M`. -/
def depthMajorant (d : ℕ) (M : ℝ) : ℝ := iterExp d M

/-- The closed-form derivative of `iterExp k` at point `x`:
    the product `∏ i ∈ range k, iterExp (i+1) x`. -/
def iterExpDerivProd (k : ℕ) (x : ℝ) : ℝ :=
  ∏ i ∈ Finset.range k, iterExp (i + 1) x

/-! ## Basic Properties of iterExp -/

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl
@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

theorem iterExp_pos (k : ℕ) (hk : 0 < k) (x : ℝ) : 0 < iterExp k x := by
  cases k with
  | zero => omega
  | succ n => simp [iterExp_succ]; exact Real.exp_pos _

theorem iterExp_one_le (k : ℕ) : 1 ≤ iterExp k 1 := by
  induction k with
  | zero => simp
  | succ n ih =>
    simp [iterExp_succ]
    linarith [Real.add_one_le_exp (iterExp n 1)]

theorem iterExp_nonneg (k : ℕ) (x : ℝ) (hx : 0 ≤ x) : 0 ≤ iterExp k x := by
  induction k with
  | zero => exact hx
  | succ n _ih => simp; exact le_of_lt (Real.exp_pos _)

/-- `iterExp k M ≥ M` for `M ≥ 0` and any `k`. -/
theorem iterExp_ge_self (k : ℕ) (M : ℝ) (hM : 0 ≤ M) : M ≤ iterExp k M := by
  induction k with
  | zero => simp
  | succ n ih =>
    simp
    calc M ≤ iterExp n M := ih
    _ ≤ Real.exp (iterExp n M) := by linarith [Real.add_one_le_exp (iterExp n M)]

/-- `depthMajorant d M ≥ 0` when `M ≥ 0`. -/
theorem depthMajorant_nonneg (d : ℕ) {M : ℝ} (hM : 0 ≤ M) :
    0 ≤ depthMajorant d M := by
  exact iterExp_nonneg d M hM

/-
Monotonicity: `depthMajorant` is monotone in the depth parameter.
-/
theorem depthMajorant_mono_depth (d₁ d₂ : ℕ) (hd : d₁ ≤ d₂) (M : ℝ) (_hM : 0 ≤ M) :
    depthMajorant d₁ M ≤ depthMajorant d₂ M := by
  -- By induction on $d_2 - d_1$.
  have h_ind : ∀ {d₁ d₂ : ℕ} (h : d₁ ≤ d₂), ∀ M : ℝ, iterExp d₁ M ≤ iterExp d₂ M := by
    intro d₁ d₂ hd M; induction hd <;> simp_all +decide [ iterExp ] ;
    exact le_trans ‹_› ( le_trans ( by norm_num ) ( Real.add_one_le_exp _ ) );
  exact h_ind hd M

/-! ## Key Inequality: exp(t) ≥ t² for t ≥ 0 -/

/-
The fundamental inequality: `exp(t) ≥ t²` for `t ≥ 0`.
    This is the engine that converts multiplicative derivative accumulation
    into tower-bounded growth.
-/
theorem exp_sq_le (t : ℝ) (ht : 0 ≤ t) : t ^ 2 ≤ Real.exp t := by
  -- Use the Taylor series expansion of the exponential function: $e^t = 1 + t + \frac{t^2}{2!} + \frac{t^3}{3!} + \cdots$.
  have h_taylor : ∀ t : ℝ, 0 ≤ t → Real.exp t = ∑' n : ℕ, (t ^ n) / (Nat.factorial n) := by
    norm_num [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ];
  -- Use the Taylor series expansion to bound $e^t$ from below.
  have h_bound : ∀ t : ℝ, 0 ≤ t → Real.exp t ≥ 1 + t + t^2 / 2 + t^3 / 6 := by
    intro t ht; rw [ h_taylor t ht ] ; refine' le_trans _ ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by exact Real.summable_pow_div_factorial _ ) ) ; norm_num [ Finset.sum_range_succ, Nat.factorial ] ;
  nlinarith [ sq_nonneg ( t - 1 ), h_bound t ht ]

/-
Consequence: `a * b ≤ exp(b)` when `0 ≤ a ≤ b`.
-/
theorem mul_le_exp_of_le (a b : ℝ) (ha : 0 ≤ a) (hab : a ≤ b) :
    a * b ≤ Real.exp b := by
  nlinarith [ exp_sq_le b ( by linarith ) ]

/-! ## Differentiability -/

/-- `iterExp k` is differentiable for every `k`. -/
theorem iterExp_differentiable (k : ℕ) : Differentiable ℝ (iterExp k) := by
  induction k with
  | zero => exact differentiable_id
  | succ n ih => exact ih.exp

/-! ## Derivative Formula -/

/-- **Core theorem**: The derivative of `iterExp k` at `x` equals the product
    `∏ i ∈ range k, iterExp (i+1) x`.

    This is the closed-form expression that makes derivative growth analysis possible:
    the derivative is a product of all intermediate tower levels.

    Proof by induction using the chain rule for `exp`. -/
theorem iterExp_hasDerivAt (k : ℕ) (x : ℝ) :
    HasDerivAt (iterExp k) (iterExpDerivProd k x) x := by
  induction k with
  | zero =>
    simp [iterExpDerivProd, iterExp]
    exact hasDerivAt_id x
  | succ n ih =>
    have h := ih.exp
    show HasDerivAt (fun y => Real.exp (iterExp n y)) _ x
    convert h using 1
    simp only [iterExpDerivProd, Finset.prod_range_succ, iterExp_succ]
    ring

/-- The derivative of `iterExp k` equals `iterExpDerivProd k`. -/
theorem iterExp_deriv (k : ℕ) (x : ℝ) :
    deriv (iterExp k) x = iterExpDerivProd k x :=
  (iterExp_hasDerivAt k x).deriv

/-- Recursive formula for the derivative of `iterExp (k+1)`. -/
theorem iterExp_deriv_succ (k : ℕ) (x : ℝ) :
    deriv (iterExp (k + 1)) x =
      iterExp (k + 1) x * deriv (iterExp k) x := by
  rw [iterExp_deriv, iterExp_deriv]
  simp only [iterExpDerivProd, Finset.prod_range_succ, iterExp_succ]
  ring

/-! ## Derivative Positivity -/

/-
The derivative product is positive for `x > 0`.
-/
theorem iterExpDerivProd_pos (k : ℕ) (x : ℝ) (_hx : 0 < x) :
    0 < iterExpDerivProd k x := by
  exact Finset.prod_pos fun i hi => iterExp_pos _ ( Nat.succ_pos _ ) _

/-
The derivative of `iterExp k` is nonneg on `[0,1]`.
-/
theorem iterExp_deriv_nonneg (k : ℕ) (x : ℝ) (hx : 0 ≤ x) :
    0 ≤ deriv (iterExp k) x := by
  exact iterExp_deriv k x ▸ Finset.prod_nonneg fun i hi => iterExp_nonneg ( i + 1 ) x hx

/-! ## Lower Bound at x = 1 -/

/-- Each factor in the derivative product at `x = 1` is ≥ 1. -/
theorem iterExp_at_one_ge_one (j : ℕ) : 1 ≤ iterExp j 1 := iterExp_one_le j

/-
**Key lower bound**: The derivative of `iterExp (k+1)` at `x = 1`
    is at least `iterExp (k+1) 1`.

    This witnesses the near-sharpness of the depth majorant bound:
    the derivative is at least as large as the top tower level.

    Proof: the derivative product at 1 contains `iterExp (k+1) 1` as a factor,
    and all other factors are ≥ 1.
-/
theorem iterExp_deriv_lower_bound_at_one (k : ℕ) :
    iterExp (k + 1) 1 ≤ deriv (iterExp (k + 1)) 1 := by
  rw [ iterExp_deriv ];
  unfold iterExpDerivProd;
  rw [ Finset.prod_range_succ ];
  exact le_mul_of_one_le_left ( by exact le_trans zero_le_one ( iterExp_one_le _ ) ) ( le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by positivity ) fun _ _ => iterExp_one_le _ ) )

/-
The depth majorant at depth `k` and base `1` is a lower bound
    for the derivative of the next tower level at `x = 1`.
-/
theorem depthMajorant_le_deriv_iterExp_succ_at_one (k : ℕ) :
    depthMajorant k 1 ≤ deriv (iterExp (k + 1)) 1 := by
  -- By `iterExp_ge_self`, we have `iterExp k 1 ≤ iterExp (k + 1) 1`
  have h_ge : iterExp k 1 ≤ iterExp (k + 1) 1 := by
    exact le_trans ( by aesop ) ( Real.add_one_le_exp _ );
  exact h_ge.trans ( by simpa only [ depthMajorant ] using iterExp_deriv_lower_bound_at_one k )

end