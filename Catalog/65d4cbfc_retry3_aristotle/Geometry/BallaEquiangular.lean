/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Balla's bound `N ≤ d²` for equiangular line systems

A family of `N` unit vectors in `ℝ^d` is *equiangular* with common angle `α` when
`|⟨vᵢ, vⱼ⟩| = α` for all `i ≠ j`.  This file proves the classical bound that such a
family can have at most `d²` members.

The argument is the **tensor-square lift**.  To each unit vector `v ∈ ℝ^d` we
associate its tensor square `tsq v ∈ ℝ^{d²}`, whose coordinates are the products
`vₐ·v_b`.  The fundamental property is
`⟨tsq u, tsq v⟩ = ⟨u, v⟩²` (`tsq_inner`),
so the Gram matrix of the lifted vectors has constant diagonal `1` and constant
off-diagonal `α²`.

Rather than diagonalising this Gram matrix, we use the elementary **quadratic-form
identity** for constant-pattern matrices
`∑ᵢⱼ xᵢ Gᵢⱼ xⱼ = (1 - c)·∑ᵢ xᵢ² + c·(∑ᵢ xᵢ)²`  (`constPattern_quadForm`),
from which positive-definiteness (`constPattern_posDef`) is immediate when
`0 ≤ c < 1`.  Positive-definiteness of the Gram form forces the lifted vectors to be
linearly independent, and the rank bound in `ℝ^{d²}` yields `N ≤ d²`.
-/
import Mathlib

open scoped RealInnerProductSpace

namespace BallaEquiangular

variable {d : ℕ}

/-- The **tensor square** of a vector `v ∈ ℝ^d`: the vector in `ℝ^{d²}` whose
coordinate at `p` is `v_a · v_b`, where `(a, b)` is the pair corresponding to `p`
under `finProdFinEquiv`. -/
noncomputable def tsq (v : EuclideanSpace ℝ (Fin d)) : EuclideanSpace ℝ (Fin (d * d)) :=
  (WithLp.equiv 2 (Fin (d * d) → ℝ)).symm
    (fun p => v (finProdFinEquiv.symm p).1 * v (finProdFinEquiv.symm p).2)

@[simp] theorem tsq_apply (v : EuclideanSpace ℝ (Fin d)) (p : Fin (d * d)) :
    tsq v p = v (finProdFinEquiv.symm p).1 * v (finProdFinEquiv.symm p).2 := rfl

/-! ## Stage 1 — The tensor-square inner product -/

/-- **Tensor-square inner product.**  `⟨tsq u, tsq v⟩ = ⟨u, v⟩²`. -/
theorem tsq_inner (u v : EuclideanSpace ℝ (Fin d)) : ⟪tsq u, tsq v⟫ = ⟪u, v⟫ ^ 2 := by
  have hinner : ∀ (x y : EuclideanSpace ℝ (Fin d)), ⟪x, y⟫ = ∑ i, x i * y i := by
    intro x y; rw [PiLp.inner_apply]; simp [mul_comm]
  rw [PiLp.inner_apply]
  simp only [RCLike.inner_apply, conj_trivial]
  rw [hinner u v, sq, Finset.sum_mul_sum]
  rw [← finProdFinEquiv.sum_comp (fun p => (tsq v) p * (tsq u) p)]
  rw [Fintype.sum_prod_type]
  congr 1; ext a; congr 1; ext b
  show tsq v (finProdFinEquiv (a, b)) * tsq u (finProdFinEquiv (a, b)) = _
  simp only [tsq, WithLp.equiv_symm_apply, Equiv.symm_apply_apply]
  ring

/-- **Tensor-square norm.**  `‖tsq v‖² = ‖v‖⁴`. -/
theorem tsq_norm_sq (v : EuclideanSpace ℝ (Fin d)) : ‖tsq v‖ ^ 2 = ‖v‖ ^ 4 := by
  have h1 : ‖tsq v‖ ^ 2 = ⟪tsq v, tsq v⟫ := by rw [← real_inner_self_eq_norm_sq]
  have h2 : ‖v‖ ^ 2 = ⟪v, v⟫ := by rw [← real_inner_self_eq_norm_sq]
  rw [h1, tsq_inner, ← h2]; ring

/-! ## Stage 2 — Off-diagonal Gram entries -/

/-- **Off-diagonal Gram entry.**  If `u`, `v` make angle `α` (i.e. `|⟨u, v⟩| = α`),
then `⟨tsq u, tsq v⟩ = α²`.

The unit-norm hypotheses `hu`, `hv` are not needed for this particular identity
(squaring already removes the absolute value); they are retained because they are
part of the equiangular setting in which the lemma is used. -/
theorem eqang_tsq_gram_offdiag (u v : EuclideanSpace ℝ (Fin d)) {α : ℝ}
    (hu : ‖u‖ = 1) (hv : ‖v‖ = 1) (h : |⟪u, v⟫| = α) :
    ⟪tsq u, tsq v⟫ = α ^ 2 := by
  rw [tsq_inner, ← h, sq_abs]

/-! ## Stage 3 — Quadratic form of constant-pattern matrices -/

