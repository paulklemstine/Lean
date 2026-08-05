import Mathlib

/-!
# EML activation monotonicity and the tropical bridge

An *EML transcendental* is a function built from the exponential and the
logarithm.  This file studies the two-parameter family of **generalized EML
activation functions**

$$ E_{a,b}(x) \;=\; a\,x + \log\bigl(1 + e^{b x}\bigr), $$

which contains the softplus (`a = 0`, `b = 1`), the leaky/residual softplus
(`a > 0`) and, after rescaling, all smoothed rectifiers.

The first half of the file determines the **exact parameter domain** on which
these activations are strictly monotone and strictly convex:

* `emlAct_deriv` : `E_{a,b}'(x) = a + b·σ(bx)` with `σ` the logistic function;
* `emlAct_deriv2` : `E_{a,b}''(x) = b²·σ(bx)(1-σ(bx)) > 0` whenever `b ≠ 0`,
  hence `emlAct_strictConvexOn`: strict convexity for *every* nonzero `b`;
* `emlAct_strictMono_iff` : for `b > 0` the activation is strictly increasing on
  all of `ℝ` **if and only if** `0 ≤ a` — an exact (sharp) parameter bound.

The second half is the **cross-domain bridge**.  The same exponential–logarithm
combination underlies the log-sum-exp operation

$$ x \oplus_b y \;=\; \tfrac1b \log\bigl(e^{bx} + e^{by}\bigr), $$

which is *exactly* (not approximately) associative, commutative, and satisfies
the distributive law `(x+z) ⊕_b (y+z) = (x ⊕_b y) + z`; i.e. `(ℝ, ⊕_b, +)` is,
for each `b ≠ 0`, a semiring-like structure transported from `(ℝ_{>0}, +, ·)` by
the EML isomorphism `x ↦ e^{bx}`.  Letting `b → ∞` this analytic structure
*dequantizes* to the **tropical semiring** (Maslov dequantization):

* `lse_gt_max`, `lse_le_max_add_log_two` : `max x y < x ⊕_b y ≤ max x y + log2/b`;
* `tendsto_lse_max` : `x ⊕_b y → max x y` as `b → ∞`;
* `tendsto_lse_tropical` : the same statement written with Mathlib's `Tropical`
  semiring, `-((-x) ⊕_b (-y)) → untrop (trop x + trop y) = min x y`.

The bridge theorem `eml_activation_tropical_bridge` packages both halves: the
strictly convex, strictly monotone smooth EML activations converge uniformly at
rate `log 2 / b` to the (convex but nowhere strictly convex, merely monotone)
tropical addition `x ↦ max x 0`.  Convex analysis of neural activations and
idempotent (tropical) algebra are thus two ends of one exponential–logarithmic
deformation.
-/

noncomputable section

open Real Filter Topology Set

namespace EMLActivation

/-! ## The logistic function -/

/-- The logistic (standard sigmoid) function `σ(t) = eᵗ / (1 + eᵗ)`. -/
def logistic (t : ℝ) : ℝ := Real.exp t / (1 + Real.exp t)

lemma one_add_exp_pos (t : ℝ) : (0 : ℝ) < 1 + Real.exp t := by
  have := Real.exp_pos t; linarith

lemma logistic_pos (t : ℝ) : 0 < logistic t := by
  have h := one_add_exp_pos t
  exact div_pos (Real.exp_pos t) h

lemma logistic_lt_one (t : ℝ) : logistic t < 1 := by
  have h := one_add_exp_pos t
  rw [logistic, div_lt_one h]
  linarith

lemma one_sub_logistic (t : ℝ) : 1 - logistic t = 1 / (1 + Real.exp t) := by
  have h := (one_add_exp_pos t).ne'
  rw [logistic, eq_div_iff h, sub_mul, div_mul_cancel₀ _ h]
  ring

