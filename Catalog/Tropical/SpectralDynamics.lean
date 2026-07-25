/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Spectral Dynamics: Cycle Gaps, Unique Critical Cycles, and Transient Entropy

## Overview

This file formalizes a bridge between three domains:
1. **Tropical linear algebra** — cycle mean optimization in weighted directed graphs
2. **Symbolic dynamics** — unique critical cycle selection under strict gap conditions
3. **Information theory** — positive entropy bounds during the transient search phase

## Main Results

* `unique_argmax_of_strict_gap` — strict gap on a finite set implies unique maximizer
* `strict_cycle_gap_unique_critical_walk` — strict cycle-gap condition for tropical
  matrices implies a unique critical walk among all closed walks of a given length
* `tropical_entropy_pos_of_card_ge_two` — tropical entropy (−log min p) is positive
  for any strict probability distribution on ≥ 2 elements
* `strict_cycle_gap_entropy_bridge` — the main bridge theorem
* `tropical_orbit_monotone` — max-plus matrix iteration is monotone

## Connection to Catalog

Extends: `tropical_eigenvalue_unique`, `tropical_entropy_search_bound`,
`tropical_cycle_gap_mixing_lower_bound` from the tropical theory catalog.
-/

import Mathlib

noncomputable section

open Finset BigOperators Real

namespace TropicalSpectralDynamics

/-! ## Section 1: Closed Walk Framework for Tropical Matrices

A closed walk of length `k` in a weighted directed graph on `n` vertices is a
function `c : Fin k → Fin n`. The walk visits vertices `c(0), c(1), ..., c(k-1)`
and closes by the edge `c(k-1) → c(0)`. We require `k ≥ 1` via `[NeZero k]`
so that `Fin k` is nonempty and `1 : Fin k` is well-defined for the wrapping
arithmetic.
-/

/-- Weight of a closed walk `c(0) → c(1) → ⋯ → c(k−1) → c(0)` in a weighted
    directed graph given by matrix `A`. Uses `Fin k` arithmetic where addition
    wraps around, so `c(k−1 + 1) = c(0)`. Requires `k ≥ 1`. -/
def closedWalkWeight {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n) : ℝ :=
  ∑ i : Fin k, A (c i) (c (i + 1))

/-- Mean weight of a closed walk of length `k ≥ 1`. -/
def closedWalkMean {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n) : ℝ :=
  closedWalkWeight A c / k

/-- A walk `c` of length `k` is critical if it maximizes the mean weight
    among all closed walks of the same length. -/
def isCriticalWalk {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n) : Prop :=
  ∀ d : Fin k → Fin n, closedWalkMean A d ≤ closedWalkMean A c

/-- The strict cycle-gap condition: walk `c` has mean weight strictly greater
    than all other walks of the same length, with gap at least `ε > 0`. -/
def StrictCycleGap {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n) (ε : ℝ) : Prop :=
  0 < ε ∧ ∀ d : Fin k → Fin n, d ≠ c →
    closedWalkMean A d ≤ closedWalkMean A c - ε

/-! ### Walk Weight Lemmas -/

/-
A closed walk of length 1 loops at a single vertex:
    weight = `A(c(0), c(0))`.
-/
theorem closedWalkWeight_one {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin 1 → Fin n) : closedWalkWeight A c = A (c 0) (c 0) := by
  -- By definition of closedWalkWeight, we have:
  simp [closedWalkWeight]

/-
Scaling all matrix entries by a constant scales the walk weight.
-/
theorem closedWalkWeight_smul {n k : ℕ} [NeZero k]
    (A : Matrix (Fin n) (Fin n) ℝ) (c : Fin k → Fin n) (r : ℝ) :
    closedWalkWeight (r • A) c = r * closedWalkWeight A c := by
  unfold closedWalkWeight; simp +decide [ mul_comm, Finset.mul_sum _ _ _ ] ;

/-! ## Section 2: Abstract Unique Maximizer Theorem -/

/-
**Unique maximizer from strict gap.**
    If `c` achieves a strictly higher score than every other element
    (by at least `ε > 0`), then any element that is a global maximizer
    must equal `c`.
-/
theorem unique_argmax_of_strict_gap {α : Type*} [DecidableEq α]
    (score : α → ℝ) (c : α)
    (hgap : ∃ ε : ℝ, 0 < ε ∧ ∀ d, d ≠ c → score d ≤ score c - ε) :
    ∀ d, (∀ e : α, score e ≤ score d) → d = c := by
  exact fun d hd => Classical.not_not.1 fun h => by linarith [ hgap.choose_spec.1, hgap.choose_spec.2 d h, hd c ] ; ;

