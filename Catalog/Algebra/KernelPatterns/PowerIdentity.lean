/-
# Counting tuples by their pattern: `|α| ^ n = ∑ₖ S(n,k) · |α|^(k)`

Every tuple `x : Fin n → α` factors, uniquely, as an equality pattern together with an
*injective* labelling of its blocks by letters of the alphabet.  Formalising that
factorisation gives

* `KernelPattern.card_fiber_patternOf` — the tuples with a prescribed pattern `p` are in
  bijection with the embeddings of the block set of `p` into `α`, hence number
  `|α|^(numBlocks p)` (a falling factorial);
* `KernelPattern.pow_card_eq_sum_stirling2_descFactorial` — summing over the patterns and
  grouping by the block count yields the classical identity
  `|α| ^ n = ∑_{k ≤ n} S(n,k) · |α|·(|α|-1)⋯(|α|-k+1)`,
  the "connection formula" between ordinary powers and falling factorials.

This complements `Algebra.KernelPatterns.Stirling`, where the same numbers `S(n,k)` were
obtained from the recurrence, and it explains the truncation phenomenon of
`Algebra.KernelPatterns.SmallAlphabet`: the terms with `k > |α|` vanish because the falling
factorial does.
-/
import Algebra.KernelPatterns.Core
import Algebra.KernelPatterns.Blocks
import Algebra.KernelPatterns.Stirling

namespace KernelPattern

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α] {n : ℕ}

/-- The blocks of a pattern, as a type. -/
abbrev Blocks (p : Pattern n) : Type := {j : Fin n // p.1 j = j}

theorem card_blocks (p : Pattern n) : Fintype.card (Blocks p) = numBlocks p := by
  rw [Fintype.card_subtype, numBlocks_eq_card_fixed]

/-- A tuple with pattern `p` is the same thing as an injective labelling of the blocks
of `p`. -/
def fiberEquivEmbedding (p : Pattern n) :
    {x : Fin n → α // patternOf x = p} ≃ (Blocks p ↪ α) where
  toFun x := by
    refine ⟨fun j => x.1 j.1, ?_⟩
    intro j j' hjj
    have hcanon : canon x.1 = p.1 := congrArg Subtype.val x.2
    have h : canon x.1 j.1 = canon x.1 j'.1 := (canon_eq_iff x.1 j.1 j'.1).2 hjj
    rw [hcanon, j.2, j'.2] at h
    exact Subtype.ext h
  invFun e := by
    refine ⟨fun i => e ⟨p.1 i, (p.2 i).2⟩, ?_⟩
    apply Subtype.ext
    have hsame : SameKernel (fun i => e ⟨p.1 i, (p.2 i).2⟩) p.1 := by
      intro i j
      constructor
      · intro h
        exact congrArg Subtype.val (e.injective h)
      · intro h
        exact congrArg e (Subtype.ext h)
    rw [patternOf_val, sameKernel_iff_canon_eq.1 hsame, canon_eq_self_of_isPattern p.2]
  left_inv := by
    rintro ⟨x, hx⟩
    apply Subtype.ext
    funext i
    have hcanon : canon x = p.1 := congrArg Subtype.val hx
    show x (p.1 i) = x i
    rw [← hcanon]
    exact apply_canon x i
  right_inv := by
    intro e
    apply Function.Embedding.ext
    rintro ⟨j, hj⟩
    show e ⟨p.1 j, _⟩ = e ⟨j, hj⟩
    congr 1
    exact Subtype.ext hj

/-- The number of tuples over `α` realising a given pattern is a falling factorial. -/
theorem card_fiber_patternOf (p : Pattern n) :
    Fintype.card {x : Fin n → α // patternOf x = p}
      = (Fintype.card α).descFactorial (numBlocks p) := by
  rw [Fintype.card_congr (fiberEquivEmbedding p), Fintype.card_embedding_eq, card_blocks]

/-- **The connection formula**: grouping the tuples over `α` by their equality pattern and
then by the number of blocks expresses `|α| ^ n` in falling factorials, with the Stirling
numbers of the second kind as coefficients. -/
theorem pow_card_eq_sum_stirling2_descFactorial (α : Type*) [Fintype α] [DecidableEq α]
    (n : ℕ) :
    (Fintype.card α) ^ n
      = ∑ k ∈ Finset.range (n + 1), stirling2 n k * (Fintype.card α).descFactorial k := by
  classical
  -- fibre the tuples over their pattern
  have hfib : (Finset.univ : Finset (Fin n → α)).card
      = ∑ p ∈ (Finset.univ : Finset (Pattern n)),
          ((Finset.univ : Finset (Fin n → α)).filter fun x => patternOf x = p).card :=
    Finset.card_eq_sum_card_fiberwise fun x _ => Finset.mem_univ _
  have hterm : ∀ p ∈ (Finset.univ : Finset (Pattern n)),
      ((Finset.univ : Finset (Fin n → α)).filter fun x => patternOf x = p).card
        = (Fintype.card α).descFactorial (numBlocks p) := by
    intro p _
    rw [← card_fiber_patternOf p, Fintype.card_subtype]
  have hcount : (Fintype.card α) ^ n
      = ∑ p ∈ (Finset.univ : Finset (Pattern n)),
          (Fintype.card α).descFactorial (numBlocks p) := by
    rw [← Finset.sum_congr rfl hterm, ← hfib, Finset.card_univ, Fintype.card_fun,
      Fintype.card_fin]
  -- group the patterns by their number of blocks
  have hgroup : ∑ k ∈ Finset.range (n + 1),
        ∑ p ∈ (Finset.univ : Finset (Pattern n)) with numBlocks p = k,
          (Fintype.card α).descFactorial (numBlocks p)
      = ∑ p ∈ (Finset.univ : Finset (Pattern n)),
          (Fintype.card α).descFactorial (numBlocks p) :=
    Finset.sum_fiberwise_of_maps_to
      (fun p _ => Finset.mem_range.2 (Nat.lt_succ_of_le (numBlocks_le p))) _
  rw [hcount, ← hgroup]
  refine Finset.sum_congr rfl fun k _ => ?_
  have hconst : ∀ p ∈ ((Finset.univ : Finset (Pattern n)).filter fun p => numBlocks p = k),
      (Fintype.card α).descFactorial (numBlocks p)
        = (Fintype.card α).descFactorial k := by
    intro p hp
    rw [(Finset.mem_filter.mp hp).2]
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, card_patternWithBlocks, smul_eq_mul]

/-- Specialising the connection formula: over a `k`-letter alphabet the terms with more
than `k` blocks drop out, which is the source of the truncated Stirling rows of
`Algebra.KernelPatterns.SmallAlphabet`. -/
theorem three_pow_four : (3 : ℕ) ^ 4 = ∑ k ∈ Finset.range 5, stirling2 4 k * (3 : ℕ).descFactorial k := by
  have h := pow_card_eq_sum_stirling2_descFactorial (Fin 3) 4
  simpa using h

end KernelPattern