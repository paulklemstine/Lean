/-
Copyright (c) 2025. All rights reserved.

# Pure Periodicity of the Cusick Predicate and Rationality of `c_t`

## Overview

Cusick's density `c_t = dens { n : s₂(n) ≤ s₂(n + t) }` is conjectured (now known)
to satisfy `c_t ≥ 1/2 + 2^{-(2 s₂(t)+1)}`.  A structural prerequisite, visible in
all the worked cases (`c_1 = 3/4`, `c_3 = 11/16`, …), is that `c_t` is always a
**dyadic rational**.  This file proves the mechanism behind that fact in full
generality:

* `CusickPeriodicity.cusick_periodic` — for every `t ≥ 1` and every `L` with
  `t < 2^L`, the Cusick predicate `P_t(n) := s₂(n) ≤ s₂(n + t)` is **purely
  periodic** in `n` with period `2^{L + s₂(t)}`:
  `P_t(n) ↔ P_t(n mod 2^{L+s₂(t)})`.
* `CusickPeriodicity.cusickCount_period` — consequently the finite count scales
  exactly: `cusickCount t (2^{L+s₂(t)}·m) = m · cusickCount t (2^{L+s₂(t)})`, so
  `c_t = cusickCount t (2^{L+s₂(t)}) / 2^{L+s₂(t)}` is a dyadic rational.

The proof rests on two facts about the binary digit sum:

* the **digit-concatenation** lemma `s2_concat` (from `CusickShiftThreeDensity`):
  `s₂(2^M·b + a) = s₂(b) + s₂(a)` for `a < 2^M`; and
* **strict subadditivity on overflow** `s2_carry_strict`: if `a, t < 2^L` and the
  low block overflows (`2^L ≤ a + t`), then `s₂(a+t) < s₂(a) + s₂(t)` — there is at
  least one carry.

The heart is the *overflow* analysis `overflow_false`: when the low `M`-bit window
`a = n mod 2^M` (with `M = L + s₂(t)`) satisfies `a + t ≥ 2^M`, the window is forced
to have its top `s₂(t)` bits all equal to `1`, and adding `t` annihilates them, so
`s₂(n+t) < s₂(n)` for **every** high part `b`.  Hence the predicate cannot depend on
the high bits, giving periodicity.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Each individual case (`t = 1, 2, 3, 7, 15, 31, …`)
showed the Cusick predicate is purely periodic with minimal period
`2^{(length t) + s₂(t)}`.  Conjecture: this is a theorem for all `t`, and the
period explanation is "carries cannot propagate past `s₂(t)` high `1`-bits without
making the inequality fail".

Experiment (Experimenter): Empirically the predicate is periodic for all `t ≤ 31`
with period exactly `2^{L+s₂(t)}` (`L = (digits 2 t).length`).  Decomposing
`n = 2^M b + a`, `a = n mod 2^M`: in the non-overflow regime (`a+t < 2^M`) the
predicate is `s₂(a) ≤ s₂(a+t)`, manifestly independent of `b`; in the overflow
regime (`a+t ≥ 2^M`) it is *uniformly false*, the new content of the theorem.

Analysis (Analyst): The overflow regime is exactly where naive subadditivity is
insufficient and *strict* subadditivity (`s2_carry_strict`, ≥ one carry) is
needed.  The arithmetic core is: `a ≥ 2^M - t > 2^L(2^s-1)` forces `a / 2^L = 2^s-1`
(all-ones high block), and the carry out of the low `L`-bits then propagates
through all `s = s₂(t)` of them.  Combined with `s₂(b+1) ≤ s₂(b)+1` (subadditivity)
this beats any gain from incrementing the high part.

Critique (Critic): Is the theorem vacuous or a finite check?  No — `cusick_periodic`
is universally quantified over all `n` (and `L`), and `cusickCount_period` is an
induction on `m`.  The result genuinely generalizes the catalog: previous files
prove periodicity only for specific `t` (`t = 1`, powers of two, `t = 3`); here it
is established for *every* `t`, which is the rationality backbone of `c_t`.
-/

import Catalog.Applications.CusickShiftThreeDensity

open Nat Finset

namespace CusickPeriodicity

open CusickSumDigits CusickDensity CusickDoubling CusickShiftThree

