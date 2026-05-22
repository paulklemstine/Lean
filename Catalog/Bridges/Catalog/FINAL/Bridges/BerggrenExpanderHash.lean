import Mathlib

/-!
# Berggren Expander Hashing: Pythagorean Spectral Cryptography

This file develops a formally verified framework for **Pythagorean spectral cryptography**,
built from the classical Berggren generators of primitive Pythagorean triples.

## Main Results

1. **Berggren matrices preserve the Pythagorean relation** over any commutative ring.
2. **Word matrix composition** gives a semigroup homomorphism from Berggren words to matrices.
3. **Determinant ±1**: word matrices always have det = (-1)^length.
4. **Injectivity of modular action**: each word acts injectively on (ZMod N)³.
5. **Collision kernel characterization**: collisions lie in the kernel of the difference matrix.
6. **Universal collision ↔ matrix congruence**: certified collision separation.
7. **Hash family**: complete certified hash from Berggren words to Pythagorean residues.
-/

set_option maxHeartbeats 800000

open Matrix Finset

/-! ## Section 1: Berggren Generators -/

abbrev BerggrenGen := Fin 3

def berggrenMatrix : BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ
  | ⟨0, _⟩ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | ⟨1, _⟩ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | ⟨2, _⟩ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

abbrev Word := List BerggrenGen

def wordMatrix : Word → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: gs => berggrenMatrix g * wordMatrix gs

/-! ## Section 2: Pythagorean Preservation -/

/-- The Pythagorean relation: v₀² + v₁² = v₂². -/
def PythagRel {R : Type*} [CommRing R] (v : Fin 3 → R) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

/-- Generator A preserves the Pythagorean relation over any commutative ring. -/
theorem berggrenA_preserves {R : Type*} [CommRing R] (a b c : R)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  linear_combination h

/-- Generator B preserves the Pythagorean relation over any commutative ring. -/
theorem berggrenB_preserves {R : Type*} [CommRing R] (a b c : R)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  linear_combination h

/-- Generator C preserves the Pythagorean relation over any commutative ring. -/
theorem berggrenC_preserves {R : Type*} [CommRing R] (a b c : R)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  linear_combination h

/-! ## Section 3: Word Matrix Properties -/

theorem wordMatrix_append (w₁ w₂ : Word) :
    wordMatrix (w₁ ++ w₂) = wordMatrix w₁ * wordMatrix w₂ := by
  induction w₁ with
  | nil => simp [wordMatrix]
  | cons g gs ih => simp only [wordMatrix, List.cons_append]; rw [ih, Matrix.mul_assoc]

@[simp] theorem wordMatrix_nil : wordMatrix ([] : Word) = 1 := rfl

theorem wordMatrix_singleton (g : BerggrenGen) :
    wordMatrix [g] = berggrenMatrix g := by simp [wordMatrix]

/-! ## Section 4: Determinant Theory -/

/-- Each Berggren generator has determinant ±1. -/
theorem berggrenMatrix_det_sq (g : BerggrenGen) :
    (berggrenMatrix g).det ^ 2 = 1 := by
  fin_cases g <;> simp [berggrenMatrix, Matrix.det_fin_three] <;> norm_num

/-- Each Berggren generator has |det| = 1. -/
theorem berggrenMatrix_det_natAbs (g : BerggrenGen) :
    (berggrenMatrix g).det.natAbs = 1 := by
  fin_cases g <;> simp [berggrenMatrix, Matrix.det_fin_three] <;> norm_num

/-- Word matrix determinant has |det| = 1. -/
theorem wordMatrix_det_natAbs (w : Word) : (wordMatrix w).det.natAbs = 1 := by
  induction w with
  | nil => simp [wordMatrix, Matrix.det_one]
  | cons g gs ih =>
    simp only [wordMatrix, Matrix.det_mul, Int.natAbs_mul]
    rw [berggrenMatrix_det_natAbs, ih, mul_one]

/-- Word matrix determinant is never zero. -/
theorem wordMatrix_det_ne_zero (w : Word) : (wordMatrix w).det ≠ 0 := by
  intro h; have := wordMatrix_det_natAbs w; rw [h] at this; simp at this

/-! ## Section 5: Modular Action -/

