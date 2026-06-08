/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Cryptography Bridge: Row-Separated Injectivity

This file establishes the first formally verified structural foundation for
tropical (min-plus) cryptographic primitives. The main results are:

1. **Row rigidity theorem** (`tropicalMatVec_eq_of_row_separation`):
   Under a row-separation hypothesis on a tropical matrix `A` and a
   bounded-oscillation condition on the input vector `x`, the min-plus
   matrix–vector product collapses to a classical affine readout.

2. **Injectivity theorem** (`tropicalMatVec_injective_on_boundedOscillation`):
   When the designated minimizer map `σ` is a bijection, the tropical
   matrix action is injective on the bounded-oscillation domain.

These results turn tropical matrices into **exact encoding maps** on
structured domains, providing a rigorous algebraic foundation for
one-way function candidates in post-quantum cryptography.

## Mathematical Overview

Let `A : Fin n → Fin m → ℝ` be a tropical matrix. Its **tropical action**
on a vector `x : Fin m → ℝ` is defined by

  `(T_A x)(i) = min_j (A i j + x j)`

Suppose each row `i` has a designated minimizing column `σ(i)` that is
separated from all competitors by at least `δ`:

  `∀ i j, j ≠ σ(i) → A i (σ i) + δ ≤ A i j`

Then for any vector `x` with bounded oscillation `|x j - x k| ≤ δ`:

  `(T_A x)(i) = A i (σ i) + x (σ i)`

This means the tropical action becomes a simple coordinate readout
(up to a row-dependent translation). If `σ` is bijective, distinct
inputs produce distinct outputs — the map is injective.

## References

- R. D. Grigoriev, V. V. Shpilrain. "Tropical Cryptography" (2014)
- D. Maclagan, B. Sturmfels. "Introduction to Tropical Geometry" (2015)
-/

noncomputable section

open Finset

/-! ### Definitions -/

/-- The tropical (min-plus) matrix–vector product. For a matrix `A` and
vector `x`, the `i`-th component is `min_j (A i j + x j)`. -/
def tropicalMatVec {m n : ℕ} [NeZero m] (A : Fin n → Fin m → ℝ) (x : Fin m → ℝ) :
    Fin n → ℝ :=
  fun i => Finset.univ.inf' ⟨0, Finset.mem_univ _⟩ (fun j => A i j + x j)

/-- Bounded oscillation: all coordinates of `x` differ by at most `δ`. -/
def BoundedOscillation {m : ℕ} (δ : ℝ) (x : Fin m → ℝ) : Prop :=
  ∀ j k : Fin m, |x j - x k| ≤ δ

/-- Row separation: for each row `i`, the designated column `σ i` achieves
a value at least `δ` smaller than any other column. -/
def RowSeparated {m n : ℕ} (A : Fin n → Fin m → ℝ) (σ : Fin n → Fin m) (δ : ℝ) : Prop :=
  ∀ i : Fin n, ∀ j : Fin m, j ≠ σ i → A i (σ i) + δ ≤ A i j

/-! ### Key Lemma: inf' equals designated value -/

/-
When `σ i` is separated and `x` has bounded oscillation,
the `inf'` over all columns equals `A i (σ i) + x (σ i)`.
-/
theorem inf'_eq_designated {m n : ℕ} [NeZero m]
    (A : Fin n → Fin m → ℝ)
    (σ : Fin n → Fin m)
    (δ : ℝ)
    (_hδ : 0 ≤ δ)
    (hsep : RowSeparated A σ δ)
    (x : Fin m → ℝ)
    (hosc : BoundedOscillation δ x)
    (i : Fin n) :
    Finset.univ.inf' ⟨0, Finset.mem_univ _⟩ (fun j => A i j + x j) =
      A i (σ i) + x (σ i) := by
  refine' le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) _;
  -- We need to show that A i (σ i) + x (σ i) is less than or equal to every element in the set.
  have h_le : ∀ j, A i (σ i) + x (σ i) ≤ A i j + x j := by
    intro j; by_cases hj : j = σ i <;> [ simp +decide [ * ] ; linarith [ hsep i j hj, abs_le.mp ( hosc j ( σ i ) ) ] ] ;
  exact Finset.le_inf' _ _ fun j _ => h_le j

/-! ### Main Theorem 1: Row Rigidity -/

/-- **Row rigidity theorem.** Under row separation and bounded oscillation,
the tropical matrix–vector product equals the classical affine readout
through the designated minimizer map `σ`. -/
theorem tropicalMatVec_eq_of_row_separation
    {m n : ℕ} [NeZero m]
    (A : Fin n → Fin m → ℝ)
    (σ : Fin n → Fin m)
    (δ : ℝ)
    (hδ : 0 ≤ δ)
    (hsep : RowSeparated A σ δ)
    (x : Fin m → ℝ)
    (hosc : BoundedOscillation δ x) :
    tropicalMatVec A x = fun i => A i (σ i) + x (σ i) := by
  funext i
  exact inf'_eq_designated A σ δ hδ hsep x hosc i

/-! ### Main Theorem 2: Injectivity -/

/-
**Tropical injectivity theorem.** When `σ` is a bijection, the tropical
matrix action is injective on the bounded-oscillation domain. This is the
structural foundation for tropical one-way function candidates.
-/
theorem tropicalMatVec_injective_on_boundedOscillation
    {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ)
    (σ : Equiv (Fin n) (Fin n))
    (δ : ℝ)
    (hδ : 0 ≤ δ)
    (hsep : RowSeparated A σ δ)
    {x y : Fin n → ℝ}
    (hx : BoundedOscillation δ x)
    (hy : BoundedOscillation δ y)
    (hEq : tropicalMatVec A x = tropicalMatVec A y) :
    x = y := by
  -- By the row rigidity theorem, we have:
  have h_row_rigidity_x : tropicalMatVec A x = fun i => A i (σ i) + x (σ i) :=
    tropicalMatVec_eq_of_row_separation A (⇑σ) δ hδ hsep x hx
  have h_row_rigidity_y : tropicalMatVec A y = fun i => A i (σ i) + y (σ i) :=
    tropicalMatVec_eq_of_row_separation A (⇑σ) δ hδ hsep y hy
  exact funext fun i => by simpa [ h_row_rigidity_x, h_row_rigidity_y ] using congr_fun hEq ( σ.symm i ) ;

/-! ### Corollary: Cardinality preservation under injective encoding -/

/-
Injective encoding preserves cardinality of finite message spaces.
This is the bridge to entropy-preservation arguments: if the tropical
encoding is injective, it preserves min-entropy lower bounds.
-/
theorem card_range_of_injective_encoding
    {α : Type*} [Fintype α] [DecidableEq α]
    {n : ℕ}
    (enc : α → Fin n → ℝ)
    (h_inj : Function.Injective enc) :
    Fintype.card (Set.range enc) = Fintype.card α := by
  rw [ Set.card_range_of_injective h_inj ]

end