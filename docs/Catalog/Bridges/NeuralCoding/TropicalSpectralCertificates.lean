/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Spectral Certificates for Neural Network Robustness

This file establishes a new geometric theory of adversarial robustness in which
**tropical spectral data** replace classical eigenspectral computations. We prove
that in structured regions of piecewise-linear networks, a **tropical spectral gap**
(Gershgorin-type diagonal dominance margin) controls the radius of perturbations
that preserve local optimality, yielding certificates that are both mathematically
novel and algorithmically cheaper than Euclidean Hessian methods.

## Main Results

* `coercivity_of_tropical_gap` — **Bridge theorem**: A symmetric matrix with
  positive tropical spectral gap (Gershgorin margin) has a coercive quadratic form.

* `robustRadius_of_quadratic_coercivity` — **Robustness radius theorem**:
  Quadratic coercivity of a local model implies a certified robustness radius.

* `energy_barrier_of_coercivity` — **Energy barrier / metastability theorem**
  (cross-domain bridge to statistical physics).

* `trust_region_quadratic_gain` — **Trust-region optimization bridge**.

* `tropicalGapCompute_spec` — **Verified algorithm**.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Builds on: `Pythagorean.TropicalLorentzianShadows`, `Speculative.AutoResearch.LorentzianStability`
-/

open Finset BigOperators Real Matrix

noncomputable section

namespace TropicalSpectralCertificates

/-! ## Section 1: Core Definitions -/

/-- Squared Euclidean norm: `‖v‖² = ∑ᵢ vᵢ²`. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ :=
  ∑ i, v i ^ 2

/-- The quadratic form induced by a matrix `Q`:
    `Q(v) = ∑ᵢ ∑ⱼ vᵢ · Q(i,j) · vⱼ`. -/
