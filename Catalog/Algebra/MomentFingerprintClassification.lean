/-
# Moment Fingerprint Classification of Spectral Statistics

Three universality classes of normalized nearest-neighbour level spacings:

* **rigid** (picket fence / harmonic oscillator): all spacings equal `1`,
  i.e. the Dirac mass `δ₁`;
* **GUE**: the Wigner surmise for `β = 2`, density `(32/π²) s² exp (-(4/π) s²)`;
* **Poisson**: the exponential law of mean one, density `exp (-s)`.

All three are probability densities on `(0, ∞)` with mean `1`; the classical
variance ordering is `0 < 3π/8 - 1 < 1`.  This file extends that single
comparison to the **entire moment sequence**:

* `gueMoment_gamma`       : a closed Gamma-form for every moment of the surmise;
* `gueMoment_succ_succ`   : the antiderivative (integration-by-parts) recursion
  `M_{k+2} = ((k+3)π/8)·M_k`;
* `gueMoment_even`, `gueMoment_odd` : the closed forms
  `M_{2m} = (2m+1)‼·(π/8)^m` and `M_{2m+1} = (m+1)!·(π/4)^m`;
* `poissonMoment_eq_factorial` : `P_k = k!`;
* `moment_fingerprint_ordering` : `1 < M_k < k!` for every `k ≥ 2`;
* `gueMoment_eq_poissonMoment_iff` : the two moment sequences agree **exactly**
  at `k = 0` and `k = 1` and nowhere else — there is *no* higher coincidence
  (the `π`-powers in the closed forms make one sequence sub-factorial);
* `gueMoment_div_poissonMoment_tendsto_zero` : the fingerprint ratio decays to `0`.

Finally, the second moment alone is a *classifier*: the three model second
moments `1 < 3π/8 < 2` are separated by the explicit constant
`sepConst = 3π/8 - 1`, and any empirical second moment of a finite spectrum
deviating from its model value by `O(n^{-1/2})` is classified correctly as soon
as `n > (2C/sepConst)²`.

The catalog module `Computation.SpectralPoissonVsGUE` referenced by the mission
is not present in this repository, so the development below is self-contained.

## Lab notes (numerical data behind the theorems)

Numerical quadrature of `∫₀^∞ sᵏ p(s) ds` on `[0,25]` (trapezoid, 2·10⁵ nodes)
versus the closed forms proved below:

```
k    quadrature   closed form            k!        M_k/k!      bound 2·2^{-⌊k/2⌋}
0    1.000000     1                      1         1.000000    2
1    1.000000     1                      1         1.000000    2
2    1.178097     3π/8    = 1.178097     2         0.589049    1
3    1.570796     π/2     = 1.570796     6         0.261799    1
4    2.313189     15π²/64 = 2.313189     24        0.096383    0.5
6    6.358709     105(π/8)³               720       0.008832    0.25
8   22.473533     945(π/8)⁴               40320     0.000557    0.125
10  97.078693     10395(π/8)⁵             3628800   0.0000268   0.0625
```

A scan of `2 ≤ k ≤ 10⁴` found no `k` with `M_k = k!`, matching
`gueMoment_eq_poissonMoment_iff`.  The even coefficients `1, 3, 15, 105, 945`
are the double factorials (OEIS A001147); the odd coefficients `1, 2, 6, 24` are
factorials (OEIS A000142).  Full data in `ComputationalEvidence.md`.
-/
import Mathlib

open Real MeasureTheory Set Filter Topology

namespace MomentFingerprint

noncomputable section

/-! ## Densities and moments -/

/-- Wigner surmise for the GUE (`β = 2`), a probability density on `(0, ∞)`. -/
def gueDensity (s : ℝ) : ℝ := (32 / π ^ 2) * s ^ 2 * exp (-(4 / π) * s ^ 2)

/-- Exponential ("Poisson spectrum") spacing density of mean one. -/
def poissonDensity (s : ℝ) : ℝ := exp (-s)

/-- `k`-th moment of the Wigner surmise. -/
def gueMoment (k : ℕ) : ℝ := ∫ s in Ioi (0 : ℝ), s ^ k * gueDensity s

