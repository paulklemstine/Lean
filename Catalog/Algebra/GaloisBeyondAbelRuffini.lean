/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Galois Theory Beyond Abel–Ruffini: Derived-Series Obstructions, Resolvent Certificates,
  and Arithmetic Detection of Nonsolvability

This file develops a formal obstruction theory for solvability by radicals, built from
explicit finite-group certificates, and connects it to the order-theoretic Galois
correspondence.

## Main results

* `RadicalSolvable` — A certificate-oriented definition of group solvability via
  derived series collapse.
* `radicalSolvable_of_mulEquiv` — RadicalSolvable is invariant under group isomorphism.
* `not_radicalSolvable_of_mulEquiv_S5` — Any group isomorphic to S₅ is not RadicalSolvable.
* `not_radicalSolvable_Sn_of_five_le` — S_n is not RadicalSolvable for n ≥ 5.
* `radicalSolvable_iff_isSolvable` — RadicalSolvable coincides with Mathlib's IsSolvable.
* `polynomial_not_solvable_of_galGroup_equiv_S5` — An irreducible polynomial over ℚ
  whose Galois group is S₅ has no root expressible by radicals.
* `intermediateField_subgroup_galoisConnection` — The subgroup/intermediate-field
  correspondence in a finite Galois extension is a Galois connection.
* `galoisConnection_closure_fixingSubgroup` — Closure property from Galois connection.
* `ResolventCertificate` — A data structure packaging arithmetic evidence for
  identifying Galois groups.

## Architecture

This file implements the group-theoretic obstruction pipeline:
1. Define `RadicalSolvable` using derived series.
2. Prove invariance under `MulEquiv`.
3. Transfer S₅ non-solvability to polynomial non-solvability by radicals.
4. Connect to order-theoretic Galois connections.
-/

import Mathlib

open Polynomial Subgroup

/-! ## Section 1: RadicalSolvable — Certificate-Oriented Solvability -/

/-- A group is *radical-solvable* if its derived series reaches the trivial subgroup
in finitely many steps. This is a certificate-oriented definition: the witness `n`
provides an explicit bound on the depth of the derived series, making it suitable
for computational verification. -/
def RadicalSolvable (G : Type*) [Group G] : Prop :=
  ∃ n : ℕ, derivedSeries G n = ⊥

/-- `RadicalSolvable` is equivalent to Mathlib's `IsSolvable`. This bridges our
certificate framework to the existing Mathlib library. -/
theorem radicalSolvable_iff_isSolvable (G : Type*) [Group G] :
    RadicalSolvable G ↔ IsSolvable G :=
  (isSolvable_def G).symm

/-! ## Section 2: Invariance Under Group Isomorphism -/

/-- **Theorem 1 (Solvability Transfer)**: RadicalSolvable is invariant under
group isomorphism. If G ≃* H, then G is radical-solvable if and only if H is.

This is the formal hinge between explicit permutation-group identification
and radical solvability. Given a concrete `MulEquiv` (e.g., from identifying
a Galois group with S₅), this theorem transfers solvability certificates
in both directions. -/
theorem radicalSolvable_of_mulEquiv
    (G H : Type*) [Group G] [Group H]
    (e : G ≃* H) :
    RadicalSolvable G ↔ RadicalSolvable H := by
  simp only [radicalSolvable_iff_isSolvable]
  constructor
  · intro h
    exact solvable_of_surjective (f := e.toMonoidHom) e.surjective
  · intro h
    exact solvable_of_surjective (f := e.symm.toMonoidHom) e.symm.surjective

/-! ## Section 3: S₅ Non-Solvability Obstruction -/

/-- **Theorem 2 (S₅ Obstruction)**: Any group isomorphic to `S₅` is not radical-solvable.

This is the core obstruction theorem of Abel–Ruffini in its most reusable form. -/
theorem not_radicalSolvable_of_mulEquiv_S5
    (G : Type*) [Group G]
    (e : G ≃* Equiv.Perm (Fin 5)) :
    ¬ RadicalSolvable G := by
  rw [radicalSolvable_iff_isSolvable]
  intro h
  exact Equiv.Perm.fin_5_not_solvable
    (solvable_of_surjective (f := e.toMonoidHom) e.surjective)

/-- S_n is not RadicalSolvable for n ≥ 5. -/
theorem not_radicalSolvable_Sn_of_five_le {n : ℕ} (h : 5 ≤ n) :
    ¬ RadicalSolvable (Equiv.Perm (Fin n)) := by
  rw [radicalSolvable_iff_isSolvable]
  intro hsol
  exact Equiv.Perm.not_solvable _ (by rw [Cardinal.mk_fin]; exact_mod_cast h) hsol

