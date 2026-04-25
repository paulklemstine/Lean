/-! # CatalogBuild.Pythagorean.Berggren.BerggrenLorentzPaper

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28
-/

import Mathlib

/-- Berggren matrix B_A (first generator) -/
def BA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- Berggren matrix B_B (second generator) -/
def BB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- Berggren matrix B_C (third generator) -/
def BC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


/-- The Lorentz metric matrix: diag(1, 1, -1) -/
def QLorentz : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]


/-- **Theorem 3.1a**: B_A preserves the Lorentz form: B_Aᵀ Q B_A = Q -/
theorem BA_preserves_lorentz : BAᵀ * QLorentz * BA = QLorentz := by
  native_decide


/-- **Theorem 3.1b**: B_B preserves the Lorentz form: B_Bᵀ Q B_B = Q -/
theorem BB_preserves_lorentz : BBᵀ * QLorentz * BB = QLorentz := by
  native_decide


/-- **Theorem 3.1c**: B_C preserves the Lorentz form: B_Cᵀ Q B_C = Q -/
theorem BC_preserves_lorentz : BCᵀ * QLorentz * BC = QLorentz := by
  native_decide


/-- det(B_A) = 1: B_A is in SO(2,1;ℤ) -/
theorem det_BA : Matrix.det BA = 1 := by decide


/-- det(B_B) = -1: B_B reverses orientation -/
theorem det_BB : Matrix.det BB = -1 := by decide


/-- det(B_C) = 1: B_C is in SO(2,1;ℤ) -/
theorem det_BC : Matrix.det BC = 1 := by decide


/-- **Theorem 3.2a**: B_A preserves the Pythagorean equation -/
theorem BA_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]


/-- **Theorem 3.2b**: B_B preserves the Pythagorean equation -/
theorem BB_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]


/-- **Theorem 3.2c**: B_C preserves the Pythagorean equation -/
theorem BC_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]


/-- The triple at a given Berggren tree path. -/
def tripleAt : BerggrenPath → ℤ × ℤ × ℤ
  | .root => (3, 4, 5)
  | .stepA p =>
    let (a, b, c) := tripleAt p
    (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .stepB p =>
    let (a, b, c) := tripleAt p
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .stepC p =>
    let (a, b, c) := tripleAt p
    (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenLorentzPaper
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28] -/
theorem tripleAt_is_pythagorean (p : BerggrenPath) :
    let (a, b, c) := tripleAt p
    a ^ 2 + b ^ 2 = c ^ 2 := by
      induction' p with p hp;
      · exact Int.neg_inj.mp rfl;
      · convert BA_preserves_pyth _ _ _ hp using 1;
      · rename_i p ih;
        convert BB_preserves_pyth _ _ _ ih using 1;
      · rename_i p ih;
        convert BC_preserves_pyth _ _ _ ih using 1


/-- **Theorem 3.4**: The factoring identity (c-b)(c+b) = a² -/
theorem factoring_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by
  nlinarith


/-- The hypotenuse along the pure B-branch path. -/
def pellHyp : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | (n + 2) => 6 * pellHyp (n + 1) - pellHyp n


/-- The first leg along the pure B-branch. -/
def pellLegA : ℕ → ℤ
  | 0 => 3
  | 1 => 21
  | (n + 2) => 6 * pellLegA (n + 1) - pellLegA n


/-- The second leg along the pure B-branch. -/
def pellLegB : ℕ → ℤ
  | 0 => 4
  | 1 => 20
  | (n + 2) => 6 * pellLegB (n + 1) - pellLegB n


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenLorentzPaper
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28] -/
theorem pellHyp_2 : pellHyp 2 = 169 := by simp [pellHyp]


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenLorentzPaper
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28] -/
theorem pellHyp_3 : pellHyp 3 = 985 := by simp [pellHyp]


theorem pellHyp_4 : pellHyp 4 = 5741 := by simp [pellHyp]


/-- **Theorem 4.4**: A⁻¹ maps the triple with parameters (m, m-1) to (m-1, m-2). -/
theorem A_inv_consecutive_params (m : ℤ) (_hm : 2 ≤ m) :
    let a := m ^ 2 - (m - 1) ^ 2
    let b := 2 * m * (m - 1)
    let c := m ^ 2 + (m - 1) ^ 2
    let a' := a + 2 * b - 2 * c      -- A⁻¹ first component
    let b' := -2 * a - b + 2 * c      -- A⁻¹ second component
    let c' := -2 * a - 2 * b + 3 * c  -- A⁻¹ third component
    a' = (m - 1) ^ 2 - (m - 2) ^ 2 ∧
    b' = 2 * (m - 1) * (m - 2) ∧
    c' = (m - 1) ^ 2 + (m - 2) ^ 2 := by
  constructor <;> [skip; constructor] <;> ring


/-- Pythagorean triples lie on the null cone Q = 0 -/
theorem pyth_null_cone {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    lorentzQ a b c = 0 := by
  unfold lorentzQ; omega


/-- B_A preserves Q for arbitrary vectors (not just null cone) -/
theorem BA_preserves_Q (a b c : ℤ) :
    lorentzQ a b c =
    lorentzQ (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) := by
  unfold lorentzQ; ring


/-- B_B preserves Q for arbitrary vectors -/
theorem BB_preserves_Q (a b c : ℤ) :
    lorentzQ a b c =
    lorentzQ (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  unfold lorentzQ; ring


/-- B_C preserves Q for arbitrary vectors -/
theorem BC_preserves_Q (a b c : ℤ) :
    lorentzQ a b c =
    lorentzQ (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
  unfold lorentzQ; ring


/-- For factoring: if N = a is odd and (a,b,c) is a PPT, then
a² = (c-b)(c+b), which exposes divisors of a² as c±b. -/
theorem sum_of_squares_factoring (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 = (c - b) * (c + b) := by
  nlinarith


