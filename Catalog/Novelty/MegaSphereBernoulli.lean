import Mathlib

/-!
# The Mega-Sphere III: Bernoulli numbers as universal arithmetic invariants

The Bernoulli numbers `Bₙ` are the universal rational coefficients through which
"summing over all stages at once" is expressed:

* **Power sums (Faulhaber).**  For every exponent `p`, the sum
  `0^p + 1^p + ⋯ + (n-1)^p` is a fixed polynomial in `n` whose coefficients are
  built from the Bernoulli numbers.  This is the arithmetic shadow of counting
  lattice points across all stages of a tower at once.
* **The Bernoulli recurrence** determines all `Bₙ` from `B₀ = 1`.
* **Vanishing of odd Bernoulli numbers** (beyond `B₁`) is the parity symmetry
  underlying the appearance of `Bₙ` in the values `ζ(1-2k) = -B₂ₖ/2k` and in the
  Hirzebruch `L`- and `Â`-genera of manifolds (the characteristic-number side of
  the mega-sphere story; see `FUTURE_DIRECTIONS.md`).

This file proves these facts completely over `ℚ`, using Mathlib's `bernoulli`.

Main results:

* `MegaSphereBernoulli.bernoulli_recurrence` — the defining recurrence
  `∑_{k<n} C(n,k) Bₖ = 0` for `n ≠ 1`.
* `MegaSphereBernoulli.bernoulli_two` — `B₂ = 1/6`.
* `MegaSphereBernoulli.bernoulli_odd_eq_zero` — `B_{2n+3} = 0`.
* `MegaSphereBernoulli.faulhaber_one`, `faulhaber_two`, `faulhaber_cube` — the
  Bernoulli-driven closed forms for `∑ k`, `∑ k²`, `∑ k³`, the last being
  Nicomachus's identity `∑ k³ = (∑ k)²`.
-/

namespace MegaSphereBernoulli

open Finset

/-! ## The Bernoulli recurrence and small values -/

/-- **The Bernoulli recurrence.**  For `n ≠ 1` the weighted sum of the first `n`
Bernoulli numbers vanishes; this recurrence determines every `Bₙ` from
`B₀ = 1`. -/
theorem bernoulli_recurrence {n : ℕ} (hn : n ≠ 1) :
    ∑ k ∈ range n, (n.choose k : ℚ) * bernoulli k = 0 := by
  rw [sum_bernoulli]; simp [hn]

/-- `B₂ = 1/6`. -/
theorem bernoulli_two : bernoulli 2 = 1 / 6 := by simp

/-- **Odd Bernoulli numbers vanish** (past `B₁`): `B_{2n+3} = 0`. -/
theorem bernoulli_odd_eq_zero (n : ℕ) : bernoulli (2 * n + 3) = 0 := by
  rw [bernoulli_eq_bernoulli'_of_ne_one (by omega),
    bernoulli'_eq_zero_of_odd ⟨n + 1, by ring⟩ (by omega)]

/-! ## Faulhaber's formula: power sums driven by Bernoulli numbers -/

/-- **Faulhaber, `p = 1`.**  `∑_{k<n} k = n(n-1)/2`, extracted from the
Bernoulli power-sum formula using `B₀ = 1`, `B₁ = -1/2`. -/
theorem faulhaber_one (n : ℕ) : ∑ k ∈ range n, (k : ℚ) = n * (n - 1) / 2 := by
  have h := sum_range_pow n 1
  simp [Finset.sum_range_succ, bernoulli_zero, bernoulli_one] at h
  rw [h]; ring

/-- **Faulhaber, `p = 2`.**  `∑_{k<n} k² = n(n-1)(2n-1)/6`, driven by
`B₀, B₁, B₂`. -/
theorem faulhaber_two (n : ℕ) :
    ∑ k ∈ range n, (k : ℚ) ^ 2 = n * (n - 1) * (2 * n - 1) / 6 := by
  have h := sum_range_pow n 2
  simp [Finset.sum_range_succ, bernoulli_zero, bernoulli_one] at h
  rw [h]; ring

/-- **Faulhaber, `p = 3` = Nicomachus's identity.**  `∑_{k<n} k³ = (∑_{k<n} k)²`,
driven by `B₀, B₁, B₂, B₃ = 0`. -/
theorem faulhaber_cube (n : ℕ) :
    ∑ k ∈ range n, (k : ℚ) ^ 3 = (n * (n - 1) / 2) ^ 2 := by
  have hb2 : bernoulli 2 = 1 / 6 := bernoulli_two
  have hb3 : bernoulli 3 = 0 := by
    simpa using bernoulli_odd_eq_zero 0
  have h := sum_range_pow n 3
  simp [Finset.sum_range_succ, bernoulli_zero, bernoulli_one, hb2, hb3, Nat.choose] at h
  rw [h]; ring

/-- Nicomachus's identity in the crisp form `∑ k³ = (∑ k)²`. -/
theorem nicomachus (n : ℕ) :
    ∑ k ∈ range n, (k : ℚ) ^ 3 = (∑ k ∈ range n, (k : ℚ)) ^ 2 := by
  rw [faulhaber_cube, faulhaber_one]

end MegaSphereBernoulli