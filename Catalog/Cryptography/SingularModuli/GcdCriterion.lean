import Cryptography.FactoringBarriers.RandomnessBarrier

/-!
# Singular Moduli Factoring, Step 1: the exact gcd criterion

The *singular moduli* factoring method attacks a semiprime `N = p q` by picking a
discriminant `D`, forming the Hilbert class polynomial `H_D ∈ ℤ[X]` (of degree
`h = h(D)`, the class number), choosing an evaluation point `j₀ ∈ ℤ`, and
computing

  `gcd (H_D(j₀), N)`.

Heuristically this works because `j₀` "is a singular modulus mod `p`" exactly
when `H_D(j₀) ≡ 0 (mod p)`, and the elliptic curve with that `j`-invariant has
CM by the order of discriminant `D`.

This file isolates the *unconditional arithmetic core* of the method, with no
elliptic curves involved: for a semiprime `N = pq` the gcd step returns a
nontrivial factor **iff** `j₀` is a root of `H_D` modulo exactly one of the two
primes, and in that case it returns exactly that prime.  The proof is a
prime-divisor analysis of `gcd (a, pq)` and is completely general in the
polynomial `H`, so it applies verbatim to any "evaluate a fixed integer
polynomial and take a gcd" method.

Main results:

* `evalGcd_eq_one_of_no_root`   — no root: the step returns `1`;
* `evalGcd_eq_left/right`       — root mod exactly one prime: the step returns
  that prime;
* `evalGcd_eq_modulus`          — root mod both primes: the step returns `N`;
* `evalGcd_nontrivialDivisor_iff` — the exact success criterion, an `Xor'`;
* `singularModuli_blind_of_no_roots` — the failure mode: if `H` has no root
  modulo either prime, *every* evaluation point is useless.
-/

namespace SingularModuli

open Polynomial FactoringBarriers

/-- One step of the singular moduli method: evaluate the integer polynomial `H`
at `j` and take the gcd with the modulus `N`. -/
def evalGcd (H : Polynomial ℤ) (j : ℤ) (N : ℕ) : ℕ := Int.gcd (H.eval j) (N : ℤ)

variable {p q : ℕ} {H : Polynomial ℤ} {j : ℤ}

/-- If `j` is not a root of `H` modulo either prime, the gcd step returns `1`.
(Reuses the collision lemma of the randomness barrier file with `b = 0`.) -/
theorem evalGcd_eq_one_of_no_root (hp : p.Prime) (hq : q.Prime)
    (hpd : ¬ (p : ℤ) ∣ H.eval j) (hqd : ¬ (q : ℤ) ∣ H.eval j) :
    evalGcd H j (p * q) = 1 := by
  have := gcd_eq_one_of_no_collision (a := H.eval j) (b := 0) hp hq
    (by simpa using hpd) (by simpa using hqd)
  simpa [evalGcd] using this

