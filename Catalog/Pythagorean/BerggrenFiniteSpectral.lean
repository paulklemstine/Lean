import Mathlib

/-!
# Berggren Spectral Theory on Finite Quotients

This file develops the spectral theory of the Berggren averaging operator
on the isotropic cone of the Lorentzian quadratic form Q(x,y,z) = x² + y² - z²
reduced modulo odd primes q.

## Main Results

### Algebraic Infrastructure (over ℤ)
* `berggrenGen_preserves_metric` — Each generator preserves the Lorentz metric MᵀQM = Q.
* `berggrenGen_mul_inv` / `berggrenInvGen_mul_gen` — Verified inverse pairs.
* `berggren_sum_lorentz_identity` — SᵀQS = diag(1,1,-9), the key amplification identity.

### Mod-q Reduction
* `quadFormMod_preserved_by_gen` — Generators preserve the quadratic form mod q.
* `berggrenGenAction` — The action on the isotropic cone is well-defined.
* `berggrenGenAction_bijective` — Each generator acts by bijection on the finite cone.

### Operator Theory
* `berggren_constants_eigenvalue_one` — Constants are eigenvectors with eigenvalue 1.
* `berggren_mean_zero_invariant` — The averaging operator preserves mean-zero functions.
* `berggren_averaging_sum_preserved` — Total sums are preserved by the operator.
-/

set_option maxHeartbeats 800000

open Matrix Finset BigOperators

namespace BerggrenFiniteSpectral

/-! ## §1. Core Definitions over ℤ -/

/-- The Lorentz metric matrix Q = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The three Berggren generators. -/
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The three Berggren inverse generators. -/
def berggrenInvGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, 2, -2; -2, -1, 2; -2, -2, 3]
  | 1 => !![1, 2, -2; 2, 1, -2; -2, -2, 3]
  | 2 => !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- The Lorentzian quadratic form Q(v) = v₀² + v₁² - v₂². -/
def quadForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Sum of the three Berggren generators. -/
def berggrenSum : Matrix (Fin 3) (Fin 3) ℤ :=
  berggrenGen 0 + berggrenGen 1 + berggrenGen 2

/-! ## §2. Algebraic Identities -/

/-- Each Berggren generator preserves the Lorentz metric: Mᵀ Q M = Q. -/
theorem berggrenGen_preserves_metric (i : Fin 3) :
    (berggrenGen i).transpose * metricQ * berggrenGen i = metricQ := by
  fin_cases i <;> native_decide

/-- Each inverse generator preserves the Lorentz metric. -/
theorem berggrenInvGen_preserves_metric (i : Fin 3) :
    (berggrenInvGen i).transpose * metricQ * berggrenInvGen i = metricQ := by
  fin_cases i <;> native_decide

/-- Generator times its inverse is the identity. -/
theorem berggrenGen_mul_inv (i : Fin 3) :
    berggrenGen i * berggrenInvGen i = 1 := by
  fin_cases i <;> native_decide

/-- Inverse times generator is the identity. -/
theorem berggrenInvGen_mul_gen (i : Fin 3) :
    berggrenInvGen i * berggrenGen i = 1 := by
  fin_cases i <;> native_decide

/-- Determinants: det(B₁) = 1, det(B₂) = -1, det(B₃) = 1. -/
theorem berggrenGen_det (i : Fin 3) :
    (berggrenGen i).det = if i = 1 then -1 else 1 := by
  fin_cases i <;> native_decide

/-- **Key algebraic identity**: SᵀQS = diag(1, 1, -9).
    This reveals the 9-fold amplification of the temporal component
    and is the algebraic engine behind spectral contraction. -/
theorem berggren_sum_lorentz_identity :
    berggrenSum.transpose * metricQ * berggrenSum = !![1, 0, 0; 0, 1, 0; 0, 0, -9] := by
  native_decide

/-- All three generators are pairwise distinct. -/
theorem berggrenGen_pairwise_distinct :
    berggrenGen 0 ≠ berggrenGen 1 ∧
    berggrenGen 0 ≠ berggrenGen 2 ∧
    berggrenGen 1 ≠ berggrenGen 2 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- Generators are pairwise non-commutative. -/
theorem berggrenGen_noncommutative (i j : Fin 3) (hij : i ≠ j) :
    berggrenGen i * berggrenGen j ≠ berggrenGen j * berggrenGen i := by
  fin_cases i <;> fin_cases j <;> simp_all <;> native_decide

