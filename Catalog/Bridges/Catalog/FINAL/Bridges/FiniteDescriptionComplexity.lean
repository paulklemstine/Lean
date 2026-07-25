/-
# Finite Description Complexity: A Compression Barrier for Shallow Computation

This module formalizes a **finite incompressibility toolkit** — exact counting theorems
that serve as certified lower-bound engines for resource-bounded computation.

## Central Idea

Given an encoder `E : Fin N → α`, the "description complexity" of an element `x : α`
relative to `E` is the least index `i` such that `E i = x`. We prove:

1. **Counting bound**: The number of outputs reachable by codes of index ≤ k is at most k+1.
2. **Incompressibility existence**: If a set has more than k+1 elements, some element
   requires a code of index > k.
3. **Collision theorem**: If the codomain is too small relative to the code budget,
   distinct codes must collide.
4. **Binary-code version**: A Kolmogorov-style bound for encoders indexed by bitstrings.

These are finite, exact analogues of classical Kolmogorov complexity counting arguments,
formalized without any appeal to Turing machines or prefix-free codes.

## Applications

- Circuit lower bounds: shallow circuits (bounded-depth families) cannot realize too many
  distinct functions unless the circuit catalog is itself large.
- Learning theory: hypothesis classes with bounded description length have bounded
  cardinality, linking to sample compression and VC theory.
- Cryptographic entropy: random elements of large spaces are necessarily incompressible
  relative to any small encoder.

## Mathematical Content

All proofs use only elementary Finset combinatorics. The key insight is that
`Finset.card_image_le` (the image of a set under any map has at most as many elements
as the set itself) combines with counting the initial segment `{i : Fin N | i.val ≤ k}`
to yield sharp bounds.
-/

import Mathlib

open Finset

/-! ## Definition: Bounded Description Complexity -/

/-- An element `x : α` has description complexity at most `k` relative to encoder `E`
if there exists a code `i : Fin N` with `i.val ≤ k` that maps to `x`. -/
def hasDescComplexityLE {α : Type*} [DecidableEq α] {N : ℕ}
    (E : Fin N → α) (k : ℕ) (x : α) : Prop :=
  ∃ i : Fin N, i.1 ≤ k ∧ E i = x

instance {α : Type*} [DecidableEq α] {N : ℕ} (E : Fin N → α) (k : ℕ) :
    DecidablePred (hasDescComplexityLE E k) := by
  intro x; unfold hasDescComplexityLE; exact Fintype.decidableExistsFintype

/-! ## Core Counting Lemma -/

/-
The number of elements of `Fin N` with value at most `k` is at most `k + 1`.
This is the key combinatorial fact underlying all description complexity bounds.
-/
lemma card_filter_fin_le (N k : ℕ) :
    (Finset.univ.filter fun i : Fin N => i.1 ≤ k).card ≤ k + 1 := by
  by_contra h;
  -- The set {i : Fin N | i.val ≤ k} injects into {0, 1, ..., k} which has k+1 elements.
  have h_inj : Finset.card (Finset.image (fun i : Fin N => i.val) (Finset.filter (fun i : Fin N => i.val ≤ k) Finset.univ)) ≤ k + 1 := by
    exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun i hi => Finset.mem_Icc.mpr ⟨ Nat.zero_le _, Finset.mem_filter.mp hi |>.2 ⟩ ) ( by simp +arith +decide );
  exact h ( le_trans ( by rw [ Finset.card_image_of_injective _ fun i j hij => by aesop ] ) h_inj )

/-! ## Theorem 1: Finite Description Counting Bound -/

/-
**Counting bound for shallow descriptions.**
The number of distinct outputs produced by codes of index at most `k` is at most `k + 1`.
This is the foundational cardinality theorem: shallow descriptions cannot generate
more distinct objects than there are codes.
-/
theorem card_image_initial_segment_le
    {α : Type*} [DecidableEq α] {N : ℕ} (E : Fin N → α) (k : ℕ) :
    ((Finset.univ.filter fun i : Fin N => i.1 ≤ k).image E).card ≤ k + 1 := by
  exact le_trans ( Finset.card_image_le ) ( card_filter_fin_le _ _ )

/-! ## Theorem 2: Finite Incompressibility Existence -/

/-
**Finite incompressibility principle.**
If a finite set `S` has more than `k + 1` elements, then some element of `S`
cannot be produced by any code of index at most `k`. This is the finite analogue
of the classical theorem "most strings are incompressible."
-/
theorem exists_not_encoded_by_small_index
    {α : Type*} [Fintype α] [DecidableEq α] {N : ℕ}
    (E : Fin N → α) (S : Finset α) (k : ℕ)
    (hcard : k + 1 < S.card) :
    ∃ x ∈ S, ¬ ∃ i : Fin N, i.1 ≤ k ∧ E i = x := by
  contrapose! hcard;
  exact le_trans ( Finset.card_le_card ( show S ⊆ Finset.image E ( Finset.univ.filter fun i : Fin N => ( i : ℕ ) ≤ k ) from fun x hx => by obtain ⟨ i, hi, rfl ⟩ := hcard x hx; exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ) ) ) ( Finset.card_image_le.trans ( card_filter_fin_le _ _ ) )

