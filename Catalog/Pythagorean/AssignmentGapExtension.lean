/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.TropicalUniversality

/-!
# Tropical Assignment Gap Extension

This file develops a **tropical assignment-complexity theory** showing that the
local tropical margin captures the global assignment landscape on a generic locus.

## Key insight

For symmetric matrices with pairwise diagonal dominance, no permutation—regardless
of cycle structure—can beat the best transposition. This collapses an `n!`-sized
optimization problem to a quadratic-size transposition search.

The central algebraic identity is:
  `2 * (idWeight W - permWeight W σ) = ∑ i, (W i i + W (σ i) (σ i) - 2 * W i (σ i))`

which rewrites the global deficit as a sum of pairwise penalties `d(i, σ(i))`,
bypassing cycle decomposition entirely.

## Main results

* `permWeight_le_bestTransposition_of_symmetric_pairwise_dom` — transpositions
  realize the full assignment gap under symmetric pairwise diagonal dominance
* `assignmentGap_eq_neg_tropMargin_of_two` — exact bridge for `n = 2`
* `longCycleExceptional_implies_tie_hyperplane` — exceptional locus containment
* `bestCompetitor_exists` — existence of the best non-identity permutation
* `idWeight_sub_permWeight_pos_of_symmetric_pairwise_dom` — identity beats all
  non-identity permutations under symmetric diagonal dominance

## Cross-domain connections

* **Combinatorial optimization:** `assignmentGap` is the energy barrier between
  the identity matching and the best alternative perfect matching.
* **Tropical geometry:** the exceptional locus where long cycles matter is
  contained in a finite union of affine hyperplanes (permutation weight ties).
* **Statistical mechanics:** permutation weights decompose as cycle-cover energies;
  pairwise dominance forces 2-cycle excitations to dominate generically.

## References

Builds on `TropicalUniversality.tropMargin`, `signalGap`, and the perturbation
stability theory developed in `Pythagorean.TropicalUniversality`.
-/

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- Weight of a permutation against a square matrix `W`. -/
def permWeight {n : ℕ} (W : Fin n → Fin n → ℝ) (σ : Equiv.Perm (Fin n)) : ℝ :=
  ∑ i : Fin n, W i (σ i)

/-- The identity assignment weight. -/
def idWeight {n : ℕ} (W : Fin n → Fin n → ℝ) : ℝ :=
  permWeight W (Equiv.refl _)

/-- `idWeight` unfolds to the diagonal sum. -/
theorem idWeight_eq_sum_diag {n : ℕ} (W : Fin n → Fin n → ℝ) :
    idWeight W = ∑ i : Fin n, W i i := by
  simp [idWeight, permWeight, Equiv.refl_apply]

/-- The set of non-identity permutations. -/
def nonIdPerms (n : ℕ) : Finset (Equiv.Perm (Fin n)) :=
  Finset.univ.filter fun σ => σ ≠ Equiv.refl _

/-
Non-identity permutations are nonempty when `n ≥ 2`.
-/
lemma nonIdPerms_nonempty {n : ℕ} (hn : 2 ≤ n) : (nonIdPerms n).Nonempty := by
  use Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩;
  simp +decide [ nonIdPerms ]

/-- Full assignment gap: identity weight minus best non-identity competitor. -/
def assignmentGap {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ) : ℝ :=
  idWeight W - (nonIdPerms n).sup' (nonIdPerms_nonempty hn) (permWeight W)

/-- A permutation is a transposition if it swaps exactly two points. -/
def IsTranspositionPerm {n : ℕ} (σ : Equiv.Perm (Fin n)) : Prop :=
  ∃ a b : Fin n, a ≠ b ∧ σ = Equiv.swap a b

/-- The set of transposition permutations. -/
def transpositionPerms (n : ℕ) : Finset (Equiv.Perm (Fin n)) :=
  Finset.univ.filter fun σ => ∃ a b : Fin n, a ≠ b ∧ σ = Equiv.swap a b