/-- `σ(t) < eᵗ`; a crude bound that forces `σ` to `0` at `-∞`. -/
lemma logistic_lt_exp (t : ℝ) : logistic t < Real.exp t := by
  have h := one_add_exp_pos t
  have hpos := Real.exp_pos t
  rw [logistic, div_lt_iff₀ h]
  nlinarith

lemma tendsto_logistic_atBot : Tendsto logistic atBot (𝓝 0) := by
  have h : Tendsto (fun t : ℝ => 1 + Real.exp t) atBot (𝓝 1) := by
    simpa using tendsto_const_nhds.add Real.tendsto_exp_atBot
  simpa [logistic] using Real.tendsto_exp_atBot.div h one_ne_zero

/-! ## The generalized EML activation -/

/-- The generalized EML activation `E_{a,b}(x) = a x + log (1 + e^{b x})`. -/
def emlAct (a b x : ℝ) : ℝ := a * x + Real.log (1 + Real.exp (b * x))

@[simp] lemma emlAct_zero_zero (a b : ℝ) : emlAct a b 0 = Real.log 2 := by
  norm_num [emlAct]

lemma hasDerivAt_emlAct (a b x : ℝ) :
    HasDerivAt (emlAct a b) (a + b * logistic (b * x)) x := by
  have h1 : HasDerivAt (fun x : ℝ => b * x) b x := by
    simpa using (hasDerivAt_id x).const_mul b
  have h2 : HasDerivAt (fun x : ℝ => 1 + Real.exp (b * x)) (Real.exp (b * x) * b) x := by
    simpa using (h1.exp).const_add 1
  have h3 := h2.log (one_add_exp_pos (b * x)).ne'
  have h4 : HasDerivAt (fun x : ℝ => a * x) a x := by
    simpa using (hasDerivAt_id x).const_mul a
  convert h4.add h3 using 1
  simp only [logistic]
  field_simp

lemma emlAct_differentiable (a b : ℝ) : Differentiable ℝ (emlAct a b) :=
  fun x => (hasDerivAt_emlAct a b x).differentiableAt

lemma emlAct_deriv (a b x : ℝ) : deriv (emlAct a b) x = a + b * logistic (b * x) :=
  (hasDerivAt_emlAct a b x).deriv

lemma hasDerivAt_logistic (t : ℝ) :
    HasDerivAt logistic (logistic t * (1 - logistic t)) t := by
  have h2 : HasDerivAt (fun x : ℝ => 1 + Real.exp x) (Real.exp t) t := by
    simpa using (Real.hasDerivAt_exp t).const_add 1
  convert (Real.hasDerivAt_exp t).div h2 (one_add_exp_pos t).ne' using 1
  simp only [logistic]
  field_simp

lemma hasDerivAt_emlAct_deriv (a b x : ℝ) :
    HasDerivAt (deriv (emlAct a b))
      (b ^ 2 * (logistic (b * x) * (1 - logistic (b * x)))) x := by
  have hfun : deriv (emlAct a b) = fun y => a + b * logistic (b * y) := by
    funext y; exact emlAct_deriv a b y
  rw [hfun]
  have h1 : HasDerivAt (fun y : ℝ => b * y) b x := by
    simpa using (hasDerivAt_id x).const_mul b
  have h2 := (hasDerivAt_logistic (b * x)).comp x h1
  convert (h2.const_mul b).const_add a using 1
  ring

/-- The second derivative of the EML activation. -/
lemma emlAct_deriv2 (a b x : ℝ) :
    deriv (deriv (emlAct a b)) x = b ^ 2 * (logistic (b * x) * (1 - logistic (b * x))) :=
  (hasDerivAt_emlAct_deriv a b x).deriv

