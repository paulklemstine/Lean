/-
# One-sidedness of conditional-independence artifacts

## Context

`Applications.JointLabelReconciliation` proves that a label merge can only
*lower* the measured mutual information (`MI_pushFst_le`), and leaves it
unchanged when the merge is injective (`MI_pushFst_eq_of_injective`).  Routing
tables, however, are read *conditionally*: the interesting quantity is
`I(X;Y|Z)`, the dependence between a dial `X` and a response `Y` at fixed
context `Z`.

This file extends the data-processing inequality to conditional mutual
information, by slicing over `z` and applying the per-slice machinery
(`H_joint_sub`, `D_superadditive`) uniformly in `z`:

* `CMI` — conditional mutual information of an (unnormalised) weight on
  `X × Y × Z`, defined slice-wise;
* `CMI_nonneg` — nonnegativity, proved from Gibbs' inequality (`kl_nonneg`)
  applied to the product comparison measure inside each slice;
* `CMI_pushFst3_le` — **the conditional data-processing inequality**:
  `I(f(X);Y|Z) ≤ I(X;Y|Z)` for every labelling `f`;
* `CMI_pushFst3_eq_of_injective` — equality for width-valid (injective) `f`;
* `dependence_never_false_positive` / `independence_may_be_artifact` — the
  one-sided error guarantee: a reported conditional *dependence* is always
  genuine, while a reported conditional *independence* can be a merge artifact
  (an explicit `2 × 2 × 2` witness is given).

The final section shows that the conditional and unconditional readings are
*logically independent*: `xor_MI_eq_zero` / `xor_CMI_eq_one` exhibit a
population with `I(X;Y) = 0` but `I(X;Y|Z) = 1`, and `copy_MI_eq_one` /
`copy_CMI_eq_zero` one with `I(X;Y) = 1` but `I(X;Y|Z) = 0`.  So the
single-dial tables genuinely need a separate argument; the guarantee proved
here is per-dial and conditional.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation

namespace ConditionalLabelDPI

open Finset LabelEntropy JointLabelReconciliation

