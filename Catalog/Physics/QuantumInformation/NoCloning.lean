/-
  # No-Cloning Theorem for Quantum States

  This file formalizes the quantum no-cloning theorem, one of the foundational
  impossibility results in quantum information theory.

  ## Mathematical Content

  The no-cloning theorem states that there is no unitary operation that can clone
  an arbitrary unknown quantum state. More precisely, if U is a unitary on H ⊗ H
  and U(ψ ⊗ b) = ψ ⊗ ψ for two distinct non-orthogonal unit vectors ψ, φ with
  the same blank state b, then we reach a contradiction.

  The proof follows from inner product preservation:
  - Unitarity gives: ⟪U(ψ⊗b), U(φ⊗b)⟫ = ⟪ψ⊗b, φ⊗b⟫ = ⟪ψ,φ⟫
  - Cloning gives: ⟪ψ⊗ψ, φ⊗φ⟫ = ⟪ψ,φ⟫²
  - Therefore ⟪ψ,φ⟫ = ⟪ψ,φ⟫², forcing ⟪ψ,φ⟫ ∈ {0, 1}
  - This contradicts ψ ≠ φ (rules out 1) and ⟪ψ,φ⟫ ≠ 0 (rules out 0)
-/
import Mathlib
import Physics.QuantumInformation.Defs

namespace QuantumInformation

open Complex

/-! ## Core algebraic lemma -/

/-- If z = z² in ℂ, then z = 0 or z = 1. This is the algebraic heart of no-cloning. -/
theorem complex_sq_eq_self {z : ℂ} (h : z = z ^ 2) : z = 0 ∨ z = 1 := by
  grind

/-- Variant: if z = z² and z ≠ 0, then z = 1. -/
theorem complex_sq_eq_self_of_ne_zero {z : ℂ} (h : z = z ^ 2) (hz : z ≠ 0) : z = 1 := by
  exact mul_left_cancel₀ hz <| by linear_combination -h

/-! ## Abstract no-cloning theorem

We formalize no-cloning using abstract inner product spaces.
The tensor product structure is captured through hypotheses about how inner products
of the input and output states relate to each other. -/

/-- **No-cloning overlap constraint**: If a linear isometry (unitary) maps states
x and y to states x' and y', and the inner products satisfy the tensor product
factorization properties (input inner product = z, output inner product = z²),
then z = z². -/
theorem no_cloning_overlap_constraint
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (U : H →ₗᵢ[ℂ] H)
    (x y x' y' : H)
    (hUx : U x = x') (hUy : U y = y')
    {z : ℂ}
    (h_input : @inner ℂ H _ x y = z)
    (h_output : @inner ℂ H _ x' y' = z ^ 2)
    : z = z ^ 2 := by
  have h_inner_preserved : ∀ (u v : H), inner ℂ (U u) (U v) = inner ℂ u v := by
    simp +zetaDelta at *
  grind

/-- **No-cloning theorem**: A unitary cannot clone two distinct non-orthogonal states.

Given a linear isometry U on an inner product space, if U maps x to x' and y to y',
and the inner product of the inputs equals z while the inner product of the outputs
equals z², and z is neither 0 nor 1, then we have a contradiction. -/
theorem no_cloning
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (U : H →ₗᵢ[ℂ] H)
    (x y x' y' : H)
    (hUx : U x = x') (hUy : U y = y')
    {z : ℂ}
    (h_input : @inner ℂ H _ x y = z)
    (h_output : @inner ℂ H _ x' y' = z ^ 2)
    (hz_ne_zero : z ≠ 0)
    (hz_ne_one : z ≠ 1)
    : False := by
  have := no_cloning_overlap_constraint U x y x' y' hUx hUy h_input h_output
  exact hz_ne_one (complex_sq_eq_self_of_ne_zero this hz_ne_zero)

/-! ## Concrete Kronecker product formulation

We also provide a concrete version using Kronecker products of vectors,
which makes the tensor product structure explicit. We use `kronVec` from `Defs.lean`. -/

