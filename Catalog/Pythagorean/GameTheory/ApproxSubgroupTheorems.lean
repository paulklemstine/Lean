/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Growth-or-Control Dichotomy for Finite Groups

This file proves the core theorems of the growth-or-control dichotomy:

## Main Results

* `eq_mul_self_of_small_doubling`: If `A` is a finite subset of a group
  with `1 ∈ A` and `|A · A| ≤ |A|`, then `A · A = A`.
* `subgroup_of_small_doubling_eq`: Under the same hypotheses plus symmetry,
  `A` is a subgroup.
* `strict_growth_of_not_subgroup`: If `A` is symmetric with `1 ∈ A` and
  is not itself a subgroup, then `|A| < |A · A|`.
* `support_walk_grows_of_product_grows`: If `|A · A| > |A|`, then the
  2-step random walk support is strictly larger than the 1-step support.
* `stabilization_is_subgroup`: If `A^k = A^(k+1)` for a symmetric set
  with `1 ∈ A`, then `A^k` is a subgroup.

## Proof Strategy

The core argument for the subgroup theorem is elementary:
1. Since `1 ∈ A`, we have `A ⊆ A · A`.
2. Combined with `|A · A| ≤ |A|`, this gives `A = A · A`.
3. Closure under multiplication and inverses follows immediately.

## References

* Freiman, G. A. — Foundations of a Structural Theory of Set Addition (1973)
* Ruzsa, I. Z. — Generalized arithmetical progressions and sumsets (1994)
* Tao, T. — Product set estimates for non-commutative groups (2008)
-/

import Mathlib
import Pythagorean.ApproxSubgroupDefs

open Finset Pointwise

/-! ## Core Lemma: A ⊆ A · A when 1 ∈ A -/

/-
If `1 ∈ A`, then `A ⊆ A · A`, since every `a ∈ A` can be written as `a · 1`.
-/
theorem subset_mul_of_one_mem {G : Type*} [Group G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A) :
    A ⊆ A * A := by
  exact?

/-
If `A` is a finite subset of a group with `1 ∈ A` and `|A · A| ≤ |A|`,
then `A · A = A`.
-/
theorem eq_mul_self_of_small_doubling {G : Type*} [Group G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A)
    (hmul : (A * A).card ≤ A.card) :
    A * A = A := by
  -- Since $A \subseteq A \cdot A$ and $|A \cdot A| \leq |A|$, we can conclude that $A \cdot A = A$.
  apply Finset.eq_of_subset_of_card_le; exact (by
  exact Finset.eq_of_subset_of_card_le ( subset_mul_of_one_mem A h1 ) hmul ▸ Finset.Subset.refl _); exact (by
  exact Finset.card_le_card fun x hx => Finset.mem_mul.mpr ⟨ x, hx, 1, h1, mul_one x ⟩)

/-! ## Theorem 1: Subgroup from Small Doubling -/

/-
**Theorem 1 (Subgroup from Small Doubling).**
Let `G` be a group and `A` a finite symmetric subset with `1 ∈ A`.
If `|A · A| ≤ |A|`, then `A` is a subgroup of `G`.

The proof:
1. Since `1 ∈ A`, `A ⊆ A · A`, so `|A| ≤ |A · A|`.
2. Combined with `|A · A| ≤ |A|`, we get `A · A = A`.
3. Closure under multiplication: `a, b ∈ A ⟹ a · b ∈ A · A = A`.
4. Closure under inverses: by symmetry.
5. Identity: `1 ∈ A` by hypothesis.
-/
theorem subgroup_of_small_doubling_eq {G : Type*} [Group G] [DecidableEq G]
    [Fintype G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : SymmetricFinset A)
    (hmul : (A * A).card ≤ A.card) :
    ∃ H : Subgroup G, (H : Set G) = ↑A := by
  -- Since $A$ is symmetric and closed under multiplication, it forms a subgroup.
  have h_subgroup : ∀ x ∈ A, ∀ y ∈ A, x * y ∈ A := by
    have := eq_mul_self_of_small_doubling A h1 hmul;
    exact fun x hx y hy => this ▸ Finset.mul_mem_mul hx hy;
  refine' ⟨ { carrier := A, mul_mem' := _, one_mem' := _, inv_mem' := _ }, _ ⟩ <;> aesop

