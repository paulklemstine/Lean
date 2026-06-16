import Mathlib

/-! # Functorial Tropical–Pythagorean Bridge (Probability)

This file builds a bridge between three worlds:

* **Tropical / log-domain analysis** — the log-sum-exp functional `lse2` and the
  softmax (Gibbs) map `softmax2`, the standard "dequantization" of the max-plus
  semiring.
* **Pythagorean geometry** — Pythagorean relations `a² + b² = c²`.
* **Probability** — two-point (Bernoulli) distributions, their variance, and a
  Pythagorean decomposition of total probability.

The unifying observation (the "functor") is the map

  `softmax2 : (tropical/log coordinates) → (probability simplex)`,

`softmax2 a b = eᵃ / (eᵃ + eᵇ)`, which is

* a **partition of unity** (`softmax2 a b + softmax2 b a = 1`),
* **translation invariant** / equivariant under the additive shift action
  (`softmax2 (a+c) (b+c) = softmax2 a b`) — this is the functoriality,
* and **surjective onto the open simplex** (`softmax2_log`): every Bernoulli
  parameter is realised by some pair of log-weights.

Dually `lse2` is an additive **monoid homomorphism** for the shift action
(`lse2 (a+c) (b+c) = lse2 a b + c`) and sandwiches the tropical `max`.

The Pythagorean side enters because **every Pythagorean relation `a²+b²=c²`
induces a Bernoulli distribution** `p = (a/c)²`, `q = (b/c)²` (it lands in the
simplex by Pythagoras), it is **scale invariant** (functorial under dilation of
the triple), and it coincides with the softmax image of the log-squared
coordinates (`pyth_eq_softmax2`). Finally the **Pythagorean probability
identity** `(p-q)² + 4·Var = 1` re-expresses the unit total probability as a
Pythagorean sum whose "legs" are the polarization `p-q` and twice the standard
deviation of the Bernoulli law.

## Main results

* `softmax2_add_symm`, `softmax_sum` — partition of unity (2-point and general).
* `softmax2_shift`, `softmax_shift` — translation invariance (functoriality).
* `softmax2_log` — softmax realises every open Bernoulli law.
* `lse2_shift` — `lse2` is a shift homomorphism (tropical degree-1 scaling).
* `lse2_ge_max`, `lse2_le_max_add_log2` — Maslov dequantization sandwich.
* `deriv_lse2_eq_softmax2` — ∇(free energy) = Gibbs probability.
* `pyth_partition`, `pyth_scale_invariant`, `pyth_eq_softmax2` — Pythagorean →
  probability functor and its compatibility with softmax.
* `bern_pythagorean_identity`, `pyth_bern_identity` — `(p-q)² + 4·Var = 1`.

-- !-- Lab Notes -- !--
HYPOTHESIS (H0). The three apparently-unrelated themes (tropical max-plus,
Pythagoras, finite probability) share one structural skeleton: a *normalization
functor into the simplex*. softmax normalizes log-weights; the Pythagorean map
normalizes a triple by `c²`. Both should be (a) partitions of unity and (b)
invariant under the natural rescaling of their inputs (additive shift / dilation).

EXPERIMENT. Formalize both functors at the 2-point level, prove partition of
unity and the invariances, then *prove they agree* on the common target via
`pyth_eq_softmax2`. OUTCOME: confirmed — `softmax2 (log a²) (log b²) = (a/c)²`
exactly. The log-squared coordinates are the tropical preimage of a Pythagorean
distribution.

INSIGHT. The "Pythagorean" identity in probability is just the polarization of
`(p+q)² = 1`: namely `(p-q)² + 4pq = 1`. Since `pq` is precisely the Bernoulli
variance, the unit total probability literally decomposes as the sum of two
squares — the polarization leg and `2σ`. This is recorded twice: abstractly
(`bern_pythagorean_identity`) and on the Pythagorean image (`pyth_bern_identity`).

INSIGHT. Differentiating the tropical free energy returns the probability map:
`deriv (lse2 · b) = softmax2 · b`. This is the analytic glue: the same object
is a max-plus functional and the generating function of the Gibbs law.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open Real Finset

namespace FunctorialTropicalPythagorean