/-- **Positive second derivative**: for every nonzero `b` and every `a`, the EML
activation has strictly positive second derivative everywhere. -/
theorem emlAct_deriv2_pos {b : ℝ} (a : ℝ) (hb : b ≠ 0) (x : ℝ) :
    0 < deriv (deriv (emlAct a b)) x := by
  rw [emlAct_deriv2]
  have h1 := logistic_pos (b * x)
  have h2 := logistic_lt_one (b * x)
  have hb2 : 0 < b ^ 2 := by positivity
  have : 0 < logistic (b * x) * (1 - logistic (b * x)) := by nlinarith
  positivity

/-- **Global strict convexity** on the whole real line, for every nonzero `b`. -/
theorem emlAct_strictConvexOn {b : ℝ} (a : ℝ) (hb : b ≠ 0) :
    StrictConvexOn ℝ univ (emlAct a b) := by
  apply strictConvexOn_of_deriv2_pos convex_univ
  · exact (continuous_iff_continuousAt.2
      fun x => (hasDerivAt_emlAct a b x).differentiableAt.continuousAt).continuousOn
  · intro x _
    simpa [Function.iterate_succ] using emlAct_deriv2_pos a hb x

/-! ### Exact monotonicity domain -/

/-- Sufficiency: `0 ≤ a` and `0 < b` force strict monotonicity. -/
theorem emlAct_strictMono {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) :
    StrictMono (emlAct a b) := by
  apply strictMono_of_deriv_pos
  intro x
  rw [emlAct_deriv]
  have := logistic_pos (b * x)
  nlinarith

/-- Necessity: if `a < 0` (and `b > 0`) then the activation fails to be even
monotone; the derivative becomes negative far out on the left. -/
theorem emlAct_not_monotone {a b : ℝ} (ha : a < 0) (hb : 0 < b) :
    ¬ Monotone (emlAct a b) := by
  intro hmono
  have key : ∀ x : ℝ, 0 ≤ a + b * logistic (b * x) := by
    intro x; rw [← emlAct_deriv]; exact hmono.deriv_nonneg
  have hlim : Tendsto (fun x : ℝ => a + b * logistic (b * x)) atBot (𝓝 a) := by
    have h1 : Tendsto (fun x : ℝ => b * x) atBot atBot := Tendsto.const_mul_atBot hb tendsto_id
    have h2 : Tendsto (fun x : ℝ => logistic (b * x)) atBot (𝓝 0) :=
      tendsto_logistic_atBot.comp h1
    simpa using (tendsto_const_nhds (x := a)).add (h2.const_mul b)
  have : (0 : ℝ) ≤ a := ge_of_tendsto hlim (Eventually.of_forall key)
  linarith

/-- **Exact parameter domain for monotonicity.**  For `b > 0`, the generalized
EML activation `E_{a,b}` is strictly increasing on `ℝ` if and only if `0 ≤ a`. -/
theorem emlAct_strictMono_iff {a b : ℝ} (hb : 0 < b) :
    StrictMono (emlAct a b) ↔ 0 ≤ a := by
  constructor
  · intro h
    by_contra hlt
    exact emlAct_not_monotone (lt_of_not_ge hlt) hb h.monotone
  · intro ha; exact emlAct_strictMono ha hb

/-! ## The log-sum-exp deformation of tropical addition -/

/-- The log-sum-exp ("softmax") operation `x ⊕_b y = (1/b) log (e^{bx} + e^{by})`. -/
def lse (b x y : ℝ) : ℝ := Real.log (Real.exp (b * x) + Real.exp (b * y)) / b

lemma lse_sum_pos (b x y : ℝ) : 0 < Real.exp (b * x) + Real.exp (b * y) := by positivity

lemma lse_comm (b x y : ℝ) : lse b x y = lse b y x := by
  rw [lse, lse, add_comm]

/-- The EML activation is the log-sum-exp against the neutral value `0`. -/
lemma emlAct_eq_lse (b x : ℝ) : emlAct 0 b x / b = lse b x 0 := by
  simp [emlAct, lse, add_comm]

