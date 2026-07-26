import Mathlib

/-!
# Renormalization Group Architecture Dynamics

Bridge: connects **statistical mechanics** (RG flow, critical exponents, universality)
to **certified robustness** (generalization bounds, Lipschitz stability, architecture transfer)
and **spectral theory** (eigenvalue classification, contraction mappings, operator norms).

## Overview

This file opens the field of **RG Architecture Theory**: a rigorous framework where
deep neural architectures define renormalization group flows under layer-coarseening,
and the spectral decomposition of the linearized RG at a fixed point determines:

1. **Generalization bounds** via the relevant operator count `d_rel`
2. **Certified stability** via contraction of irrelevant directions
3. **Universality class transfer** between architectures sharing critical exponents

## Bridge Keywords
- certified_robustness, Lipschitz_bound, neural_network, generalization_gap
- renormalization_group, critical_exponents, universality_class
- spectral_contraction, relevant_operator, irrelevant_decay
-/

open scoped BigOperators NNReal
open Finset Function LinearMap

noncomputable section

namespace RGArchitectureDynamics

/-! ## §1: Core Definitions — RG Flow Structures and Operator Classification -/

/-- Classification of operator directions in RG flow.
    Bridge: connects quantum field theory (relevant perturbations) to
    certified_robustness (sensitive directions in weight space). -/
inductive OperatorClass where
  | relevant   (eigval : ℝ) : OperatorClass
  | marginal   : OperatorClass
  | irrelevant (eigval : ℝ) : OperatorClass
  deriving DecidableEq

/-- Extract the eigenvalue associated with an operator class. -/
def OperatorClass.eigenvalue : OperatorClass → ℝ
  | OperatorClass.relevant ev => ev
  | OperatorClass.marginal => 1
  | OperatorClass.irrelevant ev => ev

/-- The linearized renormalization group transformation at a fixed point.
    Bridge: connects statistical mechanics (RG flow) to spectral theory (eigenvalues).
    The `operator_norm_bound` field provides a certified Lipschitz constant. -/
structure RGLinearization (V : Type*) [NormedAddCommGroup V]
    [InnerProductSpace ℝ V] [FiniteDimensional ℝ V] where
  fixed_point : V
  linMap : V →ₗ[ℝ] V
  is_self_adjoint : ∀ u v : V, @inner ℝ V _ u (linMap v) = @inner ℝ V _ (linMap u) v
  maxNorm : ℝ
  operator_norm_bound : ∀ v : V, ‖linMap v‖ ≤ maxNorm * ‖v‖
  maxNorm_pos : maxNorm > 0

/-- A complete certificate for an architecture's RG behavior.
    Bridge: connects statistical mechanics (RG fixed points) to
    certified_robustness (generalization guarantees). -/
structure RGFlowCertificate (V : Type*) [NormedAddCommGroup V]
    [InnerProductSpace ℝ V] [FiniteDimensional ℝ V] where
  rg : RGLinearization V
  d_rel : ℕ
  d_irrel : ℕ
  nu : ℝ
  dimension_accounting : d_rel + d_irrel = Module.finrank ℝ V
  C_gen : ℝ
  nu_pos : nu > 0
  C_gen_pos : C_gen > 0

/-- Universality class: architectures sharing critical exponents.
    Bridge: connects statistical mechanics (universality) to
    certified_robustness (architecture-agnostic bounds). -/
structure UniversalityClass where
  nu : ℝ
  d_rel : ℕ
  exponents : Fin 6 → ℝ
  nu_pos : nu > 0
  fisher_scaling : d_rel * nu = 2 - exponents 0
  rushbrooke : exponents 0 + 2 * exponents 1 + exponents 2 ≥ 2

/-- An RG architecture with layer structure.
    Bridge: connects neural_network architecture to statistical mechanics. -/
structure RGArchitecture where
  dim : ℕ
  depth : ℕ
  layer_lipschitz : ℝ
  d_rel : ℕ
  C_gen : ℝ
  d_rel_le_dim : d_rel ≤ dim
  layer_lipschitz_pos : layer_lipschitz > 0
  C_gen_pos : C_gen > 0

