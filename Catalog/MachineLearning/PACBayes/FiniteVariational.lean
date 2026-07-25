/-
# Finite PAC--Bayes variational theory

A self-contained development of the finite-hypothesis-space change-of-measure
inequality.  Unlike a bound that assumes its own analytic conclusion, the main
result below derives it from positivity, normalization, and `log x ≤ x - 1`.
-/
import Mathlib

open scoped BigOperators

noncomputable section

namespace PACBayesFinite

variable {ι : Type*} [Fintype ι]

/-- Expectation of a real observable under a finite weight function. -/
def expectation (q x : ι → ℝ) : ℝ := ∑ i, q i * x i

/-- Kullback--Leibler divergence on a finite space.  Positivity assumptions used
below ensure that every logarithm is taken at a positive argument. -/
def kl (q p : ι → ℝ) : ℝ := ∑ i, q i * Real.log (q i / p i)

/-- Exponential partition function. -/
def partition (p a : ι → ℝ) : ℝ := ∑ i, p i * Real.exp (a i)

/-- Exponentially tilted (Gibbs) posterior. -/
def tilt (p a : ι → ℝ) (i : ι) : ℝ :=
  p i * Real.exp (a i) / partition p a

lemma partition_pos (p a : ι → ℝ) (hp : ∀ i, 0 < p i) [Nonempty ι] :
    0 < partition p a := by
  have hpos : ∀ i, 0 < p i * Real.exp (a i) := fun i => mul_pos (hp i) (Real.exp_pos _)
  exact Finset.sum_pos (fun i _ => hpos i) Finset.univ_nonempty

lemma tilt_pos (p a : ι → ℝ) (hp : ∀ i, 0 < p i) [Nonempty ι] (i : ι) :
    0 < tilt p a i := by
  unfold tilt partition
  apply div_pos _ _
  · exact mul_pos (hp i) (Real.exp_pos (a i))
  · apply Finset.sum_pos'
    · intro j _
      exact le_of_lt (mul_pos (hp j) (Real.exp_pos (a j)))
    · exact ⟨Classical.arbitrary ι, Finset.mem_univ _, mul_pos (hp _) (Real.exp_pos _)⟩

lemma sum_tilt (p a : ι → ℝ) (hp : ∀ i, 0 < p i) [Nonempty ι] :
    ∑ i, tilt p a i = 1 := by
  rw [show (∑ i, tilt p a i) = partition p a / partition p a by
    simp only [tilt, Finset.sum_div, partition]]
  exact div_self (ne_of_gt (partition_pos p a hp))

/-- Gibbs' inequality, proved directly on a finite space. -/
theorem kl_nonneg (q p : ι → ℝ)
    (hq : ∀ i, 0 < q i) (hp : ∀ i, 0 < p i)
    (hqsum : ∑ i, q i = 1) (hpsum : ∑ i, p i = 1) :
    0 ≤ kl q p := by
  have h1 : ∀ i, q i * Real.log (q i / p i) ≥ q i - p i := by
    intro i
    have hq_pos : 0 < q i := hq i
    have hp_pos : 0 < p i := hp i
    have hppq : 0 < p i / q i := div_pos hp_pos hq_pos
    have hlog : Real.log (p i / q i) ≤ p i / q i - 1 :=
      Real.log_le_sub_one_of_pos hppq
    have hlog_neg : -Real.log (p i / q i) ≥ 1 - p i / q i := by linarith
    have hlog_q : Real.log (q i / p i) = -Real.log (p i / q i) := by
      rw [← Real.log_inv, inv_div]
    calc q i * Real.log (q i / p i) = q i * (-Real.log (p i / q i)) := by rw [hlog_q]
      _ ≥ q i * (1 - p i / q i) := by exact mul_le_mul_of_nonneg_left hlog_neg (le_of_lt hq_pos)
      _ = q i - p i := by field_simp
  calc 0 = ∑ i, (q i - p i) := by simp [hqsum, hpsum]
    _ ≤ ∑ i, q i * Real.log (q i / p i) := Finset.sum_le_sum (fun i _ => h1 i)
    _ = kl q p := rfl

/-- Exact KL identity for exponential tilting. -/
theorem kl_tilt_identity (q p a : ι → ℝ) [Nonempty ι]
    (hq : ∀ i, 0 < q i) (hp : ∀ i, 0 < p i)
    (hqsum : ∑ i, q i = 1) :
    kl q (tilt p a) = kl q p - expectation q a + Real.log (partition p a) := by
  have hZ : partition p a ≠ 0 := ne_of_gt (partition_pos p a hp)
  have hlog : ∀ i, Real.log (q i / tilt p a i) =
      Real.log (q i / p i) - a i + Real.log (partition p a) := by
    intro i
    have hqi : q i ≠ 0 := ne_of_gt (hq i)
    have hpi : p i ≠ 0 := ne_of_gt (hp i)
    have hei : Real.exp (a i) ≠ 0 := ne_of_gt (Real.exp_pos _)
    rw [show q i / tilt p a i = (q i / p i) / Real.exp (a i) * partition p a by
      unfold tilt
      field_simp]
    rw [Real.log_mul]
    · rw [Real.log_div]
      · simp only [Real.log_exp]
      · exact div_ne_zero hqi hpi
      · exact hei
    · exact div_ne_zero (div_ne_zero hqi hpi) hei
    · exact hZ
  simp only [kl, expectation]
  rw [Finset.sum_congr rfl (fun i _ => congrArg (q i * ·) (hlog i))]
  simp only [mul_sub, mul_add]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have hc : (∑ i, q i * Real.log (partition p a)) = Real.log (partition p a) := by
    rw [← Finset.sum_mul, hqsum, one_mul]
  rw [hc]

