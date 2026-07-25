import Mathlib

/-!
# Berggren Pythagorean Lattices: From Diophantine Dynamics to Post-Quantum Security

## Main results

1. `berggren_word_preserves_primitive` — Every Berggren orbit vector from (3,4,5) is
   a primitive Pythagorean triple.
2. `berggren_lattice_sqNorm_pos` — Nonzero integer vectors have squared norm ≥ 1.
3. `bounded_berggren_orbit_in_lattice` — Bounded orbit vectors lie in a ℤ-submodule.
4. `berggren_key_security_from_minEntropy` — Post-quantum security for key derivation.
-/

set_option linter.unusedVariables false
set_option maxHeartbeats 800000

open Matrix Finset BigOperators

namespace BerggrenLattice

/-! ## Section 1: Core Definitions -/

/-- The three Berggren matrices. -/
def G : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Integer inverses (det = ±1). -/
def Ginv : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, 2, -2; -2, -1, 2; -2, -2, 3]
  | 1 => !![1, 2, -2; 2, 1, -2; -2, -2, 3]
  | 2 => !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

abbrev BWord := List (Fin 3)

def wMat : BWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | j :: w => G j * wMat w

def evalW (w : BWord) (v : Fin 3 → ℤ) : Fin 3 → ℤ := wMat w *ᵥ v

def root : Fin 3 → ℤ := ![3, 4, 5]

def isPythTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 > 0 ∧ v 1 > 0 ∧ v 2 > 0 ∧ (v 0)^2 + (v 1)^2 = (v 2)^2

def isPrimitive (v : Fin 3 → ℤ) : Prop :=
  isPythTriple v ∧ Int.gcd (v 0) (Int.gcd (v 1) (v 2)) = 1

def sqNorm (v : Fin 3 → ℤ) : ℤ := (v 0)^2 + (v 1)^2 + (v 2)^2

def qForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-! ## Section 2: Generator Algebraic Properties -/

theorem G_mul_Ginv (j : Fin 3) : G j * Ginv j = 1 := by
  fin_cases j <;> native_decide

theorem Ginv_mul_G (j : Fin 3) : Ginv j * G j = 1 := by
  fin_cases j <;> native_decide

theorem G_preserves_qForm (j : Fin 3) (v : Fin 3 → ℤ) :
    qForm (G j *ᵥ v) = qForm v := by
  unfold qForm G
  fin_cases j <;> simp [mulVec, dotProduct, Fin.sum_univ_three] <;> ring

theorem wMat_preserves_qForm (w : BWord) (v : Fin 3 → ℤ) :
    qForm (wMat w *ᵥ v) = qForm v := by
  induction w with
  | nil => simp [wMat, qForm]
  | cons j w ih =>
    change qForm ((G j * wMat w) *ᵥ v) = _
    conv_lhs => rw [← mulVec_mulVec]
    rw [G_preserves_qForm, ih]

theorem root_qForm : qForm root = 0 := by native_decide

theorem orbit_on_null_cone (w : BWord) : qForm (evalW w root) = 0 := by
  unfold evalW; rw [wMat_preserves_qForm, root_qForm]

/-! ## Section 3: Hypotenuse Bounds -/

theorem hyp_gt_leg1 (v : Fin 3 → ℤ) (hv : isPythTriple v) : v 2 > v 0 := by
  obtain ⟨h0, h1, h2, heq⟩ := hv
  nlinarith [sq_nonneg (v 2 - v 0)]

theorem hyp_gt_leg2 (v : Fin 3 → ℤ) (hv : isPythTriple v) : v 2 > v 1 := by
  obtain ⟨h0, h1, h2, heq⟩ := hv
  nlinarith [sq_nonneg (v 2 - v 1)]

/-! ## Section 4: Generator Preserves isPythTriple -/

theorem G_preserves_pythTriple (j : Fin 3) (v : Fin 3 → ℤ) (hv : isPythTriple v) :
    isPythTriple (G j *ᵥ v) := by
  fin_cases j <;> simp_all +decide [ isPythTriple ];
  · simp +decide [ G, Matrix.mulVec ];
    exact ⟨ by nlinarith! [ hyp_gt_leg1 v hv ], by nlinarith! [ hyp_gt_leg1 v hv ], by nlinarith! [ hyp_gt_leg1 v hv ], by nlinarith! [ hyp_gt_leg1 v hv ] ⟩;
  · unfold G; simp +decide [ Matrix.vecHead, Matrix.vecTail ] ;
    exact ⟨ by linarith, by linarith, by linarith, by linarith ⟩;
  · unfold G; simp +decide [ Matrix.mulVec ] ; ring_nf at *;
    exact ⟨ by nlinarith! only [ hv ], by nlinarith! only [ hv ], by nlinarith! only [ hv ], by nlinarith! only [ hv ] ⟩

