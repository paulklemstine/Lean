/-! # CatalogBuild.Physics.Quantum.ClassicalQuantumAction

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 30
-/

import Mathlib

noncomputable section

/-- The wave ansatz: amplitude times phase -/
noncomputable def waveAnsatz (sqrtRho : ℝ) (phi : ℝ) (hbar : ℝ) : ℂ :=
  (sqrtRho : ℂ) * Complex.exp (Complex.I * (phi / hbar))


/-- [Section: ## Section 1: Wave Ansatz Algebraic Identity
The core insight is that ψ = √ρ · e^{iφ/ℏ} transforms the Schrödinger operator
into the Hamilton-Jacobi equation times ψ. We formalize the algebraic structure.] -/
theorem waveAnsatz_normSq (sqrtRho phi hbar : ℝ) (hρ : 0 ≤ sqrtRho) :
    Complex.normSq (waveAnsatz sqrtRho phi hbar) = sqrtRho ^ 2 := by
      unfold waveAnsatz; norm_num [ Complex.normSq_eq_norm_sq, Complex.norm_exp ] ;


theorem waveAnsatz_arg_eq (sqrtRho phi hbar : ℝ) (hρ : 0 < sqrtRho) (hℏ : hbar ≠ 0) :
    Complex.arg (waveAnsatz sqrtRho phi hbar) =
    Complex.arg (Complex.exp (Complex.I * (phi / hbar))) := by
      unfold waveAnsatz;
      rw [ Complex.arg_real_mul ] ; aesop


/-- Superposition of two wave branches (double slit) -/
noncomputable def doubleSlit (ρ₁ ρ₂ φ₁ φ₂ hbar : ℝ) : ℂ :=
  waveAnsatz (Real.sqrt ρ₁) φ₁ hbar + waveAnsatz (Real.sqrt ρ₂) φ₂ hbar


theorem interference_pattern (ρ₁ ρ₂ φ₁ φ₂ hbar : ℝ) (h₁ : 0 ≤ ρ₁) (h₂ : 0 ≤ ρ₂)
    (hℏ : hbar ≠ 0) :
    Complex.normSq (doubleSlit ρ₁ ρ₂ φ₁ φ₂ hbar) =
      ρ₁ + ρ₂ + 2 * Real.sqrt ρ₁ * Real.sqrt ρ₂ * Real.cos ((φ₁ - φ₂) / hbar) := by
        unfold doubleSlit waveAnsatz;
        simp +decide [ Complex.normSq, Complex.exp_re, Complex.exp_im, sub_div ];
        repeat ring <;> norm_num [ Real.sin_sq, Real.cos_sub, h₁, h₂ ]


/-- Classical density evolution along a path -/
noncomputable def classicalDensity (ρ₀ : ℝ) (laplacianIntegral : ℝ) : ℝ :=
  ρ₀ * Real.exp (-laplacianIntegral)


/-- [Section: ## Section 2: Density Path Integral Properties
The classical density satisfies ρ(t) = ρ₀ · exp(-∫₀ᵗ ΔΦ dθ).] -/
theorem classicalDensity_pos (ρ₀ : ℝ) (integral : ℝ) (h : 0 < ρ₀) :
    0 < classicalDensity ρ₀ integral := by
      exact mul_pos h ( Real.exp_pos _ )


theorem classicalDensity_mul (ρ₀ s₁ s₂ : ℝ) :
    classicalDensity (classicalDensity ρ₀ s₁) s₂ = classicalDensity ρ₀ (s₁ + s₂) := by
      unfold classicalDensity; rw [ mul_assoc, ← Real.exp_add ] ; ring;


