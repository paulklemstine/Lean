/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.AutoResearch.ModPSpectralFingerprint.Defs
import Speculative.AutoResearch.ModPSpectralFingerprint.CRT

/-!
# Main Theorems: Mod-p Spectral Fingerprints Determine Expansion

## Overview

This file contains the main structural theorems connecting mod-p spectral
data to real spectral properties of arithmetic graphs.

## Main Results

- `laplacian_entry_determined_by_modp`: Mod-p data for sufficiently many primes
  determines each Laplacian matrix entry exactly.
- `laplacian_determined_by_modp`: The full Laplacian is determined by mod-p data.
- `quadraticForm_determined_by_modp`: Cross-domain bridge — the real quadratic form
  (spectral theory) is determined by finite-field data (arithmetic).
- `spectral_gap_determined_by_modp`: The spectral gap is determined by mod-p data.

## Cross-Domain Connection

The quadratic form determination theorem connects:
- **Number theory / Arithmetic** (mod-p reductions, CRT)
- **Spectral theory** (quadratic forms, eigenvalues)
- **Combinatorial expansion** (edge expansion via spectral gap)

This creates a bridge: finite-field computations → exact matrix recovery →
spectral gap → expansion.
-/

open Finset BigOperators

namespace ModPSpectralFingerprint

/-! ## §1. Laplacian Entry Recovery from Mod-p Data -/

/-- Each entry of the Laplacian is determined by mod-p data when the
    product of primes exceeds twice the entry bound. -/
theorem laplacian_entry_determined_by_modp
    {n : ℕ} (L₁ L₂ : GraphLaplacianData n) {ps : Finset ℕ}
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : ∀ p ∈ ps, L₁.modP p = L₂.modP p)
    (hsuff : (∏ p ∈ ps, p) > 2 * max L₁.maxEntry L₂.maxEntry)
    (i j : Fin n) :
    L₁.entry i j = L₂.entry i j := by
  apply bounded_int_unique_of_agree
  any_goals assumption
  · exact le_trans (L₁.entries_bounded i j) (le_max_left _ _)
  · exact le_trans (L₂.entries_bounded i j) (le_max_right _ _)
  · intro p hp
    specialize hagree p hp
    unfold GraphLaplacianData.modP at hagree
    replace hagree := congr_fun (congr_fun hagree i) j
    simp_all +decide [congMod]
    erw [← ZMod.intCast_zmod_eq_zero_iff_dvd]; aesop

/-- The full Laplacian matrix is determined by mod-p data for sufficiently many primes. -/
theorem laplacian_determined_by_modp
    {n : ℕ} (L₁ L₂ : GraphLaplacianData n) {ps : Finset ℕ}
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : ∀ p ∈ ps, L₁.modP p = L₂.modP p)
    (hsuff : (∏ p ∈ ps, p) > 2 * max L₁.maxEntry L₂.maxEntry) :
    L₁.entry = L₂.entry := by
  funext i j
  exact laplacian_entry_determined_by_modp L₁ L₂ hprimes hagree hsuff i j

/-! ## §2. Quadratic Form and Spectral Theory (Cross-Domain Bridge) -/

/-- The quadratic form associated to a symmetric integer matrix.
    This connects spectral theory to combinatorial properties. -/
noncomputable def quadraticForm (n : ℕ) (L : GraphLaplacianData n) (v : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, (L.entry i j : ℝ) * v i * v j

/-- The quadratic form is symmetric: swapping summation indices preserves the value.
    Uses matrix symmetry (L.symmetric). This is proved by rewriting with
    the symmetry of entries and Finset.sum_comm. -/
theorem quadraticForm_symmetric {n : ℕ} (L : GraphLaplacianData n) (v : Fin n → ℝ) :
    quadraticForm n L v = ∑ i, ∑ j, (L.entry j i : ℝ) * v i * v j := by
  exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by rw [L.symmetric]

/-- **Cross-Domain Bridge**: The quadratic form over ℝ is completely determined by
    mod-p Laplacian data for sufficiently many primes.

    This bridges arithmetic (mod-p data) and spectral theory (quadratic forms):
    - **Input**: Finite-field computations (mod-p matrix reductions)
    - **Output**: Real-valued spectral invariant (quadratic form)

    The proof uses CRT-based matrix recovery. -/
theorem quadraticForm_determined_by_modp
    {n : ℕ} (L₁ L₂ : GraphLaplacianData n) {ps : Finset ℕ}
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : ∀ p ∈ ps, L₁.modP p = L₂.modP p)
    (hsuff : (∏ p ∈ ps, p) > 2 * max L₁.maxEntry L₂.maxEntry)
    (v : Fin n → ℝ) :
    quadraticForm n L₁ v = quadraticForm n L₂ v := by
  unfold quadraticForm
  congr 1; funext i; congr 1; funext j
  have h := laplacian_entry_determined_by_modp L₁ L₂ hprimes hagree hsuff i j
  rw [h]

