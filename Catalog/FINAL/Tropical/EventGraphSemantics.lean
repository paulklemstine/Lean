/-
# Compositional Tropical Semantics for Event Graphs

This file formalizes a compositional theory of timed event-graph systems
using max-plus (tropical) matrix algebra. The key results are:

1. **Series composition** of event graphs corresponds to tropical matrix
   multiplication (max-plus matrix product).
2. **Parallel composition** with disjoint interfaces corresponds to tropical
   block-diagonal matrix sum.
3. **Parallel composition** with shared interfaces corresponds to pointwise
   tropical maximum.
4. **Throughput/cycle-time bounds** compose modularly: series adds bounds,
   parallel takes the max.

## Mathematical Framework

We work with event graphs whose transfer semantics are captured by matrices
over `ℝ`. The tropical semiring operations are:
- Tropical addition: `max`
- Tropical multiplication: `+` (classical addition)

The transfer matrix `M(G)_{i,k}` of an event graph `G` with input interface `ι`
and output interface `κ` records the maximum-weight path from each input to
each output, representing the longest delay / critical path timing.

## Key Definitions

- `tropMaxPlus A B`: max-plus matrix multiplication
- `EventGraph ι κ`: event graph with typed interfaces
- `transfer G`: the transfer matrix of `G`
- `series G₁ G₂`: series composition
- `parallel G₁ G₂`: parallel (disjoint) composition
- `parallelShared G₁ G₂`: parallel (shared-interface) composition
- `CycleTimeBound G c`: predicate asserting cycle-time ≤ c
-/
import Mathlib

open Matrix Finset

noncomputable section

namespace TropicalEventGraph

/-! ## Max-Plus Matrix Operations -/

/-- Max-plus (tropical) matrix multiplication.
    `(A ⊗ B)_{i,k} = max_j (A_{i,j} + B_{j,k})`.
    This is the fundamental operation connecting series composition
    of event graphs to algebraic matrix operations. -/
def tropMaxPlus {ι κ μ : Type} [Fintype κ] [DecidableEq κ] [Nonempty κ]
    (A : Matrix ι κ ℝ) (B : Matrix κ μ ℝ) : Matrix ι μ ℝ :=
  fun i k => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + B j k)

/-- Tropical block-diagonal matrix: places `A` and `B` on diagonal blocks
    with `0` off-diagonal entries. -/
def tropBlockDiag {α₁ β₁ α₂ β₂ : Type}
    (A : Matrix α₁ β₁ ℝ) (B : Matrix α₂ β₂ ℝ) : Matrix (α₁ ⊕ α₂) (β₁ ⊕ β₂) ℝ :=
  fun i k => match i, k with
    | .inl a, .inl b => A a b
    | .inr a, .inr b => B a b
    | _, _ => 0

/-- Tropical pointwise maximum (tropical addition of matrices).
    Used for shared-interface parallel composition. -/
def tropPointwiseMax {ι κ : Type}
    (A B : Matrix ι κ ℝ) : Matrix ι κ ℝ :=
  fun i k => max (A i k) (B i k)

/-! ## Event Graph Structure -/

/-- An event graph with input interface `ι` and output interface `κ`.
    The transfer matrix records the maximum-weight (longest/critical) path
    from each input to each output.

    This is a "black-box" representation: we abstract away the internal
    structure and retain only the input-output transfer behavior. -/
structure EventGraph (ι κ : Type) where
  /-- The transfer matrix: `mat i k` is the max-weight path from input `i`
      to output `k`. -/
  mat : Matrix ι κ ℝ

/-! ## Transfer Semantics -/

/-- Extract the transfer matrix from an event graph. -/
def transfer {ι κ : Type} (G : EventGraph ι κ) : Matrix ι κ ℝ := G.mat

/-! ## Composition Operations -/

/-- Series composition: connect output of `G₁` to input of `G₂`.
    The resulting transfer matrix is the max-plus product of the two
    transfer matrices. -/
def series {ι κ μ : Type} [Fintype κ] [DecidableEq κ] [Nonempty κ]
    (G₁ : EventGraph ι κ) (G₂ : EventGraph κ μ) : EventGraph ι μ :=
  ⟨tropMaxPlus G₁.mat G₂.mat⟩

/-- Parallel composition with disjoint interfaces. -/
def parallel {α₁ β₁ α₂ β₂ : Type}
    (G₁ : EventGraph α₁ β₁) (G₂ : EventGraph α₂ β₂) : EventGraph (α₁ ⊕ α₂) (β₁ ⊕ β₂) :=
  ⟨tropBlockDiag G₁.mat G₂.mat⟩

/-- Parallel composition with shared interfaces. -/
def parallelShared {ι κ : Type}
    (G₁ G₂ : EventGraph ι κ) : EventGraph ι κ :=
  ⟨tropPointwiseMax G₁.mat G₂.mat⟩

/-! ## Theorem 1: Series Composition = Tropical Matrix Multiplication -/