/-- The finite Donsker--Varadhan / PAC--Bayes change-of-measure inequality. -/
theorem change_of_measure (q p a : ι → ℝ) [Nonempty ι]
    (hq : ∀ i, 0 < q i) (hp : ∀ i, 0 < p i)
    (hqsum : ∑ i, q i = 1) :
    expectation q a ≤ kl q p + Real.log (partition p a) := by
  have htilt_sum : ∑ i, tilt p a i = 1 := sum_tilt p a hp
  have htilt_pos : ∀ i, 0 < tilt p a i := tilt_pos p a hp
  have hkl_nonneg : 0 ≤ kl q (tilt p a) := kl_nonneg q (tilt p a) hq htilt_pos hqsum htilt_sum
  linarith [kl_tilt_identity q p a hq hp hqsum]

/-- The Gibbs posterior attains equality in the variational inequality. -/
theorem tilt_attains_bound (p a : ι → ℝ) [Nonempty ι]
    (hp : ∀ i, 0 < p i) :
    expectation (tilt p a) a - kl (tilt p a) p =
      Real.log (partition p a) := by
  have hpart_pos := partition_pos p a hp
  have hpart_ne : partition p a ≠ 0 := ne_of_gt hpart_pos
  have hlog_eq : ∀ i, Real.log (tilt p a i / p i) = a i - Real.log (partition p a) := by
    intro i
    unfold tilt
    have hpi_pos := hp i
    rw [div_div, mul_comm (p i) _, mul_div_mul_right _ _ (ne_of_gt hpi_pos)]
    rw [Real.log_div (ne_of_gt (Real.exp_pos _)) hpart_ne]
    simp [Real.log_exp]
  simp only [kl, expectation]
  have hsum : ∑ i, tilt p a i * Real.log (tilt p a i / p i) =
              ∑ i, tilt p a i * (a i - Real.log (partition p a)) := by
    exact Finset.sum_congr rfl (fun i _ => hlog_eq i ▸ rfl)
  rw [hsum]
  have hsimplify : ∀ i, tilt p a i * a i - tilt p a i * (a i - Real.log (partition p a)) =
                      tilt p a i * Real.log (partition p a) := by
    intro i; ring
  rw [← Finset.sum_sub_distrib]
  simp only [hsimplify]
  rw [← Finset.sum_mul]
  rw [sum_tilt p a hp]
  ring

/-- A finite PAC--Bayes generalization bound from an exponential-moment
certificate.  The certificate is the probabilistic input usually obtained by
Markov's inequality; all posterior-uniform change-of-measure algebra is proved
here. -/
theorem pac_bayes_from_moment
    (q p empiricalRisk trueRisk : ι → ℝ) [Nonempty ι]
    (η δ : ℝ)
    (hq : ∀ i, 0 < q i) (hp : ∀ i, 0 < p i)
    (hqsum : ∑ i, q i = 1)
    (hη : 0 < η)
    (hmoment : partition p (fun i => η * (trueRisk i - empiricalRisk i)) ≤ 1 / δ) :
    expectation q trueRisk ≤ expectation q empiricalRisk +
      (kl q p + Real.log (1 / δ)) / η := by
  have h1 := change_of_measure q p (fun i => η * (trueRisk i - empiricalRisk i)) hq hp hqsum
  have h2 : expectation q (fun i => η * (trueRisk i - empiricalRisk i)) =
            η * expectation q trueRisk - η * expectation q empiricalRisk := by
    simp [expectation, Finset.mul_sum, mul_sub]
    ac_rfl
  rw [h2] at h1
  have h3 : Real.log (partition p fun i => η * (trueRisk i - empiricalRisk i)) ≤ Real.log (1 / δ) := by
    apply Real.log_le_log
    · exact Finset.sum_pos (fun i _ => mul_pos (hp i) (Real.exp_pos _)) Finset.univ_nonempty
    · exact hmoment
  have h4 : η * expectation q trueRisk - η * expectation q empiricalRisk ≤ kl q p + Real.log (1 / δ) := by
    linarith
  have h5 : η * (expectation q trueRisk - expectation q empiricalRisk) ≤ kl q p + Real.log (1 / δ) := by
    linarith
  have h6 : expectation q trueRisk - expectation q empiricalRisk ≤ (kl q p + Real.log (1 / δ)) / η := by
    rw [le_div_iff₀ hη]
    linarith
  linarith

/-- If the KL complexity remains bounded while sample size diverges, the
McAllester square-root penalty converges to zero. -/
theorem sqrt_complexity_tendsto_zero (C : ℝ) (_hC : 0 ≤ C) :
    Filter.Tendsto (fun n : ℕ => Real.sqrt (C / (n + 1 : ℝ))) Filter.atTop (nhds 0) := by
  have h1 : Filter.Tendsto (fun n : ℕ => (n : ℝ) + 1) Filter.atTop Filter.atTop := by
    exact Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop
  have h2 : Filter.Tendsto (fun n : ℕ => C / ((n : ℝ) + 1)) Filter.atTop (nhds 0) := by
    apply tendsto_const_nhds.div_atTop h1
  convert h2.sqrt using 1
  simp

end PACBayesFinite