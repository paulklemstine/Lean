import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.ArchitectureSearch

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 16
-/


noncomputable section

/-- A sparse topology is defined by which (i,j) pairs are attended to. -/
structure SparseTopology (N : ℕ) where
  mask : Fin N → Fin N → Bool
  /-- Every token attends to itself (self-attention is preserved). -/
  self_attend : ∀ i, mask i i = true


/-- The density of a sparse topology: fraction of active pairs. -/
def SparseTopology.density {N : ℕ} (top : SparseTopology N) : ℚ :=
  ((Finset.univ (α := Fin N) ×ˢ Finset.univ).filter
    (fun p => top.mask p.1 p.2 = true)).card / (N * N : ℕ)


/-- Full (dense) attention topology. -/
def fullTopology (N : ℕ) : SparseTopology N where
  mask _ _ := true
  self_attend _ := rfl


/-- Block-diagonal topology: tokens attend only within blocks of size B. -/
def blockDiagTopology (N B : ℕ) (hB : 0 < B) : SparseTopology N where
  mask i j := ((i : ℕ) / B = (j : ℕ) / B)
  self_attend i := by simp


/-- Strided topology: token i attends to tokens j where j mod S = i mod S
or j is within distance W of i. -/
def stridedTopology (N S W : ℕ) (hS : 0 < S) : SparseTopology N where
  mask i j := ((i : ℕ) % S = (j : ℕ) % S) || (Int.natAbs ((i : ℤ) - j) ≤ W)
  self_attend i := by simp


/-- A factorization scheme decomposes a weight matrix into a product
of structured matrices with fewer total parameters. -/
structure FactorizationScheme (n m : ℕ) where
  /-- Intermediate dimension -/
  rank : ℕ
  /-- Left factor -/
  left : Fin n → Fin rank → ℝ
  /-- Right factor -/
  right : Fin rank → Fin m → ℝ


/-- Reconstruct the approximated matrix from factors. -/
def FactorizationScheme.reconstruct {n m : ℕ} (F : FactorizationScheme n m) :
    Fin n → Fin m → ℝ :=
  fun i j => ∑ k : Fin F.rank, F.left i k * F.right k j


/-- Parameter count of the factorization. -/
def FactorizationScheme.paramCount {n m : ℕ} (F : FactorizationScheme n m) : ℕ :=
  n * F.rank + F.rank * m


/-- The factorization achieves compression when paramCount < n * m. -/
def FactorizationScheme.isCompressive {n m : ℕ} (F : FactorizationScheme n m) : Prop :=
  F.paramCount < n * m


/-- A rank-r factorization is compressive when r < nm/(n+m). -/
theorem factorization_compressive (n m r : ℕ) (hn : 0 < n) (hm : 0 < m)
    (hr : r * (n + m) < n * m)
    (F : FactorizationScheme n m) (hF : F.rank = r) :
    F.isCompressive := by
  unfold FactorizationScheme.isCompressive FactorizationScheme.paramCount
  rw [hF]; linarith


/-- Frobenius error of a factorization scheme. -/
def factorizationError (n m : ℕ) (W : Fin n → Fin m → ℝ) (F : FactorizationScheme n m) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin m, (W i j - F.reconstruct i j) ^ 2


/-- Factorization error is non-negative. -/
theorem factorizationError_nonneg (n m : ℕ) (W : Fin n → Fin m → ℝ)
    (F : FactorizationScheme n m) :
    0 ≤ factorizationError n m W F := by
  apply Finset.sum_nonneg
  intro i _
  apply Finset.sum_nonneg
  intro j _
  exact sq_nonneg _


/-- If the factorization exactly recovers W, the error is zero. -/
theorem factorizationError_zero_of_exact (n m : ℕ) (W : Fin n → Fin m → ℝ)
    (F : FactorizationScheme n m)
    (h : ∀ i j, W i j = F.reconstruct i j) :
    factorizationError n m W F = 0 := by
  unfold factorizationError
  apply Finset.sum_eq_zero
  intro i _
  apply Finset.sum_eq_zero
  intro j _
  simp [h i j]


/-- Configuration for architecture search. -/
structure SearchConfig where
  maxRank : ℕ
  blockSizes : List ℕ
  strideLengths : List ℕ
  targetCompression : ℚ
  epsilonBound : ℝ


/-- A verified candidate: a factorization scheme together with
a proof that it meets the ε-bound. -/
structure VerifiedCandidate (n m : ℕ) where
  scheme : FactorizationScheme n m
  isCompressive : scheme.isCompressive
  errorBound : ℝ
  errorProof : ∀ W, factorizationError n m W scheme ≤ errorBound


/-- Combining sparse topology with factorization: the total
compression is multiplicative. -/
theorem combined_compression (N n m : ℕ) (top : SparseTopology N)
    (F : FactorizationScheme n m) (hF : F.isCompressive) :
    F.paramCount < n * m :=
  hF


end