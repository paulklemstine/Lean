/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Full Hodge Decomposition: Down + Up Laplacian and the Harmonic Obstruction

This file *extends* the up-only skeleton of
`Catalog/Speculative/AutoResearch/HodgeSpectralThreshold.lean` (theorems
`hodge_quadform`, `hodge_psd`, `harmonic_iff_boundary`) from the single up-Laplacian
`L = Bᵀ B` to the genuine combinatorial **Hodge Laplacian** on `k`-cochains, built from
*two* boundary maps.

For boundary operators
* `∂ₖ` realized as a matrix `D : C_k → C_{k-1}`  (the *down* / divergence map), and
* `∂ₖ₊₁` realized as a matrix `E : C_{k+1} → C_k`  (the *up* / gradient map),

the Hodge Laplacian on `C_k` is

  `L = Dᵀ D + E Eᵀ`   (`fullHodge D E`),

a sum of the *down* Laplacian `Dᵀ D` and the *up* Laplacian `E Eᵀ`.  The Dirichlet
energy splits as a sum of two squared norms, and the chain condition `∂ₖ ∂ₖ₊₁ = 0`
(`D * E = 0`) makes the two energy channels orthogonal.

## Main results

* `fullHodge_isSymm`        — the full Hodge Laplacian is symmetric.
* `fullHodge_quadform`      — `⟨x, Lx⟩ = ‖Dx‖² + ‖Eᵀx‖²` (split Dirichlet energy).
* `fullHodge_psd`           — `L` is positive semidefinite.
* `fullHodge_kernel`        — **discrete Hodge theorem**: a cochain is *harmonic*
    (`Lx = 0`) iff it is simultaneously **closed** (`Dx = 0`) and **coclosed**
    (`Eᵀx = 0`); this refines `harmonic_iff_boundary` to the genuine cohomological
    invariant `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`.
* `hodge_image_orthogonal`  — under `∂ₖ ∂ₖ₊₁ = 0`, the gradient image `im E` is
    orthogonal to the divergence image `im Dᵀ`.
* `hodge_energy_pythagoras` — Pythagoras for the Hodge splitting: the energy of a
    gradient-plus-curl field is the sum of the two energies.

## Catalog synthesis

This realizes **Research Direction 2** of `HodgeSpectralThreshold`'s FUTURE_DIRECTIONS:
the cross term `⟨Dx, Eᵀx⟩`-type interference vanishes exactly when `∂∂ = 0`, turning the
two Dirichlet energies into an orthogonal sum so harmonicity decouples into "closed" and
"coclosed".  It bridges the *MachineLearning* domain (higher-order/simplicial message
passing) with algebraic topology (the discrete Hodge theorem and Betti numbers).
-/
import Mathlib

namespace HodgeFullDecomposition

open Matrix

variable {p n q : ℕ}

-- !-- Lab Notebook -- !--
-- Hypothesis: The single up-Laplacian identity `⟨x, BᵀB x⟩ = ‖Bx‖²` should generalize to
--   the two-map Hodge Laplacian `Dᵀ D + E Eᵀ`, splitting the energy into a "closed" and a
--   "coclosed" channel, with the chain condition `∂∂ = 0` making the channels orthogonal.
-- Result: All six statements below are proven sorry-free.  `fullHodge_kernel` is the
--   genuine discrete Hodge theorem (harmonic = closed ∧ coclosed), and the orthogonality
--   `hodge_image_orthogonal` is the *only* place where `D * E = 0` is consumed.
-- Insight: The whole decomposition rests on bilinearity of `dotProduct` plus the two
--   transpose-adjunction lemmas `vecMul_transpose` / `mulVec_transpose`; the harmonic
--   characterization is then pure nonnegativity (`Finset.sum_nonneg` + `mul_self_nonneg`)
--   followed by `dotProduct_self_eq_zero`.  No spectral theorem is needed.
-- Failure analysis: `positivity` cannot see the `dotProduct` sum-of-products as a sum of
--   squares (entries are `v i * v i`, not `(v i)^2`), so each nonnegativity fact is built
--   by hand.  The `D * E = 0` hypothesis is genuinely unnecessary for the kernel split —
--   that fact uses only PSD of each summand — and is reserved for the orthogonality lemmas.
-- !-- end Lab Notebook -- !--

/-- The full combinatorial **Hodge Laplacian** on `k`-cochains, assembled from a down
map `D = ∂ₖ` and an up map `E = ∂ₖ₊₁`:  `L = Dᵀ D + E Eᵀ` (down Laplacian + up Laplacian). -/
def fullHodge (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ) :
    Matrix (Fin n) (Fin n) ℝ := Dᵀ * D + E * Eᵀ

-- !-- `(Dᵀ D + E Eᵀ)ᵀ = Dᵀ D + E Eᵀ` since each summand is a symmetric Gram matrix. -- !--
theorem fullHodge_isSymm (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ) :
    (fullHodge D E).IsSymm := by
  unfold fullHodge
  simp [Matrix.IsSymm, Matrix.transpose_add, Matrix.transpose_mul]

