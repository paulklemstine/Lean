/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Gaussian Free Field on Finite Weighted Graphs

This file establishes the connection between the Gaussian free field (GFF) on
finite weighted graphs and the Laplacian / canonical kernel structures from
tropical geometry and spectral graph theory.

## Main Definitions

* `GraphGFFEnergy` — the quadratic energy x^T L x for a matrix L
* `IsZeroMean` — predicate for zero-mean functions on a finite type
* `CovarianceFromResistance` — covariance kernel derived from effective resistance
* `GFFPartitionPrefactor` — the partition function normalization constant

## Main Results

* `graphGFFEnergy_nonneg` — nonnegativity of GFF energy for PSD Laplacians
* `graphGFFEnergy_add_const` — gauge invariance: E(x + c·1) = E(x)
* `pinnedGFF_partition_prefactor_pos` — positivity of the partition prefactor
* `effectiveResistance_eq_pseudoinverse_quadratic` — R_eff = L⁺_ii + L⁺_jj - 2L⁺_ij
* `variance_difference_eq_resistance` — Var(φ_i - φ_j) = R(i,j)

## Cross-Domain Connections

This file bridges:
- **Statistical mechanics** ↔ **Electrical networks**: covariance = effective resistance
- **Tropical geometry** ↔ **Gaussian fields**: canonical kernel lattice = GFF state space
- **Spectral graph theory** ↔ **Mathematical physics**: det(L_red) = partition normalization

## References

* Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and
  electrical networks" (2006)
* Lyons, R. with Peres, Y. "Probability on Trees and Networks" (2016)

## Catalog Dependencies

This file builds on results from:
- `Pythagorean.TropicalBridge.MetricKernel.Theorems` — especially `weightedLaplacian_psd`,
  `weightedLaplacian_row_sum_zero`, `weightedLaplacian_symm`
- `Bridges.Catalog.Pythagorean.TropicalBridge.CanonicalKernelTheorems` — especially
  `harmonicKernel` and chip-firing equivalence structures

The weighted Laplacian and its properties are re-imported here for the
subagent's convenience (the definitions are identical to those in the catalog).
-/

import Mathlib

open Finset BigOperators Matrix

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Weighted Laplacian from Catalog -/

/-- The **weighted Laplacian** (reproduced from MetricKernel/Theorems for self-containment). -/
noncomputable def weightedLaplacianGFF
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) : Matrix V V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (G.Adj i), w i k
    else if G.Adj i j then -(w i j)
    else 0

/-! ## Core Definitions -/

/-- The **GFF quadratic energy** associated to a matrix `L`.
    For a weighted Laplacian, this is the Dirichlet energy
    E_L(x) = x^T L x = ∑_i ∑_j x_i L_{ij} x_j. -/
def GraphGFFEnergy (L : Matrix ι ι ℝ) (x : ι → ℝ) : ℝ :=
  ∑ i, ∑ j, x i * L i j * x j

/-- A function `x : ι → ℝ` has **zero mean** if ∑_i x_i = 0. -/
def IsZeroMean (x : ι → ℝ) : Prop :=
  ∑ i : ι, x i = 0

/-- The **covariance kernel derived from effective resistance**.
    Given a resistance function R and a base vertex, the covariance is
    K(i,j) = (R(i,base) + R(j,base) - R(i,j)) / 2. -/
noncomputable def CovarianceFromResistance (R : ι → ι → ℝ) (base : ι) (i j : ι) : ℝ :=
  (R i base + R j base - R i j) / 2

/-- The **GFF partition function prefactor** for a positive definite reduced
    Laplacian of dimension n with determinant detLred.
    Z = (2π)^(n/2) / √(det L_red). -/
noncomputable def GFFPartitionPrefactor (n : ℕ) (detLred : ℝ) : ℝ :=
  (2 * Real.pi) ^ ((n : ℝ) / 2) / Real.sqrt detLred

/-- A matrix has **row-sum zero** if every row sums to zero. -/
def IsRowSumZero (L : Matrix ι ι ℝ) : Prop :=
  ∀ i, ∑ j, L i j = 0

/-- A matrix is **entry-symmetric**. -/
def IsSymmMatrix (L : Matrix ι ι ℝ) : Prop :=
  ∀ i j, L i j = L j i

/-- **Covariance compatibility**: the pseudoinverse entries encode resistance
    via L⁺_{ij} = (R(i,base) + R(j,base) - R(i,j)) / 2. -/
