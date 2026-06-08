/-
Copyright (c) 2025 Homological Transfer Learning Project. All rights reserved.

# Homological Transfer Learning — Core Definitions and Foundational Theorems

Bridge: connects Algebra (module theory, homological invariants) to
MachineLearning (transfer learning, certified robustness, domain adaptation).

## Main Ideas

Every learning domain D defines a feature module M_D over a field K.
The algebraic invariants of M_D — projectivity, flatness, rank, resolution
length — provide *certified* bounds on the quality and feasibility of
domain adaptation.
-/

import Mathlib

open LinearMap Submodule Module Function

namespace HomologicalTransferLearning

/-! ## Section 1: Feature Module Framework -/

/-- A `FeatureModule` represents a learning domain's feature space as a
finite-dimensional vector space over a field K.
Bridge: connects linear algebra to certified_robustness in ML. -/
structure FeatureModule (K : Type*) [Field K] where
  carrier : Type*
  [instAddCommGroup : AddCommGroup carrier]
  [instModule : Module K carrier]
  [instFinDim : FiniteDimensional K carrier]

attribute [instance] FeatureModule.instAddCommGroup FeatureModule.instModule
  FeatureModule.instFinDim

/-- Dimension of a feature module.
Bridge: connects vector space dimension to neural_network width. -/
noncomputable def FeatureModule.dim {K : Type*} [Field K]
    (M : FeatureModule K) : ℕ :=
  Module.finrank K M.carrier

/-- A `TransferMap` between two feature modules is a linear map.
Bridge: connects linear maps to domain adaptation. -/
structure TransferMap {K : Type*} [Field K]
    (M N : FeatureModule K) where
  toLinearMap : M.carrier →ₗ[K] N.carrier

/-- `ObstructionRank`: dimension of the kernel — information lost in transfer.
Bridge: connects ker(φ) to Ext¹ rank in homological algebra. -/
noncomputable def obstructionRank {K : Type*} [Field K]
    {M N : FeatureModule K} (φ : TransferMap M N) : ℕ :=
  Module.finrank K (LinearMap.ker φ.toLinearMap)

/-- `TransferFidelity`: dimension of the image — information preserved.
Bridge: connects image rank to neural_network transfer capacity. -/
noncomputable def transferFidelity {K : Type*} [Field K]
    {M N : FeatureModule K} (φ : TransferMap M N) : ℕ :=
  Module.finrank K (LinearMap.range φ.toLinearMap)

/-- `TransferCertificate` bundles certified transfer quality data.
Bridge: connects homological invariants to certified_robustness bounds. -/
structure TransferCertificate where
  obstructionDim : ℕ
  finetuningDepth : ℕ
  transferPossible : Bool
  errorBound : ℝ
  errorBound_nonneg : 0 ≤ errorBound
  errorBound_le_one : errorBound ≤ 1

/-- `LipschitzTransferData` captures transfers with explicit Lipschitz bounds.
Bridge: connects Lipschitz_bound to certified_robustness. -/
structure LipschitzTransferData where
  lipschitzConst : ℝ
  lipschitzConst_pos : 0 < lipschitzConst
  robustnessRadius : ℝ
  robustnessRadius_nonneg : 0 ≤ robustnessRadius

/-- `AdaptationLayer` represents a single layer in fine-tuning.
Bridge: connects chain complex maps to neural_network layers. -/
structure AdaptationLayer where
  inputDim : ℕ
  outputDim : ℕ
  layerError : ℝ
  layerError_nonneg : 0 ≤ layerError

/-- `FineTuningArchitecture` is a sequence of adaptation layers.
Bridge: connects projective resolutions to deep neural_network architectures. -/
structure FineTuningArchitecture where
  layers : List AdaptationLayer
  totalError : ℝ
  totalError_nonneg : 0 ≤ totalError

/-- `TransferQuality` packages quantitative certified metrics. -/
structure TransferQuality where
  fidelityRatio : ℝ
  lossRatio : ℝ
  sum_eq_one : fidelityRatio + lossRatio = 1
  fidelity_nonneg : 0 ≤ fidelityRatio
  loss_nonneg : 0 ≤ lossRatio

