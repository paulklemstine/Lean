import Mathlib

open Matrix

/-- The Pell numbers `0, 1, 2, 5, 12, 29, …`. -/
def pellNum : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | (n + 2) => 2 * pellNum (n + 1) + pellNum n

/-! # CatalogBuild.Pythagorean.Core.NewHypotheses

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 24
-/

/-- The quadruple Lorentz form Q₄(a,b,c,d) = a² + b² + c² - d² -/
def lorentzQ4 (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2

/-- Pythagorean quadruples lie on the null cone Q₄ = 0 -/
theorem quadruple_null_cone {a b c d : ℤ} (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    lorentzQ4 a b c d = 0 := by
  unfold lorentzQ4; omega

/-- The fundamental Pythagorean quadruple (1,2,2,3) -/
theorem fundamental_quadruple : (1 : ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 = 3 ^ 2 := by norm_num

/-- Scaling preserves quadruples -/
theorem quadruple_scaling (a b c d k : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2 = (k * d) ^ 2 := by nlinarith [sq_nonneg k]

/-- Companion Pell numbers: H(0)=1, H(1)=1, H(n+2)=2H(n+1)+H(n) -/
def pellComp : ℕ → ℤ
  | 0 => 1
  | 1 => 1
  | (n + 2) => 2 * pellComp (n + 1) + pellComp n

/-- [Section: # CatalogBuild.Pythagorean.Core.NewHypotheses
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 25] -/
theorem pellNum_0 : pellNum 0 = 0 := rfl

/-- [Section: # CatalogBuild.Pythagorean.Core.NewHypotheses
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 25] -/
theorem pellNum_1 : pellNum 1 = 1 := rfl

theorem pellNum_2 : pellNum 2 = 2 := by simp [pellNum]

theorem pellNum_3 : pellNum 3 = 5 := by simp [pellNum]

theorem pellNum_5 : pellNum 5 = 29 := by simp [pellNum]

theorem pell_equation_holds (n : ℕ) :
    pellComp n ^ 2 - 2 * pellNum n ^ 2 = (-1 : ℤ) ^ n := by
  induction n with
  | zero => simp [pellComp, pellNum]
  | succ n ih =>
    cases n with
    | zero => simp [pellComp, pellNum]
    | succ m =>
      simp only [pellComp, pellNum, pow_succ]
      -- By induction on $m$, we can show that $pellComp m = pellNum (m + 1) - pellNum m$.
      have h_comp_num : ∀ m, pellComp m = pellNum (m + 1) - pellNum m := by
        intro m; exact (by
        induction' m using Nat.strong_induction_on with m ih; rcases m with ( _ | _ | m ) <;> simp_all +decide [ pellNum, pellComp ] ; ring;);
      induction' m with m ih <;> simp_all +decide [ pow_succ ];
      rw [ show pellNum ( m + 3 ) = 2 * pellNum ( m + 2 ) + pellNum ( m + 1 ) by rfl ] at * ; linarith

/-- The trivial PPT identity: (2N)² + (N²-1)² = (N²+1)² -/
theorem trivial_ppt_identity (N : ℤ) :
    (2 * N) ^ 2 + (N ^ 2 - 1) ^ 2 = (N ^ 2 + 1) ^ 2 := by ring

theorem hypotenuse_exceeds_leg (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hb : b ≠ 0) : a ^ 2 < c ^ 2 := by
      nlinarith [ mul_self_pos.2 hb ]

/-- Difference of squares factorization -/
theorem diff_squares_factor (a b : ℤ) : a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring

/-- Berggren matrix B_A -/
def BA' : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Inverse of B_A -/
def BA'_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, (-2); (-2), (-1), 2; (-2), (-2), 3]

/-- The Lorentz metric -/
def QLorentz' : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- B_A * B_A⁻¹ = I -/
theorem BA'_mul_inv : BA' * BA'_inv = 1 := by native_decide

/-- Inverse of B_A preserves Lorentz form -/
theorem BA'_inv_preserves_lorentz : BA'_invᵀ * QLorentz' * BA'_inv = QLorentz' := by
  native_decide

/-- The lattice condition: (c-b)(c+b) = N² when N is a leg -/
theorem lattice_condition' (N b c : ℤ) (h : N ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = N ^ 2 := by nlinarith

/-- GCD factor relation for semiprimes -/
theorem gcd_factor_relation' (p q b c : ℤ)
    (h : (p * q) ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = p ^ 2 * q ^ 2 := by nlinarith

/-- A⁻¹ maps consecutive-parameter PPTs down by one step -/
theorem A_inv_descent (m : ℤ) :
    let a := m ^ 2 - (m - 1) ^ 2
    let b := 2 * m * (m - 1)
    let c := m ^ 2 + (m - 1) ^ 2
    let a' := a + 2 * b - 2 * c
    let b' := -2 * a - b + 2 * c
    let c' := -2 * a - 2 * b + 3 * c
    a' = (m - 1) ^ 2 - (m - 2) ^ 2 ∧
    b' = 2 * (m - 1) * (m - 2) ∧
    c' = (m - 1) ^ 2 + (m - 2) ^ 2 := by
  constructor <;> [skip; constructor] <;> ring

/-- Quadruple parametrization: (2mp, 2mq, 2mr, ...) -/
theorem three_square_factor' (m p q r : ℤ) :
    (2 * m * p) ^ 2 + (2 * m * q) ^ 2 + (2 * m * r) ^ 2 =
    4 * m ^ 2 * (p ^ 2 + q ^ 2 + r ^ 2) := by ring

/-- For factoring: a² = (c-b)(c+b) from a²+b²=c² -/
theorem sum_of_squares_factoring' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 = (c - b) * (c + b) := by nlinarith