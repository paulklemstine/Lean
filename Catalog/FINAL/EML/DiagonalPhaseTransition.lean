/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Diagonal Phase Transition Incompleteness for Closure Self-Models

This file formalizes the **diagonal phase transition incompleteness theorem**:
a critical point in the diagonal free energy of a closure self-model certifies
the existence of an infinite family of internally irreducible self-descriptions.

## Mathematical Overview

A **closure self-model** is a type `M` equipped with:
- A **free energy function** `freeEnergy : ℝ → M → ℝ` assigning thermodynamic
  cost at inverse temperature `β` to each element.
- A **complexity measure** `complexity : M → ℕ` capturing the internal description
  length of elements.
- A **thermodynamic bridge axiom** asserting that if every infinite family of
  `M`-elements has uniformly bounded complexity, then the diagonal free energy
  (the supremum of free energies over all elements) is everywhere differentiable.

The fundamental axiom encodes a deep principle: phase transitions (non-differentiable
points in the free energy) can only arise when there exist infinite families that
resist uniform compression. The main theorem extracts the contrapositive:

> **Diagonal Phase Transition Incompleteness:**
> If the diagonal free energy has a critical point (non-differentiable point),
> then there exists an infinite family of elements that cannot be uniformly
> compressed within the closure mechanism.

This upgrades classical incompleteness from a static impossibility statement
to a quantitative capacity law: thermodynamic criticality certifies the
existence of infinitely many internally irreducible self-descriptions.

## Main Results

* `HasCriticalPoint` — definition of critical points for real functions
* `ClosureSelfModel` — the abstract closure self-model typeclass
* `diagFreeEnergy` — the diagonal free energy function
* `UniformlyCompressibleWithinClosure` — uniform compressibility predicate
* `DiagonalEntropyBarrier` — the entropy barrier property
* `critical_point_contrapositive_bridge` — the key bridge lemma
* `not_forall_imp_exists_and_neg` — classical logic extraction helper
* `diagonal_phase_transition_incompleteness` — **the main theorem**
* `diagonal_phase_transition_incompleteness_weak` — weaker existential form
* `diagonal_entropy_barrier_iff` — characterization of the entropy barrier
* `DiagSubcriticalAnalyticFailure` — sharper analytic failure predicate
* `diagonal_phase_transition_incompleteness_of_nonanalytic` — sharper variant
* `critical_point_yields_infinite_diagonal_irreducibles` — quantitative form

## References

* Gödel, K. — Über formal unentscheidbare Sätze (1931)
* Lawvere, F.W. — Diagonal arguments and cartesian closed categories (1969)
-/

import Mathlib

open Classical Set

universe u

/-! ## §1. Fundamental Definitions -/

/-- A **critical point** of a real-valued function `f`: a point where `f` fails
    to be differentiable. In the thermodynamic setting, this models a phase
    transition where the free energy develops a singularity (e.g., a cusp or
    discontinuity in a derivative). -/
def HasCriticalPoint (f : ℝ → ℝ) : Prop :=
  ∃ β₀ : ℝ, ¬DifferentiableAt ℝ f β₀

/-- A **closure self-model** is a type equipped with thermodynamic structure:

    - `freeEnergy β m`: the free energy at inverse temperature `β` for element `m`
    - `complexity m`: an integer complexity measure of element `m`

    The fundamental axiom `ax_uniform_compression_implies_no_criticality` asserts
    that universal uniform compressibility of infinite families precludes critical
    points in the diagonal free energy. Concretely: if every infinite family of
    `M`-elements has uniformly bounded complexity, then the function
    `β ↦ sup_m freeEnergy(β, m)` is everywhere differentiable.

    This axiom encodes the principle that thermodynamic phase transitions in
    self-referential systems can only occur when there exist infinite families
    that resist uniform compression — the diagonal analogue of incompleteness
    phenomena. -/