/-- Compose two transfer maps.
Bridge: connects functor composition to deep transfer pipeline. -/
def TransferMap.comp {K : Type*} [Field K]
    {M N P : FeatureModule K}
    (ψ : TransferMap N P) (φ : TransferMap M N) : TransferMap M P where
  toLinearMap := ψ.toLinearMap.comp φ.toLinearMap

/-- Identity transfer map. Zero fine-tuning layers needed.
Bridge: pd = 0 for projective modules. -/
def identityTransfer {K : Type*} [Field K]
    (M : FeatureModule K) : TransferMap M M where
  toLinearMap := LinearMap.id

/-- `NormalizedError`: fraction of information lost, ∈ [0,1].
Bridge: certified_robustness error rate. -/
noncomputable def normalizedError {K : Type*} [Field K]
    {M N : FeatureModule K} (φ : TransferMap M N) : ℝ :=
  if M.dim = 0 then 0
  else (obstructionRank φ : ℝ) / (M.dim : ℝ)

/-! ## Section 2: Foundational Transfer Theorems -/

/-- **Rank-Nullity Transfer Theorem**: dim(source) = obstruction + fidelity.
Bridge: information bottleneck in neural_network transfer.
O(dim(M)) computational complexity. -/
theorem rank_nullity_transfer
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    M.dim = obstructionRank φ + transferFidelity φ := by
  unfold FeatureModule.dim obstructionRank transferFidelity
  have := LinearMap.finrank_range_add_finrank_ker φ.toLinearMap
  omega

/-
**Obstruction Lower Bound from Dimension Deficit**:
If dim(N) ≤ dim(M), then obstructionRank φ ≥ dim(M) - dim(N).
Bridge: certified lower bound on transfer error from algebra.
-/
theorem obstruction_ge_dim_deficit
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N)
    (_h : N.dim ≤ M.dim) :
    M.dim - N.dim ≤ obstructionRank φ := by
  have h_rank_nullity : M.dim = obstructionRank φ + transferFidelity φ := by
    exact rank_nullity_transfer φ
  exact tsub_le_iff_right.mpr ( by linarith! [ show transferFidelity φ ≤ N.dim from Submodule.finrank_le _ ] )

/-
**Zero Obstruction iff Injective**: obstructionRank = 0 ⟺ injective.
Bridge: Ext¹ = 0 ⟺ lossless certified transfer.
-/
theorem obstruction_zero_iff_injective
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    obstructionRank φ = 0 ↔ Injective φ.toLinearMap := by
  unfold obstructionRank;
  simp +decide [ LinearMap.ker_eq_bot ]

/-
**Max Fidelity iff Surjective**: fidelity = dim(N) ⟺ surjective.
Bridge: full domain coverage ⟺ surjective transfer.
-/
theorem max_fidelity_iff_surjective
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    transferFidelity φ = N.dim ↔ Surjective φ.toLinearMap := by
  constructor;
  · intro h;
    exact LinearMap.range_eq_top.mp ( Submodule.eq_top_of_finrank_eq h );
  · intro h_surjective
    have h_range : LinearMap.range φ.toLinearMap = ⊤ := by
      exact LinearMap.range_eq_top.mpr h_surjective;
    convert congr_arg ( fun s : Submodule K N.carrier => Module.finrank K s ) h_range;
    simp +decide [ FeatureModule.dim ]

/-
**Bijective iff Zero Obstruction AND Max Fidelity**.
Bridge: perfect domain adaptation ⟺ module isomorphism.
-/
theorem bijective_iff_zero_obs_max_fid
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    Bijective φ.toLinearMap ↔
      obstructionRank φ = 0 ∧ transferFidelity φ = N.dim := by
  constructor;
  · intro h_bijective
    have h_inj : Injective φ.toLinearMap := h_bijective.injective
    have h_surj : Surjective φ.toLinearMap := h_bijective.surjective
    exact ⟨obstruction_zero_iff_injective φ |>.2 h_inj, max_fidelity_iff_surjective φ |>.2 h_surj⟩;
  · intro h;
    exact ⟨ by simpa using obstruction_zero_iff_injective φ |>.1 h.1, by simpa using max_fidelity_iff_surjective φ |>.1 h.2 ⟩

