/-
# Exact accounting for conditional label artifacts, and how they chain

Second cycle on `Novelty.ConditionalLabelDPI`.  The inequality
`I(f(X);Y|Z) ≤ I(X;Y|Z)` is upgraded to an *identity* for the loss, and the
loss is shown to behave correctly under composition of label merges (chaining)
and under adding dials.

Main results:

* `MI_loss_eq` / `CMI_loss_eq` — the artifact is exactly the difference between
  the marginal fiber deficits and the sliced fiber deficits, summed over the
  conditioning variable.  The data-processing inequality is the statement that
  this difference is nonnegative, so the identity *localises* every reported
  discrepancy to a fiber and a slice.
* `pushFst3_comp` — merges compose: chaining two encodings is the same as
  applying the composite encoding.
* `CMI_chain_monotone` — consequently a chained bug can only *lower* the
  reading further; errors accumulate with a fixed sign.
* `CMI_proj_le` — a *sub-dial* reading never exceeds the full-dial reading:
  splitting one dial into two coordinates and reporting only the first can only
  lose conditional dependence.
* `CMI_le_condH` — the reading is capped by the conditional entropy of the dial,
  `I(X;Y|Z) ≤ H(X|Z)`; in particular a merged table can never report more than
  the entropy that survives the merge.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation
import Novelty.ConditionalLabelDPI

namespace ConditionalArtifactAccounting

open Finset LabelEntropy JointLabelReconciliation ConditionalLabelDPI

