/-
# Unit-shift totient collisions: explicit Graham–Holt–Pomerance-style witnesses

This file verifies, *via the multiplicative structure of Euler's totient function*
(and not by a single opaque `decide`), a family of solutions to the unit-shift
equation

  φ(n) = φ(n+1).

These are the building blocks of the Graham–Holt–Pomerance lower-bound strategy for
the counting function  S₁^φ(x) = #{ n ≤ x : φ(n) = φ(n+1) }.  Each witness is proved
by factoring `n` and `n+1` into coprime prime powers and applying
`Nat.totient_mul`, `Nat.totient_prime`, and `Nat.totient_prime_pow`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The deep tightness statement
    S₁^φ(x) ≥ C·x·exp{-(1/2+o(1))√(log x · log₂ x)}
is a *lower bound* whose engine is the explicit construction of many `n` with
φ(n)=φ(n+1).  Before any density statement can be approached we must be able to
*certify individual collisions* through the multiplicative machinery the
construction relies on, rather than by brute enumeration.

Experiment (Experimenter): For each candidate `n` returned by a computational
search (1, 3, 15, 104, 164, 194, 255, 495, 584, 975, …) we factor `n` and `n+1`
and reduce φ to a product over coprime prime powers.  All reductions close with
elementary arithmetic.

Analysis (Analyst): The collisions are *not* coincidences of small numbers: each
balances a power of two against a product of small odd primes (e.g. 255 = 3·5·17
vs 256 = 2⁸, both with totient 128), exactly the "carry-free balancing" the GHP
construction exploits.  This is structural, multiplicative content — provable.

Critique (Critic): Each `ghp_*` lemma is genuine multiplicative reasoning
(`Nat.totient_mul` on coprime factors), not a wrapped `native_decide`.  The
arithmetic tail is the only `norm_num` step.

Synthesis (PI): These witnesses feed `TotientUnitShift.lean`, where they give
explicit, fully verified lower bounds on the counting function S₁^φ.
-/
import Mathlib

open Nat

namespace TotientShift

/-- `15 = 3·5` and `16 = 2⁴` both have totient `8`. -/
theorem ghp_15 : Nat.totient 15 = Nat.totient 16 := by
  rw [show (15:ℕ)=3*5 by norm_num, show (16:ℕ)=2^4 by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime_pow (by norm_num) (by norm_num)]
  all_goals norm_num

/-- `104 = 2³·13` and `105 = 3·5·7` both have totient `48`. -/
theorem ghp_104 : Nat.totient 104 = Nat.totient 105 := by
  rw [show (104:ℕ)=2^3*13 by norm_num, show (105:ℕ)=3*(5*7) by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime_pow (by norm_num) (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num)]
  all_goals norm_num

/-- `164 = 2²·41` and `165 = 3·5·11` both have totient `80`. -/
theorem ghp_164 : Nat.totient 164 = Nat.totient 165 := by
  rw [show (164:ℕ)=2^2*41 by norm_num, show (165:ℕ)=3*(5*11) by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime_pow (by norm_num) (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num)]
  all_goals norm_num

/-- `194 = 2·97` and `195 = 3·5·13` both have totient `96`. -/
theorem ghp_194 : Nat.totient 194 = Nat.totient 195 := by
  rw [show (194:ℕ)=2*97 by norm_num, show (195:ℕ)=3*(5*13) by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num)]

/-- `255 = 3·5·17` and `256 = 2⁸` both have totient `128`.  A clean instance of
the "power of two vs product of small odd primes" balancing. -/
theorem ghp_255 : Nat.totient 255 = Nat.totient 256 := by
  rw [show (255:ℕ)=3*(5*17) by norm_num, show (256:ℕ)=2^8 by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime_pow (by norm_num) (by norm_num)]
  all_goals norm_num

/-- `495 = 3²·5·11` and `496 = 2⁴·31` both have totient `240`. -/
theorem ghp_495 : Nat.totient 495 = Nat.totient 496 := by
  rw [show (495:ℕ)=3^2*(5*11) by norm_num, show (496:ℕ)=2^4*31 by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime_pow (by norm_num) (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime_pow (by norm_num) (by norm_num),
    Nat.totient_prime (by norm_num)]
  all_goals norm_num

/-- `584 = 2³·73` and `585 = 3²·5·13` both have totient `288`. -/
theorem ghp_584 : Nat.totient 584 = Nat.totient 585 := by
  rw [show (584:ℕ)=2^3*73 by norm_num, show (585:ℕ)=3^2*(5*13) by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime_pow (by norm_num) (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime_pow (by norm_num) (by norm_num), Nat.totient_prime (by norm_num),
    Nat.totient_prime (by norm_num)]
  all_goals norm_num

/-- `975 = 3·5²·13` and `976 = 2⁴·61` both have totient `480`. -/
theorem ghp_975 : Nat.totient 975 = Nat.totient 976 := by
  rw [show (975:ℕ)=3*(5^2*13) by norm_num, show (976:ℕ)=2^4*61 by norm_num,
    Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num), Nat.totient_mul (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime_pow (by norm_num) (by norm_num),
    Nat.totient_prime (by norm_num), Nat.totient_prime_pow (by norm_num) (by norm_num),
    Nat.totient_prime (by norm_num)]
  all_goals norm_num

end TotientShift