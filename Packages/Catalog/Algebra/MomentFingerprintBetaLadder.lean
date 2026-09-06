/-
# The β-Ladder: Five Spectral Regimes Separated by One Statistic

Fourth research cycle, built on `Algebra.MomentFingerprintClassification`.

The Wigner surmise exists for every symmetry class:

* GOE (`β = 1`): `p₁(s) = (π/2)·s·exp(-π s²/4)`, second moment `4/π`;
* GUE (`β = 2`): `p₂(s) = (32/π²)·s²·exp(-4s²/π)`, second moment `3π/8`;
* GSE (`β = 4`): `p₄(s) = (2¹⁸/(3⁶π³))·s⁴·exp(-64 s²/(9π))`, second moment `45π/128`.

All of them are treated here by one generic family `surmiseMoment β a b k`, for
which we prove the Gamma closed form and the antiderivative recursion
`M_{k+2} = ((k+β+1)/(2b))·M_k`.  The recursion turns each normalization `M₀ = 1`
into the second moment for free.

The main results:

* `surmiseMoment_gamma`, `surmiseMoment_succ_succ` : generic closed form and recursion;
* `gueMoment_eq_surmise` : the earlier GUE development is the `β = 2` instance;
* `variance_ladder` : `1 < 45π/128 < 3π/8 < 4/π < 2`, i.e. the *five* regimes
  rigid ≺ GSE ≺ GUE ≺ GOE ≺ Poisson are strictly ordered by the second moment;
* `ladderGap_le_gaps` : the minimal adjacent gap is exactly `3π/128`;
* `classify5_eq_of_close`, `classify5_of_sqrt_fluctuation` : one computable
  statistic classifies a finite spectrum among all five regimes, with the proved
  separation constant `3π/128` and an explicit `n^{-1/2}` sample threshold.
-/
import Algebra.MomentFingerprintClassification

open Real MeasureTheory Set Filter Topology

namespace MomentFingerprint

noncomputable section

/-! ## A generic surmise family -/

/-- `k`-th moment of the generalized Wigner surmise `a·s^β·exp(-b s²)` on `(0,∞)`. -/
def surmiseMoment (bta : ℕ) (a b : ℝ) (k : ℕ) : ℝ :=
  ∫ s in Ioi (0 : ℝ), s ^ k * (a * s ^ bta * exp (-b * s ^ 2))

/-- Closed Gamma form for the generic surmise moments. -/
theorem surmiseMoment_gamma (bta k : ℕ) (a : ℝ) {b : ℝ} (hb : 0 < b) :
    surmiseMoment bta a b k
      = a * (1 / 2) * b ^ (-(((k + bta : ℕ) : ℝ) + 1) / 2) * Gamma ((((k + bta : ℕ) : ℝ) + 1) / 2) := by
  have key := integral_rpow_mul_exp_neg_mul_rpow (p := 2) (q := ((k + bta : ℕ) : ℝ)) (b := b)
      (by norm_num) (by linarith [Nat.cast_nonneg (α := ℝ) (k + bta)]) hb
  have e1 : surmiseMoment bta a b k
      = a * ∫ s in Ioi (0:ℝ), s ^ ((k + bta : ℕ) : ℝ) * exp (-b * s ^ (2:ℝ)) := by
    unfold surmiseMoment
    rw [← integral_const_mul]
    refine setIntegral_congr_fun measurableSet_Ioi (fun x hx => ?_)
    have hx0 : (0:ℝ) < x := hx
    rw [Real.rpow_natCast x (k + bta), show ((2:ℝ)) = ((2:ℕ) : ℝ) by norm_num,
      Real.rpow_natCast x 2, pow_add]
    ring
  rw [e1, key, show (-(((k + bta : ℕ) : ℝ) + 1) / 2) = -(((k + bta : ℕ) : ℝ) + 1) / 2 from rfl]
  ring

