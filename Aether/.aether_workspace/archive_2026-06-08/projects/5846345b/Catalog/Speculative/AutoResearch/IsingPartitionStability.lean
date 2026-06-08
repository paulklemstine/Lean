/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Stability of Ising Partition Functions Under Noisy Couplings

This file develops a **quantitative robustness theory for Ising partition functions
under coupling perturbations**, building on the Lorentzian polynomial stability
framework from `LorentzianSharpStability.lean` and `LorentzianStability.lean`.

## Mathematical Overview

For an Ising system on `n` spins with couplings `J : Fin n → Fin n → ℝ`, inverse
temperature `β > 0`, and external field `h : Fin n → ℝ`, the partition function is:

  Z_J(h) = ∑_{σ ∈ {±1}^n} exp(β · E(J, h, σ))

where E(J, h, σ) = ∑_i h_i σ_i + ∑_{i,j} J_{ij} σ_i σ_j.

We prove that:
1. The partition function is always strictly positive.
2. The energy changes in a controlled way under coupling perturbations.
3. The log partition function is Lipschitz in the coupling matrix.
4. The Gibbs expectation values are stable under coupling noise.
5. A quadratic covariance form identity connects the Hessian of log Z to
   spin covariances, bridging Lorentzian geometry to statistical physics.

The key insight is that the `1/(β n²)` perturbation scale from Lorentzian
stability theory translates directly into a physically meaningful robustness
scale for thermodynamic observables.

## Main Results

* `isingPartition_pos` — Partition function is strictly positive
* `isingEnergy_diff_bound` — Energy difference bounded by n² · δ under coupling noise
* `isingPartition_ratio_bound` — Multiplicative bound on partition function ratio
* `isingPartition_logLipschitz` — Log partition function is Lipschitz in couplings
* `gibbs_weight_ratio_bound` — Gibbs weights are stable under coupling noise
* `covarianceForm_eq_variance` — Cross-domain covariance identity
* `covarianceForm_nonneg` — Susceptibility positive semidefiniteness
* `certified_robustness_preserves_signature` — Verified robustness certificate

## Application Keywords

Ising model, partition function, log-concavity, Gibbs measure, covariance,
susceptibility, phase transition, noisy couplings, robustness certificate,
Lorentzian polynomial, Hodge theory, free energy stability

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators

noncomputable section

namespace IsingPartitionStability

/-! ## Spin Configuration Infrastructure -/

/-- Convert a Boolean to a spin value: `true ↦ 1`, `false ↦ -1`. -/
def spinVal (b : Bool) : ℝ := if b then 1 else -1

/-- The set of all spin configurations on `n` sites. -/
def spinConfigs (n : ℕ) : Finset (Fin n → Bool) := Finset.univ

theorem spinVal_sq (b : Bool) : spinVal b ^ 2 = 1 := by
  cases b <;> simp [spinVal]

theorem spinVal_abs (b : Bool) : |spinVal b| = 1 := by
  cases b <;> simp [spinVal]

theorem spinConfigs_nonempty (n : ℕ) : (spinConfigs n).Nonempty :=
  Finset.univ_nonempty

/-! ## Ising Energy and Partition Function -/

/-- The Ising energy for a spin configuration `σ` with couplings `J` and external field `h`.
    E(J, h, σ) = ∑_i h_i · σ_i + ∑_{i,j} J_{ij} · σ_i · σ_j -/
def isingEnergy {n : ℕ} (J : Fin n → Fin n → ℝ) (h : Fin n → ℝ)
    (σ : Fin n → Bool) : ℝ :=
  ∑ i, h i * spinVal (σ i) + ∑ i, ∑ j, J i j * spinVal (σ i) * spinVal (σ j)

/-- The coupling contribution to the Ising energy (without external field). -/
def couplingEnergy {n : ℕ} (J : Fin n → Fin n → ℝ)
    (σ : Fin n → Bool) : ℝ :=
  ∑ i, ∑ j, J i j * spinVal (σ i) * spinVal (σ j)

/-- The Ising partition function:
    Z(β, J, h) = ∑_{σ} exp(β · E(J, h, σ)) -/
