/-
# ECM-PARITY, the class-field face: `4p = A² + 31B²` controls the ECM order mod 4

`ℚ(√-31)` has class number `3` and its Hilbert class field is the splitting field
of `x³ + x + 1`; classically the principal-form condition

  `4p = A² + 31 B²`

singles out the primes that split completely, i.e. the `[1,1,1]` face.  Here we
prove the elementary half of that dictionary and combine it with the mod-`4`
law of `ECMParityMod4`:

* `ECMParity.isSquare_neg31_of_form` — if `4p = A² + 31B²` (`p ≠ 2`) then `-31`
  is a square mod `p`, i.e. the Frobenius of `x³ + x + 1` lies in `A₃`.
* `ECMParity.E0Card_mod_four_ne_two_of_form` — consequently the order of
  `E₀ : y² = x³ + x + 1` over `𝔽_p` is **never `≡ 2 (mod 4)`** for such `p`:
  it is either odd (Frobenius a `3`-cycle) or divisible by `4` (the split face).

This is the parity shadow of the Hilbert class field: the representability of
`4p` by the principal form of discriminant `-31` is *visible in the ECM order
mod 4*.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityFrobenius
import Algebra.ECMParityMod4
import Algebra.ECMParitySymmetric

namespace ECMParity

open Finset

variable {p : ℕ} [Fact p.Prime]

/-- If `4p = A² + 31B²` with `p` an odd prime, then `-31` is a square mod `p`. -/
theorem isSquare_neg31_of_form (hp2 : p ≠ 2) {A B : ℤ} (h : 4 * (p : ℤ) = A ^ 2 + 31 * B ^ 2) :
    IsSquare ((-31 : ℤ) : ZMod p) := by
  have hp' : p.Prime := Fact.out
  -- `p ∤ B`
  have hB : ¬ ((p : ℤ) ∣ B) := by
    intro hdvd
    obtain ⟨c, rfl⟩ := hdvd
    have hA2 : (p : ℤ) ∣ A ^ 2 := by
      refine ⟨4 - 31 * (p : ℤ) * c ^ 2, ?_⟩
      linear_combination -h
    have hpA : (p : ℤ) ∣ A := (Nat.prime_iff_prime_int.mp hp').dvd_of_dvd_pow hA2
    obtain ⟨d, rfl⟩ := hpA
    have hsq : (4 : ℤ) * p = (p : ℤ) ^ 2 * (d ^ 2 + 31 * c ^ 2) := by linear_combination h
    have hp0 : (0 : ℤ) < p := by exact_mod_cast hp'.pos
    have hdvd4 : (p : ℤ) ∣ 4 := by
      refine ⟨d ^ 2 + 31 * c ^ 2, ?_⟩
      have : (p : ℤ) * (4 : ℤ) = (p : ℤ) * ((p : ℤ) * (d ^ 2 + 31 * c ^ 2)) := by
        linear_combination hsq
      exact mul_left_cancel₀ (ne_of_gt hp0) this
    have hp4 : p ∣ 4 := by exact_mod_cast hdvd4
    have hp2' : p ∣ 2 := hp'.dvd_of_dvd_pow (n := 2) (by simpa using hp4)
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp' Nat.prime_two).1 hp2')
  -- pass to `ZMod p`
  have hBz : (B : ZMod p) ≠ 0 := by
    intro hz
    exact hB ((ZMod.intCast_zmod_eq_zero_iff_dvd B p).1 hz)
  have hkey : ((A : ZMod p)) ^ 2 + 31 * ((B : ZMod p)) ^ 2 = 0 := by
    have := congrArg (fun z : ℤ => (z : ZMod p)) h
    push_cast at this
    rw [ZMod.natCast_self] at this
    linear_combination -this
  refine ⟨(A : ZMod p) / (B : ZMod p), ?_⟩
  field_simp
  push_cast
  linear_combination -hkey

/-- **Class-field shadow on the ECM order.**  If `4p = A² + 31B²` then the order of
`E₀ : y² = x³ + x + 1` over `𝔽_p` is never `≡ 2 (mod 4)`. -/
theorem E0Card_mod_four_ne_two_of_form (hp2 : p ≠ 2) (hp31 : p ≠ 31) {A B : ℤ}
    (h : 4 * (p : ℤ) = A ^ 2 + 31 * B ^ 2) : E0Card p % 4 ≠ 2 := by
  have hd : disc (1 : ZMod p) 1 ≠ 0 := disc_E0_ne_zero hp31
  have hsq : IsSquare (disc (1 : ZMod p) 1) := by
    rw [disc_E0]
    exact isSquare_neg31_of_form hp2 h
  have hne1 : (rootSet (1 : ZMod p) 1).card ≠ 1 := by
    intro hc
    exact ((disc_not_isSquare_iff_card_eq_one hp2 1 1 hd).2 hc) hsq
  rcases rootSet_card_cases (1 : ZMod p) 1 hd with h0 | h1 | h3
  · -- no root: the order is odd
    have hnr : ∀ x : ZMod p, cubic (1 : ZMod p) 1 x ≠ 0 := by
      intro x hx
      have hmem : x ∈ rootSet (1 : ZMod p) 1 := by simp [rootSet, hx]
      rw [Finset.card_eq_zero.1 h0] at hmem
      simp at hmem
    have hodd : ¬ (2 ∣ curveCard (1 : ZMod p) 1) :=
      (curveCard_odd_iff_no_root hp2 1 1 hd).2 hnr
    unfold E0Card
    omega
  · exact absurd h1 hne1
  · -- three roots: the order is divisible by 4
    obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.1 (by omega : 1 < (rootSet (1 : ZMod p) 1).card)
    simp only [rootSet, Finset.mem_filter] at ha hb
    have h4 : 4 ∣ curveCard (1 : ZMod p) 1 :=
      four_dvd_curveCard_of_three_roots hp2 hd ha.2 hb.2 hab
    unfold E0Card
    omega

end ECMParity