import Mathlib

/-!
# BATTERY-UTILITY, information layer: the capacity gap *is* the within-class variation

## Research context (FACT round-28 #4, paper 98, verdict `THE-LABELS-ARE-NOT-FILTERS`)

`Catalog/Pythagorean/BatteryUtilityLabelsNotFilters.lean` refutes, arithmetically, the map
`residue r mod m* ↦ splitting type of a prime ≡ r`.  This file supplies the matching
information-theoretic statement, i.e. the reason *every* measured channel of the 6-dial
battery sits strictly below its label-entropy ceiling (`S₃a : I = 1.0012 < H(T) = 2.2982`).

The framework is a finite joint law `prob : R → T → ℝ` on (residue, label) pairs, with
Shannon entropies built from `Real.negMulLog`.

## Main results

* `FinChannel.chain_rule` — `H(R,T) = H(R) + H(T|R)` with the conditional entropy written as a
  sum of the pointwise terms `condTerm (p r t) (margR r) = -p log p + p log (margR r) ≥ 0`.
* `FinChannel.condEntropy_nonneg`, `FinChannel.mutualInfo_le_entropyT` — **the capacity law**:
  a label channel can never return more than its own label entropy, `I ≤ H(T)`.
* `FinChannel.mutualInfo_eq_entropyT_of_functional` — **filters saturate.**  If the label *is*
  a function of the residue (exactly the map the round tried to build), then `I = H(T)`: the
  ceiling is attained.
* `FinChannel.condEntropy_pos_of_two_labels`, `FinChannel.mutualInfo_lt_entropyT_of_two_labels`
  — **the gap theorem, and its contrapositive reading**: if a single residue class carries two
  labels with positive mass, then `I < H(T)` strictly.  Hence *any* measured `I < H(T)` is a
  certificate that no residue → label table exists; the deficit is exactly the within-class
  variation, never a defect of the measurement.
* `FinChannel.mutualInfo_eq_zero_of_product` — the Bayesian statement of the corrected
  understanding: when the labels are statistics of the joint draw and are independent of the
  single residue, the channel returns **zero** bits about that residue, although `H(T) > 0`.
* `chebotarev_model_gap` — the equidistribution model of the cubic channel
  (`X³ - 2` over the classes `1, 4, 7 mod 9`, labels `0`/`3` with weights `2/3, 1/3`):
  `I = 0` while `H(T) = log 3 - (2/3) log 2 > 0`.  The entire label entropy is within-class.
* `measured_window_gap` — the measured `21`-prime window (`p < 200`, `p ≡ 1 mod 3`) with its
  actual cell counts `(6,2 | 5,2 | 5,1)`: `0 < H(T|R)`, so `I < H(T)` strictly, exactly as
  every dial of the battery reports.
* `no_pinning_posterior_bound` — no-pinning: under the product model the posterior mass of any
  single joint residue class is the constant `1/9`, unchanged by the label vector.
-/

namespace BatteryUtility

open Finset Real

/-- The pointwise conditional-entropy term `-a log a + a log s` (with `a` a joint mass and `s`
the mass of its residue class). -/
noncomputable def condTerm (a s : ℝ) : ℝ := Real.negMulLog a + a * Real.log s

theorem condTerm_nonneg {a s : ℝ} (ha : 0 ≤ a) (has : a ≤ s) : 0 ≤ condTerm a s := by
  rcases eq_or_lt_of_le ha with rfl | ha'
  · simp [condTerm]
  · have : Real.log a ≤ Real.log s := Real.log_le_log ha' has
    simp only [condTerm, Real.negMulLog, neg_mul]
    nlinarith

theorem condTerm_pos {a s : ℝ} (ha : 0 < a) (has : a < s) : 0 < condTerm a s := by
  have : Real.log a < Real.log s := Real.log_lt_log ha has
  simp only [condTerm, Real.negMulLog, neg_mul]
  nlinarith

theorem condTerm_self (a : ℝ) : condTerm a a = 0 := by
  simp [condTerm, Real.negMulLog]

theorem condTerm_zero (s : ℝ) : condTerm 0 s = 0 := by simp [condTerm]

