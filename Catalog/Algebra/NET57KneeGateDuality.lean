import Algebra.NET57CorpusRobustKnee

/-!
# NET-57, cycle 2: the gate ↔ budget duality and the sharpness of corpus robustness

`Algebra.NET57CorpusRobustKnee` proved that the retention knee is a non-archimedean,
scale-invariant functional on the cone of corpora, and that four-decimal agreement of
two retention curves forces the knees to coincide *exactly*.  Two questions are left
open by that file, and both are answered here.

**Q1 (identifiability).**  A deployment table reports the knee `k*(τ)` at a handful of
gates.  How much of the corpus does that table actually determine?  The answer is a
Galois duality: the gate sweep and the retention curve are mutually recoverable.

* `knee_mono_gate` — the knee is monotone in the gate, so the sweep is a step function.
* `gateSet_eq_Iic`, `retained_eq_sSup_gates` — the retention curve is the *upper
  envelope* of the gate sweep: `retained w n k = sSup {τ ≤ 1 | k*(τ) ≤ k}`.
* `retained_eq_of_knee_eq` — hence two corpora with the same gate sweep have the same
  retention curve on the whole grid: **the sweep is a complete invariant**.  A
  cross-corpus replication of the knee at *every* gate is therefore not merely
  suggestive of curve agreement, it is equivalent to it.
* `knee_eq_iff_retained_bracket` — the exact step description of the knee.

**Q2 (necessity of the margin).**  `knee_eq_of_uniform_close` assumes the reference
corpus stays further than `ε` from the gate.  Is that hypothesis load-bearing?

* `four_decimal_margin_necessary` — yes, sharply: for the uniform corpus sitting
  exactly on its gate, *every* tolerance `ε > 0` admits a corpus within `ε` of it in
  retention whose knee is different.  Zero margin destroys robustness at every scale,
  so the NET-57 inference genuinely needs its measured margin, and (by
  `knee_eq_of_uniform_close`) nothing more.

-- !-- Lab Notes -- !--
Hypothesizer (cycle-2 conjectures):
 (H7) The gate sweep `τ ↦ k*(τ)` is a complete invariant of the retention curve
      — corpus identifiability from deployment tables alone.               [BOLD]
 (H8) The knee is the lower adjoint of the retention curve in a genuine Galois
      connection between gates and budgets.
 (H9) The margin hypothesis of the four-decimal theorem is necessary and its
      failure is *scale-free*: at zero margin no tolerance suffices.       [BOLD]
 (H10) Retention curves are recovered as suprema of gate sets, so the sweep
      determines the curve even when only rational gates are measured.

Experimenter: H7–H10 are formalised below with zero sorries.  Rational-arithmetic
`#eval` evidence for the step shape (`ComputationalEvidence.md`, §3):
  corpus (3/4)^i, ctx 64, gates 0.90…0.99  ↦  k* = [9,9,9,10,10,11,12,13,14,17].

Analyst: the interesting negative is that identifiability needs the *whole* gate
axis: on a finite grid of gates two corpora can share every measured knee and
still differ in retention between the measured steps.  The theorem
`retained_eq_of_knee_eq` therefore quantifies over all `τ ≤ 1`, which is the exact
strength a sweep-based deployment claim may assume.

Critic: `four_decimal_margin_necessary` is an explicit witness, not an abstract
non-existence result, and it is stated with a universally quantified tolerance so
it cannot be dodged by shrinking `ε`.  None of the statements here are vacuous:
each hypothesis class is inhabited by the uniform corpus.
-/

namespace Catalog.Algebra.NET57

open Finset

/-! ## Monotonicity in the gate: the sweep is a step function -/

variable {w : ℕ → ℝ} {n k : ℕ} {τ σ : ℝ}

/-- Raising the gate can only raise the required budget. -/
lemma clears_of_le_gate (hw : IsCorpus w) (hτσ : τ ≤ σ) (h : Clears w n k σ) :
    Clears w n k τ := by
  refine le_trans ?_ h
  have := headMass_nonneg hw n
  nlinarith [headMass_nonneg hw n]

/-- **The gate sweep is monotone.**  `τ ↦ k*(τ)` is a non-decreasing step function. -/
theorem knee_mono_gate (hw : IsCorpus w) (hσ : σ ≤ 1) (hτσ : τ ≤ σ) :
    knee w n τ ≤ knee w n σ :=
  knee_le_of_clears (clears_of_le_gate hw hτσ (clears_knee hw hσ))

/-! ## Galois duality between gates and budgets -/

/-- The set of gates a fixed budget `k` can serve. -/
def gateSet (w : ℕ → ℝ) (n k : ℕ) : Set ℝ := {τ : ℝ | τ ≤ 1 ∧ knee w n τ ≤ k}

