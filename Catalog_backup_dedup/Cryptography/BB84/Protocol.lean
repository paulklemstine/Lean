import Mathlib
import Cryptography.BB84.KeyRateThreshold

/-!
# BB84 Protocol Model and the Intercept–Resend Attack

A minimal model of the BB84 protocol focused on the eavesdropper-induced error
rate.  Bases are `Bool` (rectilinear vs. diagonal).  After *sifting* Alice and Bob
keep only the rounds where they used the **same** basis.

We model Eve's canonical **intercept–resend** attack: she measures each qubit in a
basis `e` and resends the result.  On a sifted round (Alice basis = Bob basis = `a`):

* if `e = a`, Eve learns the bit and Bob recovers it correctly (error `0`);
* if `e ≠ a`, the resent qubit is in the conjugate basis, so Bob's measurement is
  uniformly random and is wrong with probability `1/2`.

Averaging over Eve's uniformly random basis choice gives the textbook
**QBER = 1/4** for full intercept–resend.  Combined with `KeyRateThreshold`, this
exceeds the ≈ 11% security threshold, so the attack is always detectable: the
secret-key rate at `Q = 1/4` is negative.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The strongest naive eavesdropping strategy
  (intercept–resend on every qubit) produces a fixed, basis-independent error
  rate of exactly 1/4, *above* the security threshold, hence always detectable.
EXPERIMENT (Experimenter): Modeled the conditional Bob-error probability and
  averaged over Eve's two equally likely basis choices via `∑ e : Bool`. The sum
  evaluates to `1/4` for either common basis `a`. Bridged to `secureKeyRate` from
  `KeyRateThreshold`: `secureKeyRate (1/4) < 0`.
ANALYSIS (Analyst): The averaging is a genuine finite expectation (`Fintype.sum_bool`),
  not a definitional `1/4`. The bridge theorem is where the analytic threshold
  result does real work: `1/4 > 1/8 > p*`.
CRITIQUE (Critic): Counterexample hunt — is the QBER basis-dependent? Computed for
  both `a = false` and `a = true`; both give `1/4`. Edge case: partial
  intercept–resend on a fraction `μ` of qubits gives QBER `μ/4`, which is below
  threshold for `μ < 4 p*`; the claim is precisely about *full* interception.
SYNTHESIS (PI): `interceptResendQBER` (finite expectation) +
  `interceptResendQBER_eq` (= 1/4) + `interceptResend_insecure` (bridge to threshold)
  + `threshold_lt_interceptResend` (the QBER strictly exceeds the critical value).
-/

open Real

noncomputable section

namespace BB84

/-- Bob's error probability on a sifted round given Alice's/Bob's common basis
`aliceBasis` and Eve's measurement basis `eveBasis`: `0` if Eve guessed the basis,
`1/2` otherwise (random outcome in the conjugate basis). -/
def bobErrorProb (aliceBasis eveBasis : Bool) : ℝ :=
  if eveBasis = aliceBasis then 0 else 1 / 2

/-- The intercept–resend QBER: the expected Bob-error over Eve's uniformly random
basis choice on a sifted round with common basis `aliceBasis`. -/
def interceptResendQBER (aliceBasis : Bool) : ℝ :=
  ∑ e : Bool, (1 / 2) * bobErrorProb aliceBasis e

/-
**Intercept–resend induces QBER = 1/4**, independently of the basis.
-/
theorem interceptResendQBER_eq (a : Bool) : interceptResendQBER a = 1 / 4 := by
  cases a <;> norm_num [ interceptResendQBER, bobErrorProb ]

/-
**Intercept–resend is insecure / detectable.** At the intercept–resend QBER the
BB84 secret-key rate is strictly negative: no secret key can be distilled.
-/
theorem interceptResend_insecure (a : Bool) :
    secureKeyRate (interceptResendQBER a) < 0 := by
  rw [ interceptResendQBER_eq ] ; exact secureKeyRate_one_quarter_neg;

/-
The intercept–resend QBER strictly exceeds the critical threshold `p*`
(any zero of the secret-key rate in `(1/16, 1/8)`).
-/
theorem threshold_lt_interceptResend (a : Bool) {p : ℝ}
    (hp : p ∈ Set.Ioo (1 / 16 : ℝ) (1 / 8)) : p < interceptResendQBER a := by
  linarith [ hp.2, interceptResendQBER_eq a ]

end BB84