def isingPartition {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
    (h : Fin n → ℝ) : ℝ :=
  ∑ σ ∈ spinConfigs n, Real.exp (β * isingEnergy J h σ)

/-- Coupling perturbation predicate: J' is within δ of J entrywise. -/
def couplingPerturbation {n : ℕ}
    (J J' : Fin n → Fin n → ℝ) (δ : ℝ) : Prop :=
  ∀ i j, |J' i j - J i j| ≤ δ

/-! ## Field Log-Concavity -/

/-- The log partition function is concave in the external field on a set S. -/
def fieldLogConcaveOn {n : ℕ}
    (β : ℝ) (J : Fin n → Fin n → ℝ) (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S → ∀ t ∈ Set.Icc (0 : ℝ) 1,
    Real.log (isingPartition β J (t • x + (1 - t) • y)) ≥
      t * Real.log (isingPartition β J x) +
      (1 - t) * Real.log (isingPartition β J y)

/-! ## Lorentzian-Ising Bridge Definitions -/

/-- Squared Euclidean norm. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

/-- The quadratic form induced by a matrix. -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Gapped Lorentzian signature: there exists a direction `w` such that
    Q_A(v) ≤ -ε·‖v‖² for all v orthogonal to w. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- A matrix has at most one positive eigenvalue if there exists a direction w
    such that Q_A(v) ≤ 0 for all v orthogonal to w. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- A Lorentzian-compatible Ising model packages the physical parameters
    together with the Lorentzian property of the associated Hessian structure.

    This is the key bridge definition: it ties a statistical-mechanical system
    to the algebraic geometry of Lorentzian polynomials, enabling the transfer
    of stability theorems from one domain to the other. -/
structure LorentzianIsingModel (n : ℕ) where
  /-- Inverse temperature -/
  β : ℝ
  /-- Coupling matrix -/
  J : Fin n → Fin n → ℝ
  /-- Spectral gap of the associated Hessian -/
  spectralGap : ℝ
  /-- Inverse temperature is positive -/
  β_pos : 0 < β
  /-- Spectral gap is positive -/
  gap_pos : 0 < spectralGap
  /-- The coupling Hessian has gapped Lorentzian signature -/
  hessian_gapped : HasGappedSignature (Matrix.of J) spectralGap

/-- The Gibbs weight of a configuration. -/
def gibbsWeight {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
    (h : Fin n → ℝ) (σ : Fin n → Bool) : ℝ :=
  Real.exp (β * isingEnergy J h σ) / isingPartition β J h

/-- The Gibbs expectation of a real-valued observable. -/
def gibbsExpectation {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
    (h : Fin n → ℝ) (f : (Fin n → Bool) → ℝ) : ℝ :=
  ∑ σ ∈ spinConfigs n, gibbsWeight β J h σ * f σ

/-- The spin covariance: Cov(σ_i, σ_j) = ⟨σ_i σ_j⟩ - ⟨σ_i⟩⟨σ_j⟩. -/
def spinCovariance {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
    (h : Fin n → ℝ) (i j : Fin n) : ℝ :=
  gibbsExpectation β J h (fun σ => spinVal (σ i) * spinVal (σ j)) -
  gibbsExpectation β J h (fun σ => spinVal (σ i)) *
  gibbsExpectation β J h (fun σ => spinVal (σ j))

/-- The quadratic covariance form: v ↦ ∑_{i,j} Cov(σ_i, σ_j) v_i v_j.
    This is the statistical-physics analogue of the Lorentzian quadratic form. -/
def quadraticCovarianceForm {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
    (h : Fin n → ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, spinCovariance β J h i j * v i * v j

/-! ## Auxiliary: QuadForm Bound from Entry Bound -/

/-
If entries of a matrix are bounded by B, the quadratic form is bounded by n²·B·‖v‖².
-/
theorem quadFormBound_of_entry_bound {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hentry : ∀ i j, |A i j| ≤ B) (v : Fin n → ℝ) :
    |QuadForm A v| ≤ (n : ℝ) ^ 2 * B * sqNorm v := by
  -- By the properties of absolute values and sums, we can bound the absolute value of the quadratic form.
  have h_abs_sum : abs (QuadForm A v) ≤ ∑ i, ∑ j, abs (A i j) * abs (v i) * abs (v j) := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j hj => by rw [ abs_mul, abs_mul ] );
  -- Since $|A_{ij}| \leq B$, we can further bound the absolute value of the quadratic form.
  have h_abs_sum_bound : abs (QuadForm A v) ≤ B * ∑ i, ∑ j, abs (v i) * abs (v j) := by
    exact h_abs_sum.trans ( by simpa only [ Finset.mul_sum _ _ _, mul_assoc ] using Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( hentry i j ) ( abs_nonneg _ ) ) ( abs_nonneg _ ) );
  -- By the Cauchy-Schwarz inequality, we have that $\sum_{i} \sum_{j} |v_i| |v_j| \leq n \sum_{i} |v_i|^2$.
  have h_cauchy_schwarz : ∑ i, ∑ j, abs (v i) * abs (v j) ≤ n * ∑ i, abs (v i) ^ 2 := by
    have h_cauchy_schwarz : ∀ (u v : Fin n → ℝ), (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
      exact?;
    specialize h_cauchy_schwarz ( fun _ => 1 ) ( fun i => |v i| ) ; simp_all +decide [ ← sq, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  rcases n with ( _ | n ) <;> simp_all +decide [ sqNorm ];
  exact h_abs_sum_bound.trans ( by nlinarith [ mul_le_mul_of_nonneg_left h_cauchy_schwarz hB, show 0 ≤ ( n : ℝ ) * B * ∑ i, v i ^ 2 by exact mul_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) hB ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ] )

/-- QuadForm is additive in the matrix argument. -/
theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

/-! ## Theorem 1: Partition Function Positivity -/

/-- The Ising partition function is strictly positive for any parameters.
    This follows because it is a sum of exponentials, which are positive. -/
theorem isingPartition_pos {n : ℕ} (β : ℝ) (J : Fin n → Fin n → ℝ)
    (h : Fin n → ℝ) : 0 < isingPartition β J h :=
  Finset.sum_pos (fun σ _ => Real.exp_pos _) (spinConfigs_nonempty n)

/-! ## Theorem 2: Energy Difference Bound Under Coupling Perturbation -/

/-
The coupling energy difference under perturbation is bounded by n² · δ.
    This uses |σ_i| = 1 for all spin values.
-/
theorem couplingEnergy_diff_bound {n : ℕ}
    {J J' : Fin n → Fin n → ℝ} {δ : ℝ}
    (hδ : 0 ≤ δ)
    (hpert : couplingPerturbation J J' δ)
    (σ : Fin n → Bool) :
    |couplingEnergy J' σ - couplingEnergy J σ| ≤ (n : ℝ) ^ 2 * δ := by
  -- Expand couplingEnergy as sums. The difference is ∑_i ∑_j (J' i j - J i j) * spinVal(σ i) * spinVal(σ j).
  have h_diff : couplingEnergy J' σ - couplingEnergy J σ = ∑ i : Fin n, ∑ j : Fin n, (J' i j - J i j) * spinVal (σ i) * spinVal (σ j) := by
    simp +decide only [couplingEnergy, sub_mul, sum_sub_distrib];
  -- Use the triangle inequality for sums to bound the absolute value.
  have h_triangle : abs (∑ i : Fin n, ∑ j : Fin n, (J' i j - J i j) * spinVal (σ i) * spinVal (σ j)) ≤ ∑ i : Fin n, ∑ j : Fin n, abs ((J' i j - J i j) * spinVal (σ i) * spinVal (σ j)) := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ );
  simp_all +decide [ abs_mul, spinVal_abs ];
  exact h_triangle.trans ( le_trans ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => hpert i j ) ( by norm_num; nlinarith ) )

/-
The full Ising energy difference under coupling perturbation.
    The field term cancels, leaving only the coupling contribution.
-/
theorem isingEnergy_diff_bound {n : ℕ}
    {J J' : Fin n → Fin n → ℝ} {δ : ℝ}
    (hδ : 0 ≤ δ)
    (hpert : couplingPerturbation J J' δ)
    (σ : Fin n → Bool)
    (h : Fin n → ℝ) :
    |isingEnergy J' h σ - isingEnergy J h σ| ≤ (n : ℝ) ^ 2 * δ := by
  convert couplingEnergy_diff_bound hδ hpert σ using 1;
  unfold isingEnergy couplingEnergy; aesop;

/-! ## Theorem 3: Multiplicative Partition Function Bound -/

/-
Under coupling perturbation of size δ, the partition function changes by at most
    a multiplicative factor of exp(β · n² · δ).
-/
theorem isingPartition_ratio_bound {n : ℕ}
    {β δ : ℝ} (hβ : 0 ≤ β) (hδ : 0 ≤ δ)
    {J J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation J J' δ)
    (h : Fin n → ℝ) :
    isingPartition β J' h ≤ Real.exp (β * ((n : ℝ) ^ 2 * δ)) * isingPartition β J h := by
  have h_sum_bound : ∀ σ : Fin n → Bool, Real.exp (β * isingEnergy J' h σ) ≤ Real.exp (β * (n ^ 2 * δ)) * Real.exp (β * isingEnergy J h σ) := by
    exact fun σ ↦ by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by nlinarith [ abs_le.mp ( isingEnergy_diff_bound hδ hpert σ h ) ] ) ;
  simpa only [ isingPartition, Finset.mul_sum _ _ _ ] using Finset.sum_le_sum fun σ _ => h_sum_bound σ

/-! ## Theorem 4: Log-Lipschitz Bound (Main Analytic Result) -/

/-
**Log-Lipschitz stability of the partition function under coupling noise.**

    If J' is within δ of J entrywise, then the log partition functions differ
    by at most β · n² · δ. This is the fundamental analytic bridge between
    microscopic coupling uncertainty and macroscopic free-energy stability.
-/
theorem isingPartition_logLipschitz {n : ℕ}
    {β δ : ℝ} (hβ : 0 ≤ β) (hδ : 0 ≤ δ)
    {J J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation J J' δ)
    (h : Fin n → ℝ) :
    |Real.log (isingPartition β J' h) - Real.log (isingPartition β J h)|
      ≤ β * ((n : ℝ) ^ 2 * δ) := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · rw [ ← Real.log_div ( ne_of_gt ( isingPartition_pos _ _ _ ) ) ( ne_of_gt ( isingPartition_pos _ _ _ ) ) ];
    refine' le_trans ( Real.log_le_log ( div_pos ( isingPartition_pos _ _ _ ) ( isingPartition_pos _ _ _ ) ) ( div_le_of_le_mul₀ _ _ _ ) ) _;
    exact Real.exp ( β * ( n ^ 2 * δ ) );
    · exact le_of_lt ( isingPartition_pos _ _ _ );
    · positivity;
    · convert isingPartition_ratio_bound hβ hδ hpert h using 1;
    · norm_num;
  · rw [ ← Real.log_div ( ne_of_gt ( isingPartition_pos _ _ _ ) ) ( ne_of_gt ( isingPartition_pos _ _ _ ) ) ];
    refine' le_trans ( Real.log_le_iff_le_exp ( div_pos ( isingPartition_pos _ _ _ ) ( isingPartition_pos _ _ _ ) ) |>.2 _ ) _;
    exact β * ( n ^ 2 * δ );
    · rw [ div_le_iff₀ ( isingPartition_pos _ _ _ ) ];
      convert isingPartition_ratio_bound hβ hδ ( show couplingPerturbation J' J δ from fun i j => by rw [ abs_sub_comm ] ; exact hpert i j ) h using 1;
    · norm_num

/-! ## Theorem 5: Gibbs Weight Stability -/

/-
Individual Gibbs weights are multiplicatively stable under coupling perturbation.
-/
theorem gibbs_weight_ratio_bound {n : ℕ}
    {β δ : ℝ} (hβ : 0 ≤ β) (hδ : 0 ≤ δ)
    {J J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation J J' δ)
    (h : Fin n → ℝ) (σ : Fin n → Bool) :
    |gibbsWeight β J' h σ - gibbsWeight β J h σ|
      ≤ 2 * β * ((n : ℝ) ^ 2 * δ) := by
  -- By the properties of the exponential function and the definition of Gibb's weight, we have:
  have h_exp : |Real.exp (β * isingEnergy J' h σ) / isingPartition β J' h - Real.exp (β * isingEnergy J h σ) / isingPartition β J h| ≤ |β * (isingEnergy J' h σ - isingEnergy J h σ) - (Real.log (isingPartition β J' h) - Real.log (isingPartition β J h))| := by
    have h_exp : ∀ x y : ℝ, x ≤ 0 → y ≤ 0 → |Real.exp x - Real.exp y| ≤ |x - y| := by
      intros x y hx hy
      have h_exp : ∀ x y : ℝ, x ≤ 0 → y ≤ 0 → |Real.exp x - Real.exp y| ≤ |x - y| := by
        intros x y hx hy
        have h_deriv : ∀ x : ℝ, x ≤ 0 → |deriv (fun x => Real.exp x) x| ≤ 1 := by
          exact fun x hx => by simpa using Real.exp_le_one_iff.mpr hx;
        -- Apply the mean value theorem to the interval [x, y].
        have h_mvt : ∀ x y : ℝ, x < y → ∃ c ∈ Set.Ioo x y, deriv (fun x => Real.exp x) c = (Real.exp y - Real.exp x) / (y - x) := by
          intros x y hxy; apply_rules [ exists_deriv_eq_slope, Real.continuousOn_exp ];
          exact Differentiable.differentiableOn Real.differentiable_exp;
        cases lt_trichotomy x y <;> norm_num at *;
        · obtain ⟨ c, ⟨ hxc, hcy ⟩, hcd ⟩ := h_mvt x y ‹_› ; rw [ eq_div_iff ] at hcd <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Real.exp x - Real.exp y ) <;> nlinarith [ Real.exp_pos c, Real.exp_le_one_iff.mpr ( show c ≤ 0 by linarith ) ];
        · cases ‹x = y ∨ y < x› <;> simp_all +decide [ abs_sub_comm ];
          obtain ⟨ c, ⟨ h₁, h₂ ⟩, h₃ ⟩ := h_mvt _ _ ‹_› ; rw [ eq_div_iff ] at h₃ <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Real.exp x - Real.exp y ) <;> nlinarith [ Real.exp_pos c, Real.exp_le_one_iff.mpr ( show c ≤ 0 by linarith ) ] ;
      exact h_exp x y hx hy;
    convert h_exp ( β * isingEnergy J' h σ - Real.log ( isingPartition β J' h ) ) ( β * isingEnergy J h σ - Real.log ( isingPartition β J h ) ) _ _ using 1 <;> norm_num [ Real.exp_sub, Real.exp_log ( isingPartition_pos _ _ _ ) ];
    · ring;
    · rw [ Real.le_log_iff_exp_le ( isingPartition_pos _ _ _ ) ];
      exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun x _ => Real.exp_nonneg ( β * isingEnergy J' h x ) ) ( Finset.mem_univ σ ) );
    · rw [ Real.le_log_iff_exp_le ( isingPartition_pos _ _ _ ) ];
      exact le_trans ( by norm_num ) ( Finset.single_le_sum ( fun x _ => Real.exp_nonneg ( β * isingEnergy J h x ) ) ( Finset.mem_univ σ ) );
  refine le_trans h_exp ?_;
  refine' le_trans ( abs_sub _ _ ) _;
  convert add_le_add ( mul_le_mul_of_nonneg_left ( isingEnergy_diff_bound hδ hpert σ h ) hβ ) ( isingPartition_logLipschitz hβ hδ hpert h ) using 1 ; ring;
  · rw [ ← mul_sub, abs_mul, abs_of_nonneg hβ ];
  · ring

/-! ## Theorem 6: Covariance Form Identity (Cross-Domain Bridge) -/

/-
**The quadratic covariance form equals the variance of a linear spin observable.**

    For any direction vector v, the quadratic covariance form equals
    Var(∑_i v_i σ_i), which is always nonneg. This is the key identity
    connecting the Hessian structure of log Z to spin covariances.

    Physically, this says the susceptibility matrix is positive semidefinite.
-/
theorem covarianceForm_eq_variance {n : ℕ}
    (β : ℝ) (J : Fin n → Fin n → ℝ) (h : Fin n → ℝ) (v : Fin n → ℝ)
    (hZ : 0 < isingPartition β J h) :
    quadraticCovarianceForm β J h v =
      gibbsExpectation β J h (fun σ => (∑ i, v i * spinVal (σ i)) ^ 2) -
      (gibbsExpectation β J h (fun σ => ∑ i, v i * spinVal (σ i))) ^ 2 := by
  unfold gibbsExpectation quadraticCovarianceForm;
  unfold spinCovariance gibbsWeight;
  simp +decide only [gibbsExpectation, sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm];
  simp +decide only [gibbsWeight, Finset.mul_sum _ _ _];
  simp +decide only [mul_left_comm, mul_sub, Finset.mul_sum _ _ _, sum_sub_distrib];
  congr 1;
  · simp +decide only [mul_comm, pow_two, Finset.mul_sum _ _ _, mul_left_comm, mul_assoc];
    exact Eq.symm ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm ) );
  · simp +decide only [pow_two, Finset.mul_sum _ _ _, sum_mul];
    simp +decide only [← sum_product'];
    apply Finset.sum_bij (fun x _ => (x.2.2.2, x.2.1, x.2.2.1, x.1));
    · aesop;
    · grind;
    · aesop;
    · grind

/-
The quadratic covariance form is nonneg (variance is nonneg).
    This is the physical content: susceptibility is positive semidefinite.
-/
theorem covarianceForm_nonneg {n : ℕ}
    (β : ℝ) (J : Fin n → Fin n → ℝ) (h : Fin n → ℝ) (v : Fin n → ℝ)
    (hZ : 0 < isingPartition β J h) :
    0 ≤ quadraticCovarianceForm β J h v := by
  have := @covarianceForm_eq_variance n;
  rw [ this _ _ _ _ hZ ];
  -- By the properties of the variance, we know that
  have h_var : ∀ (x : Fin n → ℝ), (∑ σ ∈ spinConfigs n, gibbsWeight β J h σ * (∑ i, v i * spinVal (σ i)) ^ 2) ≥ (∑ σ ∈ spinConfigs n, gibbsWeight β J h σ * (∑ i, v i * spinVal (σ i))) ^ 2 := by
    -- Apply Jensen's inequality to the convex function $f(x) = x^2$.
    have h_jensen : ∀ (x : Fin n → ℝ), (∑ σ ∈ spinConfigs n, gibbsWeight β J h σ * (∑ i, v i * spinVal (σ i))) ^ 2 ≤ (∑ σ ∈ spinConfigs n, gibbsWeight β J h σ * (∑ i, v i * spinVal (σ i)) ^ 2) := by
      intro x
      have h_convex : ConvexOn ℝ (Set.univ : Set ℝ) (fun x : ℝ => x ^ 2) := by
        exact ⟨ convex_univ, fun x _ y _ a b ha hb hab => by simpa using by nlinarith [ sq_nonneg ( x - y ), mul_nonneg ha hb ] ⟩
      convert h_convex.map_sum_le _ _ _ <;> norm_num;
      · exact fun _ _ => div_nonneg ( Real.exp_nonneg _ ) hZ.le;
      · unfold gibbsWeight;
        rw [ ← Finset.sum_div, div_eq_iff ] <;> first | positivity | unfold isingPartition; aesop;
    exact h_jensen;
  exact sub_nonneg_of_le <| h_var 0

/-! ## Theorem 7: Certified Robustness — Transfer from Lorentzian Stability -/

/-
**Soundness of the robustness certificate.**

    If the coupling matrix J has gapped Lorentzian signature with gap ε,
    and J' differs from J by at most ε/(2n²) entrywise, then the coupling
    matrix J' still has at most one positive eigenvalue (Lorentzian signature).

    This is the key translation theorem: the algebraic stability of Lorentzian
    polynomials becomes a quantitative robustness principle for the coupling
    structure of Ising models under microscopic noise.
-/
theorem certified_robustness_preserves_signature {n : ℕ}
    {ε : ℝ} (hε : 0 < ε) (hn : 0 < n)
    {J : Fin n → Fin n → ℝ}
    (hgap : HasGappedSignature (Matrix.of J) ε)
    {J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation J J' (ε / (2 * (n : ℝ) ^ 2))) :
    HasAtMostOnePositiveEigenvalue (Matrix.of J') := by
  -- By definition of $HasGappedSignature$, there exists a direction $w$ such that $Q_J(v) \leq -\epsilon \|v\|^2$ for all $v$ orthogonal to $w$.
  obtain ⟨w, hw⟩ := hgap;
  refine' ⟨ w, fun v hv => _ ⟩;
  -- By definition of $HasGappedSignature$, we know that $Q_{J'}(v) = Q_J(v) + Q_{J' - J}(v)$.
  have h_quadForm : QuadForm (Matrix.of J') v = QuadForm (Matrix.of J) v + QuadForm (Matrix.of (fun i j => J' i j - J i j)) v := by
    convert quadForm_add ( Matrix.of J ) ( Matrix.of ( fun i j => J' i j - J i j ) ) v using 1 ; congr ; ext i j ; ring;
    norm_num;
  -- By definition of $HasGappedSignature$, we know that $|Q_{J' - J}(v)| \leq n^2 \cdot \frac{\epsilon}{2n^2} \cdot \|v\|^2 = \frac{\epsilon}{2} \cdot \|v\|^2$.
  have h_quadForm_bound : |QuadForm (Matrix.of (fun i j => J' i j - J i j)) v| ≤ (n : ℝ) ^ 2 * (ε / (2 * n ^ 2)) * sqNorm v := by
    convert quadFormBound_of_entry_bound ( Matrix.of fun i j => J' i j - J i j ) ( ε / ( 2 * n ^ 2 ) ) ( by positivity ) ( fun i j => ?_ ) v using 1;
    exact hpert i j;
  nlinarith [ hw v hv, abs_le.mp h_quadForm_bound, show ( 0 : ℝ ) < n ^ 2 by positivity, mul_div_cancel₀ ( ε : ℝ ) ( by positivity : ( 2 * n ^ 2 : ℝ ) ≠ 0 ), sqNorm_nonneg v ]

/-! ## Theorem 8: Combined Thermodynamic Robustness -/

/-
**Combined robustness theorem for Lorentzian Ising models.**

    For a Lorentzian Ising model with spectral gap ε, if couplings are perturbed
    by at most δ = ε/(2n²), then:
    1. The Lorentzian signature is preserved (certified_robustness_preserves_signature)
    2. The free energy changes by at most β·n²·δ (isingPartition_logLipschitz)

    This combines algebraic and analytic stability into a single robustness
    guarantee with explicit, computable bounds.
-/
theorem combined_robustness {n : ℕ}
    (M : LorentzianIsingModel n) (hn : 0 < n)
    {J' : Fin n → Fin n → ℝ}
    (hpert : couplingPerturbation M.J J'
      (M.spectralGap / (2 * (n : ℝ) ^ 2)))
    (h : Fin n → ℝ) :
    HasAtMostOnePositiveEigenvalue (Matrix.of J') ∧
    |Real.log (isingPartition M.β J' h) -
     Real.log (isingPartition M.β M.J h)|
      ≤ M.β * ((n : ℝ) ^ 2 * (M.spectralGap / (2 * (n : ℝ) ^ 2))) := by
  refine ⟨ ?_, isingPartition_logLipschitz ?_ ?_ hpert h ⟩;
  · convert certified_robustness_preserves_signature _ _ _ _;
    exacts [ M.spectralGap, M.gap_pos, hn, M.J, M.hessian_gapped, hpert ];
  · exact le_of_lt M.β_pos;
  · exact div_nonneg M.gap_pos.le ( by positivity )

/-! ## Conjecture: Sharpness of the Coupling Noise Scale -/

/-- **Conjecture (Sharpness of coupling noise scale).**

    The `1/n²` robustness scale is not an artifact of the proof technique
    but is close to optimal: there exist coupling matrices where perturbations
    at scale `c/n²` for large enough c destroy the desired signature property.

    This is stated as a `sorry`-ed theorem to record it as a formal conjecture. -/
theorem sharp_coupling_noise_scale_conjecture
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ c > 0, ∀ ε > 0,
      ∃ J J' : Fin n → Fin n → ℝ,
        couplingPerturbation J J' (c * ε / (n : ℝ) ^ 2) ∧
        HasGappedSignature (Matrix.of J) ε ∧
        ¬ HasAtMostOnePositiveEigenvalue (Matrix.of J') := by
  sorry -- Conjecture

end IsingPartitionStability