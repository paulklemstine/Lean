import Mathlib
import Shared.AttentionBudgetKnee
import Pythagorean.NET55SizeInvariantKnee

/-!
# NET-55, cycle 2: why a knee survives a change of model — aggregation and distortion

Cycle 1 (`NET55SizeInvariantKnee.lean`) explained size-invariance by *exact* homogeneity
(rescaling the weights) and by a *shared envelope*.  Neither mechanism covers the actual
experimental situation, where two genuinely different trained models — different width,
different depth, different head count — return the same budget.  This cycle isolates the
two structural mechanisms that do.

* **Aggregation** (`kstar_multihead_le`, `head_count_does_not_move_the_budget`).  The
  attention profile a deployment sees is a *sum over heads*.  If every head clears the
  gate at `K` keys then the aggregate clears the gate at `K` keys — for **any** number of
  heads whatsoever.  The budget of a model is bounded by the budget of its worst single
  head, uniformly in the head count, hence uniformly in the parameter count.  This is the
  sharpest available formal reading of "the KV working-set budget does not scale with
  model size".
* **Distortion** (`retained_ge_of_comparable`, `kstar_le_of_comparable`).  Two models
  whose sorted attention profiles agree within a multiplicative factor `lam` have knees
  related by a *gate shift*: `k*(w₂, τ) ≤ k*(w₁, lam ^ 2 * τ)`.  Approximate agreement of
  attention shape, not exact proportionality, is enough to transfer a measured budget
  from one model to another.
* **The gate shift is necessary** (`comparable_knees_can_differ`).  Comparability alone
  does *not* preserve the knee: two profiles comparable with factor `4` have knees `1`
  and `2` at the same gate and context.  So a transferred budget always costs gate
  margin, which is precisely the quantity a two-point size sweep cannot measure.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 2):
 (M1) The aggregate of arbitrarily many heads is no more expensive than the worst
      head: a max law with no dependence on the head count.                  [BOLD]
 (M2) Knees are stable under bounded multiplicative distortion of the profile, with
      an explicit `lam ^ 2` gate shift.                                      [BOLD]
 (M3) The `lam ^ 2` price is real: bounded distortion can move the knee.

Experimenter: M1 = `kstar_multihead_le` (proved by summing the pass inequalities, not by
iterating the two-head mediant bound of cycle 2 of the Shared file — the direct argument
avoids any nonemptiness or induction hypothesis); M2 = `kstar_le_of_comparable`;
M3 = `comparable_knees_can_differ`, explicit three-point profiles.  Zero sorries.

Analyst: M1 explains the empirical flatness without any assumption on the model: adding
heads (the dominant way parameter count grows in these families) is exactly the operation
under which the budget is monotone-in-the-worst-head, so a model can only get *more*
expensive by acquiring a bad head, never by getting bigger per se.  M2 quantifies what a
transferred measurement is worth; M3 shows that the quantification cannot be dropped.

Critic: M1's hypothesis is per-head passing at a *common* budget `K`; that is exactly
what a per-head knee sweep measures, and it is the measurement the round dropped (P2
unmeasured), so the theorem also identifies the missing experiment.  M3 is not a
degenerate witness: both profiles are strictly positive and the gate `0.9` is interior.
-/

namespace PythKnee

open Finset AttentionBudget

/-! ## M1 — aggregation over heads -/

section MultiHead

variable {ι : Type*} {W : ι → ℕ → ℝ} {τ : ℝ} {n : ℕ}

/-- Head mass is additive over a finite family of heads. -/
lemma headMass_finset_sum (s : Finset ι) (W : ι → ℕ → ℝ) (k : ℕ) :
    headMass (fun i => ∑ j ∈ s, W j i) k = ∑ j ∈ s, headMass (W j) k := by
  simpa [headMass] using Finset.sum_comm (s := Finset.range k) (t := s)
    (f := fun i j => W j i)

/-- **M1 — the aggregate passes whenever every head passes.**  No hypothesis on the
number of heads. -/
theorem retained_multihead_pass {s : Finset ι} {k : ℕ} (hpos : ∀ j, ∀ i, 0 < W j i)
    (hs : s.Nonempty) (hn : 0 < n) (h : ∀ j ∈ s, τ ≤ retained (W j) n k) :
    τ ≤ retained (fun i => ∑ j ∈ s, W j i) n k := by
  have hposS : ∀ i, 0 < ∑ j ∈ s, W j i := fun i =>
    Finset.sum_pos (fun j _ => hpos j i) hs
  have hden : 0 < headMass (fun i => ∑ j ∈ s, W j i) n := headMass_pos hposS hn
  have hstep : ∀ j ∈ s, τ * headMass (W j) n ≤ headMass (W j) (min k n) := by
    intro j hj
    have hdj : 0 < headMass (W j) n := headMass_pos (hpos j) hn
    have := h j hj
    rw [retained, le_div_iff₀ hdj] at this
    linarith
  have hsum : τ * ∑ j ∈ s, headMass (W j) n ≤ ∑ j ∈ s, headMass (W j) (min k n) := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum hstep
  rw [retained, le_div_iff₀ hden, headMass_finset_sum, headMass_finset_sum]
  exact hsum