/-- `k`-th moment of the exponential spacing law. -/
def poissonMoment (k : ℕ) : ℝ := ∫ s in Ioi (0 : ℝ), s ^ k * poissonDensity s

/-- `k`-th moment of the rigid (picket-fence) spectrum: the Dirac mass at `1`. -/
def rigidMoment (_k : ℕ) : ℝ := 1

/-! ## Closed forms -/

theorem poissonMoment_eq_factorial (k : ℕ) : poissonMoment k = (Nat.factorial k : ℝ) := by
  unfold poissonMoment poissonDensity
  rw [← Real.Gamma_nat_eq_factorial, Real.Gamma_eq_integral (by positivity : (0:ℝ) < (k:ℝ) + 1)]
  refine setIntegral_congr_fun measurableSet_Ioi (fun x hx => ?_)
  have hx0 : (0:ℝ) < x := hx
  rw [show ((k:ℝ) + 1 - 1) = ((k : ℕ) : ℝ) by ring, Real.rpow_natCast]
  ring

/-- Every moment of the Wigner surmise in closed Gamma form:
`M_k = (16/π²)·(π/4)^((k+3)/2)·Γ((k+3)/2)`. -/
theorem gueMoment_gamma (k : ℕ) :
    gueMoment k = (16 / π ^ 2) * (π / 4) ^ (((k : ℝ) + 3) / 2) * Gamma (((k : ℝ) + 3) / 2) := by
  have hpi := Real.pi_pos
  have hb : (0:ℝ) < 4 / π := by positivity
  have key := integral_rpow_mul_exp_neg_mul_rpow (p := 2) (q := (k:ℝ) + 2) (b := 4 / π)
      (by norm_num) (by linarith [Nat.cast_nonneg (α := ℝ) k]) hb
  have e1 : gueMoment k
      = (32 / π ^ 2) * ∫ s in Ioi (0:ℝ), s ^ ((k:ℝ) + 2) * exp (-(4 / π) * s ^ (2:ℝ)) := by
    unfold gueMoment gueDensity
    rw [← integral_const_mul]
    refine setIntegral_congr_fun measurableSet_Ioi (fun x hx => ?_)
    have hx0 : (0:ℝ) < x := hx
    rw [show ((k:ℝ) + 2) = ((k + 2 : ℕ) : ℝ) by push_cast; ring, Real.rpow_natCast,
      show ((2:ℝ)) = ((2:ℕ) : ℝ) by norm_num, Real.rpow_natCast]
    ring
  rw [e1, key, show (-((k:ℝ) + 2 + 1) / 2) = -(((k:ℝ) + 3) / 2) by ring,
    show ((k:ℝ) + 2 + 1) / 2 = ((k:ℝ) + 3) / 2 by ring, Real.rpow_neg hb.le,
    ← Real.inv_rpow hb.le, show (4 / π : ℝ)⁻¹ = π / 4 by field_simp]
  ring

private theorem sqrt_pi_div_four : √(π / 4) = √π / 2 := by
  rw [Real.sqrt_div' _ (by norm_num), show (4:ℝ) = 2 ^ 2 by norm_num,
    Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 2)]

private theorem gamma_three_halves : Gamma ((3:ℝ) / 2) = √π / 2 := by
  have h := Real.Gamma_add_one (s := (1/2 : ℝ)) (by norm_num)
  rw [Real.Gamma_one_half_eq] at h
  rw [show (3:ℝ) / 2 = 1/2 + 1 by norm_num, h]; ring

/-- Normalization: the Wigner surmise is a probability density. -/
theorem gueMoment_zero : gueMoment 0 = 1 := by
  have hpi := Real.pi_pos
  rw [gueMoment_gamma]
  have hr : (π / 4 : ℝ) ^ ((3:ℝ) / 2) = (π / 4) * (√π / 2) := by
    rw [show (3:ℝ) / 2 = 1 + 1/2 by norm_num, Real.rpow_add (by positivity), Real.rpow_one,
      ← Real.sqrt_eq_rpow, sqrt_pi_div_four]
  rw [show ((((0:ℕ) : ℝ) + 3) / 2) = (3:ℝ) / 2 by norm_num, hr, gamma_three_halves]
  have hs : √π * √π = π := Real.mul_self_sqrt hpi.le
  field_simp
  nlinarith [hs]

