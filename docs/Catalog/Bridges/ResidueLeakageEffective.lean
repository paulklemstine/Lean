/-
# The compensator lives in a single unit class: effective no-pruning (conjecture C1)

Ninth file of the residue-leakage thread.  `dirichlet_no_pruning` is purely
existential: it invokes Dirichlet's theorem to produce a compensating prime `q`
with `F_A(p·q) = F_A(N₀)`, with no control on the size of `q`.  Conjecture C1 of
`FUTURE_DIRECTIONS.md` asks for an *effective* version.

This file isolates exactly the arithmetic content of that conjecture and
reduces it to a statement about primes in arithmetic progressions:

* `compensating_class_coprime` / `compensating_class_works` — the compensating
  set is a **full unit class modulo the conductor**: *every* prime
  `q ≡ N₀·p (mod 4∏A)` compensates, and `N₀·p` is a unit mod `4∏A`.
  No analytic input at all is used here; this is a congruence statement.
* `effective_no_pruning_of_linnik` — consequently, *any* effective bound `B` for
  the least prime in a coprime residue class modulo `4∏A` is inherited verbatim
  by the compensator.  Linnik's theorem (`B = C·M^L`) therefore turns
  no-pruning into a constructive, polynomial-time defeat of the residue sieve.
  The hypothesis is a genuine (classically true) statement about the modulus
  `4∏A`, supplied as an explicit assumption rather than assumed as an axiom.
* `no_pruning_of_dirichlet_class` — conversely, the qualitative theorem is
  recovered from the same lemma plus infinitude of primes in the class, showing
  that the congruence lemma is the *whole* non-analytic content of no-pruning.
-/

import Mathlib
import Bridges.ResidueLeakageDirichletNoPruning

namespace Bridges.ResidueLeakage

variable {A : List ℕ}

/-- The compensating residue `N₀ · p` is a unit modulo the conductor `4∏A`. -/
theorem compensating_class_coprime (hA : ∀ a ∈ A, a.Prime) {N₀ p : ℕ}
    (hN₀ : Odd N₀) (hp : p.Prime) (hpodd : Odd p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p) :
    Nat.Coprime (N₀ * p) (qrConductor A) :=
  coprime_conductor (hN₀.mul hpodd) fun a ha =>
    Nat.Coprime.mul_left (hNA a ha)
      ((Nat.coprime_primes hp (hA a ha)).2 fun h => hpA a ha h.symm)

/-- **The compensating set is a full unit class.**  Every prime `q` congruent to
`N₀·p` modulo the conductor `4∏A` compensates: the semiprime `p·q` has exactly
the observed fingerprint.  This is the entire non-analytic content of the
no-pruning theorem — a congruence condition modulo a fixed modulus, with no
appeal to Dirichlet. -/
theorem compensating_class_works (hA : ∀ a ∈ A, a.Prime) {N₀ p q : ℕ}
    (hN₀ : Odd N₀) (hp : p.Prime) (hpodd : Odd p) (hq : q.Prime)
    (hpA : ∀ a ∈ A, a ≠ p) (hcong : q ≡ N₀ * p [MOD qrConductor A]) :
    qrFingerprint A (p * q) = qrFingerprint A N₀ := by
  have hN0 : N₀ ≠ 0 := by rintro rfl; simp at hN₀
  haveI : NeZero N₀ := ⟨hN0⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  haveI : NeZero q := ⟨hq.ne_zero⟩
  have hmodd : Odd (N₀ * p) := hN₀.mul hpodd
  -- `q` is odd because `2 ∣ 4∏A`
  have h2 : (2 : ℕ) ∣ qrConductor A := ⟨2 * A.prod, by rw [qrConductor]; ring⟩
  have hqodd : Odd q := by
    have h2' : q % 2 = (N₀ * p) % 2 := hcong.of_dvd h2
    rw [Nat.odd_iff] at hmodd ⊢
    omega
  -- the fingerprint only sees the class mod `4a` for each probe `a`
  have hsym : ∀ a ∈ A, jacobiSym (a : ℤ) q = jacobiSym (a : ℤ) (N₀ * p) := by
    intro a ha
    have hdvd : 4 * a ∣ qrConductor A := mul_dvd_mul_left 4 (List.dvd_prod ha)
    have h' : q % (4 * a) = (N₀ * p) % (4 * a) := hcong.of_dvd hdvd
    rw [jacobiSym.mod_right' a hqodd, jacobiSym.mod_right' a hmodd, h']
  refine qrFingerprint_congr fun a ha => ?_
  have hsq : jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) p = 1 := by
    have hcop : Int.gcd (a : ℤ) (p : ℕ) = 1 := by
      simpa [Int.gcd_natCast_natCast] using
        (Nat.coprime_primes (hA a ha) hp).2 (hpA a ha)
    rcases jacobiSym.eq_one_or_neg_one hcop with h | h <;> rw [h] <;> norm_num
  calc jacobiSym (a : ℤ) (p * q)
      = jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) q := jacobiSym.mul_right _ _ _
    _ = jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) (N₀ * p) := by rw [hsym a ha]
    _ = jacobiSym (a : ℤ) N₀ * (jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) p) := by
        rw [jacobiSym.mul_right (a : ℤ) N₀ p]; ring
    _ = jacobiSym (a : ℤ) N₀ := by rw [hsq, mul_one]