/-
**Universe-level incompressibility.**
If the entire type `α` has more than `k + 1` elements, then some element
has no code of index at most `k` under any encoder `E : Fin N → α`.
-/
theorem finite_incompressibility_univ
    {α : Type*} [Fintype α] [DecidableEq α] {N k : ℕ}
    (E : Fin N → α)
    (hcard : k + 1 < Fintype.card α) :
    ∃ x : α, ¬ ∃ i : Fin N, i.1 ≤ k ∧ E i = x := by
  simpa using exists_not_encoded_by_small_index E Finset.univ k hcard

/-! ## Theorem 3: Pigeonhole Collision for Shallow Descriptions -/

/-
**Collision theorem for shallow codes.**
If the codomain has fewer than `k + 1` elements, then any encoder must
map two distinct codes in the initial segment to the same output.
This is the finite-depth analogue of pigeonhole lower bounds.
-/
theorem exists_collision_of_card_lt_codes
    {α : Type*} [Fintype α] [DecidableEq α] {N : ℕ}
    (E : Fin N → α) (k : ℕ)
    (h : Fintype.card α < k + 1)
    (hk : k < N) :
    ∃ i j : Fin N, i ≠ j ∧ i.1 ≤ k ∧ j.1 ≤ k ∧ E i = E j := by
  contrapose! h;
  have h_inj_closed : Function.Injective (fun i : Fin (k + 1) => E (Fin.castLE hk (Fin.cast (by linarith) i))) := by
    intro i j hij;
    grind +qlia;
  exact Fintype.card_le_of_injective _ h_inj_closed |> le_trans ( by simp +decide )

/-! ## Subtype Cardinality Version -/

/-
**Subtype cardinality bound for description complexity.**
The number of elements with description complexity at most `k` is at most `k + 1`.
This is the most conceptually faithful bridge to Kolmogorov complexity.
-/
theorem card_setOf_hasDescComplexityLE
    {α : Type*} [Fintype α] [DecidableEq α] {N : ℕ}
    (E : Fin N → α) (k : ℕ) :
    Fintype.card {x : α // hasDescComplexityLE E k x} ≤ k + 1 := by
  convert card_image_initial_segment_le E k using 1;
  refine' Finset.card_bij ( fun x _ => x ) _ _ _ <;> simp +decide [ Finset.mem_image ];
  · exact fun x hx => by obtain ⟨ i, hi, rfl ⟩ := hx; exact ⟨ i, hi, rfl ⟩ ;
  · exact fun a ha => ⟨ a, ha, rfl ⟩

/-! ## Depth-Bounded Family Corollary -/

/-- **Depth-bounded family cardinality bound.**
If `encode` maps circuit/program indices to outputs, and we restrict to
indices of depth at most `k`, then the family of realizable outputs has
cardinality at most `k + 1`.

This models the fundamental limitation: **bounded depth limits representable diversity**.
In circuit complexity, this says a depth-`k` family cannot realize more than `k + 1`
distinct functions without increasing the circuit catalog size.

In the language of Kolmogorov complexity: at most `k + 1` objects have
finite description complexity ≤ `k` relative to any fixed encoder. -/
theorem depth_bounded_family_card_le
    {α : Type*} [DecidableEq α] {N : ℕ}
    (encode : Fin N → α) (k : ℕ) :
    ((Finset.univ.filter fun i : Fin N => i.1 ≤ k).image encode).card ≤ k + 1 :=
  card_image_initial_segment_le encode k

/-! ## Binary-Code Version (Kolmogorov-Style) -/

/-
**Binary-code counting bound.**
For an encoder indexed by `Fin M`, the image has at most `M` elements.
When `M = 2^(k+1) - 1` (the number of binary strings of length ≤ k),
this gives the classical Kolmogorov-style bound: at most `2^(k+1) - 1` objects
have description length at most `k`.
-/
theorem card_image_le_card_domain
    {α : Type*} [DecidableEq α] {M : ℕ} (E : Fin M → α) :
    (Finset.univ.image E).card ≤ M := by
  exact Finset.card_image_le.trans_eq ( Finset.card_fin M )

/-
**Binary incompressibility.**
If the codomain has more elements than the domain `Fin M`,
some element has no code at all. When `M = 2^(k+1) - 1`, this says
most objects in a large enough space have no description of bitlength ≤ k.
-/
theorem exists_not_in_range_of_card_gt
    {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}
    (E : Fin M → α)
    (h : M < Fintype.card α) :
    ∃ x : α, ∀ i : Fin M, E i ≠ x := by
  contrapose! h;
  exact le_trans ( Fintype.card_le_of_surjective _ ( fun x => by obtain ⟨ i, hi ⟩ := h x; exact ⟨ i, hi ⟩ ) ) ( by simp +decide )