/-
The binary digit sum of `2^s - 1` (the `s`-bit all-ones number) is `s`.
-/
theorem s2_pred_pow (s : ℕ) : s2 (2 ^ s - 1) = s := by
  induction s <;> simp_all +decide [ Nat.pow_succ' ];
  rw [ show 2 * 2 ^ _ - 1 = 2 * ( 2 ^ _ - 1 ) + 1 by zify ; norm_num ; ring, CusickDoubling.s2_two_mul_add_one, ‹s2 _ = _› ]

/-
**Strict subadditivity on overflow.**  If `a, t < 2^L` and the `L`-bit block
overflows when adding (`2^L ≤ a + t`), then there is at least one carry, so the
digit sum strictly drops below the additive bound: `s₂(a + t) < s₂(a) + s₂(t)`.
-/
theorem s2_carry_strict (L a t : ℕ) (ha : a < 2 ^ L) (htl : t < 2 ^ L)
    (hov : 2 ^ L ≤ a + t) : s2 (a + t) < s2 a + s2 t := by
  -- We'll use the fact that if the sum of two numbers is at least $2^L$, then the number of carries is at least one.
  have h_carry : CusickCarry.carries t a > 0 := by
    unfold CusickCarry.carries; (
    rw [ padicValNat_choose ];
    any_goals exact Nat.lt_succ_self _;
    · refine' Finset.card_pos.mpr ⟨ L, _ ⟩ ; simp +arith +decide [ *, Nat.mod_eq_of_lt ];
      exact ⟨ Nat.pos_of_ne_zero ( by rintro rfl; linarith ), Nat.le_log_of_pow_le ( by norm_num ) hov ⟩;
    · grind +splitImp);
  linarith [ CusickCarry.s2_add_carries a t ]

/-
**Overflow forces the predicate false.**  Let `M = L + s₂(t)` with `t < 2^L`,
`1 ≤ t`.  If the low `M`-bit window `a < 2^M` overflows (`2^M ≤ a + t`), then for
*every* high part `b`, `s₂(2^M·b + a + t) < s₂(2^M·b + a)`, i.e. the Cusick
inequality fails regardless of the high bits.
-/
theorem overflow_false (t L b a : ℕ) (_ht : 1 ≤ t) (hL : t < 2 ^ L)
    (ha : a < 2 ^ (L + s2 t)) (hov : 2 ^ (L + s2 t) ≤ a + t) :
    s2 (2 ^ (L + s2 t) * b + a + t) < s2 (2 ^ (L + s2 t) * b + a) := by
  -- From 2^M ≤ a+t = 2^L*(2^s-1) + a0 + t and 2^M = 2^L*2^s = 2^L*(2^s-1) + 2^L, deduce 2^L ≤ a0 + t. Also a0+t < 2^(L+1) since a0,t < 2^L; set r := a0+t-2^L, r < 2^L, and a0+t = 2^L + r.
  obtain ⟨a0, q, ha0, hq⟩ : ∃ a0 q, a = 2 ^ L * q + a0 ∧ q < 2 ^ s2 t ∧ a0 < 2 ^ L := by
    exact ⟨ a % 2 ^ L, a / 2 ^ L, by rw [ Nat.div_add_mod ], Nat.div_lt_of_lt_mul <| by rw [ ← pow_add ] at *; linarith, Nat.mod_lt _ <| by positivity ⟩;
  -- By definition of $a0$ and $q$, we have $q = 2^{s2(t)} - 1$ and $2^L \leq a0 + t$.
  have hq_eq : q = 2^s2 t - 1 := by
    exact eq_tsub_of_add_eq ( by ring_nf at *; nlinarith )
  have hle : 2^L ≤ a0 + t := by
    simp_all +decide [ pow_add ];
    nlinarith only [ hov, Nat.sub_add_cancel ( Nat.one_le_pow ( s2 t ) 2 zero_lt_two ) ];
  -- Let $r = a0 + t - 2^L$, so $a0 + t = 2^L + r$ and $r < 2^L$.
  obtain ⟨r, hr⟩ : ∃ r, a0 + t = 2^L + r ∧ r < 2^L := by
    exact ⟨ a0 + t - 2 ^ L, by rw [ Nat.add_sub_cancel' hle ], by rw [ tsub_lt_iff_left hle ] ; linarith ⟩;
  -- By definition of $s2$, we have $s2 (2^M * b + a) = s2 b + s + s2 a0$ and $s2 (2^M * b + a + t) = s2 (b + 1) + s2 r$.
  have h_s2_a : s2 (2^(L + s2 t) * b + a) = s2 b + s2 t + s2 a0 := by
    convert s2_concat ( L + s2 t ) b a _ using 1;
    · rw [ ha0, hq_eq ];
      rw [ show 2 ^ L * ( 2 ^ s2 t - 1 ) + a0 = 2 ^ L * ( 2 ^ s2 t - 1 ) + a0 from rfl, s2_concat ] <;> norm_num [ hq.2 ];
      rw [ s2_pred_pow ] ; ring;
    · linarith
  have h_s2_at : s2 (2^(L + s2 t) * b + a + t) = s2 (b + 1) + s2 r := by
    convert s2_concat ( L + s2 t ) ( b + 1 ) r _ using 1;
    · rw [ ha0, hq_eq ] ; ring;
      exact congr_arg _ ( by nlinarith only [ Nat.sub_add_cancel ( Nat.one_le_pow ( s2 t ) 2 zero_lt_two ), hr.1 ] );
    · exact hr.2.trans_le ( Nat.pow_le_pow_right ( by decide ) ( Nat.le_add_right _ _ ) );
  -- By definition of $s2$, we have $s2 (a0 + t) = s2 (2^L + r) = s2 1 + s2 r = 1 + s2 r$.
  have h_s2_at_eq : s2 (a0 + t) = 1 + s2 r := by
    convert s2_concat L 1 r ( by linarith ) using 1 ; ring;
    rw [ hr.1, add_comm ];
  -- By definition of $s2$, we have $s2 (a0 + t) < s2 a0 + s2 t$.
  have h_s2_at_lt : s2 (a0 + t) < s2 a0 + s2 t := by
    apply s2_carry_strict L a0 t hq.right hL hle;
  linarith [ show s2 ( b + 1 ) ≤ s2 b + 1 from by simpa using CusickSumDigits.s2_subadditive b 1 ]

/-
**Pure periodicity of the Cusick predicate.**  For `t ≥ 1` and any `L` with
`t < 2^L`, the predicate `s₂(n) ≤ s₂(n + t)` depends only on `n mod 2^{L+s₂(t)}`.
-/
theorem cusick_periodic (t L n : ℕ) (ht : 1 ≤ t) (hL : t < 2 ^ L) :
    (s2 n ≤ s2 (n + t)) ↔
      (s2 (n % 2 ^ (L + s2 t)) ≤ s2 (n % 2 ^ (L + s2 t) + t)) := by
  -- Set M := L + s2 t. Let b := n / 2^M and a := n % 2^M, so a < 2^M (Nat.mod_lt) and n = 2^M * b + a (Nat.div_add_mod).
  set M := L + s2 t with hM
  set b := n / 2^M with hb
  set a := n % 2^M with ha;
  by_cases hov : 2 ^ M ≤ a + t;
  · have := overflow_false t L b a ht hL ( Nat.mod_lt _ ( by positivity ) ) hov;
    have := overflow_false t L 0 a ht hL ( Nat.mod_lt _ ( by positivity ) ) hov; simp_all +decide [ Nat.div_add_mod ] ;
    bv_omega;
  · rw [ show n = 2 ^ M * b + a by rw [ Nat.div_add_mod ] ];
    rw [ show 2 ^ M * b + a + t = 2 ^ M * b + ( a + t ) by ring, s2_concat, s2_concat ];
    · grind;
    · grind;
    · exact Nat.mod_lt _ ( by positivity )

/-
**Block self-similarity of the count.**  Because `P_t` is periodic with period
`2^{L+s₂(t)}`, the count over `m` aligned blocks is `m` times the count over one
block: `cusickCount t (2^{L+s₂(t)}·m) = m · cusickCount t (2^{L+s₂(t)})`.  Hence
`c_t = cusickCount t (2^{L+s₂(t)}) / 2^{L+s₂(t)}` is a dyadic rational.
-/
theorem cusickCount_period (t L m : ℕ) (ht : 1 ≤ t) (hL : t < 2 ^ L) :
    cusickCount t (2 ^ (L + s2 t) * m) = m * cusickCount t (2 ^ (L + s2 t)) := by
  unfold cusickCount;
  induction' m with m ih;
  · norm_num;
  · rw [ Nat.mul_succ, Finset.card_filter, Finset.card_filter, Finset.sum_range_add ];
    simp_all +decide [ add_mul ];
    refine' congr_arg _ ( Finset.filter_congr fun x hx => _ );
    convert cusick_periodic t L ( 2 ^ ( L + s2 t ) * m + x ) ht hL using 1 ; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.mod_eq_of_lt ( Finset.mem_range.mp hx ) ]

end CusickPeriodicity