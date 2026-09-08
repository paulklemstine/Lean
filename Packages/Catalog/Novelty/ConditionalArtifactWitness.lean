/-
# Explicit witnesses: conditional artifacts are one-sided, and conditional
# readings are not determined by the single-dial ones

Companion to `Novelty.ConditionalLabelDPI`.  The conditional data-processing
inequality proved there says a merge can only *lower* `I(X;Y|Z)`.  This file
shows the two boundaries of that guarantee on explicit `2 × 2 × 2` populations
(`Bool × Bool × Bool`):

* `xor_CMI_merge_eq_zero` together with `xor_CMI_eq_one`: the constant merge
  `g = fun _ => true` turns a population with `I(X;Y|Z) = 1` bit into a reading
  of `0` bits.  A reported conditional *independence* can therefore be a pure
  collision artifact — the negative half of the one-sided error guarantee.
* `xor_MI_eq_zero`: the very same population has `I(X;Y) = 0`.  So a clean
  single-dial (unconditional) table can read `0` while the conditional table
  reads `1`.
* `copy_MI_eq_one` and `copy_CMI_eq_zero`: the reverse inclusion also fails, on
  the "copy" population `X = Y = Z`.

Together the last two say the unconditional and conditional readings are
*logically independent*: neither bounds the other, so the guarantee proved in
`ConditionalLabelDPI` genuinely has to be established conditionally, and no
statement about the single-dial tables follows from it.
-/
import Mathlib
import Applications.LabelEntropyDeficit
import Applications.JointLabelReconciliation
import Novelty.ConditionalLabelDPI
import Novelty.ConditionalArtifactErrorBar
import Novelty.ConditionalChainRule
import Novelty.StrictLabelDeficit

namespace ConditionalArtifactWitness

open Finset LabelEntropy JointLabelReconciliation ConditionalLabelDPI
open ConditionalArtifactErrorBar ConditionalChainRule ConditionalArtifactAccounting

/-! ## Arithmetic of the Shannon term at the dyadic values we need -/

lemma logb_two_half : Real.logb 2 ((1 : ℝ) / 2) = -1 := by
  rw [show (1 : ℝ) / 2 = (2 : ℝ)⁻¹ by norm_num, Real.logb_inv,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]

lemma logb_two_quarter : Real.logb 2 ((1 : ℝ) / 4) = -2 := by
  have h : (1 : ℝ) / 4 = ((1 : ℝ) / 2) * ((1 : ℝ) / 2) := by norm_num
  rw [h, Real.logb_mul (by norm_num) (by norm_num), logb_two_half]
  norm_num

@[simp] lemma nlp_half : nlp ((1 : ℝ) / 2) = 1 / 2 := by
  rw [nlp, logb_two_half]; norm_num

@[simp] lemma nlp_quarter : nlp ((1 : ℝ) / 4) = 1 / 2 := by
  rw [nlp, logb_two_quarter]; norm_num

@[simp] lemma nlp_one : nlp (1 : ℝ) = 0 := by
  rw [nlp, Real.logb_one]; norm_num

/-- The `X,Y`-marginal of a three-factor joint weight: the *single-dial* table
obtained by forgetting the conditioning variable. -/
noncomputable def dropThird {α β γ : Type*} [Fintype γ] (p : α × β × γ → ℝ) : α × β → ℝ :=
  fun i => ∑ z : γ, p (i.1, i.2, z)

/-! ## The XOR population: `I(X;Y) = 0` but `I(X;Y|Z) = 1` -/

/-- `Z = X xor Y`, uniform on its four supporting cells. -/
noncomputable def xorW : Bool × Bool × Bool → ℝ :=
  fun q => if xor q.1 q.2.1 = q.2.2 then 1 / 4 else 0

lemma xorW_nonneg : ∀ i, 0 ≤ xorW i := by
  intro i
  unfold xorW
  split <;> norm_num

/-- The single-dial reading of the XOR population is `0` bits: `X` and `Y` are
unconditionally independent. -/
theorem xor_MI_eq_zero : MI (dropThird xorW) = 0 := by
  simp [MI, H, marg1, marg2, dropThird, xorW, Fintype.sum_prod_type]
  norm_num

/-- The conditional reading of the XOR population is a full bit: given `Z`, the
dial `X` determines the response `Y`. -/
theorem xor_CMI_eq_one : CMI xorW = 1 := by
  simp [CMI, MI, H, marg1, marg2, mass, ConditionalLabelDPI.slice, xorW,
    Fintype.sum_prod_type]
  norm_num

/-- The collapsing label merge. -/
def mergeAll : Bool → Bool := fun _ => true

