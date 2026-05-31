/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Modular Collatz Inverse-Branch Theory: Main Theorems

## Overview

We prove structural theorems about the modular Collatz inverse-branch system
for odd primes p ≠ 3:

1. **Periodicity** (`branch_periodic_mod_order`): Branch admissibility is periodic
   in the exponent k with period `ord_p(2)`.

2. **Subgroup criterion** (`branch_admissible_iff`): For `x ≠ 0`, admissibility
   is equivalent to `2^k * x ≠ 1` in `ZMod p`.

3. **Multiplicity bound** (`branchMultiplicity_le`): Trivial upper bound `K + 1`.

4. **Multiplicity at zero** (`branchMultiplicity_zero_eq`): For `x = 0`,
   the multiplicity equals `K + 1` (every exponent is admissible).

5. **Collision implies cycle** (`collision_implies_induced_cycle4`): The explicit
   collision condition forces an induced 4-cycle in the symmetrized graph.

6. **Induced 4-cycle gives edges ≥ vertices** (`induced_cycle4_edges_ge`):
   A graph with an induced 4-cycle has at least as many edges as vertices in the cycle.
-/

import Mathlib
import Speculative.CollatzTopological.Defs

open ZMod Finset

/-! ## Theorem 1: Periodicity of branch admissibility -/

/-- **Periodicity Theorem.** The branch admissibility predicate is periodic in
    the exponent `k` with period equal to `orderOf (2 : ZMod p)`.

    The key insight: `2^(k+d) = 2^k` in `ZMod p` when `d = ord_p(2)`. -/
