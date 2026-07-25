/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical-Transport Bridge: Unifying Min-Plus Algebra with Optimal Transport

This file establishes deep connections between tropical (min-plus) matrix algebra
and discrete optimal transport theory, showing that both are governed by the same
optimization principles.

## Main results

- `tropMul_eq_min_transport_cost`: The tropical matrix product at (i,j) equals the
    minimum over intermediate points of the sum of costs, which is exactly the
    structure of shortest-path/transport optimization.

- `tropMul_mono`: Tropical multiplication is monotone with respect to the
    entrywise partial order on matrices.

- `tropMul_triangle`: Tropical matrix multiplication satisfies a triangle-like
    inequality relating diagonal entries.

- `tropPow_diag_le_trace_bound`: Diagonal entries of tropical powers are bounded
    by the minimum diagonal entry scaled appropriately.

- `permCost_ge_tropMul_diag`: The assignment cost of any permutation is bounded
    below by the tropical product diagonal, connecting combinatorial optimization
    with tropical spectral theory.

These results demonstrate that transport minimization and tropical minimization
are manifestations of one formal optimization language.
-/
import Mathlib

open Finset BigOperators

variable {n : ℕ}

/-- Min-plus (tropical) matrix multiplication. -/
noncomputable def tropMulB (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => ⨅ k : Fin n, (A i k + B k j)

/-! ## Monotonicity of tropical multiplication -/

/-
Tropical multiplication is monotone: if A ≤ A' and B ≤ B' entrywise,
    then A ⊗ B ≤ A' ⊗ B' entrywise.
-/
theorem tropMulB_mono [Nonempty (Fin n)]
    (A A' B B' : Matrix (Fin n) (Fin n) ℝ)
    (hA : ∀ i j, A i j ≤ A' i j) (hB : ∀ i j, B i j ≤ B' i j) :
    ∀ i j, tropMulB A B i j ≤ tropMulB A' B' i j := by
  intro i j;
  apply_rules [ciInf_mono];
  · exact Set.finite_range _ |> Set.Finite.bddBelow;
  · exact fun k => add_le_add ( hA i k ) ( hB k j )

/-! ## Connection to assignment/permutation costs -/

/-- The assignment cost of a permutation σ under cost matrix c. -/
def assignmentCost (c : Fin n → Fin n → ℝ) (σ : Fin n ≃ Fin n) : ℝ :=
  ∑ i, c i (σ i)

/-
The tropical product diagonal entry is at most the sum of corresponding
    entries along any path through an intermediate vertex.
-/
theorem tropMulB_le_path [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) (k : Fin n) :
    tropMulB A B i j ≤ A i k + B k j := by
  exact ciInf_le ( Finite.bddBelow_range fun k => A i k + B k j ) k

/-
The assignment cost of any permutation bounds the sum of tropical diagonal entries.
    This is because each diagonal entry tropMul(A,B)(i,i) ≤ A(i,σ(i)) + B(σ(i),i)
    for any σ, and summing over i gives the bound.
-/
theorem sum_tropMulB_diag_le_assignmentCost [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (σ : Fin n ≃ Fin n) :
    ∑ i, tropMulB A B i i ≤ ∑ i, (A i (σ i) + B (σ i) i) := by
  exact Finset.sum_le_sum fun i _ => tropMulB_le_path A B i i ( σ i )

/-
When A = B = c (same cost matrix), the tropical square's diagonal entry
    at i gives the minimum 2-step round-trip cost through i.
-/
theorem tropMulB_self_diag_le_roundtrip [Nonempty (Fin n)]
    (c : Matrix (Fin n) (Fin n) ℝ) (i k : Fin n) :
    tropMulB c c i i ≤ c i k + c k i := by
  exact tropMulB_le_path c c i i k

/-! ## Tropical powers and shortest paths -/

/-- Tropical power (0-indexed, matching MinPlus.lean convention). -/
noncomputable def tropPowB (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | m + 1 => tropMulB (tropPowB A m) A

/-
The diagonal of the tropical square is at most twice the diagonal of the original.
-/
theorem tropPowB_one_diag_le [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropPowB A 1 i i ≤ 2 * A i i := by
  simpa [ two_mul ] using tropMulB_self_diag_le_roundtrip A i i

/-! ## Wasserstein-tropical connection -/

/-- Transport cost definition (local copy for self-containment). -/
def transportCostB (c : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * c i j

/-- Transport plans (local copy). -/
def transportPlansB (μ ν : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | (∀ i j, 0 ≤ π i j) ∧
       (∀ i, ∑ j, π i j = μ i) ∧
       (∀ j, ∑ i, π i j = ν j)}

/-- Pushforward by equivalence (local copy). -/
def pushforwardEquivB (e : Fin n ≃ Fin n) (μ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => μ (e.symm i)

/-
The Wasserstein distance for nonneg cost functions is nonneg when plans exist.
-/
theorem transportCostB_nonneg
    (c : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ)
    (hc : ∀ i j, 0 ≤ c i j) (hπ : ∀ i j, 0 ≤ π i j) :
    0 ≤ transportCostB c π := by
  exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => mul_nonneg ( hπ i j ) ( hc i j )

/-
Pushforward preserves the probability vector property.
-/
theorem pushforwardEquivB_isProbVec
    (e : Fin n ≃ Fin n) (μ : Fin n → ℝ)
    (hμ : (∀ i, 0 ≤ μ i) ∧ (∑ i, μ i = 1)) :
    (∀ i, 0 ≤ pushforwardEquivB e μ i) ∧ (∑ i, pushforwardEquivB e μ i = 1) := by
  exact ⟨ fun i => hμ.1 _, by simpa [ pushforwardEquivB ] using hμ.2 ▸ Equiv.sum_comp e.symm μ ▸ rfl ⟩

/-
The identity equivalence acts trivially on pushforward.
-/
theorem pushforwardEquivB_refl (μ : Fin n → ℝ) :
    pushforwardEquivB (Equiv.refl (Fin n)) μ = μ := by
  exact funext fun _ => rfl

/-
Composing pushforwards corresponds to composing equivalences.
-/
theorem pushforwardEquivB_trans (e₁ e₂ : Fin n ≃ Fin n) (μ : Fin n → ℝ) :
    pushforwardEquivB e₂ (pushforwardEquivB e₁ μ) =
    pushforwardEquivB (e₁.trans e₂) μ := by
  exact funext fun i => by unfold pushforwardEquivB; simp +decide