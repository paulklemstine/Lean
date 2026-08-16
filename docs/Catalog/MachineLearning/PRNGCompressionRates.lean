/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Compression Rates over the Reals

The counting theorems of `MachineLearning.PRNGCompressionCore`,
`…PRNGCompressionBound` and `…PRNGCompressionDepth` are stated in `ℕ` (exact
cardinalities).  This file transports them to `ℝ`, where they read as the
statements a practitioner cares about: *fractions of files* and *average bits
per file*.

## Main Results

* `compressible_fraction_le` — for any decompressor (PRNG-driven or not), the
  fraction of `n`-bit strings whose description shrinks by `d` bits is at most
  `2 ^ (1 - d)`.  Saving one byte works for at most one file in `128`.
* `average_length_lower_real` — the average codeword length of any injective
  code over all `2 ^ n` strings is at least `(n - k)(1 - 2 ^ (-k))` for every
  `k < n`; the average rate is `n - O(log n)` bits per file.
* `average_KC_lower_real` — the same for description complexity relative to an
  arbitrary decompressor.

## Application Keywords

compression rate, average code length, incompressibility fraction, PRNG,
information theory
-/

import MachineLearning.PRNGCompressionDepth

open Finset

namespace PRNGCompression

/-- **Fraction of compressible files.**  At most a `2 ^ (1-d)` fraction of the
`2 ^ n` strings can be described in `n - d` bits by a given decompressor. -/
theorem compressible_fraction_le {n : ℕ} (d : ℕ) (D : List Bool → Bits n)
    (hD : Function.Surjective D) :
    (((univ.filter (fun x : Bits n => KC D x + d ≤ n)).card : ℝ)) / 2 ^ n ≤ 2 / 2 ^ d := by
  classical
  have hnat := KC_compressible_count d D hD
  have hcast : (2:ℝ) ^ d * ((univ.filter (fun x : Bits n => KC D x + d ≤ n)).card : ℝ)
      ≤ 2 ^ (n + 1) := by
    have := (Nat.cast_le (α := ℝ)).mpr hnat
    push_cast at this
    exact this
  have h2n : (0:ℝ) < 2 ^ n := by positivity
  have h2d : (0:ℝ) < 2 ^ d := by positivity
  rw [div_le_div_iff₀ h2n h2d]
  have hexp : (2:ℝ) ^ (n + 1) = 2 * 2 ^ n := by ring
  rw [hexp] at hcast
  nlinarith [hcast]

/-- **Average bits per file.**  For every injective code and every `k < n`, the
mean codeword length over all `2 ^ n` strings is at least `(n - k)(1 - 2 ^ (-k))`.
Choosing `k ≈ log₂ n` gives a mean of `n - O(log n)` bits: no code beats the
pigeonhole bound even on average. -/
theorem average_length_lower_real (n k : ℕ) (hk : k + 1 ≤ n) (c : Bits n → List Bool)
    (hc : Function.Injective c) :
    ((n : ℝ) - k) * (1 - (2 : ℝ)⁻¹ ^ k) ≤ (∑ x, ((c x).length : ℝ)) / 2 ^ n := by
  have hnat := sum_length_lower n k hk c hc
  have hle : (2:ℕ) ^ (n - k) ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
  have hcast : ((n : ℝ) - k) * ((2:ℝ) ^ n - 2 ^ (n - k)) ≤ ∑ x, ((c x).length : ℝ) := by
    have hc' := (Nat.cast_le (α := ℝ)).mpr hnat
    push_cast [Nat.cast_sub hle, Nat.cast_sub (by omega : k ≤ n)] at hc'
    convert hc' using 2
  have hpow : (2:ℝ) ^ (n - k) * 2 ^ k = 2 ^ n := by
    rw [← pow_add]; congr 1; omega
  have h2n : (0:ℝ) < 2 ^ n := by positivity
  have h2k : (0:ℝ) < 2 ^ k := by positivity
  have hsub : (2:ℝ) ^ (n - k) = 2 ^ n / 2 ^ k := by
    field_simp
    linarith [hpow]
  rw [le_div_iff₀ h2n]
  have hkey : ((n : ℝ) - k) * (1 - (2 : ℝ)⁻¹ ^ k) * 2 ^ n
      = ((n : ℝ) - k) * ((2:ℝ) ^ n - 2 ^ (n - k)) := by
    rw [hsub, inv_pow]
    field_simp
  rw [hkey]
  exact hcast

/-- Average description complexity, relative to an arbitrary decompressor, is at
least `(n - k)(1 - 2 ^ (-k))`. -/
theorem average_KC_lower_real (n k : ℕ) (hk : k + 1 ≤ n) (D : List Bool → Bits n)
    (hD : Function.Surjective D) :
    ((n : ℝ) - k) * (1 - (2 : ℝ)⁻¹ ^ k) ≤ (∑ x, (KC D x : ℝ)) / 2 ^ n := by
  obtain ⟨c, hinj, hspec⟩ := exists_shortest_code D hD
  have hsum : (∑ x, ((c x).length : ℝ)) = ∑ x, (KC D x : ℝ) :=
    Finset.sum_congr rfl (fun x _ => by rw [(hspec x).1])
  rw [← hsum]
  exact average_length_lower_real n k hk c hinj

end PRNGCompression