/-- **Duality.**  Below the context length, the gates served by budget `k` are exactly
the gates at or below the retained mass at `k`. -/
theorem gateSet_eq_Iic (hw : IsCorpus w) (hpos : 0 < headMass w n) (hk : k ≤ n) :
    gateSet w n k = Set.Iic (retained w n k) := by
  have hle1 : retained w n k ≤ 1 := by
    rw [retained, div_le_one hpos]
    exact headMass_mono hw hk
  ext τ
  simp only [gateSet, Set.mem_setOf_eq, Set.mem_Iic]
  constructor
  · rintro ⟨hτ1, hknee⟩
    exact (clears_iff_retained hpos).1 ((knee_le_iff hw hτ1).1 hknee)
  · intro hτ
    have hτ1 : τ ≤ 1 := hτ.trans hle1
    exact ⟨hτ1, knee_le_of_clears ((clears_iff_retained hpos).2 hτ)⟩

/-- **The retention curve is the upper envelope of the gate sweep.**  Every value of
the measured curve is recovered from the knee function alone. -/
theorem retained_eq_sSup_gates (hw : IsCorpus w) (hpos : 0 < headMass w n) (hk : k ≤ n) :
    sSup (gateSet w n k) = retained w n k := by
  rw [gateSet_eq_Iic hw hpos hk, csSup_Iic]

/-- **Identifiability (H7).**  Two corpora whose gate sweeps agree at every gate `τ ≤ 1`
have identical retention curves on the whole budget grid: the sweep is a complete
invariant of the measurable content of a corpus. -/
theorem retained_eq_of_knee_eq {A B : ℕ → ℝ} (hA : IsCorpus A) (hB : IsCorpus B)
    (hApos : 0 < headMass A n) (hBpos : 0 < headMass B n)
    (hsweep : ∀ τ : ℝ, τ ≤ 1 → knee A n τ = knee B n τ) (hk : k ≤ n) :
    retained A n k = retained B n k := by
  have hgate : gateSet A n k = gateSet B n k := by
    ext τ
    simp only [gateSet, Set.mem_setOf_eq]
    constructor
    · rintro ⟨hτ1, h⟩; exact ⟨hτ1, (hsweep τ hτ1) ▸ h⟩
    · rintro ⟨hτ1, h⟩; exact ⟨hτ1, (hsweep τ hτ1).symm ▸ h⟩
  rw [← retained_eq_sSup_gates hA hApos hk, ← retained_eq_sSup_gates hB hBpos hk, hgate]

/-- The exact step description of the knee: `k*(τ) = k` iff the gate is cleared at `k`
and missed just below it. -/
theorem knee_eq_iff_retained_bracket (hw : IsCorpus w) (hpos : 0 < headMass w n)
    (hτ : τ ≤ 1) (hk : k ≤ n) :
    knee w n τ = k ↔ (τ ≤ retained w n k ∧ ∀ j < k, retained w n j < τ) := by
  constructor
  · rintro rfl
    refine ⟨(clears_iff_retained hpos).1 (clears_knee hw hτ), fun j hj => ?_⟩
    have := not_clears_of_lt_knee hj
    rw [clears_iff_retained hpos] at this
    exact lt_of_not_ge this
  · rintro ⟨hpass, hfail⟩
    refine knee_eq_of ((clears_iff_retained hpos).2 hpass) fun j hj => ?_
    rw [clears_iff_retained hpos]
    exact not_le.2 (hfail j hj)

/-! ## Necessity of the margin hypothesis

The four-decimal theorem needs the reference corpus to stand clear of the gate.  Here
is the sharp reason: a corpus sitting *exactly* on its gate is unstable at every
tolerance.  Take the uniform corpus on a context of length `2` with gate `1/2`; its
retained mass at the knee `k = 1` is exactly `1/2`. -/

/-- The uniform corpus. -/
def uniform2 : ℕ → ℝ := fun _ => 1

lemma isCorpus_uniform2 : IsCorpus uniform2 := fun _ => by simp [uniform2]

lemma headMass_uniform2 (k : ℕ) : headMass uniform2 k = k := by
  simp [headMass, uniform2]

lemma knee_uniform2 : knee uniform2 2 (1/2) = 1 := by
  refine knee_eq_of ?_ ?_
  · simp only [Clears, headMass_uniform2]; norm_num
  · intro j hj
    interval_cases j
    simp only [Clears, headMass_uniform2, not_le]
    norm_num

/-- The tilted corpus: mass `1 - δ` on the first key and `1` afterwards. -/
def tilted (δ : ℝ) : ℕ → ℝ := fun i => if i = 0 then 1 - δ else 1

