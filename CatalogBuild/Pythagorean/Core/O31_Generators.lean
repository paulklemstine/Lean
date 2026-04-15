/-! # CatalogBuild.Pythagorean.Core.O31_Generators

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 39
-/

import Mathlib

/-- The Lorentz metric matrix for signature (3,1) -/
def lorentz_metric : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]

/-- The Lorentz inner product η(u,v) = u₀v₀ + u₁v₁ + u₂v₂ - u₃v₃ -/

def lorentz_inner (u v : Fin 4 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 + u 2 * v 2 - u 3 * v 3

/-- The Lorentz norm Q(v) = v₀² + v₁² + v₂² - v₃² -/

def lorentz_norm (v : Fin 4 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 - v 3 ^ 2

/-- Lorentz norm equals lorentz inner product with itself -/

theorem lorentz_norm_eq_inner (v : Fin 4 → ℤ) :
    lorentz_norm v = lorentz_inner v v := by
  unfold lorentz_norm lorentz_inner; ring

/-- A Pythagorean quadruple is a null vector of the Lorentz form -/

def is_pythagorean_quad (v : Fin 4 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 = v 3 ^ 2


theorem pythagorean_iff_null (v : Fin 4 → ℤ) :
    is_pythagorean_quad v ↔ lorentz_norm v = 0 := by
  unfold is_pythagorean_quad lorentz_norm; omega

/-! ## Section 2: The All-Ones Reflection Matrix -/

/-- The all-ones reflection matrix R_s for s = (1,1,1,1) in O(3,1;ℤ) -/

def allones_reflection : Matrix (Fin 4) (Fin 4) ℤ :=
  !![-1, -1, -1,  2;
     -1, -1, -1,  2;
     -1, -1, -1,  2;
     -1, -1, -1,  1]
-- Correction: the all-ones reflection R(v) = v - η(s,v)·s
-- where η(s,v) = v₀+v₁+v₂-v₃, and s = (1,1,1,1)
-- R(v)_i = v_i - (v₀+v₁+v₂-v₃)  for spatial i
-- R(v)_3 = v_3 - (v₀+v₁+v₂-v₃) = 2v₃ - v₀ - v₁ - v₂
-- Wait, let me recompute:
-- R_s(v) = v - (2η(s,v)/η(s,s))·s
-- η(s,s) = 1+1+1-1 = 2, so coeff = η(s,v)
-- R(v)_i = v_i - η(s,v)·1 for each i
-- For spatial: R(v)_0 = v₀ - (v₀+v₁+v₂-v₃) = -v₁-v₂+v₃ = d-b-c
-- R(v)_3 = v₃ - (v₀+v₁+v₂-v₃) = 2v₃-v₀-v₁-v₂ = 2d-a-b-c

-- Let me write the correct matrix:
-- R(a,b,c,d) = (d-b-c, d-a-c, d-a-b, 2d-a-b-c)
-- Row 0: v₃-v₁-v₂ → coeffs [0, -1, -1, 1]
-- Row 1: v₃-v₀-v₂ → coeffs [-1, 0, -1, 1]
-- Row 2: v₃-v₀-v₁ → coeffs [-1, -1, 0, 1]
-- Row 3: 2v₃-v₀-v₁-v₂ → coeffs [-1, -1, -1, 2]

/-- The corrected all-ones reflection matrix -/

def R₁ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, -1, -1,  1;
    -1,  0, -1,  1;
    -1, -1,  0,  1;
    -1, -1, -1,  2]

/-- R₁ is an involution (R₁² = I) -/

theorem R1_involution : R₁ * R₁ = 1 := by
  unfold R₁; native_decide

/-- R₁ preserves the Lorentz metric: R₁ᵀ η R₁ = η -/

theorem R1_preserves_metric :
    R₁.transpose * lorentz_metric * R₁ = lorentz_metric := by
  unfold R₁ lorentz_metric; native_decide

/-- R₁ has determinant -1 (it's a reflection) -/

theorem R1_det : R₁.det = -1 := by
  unfold R₁; native_decide

/-! ## Section 3: Permutation Generators -/

/-- Transposition (0,1): swaps first two spatial coordinates -/

def P01 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 1, 0, 0;
     1, 0, 0, 0;
     0, 0, 1, 0;
     0, 0, 0, 1]

/-- Transposition (0,2): swaps first and third spatial coordinates -/

def P02 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 0, 1, 0;
     0, 1, 0, 0;
     1, 0, 0, 0;
     0, 0, 0, 1]

/-- Transposition (1,2): swaps second and third spatial coordinates -/

def P12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0;
     0, 0, 1, 0;
     0, 1, 0, 0;
     0, 0, 0, 1]


