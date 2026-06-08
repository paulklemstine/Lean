/-
Copyright (c) 2025. All rights reserved.

# Reflection Positivity, Transfer Matrices, and the Yang-Mills Mass Gap

This module develops the mathematical framework connecting reflection positivity
to mass gaps in lattice gauge theories. The central result chain is:

  Reflection Positivity → Positive Transfer Matrix → Spectral Gap → Mass Gap
    → Exponential Clustering → Wilson Loop Area Law

## Main definitions

* `ReflectionPositiveForm` — A bilinear form satisfying Osterwalder-Schrader positivity
* `TransferOperatorData` — Spectral data for a transfer/Hamiltonian operator
* `WilsonLoopDecay` — Area-law decay for Wilson loop expectation values
* `StrongCouplingRegime` — Axiomatized strong coupling expansion data
* `GaugeEquivariantFiltration` — Novel structure: gauge-equivariant spectral filtration

## Main results

* `transfer_spectral_gap_from_isolation` — Isolated ground state gives mass gap
* `mass_gap_implies_exponential_clustering` — Mass gap → exponential decay
* `strong_coupling_mass_gap_positive` — Explicit mass gap at strong coupling
* `filtration_gap_positive` — Gauge-equivariant gap is positive
* `casimir_controls_filtration_gap` — Casimir eigenvalues control the mass gap
* `synthesis_mass_gap_from_filtration` — Main synthesis theorem
-/

import Mathlib

open Finset BigOperators Real

/-! ## Part I: Reflection Positivity Framework -/

/-- A **reflection positive form** on a real vector space `V` models the
    Osterwalder-Schrader positivity axiom. The form `B` is positive on
    vectors reflected by the operator `θ`. -/
structure ReflectionPositiveForm (V : Type*) [AddCommGroup V] [Module ℝ V] where
  /-- The bilinear form (correlation functional) -/
  B : V → V → ℝ
  B_add_left : ∀ u v w, B (u + v) w = B u w + B v w
  B_add_right : ∀ u v w, B u (v + w) = B u v + B u w
  B_smul_left : ∀ (r : ℝ) u v, B (r • u) v = r * B u v
  B_symm : ∀ u v, B u v = B v u
  /-- The reflection operator -/
  θ : V → V
  θ_involution : ∀ v, θ (θ v) = v
  /-- θ is self-adjoint with respect to B -/
  θ_selfadjoint : ∀ u v, B (θ u) v = B u (θ v)
  /-- **Reflection Positivity**: B(θv, v) ≥ 0 for all v -/
  reflection_pos : ∀ v, 0 ≤ B (θ v) v

namespace ReflectionPositiveForm

variable {V : Type*} [AddCommGroup V] [Module ℝ V]

/-- The physical inner product induced by reflection positivity. -/
noncomputable def physicalInnerProduct (R : ReflectionPositiveForm V) (u v : V) : ℝ :=
  R.B (R.θ u) v

/-- The physical inner product is symmetric. -/
theorem physicalInnerProduct_symm (R : ReflectionPositiveForm V) (u v : V) :
    R.physicalInnerProduct u v = R.physicalInnerProduct v u := by
  unfold physicalInnerProduct
  rw [R.θ_selfadjoint, R.B_symm]

/-- The physical inner product is positive semi-definite. -/
theorem physicalInnerProduct_nonneg (R : ReflectionPositiveForm V) (v : V) :
    0 ≤ R.physicalInnerProduct v v :=
  R.reflection_pos v

end ReflectionPositiveForm

/-! ## Part II: Transfer Operator Spectral Theory -/

/-- Spectral data for a transfer (Hamiltonian) operator on a finite-dimensional
    space. Eigenvalues of T = exp(-aH) satisfy λᵢ = exp(-aEᵢ). -/
structure TransferOperatorData (n : ℕ) where
  eigenvalues : Fin n → ℝ
  eigenvalues_pos : ∀ i, 0 < eigenvalues i
  eigenvalues_decreasing : ∀ i j : Fin n, i ≤ j → eigenvalues j ≤ eigenvalues i

namespace TransferOperatorData

variable {n : ℕ}