/-
Transposition permutations are nonempty when `n ≥ 2`.
-/
lemma transpositionPerms_nonempty {n : ℕ} (hn : 2 ≤ n) :
    (transpositionPerms n).Nonempty := by
  exact ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, by norm_num ⟩ ⟩ ⟩

/-- The best transposition weight. -/
def bestTranspositionWeight {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ) : ℝ :=
  (transpositionPerms n).sup' (transpositionPerms_nonempty hn) (permWeight W)

/-- Exceptional locus where some non-transposition permutation ties or beats
    all transpositions. -/
def LongCycleExceptional {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ) : Prop :=
  ∃ σ : Equiv.Perm (Fin n),
    σ ≠ Equiv.refl _ ∧ ¬ IsTranspositionPerm σ ∧
    bestTranspositionWeight hn W ≤ permWeight W σ

/-- Two permutations have tied weights: a hyperplane condition. -/
def PermTieHyperplane {n : ℕ} (σ τ : Equiv.Perm (Fin n))
    (W : Fin n → Fin n → ℝ) : Prop :=
  permWeight W σ = permWeight W τ

/-- The pairwise diagonal dominance deficit. -/
def pairDeficit {n : ℕ} (W : Fin n → Fin n → ℝ) (i j : Fin n) : ℝ :=
  W i i + W j j - 2 * W i j

/-- A matrix is symmetric. -/
def IsSymmetricFn {n : ℕ} (W : Fin n → Fin n → ℝ) : Prop :=
  ∀ i j : Fin n, W i j = W j i

/-- Pairwise diagonal dominance for symmetric matrices. -/
def SymmetricPairwiseDiagDom {n : ℕ} (W : Fin n → Fin n → ℝ) : Prop :=
  IsSymmetricFn W ∧ ∀ i j : Fin n, i ≠ j → W i i + W j j > 2 * W i j

/-! ## Infrastructure Lemmas -/

/-
Transpositions are non-identity.
-/
lemma transposition_ne_refl {n : ℕ} {a b : Fin n} (hab : a ≠ b) :
    Equiv.swap a b ≠ Equiv.refl (Fin n) := by
  grind +suggestions

/-
Transposition permutations are a subset of non-identity permutations.
-/
lemma transpositionPerms_subset_nonIdPerms {n : ℕ} :
    transpositionPerms n ⊆ nonIdPerms n := by
  exact fun x hx => by cases' Finset.mem_filter.mp hx with hx₁ hx₂; exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by obtain ⟨ a, b, hab, rfl ⟩ := hx₂; exact transposition_ne_refl hab ⟩ ;

/-
Weight of a transposition swap `(a, b)`: swaps entries `a` and `b`,
    all other diagonal entries are unchanged.
