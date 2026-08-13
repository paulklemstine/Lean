import MachineLearning.HalfPlaneSemiprime

/-!
# Cycle 4: the separable baseline in closed form

The circle count is an arithmetic function in the technical sense, and it is
multiplicative.  Combined with the odd-prime conic count this gives a closed
product formula for every odd squarefree modulus:

  `C(N) = ∏_{p ∣ N} (p - χ_p(-1))`.

This is the exact "free-witness / CRT-separable" baseline: `C` is computable from the
factorisation of `N` in `O(ω(N))` arithmetic operations, while the non-separable
half-plane count `H` studied in the other files admits no such product formula
(`halfPlaneCount_not_multiplicative`).
-/

namespace HalfPlane

open Finset

/-- The circle count packaged as an arithmetic function. -/
def circleArith : ArithmeticFunction ℕ where
  toFun := circleCount
  map_zero' := by decide

@[simp] lemma circleArith_apply (N : ℕ) : circleArith N = circleCount N := rfl

/-- **The circle count is a multiplicative arithmetic function.** -/
theorem circleArith_isMultiplicative : circleArith.IsMultiplicative := by
  constructor
  · decide
  · intro m n hmn
    rcases Nat.eq_zero_or_pos m with rfl | hm
    · have hn : n = 1 := (Nat.coprime_zero_left n).mp hmn
      subst hn
      decide
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · have hm1 : m = 1 := Nat.coprime_zero_right m |>.mp hmn
      subst hm1
      decide
    haveI : NeZero m := ⟨by omega⟩
    haveI : NeZero n := ⟨by omega⟩
    simpa using circleCount_mul_of_coprime hmn

/-- **Closed form of the separable baseline.**  For odd squarefree `N`,
`C(N) = ∏_{p ∣ N} (p - χ_p(-1))`, where the local factor is `p - 1` for
`p ≡ 1 (mod 4)` and `p + 1` for `p ≡ 3 (mod 4)`. -/
theorem circleCount_odd_squarefree {N : ℕ} (hodd : ¬ 2 ∣ N) (hsq : Squarefree N) :
    circleCount N = ∏ p ∈ N.primeFactors, (if p % 4 = 1 then p - 1 else p + 1) := by
  have hprod : ∏ p ∈ N.primeFactors, p = N := Nat.prod_primeFactors_of_squarefree hsq
  have hpair : (↑N.primeFactors : Set ℕ).Pairwise (Function.onFun Nat.Coprime id) := by
    intro a ha b hb hab
    have hpa : a.Prime := Nat.prime_of_mem_primeFactors (by simpa using ha)
    have hpb : b.Prime := Nat.prime_of_mem_primeFactors (by simpa using hb)
    exact (Nat.coprime_primes hpa hpb).mpr hab
  have hmap := circleArith_isMultiplicative.map_prod (id : ℕ → ℕ) N.primeFactors hpair
  simp only [id, circleArith_apply, hprod] at hmap
  rw [hmap]
  refine Finset.prod_congr rfl ?_
  intro q hq
  have hpq : q.Prime := Nat.prime_of_mem_primeFactors hq
  haveI : Fact q.Prime := ⟨hpq⟩
  have hq2 : q ≠ 2 := by
    rintro rfl
    exact hodd (Nat.dvd_of_mem_primeFactors hq)
  exact circleCount_prime hq2

/-- **A 2-adic constraint on the separable baseline.**  For odd squarefree `N`,
`4^ω(N)` divides `C(N)`: every local factor `p - χ_p(-1)` is divisible by `4`,
since `p ≡ 1 (mod 4)` gives `4 ∣ p - 1` and `p ≡ 3 (mod 4)` gives `4 ∣ p + 1`. -/
theorem four_pow_omega_dvd_circleCount {N : ℕ} (hodd : ¬ 2 ∣ N) (hsq : Squarefree N) :
    4 ^ N.primeFactors.card ∣ circleCount N := by
  rw [circleCount_odd_squarefree hodd hsq, ← Finset.prod_const]
  refine Finset.prod_dvd_prod_of_dvd _ _ ?_
  intro q hq
  have hpq : q.Prime := Nat.prime_of_mem_primeFactors hq
  have hq2 : q ≠ 2 := by
    rintro rfl
    exact hodd (Nat.dvd_of_mem_primeFactors hq)
  have hqodd : q % 2 = 1 := Nat.odd_iff.mp (hpq.odd_of_ne_two hq2)
  have h2 : 2 ≤ q := hpq.two_le
  by_cases h : q % 4 = 1
  · simp only [h, if_true]
    omega
  · simp only [h, if_false]
    omega

/-! ### Lab notes (cycle 4)

```
N = 15 = 3·5   : (3+1)(5-1) = 16 = C(15)   ✓
N = 21 = 3·7   : (3+1)(7+1) = 32 = C(21)   ✓
N = 35 = 5·7   : (5-1)(7+1) = 32 = C(35)   ✓
N = 105 = 3·5·7: (3+1)(5-1)(7+1) = 128     ✓
```
-/

example : circleCount 15 = 16 := by decide
example : circleCount 21 = 32 := by decide
example : circleCount 35 = 32 := by decide

end HalfPlane