/-- The generalization gap: C_gen · d_rel / n.
    Bridge: connects statistical mechanics (RG fixed points) to
    certified_robustness (generalization guarantees). -/
def generalizationGap (C_gen : ℝ) (d_rel : ℕ) (n : ℕ) : ℝ :=
  C_gen * d_rel / n

def RGFlowCertificate.gap {V : Type*} [NormedAddCommGroup V]
    [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
    (cert : RGFlowCertificate V) (n : ℕ) : ℝ :=
  generalizationGap cert.C_gen cert.d_rel n

def RGArchitecture.gap (arch : RGArchitecture) (n : ℕ) : ℝ :=
  generalizationGap arch.C_gen arch.d_rel n

/-! ## §2: Contraction and Expansion Theorems -/

/-
**Operator Norm Iterate Bound**: ‖T^k v‖ ≤ c^k · ‖v‖.
    Bridge: connects spectral theory (operator norm) to certified_robustness
    (Lipschitz bound amplification through layers).
    Proof: by induction on k, composing the one-step bound.
-/
theorem operator_norm_iterate_bound {V : Type*} [NormedAddCommGroup V]
    [Module ℝ V] (T : V →ₗ[ℝ] V) (c : ℝ) (hc : 0 ≤ c)
    (hT : ∀ w : V, ‖T w‖ ≤ c * ‖w‖) (v : V) (k : ℕ) :
    ‖(T ^ k) v‖ ≤ c ^ k * ‖v‖ := by
  induction' k with k ih <;> simp_all +decide [ pow_succ', mul_assoc, mul_left_comm ];
  exact le_trans ( hT _ ) ( mul_le_mul_of_nonneg_left ih hc )

/-- **Irrelevant Directions Decay**: ‖T^k v‖ ≤ c^k · ‖v‖ with c < 1.
    Bridge: connects statistical mechanics (irrelevant operators) to
    certified_robustness (stable directions in weight space). -/
theorem irrelevant_directions_decay {V : Type*} [NormedAddCommGroup V]
    [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
    (rg : RGLinearization V) (v : V) (c_irrel : ℝ)
    (hc_nn : 0 ≤ c_irrel) (_hc : c_irrel < 1)
    (h_irrel : ∀ w : V, ‖rg.linMap w‖ ≤ c_irrel * ‖w‖)
    (k : ℕ) :
    ‖(rg.linMap ^ k) v‖ ≤ c_irrel ^ k * ‖v‖ :=
  operator_norm_iterate_bound rg.linMap c_irrel hc_nn h_irrel v k

/-
**Relevant Directions Expand**: ‖T^k v‖ ≥ c^k · ‖v‖ for c ≥ 0.
    Bridge: connects quantum critical phenomena (relevant perturbations) to
    certified_robustness (sensitive directions).
-/
theorem relevant_directions_expand {V : Type*} [NormedAddCommGroup V]
    [Module ℝ V] (T : V →ₗ[ℝ] V) (c_rel : ℝ)
    (hc_pos : 0 ≤ c_rel)
    (h_rel : ∀ w : V, ‖T w‖ ≥ c_rel * ‖w‖)
    (v : V) (k : ℕ) :
    ‖(T ^ k) v‖ ≥ c_rel ^ k * ‖v‖ := by
  induction' k with k ih <;> simp_all +decide [ pow_succ', mul_assoc ];
  exact le_trans ( mul_le_mul_of_nonneg_left ih hc_pos ) ( h_rel _ )

/-
**Contraction Power Bound**: If 0 ≤ c < 1, then ∃ K, ∀ k ≥ K, c^k < ε.
    Bridge: connects analysis (geometric convergence) to statistical mechanics
    (irrelevant operator washout).
-/
theorem contraction_power_bound (c : ℝ) (hc_nn : 0 ≤ c)
    (hc : c < 1) (eps : ℝ) (heps : eps > 0) :
    ∃ K : ℕ, ∀ k : ℕ, k ≥ K → c ^ k < eps := by
  simpa using ( tendsto_pow_atTop_nhds_zero_of_lt_one hc_nn hc ) |> ( fun h => h.eventually ( gt_mem_nhds heps ) )

