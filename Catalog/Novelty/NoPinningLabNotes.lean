/-
# Lab Notes — COMPENSATING-PARTNER, verified instances

Machine-checked instances of the class-wide no-pinning lemma at battery level
`B = 12` (modulus `L = 4 · lcm(1,…,12) = 110880`).  Every statement below is a
theorem, not an `#eval`: the readouts of the full level-12 battery — twelve
residues `N mod m`, twelve Jacobi symbols `(a | N)` and twelve gcds `gcd(N, c)`,
`m, a, c ∈ {1,…,12}` — are proved equal.

Experimental protocol (data in `ComputationalEvidence.md`): target
`N₀ = 221 = 13 · 17`, chosen coprime to `L`.  For each prime candidate
`p ≤ 80` coprime to `L` the compensating partner was taken as the first prime in
the progression `N₀ · p⁻¹ + j·L`.  All 17 candidates compensated; the four
smallest-partner cases are formalised here, together with the pinned-set data
(`2, 3, 5, 7, 11` are the only pinned primes at `B = 12`) and the observation
that the *true* factorisation `221 = 13 · 17` is just one consistent completion
among infinitely many.
-/

import Mathlib
import Novelty.NoPinningBattery

namespace Novelty.NoPinning

/-- The level-12 modulus. -/
theorem modLevel_twelve : modLevel 12 = 110880 := by decide

/-- Candidate `p = 19`, compensating partner `q = 17519`:
`19 · 17519 = 332861 ≡ 221 (mod 110880)`. -/
theorem lab_compensation_19 :
    batteryValue (fullBattery 12) (19 * 17519) = batteryValue (fullBattery 12) 221 :=
  List.map_congr_left fun f hf =>
    fullBattery_isModObs 12 f hf (Nat.odd_iff.mpr rfl) (Nat.odd_iff.mpr rfl) rfl

/-- Candidate `p = 23`, compensating partner `q = 207307`. -/
theorem lab_compensation_23 :
    batteryValue (fullBattery 12) (23 * 207307) = batteryValue (fullBattery 12) 221 :=
  List.map_congr_left fun f hf =>
    fullBattery_isModObs 12 f hf (Nat.odd_iff.mpr rfl) (Nat.odd_iff.mpr rfl) rfl

/-- Candidate `p = 47`, compensating partner `q = 4723`. -/
theorem lab_compensation_47 :
    batteryValue (fullBattery 12) (47 * 4723) = batteryValue (fullBattery 12) 221 :=
  List.map_congr_left fun f hf =>
    fullBattery_isModObs 12 f hf (Nat.odd_iff.mpr rfl) (Nat.odd_iff.mpr rfl) rfl

/-- Candidate `p = 79`, compensating partner `q = 85619`. -/
theorem lab_compensation_79 :
    batteryValue (fullBattery 12) (79 * 85619) = batteryValue (fullBattery 12) 221 :=
  List.map_congr_left fun f hf =>
    fullBattery_isModObs 12 f hf (Nat.odd_iff.mpr rfl) (Nat.odd_iff.mpr rfl) rfl

/-- The four semiprimes above are pairwise distinct from the target and from
each other, yet carry the same level-12 data: the battery cannot tell them
apart, and none of them shares a factor with `221`. -/
theorem lab_compensation_coprime_to_target :
    Nat.Coprime (19 * 17519) 221 ∧ Nat.Coprime (23 * 207307) 221 ∧
      Nat.Coprime (47 * 4723) 221 ∧ Nat.Coprime (79 * 85619) 221 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

/-- The pinned primes at level `B = 12` are exactly `2, 3, 5, 7, 11`: five of
the 95 primes below 500, i.e. `3.0%` of the candidate space in the sampled
range (and a vanishing fraction as the range grows). -/
theorem lab_pinned_primes_twelve (p : ℕ) (hp : p.Prime) :
    p ∣ modLevel 12 ↔ (p = 2 ∨ p = 3 ∨ p = 5 ∨ p = 7 ∨ p = 11) := by
  rw [prime_dvd_modLevel_iff hp]
  constructor
  · rintro (rfl | h)
    · exact Or.inl rfl
    · interval_cases p <;> revert hp <;> decide
  · rintro (rfl | rfl | rfl | rfl | rfl) <;> simp

/-- Barrier 1 in action: the gcd probe against `f(x) = 7x³ + 5x + 12` returns
`gcd(12, N)` on the samples of the experiment, matching the general theorem. -/
theorem lab_gcd_polynomial_samples :
    (Nat.gcd (7 * 1000 ^ 3 + 5 * 1000 + 12) 1000 = Nat.gcd 12 1000) ∧
      (Nat.gcd (7 * 1074 ^ 3 + 5 * 1074 + 12) 1074 = Nat.gcd 12 1074) ∧
        (Nat.gcd (7 * 1296 ^ 3 + 5 * 1296 + 12) 1296 = Nat.gcd 12 1296) := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

end Novelty.NoPinning