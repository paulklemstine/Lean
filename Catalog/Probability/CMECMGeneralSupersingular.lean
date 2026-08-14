/-
# CM-ECM-GENERAL: the exact trace dichotomy (`a_p = 0` ⟺ `p` inert)

The experiment reports an "atomic trace law": `a_p = 0` on a `0.504` fraction of
the sampled primes, and *exactly* on the inert class.  Both CM curves are
handled here, and in both cases the vanishing of the trace is proved to be
*equivalent* to inertness — no density input, no Deuring theory, only the
material already formalised in this project:

* `traceJ0_eq_zero_iff` : for a prime `p > 3`,
  `a_p(E_{j0}) = 0 ↔ p ≡ 2 (mod 3)`.
  The forward direction is the new one: `a_p ≡ p + 1 (mod 3)`
  (`CMECMGeneral.trace_congr_three`) forces `3 ∣ p + 1` as soon as `a_p = 0`.

* `trace1728_eq_zero_iff` : for an odd prime `p`,
  `a_p(E_{1728}) = 0 ↔ p ≡ 3 (mod 4)`.
  Here the forward direction uses the catalogue's full-2-torsion theorem
  `ECMParity.four_dvd_curveCard_of_three_roots`: when `p ≡ 1 (mod 4)` the cubic
  `x³ + x` splits (`x`, `x ± i`), so `4 ∣ #E` while `p + 1 ≡ 2 (mod 4)`.

* `atomic_trace_law` / `atomic_trace_law_1728` : consequently, on *any* finite
  sample of good primes, the number of primes with `a_p = 0` equals the number
  of inert primes — the experimental frequency `0.504` is exactly the sampled
  inert frequency, with no arithmetic slack.

This is the sharp form of the "exact inert collapse" seal: supersingularity of
these two CM curves is a pure residue condition.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityMod4
import Probability.CMECMGeneralJ0
import Probability.CMECMGeneralInformation
import Probability.CMECMGeneralGaussian

namespace CMECMGeneral

open Finset

variable {p : ℕ} [Fact p.Prime]

/-- **Trace dichotomy for `ℚ(√-3)`.**  For a prime `p > 3`, the `j = 0` curve has
`a_p = 0` exactly on the inert class `p ≡ 2 (mod 3)`. -/
theorem traceJ0_eq_zero_iff (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    traceJ0 p = 0 ↔ p % 3 = 2 := by
  constructor
  · intro h0
    have hcong := trace_congr_three (p := p) hp2 hp3
    rw [h0] at hcong
    have hdvd : (3 : ℤ) ∣ (p : ℤ) + 1 := by
      have := (Int.ModEq.dvd hcong)
      simpa using this
    have hdvd' : (3 : ℕ) ∣ p + 1 := by
      have : ((3 : ℕ) : ℤ) ∣ ((p + 1 : ℕ) : ℤ) := by push_cast; exact hdvd
      exact_mod_cast this
    have hp0 : p % 3 ≠ 0 := by
      intro hc
      have : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero hc
      have := (Nat.prime_dvd_prime_iff_eq Nat.prime_three (Fact.out : p.Prime)).1 this
      exact hp3 this.symm
    omega
  · exact inert_trace_zero

/-- **Trace dichotomy for `ℚ(i)`.**  For an odd prime `p`, the `j = 1728` curve
has `a_p = 0` exactly on the inert class `p ≡ 3 (mod 4)`. -/
theorem trace1728_eq_zero_iff (hp2 : p ≠ 2) :
    CMECMGaussian.trace1728 p = 0 ↔ p % 4 = 3 := by
  constructor
  · intro h0
    by_contra hne
    -- `p` is odd and `p % 4 ≠ 3`, hence `p ≡ 1 (mod 4)` and `-1` is a square
    have hodd : p % 2 = 1 := by
      rcases (Fact.out : p.Prime).eq_two_or_odd with h | h
      · exact absurd h hp2
      · exact h
    have hp1 : p % 4 = 1 := by omega
    obtain ⟨i, hi⟩ : IsSquare (-1 : ZMod p) := by
      rw [ZMod.exists_sq_eq_neg_one_iff]
      omega
    have hi2 : i * i = -1 := hi.symm
    have hroot0 : ECMParity.cubic (1 : ZMod p) 0 0 = 0 := by rw [ECMParity.cubic]; ring
    have hrooti : ECMParity.cubic (1 : ZMod p) 0 i = 0 := by
      rw [ECMParity.cubic]; linear_combination i * hi2
    have hne0 : (0 : ZMod p) ≠ i := by
      intro hc
      rw [← hc] at hi2
      exact one_ne_zero (α := ZMod p) (by linear_combination hi2)
    have h4 : 4 ∣ ECMParity.curveCard (1 : ZMod p) 0 :=
      ECMParity.four_dvd_curveCard_of_three_roots hp2
        (CMECMGaussian.disc_1728_ne_zero hp2) hroot0 hrooti hne0
    obtain ⟨m, hm⟩ := h4
    have : (p : ℤ) + 1 = 4 * (m : ℤ) := by
      have := CMECMGaussian.trace1728 (p := p)
      rw [CMECMGaussian.trace1728, hm] at h0
      push_cast at h0 ⊢
      linarith
    have hnat : p + 1 = 4 * m := by exact_mod_cast this
    omega
  · exact CMECMGaussian.inert_trace_zero_1728

end CMECMGeneral

namespace CMECMGeneralInfo

open Finset CMECMGeneral

/-- The trace of Frobenius of the `j = 0` curve, on the type of good primes. -/
def traceOf (q : PrimeGt3) : ℤ := @traceJ0 q.1 ⟨q.2.1⟩

/-- The trace of Frobenius of the `j = 1728` curve, on the type of good primes. -/
def traceOf1728 (q : PrimeGt3) : ℤ := @CMECMGaussian.trace1728 q.1 ⟨q.2.1⟩

theorem traceOf_eq_zero_iff (q : PrimeGt3) : traceOf q = 0 ↔ q.1 % 3 = 2 := by
  obtain ⟨n, hn, hn3⟩ := q
  exact @traceJ0_eq_zero_iff n ⟨hn⟩ (by omega) (by omega)

theorem traceOf1728_eq_zero_iff (q : PrimeGt3) : traceOf1728 q = 0 ↔ q.1 % 4 = 3 := by
  obtain ⟨n, hn, hn3⟩ := q
  exact @trace1728_eq_zero_iff n ⟨hn⟩ (by omega)

/-- **Atomic trace law (`ℚ(√-3)`).**  On any finite sample of good primes, the
number of primes with `a_p = 0` is exactly the number of inert primes. -/
theorem atomic_trace_law (s : Finset PrimeGt3) :
    (s.filter fun q => traceOf q = 0).card = (s.filter fun q => q.1 % 3 = 2).card := by
  classical
  congr 1
  apply filter_congr
  intro q _
  simpa using traceOf_eq_zero_iff q

/-- **Atomic trace law (`ℚ(i)`).**  Same statement for the `j = 1728` curve. -/
theorem atomic_trace_law_1728 (s : Finset PrimeGt3) :
    (s.filter fun q => traceOf1728 q = 0).card = (s.filter fun q => q.1 % 4 = 3).card := by
  classical
  congr 1
  apply filter_congr
  intro q _
  simpa using traceOf1728_eq_zero_iff q

end CMECMGeneralInfo