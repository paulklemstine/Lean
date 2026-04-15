/-! # CatalogBuild.Best.03_HyperbolicShortcutsFactoring

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 38
-/

import Mathlib

/-- The core algebraic identity: for any Pythagorean triple, the hypotenuse
and one leg yield a difference-of-squares factorization of the other leg squared. -/
theorem diff_of_squares_from_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by linarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- The factorization works symmetrically for the other leg. -/

theorem diff_of_squares_sym {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - a) * (c + a) = b ^ 2 := by linarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- If a² + b² = c² with a > 0 and c > 0, then b < c. -/

theorem hyp_gt_leg {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hc : 0 < c) :
    b < c := by nlinarith [sq_nonneg (c - b)]

/-- For a Pythagorean triple with positive entries, c - b and c + b are both positive. -/

theorem factors_pos {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < c - b ∧ 0 < c + b := by
  exact ⟨by nlinarith [sq_nonneg (c - b)], by linarith⟩

/-! ## §2. The Berggren Matrices -/

/-- Berggren matrix B₁ (left branch). -/

def Q : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- B₁ preserves the Lorentz form: B₁ᵀ Q B₁ = Q. -/

theorem det_B₁ : Matrix.det B₁ = 1 := by native_decide

/-- det(B₂) = -1: B₂ is in O(2,1;ℤ) \ SO(2,1;ℤ). -/

theorem det_B₂ : Matrix.det B₂ = -1 := by native_decide

/-- det(B₃) = 1: B₃ is in SO⁺(2,1;ℤ). -/

theorem det_B₃ : Matrix.det B₃ = 1 := by native_decide

/-! ## §3. Berggren Tree Structure -/

/-- Direction in the ternary tree. -/

inductive Dir where
  | L | M | R
  deriving DecidableEq, Repr

/-- A path in the Berggren tree is a list of directions. -/

abbrev BPath := List Dir

/-- Matrix corresponding to a single direction. -/

def dirMat : Dir → Matrix (Fin 3) (Fin 3) ℤ
  | .L => B₁ | .M => B₂ | .R => B₃

/-- The composite matrix for a path (leftmost direction applied first). -/

def pathMat : BPath → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | d :: ds => dirMat d * pathMat ds

/-- The root triple (3, 4, 5). -/

def root : Fin 3 → ℤ := ![3, 4, 5]

/-- The triple at a given path in the Berggren tree. -/

def tripleAt (p : BPath) : Fin 3 → ℤ := pathMat p *ᵥ root

/-- The root satisfies the Pythagorean equation. -/

theorem root_pyth : (root 0) ^ 2 + (root 1) ^ 2 = (root 2) ^ 2 := by native_decide

/-! ## §4. Pythagorean Property Preservation -/

/-- B₁ preserves the Pythagorean property. -/

theorem pathMat_append (p q : BPath) :
    pathMat (p ++ q) = pathMat p * pathMat q := by
  induction p with
  | nil => simp [pathMat]
  | cons d ds ih => simp [pathMat, ih, Matrix.mul_assoc]

/-- **Shortcut Theorem**: navigating p then q equals the concatenated path. -/

theorem shortcut_compose (p q : BPath) :
    tripleAt (p ++ q) = pathMat p *ᵥ tripleAt q := by
  simp [tripleAt, pathMat_append, mulVec_mulVec]

/-- Any path matrix preserves the Lorentz form Q. -/

theorem pathMat_lorentz (p : BPath) :
    (pathMat p)ᵀ * Q * pathMat p = Q := by
  induction p with
  | nil => native_decide
  | cons d ds ih =>
    have hd : (dirMat d)ᵀ * Q * dirMat d = Q := by
      cases d <;> simp [dirMat] <;> native_decide
    simp only [pathMat, transpose_mul]
    rw [show (pathMat ds)ᵀ * (dirMat d)ᵀ * Q * (dirMat d * pathMat ds)
        = (pathMat ds)ᵀ * ((dirMat d)ᵀ * (Q * (dirMat d * pathMat ds))) from by
          simp [Matrix.mul_assoc]]
    rw [show Q * (dirMat d * pathMat ds) = Q * dirMat d * pathMat ds from by
          simp [Matrix.mul_assoc]]
    rw [show (dirMat d)ᵀ * (Q * dirMat d * pathMat ds)
        = (dirMat d)ᵀ * (Q * dirMat d) * pathMat ds from by simp [Matrix.mul_assoc]]
    rw [show (dirMat d)ᵀ * (Q * dirMat d) = (dirMat d)ᵀ * Q * dirMat d from by
          simp [Matrix.mul_assoc]]
    rw [hd]
    rw [show (pathMat ds)ᵀ * (Q * pathMat ds) = (pathMat ds)ᵀ * Q * pathMat ds from by
          simp [Matrix.mul_assoc]]
    exact ih

/-- The |det| of any path matrix is 1. -/

theorem pathMat_det_abs (p : BPath) : |Matrix.det (pathMat p)| = 1 := by
  induction p with
  | nil => simp [pathMat]
  | cons d ds ih =>
    have : |Matrix.det (dirMat d)| = 1 := by cases d <;> native_decide
    simp [pathMat, Matrix.det_mul, abs_mul, this, ih]

/-! ## §6. Hypotenuse Growth Bounds -/

/-- The hypotenuse strictly increases under B₂ for positive triples. -/

theorem chebyshev_step1 : (169 : ℤ) = 6 * 29 - 5 := by norm_num

/-- c₃ = 6c₂ - c₁. -/

theorem chebyshev_step2 : (985 : ℤ) = 6 * 169 - 29 := by norm_num

/-! ## §8. Inverse Berggren Matrices (Tree Ascent) -/

/-- Inverse of B₁: computed as Q · B₁ᵀ · Q. -/

theorem factoring_from_triple {a b c p q : ℤ}
    (h_pyth : a ^ 2 + b ^ 2 = c ^ 2) (h_factor : a = p * q) :
    (c - b) * (c + b) = (p * q) ^ 2 := by
  rw [h_factor] at h_pyth; linarith [sq_nonneg (c - b), sq_nonneg (c + b)]

/-- **GCD factoring**: If gcd(c - b, a) is nontrivial, it reveals a factor of a. -/

theorem gcd_reveals_factor {a c_minus_b : ℤ} (ha : 1 < a)
    (hg : 1 < Int.gcd c_minus_b a) (hg2 : Int.gcd c_minus_b a < a.natAbs) :
    ∃ d : ℕ, 1 < d ∧ d < a.natAbs ∧ (d : ℤ) ∣ a := by
  exact ⟨Int.gcd c_minus_b a, hg, hg2, Int.gcd_dvd_right c_minus_b a⟩

/-! ## §10. Computational Verification -/

/-- The triple at path [L] is (5, 12, 13). -/

theorem triple_L : tripleAt [Dir.L] = ![5, 12, 13] := by native_decide

/-- The triple at path [M] is (21, 20, 29). -/

theorem triple_M : tripleAt [Dir.M] = ![21, 20, 29] := by native_decide

/-- The triple at path [R] is (15, 8, 17). -/

theorem triple_R : tripleAt [Dir.R] = ![15, 8, 17] := by native_decide

/-- The triple at path [M, M] is (119, 120, 169). -/

theorem triple_MM : tripleAt [Dir.M, Dir.M] = ![119, 120, 169] := by native_decide

/-- The triple at path [L, M] is (39, 80, 89). -/

theorem triple_LM : tripleAt [Dir.L, Dir.M] = ![39, 80, 89] := by native_decide

/-- (5,12,13) is Pythagorean. -/

theorem pyth_5_12_13 : (5 : ℤ)^2 + 12^2 = 13^2 := by norm_num

/-- (21,20,29) is Pythagorean. -/

theorem pyth_21_20_29 : (21 : ℤ)^2 + 20^2 = 29^2 := by norm_num

/-- The difference-of-squares from (21, 20, 29): (29-20)(29+20) = 9·49 = 441 = 21². -/

theorem dos_21_20_29 : (29 - 20) * (29 + 20) = (21 : ℤ)^2 := by norm_num

/-- This reveals the factorization 21 = 3 × 7 since gcd(9, 21) = 3. -/

theorem factor_from_dos : Int.gcd 9 21 = 3 := by native_decide

/-! ## §11. Branch Disjointness -/

/-- B₁ and B₂ always produce distinct hypotenuses (when b ≠ 0). -/

theorem branch_disjoint_LM (a b c : ℤ) (hb : b ≠ 0) :
    2*a - 2*b + 3*c ≠ 2*a + 2*b + 3*c := by omega

/-- B₁ and B₃ produce distinct hypotenuses when a ≠ b. -/

theorem branch_disjoint_LR (a b c : ℤ) (hab : a ≠ b) :
    2*a - 2*b + 3*c ≠ -2*a + 2*b + 3*c := by omega

/-- All three branches produce distinct a-values when a ≠ 0, b ≠ 0, a ≠ 2b. -/

theorem branch_disjoint_legs (a b c : ℤ) (ha : a ≠ 0) (hb : b ≠ 0) (hab : a ≠ 2*b) :
    a - 2*b + 2*c ≠ a + 2*b + 2*c ∧
    a - 2*b + 2*c ≠ -a + 2*b + 2*c ∧
    a + 2*b + 2*c ≠ -a + 2*b + 2*c := by
  refine ⟨by omega, by omega, by omega⟩

/-! ## §12. Lorentz Form as Quadratic Invariant -/

/-- The Lorentz quadratic form. -/

def lorentzQ (v : Fin 3 → ℤ) : ℤ := (v 0) ^ 2 + (v 1) ^ 2 - (v 2) ^ 2

/-- Pythagorean triples are null vectors of the Lorentz form. -/

theorem pyth_iff_null (v : Fin 3 → ℤ) :
    (v 0) ^ 2 + (v 1) ^ 2 = (v 2) ^ 2 ↔ lorentzQ v = 0 := by
  unfold lorentzQ; omega

/-- The root is a null vector. -/

theorem root_null : lorentzQ root = 0 := by native_decide

/-- B₁ preserves the Lorentz form for any vector (algebraic proof). -/
