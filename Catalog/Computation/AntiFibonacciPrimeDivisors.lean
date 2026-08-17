import Novelty.Basic
import Computation.AntiFibonacciResidueSpectrum
import Mathlib

/-!
# Which primes divide an anti-Fibonacci number?

`Computation.AntiFibonacciResidueSpectrum` proves that, modulo an odd prime `p`, the value
`m` is attained by the anti-Fibonacci sequence iff `8m - 7` is a square in `ZMod p`.  Taking
`m = 0` turns this into a *prime divisor* criterion: `p` divides some anti-Fibonacci number
iff `-7` is a quadratic residue mod `p`.  The discriminant `-7 ≡ 1 (mod 4)` is exactly the
situation in which quadratic reciprocity collapses to a single congruence, and we obtain the
clean law

> `p ∣ antiFib n` for some `n` **iff** `p = 7` or `p ≡ 1, 2, 4 (mod 7)`.

This settles conjecture C6 of `FUTURE_DIRECTIONS.md`.  Combining it with Dirichlet's theorem
on primes in arithmetic progressions gives both infinitude statements: infinitely many primes
divide some term, and infinitely many primes divide no term at all — a genuine *avoidance*
phenomenon, in sharp contrast with the Fibonacci sequence, every prime of which divides some
Fibonacci number.

## Main results

* `AntiFibonacciPrimes.isSquare_neg_seven` — for a prime `p ∉ {2, 7}`,
  `IsSquare (-7 : ZMod p) ↔ p % 7 ∈ {1, 2, 4}` (quadratic reciprocity for the discriminant
  `-7`).
* `AntiFibonacciPrimes.prime_dvd_antiFib_iff` — the prime divisor law
  `(∃ n, p ∣ antiFib n) ↔ p = 7 ∨ p % 7 ∈ {1, 2, 4}`.
* `AntiFibonacciPrimes.infinite_divisor_primes` — infinitely many primes divide some term.
* `AntiFibonacciPrimes.infinite_nondivisor_primes` — infinitely many primes divide **no**
  term.  (Fibonacci contrast: there is no such prime for `Nat.fib`.)

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): since `8·antiFib n = (2n-1)² + 7`, the prime divisors of the
sequence should be exactly the primes represented by the quadratic form of discriminant
`-7`, i.e. governed by a congruence mod `7` — the class number of `ℚ(√-7)` being `1`.

Experiment (Experimenter): the primes `p < 100` dividing some anti-Fibonacci number are
`2, 7, 11, 23, 29, 37, 43, 53, 67, 71, 79` (computed in the Evidence section); their
residues mod `7` are `2, 0, 4, 2, 1, 2, 1, 4, 4, 1, 2` — precisely `{0, 1, 2, 4}`.
The non-divisor primes `3, 5, 13, 17, 19, 31, 41, 47, 59, 61, 73, 83, 89, 97` have residues
in `{3, 5, 6}`.

Analysis (Analyst): the mechanism is `legendreSym p (-7) = legendreSym 7 p`.  The two
reciprocity sign factors `(-1)^((p-1)/2)` coming from `-1` and from the reciprocity law for
`7 ≡ 3 (mod 4)` cancel exactly because `-7 ≡ 1 (mod 4)`; that cancellation is the whole
proof, and it is the reason the answer is a congruence mod `7` alone.

Critique (Critic): `p = 2` is not an exception even though the spectrum theorem excludes it:
`2 ∣ antiFib 2 = 2` and `2 % 7 = 2` is in the residue list, so the statement is uniform; only
`p = 7` needs its own disjunct (its residue is `0`).  Both infinitude statements are
unconditional, resting on Mathlib's Dirichlet theorem.
-- !-- Lab Notes -- !--
-/

namespace AntiFibonacciPrimes

open AntiFibonacci ZMod

local instance factSeven : Fact (Nat.Prime 7) := ⟨by norm_num⟩

/-! ### Quadratic reciprocity for the discriminant `-7` -/