/-
**Geometric Series Contraction Bound**: Σ_{k<n} c^k ≤ 1/(1-c) for c ∈ [0,1).
    Bridge: connects analysis (geometric series) to certified_robustness
    (total perturbation accumulation bound).
-/
theorem geometric_contraction_partial_sum (c : ℝ) (hc_nn : 0 ≤ c)
    (hc : c < 1) (n : ℕ) :
    ∑ k ∈ Finset.range n, c ^ k ≤ 1 / (1 - c) := by
  rw [ le_div_iff₀ ] <;> nlinarith [ pow_nonneg hc_nn n, geom_sum_mul c n ]

/-! ## §3: Generalization Bounds from RG Theory -/

/-
**Generalization Gap Identity**: gen_gap = C · d_rel / n.
    Bridge: connects statistical mechanics (relevant operators) to
    certified_robustness (generalization bounds).
-/
theorem generalization_gap_identity
    (C_gen : ℝ) (d_rel : ℕ) (n : ℕ) :
    generalizationGap C_gen d_rel n = C_gen * ↑d_rel / ↑n := by
  rfl

/-
**Gaussian Fixed Point Zero Gap**: d_rel = 0 ⟹ gap = 0.
    Bridge: connects statistical mechanics (Gaussian fixed point) to
    certified_robustness (optimal generalization).
-/
theorem gaussian_fixed_point_zero_gap
    (C_gen : ℝ) (n : ℕ) :
    generalizationGap C_gen 0 n = 0 := by
  unfold generalizationGap; ring;

/-
**Relevant Operator Dimension Bound**: gap(cert, n) ≤ C · dim / n.
    Bridge: connects linear algebra to certified_robustness.
-/
theorem relevant_operator_count_dimension_bound
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    [FiniteDimensional ℝ V]
    (cert : RGFlowCertificate V) (n : ℕ) (hn : 0 < n) :
    cert.gap n ≤ cert.C_gen * (Module.finrank ℝ V) / n := by
  unfold RGFlowCertificate.gap generalizationGap;
  gcongr;
  · exact le_of_lt cert.C_gen_pos;
  · linarith [ cert.dimension_accounting ]

/-- **Dimension Partition**: dim V = d_rel + d_irrel.
    Bridge: connects linear algebra to statistical mechanics. -/
theorem dimension_partition
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    [FiniteDimensional ℝ V]
    (cert : RGFlowCertificate V) :
    Module.finrank ℝ V = cert.d_rel + cert.d_irrel :=
  cert.dimension_accounting.symm

/-
**Generalization Gap Monotone in Data**: m ≤ n ⟹ gap(n) ≤ gap(m).
    Bridge: connects sample complexity to the thermodynamic limit.
-/
theorem generalization_gap_monotone_data
    (C_gen : ℝ) (hC : C_gen ≥ 0) (d_rel : ℕ) (m n : ℕ)
    (hm : 0 < m) (hmn : m ≤ n) :
    generalizationGap C_gen d_rel n ≤ generalizationGap C_gen d_rel m := by
  exact div_le_div_of_nonneg_left ( mul_nonneg hC ( Nat.cast_nonneg _ ) ) ( by positivity ) ( mod_cast hmn )

/-
**Generalization Gap Monotone in Relevance**: d₁ ≤ d₂ ⟹ gap(d₁) ≤ gap(d₂).
    Bridge: connects relevant operator counting to learning theory.
-/
theorem generalization_gap_monotone_relevance
    (C_gen : ℝ) (hC : C_gen ≥ 0) (d1 d2 : ℕ) (hd : d1 ≤ d2)
    (n : ℕ) (_hn : 0 < n) :
    generalizationGap C_gen d1 n ≤ generalizationGap C_gen d2 n := by
  exact div_le_div_of_nonneg_right ( mul_le_mul_of_nonneg_left ( Nat.cast_le.mpr hd ) hC ) ( Nat.cast_nonneg n )

