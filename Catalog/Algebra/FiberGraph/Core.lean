/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Fiber Graphs Induced by Additive Scoring on Hamming Spaces

This module develops the formal theory of fiber graphs arising from additive
scoring functions on Hamming spaces. Given a product space α^n and an abelian
group G, an additive scoring function S(x) = ∑ᵢ wᵢ(xᵢ) partitions configurations
into fibers {x | S(x) = g}. The fiber graph connects configurations in the same
fiber that differ at exactly one coordinate.

## Main Results

### Score Delta Algebra
* `scoreDelta_antisymm` — δᵢ(a,b) = -δᵢ(b,a)
* `scoreDelta_triangle` — δᵢ(a,b) + δᵢ(b,c) = δᵢ(a,c)
* `score_modify_eq` — S(x[i↦v]) = S(x) + δᵢ(xᵢ,v)
* `total_delta_zero` — for equal-score configs, ∑ᵢ δᵢ(xᵢ,yᵢ) = 0

### Bridge Duality Theorem
* `bridge_duality` — for 2-position difference: bridge through i ↔ bridge through j

### Position Separation Rigidity
* `position_separation_rigidity` — injective weights + 1-position freedom + same score → identical

### Structural Results
* `score_kernel_neg_closed` — the score kernel is closed under negation
* `score_uniform_perm` — uniform weights give permutation-invariant scores
* `double_bridge_impossibility` — injective weights block all bridges at differing positions
* `bridge_preserves_fiber` — bridges preserve fiber membership
* `bridge_chain_fiber` — composing bridges preserves fiber membership
-/
import Mathlib

namespace FiberGraph

open Finset Function

variable {n : ℕ} {α : Type*} {G : Type*} [DecidableEq (Fin n)] [DecidableEq α]

/-! ## Definitions -/

/-- An additive scoring system: a weight function for each position. -/
abbrev WeightSystem (n : ℕ) (α : Type*) (G : Type*) := Fin n → α → G

section Defs
variable [AddCommGroup G]

/-- The additive score: S(x) = ∑ᵢ wᵢ(xᵢ). -/
noncomputable def score (w : WeightSystem n α G) (x : Fin n → α) : G :=
  ∑ i : Fin n, w i (x i)

/-- The score delta at position i when switching from a to b. -/
def scoreDelta (w : WeightSystem n α G) (i : Fin n) (a b : α) : G :=
  w i b - w i a

/-- The fiber of a target score. -/
def fiber (w : WeightSystem n α G) (g : G) : Set (Fin n → α) :=
  {x | score w x = g}

/-- Modify a configuration at one position. -/
def modify (x : Fin n → α) (i : Fin n) (v : α) : Fin n → α :=
  Function.update x i v

/-- The set of disagreement positions. -/
def diffSet (x y : Fin n → α) : Finset (Fin n) :=
  Finset.univ.filter (fun i => x i ≠ y i)

/-- Hamming adjacency: differ at exactly one position. -/
def HammingAdj (x y : Fin n → α) : Prop :=
  (diffSet x y).card = 1

/-- Injective weights at position i. -/
def InjectiveAt (w : WeightSystem n α G) (i : Fin n) : Prop :=
  Function.Injective (w i)

/-- All weights are injective. -/
def AllInjective (w : WeightSystem n α G) : Prop :=
  ∀ i, InjectiveAt w i

/-- Uniform weight system: all positions use the same weight function. -/
def IsUniform (w : WeightSystem n α G) : Prop :=
  ∀ i j : Fin n, w i = w j

/-- The score kernel: achievable delta vectors that sum to zero. -/
def ScoreKernel (w : WeightSystem n α G) : Set (Fin n → G) :=
  {d | (∑ i, d i = 0) ∧ ∀ i, ∃ a b : α, d i = scoreDelta w i a b}

/-- A bridge: modifying position i to value v preserves the score. -/
def IsBridge (w : WeightSystem n α G) (x : Fin n → α) (i : Fin n) (v : α) : Prop :=
  v ≠ x i ∧ score w (modify x i v) = score w x

/-- Bridge existence at a position. -/
def BridgeExists (w : WeightSystem n α G) (x : Fin n → α) (i : Fin n) : Prop :=
  ∃ v, IsBridge w x i v

end Defs

/-! ## Score Delta Algebra -/

