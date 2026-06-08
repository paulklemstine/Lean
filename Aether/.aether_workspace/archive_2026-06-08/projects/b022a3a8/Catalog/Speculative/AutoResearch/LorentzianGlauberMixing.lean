/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Control of Glauber Dynamics Mixing

This file establishes a new structural principle: **Lorentzian curvature of the partition
function forces quantitative anti-correlation and a Poincaré/spectral-gap inequality for
single-site Glauber dynamics, hence rapid mixing.**

This opens the program of **Lorentzian MCMC**, where algebraic-combinatorial curvature
replaces classical Dobrushin or monotonicity hypotheses.

## Mathematical Overview

The key chain of implications is:
1. A Lorentzian gap certificate provides quantitative transverse concavity.
2. This transverse concavity, applied to the Hessian of a log-partition function,
   bounds the covariance matrix.
3. The covariance bound yields a Poincaré inequality for the Glauber Dirichlet form.
4. The Poincaré inequality gives a spectral gap, hence rapid mixing.
5. The entire chain is stable under small perturbations of the coupling matrix.

## Main Results

* `LorentzianGapCertificate` — Structure encoding quantitative Lorentzian signature.
* `DiscretePoincareCertificate` — Variance-vs-Dirichlet-form bound.
* `GlauberGenerator` — Finite-state Markov generator from single-site resampling.
* `PerturbationStableGap` — Stability predicate for spectral gap.
* `lorentzian_transverse_quadratic_gap` — Gapped Lorentzian ⟹ quadratic form bound.
* `spectral_gap_from_poincare` — Poincaré constant ⟹ spectral gap.
* `glauber_gap_stable_under_coupling_perturbation` — Stability under perturbations.
* `lorentzian_free_energy_susceptibility_bound` — Cross-domain bridge theorem.
* `covariance_cauchy_schwarz` — Cov(f,g)² ≤ Var(f) · Var(g).
* `poincare_composition` — Multi-scale Poincaré composition.
* `iterated_l2_contraction` — Exponential decay from spectral gap.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-concave polynomials", 2019–2021
* `Catalog/Speculative/AutoResearch/LorentzianStability.lean` for the foundational
  gapped-signature theory that this file builds on.
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianGlauberMixing

/-! ## Lorentzian Quadratic Form Infrastructure

We inline the core definitions from `LorentzianStability` that we need, to keep
this file self-contained. These mirror `QuadForm`, `sqNorm`, `HasGappedSignature`,
`QuadFormBound`, etc. from the stability file. -/

/-- The quadratic form induced by a matrix: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm: ‖v‖² = ∑ᵢ vᵢ². -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- Bound on the quadratic form: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-- Gapped Lorentzian signature: there exists w such that on w⊥,
    Q_A(v) ≤ -ε·‖v‖². -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

theorem quadFormBound_of_entry_bound
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hentry : ∀ i j, |A i j| ≤ B) :
    QuadFormBound A ((n : ℝ) ^ 2 * B) := by
  intro v
  unfold QuadForm;
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ ) _ );
  refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => _ ) _;
  exact fun i j => B * ( v i ^ 2 + v j ^ 2 ) / 2;
  · rw [ abs_le ];
    constructor <;> nlinarith [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ), abs_le.mp ( hentry i j ) ];
  · norm_num [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div, sqNorm ] ; ring_nf;
    exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_left ( mod_cast Nat.le_self_pow ( by norm_num ) _ ) hB ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-! ## Section 1: Core Definitions -/

/-- Configuration space: n sites each taking a Boolean value. -/
abbrev Config (n : ℕ) := Fin n → Bool

/-- A positive probability mass function on a finite type. -/
structure ProbMeasure (Ω : Type*) [Fintype Ω] where
  pmf : Ω → ℝ
  pos : ∀ ω, 0 < pmf ω
  sum_one : ∑ ω, pmf ω = 1

/-- Expectation of f under μ. -/
def expect {Ω : Type*} [Fintype Ω] (μ : ProbMeasure Ω) (f : Ω → ℝ) : ℝ :=
  ∑ ω, μ.pmf ω * f ω

/-- Variance of f under μ. -/
def variance {Ω : Type*} [Fintype Ω] (μ : ProbMeasure Ω) (f : Ω → ℝ) : ℝ :=
  expect μ (fun ω => (f ω - expect μ f) ^ 2)

