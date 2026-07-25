import Mathlib

namespace CounterfactualRandomPrimes

open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal NNReal

/-- The Cramér inclusion probability at the integer `n + 2`. -/
noncomputable def cramerDensity (n : ℕ) : ℝ≥0∞ :=
  ENNReal.ofReal (1 / Real.log (n + 2))

/-- A shifted harmonic comparison term. -/
noncomputable def harmonicTerm (n : ℕ) : ℝ≥0∞ :=
  ENNReal.ofReal (1 / (n + 2))

/-- The Cramér density dominates the shifted harmonic sequence. -/
theorem harmonicTerm_le_cramerDensity (n : ℕ) :
    harmonicTerm n ≤ cramerDensity n := by
  unfold harmonicTerm cramerDensity
  apply ENNReal.ofReal_le_ofReal
  have hlog : Real.log (n + 2) ≤ (n + 2 : ℝ) := Real.log_le_self (by positivity)
  have hpos : (0 : ℝ) < Real.log (n + 2) := Real.log_pos (by
    have h0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith)
  exact one_div_le_one_div_of_le hpos hlog

/-- The shifted harmonic series is not summable over the reals. -/
theorem not_summable_harmonic_shift :
    ¬ Summable (fun n : ℕ => (1 : ℝ) / (n + 2)) := by
  have h : ¬ Summable (fun n : ℕ => (1 : ℝ) / n) := Real.not_summable_one_div_natCast
  intro hs
  apply h
  rw [← summable_nat_add_iff 2]
  simpa using hs

/-- The shifted harmonic series has infinite `ℝ≥0∞` sum. -/
theorem tsum_harmonicTerm_eq_top :
    ∑' n : ℕ, harmonicTerm n = ⊤ := by
  by_contra h
  apply not_summable_harmonic_shift
  have hcoe : (fun n : ℕ => harmonicTerm n) =
      (fun n : ℕ => ((((1 : ℝ) / (n + 2)).toNNReal : ℝ≥0) : ℝ≥0∞)) := by
    funext n
    rfl
  rw [hcoe] at h
  have hsummable : Summable (fun n : ℕ => (((1 : ℝ) / (n + 2)).toNNReal : ℝ≥0)) :=
    ENNReal.tsum_coe_ne_top_iff_summable.mp h
  have hs := (NNReal.summable_coe).2 hsummable
  refine hs.congr ?_
  intro n
  rw [Real.coe_toNNReal]
  positivity

/-- The Cramér density series diverges. -/
theorem tsum_cramerDensity_eq_top :
    ∑' n : ℕ, cramerDensity n = ⊤ := by
  have hle : ∑' n : ℕ, harmonicTerm n ≤ ∑' n : ℕ, cramerDensity n :=
    ENNReal.tsum_le_tsum harmonicTerm_le_cramerDensity
  rw [tsum_harmonicTerm_eq_top] at hle
  exact top_le_iff.mp hle

/-- Every arithmetic subsequence of the Cramér density series diverges.
The parameters `q > 0` and `a` represent the progression `q*n + a`. -/
theorem tsum_cramerDensity_arithmeticProgression_eq_top
    (q a : ℕ) (hq : 0 < q) :
    ∑' n : ℕ, cramerDensity (q * n + a) = ⊤ := by
  suffices h_comp : ¬ Summable (fun n : ℕ => (1 : ℝ) / (Real.log (q * n + a + 2))) by
    contrapose! h_comp;
    convert ENNReal.summable_toReal _;
    rotate_left;
    use fun n => cramerDensity ( q * n + a );
    · convert h_comp using 1;
    · unfold cramerDensity; norm_num;
      rw [ ENNReal.toReal_ofReal ( inv_nonneg.mpr ( Real.log_nonneg ( by nlinarith ) ) ) ];
  have h_harmonic : ¬ Summable (fun n : ℕ => (1 : ℝ) / (q * n + a + 2)) := by
    have h_harmonic : ¬ Summable (fun n : ℕ => (1 : ℝ) / (q * n)) := by
      simpa [ summable_mul_right_iff, hq.ne' ] using Real.not_summable_natCast_inv;
    exact fun h => h_harmonic <| summable_nat_add_iff ( a + 2 ) |>.1 <| h.of_nonneg_of_le ( fun n => by positivity ) fun n => by rw [ div_le_div_iff₀ ] <;> norm_cast <;> nlinarith;
  exact fun h => h_harmonic <| h.of_nonneg_of_le ( fun n => by positivity ) fun n => by simpa using inv_anti₀ ( Real.log_pos <| by norm_cast; nlinarith ) <| le_trans ( Real.log_le_sub_one_of_pos <| by positivity ) <| by linarith;

variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}

/-- Independent Cramér events occur infinitely often almost surely. -/
theorem randomPrimes_infinitely_often_ae
    (s : ℕ → Set Ω) (hmeas : ∀ n, MeasurableSet (s n))
    (hindep : iIndepSet s μ)
    (hdensity : ∀ n, cramerDensity n ≤ μ (s n)) :
    μ (limsup s atTop) = 1 := by
  apply measure_limsup_eq_one hmeas hindep
  have hle : ∑' n : ℕ, cramerDensity n ≤ ∑' n : ℕ, μ (s n) :=
    ENNReal.tsum_le_tsum hdensity
  rw [tsum_cramerDensity_eq_top] at hle
  exact top_le_iff.mp hle

/-- A random Cramér set meets any fixed nonconstant arithmetic progression
infinitely often almost surely, provided its progression events are independent. -/
theorem randomDirichlet_infinitely_often_ae
    (q a : ℕ) (hq : 0 < q)
    (s : ℕ → Set Ω) (hmeas : ∀ n, MeasurableSet (s n))
    (hindep : iIndepSet s μ)
    (hdensity : ∀ n, cramerDensity (q * n + a) ≤ μ (s n)) :
    μ (limsup s atTop) = 1 := by
  apply measure_limsup_eq_one hmeas hindep
  have hle : ∑' n : ℕ, cramerDensity (q * n + a) ≤ ∑' n : ℕ, μ (s n) :=
    ENNReal.tsum_le_tsum hdensity
  rw [tsum_cramerDensity_arithmeticProgression_eq_top q a hq] at hle
  exact top_le_iff.mp hle

/-- Summable event probabilities force only finitely many random primes almost surely;
independence is not needed. -/
theorem randomPrimes_finitely_often_ae
    (s : ℕ → Set Ω) (hconv : ∑' n : ℕ, μ (s n) ≠ ⊤) :
    μ (limsup s atTop) = 0 :=
  measure_limsup_atTop_eq_zero hconv

/-- The model has a sharp qualitative boundary: divergent independent event masses
force infinitely many occurrences, whereas summable masses force finitely many. -/
theorem divergence_convergence_dichotomy
    (s t : ℕ → Set Ω)
    (hsmeas : ∀ n, MeasurableSet (s n))
    (hsindep : iIndepSet s μ)
    (hsdiv : ∑' n : ℕ, μ (s n) = ⊤)
    (htconv : ∑' n : ℕ, μ (t n) ≠ ⊤) :
    μ (limsup s atTop) = 1 ∧ μ (limsup t atTop) = 0 := by
  constructor
  · exact measure_limsup_eq_one hsmeas hsindep hsdiv
  · exact measure_limsup_atTop_eq_zero htconv

end CounterfactualRandomPrimes