section DeltaAlgebra
variable [AddCommGroup G]

/-
The score delta is antisymmetric: δᵢ(a,b) = -δᵢ(b,a).
-/
theorem scoreDelta_antisymm (w : WeightSystem n α G) (i : Fin n) (a b : α) :
    scoreDelta w i a b = -scoreDelta w i b a := by
  -- By definition of scoreDelta, we have:
  simp [scoreDelta]

/-
Triangle identity for score deltas.
-/
theorem scoreDelta_triangle (w : WeightSystem n α G) (i : Fin n) (a b c : α) :
    scoreDelta w i a b + scoreDelta w i b c = scoreDelta w i a c := by
  unfold scoreDelta; abel;

/-
The score delta is zero on the diagonal.
-/
theorem scoreDelta_self (w : WeightSystem n α G) (i : Fin n) (a : α) :
    scoreDelta w i a a = 0 := by
  exact sub_self _

/-
Score of a modified configuration in terms of delta.
-/
theorem score_modify_eq (w : WeightSystem n α G) (x : Fin n → α) (i : Fin n) (v : α) :
    score w (modify x i v) = score w x + scoreDelta w i (x i) v := by
  unfold score scoreDelta modify;
  rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ];
  rw [ Finset.sum_congr rfl fun j hj => by rw [ Function.update_of_ne ( by aesop ) ] ] ; simp +decide [ add_comm, add_left_comm, add_assoc ];
  abel1

end DeltaAlgebra

/-! ## Total Delta Conservation -/

section Conservation
variable [AddCommGroup G]

/-
**Total Delta Conservation.** For two configurations with equal score,
    the sum of per-position deltas is zero. This is the fundamental
    conservation law: any score-preserving transformation decomposes
    into local exchanges that cancel globally.
-/
omit [DecidableEq (Fin n)] [DecidableEq α] in
theorem total_delta_zero (w : WeightSystem n α G) (x y : Fin n → α)
    (h : score w x = score w y) :
    ∑ i : Fin n, scoreDelta w i (x i) (y i) = 0 := by
  unfold scoreDelta score at *; simp_all +decide [ Finset.sum_sub_distrib ] ;

end Conservation

/-! ## Bridge Duality -/

section BridgeDuality
variable [AddCommGroup G]

/-
**Bridge Duality Theorem.** For two equal-score configurations that agree
    everywhere except positions i and j (with i ≠ j):
    wᵢ(xᵢ) = wᵢ(yᵢ) ↔ wⱼ(xⱼ) = wⱼ(yⱼ).

    The proof uses that from equal scores and agreement elsewhere,
    wᵢ(xᵢ) + wⱼ(xⱼ) = wᵢ(yᵢ) + wⱼ(yⱼ), so the deltas at i and j
    are negatives of each other. One is zero iff the other is.
-/
theorem bridge_duality (w : WeightSystem n α G) (x y : Fin n → α)
    (i j : Fin n) (hij : i ≠ j)
    (hagree : ∀ k, k ≠ i → k ≠ j → x k = y k)
    (hscore : score w x = score w y) :
    w i (x i) = w i (y i) ↔ w j (x j) = w j (y j) := by
  -- Apply the total delta conservation to hscore.
  have h_total_delta : ∑ k, scoreDelta w k (x k) (y k) = 0 := by
    exact total_delta_zero w x y hscore
  -- Since hagree gives scoreDelta w k (x k) (y k) = 0 for k ≠ i, k ≠ j (because x k = y k means scoreDelta_self applies), the sum reduces to scoreDelta w i (x i) (y i) + scoreDelta w j (x j) (y j) = 0.
  have h_sum_reduced : scoreDelta w i (x i) (y i) + scoreDelta w j (x j) (y j) = 0 := by
    rw [ ← h_total_delta, ← Finset.sum_subset ( Finset.subset_univ { i, j } ) ];
    · rw [ Finset.sum_pair hij ];
    · simp +contextual [ hagree, scoreDelta_self ];
  unfold scoreDelta at h_sum_reduced; simp_all +decide [ add_eq_zero_iff_eq_neg ] ;
  grind

end BridgeDuality

/-! ## Position Separation Rigidity -/

section Rigidity
variable [AddCommGroup G]

/-
**Position Separation Rigidity.** With injective weights at position i,
    two configurations agreeing everywhere except possibly at i, having
    the same score, must be identical. Injective weights create rigid fibers.