/-- The Wigner surmise has mean one. -/
theorem gueMoment_one : gueMoment 1 = 1 := by
  have hpi := Real.pi_pos
  rw [gueMoment_gamma, show ((((1:ℕ) : ℝ) + 3) / 2) = (2:ℝ) by norm_num,
    show ((2:ℝ)) = ((2:ℕ) : ℝ) by norm_num, Real.rpow_natCast,
    show (((2:ℕ)) : ℝ) = ((1:ℕ) : ℝ) + 1 by norm_num, Real.Gamma_nat_eq_factorial]
  norm_num
  field_simp
  ring

/-- **The antiderivative recursion.**  Integration by parts against the Gaussian
antiderivative, iterated once, gives `M_{k+2} = ((k+3)π/8)·M_k` for *every* `k`
(both parities at once). -/
theorem gueMoment_succ_succ (k : ℕ) :
    gueMoment (k + 2) = (((k : ℝ) + 3) * π / 8) * gueMoment k := by
  have hpi := Real.pi_pos
  rw [gueMoment_gamma, gueMoment_gamma]
  set t : ℝ := ((k : ℝ) + 3) / 2 with ht
  have ht0 : t ≠ 0 := by positivity
  have harg : (((k + 2 : ℕ) : ℝ) + 3) / 2 = t + 1 := by push_cast [ht]; ring
  rw [harg, Real.rpow_add (by positivity), Real.rpow_one, Real.Gamma_add_one ht0, ht]
  ring

/-- Closed form for the even moments: `M_{2m} = (2m+1)‼·(π/8)^m`. -/
theorem gueMoment_even (m : ℕ) :
    gueMoment (2 * m) = (Nat.doubleFactorial (2 * m + 1) : ℝ) * (π / 8) ^ m := by
  induction m with
  | zero => simpa [Nat.doubleFactorial] using gueMoment_zero
  | succ n ih =>
    have hstep : gueMoment (2 * (n + 1)) = (((2 * n : ℕ) : ℝ) + 3) * π / 8 * gueMoment (2 * n) := by
      rw [show 2 * (n + 1) = 2 * n + 2 by ring, gueMoment_succ_succ]
    have hdf : Nat.doubleFactorial (2 * (n + 1) + 1)
        = (2 * n + 3) * Nat.doubleFactorial (2 * n + 1) := by
      rw [show 2 * (n + 1) + 1 = (2 * n + 1) + 2 by ring, Nat.doubleFactorial]
    rw [hstep, ih, hdf]
    push_cast
    ring

/-- Closed form for the odd moments: `M_{2m+1} = (m+1)!·(π/4)^m`. -/
theorem gueMoment_odd (m : ℕ) :
    gueMoment (2 * m + 1) = (Nat.factorial (m + 1) : ℝ) * (π / 4) ^ m := by
  induction m with
  | zero => simpa using gueMoment_one
  | succ n ih =>
    have hstep : gueMoment (2 * (n + 1) + 1)
        = (((2 * n + 1 : ℕ) : ℝ) + 3) * π / 8 * gueMoment (2 * n + 1) := by
      rw [show 2 * (n + 1) + 1 = (2 * n + 1) + 2 by ring, gueMoment_succ_succ]
    have hfac : Nat.factorial (n + 1 + 1) = (n + 2) * Nat.factorial (n + 1) := by
      rw [Nat.factorial_succ]
    rw [hstep, ih, hfac]
    push_cast
    ring

theorem gueMoment_two : gueMoment 2 = 3 * π / 8 := by
  have h := gueMoment_even 1
  norm_num [Nat.doubleFactorial] at h ⊢
  linarith [h]

theorem gueMoment_three : gueMoment 3 = π / 2 := by
  have h := gueMoment_odd 1
  norm_num [Nat.factorial] at h ⊢
  linarith [h]

theorem gueMoment_four : gueMoment 4 = 15 * π ^ 2 / 64 := by
  have h := gueMoment_even 2
  norm_num [Nat.doubleFactorial] at h ⊢
  rw [h]; ring

theorem poissonMoment_two : poissonMoment 2 = 2 := by
  rw [poissonMoment_eq_factorial]; norm_num [Nat.factorial]