/-! ## Section 1: The softmax functor (tropical coordinates → probability) -/

/-- Two-point softmax (Gibbs map): `eᵃ / (eᵃ + eᵇ)`. -/
def softmax2 (a b : ℝ) : ℝ := Real.exp a / (Real.exp a + Real.exp b)

/-- The Gibbs weight is strictly positive. -/
theorem softmax2_pos (a b : ℝ) : 0 < softmax2 a b :=
  div_pos (Real.exp_pos _) (add_pos (Real.exp_pos _) (Real.exp_pos _))

/-- The Gibbs weight is strictly below one. -/
theorem softmax2_lt_one (a b : ℝ) : softmax2 a b < 1 :=
  (div_lt_one (by positivity)).2 (by linarith [Real.exp_pos a, Real.exp_pos b])

/-- **Partition of unity**: the two Gibbs weights sum to one. -/
theorem softmax2_add_symm (a b : ℝ) : softmax2 a b + softmax2 b a = 1 := by
  unfold softmax2
  rw [div_add_div _ _ (by positivity) (by positivity), div_eq_one_iff_eq (by positivity)]
  ring

/-- **Functoriality / shift invariance**: `softmax2` is invariant under the
    diagonal additive shift action `(a,b) ↦ (a+c, b+c)`. -/
theorem softmax2_shift (a b c : ℝ) : softmax2 (a + c) (b + c) = softmax2 a b := by
  unfold softmax2
  rw [Real.exp_add, Real.exp_add, ← add_mul,
      mul_div_mul_right _ _ (ne_of_gt (Real.exp_pos c))]

/-- **Surjectivity onto the open simplex**: every ratio `p/(p+q)` of positive
    weights is realised by softmax of the log-coordinates. -/