theorem P01_involution : P01 * P01 = 1 := by unfold P01; native_decide

theorem P02_involution : P02 * P02 = 1 := by unfold P02; native_decide

theorem P12_involution : P12 * P12 = 1 := by unfold P12; native_decide


theorem P01_preserves_metric : P01.transpose * lorentz_metric * P01 = lorentz_metric := by
  unfold P01 lorentz_metric; native_decide


theorem P02_preserves_metric : P02.transpose * lorentz_metric * P02 = lorentz_metric := by
  unfold P02 lorentz_metric; native_decide


theorem P12_preserves_metric : P12.transpose * lorentz_metric * P12 = lorentz_metric := by
  unfold P12 lorentz_metric; native_decide

/-! ## Section 4: Sign Change Generators -/

/-- Sign change of first coordinate -/

def S0 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![-1, 0, 0, 0;
      0, 1, 0, 0;
      0, 0, 1, 0;
      0, 0, 0, 1]


theorem S0_involution : S0 * S0 = 1 := by unfold S0; native_decide


theorem S0_preserves_metric : S0.transpose * lorentz_metric * S0 = lorentz_metric := by
  unfold S0 lorentz_metric; native_decide

/-! ## Section 5: The Descent Map -/

/-- The descent map for Pythagorean quadruples -/

def descent_quad (v : Fin 4 → ℤ) : Fin 4 → ℤ :=
  ![v 3 - v 1 - v 2, v 3 - v 0 - v 2, v 3 - v 0 - v 1, 2 * v 3 - v 0 - v 1 - v 2]

/-- The descent map equals multiplication by R₁ -/

theorem descent_eq_R1_mul (v : Fin 4 → ℤ) :
    descent_quad v = R₁ *ᵥ v := by
  unfold descent_quad R₁
  ext i; fin_cases i <;> simp [mulVec, dotProduct, Fin.sum_univ_succ] <;> ring

/-- The descent preserves the Pythagorean property -/

theorem descent_preserves_pythagorean (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-b-c)^2 + (d-a-c)^2 + (d-a-b)^2 = (2*d-a-b-c)^2 := by nlinarith

/-- The descent strictly decreases the hypotenuse when a,b,c > 0 -/

theorem descent_decreases_hyp (a b c d : ℤ)
    (h : a^2 + b^2 + c^2 = d^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    0 < 2*d - a - b - c ∧ 2*d - a - b - c < d := by
  constructor
  · nlinarith [sq_nonneg (a-b), sq_nonneg (a-c), sq_nonneg (b-c)]
  · nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-! ## Section 6: Root of the Descent Tree -/

/-- The root quadruple (0,0,1,1) -/

theorem root_quad : (0:ℤ)^2 + 0^2 + 1^2 = 1^2 := by norm_num

/-- If d = 1, the only non-negative solution is a permutation of (0,0,1) -/

theorem root_characterization (a b c : ℤ)
    (h : a^2 + b^2 + c^2 = 1) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) :
    (a = 0 ∧ b = 0 ∧ c = 1) ∨ (a = 0 ∧ b = 1 ∧ c = 0) ∨ (a = 1 ∧ b = 0 ∧ c = 0) := by
  have ha1 : a ≤ 1 := by nlinarith
  have hb1 : b ≤ 1 := by nlinarith
  have hc1 : c ≤ 1 := by nlinarith
  interval_cases a <;> interval_cases b <;> interval_cases c <;> simp_all

