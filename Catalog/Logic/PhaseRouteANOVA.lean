/-
# Where the excess lives: an exact degree-1 / degree-2 split of any target

`Logic.PhaseRouteAlignment` shows that one particular family of targets (the
alignment indicators) is invisible to every singleton encoding.  This file
proves the *structural* theorem behind it, for an arbitrary target on a product
sample space `α × β`:

  every `f : α × β → ℝ` splits **uniquely and orthogonally** as

      `f = addPart f + intPart f`,

  where `addPart f (a,b) = rowMean f a + colMean f b - avg f` is additive
  (degree `1`, i.e. reachable by singleton encodings) and `intPart f` has all
  row sums and all column sums equal to zero (degree `2`, pure interaction).

Main results.

* `intPart_zeroMarginals`, `cov_intPart_additive_eq_zero` : the interaction part
  is orthogonal to *every* additive predictor.
* `varr_split` : `varr f = varr (addPart f) + varr (intPart f)` — an exact
  variance budget with no cross term.
* `msse_additive_ge_varr_intPart` and `msse_addPart` : the best possible
  singleton model has error exactly `varr (intPart f)`, attained by `addPart f`.
* `Rsq_additive_le_ceiling` and `Rsq_addPart_eq_ceiling` : hence the **degree-1
  ceiling**

      `sup over singleton encodings of R² = varr (addPart f) / varr f`,

  which is a computable diagnostic: the entire unreachable excess is
  `varr (intPart f) / varr f`, no matter which singleton features are tried.
* `addPart_alignment_const` / `alignment_ceiling_zero` : for an alignment target
  the degree-1 part is *constant*, so its ceiling is `0` and the excess is
  `100%` — the closure result of `Logic.PhaseRouteAlignment` becomes a corollary
  of the general accounting identity.
-/
import Logic.PhaseRouteAlignment

namespace Logic.PhaseRoute

open Finset

section ANOVA

variable {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]

/-- Row mean: average over the second coordinate with the first one fixed. -/
noncomputable def rowMean (f : α × β → ℝ) (a : α) : ℝ := avg (fun b : β => f (a, b))

/-- Column mean: average over the first coordinate with the second one fixed. -/
noncomputable def colMean (f : α × β → ℝ) (b : β) : ℝ := avg (fun a : α => f (a, b))

/-- The degree-1 (additive, "singleton-reachable") part of `f`. -/
noncomputable def addPart (f : α × β → ℝ) : α × β → ℝ :=
  additive (fun a => rowMean f a) (fun b => colMean f b - avg f)

/-- The degree-2 (pure interaction) part of `f`. -/
noncomputable def intPart (f : α × β → ℝ) : α × β → ℝ := fun x => f x - addPart f x

lemma cardA_pos : (0:ℝ) < (Fintype.card α : ℝ) := by
  have : 0 < Fintype.card α := Fintype.card_pos
  positivity

lemma cardB_pos : (0:ℝ) < (Fintype.card β : ℝ) := by
  have : 0 < Fintype.card β := Fintype.card_pos
  positivity

omit [Nonempty α] [Nonempty β] in
lemma addPart_add_intPart (f : α × β → ℝ) (x : α × β) :
    addPart f x + intPart f x = f x := by
  simp [intPart]

/-- The average of the row means is the grand mean. -/
lemma avg_rowMean (f : α × β → ℝ) : avg (fun a => rowMean f a) = avg f := by
  have hA := cardA_pos (α := α)
  have hB := cardB_pos (β := β)
  simp only [rowMean, avg, Fintype.card_prod, Nat.cast_mul, Fintype.sum_prod_type]
  rw [← Finset.sum_div]
  field_simp

/-- The average of the column means is the grand mean. -/
lemma avg_colMean (f : α × β → ℝ) : avg (fun b => colMean f b) = avg f := by
  have hA := cardA_pos (α := α)
  have hB := cardB_pos (β := β)
  simp only [colMean, avg, Fintype.card_prod, Nat.cast_mul, Fintype.sum_prod_type]
  rw [← Finset.sum_div, Finset.sum_comm]
  field_simp