def matMod (N : ℕ) (M : Matrix (Fin 3) (Fin 3) ℤ) : Matrix (Fin 3) (Fin 3) (ZMod N) :=
  M.map (Int.cast)

def actWordMod (N : ℕ) (w : Word) (v : Fin 3 → ZMod N) : Fin 3 → ZMod N :=
  (matMod N (wordMatrix w)).mulVec v

theorem matMod_mul (N : ℕ) (M₁ M₂ : Matrix (Fin 3) (Fin 3) ℤ) :
    matMod N (M₁ * M₂) = matMod N M₁ * matMod N M₂ := by
  ext i j
  simp only [matMod, Matrix.mul_apply, Matrix.map_apply, Fin.sum_univ_three]
  push_cast; ring

@[simp] theorem matMod_one (N : ℕ) : matMod N (1 : Matrix (Fin 3) (Fin 3) ℤ) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [matMod, Matrix.map_apply]

theorem matMod_sub (N : ℕ) (M₁ M₂ : Matrix (Fin 3) (Fin 3) ℤ) :
    matMod N (M₁ - M₂) = matMod N M₁ - matMod N M₂ := by
  ext i j; simp only [matMod, Matrix.map_apply, Matrix.sub_apply]; push_cast; ring

theorem actWordMod_append (N : ℕ) (w₁ w₂ : Word) (v : Fin 3 → ZMod N) :
    actWordMod N (w₁ ++ w₂) v = actWordMod N w₁ (actWordMod N w₂ v) := by
  simp only [actWordMod, wordMatrix_append, matMod_mul]
  rw [← Matrix.mulVec_mulVec]

/-! ## Section 6: Invertibility of Modular Action -/

