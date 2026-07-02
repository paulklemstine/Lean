/-
Copyright (c) 2025. All rights reserved.

# Density Witnesses for Cusick's Sum-of-Digits Inequality

## Overview

Cusick's conjecture (now a theorem) asserts that the asymptotic density
`c_t = dens { n : s₂(n + t) ≥ s₂(n) }` satisfies the explicit lower bound
`c_t ≥ 1/2 + 2^{-(2 s₂(t) + 1)}`.  The full asymptotic statement requires a
delicate transfer-operator / automaton analysis.  This file supplies two
*rigorous* density witnesses that bracket the phenomenon:

* `CusickDensity.s2_high_bit` — placing a fresh high bit above `t` never causes a
  carry: `s₂(t + 2ᴸ) = s₂(t) + 1` whenever `t < 2ᴸ`.
* `CusickDensity.cusick_good_set_infinite` — the Cusick "good set"
  `{ n : s₂(n) ≤ s₂(n + t) }` is **infinite** for every `t`, witnessed by the
  sparse family `n = 2^(j + t)`.
* `CusickDensity.cusick_t1_iff` — for `t = 1` the inequality is governed by the
  2-adic valuation: `s₂(n) ≤ s₂(n + 1) ↔ n % 4 ≠ 3`.
* `CusickDensity.cusick_t1_density` — the **exact finite density** for `t = 1`:
  exactly `3m` of the integers in `[0, 4m)` satisfy `s₂(n) ≤ s₂(n + 1)`.  Hence
  `c₁ = 3/4 = 1/2 + 1/4`, strictly exceeding the conjectured bound
  `1/2 + 2^{-(2·s₂(1)+1)} = 1/2 + 1/8` for `t = 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The density `c_t` should be *strictly* above `1/2`,
and for the simplest `t = 1` we can compute it exactly.  The carry reformulation
predicts the good set is `{ n : v₂(n+1) ≤ s₂(1) = 1 }`.

Experiment (Experimenter): `carries 1 n = v₂((n+1).choose 1) = v₂(n+1)` after
`Nat.choose_one_right`, so the `t = 1` condition is `v₂(n+1) ≤ 1`, i.e.
`4 ∤ (n+1)`, i.e. `n % 4 ≠ 3`.  Counting residues over `[0, 4m)` gives exactly
`3m` survivors, so `c₁ = 3/4`.  Infinitude for general `t` follows from the
no-carry witness `s2_high_bit` applied to `n = 2^(j+t)`.

Analysis (Analyst): The `t = 1` computation gives a clean, fully-proved instance
of the explicit gap: `3/4 ≥ 5/8`, with room to spare.  The general asymptotic
bound is *true but hard* (transfer operator), and is recorded as a future
direction rather than claimed here.  The infinitude theorem is the weakest
honest general statement we can fully prove.

Critique (Critic): Is `cusick_t1_density` a disguised `decide`?  No — it is an
induction on `m` whose step is a residue-counting argument, valid for all `m`,
not a finite enumeration.  The `cusick_t1_iff` proof genuinely uses the 2-adic
valuation machinery (`padicValNat_dvd_iff_le`), not brute force.  We are careful
NOT to overclaim the asymptotic bound `c_t ≥ 1/2 + 2^{-(2 s₂(t)+1)}`, which
remains open in this development.
-/

import Catalog.Applications.CusickCarryReformulation

open Nat Finset

namespace CusickDensity

open CusickSumDigits CusickCarry

/-- **No-carry high bit.**  If `t < 2ᴸ`, adjoining the bit `2ᴸ` above `t`
increases the digit sum by exactly one: `s₂(t + 2ᴸ) = s₂(t) + 1`. -/
theorem s2_high_bit (t L : ℕ) (h : t < 2 ^ L) : s2 (t + 2 ^ L) = s2 t + 1 := by
  have hlen : (Nat.digits 2 t).length ≤ L :=
    (Nat.digits_length_le_iff (by norm_num) t).mpr h
  have key := digits_append_zeroes_append_digits (b := 2)
    (k := L - (Nat.digits 2 t).length) (m := 1) (n := t) (by norm_num) (by norm_num)
  have hL : (Nat.digits 2 t).length + (L - (Nat.digits 2 t).length) = L := by omega
  rw [hL] at key
  simp only [mul_one] at key
  have hsum : s2 (t + 2 ^ L)
      = (Nat.digits 2 t ++ List.replicate (L - (Nat.digits 2 t).length) 0
          ++ Nat.digits 2 1).sum := by
    rw [s2, ← key]
  rw [hsum]
  simp [s2, List.sum_append]

/-- **The Cusick good set is infinite.**  For every `t`, infinitely many `n`
satisfy `s₂(n) ≤ s₂(n + t)`, witnessed by the sparse family `n = 2^(j + t)`. -/
theorem cusick_good_set_infinite (t : ℕ) :
    {n : ℕ | s2 n ≤ s2 (n + t)}.Infinite := by
  apply Set.infinite_of_injective_forall_mem (f := fun j : ℕ => 2 ^ (j + t))
  · intro a b hab
    simp only at hab
    have := Nat.pow_right_injective (le_refl 2) hab
    omega
  · intro j
    simp only [Set.mem_setOf_eq]
    have htlt : t < 2 ^ (j + t) :=
      lt_of_lt_of_le Nat.lt_two_pow_self (Nat.pow_le_pow_right (by norm_num) (by omega))
    have h1 : s2 (2 ^ (j + t)) = 1 := by
      have := s2_high_bit 0 (j + t) (by positivity); simpa using this
    have h2 : s2 (2 ^ (j + t) + t) = s2 t + 1 := by
      rw [Nat.add_comm]; exact s2_high_bit t (j + t) htlt
    omega

/-- **The `t = 1` Cusick condition via 2-adic valuation.**  `s₂(n) ≤ s₂(n + 1)`
holds if and only if `n % 4 ≠ 3` (equivalently `4 ∤ (n + 1)`, i.e. `v₂(n+1) ≤ 1`). -/
theorem cusick_t1_iff (n : ℕ) : s2 n ≤ s2 (n + 1) ↔ n % 4 ≠ 3 := by
  rw [cusick_reformulation]
  have hc : carries 1 n = padicValNat 2 (n + 1) := by
    unfold carries; rw [Nat.choose_one_right]
  have hs1 : s2 1 = 1 := by simp [s2]
  rw [hc, hs1]
  have : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  constructor
  · intro h hcon
    have h4 : (4 : ℕ) ∣ (n + 1) := by omega
    have hpow : (2 : ℕ) ^ 2 ∣ (n + 1) := by norm_num at h4 ⊢; exact h4
    have := (padicValNat_dvd_iff_le (by omega)).mp hpow
    omega
  · intro h
    by_contra hc2
    push_neg at hc2
    have hpow : (2 : ℕ) ^ 2 ∣ (n + 1) := (padicValNat_dvd_iff_le (by omega)).mpr (by omega)
    have h4 : (4 : ℕ) ∣ (n + 1) := by norm_num at hpow ⊢; exact hpow
    omega

/-
Residue counting: exactly `3m` integers in `[0, 4m)` avoid residue `3 mod 4`.
-/
theorem count_mod4_ne_three (m : ℕ) :
    ((range (4 * m)).filter (fun n => n % 4 ≠ 3)).card = 3 * m := by
  induction m <;> simp_all +decide [ Nat.mul_succ, Finset.range_add_one ];
  simp_all +decide [ Finset.filter_insert, Nat.add_mod ]

/-- **Exact finite density for `t = 1`.**  Exactly `3m` of the integers in
`[0, 4m)` satisfy `s₂(n) ≤ s₂(n + 1)`.  Thus the density is `c₁ = 3/4`,
strictly above the conjectured explicit bound `1/2 + 2^{-(2·s₂(1)+1)} = 5/8`. -/
theorem cusick_t1_density (m : ℕ) :
    ((range (4 * m)).filter (fun n => s2 n ≤ s2 (n + 1))).card = 3 * m := by
  have hcongr : ((range (4 * m)).filter (fun n => s2 n ≤ s2 (n + 1)))
      = ((range (4 * m)).filter (fun n => n % 4 ≠ 3)) := by
    apply Finset.filter_congr
    intro n _
    simp only [cusick_t1_iff n]
  rw [hcongr, count_mod4_ne_three]

end CusickDensity