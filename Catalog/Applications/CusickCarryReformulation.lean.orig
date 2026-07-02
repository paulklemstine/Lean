/-
Copyright (c) 2025. All rights reserved.

# Cusick's Inequality as a Carry-Counting Statement (Kummer's Theorem)

## Overview

Cusick's conjecture concerns the density of integers `n` with
`s₂(n + t) ≥ s₂(n)`.  This file proves the structural heart of the problem: the
inequality `s₂(n + t) ≥ s₂(n)` is **exactly** the statement that the number of
*carries* produced when adding `n` and `t` in binary is at most `s₂(t)`.

We define the carry count via **Kummer's theorem**:
`carries t n = v₂( C(n + t, t) )`, the 2-adic valuation of the binomial
coefficient.  The catalog reference `2_adic_valuation_binomial_coefficients` is
realised here by `Nat.sub_one_mul_padicValNat_choose_eq_sub_sum_digits'`.

Main results:

* `CusickCarry.carries_eq_sub` — Kummer: `carries t n = s₂(t) + s₂(n) − s₂(n+t)`.
* `CusickCarry.s2_add_carries` — the additive carry identity
  `s₂(n + t) + carries t n = s₂(n) + s₂(t)`.
* `CusickCarry.cusick_reformulation` — `s₂(n) ≤ s₂(n + t) ↔ carries t n ≤ s₂(t)`.
* `CusickCarry.cusick_of_no_carry` — no carries ⇒ the Cusick inequality holds
  with the *maximal* gain `s₂(n + t) = s₂(n) + s₂(t)`.
* `CusickCarry.carries_le_total` — the elementary upper bound
  `carries t n ≤ s₂(n) + s₂(t)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Cusick's inequality is secretly about carries."
Concretely `s₂(n+t) = s₂(n) + s₂(t) − (#carries)`, so `s₂(n+t) ≥ s₂(n)` iff
`#carries ≤ s₂(t)`.  This should reduce a density question about digit sums to a
density question about carry counts.

Experiment (Experimenter): Kummer's theorem in Mathlib
(`sub_one_mul_padicValNat_choose_eq_sub_sum_digits'`) gives, for `p = 2`,
`v₂(C(n+t,t)) = s₂(t) + s₂(n) − s₂(n+t)` in truncated `ℕ` subtraction.  Pairing
this with `s2_subadditive` (so the subtraction is genuine) and `omega` yields the
clean additive identity and the iff reformulation.

Analysis (Analyst): The reformulation is a genuine equivalence, not a one-way
bound — both directions fall out of the additive identity.  The "no carry" case
is the extremal witness used downstream to produce infinitely many solutions.
A natural-looking bound `carries t n ≤ s₂(t)` turns out to be FALSE in general
(it is exactly equivalent to the Cusick inequality, by the reformulation): e.g.
`n = 3, t = 1` gives `carries = 2 > s₂(1) = 1`, and indeed `s₂(4) = 1 < s₂(3) = 2`.
Only the symmetric total bound `carries ≤ s₂(n) + s₂(t)` is unconditional.

Critique (Critic): Could the iff be vacuous?  No: for `t = 1`, `s₂(1) = 1`, so the
reformulation says `s₂(n+1) ≥ s₂(n) ↔ (#carries when adding 1) ≤ 1`, i.e. `n`'s
binary expansion ends in at most one `1` — a non-trivial, checkable condition.
The proof depends essentially on `s2_subadditive` (Legendre), not on `decide`.
-/

import Applications.CusickSumOfDigits

open Nat

namespace CusickCarry

open CusickSumDigits

/-- The number of carries when adding `n` and `t` in base 2, defined via
**Kummer's theorem** as the 2-adic valuation of `C(n + t, t)`. -/
noncomputable def carries (t n : ℕ) : ℕ := padicValNat 2 ((n + t).choose t)

/-- **Kummer's theorem (subtraction form).**  The carry count equals
`s₂(t) + s₂(n) − s₂(n + t)`. -/
theorem carries_eq_sub (n t : ℕ) : carries t n = s2 t + s2 n - s2 (n + t) := by
  have := @sub_one_mul_padicValNat_choose_eq_sub_sum_digits' 2 t n ⟨Nat.prime_two⟩
  simpa [carries, s2] using this

/-- **The additive carry identity**: the digit sum of `n + t` plus the number of
carries recovers `s₂(n) + s₂(t)`. -/
theorem s2_add_carries (n t : ℕ) : s2 (n + t) + carries t n = s2 n + s2 t := by
  have h1 := carries_eq_sub n t
  have h2 := s2_subadditive n t
  omega

/-- **Cusick's inequality as carry counting.**  `s₂(n + t) ≥ s₂(n)` holds if and
only if the number of carries in `n + t` is at most `s₂(t)`. -/
theorem cusick_reformulation (n t : ℕ) :
    s2 n ≤ s2 (n + t) ↔ carries t n ≤ s2 t := by
  have := s2_add_carries n t
  omega

/-- **No-carry extremal case.**  When adding `n` and `t` produces no carries,
the digit sum is exactly additive, so the Cusick inequality holds with the
maximal possible gain. -/
theorem cusick_of_no_carry (n t : ℕ) (h : carries t n = 0) :
    s2 (n + t) = s2 n + s2 t := by
  have := s2_add_carries n t
  omega

/-- The unconditional upper bound on the carry count: `carries t n ≤ s₂(n)+s₂(t)`.
Unlike the one-sided bound `carries t n ≤ s₂(t)` (which is equivalent to the
Cusick inequality and can fail), this holds for all `n` and `t`. -/
theorem carries_le_total (n t : ℕ) : carries t n ≤ s2 n + s2 t := by
  have h := s2_add_carries n t
  omega

end CusickCarry