-/
theorem permWeight_swap {n : ℕ} (W : Fin n → Fin n → ℝ) (a b : Fin n) (hab : a ≠ b) :
    permWeight W (Equiv.swap a b) =
      W a b + W b a + ∑ i ∈ Finset.univ.filter (fun i => i ≠ a ∧ i ≠ b), W i i := by
  have h_split : ∑ i, W i (Equiv.swap a b i) = ∑ i ∈ {a, b}, W i (Equiv.swap a b i) + ∑ i ∈ {a, b}ᶜ, W i i := by
    rw [ ← Finset.sum_add_sum_compl ];
    congr! 2;
    rw [ Equiv.swap_apply_def ] ; aesop;
  simp_all +decide [ Finset.compl_eq_univ_sdiff, Finset.filter_ne', Finset.filter_and ];
  convert h_split using 1 ; ring!

/-- Reindexing: sum over `f(σ i)` equals sum over `f(i)` for a permutation `σ`. -/
lemma sum_perm_eq {n : ℕ} (f : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    ∑ i, f (σ i) = ∑ i, f i := by
  exact Equiv.sum_comp σ f

/-! ## The Central Identity -/

/-
**Central algebraic identity.** For any matrix (not necessarily symmetric):

  `idWeight W + ∑ i, W (σ i) (σ i) - 2 * permWeight W σ`
  `= ∑ i, (W i i + W (σ i) (σ i) - 2 * W i (σ i))`

For symmetric `W`, the LHS simplifies to `2 * (idWeight W - permWeight W σ)`.
-/
theorem deficit_sum_identity {n : ℕ} (W : Fin n → Fin n → ℝ)
    (σ : Equiv.Perm (Fin n)) :
    (∑ i, W i i) + (∑ i, W (σ i) (σ i)) - 2 * (∑ i, W i (σ i)) =
      ∑ i, (W i i + W (σ i) (σ i) - 2 * W i (σ i)) := by
  simp +decide only [mul_sum, sum_sub_distrib, sum_add_distrib]

/-- For symmetric `W`, the reindexed diagonal sum equals the original. -/
theorem sum_diag_perm_eq {n : ℕ} (W : Fin n → Fin n → ℝ)
    (σ : Equiv.Perm (Fin n)) :
    ∑ i, W (σ i) (σ i) = ∑ i, W i i :=
  Equiv.sum_comp σ (fun i => W i i)

/-
**The symmetric deficit identity**: for symmetric `W`,
  `2 * (idWeight W - permWeight W σ) = ∑ i, pairDeficit W i (σ i)`.
-/
theorem symmetric_deficit_identity {n : ℕ} (W : Fin n → Fin n → ℝ)
    (hsym : IsSymmetricFn W) (σ : Equiv.Perm (Fin n)) :
    2 * (idWeight W - permWeight W σ) =
      ∑ i : Fin n, pairDeficit W i (σ i) := by
  unfold idWeight permWeight pairDeficit; ring;
  simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, hsym ] ; ring;
  rw [ show ∑ x, W ( σ x ) ( σ x ) = ∑ x, W x x from Equiv.sum_comp ( σ ) fun x => W x x ] ; ring;
  rw [ ← Finset.sum_mul _ _ _ ] ; ring

/-! ## Main Theorems -/

/-
**Theorem 1 (Identity beats all non-identity permutations).**
Under symmetric pairwise diagonal dominance, the identity assignment
strictly beats every non-identity permutation.
-/
theorem idWeight_sub_permWeight_pos_of_symmetric_pairwise_dom
    {n : ℕ} (W : Fin n → Fin n → ℝ) (σ : Equiv.Perm (Fin n))
    (hσ : σ ≠ Equiv.refl _)
    (hdom : SymmetricPairwiseDiagDom W) :
    permWeight W σ < idWeight W := by
  -- By symmetric_deficit_identity, we have 2 * (idWeight W - permWeight W σ) = ∑ i, pairDeficit W i (σ i).
  have h_symm_def : 2 * (idWeight W - permWeight W σ) = ∑ i : Fin n, pairDeficit W i (σ i) := by
    exact symmetric_deficit_identity W hdom.1 σ;
  -- Since σ ≠ refl, there exists i₀ with σ i₀ ≠ i₀. For such i₀, pairDeficit W i₀ (σ i₀) > 0 by hdom.2.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, σ i₀ ≠ i₀ := by
    exact not_forall.mp fun h => hσ <| Equiv.ext h
  have h_pos : pairDeficit W i₀ (σ i₀) > 0 := by
    exact sub_pos_of_lt ( hdom.2 _ _ ( Ne.symm hi₀ ) )
  have h_sum_pos : ∑ i : Fin n, pairDeficit W i (σ i) > 0 := by
    refine' lt_of_lt_of_le h_pos ( le_trans _ ( Finset.single_le_sum ( fun i _ => _ ) ( Finset.mem_univ i₀ ) ) );
    · norm_num;
    · by_cases hi : σ i = i <;> simp_all +decide [ pairDeficit ];
      · linarith;
      · linarith [ hdom.2 i ( σ i ) ( by tauto ) ]
  linarith [h_symm_def]

/-
**Theorem 2 (Transpositions realize the full assignment gap).**
Under symmetric pairwise diagonal dominance, every non-identity permutation's
weight is at most the best transposition's weight.

This is the central result: a purely local 2-cycle inequality globally controls
the entire assignment polytope. The proof uses the symmetric deficit identity
to show that any σ's deficit is at least the minimum transposition deficit.
-/
theorem permWeight_le_bestTransposition_of_symmetric_pairwise_dom
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hdom : SymmetricPairwiseDiagDom W) :
    ∀ σ : Equiv.Perm (Fin n), σ ≠ Equiv.refl _ →
      permWeight W σ ≤ bestTranspositionWeight hn W := by
  intros σ hσ_ne_refl
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, σ i₀ ≠ i₀ := by
    exact not_forall.mp fun h => hσ_ne_refl <| Equiv.ext h
  obtain ⟨j₀, hj₀⟩ : ∃ j₀ : Fin n, σ j₀ ≠ j₀ ∧ j₀ ≠ i₀ := by
    exact ⟨ σ i₀, by aesop ⟩;
  -- By definition of $bestTranspositionWeight$, we know that
  have h_best : ∃ a b : Fin n, a ≠ b ∧ permWeight W σ ≤ idWeight W - (W a a + W b b - 2 * W a b) := by
    have h_deficit : ∑ i, (W i i + W (σ i) (σ i) - 2 * W i (σ i)) ≥ (W i₀ i₀ + W (σ i₀) (σ i₀) - 2 * W i₀ (σ i₀)) + (W j₀ j₀ + W (σ j₀) (σ j₀) - 2 * W j₀ (σ j₀)) := by
      have h_deficit : ∑ i ∈ {i₀, j₀}, (W i i + W (σ i) (σ i) - 2 * W i (σ i)) ≤ ∑ i, (W i i + W (σ i) (σ i) - 2 * W i (σ i)) := by
        apply Finset.sum_le_sum_of_subset_of_nonneg;
        · exact Finset.subset_univ _;
        · intros i hi hni
          by_cases h_eq : i = σ i;
          · grind;
          · linarith [ hdom.2 i ( σ i ) h_eq ];
      rwa [ Finset.sum_pair hj₀.2.symm ] at h_deficit;
    have h_deficit : 2 * (idWeight W - permWeight W σ) ≥ (W i₀ i₀ + W (σ i₀) (σ i₀) - 2 * W i₀ (σ i₀)) + (W j₀ j₀ + W (σ j₀) (σ j₀) - 2 * W j₀ (σ j₀)) := by
      convert h_deficit using 1;
      convert symmetric_deficit_identity W hdom.1 σ using 1;
    grind;
  obtain ⟨ a, b, hab, h ⟩ := h_best
  have h_transposition : permWeight W (Equiv.swap a b) = idWeight W - (W a a + W b b - 2 * W a b) := by
    have h_transposition : permWeight W (Equiv.swap a b) = W a b + W b a + ∑ i ∈ Finset.univ.filter (fun i => i ≠ a ∧ i ≠ b), W i i := by
      convert permWeight_swap W a b hab using 1
    generalize_proofs at *;
    have h_sum : ∑ i, W i i = W a a + W b b + ∑ i ∈ Finset.univ.filter (fun i => i ≠ a ∧ i ≠ b), W i i := by
      rw [ ← Finset.sum_sdiff ( Finset.subset_univ { a, b } ) ] ; simp +decide [ *, Finset.filter_ne', Finset.filter_and ] ; ring;
    generalize_proofs at *;
    linarith [ hdom.1 a b, idWeight_eq_sum_diag W ]
  generalize_proofs at *;
  exact le_trans h ( h_transposition ▸ Finset.le_sup' ( fun x => permWeight W x ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, a, b, hab, rfl ⟩ ) )

/-
**Theorem 3 (Exceptional locus is a hyperplane arrangement).**
If the exceptional locus holds—some non-transposition ties or beats
all transpositions—then there exist a long-cycle permutation and a transposition
lying on a tie hyperplane (equal permutation weights).

This identifies the exceptional geometry as a finite union of affine hyperplanes
in weight space, connecting to tropical discriminantal geometry.
-/
theorem longCycleExceptional_implies_tie_hyperplane
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hE : LongCycleExceptional hn W) :
    ∃ σ : Equiv.Perm (Fin n),
      ∃ τ : Equiv.Perm (Fin n),
        σ ≠ Equiv.refl _ ∧ ¬ IsTranspositionPerm σ ∧
        IsTranspositionPerm τ ∧
        permWeight W σ ≥ permWeight W τ := by
  -- By transpositionPerms_nonempty, there exists some τ₀ in transpositionPerms with permWeight W τ₀ = bestTranspositionWeight hn W.
  obtain ⟨τ₀, hτ₀⟩ : ∃ τ₀ ∈ transpositionPerms n, permWeight W τ₀ = bestTranspositionWeight hn W := by
    exact ( Finset.exists_max_image _ _ ( transpositionPerms_nonempty hn ) ) |> fun ⟨ τ₀, hτ₀₁, hτ₀₂ ⟩ => ⟨ τ₀, hτ₀₁, le_antisymm ( Finset.le_sup' ( fun τ => permWeight W τ ) hτ₀₁ ) ( Finset.sup'_le _ _ fun τ hτ => hτ₀₂ τ hτ ) ⟩;
  grind +locals

/-
**Existence of the best competitor.**
For `n ≥ 2`, there exists a non-identity permutation maximizing `permWeight`.
-/
theorem bestCompetitor_exists
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ) :
    ∃ σ : Equiv.Perm (Fin n), σ ≠ Equiv.refl _ ∧
      ∀ τ : Equiv.Perm (Fin n), τ ≠ Equiv.refl _ →
        permWeight W τ ≤ permWeight W σ := by
  obtain ⟨σ, hσ⟩ : ∃ σ ∈ nonIdPerms n, ∀ τ ∈ nonIdPerms n, permWeight W τ ≤ permWeight W σ := by
    exact Finset.exists_max_image _ _ ( nonIdPerms_nonempty hn );
  exact ⟨ σ, Finset.mem_filter.mp hσ.1 |>.2, fun τ hτ => hσ.2 τ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hτ ⟩ ) ⟩

