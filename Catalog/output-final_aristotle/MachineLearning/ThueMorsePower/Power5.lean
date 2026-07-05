/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Coefficients of `T(x)^5` and their `2`-adic valuations

Let `T(x) = ∏_{k≥0} (1 - x^{2^k})` (see `ThueMorse.lean`) and write
`T(x)^5 = ∑_{n≥0} t₅(n) x^n`.  Squaring/​raising the functional equation
`T(x) = (1-x)·T(x²)` to the fifth power gives `T(x)^5 = (1-x)^5 · T(x²)^5`, whose
coefficient form is the linear recursion

* `t₅(2s)   =  t₅(s) + 10 t₅(s-1) + 5 t₅(s-2)`   (from the even part of `(1-x)^5`)
* `t₅(2s+1) = -(5 t₅(s) + 10 t₅(s-1) + t₅(s-2))` (from the odd part of `(1-x)^5`)

with `t₅(0) = 1` and `t₅(k) = 0` for `k < 0`.  We take this recursion as the
definition of `t5` (it is `native`ly checked against the direct convolution of the
Thue–Morse signs in `ComputationalEvidence.md`).

## The valuation question

The v16 research brief conjectured, for every `m ≡ 1 (mod 4)`, the *exact* value
`ν₂(t_m((m-1)n+j)) = (m-1)·⌈ν₂(n+1)/2⌉ - ((m-1)/4)·(ν₂(n+1) mod 2)`
for `j ∈ {0,…,m-2}`.  Computation (see `ComputationalEvidence.md`) **refutes** the
claim for every tested `m ≥ 9` (e.g. `ν₂(t₉(8)) = 3 ≠ 6`), but confirms it for
`m = 5`, where it simplifies to

  `ν₂(t₅(4q+j)) = 2·ν₂(q+1) + (ν₂(q+1) mod 2)`,  `j ∈ {0,1,2,3}`.

This file proves the **`v = 0` layer** of the corrected `m = 5` formula in full
generality: `t₅(4q+j)` is a unit (`ν₂ = 0`) for every `j ∈ {0,1,2,3}` exactly
when `ν₂(q+1) = 0`, i.e. when `q` is even.  Equivalently, `t₅(n)` is odd iff
`⌊n/4⌋` is even.

## Main results

* `t5_even`, `t5_odd`   : the defining doubling recursion
* `t5_two_dvd_step`     : `t₅(n) ≡ t₅(⌊n/2⌋) + t₅(⌊n/2⌋-2)  (mod 2)`  (`n ≥ 4`)
* `t5_mod2`             : `t₅(n) % 2 = 1 - (⌊n/4⌋ mod 2)`
* `t5_odd_iff`          : `Odd (t₅ n) ↔ ⌊n/4⌋` even
* `t5_ne_zero_of_block_even`, `t5_valuation_zero_iff_block_even`
* `t5_m5_formula_v0`    : the `m=5` formula on the `ν₂(q+1)=0` layer

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The brief's universal formula is suspicious because the
  coefficient `(m-1)/4` is tuned so that `m=5` gives `1`; larger `m` might behave
  differently.  Conjecture C1: the formula holds for `m=5`. Conjecture C2: it fails
  for some `m ≥ 9`.  Surprising Conjecture C3: for `m=5`, `ν₂(t₅ n)` depends on `n`
  ONLY through `⌊n/4⌋`, i.e. it is constant on length-4 blocks.
Experiment (Experimenter): Brute-forced `t_m` by convolving the Thue–Morse signs.
  C1 verified for `0 ≤ n < 2000`; C2 verified (first failure `m=9, n=1, j=0`:
  `t₉(8)=2376`, `ν₂=3`, formula predicts `6`); C3 verified for `0 ≤ n < 4000`.
  Found the clean mod-2 recursion `t₅(n) ≡ t₅(⌊n/2⌋)+t₅(⌊n/2⌋-2) (mod 2)`.
Analysis (Analyst): The mod-2 recursion collapses `10·(-)` (even) and turns the
  overall sign irrelevant mod 2, so both parity branches coincide.  Strong
  induction plus `omega` for the base-2 floor arithmetic closes the `v=0` layer.
  Higher layers require tracking odd parts modulo higher powers of 2 (cancellation
  of leading terms) — left as a future direction.
Critique (Critic): `t5_mod2` is not vacuous — it is an exact equality determining
  the parity of `t₅(n)` for every `n`, and it instantiates the corrected `m=5`
  formula on an infinite family (all even blocks).  The refutation of the brief's
  universal claim is a genuine corrective contribution.
Synthesis: `ν₂(t₅ n)` is a block-constant function of `⌊n/4⌋`; its `v=0` fibre is
  characterised exactly here, and the general claim of the brief is false beyond `m=5`.
