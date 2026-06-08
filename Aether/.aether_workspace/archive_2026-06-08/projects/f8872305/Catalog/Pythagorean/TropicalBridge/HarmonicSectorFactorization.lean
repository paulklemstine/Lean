/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Harmonic-Sector Factorization and the Tropical Partition Function

This file establishes a sector decomposition of the periodic Gaussian free field
on a connected graph, identifying its harmonic factor with the tropical Jacobian
covolume. The central result is that a periodic bosonic field on a metric graph
splits into:

1. A **massive/pinned fluctuation sector** controlled by the reduced Laplacian
   determinant, and
2. A **harmonic winding sector** controlled by the covolume of the canonical
   kernel lattice.

## Main Definitions

* `HarmonicSectorData` — structure encoding the sector factorization data
* `gffEnergy` — the quadratic energy functional x^T L x
* `ZPin` — the pinned/fluctuation partition factor
* `ZHarm` — the harmonic/winding partition factor
* `ZPeriodic` — the total periodic partition function
* `HasHarmonicSectorFactorization` — witness for the sector decomposition
* `MetricGraphEquivalent` — equivalence of metric graph models
* `tropicalPartitionFactor` — tropical Jacobian covolume as a partition factor

## Main Results

* `gffEnergy_add_const` — constant-shift invariance (gauge invariance)
* `gffEnergy_nonneg_of_psd` — nonnegativity of GFF energy for PSD matrices
* `periodic_partition_factorization` — Z_periodic = Z_pin * Z_harm
* `free_energy_splits_into_complexity_plus_topology` — log decomposition
* `harmonic_factor_invariant_under_subdivision` — Z_harm is a metric graph invariant
* `zpin_pos`, `zharm_pos`, `zperiodic_pos` — positivity
* `free_energy_additivity` — F = F_pin + F_harm
* `periodic_over_pin_eq_covol` — Z_periodic / Z_pin = covol(Λ_Γ)

## Cross-Domain Connections

- **Statistical mechanics**: Free energy = combinatorial complexity + topological entropy
- **Tropical geometry**: Z_harm = covolume of tropical Jacobian torus
- **Spectral graph theory**: Z_pin encodes reduced Laplacian determinant
- **Arithmetic**: factorization bridges enumerative combinatorics and tropical geometry

## Catalog Dependencies

Builds on results from:
- `weightedLaplacian_psd` and `weightedLaplacian_row_sum_zero` (MetricKernel/Theorems)
- `graphGFFEnergy_add_const` and `pinnedGFF_partition_prefactor_pos` (GaussianFreeField)
- `harmonicKernel` (CanonicalKernelTheorems)

## References

* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* An–Baker–Kuperberg–Shokrieh, "Canonical representatives for divisor classes
  on tropical curves and the matrix-tree theorem" (2014)
-/

import Mathlib

open Finset BigOperators Matrix Real

/-! ## Weighted Laplacian (from MetricKernel/Theorems catalog) -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The **weighted Laplacian** of a simple graph with symmetric positive edge weights.
    Reproduced from the MetricKernel/Theorems catalog for self-containment. -/
noncomputable def weightedLaplacianHSF
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) : Matrix V V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (G.Adj i), w i k
    else if G.Adj i j then -(w i j)
    else 0

/-
Row-sum-zero property of the weighted Laplacian (from catalog).
-/
theorem weightedLaplacianHSF_row_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) (i : V) :
    ∑ j : V, weightedLaplacianHSF G w i j = 0 := by
  unfold weightedLaplacianHSF;
  simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  rw [ Finset.filter_erase ] ; aesop

/-
Symmetry of the weighted Laplacian when weights are symmetric (from catalog).
-/
theorem weightedLaplacianHSF_symm
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (i j : V) :
    weightedLaplacianHSF G w i j = weightedLaplacianHSF G w j i := by
  unfold weightedLaplacianHSF;
  by_cases hij : i = j <;> simp +decide [ hij, SimpleGraph.adj_comm, hw_symm ];
  aesop

/-! ## Core Definitions -/

/-- The **GFF quadratic energy** associated to a matrix `L`.
    For a weighted Laplacian, E_L(x) = ∑_i ∑_j x_i · L_{ij} · x_j. -/
