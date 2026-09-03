import Mathlib
open Matrix

/-! ## Reconstructed definitions

Several catalogue files that carried the definitions used below are missing from
this repository; they are reconstructed here from the statements that are proved
in this file.  `p`, `q` are the legs of the ghost triple (rows of the Barning–Hall
matrix), `syndrome` is its Lorentz form, `ghostMatrix` the integer matrix
implementing `(a,b,c) ↦ (p,q,h)`, and `pellNum`/`compPell` the Pell and
half-companion Pell sequences. -/

/-- First leg of the ghost triple. -/
def p (a b c : ℤ) : ℤ := a + 2*b - 2*c

/-- Second leg of the ghost triple. -/
def q (a b c : ℤ) : ℤ := 2*a + b - 2*c

/-- The Pell numbers `0, 1, 2, 5, 12, 29, …`. -/
def pellNum : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | (n + 2) => 2 * pellNum (n + 1) + pellNum n

/-- The half-companion Pell numbers `1, 1, 3, 7, 17, 41, …`. -/
def compPell : ℕ → ℤ
  | 0 => 1
  | 1 => 1
  | (n + 2) => 2 * compPell (n + 1) + compPell n

theorem pellNum_rec (n : ℕ) : pellNum (n + 2) = 2 * pellNum (n + 1) + pellNum n := rfl

theorem compPell_rec (n : ℕ) : compPell (n + 2) = 2 * compPell (n + 1) + compPell n := rfl

/-- The two coupled one-step relations for the Pell pair. -/
theorem pell_steps_aux (n : ℕ) :
    pellNum (n + 1) = pellNum n + compPell n ∧
      compPell (n + 1) = compPell n + 2 * pellNum n := by
  induction n with
  | zero => exact ⟨rfl, rfl⟩
  | succ k ih =>
    obtain ⟨hP, hH⟩ := ih
    refine ⟨?_, ?_⟩
    · rw [pellNum_rec, hH]; linarith [hP]
    · rw [compPell_rec, hP]; linarith [hH]

/-- The Pell square identity `H n ^ 2 - 2 * P n ^ 2 = (-1) ^ n`. -/
theorem pell_sq_identity (n : ℕ) :
    compPell n ^ 2 - 2 * pellNum n ^ 2 = (-1 : ℤ) ^ n := by
  induction n with
  | zero => decide
  | succ k ih =>
    obtain ⟨hP, hH⟩ := pell_steps_aux k
    rw [hP, hH, pow_succ]
    linear_combination -ih

/- Original: GhostAlgebra.lean -/



def hParam (a b c : ℤ) : ℤ := 3*c - 2*(a + b)

/-- The Lorentz syndrome `p² + q² − h²` of a ghost triple. -/
def syndrome (a b c : ℤ) : ℤ := p a b c ^ 2 + q a b c ^ 2 - hParam a b c ^ 2

/-- The integer matrix implementing the ghost map `(a, b, c) ↦ (p, q, h)`. -/
def ghostMatrix : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- The ghost matrix, under its short name. -/
def M : Matrix (Fin 3) (Fin 3) ℤ := ghostMatrix

/-- First Barning–Hall matrix. -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Second Barning–Hall matrix (the inverse of the ghost matrix). -/
def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Third Barning–Hall matrix. -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Inverse of `B₁`. -/
def B₁_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Inverse of `B₃`. -/
def B₃_inv : Matrix (Fin 3) (Fin 3) ℤ := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- Closed form of the `n`-th power of the ghost matrix in Pell numbers. -/
def ghostMatrix_closed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![compPell n ^ 2, 2 * pellNum n ^ 2, -2 * pellNum n * compPell n;
     2 * pellNum n ^ 2, compPell n ^ 2, -2 * pellNum n * compPell n;
     -2 * pellNum n * compPell n, -2 * pellNum n * compPell n,
       compPell n ^ 2 + 2 * pellNum n ^ 2]

/-- The closed form is correct at the first two exponents. -/
theorem ghostMatrix_closed_verified :
    ghostMatrix ^ 0 = ghostMatrix_closed 0 ∧ ghostMatrix ^ 1 = ghostMatrix_closed 1 := by
  constructor <;>
    · ext i j
      fin_cases i <;> fin_cases j <;>
        simp [ghostMatrix, ghostMatrix_closed, pellNum, compPell, Matrix.one_apply]

/-- The ghost matrix preserves the Lorentz form `a² + b² − c²`. -/
theorem ghostMatrix_lorentz (a b c : ℤ) :
    p a b c ^ 2 + q a b c ^ 2 - hParam a b c ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [p, q, hParam]; ring

def fourthGhost (a b c : ℤ) : ℤ × ℤ × ℤ := (-p a b c, -q a b c, hParam a b c)

def invB₁ (a b c : ℤ) : ℤ × ℤ × ℤ := (p a b c, -q a b c, hParam a b c)

def invB₂ (a b c : ℤ) : ℤ × ℤ × ℤ := (p a b c, q a b c, hParam a b c)

def invB₃ (a b c : ℤ) : ℤ × ℤ × ℤ := (-p a b c, q a b c, hParam a b c)

theorem hParam_alt (a b c : ℤ) : hParam a b c = -2*a - 2*b + 3*c := by
  simp only [hParam]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Fourth Ghost Pythagorean Theorem
-- ═══════════════════════════════════════════════════════════════