/-- **Effective no-pruning (conditional form of C1).**  Suppose `B` bounds the
least prime in every unit class modulo the conductor `4∏A` — this is exactly
what Linnik's theorem provides, with `B = C·(4∏A)^L`.  Then for every candidate
prime `p` there is a compensating prime `q ≤ B`: the residue sieve is defeated
*constructively*, not merely in principle.

The Linnik-type input is an explicit hypothesis on the modulus `qrConductor A`;
no unproved statement is assumed globally. -/
theorem effective_no_pruning_of_linnik (hA : ∀ a ∈ A, a.Prime) {N₀ p B : ℕ}
    (hN₀ : Odd N₀) (hp : p.Prime) (hpodd : Odd p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p)
    (hlinnik : ∀ r : ℕ, Nat.Coprime r (qrConductor A) →
      ∃ q ≤ B, q.Prime ∧ q ≡ r [MOD qrConductor A]) :
    ∃ q ≤ B, q.Prime ∧ qrFingerprint A (p * q) = qrFingerprint A N₀ := by
  obtain ⟨q, hqB, hq, hcong⟩ :=
    hlinnik (N₀ * p) (compensating_class_coprime hA hN₀ hp hpodd hNA hpA)
  exact ⟨q, hqB, hq, compensating_class_works hA hN₀ hp hpodd hq hpA hcong⟩

/-- **The qualitative theorem, re-derived from the congruence lemma.**  Feeding
Dirichlet's theorem (infinitude of primes in the unit class `N₀·p`) into
`compensating_class_works` recovers `dirichlet_no_pruning`.  This exhibits the
clean split of the argument: one congruence lemma plus one analytic input. -/
theorem no_pruning_of_dirichlet_class (hA : ∀ a ∈ A, a.Prime) {N₀ p : ℕ}
    (hN₀ : Odd N₀) (hp : p.Prime) (hpodd : Odd p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p) :
    {q : ℕ | q.Prime ∧ qrFingerprint A (p * q) = qrFingerprint A N₀}.Infinite := by
  have hM0 : qrConductor A ≠ 0 := conductor_ne_zero A hA
  haveI : NeZero (qrConductor A) := ⟨hM0⟩
  have hunit : IsUnit ((N₀ * p : ℕ) : ZMod (qrConductor A)) :=
    (ZMod.isUnit_iff_coprime _ _).2 (compensating_class_coprime hA hN₀ hp hpodd hNA hpA)
  refine (Nat.infinite_setOf_prime_and_eq_mod hunit).mono ?_
  rintro q ⟨hq, hqm⟩
  have hcong : q ≡ N₀ * p [MOD qrConductor A] :=
    (ZMod.natCast_eq_natCast_iff _ _ _).1 hqm
  exact ⟨hq, compensating_class_works hA hN₀ hp hpodd hq hpA hcong⟩

end Bridges.ResidueLeakage