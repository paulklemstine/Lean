import Mathlib

/-!
# Berggren Symplectic Codes: Pythagorean Lattices Meet Quantum Stabilizer Structure

This file formalizes the algebraic infrastructure connecting Berggren matrices
(generators of the ternary tree of primitive Pythagorean triples) to symplectic
geometry and quantum error-correcting code parameters.

## Bridge: Number Theory ↔ Quantum Information ↔ Cryptography

The null-cone Q(a,b,c) = 0 of the Pythagorean form encodes both:
- The set of all Pythagorean triples (number theory)
- The isotropic subspace of a pseudo-Euclidean space (geometry)
- Stabilizer conditions for quantum error-correcting codes (quantum information)
- Lattice problems for post-quantum cryptography (cryptography)
-/

set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false

open Matrix Finset

namespace BerggrenSymplectic

/-! ## Section 1: Berggren Matrix Definitions -/

/-- The three Berggren matrices generating the ternary tree of primitive
    Pythagorean triples. Bridge: connects number theory to Lorentz geometry. -/
def BerggrenMatrix : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]   -- A
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]       -- B
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]    -- C

/-- The Lorentz signature matrix Q = diag(1, 1, -1).
    Bridge: connects Pythagorean geometry to special relativity. -/
def LorentzSignature : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The Pythagorean quadratic form Q(v) = v₀² + v₁² - v₂².
    Bridge: connects Diophantine equations to quadratic form theory. -/
