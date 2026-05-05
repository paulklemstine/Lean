/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Elimination via Prime-Spectral Legendre Duality

This file establishes that elimination of an adjoined variable in a proof semiring
is governed by a prime-spectral variational principle: membership in the elimination
ideal equals domination against all compatible primes.

## Main results

* `mem_radicalElim_iff_spectral` — **the main duality theorem**:
  radical elimination ↔ spectral domination against all compatible primes
* `radicalElim_eq_spectralElim` — set equality form of the duality
* `not_mem_radicalElim_iff_exists_prime_witness` — non-elimination
  yields a separating prime witness
* `radicalElim_eq_variationalKernel` — the full duality chain
* `mem_radicalElim_iff_sup_gap_zero` — variational principle: elimination iff
  all free-energy gaps vanish

## Mathematical significance

Existential projection in a proof-semiring world is governed by a variational
principle on the prime spectrum: elimination = intersection over prime-compatible
contractions. This bridges algebraic geometry, proof theory, and thermodynamics.
-/

import Mathlib

open Set Polynomial Ideal Classical

noncomputable section

universe u

/-! ## Closure Operator Framework -/

/-- A closure operator on a commutative semiring, modeling derivability. -/
structure ClosureTheory (S : Type u) [CommSemiring S] where
  cl : Set S → Set S
  cl_extensive : ∀ A : Set S, A ⊆ cl A
  cl_mono : ∀ {A B : Set S}, A ⊆ B → cl A ⊆ cl B
  cl_idem : ∀ A : Set S, cl (cl A) = cl A

/-- A **coherent closure** commutes with directed unions. -/
structure CoherentClosure (S : Type u) [CommSemiring S] extends ClosureTheory S where
  coherent : ∀ (A : Set S) (a : S), a ∈ cl A →
    ∃ F : Finset S, (F : Set S) ⊆ A ∧ a ∈ cl (F : Set S)

/-! ## Polynomial Extension and Elimination Ideals -/

variable {R : Type u} [CommRing R]

/-- The **elimination ideal**: contraction of `I ⊆ R[X]` to `R` via `C`. -/
def eliminationIdeal (I : Ideal (Polynomial R)) : Ideal R :=
  I.comap Polynomial.C

/-- The **radical elimination ideal**: contraction of `√I` to `R`. -/
def radicalEliminationIdeal (I : Ideal (Polynomial R)) : Ideal R :=
  I.radical.comap Polynomial.C

theorem mem_eliminationIdeal_iff (I : Ideal (Polynomial R)) (a : R) :
    a ∈ eliminationIdeal I ↔ Polynomial.C a ∈ I :=
  Ideal.mem_comap

theorem mem_radicalEliminationIdeal_iff (I : Ideal (Polynomial R)) (a : R) :
    a ∈ radicalEliminationIdeal I ↔ Polynomial.C a ∈ I.radical :=
  Ideal.mem_comap

theorem mem_radicalEliminationIdeal_iff' (I : Ideal (Polynomial R)) (a : R) :
    a ∈ radicalEliminationIdeal I ↔ ∃ n : ℕ, Polynomial.C (a ^ n) ∈ I := by
  rw [mem_radicalEliminationIdeal_iff, Ideal.mem_radical_iff]
  simp [map_pow]

/-! ## Prime Compatibility and Spectral Elimination -/

/-- A prime `P` of `R[X]` is **compatible** with ideal `I` if `I ≤ P`. -/
def primeCompatible (I : Ideal (Polynomial R)) (P : PrimeSpectrum (Polynomial R)) : Prop :=
  I ≤ P.asIdeal

/-- The **spectral elimination set**: `{a ∈ R | ∀ P prime, I ≤ P → C(a) ∈ P}`. -/
def spectralElimination (I : Ideal (Polynomial R)) : Set R :=
  {a : R | ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P → Polynomial.C a ∈ P.asIdeal}

theorem mem_spectralElimination_iff (I : Ideal (Polynomial R)) (a : R) :
    a ∈ spectralElimination I ↔
      ∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → Polynomial.C a ∈ P.asIdeal :=
  Iff.rfl

/-! ## The Main Duality Theorem -/

/-- **Key lemma**: radical membership ↔ membership in all containing primes.
This wraps `Ideal.radical_eq_sInf` into the `PrimeSpectrum` formulation. -/
theorem mem_radical_iff_mem_all_primeSpectrum
    (I : Ideal (Polynomial R)) (f : Polynomial R) :
    f ∈ I.radical ↔
      ∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → f ∈ P.asIdeal := by
  constructor
  · intro hf P hIP
    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf] at hf
    exact hf ⟨hIP, P.isPrime⟩
  · intro hf
    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf]
    intro J ⟨hIJ, hJprime⟩
    exact hf ⟨J, hJprime⟩ hIJ

