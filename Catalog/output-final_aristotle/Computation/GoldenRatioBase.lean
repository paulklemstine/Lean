import Mathlib

/-!
# Base `φ`: The Golden-Ratio Number System

This file studies the *golden-ratio base* (base `φ`, "phinary"), the positional
system whose radix is the golden ratio `φ = (1 + √5)/2`.  Its defining feature,
famously exploited in the study of "beautiful" number systems, is that integers
can be written with only the digits `0` and `1` and **no two consecutive `1`s**.

The mechanism behind the no-two-consecutive-`1`s phenomenon is the single
algebraic identity `φ² = φ + 1`, which in positional form reads

`φⁿ + φⁿ⁺¹ = φⁿ⁺²`  (i.e. `011 = 100` in base `φ`).

We connect base `φ` to two other structures:

* the **Fibonacci sequence** (combinatorics): every base-`φ` value with natural
  exponents lands in the ring `ℤ + ℤ·φ`, with coordinates given by Fibonacci sums
  (`phiSum_fib`), and symmetric golden/conjugate power sums are integers
  (`golden_conj_pow_sum`, a Lucas-number identity);
* the **irrationality of `φ`** (analysis): because `φ` is irrational, the
  coordinate pair `(a, b)` of a value `a·φ + b` is *unique* over the rationals
  (`phi_coord_unique`), which is exactly what makes base-`φ` "coordinates"
  well defined.

As a concrete illustration, `phi_repr_three` verifies the classical phinary
expansion `3 = 100.01₍φ₎`, i.e. `φ² + φ⁻² = 3`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Base `φ` should let every integer be written
  with digits `{0,1}` and no two adjacent `1`s.  Grand form: base `φ` bridges the
  analytic world of the irrational radix `φ` and the combinatorial world of the
  Fibonacci / Zeckendorf structure, with the "no consecutive `1`s" rule being the
  positional shadow of `φ² = φ + 1`.
* **Experiment (Experimenter).**  Proved the carry/collapse rule `phiPow_carry`
  (`011 → 100`), the Fibonacci-coordinate bridge `phiSum_fib`, the Lucas integer
  identity `golden_conj_pow_sum`, coordinate uniqueness from irrationality
  `phi_coord_unique`, and the concrete expansion `φ² + φ⁻² = 3`.
* **Analysis (Analyst).**  "True and structural."  The whole no-consecutive-`1`s
  story reduces to `φ² = φ + 1`.  Natural-exponent values never leave `ℤ + ℤ·φ`,
  and genuine integers appear exactly for the *symmetric* (Lucas) combinations —
  which is why representing an arbitrary integer needs negative exponents too
  (as in `3 = φ² + φ⁻²`).
* **Critique (Critic).**  Coordinate uniqueness would be FALSE over `ℝ` (any real
  is `a·φ + b` in many ways); it holds precisely over the rationals and rests on
  the irrationality of `φ`.  The identities are not `norm_num` trivialities: each
  invokes `φ² = φ + 1`, Binet-type Fibonacci lemmas, or `Irrational φ`.
* **Synthesis (PI).**  Base `φ` is realized as a faithful bridge: the carry rule
  explains the digit restriction, Fibonacci sums give the coordinates, and
  irrationality guarantees uniqueness — three domains meeting in one radix.
-/

namespace GoldenRatioBase

open Real
open scoped goldenRatio

/-
**Base-`φ` carry / collapse rule.**  Two consecutive `1`s at positions `n` and
`n+1` collapse to a single `1` at position `n+2`: `011 = 100` in base `φ`.  This is
the positional form of `φ² = φ + 1` and is the reason integers admit base-`φ`
expansions with no two consecutive `1`s.
-/
theorem phiPow_carry (n : ℕ) : φ ^ n + φ ^ (n + 1) = φ ^ (n + 2) := by
  grind +qlia

/-
**Uniqueness of base-`φ` coordinates over `ℚ`.**  Because `φ` is irrational, a
value in `ℚ + ℚ·φ` determines its two coordinates uniquely.
-/
theorem phi_coord_unique {a b c d : ℚ}
    (h : (a : ℝ) * φ + b = (c : ℝ) * φ + d) : a = c ∧ b = d := by
  by_contra h_neq;
  -- Since $a \neq c$, we can divide both sides of the equation by $(a - c)$ to get $\varphi = \frac{d - b}{a - c}$.
  have h_div : φ = (d - b) / (a - c) := by
    rw [ eq_div_iff ] <;> first | linarith | intro H ; simp_all +decide [ sub_eq_iff_eq_add ] ;
  exact Nat.Prime.irrational_sqrt ( show Nat.Prime 5 by norm_num ) ⟨ ( d - b ) / ( a - c ) * 2 - 1, by push_cast [ ← h_div ] ; ring ⟩

/-
**Fibonacci-coordinate bridge.**  Any finite base-`φ` value with natural
exponents lies in `ℤ + ℤ·φ`, and its two coordinates are Fibonacci sums:
`∑_{i∈S} φ^{i+1} = (∑_{i∈S} F_{i+1})·φ + ∑_{i∈S} F_i`.
-/
theorem phiSum_fib (S : Finset ℕ) :
    ∑ i ∈ S, φ ^ (i + 1)
      = (∑ i ∈ S, (Nat.fib (i + 1) : ℝ)) * φ + ∑ i ∈ S, (Nat.fib i : ℝ) := by
  rw [ Finset.sum_mul _ _ _ ];
  rw [ ← Finset.sum_add_distrib ] ; congr ; ext i ;
  -- Apply the lemma `Real.goldenRatio_mul_fib_succ_add_fib` to each term in the sum.
  have h_term : ∀ i : ℕ, (Nat.fib (i + 1) : ℝ) * φ + (Nat.fib i : ℝ) = φ ^ (i + 1) := by
    exact fun i => by rw [ ← Real.goldenRatio_mul_fib_succ_add_fib ] ; ring;
  rw [ h_term ]

/-
**Lucas integer identity.**  The symmetric combination of a golden-ratio power
and its conjugate is an integer (a Lucas number):
`φ^{n+1} + ψ^{n+1} = F_{n+2} + F_n`.
-/
theorem golden_conj_pow_sum (n : ℕ) :
    φ ^ (n + 1) + ψ ^ (n + 1) = (Nat.fib (n + 2) + Nat.fib n : ℝ) := by
  -- Add the two Mathlib identities and then use goldenRatio_add_goldenConj.
  have h_sum : (φ * Nat.fib (n + 1) + Nat.fib n) + (ψ * Nat.fib (n + 1) + Nat.fib n) = (φ^(n+1) + ψ^(n+1)) := by
    convert congr_arg₂ ( · + · ) ( Real.goldenRatio_mul_fib_succ_add_fib n ) ( Real.goldenConj_mul_fib_succ_add_fib n ) using 1;
  convert h_sum.symm using 1 ; push_cast [ Nat.fib_add_two ] ; ring

/-
**The classical phinary expansion `3 = 100.01₍φ₎`.**  Using one positive and
one negative power, `φ² + φ⁻² = 3`, an integer written in base `φ` with digits
`{0,1}` and no two consecutive `1`s.
-/
theorem phi_repr_three : φ ^ (2 : ℤ) + φ ^ (-2 : ℤ) = 3 := by
  norm_cast ; norm_num [ goldenRatio_sq ];
  grind

end GoldenRatioBase