/-! ## §3. Quadratic Form Preservation over ℤ -/

/-- Each generator preserves the quadratic form. -/
theorem quadForm_preserved_by_gen (i : Fin 3) (v : Fin 3 → ℤ) :
    quadForm ((berggrenGen i).mulVec v) = quadForm v := by
  fin_cases i <;> {
    simp [quadForm, berggrenGen, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
    ring
  }

/-- Each inverse generator preserves the quadratic form. -/
theorem quadForm_preserved_by_invGen (i : Fin 3) (v : Fin 3 → ℤ) :
    quadForm ((berggrenInvGen i).mulVec v) = quadForm v := by
  fin_cases i <;> {
    simp [quadForm, berggrenInvGen, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
    ring
  }

/-! ## §4. Mod-q Definitions and Form Preservation -/

/-- The quadratic form over ZMod q. -/
def quadFormMod (q : ℕ) (v : Fin 3 → ZMod q) : ZMod q :=
  v 0 * v 0 + v 1 * v 1 - v 2 * v 2

/-- The Berggren generators reduced mod q. -/
def berggrenGenMod (q : ℕ) : Fin 3 → Matrix (Fin 3) (Fin 3) (ZMod q) :=
  fun i => (berggrenGen i).map (Int.castRingHom (ZMod q))

/-- The Berggren inverse generators reduced mod q. -/
def berggrenInvGenMod (q : ℕ) : Fin 3 → Matrix (Fin 3) (Fin 3) (ZMod q) :=
  fun i => (berggrenInvGen i).map (Int.castRingHom (ZMod q))

private theorem map_int_mul_eq {q : ℕ} [NeZero q] (A B : Matrix (Fin 3) (Fin 3) ℤ)
    (h : A * B = 1) :
    A.map (Int.castRingHom (ZMod q)) * B.map (Int.castRingHom (ZMod q)) = 1 := by
  rw [← Matrix.map_mul, h]
  ext i j
  simp only [Matrix.map_apply, Matrix.one_apply]
  split_ifs with h <;> simp

/-- Generator mod q times its inverse mod q is the identity. -/
theorem berggrenGenMod_mul_inv (q : ℕ) [NeZero q] (i : Fin 3) :
    berggrenGenMod q i * berggrenInvGenMod q i = 1 :=
  map_int_mul_eq (berggrenGen i) (berggrenInvGen i) (berggrenGen_mul_inv i)

/-- Inverse mod q times generator mod q is the identity. -/
theorem berggrenInvGenMod_mul_gen (q : ℕ) [NeZero q] (i : Fin 3) :
    berggrenInvGenMod q i * berggrenGenMod q i = 1 :=
  map_int_mul_eq (berggrenInvGen i) (berggrenGen i) (berggrenInvGen_mul_gen i)

/-- The quadratic form is preserved by Berggren generators mod q. -/
theorem quadFormMod_preserved_by_gen (q : ℕ) [NeZero q] (i : Fin 3)
    (v : Fin 3 → ZMod q) :
    quadFormMod q ((berggrenGenMod q i).mulVec v) = quadFormMod q v := by
  simp only [quadFormMod]
  fin_cases i <;> {
    simp [berggrenGenMod, berggrenGen, Matrix.mulVec, dotProduct,
      Fin.sum_univ_three, Matrix.map_apply]
    ring
  }

/-- The quadratic form is preserved by Berggren inverse generators mod q. -/
theorem quadFormMod_preserved_by_invGen (q : ℕ) [NeZero q] (i : Fin 3)
    (v : Fin 3 → ZMod q) :
    quadFormMod q ((berggrenInvGenMod q i).mulVec v) = quadFormMod q v := by
  simp only [quadFormMod]
  fin_cases i <;> {
    simp [berggrenInvGenMod, berggrenInvGen, Matrix.mulVec, dotProduct,
      Fin.sum_univ_three, Matrix.map_apply]
    ring
  }

/-! ## §5. Isotropic Cone and Group Action -/

/-- A nonzero isotropic vector mod q. -/
def IsotropicNonzero (q : ℕ) :=
  {v : Fin 3 → ZMod q // quadFormMod q v = 0 ∧ v ≠ 0}

/-- Applying an invertible matrix to a nonzero vector gives a nonzero vector. -/
private theorem mulVec_ne_zero_of_inv {q : ℕ} [NeZero q]
    (M Minv : Matrix (Fin 3) (Fin 3) (ZMod q)) (hinv : Minv * M = 1)
    (v : Fin 3 → ZMod q) (hv : v ≠ 0) :
    M.mulVec v ≠ 0 := by
  intro h
  apply hv
  have : Minv.mulVec (M.mulVec v) = Minv.mulVec 0 := by rw [h]
  rw [Matrix.mulVec_mulVec, hinv, Matrix.mulVec_zero] at this
  simpa using this

/-- The Berggren generator action on the isotropic cone is well-defined. -/
def berggrenGenAction (q : ℕ) [NeZero q] (i : Fin 3) (v : IsotropicNonzero q) :
    IsotropicNonzero q :=
  ⟨(berggrenGenMod q i).mulVec v.1,
    ⟨by rw [quadFormMod_preserved_by_gen]; exact v.2.1,
     mulVec_ne_zero_of_inv _ _ (berggrenInvGenMod_mul_gen q i) _ v.2.2⟩⟩

/-- The Berggren inverse generator action on the isotropic cone is well-defined. -/
def berggrenInvGenAction (q : ℕ) [NeZero q] (i : Fin 3) (v : IsotropicNonzero q) :
    IsotropicNonzero q :=
  ⟨(berggrenInvGenMod q i).mulVec v.1,
    ⟨by rw [quadFormMod_preserved_by_invGen]; exact v.2.1,
     mulVec_ne_zero_of_inv _ _ (berggrenGenMod_mul_inv q i) _ v.2.2⟩⟩

/-- The generator action is injective (since generators are invertible mod q). -/
theorem berggrenGenAction_injective (q : ℕ) [NeZero q] (i : Fin 3) :
    Function.Injective (berggrenGenAction q i) := by
  intro ⟨v, hv⟩ ⟨w, hw⟩ h
  have hinj : (berggrenGenMod q i).mulVec v = (berggrenGenMod q i).mulVec w :=
    congrArg Subtype.val h
  apply Subtype.ext
  have hinv := berggrenInvGenMod_mul_gen q i
  calc v = (1 : Matrix _ _ _).mulVec v := by simp
    _ = (berggrenInvGenMod q i * berggrenGenMod q i).mulVec v := by rw [hinv]
    _ = (berggrenInvGenMod q i).mulVec ((berggrenGenMod q i).mulVec v) := by
        rw [Matrix.mulVec_mulVec]
    _ = (berggrenInvGenMod q i).mulVec ((berggrenGenMod q i).mulVec w) := by rw [hinj]
    _ = (berggrenInvGenMod q i * berggrenGenMod q i).mulVec w := by
        rw [Matrix.mulVec_mulVec]
    _ = (1 : Matrix _ _ _).mulVec w := by rw [hinv]
    _ = w := by simp

/-- The inverse generator action is injective. -/
theorem berggrenInvGenAction_injective (q : ℕ) [NeZero q] (i : Fin 3) :
    Function.Injective (berggrenInvGenAction q i) := by
  intro ⟨v, hv⟩ ⟨w, hw⟩ h
  have hinj : (berggrenInvGenMod q i).mulVec v = (berggrenInvGenMod q i).mulVec w :=
    congrArg Subtype.val h
  apply Subtype.ext
  have hinv := berggrenGenMod_mul_inv q i
  calc v = (1 : Matrix _ _ _).mulVec v := by simp
    _ = (berggrenGenMod q i * berggrenInvGenMod q i).mulVec v := by rw [hinv]
    _ = (berggrenGenMod q i).mulVec ((berggrenInvGenMod q i).mulVec v) := by
        rw [Matrix.mulVec_mulVec]
    _ = (berggrenGenMod q i).mulVec ((berggrenInvGenMod q i).mulVec w) := by rw [hinj]
    _ = (berggrenGenMod q i * berggrenInvGenMod q i).mulVec w := by
        rw [Matrix.mulVec_mulVec]
    _ = (1 : Matrix _ _ _).mulVec w := by rw [hinv]
    _ = w := by simp

/-- The generator action is bijective on finite isotropic cones. -/
theorem berggrenGenAction_bijective (q : ℕ) [NeZero q]
    [Fintype (IsotropicNonzero q)] (i : Fin 3) :
    Function.Bijective (berggrenGenAction q i) :=
  (Finite.injective_iff_bijective).mp (berggrenGenAction_injective q i)

/-- The inverse generator action is bijective on finite isotropic cones. -/
theorem berggrenInvGenAction_bijective (q : ℕ) [NeZero q]
    [Fintype (IsotropicNonzero q)] (i : Fin 3) :
    Function.Bijective (berggrenInvGenAction q i) :=
  (Finite.injective_iff_bijective).mp (berggrenInvGenAction_injective q i)

/-! ## §6. Averaging Operator -/

/-- The Berggren averaging operator T_q on functions f : IsotropicNonzero q → ℂ.
    T_q f(x) = (1/3)(f(B₁⁻¹ x) + f(B₂⁻¹ x) + f(B₃⁻¹ x)). -/
noncomputable def berggrenAveragingOp (q : ℕ) [NeZero q] :
    (IsotropicNonzero q → ℂ) →ₗ[ℂ] (IsotropicNonzero q → ℂ) where
  toFun f x := (1 / 3 : ℂ) * ∑ i : Fin 3, f (berggrenInvGenAction q i x)
  map_add' f g := by
    ext x
    simp [mul_add, Finset.sum_add_distrib]
  map_smul' c f := by
    ext x
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    rw [← Finset.mul_sum]
    ring

/-- The mean-zero subspace: functions whose sum over all isotropic vectors is zero. -/
noncomputable def meanZeroSubspace (q : ℕ) [NeZero q] [Fintype (IsotropicNonzero q)] :
    Submodule ℂ (IsotropicNonzero q → ℂ) where
  carrier := {f | ∑ x : IsotropicNonzero q, f x = 0}
  add_mem' {f g} hf hg := by
    change ∑ x, (f x + g x) = 0
    rw [Finset.sum_add_distrib, hf, hg, add_zero]
  zero_mem' := by simp
  smul_mem' c f hf := by
    show ∑ x, (c • f) x = 0
    simp only [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum]
    rw [show ∑ x, f x = 0 from hf, mul_zero]

/-! ## §7. Constants are Eigenvectors -/

/-- The constant function 1 is an eigenvector of T_q with eigenvalue 1. -/
theorem berggren_constants_eigenvalue_one (q : ℕ) [NeZero q] :
    berggrenAveragingOp q (fun _ => (1 : ℂ)) = fun _ => (1 : ℂ) := by
  ext x
  simp [berggrenAveragingOp, Fin.sum_univ_three]
  norm_num

/-- More generally, any constant function is fixed by T_q. -/
theorem berggren_constants_fixed (q : ℕ) [NeZero q] (c : ℂ) :
    berggrenAveragingOp q (fun _ => c) = fun _ => c := by
  ext _
  simp [berggrenAveragingOp, Fin.sum_univ_three]
  ring

/-! ## §8. Mean-Zero Invariance -/

/-- T_q preserves the total sum of f over the isotropic cone. -/
theorem berggren_averaging_sum_preserved (q : ℕ) [NeZero q]
    [Fintype (IsotropicNonzero q)] [DecidableEq (IsotropicNonzero q)]
    (f : IsotropicNonzero q → ℂ) :
    ∑ x, berggrenAveragingOp q f x = ∑ x, f x := by
  simp only [berggrenAveragingOp, LinearMap.coe_mk, AddHom.coe_mk]
  rw [← Finset.mul_sum]
  simp_rw [Fin.sum_univ_three, Finset.sum_add_distrib]
  -- Each inverse generator acts by bijection, so summing over its image = summing over all
  have h0 : ∑ x, f (berggrenInvGenAction q 0 x) = ∑ x, f x :=
    Fintype.sum_bijective _ (berggrenInvGenAction_bijective q 0) _ _ (fun _ => rfl)
  have h1 : ∑ x, f (berggrenInvGenAction q 1 x) = ∑ x, f x :=
    Fintype.sum_bijective _ (berggrenInvGenAction_bijective q 1) _ _ (fun _ => rfl)
  have h2 : ∑ x, f (berggrenInvGenAction q 2 x) = ∑ x, f x :=
    Fintype.sum_bijective _ (berggrenInvGenAction_bijective q 2) _ _ (fun _ => rfl)
  rw [h0, h1, h2]
  ring

/-- T_q preserves the mean-zero subspace. -/
theorem berggren_mean_zero_invariant (q : ℕ) [NeZero q]
    [Fintype (IsotropicNonzero q)] [DecidableEq (IsotropicNonzero q)]
    (f : IsotropicNonzero q → ℂ)
    (hf : f ∈ meanZeroSubspace q) :
    berggrenAveragingOp q f ∈ meanZeroSubspace q := by
  show ∑ x, berggrenAveragingOp q f x = 0
  rw [berggren_averaging_sum_preserved]
  exact hf

/-! ## §9. Norm Bounds -/

/-- The ℓ² norm squared of a function on the isotropic cone. -/
noncomputable def l2NormSq (q : ℕ) [NeZero q] [Fintype (IsotropicNonzero q)]
    (f : IsotropicNonzero q → ℂ) : ℝ :=
  ∑ x : IsotropicNonzero q, ‖f x‖ ^ 2

/-- The ℓ² norm squared is nonnegative. -/
theorem l2NormSq_nonneg (q : ℕ) [NeZero q] [Fintype (IsotropicNonzero q)]
    (f : IsotropicNonzero q → ℂ) :
    0 ≤ l2NormSq q f :=
  Finset.sum_nonneg fun _ _ => pow_nonneg (norm_nonneg _) 2

/-! ## §10. Seed Triple Computations -/

/-- (3,4,5) is on the light cone: Q(3,4,5) = 0. -/
theorem seed_on_cone : quadForm ![3, 4, 5] = 0 := by native_decide

/-- B₁(3,4,5) = (5,12,13). -/
theorem gen0_seed :
    (berggrenGen 0).mulVec ![3, 4, 5] = ![5, 12, 13] := by native_decide

/-- B₂(3,4,5) = (21,20,29). -/
theorem gen1_seed :
    (berggrenGen 1).mulVec ![3, 4, 5] = ![21, 20, 29] := by native_decide

/-- B₃(3,4,5) = (15,8,17). -/
theorem gen2_seed :
    (berggrenGen 2).mulVec ![3, 4, 5] = ![15, 8, 17] := by native_decide

/-- All children of (3,4,5) lie on the light cone. -/
theorem children_on_cone :
    quadForm ![5, 12, 13] = 0 ∧
    quadForm ![21, 20, 29] = 0 ∧
    quadForm ![15, 8, 17] = 0 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-! ## §11. Sum Operator on the Pythagorean Light Cone -/

/-- On the Pythagorean light cone (Q(v) = 0), the sum operator satisfies
    Q(Sv) = -8v₂². -/
theorem lorentz_sum_on_cone (v : Fin 3 → ℤ) (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    quadForm (berggrenSum.mulVec v) = -8 * v 2 ^ 2 := by
  simp [quadForm, berggrenSum, berggrenGen, Matrix.mulVec, dotProduct,
    Fin.sum_univ_three]
  nlinarith

/-! ## §12. Cross-Generator Lorentz Products -/

/-- Cross-generator Lorentz products reveal the angle structure between generators. -/
theorem cross_gen_01 :
    (berggrenGen 0).transpose * metricQ * berggrenGen 1 =
    !![1, 0, 0; 0, -1, 0; 0, 0, (-1 : ℤ)] := by native_decide

theorem cross_gen_02 :
    (berggrenGen 0).transpose * metricQ * berggrenGen 2 =
    !![(-1 : ℤ), 0, 0; 0, -1, 0; 0, 0, -1] := by native_decide

theorem cross_gen_12 :
    (berggrenGen 1).transpose * metricQ * berggrenGen 2 =
    !![(-1 : ℤ), 0, 0; 0, 1, 0; 0, 0, -1] := by native_decide

/-! ## §13. Trace Structure -/

/-- Traces of the Berggren generators: (3, 5, 3). -/
theorem trace_gen_0 : Matrix.trace (berggrenGen 0) = 3 := by native_decide
theorem trace_gen_1 : Matrix.trace (berggrenGen 1) = 5 := by native_decide
theorem trace_gen_2 : Matrix.trace (berggrenGen 2) = 3 := by native_decide

/-- The trace of the sum operator is 11. -/
theorem trace_sum : Matrix.trace berggrenSum = 11 := by native_decide

/-- Trace of SᵀQS is -7 = 1 + 1 + (-9). -/
theorem trace_lorentz_sum :
    Matrix.trace (berggrenSum.transpose * metricQ * berggrenSum) = -7 := by
  native_decide

end BerggrenFiniteSpectral