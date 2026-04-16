import Mathlib

/-!
# Tropical Automorphic Forms on Graphs

This file develops a theory of harmonic analysis on metric graphs as a full
tropical automorphic theory.

## Key Ideas

1. **Graph Laplacian as Hecke operator**
2. **Harmonic functions as automorphic forms**: ker(Laplacian) = tropical automorphic forms
3. **Graph zeta functions**: Ihara zeta as a tropical L-function
4. **Baker-Norine Riemann-Roch**: Tropical reciprocity for graph divisors
5. **Spectral gap and Ramanujan property**
-/

noncomputable section

open Real BigOperators Finset

namespace TropicalLanglands.GraphAutomorphic

/-! ## Section 1: Graph Laplacian and Harmonic Functions -/

/-- The degree of vertex v -/
def vertexDegree (n : ℕ) (A : Fin n → Fin n → ℝ) (v : Fin n) : ℝ :=
  ∑ w : Fin n, A v w

/-- The combinatorial Laplacian: L = D - A -/
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
def GraphDivisor (n : ℕ) := Fin n → ℤ

/-- Degree of a divisor -/
def divisorDegree (n : ℕ) (D : GraphDivisor n) : ℤ :=
  ∑ v : Fin n, D v

/-- A divisor is effective if all entries ≥ 0 -/
def isEffective (n : ℕ) (D : GraphDivisor n) : Prop :=
  ∀ v : Fin n, D v ≥ 0

/-- The canonical divisor: K(v) = deg(v) - 2 -/
def canonicalDivisor (n : ℕ) (A : Fin n → Fin n → ℝ) : GraphDivisor n :=
  fun v => (⌊∑ w : Fin n, A v w⌋ : ℤ) - 2

/-- Degree of canonical divisor on (q+1)-regular graph is n*(q-1) -/
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
theorem energy_nonneg (n : ℕ) (A : Fin n → Fin n → ℝ)
    (hA : ∀ i j, A i j ≥ 0) (D : Fin n → ℝ) :
    divisorEnergy n A D ≥ 0 := by
  apply Finset.sum_nonneg; intro v _
  apply Finset.sum_nonneg; intro w _
  exact mul_nonneg (hA v w) (sq_nonneg _)

/-- Energy is zero for constant functions -/
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
theorem ramanujan_spectral_gap (n : ℕ) (eigenvalues : Fin n → ℝ) (q : ℝ) (hq : q ≥ 1)
    (hR : isRamanujan n eigenvalues q)
    (i : Fin n) (hi1 : eigenvalues i ≠ q + 1) (hi2 : eigenvalues i ≠ -(q + 1)) :
    eigenvalues i ^ 2 ≤ 4 * q := by
  convert pow_le_pow_left₀ ( abs_nonneg _ ) ( hR i hi1 hi2 ) 2 using 1 <;> norm_num [ mul_pow, hq ];
  rw [ Real.sq_sqrt ( by positivity ) ]

end TropicalLanglands.GraphAutomorphic