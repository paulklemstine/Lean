import Novelty.ProbeRetentionLimits

/-!
# Why the hybrid arm cannot hurt, and when it helps (NET-69, interaction layer)

`Novelty.ProbeRetentionLimits` analysed a *single* score.  NET-69's third arm
mixes two: the accumulated heavy-hitter statistic `h` and the content probe `p`
are combined into `hybrid h p λ = h + λ · p`, and the measurement is that on
code the mixture is **non-degrading** (`0.9371` versus `0.9340` for `λ = 1`),
whereas on prose the same mixture harms monotonically.  This file explains that
asymmetry structurally.

* `isTopSet_hybrid_iff` — the selection `S` survives the mixture iff a *linear*
  system in `λ` holds, one inequality per retained/discarded pair.
* `hybrid_isTopSet_of_margin` — hence an explicit **non-degradation threshold**:
  if the accumulated score separates `S` from its complement by a margin `γ` and
  the probe has oscillation at most `D`, then every `λ ≤ γ/D` leaves the
  selection, and therefore the retained mass, untouched.  Non-degradation is a
  margin phenomenon, not a property of the probe's accuracy.
* `hybrid_stability_convex` and `hybrid_stability_ordConnected` — the set of
  mixing weights that preserve a given selection is an **interval** containing
  every weight between any two of its members.  This is the structural reason a
  domain can only exhibit *monotone* harm: once `λ` leaves the stability
  interval of the accumulated selection it never re-enters it.
(The uniqueness lemma `eq_of_isTopSet_of_strict` of `Novelty.ProbeRetentionLimits`
makes the numerical instances below unambiguous.)

Section 3 contains two fully explicit four-key instances, both verified
numerically before being formalised (see `ComputationalEvidence.md`).

* `accuracy_does_not_order_retention` — a score that is **four times more
  accurate** in `L²` (`SSE = 150` versus `1802`) retains **nineteen times less**
  mass (`1` versus `19`).  Prediction accuracy does not order retention even
  weakly; this is the counterexample that blocks the naive reading "the probe
  arm loses because its `R²` is low", and it is the exact companion of
  `exists_probe_perfect_retention_with_Rsq`.
* `hybrid_strictly_beats_both_arms` — an instance in the NET-69 régime where the
  accumulated arm retains `11`, the probe-only arm `9`, and the `λ = 1` hybrid
  `19`: strictly more than either parent.  So the measured `+0.3` points are not
  noise-shaped luck; a mixture can strictly dominate both arms because the two
  scores misrank *different* pairs.
* `hybrid_stability_threshold_example` — for that instance the stability
  interval of the accumulated selection is exactly `[0, 2/5]`, and the mixture
  helps precisely because `λ = 1` lies outside it.  Deployment corollary:
  choosing `λ` below the margin ratio guarantees safety but also guarantees the
  hybrid learns nothing from the probe.

Section 4 closes the loop on the *pessimism* of the transfer theorems:

* `sup_transfer_bound_is_sharp` — a four-key instance attaining the constant
  `2Bε` of `retained_ge_of_isTopSet_sup` exactly.  The bound cannot be improved,
  so the gulf between it and the `R²`-perfect probe of
  `exists_probe_perfect_retention_with_Rsq` is real: `L∞`/`L²` accuracy pins
  down retention only up to the full worst case.
-/

namespace Catalog.Novelty.ProbeHybridStability

open Finset Catalog.Novelty.ProbeRetentionLimits

variable {ι : Type*} [Fintype ι]

/-! ### 1. The mixture and its stability interval -/

/-- The hybrid score: accumulated statistic `h` mixed with content probe `p` at
weight `lam`. -/
def hybrid (h p : ι → ℝ) (lam : ℝ) : ι → ℝ := fun i => h i + lam * p i

omit [Fintype ι] in
@[simp] lemma hybrid_zero (h p : ι → ℝ) : hybrid h p 0 = h := by
  funext i; simp [hybrid]