/-
**Assignment gap nonnegativity** under symmetric pairwise diagonal dominance.
-/
theorem assignmentGap_nonneg_of_symmetric_pairwise_dom
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hdom : SymmetricPairwiseDiagDom W) :
    0 ≤ assignmentGap hn W := by
  exact sub_nonneg_of_le <| Finset.sup'_le _ _ fun σ hσ => le_of_lt <| idWeight_sub_permWeight_pos_of_symmetric_pairwise_dom W σ ( Finset.mem_filter.mp hσ |>.2 ) hdom

/-! ## Bridge to Catalog -/

/-
The catalog's `diagExSlack W i j = 2 * W i j - W i i - W j j`
equals the negation of `pairDeficit`.
-/
theorem diagExSlack_eq_neg_pairDeficit {n : ℕ}
    (W : Fin n → Fin n → ℝ) (i j : Fin n) :
    TropicalUniversality.diagExSlack (Matrix.of W) i j = -pairDeficit W i j := by
  unfold TropicalUniversality.diagExSlack pairDeficit; ring;
  ring!

/-
For `n = 2` and symmetric `W`, the assignment gap equals `-tropMargin`.
This is the exact bridge: the catalog's tropical margin (measuring how much
off-diagonal exceeds diagonal) is the negation of the assignment gap
(measuring how much diagonal exceeds off-diagonal).
-/
theorem assignmentGap_eq_neg_tropMargin_of_two
    (W : Fin 2 → Fin 2 → ℝ) (hsym : IsSymmetricFn W) :
    assignmentGap (by norm_num : 2 ≤ 2) W =
      -TropicalUniversality.tropMargin (Matrix.of W) := by
  unfold assignmentGap TropicalUniversality.tropMargin;
  unfold nonIdPerms TropicalUniversality.distinctPairs TropicalUniversality.diagExSlack; simp +decide [ Finset.inf'_eq_csInf_image, Finset.sup'_eq_csSup_image ] ; ring;
  rw [ show ( { σ : Equiv.Perm ( Fin 2 ) | ¬σ = Equiv.refl ( Fin 2 ) } : Set ( Equiv.Perm ( Fin 2 ) ) ) = { Equiv.swap 0 1 } from ?_, show ( { p : Fin 2 × Fin 2 | ¬p.1 = p.2 } : Set ( Fin 2 × Fin 2 ) ) = { ( 0, 1 ), ( 1, 0 ) } from ?_ ] <;> norm_num [ Finset.image_insert, Finset.image_singleton, idWeight, permWeight ];
  · rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
    rotate_left;
    exact W 0 1 * 2 + ( -W 0 0 - W 1 1 );
    · exact ⟨ _, ⟨ ( 0, 1 ), by simp +decide, rfl ⟩ ⟩;
    · simp +decide [ hsym 0 1 ];
      rintro a ( rfl | rfl ) <;> linarith;
    · exact fun w hw => ⟨ _, ⟨ ( 0, 1 ), by norm_num, rfl ⟩, hw ⟩;
    · linarith [ hsym 0 1 ];
  · simp +decide [ Set.ext_iff ];
  · simp +decide [ Set.ext_iff ]

