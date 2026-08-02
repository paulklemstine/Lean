import Mathlib.NumberTheory.FLT.Three
import Mathlib.Tactic

/-!
# Wall–Sun–Sun primes: certified elementary results

The existence of a Wall–Sun–Sun prime is an open problem.  Accordingly, this file does not
assert existence.  It gives a direct natural-number definition, certifies a finite search bound,
and disproves two tempting but false conjectures about the relation with Fermat's Last Theorem.

For a prime `p ≠ 2, 5`, quadratic reciprocity says `(5/p) = 1` exactly when
`p % 5 ∈ {1,4}`. Thus `fibonacciIndex p` is `p - (p|5)`, represented in `ℕ`.
-/

namespace WallSunSun

set_option maxHeartbeats 2000000 in
section

/-- The natural-number form of `p - (p|5)` for primes away from `2` and `5`. -/
def fibonacciIndex (p : ℕ) : ℕ :=
  if p % 5 = 1 ∨ p % 5 = 4 then p - 1 else p + 1

/-- A Wall–Sun–Sun prime (also called a Fibonacci–Wieferich prime). -/
def IsWallSunSunPrime (p : ℕ) : Prop :=
  p.Prime ∧ p ^ 2 ∣ Nat.fib (fibonacciIndex p)

/-- The original existence question, deliberately exposed as a proposition rather than
claimed as a theorem: as of 2026 it remains open. -/
def WallSunSunExistenceConjecture : Prop := ∃ p, IsWallSunSunPrime p

/-- The first odd prime is not a Wall–Sun–Sun prime: its relevant Fibonacci number is 3. -/
theorem three_not_wallSunSun : ¬ IsWallSunSunPrime 3 := by
  norm_num [IsWallSunSunPrime, fibonacciIndex, Nat.fib]

/-- Five itself is excluded by the divisibility test (and is the ramified exceptional prime). -/
theorem five_not_wallSunSun : ¬ IsWallSunSunPrime 5 := by
  norm_num [IsWallSunSunPrime, fibonacciIndex, Nat.fib]

/-- A machine-checked finite search: there is no Wall–Sun–Sun prime below 12. -/
theorem no_wallSunSun_below_12 : ∀ p < 12, ¬ IsWallSunSunPrime p := by
  intro p hp
  interval_cases p <;> norm_num [IsWallSunSunPrime, fibonacciIndex, Nat.fib] at *

/-- Consequently, any first Wall–Sun–Sun prime must be at least 12. -/
theorem wallSunSun_lower_bound {p : ℕ} (hp : IsWallSunSunPrime p) : 12 ≤ p := by
  by_contra h
  have hlt : p < 12 := by omega
  exact no_wallSunSun_below_12 p hlt hp

/-- Fermat's Last Theorem at exponent three is already available independently. -/
theorem flt_three_and_not_wallSunSun :
    FermatLastTheoremFor 3 ∧ ¬ IsWallSunSunPrime 3 := by
  exact ⟨fermatLastTheoremThree, three_not_wallSunSun⟩

/-- **Disproof of a bold conjecture.** FLT at exponent `p` is not equivalent to `p` being a
Wall–Sun–Sun prime: `p = 3` is a counterexample. This also records a precise, conservative
formal connection without claiming the much deeper historical one-way criteria. -/
theorem not_flt_iff_wallSunSun_for_every_prime :
    ¬ (∀ p : ℕ, p.Prime → (FermatLastTheoremFor p ↔ IsWallSunSunPrime p)) := by
  intro h
  have hiff := h 3 (by norm_num)
  exact three_not_wallSunSun (hiff.mp fermatLastTheoremThree)

/-- **Disproof of another bold conjecture.** Being a prime congruent to `±1 mod 5` is not
sufficient: 11 has that residue but fails the square-divisibility condition. -/
theorem residue_condition_not_sufficient :
    ∃ p : ℕ, p.Prime ∧ (p % 5 = 1 ∨ p % 5 = 4) ∧ ¬ IsWallSunSunPrime p := by
  refine ⟨11, by norm_num, ?_, ?_⟩
  · norm_num
  · norm_num [IsWallSunSunPrime, fibonacciIndex, Nat.fib]

end

end WallSunSun