/-! ## Section 7: The Full Generating Set -/

/-- All generators are in O(3,1;ℤ): they preserve the Lorentz metric -/


theorem generators_are_lorentz :
    R₁.transpose * lorentz_metric * R₁ = lorentz_metric ∧
    P01.transpose * lorentz_metric * P01 = lorentz_metric ∧
    P02.transpose * lorentz_metric * P02 = lorentz_metric ∧
    P12.transpose * lorentz_metric * P12 = lorentz_metric ∧
    S0.transpose * lorentz_metric * S0 = lorentz_metric :=
  ⟨R1_preserves_metric, P01_preserves_metric, P02_preserves_metric,
   P12_preserves_metric, S0_preserves_metric⟩

/-- All generators are involutions -/

theorem generators_are_involutions :
    R₁ * R₁ = 1 ∧ P01 * P01 = 1 ∧ P02 * P02 = 1 ∧
    P12 * P12 = 1 ∧ S0 * S0 = 1 :=
  ⟨R1_involution, P01_involution, P02_involution, P12_involution, S0_involution⟩

/-! ## Section 8: Composition Examples -/

/-- R₁ composed with P01 gives a different descent direction -/

def R_swap01 : Matrix (Fin 4) (Fin 4) ℤ := P01 * R₁ * P01


theorem R_swap01_preserves_metric :
    R_swap01.transpose * lorentz_metric * R_swap01 = lorentz_metric := by
  unfold R_swap01; native_decide

/-- The three Berggren-type matrices for k=4 -/

theorem MA_preserves : M_A.transpose * lorentz_metric * M_A = lorentz_metric := by
  unfold M_A; exact R1_preserves_metric


theorem MB_preserves : M_B.transpose * lorentz_metric * M_B = lorentz_metric := by
  unfold M_B; native_decide


theorem MC_preserves : M_C.transpose * lorentz_metric * M_C = lorentz_metric := by
  unfold M_C; native_decide

/-! ## Section 9: Computational Verification -/

/-- Enumerate primitive Pythagorean quadruples up to bound -/

def listPrimQuads (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ) := do
  let d ← List.range (N + 1)
  let c ← List.range (d + 1)
  let b ← List.range (c + 1)
  let a ← List.range (b + 1)
  if d > 0 && a * a + b * b + c * c == d * d &&
     Nat.gcd (Nat.gcd a b) (Nat.gcd c d) == 1
  then return (a, b, c, d)
  else .nil

#eval listPrimQuads 10
#eval (listPrimQuads 50).length

/-- Apply descent and normalize -/

def descentQuad (a b c d : ℕ) : ℕ × ℕ × ℕ × ℕ :=
  let a' := (d : Int) - b - c
  let b' := (d : Int) - a - c
  let c' := (d : Int) - a - b
  let d' := 2 * (d : Int) - a - b - c
  let vals := [a'.natAbs, b'.natAbs, c'.natAbs]
  let sorted := vals.mergeSort (· ≤ ·)
  (sorted[0]!, sorted[1]!, sorted[2]!, d'.natAbs)

/-- Verify that descent reaches (0,0,1,1) -/

def verifyDescentQuad (a b c d : ℕ) (fuel : ℕ) : Bool :=
  match fuel with
  | 0 => false
  | fuel + 1 =>
    if a == 0 && b == 0 && c == 1 && d == 1 then true
    else if d == 0 then false
    else
      let (a', b', c', d') := descentQuad a b c d
      verifyDescentQuad a' b' c' d' fuel

#eval (listPrimQuads 50).map (fun (a, b, c, d) => ((a, b, c, d), verifyDescentQuad a b c d 100))