/-! ## The variance ordering: the classical base case -/

/-- The three spacing variances `0 < 3π/8 - 1 < 1` are strictly ordered
(all three laws have mean one, so the variance is `M₂ - 1`). -/
theorem variance_ordering :
    (0 : ℝ) < gueMoment 2 - 1 ∧ gueMoment 2 - 1 < poissonMoment 2 - 1 := by
  rw [gueMoment_two, poissonMoment_two]
  constructor
  · nlinarith [Real.pi_gt_d2]
  · nlinarith [Real.pi_lt_d2]

/-! ## The full moment ordering -/

/-- Beyond the mean, every Wigner-surmise moment strictly exceeds the rigid value `1`. -/
theorem gueMoment_gt_one (k : ℕ) (hk : 2 ≤ k) : 1 < gueMoment k := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 2 := ⟨k - 2, by omega⟩
  clear hk
  induction j using Nat.strong_induction_on with
  | _ j ih =>
    match j with
    | 0 => rw [gueMoment_two]; nlinarith [Real.pi_gt_d2]
    | 1 => rw [show 1 + 2 = 3 from rfl, gueMoment_three]; nlinarith [Real.pi_gt_d2]
    | (n + 2) =>
      have hprev : 1 < gueMoment (n + 2) := ih n (by omega)
      have hrec : gueMoment (n + 2 + 2) = (((n + 2 : ℕ) : ℝ) + 3) * π / 8 * gueMoment (n + 2) :=
        gueMoment_succ_succ (n + 2)
      have hcoef : (1:ℝ) < (((n + 2 : ℕ) : ℝ) + 3) * π / 8 := by
        have : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
        push_cast
        nlinarith [Real.pi_gt_d2]
      rw [hrec]
      nlinarith

/-- Every Wigner-surmise moment beyond the mean is strictly below the exponential
moment `k!`: the two fingerprints separate at every order `k ≥ 2`. -/
theorem gueMoment_lt_poissonMoment (k : ℕ) (hk : 2 ≤ k) : gueMoment k < poissonMoment k := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 2 := ⟨k - 2, by omega⟩
  clear hk
  induction j using Nat.strong_induction_on with
  | _ j ih =>
    match j with
    | 0 =>
      rw [gueMoment_two, poissonMoment_eq_factorial]
      norm_num [Nat.factorial]
      nlinarith [Real.pi_lt_d2]
    | 1 =>
      rw [show 1 + 2 = 3 from rfl, gueMoment_three, poissonMoment_eq_factorial]
      norm_num [Nat.factorial]
      nlinarith [Real.pi_lt_d2]
    | (n + 2) =>
      have hprev : gueMoment (n + 2) < poissonMoment (n + 2) := ih n (by omega)
      have hpos : 1 < gueMoment (n + 2) := gueMoment_gt_one (n + 2) (by omega)
      have hrec : gueMoment (n + 2 + 2) = (((n + 2 : ℕ) : ℝ) + 3) * π / 8 * gueMoment (n + 2) :=
        gueMoment_succ_succ (n + 2)
      have hfac : poissonMoment (n + 2 + 2)
          = (((n : ℝ) + 4) * ((n : ℝ) + 3)) * poissonMoment (n + 2) := by
        rw [poissonMoment_eq_factorial, poissonMoment_eq_factorial,
          show n + 2 + 2 = (n + 3) + 1 by ring, Nat.factorial_succ,
          show n + 3 = (n + 2) + 1 by ring, Nat.factorial_succ]
        push_cast; ring
      have hn : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      have hcoef : (((n + 2 : ℕ) : ℝ) + 3) * π / 8 < ((n : ℝ) + 4) * ((n : ℝ) + 3) := by
        push_cast
        nlinarith [Real.pi_lt_d2]
      have hppos : 0 < poissonMoment (n + 2) := by linarith
      have hcpos : 0 < (((n + 2 : ℕ) : ℝ) + 3) * π / 8 := by
        have := Real.pi_pos; push_cast; positivity
      rw [hrec, hfac]
      calc (((n + 2 : ℕ) : ℝ) + 3) * π / 8 * gueMoment (n + 2)
          < (((n + 2 : ℕ) : ℝ) + 3) * π / 8 * poissonMoment (n + 2) := by
            exact mul_lt_mul_of_pos_left hprev hcpos
        _ < ((n : ℝ) + 4) * ((n : ℝ) + 3) * poissonMoment (n + 2) := by
            exact mul_lt_mul_of_pos_right hcoef hppos

