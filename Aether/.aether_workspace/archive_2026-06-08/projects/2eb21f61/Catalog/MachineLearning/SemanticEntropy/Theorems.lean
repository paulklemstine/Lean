/-
# Semantic Entropy Theory: Main Theorems

## Overview

This file proves the core theorems of semantic entropy theory, establishing
that semantic compression (model elimination) forces proof expansion.

### Theorem 1: Chain Length Lower Bound (Entropy Drop Bound)
Any bounded-halving chain from theory S to theory T requires length at least
`Nat.log 2 (S.models.card / T.models.card)`.

### Theorem 2: Coordinate Theory Exact Counting
For bitstring theories with `k` fixed coordinates out of `n`, the model count
is exactly `2^(n-k)`, giving exact entropy formulas.

### Theorem 3: Graph Coloring Monotonicity
Adding edges to a graph can only reduce the set of proper colorings,
so semantic entropy is monotone decreasing under edge addition.

### Theorem 4: Strengthening Monotonicity of Entropy
Strengthening a theory can only decrease its semantic entropy.

### Theorem 5: Algorithmic Model Count Verification
Verified computation connecting model count to semantic entropy.
-/

import Speculative.SemanticEntropy.Defs

open Finset Real BigOperators FiniteTheory

/-! ## Section 1: Basic Properties -/

/-- Strengthening is reflexive. -/
theorem FiniteTheory.Strengthens.refl {α : Type*} (T : FiniteTheory α) :
    T.Strengthens T :=
  Finset.Subset.refl _

/-- Strengthening is transitive. -/
theorem FiniteTheory.Strengthens.trans {α : Type*}
    {T₁ T₂ T₃ : FiniteTheory α}
    (h₁₂ : T₁.Strengthens T₂) (h₂₃ : T₂.Strengthens T₃) :
    T₁.Strengthens T₃ :=
  Finset.Subset.trans h₂₃ h₁₂

/-- Strengthening can only decrease model count. -/
theorem FiniteTheory.modelCount_mono {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} (h : S.Strengthens T) :
    T.modelCount ≤ S.modelCount :=
  Finset.card_le_card h

/-
Semantic entropy is monotone under strengthening:
    if T strengthens S, then H(T) ≤ H(S).
-/
theorem FiniteTheory.semanticEntropy_mono {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} (h : S.Strengthens T) :
    T.semanticEntropy ≤ S.semanticEntropy := by
  by_cases hS : S.models.card = 0 <;> by_cases hT : T.models.card = 0 <;> simp_all +decide [ semanticEntropy ];
  · exact False.elim ( hT ( Finset.eq_empty_of_forall_notMem fun x hx => by simpa [ hS ] using h hx ) );
  · exact Real.logb_nonneg ( by norm_num ) ( mod_cast Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty hS ) );
  · gcongr <;> norm_cast;
    exact Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty hT )

/-! ## Section 2: Chain Length Lower Bound -/

/-
**Key inductive lemma**: After `j` steps of a bounded-halving chain starting
    from S, the model count is at least `S.models.card / 2^j`.
    More precisely, `S.models.card ≤ 2^j * chain(j).models.card`.
