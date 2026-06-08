/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Fractal Dimension of Proof Search — Definitions and Core Theory

## Overview

When a theorem prover searches for a proof, it explores a tree of possible
derivation steps. The "fractal dimension" of the set of successful proof paths
captures how hard the theorem is to prove. We formalize this via a
**branching search model** where at each node of a b-ary tree, exactly k
children lead to eventually-successful paths. The search dimension
D = log(k)/log(b) measures proof difficulty on a continuous scale from
0 (deterministic, unique proof) to 1 (trivial, every path works).

## Novel Concepts

- `SearchDimension`: fractal dimension of proof search = log(k)/log(b)
- `BranchingSearchModel`: parameterized proof search structure
- `ComposedSearch`: sequential composition of search problems
- `SearchEntropy` / `FullTreeEntropy`: information-theoretic measures

## Main Results

- Dimension lies in [0, 1] and equals 1 iff k = b (critical threshold)
- Dimension is monotone in survival count k
- Subcritical phase: k < b ⟹ exponential decay of success probability
- Entropy-dimension bridge: D = SearchEntropy / FullTreeEntropy
- Dimension determines information rate per search level
-/

import Mathlib

open Real Finset Nat

/-! ## Section 1: The Branching Search Model -/

/-- A **branching search model** captures the structure of proof search as a
complete b-ary tree where k out of b branches survive at each node.
- `b`: total branching factor (number of applicable tactics)
- `k`: surviving branches per node (leading to eventual proofs)
- `d`: search depth (proof length)
-/
structure BranchingSearchModel where
  b : ℕ
  k : ℕ
  d : ℕ
  hb : 2 ≤ b
  hk_pos : 1 ≤ k
  hkb : k ≤ b

namespace BranchingSearchModel

/-- Total leaf nodes: all possible proof attempts of length d. -/
def totalLeaves (M : BranchingSearchModel) : ℕ := M.b ^ M.d

/-- Successful leaf nodes: proof paths that work. -/
def successfulLeaves (M : BranchingSearchModel) : ℕ := M.k ^ M.d

end BranchingSearchModel

/-! ## Section 2: Search Dimension (Novel Definition)

The **search dimension** D = log(k)/log(b) is the box-counting dimension
of the set of successful paths in the boundary of the b-ary tree under
the natural ultrametric d(x,y) = b^{-n} where n is the common prefix length.

- D = 0: unique proof path (k = 1)
- D = 1: every path is a proof (k = b)
- 0 < D < 1: intermediate difficulty
-/

/-- The fractal dimension of proof search: log(k) / log(b).
Equals the Hausdorff dimension of successful paths in the tree boundary. -/
noncomputable def SearchDimension (b k : ℕ) : ℝ :=
  Real.log (k : ℝ) / Real.log (b : ℝ)

/-! ## Section 3: Fundamental Properties -/

/-- When every branch succeeds (k = b), dimension is 1. -/
theorem searchDim_full (b : ℕ) (hb : 2 ≤ b) :
    SearchDimension b b = 1 := by
  unfold SearchDimension
  exact div_self (ne_of_gt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb)))

/-- When exactly one branch succeeds (k = 1), dimension is 0. -/
theorem searchDim_unique (b : ℕ) :
    SearchDimension b 1 = 0 := by
  simp [SearchDimension, Nat.cast_one, Real.log_one]

/-- Dimension is non-negative for valid parameters. -/
theorem searchDim_nonneg (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (_hkb : k ≤ b) :
    0 ≤ SearchDimension b k := by
  apply div_nonneg
  · exact Real.log_nonneg (by exact_mod_cast hk)
  · exact le_of_lt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))

/-- Dimension is at most 1. -/
theorem searchDim_le_one (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k ≤ b) :
    SearchDimension b k ≤ 1 := by
  unfold SearchDimension
  rw [div_le_one (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))]
  exact Real.log_le_log (by exact_mod_cast hk) (by exact_mod_cast hkb)

/-- **Subcritical dimension**: k < b implies dimension strictly less than 1. -/
theorem searchDim_lt_one (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k < b) :
    SearchDimension b k < 1 := by
  unfold SearchDimension
  rw [div_lt_one (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))]
  exact Real.log_lt_log (by exact_mod_cast hk) (by exact_mod_cast hkb)

/-! ## Section 4: Monotonicity -/

/-- More surviving branches → higher dimension (easier search). -/
theorem searchDim_mono (b : ℕ) (hb : 2 ≤ b) {k₁ k₂ : ℕ}
    (hk₁ : 1 ≤ k₁) (h : k₁ ≤ k₂) (_hk₂b : k₂ ≤ b) :
    SearchDimension b k₁ ≤ SearchDimension b k₂ := by
  unfold SearchDimension
  apply div_le_div_of_nonneg_right
  · exact Real.log_le_log (by exact_mod_cast hk₁) (by exact_mod_cast h)
  · exact le_of_lt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))

/-! ## Section 5: Subcritical Exponential Decay -/

/-- When k < b, successful paths are strictly fewer than total paths. -/
theorem subcritical_decay (b k d : ℕ) (hkb : k < b) (hd : d ≠ 0) :
    k ^ d < b ^ d :=
  Nat.pow_lt_pow_left hkb hd

/-- The success ratio strictly worsens with each additional depth level:
    k^(d+1) · b^d < k^d · b^(d+1). -/