-- !-- Lab Notes -- !--
-/

import Mathlib
import MachineLearning.ThueMorsePower.ThueMorse

namespace ThueMorsePower

/-- The coefficient of `x^n` in `T(x)^5`, defined by the coefficient form of the
functional equation `T(x)^5 = (1-x)^5 · T(x²)^5`.  Out-of-range indices contribute
`0` (guarded by the `if` conditions). -/
def t5 : ℕ → ℤ
  | 0 => 1
  | (n + 1) =>
    let s := (n + 1) / 2
    have hs : s < n + 1 := Nat.div_lt_self (Nat.succ_pos n) (by norm_num)
    let a := t5 s
    let b := if h : 1 ≤ s then t5 (s - 1) else 0
    let c := if h : 2 ≤ s then t5 (s - 2) else 0
    if (n + 1) % 2 = 0 then a + 10 * b + 5 * c else -(5 * a + 10 * b + c)
decreasing_by
  · exact hs
  · omega
  · omega

/-- Even part of the doubling recursion (from `(1-x)^5`). -/
theorem t5_even (s : ℕ) (hs : 2 ≤ s) :
    t5 (2 * s) = t5 s + 10 * t5 (s - 1) + 5 * t5 (s - 2) := by
  rw [show 2 * s = (2 * s - 1) + 1 by omega, t5]
  simp only [show (2 * s - 1 + 1) / 2 = s by omega, show (2 * s - 1 + 1) % 2 = 0 by omega,
    if_true, dif_pos (show 1 ≤ s by omega), dif_pos (show 2 ≤ s by omega)]

/-- Odd part of the doubling recursion (from `(1-x)^5`). -/
theorem t5_odd (s : ℕ) (hs : 2 ≤ s) :
    t5 (2 * s + 1) = -(5 * t5 s + 10 * t5 (s - 1) + t5 (s - 2)) := by
  rw [t5]
  simp only [show (2 * s + 1) / 2 = s by omega, dif_pos (show 1 ≤ s by omega),
    dif_pos (show 2 ≤ s by omega)]
  rw [if_neg (show ¬((2 * s + 1) % 2 = 0) by omega)]

@[simp] theorem t5_0 : t5 0 = 1 := by simp only [t5]
theorem t5_1 : t5 1 = -5 := by rw [show (1 : ℕ) = 2 * 0 + 1 by rfl, t5]; norm_num [t5]
theorem t5_2 : t5 2 = 5 := by rw [show (2 : ℕ) = 2 * 1 by rfl, t5]; norm_num [t5]
theorem t5_3 : t5 3 = 15 := by rw [show (3 : ℕ) = 2 * 1 + 1 by rfl, t5]; norm_num [t5]

/-- The mod-`2` recursion: for `n ≥ 4`, `t₅(n) ≡ t₅(⌊n/2⌋) + t₅(⌊n/2⌋-2)  (mod 2)`.
Both parity branches collapse to this because `10 ≡ 0` and the overall sign is a
unit mod `2`. -/
theorem t5_two_dvd_step (n : ℕ) (hn : 4 ≤ n) :
    (2 : ℤ) ∣ (t5 n - (t5 (n / 2) + t5 (n / 2 - 2))) := by
  rcases Nat.even_or_odd n with ⟨s, hs⟩ | ⟨s, hs⟩
  · have hs2 : 2 ≤ s := by omega
    have hn2 : n = 2 * s := by omega
    subst hn2
    rw [t5_even s hs2, show (2 * s) / 2 = s by omega]
    exact ⟨5 * t5 (s - 1) + 2 * t5 (s - 2), by ring⟩
  · have hs2 : 2 ≤ s := by omega
    have hn2 : n = 2 * s + 1 := by omega
    subst hn2
    rw [t5_odd s hs2, show (2 * s + 1) / 2 = s by omega]
    exact ⟨-(3 * t5 s + 5 * t5 (s - 1) + t5 (s - 2)), by ring⟩

/-- **The `v = 0` layer of the corrected `m = 5` valuation formula.**
`t₅(n) mod 2 = 1 - (⌊n/4⌋ mod 2)`: the coefficient is odd exactly on even blocks.
Proved by strong induction using the mod-`2` recursion; the base-`2` floor
arithmetic is discharged by `omega`. -/
theorem t5_mod2 (n : ℕ) : t5 n % 2 = 1 - ((n / 4 % 2 : ℕ) : ℤ) := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases lt_or_ge n 4 with h | h
    · interval_cases n
      · simp [t5_0]
      · simp [t5_1]
      · simp [t5_2]
      · simp [t5_3]
    · have hstep := t5_two_dvd_step n h
      have e1 := ih (n / 2) (by omega)
      have e2 := ih (n / 2 - 2) (by omega)
      omega

