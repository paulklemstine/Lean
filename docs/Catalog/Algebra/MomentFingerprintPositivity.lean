/-
# Hankel Positivity of the Wigner Fingerprint, and Realizability of the Regimes

Third research cycle, built on `Algebra.MomentFingerprintClassification` and
`Algebra.MomentFingerprintDuality`.

Cycle 2 computed the *third* Hankel determinant of the three fingerprints and
found the ordering `0 < π²(9π-28)/256 < 4`.  Here we prove the structural fact
behind that computation: **every** Hankel form of the Wigner-surmise moment
sequence is positive semidefinite,

  `∑_{i,j} c_i c_j M_{i+j} = ∫₀^∞ (∑_i c_i s^i)² p(s) ds ≥ 0`,

which is the Hamburger side condition for the fingerprint to be a genuine moment
sequence.  This requires the integrability of every polynomial weight against the
Gaussian-type surmise density (`gueIntegrable`), and an exchange of a finite sum
with the integral.

The second half of the file shows the second-moment classifier is *surjective on
genuine finite spectra*: mean-one two-point spacing configurations realize every
second moment in `[1,2]`, hence all three regimes are attained by explicit finite
spectra.  It closes with the rigid end of the classifier: for a mean-one finite
spectrum the empirical second moment is the empirical variance
(`sum_sq_dev_eq`), so `M₂ = 1` forces the exact picket fence
(`rigid_of_empSecondMoment_eq_one`) and `M₂ = 1 + ε` forces mean absolute
deviation at most `√ε` (`meanAbsDev_le_sqrt_variance`).
-/
import Algebra.MomentFingerprintDuality

open Real MeasureTheory Set Filter Topology

namespace MomentFingerprint

noncomputable section

/-! ## Integrability of polynomial weights against the surmise -/

theorem gueDensity_nonneg (s : ℝ) : 0 ≤ gueDensity s := by
  have := Real.pi_pos
  unfold gueDensity
  positivity

/-- Every monomial is integrable against the Wigner surmise on `(0, ∞)`. -/
theorem gueIntegrable (k : ℕ) :
    IntegrableOn (fun s : ℝ => s ^ k * gueDensity s) (Ioi 0) := by
  have hpi := Real.pi_pos
  have h := integrableOn_rpow_mul_exp_neg_mul_sq (b := 4 / π) (by positivity)
      (s := (k : ℝ) + 2) (by linarith [Nat.cast_nonneg (α := ℝ) k])
  have h2 : IntegrableOn
      (fun x : ℝ => (32 / π ^ 2) * (x ^ ((k : ℝ) + 2) * exp (-(4 / π) * x ^ 2))) (Ioi 0) :=
    h.const_mul _
  refine h2.congr_fun ?_ measurableSet_Ioi
  intro x hx
  have hx0 : (0:ℝ) < x := hx
  simp only [gueDensity]
  rw [show ((k : ℝ) + 2) = ((k + 2 : ℕ) : ℝ) by push_cast; ring, Real.rpow_natCast x (k + 2)]
  ring

/-! ## Hankel positive semidefiniteness -/

