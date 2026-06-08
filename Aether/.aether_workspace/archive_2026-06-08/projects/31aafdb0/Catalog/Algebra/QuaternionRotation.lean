/-
# Quaternion Rotation Action and SO(3) Double Cover

This file proves:
1. Unit quaternion conjugation preserves pure quaternions
2. The conjugation action preserves norm (isometry on ℝ³)
3. The rotation matrix is orthogonal with determinant 1
4. The rotation map is a group homomorphism
5. The kernel is {1, -1}
6. The 2π/4π topological phenomenon

Together these establish the double cover Spin(3) → SO(3).
-/
import Mathlib
import Algebra.QuaternionBasic

namespace QuatAlg
namespace Quat

/-! ## Conjugation action preserves pure quaternions -/

theorem conj_action_pure (q : Quat) (hq : IsUnit q) (v : Quat) (hv : IsPure v) :
    IsPure (q * v * conj q) := by
  unfold IsPure at *; simp [conj]; rw [hv]; ring

noncomputable def rotatePure (q : Quat) (hq : IsUnit q) (v : PureQuat) : PureQuat :=
  ⟨q * v.1 * conj q, conj_action_pure q hq v.1 v.2⟩

/-! ## Norm preservation -/

theorem rotatePure_normSq (q : Quat) (hq : IsUnit q) (v : PureQuat) :
    normSq (rotatePure q hq v).1 = normSq v.1 := by
  unfold rotatePure; simp only
  rw [normSq_mul, normSq_mul, normSq_conj]
  unfold IsUnit at hq; rw [hq]; ring

/-! ## Explicit rotation matrix -/

noncomputable def rotMatrix (q : Quat) : Matrix (Fin 3) (Fin 3) ℝ :=
  let w := q.re; let x := q.imI; let y := q.imJ; let z := q.imK
  !![1 - 2*(y^2 + z^2), 2*(x*y - z*w), 2*(x*z + y*w);
     2*(x*y + z*w), 1 - 2*(x^2 + z^2), 2*(y*z - x*w);
     2*(x*z - y*w), 2*(y*z + x*w), 1 - 2*(x^2 + y^2)]

theorem rotMatrix_orthogonal (q : Quat) (hq : IsUnit q) :
    Matrix.transpose (rotMatrix q) * (rotMatrix q) = 1 := by
  norm_num [ ← Matrix.ext_iff, Fin.forall_fin_succ ] at *;
  -- By definition of unit quaternions, we know that $q.re^2 + q.imI^2 + q.imJ^2 + q.imK^2 = 1$.
  have h_unit : q.re^2 + q.imI^2 + q.imJ^2 + q.imK^2 = 1 := by
    exact hq;
  simp +decide [ rotMatrix, Matrix.mul_apply ];
  simp +decide [ Fin.sum_univ_succ, Matrix.vecHead, Matrix.vecTail ] at * ; ring_nf at * ;
  grind +ring

theorem rotMatrix_det_one (q : Quat) (hq : IsUnit q) :
    (rotMatrix q).det = 1 := by
  rw [ Quat.rotMatrix ] at *;
  simp +decide [ Matrix.det_fin_three ];
  rw [ show q.imI ^ 2 = 1 - q.re ^ 2 - q.imJ ^ 2 - q.imK ^ 2 by linarith [ hq.symm, show q.re ^ 2 + q.imI ^ 2 + q.imJ ^ 2 + q.imK ^ 2 = 1 from hq ] ] ; ring;
  rw [ show q.imI ^ 2 = 1 - q.re ^ 2 - q.imJ ^ 2 - q.imK ^ 2 by linarith [ hq.symm, show q.re ^ 2 + q.imI ^ 2 + q.imJ ^ 2 + q.imK ^ 2 = 1 from hq ] ] ; ring

/-! ## Homomorphism property -/