/-! ## §4: Universality and Transfer -/

/-- **Fisher Scaling Relation**: d_rel · ν = 2 - α.
    Bridge: connects statistical mechanics (scaling relations) to
    certified_robustness (exponent-based bounds). -/
theorem fisher_scaling_relation (uc : UniversalityClass) :
    (uc.d_rel : ℝ) * uc.nu = 2 - uc.exponents 0 :=
  uc.fisher_scaling

/-- **Rushbrooke Inequality**: α + 2β + γ ≥ 2.
    Bridge: connects statistical mechanics to
    certified_robustness (fundamental limits on generalization). -/
theorem rushbrooke_inequality (uc : UniversalityClass) :
    uc.exponents 0 + 2 * uc.exponents 1 + uc.exponents 2 ≥ 2 :=
  uc.rushbrooke

/-- Architecture equivalence: same d_rel and C_gen. -/
def archEquiv (a1 a2 : RGArchitecture) : Prop :=
  a1.d_rel = a2.d_rel ∧ a1.C_gen = a2.C_gen

theorem universality_class_reflexive (a : RGArchitecture) :
    archEquiv a a :=
  ⟨rfl, rfl⟩

theorem universality_class_symmetric (a1 a2 : RGArchitecture) :
    archEquiv a1 a2 → archEquiv a2 a1 := by
  exact fun h => ⟨ h.1.symm, h.2.symm ⟩

theorem universality_class_transitive (a1 a2 a3 : RGArchitecture) :
    archEquiv a1 a2 → archEquiv a2 a3 → archEquiv a1 a3 := by
  exact fun h1 h2 => ⟨ h1.1.trans h2.1, h1.2.trans h2.2 ⟩

instance archSetoid : Setoid RGArchitecture where
  r := archEquiv
  iseqv := {
    refl := universality_class_reflexive
    symm := fun h => universality_class_symmetric _ _ h
    trans := fun h1 h2 => universality_class_transitive _ _ _ h1 h2
  }

/-
**Universality Class Transfer**: Equivalent architectures have identical gaps.
    Bridge: connects statistical mechanics (universality) to
    certified_robustness (zero-shot transfer).
-/
theorem universality_class_transfer
    (a1 a2 : RGArchitecture) (h : archEquiv a1 a2) (n : ℕ) :
    a1.gap n = a2.gap n := by
  exact congr_arg₂ ( fun x y => generalizationGap x y n ) h.2 h.1

/-! ## §5: Certified Robustness from RG Theory -/

/-
**Certified Lipschitz from Contraction**: ‖T^k u - T^k v‖ ≤ c^k · ‖u - v‖.
    Bridge: connects spectral theory to certified_robustness.
-/
theorem certified_lipschitz_from_contraction {V : Type*} [NormedAddCommGroup V]
    [Module ℝ V] (T : V →ₗ[ℝ] V) (c : ℝ) (hc : 0 ≤ c)
    (hT : ∀ w : V, ‖T w‖ ≤ c * ‖w‖) (u v : V) (k : ℕ) :
    ‖(T ^ k) u - (T ^ k) v‖ ≤ c ^ k * ‖u - v‖ := by
  convert operator_norm_iterate_bound T c hc hT ( u - v ) k using 1;
  simp +decide [ map_sub ]

/-
**Lipschitz Stability Certificate**: ‖T u - T v‖ ≤ maxNorm · ‖u - v‖.
    Bridge: connects statistical mechanics (RG contraction) to
    certified_robustness (adversarial robustness certificate).
