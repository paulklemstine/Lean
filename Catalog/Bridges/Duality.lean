/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Real-Valued Thermodynamic Duality for Prime-Spectral Elimination

This file extends the basic elimination duality to a full real-valued variational
framework and provides the thermodynamic completeness theorem.

## Main results

* `elim_eq_iInter_primes` — elimination as intersection over primes
* `mem_elim_iff_energy_bound` — membership via energy domination
* `thermodynamic_elimination_completeness` — the full completeness theorem
* `exists_energy_separation` — quantitative separation theorem
* `mem_radical_span_iff_all_primes` — base-ring spectral duality
-/

import Bridges.ThermodynamicElimination.Basic

open Set Polynomial Ideal Classical

noncomputable section

universe u

variable {R : Type u} [CommRing R]

/-! ## Real-Valued Energy Evaluation at Primes -/

/-- **Energy evaluation at a prime**: 0 if `C(a) ∈ P`, else 1. -/
def energyEval (P : PrimeSpectrum (Polynomial R)) (a : R) : ℝ :=
  if Polynomial.C a ∈ P.asIdeal then (0 : ℝ) else (1 : ℝ)

theorem energyEval_nonneg (P : PrimeSpectrum (Polynomial R)) (a : R) :
    0 ≤ energyEval P a := by
  simp only [energyEval]; split_ifs <;> norm_num

theorem energyEval_eq_zero_iff (P : PrimeSpectrum (Polynomial R)) (a : R) :
    energyEval P a = 0 ↔ Polynomial.C a ∈ P.asIdeal := by
  unfold energyEval; split_ifs with h <;> simp_all

theorem energyEval_eq_one_iff (P : PrimeSpectrum (Polynomial R)) (a : R) :
    energyEval P a = 1 ↔ Polynomial.C a ∉ P.asIdeal := by
  unfold energyEval; split_ifs with h <;> simp_all

/-! ## Elimination as Prime Intersection -/

/-- **Elimination as intersection over primes**: the radical elimination set
equals the intersection of the zero-energy sets over all compatible primes. -/
theorem elim_eq_iInter_primes (I : Ideal (Polynomial R)) :
    (radicalEliminationIdeal I : Set R) =
      ⋂ (P : PrimeSpectrum (Polynomial R)) (_ : primeCompatible I P),
        {a : R | energyEval P a = 0} := by
  ext a
  simp only [SetLike.mem_coe, mem_iInter, mem_setOf_eq, energyEval_eq_zero_iff]
  exact mem_radicalElim_iff_spectral I a

/-! ## Energy Domination Characterization -/

/-- **Membership via energy domination**: `a ∈ radicalElim(I)` iff energy ≤ 0
at every compatible prime. -/
theorem mem_elim_iff_energy_bound (I : Ideal (Polynomial R)) (a : R) :
    a ∈ radicalEliminationIdeal I ↔
      ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P →
        energyEval P a ≤ 0 := by
  simp only [mem_radicalElim_iff_spectral,
    spectralElimination, primeCompatible, mem_setOf_eq, energyEval]
  constructor
  · intro h P hP; simp [h P hP]
  · intro h P hP
    specialize h P hP
    split_ifs at h with hmem
    · exact hmem
    · linarith

/-- **Membership via zero gap**: `a ∈ radicalElim(I)` iff energy = 0 at every
compatible prime. -/
theorem mem_elim_iff_gap_zero (I : Ideal (Polynomial R)) (a : R) :
    a ∈ radicalEliminationIdeal I ↔
      ∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P →
        energyEval P a = 0 := by
  simp only [mem_radicalElim_iff_spectral, spectralElimination,
    primeCompatible, mem_setOf_eq, energyEval_eq_zero_iff]

/-! ## Thermodynamic Elimination Completeness -/

/-- **Thermodynamic elimination completeness**: the following are all equivalent. -/
theorem thermodynamic_elimination_completeness
    (I : Ideal (Polynomial R)) (a : R) :
    (a ∈ radicalEliminationIdeal I) ↔
    ((∀ P : PrimeSpectrum (Polynomial R), I ≤ P.asIdeal → Polynomial.C a ∈ P.asIdeal) ∧
     (∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P → energyEval P a = 0) ∧
     (∀ P : PrimeSpectrum (Polynomial R), primeCompatible I P → energyEval P a ≤ 0) ∧
     (a ∈ primeVariationalKernelSet I)) := by
  constructor
  · intro h
    exact ⟨(mem_radicalElim_iff_spectral I a).mp h,
           (mem_elim_iff_gap_zero I a).mp h,
           (mem_elim_iff_energy_bound I a).mp h,
           (radicalElim_eq_variationalKernel I ▸ h : a ∈ primeVariationalKernelSet I)⟩
  · intro ⟨h1, _, _, _⟩
    exact (mem_radicalElim_iff_spectral I a).mpr h1

