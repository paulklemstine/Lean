/-! # CatalogBuild.Bridges.QuantumIdempotent

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 17
-/

import Mathlib

noncomputable section

/-- A density matrix is positive semi-definite with trace 1. -/
structure DensityMatrix (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℝ
  symmetric : mat.IsSymm
  trace_one : Matrix.trace mat = 1
  psd : ∀ v : Fin n → ℝ, v ⬝ᵥ (mat.mulVec v) ≥ 0



/-- A pure state density matrix is idempotent: ρ² = ρ. -/
structure PureState (n : ℕ) extends DensityMatrix n where
  idempotent : mat * mat = mat



/-- For a pure state, tr(ρ²) = 1 (purity). -/
theorem pure_state_trace_sq {n : ℕ} (rho : PureState n) :
    Matrix.trace (rho.mat * rho.mat) = 1 := by
  rw [rho.idempotent, rho.trace_one]



/-- For a mixed state, tr(ρ²) < 1. -/
def isMixedState {n : ℕ} (rho : DensityMatrix n) : Prop :=
  Matrix.trace (rho.mat * rho.mat) < 1



/-- The purity of a density matrix is tr(ρ²). -/
def purity {n : ℕ} (rho : DensityMatrix n) : ℝ :=
  Matrix.trace (rho.mat * rho.mat)



/-- Purity of a pure state is exactly 1. -/
theorem purity_of_pure {n : ℕ} (rho : PureState n) :
    purity rho.toDensityMatrix = 1 := by
  unfold purity; rw [rho.idempotent, rho.trace_one]



/-- A spectral decomposition of a density matrix: ρ = Σ pᵢ|ψᵢ⟩⟨ψᵢ|. -/
structure SpectralDecomposition (n : ℕ) where
  num_terms : ℕ
  eigenvalues : Fin num_terms → ℝ
  projectors : Fin num_terms → Matrix (Fin n) (Fin n) ℝ
  eigenvalues_nonneg : ∀ i, eigenvalues i ≥ 0
  eigenvalues_sum_one : ∑ i, eigenvalues i = 1
  projectors_idempotent : ∀ i, projectors i * projectors i = projectors i
  projectors_orthogonal : ∀ i j, i ≠ j → projectors i * projectors j = 0



/-- The density matrix from its spectral decomposition. -/
def SpectralDecomposition.toDensityMat {n : ℕ} (S : SpectralDecomposition n) :
    Matrix (Fin n) (Fin n) ℝ :=
  ∑ i, S.eigenvalues i • S.projectors i



/-- Trace of the reconstructed density matrix equals 1
(assuming each projector has trace 1). -/
theorem spectral_trace_one {n : ℕ} (S : SpectralDecomposition n)
    (h_proj_trace : ∀ i, Matrix.trace (S.projectors i) = 1) :
    Matrix.trace S.toDensityMat = 1 := by
  simp [SpectralDecomposition.toDensityMat, map_sum, Matrix.trace_smul]
  calc ∑ i, S.eigenvalues i * Matrix.trace (S.projectors i)
      = ∑ i, S.eigenvalues i * 1 := by congr 1; ext i; rw [h_proj_trace]
    _ = ∑ i, S.eigenvalues i := by simp
    _ = 1 := S.eigenvalues_sum_one



/-- [Section: # CatalogBuild.Bridges.QuantumIdempotent
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 17] -/
theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
    (p : Fin k → ℝ) (hp_nonneg : ∀ i, p i ≥ 0) (hp_sum : ∑ i, p i = 1) :
    ∑ i, (p i) ^ 2 ≥ 1 / (k : ℝ) := by
  have := Finset.univ.sum_le_sum fun i _ => pow_two_nonneg ( p i - 1 / k );
  simp_all +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hp_sum ] at this; nlinarith [ mul_inv_cancel₀ ( by positivity : ( k : ℝ ) ≠ 0 ), mul_inv_cancel₀ ( by positivity : ( k ^ 2 : ℝ ) ≠ 0 ), ( by norm_cast : ( 1 : ℝ ) ≤ k ) ] ;



/-- The von Neumann entropy S(ρ) = -Σ pᵢ log(pᵢ). -/
def vonNeumannEntropy (k : ℕ) (eigenvalues : Fin k → ℝ) : ℝ :=
  -∑ i, if eigenvalues i > 0
    then eigenvalues i * Real.log (eigenvalues i)
    else 0



/-- Pure states have zero entropy. -/
theorem pure_state_zero_entropy :
    vonNeumannEntropy 1 (fun _ => 1) = 0 := by
  simp [vonNeumannEntropy, Real.log_one]



/-- The Marchenko-Pastur distribution support bounds. -/
def marchenkoPasturSupport (gamma : ℝ) : ℝ × ℝ :=
  ((1 - Real.sqrt gamma) ^ 2, (1 + Real.sqrt gamma) ^ 2)



/-- The support width of the Marchenko-Pastur distribution is 4√γ. -/
theorem mp_support_width (gamma : ℝ) (hgamma : gamma > 0) :
    (marchenkoPasturSupport gamma).2 - (marchenkoPasturSupport gamma).1 = 4 * Real.sqrt gamma := by
  simp [marchenkoPasturSupport]; ring



/-- A quantum channel as a trace-preserving map. -/
structure QuantumChannel (n : ℕ) where
  channel_map : Matrix (Fin n) (Fin n) ℝ → Matrix (Fin n) (Fin n) ℝ
  trace_preserving : ∀ rho, Matrix.trace (channel_map rho) = Matrix.trace rho



/-- A unital quantum channel preserves the identity. -/
structure UnitalChannel (n : ℕ) extends QuantumChannel n where
  unital : channel_map 1 = 1



/-- Unital channels preserve trace of idempotents. -/
theorem unital_preserves_idempotent_trace {n : ℕ}
    (phi : UnitalChannel n) (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) :
    Matrix.trace (phi.channel_map P) = Matrix.trace P :=
  phi.trace_preserving P



end