class ClosureSelfModel (M : Type u) where
  /-- Free energy at inverse temperature `β` for element `m`. -/
  freeEnergy : ℝ → M → ℝ
  /-- Complexity measure (internal description length) of an element. -/
  complexity : M → ℕ
  /-- **Thermodynamic bridge axiom.** If every infinite family of `M`-elements
      has uniformly bounded complexity, then the diagonal free energy
      `β ↦ ⨆ m, freeEnergy β m` is everywhere differentiable.

      This is the core physical principle: universal compressibility forces
      the diagonal free energy into the subcritical (analytic) regime. -/
  ax_uniform_compression_implies_no_criticality :
    (∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
      ∃ C : ℕ, ∀ n, complexity (φ n) ≤ C) →
    ∀ β₀ : ℝ, DifferentiableAt ℝ (fun β => ⨆ m : M, freeEnergy β m) β₀

/-! ## §2. Derived Thermodynamic Notions -/

/-- The **diagonal free energy** of a closure self-model `M`:
    the supremum over all elements of their free energy at inverse temperature `β`.

    This function captures the worst-case thermodynamic cost of self-description
    across all elements of the model. Critical points of this function correspond
    to phase transitions in the model's diagonal self-evaluation capacity. -/
noncomputable def diagFreeEnergy (M : Type u) [ClosureSelfModel M] : ℝ → ℝ :=
  fun β => ⨆ m : M, ClosureSelfModel.freeEnergy β m

/-- **Uniform compressibility within closure**: a family `φ : ℕ → M` is
    uniformly compressible if there exists a uniform bound `C` on the
    complexity of all elements in the family.

    This captures the idea that the entire family can be "compressed" to
    descriptions of bounded length within the model's closure mechanism. -/
def UniformlyCompressibleWithinClosure (M : Type u) [ClosureSelfModel M]
    (φ : ℕ → M) : Prop :=
  ∃ C : ℕ, ∀ n, ClosureSelfModel.complexity (φ n) ≤ C

/-- **Compressibility within a specific bound**: the family `φ` has all
    complexities bounded by `C`. This is the quantitative refinement of
    `UniformlyCompressibleWithinClosure`. -/
def CompressibleWithinClosureBound (M : Type u) [ClosureSelfModel M]
    (φ : ℕ → M) (C : ℕ) : Prop :=
  ∀ n, ClosureSelfModel.complexity (φ n) ≤ C

/-- The **diagonal entropy barrier**: the property that every infinite family
    of `M`-elements is incompressible (has unbounded complexity).

    When this barrier holds, the model has sufficient "room" for all self-referential
    data. When it fails, some infinite family can be uniformly compressed,
    indicating a thermodynamic anomaly. -/
def DiagonalEntropyBarrier (M : Type u) [ClosureSelfModel M] : Prop :=
  ∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
    ¬ UniformlyCompressibleWithinClosure M φ

/-- **Subcritical analytic failure**: the diagonal free energy has a critical
    point at some specific inverse temperature `βc`. This is the sharper
    form of `HasCriticalPoint` that identifies the specific transition point. -/
def DiagSubcriticalAnalyticFailure (M : Type u) [ClosureSelfModel M] : Prop :=
  ∃ βc : ℝ, ¬DifferentiableAt ℝ (diagFreeEnergy M) βc

/-- Witness family type alias for diagonal constructions. -/
def DiagonalWitnessFamily (M : Type u) [ClosureSelfModel M] : Type u := ℕ → M

/-! ## §3. Equivalences and Reformulations -/

/-- `UniformlyCompressibleWithinClosure` is equivalent to the existence of a
    bound satisfying `CompressibleWithinClosureBound`. -/
theorem uniformlyCompressible_iff_exists_bound
    {M : Type u} [ClosureSelfModel M] {φ : ℕ → M} :
    UniformlyCompressibleWithinClosure M φ ↔
      ∃ C : ℕ, CompressibleWithinClosureBound M φ C := by
  rfl

/-- Unbounded complexity implies non-uniform-compressibility. -/
theorem not_uniformlyCompressible_of_unbounded
    {M : Type u} [ClosureSelfModel M] {φ : ℕ → M} :
    (∀ C : ℕ, ¬ CompressibleWithinClosureBound M φ C) →
    ¬ UniformlyCompressibleWithinClosure M φ := by
  intro h ⟨C, hC⟩
  exact h C hC

/-- `DiagSubcriticalAnalyticFailure` is equivalent to `HasCriticalPoint`
    applied to the diagonal free energy. -/