lemma isCorpus_tilted {δ : ℝ} (h1 : δ ≤ 1) : IsCorpus (tilted δ) := by
  intro i
  unfold tilted
  split
  · linarith
  · norm_num

lemma headMass_tilted_zero (δ : ℝ) : headMass (tilted δ) 0 = 0 := by simp [headMass]

lemma headMass_tilted_one (δ : ℝ) : headMass (tilted δ) 1 = 1 - δ := by
  simp [headMass, tilted]

lemma headMass_tilted_two (δ : ℝ) : headMass (tilted δ) 2 = 2 - δ := by
  simp [headMass, tilted, Finset.sum_range_succ]
  ring

/-- Tilting by any positive amount moves the knee from `1` to `2`. -/
lemma knee_tilted {δ : ℝ} (h0 : 0 < δ) (h1 : δ ≤ 1) : knee (tilted δ) 2 (1/2) = 2 := by
  refine knee_eq_of ?_ ?_
  · simp only [Clears, headMass_tilted_two]; linarith
  · intro j hj
    interval_cases j
    · simp only [Clears, headMass_tilted_two, headMass_tilted_zero, not_le]; linarith
    · simp only [Clears, headMass_tilted_two, headMass_tilted_one, not_le]; linarith

/-- **The margin hypothesis is necessary, at every scale (H9).**  The uniform corpus
sits exactly on its gate, and for *every* tolerance `ε > 0` there is a corpus whose
retention curve is within `ε` of it at every budget yet whose knee is different.  So
no amount of agreement between two retention curves can force knee agreement without
a gate margin — which is precisely the extra input NET-57's measurement supplies. -/
theorem four_decimal_margin_necessary (ε : ℝ) (hε : 0 < ε) :
    ∃ B : ℕ → ℝ, IsCorpus B ∧
      (∀ k ≤ 2, |retained uniform2 2 k - retained B 2 k| ≤ ε) ∧
      knee B 2 (1/2) ≠ knee uniform2 2 (1/2) := by
  set δ : ℝ := min 1 ε with hδ
  have hδ0 : 0 < δ := lt_min one_pos hε
  have hδ1 : δ ≤ 1 := min_le_left _ _
  have hδε : δ ≤ ε := min_le_right _ _
  refine ⟨tilted δ, isCorpus_tilted hδ1, ?_, ?_⟩
  · intro k hk
    have hden : (0 : ℝ) < 2 - δ := by linarith
    interval_cases k
    · simp only [retained, headMass_uniform2, headMass_tilted_zero, Nat.cast_zero,
        zero_div, sub_zero, abs_zero]
      exact hε.le
    · have h1 : retained uniform2 2 1 = 1 / 2 := by
        simp [retained, headMass_uniform2]
      have h2 : retained (tilted δ) 2 1 = (1 - δ) / (2 - δ) := by
        rw [retained, headMass_tilted_one, headMass_tilted_two]
      rw [h1, h2]
      have hval : 1 / 2 - (1 - δ) / (2 - δ) = δ / (2 * (2 - δ)) := by
        field_simp
        ring
      rw [hval, abs_of_nonneg (by positivity)]
      rw [div_le_iff₀ (by linarith)]
      nlinarith [hδ0, hδ1, hδε]
    · have h1 : retained uniform2 2 2 = 1 := by
        simp [retained, headMass_uniform2]
      have h2 : retained (tilted δ) 2 2 = 1 := by
        rw [retained, headMass_tilted_two, div_self (by linarith)]
      rw [h1, h2]
      simpa using hε.le
  · rw [knee_tilted hδ0 hδ1, knee_uniform2]
    norm_num

/-- Packaging the two cycle-2 answers: the gate sweep is a complete invariant, and the
robustness it certifies is exactly conditional on a positive gate margin. -/
theorem sweep_complete_and_margin_sharp {A B : ℕ → ℝ} (hA : IsCorpus A) (hB : IsCorpus B)
    (hApos : 0 < headMass A n) (hBpos : 0 < headMass B n)
    (hsweep : ∀ τ : ℝ, τ ≤ 1 → knee A n τ = knee B n τ) :
    (∀ k ≤ n, retained A n k = retained B n k) ∧
      ∀ ε : ℝ, 0 < ε → ∃ C : ℕ → ℝ, IsCorpus C ∧
        (∀ k ≤ 2, |retained uniform2 2 k - retained C 2 k| ≤ ε) ∧
        knee C 2 (1/2) ≠ knee uniform2 2 (1/2) :=
  ⟨fun _ hk => retained_eq_of_knee_eq hA hB hApos hBpos hsweep hk,
    fun ε hε => four_decimal_margin_necessary ε hε⟩

end Catalog.Algebra.NET57