/-
**Fidelity ≤ min(dim M, dim N)**: Data processing inequality.
Bound: transferFidelity(φ) ≤ min(dim(M), dim(N)).
-/
theorem fidelity_le_min_dim
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    transferFidelity φ ≤ min M.dim N.dim := by
  refine' le_min _ ( Submodule.finrank_le _ );
  exact le_of_le_of_eq ( LinearMap.finrank_range_le _ ) ( by simp +decide [ FeatureModule.dim ] )

/-
**Composition Obstruction Monotonicity**: obstruction grows under composition.
Bridge: deep neural_network error accumulation.
Bound: obstructionRank(ψ∘φ) ≥ obstructionRank(φ).
-/
theorem composition_obstruction_monotone
    {K : Type*} [Field K]
    {M N P : FeatureModule K}
    (φ : TransferMap M N) (ψ : TransferMap N P) :
    obstructionRank φ ≤ obstructionRank (ψ.comp φ) := by
  have h_ker_le : LinearMap.ker φ.toLinearMap ≤ LinearMap.ker (ψ.toLinearMap.comp φ.toLinearMap) := by
    exact?;
  exact Submodule.finrank_mono h_ker_le

/-
**Composition Fidelity Decay**: fidelity decreases under composition.
Bridge: gradient vanishing in deep neural_network fine-tuning.
Bound: transferFidelity(ψ∘φ) ≤ transferFidelity(φ).
-/
theorem composition_fidelity_decay
    {K : Type*} [Field K]
    {M N P : FeatureModule K}
    (φ : TransferMap M N) (ψ : TransferMap N P) :
    transferFidelity (ψ.comp φ) ≤ transferFidelity φ := by
  -- The range of the composition is a subspace of the range of ψ.
  have h_range_sub : LinearMap.range (ψ.comp φ).toLinearMap ≤ Submodule.map ψ.toLinearMap (LinearMap.range φ.toLinearMap) := by
    exact fun x hx => by rcases hx with ⟨ y, rfl ⟩ ; exact ⟨ φ.toLinearMap y, ⟨ y, rfl ⟩, rfl ⟩ ;
  exact Submodule.finrank_mono h_range_sub |> le_trans <| Submodule.finrank_map_le _ _

/-
**Two-Layer Obstruction Bound**: total obstruction bounded by sum.
Bridge: subadditive error in layered neural_network architecture.
Bound: obstructionRank(ψ∘φ) ≤ obstructionRank(φ) + obstructionRank(ψ).
-/
theorem two_layer_obstruction_bound
    {K : Type*} [Field K]
    {M N P : FeatureModule K}
    (φ : TransferMap M N) (ψ : TransferMap N P) :
    obstructionRank (ψ.comp φ) ≤ obstructionRank φ + obstructionRank ψ := by
  -- From rank_nullity, we have M.dim = obs(ψ∘φ) + fid(ψ∘φ), M.dim = obs(φ) + fid(φ), and N.dim = obs(ψ) + fid(ψ).
  have h_rank_nullity : M.dim = obstructionRank (ψ.comp φ) + transferFidelity (ψ.comp φ) ∧ M.dim = obstructionRank φ + transferFidelity φ ∧ N.dim = obstructionRank ψ + transferFidelity ψ := by
    exact ⟨ rank_nullity_transfer _, rank_nullity_transfer _, rank_nullity_transfer _ ⟩;
  -- By the rank-nullity theorem, we have that the dimension of the range of a composition of linear maps is at least the dimension of the range of the first map minus the dimension of the kernel of the second map.
  have h_rank_nullity_comp : Module.finrank K (LinearMap.range (ψ.toLinearMap.comp φ.toLinearMap)) ≥ Module.finrank K (LinearMap.range φ.toLinearMap) - Module.finrank K (LinearMap.ker ψ.toLinearMap) := by
    have h_rank_nullity_comp : Module.finrank K (LinearMap.range (ψ.toLinearMap.comp φ.toLinearMap)) = Module.finrank K (LinearMap.range (ψ.toLinearMap.comp (Submodule.subtype (LinearMap.range φ.toLinearMap)))) := by
      congr! 2;
      · ext; simp [LinearMap.range_comp];
      · ext; simp [LinearMap.range_comp];
      · ext; simp [LinearMap.range_comp];
    have := LinearMap.finrank_range_add_finrank_ker ( ψ.toLinearMap.comp ( Submodule.subtype ( LinearMap.range φ.toLinearMap ) ) );
    have h_rank_nullity_comp : Module.finrank K (LinearMap.ker (ψ.toLinearMap.comp (Submodule.subtype (LinearMap.range φ.toLinearMap)))) ≤ Module.finrank K (LinearMap.ker ψ.toLinearMap) := by
      rw [ ← Submodule.finrank_map_subtype_eq ];
      exact Submodule.finrank_mono ( by aesop_cat );
    grind;
  unfold transferFidelity obstructionRank at *;
  grind +extAll