lemma mergeAll_not_injective : ¬ Function.Injective mergeAll := by
  intro h
  exact absurd (h (show mergeAll false = mergeAll true from rfl)) (by decide)

/-- **A reported conditional independence can be a pure artifact.**  After the
collapsing merge the XOR population reads as conditionally independent. -/
theorem xor_CMI_merge_eq_zero : CMI (pushFst3 mergeAll xorW) = 0 := by
  simp [CMI, MI, H, marg1, marg2, mass, ConditionalLabelDPI.slice, pushFst3, fib, mergeAll, xorW,
    Fintype.sum_prod_type]
  norm_num

/-- **The negative half of the one-sided error guarantee is sharp**: the merged
table reports conditional independence although the population is maximally
conditionally dependent. -/
theorem conditional_independence_may_be_artifact :
    CMI (pushFst3 mergeAll xorW) = 0 ∧ 0 < CMI xorW := by
  refine ⟨xor_CMI_merge_eq_zero, ?_⟩
  rw [xor_CMI_eq_one]
  norm_num

/-! ## The copy population: `I(X;Y) = 1` but `I(X;Y|Z) = 0` -/

/-- The "copy" population `X = Y = Z`, uniform on its two supporting cells. -/
noncomputable def copyW : Bool × Bool × Bool → ℝ :=
  fun q => if q.1 = q.2.1 ∧ q.2.1 = q.2.2 then 1 / 2 else 0

lemma copyW_nonneg : ∀ i, 0 ≤ copyW i := by
  intro i
  unfold copyW
  split <;> norm_num

/-- The single-dial reading of the copy population is a full bit. -/
theorem copy_MI_eq_one : MI (dropThird copyW) = 1 := by
  simp [MI, H, marg1, marg2, dropThird, copyW, Fintype.sum_prod_type]
  norm_num

/-- Its conditional reading is `0`: knowing `Z` already fixes both `X` and `Y`. -/
theorem copy_CMI_eq_zero : CMI copyW = 0 := by
  simp [CMI, MI, H, marg1, marg2, mass, ConditionalLabelDPI.slice, copyW,
    Fintype.sum_prod_type]

/-- **The conditional and single-dial tables are logically independent.**
Neither reading bounds the other: there is a population with
`I(X;Y) = 0 < 1 = I(X;Y|Z)` and one with `I(X;Y|Z) = 0 < 1 = I(X;Y)`.
Hence the conditional one-sidedness theorem transfers *no* information to the
single-dial tables, and vice versa. -/
theorem conditional_and_unconditional_independent :
    (MI (dropThird xorW) < CMI xorW) ∧ (CMI copyW < MI (dropThird copyW)) := by
  rw [xor_MI_eq_zero, xor_CMI_eq_one, copy_CMI_eq_zero, copy_MI_eq_one]
  norm_num

/-! ## Merging the *context* axis is two-sided -/

/-- Collapsing the conditioning variable of the XOR population destroys a full
bit of conditional dependence. -/
theorem xor_CMI_contextMerge_eq_zero : CMI (pushThd mergeAll xorW) = 0 := by
  simp [CMI, MI, H, marg1, marg2, mass, ConditionalLabelDPI.slice, pushThd, fib, mergeAll,
    xorW, Fintype.sum_prod_type]
  norm_num

/-- Collapsing the conditioning variable of the copy population *creates* a
full bit of conditional dependence. -/
theorem copy_CMI_contextMerge_eq_one : CMI (pushThd mergeAll copyW) = 1 := by
  simp [CMI, MI, H, marg1, marg2, mass, ConditionalLabelDPI.slice, pushThd, fib, mergeAll,
    copyW, Fintype.sum_prod_type]
  norm_num

/-- **The one-sidedness guarantee is specific to the dial axis.**  Merging
labels of the *conditioning* variable can move the reading in either
direction, so a collision in the context column is not a signed error: it can
manufacture a dependence as easily as destroy one. -/
theorem context_merge_is_two_sided :
    CMI (pushThd mergeAll xorW) < CMI xorW ∧ CMI copyW < CMI (pushThd mergeAll copyW) := by
  rw [xor_CMI_contextMerge_eq_zero, xor_CMI_eq_one, copy_CMI_eq_zero,
    copy_CMI_contextMerge_eq_one]
  norm_num

/-! ## The error bar is attained -/

/-- On the XOR population the collapsing merge destroys exactly one bit of
label entropy (half a bit in each of the two contexts). -/
theorem xor_labelLoss_total_eq_one :
    ∑ z : Bool, labelLoss mergeAll xorW z = 1 := by
  simp [labelLoss, H, marg1, push, fib, mergeAll, ConditionalLabelDPI.slice, xorW]
  norm_num

