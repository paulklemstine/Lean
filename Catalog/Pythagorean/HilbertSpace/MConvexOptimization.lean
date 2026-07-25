/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Certified Discrete Optimization on M-Convex Sets

This file develops a theory of certified optimization on M-convex sets, establishing that
M-convexity is a discrete convexity principle strong enough to support certified local-to-global
optimization with explicit descent complexity certificates.

## Main Definitions

* `exchangeVec` — Elementary exchange operator: subtract from coordinate i, add to coordinate j
* `IsMConvexSet` — M-convex set predicate for `Finset (ι → ℤ)` with the symmetric exchange axiom
* `IsExchangeLocalMin` — Local optimality under exchange moves
* `CertifiedArgmin` — A point with proof of feasibility and global optimality
* `posDiff` — Positive difference potential: ∑ max(x_k - y_k, 0)

## Main Results

1. `exchange_linear_drop_eq_coeff_gap` — Objective change under exchange = coefficient gap
2. `exchange_improves_of_cost_gap` — Exchange improves objective when cost gap is favorable
3. `exchange_local_min_implies_global_min` — **Local exchange optimality ⟹ global optimality**
4. `finite_mconvex_has_optimum` — Existence of a global minimum on finite M-convex sets
5. `no_infinite_strict_descent` — No infinite descent on finite sets
6. `certified_argmin_of_mconvex` — Construction of a certified optimizer

## Cross-Domain Bridge

* `exchange_linear_drop_eq_coeff_gap` connects M-convex exchange descent to discrete energy
  dissipation: each exchange changes the linear energy by exactly the coefficient gap c_j - c_i,
  identifying exchange descent as a discrete gradient flow and connecting to majorization theory,
  resource allocation, and statistical mechanics.

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators Function

noncomputable section

namespace MConvexOptimization

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-! ## Section 1: Exchange Operator -/

/-- The elementary exchange operator on integer vectors.
    `exchangeVec x i j` decrements coordinate `i` and increments coordinate `j`. -/
def exchangeVec (x : ι → ℤ) (i j : ι) : ι → ℤ :=
  fun k => x k + (if k = j then 1 else 0) - (if k = i then 1 else 0)

@[simp]
theorem exchangeVec_apply_same (x : ι → ℤ) (i : ι) :
    exchangeVec x i i = x := by
  ext k; simp [exchangeVec]

theorem exchangeVec_apply_left {x : ι → ℤ} {i j : ι} (hij : i ≠ j) :
    exchangeVec x i j i = x i - 1 := by
  simp [exchangeVec, hij, Ne.symm hij]

theorem exchangeVec_apply_right {x : ι → ℤ} {i j : ι} (hij : i ≠ j) :
    exchangeVec x i j j = x j + 1 := by
  simp [exchangeVec, hij, Ne.symm hij]

theorem exchangeVec_apply_other {x : ι → ℤ} {i j k : ι} (hki : k ≠ i) (hkj : k ≠ j) :
    exchangeVec x i j k = x k := by
  simp [exchangeVec, hki, hkj]

/-
Exchange preserves coordinate sums.
-/
theorem sum_exchangeVec (x : ι → ℤ) {i j : ι} (hij : i ≠ j) :
    ∑ k, exchangeVec x i j k = ∑ k, x k := by
  simp +decide only [exchangeVec];
  simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hij ]

/-! ## Section 2: Objective Algebra — The Energy Dissipation Formula -/

/-
**The objective-change formula (discrete energy dissipation law).**
    An exchange from coordinate `i` to coordinate `j` changes the linear objective
    by exactly `c j - c i`.
-/
theorem exchange_linear_drop_eq_coeff_gap
    (c x : ι → ℤ) {i j : ι} (hij : i ≠ j) :
    (∑ k, c k * exchangeVec x i j k) = (∑ k, c k * x k) - c i + c j := by
  unfold exchangeVec;
  simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib, hij.symm ] ; ring

/-- An exchange strictly improves the objective when moving from an expensive
    coordinate to a cheaper one. -/
theorem exchange_improves_of_cost_gap
    (c x : ι → ℤ) {i j : ι} (hij : i ≠ j) (hgap : c j < c i) :
    (∑ k, c k * exchangeVec x i j k) < (∑ k, c k * x k) := by
  have h := exchange_linear_drop_eq_coeff_gap c x hij
  linarith

