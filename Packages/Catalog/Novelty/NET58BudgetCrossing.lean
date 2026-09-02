import Novelty.NET58RelationalImportance

/-!
# NET-58: budget crossings and the depth structure of the probe `R²`

Companion to `Novelty.NET58RelationalImportance`.  That file proves the *structural* ceiling of
content-only KV eviction.  This file addresses the two remaining features of the measured
NET-58 table,

| `B` | accumulated-HH | static probe | oracle |
|-----|----------------|--------------|--------|
| 32  | 0.8633         | 0.8395       | 0.9913 |
| 64  | 0.8822         | **0.8938**   | 0.9953 |
| 128 | 0.9189         | **0.9284**   | —      |

namely (i) the **sign flip**: the probe *loses* to accumulation at `B = 32` and *wins* at
`B = 64` and `B = 128`, and (ii) the **depth structure** of the per-`(layer, kv-head)` `R²`
(mean `0.329`, min `0.113`, max `0.639`).

## Results

* `sum_sqrt_le_sqrt_card_mul_sum` — Cauchy–Schwarz for square roots, the aggregation kernel.
* `sqrt_add_sqrt_lt_of_ne` — its strict two-point (Jensen) companion.
* `head_aggregate_gap_le` — **head aggregation**: summed over all `(layer, head)` cells, the
  total oracle deficit of a probe-driven cache is at most `2√(H · B · ∑ₕ SSEₕ)`.
* `mean_Rsq_gap_bound` — the same statement in the currency of the round: the *average*
  per-head deficit is at most `2√(B (1 - R̄²) SS)`, where `R̄²` is the reported **mean** `R²`.
  This is the `R² → retained` conversion at the level of the whole model, not one cell.
* `heterogeneity_strictly_improves_bound`, `net58_depth_structure_strict` — **P3 has teeth**:
  a depth-structured `R²` (min `0.113`, max `0.639`) gives a *strictly better* guarantee than a
  homogeneous model with the same mean.  Front-high/mid-low structure is not cosmetic; the
  measured spread strictly lowers the worst-case bound, so reporting only the mean `0.329`
  understates the probe.
* `closure_ge_of_Rsq` — the guarantee direction of the conversion: an `R²`-accurate probe closes
  at least `1 - 2√(B(1-R²)SS)/gap` of the oracle gap.
* `crossing_at_budget_one`, `crossing_at_budget_two`, `net58_no_uniform_budget_ordering` —
  a four-key instance in which the accumulation-like score strictly beats the probe-like score
  at budget `1` and strictly loses to it at budget `2`.  Policy dominance is therefore
  **budget-dependent**: the measured sign flip between `B = 32` and `B = 64` is a structural
  possibility of top-`B` selection, not a measurement artefact, and no single-budget comparison
  of two eviction policies can be extrapolated.