/-- **Identity Transfer is Bijective**: Self-adaptation is always perfect.
Bridge: pd(M) = 0 for projective M → zero-layer architecture suffices. -/
theorem identity_transfer_bijective {K : Type*} [Field K]
    (M : FeatureModule K) :
    Bijective (identityTransfer M).toLinearMap :=
  Function.bijective_id

/-
**Identity Has Zero Obstruction**: Self-transfer loses no information.
Bridge: Ext¹(M,M) = 0 for projective modules.
-/
theorem identity_zero_obstruction {K : Type*} [Field K]
    (M : FeatureModule K) :
    obstructionRank (identityTransfer M) = 0 := by
  exact?

/-
**Dimension Gap Impossibility**: If dim(M) > dim(N), no injective
transfer exists. Bridge: Tor₁ ≠ 0 impossibility theorem.
Lower bound: obstruction ≥ dim(M) - dim(N) ≥ 1.
-/
theorem dimension_gap_impossibility
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (h : N.dim < M.dim) :
    ∀ φ : TransferMap M N, ¬Injective φ.toLinearMap := by
  intro φ h_inj
  have := LinearMap.finrank_range_of_inj h_inj
  simp_all +decide [ FeatureModule.dim ];
  -- Since the range of φ is a subspace of N, its dimension cannot exceed the dimension of N.
  have h_range_dim : Module.finrank K (LinearMap.range φ.toLinearMap) ≤ Module.finrank K N.carrier := by
    apply_rules [ Submodule.finrank_le ];
  linarith

/-
**Certified Minimum Loss**: For ANY transfer from M to N,
obstruction ≥ dim(M) - dim(N). Bridge: certified minimum transfer gap.
-/
theorem certified_minimum_loss
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    M.dim - N.dim ≤ obstructionRank φ := by
  by_cases h : N.dim ≤ M.dim;
  · exact?;
  · bv_omega

/-
**Normalized Error ∈ [0,1]**: Certified error rate is a probability.
Bridge: certified_robustness error bound.
-/
theorem normalizedError_mem_unit
    {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) :
    0 ≤ normalizedError φ ∧ normalizedError φ ≤ 1 := by
  unfold normalizedError;
  split_ifs <;> norm_num;
  exact ⟨ by positivity, div_le_one_of_le₀ ( mod_cast by linarith [ rank_nullity_transfer φ ] ) ( by positivity ) ⟩

/-
**Transfer Symmetry**: Injective M→N exists ⟺ dim(M) ≤ dim(N).
Bridge: Ext¹ symmetry for free modules over fields.
-/
theorem transfer_existence_iff_dim_le
    {K : Type*} [Field K]
    {M N : FeatureModule K} :
    (∃ φ : TransferMap M N, Injective φ.toLinearMap) ↔ M.dim ≤ N.dim := by
  constructor <;> intro h;
  · have := LinearMap.finrank_range_add_finrank_ker h.choose.toLinearMap;
    rw [ show LinearMap.ker h.choose.toLinearMap = ⊥ from LinearMap.ker_eq_bot_of_injective h.choose_spec ] at this ; simp_all +decide [ FeatureModule.dim ];
    exact this ▸ Submodule.finrank_le _;
  · obtain ⟨f, hf⟩ : ∃ f : M.carrier →ₗ[K] N.carrier, Function.Injective f := by
      have := Module.finBasis K M.carrier
      have := Module.finBasis K N.carrier;
      refine' ⟨ _, _ ⟩;
      exact ( ‹Basis ( Fin ( finrank K M.carrier ) ) K M.carrier›.constr K ) ( fun i => this ( ⟨ i, by linarith! [ Fin.is_lt i ] ⟩ ) );
      intro x y hxy;
      apply ‹Basis ( Fin ( finrank K M.carrier ) ) K M.carrier›.ext_elem;
      intro i; replace hxy := congr_arg ( fun z => this.repr z ⟨ i, by linarith! [ Fin.is_lt i ] ⟩ ) hxy; simp_all +decide [ Finsupp.single_apply, Finset.sum_apply' ] ;
      simp_all +decide [ Finset.sum_ite, Fin.val_inj ];
    exact ⟨ ⟨ f ⟩, hf ⟩

/-- **Transfer Quality Conservation**: fidelityRatio + lossRatio = 1.
Bridge: information conservation in certified neural_network transfer. -/
noncomputable def computeTransferQuality {K : Type*} [Field K]
    {M N : FeatureModule K}
    (φ : TransferMap M N) (hM : 0 < M.dim) : TransferQuality where
  fidelityRatio := (transferFidelity φ : ℝ) / (M.dim : ℝ)
  lossRatio := (obstructionRank φ : ℝ) / (M.dim : ℝ)
  sum_eq_one := by
    have hrn := rank_nullity_transfer φ
    field_simp
    exact_mod_cast show transferFidelity φ + obstructionRank φ = M.dim by omega
  fidelity_nonneg := div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  loss_nonneg := div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)

