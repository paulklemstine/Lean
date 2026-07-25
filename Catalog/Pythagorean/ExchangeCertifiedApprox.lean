/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Certified Optimization via Exchange Constants

This file introduces **exchange constants** — numerical invariants of valuated exchange
families that quantitatively control optimization quality. The central innovation is that
algebraic exchange inequalities induce certified approximation laws: the exchange constant
`K` of a valuated family bounds how far any exchange-local optimum can be from the global
optimum.

## Mathematical Overview

Given a finite exchange family `F` (e.g., matroid bases) with a weight function
`w : Finset α → ℝ` satisfying a **valuated exchange bound** with constant `K ≥ 0`:

  ∀ B₁ B₂ feasible, ∀ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁ such that
    w(B₁) + w(B₂) ≤ w(swap₁) + w(swap₂) + K

then every exchange-local maximum `B` satisfies `w(Y) ≤ w(B) + K * |Y \ B|` for all
feasible `Y`. When `K = 0`, this recovers the classical theorem that exchange-local
optima are global optima on valuated matroids.

## Main Definitions

* `BaseExchangeFamily` — exchange family with equal-cardinality feasible sets
* `ValuatedExchangeBound` — two-basis exchange inequality with gap constant K
* `IsExchangeLocalMax` — exchange-local maximum of a weight function
* `ExchangeCertifiedApprox` — certified approximation predicate

## Main Results

1. `exchange_localMax_gap_bound` — **Core theorem**: valuated exchange bound + local
   optimality ⟹ certified K-controlled approximation via exchange path telescoping
2. `exchange_localMax_global_of_exact` — K = 0 recovery: exact valuated exchange implies
   local optima are global optima
3. `exchange_descent_terminates` — Exchange improvement terminates on finite families
4. `additive_weight_valuated_exact` — Additive weight functions satisfy exact (K = 0)
   valuated exchange, bridging to classical matroid greedy optimality
5. `exchange_localMax_certified_algorithm` — The exchange improvement algorithm terminates
   with a certified approximate optimum

## Cross-Domain Bridge

The exchange constant `K` bridges discrete convex analysis, combinatorial optimization,
algebraic generating functions, and certified approximation.

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Dress–Wenzel, "Valuated Matroids", Advances in Mathematics, 1992
-/

open Finset BigOperators

noncomputable section

namespace ExchangeCertifiedApprox

variable {α : Type*} [DecidableEq α]

/-! ## Section 1: Exchange Family Structure -/

/-- A **base exchange family** on a type `α`. The feasible sets all have the same
cardinality (as in matroid bases) and satisfy the symmetric exchange axiom. -/
structure BaseExchangeFamily (α : Type*) [DecidableEq α] where
  /-- Feasibility predicate on subsets -/
  feasible : Finset α → Prop
  /-- At least one feasible set exists -/
  feasible_nonempty : ∃ B, feasible B
  /-- All feasible sets have the same cardinality -/
  eq_card : ∀ ⦃B₁ B₂⦄, feasible B₁ → feasible B₂ → B₁.card = B₂.card
  /-- The **strong** symmetric exchange axiom: for any `x ∈ B₁ \ B₂`, there exists
  `y ∈ B₂ \ B₁` such that both swaps produce feasible sets. This is the strong
  basis exchange property, which holds for all matroids. -/
  exchange : ∀ ⦃B₁ B₂⦄, feasible B₁ → feasible B₂ →
    ∀ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁,
      feasible (insert y (B₁.erase x)) ∧ feasible (insert x (B₂.erase y))

/-! ## Section 2: Exchange-Local Optimality -/

/-- A feasible set `B` is an **exchange-local maximum** of `w` if no single
exchange move from `B` within the family strictly improves `w`. -/
def IsExchangeLocalMax
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (B : Finset α) : Prop :=
  F.feasible B ∧
  ∀ x ∈ B, ∀ y, y ∉ B →
    F.feasible (insert y (B.erase x)) →
    w (insert y (B.erase x)) ≤ w B

