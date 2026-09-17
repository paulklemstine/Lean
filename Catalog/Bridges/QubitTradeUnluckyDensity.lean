/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# QUBIT-TRADE3, cycle 4: at most half of all bases are permanently unlucky

`Bridges.QubitTradeSharpCriterion` proves that a base `a` modulo an odd semiprime `N = p * q` is
useless for period-certificate factoring exactly when the 2-adic valuations of its two per-prime
orders coincide. The unit group modulo `N` is the product of two cyclic groups, so the density of
useless bases is a purely group-theoretic quantity. This file bounds it:

> in a product of two cyclic groups of even order, at most half of all pairs `(x, y)` satisfy
> `v₂(ord x) = v₂(ord y)`.

Combined with the sharp criterion this is the formal content of "base re-drawing removes the cap
classically": at least half of the bases split `N` from a period certificate, so the expected
number of re-draws is at most two, whereas no sample budget at a fixed unlucky base helps at all.

## Main results

* `QubitTrade.card_orderOf_dvd_half` — in a cyclic group of even order `n`, exactly `n / 2`
  elements have order dividing `n / 2`.
* `QubitTrade.card_two_adic_level_le_half` — every level set of `v₂ ∘ orderOf` has at most `n / 2`
  elements.
* `QubitTrade.card_unlucky_pairs_le_half` and `QubitTrade.two_mul_card_unlucky_pairs_le` — at most
  half of the pairs are unlucky.
-/

import Mathlib
import Bridges.QubitTradeSharpCriterion

namespace QubitTrade

open Finset

/-! ### 2-adic arithmetic -/

/-- Halving a positive even number drops its 2-adic valuation by one. -/
theorem factorization_two_half {n : ℕ} (hn : n ≠ 0) (h2 : 2 ∣ n) :
    (n / 2).factorization 2 = n.factorization 2 - 1 := by
  obtain ⟨c, rfl⟩ := h2
  have hc : c ≠ 0 := by rintro rfl; simp at hn
  rw [Nat.mul_div_cancel_left _ (by norm_num : 0 < 2), Nat.factorization_mul (by norm_num) hc,
    Nat.Prime.factorization Nat.prime_two]
  simp

/-- Halving an even number leaves the odd part of its factorization unchanged. -/
theorem factorization_half_of_ne_two {n p : ℕ} (hn : n ≠ 0) (h2 : 2 ∣ n) (hp : p ≠ 2) :
    (n / 2).factorization p = n.factorization p := by
  obtain ⟨c, rfl⟩ := h2
  have hc : c ≠ 0 := by rintro rfl; simp at hn
  rw [Nat.mul_div_cancel_left _ (by norm_num : 0 < 2), Nat.factorization_mul (by norm_num) hc,
    Nat.Prime.factorization Nat.prime_two]
  simp [Ne.symm hp]

/-- A divisor whose 2-adic valuation is strictly smaller already divides the halved number. -/
theorem dvd_half_of_factorization_two_lt {d n : ℕ} (hd : d ≠ 0) (hn : n ≠ 0) (h2 : 2 ∣ n)
    (hdn : d ∣ n) (hlt : d.factorization 2 < n.factorization 2) : d ∣ n / 2 := by
  have hn2 : n / 2 ≠ 0 := by
    obtain ⟨c, rfl⟩ := h2
    simp only [Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    rintro rfl
    simp at hn
  refine (Nat.factorization_le_iff_dvd hd hn2).mp fun p => ?_
  by_cases hp : p = 2
  · subst hp
    rw [factorization_two_half hn h2]
    omega
  · rw [factorization_half_of_ne_two hn h2 hp]
    exact (Nat.factorization_le_iff_dvd hd hn).mpr hdn p

/-! ### Level sets of the 2-adic valuation of the order -/

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] [IsCyclic G]