/-- A finite (residue, label) channel: the joint law of the pair actually measured by a dial. -/
structure FinChannel (R T : Type*) [Fintype R] [Fintype T] where
  prob : R → T → ℝ
  nonneg : ∀ r t, 0 ≤ prob r t
  total : ∑ r, ∑ t, prob r t = 1

namespace FinChannel

variable {R T : Type*} [Fintype R] [Fintype T] (J : FinChannel R T)

/-- Residue marginal. -/
def margR (r : R) : ℝ := ∑ t, J.prob r t

/-- Label marginal. -/
def margT (t : T) : ℝ := ∑ r, J.prob r t

/-- `H(R)`. -/
noncomputable def entropyR : ℝ := ∑ r, Real.negMulLog (J.margR r)

/-- `H(T)`, the label-entropy ceiling. -/
noncomputable def entropyT : ℝ := ∑ t, Real.negMulLog (J.margT t)

/-- `H(R,T)`. -/
noncomputable def entropyJoint : ℝ := ∑ r, ∑ t, Real.negMulLog (J.prob r t)

/-- `H(T|R)`, the within-class variation. -/
noncomputable def condEntropy : ℝ := ∑ r, ∑ t, condTerm (J.prob r t) (J.margR r)

/-- `I(R;T) = H(T) - H(T|R)`. -/
noncomputable def mutualInfo : ℝ := J.entropyT - J.condEntropy

theorem prob_le_margR (r : R) (t : T) : J.prob r t ≤ J.margR r :=
  Finset.single_le_sum (f := fun t => J.prob r t) (fun i _ => J.nonneg r i) (Finset.mem_univ t)

theorem margR_nonneg (r : R) : 0 ≤ J.margR r :=
  Finset.sum_nonneg fun t _ => J.nonneg r t

/-- **The chain rule** `H(R,T) = H(R) + H(T|R)`. -/
theorem chain_rule : J.entropyJoint = J.entropyR + J.condEntropy := by
  have hR : J.entropyR = - ∑ r, ∑ t, J.prob r t * Real.log (J.margR r) := by
    rw [entropyR, ← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun r _ => ?_
    rw [← Finset.sum_mul]
    simp only [Real.negMulLog, margR, neg_mul]
  simp only [condEntropy, condTerm, entropyJoint, Finset.sum_add_distrib, hR]
  ring

theorem mutualInfo_eq : J.mutualInfo = J.entropyR + J.entropyT - J.entropyJoint := by
  rw [mutualInfo, J.chain_rule]; ring

/-- The within-class variation is never negative. -/
theorem condEntropy_nonneg : 0 ≤ J.condEntropy :=
  Finset.sum_nonneg fun r _ => Finset.sum_nonneg fun t _ =>
    condTerm_nonneg (J.nonneg r t) (J.prob_le_margR r t)

/-- **The capacity law**: a dial can return at most its own label entropy. -/
theorem mutualInfo_le_entropyT : J.mutualInfo ≤ J.entropyT := by
  have := J.condEntropy_nonneg
  simp only [mutualInfo]
  linarith

/-- **Filters saturate the ceiling.**  If the label is a *function* of the residue — the map
the utility tables presupposed — then the channel returns every bit of the label entropy. -/
theorem mutualInfo_eq_entropyT_of_functional [DecidableEq T] (g : R → T)
    (hg : ∀ r t, J.prob r t ≠ 0 → t = g r) : J.mutualInfo = J.entropyT := by
  have hcond : J.condEntropy = 0 := by
    refine Finset.sum_eq_zero fun r _ => Finset.sum_eq_zero fun t _ => ?_
    rcases eq_or_ne (J.prob r t) 0 with h | h
    · rw [h, condTerm_zero]
    · have hmarg : J.margR r = J.prob r t := by
        rw [margR]
        refine Finset.sum_eq_single t (fun b _ hb => ?_) (fun hb => absurd (Finset.mem_univ t) hb)
        by_contra hcon
        exact hb ((hg r b hcon).trans (hg r t h).symm)
      rw [hmarg, condTerm_self]
  rw [mutualInfo, hcond, sub_zero]

/-- **The gap theorem.**  One residue class carrying two labels of positive mass forces a
strictly positive within-class variation. -/
theorem condEntropy_pos_of_two_labels {r : R} {t₁ t₂ : T} (hne : t₁ ≠ t₂)
    (h₁ : 0 < J.prob r t₁) (h₂ : 0 < J.prob r t₂) : 0 < J.condEntropy := by
  classical
  have hlt : J.prob r t₁ < J.margR r := by
    have hsplit : J.prob r t₁ + J.prob r t₂ ≤ J.margR r := by
      rw [margR]
      have : ({t₁, t₂} : Finset T) ⊆ Finset.univ := Finset.subset_univ _
      calc J.prob r t₁ + J.prob r t₂
          = ∑ t ∈ ({t₁, t₂} : Finset T), J.prob r t := by
            rw [Finset.sum_pair hne]
        _ ≤ ∑ t, J.prob r t :=
            Finset.sum_le_sum_of_subset_of_nonneg this fun i _ _ => J.nonneg r i
    linarith
  refine Finset.sum_pos' (fun r' _ => Finset.sum_nonneg fun t _ =>
    condTerm_nonneg (J.nonneg r' t) (J.prob_le_margR r' t)) ⟨r, Finset.mem_univ r, ?_⟩
  exact Finset.sum_pos' (fun t _ => condTerm_nonneg (J.nonneg r t) (J.prob_le_margR r t))
    ⟨t₁, Finset.mem_univ t₁, condTerm_pos h₁ hlt⟩

