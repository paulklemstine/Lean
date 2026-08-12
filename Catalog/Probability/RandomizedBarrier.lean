/-
# The randomized barrier (Factoring Lab, Phase A v19c — cycle 3)

This file closes the first (deterministic-reduction) half of **Conjecture D** of
`FUTURE_DIRECTIONS.md`: randomization does not break the structural barrier.

`Catalog/Probability/AdaptiveBarrier.lean` proves that a *single* adaptive
strategy whose tests and outputs are band-measurable cannot predict the hidden
factor better than the band mean.  A natural escape route is to randomize: run
a finite mixture `μ = (w_1, …, w_m)` over strategies `t_1, …, t_m` and hope that
the mixture beats every one of its members.  It cannot, and the reason is
sharper than convexity alone:

* `FactoringLab.mix_sq_error_decomposition` — an exact *bias–variance identity*
  for mixtures: the expected squared error of the randomized strategy equals
  the squared error of its **mean predictor** `m(i) = Σ_j w_j t_j(i)` plus the
  randomization variance `Σ_i Σ_j w_j (t_j(i) − m(i))²`.  Randomizing therefore
  *strictly increases* the error unless all strategies with positive weight
  agree pointwise on the population (`FactoringLab.randomization_never_helps`,
  `FactoringLab.randomization_strictly_hurts`).
* `FactoringLab.mixEval_bandMeasurable` — the mean predictor of a mixture of
  band-measurable strategies is itself band-measurable, so it factors through
  the band label (`FactoringLab.randomized_is_N_only`) and is dominated by the
  band mean.
* `FactoringLab.randomized_barrier` — consequently the expected squared error of
  *any* finite mixture of `N`-only adaptive strategies is at least the
  irreducible band-conditional error, uniformly in the number of strategies,
  their sizes and the mixing weights.
* `FactoringLab.randomized_barrier_eq_iff` — the barrier is *tight exactly* on
  the degenerate mixtures: equality holds iff every strategy carrying positive
  weight reproduces the band mean on the whole population.  This is the
  equality clause conjectured in Conjecture D.

Together with `FactoringLab.adaptive_barrier`, this says: neither adaptivity nor
randomness — nor any combination of the two — extracts information about the
hidden factor beyond what the band label already carries.
-/
import Mathlib
import Probability.AdaptiveBarrier

open Finset

namespace FactoringLab

variable {ι κ : Type*}

/-! ### Mixtures of strategies -/

/-- The **mean predictor** of a randomized strategy: the mixture `Σ_j w_j t_j`
of the outputs of finitely many strategies. -/
noncomputable def mixEval {m : ℕ} (w : Fin m → ℝ) (T : Fin m → DTree ι) (i : ι) : ℝ :=
  ∑ j, w j * (T j).eval i

/-- The expected squared error of the randomized strategy `(w, T)`: the average,
over the mixing distribution, of the squared errors of its members. -/
noncomputable def mixRisk {m : ℕ} (Ω : Finset ι) (w : Fin m → ℝ) (T : Fin m → DTree ι)
    (Y : ι → ℝ) : ℝ :=
  ∑ j, w j * ∑ i ∈ Ω, ((T j).eval i - Y i) ^ 2

/-- The mean predictor of a mixture of band-measurable strategies is
band-measurable: randomizing does not create a new function of the population. -/
theorem mixEval_bandMeasurable {m : ℕ} (Ω : Finset ι) (n : ι → κ)
    (w : Fin m → ℝ) (T : Fin m → DTree ι) (hT : ∀ j, (T j).BandOnly Ω n) :
    BandMeasurable Ω n (mixEval w T) := by
  intro i hi j hj hij
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [DTree.bandMeasurable_eval Ω n (T k) (hT k) i hi j hj hij]

/-- A randomized `N`-only strategy is, in the mean, still an `N`-only
invariant: its mean predictor factors through the band label. -/
theorem randomized_is_N_only {m : ℕ} (Ω : Finset ι) (n : ι → κ)
    (w : Fin m → ℝ) (T : Fin m → DTree ι) (hT : ∀ j, (T j).BandOnly Ω n) :
    ∃ g : κ → ℝ, ∀ i ∈ Ω, mixEval w T i = g (n i) :=
  factors_through_band Ω n (mixEval w T) (mixEval_bandMeasurable Ω n w T hT)

/-! ### The bias–variance identity for mixtures -/