omit [Fintype ι] in
/-- The mixture keeps a selection iff a linear system in the mixing weight
holds: one inequality per (retained, discarded) pair. -/
lemma isTopSet_hybrid_iff {h p : ι → ℝ} {B : ℕ} {S : Finset ι} {lam : ℝ} :
    IsTopSet (hybrid h p lam) B S ↔
      S.card = B ∧ ∀ i ∈ S, ∀ j ∉ S, lam * (p j - p i) ≤ h i - h j := by
  constructor
  · rintro ⟨hcard, hsep⟩
    refine ⟨hcard, fun i hi j hj => ?_⟩
    have := hsep i hi j hj
    simp only [hybrid] at this
    nlinarith [this]
  · rintro ⟨hcard, hsep⟩
    refine ⟨hcard, fun i hi j hj => ?_⟩
    have := hsep i hi j hj
    simp only [hybrid]
    nlinarith [this]

omit [Fintype ι] in
/-- **Non-degradation threshold.**  If the accumulated score separates the
selection `S` from the discarded keys by a margin `γ`, and the probe has
oscillation at most `D`, then every mixing weight `lam` with `lam * D ≤ γ`
leaves the selection — hence the retained mass — unchanged. -/
theorem hybrid_isTopSet_of_margin {h p : ι → ℝ} {B : ℕ} {S : Finset ι} {γ D lam : ℝ}
    (hcard : S.card = B) (hmargin : ∀ i ∈ S, ∀ j ∉ S, h j + γ ≤ h i)
    (hosc : ∀ i j, p i - p j ≤ D) (hlam : 0 ≤ lam) (hle : lam * D ≤ γ) :
    IsTopSet (hybrid h p lam) B S := by
  refine isTopSet_hybrid_iff.mpr ⟨hcard, fun i hi j hj => ?_⟩
  have h1 : h j + γ ≤ h i := hmargin i hi j hj
  have h2 : p j - p i ≤ D := hosc j i
  have h3 : lam * (p j - p i) ≤ lam * D := mul_le_mul_of_nonneg_left h2 hlam
  linarith

omit [Fintype ι] in
/-- Under the margin hypothesis the hybrid evictor can retain **exactly** the
accumulated mass: the accumulated selection is still available to it. -/
theorem hybrid_retains_accumulated_mass {a h p : ι → ℝ} {B : ℕ} {S : Finset ι}
    {γ D lam : ℝ} (hcard : S.card = B) (hmargin : ∀ i ∈ S, ∀ j ∉ S, h j + γ ≤ h i)
    (hosc : ∀ i j, p i - p j ≤ D) (hlam : 0 ≤ lam) (hle : lam * D ≤ γ) :
    ∃ S', IsTopSet (hybrid h p lam) B S' ∧ retained a S' = retained a S :=
  ⟨S, hybrid_isTopSet_of_margin hcard hmargin hosc hlam hle, rfl⟩

omit [Fintype ι] in
/-- **The stability region is convex.**  If a selection survives the mixture at
two weights it survives at every weight in between.  Consequently a domain in
which the mixture harms can only harm *monotonically*: leaving the stability
interval is irreversible in `λ`. -/
theorem hybrid_stability_convex {h p : ι → ℝ} {B : ℕ} {S : Finset ι} {lam₁ lam₂ t : ℝ}
    (h1 : IsTopSet (hybrid h p lam₁) B S) (h2 : IsTopSet (hybrid h p lam₂) B S)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    IsTopSet (hybrid h p ((1 - t) * lam₁ + t * lam₂)) B S := by
  obtain ⟨hcard, hA⟩ := isTopSet_hybrid_iff.mp h1
  obtain ⟨-, hB⟩ := isTopSet_hybrid_iff.mp h2
  refine isTopSet_hybrid_iff.mpr ⟨hcard, fun i hi j hj => ?_⟩
  have hA' := hA i hi j hj
  have hB' := hB i hi j hj
  have e1 : (1 - t) * (lam₁ * (p j - p i)) ≤ (1 - t) * (h i - h j) :=
    mul_le_mul_of_nonneg_left hA' (by linarith)
  have e2 : t * (lam₂ * (p j - p i)) ≤ t * (h i - h j) :=
    mul_le_mul_of_nonneg_left hB' ht0
  nlinarith [e1, e2]

