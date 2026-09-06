/-
# Wigner–Exponential Moment Duality, Hankel Fingerprints and Generating Radii

Second research cycle built on `Catalog.Algebra.MomentFingerprintClassification`.

`MomentFingerprintClassification` proves that the *raw* moments of the GUE Wigner
surmise and of the exponential law coincide only at `k = 0, 1`.  Here we exhibit
the genuine hidden relation between the two sequences, which is **not** an
equality of raw moments but an *index-halving duality*:

* `gueMoment_odd_div_poissonMoment` :
  `M_{2m+1} / P_{m+1} = (π/4)^m` — the odd GUE moments are the Poisson moments at
  half the index, up to a purely geometric factor;
* `gueMoment_even_mul_factorial` :
  `M_{2m} · m! = P_{2m+1} · (π/16)^m` — the even GUE moments are the odd Poisson
  moments divided by `m!` and geometrically damped.

Further fingerprints of the three regimes:

* `gueMoment_unique_of_recursion` : the recursion `M_{k+2} = ((k+3)π/8)M_k` with
  `M_0 = M_1 = 1` characterizes the Wigner-surmise moment sequence;
* `hankel3` fingerprints: the third Hankel determinant of the moment sequence is
  `0` (rigid), `π²(9π - 28)/256` (GUE) and `4` (Poisson) — strictly ordered, with
  GUE positivity equivalent to the elementary bound `π > 28/9`;
* generating-function radii: `∑ M_k t^k/k!` converges whenever `t² < 2`, while
  `∑ P_k t^k/k!` diverges for `t ≥ 1`, so the whole band `1 ≤ t, t² < 2`
  separates the two regimes analytically;
* `classify_sharp` : the separation constant `sepConst/2 = (3π/8 - 1)/2` is sharp;
* `classify_of_unit_fluctuation_127` : with a `1/√n` fluctuation bound, `n ≥ 127`
  spacings already suffice for a provably correct classification.
-/
import Algebra.MomentFingerprintClassification

open Real MeasureTheory Set Filter Topology

namespace MomentFingerprint

noncomputable section

/-! ## Index-halving duality between the two moment sequences -/

/-- **Odd duality.**  The odd Wigner-surmise moments are exactly the Poisson
moments at half the index, damped by the geometric factor `(π/4)^m`. -/
theorem gueMoment_odd_eq_poissonMoment (m : ℕ) :
    gueMoment (2 * m + 1) = poissonMoment (m + 1) * (π / 4) ^ m := by
  rw [gueMoment_odd, poissonMoment_eq_factorial]

/-- The odd-moment ratio is a pure geometric progression of ratio `π/4`. -/
theorem gueMoment_odd_div_poissonMoment (m : ℕ) :
    gueMoment (2 * m + 1) / poissonMoment (m + 1) = (π / 4) ^ m := by
  rw [gueMoment_odd_eq_poissonMoment, mul_comm,
    mul_div_assoc, div_self (poissonMoment_pos (m + 1)).ne', mul_one]

/-- **Even duality.**  `M_{2m}·m! = P_{2m+1}·(π/16)^m`. -/
theorem gueMoment_even_mul_factorial (m : ℕ) :
    gueMoment (2 * m) * (Nat.factorial m : ℝ) = poissonMoment (2 * m + 1) * (π / 16) ^ m := by
  have hdf : (Nat.doubleFactorial (2 * m + 1) : ℝ) * (2 ^ m * Nat.factorial m)
      = (Nat.factorial (2 * m + 1) : ℝ) := by
    have : Nat.doubleFactorial (2 * m + 1) * Nat.doubleFactorial (2 * m) = Nat.factorial (2 * m + 1) := by
      rw [← Nat.factorial_eq_mul_doubleFactorial]
    rw [Nat.doubleFactorial_two_mul] at this
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) this
  have hp : (π / 8 : ℝ) ^ m = 2 ^ m * (π / 16) ^ m := by
    rw [← mul_pow]; congr 1; ring
  rw [gueMoment_even, poissonMoment_eq_factorial, ← hdf, hp]
  ring

/-- The two dualities together: the geometric damping ratios `π/4` (odd) and
`π/16` (even) are the *only* obstruction to a coincidence of the two
fingerprints; both are `< 1`, whence the strict domination proved in
`gueMoment_lt_poissonMoment`. -/
theorem duality_ratios_lt_one : π / 4 < 1 ∧ π / 16 < 1 := by
  constructor <;> nlinarith [Real.pi_lt_d2, Real.pi_pos]

/-! ## Rigidity: the recursion characterizes the fingerprint -/