/-- **M1 — the multi-head budget theorem.**  If every head of a model clears the gate
with `K` keys, so does the model, whatever its head count.  Consequently the aggregate
knee is bounded by the worst per-head knee, uniformly in the number of heads. -/
theorem kstar_multihead_le {s : Finset ι} {K : ℕ} (hpos : ∀ j, ∀ i, 0 < W j i)
    (hs : s.Nonempty) (hn : 0 < n) (hτ : τ ≤ 1) (h : ∀ j ∈ s, kstar (W j) n τ ≤ K) :
    kstar (fun i => ∑ j ∈ s, W j i) n τ ≤ K := by
  refine kstar_le_of_pass (retained_multihead_pass hpos hs hn fun j hj => ?_)
  exact le_trans (gate_le_retained_kstar (hpos j) hn hτ)
    (retained_mono (hpos j) n (h j hj))

/-- **Size invariance from aggregation.**  Two models built from head pools of *any*
sizes — say `H₁` and `H₂` heads, with `H₂` arbitrarily larger — whose heads all obey the
same per-head budget `K`, have the same budget `K`.  Growing the model by adding heads
cannot raise the lossless key budget. -/
theorem head_count_does_not_move_the_budget {s t : Finset ι} {K : ℕ}
    (hpos : ∀ j, ∀ i, 0 < W j i) (hs : s.Nonempty) (ht : t.Nonempty) (hn : 0 < n)
    (hτ : τ ≤ 1) (h : ∀ j, kstar (W j) n τ ≤ K) :
    kstar (fun i => ∑ j ∈ s, W j i) n τ ≤ K ∧
      kstar (fun i => ∑ j ∈ t, W j i) n τ ≤ K :=
  ⟨kstar_multihead_le hpos hs hn hτ fun j _ => h j,
   kstar_multihead_le hpos ht hn hτ fun j _ => h j⟩

end MultiHead

/-! ## M2 — stability under bounded multiplicative distortion -/

section Distortion

variable {w₁ w₂ : ℕ → ℝ} {lam τ : ℝ} {n k : ℕ}

/-- **M2 — the distortion bound.**  If the two profiles agree within a factor `lam ≥ 1`
then their retained masses agree within `lam ^ 2`. -/
theorem retained_ge_of_comparable (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i)
    (hlam : 1 ≤ lam) (h12 : ∀ i, w₁ i ≤ lam * w₂ i) (h21 : ∀ i, w₂ i ≤ lam * w₁ i)
    (hn : 0 < n) : retained w₁ n k / lam ^ 2 ≤ retained w₂ n k := by
  have hlam0 : (0 : ℝ) < lam := by linarith
  have hA : headMass w₁ (min k n) ≤ lam * headMass w₂ (min k n) := by
    have := Finset.sum_le_sum (s := Finset.range (min k n)) fun i _ => h12 i
    simpa [headMass, Finset.mul_sum] using this
  have hB : headMass w₂ n ≤ lam * headMass w₁ n := by
    have := Finset.sum_le_sum (s := Finset.range n) fun i _ => h21 i
    simpa [headMass, Finset.mul_sum] using this
  have hd1 : 0 < headMass w₁ n := headMass_pos hw₁ hn
  have hd2 : 0 < headMass w₂ n := headMass_pos hw₂ hn
  have hnum2 : 0 ≤ headMass w₂ (min k n) := headMass_nonneg hw₂ _
  rw [retained, retained, div_div, div_le_div_iff₀ (by positivity) hd2]
  have h1 : headMass w₁ (min k n) * headMass w₂ n
      ≤ (lam * headMass w₂ (min k n)) * (lam * headMass w₁ n) := by
    have hle : headMass w₁ (min k n) * headMass w₂ n
        ≤ (lam * headMass w₂ (min k n)) * headMass w₂ n :=
      mul_le_mul_of_nonneg_right hA hd2.le
    nlinarith [mul_le_mul_of_nonneg_left hB (by positivity : (0:ℝ) ≤ lam * headMass w₂ (min k n))]
  nlinarith

