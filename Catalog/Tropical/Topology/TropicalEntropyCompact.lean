/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Mathlib

/-!
# Compact Tropical Entropy: From Finite Minima to Topological Infima

This file develops the theory of tropical partition functions and entropy on compact
topological spaces, generalizing the finite tropical entropy formalism by replacing
`Finset.inf'` with order-theoretic `sInf`.

## Main definitions

* `tropicalPartitionCompact X E`: The tropical partition function on a compact space `X`
  with energy function `E : X → ℝ`, defined as `sInf (Set.range E)`.

## Main results

* `tropicalPartitionCompact_attained`: On a nonempty compact space, a lower semicontinuous
  energy function attains its minimum, which equals the tropical partition function.
* `tropicalPartitionCompact_le`: The tropical partition function is a lower bound for all
  energy values (for lsc energy functions).
* `le_tropicalPartitionCompact_of_forall_le`: Any universal lower bound on energies is
  at most the tropical partition function.
* `tropicalPartitionCompact_add_const`: Translation invariance of the tropical partition
  function under constant energy shifts.
* `tropicalPartitionCompact_mono`: Monotonicity under pointwise energy comparison.
* `tropicalPartitionCompact_pullback_surjective`: Invariance under surjective pullback
  (duplication invariance).
* `tropical_data_processing`: Data processing inequality — coarse-graining cannot decrease
  the minimum achievable energy.

## Mathematical significance

This establishes that tropical free energy is a topological invariant, not a finite-set
artifact. It opens connections between tropical geometry, idempotent analysis, compact
optimization, and information theory at zero temperature.

## Note on hypotheses

Several theorems require `LowerSemicontinuous E` to ensure `BddBelow (Set.range E)`,
which is necessary for `sInf` over `ℝ` (a conditionally complete lattice) to behave
correctly. Without boundedness, `sInf` on `ℝ` does not satisfy the expected properties.
The user-facing specification omitted this hypothesis in some places; we include it
where mathematically necessary.
-/

open Set Function Filter Topology

noncomputable section

/-- The tropical partition function on a compact topological space `X` with energy
function `E : X → ℝ`. This is the infimum of all energy values, which by
compactness and lower semicontinuity is actually attained. -/
def tropicalPartitionCompact
    (X : Type*) [TopologicalSpace X] [CompactSpace X]
    (E : X → ℝ) : ℝ :=
  sInf (Set.range E)

/-! ### Helper lemmas -/

/-- The range of a function on a nonempty type is nonempty. -/
lemma range_nonempty' (X : Type*) [Nonempty X] (E : X → ℝ) :
    (Set.range E).Nonempty :=
  Set.range_nonempty E

/-- On a nonempty compact space, the range of a lower semicontinuous function
is bounded below. -/
lemma bddBelow_range_of_compact
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) :
    BddBelow (Set.range E) := by
  have hbd : BddBelow (E '' Set.univ) :=
    (hE.lowerSemicontinuousOn (s := Set.univ)).bddBelow_of_isCompact isCompact_univ
  rwa [Set.image_univ] at hbd

/-
On a nonempty compact space, a lower semicontinuous function attains its
global minimum. This is the topological extreme value theorem for lsc functions.
-/
theorem exists_isMinOn_tropicalPartitionCompact
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) :
    ∃ x₀ : X, ∀ x : X, E x₀ ≤ E x := by
  have h_extreme : ∃ x₀ ∈ Set.univ, ∀ x ∈ Set.univ, E x₀ ≤ E x := by
    convert LowerSemicontinuousOn.exists_isMinOn _ _ _;
    any_goals exact hE.lowerSemicontinuousOn _;
    · rfl;
    · exact ⟨ Classical.arbitrary X, Set.mem_univ _ ⟩;
    · exact isCompact_univ;
  aesop

/-! ### Core API for the tropical partition function -/

/-
The tropical partition function is a lower bound for any energy value,
provided the energy function is lower semicontinuous (ensuring boundedness below).
-/
theorem tropicalPartitionCompact_le
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) (x : X) :
    tropicalPartitionCompact X E ≤ E x := by
  exact csInf_le ( bddBelow_range_of_compact X E hE ) ( Set.mem_range_self x )

/-
Any value that is at most every energy value is at most the tropical
partition function.
-/
theorem le_tropicalPartitionCompact_of_forall_le
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) {a : ℝ} (ha : ∀ x : X, a ≤ E x) :
    a ≤ tropicalPartitionCompact X E := by
  exact le_csInf ( Set.range_nonempty _ ) ( by rintro _ ⟨ x, rfl ⟩ ; exact ha x )

/-
On a nonempty compact space, a lower semicontinuous energy function attains
its minimum, which equals the tropical partition function. This is the
foundational attainment theorem.
-/
theorem tropicalPartitionCompact_attained
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) :
    ∃ x₀ : X, E x₀ = tropicalPartitionCompact X E := by
  -- Since $E$ is lower semicontinuous, by Lemma 2, $E$ attains its minimum.
  have h_min : ∃ x₀, ∀ x : X, E x₀ ≤ E x :=
    exists_isMinOn_tropicalPartitionCompact X E hE
  exact ⟨ h_min.choose, le_antisymm ( le_csInf ( Set.range_nonempty E ) ( Set.forall_mem_range.2 h_min.choose_spec ) ) ( csInf_le ( bddBelow_range_of_compact X E hE ) ( Set.mem_range_self h_min.choose ) ) ⟩