lemma avg_addPart (f : α × β → ℝ) : avg (addPart f) = avg f := by
  have h : avg (addPart f) = avg (fun a => rowMean f a) + avg (fun b => colMean f b - avg f) :=
    avg_additive _ _
  rw [h, avg_rowMean, avg_sub, avg_colMean, avg_const]
  ring

lemma avg_intPart (f : α × β → ℝ) : avg (intPart f) = 0 := by
  have h : intPart f = fun x => f x - addPart f x := rfl
  rw [h, avg_sub, avg_addPart, sub_self]

/-- Each row of the interaction part sums to zero. -/
lemma intPart_row_sum (f : α × β → ℝ) (a : α) : (∑ b : β, intPart f (a, b)) = 0 := by
  have hB := cardB_pos (β := β)
  have hrow : (∑ b : β, f (a, b)) = (Fintype.card β : ℝ) * rowMean f a := by
    simp only [rowMean, avg]
    field_simp
  have hcol : (∑ b : β, colMean f b) = (Fintype.card β : ℝ) * avg f := by
    have h1 : (∑ b : β, colMean f b) / (Fintype.card β : ℝ) = avg f := avg_colMean f
    rw [div_eq_iff (ne_of_gt hB)] at h1
    rw [h1]; ring
  simp only [intPart, addPart, additive]
  rw [Finset.sum_sub_distrib, hrow]
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul,
    Finset.sum_sub_distrib, hcol, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  ring

/-- Each column of the interaction part sums to zero. -/
lemma intPart_col_sum (f : α × β → ℝ) (b : β) : (∑ a : α, intPart f (a, b)) = 0 := by
  have hA := cardA_pos (α := α)
  have hcol : (∑ a : α, f (a, b)) = (Fintype.card α : ℝ) * colMean f b := by
    simp only [colMean, avg]
    field_simp
  have hrow : (∑ a : α, rowMean f a) = (Fintype.card α : ℝ) * avg f := by
    have h1 : (∑ a : α, rowMean f a) / (Fintype.card α : ℝ) = avg f := avg_rowMean f
    rw [div_eq_iff (ne_of_gt hA)] at h1
    rw [h1]; ring
  simp only [intPart, addPart, additive]
  rw [Finset.sum_sub_distrib, hcol, Finset.sum_add_distrib, hrow, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul]
  ring

