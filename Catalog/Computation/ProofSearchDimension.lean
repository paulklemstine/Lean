/-
  # Proof Search Dimension: Fractal Geometry of Theorem Difficulty

  This file develops the mathematical foundations of **proof search dimension**,
  a continuous measure of theorem difficulty based on the fractal geometry of
  successful proof paths in search trees.

  ## Main Definitions

  * `SearchParams` — Parameters (k, b) of a uniform search tree
  * `searchDimension` — The fractal dimension D = log(k)/log(b)
  * `HetSearchTree` — Heterogeneous search with varying branching
  * `hetSearchDimension` — Averaged dimension for heterogeneous search
  * `searchEntropyDeficit` — Novel: measures "wasted exploration" as 1 - D

  ## Main Results

  * `searchDimension_nonneg` — D ≥ 0
  * `searchDimension_le_one` — D ≤ 1
  * `searchDimension_eq_zero_iff` — D = 0 ↔ k = 1 (deterministic search)
  * `searchDimension_eq_one_iff` — D = 1 ↔ k = b (trivial search)
  * `searchDimension_product_law` — Product decomposition law
  * `searchDimension_mono` — D is monotone in k
  * `success_prob_log_eq` — Connects dimension to exponential decay rate
-/

import Mathlib

open Real

noncomputable section

/-- Parameters for a uniform proof search tree.
  `surviving` is the number of successful branches (k),
  `branching` is the total branching factor (b),
  with 1 ≤ k ≤ b and 2 ≤ b. -/
structure SearchParams where
  surviving : ℕ
  branching : ℕ
  hk_pos : 1 ≤ surviving
  hk_le : surviving ≤ branching
  hb : 2 ≤ branching

/-- The proof search dimension D = log(k) / log(b). -/
def searchDimension (T : SearchParams) : ℝ :=
  Real.log (T.surviving : ℝ) / Real.log (T.branching : ℝ)

lemma SearchParams.one_lt_branching_cast (T : SearchParams) : (1 : ℝ) < (T.branching : ℝ) := by
  have : 2 ≤ T.branching := T.hb
  exact_mod_cast this

lemma SearchParams.log_branching_pos (T : SearchParams) : 0 < Real.log (T.branching : ℝ) := by
  exact Real.log_pos T.one_lt_branching_cast

lemma SearchParams.surviving_cast_pos (T : SearchParams) : (0 : ℝ) < (T.surviving : ℝ) := by
  have : 1 ≤ T.surviving := T.hk_pos
  exact_mod_cast this

lemma SearchParams.log_surviving_nonneg (T : SearchParams) : 0 ≤ Real.log (T.surviving : ℝ) := by
  apply Real.log_nonneg
  exact_mod_cast T.hk_pos

/-
**Theorem 1**: The search dimension is nonneg.
-/
theorem searchDimension_nonneg (T : SearchParams) : 0 ≤ searchDimension T := by
  exact div_nonneg T.log_surviving_nonneg ( Real.log_nonneg ( by norm_cast; linarith [ T.hb ] ) )

/-
**Theorem 2**: The search dimension is at most 1.
-/
theorem searchDimension_le_one (T : SearchParams) : searchDimension T ≤ 1 := by
  exact div_le_one_of_le₀ ( Real.log_le_log ( by norm_cast; linarith [ T.hk_pos ] ) ( mod_cast T.hk_le ) ) ( Real.log_nonneg ( mod_cast T.hb.trans' ( by norm_num ) ) )

/-
**Theorem 3 (Phase Transition, Left Boundary)**:
  D = 0 iff k = 1. Deterministic search.
-/
theorem searchDimension_eq_zero_iff (T : SearchParams) :
    searchDimension T = 0 ↔ T.surviving = 1 := by
  simp [searchDimension];
  constructor <;> intro h <;> norm_cast at * <;> rcases T with ⟨ k, b, hk, hb, hb' ⟩ <;> aesop

/-
**Theorem 4 (Phase Transition, Right Boundary)**:
  D = 1 iff k = b. Trivial search.
-/
theorem searchDimension_eq_one_iff (T : SearchParams) :
    searchDimension T = 1 ↔ T.surviving = T.branching := by
  unfold searchDimension;
  rw [ div_eq_iff ] <;> norm_num [ ne_of_gt, SearchParams.log_branching_pos ];
  exact ⟨ fun h => Nat.cast_injective ( Real.log_injOn_pos ( by norm_num; linarith [ T.hk_pos ] ) ( by norm_num; linarith [ T.hb ] ) h ), fun h => h ▸ rfl ⟩

/-
**Theorem 5 (Monotonicity)**: More successful branches → higher dimension.
-/
theorem searchDimension_mono {T₁ T₂ : SearchParams}
    (hb : T₁.branching = T₂.branching)
    (hk : T₁.surviving ≤ T₂.surviving) :
    searchDimension T₁ ≤ searchDimension T₂ := by
  -- The logarithm function is increasing on the positive reals.
  have h_log_inc : Real.log (T₁.surviving : ℝ) ≤ Real.log (T₂.surviving : ℝ) := by
    exact Real.log_le_log ( mod_cast T₁.hk_pos ) ( mod_cast hk );
  unfold searchDimension;
  rw [ hb ] ; gcongr

/-! ## Product Search Trees -/

/-- Product of two search parameter sets. -/
def SearchParams.prod (T₁ T₂ : SearchParams) : SearchParams where
  surviving := T₁.surviving * T₂.surviving
  branching := T₁.branching * T₂.branching
  hk_pos := by
    apply Nat.one_le_iff_ne_zero.mpr
    exact Nat.mul_ne_zero (Nat.one_le_iff_ne_zero.mp T₁.hk_pos) (Nat.one_le_iff_ne_zero.mp T₂.hk_pos)
  hk_le := Nat.mul_le_mul T₁.hk_le T₂.hk_le
  hb := by
    have := T₁.hb
    have := T₂.hb
    nlinarith

/-
**Theorem 6 (Product Law)**:
  D(T₁ × T₂) · log(b₁·b₂) = D(T₁) · log(b₁) + D(T₂) · log(b₂).
-/
theorem searchDimension_product_law (T₁ T₂ : SearchParams) :
    searchDimension (T₁.prod T₂) * Real.log ((T₁.branching * T₂.branching : ℕ) : ℝ) =
    searchDimension T₁ * Real.log (T₁.branching : ℝ) +
    searchDimension T₂ * Real.log (T₂.branching : ℝ) := by
  unfold searchDimension; norm_num; ring;
  erw [ mul_inv_cancel_right₀, mul_inv_cancel_right₀ ];
  · unfold SearchParams.prod; norm_num; ring;
    rw [ mul_assoc, mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos ( by norm_cast; nlinarith [ T₁.hb, T₂.hb ] ) ) ), mul_one, Real.log_mul ( by norm_cast; linarith [ T₁.hk_pos ] ) ( by norm_cast; linarith [ T₂.hk_pos ] ) ];
  · exact ne_of_gt <| Real.log_pos <| mod_cast T₂.hb;
  · exact ne_of_gt <| Real.log_pos <| mod_cast T₁.hb