/-- **Moment fingerprint ordering.**  Beyond the first two (universal) moments the
three regimes are strictly ordered, moment by moment:
`rigid < GUE < Poisson`. -/
theorem moment_fingerprint_ordering (k : ℕ) (hk : 2 ≤ k) :
    rigidMoment k < gueMoment k ∧ gueMoment k < poissonMoment k :=
  ⟨gueMoment_gt_one k hk, gueMoment_lt_poissonMoment k hk⟩

/-- **No higher moment coincidence.**  The Wigner-surmise and exponential moment
sequences agree precisely at `k = 0` and `k = 1`; the speculation that some
higher moment coincidence relates the two laws is *false*. -/
theorem gueMoment_eq_poissonMoment_iff (k : ℕ) :
    gueMoment k = poissonMoment k ↔ k ≤ 1 := by
  constructor
  · intro h
    by_contra hk
    exact absurd h (ne_of_lt (gueMoment_lt_poissonMoment k (by omega)))
  · intro hk
    interval_cases k
    · rw [gueMoment_zero, poissonMoment_eq_factorial]; norm_num
    · rw [gueMoment_one, poissonMoment_eq_factorial]; norm_num

/-! ## Decay of the fingerprint ratio -/

theorem poissonMoment_pos (k : ℕ) : 0 < poissonMoment k := by
  rw [poissonMoment_eq_factorial]
  exact_mod_cast Nat.factorial_pos k

theorem gueMoment_pos (k : ℕ) : 0 < gueMoment k := by
  rcases Nat.lt_or_ge k 2 with hk | hk
  · interval_cases k
    · rw [gueMoment_zero]; norm_num
    · rw [gueMoment_one]; norm_num
  · linarith [gueMoment_gt_one k hk]

/-- The fingerprint ratio `M_k / k!` decays at least geometrically. -/
theorem gueMoment_div_poissonMoment_le (k : ℕ) (hk : 2 ≤ k) :
    gueMoment k / poissonMoment k ≤ 2 * (1 / 2 : ℝ) ^ (k / 2) := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 2 := ⟨k - 2, by omega⟩
  clear hk
  induction j using Nat.strong_induction_on with
  | _ j ih =>
    match j with
    | 0 =>
      rw [gueMoment_two, poissonMoment_two]
      norm_num
      nlinarith [Real.pi_lt_d2]
    | 1 =>
      rw [show 1 + 2 = 3 from rfl, gueMoment_three, poissonMoment_eq_factorial]
      norm_num [Nat.factorial]
      nlinarith [Real.pi_lt_d2]
    | (n + 2) =>
      have hprev := ih n (by omega)
      have hrec : gueMoment (n + 2 + 2) = (((n + 2 : ℕ) : ℝ) + 3) * π / 8 * gueMoment (n + 2) :=
        gueMoment_succ_succ (n + 2)
      have hfac : poissonMoment (n + 2 + 2)
          = (((n : ℝ) + 4) * ((n : ℝ) + 3)) * poissonMoment (n + 2) := by
        rw [poissonMoment_eq_factorial, poissonMoment_eq_factorial,
          show n + 2 + 2 = (n + 3) + 1 by ring, Nat.factorial_succ,
          show n + 3 = (n + 2) + 1 by ring, Nat.factorial_succ]
        push_cast; ring
      have hn : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      have hP := poissonMoment_pos (n + 2)
      have hG := gueMoment_pos (n + 2)
      have hhalf : (((n + 2 : ℕ) : ℝ) + 3) * π / 8 / (((n : ℝ) + 4) * ((n : ℝ) + 3)) ≤ 1 / 2 := by
        rw [div_le_div_iff₀ (by positivity) (by norm_num)]
        push_cast
        nlinarith [Real.pi_lt_d2]
      have hdiv : gueMoment (n + 2 + 2) / poissonMoment (n + 2 + 2)
          = ((((n + 2 : ℕ) : ℝ) + 3) * π / 8 / (((n : ℝ) + 4) * ((n : ℝ) + 3)))
            * (gueMoment (n + 2) / poissonMoment (n + 2)) := by
        rw [hrec, hfac]
        field_simp
      have hratio_nonneg : 0 ≤ gueMoment (n + 2) / poissonMoment (n + 2) := by positivity
      have hcoef_nonneg : 0 ≤ (((n + 2 : ℕ) : ℝ) + 3) * π / 8 / (((n : ℝ) + 4) * ((n : ℝ) + 3)) := by
        have := Real.pi_pos
        positivity
      have hidx : (n + 2 + 2) / 2 = (n + 2) / 2 + 1 := by omega
      rw [hdiv, hidx, pow_succ]
      calc (((n + 2 : ℕ) : ℝ) + 3) * π / 8 / (((n : ℝ) + 4) * ((n : ℝ) + 3))
              * (gueMoment (n + 2) / poissonMoment (n + 2))
          ≤ (1 / 2 : ℝ) * (2 * (1 / 2 : ℝ) ^ ((n + 2) / 2)) := by
            apply mul_le_mul hhalf hprev hratio_nonneg (by norm_num)
        _ = 2 * ((1 / 2 : ℝ) ^ ((n + 2) / 2) * (1 / 2)) := by ring

