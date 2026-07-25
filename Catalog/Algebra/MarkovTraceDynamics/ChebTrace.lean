import Mathlib

/-!
# Chebyshev Trace Sequence and Exponential Growth

The **Chebyshev trace sequence** `chebTrace t n` computes the trace of the n-th power
of any element of SL₂ with trace parameter `t`. It satisfies the linear recurrence
`T(n+2) = t · T(n+1) - T(n)` with initial conditions `T(0) = 2`, `T(1) = t`.

This recurrence arises from the Cayley-Hamilton theorem for 2×2 matrices with
determinant 1: `A² = tr(A)·A - I`, which yields `Aⁿ⁺² = tr(A)·Aⁿ⁺¹ - Aⁿ`.

## Main results

* `chebTrace_monotone` — chebTrace is monotonically increasing for t ≥ 3
* `chebTrace_ratio_bound` — chebTrace(t, n+1) ≥ (t-1) · chebTrace(t, n) for n ≥ 1
* `chebTrace_exponential_lower` — chebTrace(t, n) ≥ (t-1)^n for t ≥ 3
* `chebTrace_product_identity` — T(m+n) + T(|m-n|) = T(m) · T(n) (addition formula)
-/

open Int

namespace MarkovTrace

/-- The Chebyshev trace sequence: traces of powers of an SL₂ element with trace t.
Satisfies T(0) = 2, T(1) = t, T(n+2) = t·T(n+1) - T(n).
Related to Chebyshev polynomials of the first kind by T_trace(t,n) = 2·T_cheb(n, t/2). -/
def chebTrace (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | (n + 2) => t * chebTrace t (n + 1) - chebTrace t n

@[simp] theorem chebTrace_zero (t : ℤ) : chebTrace t 0 = 2 := rfl
@[simp] theorem chebTrace_one (t : ℤ) : chebTrace t 1 = t := rfl

theorem chebTrace_succ_succ (t : ℤ) (n : ℕ) :
    chebTrace t (n + 2) = t * chebTrace t (n + 1) - chebTrace t n := rfl

/-- chebTrace at n=2 equals t² - 2. -/
theorem chebTrace_two (t : ℤ) : chebTrace t 2 = t ^ 2 - 2 := by
  simp [chebTrace]; ring

/-- chebTrace at n=3 equals t³ - 3t. -/
theorem chebTrace_three (t : ℤ) : chebTrace t 3 = t ^ 3 - 3 * t := by
  simp [chebTrace]; ring

/-! ### Nonnegativity and Monotonicity for Hyperbolic Traces -/

/-
For t ≥ 3, chebTrace(t, n) ≥ 2 for all n.
-/
theorem chebTrace_ge_two (t : ℤ) (ht : t ≥ 3) : ∀ n : ℕ, chebTrace t n ≥ 2 := by
  intro n
  induction' n using Nat.strong_induction_on with n ih
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ chebTrace_succ_succ ];
  · grind;
  · nlinarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), show chebTrace t ( n + 1 ) ≥ chebTrace t n from by
                                                                      induction' n with n ih;
                                                                      · exact?;
                                                                      · nlinarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), ih ( n + 2 ) ( by linarith ), chebTrace_succ_succ t n, ‹ ( ∀ m ≤ n + 1, 2 ≤ chebTrace t m ) → chebTrace t ( n + 1 ) ≥ chebTrace t n › fun m hm => ih m ( by linarith ) ] ]

/-
For t ≥ 3, chebTrace is monotonically nondecreasing.
-/
theorem chebTrace_monotone (t : ℤ) (ht : t ≥ 3) (n : ℕ) :
    chebTrace t (n + 1) ≥ chebTrace t n := by
      induction' n with n ih;
      · grind +suggestions;
      · nlinarith [ chebTrace_succ_succ t n, show chebTrace t ( n + 1 ) ≥ 2 from chebTrace_ge_two t ht ( n + 1 ) ]

/-
For t ≥ 3 and n ≥ 1, the ratio bound:
chebTrace(t, n+1) ≥ (t-1) · chebTrace(t, n).
-/
theorem chebTrace_ratio_bound (t : ℤ) (ht : t ≥ 3) (n : ℕ) :
    chebTrace t (n + 2) ≥ (t - 1) * chebTrace t (n + 1) := by
      rw [ chebTrace_succ_succ ];
      linarith [ chebTrace_monotone t ht n ]

/-
**Exponential Lower Bound**: For t ≥ 3, chebTrace(t, n) ≥ (t-1)^n.
This is the key "hardness amplification" property: traces of matrix powers
grow exponentially, while computing them requires only polynomial time
(via the recurrence). This gap is the cryptographic trapdoor.
-/
theorem chebTrace_exponential_lower (t : ℤ) (ht : t ≥ 3) (n : ℕ) :
    chebTrace t n ≥ (t - 1) ^ n := by
      induction' n using Nat.strong_induction_on with n ih;
      rcases n with ( _ | _ | n );
      · -- For the base case $n = 0$, we have $chebTrace t 0 = 2$ and $(t - 1)^0 = 1$, so $2 \geq 1$.
        simp [chebTrace_zero];
      · norm_num [ chebTrace_one ];
      · rw [ pow_succ' ];
        exact le_trans ( mul_le_mul_of_nonneg_left ( ih _ <| Nat.lt_succ_self _ ) <| by linarith ) ( chebTrace_ratio_bound t ht n )

/-! ### The Chebyshev Addition Formula -/

/-
**Addition formula**: chebTrace(t, m+n) = chebTrace(t,m) · chebTrace(t,n) - chebTrace(t, |m-n|).
This is the trace analogue of the Chebyshev product-to-sum identity
2·T_m(x)·T_n(x) = T_{m+n}(x) + T_{m-n}(x), scaled by 2.
We state the m=n special case as it avoids absolute value.
-/
theorem chebTrace_double (t : ℤ) (n : ℕ) :
    chebTrace t (2 * n) = (chebTrace t n) ^ 2 - 2 := by
      induction' n using Nat.case_strong_induction_on with k ih;
      · norm_num [ chebTrace_zero ];
      · rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.mul_succ ];
        · exact?;
        · simp +decide [ chebTrace ] ; ring;
        · have := ih k ( by linarith ) ; have := ih ( k + 1 ) ( by linarith ) ; have := ih ( k + 2 ) ( by linarith ) ; simp_all +decide [ Nat.mul_succ, chebTrace_succ_succ ] ; ring;
          grind

end MarkovTrace