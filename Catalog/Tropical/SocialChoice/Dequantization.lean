/-
# Maslov dequantization of tropical aggregators

A second bridge, this time between **tropical (min-plus) aggregation** and
**classical analysis**: the log-sum-exp ("softmin") family

`F_ε x = -ε · log ( Σ_{i ∈ S} exp (-(x i + δ i)/ε) )`

is a family of genuinely classical, positive, smooth aggregators, and it
converges to the tropical aggregator `x ↦ min_{i ∈ S} (x i + δ i)` as `ε ↓ 0`.

Main results.

* `logSumExp_sandwich` : the two-sided, fully explicit estimate
  `A - ε log |S| ≤ -ε log Σ exp(-a i/ε) ≤ A`, where `A = min_{i ∈ S} a i`.
* `tendsto_logSumExp` : the resulting convergence as `ε ↓ 0`.
* `dequant_sub_trop_abs_le` : the dequantized aggregators converge to the
  tropical aggregator *uniformly in the profile*, with rate `ε log |S|`.
* `dequant_eq_trop_iff_card_eq_one` : the dequantization is *exact* (there is no
  deformation at all) precisely when the tropical support is a singleton, i.e.
  precisely for dictatorships.  This is the "dequantization stability of
  decisive coalitions" phenomenon in sharp form.
-/
import Mathlib

namespace TropicalDequantization

open Finset

variable {ι : Type*}

/-- The log-sum-exp (softmin) smoothing of the tropical minimum at scale `ε`. -/
noncomputable def logSumExp (ε : ℝ) (S : Finset ι) (a : ι → ℝ) : ℝ :=
  -ε * Real.log (∑ i ∈ S, Real.exp (-(a i) / ε))

lemma sum_exp_pos {S : Finset ι} (hS : S.Nonempty) (ε : ℝ) (a : ι → ℝ) :
    0 < ∑ i ∈ S, Real.exp (-(a i) / ε) :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) hS

