/-
# The arithmetic of a shared random stream: pooling legs that are not independent

## Provenance (round-75 #3, exp 569b, paper 220)

The `u9-drift-power` line ran three legs — a pilot (paper 214, exp567), `G1` (exp569) and
`B` (exp569b) — and pooled them by *inverse-variance weighting*, which assumes the legs are
statistically independent.  Two independence failures were then found in audit:

* `G1` and `B` share the master seed `20260824` end to end, and `B`'s draws are a **strict
  superset** of `G1`'s: the same chunk seeds `SEED + 1000 + c` are consumed as a deterministic
  prefix, so `B`'s first `150 000` samples per `N` are byte-identical to `G1`'s.  The naive
  three-leg joint therefore counted **one dataset twice**.
* The pilot's `24` band-9 semiprimes reconstruct inside `B`'s `128`-`N` pool (24/24), so even
  the "nominally independent" two-leg joint `pilot × B` shares its population.

The question this file settles is not statistical folklore but exact algebra: *by how much
does inverse-variance pooling understate the variance when the legs overlap, and what does
that do to a `CI` that excluded `1`?*

## The model

A measurement leg is a sample mean over a finite index set of a *shared* stream of draws.  We
model the draws as vectors in a real inner product space: `⟪x, y⟫` is the covariance of the
two centred readouts, `⟪x, x⟫` the variance.  A `Design` is a stream of pairwise uncorrelated
draws of common variance `σ²`; a leg is the mean over a `Finset ℕ` of stream positions.  Two
legs drawn from *one* stream overlap exactly on the intersection of their index sets, which is
what makes the audit computable.

## Main results

* `Design.cov_mean` — the master identity `Cov(x̄_S, x̄_T) = σ² |S ∩ T| / (|S| |T|)`.
* `Design.trueVar_eq_naiveVar_add` — the exact defect of the independence assumption:
  the true variance of the pooled estimator exceeds the inverse-variance bookkeeping by
  `2w(1-w)σ²|S ∩ T| / (|S||T|)`.
* `Design.trueVar_eq_naiveVar_iff_disjoint` — the pooling formula is correct **iff** the legs
  are disjoint; overlap is the only thing that breaks it.
* `Design.duplicate_leg_halves_variance` — counting one dataset twice reports exactly **half**
  the true variance (error bars shrunk by `√2`), the exact size of the retracted three-leg joint.
* `Design.nested_ivw_trueVar`, `Design.nested_ivw_inflation` — for a nested pair `S ⊆ T` with
  inverse-variance weights the true variance is `σ²(3|S| + |T|)/(|S| + |T|)²`, an inflation
  factor `(3|S| + |T|)/(|S| + |T|)` over the reported one.
* `Design.nested_pool_worse_than_large_leg` — pooling a prefix leg with its own superset is
  *strictly worse than discarding the prefix*: the honest variance beats the pool.
* `Design.quarter_prefix_inflation` — the exp569/exp569b geometry (`150k` inside `600k`,
  `|T| = 4|S|`) gives inflation exactly `7/5`.
* `Design.gate_retracted_at_quarter_prefix` — **the sting.** Any deficit whose *reported*
  `z` is at most `2.14` (the audited value) has honest `z < 1.96`: the `CI [0.9226, 0.9966]`
  that excluded `1` does not exclude it once the shared stream is paid for.  No gate is armed.

Nothing here depends on the numerical rates; it is the geometry of a shared stream.
-/
import Mathlib

namespace Catalog.Physics.PoolingAudit

open Finset RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Covariance of two partial sums of an orthogonal family of readouts of common variance `v`:
only the shared indices contribute.  This is the combinatorial core of the whole audit and is
stated for an arbitrary index type, so it applies to draws, to clusters and to
(cluster, draw) pairs alike. -/
theorem inner_sum_sum_of_orthogonal {ι : Type*} [DecidableEq ι] (f : ι → E) (v : ℝ)
    (horth : ∀ p q, p ≠ q → ⟪f p, f q⟫ = 0) (hvar : ∀ p, ⟪f p, f p⟫ = v) (S T : Finset ι) :
    ⟪∑ p ∈ S, f p, ∑ q ∈ T, f q⟫ = v * ((S ∩ T).card : ℝ) := by
  rw [sum_inner]
  have key : ∀ p ∈ S, ⟪f p, ∑ q ∈ T, f q⟫ = if p ∈ T then v else 0 := by
    intro p _
    rw [inner_sum]
    by_cases hp : p ∈ T
    · rw [Finset.sum_eq_single_of_mem p hp (fun b _ hb => horth p b (Ne.symm hb)), hvar p,
        if_pos hp]
    · rw [if_neg hp, Finset.sum_eq_zero]
      intro b hb
      exact horth p b (fun h => hp (h ▸ hb))
  rw [Finset.sum_congr rfl key, Finset.sum_ite_mem, Finset.sum_const, nsmul_eq_mul, mul_comm]

