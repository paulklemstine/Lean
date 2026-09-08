/-
# The conditional reading is a difference of two unconditional readings

Fourth cycle on `Novelty.ConditionalLabelDPI`.  The slice-wise definition of
`CMI` is convenient for the data-processing argument but opaque as an audit
procedure: it needs the full three-way table.  Here it is identified with a
four-term entropy balance and, as a consequence, with a difference of two
*ordinary* mutual informations:

  `I(X;Y|Z) = H(X,Z) + H(Y,Z) - H(X,Y,Z) - H(Z) = I(X;(Y,Z)) - I(X;Z)`.

Note that in Lean `α × β × γ` *is* `α × (β × γ)`, so the joint weight `p` is
literally also the joint weight of the pair channel `X` versus `(Y,Z)`, and
`MI p` is `I(X;(Y,Z))`.

Consequences:

* `CMI_eq_entropy_balance` — the four-term identity (no normalisation of the
  weight is required);
* `CMI_eq_MI_sub_MI` — **conditional readings are auditable from two
  unconditional tables**: the pair channel `X` vs `(Y,Z)` and the context
  channel `X` vs `Z`.  This is the independent verification route for the
  conditional columns;
* `MI_le_CMI_add_MI_context` — the pair reading is the sum of the conditional
  reading and the context reading, so a large unconditional pair reading is
  explained either by genuine conditional dependence or by dial/context
  coupling, and never by both being small.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation
import Novelty.ConditionalLabelDPI

namespace ConditionalChainRule

open Finset LabelEntropy JointLabelReconciliation ConditionalLabelDPI

variable {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]

/-- The `X,Z` table: the joint weight of the dial and the context, with the
response summed out. -/
noncomputable def margXZ (p : α × β × γ → ℝ) : α × γ → ℝ :=
  fun q => ∑ y : β, p (q.1, y, q.2)

lemma sum_H_marg1_slice (p : α × β × γ → ℝ) :
    ∑ z : γ, H (univ : Finset α) (marg1 (slice p z)) = H (univ : Finset (α × γ)) (margXZ p) := by
  simp only [H]
  rw [Fintype.sum_prod_type, Finset.sum_comm]
  rfl

lemma sum_H_marg2_slice (p : α × β × γ → ℝ) :
    ∑ z : γ, H (univ : Finset β) (marg2 (slice p z)) = H (univ : Finset (β × γ)) (marg2 p) := by
  simp only [H]
  rw [Fintype.sum_prod_type, Finset.sum_comm]
  rfl

lemma sum_H_slice (p : α × β × γ → ℝ) :
    ∑ z : γ, H (univ : Finset (α × β)) (slice p z) = H (univ : Finset (α × β × γ)) p := by
  simp only [H]
  have hL : ∀ z : γ, ∑ i : α × β, nlp (slice p z i)
      = ∑ x : α, ∑ y : β, nlp (p (x, y, z)) := by
    intro z
    rw [Fintype.sum_prod_type]
    rfl
  have hR : ∀ x : α, ∑ q : β × γ, nlp (p (x, q)) = ∑ y : β, ∑ z : γ, nlp (p (x, y, z)) := by
    intro x
    rw [Fintype.sum_prod_type]
  rw [Finset.sum_congr rfl (fun z _ => hL z), Fintype.sum_prod_type,
    Finset.sum_congr rfl (fun x _ => hR x), Finset.sum_comm]
  exact Finset.sum_congr rfl fun x _ => Finset.sum_comm

lemma sum_nlp_mass_slice (p : α × β × γ → ℝ) :
    ∑ z : γ, nlp (mass (slice p z)) = H (univ : Finset γ) (marg2 (margXZ p)) := by
  simp only [H]
  refine Finset.sum_congr rfl fun z _ => ?_
  congr 1
  simp only [mass, marg2, margXZ, ConditionalLabelDPI.slice]
  rw [Fintype.sum_prod_type]

omit [Fintype α] in
lemma marg1_margXZ (p : α × β × γ → ℝ) : marg1 (margXZ p) = marg1 p := by
  funext x
  simp only [marg1, margXZ]
  rw [Fintype.sum_prod_type]
  exact Finset.sum_comm

/-- The `X,Z` table carries the same total mass as the full three-way table. -/
lemma mass_margXZ (p : α × β × γ → ℝ) : mass (margXZ p) = ∑ i : α × β × γ, p i := by
  simp only [mass, margXZ]
  rw [Fintype.sum_prod_type, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Fintype.sum_prod_type]
  exact Finset.sum_comm

/-- **The conditional reading is a four-term entropy balance**:
`I(X;Y|Z) = H(X,Z) + H(Y,Z) - H(X,Y,Z) - H(Z)`.  No normalisation of the weight
is needed. -/
theorem CMI_eq_entropy_balance (p : α × β × γ → ℝ) :
    CMI p = H (univ : Finset (α × γ)) (margXZ p) + H (univ : Finset (β × γ)) (marg2 p)
      - H (univ : Finset (α × β × γ)) p - H (univ : Finset γ) (marg2 (margXZ p)) := by
  simp only [CMI, MI]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    sum_H_marg1_slice, sum_H_marg2_slice, sum_H_slice, sum_nlp_mass_slice]

/-- **Conditional readings are auditable from two unconditional tables.**
`I(X;Y|Z) = I(X;(Y,Z)) - I(X;Z)`: the conditional column can be recomputed from
the pair channel and the context channel, both of which are ordinary
two-variable readings. -/
theorem CMI_eq_MI_sub_MI (p : α × β × γ → ℝ) :
    CMI p = MI p - MI (margXZ p) := by
  rw [CMI_eq_entropy_balance, MI, MI, marg1_margXZ]
  ring

/-- **The pair reading splits.**  `I(X;(Y,Z)) = I(X;Y|Z) + I(X;Z)`: a
dependence seen in the pair channel is either conditional dependence or
dial/context coupling. -/
theorem MI_pair_eq_CMI_add_MI_context (p : α × β × γ → ℝ) :
    MI p = CMI p + MI (margXZ p) := by
  rw [CMI_eq_MI_sub_MI]
  ring

/-- For a (sub)probability weight both summands of the split are nonnegative,
so the pair reading dominates the conditional one:
`I(X;Y|Z) ≤ I(X;(Y,Z))`.  The hypothesis is necessary: the entropies here are
unnormalised, and a weight of total mass `> 1` can make the context reading
negative. -/
theorem CMI_le_MI_pair {p : α × β × γ → ℝ} (hp : ∀ i, 0 ≤ p i)
    (hprob : ∑ i : α × β × γ, p i ≤ 1) : CMI p ≤ MI p := by
  have hsplit := MI_pair_eq_CMI_add_MI_context p
  have hctx : 0 ≤ MI (margXZ p) - nlp (mass (margXZ p)) :=
    MI_sub_nlp_mass_nonneg (q := margXZ p) fun i => Finset.sum_nonneg fun y _ => hp _
  have hmass : 0 ≤ mass (margXZ p) :=
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun y _ => hp _
  have hle : mass (margXZ p) ≤ 1 := by rw [mass_margXZ]; exact hprob
  have hnlp : 0 ≤ nlp (mass (margXZ p)) := by
    rcases eq_or_lt_of_le hmass with h0 | hpos
    · simp [nlp, ← h0]
    · have hlog : Real.logb 2 (mass (margXZ p)) ≤ 0 :=
        Real.logb_nonpos (by norm_num) hmass hle
      simp only [nlp, neg_nonneg]
      exact mul_nonpos_of_nonneg_of_nonpos hmass hlog
  linarith

end ConditionalChainRule