/-- The generic divisor computation: `gcd (a, p q) = p` when `p ∣ a` and `q ∤ a`. -/
theorem gcd_eq_of_dvd_left (hp : p.Prime) (hq : q.Prime) {a : ℤ}
    (hpd : (p : ℤ) ∣ a) (hqd : ¬ (q : ℤ) ∣ a) : Int.gcd a ((p * q : ℕ) : ℤ) = p := by
  set d : ℕ := Int.gcd a ((p * q : ℕ) : ℤ) with hd
  have hda : (d : ℤ) ∣ a := Int.gcd_dvd_left _ _
  have hdN : d ∣ p * q := by
    have : (d : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hpdvd : p ∣ d := by
    have hpz : (p : ℤ) ∣ ((p * q : ℕ) : ℤ) := by
      push_cast
      exact Dvd.intro q rfl
    exact Int.dvd_gcd hpd hpz
  have hqnd : ¬ q ∣ d := by
    intro hqdvd
    exact hqd (dvd_trans (by exact_mod_cast hqdvd) hda)
  obtain ⟨k, hk⟩ := hpdvd
  have hkq : k ∣ q := by
    have hpk : p * k ∣ p * q := by rw [← hk]; exact hdN
    exact (mul_dvd_mul_iff_left hp.pos.ne').mp hpk
  rcases (hq.eq_one_or_self_of_dvd k hkq) with h1 | hkq'
  · rw [hk, h1, mul_one]
  · exfalso
    apply hqnd
    rw [hk, hkq']
    exact dvd_mul_left q p

/-- Root modulo `p` only: the gcd step returns the prime `p`. -/
theorem evalGcd_eq_left (hp : p.Prime) (hq : q.Prime)
    (hpd : (p : ℤ) ∣ H.eval j) (hqd : ¬ (q : ℤ) ∣ H.eval j) :
    evalGcd H j (p * q) = p :=
  gcd_eq_of_dvd_left hp hq hpd hqd

/-- Root modulo `q` only: the gcd step returns the prime `q`. -/
theorem evalGcd_eq_right (hp : p.Prime) (hq : q.Prime)
    (hpd : ¬ (p : ℤ) ∣ H.eval j) (hqd : (q : ℤ) ∣ H.eval j) :
    evalGcd H j (p * q) = q := by
  have h := gcd_eq_of_dvd_left hq hp hqd hpd
  rw [mul_comm] at h
  exact h

/-- Root modulo both primes: the gcd step returns the whole modulus, i.e. fails. -/
theorem evalGcd_eq_modulus (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hpd : (p : ℤ) ∣ H.eval j) (hqd : (q : ℤ) ∣ H.eval j) :
    evalGcd H j (p * q) = p * q := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have hpq : ((p * q : ℕ) : ℤ) ∣ H.eval j := by
    have : (p : ℤ) * (q : ℤ) ∣ H.eval j := by
      obtain ⟨c, hc⟩ := hpd
      have hqc : (q : ℤ) ∣ (p : ℤ) * c := by rw [← hc]; exact hqd
      have hcopz : IsCoprime (q : ℤ) (p : ℤ) := by
        rw [Int.isCoprime_iff_gcd_eq_one]
        simpa [Int.gcd_natCast_natCast] using hcop.symm
      obtain ⟨e, he⟩ := hcopz.dvd_of_dvd_mul_left hqc
      exact ⟨e, by rw [hc, he]; ring⟩
    simpa [Nat.cast_mul] using this
  have hdvd1 : evalGcd H j (p * q) ∣ p * q := by
    have : ((evalGcd H j (p * q) : ℕ) : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hdvd2 : p * q ∣ evalGcd H j (p * q) := Int.dvd_gcd hpq dvd_rfl
  exact Nat.dvd_antisymm hdvd1 hdvd2

/-- **The exact success criterion for the singular moduli gcd step.**
For a semiprime `N = p q` with distinct primes, the evaluation point `j`
produces a nontrivial factor of `N` if and only if `j` is a root of `H` modulo
exactly one of `p` and `q`. -/
theorem evalGcd_nontrivialDivisor_iff (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    NontrivialDivisor (p * q) (evalGcd H j (p * q)) ↔
      Xor' ((p : ℤ) ∣ H.eval j) ((q : ℤ) ∣ H.eval j) := by
  have hp1 : 1 < p := hp.one_lt
  have hq1 : 1 < q := hq.one_lt
  constructor
  · intro hnt
    by_cases hpd : (p : ℤ) ∣ H.eval j <;> by_cases hqd : (q : ℤ) ∣ H.eval j
    · rw [evalGcd_eq_modulus hp hq hne hpd hqd] at hnt
      exact absurd hnt.2.2 (lt_irrefl _)
    · exact Or.inl ⟨hpd, hqd⟩
    · exact Or.inr ⟨hqd, hpd⟩
    · rw [evalGcd_eq_one_of_no_root hp hq hpd hqd] at hnt
      exact absurd hnt.2.1 (lt_irrefl _)
  · rintro (⟨hpd, hqd⟩ | ⟨hqd, hpd⟩)
    · rw [evalGcd_eq_left hp hq hpd hqd]
      exact ⟨Dvd.intro q rfl, hp1, by nlinarith⟩
    · rw [evalGcd_eq_right hp hq hpd hqd]
      exact ⟨Dvd.intro_left p rfl, hq1, by nlinarith⟩

/-- **The failure mode.** If the polynomial has no root modulo `p` and no root
modulo `q`, then *no* evaluation point whatsoever yields a factor: the method is
completely blind for that discriminant.  This is the corner case that the
heuristic "`H_D` mod `p` has `h` roots" silently assumes away — `H_D` splits
completely mod `p` only when `D` is a square mod `p`, and otherwise it can have
no root at all. -/
theorem singularModuli_blind_of_no_roots (hp : p.Prime) (hq : q.Prime)
    (hpd : ∀ x : ℤ, ¬ (p : ℤ) ∣ H.eval x) (hqd : ∀ x : ℤ, ¬ (q : ℤ) ∣ H.eval x) :
    ∀ x : ℤ, ¬ NontrivialDivisor (p * q) (evalGcd H x (p * q)) := by
  intro x hcon
  rw [evalGcd_eq_one_of_no_root hp hq (hpd x) (hqd x)] at hcon
  exact absurd hcon.2.1 (lt_irrefl _)

/-- For a semiprime, a successful gcd step returns one of the two prime factors,
so a single success completely factors `N`. -/
theorem evalGcd_success_factors (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hsucc : Xor' ((p : ℤ) ∣ H.eval j) ((q : ℤ) ∣ H.eval j)) :
    evalGcd H j (p * q) = p ∨ evalGcd H j (p * q) = q :=
  nontrivialDivisor_semiprime hp hq
    ((evalGcd_nontrivialDivisor_iff hp hq hne).mpr hsucc)

end SingularModuli