/-- [Section: ## Section 3: Bohr-Sommerfeld Quantization (Lemma 3.4)
Periodic waves are quantized: φ(ω)/ℏ = 2πk.] -/
theorem quantization_condition (ϕ : ℝ) (hbar : ℝ) (hℏ : 0 < hbar) :
    (∀ k : ℤ, ϕ / hbar ≠ 2 * π * k) →
    Filter.Tendsto (fun K : ℕ => (1 / (K : ℂ)) *
      Finset.sum (Finset.range K) (fun κ =>
        Complex.exp (Complex.I * (κ * (ϕ / hbar))))) Filter.atTop (nhds 0) := by
          intro h;
          -- The sum of exponentials is a geometric series with ratio $e^{i\phi/hbar}$.
          have h_geo_series : ∀ K : ℕ, ∑ κ ∈ Finset.range K, Complex.exp (Complex.I * (κ * (ϕ / hbar))) = (Complex.exp (Complex.I * (K * (ϕ / hbar))) - 1) / (Complex.exp (Complex.I * (ϕ / hbar)) - 1) := by
            intro K; rw [ eq_div_iff ];
            · induction K <;> simp_all +decide [ Finset.sum_range_succ, Complex.exp_add, mul_add, add_mul ] ; ring;
            · contrapose! h;
              rw [ sub_eq_zero, Complex.exp_eq_one_iff ] at h ; obtain ⟨ k, hk ⟩ := h ; exact ⟨ k, by norm_num [ Complex.ext_iff ] at hk ; linarith ⟩;
          simp_all +decide [ div_eq_inv_mul ];
          exact squeeze_zero_norm ( fun K => by simpa [ abs_mul, abs_inv ] using mul_le_mul_of_nonneg_left ( mul_le_mul_of_nonneg_left ( show ‖Complex.exp ( I * ( K * ( ( hbar : ℂ ) ⁻¹ * ϕ ) ) ) - 1‖ ≤ 2 by exact le_trans ( norm_sub_le _ _ ) <| by norm_num [ Complex.norm_exp ] ) <| by positivity ) <| by positivity ) <| by simpa using tendsto_inv_atTop_nhds_zero_nat.mul_const ( ‖ ( Complex.exp ( I * ( ( hbar : ℂ ) ⁻¹ * ϕ ) ) - 1 ) ⁻¹‖ * 2 ) ;


