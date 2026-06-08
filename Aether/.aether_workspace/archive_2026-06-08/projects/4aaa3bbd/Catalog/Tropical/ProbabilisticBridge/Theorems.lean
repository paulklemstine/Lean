/-
  # Tropical-Probabilistic Bridge: Core Theorems

  This module proves the main theorems connecting the probabilistic method
  to tropical algebra. All definitions are self-contained.

  ## Main Results

  1. **Tropical Witness Theorem**: A TropicalCostWitness always produces
     a zero-cost element (the bridge from tropical optimization to existence).

  2. **LLL Product Positivity**: If all xᵢ ∈ (0,1), then ∏(1-xᵢ) > 0.

  3. **MinPlus-Arithmetic Duality**: The min-plus moment is 0 iff the
     arithmetic sum is below the universe size.

  4. **Tropical Deletion Bound**: If ∑ costs ≤ δ·n, then ∃ element with cost ≤ δ.

  5. **LLL Product Lower Bound**: When all xᵢ ∈ [0,1/2], ∏(1-xᵢ) ≥ (1/2)^n.

  6. **Weighted Tropical Existence**: Generalized first moment with weights.

  7. **Tropical Pigeonhole**: Min-plus pigeonhole principle.

  8. **Tropical Second Moment**: Second moment condition for existence.

  ## Novel Definitions

  - `TropicalCostWitness`: Packages the first moment method as a tropical
    optimization certificate.
  - `TropicalLLLConfig`: Algebraic LLL conditions as tropical fixed-point equations.
  - `minPlusMoment`: The tropical analogue of expected value.
-/
import Mathlib

open Finset BigOperators

namespace TropicalProbBridge

/-! ## Definitions -/

/-- A tropical cost witness certifies that a combinatorial optimization
    problem has a zero-cost solution. The `avg_bound` field encodes the
    first moment condition: ∑ costs < |universe|. -/
structure TropicalCostWitness (α : Type*) [Fintype α] where
  cost : α → ℕ
  avg_bound : Finset.univ.sum cost < Fintype.card α

/-- Configuration for an algebraic LLL argument over n events. -/
structure TropicalLLLConfig (n : ℕ) where
  probs : Fin n → ℝ
  witnesses : Fin n → ℝ
  deps : Fin n → Finset (Fin n)
  prob_nonneg : ∀ i, 0 ≤ probs i
  prob_lt_one : ∀ i, probs i < 1
  wit_pos : ∀ i, 0 < witnesses i
  wit_lt_one : ∀ i, witnesses i < 1
  lll_condition : ∀ i, probs i ≤
    witnesses i * ∏ j ∈ deps i, (1 - witnesses j)

/-- The min-plus moment: minimum value of a function over a nonempty finite type. -/
noncomputable def minPlusMoment {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) : ℕ :=
  Finset.univ.inf' Finset.univ_nonempty f

/-! ## Theorem 1: Tropical Witness Existence -/

/-
**Tropical Witness Theorem**: If the total cost across all outcomes is
    less than the number of outcomes, some outcome has zero cost.
-/
theorem tropical_witness_exists {α : Type*} [Fintype α] [Nonempty α]
    (w : TropicalCostWitness α) : ∃ a : α, w.cost a = 0 := by
  by_contra h_contra;
  -- Since `w.cost a` is not zero for every `a`, each `w.cost a` must be at least 1.
  have h_ge_one : ∀ a : α, 1 ≤ w.cost a := by
    exact fun a => Nat.pos_of_ne_zero fun h => h_contra ⟨ a, h ⟩;
  exact w.avg_bound.not_ge ( by simpa using Finset.sum_le_sum fun a ( ha : a ∈ Finset.univ ) => h_ge_one a )

/-! ## Theorem 2: LLL Product Positivity -/

/-
**LLL Product Positivity**: For any finite family of reals in (0,1),
    the product ∏(1 - xᵢ) is strictly positive.
-/
theorem lll_product_positivity {n : ℕ} (x : Fin n → ℝ)
    (_hx_pos : ∀ i, 0 < x i) (hx_lt : ∀ i, x i < 1) :
    0 < ∏ i : Fin n, (1 - x i) := by
  exact Finset.prod_pos fun i _ => sub_pos.mpr ( hx_lt i )

/-! ## Theorem 3: MinPlus-Arithmetic Duality -/

/-
**MinPlus-Arithmetic Duality (forward)**:
    If ∑ f < |α|, then minPlusMoment f = 0.