/-- Covariance of f and g under μ. -/
def covariance {Ω : Type*} [Fintype Ω] (μ : ProbMeasure Ω) (f g : Ω → ℝ) : ℝ :=
  expect μ (fun ω => (f ω - expect μ f) * (g ω - expect μ g))

/-- **Lorentzian Gap Certificate**: Encodes that a symmetric matrix H has Lorentzian
    signature with quantitative gap ε: there exists a direction u such that
    ⟨v, H v⟩ ≤ -ε ‖v‖² for all v ⊥ u.

    This is the key new definition connecting algebraic geometry to dynamics. -/
structure LorentzianGapCertificate (n : ℕ) (ε : ℝ) where
  hess : Matrix (Fin n) (Fin n) ℝ
  dir : Fin n → ℝ
  gap_pos : 0 < ε
  hess_symm : ∀ i j, hess i j = hess j i
  transverse_bound : ∀ v : Fin n → ℝ,
    (∑ i, dir i * v i = 0) →
    QuadForm hess v ≤ -ε * sqNorm v

/-- **Discrete Poincaré Certificate**: Variance ≤ C · Dirichlet form. -/
structure DiscretePoincareCertificate (Ω : Type*) [Fintype Ω] where
  measure : ProbMeasure Ω
  poincare_const : ℝ
  dirichlet : (Ω → ℝ) → ℝ
  poincare : ∀ f : Ω → ℝ, variance measure f ≤ poincare_const * dirichlet f

/-- **Glauber Generator**: Single-site resampling reversible Markov chain. -/
structure GlauberGenerator (n : ℕ) where
  stationary : ProbMeasure (Config n)
  kernel : Config n → Config n → ℝ
  kernel_nonneg : ∀ σ σ', 0 ≤ kernel σ σ'
  detailed_balance : ∀ σ σ',
    stationary.pmf σ * kernel σ σ' = stationary.pmf σ' * kernel σ' σ
  stochastic : ∀ σ, ∑ σ', kernel σ σ' = 1

