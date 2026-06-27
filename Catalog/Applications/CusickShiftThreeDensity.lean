/-
Copyright (c) 2025. All rights reserved.

# Exact Cusick Density for the Shift `t = 3` (the first `s₂(t) = 2` case)

## Overview

Cusick's conjecture (now a theorem) gives the explicit lower bound
`c_t ≥ 1/2 + 2^{-(2 s₂(t) + 1)}` for the asymptotic density
`c_t = dens { n : s₂(n) ≤ s₂(n + t) }`.

The companion files in this catalog compute the exact density only for shifts with
`s₂(t) = 1` (powers of two: `c_{2^k} = 3/4`, file `CusickDoublingInvariance.lean`).
This file breaks into the genuinely harder regime `s₂(t) = 2` by computing the
*exact* density for the smallest such shift, `t = 3`:

* `CusickShiftThree.cusick_t3_iff` — the pointwise criterion
  `s₂(n) ≤ s₂(n + 3) ↔ n % 16 ∉ {5, 7, 13, 14, 15}`.  The predicate `P_3` is
  therefore *purely periodic* with period `16 = 2^{L + s₂(3)}` (`L = 2`).
* `CusickShiftThree.cusick_t3_density` — the exact finite count
  `#{ n < 16m : s₂(n) ≤ s₂(n + 3) } = 11m`, hence `c_3 = 11/16`.
* `CusickShiftThree.cusick_t3_bound` — the explicit Cusick bound holds *with margin*:
  `c_3 = 11/16 ≥ 17/32 = 1/2 + 2^{-(2·s₂(3)+1)}`.
* `CusickShiftThree.cusick_t3_orbit_density` — propagation along the doubling orbit:
  `c_{3·2^k} = 11/16` for every `k` (the density depends only on the odd part of `t`).

The key new tool is the general **digit-concatenation** lemma `s2_concat`
(`s₂(2^M·b + a) = s₂(b) + s₂(a)` for `a < 2^M`), which lets the criterion be
established by splitting `n` into a low `4`-bit window `a = n % 16` (carrying the
finite `s₂(t)=2` carry analysis) and an arbitrary high part `b = n / 16`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The exact value `c_3 = 11/16` should be provable by the
same "periodic residue" mechanism that gave `c_1 = 3/4`, but the period jumps from
`4` to `16` and the overflow cases (`a + 3 ≥ 16`) are no longer trivially handled
by a single 2-adic valuation.  Conjecture: `P_3(n)` depends only on `n % 16`, with
exactly `11` good residues.

Experiment (Experimenter): Binary digit sums for `n < 2·10^5` confirm `P_3` is
purely periodic mod `16`, good residues `{0,1,2,3,4,6,8,9,10,11,12}`, bad residues
`{5,7,13,14,15}`.  Splitting `n = 16b + a`, `s₂(n) = s₂(b) + s₂(a)`: for `a ≤ 12`
the predicate is `s₂(a) ≤ s₂(a+3)` (independent of `b`); for `a ∈ {13,14,15}` the
high overflow makes it false for *every* `b`, because `s₂(b+1) ≤ s₂(b)+1`
(subadditivity) cannot absorb the loss of the three trailing high bits.

Analysis (Analyst): The overflow cases are where the `s₂(t)=1` template fails and
real content enters: the proof genuinely uses subadditivity `s2_subadditive`
(Legendre/Kummer) to kill the residues `13,14,15`, not a finite `decide`.  The
counting is an induction on `m`, valid for all `m`, so `11/16` is exact, not a
sampled estimate.  Combined with the doubling-orbit lemma the value spreads to the
whole family `{3, 6, 12, 24, …}`.

Critique (Critic): Is `cusick_t3_density` a disguised finite check?  No — it is an
induction on `m` over an unbounded window.  Is the bound vacuous?  No: `11/16`
exceeds `17/32` by `5/32 > 0`, a strict, explicit margin.  Does it extend the
catalog?  Yes — the previous Cusick files only resolve `s₂(t) = 1`; this is the
first fully-proved `s₂(t) = 2` density, the regime named as the hard case in
`CusickDoublingInvariance`'s notes.
-/

import Catalog.Applications.CusickDoublingInvariance

open Nat Finset

namespace CusickShiftThree

open CusickSumDigits CusickDensity CusickDoubling

/-
**Digit concatenation.**  Appending a low `M`-bit block `a < 2^M` below the
binary expansion of `b` adds the digit sums: `s₂(2^M·b + a) = s₂(b) + s₂(a)`.
-/
theorem s2_concat (M b a : ℕ) (ha : a < 2 ^ M) :
    s2 (2 ^ M * b + a) = s2 b + s2 a := by
  induction' M with M ih generalizing b a <;> simp_all +decide [ Nat.pow_succ', mul_assoc ];
  rcases Nat.even_or_odd' a with ⟨ k, rfl | rfl ⟩;
  · convert ih b k ( by linarith ) using 1;
    · convert CusickDoubling.s2_two_mul ( 2 ^ M * b + k ) using 1 ; ring;
    · exact congr_arg _ ( CusickDoubling.s2_two_mul k );
  · convert congr_arg ( · + 1 ) ( ih b k ( by linarith ) ) using 1;
    · convert CusickDoubling.s2_two_mul_add_one ( 2 ^ M * b + k ) using 1 ; ring;
    · rw [ add_assoc, CusickDoubling.s2_two_mul_add_one ]