theorem diagSubcriticalAnalyticFailure_iff_hasCriticalPoint
    {M : Type u} [ClosureSelfModel M] :
    DiagSubcriticalAnalyticFailure M ↔ HasCriticalPoint (diagFreeEnergy M) := by
  rfl

/-- The diagonal entropy barrier holds if and only if every infinite family
    is incompressible. (This is definitional but stated for API clarity.) -/
theorem diagonal_entropy_barrier_iff
    {M : Type u} [ClosureSelfModel M] :
    DiagonalEntropyBarrier M ↔
      ∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
        ¬ UniformlyCompressibleWithinClosure M φ := by
  rfl

/-! ## §4. Classical Logic Helpers -/

/-- Classical extraction: the negation of a universal implication yields an
    existential conjunction with negation. This is the key logical maneuver
    for converting "not all infinite families are compressible" into
    "some infinite family is incompressible." -/
theorem not_forall_imp_exists_and_neg
    {α : Type*} {P Q : α → Prop} :
    (¬ ∀ x, P x → Q x) → ∃ x, P x ∧ ¬ Q x := by
  intro h
  by_contra h'
  push_neg at h'
  exact h h'

/-- The negation of "all infinite families are compressible" is equivalent to
    "some infinite family is incompressible." -/
theorem not_forall_infinite_compressible_iff_exists_uncompressible
    {M : Type u} [ClosureSelfModel M] :
    (¬ ∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
        UniformlyCompressibleWithinClosure M φ) ↔
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      ¬ UniformlyCompressibleWithinClosure M φ := by
  constructor
  · exact not_forall_imp_exists_and_neg
  · rintro ⟨φ, hInf, hNC⟩ h
    exact hNC (h φ hInf)

/-- Direct witness extraction from the negation of a universal statement. -/
theorem exists_uncompressible_family_of_not_all_compressible
    {M : Type u} [ClosureSelfModel M] :
    ¬ (∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
        UniformlyCompressibleWithinClosure M φ) →
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      ¬ UniformlyCompressibleWithinClosure M φ :=
  not_forall_infinite_compressible_iff_exists_uncompressible.mp

/-! ## §5. The Thermodynamic Bridge -/

/-- **Critical point contrapositive bridge.**

    If every infinite family of `M`-elements is uniformly compressible,
    then the diagonal free energy has no critical point.

    This is the direct consequence of the thermodynamic bridge axiom:
    universal compressibility forces all partition-function singularities
    to be resolvable, yielding everywhere-differentiable free energy. -/
theorem critical_point_contrapositive_bridge
    {M : Type u} [ClosureSelfModel M] [Encodable M] :
    (∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
      UniformlyCompressibleWithinClosure M φ) →
    ¬ HasCriticalPoint (diagFreeEnergy M) := by
  intro h ⟨β₀, hβ₀⟩
  exact hβ₀ (ClosureSelfModel.ax_uniform_compression_implies_no_criticality h β₀)

/-- **Weak form**: a critical point implies not all infinite families are
    compressible. This is the direct contrapositive of the bridge. -/
theorem diagonal_phase_transition_incompleteness_weak
    {M : Type u} [ClosureSelfModel M] [Encodable M] :
    HasCriticalPoint (diagFreeEnergy M) →
    ¬ (∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
        UniformlyCompressibleWithinClosure M φ) := by
  intro hcrit hall
  exact critical_point_contrapositive_bridge hall hcrit

/-! ## §6. The Main Theorem -/

/-- **Diagonal Phase Transition Incompleteness Theorem.**

    In any closure self-model `M`: if the diagonal free energy has a critical
    point (a phase transition), then there exists an infinite family of
    `M`-elements that cannot be uniformly compressed within the closure mechanism.

    ### Proof sketch

    By contrapositive reasoning:
    1. Assume the diagonal free energy has a critical point.
    2. Suppose for contradiction that every infinite family is uniformly
       compressible within the closure.
    3. By the thermodynamic bridge axiom, this implies the diagonal free energy
       is everywhere differentiable — contradicting the critical point.
    4. Therefore some infinite family must be incompressible.
    5. Classical logic extracts the witness family from the negated universal. -/