/-- The (p, q, h) triple is Pythagorean when (a, b, c) is. -/
theorem pqh_pythagorean (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    (p a b c)^2 + (q a b c)^2 = (hParam a b c)^2 := by
  simp only [p, q, hParam]; nlinarith

/-- The fourth ghost (−p, −q, h) is Pythagorean when (a,b,c) is. -/
theorem fourthGhost_pythagorean (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    (fourthGhost a b c).1^2 + (fourthGhost a b c).2.1^2 =
    (fourthGhost a b c).2.2^2 := by
  show (-p a b c)^2 + (-q a b c)^2 = (hParam a b c)^2
  simp only [p, q, hParam]; nlinarith

/-- All four ghost triples share the same hypotenuse. -/
theorem all_ghosts_same_hyp (a b c : ℤ) :
    (invB₁ a b c).2.2 = hParam a b c ∧
    (invB₂ a b c).2.2 = hParam a b c ∧
    (invB₃ a b c).2.2 = hParam a b c ∧
    (fourthGhost a b c).2.2 = hParam a b c :=
  ⟨rfl, rfl, rfl, rfl⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Klein Four-Group Component Extraction
-- ═══════════════════════════════════════════════════════════════

-- B₂⁻¹ = (p, q, h): identity element of Klein group
-- B₁⁻¹ = (p, −q, h): flip q sign
-- B₃⁻¹ = (−p, q, h): flip p sign
-- Fourth = (−p, −q, h): flip both signs

theorem invB₂_fst (a b c : ℤ) : (invB₂ a b c).1 = p a b c := rfl

theorem invB₂_snd (a b c : ℤ) : (invB₂ a b c).2.1 = q a b c := rfl

theorem invB₁_fst (a b c : ℤ) : (invB₁ a b c).1 = p a b c := rfl

theorem invB₁_snd (a b c : ℤ) : (invB₁ a b c).2.1 = -q a b c := rfl

theorem invB₃_fst (a b c : ℤ) : (invB₃ a b c).1 = -p a b c := rfl

theorem invB₃_snd (a b c : ℤ) : (invB₃ a b c).2.1 = q a b c := rfl

theorem fourthGhost_fst (a b c : ℤ) : (fourthGhost a b c).1 = -p a b c := rfl

theorem fourthGhost_snd (a b c : ℤ) : (fourthGhost a b c).2.1 = -q a b c := rfl

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Branch Determination by Signs
-- ═══════════════════════════════════════════════════════════════

theorem branch1_from_signs (a b c : ℤ) (hp : 0 < p a b c) (hq : q a b c < 0)
    (hh : 0 < hParam a b c) :
    0 < (invB₁ a b c).1 ∧ 0 < (invB₁ a b c).2.1 ∧ 0 < (invB₁ a b c).2.2 := by
  refine ⟨hp, ?_, hh⟩; show 0 < -q a b c; linarith

theorem branch2_from_signs (a b c : ℤ) (hp : 0 < p a b c) (hq : 0 < q a b c)
    (hh : 0 < hParam a b c) :
    0 < (invB₂ a b c).1 ∧ 0 < (invB₂ a b c).2.1 ∧ 0 < (invB₂ a b c).2.2 :=
  ⟨hp, hq, hh⟩

theorem branch3_from_signs (a b c : ℤ) (hp : p a b c < 0) (hq : 0 < q a b c)
    (hh : 0 < hParam a b c) :
    0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2 := by
  refine ⟨?_, hq, hh⟩; show 0 < -p a b c; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Product Sign Determines Branch
-- ═══════════════════════════════════════════════════════════════

theorem pq_product_pos_branch2 (a b c : ℤ) (hp : 0 < p a b c) (hq : 0 < q a b c) :
    0 < p a b c * q a b c := mul_pos hp hq

theorem pq_product_neg_branch1 (a b c : ℤ) (hp : 0 < p a b c) (hq : q a b c < 0) :
    p a b c * q a b c < 0 := mul_neg_of_pos_of_neg hp hq

theorem pq_product_neg_branch3 (a b c : ℤ) (hp : p a b c < 0) (hq : 0 < q a b c) :
    p a b c * q a b c < 0 := mul_neg_of_neg_of_pos hp hq

-- ═══════════════════════════════════════════════════════════════
-- Section 6: p-q Algebraic Identities
-- ═══════════════════════════════════════════════════════════════

theorem pq_sum (a b c : ℤ) : p a b c + q a b c = 3*(a + b) - 4*c := by
  simp only [p, q]; ring

theorem pq_diff (a b c : ℤ) : p a b c - q a b c = b - a := by
  simp only [p, q]; ring

theorem p_mod2 (a b c : ℤ) : p a b c % 2 = a % 2 := by unfold p; omega

theorem q_mod2 (a b c : ℤ) : q a b c % 2 = b % 2 := by unfold q; omega

theorem hParam_mod2 (a b c : ℤ) : hParam a b c % 2 = c % 2 := by unfold hParam; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Contraction Property
-- ═══════════════════════════════════════════════════════════════

theorem descent_gap (a b c : ℤ) : c - hParam a b c = 2*(a + b - c) := by
  simp only [hParam]; ring

theorem ppt_triangle (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2) :
    c < a + b := by
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_abs (a + b)]

theorem hParam_lt_c (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2) :
    hParam a b c < c := by
  have := ppt_triangle a b c ha hb hpyth; have := descent_gap a b c; linarith

theorem descent_gap_ge_two (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) : 2 ≤ c - hParam a b c := by
  have := ppt_triangle a b c ha hb hpyth; rw [descent_gap]; linarith

theorem hParam_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hpyth : a^2 + b^2 = c^2)
    (hc : 5 ≤ c) : 0 < hParam a b c := by
  rw [hParam_alt]; nlinarith only [ha, hb, hpyth, hc, sq_nonneg (a - b)]

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Euclid Parameter Identities
-- ═══════════════════════════════════════════════════════════════

theorem p_euclid (m n : ℤ) :
    p (m^2 - n^2) (2*m*n) (m^2 + n^2) = -(m - n) * (m - 3*n) := by
  simp only [p]; ring

theorem q_euclid (m n : ℤ) :
    q (m^2 - n^2) (2*m*n) (m^2 + n^2) = 2*n*(m - 2*n) := by
  simp only [q]; ring

theorem hParam_euclid (m n : ℤ) :
    hParam (m^2 - n^2) (2*m*n) (m^2 + n^2) = (m - 2*n)^2 + n^2 := by
  simp only [hParam]; ring

theorem hParam_sum_of_squares (m n : ℤ) :
    ∃ u v : ℤ, hParam (m^2 - n^2) (2*m*n) (m^2 + n^2) = u^2 + v^2 :=
  ⟨m - 2*n, n, hParam_euclid m n⟩

theorem pq_product_euclid (m n : ℤ) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) * q (m^2-n^2) (2*m*n) (m^2+n^2) =
    -2*n*(m - n)*(m - 2*n)*(m - 3*n) := by rw [p_euclid, q_euclid]; ring