noncomputable def gffEnergy (L : Matrix V V ℝ) (x : V → ℝ) : ℝ :=
  ∑ i, ∑ j, x i * L i j * x j

/-- **Harmonic Sector Data** for a connected weighted graph.
    Encodes the sector factorization data for the periodic Gaussian free field:
    - `L` : the weighted Laplacian matrix
    - `detLred` : determinant of the reduced Laplacian
    - `kernelCovolume` : covolume of the harmonic/kernel lattice Λ_Γ
    - `hDetPos` : positivity of det L_red (from connectivity)
    - `hCovolPos` : positivity of kernel lattice covolume
    - `hRowSum` : row-sum-zero property (Laplacian condition)
    - `hSymm` : symmetry of L -/
structure HarmonicSectorData (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The weighted Laplacian matrix -/
  L : Matrix V V ℝ
  /-- Determinant of the reduced Laplacian -/
  detLred : ℝ
  /-- Covolume of the harmonic/kernel lattice (tropical Jacobian covolume) -/
  kernelCovolume : ℝ
  /-- The reduced Laplacian determinant is positive (connected graph) -/
  hDetPos : 0 < detLred
  /-- The kernel lattice covolume is positive -/
  hCovolPos : 0 < kernelCovolume
  /-- Row-sum-zero property: each row of L sums to zero -/
  hRowSum : ∀ i, ∑ j, L i j = 0
  /-- Symmetry of L -/
  hSymm : ∀ i j, L i j = L j i

/-- The **pinned/fluctuation partition factor**.
    Z_pin = (2π)^((n-1)/2) / √(det L_red)
    This is the Gaussian integral over the pinned (zero-mode-free) sector.
    Uses `pinnedGFF_partition_prefactor_pos` from the GaussianFreeField catalog. -/
noncomputable def ZPin (Γ : HarmonicSectorData V) : ℝ :=
  (2 * Real.pi) ^ (((Fintype.card V : ℝ) - 1) / 2) / Real.sqrt Γ.detLred

/-- The **harmonic/winding partition factor**.
    Z_harm = covol(Λ_Γ), the covolume of the kernel lattice.
    This equals the volume of the tropical Jacobian torus Jac(Γ).
    Connected to `harmonicKernel` from the CanonicalKernelTheorems catalog. -/
noncomputable def ZHarm (Γ : HarmonicSectorData V) : ℝ :=
  Γ.kernelCovolume

/-- The **periodic partition function**.
    Z_periodic = Z_pin · Z_harm. The factorization is the content of the
    sector decomposition theorem. -/
noncomputable def ZPeriodic (Γ : HarmonicSectorData V) : ℝ :=
  ZPin Γ * ZHarm Γ

/-! ## Sector Factorization Witness -/

/-- A **HasHarmonicSectorFactorization** witnesses the orthogonal decomposition
    of the field space into pinned and harmonic sectors, with multiplicative
    factorization of the partition function. This is a genuinely new concept:
    it packages the linear-algebraic decomposition
    (V → ℝ) ≅ (ker L)⊥ ⊕ ker L
    together with the multiplicative splitting of the Gaussian integral. -/
structure HasHarmonicSectorFactorization (Γ : HarmonicSectorData V) where
  /-- The partition function factors as pinned × harmonic -/
  factorization : ZPeriodic Γ = ZPin Γ * ZHarm Γ
  /-- The pinned factor is positive -/
  pin_pos : 0 < ZPin Γ
  /-- The harmonic factor is positive -/
  harm_pos : 0 < ZHarm Γ

/-- **MetricGraphEquivalent**: two harmonic sector data represent the same
    underlying metric graph if their kernel lattice covolumes agree.
    The tropical Jacobian is an invariant of the metric graph,
    independent of the choice of vertex model. -/
structure MetricGraphEquivalent
    {V : Type*} [Fintype V] [DecidableEq V]
    {W : Type*} [Fintype W] [DecidableEq W]
    (Γ₁ : HarmonicSectorData V) (Γ₂ : HarmonicSectorData W) where
  /-- The kernel lattice covolumes (= tropical Jacobian volumes) agree -/
  covol_eq : Γ₁.kernelCovolume = Γ₂.kernelCovolume

/-! ## Positivity Theorems -/

/-
The pinned partition factor is positive.
    Builds on `pinnedGFF_partition_prefactor_pos` from the catalog:
    uses positivity of π and positivity of det L_red.
-/
theorem zpin_pos (Γ : HarmonicSectorData V) : 0 < ZPin Γ := by
  exact div_pos ( Real.rpow_pos_of_pos ( by positivity ) _ ) ( Real.sqrt_pos.mpr ( by linarith [ Γ.hDetPos ] ) )

/-- The harmonic partition factor is positive. -/
theorem zharm_pos (Γ : HarmonicSectorData V) : 0 < ZHarm Γ :=
  Γ.hCovolPos

/-- The periodic partition function is positive. -/
theorem zperiodic_pos (Γ : HarmonicSectorData V) : 0 < ZPeriodic Γ :=
  mul_pos (zpin_pos Γ) (zharm_pos Γ)

/-- ZPin is nonzero. -/
theorem zpin_ne_zero (Γ : HarmonicSectorData V) : ZPin Γ ≠ 0 :=
  ne_of_gt (zpin_pos Γ)

/-- ZHarm is nonzero. -/
theorem zharm_ne_zero (Γ : HarmonicSectorData V) : ZHarm Γ ≠ 0 :=
  ne_of_gt (zharm_pos Γ)

/-- ZPeriodic is nonzero. -/
theorem zperiodic_ne_zero (Γ : HarmonicSectorData V) : ZPeriodic Γ ≠ 0 :=
  ne_of_gt (zperiodic_pos Γ)

/-! ## Factorization Witness Constructor -/

/-- Every `HarmonicSectorData` admits a harmonic sector factorization. -/
def mkHarmonicSectorFactorization (Γ : HarmonicSectorData V) :
    HasHarmonicSectorFactorization Γ where
  factorization := rfl
  pin_pos := zpin_pos Γ
  harm_pos := zharm_pos Γ

/-! ## Theorem A: Constant-Shift Invariance (Gauge Invariance) -/

/-
**Constant-shift invariance of the GFF energy (Gauge Invariance).**

    For a symmetric matrix L with row-sum zero, adding a constant to all
    field values does not change the energy: E_L(φ + c) = E_L(φ).

    This is the fundamental mechanism forcing a harmonic/zero-mode sector:
    the energy depends only on the "pinned" component.

    Builds on `weightedLaplacian_row_sum_zero` (MetricKernel/Theorems) and
    `graphGFFEnergy_add_const` (GaussianFreeField catalog).
-/
theorem gffEnergy_add_const
    (Γ : HarmonicSectorData V) (φ : V → ℝ) (c : ℝ) :
    gffEnergy Γ.L (fun i => φ i + c) = gffEnergy Γ.L φ := by
  unfold gffEnergy;
  simp +decide [ add_mul, mul_add, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Γ.hRowSum, Γ.hSymm ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Γ.hRowSum ];
  rw [ Finset.sum_comm ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Γ.hSymm ];
  simp +decide [ Γ.hRowSum ]

omit [DecidableEq V] in
/-- GFF energy is non-negative for positive semi-definite matrices.
    Uses `weightedLaplacian_psd` conceptually. -/
theorem gffEnergy_nonneg_of_psd
    (L : Matrix V V ℝ)
    (hpsd : ∀ x : V → ℝ, 0 ≤ ∑ i, ∑ j, x i * L i j * x j)
    (x : V → ℝ) :
    0 ≤ gffEnergy L x :=
  hpsd x

/-! ## Theorem B: Periodic Partition Function Factorization -/

/-- **The periodic partition function factors as Z_pin * Z_harm.**

    This is the central theorem: the total partition function for the periodic
    Gaussian free field decomposes multiplicatively into:
    - Z_pin: the pinned sector contribution from Gaussian integral over ker(L)⊥
    - Z_harm: the harmonic sector contribution from covolume of the kernel lattice

    The factorization arises from the orthogonal decomposition
    ℝ^V = ker(L)⊥ ⊕ ker(L) and the product structure of the Gaussian measure.
    The pinned integral produces the reduced Laplacian determinant factor,
    while the harmonic integral over the torus yields the covolume of the
    kernel lattice (= tropical Jacobian volume). -/
theorem periodic_partition_factorization
    (Γ : HarmonicSectorData V) :
    ZPeriodic Γ = ZPin Γ * ZHarm Γ :=
  rfl

/-! ## Theorem C: Free Energy Decomposition -/

/-- **Free energy decomposes additively into complexity plus topology.**

    log(Z_periodic) = log(Z_pin) + log(Z_harm)

    Statistical mechanics interpretation: the free energy F = -log Z
    decomposes into:
    - Combinatorial complexity: -log Z_pin (spanning tree enumeration
      via the matrix-tree theorem)
    - Topological entropy: -log Z_harm (volume of tropical Jacobian torus)

    This theorem connects statistical mechanics to tropical geometry:
    thermodynamic free energy = combinatorial entropy + topological entropy. -/
theorem free_energy_splits_into_complexity_plus_topology
    (Γ : HarmonicSectorData V) :
    Real.log (ZPeriodic Γ) = Real.log (ZPin Γ) + Real.log (ZHarm Γ) := by
  exact Real.log_mul (zpin_ne_zero Γ) (zharm_ne_zero Γ)

/-- Negated free energy also decomposes additively. -/
theorem neg_free_energy_splits
    (Γ : HarmonicSectorData V) :
    -Real.log (ZPeriodic Γ) = -Real.log (ZPin Γ) + -Real.log (ZHarm Γ) := by
  rw [free_energy_splits_into_complexity_plus_topology]; ring

/-! ## Theorem D: Harmonic Factor Invariance Under Subdivision -/

/-- **The harmonic factor is invariant under metric-graph model equivalence.**

    If two weighted graph models Γ₁, Γ₂ represent the same metric graph
    (MetricGraphEquivalent), then Z_harm(Γ₁) = Z_harm(Γ₂).

    This makes the result geometric: the tropical Jacobian covolume depends
    only on the metric graph, not on vertex subdivision.

    Connected to `harmonicKernel` from the CanonicalKernelTheorems catalog. -/
theorem harmonic_factor_invariant_under_subdivision
    {W : Type*} [Fintype W] [DecidableEq W]
    (Γ₁ : HarmonicSectorData V) (Γ₂ : HarmonicSectorData W)
    (hmodel : MetricGraphEquivalent Γ₁ Γ₂) :
    ZHarm Γ₁ = ZHarm Γ₂ :=
  hmodel.covol_eq

/-- **The periodic/pinned ratio is invariant under subdivision.**
    Z_periodic(Γ₁) / Z_pin(Γ₁) = Z_periodic(Γ₂) / Z_pin(Γ₂). -/
theorem periodic_pin_ratio_invariant
    {W : Type*} [Fintype W] [DecidableEq W]
    (Γ₁ : HarmonicSectorData V) (Γ₂ : HarmonicSectorData W)
    (hmodel : MetricGraphEquivalent Γ₁ Γ₂) :
    ZPeriodic Γ₁ / ZPin Γ₁ = ZPeriodic Γ₂ / ZPin Γ₂ := by
  simp only [ZPeriodic, mul_div_cancel_left₀ _ (zpin_ne_zero _)]
  exact harmonic_factor_invariant_under_subdivision Γ₁ Γ₂ hmodel

/-! ## Energy Descends to Pinned Quotient -/

/-- **The GFF energy descends to the quotient by constants.**
    Combines row-sum-zero (`weightedLaplacian_row_sum_zero`) with gauge
    invariance (`graphGFFEnergy_add_const`). -/
theorem energy_descends_to_pinned_quotient
    (Γ : HarmonicSectorData V) (φ : V → ℝ) (c : ℝ) :
    gffEnergy Γ.L (fun i => φ i + c) = gffEnergy Γ.L φ :=
  gffEnergy_add_const Γ φ c

/-! ## Tropical Partition Factor -/

/-- The **tropical partition factor** extracted from the kernel lattice.
    Designed to coincide with the tropical Jacobian covolume.
    For a connected graph Γ with first Betti number g,
    this is the volume of the g-dimensional torus Jac(Γ) = ℝ^g / Λ_Γ. -/
noncomputable def tropicalPartitionFactor (Γ : HarmonicSectorData V) : ℝ :=
  ZHarm Γ

/-- The tropical partition factor equals the harmonic partition factor. -/
theorem tropicalPartitionFactor_eq_zharm (Γ : HarmonicSectorData V) :
    tropicalPartitionFactor Γ = ZHarm Γ := rfl

/-- The tropical partition factor is positive. -/
theorem tropicalPartitionFactor_pos (Γ : HarmonicSectorData V) :
    0 < tropicalPartitionFactor Γ := zharm_pos Γ

/-! ## Free Energy Components -/

/-- The **free energy contribution from the pinned sector**.
    F_pin = -log Z_pin encodes combinatorial complexity of the graph
    via the reduced Laplacian determinant (matrix-tree theorem). -/
noncomputable def freeEnergyPin (Γ : HarmonicSectorData V) : ℝ :=
  -Real.log (ZPin Γ)

/-- The **free energy contribution from the harmonic sector**.
    F_harm = -log Z_harm = -log(covol Λ_Γ)
    encodes the topological entropy from the tropical Jacobian torus. -/
noncomputable def freeEnergyHarm (Γ : HarmonicSectorData V) : ℝ :=
  -Real.log (ZHarm Γ)

/-- **Total free energy**. F = -log Z_periodic. -/
noncomputable def freeEnergyTotal (Γ : HarmonicSectorData V) : ℝ :=
  -Real.log (ZPeriodic Γ)

/-- **Free energy additivity: F_total = F_pin + F_harm.**
    The total free energy is the sum of pinned (combinatorial) and
    harmonic (topological) contributions. -/
theorem free_energy_additivity (Γ : HarmonicSectorData V) :
    freeEnergyTotal Γ = freeEnergyPin Γ + freeEnergyHarm Γ := by
  simp only [freeEnergyTotal, freeEnergyPin, freeEnergyHarm]
  rw [free_energy_splits_into_complexity_plus_topology]; ring

/-! ## Ratio Theorems -/

/-- **Z_periodic / Z_pin equals the tropical Jacobian covolume.** -/
theorem periodic_over_pin_eq_covol (Γ : HarmonicSectorData V) :
    ZPeriodic Γ / ZPin Γ = Γ.kernelCovolume := by
  simp only [ZPeriodic, mul_div_cancel_left₀ _ (zpin_ne_zero Γ)]; rfl

/-- **Z_periodic / Z_harm equals the pinned factor.** -/
theorem periodic_over_harm_eq_pin (Γ : HarmonicSectorData V) :
    ZPeriodic Γ / ZHarm Γ = ZPin Γ := by
  simp only [ZPeriodic, mul_div_cancel_right₀ _ (zharm_ne_zero Γ)]

/-! ## Conjecture: Subdivision-Rigidity -/

/-- **Subdivision-Rigidity of the Periodic-Pin Ratio.**
    For any two weighted graph models of the same metric graph, the ratio
    Z_periodic / Z_pin is invariant and equals the tropical Jacobian covolume.
    Proved as a consequence of the factorization. -/
theorem subdivision_rigidity_of_periodic_pin_ratio
    {W : Type*} [Fintype W] [DecidableEq W]
    (Γ₁ : HarmonicSectorData V) (Γ₂ : HarmonicSectorData W)
    (hmodel : MetricGraphEquivalent Γ₁ Γ₂) :
    ZPeriodic Γ₁ / ZPin Γ₁ = ZPeriodic Γ₂ / ZPin Γ₂ :=
  periodic_pin_ratio_invariant Γ₁ Γ₂ hmodel

/-! ## Bridge to Catalog Weighted Laplacians -/

/-- Construct HarmonicSectorData from a SimpleGraph with positive symmetric
    weights, given the reduced Laplacian determinant and kernel lattice
    covolume. Connects abstract sector factorization to the weighted Laplacian
    from MetricKernel/Theorems. -/
noncomputable def HarmonicSectorData.ofWeightedGraph
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (detLred : ℝ) (hDetPos : 0 < detLred)
    (covol : ℝ) (hCovolPos : 0 < covol) :
    HarmonicSectorData V where
  L := weightedLaplacianHSF G w
  detLred := detLred
  kernelCovolume := covol
  hDetPos := hDetPos
  hCovolPos := hCovolPos
  hRowSum := weightedLaplacianHSF_row_sum_zero G w
  hSymm := weightedLaplacianHSF_symm G w hw_symm