/-- **Quadratic form of a constant-pattern matrix.**  If `G` has diagonal `1` and
off-diagonal `c`, then for every `x`,
`∑ᵢⱼ xᵢ Gᵢⱼ xⱼ = (1 - c)·∑ᵢ xᵢ² + c·(∑ᵢ xᵢ)²`. -/
theorem constPattern_quadForm {N : ℕ} (G : Matrix (Fin N) (Fin N) ℝ) (c : ℝ)
    (hdiag : ∀ i, G i i = 1) (hoff : ∀ i j, i ≠ j → G i j = c) (x : Fin N → ℝ) :
    ∑ i, ∑ j, x i * G i j * x j = (1 - c) * ∑ i, (x i) ^ 2 + c * (∑ i, x i) ^ 2 := by
  have hG : ∀ i j, G i j = c + (if i = j then (1 - c) else 0) := by
    intro i j
    by_cases h : i = j
    · subst h; simp [hdiag i]
    · simp [h, hoff i j h]
  have step1 : ∑ i, ∑ j, x i * G i j * x j
      = ∑ i, ∑ j, (c * (x i * x j) + (if i = j then (1 - c) else 0) * (x i * x j)) := by
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    rw [hG i j]; ring
  rw [step1]
  simp only [Finset.sum_add_distrib]
  have A : ∑ i, ∑ j, c * (x i * x j) = c * (∑ i, x i) ^ 2 := by
    have h : ∑ i, ∑ j, c * (x i * x j) = c * ∑ i, ∑ j, x i * x j := by
      rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; rw [Finset.mul_sum]
    rw [h, sq, Finset.sum_mul_sum]
  have B : ∑ i, ∑ j, (if i = j then (1 - c) else 0) * (x i * x j) = (1 - c) * ∑ i, (x i) ^ 2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl; intro i _
    rw [Finset.sum_eq_single i]
    · simp [sq, mul_comm, mul_assoc]
    · intro j _ hj; simp [Ne.symm hj]
    · intro h; exact absurd (Finset.mem_univ i) h
  rw [A, B]; ring

/-- **Positive-definiteness of a constant-pattern matrix.**  If `G` has diagonal `1`
and off-diagonal `c` with `0 ≤ c < 1`, then its quadratic form is strictly positive
on nonzero vectors. -/
theorem constPattern_posDef {N : ℕ} (G : Matrix (Fin N) (Fin N) ℝ) (c : ℝ)
    (hdiag : ∀ i, G i i = 1) (hoff : ∀ i j, i ≠ j → G i j = c)
    (hc0 : 0 ≤ c) (hc1 : c < 1) (x : Fin N → ℝ) (hx : x ≠ 0) :
    0 < ∑ i, ∑ j, x i * G i j * x j := by
  rw [constPattern_quadForm G c hdiag hoff x]
  have hsum_pos : 0 < ∑ i, (x i) ^ 2 := by
    obtain ⟨i, hi⟩ := Function.ne_iff.1 hx
    apply Finset.sum_pos'
    · intro j _; positivity
    · exact ⟨i, Finset.mem_univ i, sq_pos_of_ne_zero hi⟩
  have h1 : 0 < (1 - c) * ∑ i, (x i) ^ 2 := mul_pos (by linarith) hsum_pos
  have h2 : 0 ≤ c * (∑ i, x i) ^ 2 := by positivity
  linarith

/-! ## Stage 4 — Balla's bound -/

/-- **Balla's bound.**  A family of `N` unit vectors in `ℝ^d` that is equiangular
with common angle `α` (so `|⟨vᵢ, vⱼ⟩| = α` for `i ≠ j`), with `0 ≤ α < 1`, satisfies
`N ≤ d²`. -/
theorem equiangular_card_le_sq {N : ℕ} (v : Fin N → EuclideanSpace ℝ (Fin d))
    {α : ℝ} (hunit : ∀ i, ‖v i‖ = 1) (hα0 : 0 ≤ α) (hα1 : α < 1)
    (hang : ∀ i j, i ≠ j → |⟪v i, v j⟫| = α) : N ≤ d * d := by
  set w : Fin N → EuclideanSpace ℝ (Fin (d * d)) := fun i => tsq (v i) with hw
  set G : Matrix (Fin N) (Fin N) ℝ := fun i j => ⟪w i, w j⟫ with hG
  have hdiag : ∀ i, G i i = 1 := by
    intro i
    have hvi : ⟪v i, v i⟫ = 1 := by rw [real_inner_self_eq_norm_sq, hunit i]; norm_num
    simp only [hG, hw, tsq_inner, hvi]; norm_num
  have hoff : ∀ i j, i ≠ j → G i j = α ^ 2 := by
    intro i j hij
    simp only [hG, hw, tsq_inner]
    rw [← hang i j hij, sq_abs]
  have hα2 : (0 : ℝ) ≤ α ^ 2 := by positivity
  have hα2' : α ^ 2 < 1 := by nlinarith
  have hli : LinearIndependent ℝ w := by
    rw [Fintype.linearIndependent_iff]
    intro g hg
    have hg0 : g = 0 := by
      by_contra hgne
      have hquad : ∑ i, ∑ j, g i * G i j * g j = 0 := by
        have expand : ⟪∑ i, g i • w i, ∑ j, g j • w j⟫ = ∑ i, ∑ j, g i * G i j * g j := by
          rw [sum_inner]
          apply Finset.sum_congr rfl; intro i _
          rw [inner_sum]
          apply Finset.sum_congr rfl; intro j _
          rw [real_inner_smul_left, real_inner_smul_right]; ring
        rw [← expand, hg, inner_zero_left]
      have := constPattern_posDef G (α ^ 2) hdiag hoff hα2 hα2' g hgne
      linarith
    exact fun i => congrFun hg0 i
  have hcard := hli.fintype_card_le_finrank
  simpa [finrank_euclideanSpace_fin] using hcard

end BallaEquiangular