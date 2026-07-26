import Mathlib

/-!
# Chaos as a keystream: the logistic map at full strength

The **logistic map** `f(x) = 4·x·(1 - x)` on the unit interval is the archetypal
one-dimensional chaotic system.  A chaos-based stream cipher uses the orbit
`x₀, f(x₀), f²(x₀), …` of a secret seed `x₀ ∈ (0,1)` as a keystream: the plaintext
is masked by successive iterates.  The security folklore rests on two structural
claims about `f`:

* **Sensitivity** — two seeds that are exponentially close become macroscopically
  separated after only linearly many iterations (this is the "avalanche" a cipher
  needs); and
* **Algebraic depth** — the `n`-th iterate `fⁿ` is a polynomial of degree `2ⁿ`, so
  recovering the seed from the keystream means solving an equation whose degree is
  exponential in the number of steps.

This file makes both statements precise and proves them.  The unifying device is
the exact **semiconjugacy of the logistic map to angle doubling**:

  `f(sin² t) = sin²(2 t)`,      hence      `fⁿ(sin² t) = sin²(2ⁿ t)`.

Under the substitution `x = sin² t` the logistic dynamics becomes the doubling
map `t ↦ 2 t`, whose exponential stretching factor `2ⁿ` is exactly the source of
both the sensitivity and the degree growth.  The Lyapunov exponent `log 2` is the
logarithm of that per-step factor.

## Main results

* `LogisticChaos.logistic_maps_unitInterval` — `f` maps `[0,1]` into itself.
* `LogisticChaos.logistic_fixedPoints` — the only real fixed points are `0` and `3/4`.
* `LogisticChaos.logistic_conjugacy` — `f(sin² t) = sin²(2 t)`.
* `LogisticChaos.logistic_iterate_conjugacy` — `fⁿ(sin² t) = sin²(2ⁿ t)`.
* `LogisticChaos.logisticPoly_iterate_natDegree` — the `n`-th iterate is a
  polynomial of degree `2ⁿ`.
* `LogisticChaos.logisticPoly_iterate_eval` — the polynomial iterate evaluates to
  the functional iterate.
* `LogisticChaos.sensitivity` — an explicit family of seeds collapsing to `0`
  whose `n`-th iterates stay a fixed distance `1/2` from the orbit of `0`,
  the quantitative form of sensitive dependence on initial conditions.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  "Chaos is cryptography": the logistic map at `r = 4`
should exhibit (i) exponential sensitivity to the seed and (ii) an `n`-th iterate
of algebraic degree `2ⁿ`, the two ingredients a stream cipher advertises.

Experiment (Experimenter).  Rather than attack floating-point orbits, we work
exactly.  The identity `4 sin²t cos²t = sin²(2t)` conjugates `f` to angle
doubling; a clean induction lifts it to all iterates, giving both the `2ⁿ`
stretching and — via `Polynomial.natDegree_comp` — the `2ⁿ` algebraic degree.
Sensitivity is exhibited concretely: the seeds `sin²(π/2ⁿ⁺²)` shrink to `0`, yet
after `n` steps each lands exactly on `1/2` (because `2ⁿ·π/2ⁿ⁺² = π/4`), a fixed
gap from the orbit of the fixed point `0`.

Analysis (Analyst).  The doubling picture explains *why* the naive "chaos cipher"
is both attractive and fragile.  Attractive: the `2ⁿ` degree makes algebraic seed
recovery look exponential.  Fragile: conjugacy to `t ↦ 2t (mod 1)` is exactly the
binary shift map, so in binary the keystream merely reads off the bits of `t` —
transparent to anyone who thinks in the conjugate coordinate.  Sensitivity is
real but is a double-edged sword shared by the cryptanalyst.

Critique (Critic).  We avoid vacuity: `logistic_fixedPoints` is an iff pinning the
fixed set to `{0, 3/4}`; `sensitivity` produces genuinely distinct, converging
seeds with a constant output gap; the degree theorem is proved through polynomial
composition, not by fiat.  No result is `True`-typed or a definitional rfl.

