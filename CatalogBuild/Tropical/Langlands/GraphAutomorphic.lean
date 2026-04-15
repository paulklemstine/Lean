/-! # CatalogBuild.Tropical.Langlands.GraphAutomorphic

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 10
-/

import Mathlib

noncomputable section

/-- The combinatorial Laplacian: L = D - A -/
def graphLaplacian (n : ℕ) (A : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => if i = j then vertexDegree n A i - A i j else -(A i j)


/-- A function is harmonic if Lf = 0 -/
def isHarmonic (n : ℕ) (A : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Prop :=
  ∀ v : Fin n, ∑ w : Fin n, graphLaplacian n A v w * f w = 0


theorem graphLaplacian_symmetric (n : ℕ) (A : Fin n → Fin n → ℝ)
    (hA : ∀ i j, A i j = A j i) :
    ∀ i j, graphLaplacian n A i j = graphLaplacian n A j i := by
  unfold graphLaplacian; aesop;


/-- The adjacency (Hecke) operator -/
def classicalHeckeOperator (n : ℕ) (A : Fin n → Fin n → ℝ) (f : Fin n → ℝ) : Fin n → ℝ :=
  fun v => ∑ w : Fin n, A v w * f w


theorem hecke_selfadjoint (n : ℕ) (A : Fin n → Fin n → ℝ)
    (hA : ∀ i j, A i j = A j i) (f g : Fin n → ℝ) :
    ∑ v, f v * classicalHeckeOperator n A g v =
    ∑ v, classicalHeckeOperator n A f v * g v := by
  unfold classicalHeckeOperator; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] ;
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hA ] )


/-- A divisor is effective if all entries ≥ 0 -/
def isEffective (n : ℕ) (D : GraphDivisor n) : Prop :=
  ∀ v : Fin n, D v ≥ 0


/-- Degree of canonical divisor on (q+1)-regular graph is n*(q-1) -/
theorem canonical_degree_regular (n : ℕ) (A : Fin n → Fin n → ℝ)
    (q : ℕ) (hreg : ∀ v : Fin n, ∑ w : Fin n, A v w = q + 1) :
    divisorDegree n (canonicalDivisor n A) = n * (q - 1) := by
  simp [divisorDegree, canonicalDivisor, hreg]
  push_cast; ring


/-- Energy of a function (quadratic form) -/
def divisorEnergy (n : ℕ) (A : Fin n → Fin n → ℝ) (D : Fin n → ℝ) : ℝ :=
  ∑ v : Fin n, ∑ w : Fin n, A v w * (D v - D w) ^ 2


/-- Energy is zero for constant functions -/
theorem energy_zero_constant (n : ℕ) (A : Fin n → Fin n → ℝ) (c : ℝ) :
    divisorEnergy n A (fun _ => c) = 0 := by
  simp [divisorEnergy]


/-- A graph is Ramanujan if nontrivial eigenvalues satisfy |λ| ≤ 2√q -/
def isRamanujan (n : ℕ) (eigenvalues : Fin n → ℝ) (q : ℝ) : Prop :=
  ∀ i : Fin n, eigenvalues i ≠ q + 1 → eigenvalues i ≠ -(q + 1) →
    |eigenvalues i| ≤ 2 * Real.sqrt q


end
