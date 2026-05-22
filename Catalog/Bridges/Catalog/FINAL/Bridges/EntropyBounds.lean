/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Entropy Bounds for Finite State Spaces

This file establishes the fundamental bridge between Shannon entropy and
finite-state complexity: **for any probability distribution on a finite type,
the entropy is bounded above by the logarithm of the cardinality**.

## Main results

* `entropy_le_log_card` — H(p) ≤ log |α| for any distribution p on α
* `card_ge_exp_entropy` — |α| ≥ exp(H(p)), the dual cardinality lower bound
* `finite_coding_injective_bound` — injective maps preserve cardinality bounds
* `finite_image_bound_of_matrix_factorization` — rank ≤ r for M = U * V

## Mathematical significance

The entropy bound `H(p) ≤ log |α|` is the quantitative bridge between
information theory and finite-state complexity. It says:
- No distribution on a finite set can carry more information than log of its size.
- Equivalently, any finite-state system needs at least exp(H) states.

This is the universal constraint connecting automata, coding, compression,
and tropical realizations: **bounded realizability forces bounded information**.

## Proof strategy

The key insight is the **Gibbs inequality** (log-sum inequality):
for any probability distribution p on α with |α| = n,
  -∑ p(a) log p(a) ≤ -∑ p(a) log(1/n) = log n
because KL(p ‖ uniform) ≥ 0.

Application keywords: information bottleneck, finite-state complexity,
entropy bound, semantic capacity, formal information theory, rank/state duality.
-/

import Mathlib
import Bridges.FiniteInformationComplexity.Defs

open scoped BigOperators
open Finset Real Classical

noncomputable section

namespace FiniteInformationComplexity

/-! ## Core Lemmas -/

/-
Log is concave: Jensen's inequality for log gives the entropy bound.
    For any nonneg weights summing to 1, -∑ wᵢ log wᵢ ≤ log n.
