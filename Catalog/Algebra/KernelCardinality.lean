/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Rank-Sensitive Exact Kernel Cardinality over ZMod q

This file formalizes the exact cardinality of matrix kernels over finite prime fields.

## Main results

* `card_mulVecLin_ker_exact`: The cardinality of `ker(φ)` for `φ = Matrix.mulVecLin M`
  equals `q ^ finrank(ker φ)`.
* `finrank_ker_mulVecLin`: Rank-nullity for `mulVecLin`: `finrank(ker φ) = p - finrank(range φ)`.
* `card_mulVec_kernel_exact`: The number of vectors `r` with `M.mulVec r = 0` is exactly
  `q ^ (p - rank(M))`.
* `card_mulVec_affine_exact`: The number of solutions to `M.mulVec r = b` is `q^(p - rank(M))`
  when `b` is in the range, and `0` otherwise.

## Mathematical significance

This converts the coarse bound `|ker(M)| ≤ q^(p-1)` into a rank-sensitive exact counting theorem,
connecting finite-field linear algebra to randomized algorithm analysis (Freivalds verification),
coding theory (nullspace code dimension), and complexity theory.
-/

import Mathlib

open Classical

namespace KernelCardinality

variable {q m p : ℕ} [Fact q.Prime]

/-- The subtype `{r // M.mulVec r = 0}` is equivalent to the kernel of `mulVecLin M`. -/
noncomputable def subtypeMulVecZeroEquivKer
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    {r : Fin p → ZMod q // M.mulVec r = 0} ≃ LinearMap.ker (Matrix.mulVecLin M) :=
  Equiv.subtypeEquivProp (by ext r; simp [LinearMap.mem_ker])

/-- The `finrank` of `Fin p → ZMod q` over `ZMod q` is `p`. -/
theorem finrank_fin_fun_zmod :
    Module.finrank (ZMod q) (Fin p → ZMod q) = p := by
  rw [Module.finrank_pi, Fintype.card_fin]

/-- Rank-nullity for `mulVecLin`: the kernel dimension plus the range dimension equals `p`. -/
theorem finrank_ker_add_finrank_range_mulVecLin
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    Module.finrank (ZMod q) (LinearMap.ker (Matrix.mulVecLin M)) +
    Module.finrank (ZMod q) (LinearMap.range (Matrix.mulVecLin M)) = p := by
  have := LinearMap.finrank_range_add_finrank_ker (Matrix.mulVecLin M)
  rw [finrank_fin_fun_zmod] at this
  omega

/-- Rank-nullity for `mulVecLin`:
`finrank(ker(mulVecLin M)) = p - finrank(range(mulVecLin M))`. -/
theorem finrank_ker_mulVecLin
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    Module.finrank (ZMod q) (LinearMap.ker (Matrix.mulVecLin M))
      = p - Module.finrank (ZMod q) (LinearMap.range (Matrix.mulVecLin M)) := by
  have := finrank_ker_add_finrank_range_mulVecLin M
  omega

/-- The cardinality of `ker(mulVecLin M)` equals `q ^ finrank(ker)`.
This is the finite-field counting law for vector subspaces. -/
theorem card_mulVecLin_ker_exact
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    Fintype.card (LinearMap.ker (Matrix.mulVecLin M))
      = q ^ Module.finrank (ZMod q) (LinearMap.ker (Matrix.mulVecLin M)) := by
  rw [Module.card_eq_pow_finrank (K := ZMod q), ZMod.card q]

/-- **Main theorem**: The number of vectors `r : Fin p → ZMod q` satisfying `M.mulVec r = 0`
is exactly `q ^ (p - rank(M))`, where `rank(M)` is the finrank of the range of `mulVecLin M`.

This is the rank-sensitive exact kernel cardinality theorem. -/
theorem card_mulVec_kernel_exact
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      = q ^ (p - Module.finrank (ZMod q) (Matrix.mulVecLin M).range) := by
  rw [Fintype.card_congr (subtypeMulVecZeroEquivKer M)]
  rw [card_mulVecLin_ker_exact M]
  congr 1
  exact finrank_ker_mulVecLin M

/-- General cardinality theorem for kernels of linear maps over `ZMod q`.
For any linear map `φ : V →ₗ[ZMod q] W` where `V` is finite-dimensional,
the cardinality of `ker(φ)` is `q ^ finrank(ker(φ))`. -/
theorem card_linearMap_ker_zmod
    {V W : Type*} [AddCommGroup V] [Module (ZMod q) V]
    [AddCommGroup W] [Module (ZMod q) W]
    [Fintype V] [FiniteDimensional (ZMod q) V]
    (φ : V →ₗ[ZMod q] W) :
    Fintype.card (LinearMap.ker φ) = q ^ Module.finrank (ZMod q) (LinearMap.ker φ) := by
  rw [Module.card_eq_pow_finrank (K := ZMod q), ZMod.card q]

/-- The number of solutions to the affine equation `M.mulVec r = b` is `q^(p - rank(M))`
when `b` is in the range of `M`, and `0` otherwise. -/
theorem card_mulVec_affine_exact
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (b : Fin m → ZMod q) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = b}
      = if b ∈ LinearMap.range (Matrix.mulVecLin M)
        then q ^ (p - Module.finrank (ZMod q) (Matrix.mulVecLin M).range)
        else 0 := by
  split
  case isTrue hb =>
    obtain ⟨r₀, hr₀⟩ := hb
    have equiv : {r : Fin p → ZMod q // M.mulVec r = b} ≃
        LinearMap.ker (Matrix.mulVecLin M) := by
      refine ⟨fun ⟨r, hr⟩ => ⟨r - r₀, ?_⟩, fun ⟨v, hv⟩ => ⟨v + r₀, ?_⟩, ?_, ?_⟩
      · simp [LinearMap.mem_ker, map_sub, hr, hr₀]
      · simp [LinearMap.mem_ker] at hv
        simp only [Matrix.mulVec_add, hv, zero_add, Matrix.mulVecLin_apply] at hr₀ ⊢
        exact hr₀
      · intro ⟨r, hr⟩; simp
      · intro ⟨v, hv⟩; simp
    rw [Fintype.card_congr equiv, card_mulVecLin_ker_exact, finrank_ker_mulVecLin]
  case isFalse hb =>
    rw [Fintype.card_eq_zero_iff]
    exact ⟨fun ⟨r, hr⟩ => hb ⟨r, hr⟩⟩

end KernelCardinality