/-- Pointwise bias–variance identity: for weights summing to `1`, the weighted
mean of the squared deviations from a target equals the squared deviation of
the weighted mean plus the weighted spread around that mean. -/
theorem mix_sq_error_pointwise {m : ℕ} (w x : Fin m → ℝ) (y : ℝ) (hw : ∑ j, w j = 1) :
    ∑ j, w j * (x j - y) ^ 2
      = (∑ j, w j * x j - y) ^ 2 + ∑ j, w j * (x j - ∑ j', w j' * x j') ^ 2 := by
  set M := ∑ j, w j * x j with hM
  have h0 : ∑ j, w j * (x j - M) = 0 := by
    have : ∑ j, w j * (x j - M) = (∑ j, w j * x j) - (∑ j, w j) * M := by
      rw [Finset.sum_mul]
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [this, hw, ← hM]
    ring
  calc ∑ j, w j * (x j - y) ^ 2
      = ∑ j, (w j * (x j - M) ^ 2 + 2 * (M - y) * (w j * (x j - M)) + (M - y) ^ 2 * w j) :=
        Finset.sum_congr rfl fun j _ => by rw [hM]; ring
    _ = (∑ j, w j * (x j - M) ^ 2) + 2 * (M - y) * (∑ j, w j * (x j - M))
          + (M - y) ^ 2 * ∑ j, w j := by
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
    _ = (M - y) ^ 2 + ∑ j, w j * (x j - M) ^ 2 := by rw [h0, hw]; ring

/-- **Bias–variance decomposition for randomized strategies.**  The expected
squared error of a mixture is the squared error of its mean predictor plus the
randomization variance.  The identity is exact and needs only that the mixing
weights sum to `1`. -/
theorem mix_sq_error_decomposition {m : ℕ} (Ω : Finset ι) (w : Fin m → ℝ)
    (T : Fin m → DTree ι) (Y : ι → ℝ) (hw : ∑ j, w j = 1) :
    mixRisk Ω w T Y
      = ∑ i ∈ Ω, (mixEval w T i - Y i) ^ 2
        + ∑ i ∈ Ω, ∑ j, w j * ((T j).eval i - mixEval w T i) ^ 2 := by
  have hswap : mixRisk Ω w T Y = ∑ i ∈ Ω, ∑ j, w j * ((T j).eval i - Y i) ^ 2 := by
    unfold mixRisk
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun j _ => by rw [Finset.mul_sum]
  rw [hswap, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  exact mix_sq_error_pointwise w (fun j => (T j).eval i) (Y i) hw

/-- **Randomization never helps.**  The expected error of a randomized strategy
is at least the error of the single deterministic strategy given by its mean
predictor. -/
theorem randomization_never_helps {m : ℕ} (Ω : Finset ι) (w : Fin m → ℝ)
    (T : Fin m → DTree ι) (Y : ι → ℝ) (hw : ∑ j, w j = 1) (hw0 : ∀ j, 0 ≤ w j) :
    ∑ i ∈ Ω, (mixEval w T i - Y i) ^ 2 ≤ mixRisk Ω w T Y := by
  rw [mix_sq_error_decomposition Ω w T Y hw]
  have : 0 ≤ ∑ i ∈ Ω, ∑ j, w j * ((T j).eval i - mixEval w T i) ^ 2 :=
    Finset.sum_nonneg fun i _ =>
      Finset.sum_nonneg fun j _ => mul_nonneg (hw0 j) (sq_nonneg _)
  linarith

/-- **Randomization strictly hurts** unless it is degenerate: the excess of the
randomized risk over the risk of the mean predictor is exactly the
randomization variance, so it is positive as soon as two strategies with
positive weight disagree somewhere on the population. -/
theorem randomization_strictly_hurts {m : ℕ} (Ω : Finset ι) (w : Fin m → ℝ)
    (T : Fin m → DTree ι) (Y : ι → ℝ) (hw : ∑ j, w j = 1) (hw0 : ∀ j, 0 ≤ w j)
    {i₀ : ι} (hi₀ : i₀ ∈ Ω) {j₀ : Fin m} (hj₀ : 0 < w j₀)
    (hne : (T j₀).eval i₀ ≠ mixEval w T i₀) :
    ∑ i ∈ Ω, (mixEval w T i - Y i) ^ 2 < mixRisk Ω w T Y := by
  rw [mix_sq_error_decomposition Ω w T Y hw]
  have hd : (T j₀).eval i₀ - mixEval w T i₀ ≠ 0 := sub_ne_zero.mpr hne
  have hsq : 0 < ((T j₀).eval i₀ - mixEval w T i₀) ^ 2 :=
    lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 hd))
  have hinner : 0 < ∑ j, w j * ((T j).eval i₀ - mixEval w T i₀) ^ 2 :=
    Finset.sum_pos' (fun j _ => mul_nonneg (hw0 j) (sq_nonneg _))
      ⟨j₀, Finset.mem_univ j₀, mul_pos hj₀ hsq⟩
  have hpos : 0 < ∑ i ∈ Ω, ∑ j, w j * ((T j).eval i - mixEval w T i) ^ 2 :=
    Finset.sum_pos' (fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg (hw0 j) (sq_nonneg _))
      ⟨i₀, hi₀, hinner⟩
  linarith

