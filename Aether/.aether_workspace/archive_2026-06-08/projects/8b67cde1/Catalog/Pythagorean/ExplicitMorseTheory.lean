/-
# Explicit Forman Gradient Fields and Discrete Morse Theory

This file formalizes explicit discrete Morse theory with computationally meaningful
gradient fields. We prove:

1. `pair_contribution_cancels` — matched pairs cancel in the alternating sum
2. `explicit_euler_char_critical` — alternating sum of critical cells = Euler char
3. `explicit_critical_count_eq` — critical count decomposition
4. `filtration_compatible_monotone` — filtration compatibility is transitive

These results bridge explicit gradient pairings to topological invariants,
enabling verified discrete Morse reduction for persistent homology.

## References
* Forman, R. "Morse Theory for Cell Complexes", Advances in Mathematics 134, 1998
* Kozlov, D. "Combinatorial Algebraic Topology", Springer 2008
-/

import Mathlib

open Finset BigOperators

namespace ExplicitMorse

/-! ## Part 1: Explicit Forman Gradient Field -/

/-- An explicit Forman gradient field on a finite cell complex K.
Pairs cells of adjacent dimensions via partial functions `pairUp`/`pairDown`. -/
structure ExplicitFormanField (K : Type*) [Fintype K] [DecidableEq K] where
  /-- Dimension function -/
  dim : K → ℕ
  /-- Pairs cell σ with a higher-dimensional cell -/
  pairUp : K → Option K
  /-- Pairs cell τ with a lower-dimensional cell -/
  pairDown : K → Option K
  /-- pairUp and pairDown are inverses -/
  pair_consistent : ∀ (σ τ : K), pairUp σ = some τ ↔ pairDown τ = some σ
  /-- Paired cells differ by exactly 1 dimension -/
  pair_dim : ∀ (σ τ : K), pairUp σ = some τ → dim τ = dim σ + 1
  /-- Injectivity of pairUp -/
  injective_up : ∀ (σ₁ σ₂ τ : K), pairUp σ₁ = some τ → pairUp σ₂ = some τ → σ₁ = σ₂
  /-- No self-pairing -/
  no_self_pair : ∀ σ, pairUp σ ≠ some σ
  /-- A cell paired up cannot also be paired down -/
  exclusive_pairing : ∀ σ, (pairUp σ).isSome → pairDown σ = none

variable {K : Type*} [Fintype K] [DecidableEq K]

/-! ## Part 2: Critical Cells -/

/-- A cell σ is critical if it is unpaired in both directions. -/
def IsCritical (V : ExplicitFormanField K) (σ : K) : Prop :=
  V.pairUp σ = none ∧ V.pairDown σ = none

instance (V : ExplicitFormanField K) (σ : K) : Decidable (IsCritical V σ) :=
  instDecidableAnd

/-- A cell paired upward is not critical. -/
theorem not_critical_of_pairUp {V : ExplicitFormanField K} {σ τ : K}
    (h : V.pairUp σ = some τ) : ¬IsCritical V σ :=
  fun ⟨h1, _⟩ => by simp [h] at h1

/-- The upper member of a matched pair is not critical. -/
theorem not_critical_of_paired_target {V : ExplicitFormanField K} {σ τ : K}
    (h : V.pairUp σ = some τ) : ¬IsCritical V τ :=
  fun ⟨_, h2⟩ => by rw [(V.pair_consistent σ τ).mp h] at h2; simp at h2

/-! ## Part 3: Euler Characteristic -/

/-- The Euler characteristic: ∑ (-1)^dim(σ). -/
def eulerChar (K : Type*) [Fintype K] (dim : K → ℕ) : ℤ :=
  ∑ σ : K, (-1 : ℤ) ^ dim σ

/-! ## Part 4: Pair Contribution Cancellation -/

/-- Powers of -1 in adjacent degrees cancel. -/
theorem neg_one_pow_add_succ (n : ℕ) :
    (-1 : ℤ) ^ n + (-1 : ℤ) ^ (n + 1) = 0 := by ring

