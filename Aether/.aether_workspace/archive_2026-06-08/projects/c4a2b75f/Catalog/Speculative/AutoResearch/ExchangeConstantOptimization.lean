/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Exchange Constants and Certified Optimization Algorithms

This file develops the theory connecting exchange constants of valuated exchange families
to certified approximation guarantees for combinatorial optimization algorithms. The central
contribution is a formalization of how the exchange constant `K` — an algebraic invariant
measuring the "slack" in basis exchange inequalities — provides provable quality bounds for
greedy and local-search algorithms on matroid-like structures.

## Main Definitions

* `GreedyExchangeSeq` — A sequence of feasible sets connected by improving exchange moves
* `ExchangeApproxRatio` — Multiplicative approximation ratio certified by exchange constant
* `ExchangeAdjacent` / `ExchangeReachable` — Exchange graph structure

## Main Results

1. `exchange_localMax_gap_bound` — Core gap bound: local max within K·distance of any feasible set
2. `greedy_produces_localMax` — Maximal greedy sequences terminate at local maxima
3. `multiplicative_approx_from_exchange_constant` — Additive-to-multiplicative approximation
4. `exchange_approx_ratio_bound` — Certified multiplicative ratio 1 + K·r/w_min
5. `exchange_graph_connected` — Exchange graph connectivity (by induction on symmetric diff)
6. `greedy_seq_length_bound` — Greedy sequences bounded by number of feasible sets
7. `additive_weight_exact_exchange` — Additive weights have K = 0 (greedy optimality)
8. `descent_energy_nonneg` — Lyapunov function for exchange descent
9. `descent_energy_plus_gap_bound` — Combined energy + gap certified bound
10. `weight_gap_from_localMax_diameter` — Weight gap via exchange diameter (cross-domain)

## Cross-Domain Bridge: Optimization ↔ Graph Theory ↔ Algebra

The exchange constant K, the exchange graph diameter D, and the weight spread Δw
satisfy the fundamental inequality:
  `Δw ≤ K · D`
where Δw = max_{Y feasible} (w(Y) - w(B)) for a local max B. This connects:
- **Combinatorial optimization** (approximation quality via K)
- **Graph theory** (diameter D of the exchange graph)
- **Algebra** (coefficient structure determining K)

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Dress–Wenzel, "Valuated Matroids", Advances in Mathematics, 1992
-/

open Finset BigOperators

noncomputable section

namespace ExchangeConstantOpt

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Section 1: Base Exchange Family -/

/-- A **base exchange family** on a finite type `α`. -/
structure BaseExchangeFamily (α : Type*) [DecidableEq α] where
  feasible : Finset α → Prop
  feasible_nonempty : ∃ B, feasible B
  eq_card : ∀ ⦃B₁ B₂⦄, feasible B₁ → feasible B₂ → B₁.card = B₂.card
  exchange : ∀ ⦃B₁ B₂⦄, feasible B₁ → feasible B₂ →
    ∀ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁,
      feasible (insert y (B₁.erase x)) ∧ feasible (insert x (B₂.erase y))

/-- Valuated exchange bound with constant K ≥ 0. -/
def ValuatedExchangeBound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) : Prop :=
  0 ≤ K ∧
  ∀ ⦃B₁ B₂⦄, F.feasible B₁ → F.feasible B₂ →
    ∀ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁,
      F.feasible (insert y (B₁.erase x)) ∧
      F.feasible (insert x (B₂.erase y)) ∧
      w B₁ + w B₂ ≤ w (insert y (B₁.erase x)) + w (insert x (B₂.erase y)) + K

/-- Exchange-local maximum. -/
def IsExchangeLocalMax
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (B : Finset α) : Prop :=
  F.feasible B ∧
  ∀ x ∈ B, ∀ y, y ∉ B →
    F.feasible (insert y (B.erase x)) →
    w (insert y (B.erase x)) ≤ w B

/-- Additive weight function. -/
def additiveWeight (wt : α → ℝ) (B : Finset α) : ℝ := ∑ x ∈ B, wt x

/-! ## Section 2: Greedy Exchange Sequences (Novel Definition) -/