omit [Nonempty α] [Nonempty β] in
/-- A function with vanishing row and column sums is orthogonal to every additive
predictor: the raw mean of the product already vanishes. -/
lemma avg_mul_additive_of_zero_marginals {g : α × β → ℝ}
    (hrow : ∀ a, (∑ b : β, g (a, b)) = 0) (hcol : ∀ b, (∑ a : α, g (a, b)) = 0)
    (u : α → ℝ) (v : β → ℝ) :
    avg (fun x : α × β => g x * additive u v x) = 0 := by
  have hs : (∑ x : α × β, g x * additive u v x) = 0 := by
    rw [Fintype.sum_prod_type]
    have hsplit : ∀ a : α, (∑ b : β, g (a, b) * additive u v (a, b))
        = u a * (∑ b : β, g (a, b)) + ∑ b : β, g (a, b) * v b := by
      intro a
      rw [Finset.mul_sum, ← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun b _ => by simp [additive]; ring
    rw [Finset.sum_congr rfl fun a _ => hsplit a, Finset.sum_add_distrib]
    have h1 : (∑ a : α, u a * ∑ b : β, g (a, b)) = 0 := by
      refine Finset.sum_eq_zero fun a _ => ?_
      rw [hrow a, mul_zero]
    have h2 : (∑ a : α, ∑ b : β, g (a, b) * v b) = 0 := by
      rw [Finset.sum_comm]
      refine Finset.sum_eq_zero fun b _ => ?_
      rw [← Finset.sum_mul, hcol b, zero_mul]
    rw [h1, h2, add_zero]
  simp [avg, hs]

/-- **Orthogonality of the interaction part.** -/
theorem cov_intPart_additive_eq_zero (f : α × β → ℝ) (u : α → ℝ) (v : β → ℝ) :
    cov (intPart f) (additive u v) = 0 := by
  have h0 := avg_mul_additive_of_zero_marginals (g := intPart f)
    (intPart_row_sum f) (intPart_col_sum f) u v
  simp only [cov, h0, avg_intPart, zero_mul, sub_zero]

/-- The interaction part is orthogonal in particular to the additive part. -/
theorem cov_addPart_intPart (f : α × β → ℝ) : cov (addPart f) (intPart f) = 0 := by
  rw [cov_comm]
  exact cov_intPart_additive_eq_zero f _ _

omit [Nonempty α] [Nonempty β] in
lemma varr_add (g h : α × β → ℝ) :
    varr (fun x => g x + h x) = varr g + varr h + 2 * cov g h := by
  have h1 : (fun x : α × β => (g x + h x) * (g x + h x))
      = (fun x : α × β => (g x * g x + h x * h x) + 2 * (g x * h x)) := by
    funext x; ring
  simp only [varr, cov, h1]
  rw [avg_add, avg_add, avg_const_mul, avg_add]
  ring

/-- **Exact variance budget.** The degree-1 and degree-2 parts carry the whole
variance, with no cross term. -/
theorem varr_split (f : α × β → ℝ) : varr f = varr (addPart f) + varr (intPart f) := by
  have hf : f = fun x => addPart f x + intPart f x := by
    funext x; rw [addPart_add_intPart]
  rw [show varr f = varr (fun x => addPart f x + intPart f x) by rw [← hf]]
  rw [varr_add, cov_addPart_intPart]
  ring

/-- **Degree-1 lower bound.** Every singleton (additive) model has error at least
the interaction variance. -/
theorem msse_additive_ge_varr_intPart (f : α × β → ℝ) (u : α → ℝ) (v : β → ℝ) :
    varr (intPart f) ≤ msse f (additive u v) := by
  have hz := avg_mul_additive_of_zero_marginals (g := intPart f) (intPart_row_sum f)
    (intPart_col_sum f) (fun a => rowMean f a - u a) (fun b => (colMean f b - avg f) - v b)
  have hfd : ∀ x : α × β, f x - additive u v x
      = intPart f x + additive (fun a => rowMean f a - u a)
          (fun b => (colMean f b - avg f) - v b) x := by
    intro x
    simp only [intPart, addPart, additive]
    ring
  have hexp : msse f (additive u v)
      = avg (fun x => intPart f x * intPart f x)
        + 2 * avg (fun x => intPart f x * additive (fun a => rowMean f a - u a)
            (fun b => (colMean f b - avg f) - v b) x)
        + avg (fun x => additive (fun a => rowMean f a - u a)
              (fun b => (colMean f b - avg f) - v b) x
            * additive (fun a => rowMean f a - u a)
              (fun b => (colMean f b - avg f) - v b) x) := by
    simp only [msse]
    rw [show (fun x : α × β => (f x - additive u v x) * (f x - additive u v x))
        = (fun x : α × β => (intPart f x * intPart f x
            + 2 * (intPart f x * additive (fun a => rowMean f a - u a)
              (fun b => (colMean f b - avg f) - v b) x))
          + additive (fun a => rowMean f a - u a) (fun b => (colMean f b - avg f) - v b) x
            * additive (fun a => rowMean f a - u a) (fun b => (colMean f b - avg f) - v b) x)
        from funext fun x => by rw [hfd x]; ring]
    rw [avg_add, avg_add, avg_const_mul]
  have hv : varr (intPart f) = avg (fun x => intPart f x * intPart f x) := by
    simp only [varr, cov, avg_intPart]
    ring
  have hdd : 0 ≤ avg (fun x => additive (fun a => rowMean f a - u a)
      (fun b => (colMean f b - avg f) - v b) x
      * additive (fun a => rowMean f a - u a) (fun b => (colMean f b - avg f) - v b) x) :=
    avg_nonneg fun _ => mul_self_nonneg _
  rw [hexp, hv, hz]
  linarith

/-- The additive part attains the bound: it is the optimal singleton model. -/
theorem msse_addPart (f : α × β → ℝ) : msse f (addPart f) = varr (intPart f) := by
  have h : (fun x : α × β => (f x - addPart f x) * (f x - addPart f x))
      = (fun x : α × β => intPart f x * intPart f x) := by
    funext x; simp [intPart]
  have hv : varr (intPart f) = avg (fun x => intPart f x * intPart f x) := by
    simp only [varr, cov, avg_intPart]
    ring
  rw [msse, h, hv]

/-- **The degree-1 ceiling.** For a nondegenerate target, no singleton encoding
can exceed `varr (addPart f) / varr f`; the remaining
`varr (intPart f) / varr f` is unreachable at degree `1`. -/
theorem Rsq_additive_le_ceiling {f : α × β → ℝ} (hf : 0 < varr f) (u : α → ℝ) (v : β → ℝ) :
    Rsq f (additive u v) ≤ varr (addPart f) / varr f := by
  have hlb := msse_additive_ge_varr_intPart f u v
  have hsplit := varr_split f
  have hdiv : varr (intPart f) / varr f ≤ msse f (additive u v) / varr f := by
    gcongr
  have hrw : varr (intPart f) / varr f = 1 - varr (addPart f) / varr f := by
    field_simp
    linarith
  rw [hrw] at hdiv
  simp only [Rsq]
  linarith

/-- And the ceiling is attained. -/
theorem Rsq_addPart_eq_ceiling {f : α × β → ℝ} (hf : 0 < varr f) :
    Rsq f (addPart f) = varr (addPart f) / varr f := by
  have hsplit := varr_split f
  rw [Rsq, msse_addPart]
  field_simp
  linarith

end ANOVA

/-! ### The alignment target has degree-1 ceiling exactly zero -/

section AlignmentCeiling

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α] [Nonempty β]

