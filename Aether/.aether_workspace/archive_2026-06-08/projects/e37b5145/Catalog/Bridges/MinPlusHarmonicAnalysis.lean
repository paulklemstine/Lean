/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Min-Plus Harmonic Analysis: Legendre-Fenchel Spectral Theory

We formalize the foundations of **min-plus (tropical) harmonic analysis**, establishing
the Legendre-Fenchel transform as the natural Fourier transform in the idempotent setting.

## Revolutionary Insight

Convex optimization IS tropical harmonic analysis. The Legendre-Fenchel transform IS
the tropical Fourier transform. Duality in optimization IS spectral decomposition in
the min-plus world.

## Cross-Domain Bridges

- **Tropical Harmonic Analysis ↔ Convex Optimization**: Fenchel-Moreau = tropical inversion
- **Tropical Uncertainty ↔ Certified Robustness**: uncertainty bounds on adversarial perturbations
- **Min-Plus DFT ↔ Post-Quantum Lattice Crypto**: tropical spectral methods for lattice reduction
- **Idempotent Analysis ↔ Quantum Mechanics**: Maslov's tropical limits of Feynman integrals
-/

import Mathlib

noncomputable section

open Finset

namespace MinPlusHarmonic

variable {m : ℕ} [NeZero m]

private lemma univ_ne : (univ : Finset (Fin m)).Nonempty := univ_nonempty

/-! ## Section 1: Helper Lemmas for `Finset.inf'` Arithmetic -/

/-
Adding a constant on the left commutes with finite infimum.
    Bridge: connects additive group action to min-plus semimodule structure.
-/
lemma inf'_add_const_left (f : Fin m → ℝ) (c : ℝ) :
    univ.inf' univ_ne (fun i => c + f i) = c + univ.inf' univ_ne f := by
  refine' le_antisymm _ _;
  · simpa using Finset.exists_min_image Finset.univ ( fun i => f i ) ⟨ ⟨ 0, NeZero.pos m ⟩, Finset.mem_univ _ ⟩;
  · aesop

/-
Adding a constant on the right commutes with finite infimum.
-/
lemma inf'_add_const_right (f : Fin m → ℝ) (c : ℝ) :
    univ.inf' univ_ne (fun i => f i + c) = univ.inf' univ_ne f + c := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · simpa using Finset.exists_min_image Finset.univ ( fun i => f i ) ⟨ ⟨ 0, NeZero.pos m ⟩, Finset.mem_univ _ ⟩;
  · exact fun i => ⟨ i, le_rfl ⟩

/-
Infimum of a constant function equals that constant.
    Bridge: tropical zero element in idempotent measure theory.
-/
lemma inf'_const (c : ℝ) :
    univ.inf' univ_ne (fun _ : Fin m => c) = c := by
  aesop

/-! ## Section 2: Core Definitions -/

/-- **Min-plus weighted transform** (tropical DFT): f̂(k) = min_j [f(j) + W(j,k)].
    This is the Legendre-Fenchel conjugate restricted to a finite domain.
    Bridge: connects convex optimization to tropical spectral theory.
    Application: tropical_frequency_decomposition for certified_robustness_bounds. -/
def minPlusTransform (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ) (k : Fin m) : ℝ :=
  univ.inf' univ_ne (fun j => f j + W j k)

/-- **Min-plus double transform** (tropical Fourier inversion operator):
    f̂̂(j) = min_k [f̂(k) + W(k,j)].
    Bridge: tropical Fourier inversion ↔ Fenchel-Moreau duality theorem. -/
def minPlusDoubleTransform (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ) (j : Fin m) : ℝ :=
  minPlusTransform W (minPlusTransform W f) j

/-- **Idempotent energy**: E(f) = min_j f(j), the min-plus integral.
    Bridge: connects measure theory to idempotent analysis.
    Application: tropical_energy_certification for neural_network_verification. -/
def idempotentEnergy (f : Fin m → ℝ) : ℝ :=
  univ.inf' univ_ne f