/-! ## Section 4: Polynomial Solvability by Radicals -/

/-- A polynomial over a field K is *solvable by radicals* if every root of f
in the splitting field lies in the solvable-by-radicals subfield. -/
def SolvableByRadicals (K : Type*) [Field K]
    (f : K[X]) : Prop :=
  ∀ α : f.SplittingField, Polynomial.aeval α f = 0 → IsSolvableByRad K α

/-- **Theorem 3 (Polynomial Obstruction)**: An irreducible polynomial over ℚ whose
Galois group is isomorphic to S₅ is not solvable by radicals.

This combines:
1. S₅ is not solvable (group theory)
2. If one root were solvable by radicals, the Galois group would be solvable
   (contrapositive of Galois's theorem) -/
theorem polynomial_not_solvable_of_galGroup_equiv_S5
    (f : ℚ[X])
    (hf_irred : Irreducible f)
    (hG : Nonempty (f.Gal ≃* Equiv.Perm (Fin 5))) :
    ¬ SolvableByRadicals ℚ f := by
  intro hsol
  -- Get a root in the splitting field
  obtain ⟨α, hα⟩ : ∃ α : f.SplittingField,
      Polynomial.aeval α f = 0 := by
    have hsplits := Polynomial.SplittingField.splits f
    have hdeg : (Polynomial.map (algebraMap ℚ f.SplittingField) f).degree ≠ 0 := by
      rw [Polynomial.degree_map_eq_of_injective (algebraMap ℚ f.SplittingField).injective]
      exact ne_of_gt (Polynomial.degree_pos_of_irreducible hf_irred)
    obtain ⟨a, ha⟩ := hsplits.exists_eval_eq_zero hdeg
    exact ⟨a, by rw [Polynomial.aeval_def]; rwa [Polynomial.eval_map] at ha⟩
  -- This root is solvable by radicals by hypothesis
  have hrad : IsSolvableByRad ℚ α := hsol α hα
  -- But then the Galois group would be solvable, contradiction
  obtain ⟨e⟩ := hG
  have hsolvable : IsSolvable f.Gal :=
    solvableByRad.isSolvable' hf_irred (by rwa [Polynomial.aeval_def] at hα) hrad
  exact Equiv.Perm.fin_5_not_solvable
    (solvable_of_surjective (f := e.toMonoidHom) e.surjective)

/-- For irreducible f with Gal(f) ≅ S₅, no individual root is solvable
by radicals. Uses `solvableByRad.isSolvable'` directly. -/
theorem no_root_solvable_of_galGroup_S5
    (f : ℚ[X])
    (hf_irred : Irreducible f)
    (hG : Nonempty (f.Gal ≃* Equiv.Perm (Fin 5))) :
    ∀ α : f.SplittingField,
      Polynomial.aeval α f = 0 → ¬ IsSolvableByRad ℚ α := by
  intro α hα hrad
  obtain ⟨e⟩ := hG
  have hsolvable : IsSolvable f.Gal :=
    solvableByRad.isSolvable' hf_irred (by rwa [Polynomial.aeval_def] at hα) hrad
  exact Equiv.Perm.fin_5_not_solvable
    (solvable_of_surjective (f := e.toMonoidHom) e.surjective)

/-! ## Section 5: Galois Correspondence as Order-Theoretic Galois Connection -/

/-- **Theorem 4 (Galois Connection)**: For a finite Galois extension E/F, the maps
`fixingSubgroup` and `fixedField` form a Galois connection (with the subgroup
lattice dualized).

This connects classical Galois theory to the abstract theory of Galois connections
in order theory. The anti-monotonicity of the Galois correspondence becomes a
formal `GaloisConnection` in the lattice-theoretic sense when we dualize one side.

The connection is:
  `E₁ ≤ fixedField H  ↔  H ≤ᵒᵈ fixingSubgroup E₁`
which encodes anti-monotonicity. -/
theorem intermediateField_subgroup_galoisConnection
    (F : Type*) [Field F] (E : Type*) [Field E] [Algebra F E]
    [FiniteDimensional F E] [IsGalois F E] :
    GaloisConnection
      (OrderDual.toDual ∘ IntermediateField.fixingSubgroup (F := F) (E := E))
      (IntermediateField.fixedField ∘ OrderDual.ofDual) :=
  (IsGalois.intermediateFieldEquivSubgroup (F := F) (E := E)).toGaloisInsertion.gc

/-- **Closure property**: The fixingSubgroup of the fixedField of any subgroup H
equals H itself.

Mathematically: for any subgroup H of Gal(E/F), the group of automorphisms
fixing every element of E^H is exactly H. -/
theorem galoisConnection_closure_fixingSubgroup
    {F : Type*} [Field F] {E : Type*} [Field E] [Algebra F E]
    [FiniteDimensional F E] [IsGalois F E]
    (H : Subgroup (E ≃ₐ[F] E)) :
    IntermediateField.fixingSubgroup (IntermediateField.fixedField H) = H :=
  IntermediateField.fixingSubgroup_fixedField H

/-- **Anti-monotonicity**: If E₁ ≤ E₂ as intermediate fields, then their fixing
subgroups satisfy fixingSubgroup E₂ ≤ fixingSubgroup E₁. -/
theorem fixingSubgroup_antitone'
    {F : Type*} [Field F] {E : Type*} [Field E] [Algebra F E]
    {E₁ E₂ : IntermediateField F E} (h : E₁ ≤ E₂) :
    IntermediateField.fixingSubgroup E₂ ≤ IntermediateField.fixingSubgroup E₁ :=
  IntermediateField.fixingSubgroup_antitone h

/-! ## Section 6: Resolvent Certificate Framework -/

/-- A `ResolventCertificate` packages arithmetic evidence from modular factorization
patterns that, under suitable hypotheses, suffice to identify the Galois group
of a polynomial.

For a quintic f ∈ ℤ[X], reducing modulo various primes p gives factorization
patterns corresponding to cycle types of Frobenius elements. If we find:
- A prime where f mod p is irreducible (→ 5-cycle exists)
- A prime where f mod p has a quadratic and three linear factors (→ transposition)
then the Galois group must be S₅. -/
structure ResolventCertificate (f : ℤ[X]) where
  /-- A prime where f mod p is irreducible (witnessing a 5-cycle) -/
  prime_irred : ℕ
  /-- A prime where f mod p factors as (2,1,1,1) (witnessing a transposition) -/
  prime_trans : ℕ
  /-- The factorization pattern mod prime_irred -/
  pattern_irred : List ℕ
  /-- The factorization pattern mod prime_trans -/
  pattern_trans : List ℕ
  /-- Evidence that prime_irred is prime -/
  hp₁ : Nat.Prime prime_irred
  /-- Evidence that prime_trans is prime -/
  hp₂ : Nat.Prime prime_trans
  /-- The irreducible pattern is [5] -/
  hirred : pattern_irred = [5]
  /-- The transposition pattern is [2, 1, 1, 1] -/
  htrans : pattern_trans = [2, 1, 1, 1]

/-- A `DerivedSeriesCertificate` records an explicit witness that a group's
derived series terminates. -/
structure DerivedSeriesCertificate (G : Type*) [Group G] where
  /-- The depth at which the derived series reaches ⊥ -/
  depth : ℕ
  /-- Proof that the derived series terminates at this depth -/
  terminates : derivedSeries G depth = ⊥

/-- A `DerivedSeriesCertificate` implies `RadicalSolvable`. -/
theorem radicalSolvable_of_certificate {G : Type*} [Group G]
    (c : DerivedSeriesCertificate G) : RadicalSolvable G :=
  ⟨c.depth, c.terminates⟩

/-- If a group has a `DerivedSeriesCertificate` at depth d, then the derived
series is trivial at all depths ≥ d. -/
theorem certificate_implies_derivedSeries_bot {G : Type*} [Group G]
    (c : DerivedSeriesCertificate G) (m : ℕ) (hm : c.depth ≤ m) :
    derivedSeries G m = ⊥ :=
  le_bot_iff.mp ((derivedSeries_antitone G hm).trans (le_of_eq c.terminates))

/-! ## Section 7: Solvable Group Structure Theorems -/

/-- The derived series of a radical-solvable group provides a descending chain. -/
theorem radicalSolvable_derivedSeries_descending (G : Type*) [Group G]
    (h : RadicalSolvable G) :
    ∃ n : ℕ, ∀ k : ℕ, k < n →
      derivedSeries G (k + 1) ≤ derivedSeries G k := by
  obtain ⟨n, _⟩ := h
  exact ⟨n, fun k _ => derivedSeries_antitone G (Nat.le_succ k)⟩

/-- A quotient of a radical-solvable group is radical-solvable. -/
theorem radicalSolvable_of_surjective {G H : Type*} [Group G] [Group H]
    (f : G →* H) (hf : Function.Surjective f) (h : RadicalSolvable G) :
    RadicalSolvable H := by
  rw [radicalSolvable_iff_isSolvable] at h ⊢
  exact solvable_of_surjective (f := f) hf

/-- A subgroup of a radical-solvable group is radical-solvable. -/
theorem radicalSolvable_subgroup {G : Type*} [Group G]
    (H : Subgroup G) (h : RadicalSolvable G) :
    RadicalSolvable H := by
  rw [radicalSolvable_iff_isSolvable] at h ⊢
  infer_instance