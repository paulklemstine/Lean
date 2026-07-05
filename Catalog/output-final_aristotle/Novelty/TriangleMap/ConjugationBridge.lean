/-
# Bridge: Young Conjugation ≅ the Geometric Conjugation Symmetry

This file ties the algebraic `ℤ/2ℤ` of Young conjugation (`YoungConjugation.lean`) to the
geometric involutions of the natural-extension model (`NaturalExtensionInvolution.lean`).

The literal **coordinate swap** `σ = Prod.swap` is, at the level of individual cells, exactly the
rule that *defines* Young conjugation: `c ∈ λ' ↔ swap c ∈ λ` (`swap_mem_transpose_iff`).  On the
plane `σ` is a measure-preserving involution (`sigma_measurePreserving`) fixing the diagonal
cells `D₁, D₃` and swapping the anti-diagonal cells `D₂ ↔ D₄`.

Together with the point reflection `τ` of `NaturalExtensionInvolution.lean`, `σ` generates a
`ℤ/2ℤ × ℤ/2ℤ` (Klein four) group of measure-preserving symmetries: `σ` (transpose), `τ` (point
reflection), and their common composite `σ ∘ τ = τ ∘ σ`, the **anti-transpose**
`α(x, y) = (1 - y, 1 - x)`, which is again an involution (`sigma_tau_comm`, `sigma_comp_tau`,
`antitranspose_involutive`).

-- !-- Lab Notes -- !--
Hypothesis (H3): The transpose `σ`, being coordinate exchange, is the *same* operation that
  Mathlib uses to define `YoungDiagram.transpose`; and `σ`, `τ` generate a Klein four-group of
  measure-preserving symmetries of the natural extension.
Experiment: `mem_transpose` states `c ∈ μ.transpose ↔ c.swap ∈ μ`, i.e. the cell-level action of
  Young conjugation is literally `Prod.swap` — the geometric `σ`.  Computing `σ ∘ τ` and `τ ∘ σ`
  both gave the anti-transpose `α`, so the two involutions commute and the group they generate is
  `{id, σ, τ, α} ≅ (ℤ/2)²`.
Analysis: This closes the loop begun in the two companion files.  The abstract order-two symmetry
  of partitions and the equal-mass four-cell partition of the natural extension are *two faces of
  one operation*: coordinate exchange.  The Klein four-group is the honest symmetry group; the
  single generator `τ` from the description is one of its three involutions, and `σ` is the one
  that literally is Young conjugation.
Critique: We verified `σ ∘ τ = τ ∘ σ` on the nose (`funext`), so commutativity is not assumed.
  Measure preservation of `σ` reduces to `Measure.measurePreserving_swap` after rewriting `volume`
  on `ℝ²` as a product — no `sorry`, no `native_decide`.
Synthesis: Young conjugation and the triangle-map natural-extension involution coincide as the
  coordinate swap, upgraded on the plane to a measure-preserving Klein four-group acting on four
  equal-mass subdomains.
-/
import Mathlib
import Novelty.TriangleMap.YoungConjugation
import Novelty.TriangleMap.NaturalExtensionInvolution

open MeasureTheory YoungDiagram

namespace TriangleMap

noncomputable section

/-- The geometric **transpose** on the natural-extension model: coordinate exchange. -/
def sigmaMap : ℝ × ℝ → ℝ × ℝ := Prod.swap

/-- The **anti-transpose** `α(x, y) = (1 - y, 1 - x)`, i.e. transpose composed with the point
reflection. -/
def antitranspose : ℝ × ℝ → ℝ × ℝ := fun p => ((1 : ℝ) - p.2, (1 : ℝ) - p.1)

/-! ### The cell-level identity: `Prod.swap` *is* Young conjugation -/

/-- **Bridge theorem.**  The geometric coordinate swap is precisely the rule defining Young
conjugation: a cell lies in the conjugate diagram `λ'` iff its swap lies in `λ`. -/
theorem swap_mem_transpose_iff (μ : YoungDiagram) (c : ℕ × ℕ) :
    c ∈ youngConj μ ↔ Prod.swap c ∈ μ := by
  simp only [youngConj_apply]; exact (mem_transpose (μ := μ) (c := c))

/-! ### `σ` on the plane -/

theorem sigma_involutive : Function.Involutive sigmaMap := by
  intro p; simp [sigmaMap]

theorem sigma_measurePreserving : MeasurePreserving sigmaMap volume volume := by
  rw [Measure.volume_eq_prod]; exact Measure.measurePreserving_swap

/-- `σ` fixes the diagonal cell `D₁`. -/
theorem sigma_image_D1 : sigmaMap '' D1 = D1 := by
  unfold sigmaMap D1; rw [Set.image_swap_prod]

/-- `σ` fixes the diagonal cell `D₃`. -/
theorem sigma_image_D3 : sigmaMap '' D3 = D3 := by
  unfold sigmaMap D3; rw [Set.image_swap_prod]

/-- `σ` swaps the anti-diagonal cells `D₂ ↔ D₄`. -/
theorem sigma_image_D2 : sigmaMap '' D2 = D4 := by
  unfold sigmaMap D2 D4; rw [Set.image_swap_prod]

theorem sigma_image_D4 : sigmaMap '' D4 = D2 := by
  unfold sigmaMap D4 D2; rw [Set.image_swap_prod]

/-! ### The Klein four-group `⟨σ, τ⟩` -/

/-- `σ` and `τ` commute. -/
theorem sigma_tau_comm : sigmaMap ∘ tau = tau ∘ sigmaMap := by
  funext p; simp [sigmaMap, tau, Prod.swap]

/-- Their composite is the anti-transpose. -/
theorem sigma_comp_tau : sigmaMap ∘ tau = antitranspose := by
  funext p; simp [sigmaMap, tau, antitranspose, Prod.swap]

/-- The anti-transpose is an involution. -/
theorem antitranspose_involutive : Function.Involutive antitranspose := by
  intro p; simp [antitranspose]

/-- The anti-transpose is measure preserving (composite of two measure-preserving maps). -/
theorem antitranspose_measurePreserving : MeasurePreserving antitranspose volume volume := by
  rw [← sigma_comp_tau]
  exact (sigma_measurePreserving.comp tau_measurePreserving)

/-- **Main theorem (bridge / synthesis).**  The three non-identity elements of the symmetry group
`⟨σ, τ⟩` — the transpose `σ` (Young conjugation), the point reflection `τ`, and the anti-transpose
`σ ∘ τ` — are all measure-preserving involutions of the natural-extension model.  Hence Young
conjugation, realised geometrically, extends to a measure-preserving Klein four-group of the
triangle map's natural extension. -/
theorem klein_four_measurePreserving_involutions :
    (Function.Involutive sigmaMap ∧ MeasurePreserving sigmaMap volume volume) ∧
    (Function.Involutive tau ∧ MeasurePreserving tau volume volume) ∧
    (Function.Involutive antitranspose ∧ MeasurePreserving antitranspose volume volume) ∧
    sigmaMap ∘ tau = tau ∘ sigmaMap := by
  refine ⟨⟨sigma_involutive, sigma_measurePreserving⟩, ⟨tau_involutive, tau_measurePreserving⟩,
    ⟨antitranspose_involutive, antitranspose_measurePreserving⟩, sigma_tau_comm⟩

end

end TriangleMap