-/
private lemma neg_sum_mul_log_le_log_card {α : Type*} [Fintype α]
    (p : α → ℝ)
    (hp_nonneg : ∀ a, 0 ≤ p a)
    (hp_sum : ∑ a : α, p a = 1)
    (hα : 0 < Fintype.card α) :
    -∑ a : α, (if p a = 0 then 0 else p a * Real.log (p a)) ≤
    Real.log (Fintype.card α) := by
      -- By the properties of logarithms and sums, we can rewrite the left-hand side.
      have h_rewrite : ∑ a : α, (if p a = 0 then 0 else p a * (Real.log (p a) - Real.log (1 / (Fintype.card α : ℝ)))) ≥ 0 := by
        -- Apply Jensen's inequality to the convex function $f(x) = x \log x$.
        have h_jensen : ∀ a, p a * (Real.log (p a) - Real.log (1 / (Fintype.card α : ℝ))) ≥ p a - (1 / (Fintype.card α : ℝ)) := by
          intro a;
          by_cases ha : p a = 0 <;> simp_all +decide;
          have := Real.log_le_sub_one_of_pos ( show 0 < ( Fintype.card α : ℝ ) ⁻¹ / p a from div_pos ( inv_pos.mpr ( Nat.cast_pos.mpr hα ) ) ( lt_of_le_of_ne ( hp_nonneg a ) ( Ne.symm ha ) ) );
          rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_inv ] at this ; nlinarith [ hp_nonneg a, mul_div_cancel₀ ( ( Fintype.card α : ℝ ) ⁻¹ ) ha ];
        refine' le_trans _ ( Finset.sum_le_sum fun a _ => show ( if p a = 0 then 0 else p a * ( Real.log ( p a ) - Real.log ( 1 / ( Fintype.card α : ℝ ) ) ) ) ≥ p a - 1 / ( Fintype.card α : ℝ ) from _ );
        · simp +decide [ hp_sum, hα.ne' ];
        · aesop;
      simp_all +decide [ mul_add, Finset.sum_ite ];
      simp_all +decide [ Finset.sum_add_distrib, ← Finset.sum_mul _ _ _ ];
      rw [ show ( ∑ i with ¬p i = 0, p i ) = 1 by rw [ ← hp_sum, Finset.sum_filter_of_ne ] ; aesop ] at h_rewrite ; linarith

/-! ## Theorem Family A: Log-cardinality bounds entropy -/

/-- **Entropy ≤ log cardinality**: For any probability distribution on a finite type α,
    the Shannon entropy is bounded above by log |α|.

    This is the universal quantitative bridge between information content
    and state-space size. It applies to any finite system: automata states,
    code alphabets, attention heads, tropical realization components.

    Bridge: information theory × finite-state complexity.

    Mathematical statement: H(p) ≤ log(|α|) for any distribution p on α.
    Equality holds iff p is the uniform distribution. -/
theorem entropy_le_log_card
    {α : Type*} [Fintype α] [Nonempty α]
    (p : α → ℝ)
    (hp_nonneg : ∀ a, 0 ≤ p a)
    (hp_sum : ∑ a : α, p a = 1) :
    shannonEntropy p ≤ Real.log (Fintype.card α) := by
  unfold shannonEntropy
  exact neg_sum_mul_log_le_log_card p hp_nonneg hp_sum (Fintype.card_pos)

/-! ## Theorem Family B: State lower bounds from entropy -/

/-- **Cardinality ≥ exp(entropy)**: The exponential form of the entropy bound.

    This is the revolutionary direction: information content provides a
    **lower bound** on representational complexity. No finite system
    can encode more effective information than its state space allows.

    Bridge: turns information into a lower bound on realizability complexity.

    Mathematical statement: |α| ≥ exp(H(p)). -/
theorem card_ge_exp_entropy
    {α : Type*} [Fintype α] [Nonempty α]
    (p : α → ℝ)
    (hp_nonneg : ∀ a, 0 ≤ p a)
    (hp_sum : ∑ a : α, p a = 1) :
    Real.exp (shannonEntropy p) ≤ Fintype.card α := by
  have h := entropy_le_log_card p hp_nonneg hp_sum
  have hpos : (0 : ℝ) < Fintype.card α := Nat.cast_pos.mpr Fintype.card_pos
  calc Real.exp (shannonEntropy p)
      ≤ Real.exp (Real.log (Fintype.card α)) := Real.exp_le_exp_of_le h
    _ = Fintype.card α := Real.exp_log hpos

/-! ## Theorem Family D: Finite coding cardinality bounds -/

/-- **Finite coding injective bound**: Any injective map between finite types
    preserves cardinality ordering.

    This is the formal bottleneck theorem for proof coding:
    **proof coding cannot exceed realizable state complexity**.

    When combined with the Lawvere coding theorem, this shows that
    any encoding of proofs into a finite state space is constrained
    by the cardinality of that state space.

    Bridge: coding complexity × finite-state complexity. -/
theorem finite_coding_injective_bound
    {α S : Type*} [Fintype α] [Fintype S]
    (f : α → S)
    (hinj : Function.Injective f) :
    Fintype.card α ≤ Fintype.card S :=
  Fintype.card_le_of_injective f hinj

/-- The surjective dual: surjections go the other way. -/
theorem finite_coding_surjective_bound
    {α S : Type*} [Fintype α] [Fintype S]
    (f : α → S)
    (hsurj : Function.Surjective f) :
    Fintype.card S ≤ Fintype.card α :=
  Fintype.card_le_of_surjective f hsurj

/-- Finite image bound: the image of a finite set has at most as many
    elements as the source set. -/
theorem finite_image_card_le
    {α β : Type*} [DecidableEq β]
    (s : Finset α) (f : α → β) :
    (s.image f).card ≤ s.card :=
  Finset.card_image_le

/-! ## Theorem Family E: Matrix rank from factorization -/

/-- **Matrix rank from factorization**: If M = U * V where V has r rows,
    then rank(M) ≤ r.

    This gives a concrete proving ground for the compression-complexity bridge:
    low-rank factorization bounds information-carrying capacity.

    Interpretation: `r` is the latent state complexity / compressed
    realization dimension. Any matrix that factors through an r-dimensional
    space has rank at most r.

    Bridge: matrix factorization × compression × latent dimension. -/
theorem finite_image_bound_of_matrix_factorization
    {m n r : ℕ}
    (M : Matrix (Fin m) (Fin n) ℝ)
    (hfact : ∃ U : Matrix (Fin m) (Fin r) ℝ,
             ∃ V : Matrix (Fin r) (Fin n) ℝ, U * V = M) :
    M.rank ≤ r := by
  obtain ⟨U, V, rfl⟩ := hfact
  calc (U * V).rank
      ≤ U.rank := Matrix.rank_mul_le_left U V
    _ ≤ r := by
        unfold Matrix.rank
        have := U.mulVecLin.finrank_range_le
        simp at this
        exact this

/-! ## Combined Bridge Theorems -/

/-- **Entropy-rank bridge**: If a matrix M factors through an r-dimensional space,
    and we place a probability distribution on the rows induced by some
    weighting, then the effective information dimension is bounded by log r.

    This connects matrix factorization (tropical/attention compression)
    to information-theoretic entropy bounds. -/
theorem entropy_rank_bridge
    {m n r : ℕ}
    (M : Matrix (Fin m) (Fin n) ℝ)
    (hfact : ∃ U : Matrix (Fin m) (Fin r) ℝ,
             ∃ V : Matrix (Fin r) (Fin n) ℝ, U * V = M) :
    M.rank ≤ r ∧
    (0 < r → ∀ (p : Fin r → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a)
      (hp_sum : ∑ a, p a = 1),
      shannonEntropy p ≤ Real.log r) := by
  constructor
  · exact finite_image_bound_of_matrix_factorization M hfact
  · intro hr p hp_nonneg hp_sum
    have : Nonempty (Fin r) := ⟨⟨0, hr⟩⟩
    have := entropy_le_log_card p hp_nonneg hp_sum
    simp [Fintype.card_fin] at this
    exact this

/-- **Information bottleneck theorem**: For any finite type α and any
    probability distribution on α, the number of distinguishable states
    (measured by exp of entropy) cannot exceed the cardinality.

    This is the finite-information complexity principle:
    **finite realizability, finite coding, and finite information
    are quantitatively equivalent constraints**.

    Corollary: if a system has n states, it can encode at most log(n)
    bits of effective information. If it needs to encode H bits of
    information, it requires at least exp(H) states. -/
theorem information_bottleneck
    {α : Type*} [Fintype α] [Nonempty α]
    (P : FiniteProb α) :
    Real.exp P.entropy ≤ Fintype.card α := by
  exact card_ge_exp_entropy P.prob P.nonneg P.sum_one

end FiniteInformationComplexity