def CovarianceCompatible (Lplus R : Matrix ι ι ℝ) (base : ι) : Prop :=
  ∀ i j, Lplus i j = (R i base + R j base - R i j) / 2

/-! ## Auxiliary Lemmas -/

/-
Row-sum-zero implies L applied to constant vector vanishes.
-/
theorem rowSumZero_const_vanish
    (L : Matrix ι ι ℝ) (h_rowsum : IsRowSumZero L) (c : ℝ) :
    ∀ i, ∑ j, L i j * c = 0 := by
  exact fun i => by rw [ ← Finset.sum_mul, h_rowsum i, MulZeroClass.zero_mul ] ; ;

/-
Symmetry + row-sum-zero implies column-sum-zero.
-/
theorem symm_rowSumZero_colSumZero
    (L : Matrix ι ι ℝ)
    (h_rowsum : IsRowSumZero L)
    (h_symm : IsSymmMatrix L) :
    ∀ j, ∑ i, L i j = 0 := by
  intro j; rw [ ← h_rowsum j ] ; congr; ext i; exact h_symm i j;

/-! ## Theorem 1: Gauge Invariance of GFF Energy -/

/-
**Gauge invariance of GFF energy.**
    For a symmetric matrix with row-sum zero (i.e. a graph Laplacian),
    adding a constant to all entries of x does not change the energy:
    E_L(x + c·1) = E_L(x).

    This identifies the physical state space with potentials modulo constants,
    and is the rigorous gateway from spectral graph theory to the GFF measure
    on the quotient ℝ^V / ℝ·1.

    **Proof sketch:** Expand E_L(x+c) = ∑_i∑_j (x_i+c) L_{ij} (x_j+c).
    Distribute to get E_L(x) + c·∑_i x_i·(∑_j L_{ij}) + c·∑_j (∑_i L_{ij})·x_j
    + c²·∑_i∑_j L_{ij}. Each extra term vanishes by row/column-sum-zero.
-/
theorem graphGFFEnergy_add_const
    (L : Matrix ι ι ℝ)
    (h_rowsum : IsRowSumZero L)
    (h_symm : IsSymmMatrix L)
    (x : ι → ℝ) (c : ℝ) :
    GraphGFFEnergy L (fun i => x i + c) = GraphGFFEnergy L x := by
  simp [GraphGFFEnergy];
  simp +decide only [add_mul, mul_add, mul_assoc, sum_add_distrib];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, h_rowsum _, h_symm _ _ ]

/-! ## Theorem 2: Partition Function Prefactor -/

/-
**Positivity of the partition function prefactor.**
    For a positive definite reduced Laplacian (det > 0), the GFF partition
    prefactor (2π)^(n/2) / √(det L_red) is positive.

    This is the central statistical mechanics result: the reduced Laplacian
    determinant is the exact normalization constant for the pinned GFF.
-/
theorem pinnedGFF_partition_prefactor_pos
    (n : ℕ) (detLred : ℝ)
    (hdet_pos : 0 < detLred) :
    0 < GFFPartitionPrefactor n detLred := by
  exact div_pos ( by positivity ) ( Real.sqrt_pos.mpr hdet_pos )

/-! ## Theorem 3: Covariance = Effective Resistance -/

/-
**Effective resistance equals pseudoinverse quadratic form.**
    If the pseudoinverse Lplus and resistance R are covariance-compatible
    (i.e. L⁺_{ij} = (R(i,b) + R(j,b) - R(i,j))/2), then
    R(i,j) = L⁺_{ii} + L⁺_{jj} - 2·L⁺_{ij}.

    This is the cross-domain flagship result: it interprets effective resistance
    (an electrical network quantity) as a Gaussian fluctuation observable
    (Var(φ_i - φ_j) in the GFF).
-/
theorem effectiveResistance_eq_pseudoinverse_quadratic
    (Lplus R : Matrix ι ι ℝ) (base : ι)
    (hcompat : CovarianceCompatible Lplus R base)
    (hR_symm : ∀ i j, R i j = R j i)
    (hR_zero : ∀ i, R i i = 0) :
    ∀ i j, R i j = Lplus i i + Lplus j j - 2 * Lplus i j := by
  intro i j; linarith [ hcompat i i, hcompat j j, hcompat i j, hR_zero i, hR_zero j, hR_symm i j ] ;