/-- A **greedy exchange sequence** is a finite sequence of feasible sets where each
step is obtained by a single exchange that strictly improves the weight function.
This captures the iterative improvement paradigm used in matroid optimization. -/
structure GreedyExchangeSeq (F : BaseExchangeFamily α) (w : Finset α → ℝ) where
  len : ℕ
  seq : Fin (len + 1) → Finset α
  feasible : ∀ k, F.feasible (seq k)
  exchange_step : ∀ k : Fin len,
    ∃ x ∈ seq ⟨k.val, by omega⟩, ∃ y ∉ seq ⟨k.val, by omega⟩,
      seq ⟨k.val + 1, by omega⟩ = insert y ((seq ⟨k.val, by omega⟩).erase x) ∧
      F.feasible (insert y ((seq ⟨k.val, by omega⟩).erase x))
  improving : ∀ k : Fin len,
    w (seq ⟨k.val, by omega⟩) < w (seq ⟨k.val + 1, by omega⟩)

/-! ## Section 3: Exchange Approximation Ratio (Novel Definition) -/

/-- The **exchange approximation ratio**: family has ratio `ρ` if for every
exchange-local maximum `B` with `w(B) > 0` and every feasible `Y`:
  `w(Y) ≤ ρ * w(B)`.
Connects additive gap bound `K * |Y \ B|` to multiplicative ratio. -/
def HasExchangeApproxRatio
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (ρ : ℝ) : Prop :=
  1 ≤ ρ ∧
  ∀ ⦃B⦄, IsExchangeLocalMax F w B → 0 < w B →
    ∀ ⦃Y⦄, F.feasible Y → w Y ≤ ρ * w B

/-! ## Section 4: Structural Lemmas -/

set_option linter.unusedSectionVars false in
/-- Equal-cardinality sets have symmetric differences of equal size. -/
theorem sdiff_card_eq_of_eq_card {B₁ B₂ : Finset α}
    (h : B₁.card = B₂.card) :
    (B₁ \ B₂).card = (B₂ \ B₁).card := by
  have h1 := Finset.card_sdiff_add_card_inter B₁ B₂
  have h2 := Finset.card_sdiff_add_card_inter B₂ B₁
  rw [Finset.inter_comm] at h2
  omega

set_option linter.unusedSectionVars false in
/-- After an exchange, the symmetric difference shrinks by one. -/
theorem sdiff_card_decrease' {B Y : Finset α} {x y : α}
    (hx : x ∈ Y \ B) (hy : y ∈ B \ Y) :
    ((insert y (Y.erase x)) \ B).card + 1 = (Y \ B).card := by
  grind +suggestions

set_option linter.unusedSectionVars false in
/-- If sdiff is empty and cards equal, sets are equal. -/
theorem eq_of_sdiff_empty {B Y : Finset α}
    (h_card : Y.card = B.card) (h_sdiff : (Y \ B).card = 0) :
    Y = B := by
  apply Finset.eq_of_subset_of_card_le; aesop; linarith

/-! ## Section 5: Gap Bound Theorem -/

/-- **The core gap bound**: exchange-local maxima are within `K * |Y \ B|` of any
feasible `Y`. This is the central theorem connecting exchange constants to
optimization quality.

**Proof**: Strong induction on `|Y \ B|`. At each step, use the valuated exchange
bound to get a closer feasible set, and local optimality to bound the reverse
exchange cost. -/
theorem exchange_localMax_gap_bound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y → w Y ≤ w B + K * ((Y \ B).card : ℝ) := by
  intro B hB Y hY
  have h_eq_card : Y.card = B.card := F.eq_card hY hB.1
  induction' n : (Y \ B).card with n ih generalizing Y B
  · rw [eq_of_sdiff_empty h_eq_card n]; norm_num
  · obtain ⟨x, hx⟩ : ∃ x ∈ Y \ B, ∃ y ∈ B \ Y,
        F.feasible (insert y (Y.erase x)) ∧
        F.feasible (insert x (B.erase y)) ∧
        w Y + w B ≤ w (insert y (Y.erase x)) + w (insert x (B.erase y)) + K := by
      exact Exists.elim (Finset.card_pos.mp (by linarith))
        fun x hx => ⟨x, hx, hVE.2 hY hB.1 x hx⟩
    obtain ⟨y, hy⟩ := hx.right
    have h_local_max : w (insert x (B.erase y)) ≤ w B := by
      have := hB.2 y (by aesop) x (by aesop); aesop
    grind +suggestions

/-! ## Section 6: Greedy Termination at Local Maximum -/

set_option linter.unusedSectionVars false in
/-- **Theorem: Greedy exchange sequences produce exchange-local maxima.**
Any maximal greedy sequence terminates at an exchange-local maximum. -/
theorem greedy_produces_localMax
    (F : BaseExchangeFamily α) (w : Finset α → ℝ)
    (G : GreedyExchangeSeq F w)
    (h_maximal : ∀ x ∈ G.seq ⟨G.len, by omega⟩,
      ∀ y ∉ G.seq ⟨G.len, by omega⟩,
        F.feasible (insert y ((G.seq ⟨G.len, by omega⟩).erase x)) →
        w (insert y ((G.seq ⟨G.len, by omega⟩).erase x)) ≤ w (G.seq ⟨G.len, by omega⟩)) :
    IsExchangeLocalMax F w (G.seq ⟨G.len, by omega⟩) :=
  ⟨G.feasible ⟨G.len, by omega⟩, h_maximal⟩