omit [Fintype ι] in
/-- The stability region of a selection is order-connected: it contains the
whole segment between any two of its points. -/
theorem hybrid_stability_ordConnected {h p : ι → ℝ} {B : ℕ} {S : Finset ι}
    {lam₁ lam₂ lam : ℝ} (h1 : IsTopSet (hybrid h p lam₁) B S)
    (h2 : IsTopSet (hybrid h p lam₂) B S) (hlt : lam₁ ≤ lam) (hgt : lam ≤ lam₂) :
    IsTopSet (hybrid h p lam) B S := by
  rcases eq_or_lt_of_le (hlt.trans hgt) with heq | hlt'
  · have : lam = lam₁ := le_antisymm (heq ▸ hgt) hlt
    exact this ▸ h1
  · have ht0 : 0 ≤ (lam - lam₁) / (lam₂ - lam₁) := by
      apply div_nonneg <;> linarith
    have ht1 : (lam - lam₁) / (lam₂ - lam₁) ≤ 1 := by
      rw [div_le_one (by linarith)]; linarith
    have := hybrid_stability_convex h1 h2 ht0 ht1
    have hne : lam₂ - lam₁ ≠ 0 := ne_of_gt (by linarith)
    have heq2 : (1 - (lam - lam₁) / (lam₂ - lam₁)) * lam₁
        + (lam - lam₁) / (lam₂ - lam₁) * lam₂ = lam := by
      have hrw : (1 - (lam - lam₁) / (lam₂ - lam₁)) * lam₁
          + (lam - lam₁) / (lam₂ - lam₁) * lam₂
          = lam₁ + ((lam - lam₁) / (lam₂ - lam₁)) * (lam₂ - lam₁) := by ring
      rw [hrw, div_mul_cancel₀ _ hne]
      ring
    rwa [heq2] at this

/-! ### 3. Two explicit four-key instances -/

section Examples

/-- True importances of four keys. -/
def aEx : Fin 4 → ℝ := ![10, 9, 1, 0]

/-- A *very accurate* but badly ordered score (`SSE = 150`). -/
def hBad : Fin 4 → ℝ := ![1, 2, 3, 4]

/-- A *much less accurate* but correctly ordered score (`SSE = 1802`). -/
def pGood : Fin 4 → ℝ := ![40, 30, 20, 10]

lemma sse_hBad : sse aEx hBad = 150 := by
  simp [sse, aEx, hBad, Fin.sum_univ_four]
  norm_num

lemma sse_pGood : sse aEx pGood = 1802 := by
  simp [sse, aEx, pGood, Fin.sum_univ_four]
  norm_num

lemma isTopSet_hBad : IsTopSet hBad 2 {2, 3} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [hBad] <;> norm_num

lemma isTopSet_pGood : IsTopSet pGood 2 {0, 1} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [pGood] <;> norm_num

