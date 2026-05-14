import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Theorem C: Multi-Head Attention as Product Tropical Semantics

The tropical limit of multi-head attention decomposes componentwise:
each head computes its own tropical attention independently.

This shows multi-head architecture is a product-idempotent computation,
not an arbitrary engineering trick.
-/

noncomputable section

open Finset BigOperators Real

/-
**Theorem C: Headwise factorization.**
    Tropical multi-head attention is computed componentwise:
    `tropMultiHead(V, selectors) r = tropAttnWithSelector (V r) (selectors r)`.
-/
theorem tropical_multihead_componentwise
    {h n d : ℕ}
    (V : Fin h → Matrix (Fin n) (Fin d) ℝ)
    (selectors : Fin h → Fin n → Fin n) :
    tropMultiHead V selectors =
      fun r => tropAttnWithSelector (V r) (selectors r) := by
  aesop

/-
Multi-head tropical attention is idempotent when each head uses constant selectors.
-/
theorem tropMultiHead_idempotent_of_const_selectors
    {h n d : ℕ}
    (V : Fin h → Matrix (Fin n) (Fin d) ℝ)
    (jStars : Fin h → Fin n) :
    let sels := fun r (_ : Fin n) => jStars r
    tropMultiHead (tropMultiHead V sels) sels =
    tropMultiHead V sels := by
  unfold tropMultiHead tropAttnWithSelector; ext; aesop;

end