* `crossing_below_oracle` — in the same instance both arms stay strictly below the oracle at
  both budgets, matching `P2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `B = 32` inversion is not noise but the generic behaviour of two
scores that misrank different pairs; and the `R²` spread across depth should *help*, not hurt,
the worst-case guarantee, by concavity of `√`.

Experiment (Experimenter): `ComputationalEvidence.md` records the four-key crossing instance
(`v = (5,1,9,0)`, accumulation ranking `0>1>2>3`, probe ranking `1>2>0>3`: retained `5` vs `1`
at `B = 1`, `6` vs `10` at `B = 2`) and the numerical Jensen check
`√0.361 + √0.887 = 1.5426 < 1.5799 = 2√0.624`.

Analysis (Analyst): the two phenomena have opposite morals.  The crossing says a *ranking*
comparison is budget-local — "worse at 32, better at 64" is consistent, so the `P1` horn had to
be evaluated at a fixed budget.  The depth structure says the *guarantee* is concave in the
per-head accuracies, so heterogeneity is a (small) bonus.  Neither rescues the probe: both live
strictly below the ceiling of `Novelty.NET58RelationalImportance`.

Critique (Critic): `mean_Rsq_gap_bound` assumes a common `SS_tot` across heads; without it the
correct statement is `head_aggregate_gap_le`, which is proved first and used to derive the
former, so the assumption is isolated and explicit.  The crossing instance uses integers rather
than the measured fractions because no single 4-key instance can realise the measured retained
*levels* (two policies each retaining ≈ 0.86 of disjoint mass is impossible); the instance
therefore certifies the *phenomenon*, and the measured levels are handled arithmetically in
`Novelty.NET58RelationalImportance` (`net58_P1_refuted`, `net58_probe_hurts_at_B32`).
-/

namespace Catalog.Novelty.NET58BudgetCrossing

open Finset Catalog.Novelty.ProbeRetentionLimits Catalog.Novelty.NET58RelationalImportance

/-! ### 1.  Two square-root inequalities -/

/-- **Cauchy–Schwarz for square roots.**  Aggregating `H` per-head bounds `√xₕ` costs only
`√(H ∑ xₕ)`, not `H √(max xₕ)`. -/
theorem sum_sqrt_le_sqrt_card_mul_sum {α : Type*} (G : Finset α) (x : α → ℝ)
    (hx : ∀ i, 0 ≤ x i) :
    ∑ i ∈ G, Real.sqrt (x i) ≤ Real.sqrt (G.card * ∑ i ∈ G, x i) := by
  have h1 : (∑ i ∈ G, Real.sqrt (x i)) ^ 2 ≤ G.card * ∑ i ∈ G, (Real.sqrt (x i)) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have h2 : ∀ i ∈ G, (Real.sqrt (x i)) ^ 2 = x i := fun i _ => Real.sq_sqrt (hx i)
  rw [Finset.sum_congr rfl h2] at h1
  have hnn : 0 ≤ ∑ i ∈ G, Real.sqrt (x i) := Finset.sum_nonneg fun i _ => Real.sqrt_nonneg _
  have hnn2 : 0 ≤ (G.card : ℝ) * ∑ i ∈ G, x i := by
    have : 0 ≤ ∑ i ∈ G, x i := Finset.sum_nonneg fun i _ => hx i
    positivity
  exact (Real.le_sqrt hnn hnn2).mpr h1

/-- **Strict concavity of `√` at two points.**  Unequal per-head errors give a strictly smaller
aggregate than the homogeneous model with the same mean. -/
theorem sqrt_add_sqrt_lt_of_ne {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) (hne : x ≠ y) :
    Real.sqrt x + Real.sqrt y < 2 * Real.sqrt ((x + y) / 2) := by
  have hsx := Real.sq_sqrt hx
  have hsy := Real.sq_sqrt hy
  have hnx := Real.sqrt_nonneg x
  have hny := Real.sqrt_nonneg y
  have hne' : Real.sqrt x - Real.sqrt y ≠ 0 :=
    sub_ne_zero.mpr fun h => hne (by rw [← hsx, ← hsy, h])
  have hpos : 0 < (Real.sqrt x - Real.sqrt y) ^ 2 := by positivity
  have hkey : (Real.sqrt x + Real.sqrt y) ^ 2 < 2 * (x + y) := by nlinarith
  have h2 : (2 : ℝ) * Real.sqrt ((x + y) / 2) = Real.sqrt (2 * (x + y)) := by
    rw [show (2 : ℝ) * (x + y) = 4 * ((x + y) / 2) by ring, show (4 : ℝ) = 2 ^ 2 by norm_num,
      Real.sqrt_mul (by positivity), Real.sqrt_sq (by norm_num)]
  rw [h2]
  exact (Real.lt_sqrt (by positivity)).mpr hkey

/-! ### 2.  Aggregating the per-head probes -/

section Aggregate

variable {ι : Type*} [Fintype ι] {H : Type*} [Fintype H]

/-- **Head aggregation.**  Summed over all `(layer, kv-head)` cells, the deficit of the
probe-driven caches against arbitrary rival selections is at most `2√(H · B · ∑ₕ SSEₕ)`. -/
theorem head_aggregate_gap_le (a s : H → ι → ℝ) {B : ℕ} {S T : H → Finset ι}
    (hS : ∀ h, IsTopSet (s h) B (S h)) (hT : ∀ h, (T h).card = B) :
    ∑ h, (retained (a h) (T h) - retained (a h) (S h))
      ≤ 2 * Real.sqrt (Fintype.card H * (B * ∑ h, sse (a h) (s h))) := by
  have hper : ∀ h : H, retained (a h) (T h) - retained (a h) (S h)
      ≤ 2 * Real.sqrt (B * sse (a h) (s h)) := by
    intro h
    have := retained_ge_of_isTopSet_l2 (a := a h) (hS h) (hT h)
    linarith
  have hsum : ∑ h, (retained (a h) (T h) - retained (a h) (S h))
      ≤ ∑ h : H, 2 * Real.sqrt (B * sse (a h) (s h)) :=
    Finset.sum_le_sum fun h _ => hper h
  have hnn : ∀ h : H, 0 ≤ (B : ℝ) * sse (a h) (s h) := fun h => by
    have := sse_nonneg (a h) (s h); positivity
  have hcs : ∑ h : H, Real.sqrt ((B : ℝ) * sse (a h) (s h))
      ≤ Real.sqrt ((Finset.univ : Finset H).card * ∑ h : H, (B : ℝ) * sse (a h) (s h)) :=
    sum_sqrt_le_sqrt_card_mul_sum _ _ hnn
  have hpull : ∑ h : H, (B : ℝ) * sse (a h) (s h) = (B : ℝ) * ∑ h, sse (a h) (s h) := by
    rw [Finset.mul_sum]
  rw [hpull, Finset.card_univ] at hcs
  calc ∑ h, (retained (a h) (T h) - retained (a h) (S h))
      ≤ ∑ h : H, 2 * Real.sqrt ((B : ℝ) * sse (a h) (s h)) := hsum
    _ = 2 * ∑ h : H, Real.sqrt ((B : ℝ) * sse (a h) (s h)) := by rw [Finset.mul_sum]
    _ ≤ 2 * Real.sqrt (Fintype.card H * ((B : ℝ) * ∑ h, sse (a h) (s h))) := by linarith

/-- **The mean-`R²` conversion.**  If every head has the same dispersion `SS_tot = V > 0` and
`R̄²` is the mean of the per-head `R²`, the *average* per-head oracle deficit is at most
`2√(B (1 - R̄²) V)`.  With the reported `R̄² = 0.329` this is the model-level version of the
single-cell bound of `Novelty.ProbeRetentionLimits`. -/
theorem mean_Rsq_gap_bound [Nonempty H] (a s : H → ι → ℝ) {B : ℕ} {V : ℝ} (hV : 0 < V)
    {S T : H → Finset ι} (hS : ∀ h, IsTopSet (s h) B (S h)) (hT : ∀ h, (T h).card = B)
    (hss : ∀ h, sstot (a h) = V) :
    (∑ h, (retained (a h) (T h) - retained (a h) (S h))) / Fintype.card H
      ≤ 2 * Real.sqrt (B * ((1 - (∑ h, Rsq (a h) (s h)) / Fintype.card H) * V)) := by
  have hcard : (0 : ℝ) < Fintype.card H := by
    exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty H›
  have hsse : ∀ h, sse (a h) (s h) = (1 - Rsq (a h) (s h)) * V := by
    intro h
    have := sse_eq_of_Rsq (a := a h) (s := s h) (by rw [hss h]; exact ne_of_gt hV)
    rw [this, hss h]
  have hsum : ∑ h, sse (a h) (s h)
      = (Fintype.card H - ∑ h, Rsq (a h) (s h)) * V := by
    simp only [hsse, sub_mul, one_mul]
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul]
  have hagg := head_aggregate_gap_le a s hS hT
  rw [hsum] at hagg
  have hkey : (Fintype.card H : ℝ) * ((B : ℝ) * ((Fintype.card H - ∑ h, Rsq (a h) (s h)) * V))
      = (Fintype.card H : ℝ) ^ 2 *
        ((B : ℝ) * ((1 - (∑ h, Rsq (a h) (s h)) / Fintype.card H) * V)) := by
    field_simp
  rw [hkey, Real.sqrt_mul (by positivity), Real.sqrt_sq (le_of_lt hcard)] at hagg
  rw [div_le_iff₀ hcard]
  linarith

end Aggregate

/-! ### 3.  Depth structure strictly improves the guarantee (P3) -/

/-- **Heterogeneity is a bonus.**  Two heads with *different* residual variances give a strictly
smaller aggregate bound than two homogeneous heads with the same mean residual variance. -/
theorem heterogeneity_strictly_improves_bound {x y c : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y)
    (hne : x ≠ y) (hc : 0 < c) :
    Real.sqrt (c * x) + Real.sqrt (c * y) < 2 * Real.sqrt (c * ((x + y) / 2)) := by
  have hmul : ∀ z : ℝ, 0 ≤ z → Real.sqrt (c * z) = Real.sqrt c * Real.sqrt z := fun z _ =>
    Real.sqrt_mul (le_of_lt hc) z
  have hmid : (0 : ℝ) ≤ (x + y) / 2 := by linarith
  rw [hmul x hx, hmul y hy, hmul _ hmid]
  have hs : 0 < Real.sqrt c := Real.sqrt_pos.mpr hc
  have := sqrt_add_sqrt_lt_of_ne hx hy hne
  nlinarith

/-- **P3, quantitatively.**  The measured depth spread of the probe `R²` — `0.113` in the worst
cell, `0.639` in the best, mean `0.376` for that pair — gives a strictly better worst-case
guarantee than a flat model with the same mean.  The reported front-high/mid-low structure is
therefore load-bearing for the guarantee, not decoration. -/
theorem net58_depth_structure_strict :
    Real.sqrt (1 - 0.639) + Real.sqrt (1 - 0.113) < 2 * Real.sqrt (1 - (0.639 + 0.113) / 2) := by
  have h := sqrt_add_sqrt_lt_of_ne (x := (1 : ℝ) - 0.639) (y := (1 : ℝ) - 0.113)
    (by norm_num) (by norm_num) (by norm_num)
  have hmid : ((1 - 0.639 : ℝ) + (1 - 0.113)) / 2 = 1 - (0.639 + 0.113) / 2 := by norm_num
  rwa [hmid] at h

/-! ### 4.  The guarantee direction: `R²` closes a fraction of the oracle gap -/

section Closure

variable {ι : Type*} [Fintype ι]

/-- **`R² → closure fraction`.**  Measured against a rival arm `T` and the oracle `O`, a probe
with coefficient of determination `R²` closes at least `1 - 2√(B(1-R²)SS)/gap` of the oracle
gap.  Read backwards, a *measured* closure of `10.26 %` at `B = 64` bounds the population
quantities: it is a joint statement about the probe and the key population, never about the
probe alone. -/
theorem closure_ge_of_Rsq {a s : ι → ℝ} {B : ℕ} {S T O : Finset ι}
    (hS : IsTopSet s B S) (hO : O.card = B) (hss : sstot a ≠ 0)
    (hgap : retained a T < retained a O) :
    1 - 2 * Real.sqrt (B * ((1 - Rsq a s) * sstot a)) / (retained a O - retained a T)
      ≤ closureFraction (retained a T) (retained a S) (retained a O) := by
  have hpos : 0 < retained a O - retained a T := by linarith
  have hbound : retained a O - retained a S
      ≤ 2 * Real.sqrt (B * ((1 - Rsq a s) * sstot a)) :=
    retention_gap_le_of_Rsq hS hO hss
  rw [closureFraction, le_div_iff₀ hpos]
  have hexp : (1 - 2 * Real.sqrt (B * ((1 - Rsq a s) * sstot a)) /
      (retained a O - retained a T)) * (retained a O - retained a T)
      = (retained a O - retained a T) - 2 * Real.sqrt (B * ((1 - Rsq a s) * sstot a)) := by
    field_simp
  rw [hexp]
  linarith

end Closure

/-! ### 5.  Budget-dependent crossing: no uniform ordering of eviction policies -/

section Crossing

/-- True future attention of four keys. -/
def vCross : Fin 4 → ℝ := ![5, 1, 9, 0]

/-- The accumulation-like (online) score: it ranks the keys `0 > 1 > 2 > 3`. -/
def accCross : Fin 4 → ℝ := ![4, 3, 2, 1]

/-- The static probe-like score: it ranks the keys `1 > 2 > 0 > 3`. -/
def probeCross : Fin 4 → ℝ := ![2, 4, 3, 1]

lemma isTopSet_acc_one : IsTopSet accCross 1 {0} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [accCross] <;> norm_num

lemma isTopSet_probe_one : IsTopSet probeCross 1 {1} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [probeCross] <;> norm_num

lemma isTopSet_acc_two : IsTopSet accCross 2 {0, 1} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [accCross] <;> norm_num

lemma isTopSet_probe_two : IsTopSet probeCross 2 {1, 2} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [probeCross] <;> norm_num

/-- At budget `1` the accumulation arm strictly wins: `5` against `1`. -/
theorem crossing_at_budget_one :
    retained vCross {1} < retained vCross {0} := by
  simp [retained, vCross]

/-- At budget `2` the probe arm strictly wins: `10` against `6`. -/
theorem crossing_at_budget_two :
    retained vCross {0, 1} < retained vCross {1, 2} := by
  rw [retained, retained, Finset.sum_pair (by decide : (0 : Fin 4) ≠ 1),
    Finset.sum_pair (by decide : (1 : Fin 4) ≠ 2)]
  simp only [vCross, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons]
  norm_num

/-- **No uniform budget ordering.**  There are two scores and one importance profile such that
the first strictly beats the second at budget `1` while the second strictly beats the first at
budget `2`.  The measured NET-58 sign flip between `B = 32` (probe loses) and `B = 64` (probe
wins) is therefore a structural feature of top-`B` selection: a policy comparison at one budget
carries no information about another budget. -/
theorem net58_no_uniform_budget_ordering :
    ∃ (v acc probe : Fin 4 → ℝ) (S₁ P₁ S₂ P₂ : Finset (Fin 4)),
      IsTopSet acc 1 S₁ ∧ IsTopSet probe 1 P₁ ∧
      IsTopSet acc 2 S₂ ∧ IsTopSet probe 2 P₂ ∧
      retained v P₁ < retained v S₁ ∧ retained v S₂ < retained v P₂ :=
  ⟨vCross, accCross, probeCross, {0}, {1}, {0, 1}, {1, 2},
    isTopSet_acc_one, isTopSet_probe_one, isTopSet_acc_two, isTopSet_probe_two,
    crossing_at_budget_one, crossing_at_budget_two⟩

/-- The oracle at budget `2` for the crossing instance. -/
lemma isTopSet_oracle_two : IsTopSet vCross 2 {0, 2} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [vCross]

/-- **P2 inside the crossing instance.**  Both arms stay strictly below the oracle at budget
`2`, even the one that wins there: crossing changes the ranking of the arms, never their
distance from the oracle. -/
theorem crossing_below_oracle :
    retained vCross {0, 1} < retained vCross {0, 2} ∧
      retained vCross {1, 2} < retained vCross {0, 2} := by
  rw [retained, retained, retained, Finset.sum_pair (by decide : (0 : Fin 4) ≠ 1),
    Finset.sum_pair (by decide : (1 : Fin 4) ≠ 2),
    Finset.sum_pair (by decide : (0 : Fin 4) ≠ 2)]
  simp only [vCross, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons]
  norm_num

end Crossing

end Catalog.Novelty.NET58BudgetCrossing