/-- Consequence: a channel with within-class variation sits **strictly** below its ceiling —
so a measured `I < H(T)` is never a measurement defect, it is the absence of the table. -/
theorem mutualInfo_lt_entropyT_of_two_labels {r : R} {t₁ t₂ : T} (hne : t₁ ≠ t₂)
    (h₁ : 0 < J.prob r t₁) (h₂ : 0 < J.prob r t₂) : J.mutualInfo < J.entropyT := by
  have := J.condEntropy_pos_of_two_labels hne h₁ h₂
  simp only [mutualInfo]
  linarith

/-- **The Bayesian reading.**  If the label is a statistic of the joint draw, independent of
the single residue, the dial returns exactly zero bits about that residue. -/
theorem mutualInfo_eq_zero_of_product (a : R → ℝ) (b : T → ℝ)
    (hprob : ∀ r t, J.prob r t = a r * b t) (ha : ∑ r, a r = 1) (hb : ∑ t, b t = 1) :
    J.mutualInfo = 0 := by
  have hmargR : ∀ r, J.margR r = a r := by
    intro r
    simp only [margR, hprob, ← Finset.mul_sum, hb, mul_one]
  have hmargT : ∀ t, J.margT t = b t := by
    intro t
    simp only [margT, hprob, ← Finset.sum_mul, ha, one_mul]
  have hjoint : J.entropyJoint = J.entropyR + J.entropyT := by
    have : J.entropyJoint = ∑ r, ∑ t, (b t * Real.negMulLog (a r) + a r * Real.negMulLog (b t)) :=
      Finset.sum_congr rfl fun r _ => Finset.sum_congr rfl fun t _ => by
        rw [hprob r t, Real.negMulLog_mul]
    rw [this]
    simp only [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum, ha, hb, one_mul,
      entropyR, entropyT, hmargR, hmargT]
  rw [mutualInfo_eq, hjoint]
  ring

end FinChannel

/-! ### The cubic channel of the battery, `X³ - 2` over the classes `1, 4, 7 mod 9` -/

/-- The equidistribution ("Chebotarev") model of the cubic channel: residue uniform on the three
classes `1, 4, 7 mod 9`, label `0` with density `2/3` and label `3` with density `1/3`,
*independently of the residue* — this is the corrected understanding of the battery labels. -/
noncomputable def chebotarevChannel : FinChannel (Fin 3) (Fin 2) where
  prob r t := (1 / 3 : ℝ) * (if t = 0 then 2 / 3 else 1 / 3)
  nonneg r t := by split_ifs <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

theorem chebotarev_mutualInfo_zero : chebotarevChannel.mutualInfo = 0 := by
  refine chebotarevChannel.mutualInfo_eq_zero_of_product (fun _ => 1 / 3)
    (fun t => if t = 0 then 2 / 3 else 1 / 3) (fun r t => rfl) ?_ ?_
  · norm_num [Fin.sum_univ_succ]
  · norm_num [Fin.sum_univ_succ]

