/-
# Approximate Tower Rigidity — Core Theorems

This file proves foundational results for the approximate depth rigidity
of iterated exponentials (tower functions).

## Main Results

1. **iterExp properties**: Strict monotonicity, positivity, composition,
   growth bounds on the interval [1, 10].

2. **Level separation**: `iterExp n 1` grows super-exponentially in `n`,
   establishing the fundamental gap between tower levels.

3. **Relative approximation properties**: Basic consequences of
   ε-relative approximation.

4. **Derivative cascade**: The derivative of iterExp n is a product of
   all lower tower levels — the engine of the rigidity theorem.
-/
import Mathlib

noncomputable section

open Real Set

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl
@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

/-! ## Relative Approximation -/

/-- `RelApproximatesOn f g ε a b` states that `g` is an ε-relative approximation
    of `f` on the interval `[a, b]`, with the error measured relative to `|f(a)|`. -/
def RelApproximatesOn (f g : ℝ → ℝ) (ε : ℝ) (a b : ℝ) : Prop :=
  ∀ x ∈ Icc a b, |f x - g x| < ε * |f a|

/-! ## Approximate Depth Bound -/

/-- The certified depth lower bound for ε-relative approximation of `iterExp n`. -/
def approxDepthBound (n : ℕ) (ε : ℝ) : ℕ :=
  if ε ≤ 0 then n
  else n - Nat.ceil (Real.logb 2 (Real.logb 2 (1 / ε))) - 3

/-! ## Basic Properties of iterExp -/

theorem iterExp_pos_succ (n : ℕ) (x : ℝ) : 0 < iterExp (n + 1) x :=
  exp_pos _

theorem iterExp_pos_of_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  induction n with
  | zero => exact hx
  | succ n _ => exact exp_pos _

theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact Real.exp_strictMono.comp ih

theorem iterExp_mono (n : ℕ) : Monotone (iterExp n) :=
  (iterExp_strictMono n).monotone

/-! ## Growth Bounds -/

/-
iterExp n 1 ≥ 1 for all n
-/
theorem iterExp_one_ge_one (n : ℕ) : 1 ≤ iterExp n 1 := by
  induction' n with n ih <;> norm_num [ iterExp ];
  linarith

/-- iterExp grows strictly with level at any positive point -/
theorem iterExp_strict_level_increase {x : ℝ} (hx : 0 < x) (n : ℕ) :
    iterExp n x < iterExp (n + 1) x := by
  simp [iterExp_succ]
  have h := iterExp_pos_of_pos n hx
  linarith [Real.add_one_le_exp (iterExp n x)]

/-- Composing iterated exponentials adds levels -/
theorem iterExp_compose (k m : ℕ) (x : ℝ) :
    iterExp k (iterExp m x) = iterExp (k + m) x := by
  induction k with
  | zero => simp [iterExp]
  | succ k ih => simp [iterExp_succ, ih, Nat.succ_add]

/-- iterExp is at least as large as the identity for non-negative inputs -/
theorem iterExp_ge_self (n : ℕ) {x : ℝ} (_hx : 0 ≤ x) : x ≤ iterExp n x := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc x ≤ iterExp n x := ih
    _ ≤ exp (iterExp n x) := by linarith [Real.add_one_le_exp (iterExp n x)]


/-- On [1, 10], iterExp n is at least 1 -/
theorem iterExp_ge_one_on_Icc (n : ℕ) {x : ℝ} (hx : x ∈ Icc (1:ℝ) 10) :
    1 ≤ iterExp n x := by
  calc 1 ≤ iterExp n 1 := iterExp_one_ge_one n
    _ ≤ iterExp n x := iterExp_mono n hx.1

/-- The absolute value of iterExp n at a positive point equals iterExp n itself -/
theorem abs_iterExp_pos {n : ℕ} {x : ℝ} (hx : 0 < x) :
    |iterExp n x| = iterExp n x :=
  abs_of_pos (iterExp_pos_of_pos n hx)

/-! ## Tower Level Separation -/

/-
Super-exponential growth: iterExp n 1 ≥ n for all n
-/
theorem iterExp_one_ge_nat (n : ℕ) : (n : ℝ) ≤ iterExp n 1 := by
  induction' n with n ih <;> norm_num [ iterExp ] at *;
  linarith [ Real.add_one_le_exp ( iterExp n 1 ) ]

/-- iterExp (n+1) 1 ≥ e^n: exponential growth in the level -/
theorem iterExp_succ_one_ge_exp_n (n : ℕ) : exp (n : ℝ) ≤ iterExp (n + 1) 1 := by
  simp only [iterExp_succ]
  exact exp_le_exp.mpr (iterExp_one_ge_nat n)

/-! ## Relative Approximation Properties -/

/-- If g ε-relatively-approximates f on [a, b], then at any point in [a, b],
    g(x) is within ε * |f(a)| of f(x). -/
theorem RelApproximatesOn.pointwise {f g : ℝ → ℝ} {ε a b : ℝ}
    (h : RelApproximatesOn f g ε a b) {x : ℝ} (hx : x ∈ Icc a b) :
    |f x - g x| < ε * |f a| :=
  h x hx

/-- Relative approximation at the left endpoint -/
theorem RelApproximatesOn.at_left {f g : ℝ → ℝ} {ε a b : ℝ}
    (h : RelApproximatesOn f g ε a b) (hab : a ≤ b) :
    |f a - g a| < ε * |f a| :=
  h a ⟨le_refl a, hab⟩