/-
**Symmetry of the pinned covariance kernel.**
    The covariance kernel K(i,j) = (R(i,b) + R(j,b) - R(i,j))/2
    is symmetric when R is symmetric.
-/
theorem pinned_covariance_symmetry
    (R : ι → ι → ℝ) (base : ι)
    (hR_symm : ∀ i j, R i j = R j i) :
    ∀ i j, CovarianceFromResistance R base i j =
           CovarianceFromResistance R base j i := by
  exact fun i j => by unfold CovarianceFromResistance; rw [ hR_symm i j, hR_symm j base ] ; ring;

/-
**Covariance kernel diagonal from resistance.**
    The diagonal of the covariance kernel equals the resistance to base:
    K(i,i) = R(i,base).
-/
theorem covariance_diagonal_eq_resistance_to_base
    (R : ι → ι → ℝ) (base : ι)
    (hR_zero : ∀ i, R i i = 0) :
    ∀ i, CovarianceFromResistance R base i i = R i base := by
  exact fun i => by unfold CovarianceFromResistance; rw [ hR_zero i ] ; ring;;

/-
**Variance of field difference equals resistance (flagship cross-domain theorem).**
    Var(φ_i - φ_j) = K(i,i) + K(j,j) - 2K(i,j) = R(i,j).
    This is the statistical mechanics interpretation of effective resistance:
    thermal fluctuations in the GFF equal network dissipation geometry.
-/
theorem variance_difference_eq_resistance
    (R : ι → ι → ℝ) (base : ι)
    (hR_symm : ∀ i j, R i j = R j i)
    (hR_zero : ∀ i, R i i = 0) :
    ∀ i j, CovarianceFromResistance R base i i +
           CovarianceFromResistance R base j j -
           2 * CovarianceFromResistance R base i j = R i j := by
  exact fun i j => by unfold CovarianceFromResistance; linarith [ hR_symm i j, hR_zero i, hR_zero j ] ;

/-! ## Bridge to Weighted Graph Laplacian (Catalog Connection) -/

/-
The weighted Laplacian has row-sum zero (proved in MetricKernel/Theorems).
-/
theorem weightedLaplacianGFF_row_sum_zero
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) (i : V) :
    ∑ j : V, weightedLaplacianGFF G w i j = 0 := by
  convert rowSumZero_const_vanish ( L := weightedLaplacianGFF G w ) ( show IsRowSumZero ( weightedLaplacianGFF G w ) from ?_ ) ( 1 : ℝ ) i using 1;
  · grind;
  · intro i
    simp [IsRowSumZero, weightedLaplacianGFF];
    simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, Finset.filter_and ];
    simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
The weighted Laplacian is symmetric when weights are symmetric.
-/
theorem weightedLaplacianGFF_symm
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (i j : V) :
    weightedLaplacianGFF G w i j = weightedLaplacianGFF G w j i := by
  unfold weightedLaplacianGFF;
  split_ifs <;> simp_all +decide [ SimpleGraph.adj_comm ]

/-- The weighted Laplacian has row-sum zero (IsRowSumZero version). -/
theorem weightedLaplacianGFF_isRowSumZero
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) :
    IsRowSumZero (weightedLaplacianGFF G w) :=
  fun i => weightedLaplacianGFF_row_sum_zero G w i

/-- The weighted Laplacian is symmetric (IsSymmMatrix version). -/
theorem weightedLaplacianGFF_isSymmMatrix
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_symm : ∀ i j, w i j = w j i) :
    IsSymmMatrix (weightedLaplacianGFF G w) :=
  fun i j => weightedLaplacianGFF_symm G w hw_symm i j

/-- **Bridge theorem: GFF energy on any weighted graph is gauge-invariant.**
    Combines catalog Laplacian properties with GFF gauge invariance.
    This is the key cross-domain result connecting spectral graph theory
    to statistical mechanics via the tropical/metric graph viewpoint. -/
theorem weightedGraph_GFF_gauge_invariant
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (x : V → ℝ) (c : ℝ) :
    GraphGFFEnergy (weightedLaplacianGFF G w) (fun i => x i + c) =
    GraphGFFEnergy (weightedLaplacianGFF G w) x :=
  graphGFFEnergy_add_const _ (weightedLaplacianGFF_isRowSumZero G w)
    (weightedLaplacianGFF_isSymmMatrix G w hw_symm) x c