/-- **The randomized barrier.**  No finite mixture of `N`-only adaptive
strategies predicts the hidden target better than the band mean — uniformly in
the number of strategies, their sizes, and the mixing weights. -/
theorem randomized_barrier [DecidableEq κ] {m : ℕ} (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (w : Fin m → ℝ) (T : Fin m → DTree ι) (hw : ∑ j, w j = 1) (hw0 : ∀ j, 0 ≤ w j)
    (hT : ∀ j, (T j).BandOnly Ω n) :
    ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 ≤ mixRisk Ω w T Y := by
  have hstep : ∀ j, ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2
      ≤ ∑ i ∈ Ω, ((T j).eval i - Y i) ^ 2 := fun j => adaptive_barrier Ω n Y (T j) (hT j)
  calc ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2
      = ∑ j, w j * ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 := by
        rw [← Finset.sum_mul, hw, one_mul]
    _ ≤ mixRisk Ω w T Y :=
        Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hstep j) (hw0 j)

/-- **Tightness of the randomized barrier.**  Equality holds exactly for the
degenerate mixtures: those all of whose positively weighted strategies
reproduce the band mean on the whole population. -/
theorem randomized_barrier_eq_iff [DecidableEq κ] {m : ℕ} (Ω : Finset ι) (n : ι → κ)
    (Y : ι → ℝ) (w : Fin m → ℝ) (T : Fin m → DTree ι) (hw : ∑ j, w j = 1)
    (hw0 : ∀ j, 0 ≤ w j) (hT : ∀ j, (T j).BandOnly Ω n) :
    mixRisk Ω w T Y = ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 ↔
      ∀ j, 0 < w j → ∀ i ∈ Ω, (T j).eval i = bandMean Ω n Y i := by
  classical
  set E := ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 with hE
  have hstep : ∀ j, 0 ≤ (∑ i ∈ Ω, ((T j).eval i - Y i) ^ 2) - E := fun j => by
    have := adaptive_barrier Ω n Y (T j) (hT j)
    linarith
  constructor
  · intro heq j hj i hi
    have hzero : ∑ j', w j' * ((∑ i ∈ Ω, ((T j').eval i - Y i) ^ 2) - E) = 0 := by
      have hexp : ∑ j', w j' * ((∑ i ∈ Ω, ((T j').eval i - Y i) ^ 2) - E)
          = mixRisk Ω w T Y - (∑ j', w j') * E := by
        unfold mixRisk
        rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun j' _ => by ring
      rw [hexp, hw, one_mul, heq]
      ring
    have hterm : ∀ j', j' ∈ Finset.univ →
        w j' * ((∑ i ∈ Ω, ((T j').eval i - Y i) ^ 2) - E) = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg fun j' _ => ?_).1 hzero
      exact mul_nonneg (hw0 j') (hstep j')
    have hj' : (∑ i ∈ Ω, ((T j).eval i - Y i) ^ 2) - E = 0 := by
      rcases mul_eq_zero.1 (hterm j (Finset.mem_univ j)) with h | h
      · exact absurd h (ne_of_gt hj)
      · exact h
    have hdec := adaptive_sq_error_decomposition Ω n Y (T j) (hT j)
    have hsq : ∑ i ∈ Ω, ((T j).eval i - bandMean Ω n Y i) ^ 2 = 0 := by
      rw [hE] at hj'
      linarith [hdec, hj']
    have := (Finset.sum_eq_zero_iff_of_nonneg fun i _ => sq_nonneg
      ((T j).eval i - bandMean Ω n Y i)).1 hsq i hi
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
    linarith
  · intro hall
    have hrisk : ∀ j, 0 ≤ w j → w j * ∑ i ∈ Ω, ((T j).eval i - Y i) ^ 2 = w j * E := by
      intro j _
      rcases eq_or_lt_of_le (hw0 j) with h | h
      · rw [← h]; ring
      · congr 1
        refine Finset.sum_congr rfl fun i hi => ?_
        rw [hall j h i hi]
    unfold mixRisk
    rw [Finset.sum_congr rfl fun j _ => hrisk j (hw0 j), ← Finset.sum_mul, hw, one_mul]

end FactoringLab