/-
Variant without explicit ε.
-/
theorem unique_argmax_of_strict_best {α : Type*} [DecidableEq α]
    (score : α → ℝ) (c : α)
    (hbest : ∀ d, d ≠ c → score d < score c) :
    ∀ d, (∀ e : α, score e ≤ score d) → d = c := by
  exact fun d hd => Classical.not_not.1 fun h => not_le_of_gt ( hbest d h ) ( hd c )

/-! ## Section 3: Strict Cycle Gap Implies Unique Critical Walk -/

/-- **Strict cycle-gap uniqueness.**
    If walk `c` has mean weight strictly greater than all other walks of the
    same length (with gap `ε > 0`), then `c` is the unique critical walk.

    Bridge: extends `tropical_eigenvalue_unique` from abstract eigenpair
    uniqueness to concrete cycle-level uniqueness in finite matrices. -/
theorem strict_cycle_gap_unique_critical_walk
    {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n)
    (hgap : ∃ ε : ℝ, 0 < ε ∧ ∀ d : Fin k → Fin n, d ≠ c →
      closedWalkMean A d ≤ closedWalkMean A c - ε) :
    ∀ d : Fin k → Fin n, isCriticalWalk A d → d = c :=
  unique_argmax_of_strict_gap (closedWalkMean A) c hgap

/-
A critical walk exists: the maximum of a finite nonempty set is attained.
-/
theorem exists_critical_walk {n k : ℕ} [NeZero n] [NeZero k]
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ c : Fin k → Fin n, isCriticalWalk A c := by
  -- By definition of `is Critical Walk`, there exists a walk `c` such that for all `d`, `closedWalkMean A d ≤ closedWalkMean A c`.
  have h_max : ∃ c : Fin k → Fin n, ∀ d : Fin k → Fin n, closedWalkMean A d ≤ closedWalkMean A c := by
    have h_finite : Finite (Fin k → Fin n) := by
      infer_instance
    exact?;
  exact?

/-
The strict cycle gap condition implies that `c` itself is critical.
-/
theorem strict_cycle_gap_is_critical
    {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n)
    (hgap : ∃ ε : ℝ, 0 < ε ∧ ∀ d : Fin k → Fin n, d ≠ c →
      closedWalkMean A d ≤ closedWalkMean A c - ε) :
    isCriticalWalk A c := by
  exact fun d => if hd : d = c then hd ▸ le_rfl else le_trans ( hgap.choose_spec.2 d hd ) ( sub_le_self _ hgap.choose_spec.1.le )

/-! ## Section 4: Strict Probability Distributions and Tropical Entropy -/

/-- A strict probability distribution: all probabilities are positive and sum to 1.
    Models the pre-locking search distribution over candidate walks. -/
structure TropicalProbDist (α : Type*) [Fintype α] where
  prob : α → ℝ
  prob_pos : ∀ a, 0 < prob a
  sum_one : ∑ a, prob a = 1

/-- The minimum probability in a distribution. -/
def TropicalProbDist.minProb {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) : ℝ :=
  Finset.inf' Finset.univ univ_nonempty p.prob

/-- **Tropical entropy**: `H_⊕(p) = −log(min_a p(a))`.
    Measures the worst-case search complexity / surprise. -/
def tropicalEntropy {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) : ℝ :=
  -Real.log p.minProb

