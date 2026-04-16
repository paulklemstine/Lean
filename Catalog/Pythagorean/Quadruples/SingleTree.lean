/-! # CatalogBuild.Pythagorean.Quadruples.SingleTree

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 34
-/

import Mathlib

/-- The Minkowski metric η = diag(1,1,1,-1) -/
def QF_eta4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]



/-- The reflection through (1,1,1,1) in (3,1)-Minkowski space -/
def QF_R1111 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, -1, -1, 1; -1, 0, -1, 1; -1, -1, 0, 1; -1, -1, -1, 2]



/-- R₁₁₁₁ ∈ O(3,1;ℤ): it preserves the Lorentz form -/
theorem QF_R1111_isLorentz : QF_R1111.transpose * QF_eta4 * QF_R1111 = QF_eta4 := by
  native_decide



/-- R₁₁₁₁² = I: the reflection is an involution -/
theorem QF_R1111_sq_eq_one : QF_R1111 * QF_R1111 = 1 := by native_decide



/-- The descent preserves the Pythagorean property -/
theorem QF_descent_preserves_pyth (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - b - c) ^ 2 + (d - a - c) ^ 2 + (d - a - b) ^ 2 =
    (2 * d - a - b - c) ^ 2 := by nlinarith [h]



/-- a + b + c > d when b, c > 0 -/
theorem QF_sum_exceeds_hyp (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    a + b + c > d := by
  nlinarith [sq_nonneg (a + b + c - d), sq_nonneg a, mul_pos hb hc]



/-- a + b + c < 2d when a, b, c ≥ 0 -/
theorem QF_sum_below_twice_hyp (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 < d) :
    a + b + c < 2 * d := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (c - a)]



/-- The descent strictly decreases the hypotenuse: 0 < d' < d -/
theorem QF_descent_decreases (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    0 < 2 * d - (a + b + c) ∧ 2 * d - (a + b + c) < d := by
  constructor
  · linarith [QF_sum_below_twice_hyp a b c d h ha (le_of_lt hb) (le_of_lt hc) hd]
  · linarith [QF_sum_exceeds_hyp a b c d h ha hb hc hd]



/-- If a² + b² + c² = 1 then exactly one is ±1 and the rest are 0 -/
theorem QF_sum_three_sq_eq_one (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = 1) :
    (a = 0 ∧ b = 0 ∧ (c = 1 ∨ c = -1)) ∨
    (a = 0 ∧ (b = 1 ∨ b = -1) ∧ c = 0) ∨
    ((a = 1 ∨ a = -1) ∧ b = 0 ∧ c = 0) := by
  have ha2 : a ^ 2 ≤ 1 := by nlinarith [sq_nonneg b, sq_nonneg c]
  have hb2 : b ^ 2 ≤ 1 := by nlinarith [sq_nonneg a, sq_nonneg c]
  have hc2 : c ^ 2 ≤ 1 := by nlinarith [sq_nonneg a, sq_nonneg b]
  have ha_lo : -1 ≤ a := by nlinarith [sq_nonneg (a + 1)]
  have ha_hi : a ≤ 1 := by nlinarith [sq_nonneg (a - 1)]
  have hb_lo : -1 ≤ b := by nlinarith [sq_nonneg (b + 1)]
  have hb_hi : b ≤ 1 := by nlinarith [sq_nonneg (b - 1)]
  have hc_lo : -1 ≤ c := by nlinarith [sq_nonneg (c + 1)]
  have hc_hi : c ≤ 1 := by nlinarith [sq_nonneg (c - 1)]
  interval_cases a <;> interval_cases b <;> interval_cases c <;> simp_all



/-- [Section: # CatalogBuild.Pythagorean.Quadruples.SingleTree
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 34] -/
theorem QF_descended_parity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (2 * d - a - b - c) % 2 = d % 2 := by
  replace h := congr_arg Even h; simp_all +decide [ ← parity_simps ] ;
  grind



theorem QF_descent_preserves_prim (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hprim : Int.gcd (Int.gcd a b) (Int.gcd c d) = 1) :
    let a' := d - b - c
    let b' := d - a - c
    let c' := d - a - b
    let d' := 2 * d - a - b - c
    Int.gcd (Int.gcd a' b') (Int.gcd c' d') = 1 := by
  -- By definition of gcd, if $p$ divides $a'$, $b'$, $c'$, and $d'$, then it must also divide $a$, $b$, $c$, and $d$.
  have h_div : ∀ p : ℕ, Nat.Prime p → p ∣ Int.natAbs (d - b - c) → p ∣ Int.natAbs (d - a - c) → p ∣ Int.natAbs (d - a - b) → p ∣ Int.natAbs (2 * d - a - b - c) → p ∣ Int.natAbs a ∧ p ∣ Int.natAbs b ∧ p ∣ Int.natAbs c ∧ p ∣ Int.natAbs d := by
    intro p pp dp dp' dp'' dp''';
    simp_all +decide [ ← Int.natCast_dvd_natCast, dvd_add_right, dvd_add_left, dvd_sub_right, dvd_sub_left ];
    haveI := Fact.mk pp; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, sub_eq_iff_eq_add ] ;
    grind;
  contrapose! h_div;
  obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := Nat.Prime.not_coprime_iff_dvd.mp h_div;
  refine' ⟨ p, hp₁, _, _, _, _, _ ⟩ <;> simp_all +decide [ Int.gcd_eq_natAbs ];
  · exact Nat.dvd_trans hp₂ ( Nat.gcd_dvd_left _ _ );
  · exact Nat.dvd_trans hp₂ ( Nat.gcd_dvd_right _ _ );
  · exact Nat.dvd_trans hp₃ ( Nat.gcd_dvd_left _ _ );
  · exact Nat.dvd_trans hp₃ ( Nat.gcd_dvd_right _ _ );
  · intro ha hb hc hd; have := Nat.dvd_gcd ( Nat.dvd_gcd ha hb ) ( Nat.dvd_gcd hc hd ) ; aesop;