/-- An exchange does not improve the objective when the target coordinate
    is at least as expensive as the source. -/
theorem exchange_nonimproving_of_cost_le
    (c x : ι → ℤ) {i j : ι} (hij : i ≠ j) (hle : c i ≤ c j) :
    (∑ k, c k * x k) ≤ (∑ k, c k * exchangeVec x i j k) := by
  have h := exchange_linear_drop_eq_coeff_gap c x hij
  linarith

/-- **The exchange descent as discrete energy dissipation.** -/
theorem exchange_energy_dissipation
    (c x : ι → ℤ) {i j : ι} (hij : i ≠ j) :
    (∑ k, c k * x k) - (∑ k, c k * exchangeVec x i j k) = c i - c j := by
  have h := exchange_linear_drop_eq_coeff_gap c x hij
  linarith

/-! ## Section 3: M-Convex Set Definition -/

/-- **M-convex set predicate.**
    A finite set `S ⊆ ℤ^ι` is M-convex if it is nonempty, has constant coordinate sum,
    and satisfies the symmetric exchange axiom. -/
structure IsMConvexSet (S : Finset (ι → ℤ)) : Prop where
  nonempty : S.Nonempty
  constant_sum : ∀ x ∈ S, ∀ y ∈ S, ∑ k : ι, x k = ∑ k : ι, y k
  exchange : ∀ x ∈ S, ∀ y ∈ S, ∀ i : ι,
    x i > y i →
    ∃ j : ι, j ≠ i ∧ x j < y j ∧ (exchangeVec x i j) ∈ S

/-! ## Section 4: Local and Global Optimality -/

/-- A point `x ∈ S` is an **exchange-local minimum** if no single exchange move
    in `S` strictly improves the linear objective `c`. -/
def IsExchangeLocalMin
    (S : Finset (ι → ℤ)) (c : ι → ℤ) (x : ι → ℤ) : Prop :=
  x ∈ S ∧
  ∀ i j : ι, i ≠ j →
    exchangeVec x i j ∈ S →
    (∑ k, c k * x k) ≤ (∑ k, c k * exchangeVec x i j k)

/-- A **certified argmin**: a point with proof of membership and global optimality. -/
structure CertifiedArgmin (S : Finset (ι → ℤ)) (c : ι → ℤ) where
  point : ι → ℤ
  mem : point ∈ S
  optimal : ∀ y ∈ S, (∑ k, c k * point k) ≤ (∑ k, c k * y k)

/-! ## Section 5: Positive Difference Potential -/

/-- The **positive difference potential** from `x` to `y`:
    `posDiff x y = ∑ k, max(x_k - y_k, 0)` (as a natural number). -/
def posDiff (x y : ι → ℤ) : ℕ :=
  ∑ k : ι, (x k - y k).toNat

/-
When `posDiff x y = 0` and sums are equal, then `x = y`.
-/
theorem posDiff_zero_imp_eq {x y : ι → ℤ}
    (hsum : ∑ k : ι, x k = ∑ k : ι, y k)
    (hpd : posDiff x y = 0) :
    x = y := by
  have h_le : ∀ k, x k ≤ y k := by
    unfold posDiff at hpd;
    simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
  exact funext fun k => le_antisymm ( h_le k ) ( by simpa [ hsum ] using Finset.single_le_sum ( fun a _ => sub_nonneg.mpr ( h_le a ) ) ( Finset.mem_univ k ) )

/-
If `posDiff x y > 0` and sums are equal, there exists `j` with `x j < y j`.
-/
theorem posDiff_pos_exists_exceed {x y : ι → ℤ}
    (hsum : ∑ k : ι, x k = ∑ k : ι, y k)
    (hpd : 0 < posDiff x y) :
    ∃ j : ι, x j < y j := by
  contrapose! hpd; simp_all +decide [ posDiff ] ;
  -- Since the sums are equal and each term in the sum of x is greater than or equal to the corresponding term in the sum of y, each term must be equal.
  have h_eq : ∀ j, x j = y j := by
    exact fun j => le_antisymm ( le_of_not_gt fun h => by have := Finset.sum_lt_sum ( fun i _ => hpd i ) ⟨ j, Finset.mem_univ j, h ⟩ ; linarith ) ( hpd j );
  aesop