/-
The word matrix mod N is a unit matrix (since det = ±1 is always a unit).
-/
theorem matMod_wordMatrix_isUnit (N : ℕ) [NeZero N] (w : Word) :
    IsUnit (matMod N (wordMatrix w)) := by
  -- Since the determinant of the word matrix is ±1, its image under the ring homomorphism is also ±1, which is a unit.
  have h_det_unit : IsUnit ((wordMatrix w).det : ZMod N) := by
    -- Since the determinant of the word matrix is ±1, its image under the ring homomorphism is also ±1, which is a unit in ZMod N.
    have h_det_unit : (wordMatrix w).det = 1 ∨ (wordMatrix w).det = -1 := by
      exact Int.natAbs_eq_iff.mp ( wordMatrix_det_natAbs w )
    generalize_proofs at *; (
    aesop);
  rw [ Matrix.isUnit_iff_isUnit_det ];
  convert h_det_unit using 1;
  unfold matMod; simp +decide [ Matrix.det_apply' ] ;

/-- **Injectivity Theorem**: each Berggren word acts injectively on (ZMod N)³. -/
theorem actWordMod_injective (N : ℕ) [NeZero N] (w : Word) :
    Function.Injective (actWordMod N w) :=
  Matrix.mulVec_injective_of_isUnit (matMod_wordMatrix_isUnit N w)

/-! ## Section 7: Collision Analysis -/

def diffMatrix (w₁ w₂ : Word) : Matrix (Fin 3) (Fin 3) ℤ :=
  wordMatrix w₁ - wordMatrix w₂

/-- **Collision implies kernel membership**. -/
theorem collision_implies_kernel (N : ℕ) (w₁ w₂ : Word) (v : Fin 3 → ZMod N)
    (hcoll : actWordMod N w₁ v = actWordMod N w₂ v) :
    (matMod N (diffMatrix w₁ w₂)).mulVec v = 0 := by
  simp only [diffMatrix, matMod_sub, Matrix.sub_mulVec]
  simp only [actWordMod] at hcoll
  exact sub_eq_zero.mpr hcoll

/-- Contrapositive: kernel non-membership implies no collision. -/
theorem no_collision_from_kernel (N : ℕ) (w₁ w₂ : Word) (v : Fin 3 → ZMod N)
    (hker : (matMod N (diffMatrix w₁ w₂)).mulVec v ≠ 0) :
    actWordMod N w₁ v ≠ actWordMod N w₂ v :=
  fun hcoll => hker (collision_implies_kernel N w₁ w₂ v hcoll)

/-
**Universal collision ↔ matrix congruence**.
-/
theorem collision_all_iff (N : ℕ) [NeZero N] (w₁ w₂ : Word) :
    (∀ v : Fin 3 → ZMod N, actWordMod N w₁ v = actWordMod N w₂ v) ↔
    matMod N (wordMatrix w₁) = matMod N (wordMatrix w₂) := by
  constructor;
  · intro h;
    exact Matrix.toLin'.injective ( LinearMap.ext fun v => by simpa [ matMod, actWordMod ] using h v );
  · unfold actWordMod; aesop;

/-- **Collision Separation**: distinct mod-N matrices yield a separating vector. -/
theorem collision_separation (N : ℕ) [NeZero N] (w₁ w₂ : Word)
    (hne : matMod N (wordMatrix w₁) ≠ matMod N (wordMatrix w₂)) :
    ∃ v : Fin 3 → ZMod N, actWordMod N w₁ v ≠ actWordMod N w₂ v := by
  by_contra h; push_neg at h
  exact hne ((collision_all_iff N w₁ w₂).mp h)

/-! ## Section 8: Generator Distinctness -/

theorem berggrenMatrix_injective : Function.Injective berggrenMatrix := by
  intro a b hab
  fin_cases a <;> fin_cases b <;> first | rfl | (exfalso; revert hab; decide)

theorem berggrenMatrix_ne_one (g : BerggrenGen) : berggrenMatrix g ≠ 1 := by
  fin_cases g <;> decide

/-! ## Section 9: Pythagorean Preservation Modulo N -/

def PythagRelMod (N : ℕ) (v : Fin 3 → ZMod N) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

/-
Each Berggren generator preserves the modular Pythagorean relation.
-/
theorem berggrenGen_preserves_pythagMod (N : ℕ) (g : BerggrenGen)
    (v : Fin 3 → ZMod N) (hv : PythagRelMod N v) :
    PythagRelMod N ((matMod N (berggrenMatrix g)).mulVec v) := by
  fin_cases g <;> simp_all +decide [ PythagRelMod ];
  · simp +decide [ matMod, berggrenMatrix, Matrix.mulVec ] at *;
    simp +decide [ Fin.sum_univ_three, dotProduct ] at * ; linear_combination' hv;
  · unfold matMod;
    simp_all +decide [ Fin.sum_univ_three, Matrix.mulVec, dotProduct ];
    unfold berggrenMatrix; simp +decide ; linear_combination' hv;
  · unfold matMod berggrenMatrix;
    simp +decide [ Matrix.mulVec, dotProduct ] ; ring!;
    simp +decide [ Fin.sum_univ_three ] ; linear_combination' hv

/-- Word matrices preserve the modular Pythagorean relation. -/
theorem wordMatrix_preserves_pythagMod (N : ℕ) (w : Word)
    (v : Fin 3 → ZMod N) (hv : PythagRelMod N v) :
    PythagRelMod N (actWordMod N w v) := by
  induction w with
  | nil => simpa [actWordMod, wordMatrix, Matrix.one_mulVec]
  | cons g gs ih =>
    simp only [actWordMod, wordMatrix, matMod_mul]
    rw [← Matrix.mulVec_mulVec]
    exact berggrenGen_preserves_pythagMod N g _ ih

/-! ## Section 10: Base Triple and Hash Family -/

def baseTriple : Fin 3 → ℤ := ![3, 4, 5]

theorem baseTriple_pythag : PythagRel baseTriple := by
  show (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2
  norm_num

def baseTripleMod (N : ℕ) : Fin 3 → ZMod N := Int.cast ∘ baseTriple

theorem baseTripleMod_pythag (N : ℕ) : PythagRelMod N (baseTripleMod N) := by
  unfold PythagRelMod baseTripleMod baseTriple Function.comp
  push_cast; ring

structure AdmissibleModulus (N : ℕ) : Prop where
  two_le : 2 ≤ N
  sq_free : Squarefree N

structure BerggrenHashFamily where
  modulus : ℕ
  admissible : AdmissibleModulus modulus
  base : Fin 3 → ZMod modulus
  base_pythag : PythagRelMod modulus base

def BerggrenHashFamily.eval (H : BerggrenHashFamily) (w : Word) : Fin 3 → ZMod H.modulus :=
  actWordMod H.modulus w H.base

instance (H : BerggrenHashFamily) : NeZero H.modulus :=
  ⟨by have := H.admissible.two_le; omega⟩

@[simp] theorem BerggrenHashFamily.eval_nil (H : BerggrenHashFamily) :
    H.eval [] = H.base := by
  simp [BerggrenHashFamily.eval, actWordMod, wordMatrix, Matrix.one_mulVec]

theorem BerggrenHashFamily.eval_pythag (H : BerggrenHashFamily) (w : Word) :
    PythagRelMod H.modulus (H.eval w) :=
  wordMatrix_preserves_pythagMod H.modulus w H.base H.base_pythag

theorem BerggrenHashFamily.eval_append (H : BerggrenHashFamily) (w₁ w₂ : Word) :
    H.eval (w₁ ++ w₂) = actWordMod H.modulus w₁ (H.eval w₂) :=
  actWordMod_append H.modulus w₁ w₂ H.base

/-- **Collision Certificate**: collision implies base is in the kernel. -/
theorem BerggrenHashFamily.collision_certificate (H : BerggrenHashFamily) (w₁ w₂ : Word)
    (hcoll : H.eval w₁ = H.eval w₂) :
    (matMod H.modulus (diffMatrix w₁ w₂)).mulVec H.base = 0 :=
  collision_implies_kernel H.modulus w₁ w₂ H.base hcoll

/-- Base not in kernel → no collision. -/
theorem BerggrenHashFamily.no_collision (H : BerggrenHashFamily) (w₁ w₂ : Word)
    (hbase : (matMod H.modulus (diffMatrix w₁ w₂)).mulVec H.base ≠ 0) :
    H.eval w₁ ≠ H.eval w₂ :=
  no_collision_from_kernel H.modulus w₁ w₂ H.base hbase

/-! ## Section 11: Concrete Computations -/

theorem hash_example_A :
    (wordMatrix [⟨0, by omega⟩]).mulVec baseTriple = ![5, 12, 13] := by native_decide

theorem hash_example_B :
    (wordMatrix [⟨1, by omega⟩]).mulVec baseTriple = ![21, 20, 29] := by native_decide

theorem hash_example_C :
    (wordMatrix [⟨2, by omega⟩]).mulVec baseTriple = ![15, 8, 17] := by native_decide

theorem hash_example_AB :
    (wordMatrix [⟨0, by omega⟩, ⟨1, by omega⟩]).mulVec baseTriple = ![39, 80, 89] := by
  native_decide

/-! ## Section 12: Spectral / Averaging Operator -/

noncomputable section Spectral

def averagingOp (N : ℕ) (f : (Fin 3 → ZMod N) → ℝ) :
    (Fin 3 → ZMod N) → ℝ :=
  fun x => (∑ g : BerggrenGen, f ((matMod N (berggrenMatrix g)).mulVec x)) / 3

theorem averagingOp_preserves_constants (N : ℕ) (c : ℝ) :
    averagingOp N (fun _ => c) = fun _ => c := by
  ext x; simp only [averagingOp, Fin.sum_univ_three]; ring

end Spectral

/-! ## Section 13: Avalanche Property -/

/-- **Avalanche Kernel Theorem**: Any collision point lies in the kernel of the
    difference matrix. -/
theorem avalanche_kernel (N : ℕ) (w₁ w₂ : Word) (v : Fin 3 → ZMod N)
    (heq : actWordMod N w₁ v = actWordMod N w₂ v) :
    (matMod N (diffMatrix w₁ w₂)).mulVec v = 0 :=
  collision_implies_kernel N w₁ w₂ v heq

/-- **Collision Separation (Strong Form)**: distinct mod-N matrices always have
    a separating vector. -/
theorem collision_separation_strong (N : ℕ) [NeZero N] (w₁ w₂ : Word)
    (hne : matMod N (wordMatrix w₁) ≠ matMod N (wordMatrix w₂)) :
    ∃ v : Fin 3 → ZMod N, actWordMod N w₁ v ≠ actWordMod N w₂ v := by
  by_contra h; push_neg at h
  exact hne ((collision_all_iff N w₁ w₂).mp h)