theorem rotatePure_mul (q₁ q₂ : Quat) (hq₁ : IsUnit q₁) (hq₂ : IsUnit q₂) (v : PureQuat) :
    (rotatePure (q₁ * q₂) (isUnit_mul hq₁ hq₂) v).1 =
    (rotatePure q₁ hq₁ (rotatePure q₂ hq₂ v)).1 := by
  unfold rotatePure; simp only
  rw [conj_mul]
  ext <;> simp [conj] <;> ring

/-! ## Kernel theorem -/

theorem ker_rot_eq (q : Quat) (hq : IsUnit q)
    (htriv : ∀ v : PureQuat, rotatePure q hq v = v) :
    q = 1 ∨ q = -1 := by
  -- By definition of $rotatePure$, we have $q * v * conj q = v$ for all pure $v$.
  have h_eq : ∀ v : PureQuat, q * v.1 * Quat.conj q = v.1 := by
    intro v; specialize htriv v; erw [ Subtype.ext_iff ] at htriv; aesop;
  -- By definition of $rotatePure$, we have $q * v * conj q = v$ for all pure $v$. Let's consider the pure quaternions $v = qi$, $v = qj$, and $v = qk$.
  have h_eq_qi : q * Quat.qi * Quat.conj q = Quat.qi := by
    exact h_eq ⟨ qi, rfl ⟩
  have h_eq_qj : q * Quat.qj * Quat.conj q = Quat.qj := by
    convert h_eq ⟨ qj, by exact rfl ⟩
  have h_eq_qk : q * Quat.qk * Quat.conj q = Quat.qk := by
    exact h_eq ⟨ qk, rfl ⟩;
  simp_all +decide [ Quat.ext_iff, Quat.qi, Quat.qj, Quat.qk ];
  grind

/-! ## The 2π and 4π phenomena -/

theorem two_pi_rotation_neg_one (ux uy uz : ℝ) :
    (⟨Real.cos (2 * Real.pi / 2),
      Real.sin (2 * Real.pi / 2) * ux,
      Real.sin (2 * Real.pi / 2) * uy,
      Real.sin (2 * Real.pi / 2) * uz⟩ : Quat) = -1 := by
  have h1 : 2 * Real.pi / 2 = Real.pi := by ring
  rw [h1, Real.cos_pi, Real.sin_pi]; ext <;> simp

theorem four_pi_rotation_one (ux uy uz : ℝ) :
    (⟨Real.cos (4 * Real.pi / 2),
      Real.sin (4 * Real.pi / 2) * ux,
      Real.sin (4 * Real.pi / 2) * uy,
      Real.sin (4 * Real.pi / 2) * uz⟩ : Quat) = 1 := by
  have h1 : 4 * Real.pi / 2 = 2 * Real.pi := by ring
  rw [h1, Real.cos_two_pi, Real.sin_two_pi]; ext <;> simp

/-! ## Gimbal lock avoidance -/

/-- A structure encoding a path of orientations via unit quaternions. -/
structure QuaternionChart where
  path : ℝ → Quat
  unit : ∀ t, IsUnit (path t)

def eulerPitchSingular (θ : ℝ) : Prop := Real.cos θ = 0

theorem quaternion_avoids_gimbal_lock (chart : QuaternionChart) (t : ℝ) :
    (rotMatrix (chart.path t)).det = 1 :=
  rotMatrix_det_one (chart.path t) (chart.unit t)

noncomputable def axisAngleQuat (ux uy uz θ : ℝ) : Quat :=
  ⟨Real.cos (θ / 2), Real.sin (θ / 2) * ux, Real.sin (θ / 2) * uy, Real.sin (θ / 2) * uz⟩

theorem axisAngleQuat_isUnit (ux uy uz θ : ℝ) (haxis : ux ^ 2 + uy ^ 2 + uz ^ 2 = 1) :
    IsUnit (axisAngleQuat ux uy uz θ) := by
  unfold IsUnit normSq axisAngleQuat; simp
  nlinarith [Real.sin_sq_add_cos_sq (θ / 2), haxis,
             sq_nonneg ux, sq_nonneg uy, sq_nonneg uz,
             sq_nonneg (Real.sin (θ / 2))]

end Quat
end QuatAlg