/-- Lower bound for the smoothed sum: it dominates the term at a minimizer. -/
lemma exp_le_sum_exp {S : Finset ι} (hS : S.Nonempty) (ε : ℝ) (a : ι → ℝ) :
    Real.exp (-(S.inf' hS a) / ε) ≤ ∑ i ∈ S, Real.exp (-(a i) / ε) := by
  obtain ⟨i₀, hi₀S, hi₀⟩ := Finset.exists_mem_eq_inf' hS a
  calc Real.exp (-(S.inf' hS a) / ε) = Real.exp (-(a i₀) / ε) := by rw [hi₀]
    _ ≤ ∑ i ∈ S, Real.exp (-(a i) / ε) :=
        Finset.single_le_sum (f := fun i => Real.exp (-(a i) / ε))
          (fun i _ => (Real.exp_pos _).le) hi₀S

/-- Upper bound for the smoothed sum. -/
lemma sum_exp_le {S : Finset ι} (hS : S.Nonempty) {ε : ℝ} (hε : 0 < ε) (a : ι → ℝ) :
    (∑ i ∈ S, Real.exp (-(a i) / ε)) ≤ S.card * Real.exp (-(S.inf' hS a) / ε) := by
  have hterm : ∀ i ∈ S, Real.exp (-(a i) / ε) ≤ Real.exp (-(S.inf' hS a) / ε) := by
    intro i hi
    have hle : S.inf' hS a ≤ a i := Finset.inf'_le a hi
    exact Real.exp_le_exp.2 (by gcongr)
  calc (∑ i ∈ S, Real.exp (-(a i) / ε)) ≤ ∑ _i ∈ S, Real.exp (-(S.inf' hS a) / ε) :=
        Finset.sum_le_sum hterm
    _ = S.card * Real.exp (-(S.inf' hS a) / ε) := by
        rw [Finset.sum_const, nsmul_eq_mul]

/-- **Explicit dequantization sandwich.** -/
theorem logSumExp_sandwich {S : Finset ι} (hS : S.Nonempty) {ε : ℝ} (hε : 0 < ε) (a : ι → ℝ) :
    S.inf' hS a - ε * Real.log S.card ≤ logSumExp ε S a ∧ logSumExp ε S a ≤ S.inf' hS a := by
  set A := S.inf' hS a with hA
  set T := ∑ i ∈ S, Real.exp (-(a i) / ε) with hT
  have hpos : 0 < T := sum_exp_pos hS ε a
  have hlow : Real.exp (-A / ε) ≤ T := exp_le_sum_exp hS ε a
  have hhigh : T ≤ S.card * Real.exp (-A / ε) := sum_exp_le hS hε a
  have hcard : (0 : ℝ) < S.card := by
    exact_mod_cast Finset.card_pos.2 hS
  have hlog1 : -A / ε ≤ Real.log T := by
    have := Real.log_le_log (Real.exp_pos _) hlow
    rwa [Real.log_exp] at this
  have hlog2 : Real.log T ≤ Real.log S.card + (-A / ε) := by
    have h1 := Real.log_le_log hpos hhigh
    rwa [Real.log_mul (ne_of_gt hcard) (ne_of_gt (Real.exp_pos _)), Real.log_exp] at h1
  constructor
  · have hmul : -ε * Real.log T ≥ -ε * (Real.log S.card + (-A / ε)) :=
      mul_le_mul_of_nonpos_left hlog2 (by linarith)
    have hexp : -ε * (Real.log S.card + (-A / ε)) = A - ε * Real.log S.card := by
      field_simp; ring
    simp only [logSumExp, ← hT]
    linarith [hexp ▸ hmul]
  · have hmul : -ε * Real.log T ≤ -ε * (-A / ε) :=
      mul_le_mul_of_nonpos_left hlog1 (by linarith)
    have hexp : -ε * (-A / ε) = A := by field_simp
    simp only [logSumExp, ← hT]
    linarith [hexp ▸ hmul]

lemma abs_logSumExp_sub_le {S : Finset ι} (hS : S.Nonempty) {ε : ℝ} (hε : 0 < ε) (a : ι → ℝ) :
    |logSumExp ε S a - S.inf' hS a| ≤ ε * Real.log S.card := by
  obtain ⟨h1, h2⟩ := logSumExp_sandwich hS hε a
  have hcard : (1 : ℝ) ≤ S.card := by exact_mod_cast Finset.card_pos.2 hS
  have hlog : 0 ≤ Real.log S.card := Real.log_nonneg hcard
  rw [abs_le]
  constructor <;> nlinarith

/-- **Maslov dequantization**: the softmin converges to the tropical minimum. -/
theorem tendsto_logSumExp {S : Finset ι} (hS : S.Nonempty) (a : ι → ℝ) :
    Filter.Tendsto (fun ε => logSumExp ε S a) (nhdsWithin 0 (Set.Ioi (0:ℝ)))
      (nhds (S.inf' hS a)) := by
  have hupper : Filter.Tendsto (fun _ : ℝ => S.inf' hS a) (nhdsWithin 0 (Set.Ioi (0:ℝ)))
      (nhds (S.inf' hS a)) := tendsto_const_nhds
  have hlower : Filter.Tendsto (fun ε : ℝ => S.inf' hS a - ε * Real.log S.card)
      (nhdsWithin 0 (Set.Ioi (0:ℝ))) (nhds (S.inf' hS a)) := by
    have : Filter.Tendsto (fun ε : ℝ => S.inf' hS a - ε * Real.log S.card)
        (nhds 0) (nhds (S.inf' hS a - 0 * Real.log S.card)) := by
      exact (tendsto_const_nhds.sub ((continuous_id.mul continuous_const).tendsto 0))
    simpa using this.mono_left nhdsWithin_le_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlower hupper ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with ε hε
    exact (logSumExp_sandwich hS hε a).1
  · filter_upwards [self_mem_nhdsWithin] with ε hε
    exact (logSumExp_sandwich hS hε a).2

/-! ## Dequantized aggregators -/

/-- The tropical aggregator with support `S` and weights `δ`. -/
noncomputable def tropAgg (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) : (ι → ℝ) → ℝ :=
  fun x => S.inf' hS fun i => x i + δ i

/-- Its classical (positive, smooth) dequantization at scale `ε`. -/
noncomputable def dequant (ε : ℝ) (S : Finset ι) (δ : ι → ℝ) : (ι → ℝ) → ℝ :=
  fun x => logSumExp ε S fun i => x i + δ i

/-- **Uniform convergence of the dequantized aggregators**, with explicit rate
`ε log |S|` independent of the profile. -/
theorem dequant_sub_trop_abs_le {S : Finset ι} (hS : S.Nonempty) {ε : ℝ} (hε : 0 < ε)
    (δ : ι → ℝ) (x : ι → ℝ) :
    |dequant ε S δ x - tropAgg S hS δ x| ≤ ε * Real.log S.card :=
  abs_logSumExp_sub_le hS hε _

theorem tendsto_dequant {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) (x : ι → ℝ) :
    Filter.Tendsto (fun ε => dequant ε S δ x) (nhdsWithin 0 (Set.Ioi (0:ℝ)))
      (nhds (tropAgg S hS δ x)) :=
  tendsto_logSumExp hS _

/-- **Dequantization stability is exactly dictatorship.**  The classical family
`dequant ε` agrees with its tropical limit for every scale and every profile iff
the tropical support is a singleton — i.e. iff the aggregator is a
dictatorship. -/
theorem dequant_eq_trop_iff_card_eq_one {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) :
    (∀ ε : ℝ, 0 < ε → ∀ x : ι → ℝ, dequant ε S δ x = tropAgg S hS δ x) ↔ S.card = 1 := by
  constructor
  · intro hstab
    have hx := hstab 1 one_pos (fun i => -δ i)
    have hzero : ∀ i, (fun i => (fun i => -δ i) i + δ i) i = 0 := by intro i; ring
    have hsum : (∑ i ∈ S, Real.exp (-((fun i => -δ i) i + δ i) / 1)) = S.card := by
      simp [hzero]
    have htrop : tropAgg S hS δ (fun i => -δ i) = 0 := by
      simp only [tropAgg]
      have : (fun i => (-δ i) + δ i) = fun _ : ι => (0:ℝ) := by funext i; ring
      rw [this]
      simp
    rw [htrop] at hx
    simp only [dequant, logSumExp] at hx
    rw [hsum] at hx
    have hlog : Real.log (S.card : ℝ) = 0 := by
      have h1 : (-1 : ℝ) * Real.log (S.card : ℝ) = 0 := by simpa using hx
      linarith
    have hcard : (1 : ℝ) ≤ (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
    have : (S.card : ℝ) = 1 := by
      by_contra hne
      have h1 : (1 : ℝ) < S.card := lt_of_le_of_ne hcard (Ne.symm hne)
      have := Real.log_pos h1
      linarith
    exact_mod_cast this
  · intro hcard ε hε x
    obtain ⟨i₀, hi₀⟩ := Finset.card_eq_one.1 hcard
    subst hi₀
    simp only [dequant, tropAgg, logSumExp, Finset.sum_singleton, Finset.inf'_singleton,
      Real.log_exp]
    field_simp

end TropicalDequantization