/-! ## Theorem 2: Strict Growth of Non-Subgroups -/

/-
**Theorem 2 (Strict Growth of Non-Subgroups).**
If `A` is a finite symmetric subset of a group with `1 ∈ A`, and `A` is
not a subgroup, then `|A| < |A · A|`.

This is the contrapositive of Theorem 1: failure to be a subgroup
is certified by strict product expansion.
-/
theorem strict_growth_of_not_subgroup {G : Type*} [Group G] [DecidableEq G]
    [Fintype G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : SymmetricFinset A)
    (hnsub : ¬∃ H : Subgroup G, (H : Set G) = ↑A) :
    A.card < (A * A).card := by
  contrapose! hnsub;
  convert subgroup_of_small_doubling_eq A h1 hsym hnsub

/-! ## Theorem 3: Random Walk Support Growth -/

/-
**Theorem 3 (Random Walk Support Growth).**
If `A` is a symmetric generating set of a finite group with `1 ∈ A`
and `|A · A| > |A|`, then the support of the 2-step random walk
is strictly larger than that of the 1-step walk.

This bridges approximate group theory to probability on Cayley graphs:
strict product growth implies strict spreading of the random walk.
-/
theorem support_walk_grows_of_product_grows {G : Type*} [Group G]
    [DecidableEq G] [Fintype G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hgrowth : A.card < (A * A).card) :
    (randomWalkSupport A 1).card < (randomWalkSupport A 2).card := by
  convert hgrowth using 1;
  · unfold randomWalkSupport; simp +decide ;
  · exact congr_arg Finset.card ( by rw [ show randomWalkSupport A 2 = A * A from by rw [ show randomWalkSupport A 2 = A ^ 2 from rfl, pow_two ] ] )

/-! ## Theorem 4: Stabilization implies Subgroup -/

/-
**Theorem 4 (Stabilization implies Subgroup).**
If `A` is a finite symmetric subset with `1 ∈ A` and `A^k = A^(k+1)`
for some `k ≥ 1`, then `A^k` is a subgroup of `G`.

This captures the endpoint of the growth-or-control dichotomy:
product sets either keep growing strictly, or stabilize into
a subgroup.
-/
theorem stabilization_is_subgroup {G : Type*} [Group G] [DecidableEq G]
    [Fintype G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : SymmetricFinset A)
    (k : ℕ) (_hk : k ≥ 1)
    (hstab : A ^ k = A ^ (k + 1)) :
    ∃ H : Subgroup G, (H : Set G) = ↑(A ^ k) := by
  have h_mul : (A ^ k) * (A ^ k) = A ^ k := by
    have h_ind : ∀ m ≥ 0, A ^ (k + m) = A ^ k := by
      intro m hm; induction' m with m ih <;> simp_all +decide [ ← pow_succ', Nat.add_assoc ] ;
      rw [ ← add_assoc, pow_succ, ih, ← hstab ];
      rw [ ← pow_succ, hstab ];
    rw [ ← pow_add, h_ind k ( Nat.zero_le k ) ];
  convert subgroup_of_small_doubling_eq ( A ^ k ) _ _ _;
  · exact?;
  · intro x hx;
    rw [ Finset.mem_pow ] at hx ⊢;
    obtain ⟨ f, rfl ⟩ := hx;
    refine' ⟨ fun i => ⟨ ( f ( Fin.rev i ) ) ⁻¹, hsym _ ( f ( Fin.rev i ) |>.2 ) ⟩, _ ⟩ ; simp +decide [ List.prod_inv_reverse ];
    congr;
    refine' List.ext_get _ _ <;> simp +decide [ Function.comp ];
    grind +splitIndPred;
  · rw [ h_mul ]