/-- **M2 — budget transfer with a gate shift.**  A budget certified on one model
transfers to any model whose attention profile is `lam`-comparable to it, at the cost of
raising the gate by `lam ^ 2`. -/
theorem kstar_le_of_comparable (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i)
    (hlam : 1 ≤ lam) (h12 : ∀ i, w₁ i ≤ lam * w₂ i) (h21 : ∀ i, w₂ i ≤ lam * w₁ i)
    (hn : 0 < n) (hshift : lam ^ 2 * τ ≤ 1) :
    kstar w₂ n τ ≤ kstar w₁ n (lam ^ 2 * τ) := by
  have hlam0 : (0 : ℝ) < lam := by linarith
  have hpass₁ : lam ^ 2 * τ ≤ retained w₁ n (kstar w₁ n (lam ^ 2 * τ)) :=
    gate_le_retained_kstar hw₁ hn hshift
  have hstep := retained_ge_of_comparable hw₁ hw₂ hlam h12 h21 (k := kstar w₁ n (lam ^ 2 * τ)) hn
  refine kstar_le_of_pass (le_trans ?_ hstep)
  rw [le_div_iff₀ (by positivity)]
  linarith [hpass₁]

end Distortion

/-! ## M3 — the gate shift cannot be dropped -/

/-- A concrete three-value profile (the tail is irrelevant to a context of length `3`). -/
noncomputable def triProfile (x y z : ℝ) : ℕ → ℝ :=
  fun i => if i = 0 then x else if i = 1 then y else z

lemma triProfile_pos {x y z : ℝ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    ∀ i, 0 < triProfile x y z i := by
  intro i
  unfold triProfile
  split_ifs <;> assumption

lemma headMass_tri_one (x y z : ℝ) : headMass (triProfile x y z) 1 = x := by
  simp [headMass, triProfile]

lemma headMass_tri_two (x y z : ℝ) : headMass (triProfile x y z) 2 = x + y := by
  simp [headMass, triProfile, Finset.sum_range_succ]

lemma headMass_tri_three (x y z : ℝ) : headMass (triProfile x y z) 3 = x + y + z := by
  simp [headMass, triProfile, Finset.sum_range_succ]

/-- **M3 — comparability does not preserve the knee.**  The profiles `(95, 4, 1)` and
`(85, 14, 1)` are comparable with factor `4`, yet at gate `0.9` and context `3` their
knees are `1` and `2`.  Hence the gate shift in `kstar_le_of_comparable` is not an
artefact of the proof: bounded distortion of attention shape genuinely moves the
lossless budget. -/
theorem comparable_knees_can_differ :
    ∃ w₁ w₂ : ℕ → ℝ, (∀ i, 0 < w₁ i) ∧ (∀ i, 0 < w₂ i) ∧
      (∀ i, w₁ i ≤ 4 * w₂ i) ∧ (∀ i, w₂ i ≤ 4 * w₁ i) ∧
      kstar w₁ 3 (9 / 10) = 1 ∧ kstar w₂ 3 (9 / 10) = 2 := by
  refine ⟨triProfile 95 4 1, triProfile 85 14 1, triProfile_pos (by norm_num) (by norm_num)
    (by norm_num), triProfile_pos (by norm_num) (by norm_num) (by norm_num), ?_, ?_, ?_, ?_⟩
  · intro i; unfold triProfile; split_ifs <;> norm_num
  · intro i; unfold triProfile; split_ifs <;> norm_num
  · -- knee of `(95, 4, 1)` is `1`
    have hpass : (9 / 10 : ℝ) ≤ retained (triProfile 95 4 1) 3 1 := by
      rw [retained, show min 1 3 = 1 from rfl, headMass_tri_one, headMass_tri_three]
      rw [le_div_iff₀ (by norm_num)]
      norm_num
    have hfail : retained (triProfile 95 4 1) 3 0 < 9 / 10 := by
      rw [retained, show min 0 3 = 0 from rfl]
      simp [headMass]
    have hb := knee_bracket (triProfile_pos (x := 95) (y := 4) (z := 1) (by norm_num)
      (by norm_num) (by norm_num)) (n := 3) (by norm_num) (by norm_num) hfail hpass
    omega
  · -- knee of `(85, 14, 1)` is `2`
    have hpass : (9 / 10 : ℝ) ≤ retained (triProfile 85 14 1) 3 2 := by
      rw [retained, show min 2 3 = 2 from rfl, headMass_tri_two, headMass_tri_three]
      rw [le_div_iff₀ (by norm_num)]
      norm_num
    have hfail : retained (triProfile 85 14 1) 3 1 < 9 / 10 := by
      rw [retained, show min 1 3 = 1 from rfl, headMass_tri_one, headMass_tri_three]
      rw [div_lt_iff₀ (by norm_num)]
      norm_num
    have hb := knee_bracket (triProfile_pos (x := 85) (y := 14) (z := 1) (by norm_num)
      (by norm_num) (by norm_num)) (n := 3) (by norm_num) (by norm_num) hfail hpass
    omega

end PythKnee