/-
The tropical partition function satisfies a universal characterization:
it is at most `a` if and only if some state has energy at most `a`.
-/
theorem tropicalPartitionCompact_le_iff
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) (a : ℝ) :
    tropicalPartitionCompact X E ≤ a ↔ ∃ x : X, E x ≤ a := by
  refine' ⟨ fun ha => _, fun ⟨ x, hx ⟩ => _ ⟩;
  · exact Exists.elim ( tropicalPartitionCompact_attained X E hE ) fun x hx => ⟨ x, hx.symm ▸ ha ⟩;
  · exact le_trans ( csInf_le ( bddBelow_range_of_compact X E hE ) ( Set.mem_range_self x ) ) hx

/-! ### Structural theorems -/

/-
Translation invariance: shifting all energies by a constant shifts the
tropical partition function by the same constant. This says tropical entropy
depends only on relative energy.
-/
theorem tropicalPartitionCompact_add_const
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) (c : ℝ) :
    tropicalPartitionCompact X (fun x => E x + c) =
      tropicalPartitionCompact X E + c := by
  apply le_antisymm;
  · obtain ⟨ x₀, hx₀ ⟩ := tropicalPartitionCompact_attained X E hE;
    exact csInf_le ( bddBelow_range_of_compact X ( fun x => E x + c ) ( hE.add continuous_const.lowerSemicontinuous ) ) ⟨ x₀, by simp +decide [ hx₀ ] ⟩;
  · refine' le_csInf _ _ <;> norm_num +zetaDelta at *;
    · exact ⟨ _, ⟨ Classical.arbitrary X, rfl ⟩ ⟩;
    · exact fun a => tropicalPartitionCompact_le X E hE a

/-
Left-addition version of translation invariance.
-/
theorem tropicalPartitionCompact_const_add
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E : X → ℝ) (hE : LowerSemicontinuous E) (c : ℝ) :
    tropicalPartitionCompact X (fun x => c + E x) =
      c + tropicalPartitionCompact X E := by
  convert tropicalPartitionCompact_add_const X E hE c using 1;
  · simp +decide only [add_comm];
  · exact add_comm _ _

/-
Monotonicity: if every state has at most as much energy under `E` as under `F`,
then the tropical partition function of `E` is at most that of `F`.
Requires lower semicontinuity of `E` to ensure the infimum is well-behaved.
-/
theorem tropicalPartitionCompact_mono
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    (E F : X → ℝ) (hE : LowerSemicontinuous E) (hEF : ∀ x, E x ≤ F x) :
    tropicalPartitionCompact X E ≤ tropicalPartitionCompact X F := by
  refine' le_csInf _ _;
  · exact ⟨ _, ⟨ Classical.arbitrary X, rfl ⟩ ⟩;
  · rintro _ ⟨ x, rfl ⟩ ; exact le_trans ( tropicalPartitionCompact_le _ E hE x ) ( hEF x ) ;

/-
Surjective pullback invariance: pulling back an energy function along a
surjection does not change the tropical partition function. This is the
topological analogue of idempotent duplication invariance.
-/
theorem tropicalPartitionCompact_pullback_surjective
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : Y → X) (hf : Function.Surjective f) (E : X → ℝ) :
    tropicalPartitionCompact Y (fun y => E (f y)) =
      tropicalPartitionCompact X E := by
  unfold tropicalPartitionCompact;
  -- The range of a function is the set of all its outputs. Since $f$ is surjective, every element in $X$ is an output of $f$.
  have h_range : Set.range (fun y => E (f y)) = Set.range E := by
    exact Set.ext fun x => ⟨ fun ⟨ y, hy ⟩ => ⟨ f y, hy ⟩, fun ⟨ y, hy ⟩ => by obtain ⟨ z, rfl ⟩ := hf y; exact ⟨ z, hy ⟩ ⟩
  -- Since the ranges are equal, their infimums must be equal.
  rw [h_range]

/-! ### Data processing inequality -/

/-
The tropical data processing inequality: if the observed energy `F` at `f(x)` is
always at most the latent energy `E` at `x`, then the tropical partition function of
the observed system is at most that of the latent system. Coarse-graining cannot
increase the minimum achievable energy.
-/
theorem tropical_data_processing
    (X Y : Type*)
    [TopologicalSpace X] [CompactSpace X] [Nonempty X]
    [TopologicalSpace Y] [CompactSpace Y] [Nonempty Y]
    (f : X → Y) (E : X → ℝ) (F : Y → ℝ)
    (_hE : LowerSemicontinuous E) (hF : LowerSemicontinuous F)
    (hFE : ∀ x : X, F (f x) ≤ E x) :
    tropicalPartitionCompact Y F ≤ tropicalPartitionCompact X E := by
  have h_inf_F_le_F_fx : ∀ x : X, sInf (Set.range F) ≤ F (f x) :=
    fun x => csInf_le (bddBelow_range_of_compact Y F hF) (Set.mem_range_self _)
  exact le_csInf ( Set.range_nonempty E ) fun y hy => by rcases hy with ⟨ x, rfl ⟩ ; exact le_trans ( h_inf_F_le_F_fx x ) ( hFE x ) ;

end