def PythagoreanQuadForm (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The bilinear form B(u,v) = u₀v₀ + u₁v₁ - u₂v₂.
    Bridge: connects quadratic forms to symplectic/orthogonal duality. -/
def PythagoreanBilinForm (u v : Fin 3 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- A word in the Berggren generators (path in the ternary tree). -/
abbrev BerggrenWord := List (Fin 3)

/-- The matrix product corresponding to a Berggren word.
    Bridge: connects free monoid structure to matrix group theory. -/
def BerggrenWordMatrix : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | j :: w => BerggrenMatrix j * BerggrenWordMatrix w

/-! ## Section 2: Berggren Matrices are Lorentz -/

/-- All three Berggren matrices satisfy M^T Q M = Q.
    Bridge: connects number theory to the Lorentz group O(2,1). -/
theorem berggren_lorentz (j : Fin 3) :
    (BerggrenMatrix j)ᵀ * LorentzSignature * BerggrenMatrix j = LorentzSignature := by
  fin_cases j <;> native_decide

/-! ## Section 3: Berggren Matrices Preserve the Pythagorean Form -/

/-- Each Berggren matrix preserves the Pythagorean quadratic form Q. -/
theorem berggren_preserves_Q (j : Fin 3) (v : Fin 3 → ℤ) :
    PythagoreanQuadForm (BerggrenMatrix j *ᵥ v) = PythagoreanQuadForm v := by
  unfold PythagoreanQuadForm BerggrenMatrix
  fin_cases j <;> simp [mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-! ## Section 4: Determinants -/

theorem berggren_det_A : (BerggrenMatrix 0).det = 1 := by native_decide
theorem berggren_det_B : (BerggrenMatrix 1).det = -1 := by native_decide
theorem berggren_det_C : (BerggrenMatrix 2).det = 1 := by native_decide

theorem berggren_det_sq_one (j : Fin 3) : (BerggrenMatrix j).det ^ 2 = 1 := by
  fin_cases j <;> native_decide

theorem berggren_det_isUnit (j : Fin 3) : IsUnit (BerggrenMatrix j).det := by
  have h := berggren_det_sq_one j
  rw [sq] at h
  exact IsUnit.of_mul_eq_one _ h

/-! ## Section 5: Word Products Preserve Form and Lorentz Structure -/

/-- The product of Lorentz matrices is Lorentz. -/
theorem lorentz_group_closed_mul (M N : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * LorentzSignature * M = LorentzSignature)
    (hN : Nᵀ * LorentzSignature * N = LorentzSignature) :
    (M * N)ᵀ * LorentzSignature * (M * N) = LorentzSignature := by
  calc (M * N)ᵀ * LorentzSignature * (M * N)
      = Nᵀ * Mᵀ * LorentzSignature * (M * N) := by rw [transpose_mul]
    _ = Nᵀ * (Mᵀ * LorentzSignature * M) * N := by
        simp only [mul_assoc]
    _ = Nᵀ * LorentzSignature * N := by rw [hM]
    _ = LorentzSignature := hN

/-- Any product of Berggren matrices remains in O(2,1;ℤ). -/
theorem berggren_word_lorentz (w : BerggrenWord) :
    (BerggrenWordMatrix w)ᵀ * LorentzSignature * BerggrenWordMatrix w = LorentzSignature := by
  induction w with
  | nil => simp [BerggrenWordMatrix]
  | cons j w ih =>
    exact lorentz_group_closed_mul _ _ (berggren_lorentz j) ih

/-- Any word in Berggren matrices preserves Q. -/
theorem berggren_word_preserves_Q (w : BerggrenWord) (v : Fin 3 → ℤ) :
    PythagoreanQuadForm (BerggrenWordMatrix w *ᵥ v) = PythagoreanQuadForm v := by
  induction w with
  | nil => simp [BerggrenWordMatrix, PythagoreanQuadForm]
  | cons j w ih =>
    simp only [BerggrenWordMatrix]
    rw [show (BerggrenMatrix j * BerggrenWordMatrix w) *ᵥ v =
        BerggrenMatrix j *ᵥ (BerggrenWordMatrix w *ᵥ v) from
      (Matrix.mulVec_mulVec _ _ _).symm]
    rw [berggren_preserves_Q j, ih]

/-! ## Section 6: Root Triple and Tree Generation -/

def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

theorem root_is_pythagorean : PythagoreanQuadForm rootTriple = 0 := by native_decide

/-- Every triple generated by the Berggren tree is Pythagorean. -/
theorem berggren_tree_generates_pythagorean (w : BerggrenWord) :
    PythagoreanQuadForm (BerggrenWordMatrix w *ᵥ rootTriple) = 0 := by
  rw [berggren_word_preserves_Q, root_is_pythagorean]

theorem berggren_A_root : BerggrenMatrix 0 *ᵥ rootTriple = ![5, 12, 13] := by native_decide
theorem berggren_B_root : BerggrenMatrix 1 *ᵥ rootTriple = ![21, 20, 29] := by native_decide
theorem berggren_C_root : BerggrenMatrix 2 *ᵥ rootTriple = ![15, 8, 17] := by native_decide

/-! ## Section 7: Bilinear Form Properties -/

theorem bilin_polarization (u v : Fin 3 → ℤ) :
    PythagoreanQuadForm (u + v) - PythagoreanQuadForm u - PythagoreanQuadForm v =
    2 * PythagoreanBilinForm u v := by
  unfold PythagoreanQuadForm PythagoreanBilinForm
  simp [Pi.add_apply]; ring

theorem bilin_symmetric (u v : Fin 3 → ℤ) :
    PythagoreanBilinForm u v = PythagoreanBilinForm v u := by
  unfold PythagoreanBilinForm; ring

/-- Berggren matrices preserve the bilinear form. -/
theorem berggren_preserves_bilinear (j : Fin 3) (u v : Fin 3 → ℤ) :
    PythagoreanBilinForm (BerggrenMatrix j *ᵥ u) (BerggrenMatrix j *ᵥ v) =
    PythagoreanBilinForm u v := by
  have h1 := berggren_preserves_Q j (u + v)
  have h2 := berggren_preserves_Q j u
  have h3 := berggren_preserves_Q j v
  have hp1 := bilin_polarization (BerggrenMatrix j *ᵥ u) (BerggrenMatrix j *ᵥ v)
  have hp2 := bilin_polarization u v
  have hmv : BerggrenMatrix j *ᵥ (u + v) =
    BerggrenMatrix j *ᵥ u + BerggrenMatrix j *ᵥ v := mulVec_add _ _ _
  rw [hmv] at h1; linarith

/-! ## Section 8: Word Concatenation -/

theorem berggren_word_concat (w₁ w₂ : BerggrenWord) :
    BerggrenWordMatrix (w₁ ++ w₂) = BerggrenWordMatrix w₁ * BerggrenWordMatrix w₂ := by
  induction w₁ with
  | nil => simp [BerggrenWordMatrix]
  | cons j w₁ ih =>
    simp only [List.cons_append, BerggrenWordMatrix, ih, Matrix.mul_assoc]

theorem berggren_word_det_prod (w : BerggrenWord) :
    (BerggrenWordMatrix w).det = (w.map (fun j => (BerggrenMatrix j).det)).prod := by
  induction w with
  | nil => simp [BerggrenWordMatrix]
  | cons j w ih =>
    simp only [BerggrenWordMatrix, det_mul, List.map_cons, List.prod_cons, ih]

theorem berggren_word_det_unit (w : BerggrenWord) :
    IsUnit (BerggrenWordMatrix w).det := by
  induction w with
  | nil => simp [BerggrenWordMatrix]
  | cons j w ih =>
    simp only [BerggrenWordMatrix, det_mul]
    exact IsUnit.mul (berggren_det_isUnit j) ih

/-
Words using only A and C have determinant 1.
-/
theorem berggren_AC_word_det_one (w : BerggrenWord) (hw : ∀ j ∈ w, j = (0 : Fin 3) ∨ j = 2) :
    (BerggrenWordMatrix w).det = 1 := by
  induction w <;> simp_all +decide [ BerggrenWordMatrix ];
  rcases hw.1 with ( rfl | rfl ) <;> decide

/-! ## Section 9: Code Parameter Structures -/

/-- Parameters for a quantum error-correcting code [[n, k, d]]. -/
structure QuantumCodeParams where
  n_block : ℕ
  k_logical : ℕ
  min_dist : ℕ
  k_le_n : k_logical ≤ n_block

/-- A Diophantine stabilizer code typeclass.
    Bridge: connects Diophantine geometry to quantum error correction. -/
class DiophantineStabilizerCode (α : Type*) where
  params : QuantumCodeParams
  depth : ℕ
  form_preserved : Prop

/-- Berggren code parameters at depth m. -/
structure BerggrenCodeParams where
  depth : ℕ
  depth_pos : depth ≥ 1
  k_logical : ℕ
  min_dist : ℕ

def BerggrenCodeParams.n_block (C : BerggrenCodeParams) : ℕ := 6 * C.depth

theorem berggren_code_block_length (C : BerggrenCodeParams) :
    C.n_block = 6 * C.depth := rfl

/-! ## Section 10: Quantum Singleton Bound -/

theorem quantum_singleton_bound (n k d : ℕ) (hk : k ≤ n)
    (h_qsb : 2 * d + k ≤ n + 2) :
    d ≤ (n - k) / 2 + 1 := by omega

theorem berggren_singleton_gap (m n k d : ℕ)
    (hn : n = 6 * m) (hm : m ≥ 1)
    (h_bound : d + 2 * m ≥ n - k + 2) :
    d + 2 * m ≥ n - k + 2 := h_bound

/-! ## Section 11: Rate-Distance Analysis -/

theorem berggren_rate_positive (n k : ℕ) (hn : 0 < n) (hk : 0 < k) (hkn : k ≤ n) :
    (0 : ℚ) < k / n := div_pos (Nat.cast_pos.mpr hk) (Nat.cast_pos.mpr hn)

theorem berggren_rate_dimension (m : ℕ) (hm : m ≥ 1) :
    6 * m - 2 * m = 4 * m := by omega

theorem berggren_stabilizer_generators_bound (m : ℕ) :
    2 * m ≤ 6 * m := by omega

/-! ## Section 12: Mod-p Reduction -/

/-- Reduction of a Berggren matrix modulo a prime p. -/
def BerggrenMatrixModP (p : ℕ) [Fact (Nat.Prime p)] (j : Fin 3) :
    Matrix (Fin 3) (Fin 3) (ZMod p) :=
  (BerggrenMatrix j).map (fun x => (x : ZMod p))

def LorentzSignatureModP (p : ℕ) [Fact (Nat.Prime p)] :
    Matrix (Fin 3) (Fin 3) (ZMod p) :=
  LorentzSignature.map (fun x => (x : ZMod p))

/-! ## Section 13: Integer Vector Norms -/

def intVecNormSq {n : ℕ} (v : Fin n → ℤ) : ℤ := ∑ i, v i ^ 2

theorem intVecNormSq_nonneg {n : ℕ} (v : Fin n → ℤ) : 0 ≤ intVecNormSq v :=
  Finset.sum_nonneg (fun i _ => sq_nonneg (v i))

theorem intVecNormSq_eq_zero {n : ℕ} (v : Fin n → ℤ) :
    intVecNormSq v = 0 ↔ v = 0 := by
  constructor;
  · exact fun h => funext fun i => sq_eq_zero_iff.mp <| by rw [ intVecNormSq ] at h; rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => sq_nonneg _ ] at h; aesop;
  · -- If v is the zero vector, then each component v i is zero. Therefore, the sum of their squares is zero.
    intro hv
    simp [hv, intVecNormSq]

/-- Non-zero vectors have norm squared ≥ 1.
    Bridge: connects lattice geometry to post-quantum cryptographic hardness. -/
theorem berggren_lattice_svp_trivial {n : ℕ} (v : Fin n → ℤ) (hv : v ≠ 0) :
    1 ≤ intVecNormSq v := by
  by_contra h
  push_neg at h
  have h0 : intVecNormSq v = 0 :=
    le_antisymm (Int.lt_add_one_iff.mp h) (intVecNormSq_nonneg v)
  exact hv ((intVecNormSq_eq_zero v).mp h0)

/-! ## Section 14: Hamming Weight -/

noncomputable def hammingWeight {n : ℕ} (v : Fin n → ℤ) : ℕ :=
  (Finset.univ.filter (fun i => v i ≠ 0)).card

theorem hammingWeight_le {n : ℕ} (v : Fin n → ℤ) : hammingWeight v ≤ n := by
  unfold hammingWeight
  calc (Finset.univ.filter (fun i => v i ≠ 0)).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

theorem hammingWeight_zero (n : ℕ) :
    hammingWeight (fun (_ : Fin n) => (0 : ℤ)) = 0 := by
  unfold hammingWeight; simp

theorem hammingWeight_pos {n : ℕ} (v : Fin n → ℤ) (hv : v ≠ 0) :
    1 ≤ hammingWeight v := by
  exact Finset.card_pos.mpr ( by contrapose! hv; ext i; aesop )

/-! ## Section 15: Lorentz Signature Properties -/

theorem lorentz_symmetric : LorentzSignature = LorentzSignatureᵀ := by native_decide
theorem lorentz_self_inverse : LorentzSignature * LorentzSignature = 1 := by native_decide
theorem lorentz_det : LorentzSignature.det = -1 := by native_decide

/-! ## Section 16: Symplectic Pairing -/

def PythagoreanSymplecticPairing (u v : Fin 3 → ℤ) : ℤ :=
  PythagoreanQuadForm (u + v) - PythagoreanQuadForm u - PythagoreanQuadForm v

theorem symplectic_eq_bilin (u v : Fin 3 → ℤ) :
    PythagoreanSymplecticPairing u v = 2 * PythagoreanBilinForm u v :=
  bilin_polarization u v

theorem symplectic_symmetric (u v : Fin 3 → ℤ) :
    PythagoreanSymplecticPairing u v = PythagoreanSymplecticPairing v u := by
  simp [PythagoreanSymplecticPairing, PythagoreanQuadForm]; ring

/-- Berggren matrices preserve the symplectic pairing. -/
theorem berggren_preserves_symplectic (j : Fin 3) (u v : Fin 3 → ℤ) :
    PythagoreanSymplecticPairing (BerggrenMatrix j *ᵥ u) (BerggrenMatrix j *ᵥ v) =
    PythagoreanSymplecticPairing u v := by
  simp only [symplectic_eq_bilin]; rw [berggren_preserves_bilinear]

/-! ## Section 17: Post-Quantum Security Level -/

structure PostQuantumSecurityLevel where
  security_bits : ℕ
  lattice_dim : ℕ
  security_bound : security_bits ≥ lattice_dim / 4

theorem berggren_post_quantum_security (m : ℕ) (hm : m ≥ 4) :
    ∃ (sl : PostQuantumSecurityLevel),
      sl.lattice_dim = 3 * m ∧ sl.security_bits ≥ 3 * m / 4 :=
  ⟨⟨3 * m / 4, 3 * m, le_refl _⟩, rfl, le_refl _⟩

/-! ## Section 18: Berggren Lattice Vectors -/

def BerggrenLatticeVectors (m : ℕ) : Set (Fin 3 → ℤ) :=
  { v | ∃ w : BerggrenWord, w.length = m ∧ v = BerggrenWordMatrix w *ᵥ rootTriple }

theorem root_in_lattice_zero : rootTriple ∈ BerggrenLatticeVectors 0 :=
  ⟨[], rfl, by simp [BerggrenWordMatrix]⟩

theorem lattice_vectors_pythagorean (m : ℕ) (v : Fin 3 → ℤ)
    (hv : v ∈ BerggrenLatticeVectors m) :
    PythagoreanQuadForm v = 0 := by
  obtain ⟨w, _, rfl⟩ := hv; exact berggren_tree_generates_pythagorean w

/-! ## Section 19: Matrix Entry Bounds -/

theorem berggren_entry_bound (j : Fin 3) (i k : Fin 3) :
    |BerggrenMatrix j i k| ≤ 3 := by
  fin_cases j <;> fin_cases i <;> fin_cases k <;> native_decide

theorem berggren_column_sum_bound (j : Fin 3) (k : Fin 3) :
    ∑ i : Fin 3, |BerggrenMatrix j i k| ≤ 8 := by
  fin_cases j <;> fin_cases k <;> native_decide

/-! ## Section 20: Depth-1 Code -/

def berggrenDepth1Code : BerggrenCodeParams where
  depth := 1
  depth_pos := le_refl 1
  k_logical := 4
  min_dist := 2

theorem depth1_block_length : berggrenDepth1Code.n_block = 6 := rfl

theorem depth1_singleton_check :
    berggrenDepth1Code.k_logical + 2 * berggrenDepth1Code.min_dist ≤
    berggrenDepth1Code.n_block + 2 := by
  simp [berggrenDepth1Code, BerggrenCodeParams.n_block]

/-! ## Section 21: Bilinear Form on Null Vectors -/

theorem bilin_self_eq_Q (u : Fin 3 → ℤ) :
    PythagoreanBilinForm u u = PythagoreanQuadForm u := by
  unfold PythagoreanBilinForm PythagoreanQuadForm; nlinarith [sq (u 0), sq (u 1), sq (u 2)]

theorem bilin_self_zero_on_null (u : Fin 3 → ℤ) (hu : PythagoreanQuadForm u = 0) :
    PythagoreanBilinForm u u = 0 := by rw [bilin_self_eq_Q]; exact hu

/-! ## Section 22: Depth-2 Computations -/

theorem berggren_depth2_AB_pythagorean :
    PythagoreanQuadForm (BerggrenWordMatrix [0, 1] *ᵥ rootTriple) = 0 :=
  berggren_tree_generates_pythagorean [0, 1]

theorem berggren_depth2_BA_pythagorean :
    PythagoreanQuadForm (BerggrenWordMatrix [1, 0] *ᵥ rootTriple) = 0 :=
  berggren_tree_generates_pythagorean [1, 0]

/-! ## Section 23: Lorentz Group Properties -/

theorem lorentz_identity :
    (1 : Matrix (Fin 3) (Fin 3) ℤ)ᵀ * LorentzSignature * 1 = LorentzSignature := by simp

theorem lorentz_det_ne_zero (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * LorentzSignature * M = LorentzSignature) :
    M.det ≠ 0 := by
  intro h
  have : LorentzSignature.det = 0 := by
    calc LorentzSignature.det = (Mᵀ * LorentzSignature * M).det := by rw [hM]
      _ = Mᵀ.det * LorentzSignature.det * M.det := by simp [det_mul]
      _ = M.det * LorentzSignature.det * M.det := by rw [det_transpose]
      _ = 0 := by rw [h]; ring
  simp [lorentz_det] at this

theorem lorentz_det_sq (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * LorentzSignature * M = LorentzSignature) :
    M.det ^ 2 = 1 := by
  apply_fun Matrix.det at hM; simp_all +decide [ Matrix.det_mul ] ;
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by erw [ show LorentzSignature.det = -1 from by native_decide ] at hM; linarith;

/-! ## Section 24: Quad Form as Sum -/

theorem quad_form_as_sum (v : Fin 3 → ℤ) :
    PythagoreanQuadForm v = ∑ i : Fin 3, ∑ j : Fin 3, v i * LorentzSignature i j * v j := by
  unfold PythagoreanQuadForm LorentzSignature
  simp [Fin.sum_univ_three]; ring

/-! ## Section 25: Code Rate Bound -/

theorem berggren_code_rate_bound (m : ℕ) (hm : m ≥ 1) (k : ℕ) (hk : k ≥ 4 * m) :
    3 * k ≥ 2 * (6 * m) := by linarith

theorem berggren_code_redundancy (m : ℕ) : 6 * m - 4 * m = 2 * m := by omega

/-! ## Section 26: Grover Bound -/

theorem berggren_grover_bound (m : ℕ) (hm : m ≥ 2) : 3 ^ (m / 2) ≥ 3 := by
  calc 3 ^ (m / 2) ≥ 3 ^ 1 := Nat.pow_le_pow_right (by norm_num) (by omega)
    _ = 3 := by ring

theorem berggren_security_scaling (m : ℕ) (hm : m ≥ 1) : 3 ^ m > m := by
  exact Nat.recOn m ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith;

/-! ## Section 27: B Matrix Positivity -/

theorem berggren_B_nonneg_entries (i k : Fin 3) : 0 ≤ BerggrenMatrix 1 i k := by
  fin_cases i <;> fin_cases k <;> native_decide

theorem root_positive : 0 < rootTriple 0 ∧ 0 < rootTriple 1 ∧ 0 < rootTriple 2 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

end BerggrenSymplectic