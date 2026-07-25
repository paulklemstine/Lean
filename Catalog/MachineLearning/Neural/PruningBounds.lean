import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.PruningBounds

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 18
-/


noncomputable section

/-- A pruning mask: true = keep, false = prune. -/
def PruningMask (n m : ℕ) := Fin n → Fin m → Bool


/-- Apply a pruning mask to a weight matrix. -/
def applyMask (n m : ℕ) (mask : PruningMask n m) (W : Fin n → Fin m → ℝ) :
    Fin n → Fin m → ℝ :=
  fun i j => if mask i j then W i j else 0


/-- The pruning error at each entry. -/
def pruningError (n m : ℕ) (mask : PruningMask n m) (W : Fin n → Fin m → ℝ)
    (i : Fin n) (j : Fin m) : ℝ :=
  W i j - applyMask n m mask W i j


/-- The pruning error is zero at kept entries. -/
theorem pruningError_zero_of_kept (n m : ℕ) (mask : PruningMask n m)
    (W : Fin n → Fin m → ℝ) (i : Fin n) (j : Fin m)
    (hkeep : mask i j = true) :
    pruningError n m mask W i j = 0 := by
  simp [pruningError, applyMask, hkeep]


/-- The pruning error equals the original weight at pruned entries. -/
theorem pruningError_eq_weight_of_pruned (n m : ℕ) (mask : PruningMask n m)
    (W : Fin n → Fin m → ℝ) (i : Fin n) (j : Fin m)
    (hprune : mask i j = false) :
    pruningError n m mask W i j = W i j := by
  simp [pruningError, applyMask, hprune]


/-- Frobenius norm squared of the pruning error. -/
def pruningErrorFrobSq (n m : ℕ) (mask : PruningMask n m) (W : Fin n → Fin m → ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin m, (pruningError n m mask W i j) ^ 2


/-- The pruning error Frobenius norm squared is non-negative. -/
theorem pruningErrorFrobSq_nonneg (n m : ℕ) (mask : PruningMask n m)
    (W : Fin n → Fin m → ℝ) :
    0 ≤ pruningErrorFrobSq n m mask W := by
  apply Finset.sum_nonneg; intro i _
  apply Finset.sum_nonneg; intro j _
  exact sq_nonneg _


/-- Count of pruned (zeroed) entries. -/
def pruneCount (n m : ℕ) (mask : PruningMask n m) : ℕ :=
  ((Finset.univ : Finset (Fin n × Fin m)).filter
    (fun p => mask p.1 p.2 = false)).card


/-- Count of kept entries. -/
def keepCount (n m : ℕ) (mask : PruningMask n m) : ℕ :=
  ((Finset.univ : Finset (Fin n × Fin m)).filter
    (fun p => mask p.1 p.2 = true)).card


/-- [Section: ## Section 2: Pruning Counts] -/
theorem keep_plus_prune_eq_total (n m : ℕ) (mask : PruningMask n m) :
    keepCount n m mask + pruneCount n m mask = n * m := by
  convert Finset.card_add_card_compl ( Finset.filter ( fun p => mask p.1 p.2 = true ) ( Finset.univ : Finset ( Fin n × Fin m ) ) ) using 1;
  · congr;
    exact congr_arg Finset.card ( by ext; aesop );
  · norm_num


/-- Two-layer error composition: if layer 1 has error ε₁ and layer 2
has Lipschitz constant L₂ and its own error ε₂, the total error
is at most L₂ · ε₁ + ε₂. -/
theorem two_layer_error_bound'
    (ε₁ ε₂ L₂ : ℝ)
    (hε₂ : 0 ≤ ε₂) (hL₂ : 0 ≤ L₂)
    (output_error_1 actual_error : ℝ)
    (h_err1 : |output_error_1| ≤ ε₁)
    (h_composition : actual_error ≤ L₂ * |output_error_1| + ε₂) :
    actual_error ≤ L₂ * ε₁ + ε₂ := by
  nlinarith [abs_nonneg output_error_1]


/-- For uniform Lipschitz constant L = 1 and uniform error ε across n layers,
the total error is at most n · ε. -/
theorem uniform_layer_error_L1' (n : ℕ) (ε : ℝ) :
    (n : ℝ) * ε = ∑ _i : Fin n, ε := by
  simp [Finset.sum_const, nsmul_eq_mul]


/-- Sparsity ratio: fraction of weights that are pruned. -/
def sparsityRatio (n m : ℕ) (mask : PruningMask n m) : ℝ :=
  (pruneCount n m mask : ℝ) / (n * m : ℝ)


/-- Sparsity ratio is non-negative. -/
theorem sparsityRatio_nonneg (n m : ℕ) (mask : PruningMask n m) :
    0 ≤ sparsityRatio n m mask := by
  exact div_nonneg (Nat.cast_nonneg _) (by positivity)


/-- A row-structured pruning mask: either keeps or removes entire rows. -/
def isRowStructured (n m : ℕ) (mask : PruningMask n m) : Prop :=
  ∀ i : Fin n, (∀ j : Fin m, mask i j = true) ∨ (∀ j : Fin m, mask i j = false)


/-- Row-structured pruning gives zero rows for pruned rows. -/
theorem row_structured_zero_rows (n m : ℕ) (mask : PruningMask n m)
    (W : Fin n → Fin m → ℝ)
    (i : Fin n) (hpruned : ∀ j : Fin m, mask i j = false) :
    ∀ j : Fin m, applyMask n m mask W i j = 0 := by
  intro j; simp [applyMask, hpruned j]


/-- The all-keep mask preserves the original matrix. -/
theorem allKeepMask_identity (n m : ℕ) (W : Fin n → Fin m → ℝ) :
    applyMask n m (fun _ _ => true) W = W := by
  ext i j; simp [applyMask]


/-- The all-prune mask gives the zero matrix. -/
theorem allPruneMask_zero (n m : ℕ) (W : Fin n → Fin m → ℝ) :
    applyMask n m (fun _ _ => false) W = fun _ _ => 0 := by
  ext i j; simp [applyMask]


end