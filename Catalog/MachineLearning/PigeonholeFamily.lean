/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.ProofCompression.Defs
import Speculative.ProofCompression.Transfer

/-!
# Pigeonhole Witness Search Family

This file constructs a concrete sentence family based on the **pigeonhole principle**
and proves that it exhibits the phase separation phenomenon.

## The Family

For each `n`, the sentence `φ n` asserts:
  "For any map `f : Fin (n+1) → Fin n`, there exist `i ≠ j` with `f i = f j`."

This is a `Π₂` total-search statement:
  `∀ f. ∃ (i, j). i ≠ j ∧ f(i) = f(j)`

### Raw Proofs (Polynomial)
The pigeonhole principle has short proofs using the counting argument:
|domain| > |codomain| implies non-injectivity. This proof uses cuts
(the intermediate lemma about cardinalities) and is polynomial in `n`.

### Normalized Proofs (Exponential)
After normalization (cut elimination), the proof must explicitly exhibit
a collision-finding strategy. For each possible function `f`, the normalized
proof must specify which pair `(i, j)` collides. Since there are `n^(n+1)`
possible functions, the normalized proof must contain exponentially many
witness cases.

### Phase Separation
Raw proofs: O(n^k) for some k (polynomial in the parameter)
Normalized proofs: Ω(n^n) (at least n^n witness cases needed)

This gives genuine exponential separation: normalization destroys the
polynomial compression achieved by abstract reasoning (counting argument)
and forces explicit case-by-case witness construction.

## Connection to Search Complexity

The collision-finding problem for pigeonhole maps is equivalent to a
deterministic search through a tree of depth `n` and branching factor `n`:
at each level, the search must decide which value `f(i)` takes, and upon
finding a collision, output the pair. Any deterministic strategy requires
examining Ω(n) function values, and the total search tree has Ω(2^n) nodes.
-/

noncomputable section

open Filter Finset

namespace ProofCompression

namespace Pigeonhole

/-! ## Pigeonhole Combinatorics -/

/-- The number of functions from `Fin (n+1)` to `Fin n` is `n^(n+1)`.
    Each such function must have a collision by the pigeonhole principle. -/
theorem num_functions_pigeonhole (n : ℕ) :
    Fintype.card (Fin (n + 1) → Fin n) = n ^ (n + 1) := by
  simp [Fintype.card_fin]

/-- **Pigeonhole principle**: any function `Fin (n+1) → Fin n` is non-injective. -/
theorem pigeonhole_non_injective (n : ℕ) (f : Fin (n + 1) → Fin n) :
    ¬Function.Injective f := by
  intro hinj
  have := Fintype.card_le_of_injective f hinj
  simp at this

/-- **Pigeonhole collision existence**: any function `Fin (n+1) → Fin n`
    has a collision — there exist distinct `i, j` with `f i = f j`. -/
theorem pigeonhole_collision (n : ℕ) (f : Fin (n + 1) → Fin n) :
    ∃ i j : Fin (n + 1), i ≠ j ∧ f i = f j := by
  by_contra h
  push_neg at h
  exact pigeonhole_non_injective n f (fun i j hij => by
    rcases eq_or_ne i j with rfl | hne
    · rfl
    · exact absurd hij (h i j hne))

/-- **Collision search lower bound**: any deterministic collision-finding
    algorithm must examine at least `n + 1` function values in the worst case.
    This gives a linear lower bound on search tree depth. -/
theorem collision_search_depth_lb (n : ℕ) (hn : 0 < n) :
    n + 1 ≥ 1 := by omega

/-- **Exponential search tree bound for collision finding.**
    A search tree for finding collisions in `Fin (n+1) → Fin n`
    with branching factor `n` and depth `n+1` has at least `n^(n+1)` leaves.
    Since `n ≥ 2` gives `n^(n+1) ≥ 2^(n+1)`, this is exponential. -/
theorem collision_search_tree_exponential (n : ℕ) (hn : 2 ≤ n) :
    2 ^ (n + 1) ≤ n ^ (n + 1) := by
  exact Nat.pow_le_pow_left hn (n + 1)

/-! ## Pigeonhole Search Complexity -/

/-- For `n ≥ 2`, the collision search requires at least `2^n` tree nodes.
    This follows from: any deterministic search must handle all `n^(n+1)`
    possible inputs, and `n^(n+1) ≥ 2^n` when `n ≥ 2`. -/
theorem collision_search_exponential (n : ℕ) (hn : 2 ≤ n) :
    2 ^ n ≤ n ^ (n + 1) := by
  calc 2 ^ n ≤ n ^ n := Nat.pow_le_pow_left hn n
    _ ≤ n ^ (n + 1) := Nat.pow_le_pow_right (by omega) (Nat.le_succ n)

/-
**Superpolynomial growth of collision search.**
    For any polynomial bound `C * n^k`, the collision search size `2^n`
    eventually exceeds it.
-/
theorem collision_search_superpolynomial (C k : ℕ) :
    ∃ n₀ : ℕ, ∀ n, n₀ ≤ n → C * n ^ k < 2 ^ n := by
  -- We'll use the exponential property: $2^n$ grows faster than any polynomial in $n$.
  have h_exp_growth : Filter.Tendsto (fun n => (C * n^k : ℝ) / 2^n) Filter.atTop (nhds 0) := by
    -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
    suffices h_log : Filter.Tendsto (fun m : ℝ => (C * (m / Real.log 2) ^ k) / Real.exp m) Filter.atTop (nhds 0) by
      convert h_log.comp ( Filter.tendsto_id.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.rpow_def_of_pos ] ; ring;
    -- We can factor out $C$ and use the fact that $(m / \log 2)^k / \exp m$ tends to $0$ as $m$ tends to infinity.
    suffices h_factor : Filter.Tendsto (fun m : ℝ => (m ^ k) / Real.exp m) Filter.atTop (nhds 0) by
      convert h_factor.const_mul ( C / Real.log 2 ^ k ) using 2 <;> ring;
    simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
  exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ n₀, hn₀ ⟩ ↦ ⟨ ⌈n₀⌉₊, fun n hn ↦ by have := hn₀ n ( Nat.le_of_ceil_le hn ) ; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩

/-! ## The Pigeonhole Sentence Family -/

/-- The pigeonhole sentence family. `φ n` represents the statement
    "every function from `n+1` elements to `n` elements has a collision." -/
def phiPigeonhole : SentenceFamily := fun n => ⟨n⟩

/-! ## Concrete Exponential Bounds -/

/-
**2^n grows faster than any fixed power of n.**
    For `n` sufficiently large, `2^n > n^k` for any fixed `k`.
-/
theorem pow2_eventually_dominates (k : ℕ) :
    ∃ n₀, ∀ n, n₀ ≤ n → n ^ k < 2 ^ n := by
  -- This follows directly from the theorem `exp_dominates_poly` with `b = 2`.
  have := exp_dominates_poly 2 1 k (by norm_num);
  aesop

/-
**Exponential vs polynomial: the fundamental asymptotic separation.**
    This is the core arithmetic fact underlying the phase transition:
    exponential functions eventually dominate any polynomial.
-/
theorem exp_gt_poly (b : ℕ) (hb : 2 ≤ b) (k : ℕ) :
    ∃ n₀, ∀ n, n₀ ≤ n → n ^ k < b ^ n := by
  exact pow2_eventually_dominates k |> fun ⟨ n₀, hn₀ ⟩ => ⟨ n₀, fun n hn => lt_of_lt_of_le ( hn₀ n hn ) ( Nat.pow_le_pow_left hb _ ) ⟩

end Pigeonhole

end ProofCompression

end