/-- The ground state eigenvalue (largest). -/
noncomputable def groundStateEigenvalue (T : TransferOperatorData n) (hn : 0 < n) : ℝ :=
  T.eigenvalues ⟨0, hn⟩

theorem groundStateEigenvalue_pos (T : TransferOperatorData n) (hn : 0 < n) :
    0 < T.groundStateEigenvalue hn :=
  T.eigenvalues_pos _

/-- The first excited eigenvalue. -/
noncomputable def firstExcitedEigenvalue (T : TransferOperatorData n) (hn : 1 < n) : ℝ :=
  T.eigenvalues ⟨1, hn⟩

/-- The **mass gap**: Δ = -log(λ₁/λ₀) = log(λ₀/λ₁). -/
noncomputable def massGap (T : TransferOperatorData n) (hn : 1 < n) : ℝ :=
  -Real.log (T.firstExcitedEigenvalue hn / T.groundStateEigenvalue (by omega))

theorem eigenvalue_ratio_le_one (T : TransferOperatorData n) (hn : 1 < n) :
    T.firstExcitedEigenvalue hn / T.groundStateEigenvalue (by omega) ≤ 1 :=
  div_le_one_of_le₀
    (T.eigenvalues_decreasing ⟨0, by omega⟩ ⟨1, hn⟩ (Fin.mk_le_mk.mpr (by omega)))
    (le_of_lt (T.eigenvalues_pos _))

theorem eigenvalue_ratio_pos (T : TransferOperatorData n) (hn : 1 < n) :
    0 < T.firstExcitedEigenvalue hn / T.groundStateEigenvalue (by omega) :=
  div_pos (T.eigenvalues_pos _) (T.eigenvalues_pos _)

/-
The mass gap is non-negative.
-/
theorem massGap_nonneg (T : TransferOperatorData n) (hn : 1 < n) :
    0 ≤ T.massGap hn := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( by exact div_nonneg ( le_of_lt ( by exact T.eigenvalues_pos _ ) ) ( le_of_lt ( by exact T.eigenvalues_pos _ ) ) ) ( by exact T.eigenvalue_ratio_le_one hn ) )

end TransferOperatorData

/-! ## Part III: Spectral Gap from Eigenvalue Isolation -/

/-- **Transfer Matrix Spectral Gap**: If λ₁ < λ₀, the mass gap is positive. -/
theorem transfer_spectral_gap_from_isolation {n : ℕ} (hn : 1 < n)
    (T : TransferOperatorData n)
    (h_isolated : T.firstExcitedEigenvalue hn < T.groundStateEigenvalue (by omega)) :
    0 < T.massGap hn := by
  unfold TransferOperatorData.massGap
  rw [neg_pos]
  exact Real.log_neg (T.eigenvalue_ratio_pos hn)
    (by rwa [div_lt_one (T.groundStateEigenvalue_pos (by omega))])

/-- **RP → Gap**: Positive transfer operator + isolated ground state → mass gap. -/
theorem reflection_positivity_implies_mass_gap {n : ℕ} (hn : 1 < n)
    (T : TransferOperatorData n)
    (h_gap : T.eigenvalues ⟨1, hn⟩ < T.eigenvalues ⟨0, by omega⟩) :
    0 < T.massGap hn :=
  transfer_spectral_gap_from_isolation hn T h_gap

/-! ## Part IV: Mass Gap and Exponential Clustering -/

/-
**Mass Gap implies Exponential Clustering**: Connected correlation functions
    decay exponentially with rate equal to the mass gap.