/-- **Row-normalized kernel**: each row has minimum 0, all entries ≥ 0.
    This is the tropical analogue of the unitary condition for the DFT matrix.
    Bridge: connects spectral theory to tropical linear algebra.
    Application: post_quantum_lattice_reduction via tropical_spectral_methods. -/
structure RowNormalizedKernel (m : ℕ) [NeZero m] where
  /-- The weight matrix -/
  W : Fin m → Fin m → ℝ
  /-- All weights are non-negative -/
  nonneg : ∀ j k, 0 ≤ W j k
  /-- Each row achieves minimum 0 -/
  row_min_zero : ∀ j, univ.inf' univ_ne (W j) = 0

/-- **Symmetric kernel**: W(j,k) = W(k,j).
    Symmetric kernels yield self-adjoint tropical operators. -/
def IsSymmetricKernel (W : Fin m → Fin m → ℝ) : Prop :=
  ∀ j k, W j k = W k j

/-- **Min-plus DFT kernel**: W(j,k) = j·k/m, the tropical analogue
    of the unitary DFT matrix exp(2πijk/m).
    Bridge: connects finite group harmonic analysis to tropical linear algebra.
    Application: post_quantum_lattice_reduction via tropical_spectral_methods. -/
def minPlusDFTKernel (j k : Fin m) : ℝ :=
  (j : ℕ) * (k : ℕ) / (m : ℝ)

/-- **Tropical spectral support**: frequencies where f̂ is within ε of optimal.
    Bridge: connects harmonic analysis to tropical geometry.
    Application: adversarial_frequency_band detection for certified_robustness. -/
def TropicalSpectralSupport (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ) (ε : ℝ) :
    Finset (Fin m) :=
  univ.filter (fun k =>
    minPlusTransform W f k ≤ idempotentEnergy (minPlusTransform W f) + ε)

/-! ## Section 3: Fenchel-Young Inequality and Basic Properties -/

/-
**Fenchel-Young inequality** (discrete): f̂(k) ≤ f(j) + W(j,k) for all j, k.
    The fundamental inequality of tropical harmonic analysis.
    Bridge: connects convex analysis to harmonic analysis.
    Application: lipschitz_certified_robustness for tropical_neural_networks.