variable {α β γ α' α'' : Type*} [Fintype α] [Fintype β] [Fintype γ] [Fintype α']
  [Fintype α''] [DecidableEq α'] [DecidableEq α'']

/-! ## Exact loss accounting -/

/-- **Exact artifact size, unconditional version.**  The mutual information
destroyed by a label merge is the marginal fiber deficit minus the sliced
fiber deficits. -/
theorem MI_loss_eq (f : α → α') (p : α × β → ℝ) :
    MI p - MI (pushFst f p)
      = (∑ u : α', D (fib f u) (marg1 p))
        - ∑ u : α', ∑ y : β, D (fib f u) (fun x => p (x, y)) := by
  have h1 := H_sub_H_push f (marg1 p)
  have h2 := H_joint_sub f p
  have h3 : H univ (marg1 (pushFst f p)) = H univ (push f (marg1 p)) := by
    rw [marg1_pushFst]
  have h4 : H univ (marg2 (pushFst f p)) = H univ (marg2 p) := by
    rw [marg2_pushFst]
  simp only [MI, h3, h4]
  linarith

/-- **Exact artifact size, conditional version.**  Every discrepancy between a
merged conditional reading and the true one is localised to a conditioning
slice and a fiber of the merge. -/
theorem CMI_loss_eq (f : α → α') (p : α × β × γ → ℝ) :
    CMI p - CMI (pushFst3 f p)
      = ∑ z : γ, ((∑ u : α', D (fib f u) (marg1 (slice p z)))
          - ∑ u : α', ∑ y : β, D (fib f u) (fun x => slice p z (x, y))) := by
  rw [CMI, CMI, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun z _ => ?_
  rw [slice_pushFst3, mass_pushFst]
  have := MI_loss_eq f (slice p z)
  linarith

/-- The conditional data-processing inequality, re-derived from the exact
accounting: the total localised loss is nonnegative. -/
theorem CMI_loss_nonneg {f : α → α'} {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    0 ≤ ∑ z : γ, ((∑ u : α', D (fib f u) (marg1 (slice p z)))
        - ∑ u : α', ∑ y : β, D (fib f u) (fun x => slice p z (x, y))) := by
  rw [← CMI_loss_eq f p]
  have := CMI_pushFst3_le (f := f) hp
  linarith

/-! ## When is a merged reading exact? -/

omit [Fintype γ] [Fintype α'] [Fintype α''] [DecidableEq α''] in
/-- Slicing a fiber can only lose deficit: the sliced deficits of a fiber never
exceed the deficit of its marginal.  (Concavity of entropy, `D_superadditive`.) -/
lemma sliced_deficit_le (f : α → α') {q : α × β → ℝ} (hq : ∀ i, 0 ≤ q i) (u : α') :
    ∑ y : β, D (fib f u) (fun x => q (x, y)) ≤ D (fib f u) (marg1 q) := by
  have := D_superadditive (s := fib f u) (t := (univ : Finset β))
    (v := fun y x => q (x, y)) (fun y _ x _ => hq _)
  simpa [marg1] using this

/-- **Exactness criterion.**  A merged conditional reading is exact precisely
when, in every context and on every fiber of the merge, slicing the fiber over
the response loses no deficit.  Every discrepancy is therefore attributable to
a specific `(context, fiber)` pair. -/
theorem CMI_eq_iff_fiberwise_tight (f : α → α') {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 f p) = CMI p ↔
      ∀ (z : γ) (u : α'),
        ∑ y : β, D (fib f u) (fun x => slice p z (x, y)) = D (fib f u) (marg1 (slice p z)) := by
  have hloss : CMI p - CMI (pushFst3 f p)
      = ∑ z : γ, ∑ u : α', (D (fib f u) (marg1 (slice p z))
          - ∑ y : β, D (fib f u) (fun x => slice p z (x, y))) := by
    rw [CMI_loss_eq]
    exact Finset.sum_congr rfl fun z _ => (Finset.sum_sub_distrib _ _).symm
  have hnn : ∀ z : γ, ∀ u ∈ (univ : Finset α'),
      0 ≤ D (fib f u) (marg1 (slice p z))
        - ∑ y : β, D (fib f u) (fun x => slice p z (x, y)) := by
    intro z u _
    have := sliced_deficit_le f (q := slice p z) (fun i => hp _) u
    linarith
  have hnn' : ∀ z ∈ (univ : Finset γ), 0 ≤ ∑ u : α', (D (fib f u) (marg1 (slice p z))
      - ∑ y : β, D (fib f u) (fun x => slice p z (x, y))) :=
    fun z _ => Finset.sum_nonneg (hnn z)
  constructor
  · intro h z u
    have hzero : ∑ z : γ, ∑ u : α', (D (fib f u) (marg1 (slice p z))
        - ∑ y : β, D (fib f u) (fun x => slice p z (x, y))) = 0 := by
      rw [← hloss, h]
      ring
    have hz := (Finset.sum_eq_zero_iff_of_nonneg hnn').mp hzero z (mem_univ z)
    have := (Finset.sum_eq_zero_iff_of_nonneg (hnn z)).mp hz u (mem_univ u)
    linarith
  · intro h
    have hzero : ∑ z : γ, ∑ u : α', (D (fib f u) (marg1 (slice p z))
        - ∑ y : β, D (fib f u) (fun x => slice p z (x, y))) = 0 :=
      Finset.sum_eq_zero fun z _ => Finset.sum_eq_zero fun u _ => by rw [h z u]; ring
    rw [hzero] at hloss
    linarith

/-- **Local strictness criterion.**  A single context and a single fiber on
which slicing loses deficit already forces the merged reading to be strictly
below the true one. -/
theorem CMI_lt_of_fiber_gap (f : α → α') {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i)
    {z : γ} {u : α'}
    (hgap : ∑ y : β, D (fib f u) (fun x => slice p z (x, y)) < D (fib f u) (marg1 (slice p z))) :
    CMI (pushFst3 f p) < CMI p := by
  rcases lt_or_eq_of_le (CMI_pushFst3_le (f := f) hp) with h | h
  · exact h
  · exact absurd ((CMI_eq_iff_fiberwise_tight f hp).mp h z u) (ne_of_lt hgap)

/-! ## Chaining -/

omit [Fintype β] [Fintype γ] [Fintype α'] [Fintype α''] in
/-- Fibers of a composite labelling, restricted to a fiber of the outer map. -/
lemma fib_filter_comp (f : α → α') (g : α' → α'') {w : α''} {u : α'} (hu : g u = w) :
    {x ∈ fib (g ∘ f) w | f x = u} = fib f u := by
  ext x
  simp only [Finset.mem_filter, mem_fib, Function.comp_apply]
  constructor
  · rintro ⟨-, h⟩
    exact h
  · intro h
    exact ⟨by rw [h]; exact hu, h⟩

omit [Fintype β] [Fintype γ] [Fintype α''] in
/-- **Merges compose.**  Chaining two label encodings is the same as applying
the composite encoding. -/
theorem pushFst3_comp (f : α → α') (g : α' → α'') (p : α × β × γ → ℝ) :
    pushFst3 g (pushFst3 f p) = pushFst3 (g ∘ f) p := by
  funext q
  have hmaps : ∀ x ∈ fib (g ∘ f) q.1, f x ∈ fib g q.1 := by
    intro x hx
    have : (g ∘ f) x = q.1 := mem_fib.mp hx
    exact mem_fib.mpr this
  have hkey := Finset.sum_fiberwise_of_maps_to (s := fib (g ∘ f) q.1)
    (t := fib g q.1) (g := f) hmaps (fun x => p (x, q.2.1, q.2.2))
  simp only [pushFst3]
  rw [← hkey]
  refine Finset.sum_congr rfl fun u hu => ?_
  rw [fib_filter_comp f g (mem_fib.mp hu)]

/-- **Chained bugs are still one-sided.**  Composing a further merge on top of
an existing encoding can only lower the conditional reading. -/
theorem CMI_chain_monotone (f : α → α') (g : α' → α'') {p : α × β × γ → ℝ}
    (hp : ∀ i, 0 ≤ p i) : CMI (pushFst3 (g ∘ f) p) ≤ CMI (pushFst3 f p) := by
  rw [← pushFst3_comp f g p]
  exact CMI_pushFst3_le (f := g) (p := pushFst3 f p)
    (fun i => Finset.sum_nonneg fun x _ => hp _)

/-! ## Sub-dials -/

/-- **Reporting only one coordinate of a compound dial loses dependence.**
Taking the first component of a two-part dial is a label merge, so the reading
it produces is a lower bound for the compound reading. -/
theorem CMI_proj_le {α₁ α₂ : Type*} [Fintype α₁] [Fintype α₂] [DecidableEq α₁]
    {p : (α₁ × α₂) × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 Prod.fst p) ≤ CMI p :=
  CMI_pushFst3_le hp

/-! ## The capacity cap -/

omit [Fintype γ] [Fintype α'] [Fintype α''] [DecidableEq α'] [DecidableEq α''] in
/-- A marginal never carries more entropy than the joint weight it comes from. -/
lemma H_marg2_le_H {q : α × β → ℝ} (hq : ∀ i, 0 ≤ q i) :
    H (univ : Finset β) (marg2 q) ≤ H (univ : Finset (α × β)) q := by
  have hsplit : H (univ : Finset (α × β)) q = ∑ y : β, ∑ x : α, nlp (q (x, y)) := by
    simp only [H]
    rw [Fintype.sum_prod_type]
    exact Finset.sum_comm
  rw [hsplit, H]
  refine Finset.sum_le_sum fun y _ => ?_
  exact nlp_sum_le_H (s := (univ : Finset α)) (w := fun x => q (x, y)) (fun x _ => hq _)

omit [Fintype γ] [Fintype α'] [Fintype α''] [DecidableEq α'] [DecidableEq α''] in
/-- Per-slice cap: the information a slice can carry is bounded by the entropy
of its first marginal. -/
lemma MI_le_H_marg1 {q : α × β → ℝ} (hq : ∀ i, 0 ≤ q i) :
    MI q ≤ H (univ : Finset α) (marg1 q) := by
  have := H_marg2_le_H hq
  simp only [MI]
  linarith

/-- **The reading is capped by the conditional entropy of the dial**:
`I(X;Y|Z) ≤ H(X|Z)`.  Since a merge can only decrease `H(X|Z)`, a merged table
can never report more dependence than the label entropy it retains. -/
theorem CMI_le_condH {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI p ≤ ∑ z : γ, (H (univ : Finset α) (marg1 (slice p z)) - nlp (mass (slice p z))) := by
  refine Finset.sum_le_sum fun z _ => ?_
  have := MI_le_H_marg1 (q := slice p z) (fun i => hp _)
  linarith

/-! ## The audited population, conditionally -/

/-- **Conditional form of the audited reconciliation.**  On the audited `4 × 9`
population of `Applications.JointLabelReconciliation`, in *every* context and
for *every* response variable, the width-valid `·9` chaining dominates the
narrow `·3` rebuild: the narrow frame can only under-report conditional
dependence, never over-report it. -/
theorem audited_conditional_reconciliation
    {p : JointLabelReconciliation.Pop × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 encNarrow p) ≤ CMI (pushFst3 encWide p) :=
  CMI_reconciliation encWide_injective hp

end ConditionalArtifactAccounting