Synthesis (PI).  The exact conjugacy `fⁿ(sin²t) = sin²(2ⁿt)` is the single
structural fact from which sensitivity (dynamics) and degree `2ⁿ` (algebra) both
flow — a concrete bridge between real dynamics and polynomial algebra.
-/

namespace LogisticChaos

open Polynomial

/-- The logistic map at the fully chaotic parameter `r = 4`. -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

@[simp] lemma logistic_zero : logistic 0 = 0 := by simp [logistic]

@[simp] lemma logistic_one : logistic 1 = 0 := by simp [logistic]

/-- The logistic map sends the unit interval into itself. -/
theorem logistic_maps_unitInterval {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    0 ≤ logistic x ∧ logistic x ≤ 1 := by
  refine ⟨by unfold logistic; nlinarith, ?_⟩
  unfold logistic; nlinarith [sq_nonneg (2 * x - 1)]

/-- The real fixed points of the logistic map are exactly `0` and `3/4`. -/
theorem logistic_fixedPoints (x : ℝ) : logistic x = x ↔ x = 0 ∨ x = 3 / 4 := by
  unfold logistic
  constructor
  · intro h
    rcases mul_eq_zero.mp (by nlinarith : x * (3 - 4 * x) = 0) with h1 | h2
    · exact Or.inl h1
    · exact Or.inr (by linarith)
  · rintro (rfl | rfl) <;> ring

/-! ## Semiconjugacy to angle doubling -/

/-- **Semiconjugacy.**  Under `x = sin² t` the logistic map becomes angle
doubling: `f(sin² t) = sin²(2 t)`. -/
theorem logistic_conjugacy (t : ℝ) : logistic (Real.sin t ^ 2) = Real.sin (2 * t) ^ 2 := by
  unfold logistic
  rw [Real.sin_two_mul, ← Real.cos_sq_add_sin_sq t]
  ring_nf

/-- The `n`-fold logistic iterate is angle doubling by `2ⁿ`:
`fⁿ(sin² t) = sin²(2ⁿ t)`.  This is the exact source of the exponential
stretching (Lyapunov exponent `log 2`). -/
theorem logistic_iterate_conjugacy (n : ℕ) (t : ℝ) :
    logistic^[n] (Real.sin t ^ 2) = Real.sin (2 ^ n * t) ^ 2 := by
  induction n generalizing t with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ', Function.comp_apply, ih, logistic_conjugacy]
    rw [show 2 * (2 ^ k * t) = 2 ^ (k + 1) * t by ring]

/-- Iterating the logistic map fixes `0` (the boundary fixed point). -/
@[simp] theorem logistic_iterate_zero (n : ℕ) : logistic^[n] 0 = 0 := by
  induction n with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ', Function.comp_apply, ih, logistic_zero]

/-! ## Algebraic depth: the `n`-th iterate has degree `2ⁿ` -/

/-- The logistic map as a real polynomial. -/
noncomputable def logisticPoly : Polynomial ℝ := C 4 * X * (1 - X)

/-- The `n`-fold composition of `logisticPoly` with itself
(`compIter 0 = X`, the identity polynomial). -/
noncomputable def logisticPolyIter : ℕ → Polynomial ℝ
  | 0 => X
  | (n + 1) => logisticPoly.comp (logisticPolyIter n)

lemma logisticPoly_natDegree : logisticPoly.natDegree = 2 := by
  unfold logisticPoly; compute_degree!

/-- **Exponential algebraic degree.**  The `n`-th logistic iterate is a
polynomial of degree `2ⁿ`; inverting it (recovering the seed) means solving a
degree-`2ⁿ` equation. -/
theorem logisticPoly_iterate_natDegree (n : ℕ) : (logisticPolyIter n).natDegree = 2 ^ n := by
  induction n with
  | zero => simp [logisticPolyIter]
  | succ k ih =>
    rw [logisticPolyIter, Polynomial.natDegree_comp, ih, logisticPoly_natDegree]
    ring

/-- The polynomial iterate evaluates to the functional iterate: the algebraic and
dynamical descriptions of `fⁿ` coincide. -/
theorem logisticPoly_iterate_eval (n : ℕ) (x : ℝ) :
    (logisticPolyIter n).eval x = logistic^[n] x := by
  induction n generalizing x with
  | zero => simp [logisticPolyIter]
  | succ k ih =>
    rw [logisticPolyIter, Polynomial.eval_comp, Function.iterate_succ', Function.comp_apply, ih]
    simp only [logisticPoly, logistic]
    simp

/-! ## Sensitive dependence on initial conditions -/

/-- The sensitivity seeds `sₙ = sin²(π/2ⁿ⁺²)`, converging to the fixed point `0`. -/
noncomputable def sensSeed (n : ℕ) : ℝ := Real.sin (Real.pi / 2 ^ (n + 2)) ^ 2

/-- The sensitivity seeds are strictly positive (hence genuinely distinct from the
fixed point `0`). -/
theorem sensSeed_pos (n : ℕ) : 0 < sensSeed n := by
  unfold sensSeed
  have hx : 0 < Real.pi / 2 ^ (n + 2) := by positivity
  have hb : (2 : ℝ) ≤ 2 ^ (n + 2) := by
    calc (2 : ℝ) = 2 ^ 1 := by ring
      _ ≤ 2 ^ (n + 2) := by apply pow_le_pow_right₀ (by norm_num); omega
  have hxle : Real.pi / 2 ^ (n + 2) < Real.pi := by
    rw [div_lt_iff₀ (by positivity)]; nlinarith [Real.pi_pos]
  have : 0 < Real.sin (Real.pi / 2 ^ (n + 2)) := Real.sin_pos_of_pos_of_lt_pi hx hxle
  positivity

/-- The sensitivity seeds shrink quadratically towards `0`:
`sₙ ≤ (π/2ⁿ⁺²)²`. In particular they converge to the fixed point `0`. -/
theorem sensSeed_le (n : ℕ) : sensSeed n ≤ (Real.pi / 2 ^ (n + 2)) ^ 2 := by
  unfold sensSeed
  have hx : 0 ≤ Real.pi / 2 ^ (n + 2) := by positivity
  have h1 : Real.sin (Real.pi / 2 ^ (n + 2)) ≤ Real.pi / 2 ^ (n + 2) := Real.sin_le hx
  have hb : (2 : ℝ) ≤ 2 ^ (n + 2) := by
    calc (2 : ℝ) = 2 ^ 1 := by ring
      _ ≤ 2 ^ (n + 2) := by apply pow_le_pow_right₀ (by norm_num); omega
  have h2 : 0 ≤ Real.sin (Real.pi / 2 ^ (n + 2)) := by
    apply Real.sin_nonneg_of_nonneg_of_le_pi hx
    rw [div_le_iff₀ (by positivity)]; nlinarith [Real.pi_pos]
  nlinarith

/-- After exactly `n` iterations every sensitivity seed lands on `1/2`, since
`2ⁿ · π/2ⁿ⁺² = π/4` and `sin²(π/4) = 1/2`. -/
theorem sensSeed_iterate (n : ℕ) : logistic^[n] (sensSeed n) = 1 / 2 := by
  unfold sensSeed
  rw [logistic_iterate_conjugacy]
  have h : (2 : ℝ) ^ n * (Real.pi / 2 ^ (n + 2)) = Real.pi / 4 := by
    rw [pow_succ, pow_succ]; field_simp; ring
  rw [h, Real.sin_pi_div_four, div_pow, Real.sq_sqrt (by norm_num)]
  norm_num

/-- **Sensitive dependence on initial conditions.**  There is a family of seeds
`sₙ`, each strictly between `0` and the fixed point at distance `≤ (π/2ⁿ⁺²)²`
from `0`, whose `n`-th iterates stay a *fixed* distance `1/2` from the orbit of
`0`.  Arbitrarily small changes in the seed produce an `O(1)` change in the
output after only linearly many steps — the avalanche property. -/
theorem sensitivity (n : ℕ) :
    0 < sensSeed n ∧ sensSeed n ≤ (Real.pi / 2 ^ (n + 2)) ^ 2 ∧
      |logistic^[n] (sensSeed n) - logistic^[n] 0| = 1 / 2 := by
  refine ⟨sensSeed_pos n, sensSeed_le n, ?_⟩
  rw [sensSeed_iterate, logistic_iterate_zero]
  norm_num

end LogisticChaos