/-! # CatalogBuild.Algebra.Factoring.HyperbolicShortcuts

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 25
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 27] -/
theorem B₁_preserves_Q : B₁ᵀ * Q * B₁ = Q := by native_decide


/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 27] -/
theorem B₂_preserves_Q : B₂ᵀ * Q * B₂ = Q := by native_decide


/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 25] -/
theorem B₃_preserves_Q : B₃ᵀ * Q * B₃ = Q := by native_decide


def dirMatrix : BDir → Matrix (Fin 3) (Fin 3) ℤ
  | .L => B₁ | .M => B₂ | .R => B₃


def pathMatrix : BPath → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | d :: ds => dirMatrix d * pathMatrix ds


def root : Fin 3 → ℤ := ![3, 4, 5]


theorem dir_preserves_Q (d : BDir) : (dirMatrix d)ᵀ * Q * (dirMatrix d) = Q := by
  cases d <;> simp only [dirMatrix] <;> native_decide


/-- Each direction matrix has |det| = 1 (they are in O(2,1)(ℤ)). -/
theorem dir_det_abs (d : BDir) : |Matrix.det (dirMatrix d)| = 1 := by
  cases d <;> simp only [dirMatrix] <;> native_decide


theorem pathMatrix_preserves_Q (p : BPath) :
    (pathMatrix p)ᵀ * Q * (pathMatrix p) = Q := by
  induction' p with d p ih;
  · decide +kernel;
  · rw [ show pathMatrix ( d :: p ) = dirMatrix d * pathMatrix p from rfl, Matrix.mul_assoc ];
    simp +decide only [transpose_mul, Matrix.mul_assoc];
    simp +decide [ ← mul_assoc, ← Matrix.mul_assoc ( pathMatrix p |> Matrix.transpose ), ih, dir_preserves_Q ]


/-- The absolute determinant of any path matrix is 1. -/
theorem shortcut_det_abs (p : BPath) :
    |Matrix.det (pathMatrix p)| = 1 := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih =>
    simp only [pathMatrix, Matrix.det_mul, abs_mul, dir_det_abs, ih, one_mul]


theorem B₁_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 = (2*a - 2*b + 3*c)^2 := by nlinarith


theorem B₂_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 = (2*a + 2*b + 3*c)^2 := by nlinarith


theorem B₃_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith


theorem dir_preserves_pyth (d : BDir) (v : Fin 3 → ℤ)
    (hv : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    let w := dirMatrix d *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 = w 2 ^ 2 := by
  rcases d with ⟨ _ | _ | _ ⟩ <;> norm_num [ Fin.sum_univ_succ, Matrix.mulVec ] at *;
  · simp +decide [ dirMatrix, dotProduct ];
    simp +decide [ Fin.sum_univ_three, B₁ ];
    linarith;
  · norm_num [ Fin.sum_univ_succ, dotProduct, dirMatrix ] ; ring;
    simp +decide [ B₂ ] ; nlinarith;
  · simp +decide [ dirMatrix, dotProduct ];
    simp +decide [ B₃, Fin.sum_univ_three ] ; linarith


/-- Every triple in the Berggren tree satisfies a² + b² = c². -/
theorem tripleAt_pythagorean (p : BPath) :
    (tripleAt p) 0 ^ 2 + (tripleAt p) 1 ^ 2 = (tripleAt p) 2 ^ 2 := by
  induction p with
  | nil => simp only [tripleAt, pathMatrix]; native_decide
  | cons d ds ih =>
    simp only [tripleAt, pathMatrix] at *
    rw [← mulVec_mulVec]
    exact dir_preserves_pyth d _ ih


/-- (c - a)(c + a) = b² when a² + b² = c². -/
theorem factoring_identity' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - a) * (c + a) = b ^ 2 := by ring_nf; linarith


/-- Factoring from a Pythagorean triple with leg N. -/
theorem factoring_from_triple (N b c : ℤ)
    (h : N ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = N ^ 2 :=
  factoring_identity N b c h


/-- Path concatenation = matrix multiplication. -/
theorem pathMatrix_append (p q : BPath) :
    pathMatrix (p ++ q) = pathMatrix p * pathMatrix q := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih => simp only [List.cons_append, pathMatrix, ih, Matrix.mul_assoc]


theorem shortcut_preserves_information (p : BPath) :
    Function.Injective (pathMatrix p *ᵥ ·) := by
  have h_det : IsUnit (Matrix.det (pathMatrix p)) := by
    have := shortcut_det_abs p;
    rw [ abs_eq ] at this <;> aesop;
  exact fun x y hxy => by simpa [ h_det ] using congr_arg ( fun z => ( pathMatrix p ) ⁻¹ *ᵥ z ) hxy;


/-- det B₁ = 1, det B₃ = 1, but det B₂ = -1. B₁ and B₃ are in SO(2,1)(ℤ),
while B₂ is in O(2,1)(ℤ) \ SO(2,1)(ℤ). -/
theorem B₁_in_SO : Matrix.det B₁ = 1 := det_B₁


theorem B₃_in_SO : Matrix.det B₃ = 1 := det_B₃


theorem B₂_not_SO : Matrix.det B₂ = -1 := det_B₂


def lorentzInner (u v : Fin 3 → ℤ) : ℤ := u 0 * v 0 + u 1 * v 1 - u 2 * v 2


theorem root_lorentz_zero : lorentzInner root root = 0 := by
  simp [lorentzInner, root]


theorem path_preserves_lorentz (p : BPath) (u v : Fin 3 → ℤ) :
    lorentzInner (pathMatrix p *ᵥ u) (pathMatrix p *ᵥ v) = lorentzInner u v := by
  -- By definition of $pathMatrix$, we know that $pathMatrix p$ preserves the Lorentz inner product.
  have hpathMatrix_preserves_lorentzInner : ∀ p : BPath, ∀ u v : Fin 3 → ℤ, lorentzInner (pathMatrix p *ᵥ u) (pathMatrix p *ᵥ v) = lorentzInner u v := by
    intro p u v;
    -- By definition of $pathMatrix$, we know that $pathMatrix p$ preserves the Lorentz form.
    have hpathMatrix_preserves_Q : ∀ p : BPath, (pathMatrix p)ᵀ * Q * (pathMatrix p) = Q := by
      exact?;
    -- By definition of Lorentz form, we know that $u^T Q v = lorentzInner u v$.
    have hLorentzForm : ∀ u v : Fin 3 → ℤ, u ⬝ᵥ Q.mulVec v = lorentzInner u v := by
      unfold lorentzInner; simp +decide [ dotProduct, Matrix.mulVec ] ;
      unfold Q; simp +decide [ Fin.sum_univ_three ] ; intros; ring;
    rw [ ← hLorentzForm, ← hLorentzForm ];
    simp_all +decide [ Matrix.mul_assoc, Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec ];
  exact hpathMatrix_preserves_lorentzInner p u v


