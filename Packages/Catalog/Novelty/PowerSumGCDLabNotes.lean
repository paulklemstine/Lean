import Novelty.PowerSumGCDGiuga

/-!
# Lab notes: kernel-checked instances of the power-sum gcd theorems

Every statement in this file is checked by the Lean kernel (`decide` / `norm_num`), and
each is paired with the *general* theorem it instantiates, so the abstract results and the
brute-force computation are cross-validated against each other.

Recorded data (all produced by `#eval` in Lean):

```
gcd(F(N,p-1), N) for (p,q) = (3,5) (3,7) (5,7) (5,11) (7,13) (11,13) (13,17) (97,101):
   5      7      7      11     13      13      17      101      -- always q  ✓ Theorem 1

g(k) = gcd(F(15,k),15), k = 1..13 :  15 5 15 1 15 5 15 1 15 5 15 1 15   (period 4 = λ(15))
g(k) = gcd(F(35,k),35), k = 1..13 :  35 35 35 7 35 5 35 7 35 35 35 1 35 (period 12 = λ(35))

F(35,12) mod 35 = 23 = 35 - (35/5 + 35/7)      ✓ Giuga closed form
gcd(4^2-1, 15) = 15                            ✓ Pollard bad base at exponent p-1 = 2
```
-/

namespace PowerSumGCD

section LabNotes

/-- `N = 35 = 5·7`: the theorem predicts the factor `7` at `k = p - 1 = 4`. -/
theorem labnote_reveal_35_theory : Nat.gcd (powerSum (5 * 7) (5 - 1)) (5 * 7) = 7 :=
  gcd_powerSum_eq_factor (by norm_num) (by norm_num) (by norm_num) (by decide)

/-- …and the kernel agrees by direct computation. -/
theorem labnote_reveal_35_computation : Nat.gcd (powerSum 35 4) 35 = 7 := by decide

/-- The symmetric hit at `k = q - 1 = 6` returns the other factor `5`. -/
theorem labnote_reveal_35_other : Nat.gcd (powerSum 35 6) 35 = 5 := by decide

/-- `k = 12 = λ(35)` is the first trivial value of the gcd, as predicted by
`gcd_powerSum_eq_one_iff`. -/
theorem labnote_period_35 : Nat.gcd (powerSum 35 12) 35 = 1 := by decide

/-- The Giuga closed form at `N = 35`, `k = 12`: `F ≡ -(35/5 + 35/7) = -12 (mod 35)`. -/
theorem labnote_giuga_35 : (powerSum 35 12 + (7 + 5)) % 35 = 0 := by decide

/-- `N = 15`, base `a = 4`: Pollard's `p-1` step at exponent `p - 1 = 2` returns the whole
modulus, while the power sum returns the factor `5`. -/
theorem labnote_pollard_vs_powerSum :
    Nat.gcd (4 ^ 2 - 1) 15 = 15 ∧ Nat.gcd (powerSum 15 2) 15 = 5 := by
  constructor <;> decide

end LabNotes

end PowerSumGCD