theorem descent_gap_euclid (m n : ℤ) :
    (m^2 + n^2) - hParam (m^2-n^2) (2*m*n) (m^2+n^2) = 4*n*(m - n) := by
  rw [hParam_euclid]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Syndrome / Error Detection
-- ═══════════════════════════════════════════════════════════════

/-- **Syndrome = Lorentz Form**: The ghost map preserves the Lorentz quadratic form.
This means p² + q² − h² = a² + b² − c². -/
theorem syndrome_eq_Q (a b c : ℤ) :
    syndrome a b c = a^2 + b^2 - c^2 := by
  simp only [syndrome, p, q, hParam]; ring

/-- A Pythagorean triple has zero syndrome. -/
theorem syndrome_zero_of_pyth (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    syndrome a b c = 0 := by
  rw [syndrome_eq_Q]; linarith

/-- If the syndrome is nonzero, the triple is NOT Pythagorean.
This gives single-query error detection for corrupted triples. -/
theorem not_pyth_of_syndrome_ne (a b c : ℤ) (hs : syndrome a b c ≠ 0) :
    a^2 + b^2 ≠ c^2 := fun hp => hs (syndrome_zero_of_pyth a b c hp)

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Double Descent (M² Formulas)
-- ═══════════════════════════════════════════════════════════════

/-- Double descent p: applying p to (p,q,h) gives 9a + 8b − 12c. -/
theorem double_descent_p (a b c : ℤ) :
    p (p a b c) (q a b c) (hParam a b c) = 9*a + 8*b - 12*c := by
  simp only [p, q, hParam]; ring

/-- Double descent q: applying q to (p,q,h) gives 8a + 9b − 12c. -/
theorem double_descent_q (a b c : ℤ) :
    q (p a b c) (q a b c) (hParam a b c) = 8*a + 9*b - 12*c := by
  simp only [p, q, hParam]; ring

/-- Double descent h: applying h to (p,q,h) gives −12a − 12b + 17c. -/
theorem double_descent_hParam (a b c : ℤ) :
    hParam (p a b c) (q a b c) (hParam a b c) = -12*a - 12*b + 17*c := by
  simp only [p, q, hParam]; ring

/-- The double-descent p and q differ by b − a (same as single descent). -/
theorem double_descent_pq_diff (a b c : ℤ) :
    p (p a b c) (q a b c) (hParam a b c) -
    q (p a b c) (q a b c) (hParam a b c) = a - b := by
  rw [double_descent_p, double_descent_q]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Leg Swap
-- ═══════════════════════════════════════════════════════════════

theorem p_swap (a b c : ℤ) : p b a c = q a b c := by simp only [p, q]; ring

theorem q_swap (a b c : ℤ) : q b a c = p a b c := by simp only [p, q]; ring

theorem hParam_swap (a b c : ℤ) : hParam b a c = hParam a b c := by
  simp only [hParam]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Concrete Fourth Ghost Examples
-- ═══════════════════════════════════════════════════════════════

/-- Fourth ghost of (3,4,5) is (−1, 0, 1). -/
theorem fourthGhost_345 : fourthGhost 3 4 5 = (-1, 0, 1) := by decide

/-- Fourth ghost of (5,12,13) is (−3, 4, 5). -/
theorem fourthGhost_51213 : fourthGhost 5 12 13 = (-3, 4, 5) := by decide

/-- Fourth ghost of (8,15,17) is (−4, 3, 5). -/
theorem fourthGhost_81517 : fourthGhost 8 15 17 = (-4, 3, 5) := by decide

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Ghost Map = B₂⁻¹ (Matrix Form)
-- ═══════════════════════════════════════════════════════════════

/-- The ghost map (a,b,c) ↦ (p,q,h) is exactly B₂⁻¹. -/
theorem ghost_map_is_B₂_inv (a b c : ℤ) :
    (p a b c, q a b c, hParam a b c) = invB₂ a b c := rfl

/-- M² = !![9, 8, -12; 8, 9, -12; -12, -12, 17]. -/
theorem ghostMatrix_sq :
    ghostMatrix * ghostMatrix = !![9, 8, -12; 8, 9, -12; -12, -12, 17] := by native_decide

/-- Trace of M² is 35. -/
theorem ghostMatrix_sq_trace : Matrix.trace (ghostMatrix * ghostMatrix) = 35 := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Quadratic Form Boundaries
-- ═══════════════════════════════════════════════════════════════

/-- At the boundary m = 2n: q = 0 (root case). -/
theorem boundary_m_eq_2n (n : ℤ) :
    q ((2*n)^2 - n^2) (2*(2*n)*n) ((2*n)^2 + n^2) = 0 := by simp only [q]; ring

/-- At the boundary m = 3n: p = 0. -/
theorem boundary_m_eq_3n (n : ℤ) :
    p ((3*n)^2 - n^2) (2*(3*n)*n) ((3*n)^2 + n^2) = 0 := by simp only [p]; ring

theorem root_is_boundary : (2:ℤ)^2 - 1^2 = 3 ∧ 2*(2:ℤ)*1 = 4 ∧ (2:ℤ)^2 + 1^2 = 5 := by
  norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Branch Uniqueness
-- ═══════════════════════════════════════════════════════════════

/-- If p > 0 and q > 0, then B₁⁻¹ and B₃⁻¹ fail to produce all-positive. -/
theorem branch2_unique (a b c : ℤ) (hp : 0 < p a b c) (hq : 0 < q a b c) :
    ¬(0 < (invB₁ a b c).2.1) ∧ ¬(0 < (invB₃ a b c).1) := by
  constructor
  · show ¬(0 < -q a b c); linarith
  · show ¬(0 < -p a b c); linarith

/-- If p > 0 and q < 0, then B₂⁻¹ and B₃⁻¹ fail. -/
theorem branch1_unique (a b c : ℤ) (hp : 0 < p a b c) (hq : q a b c < 0) :
    ¬(0 < (invB₂ a b c).2.1) ∧ ¬(0 < (invB₃ a b c).1) := by
  constructor
  · show ¬(0 < q a b c); linarith
  · show ¬(0 < -p a b c); linarith

/-- If p < 0 and q > 0, then B₁⁻¹ and B₂⁻¹ fail. -/
theorem branch3_unique (a b c : ℤ) (hp : p a b c < 0) (_hq : 0 < q a b c) :
    ¬(0 < (invB₁ a b c).1) ∧ ¬(0 < (invB₂ a b c).1) := by
  constructor
  · show ¬(0 < p a b c); linarith
  · show ¬(0 < p a b c); linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 16: p·q Root Structure
-- ═══════════════════════════════════════════════════════════════

/-- p·q vanishes at exactly the branch boundaries m = n, m = 2n, m = 3n
(given n ≠ 0). -/
theorem pq_zero_iff_boundary (m n : ℤ) (hn : n ≠ 0) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) * q (m^2-n^2) (2*m*n) (m^2+n^2) = 0 ↔
    m = n ∨ m = 2*n ∨ m = 3*n := by
  rw [pq_product_euclid]
  constructor
  · intro hprod
    have : n * ((m - n) * ((m - 2*n) * (m - 3*n))) = 0 := by nlinarith
    rcases mul_eq_zero.mp this with h1 | h1
    · exact absurd h1 hn
    · rcases mul_eq_zero.mp h1 with h2 | h2
      · left; linarith
      · rcases mul_eq_zero.mp h2 with h3 | h3
        · right; left; linarith
        · right; right; linarith
  · rintro (rfl | rfl | rfl) <;> ring