/-- **The observable error bar of `ConditionalArtifactErrorBar` is sharp.**  On
the XOR population the conditional information destroyed by the collapsing
merge equals, exactly, the label entropy the merge destroys.  So no smaller
function of the label table alone can bound the artifact. -/
theorem error_bar_is_tight :
    CMI xorW - CMI (pushFst3 mergeAll xorW) = ∑ z : Bool, labelLoss mergeAll xorW z := by
  rw [xor_CMI_eq_one, xor_CMI_merge_eq_zero, xor_labelLoss_total_eq_one]
  norm_num

/-! ## The local strictness criterion fires on the witness -/

/-- In the context `z = true`, the fiber of the collapsing merge loses all of
its deficit when sliced over the response: the sliced deficits vanish while the
marginal deficit is `1/2`. -/
theorem xor_fiber_gap :
    ∑ y : Bool, D (fib mergeAll true) (fun x => ConditionalLabelDPI.slice xorW true (x, y))
      < D (fib mergeAll true) (marg1 (ConditionalLabelDPI.slice xorW true)) := by
  simp [D, H, fib, mergeAll, ConditionalLabelDPI.slice, marg1, xorW]
  norm_num

/-- The strict drop, obtained from the *criterion* rather than from the two
numerical values — an independent route to `xor_CMI_merge_eq_zero`. -/
theorem xor_strict_from_criterion : CMI (pushFst3 mergeAll xorW) < CMI xorW :=
  CMI_lt_of_fiber_gap mergeAll xorW_nonneg xor_fiber_gap

/-- The fiber of the collapsing merge is not a product table in the context
`z = true`: the cell `(true, true)` is empty while the rank-one prediction from
its row and column sums is `1/8`. -/
theorem xor_nonproduct_cell :
    ConditionalLabelDPI.slice xorW true (true, true) ≠
      marg1 (ConditionalLabelDPI.slice xorW true) true
        * (∑ x ∈ fib mergeAll true, ConditionalLabelDPI.slice xorW true (x, true))
        / (∑ x ∈ fib mergeAll true, marg1 (ConditionalLabelDPI.slice xorW true) x) := by
  simp [fib, mergeAll, marg1, ConditionalLabelDPI.slice, xorW]
  norm_num

/-- **The detection criterion of `StrictLabelDeficit` fires.**  Strictness of
the drop follows from a single non-product cell, with no numerical evaluation
of either conditional reading. -/
theorem xor_strict_from_nonproduct : CMI (pushFst3 mergeAll xorW) < CMI xorW := by
  refine StrictLabelDeficit.CMI_lt_of_nonproduct_fiber mergeAll xorW_nonneg true true ?_
    (y₀ := true) (x₀ := true) (by simp [fib, mergeAll]) xor_nonproduct_cell
  simp [fib, mergeAll, marg1, ConditionalLabelDPI.slice, xorW]

/-! ## Numerical cross-check of the chain rule -/

/-- The pair channel `X` versus `(Y,Z)` of the XOR population carries one bit. -/
theorem xor_MI_pair_eq_one : MI xorW = 1 := by
  simp [MI, H, marg1, marg2, xorW, Fintype.sum_prod_type]
  norm_num

/-- Its context channel `X` versus `Z` carries none. -/
theorem xor_MI_context_eq_zero : MI (margXZ xorW) = 0 := by
  simp [MI, H, marg1, marg2, margXZ, xorW, Fintype.sum_prod_type]
  norm_num

/-- The pair channel of the copy population carries one bit … -/
theorem copy_MI_pair_eq_one : MI copyW = 1 := by
  simp [MI, H, marg1, marg2, copyW, Fintype.sum_prod_type]
  norm_num

/-- … and so does its context channel. -/
theorem copy_MI_context_eq_one : MI (margXZ copyW) = 1 := by
  simp [MI, H, marg1, marg2, margXZ, copyW, Fintype.sum_prod_type]
  norm_num

/-- **Independent numerical confirmation of `CMI_eq_MI_sub_MI`.**  Both
witnesses satisfy `I(X;Y|Z) = I(X;(Y,Z)) - I(X;Z)` with values computed
separately from the definitions: `1 = 1 - 0` and `0 = 1 - 1`. -/
theorem chain_rule_numerics :
    CMI xorW = MI xorW - MI (margXZ xorW) ∧ CMI copyW = MI copyW - MI (margXZ copyW) := by
  rw [xor_CMI_eq_one, xor_MI_pair_eq_one, xor_MI_context_eq_zero, copy_CMI_eq_zero,
    copy_MI_pair_eq_one, copy_MI_context_eq_one]
  norm_num

end ConditionalArtifactWitness