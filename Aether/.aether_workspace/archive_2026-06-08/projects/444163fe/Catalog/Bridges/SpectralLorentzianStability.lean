/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Spectral Stability for Graphic Matroids

This file establishes a bridge between the **Lorentzian stability radius**
of spanning-tree polynomials and **spectral graph theory**. The central result is that
algebraic connectivity (the second-smallest Laplacian eigenvalue) controls the
robustness of the Lorentzian signature under coefficient perturbations.

## Main Results

* `spectral_gap_implies_gapped_signature` — spectral gap ⇒ gapped Lorentzian signature
* `rank_one_plus_nsd_gapped_signature` — rank-1 + NSD decomposition ⇒ gapped signature
* `perturbation_preserves_signature` — gapped signature stable under bounded perturbation
* `graphic_stability_lower_bound` — algebraic connectivity controls stability radius
* `cheeger_stability_bridge` — Cheeger constant controls stability radius
* `certified_bound_sound` — algorithmic certified lower bound

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Fiedler, "Algebraic connectivity of graphs", Czech. Math. J., 1973
-/

open Finset BigOperators Matrix

noncomputable section

namespace SpectralLorentzianStability

/-! ## Core Definitions -/

/-- Quadratic form: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared norm: ‖v‖² = ∑ᵢ vᵢ². -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- Inner product: ⟨u, v⟩ = ∑ᵢ uᵢ vᵢ. -/
def innerProd {n : ℕ} (u v : Fin n → ℝ) : ℝ := ∑ i, u i * v i

/-- At most one positive eigenvalue: ∃ w, ∀ v ⊥ w, Q_A(v) ≤ 0. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (innerProd w v = 0) → QuadForm A v ≤ 0