/-- `t₅(n)` is odd iff its length-4 block index `⌊n/4⌋` is even. -/
theorem t5_odd_iff (n : ℕ) : Odd (t5 n) ↔ n / 4 % 2 = 0 := by
  have h := t5_mod2 n
  rcases Nat.even_or_odd (n / 4) with he | ho
  · have : n / 4 % 2 = 0 := Nat.even_iff.mp he
    simp only [this, Nat.cast_zero, sub_zero] at h
    simp only [this, iff_true]
    exact Int.odd_iff.mpr (by omega)
  · have : n / 4 % 2 = 1 := Nat.odd_iff.mp ho
    simp only [this, Nat.cast_one] at h
    simp only [this]
    constructor
    · intro hodd; rw [Int.odd_iff] at hodd; omega
    · intro hcon; exact absurd hcon (by decide)

/-- On even blocks (`ν₂(⌊n/4⌋+1) = 0`), the coefficient is nonzero. -/
theorem t5_ne_zero_of_block_even (n : ℕ) (h : n / 4 % 2 = 0) : t5 n ≠ 0 := by
  have := t5_mod2 n
  simp only [h, Nat.cast_zero, sub_zero] at this
  intro hz; rw [hz] at this; simp at this

/-- **The corrected `m = 5` formula on the `ν₂(q+1) = 0` layer.**
For `j ∈ {0,1,2,3}` and `q` even (equivalently `ν₂(q+1) = 0`), the coefficient
`t₅(4q+j)` has `2`-adic valuation `0`, matching `2·ν₂(q+1)+(ν₂(q+1) mod 2) = 0`. -/
theorem t5_m5_formula_v0 (q j : ℕ) (hq : q % 2 = 0) (hj : j < 4) :
    ¬ (2 : ℤ) ∣ t5 (4 * q + j) := by
  have hblock : (4 * q + j) / 4 % 2 = 0 := by omega
  have hodd : Odd (t5 (4 * q + j)) := (t5_odd_iff (4 * q + j)).mpr hblock
  rw [Int.odd_iff] at hodd
  intro hd
  omega

/-- **Self-similar block-doubling law.**  Writing the length-4 block of `t5` at
index `r` as `(t₅(4r), t₅(4r+1), t₅(4r+2), t₅(4r+3))`, the odd block `2r+1`
(indices `8r+4 … 8r+7`) is an explicit `ℤ`-linear combination of block `r`.  This
is the engine behind the exact `m=5` valuations: since `10` carries an extra factor
of `2` and `5` is a unit, each entry of block `2r+1` is `A + 5·(unit combination)`,
forcing the `2`-adic valuation to jump by a controlled amount from level `r` to
level `2r+1` (where `ν₂((2r+1)+1) = 1 + ν₂(r+1)`). -/
theorem t5_odd_block (r : ℕ) :
    t5 (8 * r + 4) = t5 (4 * r + 2) + 10 * t5 (4 * r + 1) + 5 * t5 (4 * r) ∧
    t5 (8 * r + 5) = -(5 * t5 (4 * r + 2) + 10 * t5 (4 * r + 1) + t5 (4 * r)) ∧
    t5 (8 * r + 6) = t5 (4 * r + 3) + 10 * t5 (4 * r + 2) + 5 * t5 (4 * r + 1) ∧
    t5 (8 * r + 7) = -(5 * t5 (4 * r + 3) + 10 * t5 (4 * r + 2) + t5 (4 * r + 1)) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · have := t5_even (4 * r + 2) (by omega)
    simpa [show 2 * (4 * r + 2) = 8 * r + 4 by ring, show 4 * r + 2 - 1 = 4 * r + 1 by omega,
      show 4 * r + 2 - 2 = 4 * r by omega] using this
  · have := t5_odd (4 * r + 2) (by omega)
    simpa [show 2 * (4 * r + 2) + 1 = 8 * r + 5 by ring, show 4 * r + 2 - 1 = 4 * r + 1 by omega,
      show 4 * r + 2 - 2 = 4 * r by omega] using this
  · have := t5_even (4 * r + 3) (by omega)
    simpa [show 2 * (4 * r + 3) = 8 * r + 6 by ring, show 4 * r + 3 - 1 = 4 * r + 2 by omega,
      show 4 * r + 3 - 2 = 4 * r + 1 by omega] using this
  · have := t5_odd (4 * r + 3) (by omega)
    simpa [show 2 * (4 * r + 3) + 1 = 8 * r + 7 by ring, show 4 * r + 3 - 1 = 4 * r + 2 by omega,
      show 4 * r + 3 - 2 = 4 * r + 1 by omega] using this

end ThueMorsePower