/-- A *design*: a stream of pairwise uncorrelated centred readouts of common variance `σ²`.
Inner product = covariance. -/
structure Design (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E] where
  /-- the stream of centred draws, indexed by position in the random stream -/
  draw : ℕ → E
  /-- the common per-draw standard deviation -/
  sigma : ℝ
  sigma_pos : 0 < sigma
  /-- distinct stream positions are uncorrelated -/
  orth : ∀ i j, i ≠ j → ⟪draw i, draw j⟫ = 0
  /-- every position carries variance `σ²` -/
  scale : ∀ i, ⟪draw i, draw i⟫ = sigma ^ 2

namespace Design

variable (D : Design E)

/-- The measurement leg indexed by `S`: the sample mean of the draws at those stream
positions. -/
noncomputable def mean (S : Finset ℕ) : E := ((S.card : ℝ)⁻¹) • ∑ i ∈ S, D.draw i

/-- Covariance of two raw (unnormalised) leg sums: only the shared stream positions
contribute. -/
theorem inner_sum_sum (S T : Finset ℕ) :
    ⟪∑ i ∈ S, D.draw i, ∑ j ∈ T, D.draw j⟫ = D.sigma ^ 2 * ((S ∩ T).card : ℝ) :=
  inner_sum_sum_of_orthogonal D.draw (D.sigma ^ 2) D.orth D.scale S T

/-- **Master identity.**  Two legs cut from one stream have covariance proportional to the
number of stream positions they share. -/
theorem cov_mean (S T : Finset ℕ) :
    ⟪D.mean S, D.mean T⟫ = D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ)) := by
  rw [mean, mean, real_inner_smul_left, real_inner_smul_right, inner_sum_sum]
  ring

/-- Variance of a single leg: the textbook `σ²/n`. -/
theorem var_mean {S : Finset ℕ} (hS : S.Nonempty) :
    ⟪D.mean S, D.mean S⟫ = D.sigma ^ 2 / (S.card : ℝ) := by
  have hc : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hS)
  rw [cov_mean, Finset.inter_self]
  field_simp

/-- Disjoint legs — genuinely independent replication — are uncorrelated. -/
theorem cov_mean_of_disjoint {S T : Finset ℕ} (h : Disjoint S T) : ⟪D.mean S, D.mean T⟫ = 0 := by
  rw [cov_mean, Finset.disjoint_iff_inter_eq_empty.1 h]
  simp

/-- **Nesting is total correlation with the big leg.**  If `S ⊆ T` (a prefix of a longer run),
the covariance of the two legs equals the *variance of the long leg*: the short leg carries no
information the long leg lacks. -/
theorem cov_mean_of_subset {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty) :
    ⟪D.mean S, D.mean T⟫ = D.sigma ^ 2 / (T.card : ℝ) := by
  have hc : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hS)
  rw [cov_mean, Finset.inter_eq_left.2 hST]
  field_simp

/-! ### Pooling two legs -/

/-- The pooled estimator with weight `w` on the first leg. -/
noncomputable def pooled (w : ℝ) (S T : Finset ℕ) : E := w • D.mean S + (1 - w) • D.mean T

/-- The variance the inverse-variance bookkeeping *reports*: the two legs treated as
independent. -/
noncomputable def naiveVar (w : ℝ) (S T : Finset ℕ) : ℝ :=
  w ^ 2 * D.sigma ^ 2 / (S.card : ℝ) + (1 - w) ^ 2 * D.sigma ^ 2 / (T.card : ℝ)

/-- The variance the pooled estimator actually has. -/
noncomputable def trueVar (w : ℝ) (S T : Finset ℕ) : ℝ :=
  ⟪D.pooled w S T, D.pooled w S T⟫