/-
If `posDiff x y > 0`, there exists `i` with `x i > y i`.
-/
theorem posDiff_pos_exists_pos {x y : ι → ℤ}
    (hpd : 0 < posDiff x y) :
    ∃ i : ι, x i > y i := by
  contrapose! hpd;
  exact Finset.sum_nonpos fun i _ => by simpa [ Int.toNat_of_nonpos ( sub_nonpos_of_le ( hpd i ) ) ] ;

/-
An exchange from `y` toward `x` decreases `posDiff x _` by exactly 1.
    Specifically, if `y_j > x_j` and `y_i < x_i`, then exchanging `j → i` in `y`
    gives `y'` with `posDiff x y' = posDiff x y - 1`.
-/
theorem posDiff_exchange_dec {x y : ι → ℤ} {i j : ι}
    (hij : j ≠ i) (hyi : y i < x i) (hyj : y j > x j) :
    posDiff x (exchangeVec y j i) + 1 = posDiff x y := by
  unfold posDiff exchangeVec;
  rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem ( by aesop ) ( Finset.mem_univ j ) ) ];
  rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem ( by aesop ) ( Finset.mem_univ j ) ) ];
  rw [ Finset.sum_congr rfl fun k hk => by aesop ];
  grind +revert

/-! ## Section 6: The Main Theorem — Local Implies Global -/

/-
Auxiliary: the set `{k : x k < y k}` is nonempty when `posDiff x y > 0`
    and sums are equal. Among these, we can pick one maximizing `c`.
-/
theorem exists_argmax_deficit {x y : ι → ℤ} {c : ι → ℤ}
    (hsum : ∑ k : ι, x k = ∑ k : ι, y k)
    (hpd : 0 < posDiff x y) :
    ∃ j : ι, x j < y j ∧ ∀ k : ι, x k < y k → c k ≤ c j := by
  convert Finset.exists_max_image _ ( fun k => c k ) ( Finset.filter_nonempty_iff.mpr _ ) using 1;
  rotate_left;
  use fun k => x k < y k;
  infer_instance;
  exact Finset.univ;
  · exact Exists.elim ( posDiff_pos_exists_exceed hsum hpd ) fun k hk => ⟨ k, Finset.mem_univ _, hk ⟩;
  · aesop

/-
**Local exchange optimality implies global optimality on M-convex sets.**

    The central theorem: on an M-convex set, any point with no improving exchange
    is a global minimum. This is the discrete convex analogue of first-order optimality.

    **Proof**: Strong induction on `posDiff x y`. At each step, choose the most expensive
    deficit coordinate `j*`, use M-convexity twice (once from y toward x, once from x
    toward y), and chain the cost inequalities via local optimality.