-- !-- Split Dirichlet energy: distribute `dotProduct` over the sum, then apply the
--    up-Laplacian identity to each Gram summand via `mulVec_mulVec` and the two
--    transpose-adjunctions `vecMul_transpose` / `mulVec_transpose`. -- !--
theorem fullHodge_quadform (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ)
    (x : Fin n → ℝ) :
    x ⬝ᵥ (fullHodge D E) *ᵥ x = (D *ᵥ x) ⬝ᵥ (D *ᵥ x) + (Eᵀ *ᵥ x) ⬝ᵥ (Eᵀ *ᵥ x) := by
  unfold fullHodge
  rw [Matrix.add_mulVec, dotProduct_add]
  congr 1
  · rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec, Matrix.vecMul_transpose]
  · rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec, Matrix.mulVec_transpose]

-- !-- The Dirichlet energy is a sum of two sums of squares, hence nonnegative. -- !--
theorem fullHodge_psd (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ)
    (x : Fin n → ℝ) : 0 ≤ x ⬝ᵥ (fullHodge D E) *ᵥ x := by
  rw [fullHodge_quadform]
  have h1 : (0:ℝ) ≤ (D *ᵥ x) ⬝ᵥ (D *ᵥ x) := Finset.sum_nonneg fun i _ => mul_self_nonneg _
  have h2 : (0:ℝ) ≤ (Eᵀ *ᵥ x) ⬝ᵥ (Eᵀ *ᵥ x) := Finset.sum_nonneg fun i _ => mul_self_nonneg _
  linarith

-- !-- Discrete Hodge theorem.  `(→)`: `Lx = 0` forces the *sum* of two nonnegative
--    energies to vanish, so each vanishes, and `dotProduct_self_eq_zero` gives `Dx = 0`,
--    `Eᵀx = 0`.  `(←)`: both vanish, so `Lx = Dᵀ(Dx) + E(Eᵀx) = 0`. -- !--
theorem fullHodge_kernel (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ)
    (x : Fin n → ℝ) :
    (fullHodge D E) *ᵥ x = 0 ↔ D *ᵥ x = 0 ∧ Eᵀ *ᵥ x = 0 := by
  constructor
  · intro h
    have hq : (D *ᵥ x) ⬝ᵥ (D *ᵥ x) + (Eᵀ *ᵥ x) ⬝ᵥ (Eᵀ *ᵥ x) = 0 := by
      rw [← fullHodge_quadform, h, dotProduct_zero]
    have h1 : (0:ℝ) ≤ (D *ᵥ x) ⬝ᵥ (D *ᵥ x) := Finset.sum_nonneg fun i _ => mul_self_nonneg _
    have h2 : (0:ℝ) ≤ (Eᵀ *ᵥ x) ⬝ᵥ (Eᵀ *ᵥ x) := Finset.sum_nonneg fun i _ => mul_self_nonneg _
    exact ⟨dotProduct_self_eq_zero.mp (by linarith), dotProduct_self_eq_zero.mp (by linarith)⟩
  · rintro ⟨hD, hE⟩
    unfold fullHodge
    rw [Matrix.add_mulVec, ← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec, hD, hE,
      Matrix.mulVec_zero, Matrix.mulVec_zero, add_zero]

-- !-- Gradient/divergence orthogonality.  `⟨E y, Dᵀ z⟩ = ⟨D(E y), z⟩ = ⟨(DE) y, z⟩ = 0`
--    using the chain condition `D * E = 0`.  This is the only consumer of `∂∂ = 0`. -- !--
theorem hodge_image_orthogonal (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ)
    (hDE : D * E = 0) (y : Fin q → ℝ) (z : Fin p → ℝ) :
    (E *ᵥ y) ⬝ᵥ (Dᵀ *ᵥ z) = 0 := by
  rw [Matrix.dotProduct_mulVec, Matrix.vecMul_transpose, Matrix.mulVec_mulVec, hDE,
    Matrix.zero_mulVec, zero_dotProduct]

-- !-- Pythagoras for the Hodge splitting: the two cross terms vanish by
--    `hodge_image_orthogonal`, leaving the sum of the channel energies. -- !--
theorem hodge_energy_pythagoras (D : Matrix (Fin p) (Fin n) ℝ) (E : Matrix (Fin n) (Fin q) ℝ)
    (hDE : D * E = 0) (y : Fin q → ℝ) (z : Fin p → ℝ) :
    (E *ᵥ y + Dᵀ *ᵥ z) ⬝ᵥ (E *ᵥ y + Dᵀ *ᵥ z)
      = (E *ᵥ y) ⬝ᵥ (E *ᵥ y) + (Dᵀ *ᵥ z) ⬝ᵥ (Dᵀ *ᵥ z) := by
  have h1 : (E *ᵥ y) ⬝ᵥ (Dᵀ *ᵥ z) = 0 := hodge_image_orthogonal D E hDE y z
  have h2 : (Dᵀ *ᵥ z) ⬝ᵥ (E *ᵥ y) = 0 := by rw [dotProduct_comm]; exact h1
  rw [dotProduct_add, add_dotProduct, add_dotProduct, h1, h2]; ring

end HodgeFullDecomposition