/-- In a cyclic group of even order `n`, exactly `n / 2` elements have order dividing `n / 2`:
the unique index-two subgroup. -/
theorem card_orderOf_dvd_half (h2 : 2 ∣ Fintype.card G) :
    (Finset.univ.filter (fun x : G => orderOf x ∣ Fintype.card G / 2)).card
      = Fintype.card G / 2 := by
  classical
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := G)
  rw [Nat.card_eq_fintype_card] at hg
  have hord : orderOf (g ^ 2) = Fintype.card G / 2 := by
    rw [orderOf_pow, hg, Nat.gcd_eq_right h2]
  have hpos : 0 < Fintype.card G / 2 := by
    have := Fintype.card_pos (α := G); omega
  refine le_antisymm ?_ ?_
  · have hset : (Finset.univ.filter (fun x : G => orderOf x ∣ Fintype.card G / 2))
        = Finset.univ.filter (fun x : G => x ^ (Fintype.card G / 2) = 1) :=
      Finset.filter_congr (fun x _ => by simp [orderOf_dvd_iff_pow_eq_one])
    rw [hset]
    exact IsCyclic.card_pow_eq_one_le hpos
  · have hcard : (Finset.range (Fintype.card G / 2)).card
        ≤ (Finset.univ.filter (fun x : G => orderOf x ∣ Fintype.card G / 2)).card := by
      refine Finset.card_le_card_of_injOn (fun k : ℕ => (g ^ 2) ^ k) ?_ ?_
      · intro k _
        have hdvd : orderOf ((g ^ 2) ^ k) ∣ Fintype.card G / 2 :=
          orderOf_dvd_of_pow_eq_one (by
            rw [← pow_mul, mul_comm, pow_mul, ← hord, pow_orderOf_eq_one, one_pow])
        simpa using hdvd
      · have hinj := pow_injOn_Iio_orderOf (x := g ^ 2)
        rw [hord] at hinj
        simpa [Finset.coe_range] using hinj
    simpa using hcard