/-- **Rigidity of the antiderivative recursion.**  Any real sequence with
`M 0 = M 1 = 1` obeying `M (k+2) = ((k+3)π/8)·M k` *is* the Wigner-surmise moment
sequence. -/
theorem gueMoment_unique_of_recursion (M : ℕ → ℝ) (h0 : M 0 = 1) (h1 : M 1 = 1)
    (hrec : ∀ k : ℕ, M (k + 2) = (((k : ℝ) + 3) * π / 8) * M k) :
    ∀ k, M k = gueMoment k := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    match k with
    | 0 => rw [h0, gueMoment_zero]
    | 1 => rw [h1, gueMoment_one]
    | (n + 2) => rw [hrec n, gueMoment_succ_succ n, ih n (by omega)]

/-! ## Hankel fingerprints -/

/-- Third Hankel determinant of a moment sequence. -/
def hankel3 (M : ℕ → ℝ) : ℝ :=
  Matrix.det !![M 0, M 1, M 2; M 1, M 2, M 3; M 2, M 3, M 4]

theorem hankel3_eq (M : ℕ → ℝ) :
    hankel3 M = M 0 * (M 2 * M 4 - M 3 ^ 2) - M 1 * (M 1 * M 4 - M 3 * M 2)
      + M 2 * (M 1 * M 3 - M 2 ^ 2) := by
  unfold hankel3
  simp [Matrix.det_fin_three]
  ring

/-- The rigid spectrum is moment-degenerate: its Hankel determinant vanishes
(the Dirac mass is supported on a single point). -/
theorem hankel3_rigid : hankel3 rigidMoment = 0 := by
  rw [hankel3_eq]
  simp [rigidMoment]

/-- The GUE Hankel fingerprint in closed form. -/
theorem hankel3_gue : hankel3 gueMoment = π ^ 2 * (9 * π - 28) / 256 := by
  rw [hankel3_eq, gueMoment_zero, gueMoment_one, gueMoment_two, gueMoment_three, gueMoment_four]
  ring

/-- The Poisson Hankel fingerprint. -/
theorem hankel3_poisson : hankel3 poissonMoment = 4 := by
  rw [hankel3_eq]
  simp only [poissonMoment_eq_factorial]
  norm_num [Nat.factorial]

/-- Positivity of the GUE Hankel determinant is *equivalent* to the elementary
transcendental-free bound `π > 28/9`. -/
theorem hankel3_gue_pos_iff : 0 < hankel3 gueMoment ↔ 28 / 9 < π := by
  rw [hankel3_gue]
  constructor
  · intro h
    nlinarith [Real.pi_pos, sq_nonneg π]
  · intro h
    have hp := Real.pi_pos
    have h9 : 0 < 9 * π - 28 := by linarith
    positivity

/-- **Hankel fingerprint ordering.**  The third Hankel determinants of the three
regimes are strictly ordered exactly as the variances are:
`0 (rigid) < π²(9π-28)/256 (GUE) < 4 (Poisson)`. -/
theorem hankel3_fingerprint_ordering :
    hankel3 rigidMoment < hankel3 gueMoment ∧ hankel3 gueMoment < hankel3 poissonMoment := by
  rw [hankel3_rigid, hankel3_gue, hankel3_poisson]
  constructor
  · nlinarith [Real.pi_gt_d2, Real.pi_pos]
  · nlinarith [Real.pi_lt_d2, Real.pi_pos]

/-! ## Generating-function radii separate the regimes -/

/-- The exponential generating series of the GUE fingerprint converges on the
whole disc `t² < 2`, in stark contrast with the Poisson one. -/
theorem gue_egf_summable (t : ℝ) (ht0 : 0 ≤ t) (ht : t ^ 2 < 2) :
    Summable (fun k : ℕ => gueMoment k * t ^ k / (Nat.factorial k : ℝ)) := by
  have hq0 : 0 ≤ t ^ 2 / 2 := by positivity
  have hq1 : t ^ 2 / 2 < 1 := by linarith
  have hgeo : Summable (fun m : ℕ => (t ^ 2 / 2) ^ m) := summable_geometric_of_lt_one hq0 hq1
  have hbound : ∀ k : ℕ, gueMoment k / (Nat.factorial k : ℝ) ≤ 2 * (1 / 2 : ℝ) ^ (k / 2) := by
    intro k
    rcases Nat.lt_or_ge k 2 with hk | hk
    · interval_cases k
      · rw [gueMoment_zero]; norm_num
      · rw [gueMoment_one]; norm_num [Nat.factorial]
    · have := gueMoment_div_poissonMoment_le k hk
      rwa [poissonMoment_eq_factorial] at this
  have hterm : ∀ k : ℕ, 0 ≤ gueMoment k * t ^ k / (Nat.factorial k : ℝ) := by
    intro k
    have := (gueMoment_pos k).le
    positivity
  refine Summable.even_add_odd ?_ ?_
  · refine Summable.of_nonneg_of_le (fun m => hterm (2 * m)) (fun m => ?_) (hgeo.mul_left 2)
    have h := hbound (2 * m)
    have hidx : 2 * m / 2 = m := by omega
    rw [hidx] at h
    have ht2 : (0:ℝ) ≤ t ^ (2 * m) := by positivity
    calc gueMoment (2 * m) * t ^ (2 * m) / (Nat.factorial (2 * m) : ℝ)
        = (gueMoment (2 * m) / (Nat.factorial (2 * m) : ℝ)) * t ^ (2 * m) := by ring
      _ ≤ (2 * (1 / 2 : ℝ) ^ m) * t ^ (2 * m) := by
          exact mul_le_mul_of_nonneg_right h ht2
      _ = 2 * (t ^ 2 / 2) ^ m := by
          rw [pow_mul]; ring
  · refine Summable.of_nonneg_of_le (fun m => hterm (2 * m + 1)) (fun m => ?_)
      ((hgeo.mul_left 2).mul_left t)
    have h := hbound (2 * m + 1)
    have hidx : (2 * m + 1) / 2 = m := by omega
    rw [hidx] at h
    have ht2 : (0:ℝ) ≤ t ^ (2 * m + 1) := by positivity
    calc gueMoment (2 * m + 1) * t ^ (2 * m + 1) / (Nat.factorial (2 * m + 1) : ℝ)
        = (gueMoment (2 * m + 1) / (Nat.factorial (2 * m + 1) : ℝ)) * t ^ (2 * m + 1) := by ring
      _ ≤ (2 * (1 / 2 : ℝ) ^ m) * t ^ (2 * m + 1) := by
          exact mul_le_mul_of_nonneg_right h ht2
      _ = t * (2 * (t ^ 2 / 2) ^ m) := by
          rw [pow_succ, pow_mul]; ring