/-- Inner product of Kronecker products factors as a product of inner products.
This is the key tensor product identity: ⟪u₁⊗v₁, u₂⊗v₂⟫ = ⟪u₁,u₂⟫ · ⟪v₁,v₂⟫ -/
theorem inner_kronVec {m n : Type*} [Fintype m] [Fintype n]
    (u₁ u₂ : m → ℂ) (v₁ v₂ : n → ℂ) :
    ∑ p : m × n, starRingEnd ℂ (kronVec u₁ v₁ p) * kronVec u₂ v₂ p =
    (∑ i, starRingEnd ℂ (u₁ i) * u₂ i) *
    (∑ j, starRingEnd ℂ (v₁ j) * v₂ j) := by
  simp +decide only [kronVec, Finset.sum_mul, mul_assoc]
  simp +decide [mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul]
  exact Fintype.sum_prod_type _

/-- Norm squared of a Kronecker product equals the product of norm squares. -/
theorem normSq_kronVec {m n : Type*} [Fintype m] [Fintype n]
    (u : m → ℂ) (v : n → ℂ) :
    ∑ p : m × n, ‖kronVec u v p‖ ^ 2 =
    (∑ i, ‖u i‖ ^ 2) * (∑ j, ‖v j‖ ^ 2) := by
  unfold kronVec
  simp +decide only [norm_mul, mul_pow, Finset.sum_mul]
  simp +decide only [Finset.mul_sum _ _ _]
  exact Fintype.sum_prod_type _

/-- **No-cloning (concrete Kronecker form)**: If U preserves inner products (unitary)
and clones two states using the same blank, then the overlap satisfies z = z². -/
theorem no_cloning_kronecker
    {n : Type*} [Fintype n] [DecidableEq n]
    (ψ φ b : n → ℂ)
    (hb_norm : ∑ i, ‖b i‖ ^ 2 = 1)
    (U : (n × n → ℂ) → (n × n → ℂ))
    (hU_inner : ∀ x y : n × n → ℂ,
      ∑ p, starRingEnd ℂ (U x p) * U y p =
      ∑ p, starRingEnd ℂ (x p) * y p)
    (hcloneψ : U (kronVec ψ b) = kronVec ψ ψ)
    (hcloneφ : U (kronVec φ b) = kronVec φ φ) :
    (∑ i, starRingEnd ℂ (ψ i) * φ i) =
    (∑ i, starRingEnd ℂ (ψ i) * φ i) ^ 2 := by
  have := hU_inner (kronVec ψ b) (kronVec φ b)
  simp_all +decide [inner_kronVec]
  simp_all +decide [Complex.ext_iff, sq]
  simp_all +decide [Complex.normSq, Complex.norm_def]
  simp_all +decide [Real.mul_self_sqrt (add_nonneg (mul_self_nonneg _) (mul_self_nonneg _))]
  cases this <;> simp_all +decide [mul_comm]

/-- **No-cloning impossibility (concrete)**: Cloning distinct non-orthogonal states
with a unitary is impossible. -/
theorem no_cloning_impossible_kronecker
    {n : Type*} [Fintype n] [DecidableEq n]
    (ψ φ b : n → ℂ)
    (hb_norm : ∑ i, ‖b i‖ ^ 2 = 1)
    (U : (n × n → ℂ) → (n × n → ℂ))
    (hU_inner : ∀ x y : n × n → ℂ,
      ∑ p, starRingEnd ℂ (U x p) * U y p =
      ∑ p, starRingEnd ℂ (x p) * y p)
    (hcloneψ : U (kronVec ψ b) = kronVec ψ ψ)
    (hcloneφ : U (kronVec φ b) = kronVec φ φ)
    (hnonorth : ∑ i, starRingEnd ℂ (ψ i) * φ i ≠ 0)
    (hdistinct : ∑ i, starRingEnd ℂ (ψ i) * φ i ≠ 1) :
    False := by
  exact absurd (no_cloning_kronecker ψ φ b hb_norm U hU_inner hcloneψ hcloneφ)
    (fun h => hdistinct ((complex_sq_eq_self h).resolve_left hnonorth))

end QuantumInformation