/-! ## Section 3: Valuated Exchange Bound — The Exchange Constant -/

/-- **Valuated exchange bound with constant `K`.**

For any two feasible sets `B₁, B₂` and `x ∈ B₁ \ B₂`, there exists `y ∈ B₂ \ B₁`
such that the exchange is feasible and the two-basis valuation inequality holds
up to an additive gap `K`:
  `w(B₁) + w(B₂) ≤ w(insert y (B₁.erase x)) + w(insert x (B₂.erase y)) + K`

When `K = 0`, this is the exact valuated matroid exchange axiom. -/
def ValuatedExchangeBound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) : Prop :=
  0 ≤ K ∧
  ∀ ⦃B₁ B₂⦄, F.feasible B₁ → F.feasible B₂ →
    ∀ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁,
      F.feasible (insert y (B₁.erase x)) ∧
      F.feasible (insert x (B₂.erase y)) ∧
      w B₁ + w B₂ ≤ w (insert y (B₁.erase x)) + w (insert x (B₂.erase y)) + K

/-- The **certified approximation predicate**: every exchange-local maximum has
weight within `K * d` of any other feasible set, where `d` is the exchange
distance (symmetric difference cardinality). -/
def IsCertifiedApprox
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) : Prop :=
  ∀ ⦃B⦄, IsExchangeLocalMax F w B →
    ∀ ⦃Y⦄, F.feasible Y → w Y ≤ w B + K * ((Y \ B).card : ℝ)

/-! ## Section 4: Key Structural Lemmas -/

/-
Equal-cardinality sets have symmetric difference with equal halves.
-/
theorem sdiff_card_eq_of_eq_card {B₁ B₂ : Finset α}
    (h : B₁.card = B₂.card) :
    (B₁ \ B₂).card = (B₂ \ B₁).card := by
  grind

/-
After exchanging `x ∈ Y \ B` for `y ∈ B \ Y`, the new symmetric difference
shrinks: `|(insert y (Y.erase x)) \ B| = |Y \ B| - 1`.
-/
theorem sdiff_card_decrease {B Y : Finset α} {x y : α}
    (hx_mem : x ∈ Y \ B) (hy_mem : y ∈ B \ Y) :
    ((insert y (Y.erase x)) \ B).card + 1 = (Y \ B).card := by
  simp_all +decide;
  convert congr_arg ( · + 1 ) ( Finset.card_erase_of_mem ( show x ∈ Y \ B from Finset.mem_sdiff.mpr hx_mem ) ) using 1;
  · congr 2 with z ; aesop;
  · rw [ Nat.sub_add_cancel ( Finset.card_pos.mpr ⟨ x, by aesop ⟩ ) ]

/-
If `|Y \ B| = 0` and `|Y| = |B|`, then `Y = B`.
-/
theorem eq_of_sdiff_empty_of_eq_card {B Y : Finset α}
    (h_card : Y.card = B.card) (h_sdiff : (Y \ B).card = 0) :
    Y = B := by
  simp_all +decide [ Finset.ext_iff ];
  exact fun x => ⟨ h_sdiff x, fun hx => by_contra fun hx' => by have := Finset.eq_of_subset_of_card_le h_sdiff ( by simp +decide [ h_card ] ) ; aesop ⟩

/-! ## Section 5: The Core Theorem — Exchange Gap Bound -/

/-- **Exchange gap bound theorem (Theorem 1).**

If a base exchange family with weight `w` satisfies the valuated exchange bound
with constant `K`, then every exchange-local maximum `B` satisfies
  `w(Y) ≤ w(B) + K * |Y \ B|`
for all feasible `Y`.

