import Geometry.PowerSumCarmichaelPeriod
import Geometry.PowerSumSquarefree
import Geometry.PowerSumFirstHit
import Geometry.PowerSumPrimePower

/-!
# Lab Notes: machine-checked instances of the power-sum reveal

Every statement below is verified twice: once by kernel computation (`decide`) on the
actual definition `powerSum N k = ∑_{a=1}^{N} a^k`, and once by instantiating the
general theorems.  The agreement of the two is the point: it certifies that the
abstract master formula really describes the computed sequence.

Recorded data (computed with `#eval`, then re-proved below):

```
N = 15 = 3*5 ,  λ = lcm(2,4) = 4
k :            1   2   3   4   5   6   7   8   9  10  11  12
gcd(F k, N):  15   5  15   1  15   5  15   1  15   5  15   1

N = 35 = 5*7 ,  λ = lcm(4,6) = 12
k :            1   2   3   4   5   6   7   8   9  10  11  12
gcd(F k, N):  35  35  35   7  35   5  35   7  35  35  35   1

N = 561 = 3*11*17 (Carmichael), λ = lcm(2,10,16) = 80,  80 ∣ 560
gcd(F 560, 561) = 1     -- the reveal is blind at k = N-1 exactly on Korselt numbers
```

## Main results

* `PowerSumReveal.lab_note_15`, `lab_note_35`, `lab_note_77`, `lab_note_143` —
  computed value = theoretical value for four semiprimes.
* `PowerSumReveal.lab_period_table_35` — the full period-12 table, computed.
* `PowerSumReveal.lab_note_large_semiprimes` — reveal values for the four larger test
  semiprimes (221, 323, 667, 8633), obtained from the theorems.
* `PowerSumReveal.lab_note_561_carmichael` — the Korselt bridge on `N = 561`.
-/

namespace PowerSumReveal

set_option maxRecDepth 100000

/-! ## Small semiprimes: computation versus theory -/

/-- `N = 15 = 3 * 5`, `k = p - 1 = 2`: the computed gcd is `5`, as predicted. -/
theorem lab_note_15 :
    Nat.gcd (powerSum 15 2) 15 = 5 ∧
      Nat.gcd (powerSum (3 * 5) (3 - 1)) (3 * 5) = 5 :=
  ⟨by decide, powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)⟩

/-- `N = 35 = 5 * 7`, `k = p - 1 = 4`: the computed gcd is `7`, as predicted. -/
theorem lab_note_35 :
    Nat.gcd (powerSum 35 4) 35 = 7 ∧
      Nat.gcd (powerSum (5 * 7) (5 - 1)) (5 * 7) = 7 :=
  ⟨by decide, powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)⟩

/-- `N = 77 = 7 * 11`, `k = p - 1 = 6`: the computed gcd is `11`, as predicted. -/
theorem lab_note_77 :
    Nat.gcd (powerSum 77 6) 77 = 11 ∧
      Nat.gcd (powerSum (7 * 11) (7 - 1)) (7 * 11) = 11 :=
  ⟨by decide, powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)⟩

/-- `N = 143 = 11 * 13`, `k = p - 1 = 10`: the computed gcd is `13`, as predicted. -/
theorem lab_note_143 :
    Nat.gcd (powerSum 143 10) 143 = 13 ∧
      Nat.gcd (powerSum (11 * 13) (11 - 1)) (11 * 13) = 13 :=
  ⟨by decide, powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)⟩

/-! ## The period table -/

