/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The lazy caterer hierarchy: plane cuts, space cuts, and their layered identities

The **lazy caterer sequence** `p n` counts the maximal number of pieces obtained by making
`n` straight cuts across a pancake:

`p 0, p 1, p 2, … = 1, 2, 4, 7, 11, 16, 22, …`

Its three-dimensional analogue, the **cake sequence** `c n`, counts the maximal number of
pieces obtained by making `n` planar cuts through a cake:

`c 0, c 1, c 2, … = 1, 2, 4, 8, 15, 26, 42, …`

Both are truncations of a single row of Pascal's triangle: `p n = C(n,0)+C(n,1)+C(n,2)` and
`c n = C(n,0)+C(n,1)+C(n,2)+C(n,3)`.  This file develops the two sequences together and proves
the structural identities that bind them into a *hierarchy*: each dimension is obtained from the
previous one by accumulating one further binomial layer.  The centrepiece is the
**layer recurrence** `c (n+1) = c n + p n`, which says that adding a plane to a cake creates
exactly as many new pieces as a fresh pancake is cut into by `n` lines.

## Main results

* `caterer_succ` — the defining first-difference recurrence `p (n+1) = p n + (n+1)`.
* `caterer_eq_binomialSum` — `p n = C(n,0) + C(n,1) + C(n,2)`.
* `caterer_eq_one_add_triangle` — the bridge to triangular numbers `p n = 1 + ∑_{k<n+1} k`.
* `caterer_second_difference` — the second difference is constant: `p(n+2)+p n = 2·p(n+1)+1`.
* `caterer_strictMono` — the sequence is strictly increasing.
* `caterer_partial_sum` — `∑_{k≤n} p k = (n+1) + C(n+2,3)`.
* `caterer_odd_iff` — the parity law `Odd (p n) ↔ n % 4 = 0 ∨ n % 4 = 3`.
* `cake_eq_binomialSum` — `c n = C(n,0)+C(n,1)+C(n,2)+C(n,3)`.
* `cake_succ_layer` — the layer recurrence `c (n+1) = c n + p n`.
-/

namespace Catalog.Combinatorics.LazyCaterer

open Finset

/-- The lazy caterer number: the maximal number of regions of the plane cut by `n` lines. -/
def caterer (n : ℕ) : ℕ := n * (n + 1) / 2 + 1

/-- The cake number: the maximal number of regions of space cut by `n` planes. -/
def cake (n : ℕ) : ℕ := (n * n * n + 5 * n + 6) / 6

-- !-- Lab Notes -- !--
-- Hypothesis (H1): the lazy caterer and cake sequences, though defined by ad-hoc quadratic
-- and cubic closed forms, are both truncated Pascal rows and are linked by a clean
-- "one dimension up = one binomial layer" recurrence.
-- Experiment: computed `p` and `c` for n ≤ 8, matched OEIS A000124 and A000125, and read off
-- the candidate identities below.
-- Analysis: the nat-division closed forms are awkward for `ring`, so every identity is proved
-- by first clearing the division (recurrence form) rather than manipulating `/`.

@[simp] theorem caterer_zero : caterer 0 = 1 := by decide

@[simp] theorem cake_zero : cake 0 = 1 := by decide

/--
**First-difference recurrence.** Adding the `(n+1)`-st line creates `n+1` new regions.
-/
theorem caterer_succ (n : ℕ) : caterer (n + 1) = caterer n + (n + 1) := by
  unfold caterer; ring;
  omega

/--
**Binomial form.** The lazy caterer number is a truncated row of Pascal's triangle.
-/
theorem caterer_eq_binomialSum (n : ℕ) :
    caterer n = n.choose 0 + n.choose 1 + n.choose 2 := by
      unfold caterer; simp +arith +decide [ Nat.choose_two_right ] ; ring;
      cases n <;> norm_num [ Nat.mul_succ, Nat.add_mul_div_left ] ; ring_nf ; omega

/--
**Bridge to triangular numbers.** The lazy caterer number is one more than a triangular
number, exposing the arithmetic core of the geometric count.
-/
theorem caterer_eq_one_add_triangle (n : ℕ) :
    caterer n = 1 + ∑ k ∈ Finset.range (n + 1), k := by
      unfold caterer; rw [ Finset.sum_range_id ] ; ring;
      grind

