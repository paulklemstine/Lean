/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Certified Fermion Sampling in Noisy Quantum Circuits

This file formalizes the theory of **certified fermion sampling** under depolarizing
noise in quantum circuits. The central result connects quantum circuit noise models
to determinantal point process (DPP) theory, providing certified quality bounds for
fermionic correlation matrices produced by noisy quantum hardware.

## Main Definitions

* `IsFermionCorrelationMatrix` — PSD matrix with eigenvalues in [0,1]
* `depolarizingChannel` — Depolarizing noise channel on correlation matrices
* `NoisyCircuitSpec` — Specification of a noisy quantum circuit
* `pairwiseNegDepDefect` — Pairwise negative dependence defect
* `maxCertifiedDepth` — Maximum circuit depth with certified quality

## Main Results

* `fermion_entry_bound` — Fermion correlation entries bounded by 1
* `depolarizing_channel_contraction` — Depolarizing noise is a contraction
* `pairwise_defect_perturbation` — Defect perturbation bound (4η general)
* `tight_defect_bound_symmetric` — Tight bound (2η for symmetric case)
* `noise_threshold_for_neg_dep` — Noise threshold theorem
* `contraction_composition` — Contraction maps compose

## References

* Macchi, "The Coincidence Approach to Stochastic Point Processes", 1975
* Terhal–DiVincenzo, "Classical Simulation of Noninteracting-Fermion Quantum Circuits", 2002
-/

open Matrix BigOperators Finset

noncomputable section

namespace CertifiedFermionSampling

/-! ## Contraction Maps and Depolarizing Noise -/

/-- A map on matrices is a contraction with rate `c` in entrywise sense. -/
def IsEntrywiseContraction {n : ℕ} (Phi : Matrix (Fin n) (Fin n) ℝ → Matrix (Fin n) (Fin n) ℝ)
    (c : ℝ) : Prop :=
  ∀ (A B : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n),
    |Phi A i j - Phi B i j| ≤ c * |A i j - B i j|

/-- The depolarizing channel with noise rate `eps`:
    `K ↦ (1 - eps) · K + eps · (I/2)`. -/
def depolarizingChannel {n : ℕ} (eps : ℝ) (K : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 - eps) • K + eps • (Matrix.diagonal (fun _ => (1 : ℝ) / 2))