/-- **Main duality theorem**: radical elimination ↔ spectral elimination. -/
theorem mem_radicalElim_iff_spectral (I : Ideal (Polynomial R)) (a : R) :
    a ∈ radicalEliminationIdeal I ↔ a ∈ spectralElimination I := by
  simp only [mem_radicalEliminationIdeal_iff, mem_spectralElimination_iff]
  exact mem_radical_iff_mem_all_primeSpectrum I (Polynomial.C a)

/-- **Set equality form of the main theorem.** -/
theorem radicalElim_eq_spectralElim (I : Ideal (Polynomial R)) :
    (radicalEliminationIdeal I : Set R) = spectralElimination I :=
  Set.ext (mem_radicalElim_iff_spectral I)

/-- **Soundness**: radical elimination ⊆ spectral elimination. -/
theorem elim_subset_spectral (I : Ideal (Polynomial R)) :
    (radicalEliminationIdeal I : Set R) ⊆ spectralElimination I :=
  (radicalElim_eq_spectralElim I).subset

/-- **Completeness**: spectral elimination ⊆ radical elimination. -/
theorem spectral_subset_elim (I : Ideal (Polynomial R)) :
    spectralElimination I ⊆ (radicalEliminationIdeal I : Set R) :=
  (radicalElim_eq_spectralElim I).superset

/-! ## Spectral Intersection Formulations -/

/-- Spectral elimination as `⋂₀` over prime contraction sets. -/
theorem spectralElimination_eq_sInter (I : Ideal (Polynomial R)) :
    spectralElimination I =
      ⋂₀ {T : Set R | ∃ P : PrimeSpectrum (Polynomial R),
        primeCompatible I P ∧ T = {a : R | Polynomial.C a ∈ P.asIdeal}} := by
  ext a
  simp only [mem_sInter, mem_setOf_eq, spectralElimination, primeCompatible]
  exact ⟨fun h T ⟨P, hP, hT⟩ => hT ▸ h P hP,
         fun h P hP => h _ ⟨P, hP, rfl⟩⟩

/-! ## Prime Witness Extraction -/

/-- If `a ∉ radicalElim(I)`, there exists a separating prime witness. -/
theorem exists_prime_witness_of_not_mem_radicalElim
    (I : Ideal (Polynomial R)) (a : R)
    (ha : a ∉ radicalEliminationIdeal I) :
    ∃ P : PrimeSpectrum (Polynomial R),
      primeCompatible I P ∧ Polynomial.C a ∉ P.asIdeal := by
  rw [mem_radicalElim_iff_spectral] at ha
  simp only [spectralElimination, primeCompatible, mem_setOf_eq] at ha
  push_neg at ha
  exact ha

/-- **Contrapositive characterization**: non-elimination ↔ ∃ separating prime. -/
theorem not_mem_radicalElim_iff_exists_prime_witness
    (I : Ideal (Polynomial R)) (a : R) :
    a ∉ radicalEliminationIdeal I ↔
      ∃ P : PrimeSpectrum (Polynomial R),
        primeCompatible I P ∧ Polynomial.C a ∉ P.asIdeal := by
  constructor
  · exact exists_prime_witness_of_not_mem_radicalElim I a
  · intro ⟨P, hP, hnotmem⟩ hmem
    rw [mem_radicalElim_iff_spectral] at hmem
    exact hnotmem (hmem P hP)

/-! ## Thermodynamic Functionals -/

