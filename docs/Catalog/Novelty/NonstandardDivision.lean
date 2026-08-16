/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Euclidean division, gcd's and prime factors in the ultrapower

Which *algorithmic* theorems of arithmetic survive in a non-Archimedean model?
Here we show that the Euclidean structure survives completely, even though the
order is not a well-order (`NonstandardArithmetic.no_least_unlimited`) and the
Archimedean property fails at densely many scales
(`NonstandardArithmetic.far_dense`).

Main results:

* `hyper_euclidean_division` — existence **and uniqueness** of quotient and
  remainder for an arbitrary nonzero hypernatural divisor;
* `hyper_gcd_dvd_left/right`, `hyper_dvd_gcd` — the internal gcd is a greatest
  common divisor in the model;
* `exists_hyperprime_dvd` — every hypernatural `> 1`, standard or not, has a
  hyperprime divisor: the first step of unique factorisation survives.
-/

import Novelty.NonstandardPrimes
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-- Internal quotient. -/
noncomputable def hdiv (A B : HyperNat) : HyperNat := Filter.Germ.map₂ (· / ·) A B

/-- Internal remainder. -/
noncomputable def hmod (A B : HyperNat) : HyperNat := Filter.Germ.map₂ (· % ·) A B

/-- Internal gcd. -/
noncomputable def hgcd (A B : HyperNat) : HyperNat := Filter.Germ.map₂ Nat.gcd A B

/-- A germ is nonzero exactly when almost all of its coordinates are. -/
theorem coe_ne_zero_iff {f : ℕ → ℕ} :
    (f : HyperNat) ≠ 0 ↔ ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), f i ≠ 0 := by
  have h0 : (0 : HyperNat) = ((fun _ : ℕ => 0 : ℕ → ℕ) : HyperNat) := Filter.Germ.coe_zero.symm
  rw [h0, Ne, Filter.Germ.coe_eq]
  exact Ultrafilter.eventually_not.symm

/-- **The division algorithm survives**, with a unique quotient and remainder,
for arbitrary (possibly unlimited) hypernaturals. -/
theorem hyper_euclidean_division (A B : HyperNat) (hB : B ≠ 0) :
    ∃ Q R : HyperNat, A = B * Q + R ∧ R < B ∧
      ∀ Q' R' : HyperNat, A = B * Q' + R' → R' < B → Q' = Q ∧ R' = R := by
  refine Filter.Germ.inductionOn A (fun a => Filter.Germ.inductionOn B (fun b hB => ?_)) hB
  rw [coe_ne_zero_iff] at hB
  refine ⟨hdiv (a : HyperNat) (b : HyperNat), hmod (a : HyperNat) (b : HyperNat), ?_, ?_, ?_⟩
  · rw [hdiv, hmod, Filter.Germ.map₂_coe, Filter.Germ.map₂_coe, ← Filter.Germ.coe_mul,
      ← Filter.Germ.coe_add, Filter.Germ.coe_eq]
    filter_upwards [hB] with i hi
    simp only [Pi.add_apply, Pi.mul_apply]
    exact (Nat.div_add_mod (a i) (b i)).symm
  · rw [hmod, Filter.Germ.map₂_coe, Filter.Germ.coe_lt]
    filter_upwards [hB] with i hi
    exact Nat.mod_lt _ (Nat.pos_of_ne_zero hi)
  · intro Q' R' hEq hlt
    refine Filter.Germ.inductionOn Q' (fun q => Filter.Germ.inductionOn R' (fun r hEq hlt => ?_))
      hEq hlt
    rw [← Filter.Germ.coe_mul, ← Filter.Germ.coe_add, Filter.Germ.coe_eq] at hEq
    rw [Filter.Germ.coe_lt] at hlt
    constructor
    · rw [hdiv, Filter.Germ.map₂_coe, Filter.Germ.coe_eq]
      filter_upwards [hB, hEq, hlt] with i hi h1 h2
      simp only [Pi.add_apply, Pi.mul_apply] at h1
      have hsplit : a i = r i + b i * q i := by omega
      rw [hsplit, Nat.add_mul_div_left _ _ (Nat.pos_of_ne_zero hi), Nat.div_eq_of_lt h2]
      omega
    · rw [hmod, Filter.Germ.map₂_coe, Filter.Germ.coe_eq]
      filter_upwards [hB, hEq, hlt] with i hi h1 h2
      simp only [Pi.add_apply, Pi.mul_apply] at h1
      have hsplit : a i = r i + b i * q i := by omega
      rw [hsplit, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt h2]

/-! ## Greatest common divisors -/

theorem hyper_gcd_dvd_left (A B : HyperNat) : HyperDvd (hgcd A B) A := by
  refine Filter.Germ.inductionOn A (fun a => Filter.Germ.inductionOn B (fun b => ?_))
  rw [hgcd, Filter.Germ.map₂_coe, hyperDvd_coe]
  exact Filter.Eventually.of_forall (fun i => Nat.gcd_dvd_left _ _)

theorem hyper_gcd_dvd_right (A B : HyperNat) : HyperDvd (hgcd A B) B := by
  refine Filter.Germ.inductionOn A (fun a => Filter.Germ.inductionOn B (fun b => ?_))
  rw [hgcd, Filter.Germ.map₂_coe, hyperDvd_coe]
  exact Filter.Eventually.of_forall (fun i => Nat.gcd_dvd_right _ _)

/-- The internal gcd really is a *greatest* common divisor in the nonstandard
model. -/
theorem hyper_dvd_gcd {C A B : HyperNat} (h1 : HyperDvd C A) (h2 : HyperDvd C B) :
    HyperDvd C (hgcd A B) := by
  refine Filter.Germ.inductionOn C (fun c => Filter.Germ.inductionOn A (fun a =>
    Filter.Germ.inductionOn B (fun b h1 h2 => ?_))) h1 h2
  rw [hyperDvd_coe] at h1 h2
  rw [hgcd, Filter.Germ.map₂_coe, hyperDvd_coe]
  filter_upwards [h1, h2] with i hi1 hi2
  exact Nat.dvd_gcd hi1 hi2

/-! ## Prime factors -/

/-- **Every hypernatural greater than `1` has a hyperprime divisor.**  For
unlimited arguments this divisor is produced by the internal `minFac`, so the
existence half of unique factorisation survives. -/
theorem exists_hyperprime_dvd (A : HyperNat) (hA : standard 1 < A) :
    ∃ P : HyperNat, IsHyperPrime P ∧ HyperDvd P A := by
  refine Filter.Germ.inductionOn A (fun a hA => ?_) hA
  rw [standard_eq_coe, Filter.Germ.coe_lt] at hA
  refine ⟨((fun i => (a i).minFac : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [isHyperPrime_coe]
    filter_upwards [hA] with i hi
    exact Nat.minFac_prime (by omega)
  · rw [hyperDvd_coe]
    exact Filter.Eventually.of_forall (fun i => Nat.minFac_dvd _)

/-- A concrete instance: the nonstandard element `ω` has a hyperprime divisor. -/
theorem exists_hyperprime_dvd_omega : ∃ P : HyperNat, IsHyperPrime P ∧ HyperDvd P omega :=
  exists_hyperprime_dvd omega (standard_lt_omega 1)

end NonstandardArithmetic