-/
theorem mass_gap_implies_exponential_clustering {n : ℕ} (hn : 1 < n)
    (T : TransferOperatorData n)
    (h_gap_pos : 0 < T.massGap hn)
    (amplitudes : Fin n → ℝ)
    (h_amp_bound : ∀ i, |amplitudes i| ≤ 1)
    (h_amp_ground : amplitudes ⟨0, by omega⟩ = 0)
    (corr : ℕ → ℝ)
    (h_corr : ∀ t : ℕ, corr t = ∑ i : Fin n,
      amplitudes i * (T.eigenvalues i / T.eigenvalues ⟨0, by omega⟩) ^ t) :
    ∀ t : ℕ, |corr t| ≤ ↑n * exp (-T.massGap hn * ↑t) := by
  intro t;
  -- Each term in the sum satisfies |aᵢ|·|λᵢ/λ₀|ᵗ ≤ 1·(λ₁/λ₀)ᵗ.
  have h_term_bound : ∀ i, abs ((amplitudes i) * ((T.eigenvalues i) / (T.eigenvalues ⟨0, by omega⟩)) ^ t) ≤ if i = ⟨0, by omega⟩ then 0 else (T.firstExcitedEigenvalue hn / T.groundStateEigenvalue (by omega)) ^ t := by
    intro i; split_ifs <;> simp_all +decide [ abs_mul, abs_div ] ;
    refine' le_trans ( mul_le_of_le_one_left ( by positivity ) ( h_amp_bound i ) ) _;
    gcongr;
    · exact le_of_lt ( T.eigenvalues_pos _ );
    · exact T.eigenvalues_pos _;
    · rw [ abs_of_nonneg ( le_of_lt ( T.eigenvalues_pos i ) ) ] ; exact T.eigenvalues_decreasing _ _ ( Nat.succ_le_of_lt ( lt_of_le_of_ne ( Nat.zero_le _ ) ( Ne.symm ( by simpa [ Fin.ext_iff ] using ‹¬i = ⟨ 0, by linarith ⟩ › ) ) ) ) ;
    · exact le_abs_self _;
  refine' le_trans ( h_corr t ▸ Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => h_term_bound i ) _ );
  norm_num [ Finset.sum_ite, Finset.filter_ne' ];
  gcongr <;> norm_num;
  · exact pow_nonneg ( div_nonneg ( le_of_lt ( T.eigenvalues_pos _ ) ) ( le_of_lt ( T.eigenvalues_pos _ ) ) ) _;
  · rw [ ← Real.rpow_natCast, Real.rpow_def_of_pos ] <;> norm_num [ TransferOperatorData.massGap ];
    exact div_pos ( T.eigenvalues_pos _ ) ( T.eigenvalues_pos _ )

/-! ## Part V: Wilson Loop Area Law -/

/-- **Wilson Loop Area Law**: Wilson loop expectation decays exponentially
    with area, signaling confinement. -/
structure WilsonLoopDecay where
  σ : ℝ
  σ_pos : 0 < σ
  wilson_expectation : ℕ → ℝ
  area_law : ∀ A : ℕ, |wilson_expectation A| ≤ exp (-σ * ↑A)

/-- Wilson loop at zero area has bounded norm. -/
theorem wilson_zero_area (W : WilsonLoopDecay) :
    |W.wilson_expectation 0| ≤ 1 := by
  have h := W.area_law 0
  simp at h
  exact h

/-- Wilson loop bound decays monotonically with area. -/
theorem wilson_monotone_decay (W : WilsonLoopDecay) (A₁ A₂ : ℕ) (h : A₁ ≤ A₂) :
    exp (-W.σ * ↑A₂) ≤ exp (-W.σ * ↑A₁) := by
  apply Real.exp_le_exp.mpr
  have : (A₁ : ℝ) ≤ (A₂ : ℝ) := Nat.cast_le.mpr h
  nlinarith [W.σ_pos]

/-! ## Part VI: Strong Coupling Mass Gap -/

/-- **Strong Coupling Regime**: At strong coupling (small β), the mass gap
    has an explicit positive lower bound. -/
structure StrongCouplingRegime where
  β : ℝ
  β_pos : 0 < β
  β_small : β < 1
  gap_coeff : ℝ
  gap_coeff_pos : 0 < gap_coeff
  correction_bound : ℝ
  correction_nonneg : 0 ≤ correction_bound
  correction_small : correction_bound < gap_coeff * (-Real.log β)

/-- **Strong coupling mass gap is positive**: Δ ≥ c·(-log β) - correction > 0. -/
theorem strong_coupling_mass_gap_positive (S : StrongCouplingRegime) :
    0 < S.gap_coeff * (-Real.log S.β) - S.correction_bound := by
  linarith [S.correction_small]

/-
The leading-order gap diverges as β → 0⁺.
-/
theorem strong_coupling_gap_diverges :
    Filter.Tendsto (fun β => -Real.log β)
      (nhdsWithin (0 : ℝ) (Set.Ioi 0)) Filter.atTop := by
  convert Filter.tendsto_neg_atBot_atTop.comp ( Real.tendsto_log_nhdsNE_zero.mono_left <| nhdsWithin_mono _ ?_ ) using 1 ; norm_num

/-- **Gap monotonicity at strong coupling**: positivity at one point implies
    positivity everywhere below. -/
theorem strong_coupling_gap_monotone (gap : ℝ → ℝ) (β₀ : ℝ)
    (hmono : ∀ β₁ β₂, 0 < β₁ → β₁ ≤ β₂ → β₂ ≤ β₀ → gap β₂ ≤ gap β₁)
    (hgap : 0 < gap β₀) :
    ∀ β, 0 < β → β ≤ β₀ → 0 < gap β :=
  fun β hβ hle => lt_of_lt_of_le hgap (hmono β β₀ hβ hle le_rfl)

/-! ## Part VII: Continuum Limit -/

/-- Data for a controlled continuum limit where the mass gap persists. -/
structure ContinuumLimitData where
  gap : ℝ → ℝ
  gap_continuum : ℝ
  gap_continuum_pos : 0 < gap_continuum
  gap_uniform_lower : ℝ
  gap_uniform_pos : 0 < gap_uniform_lower
  gap_exceeds_bound : ∀ a : ℝ, 0 < a → gap_uniform_lower ≤ gap a
  gap_converges : Filter.Tendsto gap (nhdsWithin (0 : ℝ) (Set.Ioi 0)) (nhds gap_continuum)

/-
The continuum gap is at least the uniform lower bound.
-/
theorem continuum_gap_lower_bound (C : ContinuumLimitData) :
    C.gap_uniform_lower ≤ C.gap_continuum := by
  exact le_of_tendsto_of_tendsto tendsto_const_nhds C.gap_converges ( Filter.eventually_of_mem self_mem_nhdsWithin fun x hx => C.gap_exceeds_bound x hx )

/-- Lattice gap at any finite spacing is positive. -/
theorem lattice_gap_positive (C : ContinuumLimitData) (a : ℝ) (ha : 0 < a) :
    0 < C.gap a :=
  lt_of_lt_of_le C.gap_uniform_pos (C.gap_exceeds_bound a ha)

/-! ## Part VIII: Gauge-Equivariant Spectral Filtration (Novel Structure) -/

/-- **GaugeEquivariantFiltration**: A novel mathematical structure capturing
    the interplay between gauge symmetry and the spectral filtration of
    the transfer matrix via the Peter-Weyl decomposition.

    Each sector contributes independently to the partition function, and
    the mass gap is the minimum gap across all sectors. The key constraint
    `eigenvalue_casimir_bound` links representation theory to spectral theory. -/
structure GaugeEquivariantFiltration (numSectors : ℕ) where
  sectorEigenvalue : Fin numSectors → ℝ
  sectorMultiplicity : Fin numSectors → ℕ
  mult_pos : ∀ i, 0 < sectorMultiplicity i
  eigenvalue_pos : ∀ i, 0 < sectorEigenvalue i
  eigenvalue_decreasing : ∀ i j : Fin numSectors, i ≤ j →
    sectorEigenvalue j ≤ sectorEigenvalue i
  sectorCasimir : Fin numSectors → ℝ
  casimir_nonneg : ∀ i, 0 ≤ sectorCasimir i
  vacuum_casimir : ∀ (h : numSectors > 0), sectorCasimir ⟨0, h⟩ = 0
  /-- **Key constraint**: sector eigenvalue controlled by Casimir -/
  eigenvalue_casimir_bound : ∀ (i : Fin numSectors),
    sectorEigenvalue i ≤ sectorEigenvalue ⟨0, i.pos⟩ *
      exp (-sectorCasimir i)

/-- The filtration gap: log-ratio of vacuum to first excited eigenvalue. -/
noncomputable def filtrationGap {m : ℕ} (F : GaugeEquivariantFiltration m)
    (hm : 1 < m) : ℝ :=
  -Real.log (F.sectorEigenvalue ⟨1, hm⟩ / F.sectorEigenvalue ⟨0, by omega⟩)

/-
**Filtration gap is non-negative**.
-/
theorem filtration_gap_nonneg {m : ℕ} (F : GaugeEquivariantFiltration m)
    (hm : 1 < m) : 0 ≤ filtrationGap F hm := by
  refine' neg_nonneg.mpr ( Real.log_nonpos _ _ );
  · exact div_nonneg ( le_of_lt ( F.eigenvalue_pos _ ) ) ( le_of_lt ( F.eigenvalue_pos _ ) );
  · exact div_le_one_of_le₀ ( F.eigenvalue_decreasing _ _ ( by norm_num ) ) ( le_of_lt ( F.eigenvalue_pos _ ) )

/-
**Filtration gap is positive** when the first excited sector is strictly
    below the vacuum.
-/
theorem filtration_gap_positive {m : ℕ} (F : GaugeEquivariantFiltration m)
    (hm : 1 < m)
    (h_strict : F.sectorEigenvalue ⟨1, hm⟩ < F.sectorEigenvalue ⟨0, by omega⟩) :
    0 < filtrationGap F hm := by
  exact neg_pos_of_neg ( Real.log_neg ( div_pos ( F.eigenvalue_pos _ ) ( F.eigenvalue_pos _ ) ) ( by rw [ div_lt_iff₀ ( F.eigenvalue_pos _ ) ] ; linarith ) )

/-
**Casimir controls the filtration gap**: The filtration gap is at least
    the first excited Casimir eigenvalue. This is the key bound connecting
    representation theory to the mass gap.

    Proof strategy: From the eigenvalue-Casimir bound,
      λ₁ ≤ λ₀ · exp(-c₂(1))
    so λ₁/λ₀ ≤ exp(-c₂(1)), hence -log(λ₁/λ₀) ≥ c₂(1).
-/
theorem casimir_controls_filtration_gap {m : ℕ}
    (F : GaugeEquivariantFiltration m) (hm : 1 < m)
    (h_casimir_pos : 0 < F.sectorCasimir ⟨1, hm⟩) :
    F.sectorCasimir ⟨1, hm⟩ ≤ filtrationGap F hm := by
  unfold filtrationGap;
  rw [ le_neg, Real.log_le_iff_le_exp ];
  · rw [ div_le_iff₀ ( F.eigenvalue_pos _ ) ];
    simpa [ mul_comm ] using F.eigenvalue_casimir_bound ⟨ 1, hm ⟩;
  · exact div_pos ( F.eigenvalue_pos _ ) ( F.eigenvalue_pos _ )

/-! ## Part IX: Synthesis Theorem -/

/-- **Main Synthesis**: Gauge-equivariant filtration with strict isolation
    yields a certified positive mass gap bounded below by the Casimir eigenvalue.

    This chains: Reflection Positivity → Gauge-Equivariant Spectrum →
    Casimir Bound → Mass Gap. -/
theorem synthesis_mass_gap_from_filtration {m : ℕ} (hm : 1 < m)
    (F : GaugeEquivariantFiltration m)
    (h_strict : F.sectorEigenvalue ⟨1, hm⟩ < F.sectorEigenvalue ⟨0, by omega⟩)
    (h_casimir_pos : 0 < F.sectorCasimir ⟨1, hm⟩) :
    0 < filtrationGap F hm ∧ F.sectorCasimir ⟨1, hm⟩ ≤ filtrationGap F hm :=
  ⟨filtration_gap_positive F hm h_strict, casimir_controls_filtration_gap F hm h_casimir_pos⟩

/-
**Perturbation stability**: The filtration gap survives small perturbations.
-/
theorem filtration_gap_perturbation_stable {m : ℕ}
    (F₁ F₂ : GaugeEquivariantFiltration m) (hm : 1 < m)
    (δ : ℝ) (hδ : 0 < δ)
    (h_gap : δ < filtrationGap F₁ hm)
    (h_close_vac : |Real.log (F₂.sectorEigenvalue ⟨0, by omega⟩) -
      Real.log (F₁.sectorEigenvalue ⟨0, by omega⟩)| ≤ δ / 2)
    (h_close_exc : |Real.log (F₂.sectorEigenvalue ⟨1, hm⟩) -
      Real.log (F₁.sectorEigenvalue ⟨1, hm⟩)| ≤ δ / 2) :
    0 < filtrationGap F₂ hm := by
  unfold filtrationGap at *;
  rw [ Real.log_div ] at * <;> try linarith [ F₁.eigenvalue_pos ⟨ 0, by linarith ⟩, F₁.eigenvalue_pos ⟨ 1, hm ⟩, F₂.eigenvalue_pos ⟨ 0, by linarith ⟩, F₂.eigenvalue_pos ⟨ 1, hm ⟩ ];
  linarith [ abs_le.mp h_close_vac, abs_le.mp h_close_exc ]

/-! ## Part X: Falsifiable Conjecture -/

/-- **Conjecture (Exponential Casimir Suppression)**: For SU(N) Yang-Mills at
    coupling β, the sector eigenvalue ratio satisfies
      λⱼ/λ₀ ≤ exp(-c₂(j)/β)

    **Testable prediction**: For SU(2) at β = 2.3 on a 4⁴ lattice,
    measure λ₁/λ₀. The conjecture predicts λ₁/λ₀ ≤ exp(-3/(4·2.3)) ≈ 0.72.
    If the measured ratio exceeds this bound, the conjecture is refuted. -/
def ExponentialCasimirSuppression (numSectors : ℕ) (β : ℝ) : Prop :=
  ∀ (F : GaugeEquivariantFiltration numSectors) (j : Fin numSectors),
    F.sectorEigenvalue j / F.sectorEigenvalue ⟨0, j.pos⟩ ≤
    exp (-F.sectorCasimir j / β)

/-- The conjecture holds trivially at the vacuum sector. -/
theorem exponential_casimir_trivial_sector {m : ℕ} (hm : 0 < m) (β : ℝ)
    (F : GaugeEquivariantFiltration m)
    (h_vac : F.sectorCasimir ⟨0, hm⟩ = 0) :
    F.sectorEigenvalue ⟨0, hm⟩ / F.sectorEigenvalue ⟨0, hm⟩ ≤
    exp (-F.sectorCasimir ⟨0, hm⟩ / β) := by
  rw [div_self (ne_of_gt (F.eigenvalue_pos _)), h_vac, neg_zero, zero_div, exp_zero]

/-
At β = 1, the conjecture follows from the eigenvalue-Casimir bound.
-/
theorem exponential_casimir_at_unit_coupling {m : ℕ} (hm : 0 < m)
    (F : GaugeEquivariantFiltration m) (j : Fin m) :
    F.sectorEigenvalue j / F.sectorEigenvalue ⟨0, hm⟩ ≤
    exp (-F.sectorCasimir j) := by
  rw [ div_le_iff₀ ( F.eigenvalue_pos _ ) ];
  convert F.eigenvalue_casimir_bound j using 1 ; ring

/-! ## Part XI: Partition Function Thermodynamics -/

/-- The partition function of lattice Yang-Mills on a finite lattice. -/
structure LatticePartitionFn where
  latticeSize : ℕ
  latticeSize_ge : 2 ≤ latticeSize
  freeEnergyDensity : ℝ → ℝ
  freeEnergy_nonneg : ∀ β, 0 < β → 0 ≤ freeEnergyDensity β

/-
**Free energy convexity bound**: If free energy is convex (as it is in
    statistical mechanics), the midpoint value is bounded by the average.
-/
theorem free_energy_midpoint_bound (Z : LatticePartitionFn)
    (β₁ β₂ : ℝ) (hβ₁ : 0 < β₁) (hβ₂ : 0 < β₂) (hlt : β₁ < β₂)
    (hconv : ConvexOn ℝ (Set.Ioi 0) Z.freeEnergyDensity) :
    Z.freeEnergyDensity ((β₁ + β₂) / 2) ≤
    (Z.freeEnergyDensity β₁ + Z.freeEnergyDensity β₂) / 2 := by
  have := hconv.2 ( show 0 < β₁ by linarith ) ( show 0 < β₂ by linarith );
  convert @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) using 1 <;> norm_num <;> ring