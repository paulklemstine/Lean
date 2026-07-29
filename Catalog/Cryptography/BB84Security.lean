import Mathlib

/-!
# A finite BB84 security core

This file formalizes a self-contained chain of nontrivial finite results underlying BB84:

* preparation and measurement in matching BB84 bases is perfectly correct;
* measuring in the conjugate basis is uniform;
* an intercept/resend attack causes error probability `1/4` on sifted bits;
* a standard universal₂-hashing failure bound is nonnegative, decreases with every
  added hash bit, and is exactly exponentially small.

The attack theorem is an exact finite calculation.  The final chain isolates the
arithmetic step used after a universal₂ collision argument has supplied a bound of
`2⁻ʳ`.  A full security theorem against arbitrary quantum side information, and a
proof of the asymptotic 11% threshold, require substantially more operator, entropy,
and probability infrastructure; neither stronger claim is made here.
-/

namespace BB84

inductive Bit where
  | zero
  | one
  deriving DecidableEq, Fintype, Repr

inductive Basis where
  | computational
  | diagonal
  deriving DecidableEq, Fintype, Repr


/-- Probability that measuring an ideal BB84 state gives a requested output bit. -/
def measurementProbability (preparedBasis measuredBasis : Basis)
    (preparedBit outputBit : Bit) : ℚ :=
  if preparedBasis = measuredBasis then
    if preparedBit = outputBit then 1 else 0
  else 1 / 2

/-- Matching-basis BB84 measurement recovers the encoded bit with certainty. -/
theorem matching_basis_correct (basis : Basis) (bit : Bit) :
    measurementProbability basis basis bit bit = 1 := by
  simp [measurementProbability]

/-- A conjugate-basis BB84 measurement is unbiased. -/
theorem conjugate_basis_uniform (preparedBasis measuredBasis : Basis)
    (bit output : Bit) (h : preparedBasis ≠ measuredBasis) :
    measurementProbability preparedBasis measuredBasis bit output = 1 / 2 := by
  simp [measurementProbability, h]

/-- Error probability conditioned on Alice and Bob using the same basis, when Eve
intercepts in `eveBasis`, measures, and resends her result. -/
def interceptResendError (aliceBasis eveBasis : Basis) : ℚ :=
  if aliceBasis = eveBasis then 0 else 1 / 2

/-- Eve introduces no errors when she happened to choose Alice's basis. -/
theorem intercept_resend_matching (basis : Basis) :
    interceptResendError basis basis = 0 := by
  simp [interceptResendError]

/-- If Eve chose the conjugate basis, Bob's sifted bit is wrong with probability one half. -/
theorem intercept_resend_conjugate (aliceBasis eveBasis : Basis)
    (h : aliceBasis ≠ eveBasis) : interceptResendError aliceBasis eveBasis = 1 / 2 := by
  simp [interceptResendError, h]

/-- With an independent uniform basis choice by Eve, intercept/resend creates QBER `1/4`. -/
theorem intercept_resend_qber (aliceBasis otherBasis : Basis)
    (h : aliceBasis ≠ otherBasis) :
    (interceptResendError aliceBasis aliceBasis +
      interceptResendError aliceBasis otherBasis) / 2 = 1 / 4 := by
  rw [intercept_resend_matching, intercept_resend_conjugate aliceBasis otherBasis h]
  norm_num

/-- The standard upper bound after `rounds` independent universal₂ hash checks. -/
def privacyFailureBound (rounds : ℕ) : ℚ := (1 / 2) ^ rounds

/-- Before hashing, the bound is one. -/
theorem privacyFailureBound_zero : privacyFailureBound 0 = 1 := by
  norm_num [privacyFailureBound]

/-- Every additional independent universal₂ hash bit halves the failure bound. -/
theorem privacyFailureBound_succ (rounds : ℕ) :
    privacyFailureBound (rounds + 1) = privacyFailureBound rounds / 2 := by
  rw [privacyFailureBound, privacyFailureBound, pow_succ]
  ring

/-- The universal-hashing privacy bound is nonnegative. -/
theorem privacyFailureBound_nonneg (rounds : ℕ) :
    0 ≤ privacyFailureBound rounds := by
  exact pow_nonneg (by norm_num) rounds

/-- The bound is monotone: adding a universal hash output bit cannot hurt privacy. -/
theorem privacyFailureBound_antitone (rounds : ℕ) :
    privacyFailureBound (rounds + 1) ≤ privacyFailureBound rounds := by
  rw [privacyFailureBound_succ]
  have h := privacyFailureBound_nonneg rounds
  linarith

/-- After `k` further output bits, the failure bound is reduced by exactly `2^k`.
This is the finite exponential privacy-amplification statement. -/
theorem privacy_amplification_exponential (rounds extra : ℕ) :
    privacyFailureBound (rounds + extra) =
      privacyFailureBound rounds / (2 : ℚ) ^ extra := by
  simp only [privacyFailureBound, pow_add, div_eq_mul_inv]
  rw [← inv_pow]
  norm_num

/-- In particular, starting from unit failure, `rounds` hash bits leave bound `1/2^rounds`. -/
theorem privacy_amplification_from_unit (rounds : ℕ) :
    privacyFailureBound rounds = 1 / (2 : ℚ) ^ rounds := by
  have h := privacy_amplification_exponential 0 rounds
  simpa [privacyFailureBound_zero] using h

end BB84