-- ═══════════════════════════════════════════════════════════════
-- Section 17: Euclid Branch Conditions
-- ═══════════════════════════════════════════════════════════════

theorem euclid_branch1_signs (m n : ℤ) (hn : 0 < n) (h1 : n < m) (h2 : m < 2*n) :
    0 < p (m^2-n^2) (2*m*n) (m^2+n^2) ∧
    q (m^2-n^2) (2*m*n) (m^2+n^2) < 0 := by
  rw [p_euclid, q_euclid]; constructor <;> nlinarith

theorem euclid_branch2_signs (m n : ℤ) (hn : 0 < n) (h1 : 2*n < m) (h2 : m < 3*n) :
    0 < p (m^2-n^2) (2*m*n) (m^2+n^2) ∧
    0 < q (m^2-n^2) (2*m*n) (m^2+n^2) := by
  rw [p_euclid, q_euclid]; constructor <;> nlinarith

theorem euclid_branch3_signs (m n : ℤ) (hn : 0 < n) (h1 : 3*n < m) :
    p (m^2-n^2) (2*m*n) (m^2+n^2) < 0 ∧
    0 < q (m^2-n^2) (2*m*n) (m^2+n^2) := by
  rw [p_euclid, q_euclid]; constructor <;> nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 18: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms fourthGhost_pythagorean
#print axioms syndrome_eq_Q
#print axioms double_descent_p
#print axioms ghostMatrix_lorentz
#print axioms pq_zero_iff_boundary

/- Original: GhostMatrixInduction.lean -/



/-- [Section: ### Step relations for Pell sequences] -/
theorem compPell_step (n : ℕ) :
    compPell (n + 1) = compPell n + 2 * pellNum n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
  linarith! [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), pellNum_rec n, pellNum_rec ( n + 1 ), compPell_rec n, compPell_rec ( n + 1 ) ]

theorem pellNum_step (n : ℕ) :
    pellNum (n + 1) = pellNum n + compPell n := by
  induction' n with n ih;
  · rfl;
  · rw [ pellNum_rec, compPell_step ] ; linarith