theorem softmax2_log (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    softmax2 (Real.log p) (Real.log q) = p / (p + q) := by
  unfold softmax2; rw [Real.exp_log hp, Real.exp_log hq]

/-! ## Section 2: The log-sum-exp functional (tropical dequantization) -/

/-- Two-point log-sum-exp. -/
def lse2 (a b : ℝ) : ℝ := Real.log (Real.exp a + Real.exp b)

/-- **Shift homomorphism**: `lse2` intertwines the diagonal shift with addition,
    `lse2 (a+c) (b+c) = lse2 a b + c`. -/
theorem lse2_shift (a b c : ℝ) : lse2 (a + c) (b + c) = lse2 a b + c := by
  unfold lse2
  rw [Real.exp_add, Real.exp_add, ← add_mul, mul_comm,
      Real.log_mul (by positivity) (by positivity), Real.log_exp, add_comm]

/-- Tropical lower bound: `max a b ≤ lse2 a b`. -/
theorem lse2_ge_max (a b : ℝ) : max a b ≤ lse2 a b := by
  unfold lse2
  cases max_cases a b <;>
    linarith [Real.log_exp a, Real.log_exp b,
      Real.log_le_log (by positivity)
        (by linarith [Real.exp_pos a, Real.exp_pos b] : Real.exp a + Real.exp b ≥ Real.exp a),
      Real.log_le_log (by positivity)
        (by linarith [Real.exp_pos a, Real.exp_pos b] : Real.exp a + Real.exp b ≥ Real.exp b)]

/-- Tropical upper bound (Maslov sandwich): `lse2 a b ≤ max a b + log 2`. -/
theorem lse2_le_max_add_log2 (a b : ℝ) : lse2 a b ≤ max a b + Real.log 2 := by
  rw [← Real.log_exp (max a b), lse2, ← Real.log_mul (by positivity) (by positivity)]
  gcongr
  cases max_cases a b <;>
    nlinarith [Real.exp_pos a, Real.exp_pos b, Real.exp_le_exp.2 (le_max_left a b),
      Real.exp_le_exp.2 (le_max_right a b)]

/-- Diagonal value: `lse2 a a = a + log 2`. -/
theorem lse2_self (a : ℝ) : lse2 a a = a + Real.log 2 := by
  rw [lse2, ← two_mul, Real.log_mul (by norm_num) (Real.exp_ne_zero a), Real.log_exp]
  ring

/-- **Gradient of the free energy is the Gibbs probability**: the derivative of
    `a ↦ lse2 a b` is `softmax2 a b`. This is the analytic heart of the bridge:
    differentiating the tropical functional `lse2` returns the probability
    functional `softmax2`. -/
theorem deriv_lse2_eq_softmax2 (a b : ℝ) :
    deriv (fun x => lse2 x b) a = softmax2 a b := by
  unfold lse2 softmax2
  norm_num [Real.differentiableAt_exp,
    ne_of_gt (add_pos (Real.exp_pos a) (Real.exp_pos b))]

/-! ## Section 3: The general (finite) softmax functor -/

/-- Softmax over a finite index type. -/
def softmax {ι : Type*} [Fintype ι] (w : ι → ℝ) (i : ι) : ℝ :=
  Real.exp (w i) / ∑ j, Real.exp (w j)

/-- Each general softmax weight is positive (nonempty index type). -/
theorem softmax_pos {ι : Type*} [Fintype ι] [Nonempty ι] (w : ι → ℝ) (i : ι) :
    0 < softmax w i :=
  div_pos (Real.exp_pos _) (Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty)

/-- **Partition of unity (general)**: softmax weights sum to one. -/
theorem softmax_sum {ι : Type*} [Fintype ι] [Nonempty ι] (w : ι → ℝ) :
    ∑ i, softmax w i = 1 := by
  unfold softmax
  rw [← Finset.sum_div,
    div_self (ne_of_gt (Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty))]

/-- **Functoriality (general)**: softmax is invariant under a global additive
    shift of all the log-weights. -/
theorem softmax_shift {ι : Type*} [Fintype ι] [Nonempty ι] (w : ι → ℝ) (c : ℝ)
    (i : ι) : softmax (fun j => w j + c) i = softmax w i := by
  simp only [softmax, exp_add]
  rw [← Finset.sum_mul, mul_div_mul_right _ _ (ne_of_gt (Real.exp_pos _))]

/-! ## Section 4: The Pythagorean → probability functor -/

/-- **Pythagoras lands in the simplex**: a Pythagorean relation `a²+b²=c²`
    (`c ≠ 0`) gives a Bernoulli distribution `p = (a/c)²`, `q = (b/c)²`. -/
theorem pyth_partition (a b c : ℝ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    (a / c) ^ 2 + (b / c) ^ 2 = 1 := by
  field_simp
  linarith [h]

/-- The induced weights are nonnegative. -/
theorem pyth_nonneg (a c : ℝ) : 0 ≤ (a / c) ^ 2 := by positivity

/-- **Scale invariance (functoriality of the Pythagorean functor)**: dilating the
    triple by `k ≠ 0` leaves the induced distribution unchanged. -/
theorem pyth_scale_invariant (a c k : ℝ) (hk : k ≠ 0) :
    ((k * a) / (k * c)) ^ 2 = (a / c) ^ 2 := by
  rw [mul_div_mul_left _ _ hk]

/-- **Compatibility with the softmax functor**: the Pythagorean-induced weight
    equals the softmax image of the log-squared coordinates. Thus the two
    functors into the simplex agree. -/
theorem pyth_eq_softmax2 (a b c : ℝ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0) :
    softmax2 (Real.log (a ^ 2)) (Real.log (b ^ 2)) = (a / c) ^ 2 := by
  unfold softmax2
  rw [Real.exp_log (by positivity), Real.exp_log (by positivity), div_pow,
    div_eq_div_iff (by positivity) (by positivity)]
  nlinarith [h]

/-! ## Section 5: The Pythagorean probability identity (Bernoulli variance) -/

/-- Variance of the Bernoulli law `(p, 1-p)`. -/
def bernVar (p : ℝ) : ℝ := p * (1 - p)

/-- **Pythagorean probability identity**: for a Bernoulli parameter `p` with
    complement `q = 1-p`, the total probability splits as a Pythagorean sum
    `(p-q)² + 4·Var = 1`, with legs the polarization `p-q` and `2·σ`. -/
theorem bern_pythagorean_identity (p : ℝ) :
    (p - (1 - p)) ^ 2 + 4 * bernVar p = 1 := by
  unfold bernVar; ring

/-- Bernoulli variance is maximized at `p = 1/2` with value `1/4`. -/
theorem bernVar_le_quarter (p : ℝ) : bernVar p ≤ 1 / 4 := by
  unfold bernVar; nlinarith [sq_nonneg (p - 1 / 2)]

/-- Variance is nonnegative on the unit interval. -/
theorem bernVar_nonneg (p : ℝ) (hp : 0 ≤ p) (hp1 : p ≤ 1) : 0 ≤ bernVar p :=
  mul_nonneg hp (sub_nonneg.2 hp1)

/-- **Pythagorean triple of probabilities**: for the Bernoulli law induced by a
    Pythagorean relation, the polarization `p-q` and twice the standard
    deviation form the legs of a unit-hypotenuse right triangle. Concretely,
    with `p = (a/c)²`, `q = (b/c)²`, we get `(p-q)² + 4 p q = 1`. -/
theorem pyth_bern_identity (a b c : ℝ) (h : a ^ 2 + b ^ 2 = c ^ 2) (hc : c ≠ 0) :
    ((a / c) ^ 2 - (b / c) ^ 2) ^ 2 + 4 * ((a / c) ^ 2 * (b / c) ^ 2) = 1 := by
  have hp := pyth_partition a b c h hc
  nlinarith [hp]

/-! ## Section 6: Deepening — sigmoid form and tropical curvature = variance

-- !-- Lab Notes -- !--
HYPOTHESIS (H1). The Hessian (second derivative) of the tropical free energy
`lse2` should equal the *variance* of the Gibbs law it generates, mirroring the
classical fact that the log-partition function is the cumulant generating
function. Since the Gibbs law here is Bernoulli with parameter `p = softmax2 a b`,
the predicted curvature is `bernVar p = p(1-p)`.

EXPERIMENT. Prove `deriv (softmax2 · b) a = bernVar (softmax2 a b)` first, then
chain it with `deriv_lse2_eq_softmax2` to obtain the second-derivative identity.
OUTCOME: confirmed. The tropical curvature of `lse2` is exactly the Bernoulli
variance — the same `pq` that appears as the leg `4pq` of the Pythagorean
probability identity. So all three pictures (tropical curvature, Pythagorean
leg, probabilistic variance) are literally the same number.
-- !-- end Lab Notes -- !--
-/

/-- Sigmoid form of the two-point softmax: `softmax2 a b = 1 / (1 + e^{b-a})`. -/
theorem softmax2_eq_sigmoid (a b : ℝ) :
    softmax2 a b = 1 / (1 + Real.exp (b - a)) := by
  unfold softmax2
  rw [Real.exp_sub, div_eq_div_iff (by positivity) (by positivity)]
  field_simp

/-- `lse2` is symmetric. -/
theorem lse2_comm (a b : ℝ) : lse2 a b = lse2 b a := by
  unfold lse2; rw [add_comm]

/-
**Derivative of the Gibbs map is its variance**: differentiating the
    probability functional `softmax2 · b` returns the Bernoulli variance of the
    Gibbs law. This is the score/variance identity at the two-point level.
-/
theorem deriv_softmax2_eq_bernVar (a b : ℝ) :
    deriv (fun x => softmax2 x b) a = bernVar (softmax2 a b) := by
  unfold softmax2 bernVar;
  norm_num [ Real.differentiableAt_exp, ne_of_gt ( add_pos ( Real.exp_pos _ ) ( Real.exp_pos _ ) ) ];
  rw [ one_sub_div, div_mul_div_comm ] <;> ring ; positivity

/-
**Tropical curvature equals probabilistic variance**: the second derivative
    (Hessian, in one variable) of the tropical free energy `lse2 · b` equals the
    variance of the Gibbs/Bernoulli law it generates. This unifies the three
    threads: tropical curvature `= p(1-p) =` Bernoulli variance `=` the leg
    `pq` of the Pythagorean probability identity.
-/
theorem deriv2_lse2_eq_bernVar (b : ℝ) :
    deriv (deriv (fun x => lse2 x b)) = fun a => bernVar (softmax2 a b) := by
  convert funext fun x => deriv_softmax2_eq_bernVar x b using 1;
  exact congr_arg deriv ( funext fun x => deriv_lse2_eq_softmax2 x b )

end FunctorialTropicalPythagorean