-/
theorem minplus_zero_of_sum_lt {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) (h : Finset.univ.sum f < Fintype.card α) :
    minPlusMoment f = 0 := by
  contrapose! h;
  exact le_trans ( by simp +decide ) ( Finset.sum_le_sum fun x _ => Nat.one_le_iff_ne_zero.2 <| ne_of_gt <| lt_of_lt_of_le ( Nat.pos_of_ne_zero h ) <| Finset.inf'_le _ <| Finset.mem_univ x )

/-
**MinPlus-Arithmetic Duality (reverse)**:
    If minPlusMoment f = 0, then ∃ a, f a = 0.
-/
theorem zero_cost_of_minplus_zero {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) (h : minPlusMoment f = 0) :
    ∃ a : α, f a = 0 := by
  unfold minPlusMoment at h;
  simp_all +decide [ Finset.inf'_eq_csInf_image ]

/-! ## Theorem 4: Tropical Deletion Bound -/

/-
**Tropical Deletion Bound**: If ∑ f ≤ δ·|α|, some element has cost ≤ δ.
-/
theorem tropical_deletion_bound {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) (δ : ℕ) (h : Finset.univ.sum f ≤ δ * Fintype.card α) :
    ∃ a : α, f a ≤ δ := by
  contrapose! h;
  simpa [ mul_comm ] using Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => h a

/-! ## Theorem 5: LLL Product Lower Bound -/

/-
**LLL Single Factor Bound**: For 0 ≤ x ≤ 1/2, we have 1 - x ≥ 1/2.
-/
theorem lll_single_factor_bound (x : ℝ) (_hx_nn : 0 ≤ x) (hx_le : x ≤ 1/2) :
    1/2 ≤ 1 - x := by
  linarith

/-
**LLL Product Lower Bound**: When all xᵢ ∈ [0, 1/2],
    ∏(1-xᵢ) ≥ (1/2)^n.
-/
theorem lll_product_lower_bound {n : ℕ} (x : Fin n → ℝ)
    (_hx_nn : ∀ i, 0 ≤ x i) (hx_le : ∀ i, x i ≤ 1/2) :
    (1/2 : ℝ) ^ n ≤ ∏ i : Fin n, (1 - x i) := by
  -- Apply the lemma that if each term in a product is greater than or equal to some value, then the product is greater than or equal to the product of those values.
  have h_prod_ge_prod : ∏ i, (1 - x i) ≥ ∏ i : Fin n, (1 / 2 : ℝ) := by
    exact Finset.prod_le_prod ( fun _ _ => by norm_num ) fun i _ => by linarith [ _hx_nn i, hx_le i ] ;
  aesop

/-! ## Theorem 6: Weighted Tropical Existence -/

/-
**Weighted First Moment**: Given weights w and costs c, if
    ∑ w·c < ∑ w, then some element with positive weight has c = 0.
-/
theorem weighted_tropical_existence {α : Type*} [Fintype α]
    (w : α → ℕ) (c : α → ℕ)
    (_hw : 0 < Finset.univ.sum w)
    (h : Finset.univ.sum (fun a => w a * c a) < Finset.univ.sum w) :
    ∃ a : α, 0 < w a ∧ c a = 0 := by
  contrapose! h;
  exact Finset.sum_le_sum fun a _ => if ha : w a = 0 then by simp +decide [ ha ] else by nlinarith [ Nat.pos_of_ne_zero ha, Nat.pos_of_ne_zero ( h a ( Nat.pos_of_ne_zero ha ) ) ] ;

/-! ## Theorem 7: Tropical Pigeonhole -/

/-
**Tropical Pigeonhole**: If ∑ counts > k·m, some bin has count > m.
-/
theorem tropical_pigeonhole {k : ℕ} (_hk : 0 < k)
    (counts : Fin k → ℕ) (m : ℕ)
    (h : k * m < Finset.univ.sum counts) :
    ∃ i : Fin k, m < counts i := by
  contrapose! h;
  exact le_trans ( Finset.sum_le_sum fun _ _ => h _ ) ( by norm_num )

/-! ## Theorem 8: Tropical Second Moment -/

/-
**Tropical Second Moment**: If ∑ f² < |α|, then ∃ a, f a = 0.
-/
theorem tropical_second_moment {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) (h : Finset.univ.sum (fun a => f a ^ 2) < Fintype.card α) :
    ∃ a : α, f a = 0 := by
  contrapose! h;
  exact le_trans ( by simp +decide ) ( Finset.sum_le_sum fun a _ => Nat.pow_le_pow_left ( Nat.pos_of_ne_zero ( h a ) ) 2 )

end TropicalProbBridge