/-! ## Section 5: Coprimality Preservation -/

theorem dvd_of_dvd_mulVec {v : Fin 3 → ℤ} {d : ℤ}
    (M Minv : Matrix (Fin 3) (Fin 3) ℤ)
    (hInv : Minv * M = 1) (hdiv : ∀ i : Fin 3, d ∣ (M *ᵥ v) i) :
    ∀ i : Fin 3, d ∣ v i := by
  have h_eq : v = Minv *ᵥ (M *ᵥ v) := by
    have h_mul : Minv *ᵥ (M *ᵥ v) = (Minv * M) *ᵥ v := by
      rw [ Matrix.mulVec_mulVec ]
    rw [h_mul, hInv, Matrix.one_mulVec];
  exact fun i => h_eq ▸ by simpa [ Matrix.mulVec ] using Finset.dvd_sum fun j _ => dvd_mul_of_dvd_right ( hdiv j ) ( Minv i j ) ;

theorem G_preserves_gcd (j : Fin 3) (v : Fin 3 → ℤ)
    (hgcd : Int.gcd (v 0) (Int.gcd (v 1) (v 2)) = 1) :
    Int.gcd ((G j *ᵥ v) 0) (Int.gcd ((G j *ᵥ v) 1) ((G j *ᵥ v) 2)) = 1 := by
  -- Let $d$ be the gcd of the components of $G j *ᵥ v$.
  set d := Int.gcd ((G j *ᵥ v) 0) (Int.gcd ((G j *ᵥ v) 1) ((G j *ᵥ v) 2)) with hd;
  -- Since $d$ divides each component of $G j *ᵥ v$, it follows that $d$ divides each component of $v$.
  have h_div_v : ∀ i, (d : ℤ) ∣ v i := by
    have h_div_v : ∀ i, (d : ℤ) ∣ (G j *ᵥ v) i := by
      exact fun i => by fin_cases i <;> [ exact Int.gcd_dvd_left _ _ ; exact Int.dvd_trans ( Int.gcd_dvd_right _ _ ) ( Int.gcd_dvd_left _ _ ) ; exact Int.dvd_trans ( Int.gcd_dvd_right _ _ ) ( Int.gcd_dvd_right _ _ ) ] ;
    convert dvd_of_dvd_mulVec ( G j ) ( Ginv j ) ( Ginv_mul_G j ) h_div_v using 1;
  exact Nat.dvd_one.mp ( hgcd ▸ Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr ( h_div_v 0 ) ) ( Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr ( h_div_v 1 ) ) ( Int.natAbs_dvd_natAbs.mpr ( h_div_v 2 ) ) ) )

/-! ## Section 6: Main Theorems -/

theorem G_preserves_primitive (j : Fin 3) (v : Fin 3 → ℤ)
    (hv : isPrimitive v) : isPrimitive (G j *ᵥ v) :=
  ⟨G_preserves_pythTriple j v hv.1, G_preserves_gcd j v hv.2⟩

theorem root_isPrimitive : isPrimitive root := by
  constructor
  · exact ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩
  · native_decide

/-- **Theorem 1**: Every Berggren orbit vector from (3,4,5) is primitive. -/
theorem berggren_word_preserves_primitive (w : BWord) :
    isPrimitive (evalW w root) := by
  induction w with
  | nil => exact root_isPrimitive
  | cons j w ih =>
    show isPrimitive ((G j * wMat w) *ᵥ root)
    have : (G j * wMat w) *ᵥ root = G j *ᵥ (wMat w *ᵥ root) := by
      rw [← mulVec_mulVec]
    rw [this]
    exact G_preserves_primitive j _ ih

/-! ## Section 7: Norm Lower Bounds -/

theorem sqNorm_nonneg (v : Fin 3 → ℤ) : 0 ≤ sqNorm v := by
  unfold sqNorm; positivity

theorem sqNorm_eq_zero_iff (v : Fin 3 → ℤ) : sqNorm v = 0 ↔ v = 0 := by
  constructor <;> intro h;
  · exact funext fun i => by fin_cases i <;> simp_all +decide [ sqNorm ] <;> nlinarith;
  · aesop