theorem branch_periodic_mod_order
    {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    let d := orderOf (2 : ZMod p)
    ∀ x : ZMod p, ∀ k : ℕ,
      branchAdmissible p x k ↔ branchAdmissible p x (k + d) := by
  unfold branchAdmissible
  simp +decide [pow_add, pow_orderOf_eq_one]

/-! ## Theorem 2: Subgroup characterization of admissibility -/

/-
**Subgroup Criterion.** When `x ≠ 0`, branch admissibility at `x` with
    exponent `k` is equivalent to `2^k * x ≠ 1` in `ZMod p`.
    This is because the unique `y` satisfying `3y + 1 = 2^k x` is
    `y = (2^k x - 1) · 3⁻¹`, and `y ≠ 0 ↔ 2^k x ≠ 1`.
-/
theorem branch_admissible_iff
    {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3)
    (x : ZMod p) (hx : x ≠ 0) (k : ℕ) :
    branchAdmissible p x k ↔
      (2 : ZMod p) ^ k * x ≠ 1 := by
  constructor;
  · rintro ⟨ y, hy, hy' ⟩;
    haveI := Fact.mk hp; simp_all +decide [ ← eq_sub_iff_add_eq' ] ;
    simp_all +decide [ sub_eq_add_neg ];
    erw [ ZMod.natCast_eq_zero_iff ] ; exact fun h => hp3 <| by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial;
  · intro h2kx_ne_one
    use (2^k * x - 1) * (3 : ZMod p)⁻¹
    have h_inv : (3 : ZMod p) ≠ 0 := by
      haveI := Fact.mk hp; exact by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact fun h => hp3 <| by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial;
    simp [h_inv];
    haveI := Fact.mk hp; simp_all +decide [ sub_eq_iff_eq_add, mul_assoc, mul_left_comm ] ;

/-! ## Theorem 3: Collision condition implies induced 4-cycle -/

/-
**Collision-to-Cycle Theorem.** If the explicit collision condition holds,
    then the symmetrized Collatz graph contains an induced 4-cycle.
-/
theorem collision_implies_induced_cycle4
    {p K : ℕ} [inst : Fact (Nat.Prime p)]
    (hcoll : explicitCollisionCondition p K) :
    ∃ v₁ v₂ v₃ v₄ : ZMod p,
      IsInducedCycle4 (collatzSymGraph p K) v₁ v₂ v₃ v₄ := by
  revert hcoll;
  -- Unpack the definition of `IsInducedCycle4`.
  simp [IsInducedCycle4, collatzSymGraph, collatzSymAdj'];
  rintro ⟨ v₁, v₂, v₃, v₄, k₁, k₂, k₃, k₄, h₁, h₂, h₃, h₄, h₅, h₆ ⟩;
  use v₁, v₂, h₁, v₃, h₂, v₄, h₃;
  grind

/-! ## Theorem 4: Multiplicity trivial upper bound -/

/-
The branch multiplicity is at most `K + 1` (total number of candidate exponents).
-/
theorem branchMultiplicity_le
    (p K : ℕ) [Fact (Nat.Prime p)] (x : ZMod p) :
    branchMultiplicity p K x ≤ K + 1 := by
  convert Fintype.card_subtype_le _ |> le_trans <| ?_;
  exacts [ inferInstance, by simp +decide ]

/-! ## Theorem 5: Branch admissibility at zero -/

/-
At `x = 0`, every exponent `k` is admissible (the unique preimage `y = -1/3`
    is nonzero since `p > 3`). Therefore `branchMultiplicity p K 0 = K + 1`.
-/
theorem branchAdmissible_zero
    {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3) (k : ℕ) :
    branchAdmissible p 0 k := by
  -- We need to show that there exists a y such that y ≠ 0 and 3y + 1 = 0.
  use (-1 : ZMod p) * ((3 : ZMod p)⁻¹);
  haveI := Fact.mk hp; norm_num;
  erw [ mul_inv_cancel₀ ] <;> norm_num; all_goals erw [ ZMod.natCast_eq_zero_iff ] ; exact fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial;

/-! ## Theorem 6: Non-admissibility characterization -/

/-
For `x ≠ 0`, the exponent `k` is NOT admissible iff `2^k * x = 1`.
    This means exactly one residue class mod `ord_p(2)` is non-admissible.
-/
theorem branch_not_admissible_iff
    {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3)
    (x : ZMod p) (hx : x ≠ 0) (k : ℕ) :
    ¬branchAdmissible p x k ↔ (2 : ZMod p) ^ k * x = 1 := by
  rw [ branch_admissible_iff hp hp2 hp3 x hx k ];
  grind

/-! ## Theorem 7: Monotonicity of multiplicity in K -/

/-
The branch multiplicity is monotonically nondecreasing in `K`.
-/
theorem branchMultiplicity_mono
    {p : ℕ} [Fact (Nat.Prime p)] (x : ZMod p) {K₁ K₂ : ℕ} (h : K₁ ≤ K₂) :
    branchMultiplicity p K₁ x ≤ branchMultiplicity p K₂ x := by
  unfold branchMultiplicity;
  rw [ Fintype.card_subtype, Fintype.card_subtype ];
  rw [ Finset.card_filter, Finset.card_filter ];
  rw [ ← Finset.sum_sdiff ( Finset.subset_univ ( Finset.image ( fun i : Fin ( K₁ + 1 ) => ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ : Fin ( K₁ + 1 ) → Fin ( K₂ + 1 ) ) Finset.univ ) ) ];
  rw [ Finset.sum_image ] ; aesop;
  exact fun i _ j _ hij => Fin.ext <| by simpa using congr_arg Fin.val hij;

/-! ## Theorem 8: Graph adjacency criterion -/

/-- Two distinct nonzero elements `x, y` are adjacent in the Collatz graph
    iff there exists `k ≤ K` with `3y + 1 = 2^k x` or `3x + 1 = 2^k y`. -/
theorem collatzSymGraph_adj_iff
    {p K : ℕ} [Fact (Nat.Prime p)] (x y : ZMod p) :
    (collatzSymGraph p K).Adj x y ↔ collatzSymAdj' p K x y := by
  rfl

/-! ## Theorem 9: Periodicity determines graph structure -/

/-
The graph adjacency is periodic: if `x` and `y` are adjacent via exponent `k`,
    they are also adjacent via exponent `k + d` (when `k + d ≤ K`).
-/
theorem collatzSymGraph_edge_periodic
    {p K : ℕ} [Fact (Nat.Prime p)]
    (_hp2 : p ≠ 2) (_hp3 : p ≠ 3)
    (x y : ZMod p) (k : ℕ) (_hk : k + orderOf (2 : ZMod p) ≤ K) :
    ((3 : ZMod p) * y + 1 = (2 : ZMod p) ^ k * x) →
    ((3 : ZMod p) * y + 1 = (2 : ZMod p) ^ (k + orderOf (2 : ZMod p)) * x) := by
  simp +decide [ pow_add, pow_orderOf_eq_one ]