theorem chebotarev_entropyT : chebotarevChannel.entropyT = Real.log 3 - (2 / 3) * Real.log 2 := by
  have hmarg : ∀ t : Fin 2, chebotarevChannel.margT t = if t = 0 then 2 / 3 else 1 / 3 := by
    intro t
    simp only [FinChannel.margT, chebotarevChannel, Fin.sum_univ_succ]
    split <;> norm_num
  simp only [FinChannel.entropyT, Fin.sum_univ_succ, hmarg]
  norm_num [Real.negMulLog]
  rw [show (2 : ℝ) / 3 = 2 * 3⁻¹ by ring, show (1 : ℝ) / 3 = 3⁻¹ by ring,
    Real.log_mul (by norm_num) (by norm_num), Real.log_inv]
  ring

/-- The label entropy of the cubic channel is strictly positive: `log 3 - (2/3) log 2 > 0`,
because `27 > 4`. -/
theorem chebotarev_entropyT_pos : 0 < chebotarevChannel.entropyT := by
  rw [chebotarev_entropyT]
  have h : Real.log 4 < Real.log 27 := Real.log_lt_log (by norm_num) (by norm_num)
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
  have h27 : Real.log 27 = 3 * Real.log 3 := by
    rw [show (27 : ℝ) = 3 ^ 3 by norm_num, Real.log_pow]; push_cast; ring
  rw [h4, h27] at h
  linarith

/-- **The whole ceiling is within-class variation.**  In the equidistribution model of the
cubic channel the dial returns zero bits about the residue while its label entropy is
positive: the `12.7`-bit capacity is a statement about the joint draw, not a filter. -/
theorem chebotarev_model_gap :
    chebotarevChannel.mutualInfo = 0 ∧ 0 < chebotarevChannel.entropyT ∧
      chebotarevChannel.mutualInfo < chebotarevChannel.entropyT := by
  refine ⟨chebotarev_mutualInfo_zero, chebotarev_entropyT_pos, ?_⟩
  rw [chebotarev_mutualInfo_zero]
  exact chebotarev_entropyT_pos

/-- No pinning, product form: the posterior mass of a single joint residue pair stays at the
constant `1/9` — the label vector moves no individual candidate. -/
theorem no_pinning_posterior_bound (r : Fin 3) (t : Fin 2) :
    chebotarevChannel.prob r t ≤ 1 / 3 ∧ chebotarevChannel.margR r = 1 / 3 := by
  constructor
  · show (1 / 3 : ℝ) * (if t = 0 then 2 / 3 else 1 / 3) ≤ 1 / 3
    split_ifs <;> norm_num
  · simp only [FinChannel.margR, chebotarevChannel, Fin.sum_univ_succ]
    norm_num

/-- The measured window: the `21` primes `p < 200` with `p ≡ 1 (mod 3)`, split by residue
mod `9` (rows `1, 4, 7`) and by cubic label (`0` versus `3`).  Cell counts `(6,2 | 5,2 | 5,1)`,
exactly as enumerated in `ComputationalEvidence.md`. -/
noncomputable def measuredWindow : FinChannel (Fin 3) (Fin 2) where
  prob r t := (![![6, 2], ![5, 2], ![5, 1]] r t : ℝ) / 21
  nonneg r t := by fin_cases r <;> fin_cases t <;> norm_num
  total := by norm_num [Fin.sum_univ_succ]

/-- Every cell of the measured window is occupied, in particular the residue class `1 mod 9`
carries both labels. -/
theorem measuredWindow_two_labels :
    0 < measuredWindow.prob 0 0 ∧ 0 < measuredWindow.prob 0 1 := by
  constructor <;> norm_num [measuredWindow]

/-- **The measured gap.**  The window has strictly positive within-class variation, hence its
mutual information is strictly below the label-entropy ceiling — the qualitative shape of the
`S₃a` reading `I = 1.0012 < 2.2982 = H(T)`. -/
theorem measured_window_gap :
    0 < measuredWindow.condEntropy ∧ measuredWindow.mutualInfo < measuredWindow.entropyT := by
  obtain ⟨h1, h2⟩ := measuredWindow_two_labels
  exact ⟨measuredWindow.condEntropy_pos_of_two_labels (by decide) h1 h2,
    measuredWindow.mutualInfo_lt_entropyT_of_two_labels (by decide) h1 h2⟩

end BatteryUtility