def quadraticForm {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, v i * Q i j * v j

/-- **Tropical spectral gap** (Gershgorin diagonal dominance margin):
    For each row `i`, the diagonal entry exceeds the sum of absolute values
    of off-diagonal entries by at least `γ`. Computable in O(n²) time. -/
def TropicalSpectralGap {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ) (γ : ℝ) : Prop :=
  ∀ i : Fin n, Q i i - ∑ j ∈ Finset.univ.erase i, |Q i j| ≥ γ

/-- **Certified robust radius**: `f` does not decrease within a ball of
    squared radius `r²` around `x`. -/
def CertifiedRobustRadius {n : ℕ}
    (f : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ) (r : ℝ) : Prop :=
  0 ≤ r ∧ ∀ h : Fin n → ℝ, sqNorm h ≤ r ^ 2 →
    f (fun i => x i + h i) ≥ f x

/-- **Tropical curvature certificate**: bundles the data needed for
    tropical spectral certification. -/
structure TropicalCurvatureCertificate (n : ℕ) where
  Q : Matrix (Fin n) (Fin n) ℝ
  gradNorm : ℝ
  gap : ℝ
  remBound : ℝ
  gap_nonneg : 0 ≤ gap
  gradNorm_nonneg : 0 ≤ gradNorm
  remBound_nonneg : 0 ≤ remBound

/-! ## Section 2: Basic Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem sqNorm_zero {n : ℕ} : sqNorm (fun _ : Fin n => (0 : ℝ)) = 0 := by
  simp [sqNorm]

theorem quadraticForm_zero_vec {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ) :
    quadraticForm Q (fun _ => 0) = 0 := by
  simp [quadraticForm]

/-! ## Section 3: The AM-GM Bound -/

/-
AM-GM for absolute value of products: `2|ab| ≤ a² + b²`.
-/
theorem two_mul_abs_le_sq_add_sq (a b : ℝ) :
    2 * |a * b| ≤ a ^ 2 + b ^ 2 := by
  cases abs_cases ( a * b ) <;> cases abs_cases ( a + b ) <;> cases abs_cases ( a - b ) <;> nlinarith [ sq_nonneg ( a - b ), sq_nonneg ( a + b ) ]

/-! ## Section 4: Bridge Theorem — Tropical Spectral Gap Implies Coercivity -/

/-
**Bridge Theorem (Gershgorin Coercivity).**
    If `Q` is symmetric and has tropical spectral gap `γ`, then
    `Q(v) ≥ γ · ‖v‖²` for all `v`.

    This is the central result connecting tropical combinatorial data
    to analytic coercivity, replacing O(n³) eigenvalue computations
    with O(n²) entry checks.
-/
theorem coercivity_of_tropical_gap {n : ℕ} (Q : Matrix (Fin n) (Fin n) ℝ) (γ : ℝ)
    (hQ : Q.IsSymm) (hgap : TropicalSpectralGap Q γ) :
    ∀ v : Fin n → ℝ, quadraticForm Q v ≥ γ * sqNorm v := by
  -- We show quadraticForm Q v ≥ γ * sqNorm v by Gershgorin-type argument.
  intro v
  have h_split : quadraticForm Q v = ∑ i, Q i i * v i ^ 2 + ∑ i, ∑ j ∈ Finset.univ.erase i, v i * Q i j * v j := by
    simp +decide [ quadraticForm, sq, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  -- For each i,j with i ≠ j: v i * Q i j * v j ≥ -|Q i j| * |v i * v j| ≥ -|Q i j| * (v i ^ 2 + v j ^ 2) / 2
  have h_bound : ∀ i j, i ≠ j → v i * Q i j * v j ≥ -|Q i j| * ((v i) ^ 2 + (v j) ^ 2) / 2 := by
    intro i j hij;
    cases abs_cases ( Q i j ) <;> nlinarith [ sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ) ];
  -- Sum over off-diagonal pairs. Using symmetry of Q (|Q i j| = |Q j i|):
  have h_sum_bound : ∑ i, ∑ j ∈ Finset.univ.erase i, v i * Q i j * v j ≥ ∑ i, ∑ j ∈ Finset.univ.erase i, -|Q i j| * ((v i) ^ 2 + (v j) ^ 2) / 2 := by
    exact Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => h_bound i j <| by aesop;
  -- Combine the diagonal terms and the off-diagonal terms:
  have h_combined : quadraticForm Q v ≥ ∑ i, Q i i * v i ^ 2 - ∑ i, (v i) ^ 2 * ∑ j ∈ Finset.univ.erase i, |Q i j| := by
    -- By combining terms, we can factor out common factors and simplify the expression.
    have h_simplify : ∑ i, ∑ j ∈ Finset.univ.erase i, -|Q i j| * ((v i) ^ 2 + (v j) ^ 2) / 2 = -∑ i, (v i) ^ 2 * ∑ j ∈ Finset.univ.erase i, |Q i j| := by
      norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_div, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
      norm_num [ mul_sub, Finset.mul_sum _ _ _, Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, hQ.apply ] ; ring;
      rw [ show ( ∑ x : Fin n, ∑ x_1 : Fin n, |Q x x_1| * v x_1 ^ 2 * ( 1 / 2 ) ) = ∑ x : Fin n, ∑ x_1 : Fin n, |Q x x_1| * v x ^ 2 * ( 1 / 2 ) by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hQ.apply ] ] ; norm_num [ ← Finset.sum_mul _ _ _ ] ; ring;
    linarith;
  -- Using the tropical spectral gap condition:
  have h_tropical_gap : ∑ i, Q i i * v i ^ 2 - ∑ i, (v i) ^ 2 * ∑ j ∈ Finset.univ.erase i, |Q i j| ≥ γ * ∑ i, (v i) ^ 2 := by
    rw [ Finset.mul_sum _ _ _ ] ; rw [ ← Finset.sum_sub_distrib ] ; exact Finset.sum_le_sum fun i _ => by nlinarith only [ hgap i ] ;
  exact h_combined.trans' h_tropical_gap

/-! ## Section 5: Scalar Optimization Lemmas -/

/-
Scalar coercive bound: `(α/2)t - Rt² ≥ 0` when `2Rt ≤ α`.
-/
theorem scalar_coercive_bound {α R t : ℝ}
    (ht : 0 ≤ t) (_hα : 0 ≤ α) (_hR : 0 ≤ R) (hbound : 2 * R * t ≤ α) :
    (1/2 : ℝ) * α * t - R * t ^ 2 ≥ 0 := by
  nlinarith

/-
Scalar energy barrier: `(α/2)t - Rt² ≥ (α/4)t` when `Rt ≤ α/4`.
-/
theorem scalar_energy_barrier {α R t : ℝ}
    (ht : 0 ≤ t) (_hα : 0 ≤ α) (_hR : 0 ≤ R) (hbound : R * t ≤ α / 4) :
    (1/2 : ℝ) * α * t - R * t ^ 2 ≥ (α / 4) * t := by
  nlinarith

/-
Trust-region scalar margin:
    `-G·s + (α/2)·s² ≥ -G²/(2α)` for all `s ≥ 0`.