omit [Fintype α] [Nonempty α] in
lemma rowMean_graphInd (σ : α ≃ β) (a : α) :
    rowMean (graphInd σ) a = 1 / (Fintype.card β : ℝ) := by
  have hB := cardB_pos (β := β)
  have hs : (∑ b : β, graphInd σ (a, b)) = 1 := by
    simp [graphInd]
  simp only [rowMean, avg, hs]

omit [Fintype β] [Nonempty β] in
lemma colMean_graphInd (σ : α ≃ β) (b : β) :
    colMean (graphInd σ) b = 1 / (Fintype.card α : ℝ) := by
  have hA := cardA_pos (α := α)
  have hs : (∑ a : α, graphInd σ (a, b)) = 1 := by
    rw [Finset.sum_eq_single (σ.symm b)]
    · simp [graphInd]
    · intro a _ ha
      have hb : ¬ (b = σ a) := fun hb => ha (by rw [hb, Equiv.symm_apply_apply])
      simp [graphInd, hb]
    · intro hmem
      exact absurd (Finset.mem_univ (σ.symm b)) hmem
  simp only [colMean, avg, hs]

/-- **The degree-1 part of an alignment target is constant.** All information is
in the interaction layer. -/
theorem addPart_graphInd_const (σ : α ≃ β) (x : α × β) :
    addPart (graphInd σ) x = 1 / (Fintype.card α : ℝ) := by
  have hA := cardA_pos (α := α)
  have hb : (Fintype.card β : ℝ) = (Fintype.card α : ℝ) := card_eq_of_equiv σ
  simp only [addPart, additive, rowMean_graphInd, colMean_graphInd, avg_graphInd, hb]
  ring

theorem varr_addPart_graphInd (σ : α ≃ β) : varr (addPart (graphInd σ)) = 0 := by
  have h : addPart (graphInd σ) = fun _ : α × β => 1 / (Fintype.card α : ℝ) := by
    funext x; exact addPart_graphInd_const σ x
  rw [h, varr_const]

/-- **The degree-1 ceiling of an alignment target is exactly `0`, and the whole
variance is the unreachable interaction excess.** This re-derives — now as an
instance of a general accounting identity — the closure of the linear phase
route, and simultaneously says precisely how much is missing: everything. -/
theorem alignment_ceiling_zero (σ : α ≃ β) (hcard : 2 ≤ Fintype.card α) :
    varr (addPart (graphInd σ)) / varr (graphInd σ) = 0 ∧
      varr (intPart (graphInd σ)) = varr (graphInd σ) := by
  have hpos := varr_graphInd_pos σ hcard
  have hsplit := varr_split (graphInd σ)
  have hz := varr_addPart_graphInd σ
  constructor
  · rw [hz, zero_div]
  · rw [hz] at hsplit; linarith

end AlignmentCeiling

end Logic.PhaseRoute