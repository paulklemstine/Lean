/-
# Quaternion Algebra: Basic Definitions and Properties

This file defines a real quaternion structure from scratch and proves
fundamental algebraic properties including:
- Multiplication (Hamilton's rules)
- Conjugation is an involution and anti-homomorphism
- Norm squared is multiplicative
- Inverse formula for nonzero quaternions
- Unit quaternion characterization
-/
import Mathlib

namespace QuatAlg

/-- Real quaternion: q = re + imI·i + imJ·j + imK·k -/
@[ext]
structure Quat where
  re : ℝ
  imI : ℝ
  imJ : ℝ
  imK : ℝ

namespace Quat

/-! ## Basic instances -/

instance : Zero Quat := ⟨⟨0, 0, 0, 0⟩⟩
instance : One Quat := ⟨⟨1, 0, 0, 0⟩⟩
instance : Neg Quat := ⟨fun q => ⟨-q.re, -q.imI, -q.imJ, -q.imK⟩⟩
instance : Add Quat := ⟨fun q₁ q₂ => ⟨q₁.re + q₂.re, q₁.imI + q₂.imI, q₁.imJ + q₂.imJ, q₁.imK + q₂.imK⟩⟩
instance : Sub Quat := ⟨fun q₁ q₂ => ⟨q₁.re - q₂.re, q₁.imI - q₂.imI, q₁.imJ - q₂.imJ, q₁.imK - q₂.imK⟩⟩

/-- Hamilton multiplication -/
instance : Mul Quat := ⟨fun q₁ q₂ =>
  ⟨q₁.re * q₂.re - q₁.imI * q₂.imI - q₁.imJ * q₂.imJ - q₁.imK * q₂.imK,
   q₁.re * q₂.imI + q₁.imI * q₂.re + q₁.imJ * q₂.imK - q₁.imK * q₂.imJ,
   q₁.re * q₂.imJ - q₁.imI * q₂.imK + q₁.imJ * q₂.re + q₁.imK * q₂.imI,
   q₁.re * q₂.imK + q₁.imI * q₂.imJ - q₁.imJ * q₂.imI + q₁.imK * q₂.re⟩⟩

instance : SMul ℝ Quat := ⟨fun r q => ⟨r * q.re, r * q.imI, r * q.imJ, r * q.imK⟩⟩

/-! ## Simp lemmas for components -/

@[simp] theorem zero_re : (0 : Quat).re = 0 := rfl
@[simp] theorem zero_imI : (0 : Quat).imI = 0 := rfl
@[simp] theorem zero_imJ : (0 : Quat).imJ = 0 := rfl
@[simp] theorem zero_imK : (0 : Quat).imK = 0 := rfl
@[simp] theorem one_re : (1 : Quat).re = 1 := rfl
@[simp] theorem one_imI : (1 : Quat).imI = 0 := rfl
@[simp] theorem one_imJ : (1 : Quat).imJ = 0 := rfl
@[simp] theorem one_imK : (1 : Quat).imK = 0 := rfl
@[simp] theorem neg_re (q : Quat) : (-q).re = -q.re := rfl
@[simp] theorem neg_imI (q : Quat) : (-q).imI = -q.imI := rfl
@[simp] theorem neg_imJ (q : Quat) : (-q).imJ = -q.imJ := rfl
@[simp] theorem neg_imK (q : Quat) : (-q).imK = -q.imK := rfl
@[simp] theorem add_re (q₁ q₂ : Quat) : (q₁ + q₂).re = q₁.re + q₂.re := rfl
@[simp] theorem add_imI (q₁ q₂ : Quat) : (q₁ + q₂).imI = q₁.imI + q₂.imI := rfl
@[simp] theorem add_imJ (q₁ q₂ : Quat) : (q₁ + q₂).imJ = q₁.imJ + q₂.imJ := rfl
@[simp] theorem add_imK (q₁ q₂ : Quat) : (q₁ + q₂).imK = q₁.imK + q₂.imK := rfl
@[simp] theorem sub_re (q₁ q₂ : Quat) : (q₁ - q₂).re = q₁.re - q₂.re := rfl
@[simp] theorem sub_imI (q₁ q₂ : Quat) : (q₁ - q₂).imI = q₁.imI - q₂.imI := rfl
@[simp] theorem sub_imJ (q₁ q₂ : Quat) : (q₁ - q₂).imJ = q₁.imJ - q₂.imJ := rfl
@[simp] theorem sub_imK (q₁ q₂ : Quat) : (q₁ - q₂).imK = q₁.imK - q₂.imK := rfl
@[simp] theorem mul_re (q₁ q₂ : Quat) :
    (q₁ * q₂).re = q₁.re * q₂.re - q₁.imI * q₂.imI - q₁.imJ * q₂.imJ - q₁.imK * q₂.imK := rfl
@[simp] theorem mul_imI (q₁ q₂ : Quat) :
    (q₁ * q₂).imI = q₁.re * q₂.imI + q₁.imI * q₂.re + q₁.imJ * q₂.imK - q₁.imK * q₂.imJ := rfl
@[simp] theorem mul_imJ (q₁ q₂ : Quat) :
    (q₁ * q₂).imJ = q₁.re * q₂.imJ - q₁.imI * q₂.imK + q₁.imJ * q₂.re + q₁.imK * q₂.imI := rfl
@[simp] theorem mul_imK (q₁ q₂ : Quat) :
    (q₁ * q₂).imK = q₁.re * q₂.imK + q₁.imI * q₂.imJ - q₁.imJ * q₂.imI + q₁.imK * q₂.re := rfl
@[simp] theorem smul_re (r : ℝ) (q : Quat) : (r • q).re = r * q.re := rfl
@[simp] theorem smul_imI (r : ℝ) (q : Quat) : (r • q).imI = r * q.imI := rfl
@[simp] theorem smul_imJ (r : ℝ) (q : Quat) : (r • q).imJ = r * q.imJ := rfl
@[simp] theorem smul_imK (r : ℝ) (q : Quat) : (r • q).imK = r * q.imK := rfl

/-! ## Ring axioms -/

theorem mul_one (q : Quat) : q * 1 = q := by ext <;> simp
theorem one_mul (q : Quat) : 1 * q = q := by ext <;> simp
theorem mul_assoc (q₁ q₂ q₃ : Quat) : q₁ * q₂ * q₃ = q₁ * (q₂ * q₃) := by
  ext <;> simp <;> ring
theorem add_comm (q₁ q₂ : Quat) : q₁ + q₂ = q₂ + q₁ := by ext <;> simp <;> ring
theorem add_assoc (q₁ q₂ q₃ : Quat) : q₁ + q₂ + q₃ = q₁ + (q₂ + q₃) := by
  ext <;> simp <;> ring
theorem left_distrib (q₁ q₂ q₃ : Quat) : q₁ * (q₂ + q₃) = q₁ * q₂ + q₁ * q₃ := by
  ext <;> simp <;> ring
theorem right_distrib (q₁ q₂ q₃ : Quat) : (q₁ + q₂) * q₃ = q₁ * q₃ + q₂ * q₃ := by
  ext <;> simp <;> ring

/-! ## Conjugation -/

/-- Quaternion conjugation: conj(a + bi + cj + dk) = a - bi - cj - dk -/
def conj (q : Quat) : Quat := ⟨q.re, -q.imI, -q.imJ, -q.imK⟩

@[simp] theorem conj_re (q : Quat) : (conj q).re = q.re := rfl
@[simp] theorem conj_imI (q : Quat) : (conj q).imI = -q.imI := rfl
@[simp] theorem conj_imJ (q : Quat) : (conj q).imJ = -q.imJ := rfl
@[simp] theorem conj_imK (q : Quat) : (conj q).imK = -q.imK := rfl

/-- Conjugation is an involution -/
theorem conj_conj (q : Quat) : conj (conj q) = q := by ext <;> simp

/-- Conjugation is an anti-homomorphism: conj(q₁q₂) = conj(q₂)conj(q₁) -/
theorem conj_mul (q₁ q₂ : Quat) : conj (q₁ * q₂) = conj q₂ * conj q₁ := by
  ext <;> simp [conj] <;> ring

theorem conj_one : conj 1 = 1 := by ext <;> simp [conj]
theorem conj_neg (q : Quat) : conj (-q) = -conj q := by ext <;> simp [conj]

/-! ## Norm squared -/

/-- Squared norm: ‖q‖² = re² + imI² + imJ² + imK² -/
def normSq (q : Quat) : ℝ := q.re ^ 2 + q.imI ^ 2 + q.imJ ^ 2 + q.imK ^ 2

/-- q * conj(q) = normSq(q) as a real quaternion -/
theorem mul_conj (q : Quat) : q * conj q = ⟨normSq q, 0, 0, 0⟩ := by
  ext <;> simp [normSq, conj] <;> ring

/-- conj(q) * q = normSq(q) as a real quaternion -/
theorem conj_mul_self (q : Quat) : conj q * q = ⟨normSq q, 0, 0, 0⟩ := by
  ext <;> simp [normSq, conj] <;> ring

theorem normSq_nonneg (q : Quat) : 0 ≤ normSq q := by unfold normSq; positivity

theorem normSq_eq_zero {q : Quat} : normSq q = 0 ↔ q = 0 := by
  constructor
  · intro h
    unfold normSq at h
    have h1 : q.re = 0 := by nlinarith [sq_nonneg q.re, sq_nonneg q.imI, sq_nonneg q.imJ, sq_nonneg q.imK]
    have h2 : q.imI = 0 := by nlinarith [sq_nonneg q.re, sq_nonneg q.imI, sq_nonneg q.imJ, sq_nonneg q.imK]
    have h3 : q.imJ = 0 := by nlinarith [sq_nonneg q.re, sq_nonneg q.imI, sq_nonneg q.imJ, sq_nonneg q.imK]
    have h4 : q.imK = 0 := by nlinarith [sq_nonneg q.re, sq_nonneg q.imI, sq_nonneg q.imJ, sq_nonneg q.imK]
    ext <;> assumption
  · intro h; rw [h]; unfold normSq; simp

theorem normSq_pos {q : Quat} (hq : q ≠ 0) : 0 < normSq q := by
  rcases (normSq_nonneg q).lt_or_eq with h | h
  · exact h
  · exfalso; exact hq (normSq_eq_zero.mp h.symm)

/-- **Multiplicativity of the norm squared** — a fundamental identity. -/
theorem normSq_mul (q₁ q₂ : Quat) : normSq (q₁ * q₂) = normSq q₁ * normSq q₂ := by
  unfold normSq; simp; ring

theorem normSq_one : normSq 1 = 1 := by unfold normSq; simp

theorem normSq_neg (q : Quat) : normSq (-q) = normSq q := by
  unfold normSq; simp

theorem normSq_conj (q : Quat) : normSq (conj q) = normSq q := by
  unfold normSq; simp

/-! ## Inverse -/

/-- Inverse of a quaternion: q⁻¹ = conj(q) / normSq(q) -/
noncomputable def inv (q : Quat) : Quat :=
  ⟨q.re / normSq q, -q.imI / normSq q, -q.imJ / normSq q, -q.imK / normSq q⟩

theorem inv_mul_cancel {q : Quat} (hq : q ≠ 0) : inv q * q = 1 := by
  have hns : normSq q ≠ 0 := ne_of_gt (normSq_pos hq)
  ext <;> simp [inv] <;> field_simp <;> unfold normSq <;> ring

theorem mul_inv_cancel {q : Quat} (hq : q ≠ 0) : q * inv q = 1 := by
  have hns : normSq q ≠ 0 := ne_of_gt (normSq_pos hq)
  ext <;> simp [inv] <;> field_simp <;> unfold normSq <;> ring

/-! ## Unit quaternions -/

/-- A unit quaternion has normSq = 1 -/
def IsUnit (q : Quat) : Prop := normSq q = 1

theorem isUnit_one : IsUnit 1 := normSq_one

theorem isUnit_neg_one : IsUnit (-1) := by
  unfold IsUnit; rw [normSq_neg]; exact normSq_one

theorem isUnit_mul {q₁ q₂ : Quat} (h₁ : IsUnit q₁) (h₂ : IsUnit q₂) :
    IsUnit (q₁ * q₂) := by
  unfold IsUnit at *; rw [normSq_mul, h₁, h₂, _root_.mul_one]

theorem isUnit_conj {q : Quat} (h : IsUnit q) : IsUnit (conj q) := by
  unfold IsUnit at *; rw [normSq_conj]; exact h

theorem isUnit_ne_zero {q : Quat} (h : IsUnit q) : q ≠ 0 := by
  intro heq; rw [heq] at h; unfold IsUnit normSq at h; simp at h

/-- For unit quaternions, inv q = conj q -/
theorem inv_eq_conj {q : Quat} (h : IsUnit q) : inv q = conj q := by
  unfold inv IsUnit normSq at *; ext <;> simp [conj] <;> rw [h] <;> ring

/-! ## Pure quaternions -/

/-- A pure (imaginary) quaternion has re = 0 -/
def IsPure (q : Quat) : Prop := q.re = 0

/-- The subtype of pure quaternions -/
def PureQuat := {q : Quat // IsPure q}

/-- Construct a pure quaternion from three coordinates -/
def mkPure (x y z : ℝ) : PureQuat := ⟨⟨0, x, y, z⟩, rfl⟩

/-- Extract the 3D vector from a pure quaternion -/
def pureToVec (v : PureQuat) : Fin 3 → ℝ := ![v.1.imI, v.1.imJ, v.1.imK]

/-- Construct a pure quaternion from a 3D vector -/
def vecToPure (v : Fin 3 → ℝ) : PureQuat := mkPure (v 0) (v 1) (v 2)

/-- The basis quaternions i, j, k -/
def qi : Quat := ⟨0, 1, 0, 0⟩
def qj : Quat := ⟨0, 0, 1, 0⟩
def qk : Quat := ⟨0, 0, 0, 1⟩

/-- The squared norm of a pure quaternion equals the Euclidean norm squared -/
theorem normSq_pure (v : PureQuat) :
    normSq v.1 = v.1.imI ^ 2 + v.1.imJ ^ 2 + v.1.imK ^ 2 := by
  unfold normSq; rw [v.2]; ring

end Quat

end QuatAlg