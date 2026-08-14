/-
# CM-ECM-GENERAL: the full rational torsion of the `j = 0` curve

`Probability.CMECMGeneralJ0` shows `3 ∣ #E_{j0}(𝔽_p)` for all `p > 3`, coming
from the rational `3`-torsion point `(0,1)`.  The `j = 0` curve
`E_{j0} : y² = x³ + 1` also carries the rational `2`-torsion point `(-1, 0)`,
and this file combines the two halves into

  `6 ∣ #E_{j0}(𝔽_p)`   for every prime `p > 3`  (`six_dvd_curveCard_j0`).

The `2`-divisibility is *not* reproved here: it is obtained from the catalogue's
parity dichotomy `ECMParity.two_dvd_curveCard_iff` (`Algebra.ECMParityCore`),
whose right-hand side — "the cubic has a root in `𝔽_p`" — is witnessed
unconditionally by `x = -1`.  This is the sharpest form of the degeneracy
headline: on the `j = 0` curve *both* small-`ℓ` ECM order channels `ℓ = 2` and
`ℓ = 3` are constants, hence carry exactly zero bits
(`ecm_order_channels_two_three_six_silent`), and the trace of Frobenius is
pinned modulo `6`:

  `a_p ≡ p + 1 (mod 6)`  (`trace_congr_six`).
-/
import Mathlib
import Algebra.ECMParityCore
import Probability.CMECMGeneralJ0
import Probability.CMECMGeneralInformation

namespace CMECMGeneral

variable {p : ℕ} [Fact p.Prime]

/-- The discriminant of `x³ + 1` is `-27`, nonzero away from `p = 3`. -/
theorem disc_j0_ne_zero (hp3 : p ≠ 3) : ECMParity.disc (0 : ZMod p) 1 ≠ 0 := by
  have h3 : (3 : ZMod p) ≠ 0 := three_ne_zero_of_ne_three hp3
  have h27 : (27 : ZMod p) = 3 * 3 * 3 := by norm_num
  rw [ECMParity.disc]
  intro hc
  have : (3 : ZMod p) * 3 * 3 = 0 := by rw [← h27]; linear_combination -hc
  rcases mul_eq_zero.mp this with h | h
  · rcases mul_eq_zero.mp h with h' | h' <;> exact h3 h'
  · exact h3 h

/-- **Rational `2`-torsion degeneracy.**  The point `(-1,0)` is a rational
`2`-torsion point of `E_{j0}`, so the parity channel is a constant too:
`2 ∣ #E_{j0}(𝔽_p)` for every prime `p > 3`. -/
theorem two_dvd_curveCard_j0 (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    2 ∣ ECMParity.curveCard (0 : ZMod p) 1 := by
  rw [ECMParity.two_dvd_curveCard_iff hp2 _ _ (disc_j0_ne_zero hp3)]
  exact ⟨-1, by rw [ECMParity.cubic]; ring⟩

/-- **Full torsion degeneracy.**  `E_{j0}` has rational `6`-torsion, so
`6 ∣ #E_{j0}(𝔽_p)` for every prime `p > 3`. -/
theorem six_dvd_curveCard_j0 (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    6 ∣ ECMParity.curveCard (0 : ZMod p) 1 := by
  have h2 := two_dvd_curveCard_j0 (p := p) hp2 hp3
  have h3 := three_dvd_curveCard_j0 (p := p) hp2 hp3
  have h6 : (2 * 3) ∣ ECMParity.curveCard (0 : ZMod p) 1 :=
    Nat.Coprime.mul_dvd_of_dvd_of_dvd (by norm_num) h2 h3
  simpa using h6

/-- **Trace visibility modulo 6.**  For every prime `p > 3`,
`a_p ≡ p + 1 (mod 6)`. -/
theorem trace_congr_six (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    traceJ0 p ≡ (p : ℤ) + 1 [ZMOD 6] := by
  obtain ⟨k, hk⟩ := six_dvd_curveCard_j0 (p := p) hp2 hp3
  have h : traceJ0 p - ((p : ℤ) + 1) = -6 * (k : ℤ) := by
    rw [traceJ0, hk]; push_cast; ring
  exact Int.ModEq.symm (Int.modEq_iff_dvd.mpr ⟨-(k : ℤ), by linarith [h]⟩)

/-- On the inert half the `6`-divisibility is the statement `6 ∣ p + 1`. -/
theorem inert_six_dvd (hp : p % 3 = 2) (hp2 : p ≠ 2) :
    6 ∣ ECMParity.curveCard (0 : ZMod p) 1 := by
  have hodd : p % 2 = 1 := by
    have hpp : p.Prime := Fact.out
    rcases hpp.eq_two_or_odd with h | h
    · exact absurd h hp2
    · exact h
  rw [inert_curveCard hp]
  omega

end CMECMGeneral

namespace CMECMGeneralInfo

open CMECMGeneral

/-- Both small ECM-order channels `ℓ ∈ {2, 3, 6}` on the `j = 0` curve are
silent on every sample of good primes: their events are constants. -/
theorem ecm_order_channels_two_three_six_silent
    {Ω : Type*} [Fintype Ω] [DecidableEq Ω] [Nonempty Ω]
    {κ : Type*} [Fintype κ] [DecidableEq κ]
    (sample : Ω → PrimeGt3) (c : Ω → κ) (ℓ : ℕ) (hℓ : ℓ = 2 ∨ ℓ = 3 ∨ ℓ = 6) :
    empMI c (fun ω => decide (ℓ ∣ cardJ0 (sample ω))) = 0 := by
  refine empMI_of_const c _ true (fun ω => ?_)
  obtain ⟨n, hn, hn3⟩ := sample ω
  have hdvd : ℓ ∣ @ECMParity.curveCard n ⟨hn⟩ 0 1 := by
    rcases hℓ with rfl | rfl | rfl
    · exact @two_dvd_curveCard_j0 n ⟨hn⟩ (by omega) (by omega)
    · exact @three_dvd_curveCard_j0 n ⟨hn⟩ (by omega) (by omega)
    · exact @six_dvd_curveCard_j0 n ⟨hn⟩ (by omega) (by omega)
  simpa [cardJ0] using hdvd

end CMECMGeneralInfo