/-- **The exact defect of the independence assumption.** -/
theorem trueVar_eq_naiveVar_add {w : ℝ} {S T : Finset ℕ} (hS : S.Nonempty) (hT : T.Nonempty) :
    D.trueVar w S T =
      D.naiveVar w S T
        + 2 * w * (1 - w) * D.sigma ^ 2 * ((S ∩ T).card : ℝ) / ((S.card : ℝ) * (T.card : ℝ)) := by
  have hcS : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hS)
  have hcT : (T.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (Finset.card_ne_zero.2 hT)
  rw [trueVar, pooled, naiveVar]
  simp only [inner_add_left, inner_add_right, real_inner_smul_left, real_inner_smul_right]
  rw [real_inner_comm (D.mean S) (D.mean T), D.var_mean hS, D.var_mean hT, D.cov_mean S T]
  field_simp
  ring

/-- Overlapping legs: the reported variance is never larger than the truth. -/
theorem naiveVar_le_trueVar {w : ℝ} {S T : Finset ℕ} (hw0 : 0 ≤ w) (hw1 : w ≤ 1)
    (hS : S.Nonempty) (hT : T.Nonempty) : D.naiveVar w S T ≤ D.trueVar w S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  rw [D.trueVar_eq_naiveVar_add hS hT]
  have hnum : 0 ≤ 2 * w * (1 - w) * D.sigma ^ 2 * ((S ∩ T).card : ℝ) := by
    have : (0 : ℝ) ≤ ((S ∩ T).card : ℝ) := Nat.cast_nonneg _
    have hs : (0 : ℝ) ≤ D.sigma ^ 2 := sq_nonneg _
    have : (0 : ℝ) ≤ 2 * w * (1 - w) := by nlinarith
    positivity
  have : (0 : ℝ) ≤ 2 * w * (1 - w) * D.sigma ^ 2 * ((S ∩ T).card : ℝ) /
      ((S.card : ℝ) * (T.card : ℝ)) := div_nonneg hnum (by positivity)
  linarith

/-- **Independence is exactly disjointness.**  With any interior weight, inverse-variance
pooling reports the correct variance if and only if the two legs share no draw. -/
theorem trueVar_eq_naiveVar_iff_disjoint {w : ℝ} {S T : Finset ℕ} (hw0 : 0 < w) (hw1 : w < 1)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    D.trueVar w S T = D.naiveVar w S T ↔ Disjoint S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  rw [D.trueVar_eq_naiveVar_add hS hT]
  constructor
  · intro h
    have hz : 2 * w * (1 - w) * D.sigma ^ 2 * ((S ∩ T).card : ℝ) /
        ((S.card : ℝ) * (T.card : ℝ)) = 0 := by linarith
    have hden : ((S.card : ℝ) * (T.card : ℝ)) ≠ 0 := by positivity
    have hnum : 2 * w * (1 - w) * D.sigma ^ 2 * ((S ∩ T).card : ℝ) = 0 := by
      field_simp at hz; simpa using hz
    have hpos : 0 < 2 * w * (1 - w) * D.sigma ^ 2 := by
      have := D.sigma_pos
      have h2 : 0 < 2 * w * (1 - w) := by nlinarith
      positivity
    have hcard : ((S ∩ T).card : ℝ) = 0 := by
      rcases mul_eq_zero.1 hnum with h' | h'
      · exact absurd h' (ne_of_gt hpos)
      · exact h'
    have : (S ∩ T).card = 0 := by exact_mod_cast hcard
    exact Finset.disjoint_iff_inter_eq_empty.2 (Finset.card_eq_zero.1 this)
  · intro h
    rw [Finset.disjoint_iff_inter_eq_empty.1 h]
    simp

/-! ### Failure mode 1: one dataset counted twice -/

/-- **The retracted three-leg joint, exactly.**  Pooling a leg with *itself* (the `G1`/`B`
double count, in the limiting case of identical draws) reports precisely half of the true
variance: the error bar is shrunk by `√2` while the point estimate is unchanged. -/
theorem duplicate_leg_halves_variance {S : Finset ℕ} (hS : S.Nonempty) :
    D.trueVar (1 / 2) S S = 2 * D.naiveVar (1 / 2) S S := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  rw [D.trueVar_eq_naiveVar_add hS hS, naiveVar, Finset.inter_self]
  field_simp
  ring

/-- The double-counted pool is *no better than one leg*: its true variance is the single-leg
variance, not the halved one advertised. -/
theorem duplicate_leg_trueVar {S : Finset ℕ} (hS : S.Nonempty) :
    D.trueVar (1 / 2) S S = D.sigma ^ 2 / (S.card : ℝ) := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  rw [D.trueVar_eq_naiveVar_add hS hS, naiveVar, Finset.inter_self]
  field_simp
  ring

/-! ### Failure mode 2: a prefix nested in a longer run -/

/-- Inverse-variance weight for two legs treated as independent sample means: proportional to
sample size. -/
noncomputable def ivw (S T : Finset ℕ) : ℝ := (S.card : ℝ) / ((S.card : ℝ) + (T.card : ℝ))

/-- With inverse-variance weights the *reported* variance is the pooled-sample-size one. -/
theorem naiveVar_ivw {S T : Finset ℕ} (hS : S.Nonempty) (hT : T.Nonempty) :
    D.naiveVar (ivw S T) S T = D.sigma ^ 2 / ((S.card : ℝ) + (T.card : ℝ)) := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hsum : (0 : ℝ) < (S.card : ℝ) + (T.card : ℝ) := by linarith
  rw [naiveVar, ivw]
  field_simp
  ring

/-- **Nested legs, honest variance.**  For `S ⊆ T` pooled by inverse variance,
`Var = σ²(3|S| + |T|)/(|S| + |T|)²`. -/
theorem nested_ivw_trueVar {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty) (hT : T.Nonempty) :
    D.trueVar (ivw S T) S T =
      D.sigma ^ 2 * (3 * (S.card : ℝ) + (T.card : ℝ)) / ((S.card : ℝ) + (T.card : ℝ)) ^ 2 := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hsum : (0 : ℝ) < (S.card : ℝ) + (T.card : ℝ) := by linarith
  rw [D.trueVar_eq_naiveVar_add hS hT, D.naiveVar_ivw hS hT, ivw,
    Finset.inter_eq_left.2 hST]
  field_simp
  ring

/-- **The inflation factor of a nested pool.** -/
theorem nested_ivw_inflation {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty) (hT : T.Nonempty) :
    D.trueVar (ivw S T) S T =
      ((3 * (S.card : ℝ) + (T.card : ℝ)) / ((S.card : ℝ) + (T.card : ℝ)))
        * D.naiveVar (ivw S T) S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hsum : (0 : ℝ) < (S.card : ℝ) + (T.card : ℝ) := by linarith
  rw [D.nested_ivw_trueVar hST hS hT, D.naiveVar_ivw hS hT]
  field_simp

/-- The inflation factor of a nested pool is strictly bigger than `1`: the reported CI is
always too narrow. -/
theorem nested_inflation_gt_one {S T : Finset ℕ} (hS : S.Nonempty) (hT : T.Nonempty) :
    1 < (3 * (S.card : ℝ) + (T.card : ℝ)) / ((S.card : ℝ) + (T.card : ℝ)) := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  rw [lt_div_iff₀ (by linarith)]
  linarith

/-- **Pooling a prefix with its own superset is worse than throwing the prefix away.**
The honest variance of the nested pool strictly exceeds the variance of the long leg alone
whenever the prefix is proper. -/
theorem nested_pool_worse_than_large_leg {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty)
    (hlt : S.card < T.card) :
    D.sigma ^ 2 / (T.card : ℝ) < D.trueVar (ivw S T) S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hT : T.Nonempty := Finset.card_pos.1 (lt_of_le_of_lt (Nat.zero_le _) hlt)
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hcast : (S.card : ℝ) < (T.card : ℝ) := by exact_mod_cast hlt
  have hsum : (0 : ℝ) < (S.card : ℝ) + (T.card : ℝ) := by linarith
  rw [D.nested_ivw_trueVar hST hS hT, div_lt_div_iff₀ hcT (by positivity)]
  have hσ : 0 < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  nlinarith [mul_pos hcS (sub_pos.2 hcast), sq_nonneg ((S.card : ℝ) - (T.card : ℝ))]

/-- **The exp569 / exp569b geometry.**  `G1` is the `150 000`-sample prefix of `B`'s
`600 000` samples per `N`: `|T| = 4|S|`, and the honest variance of the pooled pair is
exactly `7/5` of the reported one. -/
theorem quarter_prefix_inflation {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty)
    (hcard : T.card = 4 * S.card) :
    D.trueVar (ivw S T) S T = (7 / 5) * D.naiveVar (ivw S T) S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hT : T.Nonempty := by
    refine Finset.card_pos.1 ?_
    rw [hcard]
    exact Nat.mul_pos (by norm_num) (Finset.card_pos.2 hS)
  have hcast : (T.card : ℝ) = 4 * (S.card : ℝ) := by exact_mod_cast hcard
  rw [D.nested_ivw_inflation hST hS hT, hcast]
  congr 1
  field_simp
  ring

/-! ### What the inflation does to the gate -/

/-- The `z`-statistic of a deficit `d` against a variance `v`. -/
noncomputable def zscore (d v : ℝ) : ℝ := d / Real.sqrt v

/-- Rescaling the variance by `f` rescales the `z`-statistic by `1/√f`. -/
theorem zscore_scaled {d v f : ℝ} (hf : 0 ≤ f) :
    zscore d (f * v) = zscore d v / Real.sqrt f := by
  rw [zscore, zscore, Real.sqrt_mul hf]
  field_simp

/-- **The gate is retracted.**  With the audited nesting (`|T| = 4|S|`, inflation `7/5`), any
deficit whose *reported* two-sided statistic reaches at most `2.14` — the value obtained from
the corrected joint `CI [0.9226, 0.9966]` — has honest statistic strictly below the `1.96`
threshold.  Overlap alone dissolves the exclusion of `1`; no confirmed deviation is available
from seed `20260824`. -/
theorem gate_retracted_at_quarter_prefix {d v : ℝ} (hd : 0 ≤ d) (hv : 0 < v)
    (hz : zscore d v ≤ 2.14) : zscore d ((7 / 5) * v) < 1.96 := by
  rw [zscore_scaled (by norm_num)]
  have hs : Real.sqrt v > 0 := Real.sqrt_pos.2 hv
  have hz0 : 0 ≤ zscore d v := div_nonneg hd hs.le
  have h75 : (1.1832 : ℝ) < Real.sqrt (7 / 5) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 7 / 5),
      Real.sqrt_nonneg ((7 : ℝ) / 5)]
  have hpos : (0 : ℝ) < Real.sqrt (7 / 5) := by linarith
  rw [div_lt_iff₀ hpos]
  nlinarith