-/
theorem trust_region_margin_bound {G α : ℝ} (hα : 0 < α) (_hG : 0 ≤ G) :
    ∀ s : ℝ, 0 ≤ s → -G * s + (1/2 : ℝ) * α * s ^ 2 ≥ -G ^ 2 / (2 * α) := by
  field_simp;
  exact fun s hs => by nlinarith [ sq_nonneg ( s * α - G ) ] ;

/-! ## Section 6: Robustness Radius Theorem -/

/-
**Robustness at critical points via quadratic coercivity.**
    If `f` has a local quadratic lower bound with coercivity `α` and
    quartic remainder `R`, then `f` is nondecreasing on balls where
    `2R·r² ≤ α`.
-/
theorem robustRadius_of_quadratic_coercivity
    {n : ℕ} (f : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ)
    {α R ρ : ℝ} (hα : 0 < α) (hR : 0 ≤ R) (hρ : 0 ≤ ρ)
    (hlocal : ∀ h : Fin n → ℝ, sqNorm h ≤ ρ ^ 2 →
      f (fun i => x i + h i) ≥ f x + (1/2 : ℝ) * α * sqNorm h - R * (sqNorm h) ^ 2)
    {r : ℝ} (hr : 0 ≤ r) (hrρ : r ≤ ρ) (hRr : 2 * R * r ^ 2 ≤ α) :
    CertifiedRobustRadius f x r := by
  exact ⟨ hr, fun h hh => le_trans ( by nlinarith [ sqNorm_nonneg h, scalar_coercive_bound ( sqNorm_nonneg h ) hα.le hR ( by nlinarith [ sqNorm_nonneg h ] ) ] ) ( hlocal h <| by nlinarith [ sqNorm_nonneg h ] ) ⟩

/-
**Combined tropical certificate**: tropical gap → certified robustness.
-/
theorem tropical_certified_robustness
    {n : ℕ} (f : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ)
    (Q : Matrix (Fin n) (Fin n) ℝ) {γ R ρ : ℝ}
    (hQ : Q.IsSymm) (hgap : TropicalSpectralGap Q γ)
    (hγ : 0 < γ) (hR : 0 ≤ R) (hρ : 0 ≤ ρ)
    (hlocal : ∀ h : Fin n → ℝ, sqNorm h ≤ ρ ^ 2 →
      f (fun i => x i + h i) ≥
        f x + (1/2 : ℝ) * quadraticForm Q h - R * (sqNorm h) ^ 2)
    {r : ℝ} (hr : 0 ≤ r) (hrρ : r ≤ ρ) (hRr : 2 * R * r ^ 2 ≤ γ) :
    CertifiedRobustRadius f x r := by
  convert robustRadius_of_quadratic_coercivity _ _ _ _ _ _ _ _ _ using 1;
  exact γ;
  exact R;
  exact ρ;
  any_goals assumption;
  exact fun h hh => le_trans ( by nlinarith [ coercivity_of_tropical_gap Q γ hQ hgap h ] ) ( hlocal h hh )

/-! ## Section 7: Energy Barrier Theorem (Cross-Domain Bridge)

Connects adversarial robustness to **energy landscape theory** from
statistical physics. The tropical spectral gap prevents low-energy escape
directions, creating a barrier proportional to gap × radius².
-/

/-
**Energy barrier from coercivity (metastability bound).**
    On the sphere `‖h‖² = r²`, with `R·r² ≤ α/4`, we have
    `E(x+h) ≥ E(x) + (α/4)·r²`.
-/
theorem energy_barrier_of_coercivity
    {n : ℕ} (E : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ)
    {α R ρ : ℝ} (_hα : 0 < α) (_hR : 0 ≤ R) (hρ : 0 ≤ ρ)
    (hlocal : ∀ h : Fin n → ℝ, sqNorm h ≤ ρ ^ 2 →
      E (fun i => x i + h i) ≥ E x + (1/2 : ℝ) * α * sqNorm h - R * (sqNorm h) ^ 2)
    {r : ℝ} (hr : 0 ≤ r) (hrρ : r ≤ ρ) (hRr : R * r ^ 2 ≤ α / 4) :
    ∀ h : Fin n → ℝ, sqNorm h = r ^ 2 →
      E (fun i => x i + h i) ≥ E x + (α / 4) * r ^ 2 := by
  exact fun h hh => le_trans ( by rw [ hh ] ; nlinarith [ sq_nonneg ( r * R - 1 / 2 * α ) ] ) ( hlocal h ( by nlinarith ) )

