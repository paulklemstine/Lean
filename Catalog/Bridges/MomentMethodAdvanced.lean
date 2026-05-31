/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Advanced Moment Method: Trace Identity and Backtrack-Free Counting

This file contains the deeper results of the moment method framework:
- The trace–closed-walk identity connecting matrix powers to word counting
- The backtrack-free word counting theorem: 4 · 3^(m-1)
- The spectral moment = return probability bridge theorem
- Walk counting via adjacency matrix powers

## Cross-Domain Connections

The trace identity is the noncommutative analogue of Wigner-moment counting
from random matrix theory. The moment kernel is the return probability of a
Markov chain, connecting group expansion to stochastic processes.

## Catalog Leverage

Builds on `Pythagorean.CayleyExpander.MomentMethod` for word evaluation
and closed-word counting infrastructure.
-/
import Mathlib
import Pythagorean.CayleyExpander.MomentMethod

open Finset BigOperators Matrix

/-! ## Adjacency Matrix Walk Counting

We prove that the (g,h) entry of A^m counts length-m walks from g to h.
This is the fundamental bridge between linear algebra and combinatorics. -/

/-
The (g,h) entry of the m-th power of the adjacency matrix counts length-m
    walks from g to h. This is proved by induction on m, with the key step
    being the decomposition of a walk of length m+1 into a first step
    followed by a walk of length m.
-/
theorem adjMatrix_pow_counts_walks
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) (g h : G) :
    (cayleyAdjMatrixTwoGen σ τ ^ m) g h =
      ((Finset.univ.filter fun w : Fin m → GenLetter =>
        evalWord σ τ (List.ofFn w) * g = h).card : ℚ) := by
  induction' m with m ih generalizing g h <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
  · split_ifs <;> simp +decide [ *, Matrix.one_apply ];
  · simp +decide [ cayleyAdjMatrixTwoGen, Finset.sum_mul _ _ _ ];
    rw_mod_cast [ ← Finset.sum_congr rfl fun x _ => ?_ ];
    rotate_left;
    use fun x => Finset.card ( Finset.filter ( fun w : Fin ( m + 1 ) → GenLetter => ( TwoGenCayleyData.mk σ τ ).evalLetter ( w 0 ) * evalWord σ τ ( List.ofFn fun i => w i.succ ) * g = h ∧ evalWord σ τ ( List.ofFn fun i => w i.succ ) * g = x ) Finset.univ );
    · rw [ ← Finset.card_product ];
      refine' Finset.card_bij ( fun w hw => ( fun i => w i.succ, w 0 ) ) _ _ _ <;> simp +decide [ Finset.mem_filter, Finset.mem_product ];
      · grind;
      · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h₁ h₂; ext i; induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
      · intro a b hx hy; use Fin.cons b a; simp_all +decide [ Fin.forall_fin_succ ] ;
        simp +decide [ mul_assoc, hx ];
    · rw [ ← Finset.card_biUnion ];
      · congr with w ; aesop;
      · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun w hw₁ hw₂ => hxy <| by aesop;

/-! ## Trace–Closed-Walk Identity

**Theorem 1 (Main)**: The trace of A^m equals the closed-word count
times |G|. This is the master identity of the moment method. -/

/-
**Trace–Closed-Walk Identity**: The trace of the m-th power of the
    adjacency matrix equals the closed-word count times the group order.
    This identity is the combinatorial skeleton of spectral moment bounds.

    Mathematical statement: tr(A^m) = |G| · N_m(e)

    This uses a multi-step argument:
    1. Diagonal entries of A^m count closed walks starting at each g
    2. By group translation invariance, all diagonal entries are equal
    3. The trace sums |G| identical diagonal entries
-/
theorem trace_pow_eq_closedWordCount
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    Matrix.trace (cayleyAdjMatrixTwoGen σ τ ^ m) =
      ((closedWordCount σ τ m : ℚ) * (Fintype.card G : ℚ)) := by
  convert Finset.sum_congr rfl fun g _ => adjMatrix_pow_counts_walks σ τ m g g;
  simp +decide [ closedWordCount_eq_filter, mul_comm ]

/-! ## Spectral Moment = Return Probability

**Cross-domain bridge theorem**: The normalized trace equals the
moment kernel (return probability). This connects:
- Group expansion (spectral gap) to stochastic processes (mixing)
- Cayley graph combinatorics to random matrix observables
- Quantum channel purity to word counting -/