/-- The antiderivative recursion for the generic surmise family. -/
theorem surmiseMoment_succ_succ (bta k : ℕ) (a : ℝ) {b : ℝ} (hb : 0 < b) :
    surmiseMoment bta a b (k + 2)
      = ((((k + bta : ℕ) : ℝ) + 1) / (2 * b)) * surmiseMoment bta a b k := by
  rw [surmiseMoment_gamma bta (k + 2) a hb, surmiseMoment_gamma bta k a hb]
  set t : ℝ := (((k + bta : ℕ) : ℝ) + 1) / 2 with ht
  have ht0 : t ≠ 0 := by
    have : (0:ℝ) ≤ ((k + bta : ℕ) : ℝ) := Nat.cast_nonneg _
    rw [ht]; positivity
  have harg : ((((k + 2 + bta : ℕ)) : ℝ) + 1) / 2 = t + 1 := by push_cast [ht]; ring
  have hexp : (-(((k + 2 + bta : ℕ) : ℝ) + 1) / 2)
      = (-(((k + bta : ℕ) : ℝ) + 1) / 2) + (-1 : ℝ) := by push_cast; ring
  rw [harg, Real.Gamma_add_one ht0, hexp, Real.rpow_add hb, Real.rpow_neg_one, ht]
  field_simp

/-- The GUE development of `MomentFingerprintClassification` is the `β = 2`
instance of the generic family. -/
theorem gueMoment_eq_surmise (k : ℕ) : gueMoment k = surmiseMoment 2 (32 / π ^ 2) (4 / π) k := by
  unfold gueMoment surmiseMoment gueDensity
  refine setIntegral_congr_fun measurableSet_Ioi (fun x _ => ?_)
  ring

/-! ## Half-integer powers helper -/

private theorem rpow_neg_three_halves (c : ℝ) (hc : 0 < c) :
    c ^ (-(3 / 2) : ℝ) = (c * Real.sqrt c)⁻¹ := by
  rw [show (-(3 / 2) : ℝ) = -(1 + 1 / 2) by norm_num, Real.rpow_neg hc.le,
    Real.rpow_add hc, Real.rpow_one, ← Real.sqrt_eq_rpow]

private theorem rpow_neg_five_halves (c : ℝ) (hc : 0 < c) :
    c ^ (-(5 / 2) : ℝ) = (c ^ 2 * Real.sqrt c)⁻¹ := by
  rw [show (-(5 / 2) : ℝ) = -(2 + 1 / 2) by norm_num, Real.rpow_neg hc.le,
    Real.rpow_add hc, ← Real.sqrt_eq_rpow,
    show ((2 : ℝ)) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]

private theorem sqrt_pi_div_four' : √(π / 4) = √π / 2 := by
  rw [Real.sqrt_div' _ (by norm_num), show (4:ℝ) = 2 ^ 2 by norm_num,
    Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 2)]

private theorem sqrt_sixtyfour_div : √(64 / (9 * π)) = 8 / (3 * √π) := by
  have hpi := Real.pi_pos
  have hs : √π * √π = π := Real.mul_self_sqrt hpi.le
  have hspos : 0 < √π := Real.sqrt_pos.2 hpi
  rw [show (64 : ℝ) / (9 * π) = (8 / (3 * √π)) ^ 2 by
    field_simp
    nlinarith [hs]]
  exact Real.sqrt_sq (by positivity)

private theorem gamma_three_halves' : Gamma ((3:ℝ) / 2) = √π / 2 := by
  have h := Real.Gamma_add_one (s := (1/2 : ℝ)) (by norm_num)
  rw [Real.Gamma_one_half_eq] at h
  rw [show (3:ℝ) / 2 = 1/2 + 1 by norm_num, h]; ring