/-! ## Non-Elimination Yields Quantitative Separation -/

/-- **Quantitative separation**: `a ∉ radicalElim(I)` ⟹ ∃ prime with energy = 1. -/
theorem exists_energy_separation
    (I : Ideal (Polynomial R)) (a : R)
    (ha : a ∉ radicalEliminationIdeal I) :
    ∃ P : PrimeSpectrum (Polynomial R),
      primeCompatible I P ∧ energyEval P a = 1 := by
  obtain ⟨P, hP, hnotmem⟩ := exists_prime_witness_of_not_mem_radicalElim I a ha
  exact ⟨P, hP, by simp [energyEval, hnotmem]⟩

/-- **Strict gap**: non-elimination implies a strictly positive energy. -/
theorem exists_positive_gap
    (I : Ideal (Polynomial R)) (a : R)
    (ha : a ∉ radicalEliminationIdeal I) :
    ∃ P : PrimeSpectrum (Polynomial R),
      primeCompatible I P ∧ 0 < energyEval P a := by
  obtain ⟨P, hP, he⟩ := exists_energy_separation I a ha
  exact ⟨P, hP, by rw [he]; norm_num⟩

/-! ## Evaluation Elimination -/

/-- **Evaluation elimination set**: `a` is evaluation-eliminated if evaluating
the polynomials in `I` at any point always yields `a` as a consequence. -/
def evalEliminationSet (I : Ideal (Polynomial R)) : Set R :=
  {a : R | ∀ s : R, a ∈ I.map (Polynomial.evalRingHom s)}

/-- The elimination ideal is contained in the evaluation elimination. -/
theorem eliminationIdeal_le_evalElimination (I : Ideal (Polynomial R)) :
    (eliminationIdeal I : Set R) ⊆ evalEliminationSet I := by
  intro a ha s
  have hca : Polynomial.C a ∈ I := ha
  have : (Polynomial.evalRingHom s) (Polynomial.C a) = a := Polynomial.eval_C
  rw [← this]
  exact Ideal.mem_map_of_mem (Polynomial.evalRingHom s) hca

/-! ## Theory-Based Formulation -/

/-- **Prime compatibility with a theory**: `Q` is compatible with `Γ` if `Γ ⊆ Q`. -/
def primeCompatibleWithTheory (Γ : Set R) (Q : PrimeSpectrum R) : Prop :=
  Γ ⊆ Q.asIdeal

/-- **Base pressure**: 0 if compatible, 1 if not. -/
def basePressure (Γ : Set R) (Q : PrimeSpectrum R) : ℝ :=
  if Γ ⊆ (Q.asIdeal : Set R) then (0 : ℝ) else (1 : ℝ)

/-- **Spectral theory intersection**: `a ∈ √(span Γ)` iff `a` is in every prime
containing `Γ`. -/
theorem mem_radical_span_iff_all_primes (Γ : Set R) (a : R) :
    a ∈ (Ideal.span Γ).radical ↔
      ∀ Q : PrimeSpectrum R, Γ ⊆ Q.asIdeal → a ∈ Q.asIdeal := by
  constructor
  · intro ha Q hQ
    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf] at ha
    exact ha ⟨Ideal.span_le.mpr hQ, Q.isPrime⟩
  · intro ha
    rw [Ideal.radical_eq_sInf, Ideal.mem_sInf]
    intro J ⟨hJ, hJprime⟩
    exact ha ⟨J, hJprime⟩ (fun x hx => hJ (Ideal.subset_span hx))

/-! ## Axiom verification -/

#print axioms elim_eq_iInter_primes
#print axioms mem_elim_iff_energy_bound
#print axioms mem_elim_iff_gap_zero
#print axioms thermodynamic_elimination_completeness
#print axioms exists_energy_separation
#print axioms exists_positive_gap
#print axioms mem_radical_span_iff_all_primes