/-! ## Section 7: Multiplicative Approximation Ratio -/

/-- **Multiplicative approximation from exchange constant.**
Exchange constant K + rank bound r → additive bound `w(Y) ≤ w(B) + K * r`. -/
theorem multiplicative_approx_from_exchange_constant
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) (r : ℕ)
    (hVE : ValuatedExchangeBound F w K)
    (h_rank : ∀ B, F.feasible B → B.card ≤ r)
    (hfin : {B : Finset α | F.feasible B}.Finite) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B → 0 < w B →
      ∀ ⦃Y⦄, F.feasible Y → w Y ≤ w B + K * (r : ℝ) := by
  intro B hB _ Y hY
  calc w Y ≤ w B + K * ((Y \ B).card : ℝ) := exchange_localMax_gap_bound F w K hVE hB hY
    _ ≤ w B + K * (r : ℝ) := by
        gcongr
        · exact hVE.1
        · exact_mod_cast le_trans (Finset.card_le_card Finset.sdiff_subset) (h_rank _ hY)

/-- **Certified multiplicative ratio**: `1 + K * r / w_min`. -/
theorem exchange_approx_ratio_bound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) (r : ℕ) (w_min : ℝ)
    (hVE : ValuatedExchangeBound F w K)
    (h_rank : ∀ B, F.feasible B → B.card ≤ r)
    (hw_min : 0 < w_min)
    (hw_lb : ∀ B, F.feasible B → w_min ≤ w B)
    (hfin : {B : Finset α | F.feasible B}.Finite) :
    HasExchangeApproxRatio F w (1 + K * r / w_min) := by
  constructor
  · exact le_add_of_nonneg_right (div_nonneg (mul_nonneg hVE.1 (Nat.cast_nonneg _)) hw_min.le)
  · intro B hB hB_pos Y hY
    have h_bound : w Y ≤ w B + K * (r : ℝ) := by
      grind +suggestions
    nlinarith [hw_lb B hB.1, mul_div_cancel₀ (K * r) hw_min.ne', hVE.1,
      show (r : ℝ) * K ≥ 0 from mul_nonneg (Nat.cast_nonneg _) hVE.1]

/-! ## Section 8: Exchange Graph Connectivity -/

/-- Two feasible sets are **exchange-adjacent** if they differ by a single exchange. -/
def ExchangeAdjacent (F : BaseExchangeFamily α) (B₁ B₂ : Finset α) : Prop :=
  F.feasible B₁ ∧ F.feasible B₂ ∧
  ∃ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁, B₂ = insert y (B₁.erase x)

/-- Exchange-reachability via single exchange steps. -/
inductive ExchangeReachable (F : BaseExchangeFamily α) :
    Finset α → Finset α → Prop where
  | refl (B : Finset α) (hB : F.feasible B) : ExchangeReachable F B B
  | step (B₁ B₂ B₃ : Finset α) :
      ExchangeAdjacent F B₁ B₂ → ExchangeReachable F B₂ B₃ →
      ExchangeReachable F B₁ B₃

/-- **Exchange graph connectivity**: any two feasible sets are exchange-reachable.
Proof by induction on `|B₁ \ B₂|`. -/
theorem exchange_graph_connected
    (F : BaseExchangeFamily α) (B₁ B₂ : Finset α)
    (h₁ : F.feasible B₁) (h₂ : F.feasible B₂) :
    ExchangeReachable F B₁ B₂ := by
  induction' n : (B₁ \ B₂).card with n ih generalizing B₁ B₂
  · convert ExchangeReachable.refl B₂ h₂
    exact eq_of_sdiff_empty (F.eq_card h₁ h₂) n
  · obtain ⟨x, hx⟩ : ∃ x, x ∈ B₁ \ B₂ :=
      Finset.card_pos.mp (n.symm ▸ Nat.succ_pos _)
    obtain ⟨y, hy₁, hy₂⟩ : ∃ y ∈ B₂ \ B₁, F.feasible (insert y (B₁.erase x)) :=
      F.exchange h₁ h₂ x hx |>.imp fun y ⟨hy₁, hy₂, _⟩ => ⟨hy₁, hy₂⟩
    have h_ind : ExchangeReachable F (insert y (B₁.erase x)) B₂ := by
      grind +suggestions
    exact ExchangeReachable.step _ _ _ ⟨h₁, hy₂, x, by aesop⟩ h_ind