theorem diagonal_phase_transition_incompleteness
    {M : Type u} [ClosureSelfModel M] [Encodable M] :
    HasCriticalPoint (diagFreeEnergy M) →
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      ¬ UniformlyCompressibleWithinClosure M φ := by
  intro hcrit
  exact exists_uncompressible_family_of_not_all_compressible
    (diagonal_phase_transition_incompleteness_weak hcrit)

/-! ## §7. Sharper Variants -/

/-- **Sharper variant via subcritical analytic failure.**

    The same conclusion follows from the sharper hypothesis that the diagonal
    free energy specifically fails subcritical analyticity (has a critical point).
    Since `DiagSubcriticalAnalyticFailure M` is definitionally equal to
    `HasCriticalPoint (diagFreeEnergy M)`, this is a direct restatement. -/
theorem diagonal_phase_transition_incompleteness_of_nonanalytic
    {M : Type u} [ClosureSelfModel M] [Encodable M] :
    DiagSubcriticalAnalyticFailure M →
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      ¬ UniformlyCompressibleWithinClosure M φ :=
  diagonal_phase_transition_incompleteness

/-- **Quantitative form: unbounded complexity.**

    Under a critical point, there exists an infinite family such that
    for every bound `C`, the family is not `C`-compressible. This is
    the strongest quantitative version. -/
theorem critical_point_yields_infinite_diagonal_irreducibles
    {M : Type u} [ClosureSelfModel M] [Encodable M] :
    HasCriticalPoint (diagFreeEnergy M) →
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      (∀ C : ℕ, ¬ CompressibleWithinClosureBound M φ C) := by
  intro hcrit
  obtain ⟨φ, hInf, hNC⟩ := diagonal_phase_transition_incompleteness hcrit
  exact ⟨φ, hInf, fun C hC => hNC ⟨C, hC⟩⟩

/-- The quantitative form implies the main theorem. -/
theorem diagonal_phase_transition_incompleteness_of_quantitative
    {M : Type u} [ClosureSelfModel M] [Encodable M] {φ : ℕ → M} :
    (∀ C : ℕ, ¬ CompressibleWithinClosureBound M φ C) →
    ¬ UniformlyCompressibleWithinClosure M φ :=
  not_uniformlyCompressible_of_unbounded

/-! ## §8. Entropy Barrier Characterization -/

/-- **Critical point breaks the entropy barrier's contrapositive.**

    A critical point implies that the "all infinite families are compressible"
    property fails, which is the negation of the entropy barrier when stated
    in its contrapositive form.

    Note: `DiagonalEntropyBarrier M` says "every infinite family is incompressible."
    A critical point implies `¬ AllInfiniteCompressible`, i.e., "some infinite
    family is incompressible" — which is *weaker* than `DiagonalEntropyBarrier`.
    The critical point gives at least one incompressible infinite family, but
    does not by itself guarantee that ALL infinite families are incompressible. -/
theorem critical_point_yields_partial_barrier
    {M : Type u} [ClosureSelfModel M] [Encodable M] :
    HasCriticalPoint (diagFreeEnergy M) →
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      ¬ UniformlyCompressibleWithinClosure M φ :=
  diagonal_phase_transition_incompleteness

/-- The existence of an incompressible infinite family is equivalent to the
    failure of universal infinite-family compressibility. -/
theorem exists_incompressible_iff_not_all_compressible
    {M : Type u} [ClosureSelfModel M] :
    (∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
        ¬ UniformlyCompressibleWithinClosure M φ) ↔
    ¬ (∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
        UniformlyCompressibleWithinClosure M φ) :=
  not_forall_infinite_compressible_iff_exists_uncompressible.symm

/-! ## §9. Axiom Verification -/

#print axioms HasCriticalPoint
#print axioms diagFreeEnergy
#print axioms UniformlyCompressibleWithinClosure
#print axioms DiagonalEntropyBarrier
#print axioms critical_point_contrapositive_bridge
#print axioms diagonal_phase_transition_incompleteness_weak
#print axioms diagonal_phase_transition_incompleteness
#print axioms diagonal_phase_transition_incompleteness_of_nonanalytic
#print axioms critical_point_yields_infinite_diagonal_irreducibles
#print axioms not_forall_infinite_compressible_iff_exists_uncompressible
#print axioms exists_uncompressible_family_of_not_all_compressible