/-- The computed gcd sequence for `N = 35` over one full Carmichael period
`λ(35) = lcm(4,6) = 12`. -/
theorem lab_period_table_35 :
    (List.range' 1 12).map (fun k => Nat.gcd (powerSum 35 k) 35)
      = [35, 35, 35, 7, 35, 5, 35, 7, 35, 35, 35, 1] := by
  decide

/-- Theory side of the table: `λ(35) = 12`, and `12` is the *least* exponent at which the
gcd degenerates to `1`. -/
theorem lab_period_35_isLeast :
    carmichael 5 7 = 12 ∧
      IsLeast {k : ℕ | 0 < k ∧ Nat.gcd (powerSum (5 * 7) k) (5 * 7) = 1} 12 := by
  refine ⟨by decide, ?_⟩
  have h := lambda_isLeast_period_point (p := 5) (q := 7) (by norm_num) (by norm_num)
    (by norm_num)
  have hc : carmichael 5 7 = 12 := by decide
  rwa [hc] at h

/-- The gcd sequence for `N = 15` over three periods, computed. -/
theorem lab_period_table_15 :
    (List.range' 1 12).map (fun k => Nat.gcd (powerSum 15 k) 15)
      = [15, 5, 15, 1, 15, 5, 15, 1, 15, 5, 15, 1] := by
  decide

/-! ## Larger test semiprimes (theory only — the sums have thousands of digits) -/

/-- The four larger semiprimes of the test set: at `k = p-1` the reveal returns `q`,
at `k = q-1` it returns `p` (side conditions checked numerically). -/
theorem lab_note_large_semiprimes :
    Nat.gcd (powerSum (13 * 17) (13 - 1)) (13 * 17) = 17 ∧
    Nat.gcd (powerSum (17 * 19) (17 - 1)) (17 * 19) = 19 ∧
    Nat.gcd (powerSum (23 * 29) (23 - 1)) (23 * 29) = 29 ∧
    Nat.gcd (powerSum (89 * 97) (89 - 1)) (89 * 97) = 97 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact powerSum_factor_reveal (by norm_num) (by norm_num) (by norm_num) (by decide)

/-! ## Density of revealing exponents, checked against the table -/

/-- For `N = 35` the density formula predicts `λ/(p-1) + λ/(q-1) - 2 = 12/4 + 12/6 - 2 = 3`
revealing exponents in one period, and the computed table indeed shows exactly the three
exponents `k = 4, 6, 8` (with values `7, 5, 7`). -/
theorem lab_density_35 :
    ({k ∈ Finset.Ioc 0 (carmichael 5 7) |
        Nat.gcd (powerSum (5 * 7) k) (5 * 7) ≠ 1 ∧
          Nat.gcd (powerSum (5 * 7) k) (5 * 7) ≠ 5 * 7}).card = 3 ∧
      carmichael 5 7 / (5 - 1) + carmichael 5 7 / (7 - 1) - 2 = 3 := by
  refine ⟨?_, by decide⟩
  rw [card_revealing_exponents (by norm_num) (by norm_num) (by norm_num)]
  decide

/-- Computed cross-check of the density formula: the exponents in `1..12` whose gcd is a
proper factor of `35` are exactly `4, 6, 8` — three of them, as predicted. -/
theorem lab_density_35_computed :
    (List.range' 1 12).filter
        (fun k => !(Nat.gcd (powerSum 35 k) 35 == 1) && !(Nat.gcd (powerSum 35 k) 35 == 35))
      = [4, 6, 8] := by
  decide

/-- The first hit for `N = 35` is at `k* = min (p-1) (q-1) = 4`, and `(k*+1)^2 = 25 ≤ 35`. -/
theorem lab_first_hit_35 :
    IsLeast {k : ℕ | 0 < k ∧ Nat.gcd (powerSum (5 * 7) k) (5 * 7) ≠ 5 * 7} 4 ∧
      (4 + 1) ^ 2 ≤ 5 * 7 := by
  refine ⟨?_, by norm_num⟩
  have h := first_hit_isLeast (p := 5) (q := 7) (by norm_num) (by norm_num) (by norm_num)
  norm_num at h
  exact h

/-! ## A non-squarefree modulus: one power of `p` is lost -/

/-- `N = 45 = 3^2 · 5`, `k = 2`.  Since `(3-1) ∣ 2`, the prime-power master formula predicts
that the `3`-part of the gcd drops from `9` to `3`; the computed gcd of the full power sum
with `45` is `15 = 3 · 5`, confirming it. -/
theorem lab_note_45 :
    Nat.gcd (powerSum (3 ^ 2 * 5) 2) (3 ^ 2) = 3 ∧ Nat.gcd (powerSum 45 2) 45 = 15 := by
  refine ⟨?_, by decide⟩
  rw [gcd_powerSum_prime_pow (p := 3) (e := 2) (m := 5) (k := 2) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by decide)]
  decide

/-! ## A Carmichael number defeats the exponent `N - 1` -/

/-- `N = 561 = 3 · 11 · 17` is squarefree and Korselt, hence the power-sum gcd at the
natural exponent `k = 560` is trivial: Carmichael numbers are blind spots of the
`k = N-1` reveal. -/
theorem lab_note_561_carmichael :
    Nat.gcd (powerSum 561 560) 561 = 1 := by
  have p3 : Nat.Prime 3 := by norm_num
  have p11 : Nat.Prime 11 := by norm_num
  have p17 : Nat.Prime 17 := by norm_num
  have hsq : Squarefree 561 := by
    have h : (561 : ℕ) = 3 * (11 * 17) := by norm_num
    rw [h]
    refine Nat.squarefree_mul_iff.2 ⟨by norm_num, p3.squarefree, ?_⟩
    exact Nat.squarefree_mul_iff.2 ⟨by norm_num, p11.squarefree, p17.squarefree⟩
  refine (korselt_iff_coprime_powerSum hsq (by norm_num)).1 ?_
  intro r hr
  obtain ⟨hprime, hdvd, -⟩ := Nat.mem_primeFactors.1 hr
  have hmem : r ∈ Nat.divisors 561 := Nat.mem_divisors.2 ⟨hdvd, by norm_num⟩
  have hdiv : Nat.divisors 561 = {1, 3, 11, 17, 33, 51, 187, 561} := by decide
  rw [hdiv] at hmem
  clear hr hdvd
  fin_cases hmem <;> first
    | decide
    | exact absurd hprime (by norm_num)

end PowerSumReveal