/-- **Series composition theorem**: The transfer matrix of the series
    composition equals the max-plus product of the transfer matrices. -/
theorem transfer_series
    {ι κ μ : Type} [Fintype κ] [DecidableEq κ] [Nonempty κ]
    (G₁ : EventGraph ι κ) (G₂ : EventGraph κ μ) :
    transfer (series G₁ G₂) = tropMaxPlus (transfer G₁) (transfer G₂) := by
  rfl

/-! ## Theorem 2a: Parallel (Disjoint) = Block Diagonal -/

/-- **Parallel composition theorem (disjoint interfaces)**: The transfer
    matrix of the parallel composition equals the block-diagonal assembly. -/
theorem transfer_parallel
    {α₁ β₁ α₂ β₂ : Type}
    (G₁ : EventGraph α₁ β₁) (G₂ : EventGraph α₂ β₂) :
    transfer (parallel G₁ G₂) = tropBlockDiag (transfer G₁) (transfer G₂) := by
  rfl

/-! ## Theorem 2b: Parallel (Shared) = Pointwise Max -/

/-- **Parallel composition theorem (shared interfaces)**: The transfer
    of shared parallel composition is the pointwise max of the transfers. -/
theorem transfer_parallel_shared
    {ι κ : Type}
    (G₁ G₂ : EventGraph ι κ) :
    transfer (parallelShared G₁ G₂) = tropPointwiseMax (transfer G₁) (transfer G₂) := by
  rfl

/-! ## Cycle-Time Bounds -/

/-- A cycle-time bound asserts that every entry of the transfer matrix
    is at most `c`. This captures that no critical path exceeds `c`. -/
def CycleTimeBound {ι κ : Type} (G : EventGraph ι κ) (c : ℝ) : Prop :=
  ∀ i k, G.mat i k ≤ c

/-! ## Theorem 3a: Series Throughput Certification -/

/-
**Series throughput theorem**: If `G₁` has cycle-time bound `c₁` and
    `G₂` has cycle-time bound `c₂`, then their series composition has
    cycle-time bound `c₁ + c₂`.
-/
theorem cycleTime_series
    {ι κ μ : Type} [Fintype κ] [DecidableEq κ] [Nonempty κ]
    (G₁ : EventGraph ι κ) (G₂ : EventGraph κ μ) {c₁ c₂ : ℝ}
    (h₁ : CycleTimeBound G₁ c₁) (h₂ : CycleTimeBound G₂ c₂) :
    CycleTimeBound (series G₁ G₂) (c₁ + c₂) := by
  intro i k
  simp only [series, tropMaxPlus]
  exact Finset.sup'_le _ _ fun j _ => add_le_add (h₁ i j) (h₂ j k)

/-! ## Theorem 3b: Parallel (Disjoint) Throughput Certification -/

/-
**Parallel throughput theorem (disjoint)**: Cycle-time bound is max.
    Requires `0 ≤ c₁` and `0 ≤ c₂` because off-diagonal (cross-system)
    entries are `0`, representing the absence of paths.
-/
theorem cycleTime_parallel
    {α₁ β₁ α₂ β₂ : Type}
    (G₁ : EventGraph α₁ β₁) (G₂ : EventGraph α₂ β₂) {c₁ c₂ : ℝ}
    (h₁ : CycleTimeBound G₁ c₁) (h₂ : CycleTimeBound G₂ c₂)
    (hc₁ : 0 ≤ c₁) (hc₂ : 0 ≤ c₂) :
    CycleTimeBound (parallel G₁ G₂) (max c₁ c₂) := by
  -- Case 2: When $i$ and $k$ are both in $α₂$ and $β₂$.
  unfold CycleTimeBound at *; simp at *; (
  exact ⟨ fun i => ⟨ fun j => Or.inl <| h₁ i j, fun j => Or.inl <| by unfold parallel; aesop ⟩, fun j => ⟨ fun i => Or.inr <| by unfold parallel; aesop, fun j' => Or.inr <| h₂ j j' ⟩ ⟩);

/-! ## Theorem 3c: Shared-Parallel Throughput Certification -/

/-
**Shared-parallel throughput theorem**: Cycle-time bound is max.
-/
theorem cycleTime_parallel_shared
    {ι κ : Type}
    (G₁ G₂ : EventGraph ι κ) {c₁ c₂ : ℝ}
    (h₁ : CycleTimeBound G₁ c₁) (h₂ : CycleTimeBound G₂ c₂) :
    CycleTimeBound (parallelShared G₁ G₂) (max c₁ c₂) := by
  exact fun i k => le_trans ( max_le_max ( h₁ i k ) ( h₂ i k ) ) ( max_le_max le_rfl le_rfl )

/-! ## Associativity of Max-Plus Matrix Multiplication -/