/-- **Prime pressure indicator**: `1` if `a ∉ P` (positive pressure), `0` if `a ∈ P`. -/
def primePressureIndicator (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
  if Polynomial.C a ∈ P.asIdeal then (0 : ℝ) else (1 : ℝ)

/-- `a ∈ spectralElim(I)` iff pressure vanishes at all compatible primes. -/
theorem mem_spectralElimination_iff_pressure_zero
    (I : Ideal (Polynomial R)) (a : R) :
    a ∈ spectralElimination I ↔
      ∀ P : PrimeSpectrum (Polynomial R),
        primeCompatible I P → primePressureIndicator P a = 0 := by
  simp only [spectralElimination, primeCompatible, mem_setOf_eq, primePressureIndicator]
  constructor
  · intro h P hP; simp [h P hP]
  · intro h P hP
    specialize h P hP
    split_ifs at h with hmem
    · exact hmem
    · norm_num at h

/-- Non-elimination implies a positive-pressure prime witness. -/
theorem exists_positive_pressure_witness
    (I : Ideal (Polynomial R)) (a : R)
    (ha : a ∉ radicalEliminationIdeal I) :
    ∃ P : PrimeSpectrum (Polynomial R),
      primeCompatible I P ∧ primePressureIndicator P a = 1 := by
  obtain ⟨P, hP, hnotmem⟩ := exists_prime_witness_of_not_mem_radicalElim I a ha
  exact ⟨P, hP, by simp [primePressureIndicator, hnotmem]⟩

/-- **Free-energy gap** at a prime: same as the pressure indicator. -/
def freeEnergyGap (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
  primePressureIndicator P a

/-- **The variational kernel set**: elements with zero pressure everywhere. -/
def primeVariationalKernelSet (I : Ideal (Polynomial R)) : Set R :=
  {a : R | ∀ P : PrimeSpectrum (Polynomial R),
    primeCompatible I P → primePressureIndicator P a = 0}

/-- Variational kernel = spectral elimination. -/
theorem primeVariationalKernelSet_eq_spectralElimination
    (I : Ideal (Polynomial R)) :
    primeVariationalKernelSet I = spectralElimination I := by
  ext a
  exact (mem_spectralElimination_iff_pressure_zero I a).symm

/-- **Full duality chain**: radical elim = spectral elim = variational kernel. -/
theorem radicalElim_eq_variationalKernel (I : Ideal (Polynomial R)) :
    (radicalEliminationIdeal I : Set R) = primeVariationalKernelSet I := by
  rw [primeVariationalKernelSet_eq_spectralElimination, ← radicalElim_eq_spectralElim]

/-- **Variational principle**: elimination iff all free-energy gaps vanish. -/
theorem mem_radicalElim_iff_sup_gap_zero (I : Ideal (Polynomial R)) (a : R) :
    a ∈ radicalEliminationIdeal I ↔
      ∀ P : PrimeSpectrum (Polynomial R),
        primeCompatible I P → freeEnergyGap P a = 0 := by
  rw [mem_radicalElim_iff_spectral]
  exact mem_spectralElimination_iff_pressure_zero I a

/-! ## Monotonicity -/

theorem eliminationIdeal_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
    eliminationIdeal I ≤ eliminationIdeal J :=
  Ideal.comap_mono h

theorem radicalEliminationIdeal_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
    radicalEliminationIdeal I ≤ radicalEliminationIdeal J :=
  Ideal.comap_mono (Ideal.radical_mono h)

/-- Spectral elimination is monotone: `I ≤ J → spectralElim(I) ⊆ spectralElim(J)`.
Larger ideals eliminate into larger sets, because they impose constraints on
fewer primes. -/
theorem spectralElimination_mono {I J : Ideal (Polynomial R)} (h : I ≤ J) :
    spectralElimination I ⊆ spectralElimination J := by
  intro a ha P hP
  exact ha P (le_trans h hP)

/-! ## Contraction Map -/

/-- The contraction map `Spec(R[X]) → Spec(R)`. -/
def contractionMap : PrimeSpectrum (Polynomial R) → PrimeSpectrum R :=
  fun P => ⟨Ideal.comap Polynomial.C P.asIdeal, Ideal.IsPrime.comap Polynomial.C⟩

theorem mem_contractionMap_iff (P : PrimeSpectrum (Polynomial R)) (a : R) :
    a ∈ (contractionMap P).asIdeal ↔ Polynomial.C a ∈ P.asIdeal :=
  Ideal.mem_comap

/-! ## Pressure Set Equality -/

/-- Radical elimination = set of elements with non-positive pressure everywhere. -/
theorem radicalElim_eq_pressure_set (I : Ideal (Polynomial R)) :
    (radicalEliminationIdeal I : Set R) =
      {a | ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P →
        primePressureIndicator P a ≤ 0} := by
  ext a
  simp only [SetLike.mem_coe, mem_setOf_eq]
  rw [mem_radicalElim_iff_spectral]
  simp only [spectralElimination, primeCompatible, mem_setOf_eq, primePressureIndicator]
  constructor
  · intro h P hP; simp [h P hP]
  · intro h P hP
    specialize h P hP
    split_ifs at h with hmem
    · exact hmem
    · linarith

/-! ## Axiom verification -/

#print axioms mem_eliminationIdeal_iff
#print axioms mem_radical_iff_mem_all_primeSpectrum
#print axioms mem_radicalElim_iff_spectral
#print axioms radicalElim_eq_spectralElim
#print axioms not_mem_radicalElim_iff_exists_prime_witness
#print axioms radicalElim_eq_variationalKernel
#print axioms spectralElimination_eq_sInter
#print axioms mem_radicalElim_iff_sup_gap_zero
#print axioms exists_positive_pressure_witness
#print axioms radicalElim_eq_pressure_set