theorem QF_sorted_has_two_pos (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hprim : Int.gcd (Int.gcd a b) (Int.gcd c d) = 1)
    (ha : 0 ≤ a) (hab : a ≤ b) (hbc : b ≤ c)
    (hd : 2 ≤ d) :
    0 < b ∧ 0 < c := by
  constructor;
  · by_contra h_neg_b;
    norm_num [ show a = 0 by linarith, show b = 0 by linarith ] at *;
    cases le_or_gt c d <;> simp_all +decide [ sq_eq_sq_iff_eq_or_eq_neg ];
    · cases h <;> simp_all +decide [ Int.gcd_eq_right ];
      · linarith [ abs_of_nonneg hbc ];
      · linarith;
    · cases h <;> linarith;
  · nlinarith



/-- Cauchy-Schwarz identity for three variables -/
theorem QF_cauchy_schwarz_three (a b c : ℤ) :
    3 * (a ^ 2 + b ^ 2 + c ^ 2) - (a + b + c) ^ 2 =
    (a - b) ^ 2 + (a - c) ^ 2 + (b - c) ^ 2 := by ring



/-- The Euler parametrization yields a Pythagorean quadruple -/
theorem QF_euler_param_valid (m n p q : ℤ) :
    (m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2) ^ 2 +
    (2 * (m * q + n * p)) ^ 2 +
    (2 * (n * q - m * p)) ^ 2 =
    (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2) ^ 2 := by ring



/-- The four-square (quaternion norm) identity -/
theorem QF_quaternion_norm_mult (a b c d e f g h : ℤ) :
    (a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2) * (e ^ 2 + f ^ 2 + g ^ 2 + h ^ 2) =
    (a*e - b*f - c*g - d*h) ^ 2 +
    (a*f + b*e + c*h - d*g) ^ 2 +
    (a*g - b*h + c*e + d*f) ^ 2 +
    (a*h + b*g - c*f + d*e) ^ 2 := by ring



/-- R₁₁₁₁ applied twice returns the original tuple -/
theorem QF_R1111_involution_tuple (a b c d : ℤ) :
    let a' := d - b - c
    let b' := d - a - c
    let c' := d - a - b
    let d' := 2 * d - a - b - c
    let a'' := d' - b' - c'
    let b'' := d' - a' - c'
    let c'' := d' - a' - b'
    let d'' := 2 * d' - a' - b' - c'
    a'' = a ∧ b'' = b ∧ c'' = c ∧ d'' = d := by
  simp only
  exact ⟨by ring, by ring, by ring, by ring⟩



/-- The naive 5D analogue is FALSE: verified by counterexample -/
theorem QF_5d_identity_fails :
    ¬ ((0:ℤ) ^ 2 + 0 ^ 2 + 1 ^ 2 + 0 ^ 2 = 1 ^ 2 →
    (1 - 0 - 1 - 0) ^ 2 + (1 - 0 - 1 - 0) ^ 2 +
    (1 - 0 - 0 - 0) ^ 2 + (1 - 0 - 0 - 1) ^ 2 =
    (3 * 1 - 0 - 0 - 1 - 0) ^ 2) := by norm_num



/-- Worst-case depth: hypotenuse decreases by at least 1 each step -/
theorem QF_depth_upper_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) :
    2 * d - (a + b + c) ≤ d - 1 := by
  linarith [QF_sum_exceeds_hyp a b c d h ha hb hc hd]