theorem quantization_resonance (k : ℤ) (hbar : ℝ) (hℏ : 0 < hbar) :
    ∀ K : ℕ, 0 < K →
      (1 / (K : ℂ)) * Finset.sum (Finset.range K) (fun κ =>
        Complex.exp (Complex.I * (κ * (2 * π * k)))) = 1 := by
          intro K hK; rw [ one_div, inv_mul_eq_div, div_eq_iff ( Nat.cast_ne_zero.mpr hK.ne' ) ] ; norm_cast ; ring;
          exact Eq.trans ( Finset.sum_congr rfl fun _ _ => by rw [ Complex.exp_eq_one_iff ] ; use k * ‹ℕ›; push_cast; ring ) ( by norm_num )


/-- Distance from a slit position -/
noncomputable def slitDistance (x slit : ℝ × ℝ) : ℝ :=
  Real.sqrt ((x.1 - slit.1)^2 + (x.2 - slit.2)^2)


/-- [Section: ## Section 4: Double Slit Geometry
The action in the double slit is φⱼ = p₀rⱼ where rⱼ = |x - xⱼ|.] -/
theorem slitDistance_nonneg (x slit : ℝ × ℝ) : 0 ≤ slitDistance x slit := by
  exact Real.sqrt_nonneg _


/-- Density behind slit falls as 1/r² in 3D -/
noncomputable def slitDensity3D (r : ℝ) : ℝ := 1 / r^2


/-- Double slit probability density on screen -/
noncomputable def doubleSlitProbability (p₀ hbar x₁ x₂ : ℝ) (screen : ℝ × ℝ)
    (slit₁ slit₂ : ℝ × ℝ) : ℝ :=
  let r₁ := slitDistance screen slit₁
  let r₂ := slitDistance screen slit₂
  1/r₁^2 + 1/r₂^2 + 2/(r₁ * r₂) * Real.cos (p₀ * (r₁ - r₂) / hbar)


/-- Energy levels of a particle in a box -/
noncomputable def boxEnergy (hbar M L : ℝ) (k : ℕ) : ℝ :=
  hbar^2 * π^2 * k^2 / (2 * M * L^2)


/-- [Section: ## Section 5: Particle in a Box Quantization
Energy levels: Eₖ = ℏ²π²k²/(2ML²)] -/
theorem boxEnergy_nonneg (hbar M L : ℝ) (k : ℕ) (hM : 0 < M) (hL : 0 < L) :
    0 ≤ boxEnergy hbar M L k := by
      exact div_nonneg ( by positivity ) ( by positivity )


theorem boxEnergy_mono (hbar M L : ℝ) (k₁ k₂ : ℕ) (h : k₁ ≤ k₂)
    (hℏ : 0 < hbar) (hM : 0 < M) (hL : 0 < L) :
    boxEnergy hbar M L k₁ ≤ boxEnergy hbar M L k₂ := by
      unfold boxEnergy; gcongr;


/-- Wave function of particle in a box -/
noncomputable def boxWavefunction (L x : ℝ) (k : ℕ) : ℝ :=
  Real.sqrt (2 / L) * Real.sin (π * k * x / L)


/-- Transmitted momentum through a barrier -/
noncomputable def transmittedMomentum (p₀ M V : ℝ) : ℝ :=
  Real.sqrt (p₀^2 - 2 * M * V)


/-- Transmission coefficient (when p₀² > 2MV) -/
noncomputable def transmissionCoeff (p₀ M V : ℝ) : ℝ :=
  let pT := transmittedMomentum p₀ M V
  4 * p₀ * pT / (p₀ + pT)^2


/-- [Section: ## Section 6: Tunnelling - Complex Action
For tunnelling, the transmitted momentum pT = √(p₀² - 2MV) can be imaginary.] -/
theorem reflection_transmission_sum (p₀ M V : ℝ) (hp : 0 < p₀)
    (hpT : 0 < transmittedMomentum p₀ M V) :
    let pT := transmittedMomentum p₀ M V
    let T := 4 * p₀ * pT / (p₀ + pT)^2
    let R := ((p₀ - pT) / (p₀ + pT))^2
    R + T = 1 := by
      grind +qlia


/-- Harmonic oscillator eigenvalues -/
noncomputable def harmonicEnergy (hbar ω : ℝ) (k N : ℕ) : ℝ :=
  hbar * ω * (k + N / 2)


/-- Hydrogen energy levels -/
noncomputable def hydrogenEnergy (M G hbar : ℝ) (k : ℕ) : ℝ :=
  M / 2 * (G / (hbar * k))^2


/-- [Section: ## Section 8: Hydrogen Atom Energy Levels
From the Coulomb potential via Kepler orbits: Eₖ = M/2 · (G/(ℏk))²] -/
theorem hydrogenEnergy_decreasing (M G hbar : ℝ) (k₁ k₂ : ℕ)
    (hk₁ : 0 < k₁) (hk₂ : 0 < k₂) (h : k₁ ≤ k₂)
    (hM : 0 < M) (hG : 0 < G) (hℏ : 0 < hbar) :
    hydrogenEnergy M G hbar k₂ ≤ hydrogenEnergy M G hbar k₁ := by
      unfold hydrogenEnergy; gcongr;


/-- Spin direction unit vector from angles -/
noncomputable def spinDirection (α β : ℝ) : Fin 3 → ℝ :=
  ![Real.sin β * Real.cos α, Real.sin β * Real.sin α, Real.cos β]


/-- EPR correlation between two spin measurements -/
noncomputable def eprCorrelation (α₁ β₁ α₂ β₂ : ℝ) : ℝ :=
  -(spinDirection α₁ β₁ 0 * spinDirection α₂ β₂ 0 +
    spinDirection α₁ β₁ 1 * spinDirection α₂ β₂ 1 +
    spinDirection α₁ β₁ 2 * spinDirection α₂ β₂ 2)


/-- [Section: ## Section 9: EPR Correlation
The EPR correlation: ⟨ψ₁↑, ψ₂↓⟩ = -n₁·n₂] -/
theorem epr_aligned (α β : ℝ) :
    eprCorrelation α β α β = -1 := by
      unfold eprCorrelation spinDirection; norm_num; ring;
      erw [ Matrix.cons_val_succ' ] ; norm_num ; rw [ Real.sin_sq, Real.sin_sq ] ; ring


theorem epr_perpendicular :
    eprCorrelation 0 0 0 (π / 2) = 0 := by
      unfold eprCorrelation spinDirection; norm_num [ Real.sin_pi_div_two, Real.cos_pi_div_two ] ;
      exact Or.inr rfl


/-- Superposition of N branch waves -/
noncomputable def multipathWave (branches : Fin n → ℝ × ℝ) (hbar : ℝ) : ℂ :=
  Finset.sum Finset.univ (fun j =>
    waveAnsatz (Real.sqrt (branches j).1) (branches j).2 hbar)


/-- [Section: ## Section 10: Multipath Superposition Principle
The total wave is a sum of branch waves.] -/
theorem multipathWave_density_nonneg (branches : Fin n → ℝ × ℝ) (hbar : ℝ) :
    0 ≤ Complex.normSq (multipathWave branches hbar) := by
      exact Complex.normSq_nonneg _


end