/-- The normalized adjacency matrix, dividing by degree 4. -/
noncomputable def cayleyAdjMatrixNorm' {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : Matrix G G ℚ :=
  (1 / 4 : ℚ) • cayleyAdjMatrixTwoGen σ τ

/-
**Cross-Domain Bridge**: The m-th spectral moment of the normalized
    Cayley graph equals the return probability of the associated random walk.

    This theorem establishes that:
    (1/|G|) · tr(Ā^m) = μ^{*m}(e)

    where Ā is the normalized adjacency operator and μ is the uniform
    measure on {σ,σ⁻¹,τ,τ⁻¹}. This is the exact parallel to:
    - Wigner moment counting in random matrix theory
    - Purity decay in quantum information
    - Partition function evaluation in statistical mechanics
-/
theorem spectral_moment_eq_return_prob
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    (1 / (Fintype.card G : ℚ)) * Matrix.trace (cayleyAdjMatrixNorm' σ τ ^ m) =
      momentKernel σ τ m := by
  unfold cayleyAdjMatrixNorm' momentKernel;
  convert congr_arg ( fun x : ℚ => ( 1 / ( Fintype.card G : ℚ ) * ( ( 1 / 4 ) ^ m * x ) ) ) ( trace_pow_eq_closedWordCount σ τ m ) using 1 ; ring;
  · rw [ smul_pow, Matrix.trace_smul ] ; norm_num ; ring;
  · field_simp;
    simp +decide [ mul_assoc, ← mul_pow ]

/-! ## Backtrack-Free Word Counting

**Theorem 3**: The number of backtrack-free words of length m (m ≥ 1)
is exactly 4 · 3^(m-1). This isolates the tree-like contribution to
spectral moments—the free-group baseline against which relation-driven
corrections are measured. -/

/-
Helper: the number of letters not equal to a given letter's inverse is 3.
-/
theorem card_ne_inv (a : GenLetter) :
    (Finset.univ.filter fun b : GenLetter => b ≠ a.inv).card = 3 := by
  fin_cases a <;> simp +decide [ Finset.filter_ne' ]

/-
**Backtrack-Free Counting Theorem**: The number of backtrack-free
    words of length m (for m ≥ 1) is exactly 4 · 3^(m-1).

    Proof by induction:
    - Base case m=1: all 4 single-letter words are backtrack-free
    - Inductive step: each backtrack-free word of length m can be extended
      by 3 letters (any letter except the inverse of the last),
      giving 3 · (count for length m) extensions

    This is the combinatorial backbone: it counts the tree-like walks,
    i.e., walks that would never return to the identity on a free group.
-/
theorem card_backtrackFree_words
    (m : ℕ) (hm : 1 ≤ m) :
    (Finset.univ.filter fun w : Fin m → GenLetter =>
      BacktrackFree (List.ofFn w)).card = 4 * 3 ^ (m - 1) := by
  rcases m with ( _ | _ | m ) <;> simp_all +decide;
  induction' m with m ih;
  · simp +arith +decide [ BacktrackFree ];
  · have h_count_succ : ∀ (w : Fin (m + 2) → GenLetter), BacktrackFree (w 0 :: w 1 :: List.ofFn fun i => w i.succ.succ) → #{v : Fin (m + 3) → GenLetter | BacktrackFree (v 0 :: v 1 :: List.ofFn fun i => v i.succ.succ) ∧ (fun i => v i.succ) = w} = 3 := by
      intro w hw
      have h_count_succ : #{v : Fin (m + 3) → GenLetter | v 0 ≠ (w 0).inv ∧ (fun i => v i.succ) = w} = 3 := by
        convert card_ne_inv ( w 0 ) using 1;
        refine' Finset.card_bij ( fun v hv => v 0 ) _ _ _ <;> simp +decide [ funext_iff, Fin.forall_fin_succ ];
        · tauto;
        · aesop;
        · intro b hb; use Fin.cons b ( Fin.cons ( w 0 ) ( Fin.cons ( w 1 ) ( fun i => w i.succ.succ ) ) ) ; aesop;
      convert h_count_succ using 2;
      ext v; simp [BacktrackFree];
      cases hw ; aesop;
    have h_count_succ : #{v : Fin (m + 3) → GenLetter | BacktrackFree (v 0 :: v 1 :: List.ofFn fun i => v i.succ.succ)} = ∑ w ∈ Finset.filter (fun w : Fin (m + 2) → GenLetter => BacktrackFree (w 0 :: w 1 :: List.ofFn fun i => w i.succ.succ)) Finset.univ, #{v : Fin (m + 3) → GenLetter | BacktrackFree (v 0 :: v 1 :: List.ofFn fun i => v i.succ.succ) ∧ (fun i => v i.succ) = w} := by
      rw [ ← Finset.card_biUnion ];
      · congr with v ; simp +decide [ Fin.forall_fin_succ ];
        exact fun h => h.2;
      · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;
    rw [ h_count_succ, Finset.sum_congr rfl fun x hx => ‹∀ w : Fin ( m + 2 ) → GenLetter, BacktrackFree ( w 0 :: w 1 :: List.ofFn fun i => w i.succ.succ ) → Finset.card { v : Fin ( m + 3 ) → GenLetter | BacktrackFree ( v 0 :: v 1 :: List.ofFn fun i => v i.succ.succ ) ∧ ( fun i => v i.succ ) = w } = 3› x <| Finset.mem_filter.mp hx |>.2 ] ; norm_num [ ih, pow_succ' ] ; ring

/-! ## Closed-Word Count equals Subtype Cardinality

This theorem makes explicit the relationship between the filter-based
and subtype-based formulations of closed-word counting. -/

/-- The closed-word count equals the cardinality of the subtype of words
    evaluating to the identity. -/
theorem closedWordCount_eq_card_subtype
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m =
      Fintype.card {w : Fin m → GenLetter // evalWord σ τ (List.ofFn w) = 1} := by
  rfl

/-! ## Moment Kernel Inversion Symmetry -/

/-- The moment kernel is invariant under generator inversion. -/
theorem momentKernel_inv_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    momentKernel σ τ m = momentKernel σ⁻¹ τ⁻¹ m := by
  unfold momentKernel
  rw [closedWordCount_inv_invariant]

/-! ## Moment Kernel Conjugation Invariance -/

/-- The moment kernel is a class function: invariant under conjugation. -/
theorem momentKernel_conj_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ h : G) (m : ℕ) :
    momentKernel (h * σ * h⁻¹) (h * τ * h⁻¹) m = momentKernel σ τ m := by
  unfold momentKernel
  rw [closedWordCount_conj_invariant]

/-! ## Free Group Baseline Values

The free-group return probabilities are the baseline against which
the Random Cayley Expander Conjecture is measured. -/

/-
At length 2 on a free group (no relations), the return probability is 1/4.
    This is because exactly 4 of 16 length-2 words cancel to identity.
-/
theorem free_group_moment_two_lower
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    (1 : ℚ) / 4 ≤ momentKernel σ τ 2 := by
  -- By definition, momentKernel σ τ 2 = closedWordCount σ τ 2 / 16.
  have h_moment_def : momentKernel σ τ 2 = (closedWordCount σ τ 2 : ℚ) / 16 := by
    exact congr_arg _ ( mod_cast rfl );
  exact h_moment_def ▸ by rw [ div_le_div_iff₀ ] <;> norm_cast ; linarith [ show ( closedWordCount σ τ 2 : ℕ ) ≥ 4 by exact_mod_cast closedWordCount_two_ge_four σ τ ] ;

/-! ## evalWord for ofFn -/

/-- evalWord of List.ofFn factors through function evaluation. -/
theorem evalWord_ofFn_succ {G : Type*} [Group G] (σ τ : G)
    (m : ℕ) (w : Fin (m + 1) → GenLetter) :
    evalWord σ τ (List.ofFn w) =
      (TwoGenCayleyData.mk σ τ).evalLetter (w 0) *
        evalWord σ τ (List.ofFn (fun i : Fin m => w i.succ)) := by
  conv_lhs => rw [show List.ofFn w = w 0 :: List.ofFn (fun i : Fin m => w i.succ) from by
    simp [List.ofFn_succ]]
  simp

/-! ## Relationship to Subgroup Generation

This section connects closed walks to the algebraic structure of the
subgroup generated by σ and τ. It builds on
`Pythagorean.CayleyExpander.Connectivity.word_in_generators_of_mem_closure`. -/

/-- Every closed word is a witness that the identity lies in the subgroup
    generated by {σ, σ⁻¹, τ, τ⁻¹}. This is trivially true but establishes
    the bridge from walk counting to group law counting. -/
theorem closed_word_mem_closure
    {G : Type*} [Group G] (σ τ : G) (w : List GenLetter)
    (_hw : evalWord σ τ w = 1) :
    (1 : G) ∈ Subgroup.closure ({σ, σ⁻¹, τ, τ⁻¹} : Set G) := by
  exact Subgroup.one_mem _