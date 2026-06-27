/-
Copyright (c) 2025. All rights reserved.

# Doubling Invariance and the Cusick Density for Powers of Two

## Overview

Cusick's conjecture concerns the asymptotic density
`c_t = dens { n : s₂(n + t) ≥ s₂(n) }`.  The companion file
`CusickDensityWitness.lean` computes the single exact value `c₁ = 3/4`
(bias `1/4` over the trivial `1/2`).  This file isolates the *structural*
mechanism behind that computation and propagates it to an entire infinite
family of shifts.

The key new insight is a **doubling invariance** of the Cusick predicate:
for every `n` and `t`,

* `s₂(n) ≤ s₂(n + t)  ↔  s₂(2n) ≤ s₂(2n + 2t)`   (even fibre), and
* `s₂(n) ≤ s₂(n + t)  ↔  s₂(2n+1) ≤ s₂(2n+1 + 2t)` (odd fibre).

Both fibres reduce to the *same* base predicate at `t`, because `s₂` is
invariant under appending a low `0` bit (`s₂(2n) = s₂(n)`) and shifts by one
under appending a low `1` bit (`s₂(2n+1) = s₂(n)+1`).  Consequently the finite
counting function

`cusickCount t N = #{ n < N : s₂(n) ≤ s₂(n + t) }`

satisfies the exact self-similarity `cusickCount (2t) (2N) = 2 · cusickCount t N`.

Iterating from the base case `cusickCount 1 (4m) = 3m` (proved in
`CusickDensityWitness.lean`) gives the headline result: for **every** `k`,

`cusickCount (2^k) (2^{k+2} · m) = 3 · 2^k · m`,

i.e. the Cusick density for the shift `t = 2^k` is exactly `3/4`, with explicit
bias `1/4` above `1/2`.  We also record the clean pointwise characterisation
`s₂(n) ≤ s₂(n + 2^k) ↔ (n / 2^k) % 4 ≠ 3`, the natural lift of the `t = 1`
criterion `n % 4 ≠ 3`.

Main results:

* `CusickDoubling.s2_two_mul` / `s2_two_mul_add_one` — the digit-sum recursion
  `s₂(2n) = s₂(n)` and `s₂(2n+1) = s₂(n)+1`.
* `CusickDoubling.cusick_double_even` / `cusick_double_odd` — doubling invariance
  of the Cusick predicate on each parity fibre.
* `CusickDoubling.cusick_pow2_iff` — `s₂(n) ≤ s₂(n + 2^k) ↔ (n / 2^k) % 4 ≠ 3`.
* `CusickDoubling.cusickCount_two_mul` — the self-similarity
  `cusickCount (2t) (2N) = 2 · cusickCount t N`.