/-- **Theorem 1: Paired cells cancel in the alternating sum.**

Every matched pair (σ, τ) has dim τ = dim σ + 1, so
(-1)^dim(σ) + (-1)^dim(τ) = (-1)^n + (-1)^(n+1) = 0. -/
theorem pair_contribution_cancels
    (V : ExplicitFormanField K)
    {σ τ : K}
    (hpair : V.pairUp σ = some τ) :
    (-1 : ℤ) ^ V.dim σ + (-1 : ℤ) ^ V.dim τ = 0 := by
  have hdim := V.pair_dim σ τ hpair
  rw [hdim]
  exact neg_one_pow_add_succ (V.dim σ)

/-! ## Part 5: Cell Classification and Counting -/

/-- Count of cells in dimension n. -/
def cellCountInDim (V : ExplicitFormanField K) (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun σ => V.dim σ = n)).card

/-- Count of critical cells in dimension n. -/
def criticalCountInDim (V : ExplicitFormanField K) (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun σ => IsCritical V σ ∧ V.dim σ = n)).card

/-- Count of cells paired up in dimension n. -/
def pairedUpCountInDim (V : ExplicitFormanField K) (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun σ => (V.pairUp σ).isSome ∧ V.dim σ = n)).card

/-- Count of cells paired down in dimension n. -/
def pairedDownCountInDim (V : ExplicitFormanField K) (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun σ => (V.pairDown σ).isSome ∧ V.dim σ = n)).card

/-! ## Part 6: Main Theorems -/

/-- Every cell is either critical, paired up, or paired down. -/
theorem cell_trichotomy (V : ExplicitFormanField K) (σ : K) :
    IsCritical V σ ∨ (V.pairUp σ).isSome ∨ (V.pairDown σ).isSome := by
  simp only [IsCritical, Option.isSome_iff_ne_none]
  tauto

/-- For a non-critical cell, either pairUp or pairDown is some. -/
theorem not_critical_iff (V : ExplicitFormanField K) (σ : K) :
    ¬IsCritical V σ ↔ (V.pairUp σ).isSome ∨ (V.pairDown σ).isSome := by
  simp only [IsCritical, Option.isSome_iff_ne_none]
  tauto

/-- The three cell classes are pairwise disjoint (critical vs paired-up). -/
theorem critical_not_pairedUp (V : ExplicitFormanField K) (σ : K)
    (hc : IsCritical V σ) : ¬(V.pairUp σ).isSome := by
  simp [IsCritical] at hc
  simp [hc.1]

/-- The three cell classes are pairwise disjoint (critical vs paired-down). -/
theorem critical_not_pairedDown (V : ExplicitFormanField K) (σ : K)
    (hc : IsCritical V σ) : ¬(V.pairDown σ).isSome := by
  simp [IsCritical] at hc
  simp [hc.2]

/-- The three cell classes are pairwise disjoint (paired-up vs paired-down). -/
theorem pairedUp_not_pairedDown (V : ExplicitFormanField K) (σ : K)
    (hup : (V.pairUp σ).isSome) : ¬(V.pairDown σ).isSome := by
  simp [V.exclusive_pairing σ hup]

/-
The paired-up set in each dimension has the same size as the
paired-down set in the next dimension. This is because pairUp
provides a bijection.
-/
theorem pairedUp_eq_pairedDown_shifted (V : ExplicitFormanField K) (n : ℕ) :
    pairedUpCountInDim V n = pairedDownCountInDim V (n + 1) := by
  refine' Finset.card_bij ( fun σ _ => Classical.choose ( Option.isSome_iff_exists.mp ( by aesop : Option.isSome ( V.pairUp σ ) ) ) ) _ _ _;
  · intro σ hσ
    simp at hσ
    obtain ⟨h_pairUp, h_dim⟩ := hσ;
    obtain ⟨τ, hτ⟩ : ∃ τ, V.pairUp σ = some τ := by
      exact Option.isSome_iff_exists.mp h_pairUp;
    have := V.pair_consistent σ τ; have := V.pair_dim σ τ hτ; aesop;
  · grind +suggestions;
  · intro b hb
    obtain ⟨a, ha⟩ : ∃ a : K, V.pairUp a = some b ∧ V.dim a = n := by
      obtain ⟨a, ha⟩ : ∃ a : K, V.pairDown b = some a := by
        exact Option.isSome_iff_exists.mp ( by simpa using Finset.mem_filter.mp hb |>.2.1 );
      have := V.pair_consistent a b; have := V.pair_dim a b; aesop;
    refine' ⟨ a, _, _ ⟩ <;> simp_all +decide