-/
theorem exchange_local_min_implies_global_min
    (S : Finset (ι → ℤ))
    (hM : IsMConvexSet S)
    (c : ι → ℤ)
    (x : ι → ℤ)
    (hx : x ∈ S)
    (hlocal : ∀ i j : ι, i ≠ j →
      exchangeVec x i j ∈ S →
      (∑ k, c k * x k) ≤ (∑ k, c k * exchangeVec x i j k)) :
    ∀ y, y ∈ S → (∑ k, c k * x k) ≤ (∑ k, c k * y k) := by
  intro y hy
  induction' n : posDiff x y using Nat.strong_induction_on with n ih generalizing y;
  by_cases hpd : 0 < posDiff x y;
  · -- By exists_argmax_deficit, there exists j_star such that x j_star < y j_star and ∀ k, x k < y k → c k ≤ c j_star.
    obtain ⟨j_star, hj_star_deficit, hj_star_max⟩ : ∃ j_star : ι, x j_star < y j_star ∧ ∀ k : ι, x k < y k → c k ≤ c j_star := by
      apply exists_argmax_deficit;
      · exact hM.constant_sum x hx y hy;
      · exact hpd;
    -- Since y j_star > x j_star, apply hM.exchange y hy x hx j_star (by linarith) to get i_star with i_star ≠ j_star, y i_star < x i_star, and exchangeVec y j_star i_star ∈ S.
    obtain ⟨i_star, hi_star_ne, hi_star_deficit, hi_star_exchange⟩ : ∃ i_star : ι, i_star ≠ j_star ∧ y i_star < x i_star ∧ exchangeVec y j_star i_star ∈ S := by
      exact hM.exchange y hy x hx j_star hj_star_deficit |> fun ⟨ i, hi₁, hi₂, hi₃ ⟩ => ⟨ i, by aesop ⟩;
    -- By IH on y' (with posDiff x y' < posDiff x y): c·x ≤ c·y'.
    have h_ind : ∑ k, c k * x k ≤ ∑ k, c k * (exchangeVec y j_star i_star) k := by
      apply ih (posDiff x (exchangeVec y j_star i_star));
      · linarith [ posDiff_exchange_dec ( by tauto ) ( by tauto ) ( by tauto : y j_star > x j_star ) ];
      · assumption;
      · rfl;
    -- By exchange_linear_drop_eq_coeff_gap, we have c·y' = c·y + c i_star - c j_star.
    have h_exchange : ∑ k, c k * (exchangeVec y j_star i_star) k = ∑ k, c k * y k + c i_star - c j_star := by
      convert exchange_linear_drop_eq_coeff_gap c y ( show j_star ≠ i_star from Ne.symm hi_star_ne ) using 1 ; ring;
    -- By hM.exchange x hx y hy i_star (y i_star < x i_star gives x i_star > y i_star) to get j_prime with j_prime ≠ i_star, x j_prime < y j_prime, and exchangeVec x i_star j_prime ∈ S.
    obtain ⟨j_prime, hj_prime_ne, hj_prime_deficit, hj_prime_exchange⟩ : ∃ j_prime : ι, j_prime ≠ i_star ∧ x j_prime < y j_prime ∧ exchangeVec x i_star j_prime ∈ S := by
      exact hM.exchange x hx y hy i_star ( by linarith );
    linarith [ hlocal i_star j_prime ( Ne.symm hj_prime_ne ) hj_prime_exchange, exchange_linear_drop_eq_coeff_gap c x ( Ne.symm hj_prime_ne ) |> Eq.symm, hj_star_max j_prime hj_prime_deficit ];
  · have := posDiff_zero_imp_eq ( hM.constant_sum x hx y hy ) ( by linarith ) ; aesop;

/-! ## Section 7: Existence of Minimum and Termination -/

/-
Any nonempty finset has a minimum under a linear objective.
-/
theorem finite_mconvex_has_optimum
    (S : Finset (ι → ℤ))
    (hne : S.Nonempty)
    (c : ι → ℤ) :
    ∃ x ∈ S, ∀ y ∈ S, (∑ k, c k * x k) ≤ (∑ k, c k * y k) := by
  exact Finset.exists_min_image _ _ hne

/-
**Termination of exchange descent.**
    On a finite M-convex set, there exists an exchange-local minimum.
-/
theorem steepest_descent_terminates
    (S : Finset (ι → ℤ))
    (hM : IsMConvexSet S)
    (c : ι → ℤ) :
    ∃ x ∈ S, IsExchangeLocalMin S c x := by
  obtain ⟨x_min, hx_min⟩ : ∃ x_min ∈ S, ∀ y ∈ S, (∑ k, c k * x_min k) ≤ (∑ k, c k * y k) := by
    exact Finset.exists_min_image _ _ hM.nonempty;
  exact ⟨ x_min, hx_min.1, hx_min.1, fun i j hij h => hx_min.2 _ h ⟩

/-
An infinite strictly descending objective sequence on a finite set is impossible.
-/
theorem no_infinite_strict_descent
    (S : Finset (ι → ℤ))
    (c : ι → ℤ)
    (seq : ℕ → ι → ℤ)
    (hseq_mem : ∀ n, seq n ∈ S)
    (hseq_strict : ∀ n, (∑ k, c k * seq (n + 1) k) < (∑ k, c k * seq n k)) :
    False := by
  -- By definition of `seq`, the sequence of sums `∑ k, c k * seq n k` is strictly decreasing.
  have h_sum_dec : StrictAnti (fun n => ∑ k, c k * seq n k) := by
    exact strictAnti_nat_of_succ_lt hseq_strict;
  -- Since `S` is finite, the set of values `∑ k, c k * seq n k` is also finite.
  have h_finite_sum : Set.Finite (Set.range (fun n => ∑ k, c k * seq n k)) := by
    exact Set.Finite.subset ( S.finite_toSet.image fun x => ∑ k, c k * x k ) ( Set.range_subset_iff.mpr fun n => by aesop );
  exact h_finite_sum.not_infinite <| Set.infinite_range_of_injective h_sum_dec.injective