theorem decay_ratio_worsens (b k d : ℕ) (hk : 1 ≤ k) (hkb : k < b) :
    k ^ (d + 1) * b ^ d < k ^ d * b ^ (d + 1) := by
  simp only [pow_succ]
  have hkd : 0 < k ^ d := Nat.one_le_pow _ _ hk
  have hbd : 0 < b ^ d := Nat.one_le_pow _ _ (by omega)
  nlinarith [mul_lt_mul_of_pos_right hkb hbd]

/-! ## Section 6: Critical Threshold -/

/-- **Critical threshold**: D = 1 if and only if k = b. -/
theorem critical_threshold (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k ≤ b) :
    SearchDimension b k = 1 ↔ k = b := by
  constructor
  · intro h
    unfold SearchDimension at h
    have hlogb_pos : 0 < Real.log (b : ℝ) :=
      Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb)
    rw [div_eq_one_iff_eq (ne_of_gt hlogb_pos)] at h
    have hk_pos : (0 : ℝ) < k := by positivity
    have hb_pos : (0 : ℝ) < b := by positivity
    exact_mod_cast Real.log_injOn_pos (Set.mem_Ioi.mpr hk_pos) (Set.mem_Ioi.mpr hb_pos) h
  · intro heq; subst heq; exact searchDim_full k hb

/-- **Subcritical iff**: D < 1 iff k < b. -/
theorem subcritical_iff (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k ≤ b) :
    SearchDimension b k < 1 ↔ k < b := by
  constructor
  · intro h
    by_contra hle
    push_neg at hle
    have : k = b := le_antisymm hkb hle
    rw [(critical_threshold b k hb hk hkb).mpr this] at h
    exact lt_irrefl 1 h
  · exact searchDim_lt_one b k hb hk

/-! ## Section 7: Entropy-Dimension Bridge -/

/-- Search entropy: log of successful path count at depth d. -/
noncomputable def SearchEntropy (k d : ℕ) : ℝ := Real.log ((k : ℝ) ^ d)

/-- Full tree entropy: log of total path count at depth d. -/
noncomputable def FullTreeEntropy (b d : ℕ) : ℝ := Real.log ((b : ℝ) ^ d)

/-- **Entropy-dimension bridge**: search dimension = SearchEntropy / FullTreeEntropy.
This is the key connection between information theory and fractal geometry. -/
theorem entropy_dimension_bridge (b k d : ℕ) (_hb : 2 ≤ b) (_hd : 1 ≤ d) :
    SearchEntropy k d / FullTreeEntropy b d = SearchDimension b k := by
  unfold SearchEntropy FullTreeEntropy SearchDimension
  rw [Real.log_pow, Real.log_pow]
  have hd_pos : (d : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  field_simp

/-- The information per depth level equals log(b) · (1 - D). -/
theorem dimension_info_rate (b k : ℕ) (hb : 2 ≤ b) (_hk : 1 ≤ k) (_hkb : k ≤ b) :
    Real.log (b : ℝ) - Real.log (k : ℝ) =
    Real.log (b : ℝ) * (1 - SearchDimension b k) := by
  unfold SearchDimension
  have hlogb : Real.log (b : ℝ) ≠ 0 :=
    ne_of_gt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))
  field_simp

/-- Information content decomposes multiplicatively over depth. -/
theorem info_content_decomposition (b k d : ℕ) :
    Real.log ((b : ℝ) ^ d) - Real.log ((k : ℝ) ^ d) =
    (d : ℝ) * (Real.log (b : ℝ) - Real.log (k : ℝ)) := by
  rw [Real.log_pow, Real.log_pow]; ring

/-! ## Section 9: Composition of Searches -/

/-- Sequential composition of two proof searches. -/
structure ComposedSearch where
  b₁ : ℕ
  k₁ : ℕ
  d₁ : ℕ
  b₂ : ℕ
  k₂ : ℕ
  d₂ : ℕ
  hb₁ : 2 ≤ b₁
  hb₂ : 2 ≤ b₂
  hk₁ : 1 ≤ k₁
  hk₂ : 1 ≤ k₂
  hkb₁ : k₁ ≤ b₁
  hkb₂ : k₂ ≤ b₂

namespace ComposedSearch

def totalSpace (C : ComposedSearch) : ℕ := C.b₁ ^ C.d₁ * C.b₂ ^ C.d₂
def successfulPaths (C : ComposedSearch) : ℕ := C.k₁ ^ C.d₁ * C.k₂ ^ C.d₂

/-- Successful paths are bounded by total space. -/
theorem bound (C : ComposedSearch) :
    C.successfulPaths ≤ C.totalSpace := by
  unfold successfulPaths totalSpace
  exact Nat.mul_le_mul (Nat.pow_le_pow_left C.hkb₁ C.d₁) (Nat.pow_le_pow_left C.hkb₂ C.d₂)

end ComposedSearch

/-- Log of composed search entropy decomposes additively. -/
theorem same_branching_composition (k₁ k₂ d₁ d₂ : ℕ)
    (hk₁ : 1 ≤ k₁) (hk₂ : 1 ≤ k₂) :
    Real.log ((k₁ : ℝ) ^ d₁ * (k₂ : ℝ) ^ d₂) =
    (d₁ : ℝ) * Real.log (k₁ : ℝ) + (d₂ : ℝ) * Real.log (k₂ : ℝ) := by
  have h1 : (0 : ℝ) < (k₁ : ℝ) ^ d₁ := by positivity
  have h2 : (0 : ℝ) < (k₂ : ℝ) ^ d₂ := by positivity
  rw [Real.log_mul (ne_of_gt h1) (ne_of_gt h2), Real.log_pow, Real.log_pow]