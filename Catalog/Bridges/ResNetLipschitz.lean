import Mathlib

/-!
# Lipschitz constants of residual blocks

This module supplies the two basic estimates used by the certified-robustness files
`Bridges/ResNetTropicalCertified.lean` and
`Bridges/AbstractAlgebra/ResNetTropicalCertified.lean`:

* `ResNetLipschitz.resnet_block_lipschitz` — a residual block `x ↦ x + g x` with an
  `L`-Lipschitz branch `g` is `(1 + L)`-Lipschitz;
* `ResNetLipschitz.bernoulli_resnet` — Bernoulli's inequality `1 + nL ≤ (1 + L)ⁿ`,
  the depth-`n` iterate of the previous bound.
-/

noncomputable section

namespace ResNetLipschitz

/-- **Residual block bound.**  If `g` is `L`-Lipschitz then `x ↦ x + g x` is
`(1 + L)`-Lipschitz. -/
theorem resnet_block_lipschitz {X : Type*} [NormedAddCommGroup X]
    (g : X → X) (L : ℝ) (_hL : 0 ≤ L)
    (hg : ∀ x y, ‖g x - g y‖ ≤ L * ‖x - y‖) (x y : X) :
    ‖(x + g x) - (y + g y)‖ ≤ (1 + L) * ‖x - y‖ := by
  have hsplit : (x + g x) - (y + g y) = (x - y) + (g x - g y) := by abel
  calc ‖(x + g x) - (y + g y)‖ = ‖(x - y) + (g x - g y)‖ := by rw [hsplit]
    _ ≤ ‖x - y‖ + ‖g x - g y‖ := norm_add_le _ _
    _ ≤ ‖x - y‖ + L * ‖x - y‖ := by gcongr; exact hg x y
    _ = (1 + L) * ‖x - y‖ := by ring

/-- **Depth growth.**  Bernoulli's inequality: stacking `n` residual blocks whose branch
has Lipschitz constant `L` grows the certified bound at least linearly. -/
theorem bernoulli_resnet (L : ℝ) (hL : 0 ≤ L) (n : ℕ) : 1 + n * L ≤ (1 + L) ^ n :=
  one_add_mul_le_pow (by linarith) n

/-- The certified Lipschitz constant of a residual block is at least `1`: the skip
connection cannot be contracted away. -/
theorem one_le_resnet_constant (L : ℝ) (hL : 0 ≤ L) : (1 : ℝ) ≤ 1 + L := by linarith

end ResNetLipschitz