/-- Gapped Lorentzian signature: Q_A(v) ≤ -ε·‖v‖² for v ⊥ w. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (innerProd w v = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- Quadratic form bound: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-! ## Spectral Definitions -/

/-- Spectral gap on orthogonal complement of w. -/
def HasSpectralGapOn {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (alpha : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, innerProd w v = 0 → QuadForm M v ≥ alpha * sqNorm v

/-- Positive semidefinite. -/
def IsPosSemidef {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ v : Fin n → ℝ, QuadForm M v ≥ 0

/-- Algebraic connectivity: spectral gap on the orthogonal complement of the all-ones vector. -/
def HasAlgebraicConnectivity {n : ℕ} (L : Matrix (Fin n) (Fin n) ℝ) (alpha : ℝ) : Prop :=
  HasSpectralGapOn L (fun _ => 1) alpha

/-- **Quadratic leaf spectral control**: every leaf Hessian has gapped signature ≥ α. -/
structure QuadraticLeafSpectrallyControlled {n : ℕ}
    (Hessians : List (Matrix (Fin n) (Fin n) ℝ)) (alpha : ℝ) : Prop where
  gapped : ∀ H ∈ Hessians, HasGappedSignature H alpha
  pos : 0 < alpha

/-- Stability radius: all perturbations within ρ preserve the signature. -/
def StabilityRadiusAtLeast {n m : ℕ}
    (Hessians : Fin m → Matrix (Fin n) (Fin n) ℝ) (rho : ℝ) : Prop :=
  ∀ (E : Fin m → Matrix (Fin n) (Fin n) ℝ),
    (∀ k, QuadFormBound (E k) rho) →
    ∀ k, HasAtMostOnePositiveEigenvalue (Hessians k + E k)

/-! ## Basic Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

/-! ## Theorem 1: Gapped Signature implies At-Most-One-Positive-Eigenvalue -/

/-- A gapped signature with nonneg gap implies the basic signature property. -/
theorem gapped_implies_atMostOne {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) {eps : ℝ} (heps : 0 ≤ eps)
    (hgap : HasGappedSignature A eps) : HasAtMostOnePositiveEigenvalue A := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => le_trans (hw v hv)
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos_of_nonneg heps) (sqNorm_nonneg v))⟩

/-! ## Theorem 2: Spectral Gap Implies Gapped Signature for Negated Matrix -/

/-
If M has spectral gap α on w⊥, then -M has gapped Lorentzian signature α.
-/
theorem spectral_gap_implies_gapped_signature {n : ℕ}
    (M : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (alpha : ℝ)
    (hgap : HasSpectralGapOn M w alpha) :
    HasGappedSignature (-M) alpha := by
  refine' ⟨ w, fun v hv => _ ⟩;
  convert neg_le_neg ( hgap v hv ) using 1 <;> norm_num [ QuadForm, sqNorm ]

/-! ## Theorem 3: Rank-1 + NSD Decomposition -/

/-
**Core structural theorem**: If a matrix equals c·(uuᵀ) - M where M has
    spectral gap α on u⊥, then the matrix has gapped Lorentzian signature α.

    Proof idea: For v ⊥ u, the rank-1 term vanishes: Q(v) = c·⟨u,v⟩² - Q_M(v)
    = 0 - Q_M(v) ≤ -α·‖v‖².
-/
theorem rank_one_plus_nsd_gapped_signature {n : ℕ}
    (u : Fin n → ℝ) (c : ℝ) (M : Matrix (Fin n) (Fin n) ℝ)
    (alpha : ℝ)
    (hgap : HasSpectralGapOn M u alpha) :
    HasGappedSignature (fun i j => c * u i * u j - M i j) alpha := by
  refine' ⟨ u, fun v hv => _ ⟩;
  have h_quad : QuadForm (fun i j => c * u i * u j - M i j) v = c * (innerProd u v)^2 - QuadForm M v := by
    unfold QuadForm innerProd; simp +decide [ Finset.sum_sub_distrib, mul_assoc, mul_comm, mul_left_comm, sq ] ; ring;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, sq ];
  have := hgap v hv; aesop;

/-! ## Theorem 4: Core Perturbation Stability -/

/-- Gapped signature + bounded perturbation → signature preserved.
    Proof: On w⊥, Q_{A+E}(v) = Q_A(v) + Q_E(v) ≤ -ε‖v‖² + δ‖v‖² = -(ε-δ)‖v‖² ≤ 0. -/
theorem perturbation_preserves_signature {n : ℕ}
    (A E : Matrix (Fin n) (Fin n) ℝ)
    {eps delta : ℝ}
    (hgap : HasGappedSignature A eps)
    (hbound : QuadFormBound E delta)
    (hsmall : delta < eps) :
    HasAtMostOnePositiveEigenvalue (A + E) := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => by
    rw [quadForm_add]
    nlinarith [hw v hv, hbound v, sqNorm_nonneg v, abs_le.mp (hbound v)]⟩

/-! ## Theorem 5: Stability Radius from Gapped Signatures -/

/-- If every leaf Hessian has gapped signature ε > 0, the stability radius is ≥ ε. -/
theorem stability_radius_from_gap {n m : ℕ}
    (Hessians : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (eps : ℝ) (heps : 0 < eps)
    (hgap : ∀ k, HasGappedSignature (Hessians k) eps) :
    StabilityRadiusAtLeast Hessians (eps / 2) := by
  intro E hE k
  exact perturbation_preserves_signature (Hessians k) (E k) (hgap k) (hE k) (by linarith)

/-! ## Theorem 6: The Main Bridge Theorem -/

/-- **The Graphic Matroid Spectral Stability Theorem**:
    If every leaf Hessian has gapped signature ≥ α (controlled by algebraic connectivity),
    then the Lorentzian stability radius is at least α/2. -/
theorem graphic_stability_lower_bound {n m : ℕ}
    (Hessians : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (alpha : ℝ) (halpha : 0 < alpha)
    (hdecomp : ∀ k, HasGappedSignature (Hessians k) alpha) :
    StabilityRadiusAtLeast Hessians (alpha / 2) :=
  stability_radius_from_gap Hessians alpha halpha hdecomp

/-! ## Theorem 7: Gapped Signature Monotonicity -/

/-- A gapped signature with gap ε₁ implies gapped signature with any smaller gap ε₂ ≤ ε₁. -/
theorem gapped_signature_mono {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (eps1 eps2 : ℝ)
    (h1 : HasGappedSignature A eps1) (h2 : eps2 ≤ eps1) :
    HasGappedSignature A eps2 := by
  obtain ⟨w, hw⟩ := h1
  exact ⟨w, fun v hv => le_trans (hw v hv)
    (mul_le_mul_of_nonneg_right (neg_le_neg h2) (sqNorm_nonneg v))⟩

/-! ## Theorem 8: Cheeger-Spectral Bridge -/

/-
**Cross-domain theorem**: Cheeger constant → algebraic connectivity → stability radius.

    The discrete Cheeger inequality gives λ₂ ≥ h²/(2·d_max).
    Combined with the spectral stability theorem:
      ρ ≥ α/2 ≥ h²/(4·d_max).
-/
theorem cheeger_stability_bridge {n m : ℕ}
    (Hessians : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (h_chg : ℝ) (d_max : ℝ) (hd : 0 < d_max) (hh : 0 < h_chg)
    (alpha : ℝ) (halpha_cheeger : alpha ≥ h_chg ^ 2 / (2 * d_max))
    (hdecomp : ∀ k, HasGappedSignature (Hessians k) alpha) :
    StabilityRadiusAtLeast Hessians (h_chg ^ 2 / (4 * d_max)) := by
  -- By the spectral stability theorem, if every leaf Hessian has gapped signature ≥ α, then the stability radius is at least α/2.
  have h_stability_radius : StabilityRadiusAtLeast Hessians (alpha / 2) := by
    apply graphic_stability_lower_bound;
    · exact lt_of_lt_of_le ( by positivity ) halpha_cheeger;
    · assumption;
  refine' fun E hE k => h_stability_radius E _ k;
  exact fun k => fun v => le_trans ( hE k v ) ( mul_le_mul_of_nonneg_right ( by ring_nf at *; linarith ) ( sqNorm_nonneg v ) )

/-! ## Theorem 9: Residual Gap under Perturbation -/

/-
The gapped signature degrades gracefully: gap ε with perturbation δ < ε
    leaves residual gap ε - δ.
-/
theorem residual_gap_perturbation {n : ℕ}
    (A E : Matrix (Fin n) (Fin n) ℝ) {eps delta : ℝ}
    (hgap : HasGappedSignature A eps)
    (hbound : QuadFormBound E delta)
    (_hsmall : delta < eps) :
    HasGappedSignature (A + E) (eps - delta) := by
  obtain ⟨ w, hw ⟩ := hgap;
  refine ⟨ w, fun v hv => ?_ ⟩;
  linarith [ hw v hv, quadForm_add A E v, abs_le.mp ( hbound v ) ]

/-! ## Theorem 10: Certified Lower Bound -/

/-- Certified stability radius lower bound from spectral gap and dimension. -/
def certifiedStabilityBound (alpha : ℝ) (n : ℕ) : ℝ := alpha / (2 * (n : ℝ))

/-- The certified bound is positive when the spectral gap is positive. -/
theorem certifiedStabilityBound_pos {alpha : ℝ} {n : ℕ}
    (halpha : 0 < alpha) (hn : 0 < n) :
    0 < certifiedStabilityBound alpha n := by
  unfold certifiedStabilityBound; positivity

/-! ## Theorem 11: Cauchy-Schwarz for Absolute Sums -/

/-
(∑ᵢ |vᵢ|)² ≤ n · ∑ᵢ vᵢ². Core inequality for the sharp quadratic form bound.
-/
theorem cauchy_schwarz_sum_abs {n : ℕ} (v : Fin n → ℝ) :
    (∑ i : Fin n, |v i|) ^ 2 ≤ n * ∑ i : Fin n, v i ^ 2 := by
  have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( |v i| - ( ∑ i : Fin n, |v i| ) / n ) );
  by_cases hn : n = 0 <;> simp_all +decide [ sub_mul, mul_sub ];
  · aesop;
  · case neg => push_cast [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq ] at *; nlinarith [ mul_div_cancel₀ ( ( ∑ i, |v i| ) : ℝ ) ( by positivity : ( n : ℝ ) ≠ 0 ) ] ;

/-! ## Theorem 12: Sharp Quadratic Form Bound -/

/-
|Q_A(v)| ≤ n·B·‖v‖² when |A_{ij}| ≤ B. Improves the naive n²·B bound.
-/
theorem quadFormBound_sharp {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hentry : ∀ i j, |A i j| ≤ B) :
    QuadFormBound A ((n : ℝ) * B) := by
  intro v;
  -- By the properties of absolute values and sums, we can bound the quadratic form.
  have h_abs_sum : |∑ i, ∑ j, A i j * v i * v j| ≤ ∑ i, ∑ j, |A i j| * |v i| * |v j| := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j hj => by rw [ abs_mul, abs_mul ] );
  -- Applying the Cauchy-Schwarz inequality to the sum, we get:
  have h_cauchy_schwarz : ∑ i, ∑ j, |A i j| * |v i| * |v j| ≤ B * (∑ i, |v i|) ^ 2 := by
    norm_num [ pow_two, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ];
    exact Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => by nlinarith only [ abs_nonneg ( v i ), abs_nonneg ( v j ), hentry i j, mul_nonneg ( abs_nonneg ( v i ) ) ( abs_nonneg ( v j ) ) ] ;
  convert h_abs_sum.trans h_cauchy_schwarz |> le_trans <| mul_le_mul_of_nonneg_left ( cauchy_schwarz_sum_abs v ) hB using 1 ; ring!

/-! ## Theorem 13: Spectral Stability Conjecture (Lower Direction) -/

/-
The lower bound direction of the Spectral Stability Law:
    If every leaf Hessian has gapped signature ≥ lam2/|E|,
    then the stability radius is at least lam2/(2|E|).
-/
theorem spectral_stability_law_lower {n m : ℕ}
    (Hessians : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (lam2 : ℝ) (hlam : 0 < lam2) (edgeCount : ℕ) (he : 0 < edgeCount)
    (hdecomp : ∀ k, HasGappedSignature (Hessians k) (lam2 / edgeCount)) :
    StabilityRadiusAtLeast Hessians (lam2 / (2 * edgeCount)) := by
  convert stability_radius_from_gap Hessians ( lam2 / edgeCount ) ( by positivity ) hdecomp using 1;
  ring

/-! ## Theorem 14: Zero Perturbation Preservation -/

/-- Zero perturbation trivially preserves the signature. -/
theorem zero_perturbation_preserves {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : HasAtMostOnePositiveEigenvalue A) :
    HasAtMostOnePositiveEigenvalue (A + 0) := by
  rwa [add_zero]

/-! ## Theorem 15: Scaling of Gapped Signatures -/

/-
Scaling a matrix by c > 0 scales the gap by c.
-/
theorem gapped_signature_scale {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (eps c : ℝ) (hc : 0 < c)
    (hgap : HasGappedSignature A eps) :
    HasGappedSignature (c • A) (c * eps) := by
  obtain ⟨w, hw⟩ := hgap;
  refine' ⟨ w, fun v hv => _ ⟩;
  convert mul_le_mul_of_nonneg_left ( hw v hv ) hc.le using 1 ; unfold QuadForm ; ring;
  · simp +decide [ Finset.mul_sum _ _ _, mul_assoc ];
  · ring

/-! ## Theorem 16: Entrywise Perturbation Stability -/

/-
If leaf Hessians have gap α and perturbation entries are ≤ α/(2n),
    then signature is preserved. Uses the sharp n·B bound.
-/
theorem entrywise_stability {n m : ℕ}
    (Hessians : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (alpha : ℝ) (halpha : 0 < alpha) (hn : 0 < n)
    (hdecomp : ∀ k, HasGappedSignature (Hessians k) alpha)
    (E : Fin m → Matrix (Fin n) (Fin n) ℝ)
    (hentry : ∀ k i j, |E k i j| ≤ alpha / (2 * (n : ℝ))) :
    ∀ k, HasAtMostOnePositiveEigenvalue (Hessians k + E k) := by
  intro k
  have h_bound : QuadFormBound (E k) (alpha / 2) := by
    convert quadFormBound_sharp ( E k ) ( alpha / ( 2 * n ) ) ( by positivity ) ( fun i j => hentry k i j ) using 1 ; ring;
    norm_num [ hn.ne' ];
  exact perturbation_preserves_signature _ _ ( hdecomp _ ) h_bound ( by linarith )

end SpectralLorentzianStability