/-- The depolarizing channel is a contraction with rate `(1 - eps)`. -/
theorem depolarizing_channel_contraction {n : ℕ} (eps : ℝ)
    (_heps : 0 ≤ eps) (heps1 : eps ≤ 1) :
    IsEntrywiseContraction (depolarizingChannel (n := n) eps) (1 - eps) := by
  intro A B i j
  simp only [depolarizingChannel, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
  have : (1 - eps) * A i j + eps * (Matrix.diagonal (fun _ => (1 : ℝ) / 2)) i j -
    ((1 - eps) * B i j + eps * (Matrix.diagonal (fun _ => (1 : ℝ) / 2)) i j) =
    (1 - eps) * (A i j - B i j) := by ring
  rw [this, abs_mul, abs_of_nonneg (by linarith)]

/-- Composing two contractions yields a contraction with multiplied rates. -/
theorem contraction_composition {n : ℕ}
    (Phi Psi : Matrix (Fin n) (Fin n) ℝ → Matrix (Fin n) (Fin n) ℝ)
    (c1 c2 : ℝ) (hc1 : 0 ≤ c1)
    (hPhi : IsEntrywiseContraction Phi c1) (hPsi : IsEntrywiseContraction Psi c2) :
    IsEntrywiseContraction (Phi ∘ Psi) (c1 * c2) := by
  intro A B i j
  simp only [Function.comp]
  calc |Phi (Psi A) i j - Phi (Psi B) i j|
      ≤ c1 * |Psi A i j - Psi B i j| := hPhi (Psi A) (Psi B) i j
    _ ≤ c1 * (c2 * |A i j - B i j|) :=
        mul_le_mul_of_nonneg_left (hPsi A B i j) hc1
    _ = c1 * c2 * |A i j - B i j| := by ring

/-! ## Fermion Correlation Matrix -/

/-- A valid fermion correlation matrix: PSD with eigenvalues in [0, 1]. -/
def IsFermionCorrelationMatrix {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  K.PosSemidef ∧ (1 - K).PosSemidef

/-- Diagonal entries lie in [0, 1]. -/
lemma fermion_diag_in_unit_interval {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : IsFermionCorrelationMatrix K) (i : Fin n) :
    0 ≤ K i i ∧ K i i ≤ 1 := by
  refine ⟨hK.1.diag_nonneg, ?_⟩
  have h : 0 ≤ (1 - K) i i := hK.2.diag_nonneg
  simp [Matrix.sub_apply] at h
  linarith

/-- A fermion correlation matrix is symmetric. -/
lemma fermion_symmetric {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : IsFermionCorrelationMatrix K) : K.IsSymm :=
  hK.1.isHermitian

/-- Helper: K j i = K i j for symmetric matrices. -/
lemma symm_entries {n : ℕ} {K : Matrix (Fin n) (Fin n) ℝ}
    (hK : K.IsSymm) (i j : Fin n) : K j i = K i j := by
  have h : K.transpose = K := hK
  have := congr_fun (congr_fun h i) j
  simp [Matrix.transpose_apply] at this
  exact this

/-
Entries bounded by 1 in absolute value.
-/
lemma fermion_entry_bound {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : IsFermionCorrelationMatrix K) (i j : Fin n) :
    |K i j| ≤ 1 := by
  -- By the properties of the determinant and the fact that K is a submatrix of a correlation matrix, we have
  have h_det : (K i i * K j j - K i j * K j i) ≥ 0 := by
    have h_submatrix : Matrix.PosSemidef (Matrix.of (fun (x y : Fin 2) => K (if x = 0 then i else j) (if y = 0 then i else j))) := by
      exact hK.1.submatrix _;
    have := h_submatrix.det_nonneg;
    simp_all +decide [ Matrix.det_fin_two ];
  rw [ abs_le ];
  constructor <;> nlinarith [ fermion_diag_in_unit_interval K hK i, fermion_diag_in_unit_interval K hK j, symm_entries ( fermion_symmetric K hK ) i j ]

/-! ## Noisy Quantum Circuit -/

/-- A noisy quantum circuit specification. -/
structure NoisyCircuitSpec (n : ℕ) where
  depth : ℕ
  noisePerGate : ℝ
  noise_nonneg : 0 ≤ noisePerGate
  idealKernel : Matrix (Fin n) (Fin n) ℝ
  noisyKernel : Matrix (Fin n) (Fin n) ℝ
  noise_bound : ∀ i j, |idealKernel i j - noisyKernel i j| ≤ depth * noisePerGate

/-! ## Error Accumulation -/

/-- d layers of noise at most eps each give total error at most d · eps. -/
theorem noise_accumulation_induction (d : ℕ) (eps : ℝ)
    (errors : Fin d → ℝ)
    (herr : ∀ i, 0 ≤ errors i ∧ errors i ≤ eps) :
    ∑ i : Fin d, errors i ≤ d * eps :=
  calc ∑ i : Fin d, errors i
      ≤ ∑ _i : Fin d, eps := Finset.sum_le_sum fun i _ => (herr i).2
    _ = d * eps := by simp [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-! ## Pairwise Negative Dependence -/

/-- The pairwise negative dependence defect = -K_ij · K_ji. -/
def pairwiseNegDepDefect {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  (K i i * K j j - K i j * K j i) - K i i * K j j

/-- For symmetric matrices, defect = -(K_ij)². -/
lemma defect_of_symmetric {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.IsSymm) (i j : Fin n) :
    pairwiseNegDepDefect K i j = -(K i j) ^ 2 := by
  unfold pairwiseNegDepDefect
  rw [symm_entries hK i j]; ring

/-- True DPPs satisfy negative dependence. -/
theorem dpp_neg_dep {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : IsFermionCorrelationMatrix K) (i j : Fin n) :
    pairwiseNegDepDefect K i j ≤ 0 := by
  rw [defect_of_symmetric K (fermion_symmetric K hK)]
  exact neg_nonpos.mpr (sq_nonneg _)

/-
Product perturbation: |ab - a'b'| ≤ 2η when entries bounded by 1.
-/
lemma product_perturbation (a b a' b' eta : ℝ)
    (ha : |a| ≤ 1) (hb' : |b'| ≤ 1)
    (haa' : |a - a'| ≤ eta) (hbb' : |b - b'| ≤ eta) (_heta : 0 ≤ eta) :
    |a * b - a' * b'| ≤ 2 * eta := by
  exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp ha, abs_le.mp hb', abs_le.mp haa', abs_le.mp hbb' ], by nlinarith [ abs_le.mp ha, abs_le.mp hb', abs_le.mp haa', abs_le.mp hbb' ] ⟩

/-
**Defect perturbation bound:** 4η for general matrices.
-/
theorem pairwise_defect_perturbation {n : ℕ}
    (K K' : Matrix (Fin n) (Fin n) ℝ) (eta : ℝ)
    (heta : 0 ≤ eta)
    (hKK' : ∀ i j, |K i j - K' i j| ≤ eta)
    (hK_bounded : ∀ i j, |K i j| ≤ 1)
    (hK'_bounded : ∀ i j, |K' i j| ≤ 1)
    (i j : Fin n) :
    |pairwiseNegDepDefect K i j - pairwiseNegDepDefect K' i j| ≤ 4 * eta := by
  rw [ abs_le ];
  constructor <;> unfold pairwiseNegDepDefect <;> nlinarith [ abs_le.mp ( hKK' i j ), abs_le.mp ( hKK' j i ), abs_le.mp ( hK_bounded i j ), abs_le.mp ( hK_bounded j i ), abs_le.mp ( hK'_bounded i j ), abs_le.mp ( hK'_bounded j i ) ]

/-! ## Main Certification Theorems -/

/-- Certified negative dependence defect for noisy fermion sampling. -/
theorem fermion_neg_dep_defect_bound {n : ℕ}
    (spec : NoisyCircuitSpec n)
    (hK_fermion : IsFermionCorrelationMatrix spec.idealKernel)
    (hK'_bounded : ∀ i j, |spec.noisyKernel i j| ≤ 1)
    (i j : Fin n) :
    |pairwiseNegDepDefect spec.idealKernel i j -
     pairwiseNegDepDefect spec.noisyKernel i j| ≤
      4 * (spec.depth * spec.noisePerGate) := by
  have h_nn : (0 : ℝ) ≤ (spec.depth : ℝ) * spec.noisePerGate :=
    mul_nonneg (Nat.cast_nonneg _) spec.noise_nonneg
  exact pairwise_defect_perturbation _ _ _ h_nn
    spec.noise_bound (fermion_entry_bound _ hK_fermion) hK'_bounded i j

/-- **Noise threshold:** if 4·d·eps < delta then negative dependence preserved. -/
theorem noise_threshold_for_neg_dep {n : ℕ}
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (d : ℕ) (eps delta : ℝ)
    (_heps : 0 ≤ eps)
    (hK_fermion : IsFermionCorrelationMatrix K)
    (hK'_bounded : ∀ i j, |K' i j| ≤ 1)
    (hKK' : ∀ i j, |K i j - K' i j| ≤ d * eps)
    (hmargin : ∀ i j : Fin n, pairwiseNegDepDefect K i j ≤ -delta)
    (hthreshold : 4 * (d * eps) < delta) :
    ∀ i j : Fin n, pairwiseNegDepDefect K' i j < 0 := by
  intro i j
  have hdeps : (0 : ℝ) ≤ (d : ℝ) * eps := by positivity
  have hpert := pairwise_defect_perturbation K K' ((d : ℝ) * eps) hdeps
    hKK' (fermion_entry_bound K hK_fermion) hK'_bounded i j
  linarith [abs_le.mp hpert, hmargin i j]

/-! ## Tight Bound for Symmetric Case -/

/-
**Tight defect bound for symmetric matrices:** only 2η.
-/
theorem tight_defect_bound_symmetric {n : ℕ}
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.IsSymm) (hK' : K'.IsSymm) (eta : ℝ) (heta : 0 ≤ eta)
    (hKK' : ∀ i j, |K i j - K' i j| ≤ eta)
    (hK_bounded : ∀ i j, |K i j| ≤ 1)
    (hK'_bounded : ∀ i j, |K' i j| ≤ 1)
    (i j : Fin n) :
    |pairwiseNegDepDefect K i j - pairwiseNegDepDefect K' i j| ≤ 2 * eta := by
  unfold pairwiseNegDepDefect;
  simp_all +decide [ abs_le, Matrix.IsSymm ];
  constructor <;> nlinarith [ hKK' i j, hKK' j i, hK_bounded i j, hK_bounded j i, hK'_bounded i j, hK'_bounded j i, show K i j = K j i from by simpa using congr_fun ( congr_fun hK j ) i, show K' i j = K' j i from by simpa using congr_fun ( congr_fun hK' j ) i ]

/-- **Improved noise threshold for symmetric kernels.** -/
theorem symmetric_noise_threshold {n : ℕ}
    (K K' : Matrix (Fin n) (Fin n) ℝ)
    (hK_symm : K.IsSymm) (hK'_symm : K'.IsSymm)
    (d : ℕ) (eps delta : ℝ)
    (_heps : 0 ≤ eps)
    (hK_fermion : IsFermionCorrelationMatrix K)
    (hK'_bounded : ∀ i j, |K' i j| ≤ 1)
    (hKK' : ∀ i j, |K i j - K' i j| ≤ d * eps)
    (hmargin : ∀ i j : Fin n, pairwiseNegDepDefect K i j ≤ -delta)
    (hthreshold : 2 * (d * eps) < delta) :
    ∀ i j : Fin n, pairwiseNegDepDefect K' i j < 0 := by
  intro i j
  have hdeps : (0 : ℝ) ≤ (d : ℝ) * eps := by positivity
  have hpert := tight_defect_bound_symmetric K K' hK_symm hK'_symm ((d : ℝ) * eps) hdeps
    hKK' (fermion_entry_bound K hK_fermion) hK'_bounded i j
  linarith [abs_le.mp hpert, hmargin i j]

/-! ## Cross-Domain: Maximum Certified Depth -/

/-- Maximum circuit depth maintaining certified negative dependence. -/
def maxCertifiedDepth (eps tau : ℝ) (symmetric : Bool) : ℝ :=
  if symmetric then tau / (2 * eps) else tau / (4 * eps)

/-- Positive for positive inputs. -/
lemma maxCertifiedDepth_pos (eps tau : ℝ) (heps : 0 < eps) (htau : 0 < tau) (sym : Bool) :
    0 < maxCertifiedDepth eps tau sym := by
  unfold maxCertifiedDepth; cases sym <;> simp <;> positivity

/-- Symmetric kernels allow 2× deeper circuits. -/
theorem symmetric_depth_advantage (eps tau : ℝ) (heps : 0 < eps) :
    maxCertifiedDepth eps tau true = 2 * maxCertifiedDepth eps tau false := by
  unfold maxCertifiedDepth; simp; field_simp; ring

/-! ## Conjecture (Falsifiable) -/

/-- **Conjecture:** The constant 2 in the symmetric defect bound is tight.

    **Test:** For K with K_ij close to 1, perturb to K'_ij = K_ij - eta.
    Then |K_ij² - K'_ij²| = |2*K_ij - eta| * eta → 2*eta as K_ij → 1.
    Compute this ratio for various K_ij values to verify convergence to 2. -/
def conjecture_optimal_symmetric_constant : ℝ := 2

end CertifiedFermionSampling

end