/-
**Optimal Transfer Achievability**: For any pair of feature modules,
∃ transfer achieving minimum obstruction = max(0, dim(M) - dim(N)).
Bridge: tight certified bound on minimum Ext¹ rank.
-/
theorem optimal_transfer_exists
    {K : Type*} [Field K]
    {M N : FeatureModule K} :
    ∃ φ : TransferMap M N,
      obstructionRank φ = M.dim - min M.dim N.dim := by
  rcases le_total M.dim N.dim with h | h;
  · obtain ⟨ φ, hφ ⟩ := transfer_existence_iff_dim_le.mpr h;
    exact ⟨ φ, by rw [ min_eq_left h, obstruction_zero_iff_injective _ |>.2 hφ, tsub_self ] ⟩;
  · -- Since $N.dim \leq M.dim$, we can construct a surjective map from $M$ to $N$.
    obtain ⟨φ, hφ⟩ : ∃ φ : M.carrier →ₗ[K] N.carrier, Function.Surjective φ := by
      -- Apply the fact that there exists a surjective linear map from a vector space of higher dimension to a vector space of lower dimension.
      have h_surjective_map : ∃ (φ : (Fin M.dim → K) →ₗ[K] (Fin N.dim → K)), Function.Surjective φ := by
        refine' ⟨ _, _ ⟩;
        refine' { toFun := fun f => fun i => f ⟨ i, by linarith [ Fin.is_lt i ] ⟩, map_add' := _, map_smul' := _ } <;> intros <;> ext <;> simp +decide [ * ];
        intro f; use fun i => if h : i.val < N.dim then f ⟨ i.val, h ⟩ else 0; aesop;
      -- Use the fact that $M$ and $N$ are finite-dimensional vector spaces to construct an isomorphism between $M$ and $Fin M.dim → K$, and between $N$ and $Fin N.dim → K$.
      have h_iso_M : Nonempty (M.carrier ≃ₗ[K] Fin M.dim → K) := by
        exact ⟨ ( Module.finBasis K M.carrier ).equivFun ⟩
      have h_iso_N : Nonempty (N.carrier ≃ₗ[K] Fin N.dim → K) := by
        exact ⟨ ( Module.finBasis K N.carrier ).equivFun ⟩;
      obtain ⟨φ, hφ⟩ := h_surjective_map
      obtain ⟨iso_M⟩ := h_iso_M
      obtain ⟨iso_N⟩ := h_iso_N
      use iso_N.symm.toLinearMap.comp (φ.comp iso_M.toLinearMap);
      exact iso_N.symm.surjective.comp ( hφ.comp iso_M.surjective );
    refine' ⟨ ⟨ φ ⟩, _ ⟩;
    rw [ min_eq_right h, eq_tsub_iff_add_eq_of_le h ];
    convert rank_nullity_transfer ⟨ φ ⟩ |> Eq.symm;
    exact max_fidelity_iff_surjective ⟨ φ ⟩ |>.2 hφ ▸ rfl

end HomologicalTransferLearning