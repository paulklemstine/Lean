/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Number theory inside the ultrapower: hyperprimes, Fermat and Wilson

We continue the study of the ultrapower `HyperNat` of `ℕ` (see
`Novelty.NonstandardArithmetic` and `Novelty.NonstandardInternalSets`) and ask
which theorems of elementary number theory survive in the nonstandard model.

Internal arithmetic operations are obtained by lifting the ordinary ones with
`Germ.map`/`Germ.map₂`: truncated subtraction `hsub`, exponentiation with a
*hypernatural exponent* `hpow`, and the internal factorial `hfact`.  With these
we prove:

* `exists_unlimited_hyperprime` — there are unlimited (i.e. nonstandard) primes;
* `exists_least_hyperprime_gt` — Euclid's theorem survives in the sharp form
  "every hypernatural is followed by a *least* hyperprime", which combines the
  internal least number principle with pointwise Euclid;
* `hyper_fermat` — Fermat's little theorem `P ∣ A ^ P - A` holds with both the
  base and the exponent nonstandard;
* `hyper_wilson` — Wilson's theorem `P ∣ (P - 1)! + 1` holds for the internal
  factorial;
* `unlimited_hyperprime_not_even` — unlimited hyperprimes are odd,
  showing that the elementary parity obstruction survives.
-/

import Novelty.NonstandardInternalSets
import Mathlib.NumberTheory.Wilson
import Mathlib.Data.Nat.Nth
import Mathlib.NumberTheory.PrimeCounting
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-! ## Internal operations and predicates -/

/-- Truncated subtraction, lifted to the ultrapower. -/
noncomputable def hsub (A B : HyperNat) : HyperNat := Filter.Germ.map₂ (· - ·) A B

/-- Exponentiation with a hypernatural exponent. -/
noncomputable def hpow (A B : HyperNat) : HyperNat := Filter.Germ.map₂ (· ^ ·) A B

/-- The internal factorial. -/
noncomputable def hfact (A : HyperNat) : HyperNat := Filter.Germ.map Nat.factorial A

/-- Divisibility in the ultrapower. -/
def HyperDvd (A B : HyperNat) : Prop := Filter.Germ.LiftRel (· ∣ ·) A B

/-- A hypernatural is a *hyperprime* when almost all of its coordinates are
prime; equivalently, when it satisfies the transferred primality predicate. -/
def IsHyperPrime (P : HyperNat) : Prop := Filter.Germ.LiftPred Nat.Prime P

theorem isHyperPrime_coe (f : ℕ → ℕ) :
    IsHyperPrime (f : HyperNat) ↔ ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), (f i).Prime :=
  Filter.Germ.liftPred_coe

theorem hyperDvd_coe (f g : ℕ → ℕ) :
    HyperDvd (f : HyperNat) (g : HyperNat) ↔
      ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), f i ∣ g i :=
  Filter.Germ.liftRel_coe

/-! ## Auxiliary standard facts -/

/-- Fermat's little theorem in the form `p ∣ a ^ p - a` (truncated subtraction
in `ℕ`). -/
theorem nat_dvd_pow_sub_self {p : ℕ} (a : ℕ) (hp : p.Prime) : p ∣ a ^ p - a := by
  haveI : Fact p.Prime := ⟨hp⟩
  have h1 : a ≤ a ^ p := Nat.le_self_pow hp.pos.ne' a
  have h2 : ((a ^ p - a : ℕ) : ZMod p) = 0 := by
    rw [Nat.cast_sub h1]
    push_cast
    rw [ZMod.pow_card]
    ring
  exact (ZMod.natCast_eq_zero_iff _ _).mp h2

/-- Wilson's theorem in divisibility form. -/
theorem nat_dvd_factorial_pred_add_one {p : ℕ} (hp : p.Prime) :
    p ∣ (p - 1).factorial + 1 := by
  have h1 : (((p - 1).factorial : ℕ) : ZMod p) = -1 :=
    (Nat.prime_iff_fac_equiv_neg_one hp.ne_one).mp hp
  have h2 : ((((p - 1).factorial + 1 : ℕ)) : ZMod p) = 0 := by
    push_cast [h1]
    ring
  exact (ZMod.natCast_eq_zero_iff _ _).mp h2

/-! ## Unlimited primes -/

/-- **There exist unlimited hyperprimes.**  The germ of the sequence of ordinary
primes is prime in the model and dominates every standard natural, so Euclid's
theorem produces genuinely nonstandard primes. -/
theorem exists_unlimited_hyperprime : ∃ P : HyperNat, IsHyperPrime P ∧ IsUnlimited P := by
  refine ⟨((fun i => Nat.nth Nat.Prime i : ℕ → ℕ) : HyperNat), ?_, ?_⟩
  · rw [isHyperPrime_coe]
    exact Filter.Eventually.of_forall (fun i => Nat.prime_nth_prime i)
  · rw [isUnlimited_coe]
    intro n
    filter_upwards [eventually_ge_hyperfilter (n + 1)] with i hi
    have hmono : Nat.nth Nat.Prime n < Nat.nth Nat.Prime i :=
      (Nat.nth_lt_nth Nat.infinite_setOf_prime).mpr (by omega)
    have hle : n ≤ Nat.nth Nat.Prime n :=
      Nat.le_nth (fun hf => absurd hf Nat.infinite_setOf_prime)
    omega