/-- The defining property: `e^{b (x ⊕_b y)} = e^{bx} + e^{by}`, i.e. `x ↦ e^{bx}`
is an isomorphism from `(ℝ, ⊕_b)` onto `(ℝ_{>0}, +)`. -/
lemma exp_mul_lse {b : ℝ} (hb : b ≠ 0) (x y : ℝ) :
    Real.exp (b * lse b x y) = Real.exp (b * x) + Real.exp (b * y) := by
  rw [lse, mul_div_cancel₀ _ hb, Real.exp_log (lse_sum_pos b x y)]

/-- `⊕_b` is *exactly* associative for every `b ≠ 0`. -/
theorem lse_assoc {b : ℝ} (hb : b ≠ 0) (x y z : ℝ) :
    lse b (lse b x y) z = lse b x (lse b y z) := by
  have h1 : Real.exp (b * lse b (lse b x y) z) = Real.exp (b * lse b x (lse b y z)) := by
    rw [exp_mul_lse hb, exp_mul_lse hb, exp_mul_lse hb, exp_mul_lse hb]; ring
  exact mul_left_cancel₀ hb (Real.exp_injective h1)

/-- Distributivity of ordinary addition over `⊕_b`: `(x+z) ⊕_b (y+z) = (x ⊕_b y) + z`. -/
theorem lse_add_right {b : ℝ} (hb : b ≠ 0) (x y z : ℝ) :
    lse b (x + z) (y + z) = lse b x y + z := by
  have h : Real.exp (b * (x + z)) + Real.exp (b * (y + z))
      = Real.exp (b * z) * (Real.exp (b * x) + Real.exp (b * y)) := by
    rw [mul_add, mul_add, Real.exp_add, Real.exp_add]; ring
  rw [lse, lse, h, Real.log_mul (Real.exp_ne_zero _) (lse_sum_pos b x y).ne', Real.log_exp]
  field_simp
  ring

/-- Failure of idempotency, measured exactly: `x ⊕_b x = x + log 2 / b`.  Tropical
addition is idempotent, and idempotency is recovered precisely in the limit
`b → ∞`; the defect `log 2 / b` is the deformation parameter. -/
theorem lse_self {b : ℝ} (hb : b ≠ 0) (x : ℝ) : lse b x x = x + Real.log 2 / b := by
  have h : Real.exp (b * x) + Real.exp (b * x) = 2 * Real.exp (b * x) := by ring
  rw [lse, h, Real.log_mul two_ne_zero (Real.exp_ne_zero _), Real.log_exp]
  field_simp
  ring

/-- Strict domination of tropical addition. -/
theorem lse_gt_max {b : ℝ} (hb : 0 < b) (x y : ℝ) : max x y < lse b x y := by
  rw [lse, lt_div_iff₀ hb, ← Real.log_exp (max x y * b)]
  apply Real.log_lt_log (Real.exp_pos _)
  rcases le_total x y with h | h
  · rw [max_eq_right h]
    have h1 : Real.exp (y * b) = Real.exp (b * y) := by ring_nf
    have := Real.exp_pos (b * x)
    rw [h1]; linarith
  · rw [max_eq_left h]
    have h1 : Real.exp (x * b) = Real.exp (b * x) := by ring_nf
    have := Real.exp_pos (b * y)
    rw [h1]; linarith

/-- The deformation error is at most `log 2 / b`. -/
theorem lse_le_max_add_log_two {b : ℝ} (hb : 0 < b) (x y : ℝ) :
    lse b x y ≤ max x y + Real.log 2 / b := by
  rw [lse, div_le_iff₀ hb]
  have h : Real.exp (b * x) + Real.exp (b * y) ≤ 2 * Real.exp (b * max x y) := by
    rcases le_total x y with h | h
    · rw [max_eq_right h]
      have : Real.exp (b * x) ≤ Real.exp (b * y) := Real.exp_le_exp.2 (by nlinarith)
      linarith
    · rw [max_eq_left h]
      have : Real.exp (b * y) ≤ Real.exp (b * x) := Real.exp_le_exp.2 (by nlinarith)
      linarith
  calc Real.log (Real.exp (b * x) + Real.exp (b * y))
      ≤ Real.log (2 * Real.exp (b * max x y)) := Real.log_le_log (lse_sum_pos b x y) h
    _ = Real.log 2 + b * max x y := by
        rw [Real.log_mul two_ne_zero (Real.exp_ne_zero _), Real.log_exp]
    _ = (max x y + Real.log 2 / b) * b := by field_simp; ring

/-- **Maslov dequantization**: the analytic operations `⊕_b` converge to the
tropical (max-plus) addition as `b → ∞`. -/
theorem tendsto_lse_max (x y : ℝ) :
    Tendsto (fun b : ℝ => lse b x y) atTop (𝓝 (max x y)) := by
  have hupper : Tendsto (fun b : ℝ => max x y + Real.log 2 / b) atTop (𝓝 (max x y)) := by
    simpa using tendsto_const_nhds.add
      (tendsto_const_nhds.div_atTop (f := fun b : ℝ => Real.log 2) tendsto_id)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with b hb using (lse_gt_max hb x y).le
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with b hb using lse_le_max_add_log_two hb x y

/-- The same limit phrased inside Mathlib's tropical semiring `Tropical ℝ`
(whose addition is `min`): the min-plus log-sum-exp deformation converges to
tropical addition. -/
theorem tendsto_lse_tropical (x y : ℝ) :
    Tendsto (fun b : ℝ => -lse b (-x) (-y)) atTop
      (𝓝 (Tropical.untrop (Tropical.trop x + Tropical.trop y))) := by
  have h : Tropical.untrop (Tropical.trop x + Tropical.trop y) = -max (-x) (-y) := by
    simp [Tropical.untrop_add, ← min_neg_neg]
  rw [h]
  exact (tendsto_lse_max (-x) (-y)).neg

/-! ## The bridge theorem -/

/-- **EML activation ↔ tropical algebra bridge.**

For every `b > 0` the EML activation `E_{0,b}(x)/b = (1/b) log(1 + e^{bx})`:

1. is strictly convex on all of `ℝ` and strictly increasing (the exact
   monotonicity domain `0 ≤ a` of `emlAct_strictMono_iff` at `a = 0`);
2. dominates the tropical expression `max x 0 = untrop (trop x + trop 0)`
   computed in the max-plus semiring;
3. approximates it uniformly with error at most `log 2 / b`; and
4. converges to it as `b → ∞`.

Thus the strictly convex smooth EML transcendentals form an analytic
deformation of idempotent tropical addition. -/
theorem eml_activation_tropical_bridge {b : ℝ} (hb : 0 < b) :
    StrictConvexOn ℝ univ (emlAct 0 b) ∧ StrictMono (emlAct 0 b) ∧
      (∀ x : ℝ, max x 0 < emlAct 0 b x / b ∧
        emlAct 0 b x / b ≤ max x 0 + Real.log 2 / b) ∧
      (∀ x : ℝ, Tendsto (fun c : ℝ => emlAct 0 c x / c) atTop (𝓝 (max x 0))) := by
  refine ⟨emlAct_strictConvexOn 0 hb.ne', emlAct_strictMono le_rfl hb, ?_, ?_⟩
  · intro x
    rw [emlAct_eq_lse b x]
    exact ⟨lse_gt_max hb x 0, lse_le_max_add_log_two hb x 0⟩
  · intro x
    have h : (fun c : ℝ => lse c x 0) =ᶠ[atTop] fun c : ℝ => emlAct 0 c x / c := by
      filter_upwards with c
      exact (emlAct_eq_lse c x).symm
    exact (tendsto_lse_max x 0).congr' h

end EMLActivation