/-- [Section: ### Quadratic step identities] -/
theorem compPell_sq_step (n : ℕ) :
    compPell (n + 1) ^ 2 = 3 * compPell n ^ 2 + 4 * pellNum n * compPell n - 2 * (-1 : ℤ) ^ n := by
  rw [ ← pell_sq_identity ] ; rw [ compPell_step ] ; ring;

theorem pellNum_compPell_step (n : ℕ) :
    pellNum (n + 1) * compPell (n + 1) =
    3 * pellNum n * compPell n + 2 * compPell n ^ 2 - (-1 : ℤ) ^ n := by
  rw [ pellNum_step, compPell_step ];
  linarith [ pell_sq_identity n ]

/-- [Section: ### The matrix recurrence] -/
theorem ghostMatrix_closed_mul_step (n : ℕ) :
    ghostMatrix_closed n * ghostMatrix = ghostMatrix_closed (n + 1) := by
  obtain ⟨hP, hH⟩ := pell_steps_aux n
  unfold ghostMatrix_closed ghostMatrix
  rw [hP, hH]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

/-- **Main theorem**: M^n = ghostMatrix_closed n for all n ∈ ℕ. -/
theorem ghostMatrix_pow_eq_closed (n : ℕ) :
    ghostMatrix ^ n = ghostMatrix_closed n := by
  induction n with
  | zero =>
    exact ghostMatrix_closed_verified.1
  | succ n ih =>
    rw [pow_succ, ih, ghostMatrix_closed_mul_step]

/- Original: GhostMatrixPowers.lean -/



/-- [Section: ## Inverse Relations] -/
theorem M_B₂_inv : M * B₂ = 1 := by native_decide

theorem B₂_M_inv : B₂ * M = 1 := by native_decide

theorem B₁_inv_left : B₁_inv * B₁ = 1 := by native_decide

theorem B₁_inv_right : B₁ * B₁_inv = 1 := by native_decide

theorem B₃_inv_left : B₃_inv * B₃ = 1 := by native_decide

theorem B₃_inv_right : B₃ * B₃_inv = 1 := by native_decide

/-- M⁴ explicit form -/
theorem M_pow4 : M ^ 4 = !![289, 288, (-408); 288, 289, (-408); (-408), (-408), 577] := by
  native_decide

/-- M⁵ explicit form -/
theorem M_pow5 : M ^ 5 =
    !![1681, 1682, (-2378); 1682, 1681, (-2378); (-2378), (-2378), 3363] := by
  native_decide

/-- [Section: ## Trace of Powers] -/
theorem trace_M1 : trace M = 5 := by native_decide

theorem trace_M2 : trace (M ^ 2) = 35 := by native_decide

theorem trace_M3 : trace (M ^ 3) = 197 := by native_decide

theorem trace_M4 : trace (M ^ 4) = 1155 := by native_decide

theorem trace_M5 : trace (M ^ 5) = 6725 := by native_decide

/-- From Cayley-Hamilton: tr(M^{n+3}) = 5·tr(M^{n+2}) + 5·tr(M^{n+1}) - tr(M^n) -/
theorem trace_recurrence :
    trace (M ^ 3) = 5 * trace (M ^ 2) + 5 * trace M - trace (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

theorem trace_recurrence_4 :
    trace (M ^ 4) = 5 * trace (M ^ 3) + 5 * trace (M ^ 2) - trace M := by
  native_decide

theorem trace_recurrence_5 :
    trace (M ^ 5) = 5 * trace (M ^ 4) + 5 * trace (M ^ 3) - trace (M ^ 2) := by
  native_decide

theorem char_poly_factor (x : ℤ) :
    x ^ 3 - 5 * x ^ 2 - 5 * x + 1 = (x + 1) * (x ^ 2 - 6 * x + 1) := by ring

/-- Children of (3,4,5) under B₁, B₂, B₃ -/
theorem child_B1 : B₁.mulVec ![3, 4, 5] = ![5, 12, 13] := by native_decide

/-- [Section: ## Berggren Tree Properties] -/
theorem child_B2 : B₂.mulVec ![3, 4, 5] = ![21, 20, 29] := by native_decide

theorem child_B3 : B₃.mulVec ![3, 4, 5] = ![15, 8, 17] := by native_decide

/-- All children are Pythagorean -/
theorem child_B1_pyth : (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num

theorem child_B2_pyth : (21 : ℤ) ^ 2 + 20 ^ 2 = 29 ^ 2 := by norm_num

theorem child_B3_pyth : (15 : ℤ) ^ 2 + 8 ^ 2 = 17 ^ 2 := by norm_num

/-- Ghost map sends (3,4,5) to (1,0,1) -/
theorem ghost_345 : M.mulVec ![3, 4, 5] = ![1, 0, 1] := by native_decide

/-- Second ghost ancestor of (3,4,5) -/
theorem ghost2_345 : (M ^ 2).mulVec ![3, 4, 5] = ![-1, 0, 1] := by native_decide

/-- Third ghost ancestor: M³(3,4,5) = (-3,-4,5) (legs negated, hypotenuse same) -/
theorem ghost3_345 : (M ^ 3).mulVec ![3, 4, 5] = ![-3, -4, 5] := by native_decide

/-- For PPT (a,b,c) with positive legs and c≥5, ghost hypotenuse < c -/
theorem ghost_hyp_descent (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hbig : 5 ≤ c) :
    -2 * a - 2 * b + 3 * c < c := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg (a + b - c)]

/-- Non-commutativity of Berggren matrices -/
theorem B₁B₂_ne_B₂B₁ : B₁ * B₂ ≠ B₂ * B₁ := by native_decide

/-- [Section: ## Semigroup Structure] -/
theorem B₁B₃_ne_B₃B₁ : B₁ * B₃ ≠ B₃ * B₁ := by native_decide

theorem B₂B₃_ne_B₃B₂ : B₂ * B₃ ≠ B₃ * B₂ := by native_decide

/-- M has -1 as an eigenvalue: (M+I) is singular -/
theorem M_eigenvalue_neg1 : det (M + 1) = 0 := by native_decide

/-- The eigenvalue -1 eigenvector is (1,-1,0) -/
theorem M_eigenvec_neg1 : M.mulVec ![1, -1, 0] = ![-1, 1, 0] := by native_decide

/-- (1,-1,0) is indeed a -1 eigenvector -/
theorem M_eigenvec_neg1' : M.mulVec ![1, -1, 0] = (-1 : ℤ) • ![1, -1, 0] := by native_decide

/- Original: GhostStructure4D.lean -/



/-- A Pythagorean quadruple satisfies a² + b² + c² = d². -/
def isPQ (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2

/-- The 4D Lorentz form Q₄(a,b,c,d) = a² + b² + c² - d². -/
def LQ4 (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2

/-- A quadruple is Pythagorean iff the Lorentz form vanishes. -/
theorem isPQ_iff_LQ4 (a b c d : ℤ) :
    isPQ a b c d ↔ LQ4 a b c d = 0 := by
  simp [isPQ, LQ4]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 2: (ℤ/2)³ Sign-Flip Symmetry
-- ═══════════════════════════════════════════════════════════════

/-- [Section: # Four-Dimensional Pythagorean Quadruples: Ghost Structure
For Pythagorean quadruples a² + b² + c² = d², we establish:
1. **(ℤ/2)³ Sign-Flip Symmetry**: Sign flips of spatial components preserve the equation
2. **S₃ Permutation Symmetry**: Permuting spatial components preserves the equation
3. **Lifted 3D Ghost Structure**: The Berggren inverse lifts to 4D via 3 lifting planes
4. **O(3,1;ℤ) Matrix Verification**: Lifted matrices are in the integer Lorentz group
5. **Hypotenuse Descent**: Conditions for the parent hypotenuse to decrease
## Key Discovery: 4D Ghost Structure is Richer Than 3D
In 3D, all three Berggren inverse images share a universal parent hypotenuse.
In 4D, there are THREE families of parent hypotenuses (one per lifting plane),
and the descent depends on choosing the right plane. The full ghost group is
S₃ × (ℤ/2)², giving 24 ghost images (vs. 4 in 3D).] -/
theorem sf1 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) b c d := by
  unfold isPQ at *; nlinarith

theorem sf2 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a (-b) c d := by
  unfold isPQ at *; nlinarith

theorem sf3 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a b (-c) d := by
  unfold isPQ at *; nlinarith

theorem sf12 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) (-b) c d := by
  unfold isPQ at *; nlinarith

theorem sf13 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) b (-c) d := by
  unfold isPQ at *; nlinarith

theorem sf23 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a (-b) (-c) d := by
  unfold isPQ at *; nlinarith

theorem sf123 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) (-b) (-c) d := by
  unfold isPQ at *; nlinarith

/-- All 8 sign patterns preserve the quadruple equation ((ℤ/2)³ action). -/
theorem octahedral_ghost (a b c d : ℤ) (h : isPQ a b c d)
    (s₁ s₂ s₃ : ℤ) (hs₁ : s₁ = 1 ∨ s₁ = -1) (hs₂ : s₂ = 1 ∨ s₂ = -1)
    (hs₃ : s₃ = 1 ∨ s₃ = -1) :
    isPQ (s₁ * a) (s₂ * b) (s₃ * c) d := by
  simp [isPQ] at *
  rcases hs₁ with rfl | rfl <;> rcases hs₂ with rfl | rfl <;> rcases hs₃ with rfl | rfl <;>
    nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: S₃ Permutation Symmetry
-- ═══════════════════════════════════════════════════════════════

theorem pm12 (a b c d : ℤ) (h : isPQ a b c d) : isPQ b a c d := by
  simp only [isPQ] at *; linarith

theorem pm13 (a b c d : ℤ) (h : isPQ a b c d) : isPQ c b a d := by
  simp only [isPQ] at *; linarith

theorem pm23 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a c b d := by
  simp only [isPQ] at *; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Lorentz Form Properties
-- ═══════════════════════════════════════════════════════════════

theorem LQ4_sf1 (a b c d : ℤ) : LQ4 (-a) b c d = LQ4 a b c d := by
  unfold LQ4; ring

theorem LQ4_sf2 (a b c d : ℤ) : LQ4 a (-b) c d = LQ4 a b c d := by
  unfold LQ4; ring

theorem LQ4_sf3 (a b c d : ℤ) : LQ4 a b (-c) d = LQ4 a b c d := by
  unfold LQ4; ring

theorem LQ4_pm12 (a b c d : ℤ) : LQ4 b a c d = LQ4 a b c d := by
  unfold LQ4; ring

theorem LQ4_pm23 (a b c d : ℤ) : LQ4 a c b d = LQ4 a b c d := by
  unfold LQ4; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Lebesgue Parametrization
-- ═══════════════════════════════════════════════════════════════

/-- The Lebesgue parametrization of Pythagorean quadruples. -/
def lebParam (m n p q : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (m^2 + n^2 - p^2 - q^2, 2*(m*q + n*p), 2*(n*q - m*p), m^2 + n^2 + p^2 + q^2)

/-- The Lebesgue parametrization always produces a Pythagorean quadruple. -/
theorem leb_is_pq (m n p q : ℤ) :
    isPQ (lebParam m n p q).1 (lebParam m n p q).2.1
         (lebParam m n p q).2.2.1 (lebParam m n p q).2.2.2 := by
  simp [lebParam, isPQ]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Lifted 3D Berggren Inverse to 4D
-- ═══════════════════════════════════════════════════════════════

/-- B₂⁻¹ lifted in the (1,2) plane: transforms (a,b) w.r.t. d, fixing c. -/
def lift12 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a + 2*b - 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)

/-- B₁⁻¹ lifted in the (1,2) plane. -/
def lift12_B1 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a + 2*b - 2*d, -2*a - b + 2*d, c, -2*a - 2*b + 3*d)

/-- B₃⁻¹ lifted in the (1,2) plane. -/
def lift12_B3 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)

/-- B₂⁻¹ lifted in the (1,3) plane: transforms (a,c) w.r.t. d, fixing b. -/
def lift13 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a + 2*c - 2*d, b, 2*a + c - 2*d, -2*a - 2*c + 3*d)

/-- B₂⁻¹ lifted in the (2,3) plane: transforms (b,c) w.r.t. d, fixing a. -/
def lift23 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a, b + 2*c - 2*d, 2*b + c - 2*d, -2*b - 2*c + 3*d)

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Lorentz Form Preservation
-- ═══════════════════════════════════════════════════════════════

theorem lift12_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift12 a b c d).1 (lift12 a b c d).2.1
        (lift12 a b c d).2.2.1 (lift12 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift12]; ring