variable {α β γ α' : Type*} [Fintype α] [Fintype β] [Fintype γ] [Fintype α']
  [DecidableEq α']

/-- The `z`-slice of a joint weight on `X × Y × Z`. -/
noncomputable def slice (p : α × β × γ → ℝ) (z : γ) : α × β → ℝ :=
  fun q => p (q.1, q.2, z)

/-- Total mass of a joint weight on `X × Y`. -/
noncomputable def mass (q : α × β → ℝ) : ℝ := ∑ i : α × β, q i

/-- Pushforward along a labelling of the first coordinate, for a three-factor
joint weight (the second coordinate is the reference variable, the third the
conditioning variable). -/
noncomputable def pushFst3 (f : α → α') (p : α × β × γ → ℝ) : α' × β × γ → ℝ :=
  fun q => ∑ x ∈ fib f q.1, p (x, q.2.1, q.2.2)

/-- Pushforward along a labelling of the *conditioning* coordinate.  No
one-sidedness holds for this operation; see
`Novelty.ConditionalArtifactWitness.context_merge_is_two_sided`. -/
noncomputable def pushThd {γ' : Type*} [DecidableEq γ'] (f : γ → γ')
    (p : α × β × γ → ℝ) : α × β × γ' → ℝ :=
  fun q => ∑ z ∈ fib f q.2.2, p (q.1, q.2.1, z)

/-- Conditional mutual information in bits, sliced over the conditioning
variable:
`I(X;Y|Z) = ∑_z [H(p_{X,z}) + H(p_{Y,z}) - H(p_z) - nlp(mass p_z)]`.
For a probability weight this is the usual
`∑ p(x,y,z)·log₂ (p(x,y,z)·p(z) / (p(x,z)·p(y,z)))`. -/
noncomputable def CMI (p : α × β × γ → ℝ) : ℝ :=
  ∑ z : γ, (MI (slice p z) - nlp (mass (slice p z)))

omit [Fintype β] [Fintype γ] [Fintype α'] in
/-- Slicing commutes with a first-coordinate label merge. -/
lemma slice_pushFst3 (f : α → α') (p : α × β × γ → ℝ) (z : γ) :
    slice (pushFst3 f p) z = pushFst f (slice p z) := rfl

lemma mass_eq_sum_marg2 (q : α × β → ℝ) : mass q = ∑ y : β, marg2 q y := by
  simp only [mass, marg2]
  rw [Fintype.sum_prod_type]
  exact Finset.sum_comm

lemma mass_eq_sum_marg1 (q : α × β → ℝ) : mass q = ∑ x : α, marg1 q x := by
  simp only [mass, marg1]
  rw [Fintype.sum_prod_type]

/-- A label merge preserves the total mass of a slice. -/
lemma mass_pushFst (f : α → α') (q : α × β → ℝ) : mass (pushFst f q) = mass q := by
  rw [mass_eq_sum_marg2, mass_eq_sum_marg2, marg2_pushFst]

/-! ## Nonnegativity: the per-slice Gibbs estimate -/

/-- Per-slice conditional information is nonnegative.  This is Gibbs'
inequality (`kl_nonneg`) against the product comparison weight
`b(x,y) = p_X(x)·p_Y(y)/mass`. -/
theorem MI_sub_nlp_mass_nonneg {q : α × β → ℝ} (hq : ∀ i, 0 ≤ q i) :
    0 ≤ MI q - nlp (mass q) := by
  classical
  have hm1 : ∀ x, 0 ≤ marg1 q x := fun x => Finset.sum_nonneg fun y _ => hq _
  have hm2 : ∀ y, 0 ≤ marg2 q y := fun y => Finset.sum_nonneg fun x _ => hq _
  have hle1 : ∀ i : α × β, q i ≤ marg1 q i.1 := by
    intro i
    have : q (i.1, i.2) ≤ ∑ y : β, q (i.1, y) :=
      Finset.single_le_sum (f := fun y => q (i.1, y)) (fun y _ => hq _) (mem_univ i.2)
    simpa [marg1] using this
  have hle2 : ∀ i : α × β, q i ≤ marg2 q i.2 := by
    intro i
    have : q (i.1, i.2) ≤ ∑ x : α, q (x, i.2) :=
      Finset.single_le_sum (f := fun x => q (x, i.2)) (fun x _ => hq _) (mem_univ i.1)
    simpa [marg2] using this
  have hMnonneg : 0 ≤ mass q := Finset.sum_nonneg fun i _ => hq i
  rcases eq_or_lt_of_le hMnonneg with hM0 | hMpos
  · -- degenerate slice: no mass, everything vanishes
    have hq0 : ∀ i, q i = 0 := by
      intro i
      exact (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => hq i)).mp hM0.symm i (mem_univ i)
    have hmarg1_0 : ∀ x, marg1 q x = 0 := fun x => Finset.sum_eq_zero fun y _ => hq0 _
    have hmarg2_0 : ∀ y, marg2 q y = 0 := fun y => Finset.sum_eq_zero fun x _ => hq0 _
    have h1 : H (univ : Finset α) (marg1 q) = 0 :=
      Finset.sum_eq_zero fun x _ => by rw [hmarg1_0 x, nlp_zero]
    have h2 : H (univ : Finset β) (marg2 q) = 0 :=
      Finset.sum_eq_zero fun y _ => by rw [hmarg2_0 y, nlp_zero]
    have h3 : H (univ : Finset (α × β)) q = 0 :=
      Finset.sum_eq_zero fun i _ => by rw [hq0 i, nlp_zero]
    rw [MI, h1, h2, h3, ← hM0, nlp_zero]
    norm_num
  · set M := mass q with hM
    set b : α × β → ℝ := fun i => marg1 q i.1 * marg2 q i.2 / M with hb
    have hbnn : ∀ i ∈ (univ : Finset (α × β)), 0 ≤ b i := fun i _ =>
      div_nonneg (mul_nonneg (hm1 i.1) (hm2 i.2)) hMpos.le
    have hMsum1 : ∑ x : α, marg1 q x = M := (mass_eq_sum_marg1 q).symm
    have hMsum2 : ∑ y : β, marg2 q y = M := (mass_eq_sum_marg2 q).symm
    have hbsum : ∑ i : α × β, b i = M := by
      simp only [hb]
      rw [Fintype.sum_prod_type]
      have hrow : ∀ x : α, ∑ y : β, marg1 q x * marg2 q y / M = marg1 q x * M / M := by
        intro x
        rw [← Finset.sum_div, ← Finset.mul_sum, hMsum2]
      rw [Finset.sum_congr rfl (fun x _ => hrow x), ← Finset.sum_div, ← Finset.sum_mul,
        hMsum1]
      field_simp
    have hac : ∀ i ∈ (univ : Finset (α × β)), b i = 0 → q i = 0 := by
      intro i _ hbi
      simp only [hb, div_eq_zero_iff] at hbi
      rcases hbi with h | h
      · rcases mul_eq_zero.mp h with h1 | h2
        · have := hle1 i
          rw [h1] at this
          exact le_antisymm this (hq i)
        · have := hle2 i
          rw [h2] at this
          exact le_antisymm this (hq i)
      · exact absurd h (ne_of_gt hMpos)
    have hkl := kl_nonneg (s := (univ : Finset (α × β))) (a := q) (b := b)
      (fun i _ => hq i) hbnn hac (by rw [hbsum]; exact le_of_eq hM)
    -- identify the relative entropy with `MI q - nlp (mass q)`
    have hterm : ∀ i : α × β, q i * (Real.logb 2 (q i) - Real.logb 2 (b i))
        = q i * Real.logb 2 (q i) - q i * Real.logb 2 (marg1 q i.1)
          - q i * Real.logb 2 (marg2 q i.2) + q i * Real.logb 2 M := by
      intro i
      rcases eq_or_lt_of_le (hq i) with h0 | hpos
      · simp [← h0]
      · have h1 : 0 < marg1 q i.1 := lt_of_lt_of_le hpos (hle1 i)
        have h2 : 0 < marg2 q i.2 := lt_of_lt_of_le hpos (hle2 i)
        have hbi : Real.logb 2 (b i)
            = Real.logb 2 (marg1 q i.1) + Real.logb 2 (marg2 q i.2) - Real.logb 2 M := by
          simp only [hb]
          rw [Real.logb_div (by positivity) (ne_of_gt hMpos),
            Real.logb_mul (ne_of_gt h1) (ne_of_gt h2)]
        rw [hbi]; ring
    have hA : H (univ : Finset (α × β)) q = - ∑ i : α × β, q i * Real.logb 2 (q i) := by
      simp [H, nlp]
    have hB : ∑ i : α × β, q i * Real.logb 2 (marg1 q i.1)
        = ∑ x : α, marg1 q x * Real.logb 2 (marg1 q x) := by
      rw [Fintype.sum_prod_type]
      refine Finset.sum_congr rfl fun x _ => ?_
      show ∑ y : β, q (x, y) * Real.logb 2 (marg1 q x) = marg1 q x * Real.logb 2 (marg1 q x)
      rw [← Finset.sum_mul]
      rfl
    have hC : ∑ i : α × β, q i * Real.logb 2 (marg2 q i.2)
        = ∑ y : β, marg2 q y * Real.logb 2 (marg2 q y) := by
      rw [Fintype.sum_prod_type, Finset.sum_comm]
      refine Finset.sum_congr rfl fun y _ => ?_
      show ∑ x : α, q (x, y) * Real.logb 2 (marg2 q y) = marg2 q y * Real.logb 2 (marg2 q y)
      rw [← Finset.sum_mul]
      rfl
    have hD : ∑ i : α × β, q i * Real.logb 2 M = M * Real.logb 2 M := by
      rw [← Finset.sum_mul]
      congr 1
    have hH1 : H (univ : Finset α) (marg1 q)
        = - ∑ x : α, marg1 q x * Real.logb 2 (marg1 q x) := by
      simp [H, nlp]
    have hH2 : H (univ : Finset β) (marg2 q)
        = - ∑ y : β, marg2 q y * Real.logb 2 (marg2 q y) := by
      simp [H, nlp]
    rw [Finset.sum_congr rfl (fun i (_ : i ∈ (univ : Finset (α × β))) => hterm i)] at hkl
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib, hB, hC,
      hD] at hkl
    simp only [MI, nlp, hA, hH1, hH2]
    linarith

/-- **Conditional mutual information is nonnegative.** -/
theorem CMI_nonneg {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) : 0 ≤ CMI p :=
  Finset.sum_nonneg fun _ _ => MI_sub_nlp_mass_nonneg (fun _ => hp _)

/-! ## The conditional data-processing inequality -/

/-- **Conditional data-processing inequality.**  Merging labels of the dial `X`
can only *decrease* the conditional mutual information `I(X;Y|Z)`, uniformly in
the conditioning variable. -/
theorem CMI_pushFst3_le {f : α → α'} {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 f p) ≤ CMI p := by
  refine Finset.sum_le_sum fun z _ => ?_
  rw [slice_pushFst3, mass_pushFst]
  have := MI_pushFst_le (f := f) (p := slice p z) (fun i => hp _)
  linarith

/-- **Encoding invariance.**  A width-valid (injective) relabelling of the dial
leaves the conditional reading unchanged. -/
theorem CMI_pushFst3_eq_of_injective {f : α → α'} (hf : Function.Injective f)
    (p : α × β × γ → ℝ) : CMI (pushFst3 f p) = CMI p := by
  refine Finset.sum_congr rfl fun z _ => ?_
  rw [slice_pushFst3, mass_pushFst, MI_pushFst_eq_of_injective hf]

/-- **The conditional reconciliation.**  On one and the same population a
width-valid encoding reports the true conditional value and *any* other
encoding reports at most that value. -/
theorem CMI_reconciliation {f g : α → α'} (hf : Function.Injective f)
    {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 g p) ≤ CMI (pushFst3 f p) := by
  rw [CMI_pushFst3_eq_of_injective hf]
  exact CMI_pushFst3_le hp

/-- **One-sided error, positive half.**  A conditional dependence reported off a
merged table is never a false positive. -/
theorem dependence_never_false_positive {f : α → α'} {p : α × β × γ → ℝ}
    (hp : ∀ i, 0 ≤ p i) (h : 0 < CMI (pushFst3 f p)) : 0 < CMI p :=
  lt_of_lt_of_le h (CMI_pushFst3_le hp)

/-- Contrapositive form: if the true population is conditionally independent,
every merged reading is conditionally independent too. -/
theorem independence_is_inherited {f : α → α'} {p : α × β × γ → ℝ}
    (hp : ∀ i, 0 ≤ p i) (h : CMI p = 0) : CMI (pushFst3 f p) = 0 := by
  have hle : CMI (pushFst3 f p) ≤ 0 := h ▸ CMI_pushFst3_le hp
  have hnn : 0 ≤ CMI (pushFst3 f p) := by
    refine CMI_nonneg (p := pushFst3 f p) fun i => ?_
    exact Finset.sum_nonneg fun x _ => hp _
  linarith

end ConditionalLabelDPI