/-- Every level set of `v₂ ∘ orderOf` in a cyclic group of even order has at most half the
elements of the group. The maximal level is exactly half, and all the other levels together make
up the other half. -/
theorem card_two_adic_level_le_half (h2 : 2 ∣ Fintype.card G) (k : ℕ) :
    (Finset.univ.filter (fun x : G => (orderOf x).factorization 2 = k)).card
      ≤ Fintype.card G / 2 := by
  classical
  set n : ℕ := Fintype.card G with hn
  have hn0 : n ≠ 0 := (Fintype.card_pos (α := G)).ne'
  have hn2 : n / 2 ≠ 0 := by
    obtain ⟨c, hc⟩ := h2
    rw [hc, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    rintro rfl
    simp [hc] at hn0
  have hordne : ∀ x : G, orderOf x ≠ 0 := fun x => (orderOf_pos x).ne'
  have hdvd : ∀ x : G, orderOf x ∣ n := fun x => orderOf_dvd_card
  -- an element has order dividing `n / 2` exactly when its valuation is below the maximum
  have hkey : ∀ x : G, orderOf x ∣ n / 2 ↔ (orderOf x).factorization 2 < n.factorization 2 := by
    intro x
    constructor
    · intro h
      have hle : (orderOf x).factorization 2 ≤ (n / 2).factorization 2 :=
        (Nat.factorization_le_iff_dvd (hordne x) hn2).mpr h 2
      rw [factorization_two_half hn0 h2] at hle
      have hpos : 0 < n.factorization 2 :=
        Nat.Prime.factorization_pos_of_dvd Nat.prime_two hn0 h2
      omega
    · intro h
      exact dvd_half_of_factorization_two_lt (hordne x) hn0 h2 (hdvd x) h
  by_cases hk : k = n.factorization 2
  · -- the maximal level is the complement of the index-two subgroup
    subst hk
    have hcompl : (Finset.univ.filter
        (fun x : G => (orderOf x).factorization 2 = n.factorization 2))
        = Finset.univ.filter (fun x : G => ¬ (orderOf x ∣ n / 2)) := by
      refine Finset.filter_congr fun x _ => ?_
      have hle : (orderOf x).factorization 2 ≤ n.factorization 2 :=
        (Nat.factorization_le_iff_dvd (hordne x) hn0).mpr (hdvd x) 2
      simp only [hkey x]
      constructor
      · intro h hlt; omega
      · intro h; omega
    have hsplit := Finset.card_filter_add_card_filter_not
      (s := (Finset.univ : Finset G)) (p := fun x : G => orderOf x ∣ n / 2)
    rw [card_orderOf_dvd_half h2] at hsplit
    rw [hcompl]
    have hcardG : (Finset.univ : Finset G).card = n := by simp [hn]
    omega
  · -- every other level sits inside the index-two subgroup
    have hsub : (Finset.univ.filter (fun x : G => (orderOf x).factorization 2 = k))
        ⊆ Finset.univ.filter (fun x : G => orderOf x ∣ n / 2) := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
      have hle : (orderOf x).factorization 2 ≤ n.factorization 2 :=
        (Nat.factorization_le_iff_dvd (hordne x) hn0).mpr (hdvd x) 2
      exact (hkey x).mpr (by omega)
    calc (Finset.univ.filter (fun x : G => (orderOf x).factorization 2 = k)).card
        ≤ (Finset.univ.filter (fun x : G => orderOf x ∣ n / 2)).card :=
          Finset.card_le_card hsub
      _ = n / 2 := card_orderOf_dvd_half h2

/-! ### The density of permanently unlucky bases -/

omit [DecidableEq G] [IsCyclic G] in
/-- **At most half of the bases are permanently unlucky.** In a product of two cyclic groups of
even order — the shape of the unit group modulo an odd semiprime — at most half of all pairs have
per-coordinate orders with equal 2-adic valuation. By the sharp criterion
(`QubitTrade.splits_iff_two_adic_ne`) these are exactly the bases from which no period certificate
can ever extract a factor, so re-drawing the base succeeds with probability at least one half. -/
theorem card_unlucky_pairs_le_half {H : Type*} [Group H] [Fintype H] [DecidableEq H] [IsCyclic H]
    (hH : 2 ∣ Fintype.card H) :
    ((Finset.univ : Finset (G × H)).filter
        (fun p => (orderOf p.1).factorization 2 = (orderOf p.2).factorization 2)).card
      ≤ Fintype.card G * (Fintype.card H / 2) := by
  classical
  have hpair : ((Finset.univ : Finset (G × H)).filter
      (fun p => (orderOf p.1).factorization 2 = (orderOf p.2).factorization 2)).card
      = ∑ x : G, ((Finset.univ : Finset H).filter
          (fun y => (orderOf x).factorization 2 = (orderOf y).factorization 2)).card := by
    rw [Finset.card_filter, ← Finset.univ_product_univ, Finset.sum_product]
    exact Finset.sum_congr rfl fun x _ => (Finset.card_filter _ _).symm
  rw [hpair]
  have hbound : ∀ x : G, ((Finset.univ : Finset H).filter
      (fun y => (orderOf x).factorization 2 = (orderOf y).factorization 2)).card
      ≤ Fintype.card H / 2 := by
    intro x
    have hswap : ((Finset.univ : Finset H).filter
        (fun y => (orderOf x).factorization 2 = (orderOf y).factorization 2))
        = (Finset.univ : Finset H).filter
          (fun y => (orderOf y).factorization 2 = (orderOf x).factorization 2) :=
      Finset.filter_congr fun y _ => by simp [eq_comm]
    rw [hswap]
    exact card_two_adic_level_le_half hH _
  calc ∑ x : G, ((Finset.univ : Finset H).filter
          (fun y => (orderOf x).factorization 2 = (orderOf y).factorization 2)).card
      ≤ ∑ _x : G, Fintype.card H / 2 := Finset.sum_le_sum fun x _ => hbound x
    _ = Fintype.card G * (Fintype.card H / 2) := by
        simp [Finset.sum_const, Finset.card_univ]

omit [DecidableEq G] [IsCyclic G] in
/-- Division-free form: twice the number of permanently unlucky bases is at most the total. -/
theorem two_mul_card_unlucky_pairs_le {H : Type*} [Group H] [Fintype H] [DecidableEq H]
    [IsCyclic H] (hH : 2 ∣ Fintype.card H) :
    2 * ((Finset.univ : Finset (G × H)).filter
        (fun p => (orderOf p.1).factorization 2 = (orderOf p.2).factorization 2)).card
      ≤ Fintype.card G * Fintype.card H := by
  have h := card_unlucky_pairs_le_half (G := G) (H := H) hH
  obtain ⟨c, hc⟩ := hH
  rw [hc, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)] at h
  rw [hc]
  calc 2 * ((Finset.univ : Finset (G × H)).filter
        (fun p => (orderOf p.1).factorization 2 = (orderOf p.2).factorization 2)).card
      ≤ 2 * (Fintype.card G * c) := by omega
    _ = Fintype.card G * (2 * c) := by ring

end QubitTrade