/-
The quadratic form is bilinear: it equals ∑ᵢⱼ Lᵢⱼ vᵢ vⱼ which can be
    rewritten as vᵀ L v. This commutativity in the arguments follows from
    matrix symmetry and the commutativity of multiplication in ℝ.
-/
theorem quadraticForm_comm {n : ℕ} (L : GraphLaplacianData n) (v : Fin n → ℝ) :
    quadraticForm n L v = ∑ j, ∑ i, (L.entry i j : ℝ) * v i * v j := by
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ L.symmetric ] )

/-! ## §3. Spectral Gap Recovery -/

/-- If two Laplacians have the same entries, they have the same spectral gap. -/
theorem spectral_gap_eq_of_entry_eq {n : ℕ} (L₁ L₂ : GraphLaplacianData n)
    (h : L₁.entry = L₂.entry) :
    rayleighQuotientBound n L₁ = rayleighQuotientBound n L₂ := by
  unfold rayleighQuotientBound
  aesop

/-- **Main Theorem**: The spectral gap is exactly determined by mod-p Laplacian
    data when the product of primes exceeds twice the entry bound.

    This is the finite (non-asymptotic) version of the spectral fingerprint
    determination theorem. It shows that a finite amount of mod-p data
    suffices for exact spectral gap recovery. -/
theorem spectral_gap_determined_by_modp
    {n : ℕ} (L₁ L₂ : GraphLaplacianData n) {ps : Finset ℕ}
    (hprimes : ∀ p ∈ ps, Nat.Prime p)
    (hagree : ∀ p ∈ ps, L₁.modP p = L₂.modP p)
    (hsuff : (∏ p ∈ ps, p) > 2 * max L₁.maxEntry L₂.maxEntry) :
    rayleighQuotientBound n L₁ = rayleighQuotientBound n L₂ :=
  spectral_gap_eq_of_entry_eq L₁ L₂
    (laplacian_determined_by_modp L₁ L₂ hprimes hagree hsuff)

/-! ## §4. Monotonicity: More primes give more information -/

/-
Adding more primes to the fingerprint set only makes recovery easier.
    If a subset of primes suffices, any superset also suffices.
-/
theorem modp_recovery_monotone
    {n : ℕ} (L₁ L₂ : GraphLaplacianData n)
    {ps qs : Finset ℕ} (hsub : ps ⊆ qs)
    (hprimes_q : ∀ p ∈ qs, Nat.Prime p)
    (hagree_q : ∀ p ∈ qs, L₁.modP p = L₂.modP p)
    (hsuff : (∏ p ∈ ps, p) > 2 * max L₁.maxEntry L₂.maxEntry) :
    L₁.entry = L₂.entry := by
  apply laplacian_determined_by_modp;
  exacts [ fun p hp => hprimes_q p ( hsub hp ), fun p hp => hagree_q p ( hsub hp ), hsuff ]

/-! ## §5. Prime Counting and Asymptotic Sufficiency -/

/-- The number of primes up to x grows without bound.
    Combined with the prime product growing faster than any polynomial,
    this ensures that for large enough N, primes up to C·log(N) suffice. -/
theorem prime_count_unbounded :
    ∀ k : ℕ, ∃ ps : Finset ℕ, (∀ p ∈ ps, Nat.Prime p) ∧ ps.card ≥ k := by
  intro k
  have h_inf_primes : Set.Infinite {p : ℕ | Nat.Prime p} :=
    Nat.infinite_setOf_prime
  obtain ⟨ps, hps⟩ : ∃ ps : Finset ℕ, (∀ p ∈ ps, Nat.Prime p) ∧ ps.card ≥ k := by
    have := h_inf_primes.exists_subset_card_eq k; aesop
  use ps

/-! ## §6. Falsifiable Conjecture -/

/-- **Conjecture (Testable Prediction)**:
    For the family of Cayley graphs of PSL₂(𝔽_q) with standard generators,
    as q ranges over primes, the mod-p Laplacian data for primes p ≤ 3·log(q)
    determines the spectral gap up to error at most 1/log(q).

    **Test**: Compute the Laplacian of PSL₂(𝔽_q) for q = 5, 7, 11, 13, ..., 97.
    For each q, compute mod-p reductions for p ≤ 3·log(q). Verify that the
    reconstructed spectral gap matches the true spectral gap (computed over ℝ)
    to within 1/log(q).

    **Refutation**: Find two Cayley graphs with different real spectral gaps
    but identical mod-p data for all p ≤ 3·log(q). -/
def cayleySpectralFingerprint_conjecture : Prop :=
  ∀ ε : ℝ, ε > 0 →
  ∃ q₀ : ℕ,
  ∀ q : ℕ, Nat.Prime q → q ≥ q₀ →
  ∀ (L₁ L₂ : GraphLaplacianData q),
    L₁.maxEntry ≤ q → L₂.maxEntry ≤ q →
    (∀ p : ℕ, Nat.Prime p → (p : ℝ) ≤ 3 * Real.log q →
      L₁.modP p = L₂.modP p) →
    |rayleighQuotientBound q L₁ - rayleighQuotientBound q L₂| ≤ ε

end ModPSpectralFingerprint