/-- The GUE fingerprint is asymptotically negligible against the Poisson one. -/
theorem gueMoment_div_poissonMoment_tendsto_zero :
    Tendsto (fun k => gueMoment k / poissonMoment k) atTop (𝓝 0) := by
  have hbound : Tendsto (fun k : ℕ => 2 * (1 / 2 : ℝ) ^ (k / 2)) atTop (𝓝 0) := by
    have hd : Tendsto (fun k : ℕ => k / 2) atTop atTop := by
      apply tendsto_atTop_atTop.2
      intro b
      exact ⟨2 * b, fun a ha => by omega⟩
    have hp : Tendsto (fun n : ℕ => (1 / 2 : ℝ) ^ n) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
    have := (hp.comp hd).const_mul (2 : ℝ)
    simpa using this
  refine squeeze_zero' (Eventually.of_forall fun k => ?_) ?_ hbound
  · exact div_nonneg (gueMoment_pos k).le (poissonMoment_pos k).le
  · filter_upwards [eventually_ge_atTop 2] with k hk using gueMoment_div_poissonMoment_le k hk

/-! ## Second-moment classification of finite spectra -/

/-- The explicit separation constant between the three model second moments
`1 < 3π/8 < 2`: the minimal adjacent gap. -/
def sepConst : ℝ := 3 * π / 8 - 1

theorem sepConst_pos : 0 < sepConst := by
  unfold sepConst; nlinarith [Real.pi_gt_d2]

/-- `sepConst` really is the *minimal* gap: the upper gap `2 - 3π/8` is larger. -/
theorem sepConst_le_upper_gap : sepConst ≤ 2 - 3 * π / 8 := by
  unfold sepConst; nlinarith [Real.pi_lt_d2]

/-- The classifier: `0 = rigid`, `1 = GUE`, `2 = Poisson`, decided by the two
midpoints between the three model second moments. -/
def classify (x : ℝ) : ℕ :=
  if x < (1 + 3 * π / 8) / 2 then 0 else if x < (3 * π / 8 + 2) / 2 then 1 else 2

theorem classify_rigid : classify 1 = 0 := by
  unfold classify
  rw [if_pos]
  nlinarith [Real.pi_gt_d2]

theorem classify_gue : classify (3 * π / 8) = 1 := by
  unfold classify
  rw [if_neg (by nlinarith [Real.pi_gt_d2]), if_pos (by nlinarith [Real.pi_lt_d2])]

theorem classify_poisson : classify 2 = 2 := by
  unfold classify
  rw [if_neg (by nlinarith [Real.pi_lt_d2]), if_neg (by nlinarith [Real.pi_lt_d2])]