private theorem gamma_five_halves : Gamma ((5:ℝ) / 2) = 3 * √π / 4 := by
  have h2 := Real.Gamma_add_one (s := (3/2 : ℝ)) (by norm_num)
  rw [gamma_three_halves'] at h2
  rw [show (5:ℝ) / 2 = 3/2 + 1 by norm_num, h2]
  ring

/-! ## GOE (β = 1) -/

/-- Moments of the GOE Wigner surmise `p₁(s) = (π/2)·s·exp(-π s²/4)`. -/
def goeMoment (k : ℕ) : ℝ := surmiseMoment 1 (π / 2) (π / 4) k

theorem goeMoment_zero : goeMoment 0 = 1 := by
  have hpi := Real.pi_pos
  unfold goeMoment
  rw [surmiseMoment_gamma 1 0 (π / 2) (by positivity)]
  norm_num
  rw [Real.rpow_neg_one]
  field_simp
  norm_num

theorem goeMoment_one : goeMoment 1 = 1 := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < π / 4 := by positivity
  have hs : √π * √π = π := Real.mul_self_sqrt hpi.le
  have hspos : 0 < √π := Real.sqrt_pos.2 hpi
  unfold goeMoment
  rw [surmiseMoment_gamma 1 1 (π / 2) hq]
  norm_num
  rw [rpow_neg_three_halves _ hq, gamma_three_halves', sqrt_pi_div_four']
  field_simp
  nlinarith [hs]

theorem goeMoment_two : goeMoment 2 = 4 / π := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < π / 4 := by positivity
  have h := surmiseMoment_succ_succ 1 0 (π / 2) hq
  have h0 : surmiseMoment 1 (π / 2) (π / 4) 0 = 1 := goeMoment_zero
  unfold goeMoment
  rw [h, h0]
  norm_num
  field_simp

/-! ## GSE (β = 4) -/

/-- Moments of the GSE Wigner surmise `p₄(s) = (2¹⁸/(3⁶π³))·s⁴·exp(-64 s²/(9π))`. -/
def gseMoment (k : ℕ) : ℝ := surmiseMoment 4 (262144 / (729 * π ^ 3)) (64 / (9 * π)) k

theorem gseMoment_zero : gseMoment 0 = 1 := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < 64 / (9 * π) := by positivity
  have hs : √π * √π = π := Real.mul_self_sqrt hpi.le
  have hspos : 0 < √π := Real.sqrt_pos.2 hpi
  unfold gseMoment
  rw [surmiseMoment_gamma 4 0 (262144 / (729 * π ^ 3)) hq]
  norm_num
  rw [rpow_neg_five_halves _ hq, gamma_five_halves, sqrt_sixtyfour_div]
  field_simp
  nlinarith [hs, sq_nonneg (√π * π), Real.pi_pos]

theorem gseMoment_one : gseMoment 1 = 1 := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < 64 / (9 * π) := by positivity
  unfold gseMoment
  rw [surmiseMoment_gamma 4 1 (262144 / (729 * π ^ 3)) hq]
  norm_num
  field_simp
  ring

theorem gseMoment_two : gseMoment 2 = 45 * π / 128 := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < 64 / (9 * π) := by positivity
  have h := surmiseMoment_succ_succ 4 0 (262144 / (729 * π ^ 3)) hq
  have h0 : surmiseMoment 4 (262144 / (729 * π ^ 3)) (64 / (9 * π)) 0 = 1 := gseMoment_zero
  unfold gseMoment
  rw [h, h0]
  norm_num
  field_simp
  ring

/-! ## The five-regime ladder -/

/-- **The β-ladder.**  The second moments of the five regimes
rigid, GSE, GUE, GOE, Poisson are strictly increasing. -/
theorem variance_ladder :
    (1 : ℝ) < 45 * π / 128 ∧ 45 * π / 128 < 3 * π / 8 ∧ 3 * π / 8 < 4 / π ∧ (4 : ℝ) / π < 2 := by
  have hpi := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  have hp : (0:ℝ) < π := Real.pi_pos
  refine ⟨by nlinarith, by nlinarith, ?_, ?_⟩
  · rw [lt_div_iff₀ hp]; nlinarith
  · rw [div_lt_iff₀ hp]; nlinarith

/-- The five model second moments, as a function of the regime index. -/
def ladderValue : ℕ → ℝ
  | 0 => 1
  | 1 => 45 * π / 128
  | 2 => 3 * π / 8
  | 3 => 4 / π
  | _ => 2

/-- The minimal adjacent gap of the ladder. -/
def ladderGap : ℝ := 3 * π / 128

theorem ladderGap_pos : 0 < ladderGap := by
  unfold ladderGap; positivity

/-- `ladderGap` is a lower bound for every adjacent gap of the ladder, and is
attained by the GSE/GUE pair. -/
theorem ladderGap_le_gaps :
    ladderGap ≤ 45 * π / 128 - 1 ∧ ladderGap = 3 * π / 8 - 45 * π / 128 ∧
    ladderGap ≤ 4 / π - 3 * π / 8 ∧ ladderGap ≤ 2 - 4 / π := by
  have hpi := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  have hp : (0:ℝ) < π := Real.pi_pos
  unfold ladderGap
  refine ⟨by nlinarith, by ring, ?_, ?_⟩
  · rw [le_sub_iff_add_le, le_div_iff₀ hp]
    nlinarith
  · have h4 : 4 / π < 1.28 := by rw [div_lt_iff₀ hp]; nlinarith
    linarith

/-- The five-regime classifier, by nearest ladder value. -/
def classify5 (x : ℝ) : ℕ :=
  if x < (1 + 45 * π / 128) / 2 then 0
  else if x < (45 * π / 128 + 3 * π / 8) / 2 then 1
  else if x < (3 * π / 8 + 4 / π) / 2 then 2
  else if x < (4 / π + 2) / 2 then 3
  else 4

/-- **Five-regime separation theorem.**  A statistic within `ladderGap/2 = 3π/256`
of a ladder value is classified into that regime. -/
theorem classify5_eq_of_close (i : ℕ) (hi : i ≤ 4) (x : ℝ)
    (h : |x - ladderValue i| < ladderGap / 2) : classify5 x = i := by
  have hpi := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  have hp : (0:ℝ) < π := Real.pi_pos
  have hinv1 : 1.269 < 4 / π := by rw [lt_div_iff₀ hp]; nlinarith
  have hinv2 : 4 / π < 1.274 := by rw [div_lt_iff₀ hp]; nlinarith
  rw [abs_lt] at h
  obtain ⟨h1, h2⟩ := h
  unfold ladderGap at h1 h2
  interval_cases i <;> simp only [ladderValue] at h1 h2 <;> unfold classify5
  · rw [if_pos (by nlinarith)]
  · rw [if_neg (by nlinarith), if_pos (by nlinarith)]
  · rw [if_neg (by nlinarith), if_neg (by nlinarith), if_pos (by nlinarith)]
  · rw [if_neg (by nlinarith), if_neg (by nlinarith), if_neg (by nlinarith),
      if_pos (by nlinarith)]
  · rw [if_neg (by nlinarith), if_neg (by nlinarith), if_neg (by nlinarith),
      if_neg (by nlinarith)]

/-- **Five-regime classification under `n^{-1/2}` fluctuations.** -/
theorem classify5_of_sqrt_fluctuation (C : ℝ) (n : ℕ) (s : Fin n → ℝ) (i : ℕ) (hi : i ≤ 4)
    (hn : (2 * C / ladderGap) ^ 2 < n)
    (h : |empSecondMoment n s - ladderValue i| ≤ C / Real.sqrt n) :
    classify5 (empSecondMoment n s) = i := by
  have hgap := ladderGap_pos
  have hCnn : 0 ≤ C := by
    by_contra hC
    push_neg at hC
    have hnpos : (0:ℝ) < n := by nlinarith [sq_nonneg (2 * C / ladderGap)]
    have : C / Real.sqrt n < 0 := div_neg_of_neg_of_pos hC (Real.sqrt_pos.2 hnpos)
    linarith [abs_nonneg (empSecondMoment n s - ladderValue i)]
  have hnpos : (0:ℝ) < n := by nlinarith [sq_nonneg (2 * C / ladderGap)]
  have hsqrt : 2 * C / ladderGap < Real.sqrt n := by
    have h0 : 0 ≤ 2 * C / ladderGap := by positivity
    nlinarith [Real.sq_sqrt hnpos.le, Real.sqrt_nonneg (n : ℝ), Real.sqrt_pos.2 hnpos]
  have hlt : C / Real.sqrt n < ladderGap / 2 := by
    have hs : 0 < Real.sqrt n := Real.sqrt_pos.2 hnpos
    rw [div_lt_div_iff₀ hs (by norm_num)]
    rw [div_lt_iff₀ hgap] at hsqrt
    linarith
  exact classify5_eq_of_close i hi _ (lt_of_le_of_lt h hlt)

/-- With a unit-constant `1/√n` fluctuation bound, `n ≥ 738` spacings suffice for
a provably correct classification among all *five* regimes. -/
theorem classify5_of_unit_fluctuation_738 (n : ℕ) (hn : 738 ≤ n) (s : Fin n → ℝ) (i : ℕ)
    (hi : i ≤ 4) (h : |empSecondMoment n s - ladderValue i| ≤ 1 / Real.sqrt n) :
    classify5 (empSecondMoment n s) = i := by
  have hgap : 0.073628 < ladderGap := by
    unfold ladderGap
    nlinarith [Real.pi_gt_d4]
  have hn' : (738 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  refine classify5_of_sqrt_fluctuation 1 n s i hi ?_ (by simpa using h)
  have hgp := ladderGap_pos
  have : (2 * 1 / ladderGap) ^ 2 < 738 := by
    rw [div_pow, div_lt_iff₀ (by positivity)]
    nlinarith
  linarith

/-! ## The full moment ladder: every moment order separates all five regimes -/

/-- A moment sequence generated by a two-step recursion with positive coefficients
and `M₀ = M₁ = 1` is positive. -/
theorem pos_of_recursion (A c : ℕ → ℝ) (hA0 : A 0 = 1) (hA1 : A 1 = 1)
    (hA : ∀ k, A (k + 2) = c k * A k) (hc : ∀ k, 0 < c k) : ∀ k, 0 < A k := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    match k with
    | 0 => rw [hA0]; norm_num
    | 1 => rw [hA1]; norm_num
    | (n + 2) => rw [hA n]; exact mul_pos (hc n) (ih n (by omega))

/-- Comparison principle: coefficientwise domination of the two-step recursions
gives strict domination of the moment sequences from order `2` on. -/
theorem lt_of_coeff_lt (A B cA cB : ℕ → ℝ) (hA0 : A 0 = 1) (hA1 : A 1 = 1)
    (hB0 : B 0 = 1) (hB1 : B 1 = 1)
    (hA : ∀ k, A (k + 2) = cA k * A k) (hB : ∀ k, B (k + 2) = cB k * B k)
    (hcA : ∀ k, 0 < cA k) (hlt : ∀ k, cA k < cB k) :
    ∀ k, 2 ≤ k → A k < B k := by
  have hApos := pos_of_recursion A cA hA0 hA1 hA hcA
  intro k hk
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 2 := ⟨k - 2, by omega⟩
  clear hk
  induction j using Nat.strong_induction_on with
  | _ j ih =>
    match j with
    | 0 => rw [hA 0, hB 0, hA0, hB0, mul_one, mul_one]; exact hlt 0
    | 1 => rw [hA 1, hB 1, hA1, hB1, mul_one, mul_one]; exact hlt 1
    | (n + 2) =>
      have hprev : A (n + 2) < B (n + 2) := ih n (by omega)
      have hpos : 0 < A (n + 2) := hApos (n + 2)
      have hcBpos : 0 < cB (n + 2) := lt_trans (hcA (n + 2)) (hlt (n + 2))
      rw [hA (n + 2), hB (n + 2)]
      calc cA (n + 2) * A (n + 2) < cB (n + 2) * A (n + 2) :=
            mul_lt_mul_of_pos_right (hlt (n + 2)) hpos
        _ < cB (n + 2) * B (n + 2) := mul_lt_mul_of_pos_left hprev hcBpos

/-- Coefficients larger than `1` force all moments beyond the mean to exceed `1`. -/
theorem one_lt_of_coeff_one_lt (A c : ℕ → ℝ) (hA0 : A 0 = 1) (hA1 : A 1 = 1)
    (hA : ∀ k, A (k + 2) = c k * A k) (hc : ∀ k, 1 < c k) : ∀ k, 2 ≤ k → 1 < A k := by
  refine lt_of_coeff_lt (fun _ => 1) A (fun _ => 1) c ?_ ?_ hA0 hA1 ?_ hA ?_ hc <;> simp

/-- The GOE recursion. -/
theorem goeMoment_succ_succ (k : ℕ) :
    goeMoment (k + 2) = (((k : ℝ) + 2) * 2 / π) * goeMoment k := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < π / 4 := by positivity
  have h := surmiseMoment_succ_succ 1 k (π / 2) hq
  unfold goeMoment
  rw [h]
  congr 1
  push_cast
  field_simp
  ring

/-- The GSE recursion. -/
theorem gseMoment_succ_succ (k : ℕ) :
    gseMoment (k + 2) = (((k : ℝ) + 5) * 9 * π / 128) * gseMoment k := by
  have hpi := Real.pi_pos
  have hq : (0:ℝ) < 64 / (9 * π) := by positivity
  have h := surmiseMoment_succ_succ 4 k (262144 / (729 * π ^ 3)) hq
  unfold gseMoment
  rw [h]
  congr 1
  push_cast
  field_simp
  ring

/-- The Poisson recursion. -/
theorem poissonMoment_succ_succ (k : ℕ) :
    poissonMoment (k + 2) = (((k : ℝ) + 1) * ((k : ℝ) + 2)) * poissonMoment k := by
  rw [poissonMoment_eq_factorial, poissonMoment_eq_factorial,
    show k + 2 = (k + 1) + 1 by ring, Nat.factorial_succ, Nat.factorial_succ]
  push_cast
  ring

/-- **Full moment ladder.**  At *every* moment order `k ≥ 2` the five regimes are
strictly ordered
`1 (rigid) < M_k(GSE) < M_k(GUE) < M_k(GOE) < k! (Poisson)`,
extending the second-moment ladder `1 < 45π/128 < 3π/8 < 4/π < 2` to the whole
moment sequence. -/
theorem full_moment_ladder (k : ℕ) (hk : 2 ≤ k) :
    1 < gseMoment k ∧ gseMoment k < gueMoment k ∧ gueMoment k < goeMoment k ∧
      goeMoment k < poissonMoment k := by
  have hpi := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  have hp : (0:ℝ) < π := Real.pi_pos
  have hcast : ∀ j : ℕ, (0:ℝ) ≤ (j : ℝ) := fun j => Nat.cast_nonneg j
  refine ⟨?_, ?_, ?_, ?_⟩
  · refine one_lt_of_coeff_one_lt gseMoment (fun j => ((j : ℝ) + 5) * 9 * π / 128)
      gseMoment_zero gseMoment_one gseMoment_succ_succ (fun j => ?_) k hk
    have := hcast j
    nlinarith
  · refine lt_of_coeff_lt gseMoment gueMoment (fun j => ((j : ℝ) + 5) * 9 * π / 128)
      (fun j => ((j : ℝ) + 3) * π / 8) gseMoment_zero gseMoment_one gueMoment_zero gueMoment_one
      gseMoment_succ_succ gueMoment_succ_succ (fun j => ?_) (fun j => ?_) k hk
    · have := hcast j; positivity
    · have := hcast j; nlinarith
  · refine lt_of_coeff_lt gueMoment goeMoment (fun j => ((j : ℝ) + 3) * π / 8)
      (fun j => ((j : ℝ) + 2) * 2 / π) gueMoment_zero gueMoment_one goeMoment_zero goeMoment_one
      gueMoment_succ_succ goeMoment_succ_succ (fun j => ?_) (fun j => ?_) k hk
    · have := hcast j; positivity
    · have hj := hcast j
      have hpisq : π * π < 9.9225 := by nlinarith
      rw [div_lt_div_iff₀ (by norm_num) hp]
      nlinarith [mul_le_mul_of_nonneg_left hpisq.le (show (0:ℝ) ≤ (j : ℝ) + 3 by linarith)]
  · refine lt_of_coeff_lt goeMoment poissonMoment (fun j => ((j : ℝ) + 2) * 2 / π)
      (fun j => ((j : ℝ) + 1) * ((j : ℝ) + 2)) goeMoment_zero goeMoment_one
      (by rw [poissonMoment_eq_factorial]; norm_num)
      (by rw [poissonMoment_eq_factorial]; norm_num)
      goeMoment_succ_succ poissonMoment_succ_succ (fun j => ?_) (fun j => ?_) k hk
    · have := hcast j; positivity
    · have hj := hcast j
      rw [div_lt_iff₀ hp]
      have h1 : ((j : ℝ) + 2) * 2 < ((j : ℝ) + 2) * π := by nlinarith
      have h2 : ((j : ℝ) + 2) * π ≤ ((j : ℝ) + 1) * ((j : ℝ) + 2) * π := by nlinarith
      simpa using lt_of_lt_of_le h1 h2

end

end MomentFingerprint