/-- The honest confidence half-width of the nested pool is `√(7/5) ≈ 1.183` times the reported
one; equivalently the reported interval covers only about `84.6%` of the honest length. -/
theorem quarter_prefix_width_ratio :
    Real.sqrt ((7 : ℝ) / 5) < 1.1833 ∧ (1.1832 : ℝ) < Real.sqrt ((7 : ℝ) / 5) := by
  constructor
  · nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 7 / 5), Real.sqrt_nonneg ((7:ℝ) / 5)]
  · nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 7 / 5), Real.sqrt_nonneg ((7:ℝ) / 5)]

end Design

/-! ### Non-vacuity

The `Design` axioms are satisfiable: the standard orthonormal stream in `ℓ²(ℕ)` realises any
per-draw scale `σ > 0`.  Hence every theorem above is a statement about a nonempty class of
models. -/

/-- A concrete design with any prescribed `σ > 0`, in the Hilbert space `ℓ²(ℕ)`. -/
noncomputable def sequenceDesign {s : ℝ} (hs : 0 < s) : Design (lp (fun _ : ℕ => ℝ) 2) where
  draw i := lp.single 2 i s
  sigma := s
  sigma_pos := hs
  orth i j hij := by
    simp only [lp.inner_single_left, lp.single_apply, RCLike.inner_apply, conj_trivial]
    simp [hij]
  scale i := by
    simp only [lp.inner_single_left, lp.single_apply, RCLike.inner_apply, conj_trivial]
    simp [sq]

theorem sequenceDesign_sigma {s : ℝ} (hs : 0 < s) : (sequenceDesign hs).sigma = s := rfl

end Catalog.Physics.PoolingAudit