/-- **Separation theorem.**  A statistic within `sepConst/2` of a model second
moment is classified as that regime; the three basins are therefore disjoint and
the classification is stable under perturbations smaller than `sepConst/2`. -/
theorem classify_eq_of_close (mu x : ℝ) (hmu : mu = 1 ∨ mu = 3 * π / 8 ∨ mu = 2)
    (h : |x - mu| < sepConst / 2) : classify x = classify mu := by
  have hpi1 := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  rw [abs_lt] at h
  obtain ⟨h1, h2⟩ := h
  unfold sepConst at h1 h2
  rcases hmu with rfl | rfl | rfl
  · rw [classify_rigid]
    unfold classify
    rw [if_pos (by linarith)]
  · rw [classify_gue]
    unfold classify
    rw [if_neg (by linarith), if_pos (by linarith)]
  · rw [classify_poisson]
    unfold classify
    rw [if_neg (by linarith), if_neg (by linarith)]

/-- Empirical second moment of `n` normalized spacings. -/
def empSecondMoment (n : ℕ) (s : Fin n → ℝ) : ℝ := (∑ i, (s i) ^ 2) / n

/-- **Classification under `n^{-1/2}` fluctuations.**  If the empirical second
moment of a finite spectrum deviates from its model value by at most `C/√n`,
then the second-moment classifier returns the right regime as soon as
`n > (2C/sepConst)²`.  This is the promised "one computable statistic with a
proved separation constant". -/
theorem classify_of_sqrt_fluctuation (C : ℝ) (n : ℕ) (s : Fin n → ℝ) (mu : ℝ)
    (hmu : mu = 1 ∨ mu = 3 * π / 8 ∨ mu = 2)
    (hn : (2 * C / sepConst) ^ 2 < n)
    (h : |empSecondMoment n s - mu| ≤ C / Real.sqrt n) :
    classify (empSecondMoment n s) = classify mu := by
  have hsep := sepConst_pos
  have hCnn : 0 ≤ C := by
    by_contra hC
    push_neg at hC
    have h1 : 0 ≤ |empSecondMoment n s - mu| := abs_nonneg _
    have hnpos : (0:ℝ) < n := by nlinarith [sq_nonneg (2 * C / sepConst)]
    have : C / Real.sqrt n < 0 := div_neg_of_neg_of_pos hC (Real.sqrt_pos.2 hnpos)
    linarith
  have hnpos : (0:ℝ) < n := by nlinarith [sq_nonneg (2 * C / sepConst)]
  have hsqrt : 2 * C / sepConst < Real.sqrt n := by
    have h0 : 0 ≤ 2 * C / sepConst := by positivity
    nlinarith [Real.sq_sqrt hnpos.le, Real.sqrt_nonneg (n : ℝ),
      Real.sqrt_pos.2 hnpos]
  have hlt : C / Real.sqrt n < sepConst / 2 := by
    have hs : 0 < Real.sqrt n := Real.sqrt_pos.2 hnpos
    rw [div_lt_div_iff₀ hs (by norm_num)]
    rw [div_lt_iff₀ hsep] at hsqrt
    linarith
  exact classify_eq_of_close mu _ hmu (lt_of_le_of_lt h hlt)

/-- A perfectly rigid spectrum (eigenvalues in arithmetic progression with unit
mean spacing) has empirical second moment exactly `1`, hence is classified as the
rigid regime. -/
theorem classify_arithmetic_spectrum (n : ℕ) (hn : 0 < n) (a : ℝ)
    (lam : Fin (n + 1) → ℝ) (hlam : ∀ i : Fin (n + 1), lam i = a + (i : ℕ)) :
    classify (empSecondMoment n (fun i : Fin n => lam i.succ - lam i.castSucc)) = 0 := by
  have hspacing : ∀ i : Fin n, lam i.succ - lam i.castSucc = 1 := by
    intro i
    rw [hlam, hlam, Fin.val_succ, Fin.val_castSucc]
    push_cast
    ring
  have hemp : empSecondMoment n (fun i : Fin n => lam i.succ - lam i.castSucc) = 1 := by
    unfold empSecondMoment
    have : ∀ i : Fin n, (lam i.succ - lam i.castSucc) ^ 2 = 1 := by
      intro i; rw [hspacing i]; norm_num
    simp only [this, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
    field_simp
  rw [hemp, classify_rigid]

end

end MomentFingerprint