/-- **Euclid's theorem survives in sharp form**: above every hypernatural there
is a *least* hyperprime.  The proof combines pointwise Euclid with the internal
least number principle. -/
theorem exists_least_hyperprime_gt (H : HyperNat) :
    ∃ P : HyperNat, IsHyperPrime P ∧ H < P ∧
      ∀ Q : HyperNat, IsHyperPrime Q → H < Q → P ≤ Q := by
  refine Filter.Germ.inductionOn H (fun f => ?_)
  classical
  set A : ℕ → Set ℕ := fun i => {p | p.Prime ∧ f i < p} with hA
  have hmem : ∀ Q : HyperNat, Q ∈* (A : InternalSet) ↔
      (IsHyperPrime Q ∧ (f : HyperNat) < Q) := by
    intro Q
    refine Filter.Germ.inductionOn Q (fun g => ?_)
    rw [internalMem_coe, isHyperPrime_coe, Filter.Germ.coe_lt, ← Filter.eventually_and]
    rfl
  have hne : ∃ Q : HyperNat, Q ∈* (A : InternalSet) := by
    choose p hp1 hp2 using fun i : ℕ => Nat.exists_infinite_primes (f i + 1)
    refine ⟨(p : HyperNat), ?_⟩
    rw [internalMem_coe]
    exact Filter.Eventually.of_forall (fun i => ⟨hp2 i, by have := hp1 i; omega⟩)
  obtain ⟨P, hP, hmin⟩ := internal_least_element (A : InternalSet) hne
  obtain ⟨hP1, hP2⟩ := (hmem P).mp hP
  exact ⟨P, hP1, hP2, fun Q hQ1 hQ2 => hmin Q ((hmem Q).mpr ⟨hQ1, hQ2⟩)⟩

/-! ## Transferred theorems of elementary number theory -/

/-- **Fermat's little theorem transfers**, with nonstandard base *and*
nonstandard exponent. -/
theorem hyper_fermat (A P : HyperNat) (hP : IsHyperPrime P) :
    HyperDvd P (hsub (hpow A P) A) := by
  refine Filter.Germ.inductionOn A (fun a => Filter.Germ.inductionOn P (fun p hp => ?_) hP)
  rw [isHyperPrime_coe] at hp
  show HyperDvd (p : HyperNat) (hsub (hpow (a : HyperNat) (p : HyperNat)) (a : HyperNat))
  rw [hsub, hpow, Filter.Germ.map₂_coe, Filter.Germ.map₂_coe, hyperDvd_coe]
  filter_upwards [hp] with i hi
  exact nat_dvd_pow_sub_self (a i) hi

/-- **Wilson's theorem transfers** to hyperprimes and the internal factorial. -/
theorem hyper_wilson (P : HyperNat) (hP : IsHyperPrime P) :
    HyperDvd P (hfact (hsub P 1) + 1) := by
  refine Filter.Germ.inductionOn P (fun p hp => ?_) hP
  rw [isHyperPrime_coe] at hp
  show HyperDvd (p : HyperNat) (hfact (hsub (p : HyperNat) 1) + 1)
  have h1 : (1 : HyperNat) = ((fun _ : ℕ => 1 : ℕ → ℕ) : HyperNat) := Filter.Germ.coe_one.symm
  rw [h1, hsub, Filter.Germ.map₂_coe, hfact, Filter.Germ.map_coe, ← Filter.Germ.coe_add,
    hyperDvd_coe]
  filter_upwards [hp] with i hi
  simpa using nat_dvd_factorial_pred_add_one hi

/-- Unlimited hyperprimes are odd: `2` does not divide them.  The elementary
parity obstruction survives in the nonstandard model. -/
theorem unlimited_hyperprime_not_even (P : HyperNat) (hP : IsHyperPrime P)
    (hU : IsUnlimited P) : ¬ HyperDvd (standard 2) P := by
  refine Filter.Germ.inductionOn P (fun p hp hU hdvd => ?_) hP hU
  rw [isHyperPrime_coe] at hp
  rw [isUnlimited_coe] at hU
  rw [standard_eq_coe, hyperDvd_coe] at hdvd
  have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
    filter_upwards [hp, hU 2, hdvd] with i h1 h2 h3
    rcases (Nat.Prime.eq_one_or_self_of_dvd h1 2 h3) with h | h <;> omega
  rw [Filter.eventually_false_iff_eq_bot] at hfalse
  exact Filter.NeBot.ne inferInstance hfalse

end NonstandardArithmetic