-/
theorem position_separation_rigidity (w : WeightSystem n α G) (x y : Fin n → α)
    (i : Fin n)
    (hinj : InjectiveAt w i)
    (hagree : ∀ k, k ≠ i → x k = y k)
    (hscore : score w x = score w y) :
    x = y := by
  -- By total_delta_zero, we have that the sum of the deltas is zero.
  have h_sum_deltas : ∑ j, scoreDelta w j (x j) (y j) = 0 := by
    exact total_delta_zero w x y hscore
  rw [ Finset.sum_eq_single i ] at h_sum_deltas;
  · ext k; by_cases hk : k = i <;> simp_all +decide [ scoreDelta ] ;
    exact hinj ( sub_eq_zero.mp h_sum_deltas ▸ rfl );
  · exact fun j _ hj => by rw [ hagree j hj, scoreDelta_self ] ;
  · aesop

end Rigidity

/-! ## Score Kernel Structure -/

section Kernel
variable [AddCommGroup G]

/-
The score kernel is closed under negation: any score-preserving
    exchange can be reversed.
-/
omit [DecidableEq (Fin n)] [DecidableEq α] in
theorem score_kernel_neg_closed (w : WeightSystem n α G)
    (d : Fin n → G) (hd : d ∈ ScoreKernel w) :
    (-d) ∈ ScoreKernel w := by
  unfold ScoreKernel at *;
  simp_all +decide [ scoreDelta ];
  exact fun i => by obtain ⟨ a, b, h ⟩ := hd.2 i; exact ⟨ b, a, by rw [ h, neg_sub ] ⟩ ;

end Kernel

/-! ## Uniform Weight Symmetry -/

section Uniform
variable [AddCommGroup G]

/-
**Uniform Weight Permutation Invariance.** When all positions use
    the same weight function, the score is invariant under permutation
    of position values: S(x ∘ σ) = S(x).
-/
omit [DecidableEq (Fin n)] [DecidableEq α] in
theorem score_uniform_perm (w : WeightSystem n α G) (x : Fin n → α)
    (σ : Equiv.Perm (Fin n))
    (huniform : IsUniform w) :
    score w (x ∘ σ) = score w x := by
  convert Equiv.sum_comp σ fun i => w i ( x i ) using 1;
  exact Finset.sum_congr rfl fun i _ => huniform i ( σ i ) ▸ rfl

end Uniform

/-! ## Bridge Impossibility and Fiber Preservation -/

section BridgeStructure
variable [AddCommGroup G]

/-
**Double Bridge Impossibility.** With injective weights at positions
    i and j, equal-score configs agreeing elsewhere but differing at i
    cannot have wᵢ(xᵢ) = wᵢ(yᵢ). Combined with bridge duality, this
    means no bridge exists through either position.
-/
omit [DecidableEq (Fin n)] [DecidableEq α] in
theorem double_bridge_impossibility (w : WeightSystem n α G) (x y : Fin n → α)
    (i j : Fin n) (_hij : i ≠ j)
    (hinj_i : InjectiveAt w i)
    (_hagree : ∀ k, k ≠ i → k ≠ j → x k = y k)
    (_hscore : score w x = score w y)
    (hdiff_i : x i ≠ y i) :
    w i (x i) ≠ w i (y i) := by
  exact hinj_i.ne hdiff_i

/-
Bridges preserve fiber membership.
-/
omit [DecidableEq α] in
theorem bridge_preserves_fiber (w : WeightSystem n α G) (x : Fin n → α)
    (i : Fin n) (v : α) (g : G)
    (hx : x ∈ fiber w g)
    (hb : IsBridge w x i v) :
    modify x i v ∈ fiber w g := by
  exact hb.2.trans hx

/-
Composing two bridges preserves fiber membership.
-/
omit [DecidableEq α] in
theorem bridge_chain_fiber (w : WeightSystem n α G) (x : Fin n → α)
    (i j : Fin n) (v₁ v₂ : α) (_hij : i ≠ j)
    (hb1 : IsBridge w x i v₁)
    (hb2 : IsBridge w (modify x i v₁) j v₂) :
    score w (modify (modify x i v₁) j v₂) = score w x := by
  rw [ hb2.2, hb1.2 ]

end BridgeStructure

end FiberGraph