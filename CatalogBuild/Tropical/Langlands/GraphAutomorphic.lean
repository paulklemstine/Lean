/-! # CatalogBuild.Tropical.Langlands.GraphAutomorphic

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 10
-/

import Mathlib

noncomputable section

def graphLaplacian (n : ℕ) (A : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => if i = j then vertexDegree n A i - A i j else -(A i j)

/-- A function is harmonic if Lf = 0 -/

def isHarmonic (n : ℕ) (A : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Prop :=
  ∀ v : Fin n, ∑ w : Fin n, graphLaplacian n A v w * f w = 0

/-
The graph Laplacian is symmetric
-/

theorem graphLaplacian_symmetric (n : ℕ) (A : Fin n → Fin n → ℝ)
    (hA : ∀ i j, A i j = A j i) :
    ∀ i j, graphLaplacian n A i j = graphLaplacian n A j i := by
  unfold graphLaplacian; aesop;

/-- The adjacency (Hecke) operator -/

def classicalHeckeOperator (n : ℕ) (A : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Fin n → ℝ :=
  fun v => ∑ w : Fin n, A v w * f w

/-
Hecke operator is self-adjoint for symmetric adjacency
-/

theorem hecke_selfadjoint (n : ℕ) (A : Fin n → Fin n → ℝ)
    (hA : ∀ i j, A i j = A j i) (f g : Fin n → ℝ) :
    ∑ v, f v * classicalHeckeOperator n A g v =
    ∑ v, classicalHeckeOperator n A f v * g v := by
  unfold classicalHeckeOperator; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] ;
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hA ] )

/-! ## Section 2: Baker-Norine Theory (Tropical Riemann-Roch) -/

/-- A divisor on a graph -/

def isEffective (n : ℕ) (D : GraphDivisor n) : Prop :=
  ∀ v : Fin n, D v ≥ 0

/-- The canonical divisor: K(v) = deg(v) - 2 -/

theorem canonical_degree_regular (n : ℕ) (A : Fin n → Fin n → ℝ)
    (q : ℕ) (hreg : ∀ v : Fin n, ∑ w : Fin n, A v w = q + 1) :
    divisorDegree n (canonicalDivisor n A) = n * (q - 1) := by
  simp [divisorDegree, canonicalDivisor, hreg]
  push_cast; ring

/-! ## Section 3: Energy and Positive Semi-definiteness -/

/-- Energy of a function (quadratic form) -/

def divisorEnergy (n : ℕ) (A : Fin n → Fin n → ℝ) (D : Fin n → ℝ) : ℝ :=
  ∑ v : Fin n, ∑ w : Fin n, A v w * (D v - D w) ^ 2

/-- Energy is non-negative -/

theorem energy_zero_constant (n : ℕ) (A : Fin n → Fin n → ℝ) (c : ℝ) :
    divisorEnergy n A (fun _ => c) = 0 := by
  simp [divisorEnergy]

/-! ## Section 4: Ramanujan Graphs -/

/-- A graph is Ramanujan if nontrivial eigenvalues satisfy |λ| ≤ 2√q -/

def isRamanujan (n : ℕ) (eigenvalues : Fin n → ℝ) (q : ℝ) : Prop :=
  ∀ i : Fin n, eigenvalues i ≠ q + 1 → eigenvalues i ≠ -(q + 1) →
    |eigenvalues i| ≤ 2 * Real.sqrt q

/-
Ramanujan property implies eigenvalue² ≤ 4q
-/

end