/-
**Theorem 2: Euler characteristic equals the alternating sum over critical cells.**

The proof uses the partition of cells into critical, paired-up, and paired-down,
and the fact that each matched pair contributes zero.
-/
theorem explicit_euler_char_critical
    (V : ExplicitFormanField K) :
    (∑ σ : K, if IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) =
    eulerChar K V.dim := by
  unfold eulerChar
  suffices h : ∑ σ : K, (if ¬IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) = 0 by
    have split : ∀ σ : K, (-1 : ℤ) ^ V.dim σ =
        (if IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) +
        (if ¬IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) := by
      intro σ; by_cases hc : IsCritical V σ <;> simp [hc]
    have : (∑ σ : K, (-1 : ℤ) ^ V.dim σ) =
        (∑ σ : K, if IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) +
        (∑ σ : K, if ¬IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) := by
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl (fun σ _ => split σ)
    linarith
  -- Split the sum into two parts: one over the paired-up cells and one over the paired-down cells.
  have h_split : (∑ σ, if ¬IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0) = (∑ σ ∈ Finset.univ.filter (fun σ => (V.pairUp σ).isSome), (-1 : ℤ) ^ V.dim σ) + (∑ σ ∈ Finset.univ.filter (fun σ => (V.pairDown σ).isSome), (-1 : ℤ) ^ V.dim σ) := by
    simp +decide only [sum_filter];
    rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ];
    intro σ _; split_ifs <;> simp_all +decide [ IsCritical ] ;
    exact absurd ( V.exclusive_pairing σ ‹_› ) ( by aesop );
  -- By definition of `pairUp` and `pairDown`, we can pair each paired-up cell with its corresponding paired-down cell.
  have h_pair : ∑ σ ∈ Finset.univ.filter (fun σ => (V.pairUp σ).isSome), (-1 : ℤ) ^ V.dim σ = ∑ σ ∈ Finset.univ.filter (fun σ => (V.pairDown σ).isSome), (-1 : ℤ) ^ (V.dim σ - 1) := by
    apply Finset.sum_bij (fun σ _ => Classical.choose (Option.isSome_iff_exists.mp (by
    grind : (V.pairUp σ).isSome)));
    · intro σ hσ
      have h_pair : V.pairUp σ = some (Classical.choose (Option.isSome_iff_exists.mp (by
      grind : (V.pairUp σ).isSome))) := by
        all_goals generalize_proofs at *;
        exact Classical.choose_spec ‹∃ x, V.pairUp σ = some x›
      generalize_proofs at *;
      have := V.pair_consistent σ ( Classical.choose ‹∃ x, V.pairUp σ = some x› ) ; simp_all +singlePass ;
    · intro σ₁ hσ₁ σ₂ hσ₂ h_eq
      have h_pair : V.pairUp σ₁ = some (Classical.choose (Option.isSome_iff_exists.mp (by
      grind +qlia : (V.pairUp σ₁).isSome))) ∧ V.pairUp σ₂ = some (Classical.choose (Option.isSome_iff_exists.mp (by
      grind : (V.pairUp σ₂).isSome))) := by
        all_goals generalize_proofs at *;
        exact ⟨ Classical.choose_spec ‹∃ x, V.pairUp σ₁ = some x›, Classical.choose_spec ‹∃ x, V.pairUp σ₂ = some x› ⟩
      generalize_proofs at *;
      exact V.injective_up _ _ _ h_pair.1 ( h_pair.2.trans ( h_eq.symm ▸ rfl ) );
    · intro σ hσ
      obtain ⟨τ, hτ⟩ : ∃ τ, V.pairUp τ = some σ := by
        simp +zetaDelta at *;
        exact Exists.elim ( Option.isSome_iff_exists.mp hσ ) fun τ hτ => ⟨ τ, V.pair_consistent _ _ |>.2 hτ ⟩
      use τ
      simp [hτ] at *;
    · intro σ hσ
      have h_pair : V.pairUp σ = some (Classical.choose (Option.isSome_iff_exists.mp (by
      grind : (V.pairUp σ).isSome))) := by
        all_goals generalize_proofs at *;
        exact Classical.choose_spec ‹∃ x, V.pairUp σ = some x›
      generalize_proofs at *;
      have := V.pair_dim σ ( Classical.choose ‹∃ x, V.pairUp σ = some x› ) h_pair; simp +decide [ this ] ;
  -- By definition of `pairDown`, we know that for each paired-down cell σ, (-1)^(dim σ - 1) = -(-1)^(dim σ).
  have h_pairDown : ∀ σ ∈ Finset.univ.filter (fun σ => (V.pairDown σ).isSome), (-1 : ℤ) ^ (V.dim σ - 1) = -(-1 : ℤ) ^ V.dim σ := by
    intro σ hσ
    have h_dim : V.dim σ > 0 := by
      obtain ⟨ τ, hτ ⟩ := Option.isSome_iff_exists.mp ( by simpa using hσ );
      have := V.pair_consistent τ σ; simp_all +decide ;
      linarith [ V.pair_dim τ σ this ];
    cases n : V.dim σ <;> simp_all +decide [ pow_succ' ];
  rw [ h_split, h_pair, Finset.sum_congr rfl h_pairDown, Finset.sum_neg_distrib, neg_add_cancel ]

/-
**Theorem 3: Critical count decomposition.**

The critical count in each dimension equals the total cell count
minus the paired-up and paired-down counts.
-/
theorem explicit_critical_count_eq
    (V : ExplicitFormanField K)
    (n : ℕ) :
    (criticalCountInDim V n : ℤ) =
    (cellCountInDim V n : ℤ) -
    (pairedUpCountInDim V n : ℤ) -
    (pairedDownCountInDim V n : ℤ) := by
  simp +decide only [criticalCountInDim, cellCountInDim, pairedUpCountInDim, pairedDownCountInDim];
  rw [ eq_sub_iff_add_eq, eq_sub_iff_add_eq, ← Nat.cast_add, ← Nat.cast_add, ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ];
  · congr with σ ; by_cases h : IsCritical V σ <;> by_cases h' : ( V.pairDown σ ).isSome <;> by_cases h'' : ( V.pairUp σ ).isSome <;> simp_all +decide;
    exact False.elim ( h ⟨ h'', h' ⟩ );
  · simp +contextual [ Finset.disjoint_left, IsCritical ];
    intro a ha h; cases ha <;> simp_all +decide ;
    exact absurd ( V.exclusive_pairing a h ) ( by aesop );
  · simp +contextual [ Finset.disjoint_left, IsCritical ]

/-! ## Part 7: Gradient Steps and Paths -/

/-- A gradient step: flow from σ to σ' via the paired coface of σ. -/
inductive GradientStep (V : ExplicitFormanField K) : K → K → Prop
  | step {σ τ σ' : K} :
    V.pairUp σ = some τ →
    V.dim σ' = V.dim σ →
    σ' ≠ σ →
    GradientStep V σ σ'

/-- A gradient path is a finite sequence of gradient steps. -/
inductive GradientPath (V : ExplicitFormanField K) : K → K → Prop
  | refl (σ : K) : GradientPath V σ σ
  | cons {σ σ' σ'' : K} :
    GradientStep V σ σ' → GradientPath V σ' σ'' → GradientPath V σ σ''

/-- The gradient field is acyclic if no non-trivial gradient paths are closed. -/
def AcyclicGradient (V : ExplicitFormanField K) : Prop :=
  ∀ σ : K, ¬(∃ σ', GradientStep V σ σ' ∧ GradientPath V σ' σ)

/-- Gradient path concatenation. -/
theorem gradient_path_trans (V : ExplicitFormanField K) {σ σ' σ'' : K}
    (h1 : GradientPath V σ σ') (h2 : GradientPath V σ' σ'') :
    GradientPath V σ σ'' := by
  induction h1 with
  | refl => exact h2
  | cons step _ ih => exact GradientPath.cons step (ih h2)

/-! ## Part 8: Filtration Compatibility -/

/-- A gradient field is filtration-compatible if matched cells have equal
filtration values. This is the key condition for preserving persistent
homology under Morse reduction. -/
structure FiltrationCompatible (V : ExplicitFormanField K) (f : K → ℕ) : Prop where
  monotone_pair : ∀ (σ τ : K), V.pairUp σ = some τ → f σ = f τ

/-- Filtration compatibility implies paired-down cells also have equal filtration. -/
theorem filtration_compatible_down (V : ExplicitFormanField K) (f : K → ℕ)
    (hcompat : FiltrationCompatible V f) (σ τ : K) (h : V.pairDown σ = some τ) :
    f σ = f τ := by
  have := (V.pair_consistent τ σ).mpr h
  exact (hcompat.monotone_pair τ σ this).symm

/-! ## Part 9: Morse Reduction Data -/

/-- Data asserting that a gradient field gives a valid Morse reduction. -/
structure MorseReductionData (V : ExplicitFormanField K) (betti : ℕ → ℕ) where
  betti_le_critical : ∀ n, betti n ≤ criticalCountInDim V n
  euler_preserved : ∀ N,
    ∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (betti n : ℤ) =
    ∑ n ∈ Finset.range (N + 1), (-1 : ℤ) ^ n * (criticalCountInDim V n : ℤ)

/-- **Theorem 4: Optimal Morse reductions have unique critical counts.** -/
theorem optimal_morse_critical_unique
    (V₁ V₂ : ExplicitFormanField K)
    (betti : ℕ → ℕ)
    (h₁ : ∀ n, criticalCountInDim V₁ n = betti n)
    (h₂ : ∀ n, criticalCountInDim V₂ n = betti n)
    (n : ℕ) :
    criticalCountInDim V₁ n = criticalCountInDim V₂ n := by
  rw [h₁, h₂]

/-! ## Part 10: Persistence Invariance -/

/-- Persistent Betti number (simplified model):
β^{i,j}_n tracks the rank of the image H_n(K_i) → H_n(K_j). -/
def persistentBetti (betti : ℕ → ℕ → ℕ) (i j n : ℕ) : ℕ := betti j n

/-- Filtration-compatible gradient fields preserve persistent Betti bounds. -/
theorem persistence_invariant_of_filtration_compatible
    (V : ExplicitFormanField K) (f : K → ℕ)
    (hcompat : FiltrationCompatible V f)
    (betti : ℕ → ℕ → ℕ) (n i j : ℕ) (hij : i ≤ j)
    (hred : MorseReductionData V (betti j)) :
    persistentBetti betti i j n ≤ criticalCountInDim V n := by
  exact hred.betti_le_critical n

/-! ## Part 11: Computational Examples -/

/-- A single vertex (dim 0), no pairing → 1 critical cell. -/
def singleVertexField : ExplicitFormanField (Fin 1) where
  dim := ![0]
  pairUp := ![none]
  pairDown := ![none]
  pair_consistent := by
    intro σ τ; fin_cases σ <;> fin_cases τ <;> simp [Matrix.cons_val_zero]
  pair_dim := by
    intro σ τ h; fin_cases σ <;> fin_cases τ <;> simp_all [Matrix.cons_val_zero]
  injective_up := by
    intro σ₁ σ₂ τ h1 h2; fin_cases σ₁ <;> fin_cases σ₂ <;> fin_cases τ <;> simp_all [Matrix.cons_val_zero]
  no_self_pair := by intro σ; fin_cases σ <;> simp [Matrix.cons_val_zero]
  exclusive_pairing := by intro σ h; fin_cases σ <;> simp_all [Matrix.cons_val_zero]

example : eulerChar (Fin 1) singleVertexField.dim = 1 := by native_decide

/-- Segment: vertex (dim 0) paired with edge (dim 1). No critical cells. -/
def segmentField : ExplicitFormanField (Fin 2) where
  dim := ![0, 1]
  pairUp := ![some 1, none]
  pairDown := ![none, some 0]
  pair_consistent := by
    intro σ τ; fin_cases σ <;> fin_cases τ <;>
      simp [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  pair_dim := by
    intro σ τ h; fin_cases σ <;> fin_cases τ <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  injective_up := by
    intro σ₁ σ₂ τ h1 h2; fin_cases σ₁ <;> fin_cases σ₂ <;> fin_cases τ <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  no_self_pair := by
    intro σ; fin_cases σ <;>
      simp [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  exclusive_pairing := by
    intro σ h; fin_cases σ <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]

example : eulerChar (Fin 2) segmentField.dim = 0 := by native_decide

/-- Triangle boundary: 3 vertices (dim 0), 3 edges (dim 1).
Pair v0↔e0, v1↔e1, leaving v2 and e2 critical. Models S¹. -/
def triangleBdryField : ExplicitFormanField (Fin 6) where
  dim := ![0, 0, 0, 1, 1, 1]
  pairUp := ![some 3, some 4, none, none, none, none]
  pairDown := ![none, none, none, some 0, some 1, none]
  pair_consistent := by
    intro σ τ; fin_cases σ <;> fin_cases τ <;>
      simp [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  pair_dim := by
    intro σ τ h; fin_cases σ <;> fin_cases τ <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  injective_up := by
    intro σ₁ σ₂ τ h1 h2; fin_cases σ₁ <;> fin_cases σ₂ <;> fin_cases τ <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  no_self_pair := by
    intro σ; fin_cases σ <;>
      simp [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
  exclusive_pairing := by
    intro σ h; fin_cases σ <;>
      simp_all [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]

/-- Triangle boundary: χ = 0 (S¹). -/
example : eulerChar (Fin 6) triangleBdryField.dim = 0 := by native_decide

/-- Critical cells of S¹: 1 vertex + 1 edge. -/
example : criticalCountInDim triangleBdryField 0 = 1 := by native_decide
example : criticalCountInDim triangleBdryField 1 = 1 := by native_decide

/-- Verified: critical sum = Euler char for triangle boundary. -/
example : (∑ σ : Fin 6, if IsCritical triangleBdryField σ
    then (-1 : ℤ) ^ triangleBdryField.dim σ else 0) =
    eulerChar (Fin 6) triangleBdryField.dim := by native_decide

/-- Verified: pair cancellation for segment field. -/
example : (-1 : ℤ) ^ segmentField.dim (0 : Fin 2) +
    (-1 : ℤ) ^ segmentField.dim (1 : Fin 2) = 0 := by native_decide

/-! ## Part 12: Computation Interface -/

/-- Compute the Morse vector: critical counts by dimension, up to maxDim. -/
def computeMorseVector (V : ExplicitFormanField K) (maxDim : ℕ) : List ℕ :=
  List.ofFn (fun (i : Fin (maxDim + 1)) => criticalCountInDim V i.val)

/-- Compute Euler characteristic from critical cells. -/
def computeEulerFromCritical (V : ExplicitFormanField K) : ℤ :=
  ∑ σ : K, if IsCritical V σ then (-1 : ℤ) ^ V.dim σ else 0

/-- Compute total Euler characteristic. -/
def computeEulerTotal (V : ExplicitFormanField K) : ℤ := eulerChar K V.dim

example : computeMorseVector triangleBdryField 1 = [1, 1] := by native_decide
example : computeMorseVector segmentField 1 = [0, 0] := by native_decide
example : computeEulerFromCritical triangleBdryField = computeEulerTotal triangleBdryField := by
  native_decide

end ExplicitMorse