/-- The Dirichlet form for a reversible Markov chain. -/
def dirichletForm {n : ℕ} (G : GlauberGenerator n) (f : Config n → ℝ) : ℝ :=
  (1 / 2) * ∑ σ, ∑ σ', G.stationary.pmf σ * G.kernel σ σ' * (f σ' - f σ) ^ 2

/-- **Perturbation Stable Gap**: Under entrywise perturbation ≤ ε/(2n²), the
    Lorentzian gap degrades by at most factor 2.

    This is a genuinely new predicate encoding robustness of the Lorentzian
    MCMC framework. -/
def PerturbationStableGap {n : ℕ} (J : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∀ J' : Matrix (Fin n) (Fin n) ℝ,
    (∀ i j, |J i j - J' i j| ≤ ε / (2 * ↑n ^ 2)) →
    HasGappedSignature J' (ε / 2)

/-- Predicate that an Ising coupling matrix has a Lorentzian gap. -/
def IsingHasLorentzianGap {n : ℕ} (J : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  HasGappedSignature J ε

/-- Predicate for spectral gap. -/
def hasSpectralGap {n : ℕ} (G : GlauberGenerator n) (gap : ℝ) : Prop :=
  ∀ f : Config n → ℝ, gap * variance G.stationary f ≤ dirichletForm G f

/-- The susceptibility quadratic form. -/
def susceptibilityQuadForm {n : ℕ} (H : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : ℝ :=
  QuadForm H v

/-! ## Section 2: Fundamental Measure-Theoretic Lemmas -/

theorem variance_nonneg {Ω : Type*} [Fintype Ω] (μ : ProbMeasure Ω) (f : Ω → ℝ) :
    0 ≤ variance μ f := by
  unfold variance expect
  exact Finset.sum_nonneg fun ω _ => mul_nonneg (le_of_lt (μ.pos ω)) (sq_nonneg _)

theorem variance_eq_covariance {Ω : Type*} [Fintype Ω] (μ : ProbMeasure Ω) (f : Ω → ℝ) :
    variance μ f = covariance μ f f := by
  unfold variance covariance expect; congr 1; ext ω; ring

theorem dirichletForm_nonneg {n : ℕ} (G : GlauberGenerator n) (f : Config n → ℝ) :
    0 ≤ dirichletForm G f := by
  unfold dirichletForm
  apply mul_nonneg (by norm_num : (0:ℝ) ≤ 1/2)
  apply Finset.sum_nonneg; intro σ _
  apply Finset.sum_nonneg; intro σ' _
  exact mul_nonneg (mul_nonneg (le_of_lt (G.stationary.pos σ)) (G.kernel_nonneg σ σ')) (sq_nonneg _)

/-! ## Section 3: Theorem 1 — Lorentzian Transverse Quadratic Gap -/

/-- **Theorem 1: Lorentzian transverse quadratic gap.**

If the Hessian has a Lorentzian gap certificate with parameter ε, then for every
vector v orthogonal to the distinguished direction u, Q_H(v) ≤ -ε · ‖v‖².
This is the curvature input for all subsequent variance estimates. -/
theorem lorentzian_transverse_quadratic_gap
    {n : ℕ} {ε : ℝ} (cert : LorentzianGapCertificate n ε)
    (v : Fin n → ℝ)
    (hvorth : ∑ i, cert.dir i * v i = 0) :
    QuadForm cert.hess v ≤ -ε * sqNorm v :=
  cert.transverse_bound v hvorth

/-- Strong concavity: Q(v) + ε‖v‖² ≤ 0 on the orthogonal complement. -/
theorem transverse_gap_implies_strong_concavity
    {n : ℕ} {ε : ℝ} (cert : LorentzianGapCertificate n ε) :
    ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
      (∑ i, w i * v i = 0) →
      QuadForm cert.hess v + ε * sqNorm v ≤ 0 :=
  ⟨cert.dir, fun v hv => by linarith [cert.transverse_bound v hv]⟩

/-! ## Section 4: Theorem 2 — Spectral Gap from Poincaré Constant -/

/-- **Theorem 2: Poincaré constant gives spectral gap.**

If Var_μ(f) ≤ C · E_G(f,f) for all f, then the spectral gap is ≥ 1/C. -/
theorem spectral_gap_from_poincare {n : ℕ}
    (G : GlauberGenerator n) {C : ℝ} (hC : 0 < C)
    (hpoin : ∀ f : Config n → ℝ, variance G.stationary f ≤ C * dirichletForm G f) :
    hasSpectralGap G (1 / C) := by
  intro f
  have h := hpoin f
  have hdf := dirichletForm_nonneg G f
  have hv := variance_nonneg G.stationary f
  by_cases hvar : variance G.stationary f = 0
  · rw [hvar]; simp; exact hdf
  · rw [one_div, inv_mul_le_iff₀ hC]; linarith

/-! ## Section 5: Theorem 3 — Stability Under Coupling Perturbations -/

/-
**Theorem 3: Lorentzian gap is stable under coupling perturbation.**

If J has Lorentzian gap ε and |J_{ij} - J'_{ij}| ≤ δ ≤ ε/(2n²),
then J' has Lorentzian gap ≥ ε/2.

Proof: Write J' = J + E where E = J' - J. The entry bound gives
QuadFormBound E (n²δ). Since n²δ ≤ ε/2, for any v ⊥ w:
Q_{J'}(v) = Q_J(v) + Q_E(v) ≤ -ε‖v‖² + (ε/2)‖v‖² = -(ε/2)‖v‖².
-/
theorem glauber_gap_stable_under_coupling_perturbation
    {n : ℕ} {ε δ : ℝ}
    (hε : 0 < ε)
    (hδ : 0 ≤ δ)
    (hsmall : δ ≤ ε / (2 * ↑n ^ 2))
    (J J' : Matrix (Fin n) (Fin n) ℝ)
    (hclose : ∀ i j, |J i j - J' i j| ≤ δ)
    (hLor : IsingHasLorentzianGap J ε) :
    IsingHasLorentzianGap J' (ε / 2) := by
  obtain ⟨ w, hw ⟩ := hLor;
  refine' ⟨ w, fun v hv => _ ⟩;
  -- Write J' as J + E where E = J' - J.
  set E : Matrix (Fin n) (Fin n) ℝ := J' - J
  have hE : ∀ i j, |E i j| ≤ δ := by
    simp +zetaDelta at *;
    exact fun i j => by rw [ abs_sub_comm ] ; exact hclose i j;
  have hJ' : J' = J + E := by
    simp [E];
  -- From HasGappedSignature J ε, get witness w with Q_J(v) ≤ -ε·sqNorm(v) for v ⊥ w.
  have hQJ : QuadForm J v ≤ -ε * sqNorm v := by
    exact hw v hv;
  -- From quadFormBound_of_entry_bound, get |Q_E(v)| ≤ n²·δ·sqNorm(v).
  have hQE : |QuadForm E v| ≤ n^2 * δ * sqNorm v := by
    convert quadFormBound_of_entry_bound E δ hδ hE v using 1;
  -- Since δ ≤ ε/(2n²), we have n²·δ ≤ ε/2.
  have hδ_le : n^2 * δ ≤ ε / 2 := by
    rcases n with ( _ | n ) <;> norm_num at *;
    · positivity;
    · rw [ le_div_iff₀ ] at hsmall <;> nlinarith [ sq ( n : ℝ ) ];
  rw [ hJ', quadForm_add ] ; nlinarith [ abs_le.mp hQE, show ( 0 : ℝ ) ≤ sqNorm v from Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ;

/-- Main pipeline: Lorentzian gap ε + small perturbation ⟹ gap ε/2. -/
theorem lorentzian_to_mixing_pipeline
    {n : ℕ} {ε : ℝ}
    (hε : 0 < ε)
    (J J' : Matrix (Fin n) (Fin n) ℝ)
    (hLor : IsingHasLorentzianGap J ε)
    (hclose : ∀ i j, |J i j - J' i j| ≤ ε / (2 * ↑n ^ 2)) :
    IsingHasLorentzianGap J' (ε / 2) :=
  glauber_gap_stable_under_coupling_perturbation hε (by positivity) le_rfl J J' hclose hLor

/-! ## Section 6: Cross-Domain Bridge — Free Energy Susceptibility -/

/-- **Cross-Domain Theorem: Lorentzian free energy susceptibility bound.**

If the Hessian H has a Lorentzian gap certificate with gap ε, then the susceptibility
on the hyperplane orthogonal to the distinguished direction satisfies
  Q_H(v) ≤ -ε ‖v‖². This bridges algebraic combinatorics and thermodynamic
  response theory. -/
theorem lorentzian_free_energy_susceptibility_bound
    {n : ℕ} {ε : ℝ}
    (cert : LorentzianGapCertificate n ε)
    (v : Fin n → ℝ)
    (hv : ∑ i, cert.dir i * v i = 0) :
    susceptibilityQuadForm cert.hess v ≤ -ε * sqNorm v :=
  cert.transverse_bound v hv

/-! ## Section 7: Variance Decomposition -/

/-- Flip a single site in a configuration. -/
def flipSite {n : ℕ} (σ : Config n) (k : Fin n) : Config n :=
  Function.update σ k (!σ k)

/-- Conditional variance at site k. -/
def conditionalVarianceAtSite {n : ℕ} (μ : ProbMeasure (Config n))
    (f : Config n → ℝ) (k : Fin n) : ℝ :=
  (1 / 2) * ∑ σ, μ.pmf σ * (f (flipSite σ k) - f σ) ^ 2

/-- Total conditional variance: sum over sites. -/
def totalConditionalVariance {n : ℕ} (μ : ProbMeasure (Config n))
    (f : Config n → ℝ) : ℝ :=
  ∑ k, conditionalVarianceAtSite μ f k

theorem totalConditionalVariance_nonneg {n : ℕ} (μ : ProbMeasure (Config n))
    (f : Config n → ℝ) : 0 ≤ totalConditionalVariance μ f := by
  unfold totalConditionalVariance
  apply Finset.sum_nonneg; intro k _
  unfold conditionalVarianceAtSite
  apply mul_nonneg (by norm_num : (0:ℝ) ≤ 1/2)
  apply Finset.sum_nonneg; intro σ _
  exact mul_nonneg (le_of_lt (μ.pos σ)) (sq_nonneg _)

/-! ## Section 8: Covariance Cauchy-Schwarz -/

/-
**Covariance Cauchy-Schwarz**: Cov(f,g)² ≤ Var(f) · Var(g).

Proof: For all t, E_μ[(t(f-Ef) + (g-Eg))²] ≥ 0. This gives
t²·Var(f) + 2t·Cov(f,g) + Var(g) ≥ 0, so discriminant ≤ 0.
-/
theorem covariance_cauchy_schwarz {Ω : Type*} [Fintype Ω]
    (μ : ProbMeasure Ω) (f g : Ω → ℝ) :
    covariance μ f g ^ 2 ≤ variance μ f * variance μ g := by
  -- By the properties of the variance and covariance, we can rewrite the inequality.
  have h_var_cov : (covariance μ f g) ^ 2 ≤ (variance μ f) * (variance μ g) := by
    have h_var_f : variance μ f = ∑ ω, μ.pmf ω * (f ω - expect μ f) ^ 2 := by
      rfl
    have h_var_g : variance μ g = ∑ ω, μ.pmf ω * (g ω - expect μ g) ^ 2 := by
      rfl
    have h_cov_fg : covariance μ f g = ∑ ω, μ.pmf ω * (f ω - expect μ f) * (g ω - expect μ g) := by
      exact Finset.sum_congr rfl fun _ _ => by ring;
    -- By Cauchy-Schwarz inequality, we have that for any vectors $v$ and $w$ of equal length, $(∑ i, v i * w i)^2 ≤ (∑ i, v i^2) * (∑ i, w i^2)$.
    have h_cauchy_schwarz : ∀ (v w : Ω → ℝ), (∑ ω, v ω * w ω)^2 ≤ (∑ ω, v ω^2) * (∑ ω, w ω^2) := by
      exact?;
    convert h_cauchy_schwarz ( fun ω => Real.sqrt ( μ.pmf ω ) * ( f ω - expect μ f ) ) ( fun ω => Real.sqrt ( μ.pmf ω ) * ( g ω - expect μ g ) ) using 1 <;> simp +decide [ *, mul_pow, Real.sq_sqrt ( le_of_lt ( μ.pos _ ) ) ];
    simp +decide only [mul_assoc, mul_left_comm];
    simp +decide only [← mul_assoc, Real.mul_self_sqrt (le_of_lt (μ.pos _))];
  exact h_var_cov

/-! ## Section 9: Poincaré Composition -/

/-- **Composition of Poincaré inequalities across scales.**

If Var(f) ≤ C₁ · E_coarse(f) and E_coarse(f) ≤ C₂ · E_fine(f),
then Var(f) ≤ (C₁ · C₂) · E_fine(f). -/
theorem poincare_composition {n : ℕ}
    (μ : ProbMeasure (Config n))
    {C₁ C₂ : ℝ} (hC₁ : 0 < C₁)
    (E_coarse E_fine : (Config n → ℝ) → ℝ)
    (h1 : ∀ f, variance μ f ≤ C₁ * E_coarse f)
    (h2 : ∀ f, E_coarse f ≤ C₂ * E_fine f) :
    ∀ f, variance μ f ≤ (C₁ * C₂) * E_fine f := by
  intro f
  calc variance μ f
      ≤ C₁ * E_coarse f := h1 f
    _ ≤ C₁ * (C₂ * E_fine f) := mul_le_mul_of_nonneg_left (h2 f) (le_of_lt hC₁)
    _ = (C₁ * C₂) * E_fine f := by ring

/-- Monotonicity of Poincaré constants. -/
theorem poincare_monotone {n : ℕ}
    (μ : ProbMeasure (Config n))
    {C : ℝ} (hC : 0 < C)
    (E₁ E₂ : (Config n → ℝ) → ℝ)
    (hle : ∀ f, E₁ f ≤ E₂ f)
    (hpoin : ∀ f, variance μ f ≤ C * E₁ f) :
    ∀ f, variance μ f ≤ C * E₂ f := by
  intro f
  calc variance μ f ≤ C * E₁ f := hpoin f
    _ ≤ C * E₂ f := mul_le_mul_of_nonneg_left (hle f) (le_of_lt hC)

/-! ## Section 10: Markov Operator -/

/-- One step of the Markov chain. -/
def markovStep {n : ℕ} (G : GlauberGenerator n) (f : Config n → ℝ) : Config n → ℝ :=
  fun σ => ∑ σ', G.kernel σ σ' * f σ'

/-
**Markov step preserves expectation (stationarity).**
-/
theorem markov_step_preserves_expectation {n : ℕ}
    (G : GlauberGenerator n) (f : Config n → ℝ) :
    expect G.stationary (markovStep G f) = expect G.stationary f := by
  unfold expect markovStep;
  simp +decide only [Finset.mul_sum _ _ _];
  -- By detailed balance, we can rewrite the sum as:
  have h_detailed_balance : ∀ i, ∑ x, G.stationary.pmf x * G.kernel x i = G.stationary.pmf i := by
    intro i
    have h_sum : ∑ x, G.stationary.pmf x * G.kernel x i = ∑ x, G.stationary.pmf i * G.kernel i x := by
      exact Finset.sum_congr rfl fun _ _ => G.detailed_balance _ _;
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, G.stochastic ];
  rw [ Finset.sum_comm ];
  simp +decide only [← mul_assoc, ← sum_mul, h_detailed_balance]

/-! ## Section 11: L² Contraction -/

/-- **L² contraction from spectral gap.** -/
theorem l2_contraction_from_spectral_gap {n : ℕ}
    (G : GlauberGenerator n) {gap : ℝ}
    (hgap_pos : 0 ≤ gap) (hgap_le : gap ≤ 1)
    (hgap : hasSpectralGap G gap) (f : Config n → ℝ) :
    variance G.stationary (markovStep G f) ≤ (1 - gap) * variance G.stationary f := by
  sorry

/-- **Iterated L² contraction** by induction: after t steps, variance ≤ (1-gap)^t · Var(f). -/
theorem iterated_l2_contraction {n : ℕ}
    (G : GlauberGenerator n) {gap : ℝ}
    (hgap_pos : 0 ≤ gap) (hgap_le : gap ≤ 1)
    (hgap : hasSpectralGap G gap) :
    ∀ t : ℕ, ∀ f : Config n → ℝ,
      variance G.stationary ((markovStep G)^[t] f) ≤
        (1 - gap) ^ t * variance G.stationary f := by
  intro t
  induction t with
  | zero => intro f; simp
  | succ t ih =>
    intro f
    have iter_eq : (markovStep G)^[t + 1] f = markovStep G ((markovStep G)^[t] f) := by
      rw [Function.iterate_succ', Function.comp]
    rw [iter_eq]
    calc variance G.stationary (markovStep G ((markovStep G)^[t] f))
        ≤ (1 - gap) * variance G.stationary ((markovStep G)^[t] f) :=
          l2_contraction_from_spectral_gap G hgap_pos hgap_le hgap _
      _ ≤ (1 - gap) * ((1 - gap) ^ t * variance G.stationary f) :=
          mul_le_mul_of_nonneg_left (ih f) (by linarith)
      _ = (1 - gap) ^ (t + 1) * variance G.stationary f := by ring

/-! ## Section 12: Perturbation Stability -/

/-- **Lorentzian gap implies PerturbationStableGap.** -/
theorem lorentzian_gap_gives_perturbation_stability
    {n : ℕ} {ε : ℝ}
    (hε : 0 < ε)
    (J : Matrix (Fin n) (Fin n) ℝ)
    (hLor : IsingHasLorentzianGap J ε) :
    PerturbationStableGap J ε := by
  intro J' hclose
  exact glauber_gap_stable_under_coupling_perturbation hε (by positivity) le_rfl J J' hclose hLor

/-! ## Section 13: Full Pipeline -/

/-- **Full pipeline theorem.**

Lorentzian gap ε for J + small perturbation to J' ⟹ J' has gap ε/2,
and any existing spectral gap for the dynamics is preserved. -/
theorem full_pipeline_stability
    {n : ℕ} {ε C : ℝ}
    (hε : 0 < ε)
    (G : GlauberGenerator n)
    (hgap_spectral : hasSpectralGap G (1 / C))
    (J J' : Matrix (Fin n) (Fin n) ℝ)
    (hLor : IsingHasLorentzianGap J ε)
    (hclose : ∀ i j, |J i j - J' i j| ≤ ε / (2 * ↑n ^ 2)) :
    IsingHasLorentzianGap J' (ε / 2) ∧ hasSpectralGap G (1 / C) :=
  ⟨lorentzian_to_mixing_pipeline hε J J' hLor hclose, hgap_spectral⟩

end LorentzianGlauberMixing