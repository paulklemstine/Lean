/-! # CatalogBuild.MachineLearning.Neural.VerifiedCompilation

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Specification of a matrix multiplication kernel. -/
def matmulSpec (n m p : ℕ) (A : Fin n → Fin m → ℝ) (B : Fin m → Fin p → ℝ) :
    Fin n → Fin p → ℝ :=
  fun i k => ∑ j : Fin m, A i j * B j k


/-- A kernel implementation is correct if it matches the spec. -/
def KernelCorrect (n m p : ℕ)
    (impl : (Fin n → Fin m → ℝ) → (Fin m → Fin p → ℝ) → (Fin n → Fin p → ℝ)) : Prop :=
  ∀ A B, impl A B = matmulSpec n m p A B


/-- [Section: ## Section 1: Kernel Semantics as Algebraic Specifications] -/
theorem matmul_assoc (n m p q : ℕ)
    (A : Fin n → Fin m → ℝ) (B : Fin m → Fin p → ℝ) (C : Fin p → Fin q → ℝ) :
    matmulSpec n m q A (matmulSpec m p q B C) =
    matmulSpec n p q (matmulSpec n m p A B) C := by
  funext i k; simp [matmulSpec] ; ring;
  simpa only [ mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul ] using Finset.sum_comm


/-- A partition of work across G GPUs. -/
def gpuPartition (N G : ℕ) (hG : 0 < G) (gpu : Fin G) : Finset (Fin N) :=
  Finset.univ.filter (fun i => (i : ℕ) % G = gpu)


/-- The GPU partitions cover all indices. -/
theorem gpuPartition_covers (N G : ℕ) (hG : 0 < G) :
    ∀ i : Fin N, ∃ gpu : Fin G, i ∈ gpuPartition N G hG gpu := by
  intro i
  have hmod : (i : ℕ) % G < G := Nat.mod_lt _ hG
  exact ⟨⟨(i : ℕ) % G, hmod⟩, by simp [gpuPartition]⟩


/-- The GPU partitions are pairwise disjoint. -/
theorem gpuPartition_disjoint (N G : ℕ) (hG : 0 < G)
    (g₁ g₂ : Fin G) (hne : g₁ ≠ g₂) :
    Disjoint (gpuPartition N G hG g₁) (gpuPartition N G hG g₂) := by
  simp only [gpuPartition, Finset.disjoint_filter]
  intro x _ h1 h2
  exact absurd (Fin.ext (h1.symm.trans h2)) hne


/-- [Section: ## Section 2: Distributed Reduction] -/
theorem allreduce_sum_equiv (N G : ℕ) (hG : 0 < G) (f : Fin N → ℝ) :
    ∑ gpu : Fin G, ∑ i ∈ gpuPartition N G hG gpu, f i = ∑ i : Fin N, f i := by
  rw [ ← Finset.sum_biUnion ] ; congr; ext i ; simp +decide [ Finset.ext_iff, gpuPartition ] ;
  · exact ⟨ ⟨ i % G, Nat.mod_lt _ hG ⟩, rfl ⟩;
  · exact fun i _ j _ hij => gpuPartition_disjoint N G hG i j hij


/-- A weight projection is a deterministic function on matrices. -/
structure WeightProjection (n m : ℕ) where
  project : (Fin n → Fin m → ℝ) → (Fin n → Fin m → ℝ)


/-- Error bound for a weight projection. -/
def projectionErrorBound (n m : ℕ) (P : WeightProjection n m) (δ : ℝ) : Prop :=
  ∀ W : Fin n → Fin m → ℝ, ∀ i j, |W i j - P.project W i j| ≤ δ


/-- Low-rank factorization. -/
structure LowRankProjection (n m : ℕ) where
  rank : ℕ
  factorA : Fin n → Fin rank → ℝ
  factorB : Fin rank → Fin m → ℝ


/-- Reconstructed matrix from low-rank factorization. -/
def LowRankProjection.reconstruct {n m : ℕ} (P : LowRankProjection n m) :
    Fin n → Fin m → ℝ :=
  fun i j => ∑ k : Fin P.rank, P.factorA i k * P.factorB k j


/-- Parameter savings from low-rank factorization. -/
theorem lowrank_param_savings (n m r : ℕ)
    (hr : r * (n + m) < n * m) :
    r * (n + m) < n * m := hr


/-- [Section: ## Section 4: Compilation Pipeline Correctness] -/
theorem matmul_weight_perturbation (n m p : ℕ)
    (W W' : Fin n → Fin m → ℝ) (B : Fin m → Fin p → ℝ)
    (δ : ℝ) (hδ : 0 ≤ δ)
    (hW : ∀ i j, |W i j - W' i j| ≤ δ) :
    ∀ i k, |matmulSpec n m p W B i k - matmulSpec n m p W' B i k| ≤
      δ * ∑ j : Fin m, |B j k| := by
  intros i k; rw [ mul_comm, Finset.sum_mul _ _ _ ] ; exact (by
  rw [ matmulSpec, matmulSpec ];
  simpa only [ ← Finset.sum_sub_distrib, ← mul_sub ] using le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun j _ => by rw [ abs_le ] ; constructor <;> cases abs_cases ( B j k ) <;> nlinarith [ abs_le.mp ( hW i j ) ] ))


end