/-! ## Search Entropy Deficit -/

/-- The search entropy deficit: complement of the dimension. -/
def searchEntropyDeficit (T : SearchParams) : ℝ :=
  1 - searchDimension T

/-- Deficit + Dimension = 1. -/
theorem entropy_deficit_complement (T : SearchParams) :
    searchEntropyDeficit T + searchDimension T = 1 := by
  unfold searchEntropyDeficit; ring

/-
The entropy deficit is nonneg.
-/
theorem entropy_deficit_nonneg (T : SearchParams) : 0 ≤ searchEntropyDeficit T := by
  exact sub_nonneg_of_le ( searchDimension_le_one T )

/-
The entropy deficit is at most 1.
-/
theorem entropy_deficit_le_one (T : SearchParams) : searchEntropyDeficit T ≤ 1 := by
  exact sub_le_self _ ( searchDimension_nonneg T )

/-! ## Heterogeneous Search Dimension -/

/-- Parameters for a single depth level. -/
structure LevelParams where
  surviving : ℕ
  branching : ℕ
  hk_pos : 1 ≤ surviving
  hk_le : surviving ≤ branching
  hb : 2 ≤ branching

/-- Convert LevelParams to SearchParams. -/
def LevelParams.toSearchParams (L : LevelParams) : SearchParams where
  surviving := L.surviving
  branching := L.branching
  hk_pos := L.hk_pos
  hk_le := L.hk_le
  hb := L.hb

/-- A heterogeneous search tree: varying parameters at each depth level. -/
structure HetSearchTree where
  depth : ℕ
  hd : 1 ≤ depth
  levels : Fin depth → LevelParams

/-- The heterogeneous search dimension:
  D = Σ log(k_i) / Σ log(b_i).
  This is the natural generalization because the total number of
  successful paths at depth d is Π k_i and total paths is Π b_i. -/
def hetSearchDimension (H : HetSearchTree) : ℝ :=
  (∑ i : Fin H.depth, Real.log ((H.levels i).surviving : ℝ)) /
  (∑ i : Fin H.depth, Real.log ((H.levels i).branching : ℝ))

/-
**Theorem 10**: A uniform heterogeneous tree has the same dimension
  as the underlying uniform tree.
-/
theorem hetSearchDimension_uniform (T : SearchParams) (d : ℕ) (hd : 1 ≤ d) :
    hetSearchDimension ⟨d, hd, fun _ => ⟨T.surviving, T.branching, T.hk_pos, T.hk_le, T.hb⟩⟩ =
    searchDimension T := by
  unfold hetSearchDimension searchDimension; norm_num [ mul_div_mul_comm ] ;
  rw [ div_self ( by positivity ), one_mul ]

/-! ## Success Probability -/

/-- Success probability at depth d. -/
def successProb (T : SearchParams) (d : ℕ) : ℝ :=
  ((T.surviving : ℝ) / (T.branching : ℝ)) ^ d

/-
**Theorem 11 (Decay Rate)**: log(P(d)) = d · (D - 1) · log(b).
  This connects the search dimension to the exponential decay rate
  of the success probability with increasing search depth.
-/
theorem success_prob_log_eq (T : SearchParams) (d : ℕ) :
    Real.log (successProb T d) =
    d * (searchDimension T - 1) * Real.log (T.branching : ℝ) := by
  rw [ successProb, searchDimension ];
  rw [ Real.log_pow, Real.log_div ] <;> ring <;> norm_num [ T.hk_pos, T.hk_le, T.hb ];
  · rw [ mul_assoc, mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos ( mod_cast T.hb ) ) ), mul_one ];
  · linarith [ T.hk_pos ];
  · linarith [ T.hb ]

/-
**Falsifiable Conjecture**: The heterogeneous dimension is bounded
  between the minimum and maximum local dimensions. Testable by
  generating random heterogeneous trees.
-/
theorem hetSearchDimension_nonneg (H : HetSearchTree) :
    0 ≤ hetSearchDimension H := by
  refine' div_nonneg _ _;
  · exact Finset.sum_nonneg fun _ _ => Real.log_nonneg <| mod_cast H.levels _ |>.hk_pos;
  · exact Finset.sum_nonneg fun _ _ => Real.log_nonneg <| mod_cast H.levels _ |>.hb.trans' <| by norm_num;

end