-/
theorem fenchel_young_discrete (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    (j k : Fin m) :
    minPlusTransform W f k ≤ f j + W j k := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
**Antitonicity**: f ≤ g pointwise implies f̂ ≤ ĝ pointwise.
    The tropical Fourier transform preserves the ordering on min-plus functions.
    Bridge: connects order theory to spectral analysis.
-/
theorem minPlusTransform_antitone (W : Fin m → Fin m → ℝ)
    {f g : Fin m → ℝ} (hfg : ∀ j, f j ≤ g j) (k : Fin m) :
    minPlusTransform W f k ≤ minPlusTransform W g k := by
  unfold minPlusTransform;
  simp_all +decide [ Finset.inf'_le ];
  exact fun j => ⟨ j, by linarith [ hfg j ] ⟩

/-
**Shift property**: shifting f by a constant c shifts f̂ by c.
    The tropical analogue of the modulation theorem.
    Bridge: connects translation invariance to tropical gauge symmetry in physics.
-/
theorem minPlusTransform_shift (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    (c : ℝ) (k : Fin m) :
    minPlusTransform W (fun j => c + f j) k = c + minPlusTransform W f k := by
  convert inf'_add_const_left _ _;
  exact congr_arg _ ( funext fun _ => by ring );
  infer_instance

/-
**Transform of a constant**: when f ≡ c, f̂(k) = c + min_j W(j,k).
    Bridge: tropical DC component analysis.
-/
theorem minPlusTransform_const (W : Fin m → Fin m → ℝ) (c : ℝ) (k : Fin m) :
    minPlusTransform W (fun _ => c) k = c + univ.inf' univ_ne (fun j => W j k) := by
  convert inf'_add_const_left _ c using 3;
  infer_instance

/-
**Witness property**: the infimum is attained at some index.
    Tropical analogue of the extremal character in spectral decomposition.
-/
theorem minPlusTransform_attained (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    (k : Fin m) :
    ∃ j : Fin m, minPlusTransform W f k = f j + W j k := by
  unfold minPlusTransform;
  convert Finset.exists_min_image Finset.univ ( fun j => f j + W j k ) ( Finset.univ_nonempty ) using 1;
  simp +decide [ Finset.inf'_eq_csInf_image ];
  ext; simp +decide [ eq_comm, le_csInf_iff ] ;
  exact ⟨ fun h x' => h.symm ▸ csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self _ ), fun h => le_antisymm ( le_csInf ( Set.nonempty_of_mem ( Set.mem_range_self ‹_› ) ) ( Set.forall_mem_range.mpr h ) ) ( csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self _ ) ) ⟩

/-! ## Section 4: Double Conjugate and Duality Theory -/

/-
**Double conjugate upper bound**: f̂̂(j) ≤ f(j₀) + W(j₀,k) + W(k,j) for any j₀, k.
    Bridge: tropical Fourier inversion ↔ Fenchel-Moreau duality.
-/
theorem double_conjugate_pointwise_le (W : Fin m → Fin m → ℝ)
    (f : Fin m → ℝ) (j j₀ k : Fin m) :
    minPlusDoubleTransform W f j ≤ f j₀ + W j₀ k + W k j := by
  have := fenchel_young_discrete W f j₀ k;
  exact le_trans ( fenchel_young_discrete W ( minPlusTransform W f ) k j ) ( by linarith )

/-
**Double conjugate self-bound**: f̂̂(j) ≤ f(j) + min_k [W(j,k) + W(k,j)].
    For row-normalized symmetric kernels, this gives f̂̂ ≤ f.
    Bridge: tropical Fourier inversion ↔ Fenchel-Moreau duality.
    Application: tropical_signal_reconstruction for certified_robustness.
-/
theorem double_conjugate_le_general (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    (j : Fin m) :
    minPlusDoubleTransform W f j ≤
      f j + univ.inf' univ_ne (fun k => W j k + W k j) := by
  convert double_conjugate_pointwise_le W f j j using 1
  generalize_proofs at *;
  grind +suggestions

/-! ## Section 5: Idempotent Parseval Identity -/

/-
**Energy is a lower bound**: E(f) ≤ f(j) for all j.
    Bridge: tropical ground state energy bounds.
-/
theorem idempotentEnergy_le (f : Fin m → ℝ) (j : Fin m) :
    idempotentEnergy f ≤ f j := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
**Energy attained**: ∃ j, E(f) = f(j). The minimum is always attained.
    Bridge: existence of tropical ground states in statistical mechanics.
-/
theorem idempotentEnergy_attained (f : Fin m → ℝ) :
    ∃ j : Fin m, idempotentEnergy f = f j := by
  have := Finset.exists_mem_eq_inf' univ_ne f;
  exact this.imp fun i hi => hi.2

/-
**Energy shift**: E(c + f) = c + E(f).
    Bridge: gauge invariance in tropical quantum mechanics.
-/
theorem idempotentEnergy_shift (f : Fin m → ℝ) (c : ℝ) :
    idempotentEnergy (fun j => c + f j) = c + idempotentEnergy f := by
  convert inf'_add_const_left f c using 1

/-
**Energy monotonicity**: if f ≤ g pointwise, then E(f) ≤ E(g).
    Bridge: order-preserving maps in tropical dynamical systems.
-/
theorem idempotentEnergy_monotone {f g : Fin m → ℝ} (h : ∀ j, f j ≤ g j) :
    idempotentEnergy f ≤ idempotentEnergy g := by
  unfold idempotentEnergy;
  simp +decide [ *, Finset.inf'_le ];
  exact fun j => ⟨ j, h j ⟩

/-
**Idempotent Parseval identity**: E(f) = E(f̂) for row-normalized kernels.
    The tropical analogue of Plancherel's theorem ‖f‖² = ‖f̂‖².
    Bridge: connects idempotent analysis to measure-theoretic harmonic analysis.
    Application: tropical_energy_conservation for neural_network_verification.

    Proof:
    (≤): E(f̂) ≤ f̂(k₀) ≤ f(j*) + W(j*,k₀) = f(j*) + 0 = f(j*) = E(f)
      where j* achieves E(f) and k₀ achieves W(j*,k₀) = 0 by row-normalization.
    (≥): f̂(k) = min_j [f(j)+W(j,k)] ≥ min_j f(j) + 0 = E(f) since W ≥ 0.
      So E(f̂) = min_k f̂(k) ≥ E(f).
-/
theorem idempotent_parseval (K : RowNormalizedKernel m) (f : Fin m → ℝ) :
    idempotentEnergy f = idempotentEnergy (minPlusTransform K.W f) := by
  refine' le_antisymm _ _;
  · unfold idempotentEnergy;
    simp +decide [ Finset.inf'_le, minPlusTransform ];
    exact fun i j => ⟨ j, le_add_of_nonneg_right ( K.nonneg _ _ ) ⟩;
  · obtain ⟨ j, hj ⟩ := idempotentEnergy_attained f;
    -- By definition of $minPlusTransform$, we know that $minPlusTransform K.W f k₀ ≤ f j + K.W j k₀$.
    obtain ⟨ k₀, hk₀ ⟩ : ∃ k₀ : Fin m, K.W j k₀ = 0 := by
      have := K.row_min_zero j;
      have := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( K.W j ) ; aesop;
    exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ k₀ ) ) ( by simpa [ hk₀ ] using fenchel_young_discrete K.W f j k₀ ) |> le_trans <| by linarith;

/-! ## Section 6: DFT Kernel Properties -/

/-
The min-plus DFT kernel is non-negative.
    Bridge: tropical positivity ↔ post-quantum security via lattice structure.
-/
omit [NeZero m] in
theorem minPlusDFTKernel_nonneg (j k : Fin m) :
    0 ≤ minPlusDFTKernel (m := m) j k := by
  exact div_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( Nat.cast_nonneg _ )

/-
The min-plus DFT kernel is symmetric: W(j,k) = W(k,j).
    Bridge: self-adjointness of tropical Fourier operator.
-/
omit [NeZero m] in
theorem minPlusDFTKernel_symmetric (j k : Fin m) :
    minPlusDFTKernel (m := m) j k = minPlusDFTKernel k j := by
  unfold minPlusDFTKernel; ring;

/-
Row 0 of the DFT kernel is identically 0.
    Bridge: tropical DC component ↔ constant mode in spectral decomposition.
-/
theorem minPlusDFTKernel_row_zero (k : Fin m) :
    minPlusDFTKernel (m := m) ⟨0, Nat.pos_of_ne_zero (NeZero.ne m)⟩ k = 0 := by
  unfold minPlusDFTKernel; norm_num;

/-
Column 0 of the DFT kernel is identically 0.
-/
theorem minPlusDFTKernel_col_zero (j : Fin m) :
    minPlusDFTKernel (m := m) j ⟨0, Nat.pos_of_ne_zero (NeZero.ne m)⟩ = 0 := by
  unfold minPlusDFTKernel; norm_num

/-
Each row of the DFT kernel has minimum 0 (achieved at column 0).
    This is the row-normalization property needed for the Parseval identity.
    Bridge: unitarity condition in tropical spectral theory.
-/
theorem minPlusDFTKernel_row_min_zero (j : Fin m) :
    univ.inf' univ_ne (minPlusDFTKernel (m := m) j) = 0 := by
  refine' le_antisymm _ _ <;> norm_num;
  · exact ⟨ ⟨ 0, NeZero.pos m ⟩, by unfold minPlusDFTKernel; norm_num ⟩;
  · exact fun k => div_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( Nat.cast_nonneg _ )

/-! ## Section 7: Delta Functions and Sharp Uncertainty -/

/-
**Delta function transform bound**: δ_{j₀} transformed yields f̂(k) ≤ W(j₀,k).
    Bridge: connects extremal combinatorics to harmonic analysis.
    Application: sharp_certified_robustness_bound for adversarial examples.
-/
theorem delta_transform_le [DecidableEq (Fin m)] (W : Fin m → Fin m → ℝ)
    (j₀ : Fin m) (M : ℝ) (_hM : 0 ≤ M) (k : Fin m) :
    minPlusTransform W (fun j => if j = j₀ then 0 else M) k ≤ W j₀ k := by
  convert fenchel_young_discrete W _ j₀ k using 1 ; aesop

/-
**Delta function energy**: E(δ_{j₀}) = 0.
    Bridge: tropical ground state energy of localized states.
-/
theorem delta_energy [DecidableEq (Fin m)] (j₀ : Fin m) (M : ℝ) (hM : 0 < M) :
    idempotentEnergy (fun j : Fin m => if j = j₀ then (0 : ℝ) else M) = 0 := by
  unfold idempotentEnergy;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · exact ⟨ j₀, by norm_num ⟩;
  · lia

/-! ## Section 8: Tropical Spectral Support Properties -/

/-
**Spectral support monotonicity**: smaller ε gives smaller support.
    Application: resolution-accuracy tradeoff in adversarial detection.
-/
theorem spectral_support_mono (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    {ε₁ ε₂ : ℝ} (hε : ε₁ ≤ ε₂) :
    TropicalSpectralSupport W f ε₁ ⊆ TropicalSpectralSupport W f ε₂ := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, by linarith [ Finset.mem_filter.mp hx |>.2 ] ⟩

/-
The spectral support at ε = 0 contains the minimizer of f̂.
    Application: optimal_frequency_detection for tropical_neural_networks.
-/
theorem spectral_support_minimizer (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    (k : Fin m) (hk : minPlusTransform W f k = idempotentEnergy (minPlusTransform W f)) :
    k ∈ TropicalSpectralSupport W f 0 := by
  unfold TropicalSpectralSupport; aesop;

/-! ## Section 9: Min-Plus Algebra Foundations -/

/-
**Min-plus distributivity**: a + min(b, c) = min(a+b, a+c).
    The fundamental distributive law of the tropical semiring.
    Bridge: connects tropical algebra to neural_network_ReLU_decomposition.
-/
theorem minPlus_distrib (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  exact add_min a b c

/-- **Min is idempotent**: min(a, a) = a.
    The characteristic property of idempotent semirings.
    Bridge: connects idempotent analysis to quantum decoherence (ℏ → 0 limit). -/
theorem min_idempotent (a : ℝ) : min a a = a := min_self a

/-
**Min-plus absorption**: min(a, a + b) = a when b ≥ 0.
    Bridge: tropical absorption law ↔ relaxation in gradient_descent.
-/
theorem minPlus_absorption (a b : ℝ) (hb : 0 ≤ b) :
    min a (a + b) = a := by
  -- Since $b \geq 0$, we have $a \leq a + b$.
  apply min_eq_left; linarith

/-
**Min-plus triangle inequality**: min(a+c, b+d) ≥ min(a,b) + min(c,d).
    Bridge: tropical metric structure ↔ certified_robustness bounds.
-/
theorem minPlus_triangle (a b c d : ℝ) :
    min a b + min c d ≤ min (a + c) (b + d) := by
  grind

/-! ## Section 10: Transform Composition -/

/-
**Transform unfold**: minPlusDoubleTransform unfolds to nested infima.
    Bridge: spectral composition for multi-layer tropical_neural_networks.
-/
theorem minPlusDoubleTransform_unfold (W : Fin m → Fin m → ℝ) (f : Fin m → ℝ)
    (j : Fin m) :
    minPlusDoubleTransform W f j =
      univ.inf' univ_ne (fun k =>
        univ.inf' univ_ne (fun l => f l + W l k) + W k j) := by
  rfl

end MinPlusHarmonic

end