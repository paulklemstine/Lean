/-
# Tropical Rank-One Factorization Theorem

This file proves the fundamental structure theorem for tropical rank-one matrices:
a matrix over ℝ has all 2×2 tropical minors vanishing (i.e., satisfies
  A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁
for all index pairs) if and only if it is additively separable, meaning
there exist potentials u : Fin n → ℝ and v : Fin m → ℝ with A i j = u i + v j.

This is the additive (tropical) analogue of the classical fact that a matrix has
rank ≤ 1 iff all 2×2 minors vanish. It provides the algebraic backbone for
tropical matrix decomposition, tropical latent-variable models, and low-complexity
certificates in neural network and representation-theoretic settings.

## Main results

* `all_tropical_2x2_minors_vanish_of_additive_separable` — converse direction
* `tropical_rank_one_factorization_normalized` — explicit construction of u, v
* `additive_separable_of_all_tropical_2x2_minors_vanish` — forward direction
* `tropical_rank_one_iff_additive_separable` — the full equivalence
* `additive_separable_gauge_uniqueness` — uniqueness of factorization up to gauge
-/

import Mathlib

open Finset

/-
The converse direction: any matrix of the form A i j = u i + v j satisfies
    all 2×2 tropical minor equalities.
-/
theorem all_tropical_2x2_minors_vanish_of_additive_separable
    {n m : ℕ}
    (A : Fin n → Fin m → ℝ)
    (hA : ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j) :
    ∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁ := by
  grind

/-
Normalized factorization: given base indices i₀, j₀, the explicit construction
    u(i) = A(i, j₀) and v(j) = A(i₀, j) - A(i₀, j₀) yields A(i,j) = u(i) + v(j)
    under the minor-vanishing hypothesis.
-/
theorem tropical_rank_one_factorization_normalized
    {n m : ℕ} (_hn : 0 < n) (_hm : 0 < m)
    (A : Fin n → Fin m → ℝ)
    (i₀ : Fin n) (j₀ : Fin m)
    (hminor : ∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) :
    let u : Fin n → ℝ := fun i => A i j₀
    let v : Fin m → ℝ := fun j => A i₀ j - A i₀ j₀
    ∀ i j, A i j = u i + v j := by
  exact fun i j => by linear_combination hminor i i₀ j j₀

/-
Forward direction: if all 2×2 tropical minors vanish, then A is additively separable.
-/
theorem additive_separable_of_all_tropical_2x2_minors_vanish
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ)
    (hminor : ∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) :
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j := by
  exact ⟨ fun i => A i ⟨ 0, hm ⟩, fun j => A ⟨ 0, hn ⟩ j - A ⟨ 0, hn ⟩ ⟨ 0, hm ⟩, fun i j => by linarith [ hminor i ⟨ 0, hn ⟩ j ⟨ 0, hm ⟩ ] ⟩

/-
**Tropical Rank-One Factorization Theorem**: A matrix A : Fin n → Fin m → ℝ
    satisfies the 2×2 tropical minor condition (additive Plücker relation)
    A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁ for all indices
    if and only if A is additively separable: A i j = u i + v j for some u, v.
-/
theorem tropical_rank_one_iff_additive_separable
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ) :
    (∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) ↔
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j := by
  -- Apply the theorems in the provided solution to split the iff statement.
  apply Iff.intro (additive_separable_of_all_tropical_2x2_minors_vanish hn hm A) (all_tropical_2x2_minors_vanish_of_additive_separable A)

/-
**Gauge Uniqueness**: If A i j = u i + v j = u' i + v' j, then u' and u differ
    by a constant c, and v' and v differ by -c.
-/
theorem additive_separable_gauge_uniqueness
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    {A : Fin n → Fin m → ℝ}
    {u u' : Fin n → ℝ} {v v' : Fin m → ℝ}
    (h : ∀ i j, A i j = u i + v j)
    (h' : ∀ i j, A i j = u' i + v' j) :
    ∃ c : ℝ, (∀ i, u' i = u i + c) ∧ (∀ j, v' j = v j - c) := by
  exact ⟨ u' ⟨ 0, hn ⟩ - u ⟨ 0, hn ⟩, fun i => by linarith [ h i ⟨ 0, hm ⟩, h' i ⟨ 0, hm ⟩, h ⟨ 0, hn ⟩ ⟨ 0, hm ⟩, h' ⟨ 0, hn ⟩ ⟨ 0, hm ⟩ ], fun j => by linarith [ h ⟨ 0, hn ⟩ j, h' ⟨ 0, hn ⟩ j, h ⟨ 0, hn ⟩ ⟨ 0, hm ⟩, h' ⟨ 0, hn ⟩ ⟨ 0, hm ⟩ ] ⟩

/-
Matrix version of the tropical rank-one factorization theorem using `Matrix`.
-/
theorem tropical_rank_one_iff_matrix_additive_separable
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Matrix (Fin n) (Fin m) ℝ) :
    (∀ i₁ i₂ j₁ j₂,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) ↔
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j := by
  convert tropical_rank_one_iff_additive_separable hn hm A