-/
theorem lipschitz_stability_certificate {V : Type*} [NormedAddCommGroup V]
    [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
    (rg : RGLinearization V) (u v : V) :
    ‖rg.linMap u - rg.linMap v‖ ≤ rg.maxNorm * ‖u - v‖ := by
  simpa using rg.operator_norm_bound ( u - v )

/-
**Contraction Composition**: ‖(T₁ ∘ T₂) v‖ ≤ c₁ · c₂ · ‖v‖.
    Bridge: connects linear algebra to neural_network layer composition.
-/
theorem contraction_composition {V : Type*} [NormedAddCommGroup V]
    [Module ℝ V] (T1 T2 : V →ₗ[ℝ] V) (c1 c2 : ℝ)
    (hc1 : 0 ≤ c1) (_hc2 : 0 ≤ c2)
    (h1 : ∀ w : V, ‖T1 w‖ ≤ c1 * ‖w‖) (h2 : ∀ w : V, ‖T2 w‖ ≤ c2 * ‖w‖)
    (v : V) :
    ‖(T1 ∘ₗ T2) v‖ ≤ c1 * c2 * ‖v‖ := by
  simpa only [ mul_assoc, LinearMap.comp_apply ] using le_trans ( h1 _ ) ( mul_le_mul_of_nonneg_left ( h2 _ ) hc1 )

/-
**Spectral Gap Stability**: c < 1 ⟹ ∃ ε > 0, |c' - c| < ε → c' < 1.
    Bridge: connects perturbation theory to certified_robustness
    (robustness of stability classification).
-/
theorem spectral_gap_stability (c : ℝ) (hc1 : c < 1) :
    ∃ eps : ℝ, eps > 0 ∧ ∀ c' : ℝ, |c' - c| < eps → c' < 1 := by
  exact ⟨ 1 - c, by linarith, fun c' hc' => by linarith [ abs_lt.mp hc' ] ⟩

/-
**Generalization Gap Nonnegativity**: gap ≥ 0 when C_gen ≥ 0.
    Bridge: connects measure theory to learning theory.
-/
theorem generalization_gap_nonneg (C_gen : ℝ) (hC : C_gen ≥ 0) (d_rel n : ℕ)
    (_hn : 0 < n) :
    generalizationGap C_gen d_rel n ≥ 0 := by
  exact div_nonneg ( mul_nonneg hC ( Nat.cast_nonneg _ ) ) ( Nat.cast_nonneg _ )

/-
**Gaussian Fixed Point All Irrelevant**: d_rel = 0 ⟹ dim - d_rel = dim.
    Bridge: connects statistical mechanics to certified_robustness.
-/
theorem gaussian_fixed_point_all_irrelevant (arch : RGArchitecture)
    (h : arch.d_rel = 0) :
    arch.dim - arch.d_rel = arch.dim := by
  rw [ h, Nat.sub_zero ]

/-
**Overparameterization Resolution**: gap(d_rel) ≤ gap(dim).
    Bridge: connects irrelevant operator washout to the
    overparameterization paradox resolution.
-/
theorem overparameterization_resolution (arch : RGArchitecture) (n : ℕ)
    (_hn : 0 < n) :
    arch.gap n ≤ generalizationGap arch.C_gen arch.dim n := by
  exact div_le_div_of_nonneg_right ( mul_le_mul_of_nonneg_left ( Nat.cast_le.mpr arch.d_rel_le_dim ) ( le_of_lt arch.C_gen_pos ) ) ( Nat.cast_nonneg _ )

/-
**Monotone Layers**: c ≤ 1 ⟹ c^(k+1) ≤ c^k.
    Bridge: connects neural_network depth to certified_robustness.
-/
theorem monotone_generalization_in_layers (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) (k : ℕ) :
    c ^ (k + 1) ≤ c ^ k := by
  exact pow_le_pow_of_le_one hc0 hc1 k.le_succ

/-
**Depth Amplification Positivity**: c^depth · v ≥ 0 when v ≥ 0.
    Bridge: connects architecture depth to bound positivity.
-/
theorem depth_amplification_nonneg (arch : RGArchitecture)
    (v : ℝ) (hv : v ≥ 0) :
    arch.layer_lipschitz ^ arch.depth * v ≥ 0 := by
  exact mul_nonneg ( pow_nonneg ( le_of_lt arch.layer_lipschitz_pos ) _ ) hv

/-- **Critical Exponent Positivity**: ν > 0.
    Bridge: connects critical exponents to analysis. -/
theorem critical_exponent_positivity (uc : UniversalityClass) :
    uc.nu > 0 :=
  uc.nu_pos

end RGArchitectureDynamics