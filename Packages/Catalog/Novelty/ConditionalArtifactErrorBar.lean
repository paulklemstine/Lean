/-
# An observable error bar for merged conditional readings

Third cycle on `Novelty.ConditionalLabelDPI`.  The one-sidedness theorem fixes
the *sign* of every collision artifact.  This file fixes its *size*, and does
so in terms of a quantity that an auditor can compute from the label table
alone, without access to the true population:

  `0 ≤ I(X;Y|Z) - I(f(X);Y|Z) ≤ ∑_z [ H(p_{X,z}) - H(f_* p_{X,z}) ]`.

The right-hand side is the label entropy the merge destroys inside each
conditioning slice — a property of the encoding and of the *marginal* dial
counts, not of the joint table.  Consequences:

* `CMI_loss_le_label_entropy_loss` — the sandwich itself;
* `CMI_exact_of_no_label_loss` — if the merge destroys no label entropy in any
  slice, the merged conditional reading is *exact*.  This strictly generalises
  the injective case: the encoding may collide, as long as it never collides on
  dial settings that actually occur in a slice;
* `CMI_loss_le_of_uniform_slice_bound` — a per-slice error budget adds up to a
  global error budget.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation
import Novelty.ConditionalLabelDPI
import Novelty.ConditionalArtifactAccounting

namespace ConditionalArtifactErrorBar

open Finset LabelEntropy JointLabelReconciliation ConditionalLabelDPI
open ConditionalArtifactAccounting

variable {α β γ α' : Type*} [Fintype α] [Fintype β] [Fintype γ] [Fintype α']
  [DecidableEq α']

/-- The label entropy destroyed by the merge `f` inside the slice `z`; an
observable of the encoding and the marginal dial counts only. -/
noncomputable def labelLoss (f : α → α') (p : α × β × γ → ℝ) (z : γ) : ℝ :=
  H (univ : Finset α) (marg1 (slice p z)) - H (univ : Finset α') (push f (marg1 (slice p z)))

omit [Fintype γ] in
lemma labelLoss_eq_sum_D (f : α → α') (p : α × β × γ → ℝ) (z : γ) :
    labelLoss f p z = ∑ u : α', D (fib f u) (marg1 (slice p z)) :=
  H_sub_H_push f (marg1 (slice p z))

omit [Fintype γ] in
lemma labelLoss_nonneg {f : α → α'} {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) (z : γ) :
    0 ≤ labelLoss f p z := by
  rw [labelLoss_eq_sum_D]
  exact Finset.sum_nonneg fun u _ =>
    D_nonneg fun x _ => Finset.sum_nonneg fun y _ => hp _

/-- **The error bar.**  The conditional information destroyed by a label merge
never exceeds the label entropy that the merge destroys, slice by slice.
Together with `CMI_pushFst3_le` this sandwiches every reported conditional
value between two computable numbers. -/
theorem CMI_loss_le_label_entropy_loss (f : α → α') {p : α × β × γ → ℝ}
    (hp : ∀ i, 0 ≤ p i) :
    CMI p - CMI (pushFst3 f p) ≤ ∑ z : γ, labelLoss f p z := by
  rw [CMI_loss_eq f p]
  refine Finset.sum_le_sum fun z _ => ?_
  rw [labelLoss_eq_sum_D]
  have hnn : 0 ≤ ∑ u : α', ∑ y : β, D (fib f u) (fun x => slice p z (x, y)) :=
    Finset.sum_nonneg fun u _ =>
      Finset.sum_nonneg fun y _ => D_nonneg fun x _ => hp _
  linarith

/-- **Two-sided bracket.**  A merged reading and the observable label loss
bracket the true conditional value. -/
theorem CMI_bracket (f : α → α') {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i) :
    CMI (pushFst3 f p) ≤ CMI p ∧
      CMI p ≤ CMI (pushFst3 f p) + ∑ z : γ, labelLoss f p z := by
  refine ⟨CMI_pushFst3_le hp, ?_⟩
  have := CMI_loss_le_label_entropy_loss f hp
  linarith

/-- **Exactness without injectivity.**  If the encoding destroys no label
entropy in any conditioning slice — i.e. it never merges two dial settings that
both occur in the same context — then the merged conditional reading is exact,
even though `f` may be wildly non-injective elsewhere. -/
theorem CMI_exact_of_no_label_loss (f : α → α') {p : α × β × γ → ℝ}
    (hp : ∀ i, 0 ≤ p i) (h : ∀ z : γ, labelLoss f p z = 0) :
    CMI (pushFst3 f p) = CMI p := by
  have hupper := CMI_loss_le_label_entropy_loss f hp
  rw [Finset.sum_congr rfl (fun z _ => h z)] at hupper
  simp only [Finset.sum_const_zero] at hupper
  have hlower := CMI_pushFst3_le (f := f) hp
  linarith

/-- A uniform per-slice error budget integrates to a global one. -/
theorem CMI_loss_le_of_uniform_slice_bound (f : α → α') {p : α × β × γ → ℝ} {c : ℝ}
    (hp : ∀ i, 0 ≤ p i) (h : ∀ z : γ, labelLoss f p z ≤ c) :
    CMI p - CMI (pushFst3 f p) ≤ (Fintype.card γ : ℝ) * c := by
  refine le_trans (CMI_loss_le_label_entropy_loss f hp) ?_
  have : ∑ _z : γ, c = (Fintype.card γ : ℝ) * c := by
    rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  rw [← this]
  exact Finset.sum_le_sum fun z _ => h z

end ConditionalArtifactErrorBar