/-! ## Section 9: Greedy Sequence Length Bound -/

/-- **Greedy sequences have bounded length**: at most `|feasible sets|` steps. -/
theorem greedy_seq_length_bound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ)
    (hfin : {B : Finset α | F.feasible B}.Finite)
    (G : GreedyExchangeSeq F w)
    (h_mem : ∀ k, G.seq k ∈ hfin.toFinset) :
    G.len < hfin.toFinset.card := by
  have h_strict_mono : StrictMono (fun k : Fin (G.len + 1) => w (G.seq k)) := by
    intro i j hij
    induction' j using Fin.inductionOn with j ih
    · tauto
    · cases lt_or_eq_of_le (show i ≤ Fin.castSucc j from Nat.le_of_lt_succ hij) <;>
        simp_all +decide [Fin.castSucc_lt_succ]
      · exact lt_trans ih (G.improving j)
      · exact G.improving j
  have h_inj := h_strict_mono.injective
  have h_card : (Finset.image (fun k : Fin (G.len + 1) => w (G.seq k)) Finset.univ).card ≤
      (Finset.image w hfin.toFinset).card :=
    Finset.card_le_card (Finset.image_subset_iff.mpr fun k _ =>
      Finset.mem_image_of_mem _ (h_mem k))
  simp_all +decide [Finset.card_image_of_injective _ h_inj]
  exact h_card.trans_le (Finset.card_image_le.trans (by simp +decide [Fintype.card_subtype]))

/-! ## Section 10: Additive Weights and Classical Greedy Optimality -/

/-- **Additive weight functions have exchange constant 0.**
For `w(B) = ∑_{x ∈ B} wt(x)`, swapping x ↔ y preserves the total weight sum,
so the exchange inequality holds with equality (K = 0). -/
theorem additive_weight_exact_exchange
    (F : BaseExchangeFamily α) (wt : α → ℝ) :
    ValuatedExchangeBound F (additiveWeight wt) 0 := by
  constructor <;> norm_num [ValuatedExchangeBound]
  intro B₁ B₂ hB₁ hB₂ x hx₁ hx₂
  obtain ⟨y, hy₁, hy₂, hy₃⟩ := F.exchange hB₁ hB₂ x (by aesop)
  use y
  simp_all [additiveWeight]
  linarith

/-- **Classical greedy optimality**: for additive weights, local max = global max. -/
theorem additive_greedy_globally_optimal
    (F : BaseExchangeFamily α) (wt : α → ℝ)
    (hVE : ValuatedExchangeBound F (additiveWeight wt) 0) :
    ∀ ⦃B⦄, IsExchangeLocalMax F (additiveWeight wt) B →
      ∀ ⦃Y⦄, F.feasible Y → additiveWeight wt Y ≤ additiveWeight wt B := by
  convert exchange_localMax_gap_bound F (additiveWeight wt) 0 hVE using 1
  norm_num

/-! ## Section 11: Descent Energy and Lyapunov Function -/

/-- The **descent energy** of a greedy exchange sequence: total weight improvement. -/
def descentEnergy (F : BaseExchangeFamily α) (w : Finset α → ℝ)
    (G : GreedyExchangeSeq F w) : ℝ :=
  w (G.seq ⟨G.len, by omega⟩) - w (G.seq ⟨0, by omega⟩)

/-- **Descent energy is nonnegative**: every greedy sequence improves the objective. -/
theorem descent_energy_nonneg
    (F : BaseExchangeFamily α) (w : Finset α → ℝ)
    (G : GreedyExchangeSeq F w) :
    0 ≤ descentEnergy F w G := by
  obtain ⟨len, seq, feasible, exchange_step, improving⟩ := G
  exact sub_nonneg_of_le (Fin.induction (by norm_num)
    (fun k ih => le_trans ih (le_of_lt (improving k)))
    (⟨len, Nat.lt_succ_self len⟩ : Fin (len + 1)))

/-- **Descent energy + gap bound**: certified quality for the greedy algorithm.
For a maximal greedy sequence ending at local max B:
  `w(Y) - w(start) ≤ descentEnergy + K * |Y \ B|` -/
