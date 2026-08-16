/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Prime-free galaxies: a conjecture and its refutation

`exists_least_hyperprime_gt` shows that hyperprimes are unbounded in the
ultrapower.  A natural strengthening is:

> *every galaxy of the ultrapower contains a hyperprime.*

This file **refutes** that conjecture.  Unbounded prime gaps, in the classical
form "`i! + j` is composite for `2 ≤ j ≤ i`", transfer to a hypernatural whose
entire galaxy — everything within a standard distance of it — consists of
composite numbers.  Formally

* `exists_primeFree_galaxy` : there is an unlimited `H` such that no hyperprime
  lies in the galaxy of `H`;
* `no_prime_galaxy_between` : more strongly, a whole *interval* of galaxies can
  be prime-free, so the prime-carrying galaxies are not even dense in the
  galaxy order;
* `exists_prime_galaxy` : some galaxies do contain hyperprimes,

so the galaxy order of the model is genuinely partitioned into prime-carrying
and prime-free scales.  The witness is the germ of `i! + i / 2`, sitting in the
middle of the composite run `i! + 2, …, i! + i`.
-/

import Novelty.NonstandardGalaxies
import Novelty.NonstandardPrimes
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-- The classical long composite run: `i ! + j` is not prime for `2 ≤ j ≤ i`. -/
theorem not_prime_factorial_add {i j : ℕ} (h2 : 2 ≤ j) (hj : j ≤ i) :
    ¬ Nat.Prime (i.factorial + j) := by
  intro hp
  have hdvd : j ∣ i.factorial + j :=
    Nat.dvd_add (Nat.dvd_factorial (by omega) hj) dvd_rfl
  have hfac : 0 < i.factorial := Nat.factorial_pos i
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp j hdvd) with h | h <;> omega

/-- The hypernatural sitting in the middle of the composite run. -/
noncomputable def compositeCentre : HyperNat :=
  ((fun i => i.factorial + i / 2 : ℕ → ℕ) : HyperNat)

theorem isUnlimited_compositeCentre : IsUnlimited compositeCentre := by
  rw [compositeCentre, isUnlimited_coe]
  intro n
  filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
  have := Nat.self_le_factorial i
  omega

/-- **Refutation of "every galaxy contains a hyperprime".**  No hyperprime is
within a standard distance of `[i! + i/2]`. -/
theorem exists_primeFree_galaxy :
    ∃ H : HyperNat, IsUnlimited H ∧ ∀ P : HyperNat, IsHyperPrime P → ¬ SameGalaxy P H := by
  refine ⟨compositeCentre, isUnlimited_compositeCentre, ?_⟩
  intro P hP hgal
  refine Filter.Germ.inductionOn P (fun p hP hgal => ?_) hP hgal
  rw [isHyperPrime_coe] at hP
  rw [compositeCentre, sameGalaxy_coe] at hgal
  obtain ⟨m, h1, h2⟩ := hgal
  have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
    filter_upwards [hP, h1, h2, eventually_ge_hyperfilter (2 * m + 8)] with i hp hle1 hle2 hi
    have hfac : 0 < i.factorial := Nat.factorial_pos i
    -- `p i = i ! + j` with `2 ≤ j ≤ i`, so `p i` is composite
    have hj2 : 2 ≤ p i - i.factorial := by omega
    have hji : p i - i.factorial ≤ i := by omega
    have heq : i.factorial + (p i - i.factorial) = p i := by omega
    have hp' : Nat.Prime (i.factorial + (p i - i.factorial)) := by rw [heq]; exact hp
    exact not_prime_factorial_add hj2 hji hp'
  rw [Filter.eventually_false_iff_eq_bot] at hfalse
  exact Filter.NeBot.ne inferInstance hfalse

/-- **A whole interval of galaxies can be prime-free.**  Between the galaxy of
`[i!]` and the galaxy of `[i! + i]` — which are strictly separated — there is
no galaxy containing a hyperprime.  Hence the prime-carrying galaxies are not
even dense in the galaxy order. -/
theorem no_prime_galaxy_between :
    ∃ H K : HyperNat, Far H K ∧ ∀ P : HyperNat, IsHyperPrime P → ¬ (Far H P ∧ Far P K) := by
  refine ⟨((fun i => i.factorial : ℕ → ℕ) : HyperNat),
    ((fun i => i.factorial + i : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [far_coe]
    intro n
    filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
    omega
  · rintro P hP ⟨hf1, hf2⟩
    refine Filter.Germ.inductionOn P (fun p hP hf1 hf2 => ?_) hP hf1 hf2
    rw [isHyperPrime_coe] at hP
    rw [far_coe] at hf1 hf2
    have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
      filter_upwards [hP, hf1 3, hf2 3, eventually_ge_hyperfilter 8] with i hp h1 h2 hi
      have hfac : 0 < i.factorial := Nat.factorial_pos i
      have hj2 : 2 ≤ p i - i.factorial := by omega
      have hji : p i - i.factorial ≤ i := by omega
      have heq : i.factorial + (p i - i.factorial) = p i := by omega
      have hp' : Nat.Prime (i.factorial + (p i - i.factorial)) := by rw [heq]; exact hp
      exact not_prime_factorial_add hj2 hji hp'
    rw [Filter.eventually_false_iff_eq_bot] at hfalse
    exact Filter.NeBot.ne inferInstance hfalse

/-- Some galaxies do contain hyperprimes: the germ of the sequence of primes is
an unlimited hyperprime, trivially in its own galaxy.  Together with
`exists_primeFree_galaxy` this shows that primality genuinely distinguishes
galaxies. -/
theorem exists_prime_galaxy :
    ∃ H : HyperNat, IsUnlimited H ∧ ∃ P : HyperNat, IsHyperPrime P ∧ SameGalaxy P H := by
  obtain ⟨P, hP, hU⟩ := exists_unlimited_hyperprime
  exact ⟨P, hU, P, hP, sameGalaxy_refl P⟩

end NonstandardArithmetic