/-
**Pointwise criterion for the shift `t = 3`.**  `s₂(n) ≤ s₂(n + 3)` holds iff
`n % 16` avoids the five bad residues `{5, 7, 13, 14, 15}`.  Equivalently `P_3` is
purely periodic with period `16`.
-/
theorem cusick_t3_iff (n : ℕ) :
    s2 n ≤ s2 (n + 3) ↔
      (n % 16 ≠ 5 ∧ n % 16 ≠ 7 ∧ n % 16 ≠ 13 ∧ n % 16 ≠ 14 ∧ n % 16 ≠ 15) := by
  by_contra h_contra;
  -- By definition of $s2$, we know that $s2(n) = s2(n / 16) + s2(n % 16)$.
  have h_s2_def : ∀ n, s2 n = s2 (n / 16) + s2 (n % 16) := by
    intro n
    rw [← s2_concat 4 (n / 16) (n % 16) (Nat.mod_lt _ (by decide))];
    norm_num [ Nat.div_add_mod ];
  rw [ h_s2_def n, h_s2_def ( n + 3 ) ] at h_contra ; norm_num [ Nat.add_mod, Nat.add_div ] at h_contra ⊢;
  have := Nat.mod_lt n ( by decide : 0 < 16 ) ; interval_cases n % 16 <;> simp +decide at h_contra;
  · have := s2_subadditive ( n / 16 ) 1; norm_num [ CusickSumDigits.s2 ] at *; omega;
  · -- By definition of $s2$, we know that $s2(n + 1) \leq s2(n) + 1$.
    have h_s2_add_one : ∀ n, s2 (n + 1) ≤ s2 n + 1 := by
      exact fun n => CusickSumDigits.s2_subadditive n 1;
    exact absurd h_contra ( by have := h_s2_add_one ( n / 16 ) ; norm_num [ CusickSumDigits.s2 ] at * ; linarith );
  · -- By definition of $s2$, we know that $s2(n + 1) \leq s2(n) + 1$.
    have h_s2_add_one : ∀ n, s2 (n + 1) ≤ s2 n + 1 := by
      exact fun n => by simpa using CusickSumDigits.s2_subadditive n 1;
    exact absurd h_contra ( by have := h_s2_add_one ( n / 16 ) ; norm_num [ CusickSumDigits.s2 ] at * ; linarith )

/-
Residue counting: exactly `11m` integers in `[0, 16m)` avoid the five bad
residues mod `16`.
-/
theorem count_t3_residues (m : ℕ) :
    ((range (16 * m)).filter
      (fun n => n % 16 ≠ 5 ∧ n % 16 ≠ 7 ∧ n % 16 ≠ 13 ∧ n % 16 ≠ 14 ∧ n % 16 ≠ 15)).card
      = 11 * m := by
  induction m <;> simp_all +arith +decide [ Nat.mul_succ, Finset.range_add_one ];
  simp_all +arith +decide [ Finset.filter_insert, Nat.add_mod ]

/-- **Exact finite density for `t = 3`.**  Exactly `11m` of the integers in
`[0, 16m)` satisfy `s₂(n) ≤ s₂(n + 3)`.  Hence `c_3 = 11/16`. -/
theorem cusick_t3_density (m : ℕ) :
    ((range (16 * m)).filter (fun n => s2 n ≤ s2 (n + 3))).card = 11 * m := by
  have hcongr : ((range (16 * m)).filter (fun n => s2 n ≤ s2 (n + 3)))
      = ((range (16 * m)).filter
          (fun n => n % 16 ≠ 5 ∧ n % 16 ≠ 7 ∧ n % 16 ≠ 13 ∧ n % 16 ≠ 14 ∧ n % 16 ≠ 15)) := by
    apply Finset.filter_congr
    intro n _
    simp only [cusick_t3_iff n]
  rw [hcongr, count_t3_residues]

/-- The exact `t = 3` density restated through the `cusickCount` counter of
`CusickDoublingInvariance`: `cusickCount 3 (16m) = 11m`. -/
theorem cusickCount_three (m : ℕ) : cusickCount 3 (16 * m) = 11 * m := by
  unfold cusickCount
  exact cusick_t3_density m

/-- **Explicit Cusick bound for `t = 3`, with margin.**  Over any aligned block
`[0, 16m)` the Cusick count is at least `17/32` of the block:
`32 · cusickCount 3 (16m) ≥ 17 · (16m)`.  Since the actual value is `11/16 = 22/32`,
the conjectured bound `1/2 + 2^{-(2·s₂(3)+1)} = 17/32` is cleared by `5/32`. -/
theorem cusick_t3_bound (m : ℕ) :
    32 * cusickCount 3 (16 * m) ≥ 17 * (16 * m) := by
  rw [cusickCount_three]; omega

/-- **Doubling-orbit density.**  For every `k`, `cusickCount (3·2^k) (2^k·16m) =
2^k·11m`, i.e. the Cusick density along the orbit `{3, 6, 12, 24, …}` is constantly
`11/16`.  Combines `cusickCount_three` with the orbit invariance
`cusickCount_two_pow_mul` from `CusickDoublingInvariance`. -/
theorem cusick_t3_orbit_density (k m : ℕ) :
    cusickCount (2 ^ k * 3) (2 ^ k * (16 * m)) = 2 ^ k * (11 * m) := by
  rw [cusickCount_two_pow_mul, cusickCount_three]

end CusickShiftThree