/-! ## Section 8: Trust-Region Optimization Bridge -/

/-
**Trust-region improvement bound.**
    The worst-case quadratic model improvement over the ball is bounded
    below by `-G²/(2α)`, where `G` is the gradient norm bound and `α`
    is the coercivity.
-/
theorem trust_region_quadratic_gain
    {G α s : ℝ} (hα : 0 < α) (_hG : 0 ≤ G) (hs : 0 ≤ s) :
    -G * s + (1/2 : ℝ) * α * s ^ 2 ≥ -(G ^ 2 / (2 * α)) := by
  convert trust_region_margin_bound hα _hG s hs using 1 ; ring

/-! ## Section 9: Exponential Bridge (Conditional) -/

/-
**Exponential bridge**: If the coercivity grows exponentially in the
    tropical gap, the robustness radius inherits this exponential growth.
-/
theorem robustRadius_exp_tropGap_lower_bound
    {n : ℕ} (f : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ)
    (Q : Matrix (Fin n) (Fin n) ℝ) {γ C₀ R ρ : ℝ}
    (_hQ : Q.IsSymm)
    (_hgap : TropicalSpectralGap Q γ)
    (hC₀ : 0 < C₀) (hR : 0 ≤ R) (hρ : 0 ≤ ρ)
    (hbridge : ∀ v : Fin n → ℝ,
      quadraticForm Q v ≥ C₀ * Real.exp γ * sqNorm v)
    (hlocal : ∀ h : Fin n → ℝ, sqNorm h ≤ ρ ^ 2 →
      f (fun i => x i + h i) ≥
        f x + (1/2 : ℝ) * quadraticForm Q h - R * (sqNorm h) ^ 2)
    {r : ℝ} (hr : 0 ≤ r) (hrρ : r ≤ ρ)
    (hRr : 2 * R * r ^ 2 ≤ C₀ * Real.exp γ) :
    CertifiedRobustRadius f x r := by
  convert robustRadius_of_quadratic_coercivity _ _ _ _ _ _ _ _ _ using 1;
  exact C₀ * Real.exp γ;
  exact R;
  exact ρ;
  any_goals linarith;
  · positivity;
  · exact fun h hh => by linarith [ hlocal h hh, hbridge h ] ;

/-! ## Section 10: Verified Computational Algorithm -/

/-- Compute the tropical spectral gap from matrix entries. -/
def tropicalGapCompute {n : ℕ} [NeZero n]
    (Q : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨⟨0, Fin.pos'⟩, Finset.mem_univ _⟩
    (fun i => Q i i - ∑ j ∈ Finset.univ.erase i, |Q i j|)

/-
The computed gap witnesses the TropicalSpectralGap property.
-/
theorem tropicalGapCompute_spec {n : ℕ} [NeZero n]
    (Q : Matrix (Fin n) (Fin n) ℝ) :
    TropicalSpectralGap Q (tropicalGapCompute Q) := by
  intro i;
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
The computed gap is at most every row dominance margin.
-/
theorem tropicalGapCompute_le {n : ℕ} [NeZero n]
    (Q : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropicalGapCompute Q ≤ Q i i - ∑ j ∈ Finset.univ.erase i, |Q i j| := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
Monotonicity: larger gap implies weaker gap condition.
-/
theorem tropical_gap_monotone {n : ℕ}
    (Q : Matrix (Fin n) (Fin n) ℝ) {γ₁ γ₂ : ℝ}
    (h : γ₁ ≤ γ₂) (hgap : TropicalSpectralGap Q γ₂) :
    TropicalSpectralGap Q γ₁ := by
  exact fun i => le_trans h ( hgap i )

/-! ## Section 11: 2×2 Bridge Specialization -/

/-
For 2×2 symmetric matrices, the bridge theorem specializes cleanly.
-/
theorem coercivity_of_tropical_gap_2x2
    (Q : Matrix (Fin 2) (Fin 2) ℝ) (γ : ℝ) (_hγ : 0 < γ)
    (hQ : Q.IsSymm)
    (hgap : TropicalSpectralGap Q γ) :
    ∀ v : Fin 2 → ℝ, quadraticForm Q v ≥ γ * sqNorm v := by
  convert coercivity_of_tropical_gap Q γ hQ hgap using 1

end TropicalSpectralCertificates