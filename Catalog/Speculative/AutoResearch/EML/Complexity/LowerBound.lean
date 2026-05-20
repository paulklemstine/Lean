import EML.Complexity.Basic
import EML.Complexity.Growth

/-!
# EML Circuit Depth Separation — Lower Bound and Separation Theorem

## Main Results

- **`emlDepth_lower_bound_iterExp`**: Any EML expression representing `iterExp n` on
  positive reals must have `emlDepth ≥ n`. This is the central depth separation theorem.
- **`depth_separation`**: Formal separation: `iterExp n` has depth `n` in `FullExpr`
  but requires `emlDepth ≥ n` in `EMLExpr`.
-/

noncomputable section

open Real

/-- emlDepth = 0 iff the expression has no eml nodes. -/
theorem EMLExpr.emlDepth_eq_zero_iff_noEml (e : EMLExpr) :
    e.emlDepth = 0 ↔ e.noEml := by
  induction e <;> simp_all [EMLExpr.emlDepth, EMLExpr.noEml]

/-! ## The Main Lower Bound -/

/-- **Core theorem**: Any EML expression representing `iterExp n` on positive reals
    must have EML depth at least `n`. -/
theorem emlDepth_lower_bound_iterExp
    (n : ℕ) (e : EMLExpr)
    (hrep : RepresentsOnPos e (iterExp n)) :
    n ≤ e.emlDepth := by
  sorry

/-! ## The Separation Theorem -/

/-- **Depth separation theorem**: The family `iterExp n` witnesses an asymptotically
    tight separation between `FullExpr` depth and `EMLExpr` EML-depth. -/
theorem depth_separation (n : ℕ) :
    (∃ ef : FullExpr, FullRepresentsOnPos ef (iterExp n) ∧ ef.depth = n) ∧
    (∀ ee : EMLExpr, RepresentsOnPos ee (iterExp n) → n ≤ ee.emlDepth) := by
  constructor
  · exact ⟨fullExprIterExp n, fun x hx => fullExprIterExp_eval n x, fullExprIterExp_depth n⟩
  · exact emlDepth_lower_bound_iterExp n

/-- **Cross-language separation**: For every n, there exists a FullExpr of depth n
    such that any EMLExpr computing the same function requires emlDepth ≥ n. -/
theorem cross_language_depth_separation :
    ∀ n : ℕ, ∃ ef : FullExpr,
      ef.depth = n ∧
      ∀ ee : EMLExpr, RepresentsSameFunctionOnPos ef ee → n ≤ ee.emlDepth := by
  intro n
  refine ⟨fullExprIterExp n, fullExprIterExp_depth n, fun ee h => ?_⟩
  apply emlDepth_lower_bound_iterExp
  intro x hx
  rw [← fullExprIterExp_eval]
  exact (h x hx).symm

end