-/
theorem chain_card_bound {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} {k : ℕ}
    (C : BoundedHalvingChain S T k)
    (j : Fin (k + 1)) :
    S.models.card ≤ 2 ^ j.val * (C.chain j).models.card := by
  induction' j using Fin.induction with j ih;
  · have := C.start; aesop;
  · have := C.halving j;
    norm_num [ pow_succ' ] at * ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) j ]

/-
**Theorem 1 (Entropy Drop Lower Bound):**
    Any bounded-halving chain from S to T has length at least
    `Nat.log 2 (S.models.card / T.models.card)`.

    This is the fundamental semantic entropy / proof length inequality:
    proof length is forced by the geometry of model elimination.
-/
theorem chain_length_ge_entropy_drop {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} {k : ℕ}
    (C : BoundedHalvingChain S T k)
    (hT : 0 < T.models.card) :
    Nat.log 2 (S.models.card / T.models.card) ≤ k := by
  have := C.stop;
  refine' Nat.le_trans ( Nat.log_mono_right <| Nat.div_le_div_right _ ) _;
  exact 2 ^ k * T.models.card;
  · convert chain_card_bound C ⟨ k, Nat.lt_succ_self k ⟩ ; aesop;
  · rw [ Nat.mul_div_cancel _ hT, Nat.log_pow ] ; norm_num

/-! ## Section 3: Coordinate Theory Exact Counting -/

/-
**Lemma**: The coordinate theory with no constraints has all `2^n` models.
-/
theorem coordTheory_empty_card (n : ℕ) :
    (coordTheory n ∅).models.card = 2 ^ n := by
  unfold coordTheory; aesop;

/-
**Lemma**: Coordinate constraint theories are monotone under set inclusion:
    more constraints means fewer models.
-/
theorem coordTheory_models_mono (n : ℕ) {A B : Finset (Fin n)}
    (h : A ⊆ B) :
    (coordTheory n B).models ⊆ (coordTheory n A).models := by
  -- By definition of coordTheory, if f is in the models of B, then for all i in B, f i is true.
  intro f hf
  simp [coordTheory] at hf ⊢
  aesop

/-
**Theorem 2 (Coordinate Theory Exact Count):**
    For `A ⊆ Fin n` with `|A| ≤ n`, the coordinate theory has exactly `2^(n - |A|)` models.

    This is the canonical "toy universe" where semantic entropy exactly measures
    strengthening depth: each independent constraint removes exactly 1 bit of entropy.
-/
theorem coordTheory_card (n : ℕ) (A : Finset (Fin n)) :
    (coordTheory n A).models.card = 2 ^ (n - A.card) := by
  simp +decide [ coordTheory ];
  -- We can count the number of functions by considering the number of ways to assign values to the elements not in A.
  have h_count : Finset.card (Finset.filter (fun f : Fin n → Bool => ∀ i ∈ A, f i = true) (Finset.univ : Finset (Fin n → Bool))) = Finset.card (Finset.image (fun f : { i : Fin n // i ∉ A } → Bool => fun i => if h : i ∈ A then true else f ⟨i, h⟩) (Finset.univ : Finset ({ i : Fin n // i ∉ A } → Bool))) := by
    congr with f;
    simp +zetaDelta at *;
    exact ⟨ fun h => ⟨ fun i => f i, funext fun i => by aesop ⟩, by rintro ⟨ a, rfl ⟩ i hi; aesop ⟩;
  rw [ h_count, Finset.card_image_of_injective ];
  · simp +decide [ Finset.card_univ ];
  · intro f g hfg; ext i; replace hfg := congr_fun hfg i; aesop;

/-
**Corollary**: Semantic entropy of coordinate theories equals `n - |A|`.
-/
theorem coordTheory_entropy (n : ℕ) (A : Finset (Fin n))
    (_hA : A.card ≤ n) :
    (coordTheory n A).semanticEntropy = (n - A.card : ℕ) := by
  have h_card : (coordTheory n A).models.card = 2 ^ (n - A.card) := by
    convert coordTheory_card n A;
  unfold FiniteTheory.semanticEntropy;
  rw [ h_card, Nat.cast_pow, Real.logb, Real.log_pow ] ; norm_num

/-
**Theorem (Entropy Drop for Coordinate Theories):**
    Adding `|B| - |A|` independent constraints drops entropy by exactly that amount.
-/
theorem coordTheory_entropy_drop (n : ℕ) {A B : Finset (Fin n)}
    (h : A ⊆ B) (hB : B.card ≤ n) :
    (coordTheory n A).semanticEntropy - (coordTheory n B).semanticEntropy
    = ((B.card - A.card : ℕ) : ℝ) := by
  rw [ coordTheory_entropy, coordTheory_entropy, Nat.cast_sub, Nat.cast_sub ] <;> norm_num;
  · rw [ Nat.cast_sub ( Finset.card_le_card h ) ];
  · assumption;
  · exact le_trans ( Finset.card_le_card h ) hB;
  · assumption;
  · exact le_trans ( Finset.card_le_card h ) hB

/-! ## Section 4: Graph Coloring Monotonicity -/

/-
**Theorem 3 (Graph Coloring Monotonicity):**
    Adding edges to a graph can only reduce the set of proper colorings.
    This connects proof complexity to graph coloring / partition functions:
    proof burden tracks free-energy loss in constrained combinatorial systems.
-/
theorem coloring_mono_edge {V : Type*} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hGH : ∀ u v, G.Adj u v → H.Adj u v) (q : ℕ) :
    (coloringTheory H q).models ⊆ (coloringTheory G q).models := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, fun u v huv => Finset.mem_filter.mp hx |>.2 u v ( hGH u v huv ) ⟩

/-
Coloring monotonicity implies semantic entropy monotonicity.
-/
theorem coloring_entropy_mono {V : Type*} [Fintype V] [DecidableEq V]
    (G H : SimpleGraph V) [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hGH : ∀ u v, G.Adj u v → H.Adj u v) (q : ℕ) :
    (coloringTheory H q).semanticEntropy ≤ (coloringTheory G q).semanticEntropy := by
  convert FiniteTheory.semanticEntropy_mono _;
  · infer_instance;
  · exact coloring_mono_edge G H hGH q

/-! ## Section 5: Algorithmic Model Count -/

/-- Compute the model count of a finite theory (verified computation). -/
def computeModelCount {α : Type*} [DecidableEq α] (T : FiniteTheory α) : ℕ :=
  T.models.card

/-- The computed model count equals the semantic model count. -/
theorem computeModelCount_correct {α : Type*} [DecidableEq α]
    (T : FiniteTheory α) :
    computeModelCount T = T.modelCount :=
  rfl

/-- **Verified entropy lower bound checker:**
    Given a chain length `k` and model counts for start/end theories,
    verify the entropy drop lower bound holds. -/
def checkEntropyBound (startCount endCount k : ℕ) : Bool :=
  Nat.log 2 (startCount / endCount) ≤ k

/-
The entropy bound checker is sound: if it returns false, the chain is too short.
-/
theorem checkEntropyBound_sound {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} {k : ℕ}
    (C : BoundedHalvingChain S T k)
    (hT : 0 < T.models.card) :
    checkEntropyBound S.models.card T.models.card k = true := by
  convert chain_length_ge_entropy_drop C hT using 1;
  unfold checkEntropyBound; aesop;

/-! ## Section 6: Elimination Cost Properties -/

/-
The elimination cost is the complement of the retained models.
-/
theorem eliminationCost_add_card {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} (h : S.Strengthens T) :
    S.eliminationCost T + T.models.card = S.models.card := by
  convert Finset.card_sdiff_add_card_eq_card ( show T.models ⊆ S.models from h )

/-
Elimination cost is zero iff the theories have the same models.
-/
theorem eliminationCost_eq_zero_iff {α : Type*} [DecidableEq α]
    {S T : FiniteTheory α} (h : S.Strengthens T) :
    S.eliminationCost T = 0 ↔ S.models = T.models := by
  constructor <;> intro h <;> simp_all +decide [ Finset.ext_iff ];
  · simp_all +decide [ FiniteTheory.eliminationCost, Finset.ext_iff ];
    exact fun a => ⟨ h a, fun ha => by have := ‹S.Strengthens T›; exact this ha ⟩;
  · exact Finset.card_eq_zero.mpr ( Finset.sdiff_eq_empty_iff_subset.mpr fun x hx => by aesop )