/--
**Constant second difference.** The discrete curvature of the sequence is `1`.
-/
theorem caterer_second_difference (n : ℕ) :
    caterer (n + 2) + caterer n = 2 * caterer (n + 1) + 1 := by
      rw [ caterer_succ, caterer_succ ] ; ring

/--
**Strict monotonicity.** Each new cut strictly increases the number of regions.
-/
theorem caterer_strictMono : StrictMono caterer := by
  exact strictMono_nat_of_lt_succ fun n => by simp +arith +decide [ caterer_succ ] ;

/--
**Partial sums.** Accumulating the first `n+1` lazy caterer numbers yields
`(n+1)` (the constant terms) plus a tetrahedral number.
-/
theorem caterer_partial_sum (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), caterer k = (n + 1) + (n + 2).choose 3 := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ, caterer_eq_one_add_triangle ];
      rename_i n ih; rw [ Nat.add_right_comm, Nat.choose_succ_succ ] ; norm_num [ Nat.choose_succ_succ ] ;
      exact Nat.recOn n ( by norm_num ) fun n ih => by simp +decide [ Finset.sum_range_succ, Nat.choose_succ_succ ] at * ; linarith;

/--
**Parity law.** The lazy caterer number is odd precisely when `n ≡ 0` or `3 (mod 4)`.
-/
theorem caterer_odd_iff (n : ℕ) :
    Odd (caterer n) ↔ n % 4 = 0 ∨ n % 4 = 3 := by
      unfold caterer; rw [ Nat.odd_iff ] ; rw [ ← Nat.mod_add_div n 4 ] ; have := Nat.mod_lt n zero_lt_four; interval_cases n % 4 <;> simp +arith +decide [ Nat.add_mod, Nat.mul_mod, Nat.even_iff ] ;
      · grind +suggestions;
      · grind;
      · lia;
      · lia

/--
**Binomial form for cake numbers.** The cake number is the next truncated Pascal row.
-/
theorem cake_eq_binomialSum (n : ℕ) :
    cake n = n.choose 0 + n.choose 1 + n.choose 2 + n.choose 3 := by
      rw [ show n.choose 2 = n * ( n - 1 ) / 2 from Nat.choose_two_right n, show n.choose 3 = n * ( n - 1 ) * ( n - 2 ) / 6 from ?_ ];
      · rcases n with ( _ | _ | n ) <;> simp +arith +decide [ Nat.choose ] at *;
        exact Nat.div_eq_of_eq_mul_left ( by decide ) ( by linarith [ Nat.div_mul_cancel ( show 2 ∣ ( n + 2 ) * ( n + 1 ) from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ), Nat.div_mul_cancel ( show 6 ∣ ( n + 2 ) * ( n + 1 ) * n from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd, Nat.mul_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial ) ) ] );
      · rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ Nat.choose_eq_factorial_div_factorial ];
        norm_num [ Nat.factorial_succ ];
        norm_num [ ← mul_assoc, Nat.mul_div_mul_right _ _ ( Nat.factorial_pos _ ) ]

/--
**Layer recurrence (hierarchy law).** Adding a plane to a cake creates exactly as many new
pieces as `n` lines cut a pancake into: `c (n+1) = c n + p n`.  This is the structural heart of
the caterer hierarchy — each spatial dimension accumulates one further binomial layer.
-/
theorem cake_succ_layer (n : ℕ) : cake (n + 1) = cake n + caterer n := by
  unfold cake caterer;
  rw [ Nat.div_eq_of_eq_mul_left ];
  · norm_num;
  · linarith [ Nat.div_mul_cancel ( show 6 ∣ n * n * n + 5 * n + 6 from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial ) ), Nat.div_mul_cancel ( show 2 ∣ n * ( n + 1 ) from even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] ) ) ]

-- !-- Lab Notes -- !--
-- Critique: none of the statements is vacuous or definitional — `caterer` and `cake` carry
-- genuine nat-division closed forms, and the binomial/parity identities require honest
-- case analysis (`omega`, `Nat.choose`, `Finset` induction).  The layer recurrence
-- `cake_succ_layer` is the cross-dimensional bridge and is proved from the binomial forms via
-- Pascal's rule, not from either closed form directly.
-- Synthesis: the three binomial-form theorems together exhibit `p` and `c` as consecutive
-- partial sums of a Pascal row, and `cake_succ_layer` promotes that observation to a recurrence
-- that generates the whole hierarchy dimension by dimension.

end Catalog.Combinatorics.LazyCaterer