theorem lift12_B1_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift12_B1 a b c d).1 (lift12_B1 a b c d).2.1
        (lift12_B1 a b c d).2.2.1 (lift12_B1 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift12_B1]; ring

theorem lift12_B3_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift12_B3 a b c d).1 (lift12_B3 a b c d).2.1
        (lift12_B3 a b c d).2.2.1 (lift12_B3 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift12_B3]; ring

theorem lift13_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift13 a b c d).1 (lift13 a b c d).2.1
        (lift13 a b c d).2.2.1 (lift13 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift13]; ring

theorem lift23_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift23 a b c d).1 (lift23 a b c d).2.1
        (lift23 a b c d).2.2.1 (lift23 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift23]; ring

-- Corollaries: preservation of quadruples.

theorem lift12_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift12 a b c d).1 (lift12 a b c d).2.1
         (lift12 a b c d).2.2.1 (lift12 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift12_preserves_LQ4]; exact h

theorem lift12_B1_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift12_B1 a b c d).1 (lift12_B1 a b c d).2.1
         (lift12_B1 a b c d).2.2.1 (lift12_B1 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift12_B1_preserves_LQ4]; exact h

theorem lift12_B3_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift12_B3 a b c d).1 (lift12_B3 a b c d).2.1
         (lift12_B3 a b c d).2.2.1 (lift12_B3 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift12_B3_preserves_LQ4]; exact h

theorem lift13_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift13 a b c d).1 (lift13 a b c d).2.1
         (lift13 a b c d).2.2.1 (lift13 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift13_preserves_LQ4]; exact h

theorem lift23_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift23 a b c d).1 (lift23 a b c d).2.1
         (lift23 a b c d).2.2.1 (lift23 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift23_preserves_LQ4]; exact h

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Ghost Structure of Lifted Transforms
-- ═══════════════════════════════════════════════════════════════