* `CusickDoubling.cusick_pow2_density` — the explicit density
  `cusickCount (2^k) (2^{k+2} · m) = 3 · 2^k · m` (density `3/4`, bias `1/4`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The exact value `c₁ = 3/4` should not be an isolated
accident of `t = 1`.  Since `s₂` ignores low `0` bits and only shifts by one on a
low `1` bit, the Cusick predicate ought to be invariant under the simultaneous
doubling `(n, t) ↦ (2n, 2t)`.  If so, the whole orbit `{ t, 2t, 4t, … }` shares a
single density, and in particular every power of two inherits `c = 3/4` from
`t = 1`.

Experiment (Experimenter): Computationally (binary digit sums over `n < 768`,
`t < 30`) the two parity-fibre equivalences hold without exception, and the block
counts `cusickCount (2^k) (2^{k+2}·3)` come out as `9, 18, 36, 72 = 3·2^k·3` for
`k = 0,1,2,3`.  The pointwise rule `(n / 2^k) % 4 ≠ 3` matches on `n < 200`,
`k < 4`.

Analysis (Analyst): The proof factors cleanly.  `s2_two_mul(_add_one)` are pure
digit-recursion facts; the two invariance lemmas are one-line consequences via
`omega`; the counting self-similarity is a parity split of `range (2N)` into the
images of `j ↦ 2j` and `j ↦ 2j+1`; and the density follows by induction on `k`
from the `t = 1` base case `cusick_t1_density`.  No transfer operator or automaton
is needed for this *exact* sub-family — the difficulty in the general DKS bound
lives entirely in shifts with `s₂(t) ≥ 2`, which do not have a single rational
density forced by doubling alone.

Critique (Critic): Is `cusick_pow2_density` a disguised finite check?  No — it is
an induction on `k` (and on `m` inside the base case), valid for all `k, m`.  Is
the result vacuous?  No: `3 · 2^k · m` out of a block of `2^{k+2} · m = 4·(2^k m)`
is exactly `3/4`, strictly above `1/2`, so the bias `1/4` is genuine.  The
doubling invariance is an honest `↔`, both directions proved, not a one-way bound.
-/

import Applications.CusickDensityWitness

open Nat Finset

namespace CusickDoubling

open CusickSumDigits CusickDensity

/-
Appending a low `0` bit leaves the binary digit sum unchanged:
`s₂(2n) = s₂(n)`.
-/
theorem s2_two_mul (n : ℕ) : s2 (2 * n) = s2 n := by
  unfold s2;
  cases n <;> norm_num

/-
Appending a low `1` bit increases the binary digit sum by one:
`s₂(2n+1) = s₂(n) + 1`.
-/
theorem s2_two_mul_add_one (n : ℕ) : s2 (2 * n + 1) = s2 n + 1 := by
  unfold s2;
  grind +suggestions

/-- **Doubling invariance, even fibre.**  The Cusick predicate is invariant under
`(n, t) ↦ (2n, 2t)`. -/
theorem cusick_double_even (n t : ℕ) :
    (s2 (2 * n) ≤ s2 (2 * n + 2 * t)) ↔ (s2 n ≤ s2 (n + t)) := by
  have h1 : 2 * n + 2 * t = 2 * (n + t) := by ring
  rw [h1, s2_two_mul, s2_two_mul]

/-- **Doubling invariance, odd fibre.**  The Cusick predicate at `2n+1` for the
doubled shift `2t` reduces to the predicate at `n` for `t`. -/
theorem cusick_double_odd (n t : ℕ) :
    (s2 (2 * n + 1) ≤ s2 (2 * n + 1 + 2 * t)) ↔ (s2 n ≤ s2 (n + t)) := by
  have h1 : 2 * n + 1 + 2 * t = 2 * (n + t) + 1 := by ring
  rw [h1, s2_two_mul_add_one, s2_two_mul_add_one]
  omega

/-
**Pointwise criterion for power-of-two shifts.**  `s₂(n) ≤ s₂(n + 2^k)` holds
iff `(n / 2^k) % 4 ≠ 3`, the natural lift of the `t = 1` rule `n % 4 ≠ 3`.
-/
theorem cusick_pow2_iff (k n : ℕ) :
    s2 n ≤ s2 (n + 2 ^ k) ↔ (n / 2 ^ k) % 4 ≠ 3 := by
      -- Let q = n / 2^k and r = n % 2^k, so n = 2^k * q + r with r < 2^k.
      set q := n / 2^k
      set r := n % 2^k
      have hn : n = 2^k * q + r := by
        rw [ Nat.div_add_mod ]
      have hr : r < 2^k := by
        exact Nat.mod_lt _ ( by positivity );
      -- By the properties of the binary digit sum function, we have $s2 (2^k * q + r) = s2 q + s2 r$ and $s2 (2^k * (q + 1) + r) = s2 (q + 1) + s2 r$.
      have h_s2 : s2 (2^k * q + r) = s2 q + s2 r ∧ s2 (2^k * (q + 1) + r) = s2 (q + 1) + s2 r := by
        have h_s2 : ∀ (k q r : ℕ), r < 2^k → s2 (2^k * q + r) = s2 q + s2 r := by
          intros k q r hr
          induction' k with k ih generalizing q r;
          · simp +zetaDelta at *;
            simp +decide [ hr, s2 ];
          · rcases Nat.even_or_odd' r with ⟨ r, rfl | rfl ⟩ <;> simp +decide [ Nat.pow_succ', Nat.mul_assoc ] at hr ⊢;
            · convert ih q r hr using 1 ; ring;
              · convert s2_two_mul ( q * 2 ^ k + r ) using 1 ; ring;
              · exact congr_arg _ ( s2_two_mul _ );
            · convert congr_arg ( · + 1 ) ( ih q r ( by linarith ) ) using 1;
              · convert s2_two_mul_add_one ( 2 ^ k * q + r ) using 1 ; ring;
              · rw [ add_assoc, s2_two_mul_add_one ];
        exact ⟨ h_s2 k q r hr, h_s2 k ( q + 1 ) r hr ⟩;
      convert cusick_t1_iff q using 1;
      grind

/-- The finite Cusick counting function:
`cusickCount t N = #{ n < N : s₂(n) ≤ s₂(n + t) }`. -/
noncomputable def cusickCount (t N : ℕ) : ℕ :=
  ((range N).filter (fun n => s2 n ≤ s2 (n + t))).card