/-
The minimum probability is positive.
-/
theorem TropicalProbDist.minProb_pos {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) : 0 < p.minProb := by
  cases' ( Finset.exists_min_image Finset.univ p.prob ( Finset.univ_nonempty ) ) with x hx;
  exact lt_of_lt_of_le ( p.prob_pos x ) ( Finset.le_inf' _ _ fun y _ => hx.2 y ( Finset.mem_univ y ) )

/-
The minimum probability is at most any individual probability.
-/
theorem TropicalProbDist.minProb_le_prob {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) (a : α) : p.minProb ≤ p.prob a := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
The minimum probability is at most 1.
-/
theorem TropicalProbDist.minProb_le_one {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) : p.minProb ≤ 1 := by
  exact le_trans ( p.minProb_le_prob ( Classical.arbitrary α ) ) ( p.sum_one ▸ Finset.single_le_sum ( fun a _ => le_of_lt ( p.prob_pos a ) ) ( Finset.mem_univ _ ) )

/-
When there are ≥ 2 elements, the minimum probability is strictly less than 1.
-/
theorem TropicalProbDist.minProb_lt_one {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) (hcard : 2 ≤ Fintype.card α) :
    p.minProb < 1 := by
  -- By contradiction, assume that minProb ≥ 1.
  by_contra h_contra;
  -- By definition of infimum, this means that for all `a : α`, `p.prob a ≥ 1`.
  have h_all_ge_one : ∀ a : α, p.prob a ≥ 1 := by
    exact fun a => le_trans ( le_of_not_gt h_contra ) ( Finset.inf'_le _ ( Finset.mem_univ a ) );
  exact absurd ( p.sum_one ▸ Finset.sum_le_sum fun a _ => h_all_ge_one a ) ( by norm_num; linarith )

/-
Tropical entropy is nonneg for any strict probability distribution.
-/
theorem tropical_entropy_nonneg {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) : 0 ≤ tropicalEntropy p := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( by exact le_of_lt ( by exact? ) ) ( by exact? ) )

/-
**Tropical entropy is positive when there are ≥ 2 elements.**
    Any strict probability distribution on ≥ 2 elements has positive
    tropical entropy, meaning nontrivial search uncertainty.

    Bridge: combined with `tropical_entropy_search_bound`, this gives
    `exp(H_⊕) = 1/minProb > 1`.
-/
theorem tropical_entropy_pos_of_card_ge_two {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) (hcard : 2 ≤ Fintype.card α) :
    0 < tropicalEntropy p := by
  exact neg_pos_of_neg ( Real.log_neg ( TropicalProbDist.minProb_pos p ) ( TropicalProbDist.minProb_lt_one p hcard ) )

/-
**Tropical entropy search bound**: `exp(H_⊕(p)) = 1/minProb(p)`.
    Mirrors `tropical_entropy_search_bound` from the catalog.
-/
theorem tropical_entropy_search_eq {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) :
    Real.exp (tropicalEntropy p) = 1 / p.minProb := by
  unfold tropicalEntropy;
  rw [ Real.exp_neg, Real.exp_log ( TropicalProbDist.minProb_pos p ), one_div ]

/-! ### Uniform Distribution -/

/-- The uniform distribution on a nonempty finite type. -/
def uniformDist (α : Type*) [Fintype α] [Nonempty α] : TropicalProbDist α where
  prob := fun _ => (1 : ℝ) / Fintype.card α
  prob_pos := fun _ => div_pos one_pos (Nat.cast_pos.mpr Fintype.card_pos)
  sum_one := by
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    rw [mul_div_cancel₀]
    exact Nat.cast_ne_zero.mpr (Nat.pos_iff_ne_zero.mp Fintype.card_pos)

/-
The minimum probability of the uniform distribution.
-/
theorem uniformDist_minProb (α : Type*) [Fintype α] [Nonempty α] :
    (uniformDist α).minProb = 1 / Fintype.card α := by
  exact le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ ( Classical.arbitrary _ ) ) ) ( Finset.le_inf' _ _ fun i _ => le_rfl )

/-
The tropical entropy of the uniform distribution equals `log(card α)`.
-/
theorem uniform_entropy_eq_log_card (α : Type*) [Fintype α] [Nonempty α] :
    tropicalEntropy (uniformDist α) = Real.log (Fintype.card α) := by
  unfold tropicalEntropy;
  rw [ uniformDist_minProb, ← Real.log_inv, inv_div ];
  grind +revert

/-! ## Section 5: Max-Plus Matrix Operations -/

/-- Max-plus matrix product: `(A ⊗ B)(i,j) = max_k (A(i,k) + B(k,j))`. -/
def tropMaxPlusMul {n : ℕ} [NeZero n] (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.sup' Finset.univ univ_nonempty (fun k => A i k + B k j)

/-
The max-plus product entry is at least `A(i,k) + B(k,j)` for any `k`.
-/
theorem tropMaxPlusMul_le {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    A i k + B k j ≤ tropMaxPlusMul A B i j := by
  exact Finset.le_sup' ( fun x => A i x + B x j ) ( Finset.mem_univ k )

/-- Max-plus matrix-vector product: `(A ⊗ x)(i) = max_j (A(i,j) + x(j))`. -/
def tropMaxPlusMulVec {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.sup' Finset.univ univ_nonempty (fun j => A i j + x j)

/-
**Tropical orbit monotonicity**: if `x ≤ y` pointwise, then
    `A ⊗ x ≤ A ⊗ y` pointwise.
-/
theorem tropical_orbit_monotone {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x y : Fin n → ℝ)
    (hle : ∀ i, x i ≤ y i) :
    ∀ i, tropMaxPlusMulVec A x i ≤ tropMaxPlusMulVec A y i := by
  -- since $x_i \leq y_i$ for all $i$, we have that $A_{ij} x_j \leq A_{ij} y_j$ for all $i$ and $j$.
  intro i
  simp [tropMaxPlusMulVec, hle];
  -- Since $x_i \leq y_i$ for all $i$, we have that $A_{ij} x_j \leq A_{ij} y_j$ for all $i$ and $j$. Hence, we can choose $b$ to be the index where $A_{ij} y_j$ is maximized.
  obtain ⟨b, hb⟩ : ∃ b, ∀ j, A i j + y j ≤ A i b + y b := by
    simpa using Finset.exists_max_image Finset.univ ( fun j => A i j + y j ) ⟨ i, Finset.mem_univ i ⟩
  use b
  intro j
  linarith [hle j, hb j]

/-
Adding a constant to the vector shifts the max-plus product by the same
    constant (tropical linearity).
-/
theorem tropMaxPlusMulVec_add_const {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (c : ℝ) :
    tropMaxPlusMulVec A (fun i => x i + c) = fun i => tropMaxPlusMulVec A x i + c := by
  unfold tropMaxPlusMulVec;
  -- Apply the fact that adding a constant to each element in a set does not change the supremum.
  funext j; simp [Finset.sup'_add];
  simp +decide only [add_assoc]

/-
**Tropical eigenvector shift invariance**: Adding a constant to a tropical
    eigenvector preserves the eigenpair relation.
-/
theorem tropical_eigenvector_shift {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (ev : ℝ) (v : Fin n → ℝ)
    (heig : ∀ i, tropMaxPlusMulVec A v i = ev + v i) (c : ℝ) :
    ∀ i, tropMaxPlusMulVec A (fun j => v j + c) i = ev + (v i + c) := by
  unfold tropMaxPlusMulVec at *;
  simp_all +decide [ ← add_assoc, Finset.sup'_eq_sup ];
  simp +decide [ ← heig, Finset.sup'_eq_sup ];
  exact?

/-! ## Section 6: Bridge Theorems -/

/-- **Main Bridge Theorem**: A strict cycle-gap condition on a tropical matrix
    simultaneously forces:
    1. **Unique critical walk selection** — exactly one walk of length `k`
       maximizes the cycle mean
    2. **Positive transient entropy** — any pre-locking probability distribution
       on a search space with ≥ 2 candidates has positive tropical entropy

    The cycle gap acts analogously to a spectral gap in Markov chain theory
    (controls mixing time) or a zero-temperature gap in statistical mechanics
    (forces ground-state locking).

    Bridge: connects `strict_cycle_gap_unique_critical_walk` with
    `tropical_entropy_pos_of_card_ge_two`. -/
theorem strict_cycle_gap_entropy_bridge
    {n k : ℕ} [NeZero k] (A : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n)
    (hgap : ∃ ε : ℝ, 0 < ε ∧ ∀ d : Fin k → Fin n, d ≠ c →
      closedWalkMean A d ≤ closedWalkMean A c - ε)
    {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α)
    (hcard : 2 ≤ Fintype.card α) :
    (∀ d : Fin k → Fin n, isCriticalWalk A d → d = c) ∧
    0 < tropicalEntropy p :=
  ⟨strict_cycle_gap_unique_critical_walk A c hgap,
   tropical_entropy_pos_of_card_ge_two p hcard⟩

/-
**Quantitative search bound**: Under ≥ 2 competitors, the search
    complexity `1/minProb` exceeds 1.
-/
theorem search_complexity_gt_one
    {α : Type*} [Fintype α] [Nonempty α]
    (p : TropicalProbDist α) (hcard : 2 ≤ Fintype.card α) :
    1 < 1 / p.minProb := by
  exact one_lt_one_div ( TropicalProbDist.minProb_pos p ) ( TropicalProbDist.minProb_lt_one p hcard )

/-- `log` is monotone on positive reals (helper). -/
theorem log_le_log_of_le {a b : ℝ} (ha : 0 < a) (hab : a ≤ b) :
    Real.log a ≤ Real.log b :=
  Real.log_le_log ha hab

/-
**Entropy lower bound from uniform competitors**: For ≥ 2 candidates,
    the uniform distribution has entropy at least `log 2`.
-/
theorem uniform_entropy_ge_log_two (α : Type*) [Fintype α] [Nonempty α]
    (hcard : 2 ≤ Fintype.card α) :
    Real.log 2 ≤ tropicalEntropy (uniformDist α) := by
  have := @uniform_entropy_eq_log_card;
  convert this α |> fun h => h.symm ▸ Real.log_le_log ( by positivity ) ( Nat.cast_le.mpr hcard ) using 1

end TropicalSpectralDynamics

end