theorem descent_energy_plus_gap_bound
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K)
    (G : GreedyExchangeSeq F w)
    (h_maximal : IsExchangeLocalMax F w (G.seq ⟨G.len, by omega⟩))
    (Y : Finset α) (hY : F.feasible Y) :
    w Y - w (G.seq ⟨0, by omega⟩) ≤
      descentEnergy F w G + K * ((Y \ G.seq ⟨G.len, by omega⟩).card : ℝ) := by
  unfold descentEnergy
  nlinarith [exchange_localMax_gap_bound F w K hVE h_maximal hY]

/-! ## Section 12: Weight Gap via Exchange Diameter (Cross-Domain Bridge) -/

/-
**Cross-domain theorem**: Weight gap bounded by K times exchange diameter.

For any exchange-local maximum B and feasible Y, the weight gap satisfies:
  `w(Y) - w(B) ≤ K * D`
where D bounds the symmetric difference cardinality (exchange diameter).

This theorem bridges three domains:
- **Combinatorial optimization**: the gap `w(Y) - w(B)` measures approximation quality
- **Graph theory**: D is the diameter of the exchange graph
- **Algebra**: K is determined by the coefficient structure of generating polynomials

The practical consequence: if a matroid-like structure has small exchange constant K
and small diameter D, then any exchange-local optimum is a good approximation to the
global optimum, certifying the quality of polynomial-time local search algorithms.
-/
theorem weight_gap_from_localMax_diameter
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ)
    (hVE : ValuatedExchangeBound F w K)
    (D : ℕ)
    (h_diam : ∀ B₁ B₂, F.feasible B₁ → F.feasible B₂ → (B₁ \ B₂).card ≤ D)
    (B : Finset α) (hB : IsExchangeLocalMax F w B)
    (Y : Finset α) (hY : F.feasible Y) :
    w Y - w B ≤ K * (D : ℝ) := by
  -- Apply the exchange_localMax_gap_bound theorem to get w Y ≤ w B + K * |Y \ B|.
  have h_gap : w Y ≤ w B + K * ((Y \ B).card : ℝ) := by
    apply exchange_localMax_gap_bound F w K hVE hB hY;
  nlinarith [ show ( Finset.card ( Y \ B ) : ℝ ) ≤ D by exact_mod_cast h_diam Y B hY hB.1, hVE.1 ]

/-! ## Section 13: Monotonicity of Exchange Constant -/

/-
A smaller exchange constant gives a tighter certified bound.
-/
theorem valuated_exchange_mono {F : BaseExchangeFamily α} {w : Finset α → ℝ}
    {K₁ K₂ : ℝ} (h : K₁ ≤ K₂)
    (hVE : ValuatedExchangeBound F w K₁) :
    ValuatedExchangeBound F w K₂ := by
  exact ⟨ by linarith [ hVE.1 ], fun B₁ B₂ hB₁ hB₂ x hx => by obtain ⟨ y, hy, hB₁', hB₂', h ⟩ := hVE.2 hB₁ hB₂ x hx; exact ⟨ y, hy, hB₁', hB₂', by linarith ⟩ ⟩

/-! ## Section 14: Falsifiable Conjecture -/

/-- **Conjecture (Sharp Exchange Bound).**
For exchange families with rank r, the gap bound can be sharpened from
`K * |Y \ B|` to `K * (r - 1)` since at most `r - 1` exchanges are needed
when the symmetric difference is at most r.

This is falsifiable: compute the gap and symmetric difference for all pairs
of bases in random graphic matroids with r ∈ {3, 4, 5, 6} and check whether
the bound `K * (r - 1)` is tight.

**Computational test**: For the uniform matroid U(3,6), enumerate all bases,
compute all exchange constants, and verify `gap ≤ K * 2` for rank 3.

**Status**: Open conjecture. The standard gap bound gives `K * r`. The sharper
bound `K * (r-1)` requires showing that when Y ≠ B with equal cardinality r,
the symmetric difference |Y \ B| ≤ r-1, which is FALSE for disjoint feasible sets.
However, the conjecture may hold for specific matroid classes (graphic, transversal)
where the exchange structure is more constrained. -/
theorem sharp_exchange_gap_conjecture
    (F : BaseExchangeFamily α) (w : Finset α → ℝ) (K : ℝ) (r : ℕ)
    (hVE : ValuatedExchangeBound F w K)
    (h_rank : ∀ B, F.feasible B → B.card = r) (hr : 1 ≤ r) :
    ∀ ⦃B⦄, IsExchangeLocalMax F w B →
      ∀ ⦃Y⦄, F.feasible Y → w Y ≤ w B + K * (r - 1 : ℝ) := by
  -- Open conjecture: the bound K*(r-1) vs K*r. Leave as sorry.
  sorry

end ExchangeConstantOpt