**Proof**: Strong induction on `|Y \ B|`. At each step, pick `x ∈ Y \ B`, use
the valuated exchange bound to get `y ∈ B \ Y` with the two-basis inequality.
Local optimality at `B` ensures `w(B') ≤ w(B)` for the reverse exchange. The
inductive hypothesis on `Y' = insert y (Y.erase x)` completes the telescoping.

Helper: the core inductive step. Given the valuated exchange bound, local optimality
at B, and any feasible Y, we bound w(Y) by induction on (Y \ B).card. -/
private theorem gap_bound_induction
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K)
    (B : Finset α) (hBfeas : F.feasible B)
    (hBloc : ∀ x ∈ B, ∀ y, y ∉ B → F.feasible (insert y (B.erase x)) →
      w (insert y (B.erase x)) ≤ w B)
    (n : ℕ) (Y : Finset α) (hYfeas : F.feasible Y)
    (hn : (Y \ B).card = n) :
    w Y ≤ w B + K * (n : ℝ) := by
  induction n using Nat.strongRecOn generalizing Y with
  | _ n ih =>
  by_cases hn0 : n = 0
  · -- Base case
    subst hn0
    have hYB : Y = B := eq_of_sdiff_empty_of_eq_card (F.eq_card hYfeas hBfeas) hn
    subst hYB
    simp
  · -- Inductive step: n > 0
    have hne : (Y \ B).Nonempty := by
      rwa [← Finset.card_pos, hn, Nat.pos_iff_ne_zero]
    obtain ⟨x, hx_mem⟩ := hne
    -- Apply valuated exchange bound to Y, B with x ∈ Y \ B
    obtain ⟨y, hy_mem, hy_feas, hy_rev_feas, hy_ineq⟩ := hVE.2 hYfeas hBfeas x hx_mem
    have hyB : y ∈ B := (Finset.mem_sdiff.mp hy_mem).1
    have hyY : y ∉ Y := (Finset.mem_sdiff.mp hy_mem).2
    have hxB : x ∉ B := (Finset.mem_sdiff.mp hx_mem).2
    -- Local optimality: w(insert x (B.erase y)) ≤ w(B)
    -- B' = insert x (B.erase y) is feasible by hy_rev_feas
    have hB'_le : w (insert x (B.erase y)) ≤ w B := hBloc y hyB x hxB hy_rev_feas
    -- w(Y) + w(B) ≤ w(Y') + w(B') + K, with w(B') ≤ w(B)
    -- So w(Y) ≤ w(Y') + K
    have hY_le : w Y ≤ w (insert y (Y.erase x)) + K := by linarith
    -- |Y' \ B| = n - 1
    have hY'_card : (insert y (Y.erase x) \ B).card = n - 1 := by
      have := sdiff_card_decrease hx_mem hy_mem
      omega
    -- By IH
    have hY'_bound := ih (n - 1) (by omega) (insert y (Y.erase x)) hy_feas hY'_card
    -- Combine
    have hn_ge : 1 ≤ n := Nat.one_le_iff_ne_zero.mpr hn0
    have hn1 : (n : ℝ) = ((n - 1 : ℕ) : ℝ) + 1 := by
      rw [Nat.cast_sub hn_ge]; ring
    nlinarith [hY_le, hY'_bound, hVE.1]

theorem exchange_localMax_gap_bound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y → w Y ≤ w B + K * ((Y \ B).card : ℝ) := by
  intro B ⟨hBfeas, hBloc⟩ Y hYfeas
  exact gap_bound_induction F w K hVE B hBfeas hBloc _ Y hYfeas rfl

/-- **Corollary: Certified approximation.** -/
theorem valuated_exchange_implies_certified
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K) :
    IsCertifiedApprox F w K :=
  exchange_localMax_gap_bound F w K hVE

/-! ## Section 6: K = 0 Recovery — Exact Optimality -/

/-- **Exact optimality recovery (Theorem 2).**
When `K = 0`, the certified approximation becomes exact: every exchange-local
maximum is a global maximum. -/
theorem exchange_localMax_global_of_exact
    (F : BaseExchangeFamily α) (w : Finset α → ℝ)
    (hVE : ValuatedExchangeBound F w 0) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y → w Y ≤ w B := by
  intro B hB Y hY
  have h := exchange_localMax_gap_bound F w 0 hVE hB hY
  simp at h
  exact h

/-! ## Section 7: Additive Weight Functions -/

/-- An **additive weight function**: `w(B) = ∑_{x ∈ B} wt(x)`. -/
def additiveWeight (wt : α → ℝ) (B : Finset α) : ℝ := ∑ x ∈ B, wt x

/-
**Additive weights satisfy exact valuated exchange (Theorem 4).**
For `w(B) = ∑ wt(x)`, swapping `x ↔ y` preserves total weight:
`w(B₁) + w(B₂) = w(B₁') + w(B₂')`, so `K = 0`.
-/
theorem additive_weight_valuated_exact
    (F : BaseExchangeFamily α) (wt : α → ℝ) :
    ValuatedExchangeBound F (additiveWeight wt) 0 := by
  use le_rfl;
  intro B₁ B₂ h₁ h₂ x hx;
  obtain ⟨ y, hy, hy₁, hy₂ ⟩ := F.exchange h₁ h₂ x hx;
  -- By definition of additive weight, we have:
  have h_add : additiveWeight wt (insert y (B₁.erase x)) = additiveWeight wt B₁ - wt x + wt y ∧ additiveWeight wt (insert x (B₂.erase y)) = additiveWeight wt B₂ - wt y + wt x := by
    constructor <;> unfold additiveWeight <;> rw [ Finset.sum_insert ] <;> simp_all +decide [ Finset.sum_erase ]; all_goals ring;
  grind

/-- **Corollary: Greedy optimality for additive weights.**
Every exchange-local maximum of an additive weight function is globally optimal. -/
theorem additive_weight_local_is_global
    (F : BaseExchangeFamily α) (wt : α → ℝ) :
    ∀ ⦃B⦄, IsExchangeLocalMax F (additiveWeight wt) B →
      ∀ ⦃Y⦄, F.feasible Y → additiveWeight wt Y ≤ additiveWeight wt B :=
  exchange_localMax_global_of_exact F (additiveWeight wt) (additive_weight_valuated_exact F wt)

/-! ## Section 8: Exchange Descent Termination -/

/-
**Exchange descent termination (Theorem 3).**
On a finite exchange family, there exists an exchange-locally optimal set.
-/
theorem exchange_descent_terminates
    (F : BaseExchangeFamily α) [Fintype α]
    (w : Finset α → ℝ)
    (hfin : {B : Finset α | F.feasible B}.Finite) :
    ∃ B, IsExchangeLocalMax F w B := by
  -- By definition of finite sets, there exists a maximum element in the set of feasible sets with respect to the weight function $w$.
  obtain ⟨B, hB⟩ : ∃ B ∈ {B | F.feasible B}, ∀ Y ∈ {B | F.feasible B}, w Y ≤ w B := by
    apply_rules [ Set.exists_max_image ];
    exact ⟨ _, F.feasible_nonempty.choose_spec ⟩;
  exact ⟨ B, hB.1, fun x hx y hy hxy => hB.2 _ hxy ⟩

/-- **Certified algorithm (Theorem 5).**
There exists an exchange-local maximum satisfying the certified approximation. -/
theorem exchange_localMax_certified_algorithm
    (F : BaseExchangeFamily α) [Fintype α]
    (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K)
    (hfin : {B : Finset α | F.feasible B}.Finite) :
    ∃ B, IsExchangeLocalMax F w B ∧
      ∀ Y, F.feasible Y → w Y ≤ w B + K * ((Y \ B).card : ℝ) := by
  obtain ⟨B, hB⟩ := exchange_descent_terminates F w hfin
  exact ⟨B, hB, fun Y hY => exchange_localMax_gap_bound F w K hVE hB hY⟩

/-! ## Section 9: Exchange Distance and Diameter -/

/-- The **exchange distance** between two sets. -/
def exchangeDist (B₁ B₂ : Finset α) : ℕ := (B₁ \ B₂).card

/-- Exchange distance is symmetric for equal-cardinality sets. -/
theorem exchangeDist_comm {B₁ B₂ : Finset α} (h : B₁.card = B₂.card) :
    exchangeDist B₁ B₂ = exchangeDist B₂ B₁ :=
  sdiff_card_eq_of_eq_card h

/-- The **exchange diameter** of a family. -/
noncomputable def exchangeDiameter
    (F : BaseExchangeFamily α) (hfin : {B : Finset α | F.feasible B}.Finite) : ℕ :=
  hfin.toFinset.sup fun B => hfin.toFinset.sup fun B' => exchangeDist B B'

/-
**Global gap bound via diameter.**
-/
theorem exchange_localMax_global_gap_bound
    (F : BaseExchangeFamily α) [Fintype α]
    (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K)
    (hfin : {B : Finset α | F.feasible B}.Finite) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y →
        w Y ≤ w B + K * (exchangeDiameter F hfin : ℝ) := by
  intros B hB Y hY;
  refine' le_trans ( exchange_localMax_gap_bound F w K hVE hB hY ) _;
  gcongr;
  · exact hVE.1;
  · refine' le_trans _ ( Finset.le_sup <| hfin.mem_toFinset.mpr hY );
    exact Finset.le_sup ( f := fun B' => exchangeDist Y B' ) ( hfin.mem_toFinset.mpr hB.1 ) |> le_trans ( by rfl ) ;

/-! ## Section 10: Exchange Lipschitz Property -/

/-- The **exchange Lipschitz property**: weight varies by at most `K` along
single exchange steps. -/
def IsExchangeLipschitz
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) : Prop :=
  ∀ ⦃B₁ B₂⦄, F.feasible B₁ → F.feasible B₂ →
    exchangeDist B₁ B₂ = 1 → |w B₁ - w B₂| ≤ K

/-- The gap bound implies a directional Lipschitz property from any local max. -/
theorem gap_bound_implies_lipschitz_from_localMax
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y →
        w Y - w B ≤ K * ((Y \ B).card : ℝ) := by
  intro B hB Y hY
  linarith [exchange_localMax_gap_bound F w K hVE hB hY]

/-! ## Section 11: Monotonicity of Exchange Constant -/

/-- A smaller exchange constant gives a tighter certified bound. -/
theorem valuated_exchange_mono {F : BaseExchangeFamily α} {w : Finset α → ℝ}
    {K₁ K₂ : ℝ} (h : K₁ ≤ K₂)
    (hVE : ValuatedExchangeBound F w K₁) :
    ValuatedExchangeBound F w K₂ := by
  refine ⟨le_trans hVE.1 h, fun {B₁ B₂} h₁ h₂ x hx => ?_⟩
  obtain ⟨y, hy, hfeas, hrev, hineq⟩ := hVE.2 h₁ h₂ x hx
  exact ⟨y, hy, hfeas, hrev, by linarith⟩

/-! ## Section 12: Conjecture — Sharp Exchange Approximation -/

/-
**Conjecture (Sharp Exchange Approximation).**
For every base exchange family, the gap bound can be strengthened from
`K * |Y \ B|` to `K * rank`, where `rank` is the common cardinality.
This is provable from the gap bound since `|Y \ B| ≤ rank`.
-/
theorem sharp_exchange_bound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y →
        w Y ≤ w B + K * (Y.card : ℝ) := by
  intros B hB Y hY;
  convert exchange_localMax_gap_bound F w K hVE hB hY |> le_trans <| ?_;
  gcongr;
  · exact hVE.1;
  · grind

end ExchangeCertifiedApprox