/-- The Legendre symbol of `p` at `7` is `1` exactly for the quadratic residues
`1, 2, 4 (mod 7)`. -/
theorem legendreSym_seven_eq_one_iff (p : ℕ) [Fact p.Prime] (hp7 : p ≠ 7) :
    legendreSym 7 p = 1 ↔ (p % 7 = 1 ∨ p % 7 = 2 ∨ p % 7 = 4) := by
  have hdvd : ¬ (7 ∣ p) := fun h =>
    hp7 ((Nat.prime_dvd_prime_iff_eq (by norm_num) Fact.out).1 h).symm
  have hpne : ((p : ℕ) : ZMod 7) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]; exact hdvd
  have h0 : p % 7 ≠ 0 := fun h => hdvd (Nat.dvd_of_mod_eq_zero h)
  rw [legendreSym.eq_one_iff' 7 hpne, ← ZMod.natCast_mod p 7]
  have hns : ∀ a : ZMod 7, a = 3 ∨ a = 5 ∨ a = 6 → ¬ IsSquare a := by decide
  have hr : p % 7 = 1 ∨ p % 7 = 2 ∨ p % 7 = 3 ∨ p % 7 = 4 ∨ p % 7 = 5 ∨ p % 7 = 6 := by omega
  rcases hr with h | h | h | h | h | h <;> rw [h]
  · exact iff_of_true ⟨1, by decide⟩ (by norm_num)
  · exact iff_of_true ⟨3, by decide⟩ (by norm_num)
  · exact iff_of_false (by simpa using hns 3 (by tauto)) (by norm_num)
  · exact iff_of_true ⟨2, by decide⟩ (by norm_num)
  · exact iff_of_false (by simpa using hns 5 (by tauto)) (by norm_num)
  · exact iff_of_false (by simpa using hns 6 (by tauto)) (by norm_num)

/-- **Quadratic reciprocity for `-7`.**  For a prime `p ∉ {2, 7}`, `-7` is a square modulo
`p` iff `p ≡ 1, 2, 4 (mod 7)`.  The proof is the cancellation
`legendreSym p (-7) = (-1)^(p/2) · (-1)^(3·(p/2)) · legendreSym 7 p = legendreSym 7 p`. -/
theorem isSquare_neg_seven (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (hp7 : p ≠ 7) :
    IsSquare (-7 : ZMod p) ↔ (p % 7 = 1 ∨ p % 7 = 2 ∨ p % 7 = 4) := by
  have hne : ((-7 : ℤ) : ZMod p) ≠ 0 := by
    rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
    intro h
    have h7 : p ∣ 7 := by
      have : ((p : ℤ)) ∣ ((7 : ℕ) : ℤ) := by simpa using (dvd_neg).mp h
      exact_mod_cast this
    exact hp7 ((Nat.prime_dvd_prime_iff_eq Fact.out (by norm_num)).1 h7)
  have hcast : ((-7 : ℤ) : ZMod p) = -7 := by push_cast; ring
  have h1 : legendreSym p (-7) = legendreSym p (-1) * legendreSym p 7 := by
    rw [← legendreSym.mul]; norm_num
  have hodd : p % 2 = 1 := (Nat.Prime.eq_two_or_odd (Fact.out : p.Prime)).resolve_left hp2
  have h2 : legendreSym p (-1) = (-1) ^ (p / 2) := by
    rw [legendreSym.at_neg_one hp2, χ₄_eq_neg_one_pow hodd]
  have h3 : legendreSym p 7 = (-1) ^ (7 / 2 * (p / 2)) * legendreSym 7 p :=
    legendreSym.quadratic_reciprocity' (by norm_num) hp2
  have h4 : legendreSym p (-7) = legendreSym 7 p := by
    rw [h1, h2, h3, ← mul_assoc, ← pow_add]
    have hsign : (-1 : ℤ) ^ (p / 2 + 7 / 2 * (p / 2)) = 1 := by
      rw [show p / 2 + 7 / 2 * (p / 2) = 2 * (2 * (p / 2)) by ring]
      simp [pow_mul]
    rw [hsign, one_mul]
  rw [← hcast, ← legendreSym.eq_one_iff p hne, h4]
  exact legendreSym_seven_eq_one_iff p hp7

/-! ### The prime divisor law -/

/-- **Prime divisor law for the anti-Fibonacci sequence.**  A prime `p` divides some
anti-Fibonacci number iff `p = 7` or `p ≡ 1, 2, 4 (mod 7)`. -/
theorem prime_dvd_antiFib_iff (p : ℕ) [Fact p.Prime] :
    (∃ n, p ∣ antiFib n) ↔ (p = 7 ∨ p % 7 = 1 ∨ p % 7 = 2 ∨ p % 7 = 4) := by
  by_cases hp7 : p = 7
  · subst hp7
    exact iff_of_true ⟨4, by decide⟩ (Or.inl rfl)
  by_cases hp2 : p = 2
  · subst hp2
    exact iff_of_true ⟨2, by decide⟩ (by norm_num)
  have hkey := AntiFibonacciSpectrum.mem_range_mod_iff p hp2 0
  have hsimp : (8 * (0 : ZMod p) - 7) = -7 := by ring
  rw [hsimp] at hkey
  have hdvd : (∃ n, p ∣ antiFib n) ↔ ∃ n, ((antiFib n : ℕ) : ZMod p) = 0 := by
    constructor
    · rintro ⟨n, hn⟩
      exact ⟨n, (ZMod.natCast_eq_zero_iff _ _).2 hn⟩
    · rintro ⟨n, hn⟩
      exact ⟨n, (ZMod.natCast_eq_zero_iff _ _).1 hn⟩
  rw [hdvd, hkey, isSquare_neg_seven p hp2 hp7]
  constructor
  · intro h; tauto
  · rintro (h | h) <;> tauto

/-! ### Infinitude, via Dirichlet's theorem -/

/-- Infinitely many primes divide some anti-Fibonacci number (take `p ≡ 1 mod 7`). -/
theorem infinite_divisor_primes :
    {p : ℕ | p.Prime ∧ ∃ n, p ∣ antiFib n}.Infinite := by
  refine Set.Infinite.mono ?_ (Nat.infinite_setOf_prime_and_modEq (q := 7) (a := 1)
    (by norm_num) (by norm_num))
  rintro p ⟨hp, hmod⟩
  haveI := Fact.mk hp
  have h1 : p % 7 = 1 := by
    have := hmod
    unfold Nat.ModEq at this
    omega
  exact ⟨hp, (prime_dvd_antiFib_iff p).2 (Or.inr (Or.inl h1))⟩

/-- Infinitely many primes divide **no** anti-Fibonacci number (take `p ≡ 3 mod 7`).
The Fibonacci sequence has no such primes: every prime divides some Fibonacci number. -/
theorem infinite_nondivisor_primes :
    {p : ℕ | p.Prime ∧ ∀ n, ¬ p ∣ antiFib n}.Infinite := by
  refine Set.Infinite.mono ?_ (Nat.infinite_setOf_prime_and_modEq (q := 7) (a := 3)
    (by norm_num) (by norm_num))
  rintro p ⟨hp, hmod⟩
  haveI := Fact.mk hp
  have h3 : p % 7 = 3 := by
    have := hmod
    unfold Nat.ModEq at this
    omega
  refine ⟨hp, ?_⟩
  intro n hn
  have hex : ∃ n, p ∣ antiFib n := ⟨n, hn⟩
  rcases (prime_dvd_antiFib_iff p).1 hex with h | h | h | h <;> omega

/-! ### Experimental data -/

section Evidence

/-- Brute-force search for a multiple of `p` among the first `p + 1` anti-Fibonacci terms
(the sequence is periodic mod `p` with period `p` for odd `p`). -/
def dividesSome (p : ℕ) : Bool :=
  (List.range (p + 1)).any fun n => antiFib n % p == 0

/-- info: [2, 7, 11, 23, 29, 37, 43, 53, 67, 71, 79] -/
#guard_msgs in
#eval ((List.range 100).filter fun p => Nat.Prime p && dividesSome p)

/-- info: [2, 0, 4, 2, 1, 2, 1, 4, 4, 1, 2] -/
#guard_msgs in
#eval ((List.range 100).filter fun p => Nat.Prime p && dividesSome p).map (· % 7)

/-- info: [3, 5, 6, 3, 5, 3, 6, 5, 3, 5, 3, 6, 5, 6] -/
#guard_msgs in
#eval ((List.range 100).filter fun p => Nat.Prime p && !dividesSome p).map (· % 7)

end Evidence

end AntiFibonacciPrimes