/-- All (1,2)-lifted transforms share the same hypotenuse. -/
theorem lift12_same_hyp (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 = (lift12_B1 a b c d).2.2.2 ∧
    (lift12_B1 a b c d).2.2.2 = (lift12_B3 a b c d).2.2.2 := by
  simp [lift12, lift12_B1, lift12_B3]

/-- All (1,2)-lifted transforms fix the third coordinate c. -/
theorem lift12_same_c (a b c d : ℤ) :
    (lift12 a b c d).2.2.1 = c ∧
    (lift12_B1 a b c d).2.2.1 = c ∧
    (lift12_B3 a b c d).2.2.1 = c := by
  simp [lift12, lift12_B1, lift12_B3]

/-- B₁⁻¹ and B₂⁻¹ share first component (p-parameter). -/
theorem lift12_B1_B2_share_fst (a b c d : ℤ) :
    (lift12_B1 a b c d).1 = (lift12 a b c d).1 := by
  simp [lift12_B1, lift12]

/-- B₂⁻¹ and B₃⁻¹ share second component (q-parameter). -/
theorem lift12_B2_B3_share_snd (a b c d : ℤ) :
    (lift12 a b c d).2.1 = (lift12_B3 a b c d).2.1 := by
  simp [lift12, lift12_B3]

/-- B₁⁻¹ and B₂⁻¹ have opposite second components. -/
theorem lift12_B1_B2_opp_snd (a b c d : ℤ) :
    (lift12_B1 a b c d).2.1 = -(lift12 a b c d).2.1 := by
  simp [lift12_B1, lift12]; ring

/-- B₂⁻¹ and B₃⁻¹ have opposite first components. -/
theorem lift12_B2_B3_opp_fst (a b c d : ℤ) :
    (lift12_B3 a b c d).1 = -(lift12 a b c d).1 := by
  simp [lift12_B3, lift12]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Three Different Parent Hypotenuses in 4D
-- ═══════════════════════════════════════════════════════════════

theorem hyp12_def (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 = -2*a - 2*b + 3*d := by
  simp [lift12]

theorem hyp13_def (a b c d : ℤ) :
    (lift13 a b c d).2.2.2 = -2*a - 2*c + 3*d := by
  simp [lift13]

theorem hyp23_def (a b c d : ℤ) :
    (lift23 a b c d).2.2.2 = -2*b - 2*c + 3*d := by
  simp [lift23]

/-- The three hypotenuses differ by leg differences. -/
theorem hyp12_minus_hyp13 (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 - (lift13 a b c d).2.2.2 = 2*(c - b) := by
  simp [lift12, lift13]; ring

theorem hyp12_minus_hyp23 (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 - (lift23 a b c d).2.2.2 = 2*(c - a) := by
  simp [lift12, lift23]; ring

theorem hyp13_minus_hyp23 (a b c d : ℤ) :
    (lift13 a b c d).2.2.2 - (lift23 a b c d).2.2.2 = 2*(b - a) := by
  simp [lift13, lift23]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Descent in 4D
-- ═══════════════════════════════════════════════════════════════

/-- The (2,3)-lift hypotenuse decreases when b + c > d. -/
theorem hyp23_decrease (b c d : ℤ) (hbc : b + c > d) :
    -2*b - 2*c + 3*d < d := by linarith

/-- For a positive PQ quadruple the spatial components satisfy the strict triangle
inequality `a + b + c > d`.  (Supplied here: it was referenced but missing.) -/
theorem pq_triangle (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hq : isPQ a b c d) (hd : 0 < d) : a + b + c > d := by
  unfold isPQ at hq
  nlinarith [mul_pos ha hb, mul_pos ha hc, mul_pos hb hc]

theorem descent_exists (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hq : isPQ a b c d) (hd : 0 < d) :
    -2*a - 2*b + 3*d < d ∨ -2*a - 2*c + 3*d < d ∨ -2*b - 2*c + 3*d < d := by
  have htri := pq_triangle a b c d ha hb hc hq hd
  by_contra hno
  push_neg at hno
  obtain ⟨h1, h2, h3⟩ := hno
  -- h1: d ≤ -2a - 2b + 3d, i.e., 2a + 2b ≤ 2d
  -- h2: d ≤ -2a - 2c + 3d, i.e., 2a + 2c ≤ 2d
  -- h3: d ≤ -2b - 2c + 3d, i.e., 2b + 2c ≤ 2d
  -- Adding all three: 4(a+b+c) ≤ 6d, i.e., 2(a+b+c) ≤ 3d.
  -- But a+b+c > d, so 2d < 2(a+b+c) ≤ 3d, giving 2d < 3d, i.e., d > 0.
  -- Actually that's not a contradiction. Let me be more careful.
  -- h1 + h2 + h3: 3d ≤ -4a - 4b - 4c + 9d, i.e., 4(a+b+c) ≤ 6d.
  -- But a+b+c > d means 4(a+b+c) > 4d, so 4d < 6d, which is true for d > 0.
  -- So this approach doesn't work directly. Let me think differently.
  -- Actually: the sum of any two spatial components must exceed d for some pair.
  -- From htri: a + b + c > d.
  -- Suppose a + b ≤ d, a + c ≤ d, b + c ≤ d.
  -- Then 2(a+b+c) = (a+b) + (a+c) + (b+c) ≤ 3d.
  -- But also a+b+c > d.
  -- Example: a=1, b=1, c=1, d=1.5. Then a+b+c = 3 > 1.5,
  -- but a+b = 2 > 1.5. So in some cases the hypothesis holds.
  -- Actually for quadruples: (1,2,2,3). a+b=3=d, a+c=3=d, b+c=4>3.
  -- So b+c > d but a+b = d. So at least one pair works.
  -- Can we have all three ≤ d? That would require 2(a+b+c) ≤ 3d.
  -- With a²+b²+c² = d², we need to check...
  -- By AM-QM: (a+b+c)/3 ≥ 1 (if all positive) but this isn't strong enough.
  -- Actually consider a=b=c. Then 3a²=d², d = a√3.
  -- a+b = 2a, d = a√3 ≈ 1.73a. So a+b = 2a > 1.73a = d. ✓
  -- So for the equal case, a+b > d.
  -- For very skewed: a=ε, b=ε, c=d-ε'. Then ε²+ε²+(d-ε')² = d².
  -- 2ε² + d² - 2dε' + ε'² = d². So 2ε² + ε'² = 2dε'. For small ε,
  -- ε' ≈ ε²/(2d). Then b+c ≈ ε + d > d. But a+b ≈ 2ε < d.
  -- And a+c ≈ ε + d > d.
  -- So we can have a+b < d when a is small.
  -- But b+c > d. Let me try: does at least one pair exceed d?
  -- From a+b+c > d and all positive: Suppose a ≤ b ≤ c.
  -- Then b+c ≥ 2c/1... Actually a+b+c > d and a ≤ b, a ≤ c gives
  -- b+c ≥ 2a, and a+b+c > d, so b+c > d - a.
  -- We need b+c > d. Can b+c ≤ d? Then a > 0, b+c ≤ d, a+b+c > d.
  -- So a > d - b - c ≥ 0.
  -- From a²+b²+c² = d²: a² = d² - b² - c².
  -- a² = d² - b² - c² = (d-b)(d+b) - c² ≤ (d-b)(d+b).
  -- Not sure this leads anywhere directly.
  -- Let me just prove: for all positive PQ, b+c > d (where a ≤ b ≤ c).
  -- a² + b² + c² = d². Since a ≤ c, a² ≤ c².
  -- So d² = a²+b²+c² ≤ 2c²+b². Also d² ≥ b²+c².
  -- (b+c)² = b²+2bc+c² = d²-a²+2bc ≥ d²+2bc-c² ≥ d² (if b ≥ 0).
  -- Actually (b+c)² = b²+c²+2bc = d²-a²+2bc > d²-a² (since bc > 0).
  -- And d²-a² < d². So (b+c)² > d²-a².
  -- We need (b+c)² > d². That means d²-a²+2bc > d², i.e., 2bc > a².
  -- Is this always true? For a=b=c: 2a² > a². Yes.
  -- For a=1, b=2, c=2, d=3: 2*2*2=8 > 1. Yes.
  -- For a=1, b=1, c=1: not a quadruple.
  -- For a small: 2bc > a² when bc > a²/2. Since a ≤ b ≤ c, bc ≥ a², so yes!
  -- bc ≥ a·a = a² (since b ≥ a and c ≥ a). So 2bc ≥ 2a² > a². ✓
  -- This means (b+c)² > d² when a ≤ b ≤ c, so b+c > d!
  -- Let me prove this properly.
  have h_sq : (b + c)^2 > d^2 := by
    gcongr ; nlinarith [ hq.symm ];
  nlinarith only [ ha, hb, hc, hd, htri, h1, h2, h3, h_sq ]

-- ═══════════════════════════════════════════════════════════════
-- Section 11: O(3,1;ℤ) Matrix Verification
-- ═══════════════════════════════════════════════════════════════

/-- The Lorentz metric η = diag(1,1,1,-1). -/
def eta4D : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, (-1)]

def inO31 (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M.transpose * eta4D * M = eta4D

/-- Matrix form of lift12 (B₂⁻¹ in (1,2) plane). -/
def mLift12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 2, 0, (-2); 2, 1, 0, (-2); 0, 0, 1, 0; (-2), (-2), 0, 3]

theorem mLift12_in_O31 : inO31 mLift12 := by
  unfold inO31 mLift12 eta4D; native_decide

/-- Matrix form of lift13 (B₂⁻¹ in (1,3) plane). -/
def mLift13 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 2, (-2); 0, 1, 0, 0; 2, 0, 1, (-2); (-2), 0, (-2), 3]

theorem mLift13_in_O31 : inO31 mLift13 := by
  unfold inO31 mLift13 eta4D; native_decide

/-- Matrix form of lift23 (B₂⁻¹ in (2,3) plane). -/
def mLift23 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 2, (-2); 0, 2, 1, (-2); 0, (-2), (-2), 3]