/-
Splitting a count over `range (2N)` into its even and odd fibres.
-/
theorem card_filter_range_two_mul (P : ℕ → Prop) [DecidablePred P] (N : ℕ) :
    ((range (2 * N)).filter P).card
      = ((range N).filter (fun j => P (2 * j))).card
        + ((range N).filter (fun j => P (2 * j + 1))).card := by
          induction' N with N ih <;> simp_all +arith +decide [ Nat.mul_succ, Finset.range_add_one ];
          by_cases h : P ( 2 * N + 1 ) <;> by_cases h' : P ( 2 * N ) <;> simp_all +arith +decide [ Finset.filter_insert ]

/-- **Self-similarity of the Cusick count.**  Doubling both the shift and the
window doubles the count: `cusickCount (2t) (2N) = 2 · cusickCount t N`. -/
theorem cusickCount_two_mul (t N : ℕ) :
    cusickCount (2 * t) (2 * N) = 2 * cusickCount t N := by
  unfold cusickCount
  rw [card_filter_range_two_mul (fun n => s2 n ≤ s2 (n + 2 * t)) N]
  have he : (range N).filter (fun j => s2 (2 * j) ≤ s2 (2 * j + 2 * t))
      = (range N).filter (fun n => s2 n ≤ s2 (n + t)) := by
    apply Finset.filter_congr
    intro j _
    exact cusick_double_even j t
  have ho : (range N).filter (fun j => s2 (2 * j + 1) ≤ s2 (2 * j + 1 + 2 * t))
      = (range N).filter (fun n => s2 n ≤ s2 (n + t)) := by
    apply Finset.filter_congr
    intro j _
    exact cusick_double_odd j t
  rw [he, ho]
  ring

/-- The base case of the density induction: `cusickCount 1 (4m) = 3m`, restating
`cusick_t1_density` in terms of `cusickCount`. -/
theorem cusickCount_one (m : ℕ) : cusickCount 1 (4 * m) = 3 * m := by
  unfold cusickCount
  exact cusick_t1_density m

/-- **Explicit Cusick density for powers of two.**  For every `k` and `m`,
`cusickCount (2^k) (2^{k+2} · m) = 3 · 2^k · m`.  Equivalently, exactly `3/4` of
the integers in any aligned block satisfy `s₂(n) ≤ s₂(n + 2^k)`, an explicit
density bias of `1/4` above `1/2`. -/
theorem cusick_pow2_density (k m : ℕ) :
    cusickCount (2 ^ k) (2 ^ (k + 2) * m) = 3 * 2 ^ k * m := by
  induction k with
  | zero => simpa using cusickCount_one m
  | succ k ih =>
    have hshift : (2 : ℕ) ^ (k + 1) = 2 * 2 ^ k := by ring
    have hwin : (2 : ℕ) ^ (k + 1 + 2) * m = 2 * (2 ^ (k + 2) * m) := by ring
    rw [hshift, hwin, cusickCount_two_mul, ih]
    ring

/-- **Full doubling-orbit invariance.**  Multiplying both the shift `t` and the
window `N` by `2^k` scales the count by `2^k`:
`cusickCount (2^k · t) (2^k · N) = 2^k · cusickCount t N`.  In density terms this
says the Cusick density is constant along the orbit `{ t, 2t, 4t, … }`, i.e. it
depends only on the odd part of `t`. -/
theorem cusickCount_two_pow_mul (k t N : ℕ) :
    cusickCount (2 ^ k * t) (2 ^ k * N) = 2 ^ k * cusickCount t N := by
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 : (2 : ℕ) ^ (k + 1) * t = 2 * (2 ^ k * t) := by ring
    have h2 : (2 : ℕ) ^ (k + 1) * N = 2 * (2 ^ k * N) := by ring
    rw [h1, h2, cusickCount_two_mul, ih]
    ring

/-- **Explicit density bias for power-of-two shifts.**  Over any aligned block
`[0, 2^{k+2}·m)`, whose exact half is `2^{k+1}·m`, the Cusick count *exceeds the
half* by exactly `2^k·m`.  This is the explicit bias `1/4` (since
`2^k·m = (1/4)·2^{k+2}·m`) of the density `c_{2^k} = 3/4` above the trivial `1/2`. -/
theorem cusick_pow2_bias (k m : ℕ) :
    cusickCount (2 ^ k) (2 ^ (k + 2) * m) = 2 ^ (k + 1) * m + 2 ^ k * m := by
  rw [cusick_pow2_density]
  ring

end CusickDoubling