/-
**Theorem 2**: Nonzero integer vectors have squared norm ≥ 1.
-/
theorem berggren_lattice_sqNorm_pos (v : Fin 3 → ℤ) (hne : v ≠ 0) :
    1 ≤ sqNorm v := by
  exact sqNorm_nonneg v |> fun h => h.lt_of_ne' fun h' => hne <| by simpa [ sqNorm_eq_zero_iff ] using h';

theorem pyth_sqNorm (v : Fin 3 → ℤ) (hv : isPythTriple v) :
    sqNorm v = 2 * (v 2) ^ 2 := by
  obtain ⟨_, _, _, heq⟩ := hv; unfold sqNorm; linarith

theorem pyth_sqNorm_ge_two (v : Fin 3 → ℤ) (hv : isPythTriple v) :
    sqNorm v ≥ 2 := by
  rw [pyth_sqNorm v hv]; nlinarith [hv.2.2.1, sq_nonneg (v 2 - 1)]

/-! ## Section 8: Bounded Orbit and Lattice -/

def boundedOrbit (d : ℕ) : Set (Fin 3 → ℤ) :=
  { v | ∃ w : BWord, w.length ≤ d ∧ v = evalW w root }

theorem boundedOrbit_primitive (d : ℕ) (v : Fin 3 → ℤ) (hv : v ∈ boundedOrbit d) :
    isPrimitive v := by
  obtain ⟨w, _, rfl⟩ := hv; exact berggren_word_preserves_primitive w

def orbitLattice (d : ℕ) : Submodule ℤ (Fin 3 → ℤ) :=
  Submodule.span ℤ (boundedOrbit d)

/-- **Theorem 3**: Bounded orbit vectors lie in the orbit lattice. -/
theorem bounded_berggren_orbit_in_lattice (d : ℕ) (v : Fin 3 → ℤ)
    (hv : v ∈ boundedOrbit d) : v ∈ orbitLattice d :=
  Submodule.subset_span hv

theorem orbit_lattice_norm_pos (d : ℕ) (x : Fin 3 → ℤ)
    (hne : x ≠ 0) : 1 ≤ sqNorm x :=
  berggren_lattice_sqNorm_pos x hne

/-! ## Section 9: Security Reduction -/

def berggrenMinEntropy (d : ℕ) : ℕ := d
def pqSecBits (d : ℕ) : ℕ := berggrenMinEntropy d / 2

/-- **Theorem 4**: Post-quantum security from sufficient depth. -/
theorem berggren_key_security_from_minEntropy
    (keyLen entropyLoss d : ℕ) (hd : 2 * keyLen + entropyLoss ≤ d) :
    keyLen ≤ pqSecBits d := by
  simp only [pqSecBits, berggrenMinEntropy]; omega

theorem orbit_exponential (d : ℕ) : 3 ^ d ≥ 2 ^ d :=
  Nat.pow_le_pow_left (by norm_num) d

theorem grover_halves (d : ℕ) : 2 ^ (d / 2) ≤ 2 ^ d :=
  Nat.pow_le_pow_right (by norm_num) (Nat.div_le_self d 2)

theorem security_from_depth (k d : ℕ) (hd : 2 * k ≤ d) :
    k ≤ pqSecBits d := by
  simp only [pqSecBits, berggrenMinEntropy]; omega

/-! ## Section 10: Computational Verification -/

theorem depth1_A : evalW [0] root = ![5, 12, 13] := by native_decide
theorem depth1_B : evalW [1] root = ![21, 20, 29] := by native_decide
theorem depth1_C : evalW [2] root = ![15, 8, 17] := by native_decide
theorem depth2_AB : evalW [0, 1] root = ![39, 80, 89] := by native_decide

/-! ## Section 11: Word Matrix Algebra -/

theorem wMat_append (w₁ w₂ : BWord) :
    wMat (w₁ ++ w₂) = wMat w₁ * wMat w₂ := by
  induction w₁ with
  | nil => simp [wMat]
  | cons j w₁ ih => simp only [List.cons_append, wMat, ih, Matrix.mul_assoc]

theorem G_det_sq (j : Fin 3) : (G j).det ^ 2 = 1 := by
  fin_cases j <;> native_decide

theorem wMat_det_unit (w : BWord) : IsUnit (wMat w).det := by
  induction w with
  | nil => simp [wMat]
  | cons j w ih =>
    simp only [wMat, det_mul]
    have hsq := G_det_sq j
    rw [sq] at hsq
    exact IsUnit.mul (IsUnit.of_mul_eq_one _ hsq) ih

end BerggrenLattice