/-
Max-plus matrix multiplication is associative.
-/
theorem tropMaxPlus_assoc
    {ι κ μ ν : Type} [Fintype κ] [Fintype μ]
    [DecidableEq κ] [DecidableEq μ]
    [Nonempty κ] [Nonempty μ]
    (A : Matrix ι κ ℝ) (B : Matrix κ μ ℝ) (C : Matrix μ ν ℝ) :
    tropMaxPlus (tropMaxPlus A B) C = tropMaxPlus A (tropMaxPlus B C) := by
  -- By definition of tropMaxPlus, we know that for any i and k, the entry of the resulting matrix at (i, k) is the supremum over μ of (supremum over κ of (A i κ + B κ μ)) + C μ k.
  ext i k; simp [tropMaxPlus];
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) ( Finset.sup'_le _ _ _ );
  · intro b hb;
    obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun j => A i j + B j b );
    refine' le_trans _ ( Finset.le_sup' _ ( Finset.mem_univ j ) );
    linarith [ Finset.le_sup' ( fun j_1 => B j j_1 + C j_1 k ) hb ];
  · intro b hb;
    obtain ⟨ c, hc ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun j => B b j + C j k );
    refine' le_trans _ ( Finset.le_sup' _ ( Finset.mem_univ c ) );
    linarith [ show A i b ≤ Finset.univ.sup' ( Finset.univ_nonempty ) ( fun j => A i j + B j c ) - B b c from by linarith [ Finset.le_sup' ( fun j => A i j + B j c ) ( Finset.mem_univ b ) ] ]

/-- Series composition of event graphs is associative. -/
theorem series_assoc
    {ι κ μ ν : Type} [Fintype κ] [Fintype μ]
    [DecidableEq κ] [DecidableEq μ]
    [Nonempty κ] [Nonempty μ]
    (G₁ : EventGraph ι κ) (G₂ : EventGraph κ μ) (G₃ : EventGraph μ ν) :
    transfer (series (series G₁ G₂) G₃) = transfer (series G₁ (series G₂ G₃)) := by
  simp only [transfer_series]
  exact tropMaxPlus_assoc G₁.mat G₂.mat G₃.mat

/-! ## Commutativity and Associativity of Shared Parallel -/

/-- Shared-interface parallel composition is commutative. -/
theorem parallelShared_comm
    {ι κ : Type}
    (G₁ G₂ : EventGraph ι κ) :
    transfer (parallelShared G₁ G₂) = transfer (parallelShared G₂ G₁) := by
  ext i k
  simp [transfer, parallelShared, tropPointwiseMax, max_comm]

/-- Shared-interface parallel composition is associative. -/
theorem parallelShared_assoc
    {ι κ : Type}
    (G₁ G₂ G₃ : EventGraph ι κ) :
    transfer (parallelShared (parallelShared G₁ G₂) G₃) =
    transfer (parallelShared G₁ (parallelShared G₂ G₃)) := by
  ext i k
  simp [transfer, parallelShared, tropPointwiseMax, max_assoc]

/-! ## Concrete Examples -/

/-
A simple 2-stage pipeline: two scalar event graphs with delays 3 and 5.
    Series composition yields delay 8 = 3 + 5 (tropical multiplication).
-/
example : ∀ (i k : Fin 1), transfer (series
    (⟨fun (_ : Fin 1) (_ : Fin 1) => (3 : ℝ)⟩ : EventGraph (Fin 1) (Fin 1))
    (⟨fun (_ : Fin 1) (_ : Fin 1) => (5 : ℝ)⟩ : EventGraph (Fin 1) (Fin 1))) i k
    = (8 : ℝ) := by
  intro i k; fin_cases i; fin_cases k; norm_num [ transfer, series, tropMaxPlus ] ;

/-
Fork-join: two parallel paths with delays 3 and 5.
    Shared parallel composition yields delay 5 = max(3, 5).
-/
example : ∀ (i k : Fin 1), transfer (parallelShared
    (⟨fun (_ : Fin 1) (_ : Fin 1) => (3 : ℝ)⟩ : EventGraph (Fin 1) (Fin 1))
    (⟨fun (_ : Fin 1) (_ : Fin 1) => (5 : ℝ)⟩ : EventGraph (Fin 1) (Fin 1))) i k
    = (5 : ℝ) := by
  norm_num [ Fin.eq_zero, transfer, parallelShared, tropPointwiseMax ]

/-- A 2×2 pipeline network: two 2-input/2-output stages composed in series.
    Demonstrates that max-plus matrix multiplication computes critical paths
    through a multi-port pipeline. -/
example : let G₁ : EventGraph (Fin 2) (Fin 2) :=
    ⟨!![1, 3; 2, 4]⟩
  let G₂ : EventGraph (Fin 2) (Fin 2) :=
    ⟨!![5, 6; 7, 8]⟩
  ∀ i k, transfer (series G₁ G₂) i k =
    tropMaxPlus (transfer G₁) (transfer G₂) i k := by
  intro G₁ G₂ i k
  rfl

end TropicalEventGraph