/-! ## Section 8: Complexity Bound -/

/-
**Complexity bound**: a strictly descending objective sequence on `S`
    has length at most `|S|`.
-/
theorem descent_length_le_card
    (S : Finset (ι → ℤ))
    (c : ι → ℤ)
    (n : ℕ)
    (hn : S.card < n)
    (seq : Fin n → ι → ℤ)
    (hseq_mem : ∀ k, seq k ∈ S)
    (hseq_strict : ∀ k : Fin (n - 1),
      (∑ l, c l * seq ⟨k.val + 1, by omega⟩ l) <
      (∑ l, c l * seq ⟨k.val, by omega⟩ l)) :
    False := by
  by_contra hn_not_lt_card_S
  generalize_proofs at *;
  -- By the pigeonhole principle, since there are more steps than elements in S, there must be at least two indices a and b such that seq a = seq b.
  obtain ⟨a, b, hab⟩ : ∃ a b : Fin n, a < b ∧ seq a = seq b := by
    by_contra h_contra;
    exact absurd ( Finset.card_le_card ( show Finset.image seq Finset.univ ⊆ S from Finset.image_subset_iff.mpr fun k _ => hseq_mem k ) ) ( by rw [ Finset.card_image_of_injective _ fun a b h => le_antisymm ( not_lt.mp fun hlt => h_contra ⟨ b, a, hlt, h.symm ⟩ ) ( not_lt.mp fun hlt => h_contra ⟨ a, b, hlt, h ⟩ ) ] ; simpa );
  -- By induction on $k$, we can show that the objective value at $k$ is strictly decreasing.
  have h_ind : ∀ k : Fin n, ∀ l : Fin n, k < l → ∑ i, c i * seq k i > ∑ i, c i * seq l i := by
    intro k l hkl; induction' l with l hl ih generalizing k; induction' k with k hk ihk; (
    induction' l with l hl generalizing k; induction' k with k hk ihk; (
    tauto);
    · tauto;
    · rcases eq_or_lt_of_le ( show k ≤ l from Nat.le_of_lt_succ hkl ) with rfl | hkl <;> simp_all +decide [ Fin.add_def, Nat.mod_eq_of_lt ];
      · exact hseq_strict ⟨ k, Nat.lt_pred_iff.mpr ‹_› ⟩;
      · exact lt_trans ( hseq_strict ⟨ l, Nat.lt_pred_iff.mpr ‹_› ⟩ ) ( hl ( Nat.lt_of_succ_lt ‹_› ) _ hk hkl ));
  grind +splitImp

/-! ## Section 9: Certified Optimizer -/

/-- **Construction of a certified argmin on M-convex sets.** -/
theorem certified_argmin_of_mconvex
    (S : Finset (ι → ℤ))
    (hM : IsMConvexSet S)
    (c : ι → ℤ) :
    ∃ z : CertifiedArgmin S c, True := by
  obtain ⟨x, hx, hopt⟩ := finite_mconvex_has_optimum S hM.nonempty c
  exact ⟨⟨x, hx, hopt⟩, trivial⟩

/-! ## Section 10: Exchange Reachability and Distance -/

/-- Exchange reachability in at most `n` steps within `S`. -/
inductive ExchangeReachableIn
    (S : Finset (ι → ℤ)) : ℕ → (ι → ℤ) → (ι → ℤ) → Prop where
  | refl (x : ι → ℤ) (n : ℕ) : ExchangeReachableIn S n x x
  | step (x y z : ι → ℤ) (n : ℕ) (i j : ι)
      (hij : i ≠ j) (hy : y = exchangeVec x i j) (hyS : y ∈ S)
      (hrest : ExchangeReachableIn S n y z) :
      ExchangeReachableIn S (n + 1) x z

/-- Exchange distance: minimum number of exchanges connecting two points. -/
def exchangeDist (S : Finset (ι → ℤ)) (x y : ι → ℤ) : ℕ :=
  sInf {n | ExchangeReachableIn S n x y}

end MConvexOptimization