/-- The exponential generating series of the Poisson fingerprint is the geometric
series, hence diverges for every `t ≥ 1`. -/
theorem poisson_egf_not_summable (t : ℝ) (ht : 1 ≤ t) :
    ¬ Summable (fun k : ℕ => poissonMoment k * t ^ k / (Nat.factorial k : ℝ)) := by
  have hfun : (fun k : ℕ => poissonMoment k * t ^ k / (Nat.factorial k : ℝ))
      = fun k : ℕ => t ^ k := by
    funext k
    rw [poissonMoment_eq_factorial]
    have : (Nat.factorial k : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero k)
    field_simp
  rw [hfun, summable_geometric_iff_norm_lt_one]
  simp only [Real.norm_eq_abs, not_lt, abs_of_nonneg (by linarith : (0:ℝ) ≤ t)]
  exact ht

/-- **Analytic separation band.**  For every `t` with `1 ≤ t` and `t² < 2` the GUE
exponential generating series converges while the Poisson one diverges: the pair
of moment sequences is separated by an entire interval of generating radii. -/
theorem egf_radius_separation (t : ℝ) (ht1 : 1 ≤ t) (ht2 : t ^ 2 < 2) :
    Summable (fun k : ℕ => gueMoment k * t ^ k / (Nat.factorial k : ℝ)) ∧
    ¬ Summable (fun k : ℕ => poissonMoment k * t ^ k / (Nat.factorial k : ℝ)) :=
  ⟨gue_egf_summable t (by linarith) ht2, poisson_egf_not_summable t ht1⟩

/-! ## Sharpness and an explicit finite-sample threshold -/

/-- **Sharpness of the separation constant.**  At exactly distance `sepConst/2`
from the rigid value `1` the classifier already switches regime, so the strict
inequality in `classify_eq_of_close` cannot be weakened to `≤`. -/
theorem classify_sharp :
    |(1 + 3 * π / 8) / 2 - 1| = sepConst / 2 ∧ classify ((1 + 3 * π / 8) / 2) ≠ classify 1 := by
  have hpi := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  constructor
  · rw [abs_of_nonneg (by nlinarith), sepConst]
    ring
  · rw [classify_rigid]
    unfold classify
    rw [if_neg (by norm_num), if_pos (by nlinarith)]
    exact one_ne_zero

/-- With a unit-constant `1/√n` fluctuation bound, `n ≥ 127` spacings already
suffice for a provably correct second-moment classification. -/
theorem classify_of_unit_fluctuation_127 (n : ℕ) (hn : 127 ≤ n) (s : Fin n → ℝ) (mu : ℝ)
    (hmu : mu = 1 ∨ mu = 3 * π / 8 ∨ mu = 2)
    (h : |empSecondMoment n s - mu| ≤ 1 / Real.sqrt n) :
    classify (empSecondMoment n s) = classify mu := by
  have hsep : 0.178 < sepConst := by
    unfold sepConst
    nlinarith [Real.pi_gt_d4]
  have hn' : (127 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  refine classify_of_sqrt_fluctuation 1 n s mu hmu ?_ (by simpa using h)
  have hsp := sepConst_pos
  have : (2 * 1 / sepConst) ^ 2 < 127 := by
    rw [div_pow, div_lt_iff₀ (by positivity)]
    nlinarith
  linarith

end

end MomentFingerprint