theorem mLift23_in_O31 : inO31 mLift23 := by
  unfold inO31 mLift23 eta4D; native_decide

/-- The lifted transforms don't commute (nonabelian structure). -/
theorem lifts_noncommutative : mLift12 * mLift13 ≠ mLift13 * mLift12 := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Embedding 3D into 4D
-- ═══════════════════════════════════════════════════════════════

theorem triple_embeds (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    isPQ a b 0 c := by
  simp [isPQ]; linarith

theorem combine_triples_pq (a b c d e : ℤ)
    (h1 : a ^ 2 + b ^ 2 = e ^ 2) (h2 : e ^ 2 + c ^ 2 = d ^ 2) :
    isPQ a b c d := by
  simp [isPQ]; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Concrete Examples
-- ═══════════════════════════════════════════════════════════════

theorem pq_1_2_2_3 : isPQ 1 2 2 3 := by unfold isPQ; norm_num

theorem pq_2_3_6_7 : isPQ 2 3 6 7 := by unfold isPQ; norm_num

theorem pq_1_4_8_9 : isPQ 1 4 8 9 := by unfold isPQ; norm_num

theorem pq_4_4_7_9 : isPQ 4 4 7 9 := by unfold isPQ; norm_num

-- (2,3,6,7): the (1,3)-lift gives descent to hypotenuse 5.

theorem descent_1_4_8_9 :
    lift23 1 4 8 9 = (1, 2, -2, 3) := by simp [lift23]

-- Verify descended quadruples

theorem descended_0_3_m4_5 : isPQ 0 3 (-4) 5 := by unfold isPQ; norm_num

theorem descended_1_2_m2_3 : isPQ 1 2 (-2) 3 := by unfold isPQ; norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Parity in 4D Lifting
-- ═══════════════════════════════════════════════════════════════

theorem lift12_par_a (a b c d : ℤ) :
    (lift12 a b c d).1 % 2 = a % 2 := by
  show (a + 2 * b - 2 * d) % 2 = a % 2; omega

theorem lift12_par_b (a b c d : ℤ) :
    (lift12 a b c d).2.1 % 2 = b % 2 := by
  show (2 * a + b - 2 * d) % 2 = b % 2; omega

theorem lift12_par_c (a b c d : ℤ) :
    (lift12 a b c d).2.2.1 % 2 = c % 2 := by rfl

theorem lift12_par_d (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 % 2 = d % 2 := by
  show (-2 * a - 2 * b + 3 * d) % 2 = d % 2; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Ghost Group Order by Dimension
-- ═══════════════════════════════════════════════════════════════

theorem ghost_group_3d : 2 * (2 ^ 2 : ℕ) = 8 := by norm_num

theorem ghost_group_4d : 6 * (2 ^ 3 : ℕ) = 48 := by norm_num

theorem ghost_group_5d : 24 * (2 ^ 4 : ℕ) = 384 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 16: Axiom Check
-- ═══════════════════════════════════════════════════════════════

#print axioms octahedral_ghost
#print axioms lift12_preserves_PQ
#print axioms lift13_preserves_PQ
#print axioms lift23_preserves_PQ
#print axioms mLift12_in_O31
#print axioms pq_triangle