import Novelty.Basic

/-!
# Consecutive anti-Fibonacci numbers: an exact gcd law

Consecutive Fibonacci numbers are always coprime (`Nat.fib_coprime_fib_succ`).  For the
anti-Fibonacci sequence of `Novelty.Basic` this fails — but it fails in a completely
controlled way:

> `gcd (antiFib n) (antiFib (n+1)) = 2` when `n ≡ 2 (mod 4)`, and `= 1` otherwise.

So the "addition-avoiding" sequence is *almost* coprime-consecutive: exactly one residue
class in four carries a common factor, and that factor is always exactly `2`.

## Main results

* `AntiFibonacciGcd.gcd_dvd_two` — the gcd of two consecutive terms always divides `2`.
* `AntiFibonacciGcd.gcd_consecutive` — the exact law
  `gcd (antiFib n) (antiFib (n+1)) = if n % 4 = 2 then 2 else 1`.
* `AntiFibonacciGcd.coprime_consecutive_iff` — consecutive terms are coprime iff
  `n % 4 ≠ 2`, contrasting with `Nat.fib_coprime_fib_succ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `antiFib (n+1) = antiFib n + n`, so the gcd of two consecutive
terms is `gcd (antiFib n) n`; combined with `2·antiFib n + n = n² + 2` this gcd must
divide `2`, and the only question is when it equals `2`.

Experiment (Experimenter): `gcd (antiFib n) (antiFib (n+1))` for `n = 0, …, 15` is
`1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1` — period `4`, the value `2` occurring exactly at
`n ≡ 2 (mod 4)` (checked in Lean below).

Analysis (Analyst): if `d ∣ antiFib n` and `d ∣ antiFib (n+1)` then `d ∣ n`, hence
`d ∣ 2·antiFib n + n - n² = 2`.  Writing `n = 2t` and `antiFib n = 2s` in the case `d = 2`,
the closed form gives `2s + t = 2t² + 1`, forcing `t` odd, i.e. `n ≡ 2 (mod 4)`.

Critique (Critic): the converse direction must exhibit the factor `2`, which needs the
explicit value `antiFib (4k+2) = 8k² + 6k + 2`; this is proved rather than asserted, and
all `ℕ`-subtraction is avoided by working with the subtraction-free closed form.
-- !-- Lab Notes -- !--
-/

open AntiFibonacci

namespace AntiFibonacciGcd

/-- The gcd of two consecutive anti-Fibonacci numbers divides the index. -/
theorem gcd_dvd_index (n : ℕ) : Nat.gcd (antiFib n) (antiFib (n + 1)) ∣ n := by
  have h : Nat.gcd (antiFib n) (antiFib (n + 1)) ∣ antiFib n + n := by
    rw [← antiFib_succ n]
    exact Nat.gcd_dvd_right _ _
  exact (Nat.dvd_add_right (Nat.gcd_dvd_left _ _)).1 h

/-- **The gcd of two consecutive anti-Fibonacci numbers always divides `2`.** -/
theorem gcd_dvd_two (n : ℕ) : Nat.gcd (antiFib n) (antiFib (n + 1)) ∣ 2 := by
  set d := Nat.gcd (antiFib n) (antiFib (n + 1)) with hd
  have hdA : d ∣ antiFib n := Nat.gcd_dvd_left _ _
  have hdn : d ∣ n := gcd_dvd_index n
  have hclosed := antiFib_closed n
  have h1 : d ∣ n * n + 2 := by
    rw [← hclosed]
    exact Nat.dvd_add (Dvd.dvd.mul_left hdA 2) hdn
  have h2 : d ∣ n * n := Dvd.dvd.mul_left hdn n
  exact (Nat.dvd_add_right h2).1 h1

/-- The explicit value at indices `≡ 2 (mod 4)`. -/
theorem antiFib_four_mul_add_two (k : ℕ) : antiFib (4 * k + 2) = 8 * k * k + 6 * k + 2 := by
  have h := antiFib_closed (4 * k + 2)
  nlinarith [h]

/-- **Exact gcd law for consecutive terms.** -/
theorem gcd_consecutive (n : ℕ) :
    Nat.gcd (antiFib n) (antiFib (n + 1)) = if n % 4 = 2 then 2 else 1 := by
  set d := Nat.gcd (antiFib n) (antiFib (n + 1)) with hd
  have hdvd2 : d ∣ 2 := gcd_dvd_two n
  by_cases hn : n % 4 = 2
  · rw [if_pos hn]
    obtain ⟨k, rfl⟩ : ∃ k, n = 4 * k + 2 := ⟨n / 4, by omega⟩
    have hA : antiFib (4 * k + 2) = 8 * k * k + 6 * k + 2 := antiFib_four_mul_add_two k
    have hB : antiFib (4 * k + 2 + 1) = 8 * k * k + 10 * k + 4 := by
      rw [antiFib_succ, hA]; ring
    have h2A : 2 ∣ antiFib (4 * k + 2) := ⟨4 * k * k + 3 * k + 1, by rw [hA]; ring⟩
    have h2B : 2 ∣ antiFib (4 * k + 2 + 1) := ⟨4 * k * k + 5 * k + 2, by rw [hB]; ring⟩
    exact Nat.dvd_antisymm hdvd2 (Nat.dvd_gcd h2A h2B)
  · rw [if_neg hn]
    rcases (Nat.dvd_prime Nat.prime_two).1 hdvd2 with h1 | h2
    · exact h1
    · exfalso
      have hdA : d ∣ antiFib n := Nat.gcd_dvd_left _ _
      have hdn : d ∣ n := gcd_dvd_index n
      rw [h2] at hdA hdn
      obtain ⟨s, hs⟩ := hdA
      obtain ⟨t, ht⟩ := hdn
      have hclosed := antiFib_closed n
      rw [hs, ht] at hclosed
      have hexp : 2 * t * (2 * t) = 4 * (t * t) := by ring
      omega

/-- Consecutive anti-Fibonacci numbers are coprime **iff** `n % 4 ≠ 2` — in contrast with
`Nat.fib_coprime_fib_succ`, which holds for every index. -/
theorem coprime_consecutive_iff (n : ℕ) :
    Nat.Coprime (antiFib n) (antiFib (n + 1)) ↔ n % 4 ≠ 2 := by
  rw [Nat.Coprime, gcd_consecutive n]
  by_cases hn : n % 4 = 2 <;> simp [hn]

/-- The failure is genuine: `antiFib 2 = 2` and `antiFib 3 = 4` share the factor `2`,
whereas the corresponding Fibonacci pair is coprime. -/
theorem not_coprime_two : ¬ Nat.Coprime (antiFib 2) (antiFib 3) := by
  rw [coprime_consecutive_iff]
  norm_num

/-! ### Experimental data -/

section Evidence

/-- info: [1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1] -/
#guard_msgs in
#eval (List.range 16).map fun n => Nat.gcd (antiFib n) (antiFib (n + 1))

/-- info: true -/
#guard_msgs in
#eval (List.range 200).all fun n =>
  Nat.gcd (antiFib n) (antiFib (n + 1)) == (if n % 4 = 2 then 2 else 1)

end Evidence

end AntiFibonacciGcd