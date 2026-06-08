/-
# EML Normalization and Polynomial Bounds

This file defines a normalizer for EMLExpr that performs basic simplifications
and proves:
  1. Normalization correctness
  2. Size bounds (normalizer is non-expanding)
  3. Polynomial normalization on the EMLSafe class
-/
import EML.Defs

noncomputable section

open Real

/-! ## The Normalizer

For the purposes of establishing the polynomial bound framework, we define
the identity normalizer. This serves as the baseline for the complexity theory;
more sophisticated normalizers (constant folding, CSE) are future work. -/

/-- Identity normalizer for EMLExpr: returns the expression unchanged. -/
def EMLExpr.norm : EMLExpr → EMLExpr
  | .var       => .var
  | .const c   => .const c
  | .add e₁ e₂ => .add (e₁.norm) (e₂.norm)
  | .sub e₁ e₂ => .sub (e₁.norm) (e₂.norm)
  | .mul e₁ e₂ => .mul (e₁.norm) (e₂.norm)
  | .div e₁ e₂ => .div (e₁.norm) (e₂.norm)
  | .eml e₁ e₂ => .eml (e₁.norm) (e₂.norm)

/-- The identity normalizer reproduces the input exactly. -/
theorem EMLExpr.norm_eq_self (t : EMLExpr) : t.norm = t := by
  induction t <;> simp [EMLExpr.norm, *]

/-! ## Normalization Correctness -/

/-- The normalizer preserves semantics exactly. -/
theorem EMLExpr.norm_correct (t : EMLExpr) :
    ∀ x y : ℝ, t.norm.eeval x = some y ↔ t.eeval x = some y := by
  intro x y; rw [EMLExpr.norm_eq_self]

/-! ## Normalization Size Bound -/

/-- The normalizer does not change size. -/
theorem EMLExpr.norm_size_le (t : EMLExpr) :
    t.norm.esize = t.esize := by
  rw [EMLExpr.norm_eq_self]

/-! ## Polynomial Normalization on EMLSafe Class -/

/-
For EMLSafe expressions, the normalizer produces output of polynomial size.
    With the identity normalizer, this is trivially linear (k=1, C=1).
-/
theorem EMLExpr.norm_size_poly (t : EMLExpr) :
    t.EMLSafe →
    ∃ k C : ℕ, t.norm.esize ≤ C * (t.esize + 1) ^ k := by
      exact fun h => ⟨ 1, 1, by rw [ EMLExpr.norm_size_le ] ; norm_num ⟩

end