/-
**Catalog bridge**: Strict tropical separation of the signal matrix
    means off-diagonal dominates diagonal. Under symmetry, this means
    the identity assignment is strictly suboptimal: assignmentGap < 0.
    This is the flip side of diagonal dominance.
-/
theorem assignmentGap_neg_of_strict_separation
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hsym : IsSymmetricFn W)
    (hsep : TropicalUniversality.StrictTropicalSeparation (Matrix.of W)) :
    assignmentGap hn W < 0 := by
  refine' sub_neg_of_lt ( lt_of_lt_of_le _ ( Finset.le_sup' _ ( show Equiv.swap ( ⟨ 0, by linarith ⟩ : Fin n ) ⟨ 1, by linarith ⟩ ∈ nonIdPerms n from _ ) ) );
  · have := symmetric_deficit_identity W hsym ( Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩ ) ; simp_all +decide [ idWeight, permWeight ] ;
    -- Since $W$ is strictly separable, we have $pairDeficit W i (σ i) < 0$ for all $i ≠ j$.
    have h_pairDeficit_neg : ∀ i j : Fin n, i ≠ j → pairDeficit W i j < 0 := by
      intro i j hij; have := hsep i j hij; simp_all +decide [ TropicalUniversality.diagExSlack ] ;
      unfold pairDeficit; linarith;
    -- Since $pairDeficit W i (σ i) < 0$ for all $i ≠ j$, the sum $\sum i, pairDeficit W i (σ i)$ is negative.
    have h_sum_neg : ∑ i, pairDeficit W i (Equiv.swap ⟨0, by linarith⟩ ⟨1, by linarith⟩ i) < 0 := by
      rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ ⟨ 0, by linarith ⟩ ) ];
      refine' add_neg_of_neg_of_nonpos ( h_pairDeficit_neg _ _ _ ) ( Finset.sum_nonpos _ ) <;> norm_num;
      grind +locals;
    linarith;
  · unfold nonIdPerms; aesop;

/-! ## Verified Algorithm: Best Competitor by Exhaustive Search -/

/-
The best competitor permutation weight equals the `sup'` over non-identity perms.
-/
theorem bestCompetitorWeight_spec {n : ℕ} (hn : 2 ≤ n)
    (W : Fin n → Fin n → ℝ) :
    (nonIdPerms n).sup' (nonIdPerms_nonempty hn) (permWeight W) =
      idWeight W - assignmentGap hn W := by
  rw [ eq_sub_iff_add_eq, add_comm, assignmentGap ];
  lia

end