/-- **Hamburger positivity of the Wigner fingerprint.**  Every Hankel quadratic
form built from the Wigner-surmise moments is nonnegative; the moment sequence is
therefore a bona fide positive-definite moment sequence, of which
`hankel3_gue > 0` is the order-three instance. -/
theorem gueMoment_hankel_psd (n : ℕ) (c : Fin n → ℝ) :
    0 ≤ ∑ i : Fin n, ∑ j : Fin n, c i * c j * gueMoment ((i : ℕ) + (j : ℕ)) := by
  have hterm : ∀ i j : Fin n,
      c i * c j * gueMoment ((i : ℕ) + (j : ℕ))
        = ∫ s in Ioi (0:ℝ), (c i * c j) * (s ^ ((i : ℕ) + (j : ℕ)) * gueDensity s) := by
    intro i j
    rw [integral_const_mul]
    rfl
  have hint : ∀ i j : Fin n, IntegrableOn
      (fun s : ℝ => (c i * c j) * (s ^ ((i : ℕ) + (j : ℕ)) * gueDensity s)) (Ioi 0) :=
    fun i j => (gueIntegrable ((i : ℕ) + (j : ℕ))).const_mul _
  have hswap : ∑ i : Fin n, ∑ j : Fin n, c i * c j * gueMoment ((i : ℕ) + (j : ℕ))
      = ∫ s in Ioi (0:ℝ), ∑ i : Fin n, ∑ j : Fin n,
          (c i * c j) * (s ^ ((i : ℕ) + (j : ℕ)) * gueDensity s) := by
    rw [integral_finset_sum _ (fun i _ => integrable_finset_sum _ (fun j _ => hint i j))]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [integral_finset_sum _ (fun j _ => hint i j)]
    exact Finset.sum_congr rfl fun j _ => hterm i j
  rw [hswap]
  refine setIntegral_nonneg measurableSet_Ioi (fun s _ => ?_)
  have hexpand : ∑ i : Fin n, ∑ j : Fin n,
      (c i * c j) * (s ^ ((i : ℕ) + (j : ℕ)) * gueDensity s)
      = (∑ i : Fin n, c i * s ^ (i : ℕ)) ^ 2 * gueDensity s := by
    rw [sq, Finset.sum_mul_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [pow_add]
    ring
  rw [hexpand]
  exact mul_nonneg (sq_nonneg _) (gueDensity_nonneg s)

/-- The order-two instance recovers the strict variance gap: the `2 × 2` Hankel
determinant `M₀M₂ - M₁²` is the variance `3π/8 - 1 > 0`. -/
theorem gue_hankel2_eq_variance :
    gueMoment 0 * gueMoment 2 - gueMoment 1 ^ 2 = 3 * π / 8 - 1 := by
  rw [gueMoment_zero, gueMoment_one, gueMoment_two]
  ring

/-! ## Realizability: all three regimes occur for explicit finite spectra -/

/-- The mean-one two-point spacing configuration `(1 + t, 1 - t)`. -/
def twoSpacing (t : ℝ) : Fin 2 → ℝ := ![1 + t, 1 - t]

theorem twoSpacing_mean (t : ℝ) : (∑ i, twoSpacing t i) / 2 = 1 := by
  simp [twoSpacing, Fin.sum_univ_two]

theorem empSecondMoment_twoSpacing (t : ℝ) : empSecondMoment 2 (twoSpacing t) = 1 + t ^ 2 := by
  unfold empSecondMoment twoSpacing
  simp [Fin.sum_univ_two]
  ring

/-- Every second moment in `[1,2]` is realized by a genuine (nonnegative,
mean-one) finite spacing configuration. -/
theorem realizable_second_moment (mu : ℝ) (h1 : 1 ≤ mu) (h2 : mu ≤ 2) :
    ∃ s : Fin 2 → ℝ, (∀ i, 0 ≤ s i) ∧ (∑ i, s i) / 2 = 1 ∧ empSecondMoment 2 s = mu := by
  refine ⟨twoSpacing (Real.sqrt (mu - 1)), ?_, twoSpacing_mean _, ?_⟩
  · intro i
    have hle : Real.sqrt (mu - 1) ≤ 1 := by
      have h := Real.sqrt_le_sqrt (show mu - 1 ≤ 1 by linarith)
      simpa using h
    have hnn : 0 ≤ Real.sqrt (mu - 1) := Real.sqrt_nonneg _
    fin_cases i <;> simp [twoSpacing] <;> linarith
  · rw [empSecondMoment_twoSpacing, Real.sq_sqrt (by linarith)]
    ring

/-! ## The rigid bucket is a genuine rigidity statement -/

/-- For a mean-one finite spacing configuration the total squared deviation from
the picket fence is exactly `n·(M₂ - 1)`: the empirical second moment *is* the
empirical variance. -/
theorem sum_sq_dev_eq (n : ℕ) (hn : 0 < n) (s : Fin n → ℝ)
    (hmean : (∑ i, s i) / n = 1) :
    ∑ i, (s i - 1) ^ 2 = n * (empSecondMoment n s - 1) := by
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hn.ne'
  have hs : ∑ i, s i = (n : ℝ) := by field_simp at hmean; linarith
  have hq : ∑ i, (s i) ^ 2 = (n : ℝ) * empSecondMoment n s := by
    unfold empSecondMoment; field_simp
  have hexp : ∑ i, (s i - 1) ^ 2 = (∑ i, (s i) ^ 2) - 2 * (∑ i, s i) + n := by
    have h : ∀ i : Fin n, (s i - 1) ^ 2 = s i ^ 2 - 2 * s i + 1 := fun i => by ring
    simp only [h, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
  rw [hexp, hs, hq]; ring

/-- **Exact rigidity.**  A mean-one finite spectrum whose empirical second moment
equals the rigid value `1` is *exactly* the picket fence: every spacing is `1`.
The rigid bucket of `classify` is therefore not a labelling convention but a
characterization. -/
theorem rigid_of_empSecondMoment_eq_one (n : ℕ) (hn : 0 < n) (s : Fin n → ℝ)
    (hmean : (∑ i, s i) / n = 1) (hsq : empSecondMoment n s = 1) : ∀ i, s i = 1 := by
  have h := sum_sq_dev_eq n hn s hmean
  rw [hsq] at h
  simp only [sub_self, mul_zero] at h
  intro i
  have hzero : (s i - 1) ^ 2 = 0 :=
    (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => sq_nonneg (s i - 1))).1 h i (Finset.mem_univ i)
  have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hzero
  linarith

/-- **Quantitative rigidity.**  For a mean-one finite spectrum the mean absolute
deviation from the picket fence is at most `√(M₂ - 1)`; a second moment `1 + ε`
therefore certifies an `√ε`-approximately rigid spectrum (the transport-distance
form of the rigid end of the classifier). -/
theorem meanAbsDev_le_sqrt_variance (n : ℕ) (hn : 0 < n) (s : Fin n → ℝ)
    (hmean : (∑ i, s i) / n = 1) :
    (∑ i, |s i - 1|) / n ≤ Real.sqrt (empSecondMoment n s - 1) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hcs := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset (Fin n)))
    (f := fun i => |s i - 1|)
  simp only [sq_abs, Finset.card_univ, Fintype.card_fin] at hcs
  rw [sum_sq_dev_eq n hn s hmean] at hcs
  have hD : 0 ≤ ∑ i, |s i - 1| := Finset.sum_nonneg fun i _ => abs_nonneg _
  have hnn : 0 ≤ empSecondMoment n s - 1 := by
    by_contra hc
    push_neg at hc
    nlinarith [sq_nonneg (∑ i, |s i - 1|), mul_pos hn0 hn0]
  rw [Real.le_sqrt (by positivity) hnn, div_pow, div_le_iff₀ (by positivity)]
  nlinarith

/-- **All three regimes are attained.**  Explicit mean-one finite spacing
configurations are classified as rigid, GUE and Poisson respectively. -/
theorem all_regimes_realized :
    classify (empSecondMoment 2 (twoSpacing 0)) = 0 ∧
    classify (empSecondMoment 2 (twoSpacing (Real.sqrt (3 * π / 8 - 1)))) = 1 ∧
    classify (empSecondMoment 2 (twoSpacing 1)) = 2 := by
  have hpi := Real.pi_gt_d2
  have hpi2 := Real.pi_lt_d2
  refine ⟨?_, ?_, ?_⟩
  · rw [empSecondMoment_twoSpacing]
    norm_num
    exact classify_rigid
  · rw [empSecondMoment_twoSpacing, Real.sq_sqrt (by nlinarith),
      show 1 + (3 * π / 8 - 1) = 3 * π / 8 by ring]
    exact classify_gue
  · rw [empSecondMoment_twoSpacing]
    norm_num
    exact classify_poisson

end

end MomentFingerprint