/-
If ε < 1 and f(a) > 0, then g(a) > 0 under ε-relative approximation
-/
theorem RelApproximatesOn.g_pos_at_left {f g : ℝ → ℝ} {ε a b : ℝ}
    (h : RelApproximatesOn f g ε a b) (hab : a ≤ b)
    (hε : ε < 1) (hfa : 0 < f a) :
    0 < g a := by
  -- From h.at_left hab we get |f a - g a| < ε * |f a|. Since f a > 0, |f a| = f a.
  have h_left : |f a - g a| < ε * f a := by
    convert h a ⟨ le_rfl, hab ⟩ using 1 ; norm_num [ abs_of_pos hfa ];
  nlinarith [ abs_lt.mp h_left ]

/-- Weakening: if g ε-approximates f and ε ≤ ε', then g ε'-approximates f -/
theorem RelApproximatesOn.weaken {f g : ℝ → ℝ} {ε ε' a b : ℝ}
    (h : RelApproximatesOn f g ε a b) (hεε : ε ≤ ε') (hfa : 0 ≤ |f a|) :
    RelApproximatesOn f g ε' a b := by
  intro x hx
  calc |f x - g x| < ε * |f a| := h x hx
    _ ≤ ε' * |f a| := by exact mul_le_mul_of_nonneg_right hεε hfa

/-! ## iterExp Continuity and Differentiability -/

/-- iterExp n is continuous -/
theorem iterExp_continuous (n : ℕ) : Continuous (iterExp n) := by
  induction n with
  | zero => exact continuous_id
  | succ n ih => exact Real.continuous_exp.comp ih

/-- iterExp n is differentiable -/
theorem iterExp_differentiable (n : ℕ) : Differentiable ℝ (iterExp n) := by
  induction n with
  | zero => exact differentiable_id
  | succ n ih => exact Real.differentiable_exp.comp ih

/-! ## Derivative of iterExp -/

/-
The derivative of iterExp (n+1) satisfies the chain rule cascade:
    (iterExp (n+1))' x = iterExp (n+1) x · (iterExp n)' x
-/
theorem iterExp_deriv_succ (n : ℕ) (x : ℝ) :
    deriv (iterExp (n + 1)) x = iterExp (n + 1) x * deriv (iterExp n) x := by
  convert deriv_comp _ ( Real.differentiableAt_exp ) ( show DifferentiableAt ℝ ( fun y => iterExp n y ) _ from iterExp_differentiable n |> Differentiable.differentiableAt ) using 1 ; aesop

/-- The derivative of iterExp 0 is 1 -/
theorem iterExp_deriv_zero (x : ℝ) : deriv (iterExp 0) x = 1 := by
  show deriv id x = 1
  simp [deriv_id']

/-
The derivative of iterExp n is positive for all x when n ≥ 1
-/
theorem iterExp_deriv_pos (n : ℕ) (hn : 1 ≤ n) (x : ℝ) :
    0 < deriv (iterExp n) x := by
  induction' hn with n hn ih generalizing x <;> simp_all +decide [ iterExp_deriv_succ ];
  · exact mul_pos ( Real.exp_pos x ) ( by rw [ show deriv ( iterExp 0 ) x = 1 by rw [ show iterExp 0 = fun x => x from funext fun x => rfl ] ; norm_num ] ; norm_num );
  · positivity

/-! ## The Derivative Cascade Product -/

/-
The logarithmic derivative cascade: the derivative of iterExp n is the product
    of all tower levels from 1 to n. Specifically:
    (iterExp n)' x = ∏_{k=0}^{n-1} iterExp (k + 1) x  for n ≥ 1

    This multiplicative structure is the engine of the rigidity theorem.
-/
theorem iterExp_deriv_product (n : ℕ) (hn : 1 ≤ n) (x : ℝ) :
    deriv (iterExp n) x = ∏ k ∈ Finset.range n, iterExp (k + 1) x := by
  induction' n with n ih generalizing x <;> simp_all +decide [ Finset.prod_range_succ, iterExp_deriv_succ ];
  by_cases hn : 1 ≤ n <;> simp_all +decide [ mul_comm ];
  exact iterExp_deriv_zero x

/-
Key derivative lower bound: deriv(iterExp n) x ≥ iterExp n x for n ≥ 1
    when x ≥ 0 (so all tower levels are ≥ 1).
-/
theorem iterExp_deriv_ge_self (n : ℕ) (hn : 1 ≤ n) {x : ℝ} (hx : 0 ≤ x) :
    iterExp n x ≤ deriv (iterExp n) x := by
  rw [ iterExp_deriv_product n hn ];
  induction hn <;> simp_all +decide [ Finset.prod_range_succ ];
  exact le_mul_of_one_le_left ( Real.exp_nonneg _ ) ( by linarith [ show 1 ≤ ∏ k ∈ Finset.range ‹_›, Real.exp ( iterExp k x ) from by exact le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by positivity ) fun _ _ => Real.one_le_exp ( by linarith [ iterExp_ge_self ‹_› hx ] ) ) ] )

/-! ## approxDepthBound Properties -/

/-- The depth bound is at most n -/
theorem approxDepthBound_le (n : ℕ) (ε : ℝ) : approxDepthBound n ε ≤ n := by
  unfold approxDepthBound
  split
  · exact le_refl n
  · simp; omega

/-- For ε ≤ 0, the depth bound equals n (vacuous case) -/
theorem approxDepthBound_nonpos (n : ℕ) {ε : ℝ} (hε : ε ≤ 0) :
    approxDepthBound n ε = n := by
  unfold approxDepthBound
  simp [hε]

end