/-- The descended hypotenuse from Euler parameters simplifies to a quaternion expression -/
theorem QF_euler_descent_hyp (m n p q : ℤ) :
    2 * (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2) -
    (m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2) -
    2 * (m * q + n * p) -
    2 * (n * q - m * p) =
    m ^ 2 + n ^ 2 + 3 * p ^ 2 + 3 * q ^ 2 - 2 * m * q - 2 * n * p -
    2 * n * q + 2 * m * p := by ring



/-- Berggren descent preserves triples -/
theorem QF_berggren_preserves_triple (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2 * b + 2 * c) ^ 2 + (2 * a - b + 2 * c) ^ 2 =
    (2 * a - 2 * b + 3 * c) ^ 2 := by nlinarith [h]



/-- Each spatial component ≤ hypotenuse -/
theorem QF_component_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 < d) :
    a ≤ d ∧ b ≤ d ∧ c ≤ d := by
  refine ⟨?_, ?_, ?_⟩
  · nlinarith [sq_nonneg b, sq_nonneg c, sq_nonneg (a - d)]
  · nlinarith [sq_nonneg a, sq_nonneg c, sq_nonneg (b - d)]
  · nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (c - d)]



def QF_perm01 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]



def QF_perm12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 0, 1, 0; 0, 1, 0, 0; 0, 0, 0, 1]



def QF_signFlip0 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![-1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]



theorem QF_perm01_isLorentz : QF_perm01.transpose * QF_eta4 * QF_perm01 = QF_eta4 := by
  native_decide



theorem QF_perm12_isLorentz : QF_perm12.transpose * QF_eta4 * QF_perm12 = QF_eta4 := by
  native_decide



theorem QF_signFlip0_isLorentz : QF_signFlip0.transpose * QF_eta4 * QF_signFlip0 = QF_eta4 := by
  native_decide



/-- The root (0,0,1,1) is a fixed point of R₁₁₁₁ -/
theorem QF_root_fixed_point : QF_R1111.mulVec ![(0:ℤ), 0, 1, 1] = ![(0:ℤ), 0, 1, 1] := by
  native_decide



/-- (1,2,2,3) descends to (-1,0,0,1) -/
theorem QF_descent_1223 : QF_R1111.mulVec ![(1:ℤ), 2, 2, 3] = ![(-1:ℤ), 0, 0, 1] := by
  native_decide



/-- ab bound from the Pythagorean equation -/
theorem QF_count_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a * a + b * b ≤ d * d := by
  nlinarith [sq_nonneg c]



/-- Descent step -/
def QF_descentStep (a b c d : ℕ) : ℤ × ℤ × ℤ × ℤ :=
  ((d : ℤ) - b - c, (d : ℤ) - a - c, (d : ℤ) - a - b, 2 * (d : ℤ) - a - b - c)



/-- Normalize: abs and sort -/
def QF_normalizeQuad (t : ℤ × ℤ × ℤ × ℤ) : ℕ × ℕ × ℕ × ℕ :=
  let vals := [t.1.natAbs, t.2.1.natAbs, t.2.2.1.natAbs].mergeSort (· ≤ ·)
  (vals[0]!, vals[1]!, vals[2]!, t.2.2.2.natAbs)



/-- Full descent with fuel -/
def QF_fullDescent : ℕ × ℕ × ℕ × ℕ → ℕ → ℕ × ℕ × ℕ × ℕ
  | q, 0 => q
  | (a, b, c, d), n + 1 =>
    if d ≤ 1 then (a, b, c, d)
    else
      let stepped := QF_descentStep a b c d
      let q' := QF_normalizeQuad stepped
      QF_fullDescent q' n

-- Verify descent for small quadruples
#eval QF_fullDescent (1, 2, 2, 3) 10
#eval QF_fullDescent (2, 3, 6, 7) 10
#eval QF_fullDescent (4, 4, 7, 9) 10
#eval QF_fullDescent (1, 4, 8, 9) 10
#eval QF_fullDescent (3, 4, 12, 13) 10



/-- List primitive quadruples with hypotenuse ≤ N -/
def QF_listPrimQuads (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ) := do
  let d ← List.range (N + 1)
  let c ← List.range (d + 1)
  let b ← List.range (c + 1)
  let a ← List.range (b + 1)
  if b > 0 && c > 0 && d > 0 &&
     a * a + b * b + c * c == d * d &&
     Nat.gcd (Nat.gcd a b) (Nat.gcd c d) == 1
  then return (a, b, c, d)
  else .nil

-- Universal verification: all 93 primitive quadruples with d ≤ 50 descend to (0,0,1,1)
#eval (QF_listPrimQuads 50).all fun (a, b, c, d) =>
  QF_fullDescent (a, b, c, d) 30 == (0, 0, 1, 1)

#eval (QF_listPrimQuads 50).length

