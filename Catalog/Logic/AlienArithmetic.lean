import Mathlib

/-!
# Alien arithmetic: would a non-human intelligence discover primes?

The companion file `UniversalMathematics.lean` asks *which theorems* any
sufficiently expressive reasoner must accept.  Here we ask a sharper, concrete
version of the same question for number theory: **would aliens discover primes?**

Our answer is that primes are not a human convention but a *definitional
invariant* of the multiplicative structure of the natural numbers.  Any
intelligence that has

* the divisibility relation `∣`, or equivalently
* multiplication of counting numbers,

is forced to the very same set of primes.  We make this precise with several
characterizations that pin down "prime" using only structure any counting
intelligence possesses, together with the classical facts (infinitude, existence
and uniqueness of factorization) that make primes the fundamental building
blocks.

* `prime_iff_divisibility` — primes are definable from the *divisibility order
  alone*: `p` is prime iff `p ≥ 2` and its only divisors are `1` and `p`.
* `prime_iff_indecomposable` — primes are the *multiplicatively indecomposable*
  numbers: those `≥ 2` that are not a product of two smaller factors.
* `prime_iff_algebraic` — the arithmetic notion of prime coincides with the
  general algebraic notions `Prime` and `Irreducible`, which make sense in *any*
  commutative monoid.  An alien algebra recovers exactly our primes.
* `minFac_is_prime` — the smallest factor `> 1` of any `n ≥ 2` is always prime:
  the canonical, universal way to *find* a prime.
* `infinitude_of_primes` / `setOf_primes_infinite` — there are infinitely many
  primes (Euclid).
* `factorization_exists` / `factorization_unique` — every positive number
  factors into primes, uniquely up to reordering (the Fundamental Theorem of
  Arithmetic).
-/

namespace AlienArithmetic

/-! ## Primes are definable from structure any counting intelligence has -/

/-- **Primes from the divisibility order.**  A number is prime exactly when it is
at least `2` and its only divisors are `1` and itself.  This uses nothing beyond
the relation `∣`, so any intelligence that can ask "does `a` divide `b`?"
isolates the same primes. -/
theorem prime_iff_divisibility (p : ℕ) :
    p.Prime ↔ 2 ≤ p ∧ ∀ d, d ∣ p → d = 1 ∨ d = p := by
  rw [Nat.prime_def]

/-- **Primes as the multiplicatively indecomposable numbers.**  A number `≥ 2` is
prime exactly when it cannot be written as a product of two factors each `≥ 2`.
This is the notion an intelligence reaches by trying to *break numbers apart*
under multiplication. -/
theorem prime_iff_indecomposable (p : ℕ) (hp : 2 ≤ p) :
    p.Prime ↔ ¬ ∃ a b, 2 ≤ a ∧ 2 ≤ b ∧ p = a * b := by
  rw [Nat.prime_def]
  constructor
  · rintro ⟨_, hdvd⟩ ⟨a, b, ha, hb, rfl⟩
    rcases hdvd a ⟨b, rfl⟩ with h | h
    · omega
    · nlinarith [h]
  · intro h
    refine ⟨hp, ?_⟩
    rintro d ⟨c, rfl⟩
    by_contra hcon
    push_neg at hcon
    obtain ⟨hd1, _⟩ := hcon
    have hd0 : d ≠ 0 := by rintro rfl; simp at hp
    have hc0 : c ≠ 0 := by rintro rfl; simp at hp
    have hd2 : 2 ≤ d := by omega
    have hc2 : 2 ≤ c := by
      rcases Nat.lt_or_ge c 2 with hc | hc
      · interval_cases c <;> omega
      · exact hc
    exact h ⟨d, c, hd2, hc2, rfl⟩

/-- **Primes are the general algebraic notion.**  In `ℕ`, being `Nat.Prime` is the
same as being `Prime` (no unit factors) and the same as being `Irreducible` in
the abstract sense.  These definitions live in *any* commutative monoid, so an
alien who axiomatizes multiplication abstractly recovers exactly our primes. -/
theorem prime_iff_algebraic (p : ℕ) :
    p.Prime ↔ Prime p ∧ Irreducible p := by
  rw [Nat.prime_iff]
  exact ⟨fun h => ⟨h, (irreducible_iff_prime).2 h⟩, fun h => h.1⟩

/-! ## Finding a prime: the smallest nontrivial factor -/

/-- **The canonical prime finder.**  For any `n ≥ 2`, the least factor of `n`
that exceeds `1` is prime and divides `n`.  This is the algorithm any counting
intelligence uses to produce a prime from an arbitrary number, so it converges on
our primes. -/
theorem minFac_is_prime (n : ℕ) (hn : 2 ≤ n) :
    (n.minFac).Prime ∧ n.minFac ∣ n :=
  ⟨Nat.minFac_prime (by omega), Nat.minFac_dvd n⟩

/-! ## There are infinitely many primes (Euclid) -/

/-- **Euclid's theorem.**  Beyond every bound there is a prime; primes never run
out.  No finite intelligence exhausts them. -/
theorem infinitude_of_primes (n : ℕ) : ∃ p, n ≤ p ∧ p.Prime :=
  Nat.exists_infinite_primes n

/-- The set of primes is infinite. -/
theorem setOf_primes_infinite : {p : ℕ | p.Prime}.Infinite :=
  Nat.infinite_setOf_prime

/-! ## The Fundamental Theorem of Arithmetic -/

/-- **Existence of prime factorization.**  Every positive natural number is a
product of primes. -/
theorem factorization_exists (n : ℕ) (hn : n ≠ 0) :
    ∃ l : List ℕ, (∀ p ∈ l, p.Prime) ∧ l.prod = n :=
  ⟨n.primeFactorsList, fun _ hp => Nat.prime_of_mem_primeFactorsList hp,
    Nat.prod_primeFactorsList hn⟩

/-- **Uniqueness of prime factorization.**  Any two prime-factorization lists of
the same number are permutations of each other: the multiset of prime factors is
an invariant of the number, independent of how it was produced.  Together with
`factorization_exists` this is the Fundamental Theorem of Arithmetic — the
structural reason every intelligence agrees on the "atoms" of a number. -/
theorem factorization_unique {n : ℕ} {l₁ l₂ : List ℕ}
    (h₁ : l₁.prod = n) (hp₁ : ∀ p ∈ l₁, p.Prime)
    (h₂ : l₂.prod = n) (hp₂ : ∀ p ∈ l₂, p.Prime) :
    l₁.Perm l₂ := by
  have e₁ : l₁.Perm n.primeFactorsList := Nat.primeFactorsList_unique h₁ hp₁
  have e₂ : l₂.Perm n.primeFactorsList := Nat.primeFactorsList_unique h₂ hp₂
  exact e₁.trans e₂.symm

end AlienArithmetic