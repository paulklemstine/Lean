/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Certified Floating-Point Lorentzian Recognition: Core Definitions

This file introduces the foundational definitions for a **quantitative decision theory**
of Lorentzian polynomial recognition under coefficient uncertainty. The key idea is to
treat Lorentzianity not as a brittle symbolic property, but as a spectrally
margin-certified geometric phase.

## Main Definitions

* `FPBox` — A floating-point coefficient box representing interval uncertainty
* `CertifiedDecision` — A three-valued decision type (yes/no/unknown)
* `QuadForm`, `sqNorm` — Quadratic form and squared norm
* `HasGappedSignature` — Gapped Lorentzian signature with spectral margin
* `HasLorentzianSignature` — At-most-one positive eigenvalue condition
* `QuadFormBound` — Bound on quadratic form norm
* `RobustLorentzianOnBox` — Uniform Lorentzianity on a coefficient box
* `HasObstruction` — Quantitative non-Lorentzianity obstruction
* `LorentzianCertificate` — Certificate structure for numerical verification

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Matrix

noncomputable section

namespace CertifiedLorentzian

/-! ## Core Linear Algebra -/

/-- The quadratic form induced by a matrix A: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Squared Euclidean norm. -/
def sqNorm {n : ℕ} (v : Fin n → ℝ) : ℝ := ∑ i, v i ^ 2

/-- A bound on the quadratic form: |Q_A(v)| ≤ c · ‖v‖² for all v. -/
def QuadFormBound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) : Prop :=
  ∀ v : Fin n → ℝ, |QuadForm A v| ≤ c * sqNorm v

/-- Gapped Lorentzian signature with margin ε. -/
def HasGappedSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (ε : ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ -ε * sqNorm v

/-- A matrix has at most one positive eigenvalue (Lorentzian signature). -/
def HasLorentzianSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Quantitative obstruction to Lorentzianity: for every candidate witness w,
    there exists v ⊥ w with Q(v) ≥ obs · ‖v‖² and ‖v‖ > 0. -/
def HasObstruction {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (obs : ℝ) : Prop :=
  ∀ w : Fin n → ℝ, ∃ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) ∧ QuadForm A v ≥ obs * sqNorm v ∧ sqNorm v > 0

/-! ## Floating-Point Box -/

/-- A floating-point coefficient box: center ± radius for each coordinate. -/
structure FPBox (ι : Type*) where
  center : ι → ℝ
  radius : ι → ℝ
  radius_nonneg : ∀ i, 0 ≤ radius i

/-- Membership in an FPBox. -/
def FPBox.mem {ι : Type*} (B : FPBox ι) (a : ι → ℝ) : Prop :=
  ∀ i, |a i - B.center i| ≤ B.radius i

/-! ## Certified Decision -/

/-- A three-valued certified decision. -/
inductive CertifiedDecision
  | yes
  | no
  | unknown
  deriving DecidableEq, Repr

/-! ## Robust Recognition -/

/-- Every coefficient vector in a box produces a matrix with Lorentzian signature. -/
def RobustLorentzianOnBox {n : ℕ} {ι : Type*} (B : FPBox ι)
    (toMatrix : (ι → ℝ) → Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ a, B.mem a → HasLorentzianSignature (toMatrix a)

/-- No coefficient vector in a box produces a matrix with Lorentzian signature. -/
def RobustNonLorentzianOnBox {n : ℕ} {ι : Type*} (B : FPBox ι)
    (toMatrix : (ι → ℝ) → Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ a, B.mem a → ¬HasLorentzianSignature (toMatrix a)

/-! ## Energy Functionals (Cross-Domain Bridge) -/

/-- Energy decay functional on orthogonal complement. -/
def energyDecayFunctional {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (w v : Fin n → ℝ) : ℝ :=
  if (∑ i, w i * v i = 0) then QuadForm A v else 0

/-- Positive norm functional on orthogonal complement. -/
def positiveNormFunctional {n : ℕ} (w v : Fin n → ℝ) : ℝ :=
  if (∑ i, w i * v i = 0) then sqNorm v else 0

/-! ## Certificate Structure -/

/-- A **LorentzianCertificate** bundles a witness direction, spectral gap,
    and certification proof. -/
structure LorentzianCertificate (n : ℕ) where
  witness : Fin n → ℝ
  gap : ℝ
  gap_pos : 0 < gap
  certMatrix : Matrix (Fin n) (Fin n) ℝ
  certified : ∀ v : Fin n → ℝ,
    (∑ i, witness i * v i = 0) → QuadForm certMatrix v ≤ -gap * sqNorm v

/-! ## Fundamental Lemmas -/

theorem sqNorm_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ sqNorm v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

theorem quadForm_add {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    QuadForm (A + E) v = QuadForm A v + QuadForm E v := by
  simp only [QuadForm, Matrix.add_apply, add_mul, Finset.sum_add_distrib]

theorem hasLorentzianSignature_of_gapped {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {ε : ℝ} (hε : 0 ≤ ε) (hgap : HasGappedSignature A ε) :
    HasLorentzianSignature A := by
  obtain ⟨w, hw⟩ := hgap
  exact ⟨w, fun v hv => le_trans (hw v hv)
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos_of_nonneg hε) (sqNorm_nonneg v))⟩

end CertifiedLorentzian