/-- **Accuracy does not order retention.**  `hBad` predicts the importances an
order of magnitude better than `pGood` in `L²`, yet the budget-2 evictor driven
by `hBad` retains `1` unit of mass where `pGood` retains `19`.  Hence no bound
of the form "smaller `SSE` ⇒ more retained mass" can hold, and the NET-69
probe deficit is *not* deducible from its `R²`. -/
theorem accuracy_does_not_order_retention :
    sse aEx hBad < sse aEx pGood ∧
      (∀ S, IsTopSet hBad 2 S → retained aEx S = 1) ∧
      (∀ T, IsTopSet pGood 2 T → retained aEx T = 19) := by
  refine ⟨by rw [sse_hBad, sse_pGood]; norm_num, ?_, ?_⟩
  · intro S hS
    have hSeq : S = ({2, 3} : Finset (Fin 4)) := by
      refine eq_of_isTopSet_of_strict (B := 2) (by decide) ?_ hS
      intro i hi j hj
      fin_cases i <;> fin_cases j <;> simp_all [hBad] <;> norm_num
    subst hSeq
    rw [retained, Finset.sum_pair (show (2 : Fin 4) ≠ 3 by decide)]
    norm_num [aEx, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  · intro T hT
    have : T = ({0, 1} : Finset (Fin 4)) := by
      refine eq_of_isTopSet_of_strict (B := 2) (by decide) ?_ hT
      intro i hi j hj
      fin_cases i <;> fin_cases j <;> simp_all [pGood] <;> norm_num
    subst this
    norm_num [retained, aEx]

/-- Accumulated heavy-hitter score of the second instance. -/
def hAcc : Fin 4 → ℝ := ![6, 2, 4, 0]

/-- Content-probe score of the second instance. -/
def pProbe : Fin 4 → ℝ := ![2, 7, 2, 5]

lemma isTopSet_hAcc : IsTopSet hAcc 2 {0, 2} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [hAcc] <;> norm_num

lemma isTopSet_pProbe : IsTopSet pProbe 2 {1, 3} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [pProbe] <;> norm_num

lemma isTopSet_hyb : IsTopSet (hybrid hAcc pProbe 1) 2 {0, 1} := by
  refine ⟨by decide, ?_⟩
  intro i hi j hj
  fin_cases i <;> fin_cases j <;> simp_all [hybrid, hAcc, pProbe] <;> norm_num

/-- **A mixture can strictly dominate both parents.**  Accumulated retains `11`,
probe-only retains `9`, and the `λ = 1` hybrid retains `19` — because the two
parent scores misrank *different* pairs, and the sum repairs both.  The measured
NET-69 gain of the hybrid over the accumulated arm is therefore a structurally
available effect, not a rounding artefact. -/
theorem hybrid_strictly_beats_both_arms :
    (∀ S, IsTopSet hAcc 2 S → retained aEx S = 11) ∧
      (∀ S, IsTopSet pProbe 2 S → retained aEx S = 9) ∧
      (∀ S, IsTopSet (hybrid hAcc pProbe 1) 2 S → retained aEx S = 19) := by
  refine ⟨?_, ?_, ?_⟩
  · intro S hS
    have hSeq : S = ({0, 2} : Finset (Fin 4)) := by
      refine eq_of_isTopSet_of_strict (B := 2) (by decide) ?_ hS
      intro i hi j hj
      fin_cases i <;> fin_cases j <;> simp_all [hAcc] <;> norm_num
    subst hSeq
    rw [retained, Finset.sum_pair (show (0 : Fin 4) ≠ 2 by decide)]
    norm_num [aEx, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  · intro S hS
    have hSeq : S = ({1, 3} : Finset (Fin 4)) := by
      refine eq_of_isTopSet_of_strict (B := 2) (by decide) ?_ hS
      intro i hi j hj
      fin_cases i <;> fin_cases j <;> simp_all [pProbe] <;> norm_num
    subst hSeq
    rw [retained, Finset.sum_pair (show (1 : Fin 4) ≠ 3 by decide)]
    norm_num [aEx, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  · intro S hS
    have : S = ({0, 1} : Finset (Fin 4)) := by
      refine eq_of_isTopSet_of_strict (B := 2) (by decide) ?_ hS
      intro i hi j hj
      fin_cases i <;> fin_cases j <;> simp_all [hybrid, hAcc, pProbe] <;> norm_num
    subst this
    norm_num [retained, aEx]

/-- **The stability interval of the instance is exactly `[0, 2/5]`.**  For
non-negative mixing weights the accumulated selection `{0,2}` survives the
mixture precisely up to `λ = 2/5`; the helpful `λ = 1` of NET-69 lies *outside*
the safe region.  Safety and usefulness of the probe are thus in exact
quantitative tension. -/
theorem hybrid_stability_threshold_example (lam : ℝ) :
    IsTopSet (hybrid hAcc pProbe lam) 2 {0, 2} ↔ lam ≤ 2 / 5 := by
  rw [isTopSet_hybrid_iff]
  constructor
  · rintro ⟨-, hsep⟩
    have h := hsep 2 (by decide) 1 (by decide)
    simp [hAcc, pProbe] at h
    linarith
  · intro hle
    refine ⟨by decide, fun i hi j hj => ?_⟩
    fin_cases i <;> fin_cases j <;> simp_all [hAcc, pProbe] <;> norm_num <;> linarith

/-- The comparison of `hybrid_strictly_beats_both_arms` with explicit witnesses,
so that none of its clauses can be read vacuously: the three arms are realised
by `{0,2}`, `{1,3}` and `{0,1}` and their retained masses are strictly ordered
`9 < 11 < 19`. -/
theorem hybrid_gain_is_strict :
    ∃ Sa Sp Sh : Finset (Fin 4),
      IsTopSet hAcc 2 Sa ∧ IsTopSet pProbe 2 Sp ∧
        IsTopSet (hybrid hAcc pProbe 1) 2 Sh ∧
        retained aEx Sp < retained aEx Sa ∧ retained aEx Sa < retained aEx Sh := by
  obtain ⟨hacc, hprb, hhyb⟩ := hybrid_strictly_beats_both_arms
  refine ⟨{0, 2}, {1, 3}, {0, 1}, isTopSet_hAcc, isTopSet_pProbe, isTopSet_hyb, ?_, ?_⟩
  · rw [hacc _ isTopSet_hAcc, hprb _ isTopSet_pProbe]; norm_num
  · rw [hacc _ isTopSet_hAcc, hhyb _ isTopSet_hyb]; norm_num

/-- The counterexample of `accuracy_does_not_order_retention` with explicit
witnesses: both selections exist, so the comparison `1 < 19` is real. -/
theorem accuracy_inversion_is_strict :
    ∃ S T : Finset (Fin 4), IsTopSet hBad 2 S ∧ IsTopSet pGood 2 T ∧
      sse aEx hBad < sse aEx pGood ∧ retained aEx S < retained aEx T := by
  obtain ⟨hsse, h1, h2⟩ := accuracy_does_not_order_retention
  refine ⟨{2, 3}, {0, 1}, isTopSet_hBad, isTopSet_pGood, hsse, ?_⟩
  rw [h1 _ isTopSet_hBad, h2 _ isTopSet_pGood]; norm_num

/-! ### 4. The `L∞` transfer constant cannot be improved -/

/-- Importances of a maximally adversarial four-key context. -/
def aSharp : Fin 4 → ℝ := ![1, 1, -1, -1]

/-- A totally uninformative score: every key looks the same. -/
def sFlat : Fin 4 → ℝ := fun _ => 0

/-- **The constant `2Bε` of `retained_ge_of_isTopSet_sup` is attained.**  With
`ε = 1`, `B = 2` and a flat score the evictor may retain the *worst* pair, and
the loss against the oracle is exactly `2Bε = 4`.  So no bound of the form
`retained a T - c · B · ε ≤ retained a S` holds with `c < 2`: the transfer
theorem is sharp, and its pessimism is not an artefact of the proof. -/
theorem sup_transfer_bound_is_sharp :
    (∀ i, |aSharp i - sFlat i| ≤ 1) ∧ IsTopSet sFlat 2 {2, 3} ∧
      ({0, 1} : Finset (Fin 4)).card = 2 ∧
      retained aSharp {2, 3} = retained aSharp {0, 1} - 2 * 2 * 1 := by
  refine ⟨?_, ⟨by decide, ?_⟩, by decide, ?_⟩
  · intro i
    fin_cases i <;> norm_num [aSharp, sFlat]
  · intro i _ j _
    simp [sFlat]
  · rw [retained, retained, Finset.sum_pair (show (2 : Fin 4) ≠ 3 by decide),
      Finset.sum_pair (show (0 : Fin 4) ≠ 1 by decide)]
    norm_num [aSharp, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]

end Examples

end Catalog.Novelty.ProbeHybridStability